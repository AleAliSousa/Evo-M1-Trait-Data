# Korbo__1999_Text.R -------------------------------------------------------------
#
# Korbo L (1999), Glial cell loss in the hippocampus of alcoholics.
# Alcohol Clin Exp Res 23(1): 164-168.
# Glial-cell values printed only in the RESULTS text (pp. 165-166, PDF pages 2-3).
#
# Reads the constructed snapshot Korbo__1999_Text_snapshot.csv (one record per printed
# value, with its verbatim sentence; transcribed from the page images) and:
#   - parses the printed value and unit; keeps the printed group wording and adds a
#     group role (healthy control / alcoholic / alcoholic-vs-control comparison);
#   - adds the absolute control glia total (256 million -> cells);
#   - DERIVES the control astrocyte / oligodendrocyte / microglia numbers as
#     total x printed percentage (rows D01-D03, flagged derived = 1; the paper does
#     not print them);
#   - checks that the three printed percentages add to 100 (table_checks);
#   - writes the analysis CSV and, once registered, the public TSV.
#
# No printed value is typed in this script.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base <- item_name

suppressPackageStartupMessages(library(readxl))

## ---- read the frozen snapshot (positional; every cell as printed text) -------
snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE,
                           colClasses = "character", na.strings = character(0),
                           check.names = FALSE, fileEncoding = "UTF-8"))
dimnames(snap) <- NULL

## ---- helpers -----------------------------------------------------------------
## "80,900 (0.12)" -> value 80900, paren 0.12. Thousands commas stripped; a dash
## or blank cell is missing (never zero).
na_tokens <- c("", "-", "\u2013", "\u2014", "NA", "n.a.", "__", "e")
cell_value <- function(x) {
  v <- trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x))
  out <- suppressWarnings(as.numeric(gsub(",", "", v)))
  out[v %in% na_tokens] <- NA_real_
  out
}
cell_value_string <- function(x) gsub(",", "", trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x)))
cell_paren <- function(x) {
  p <- ifelse(grepl("\\(", x), sub("^.*\\(([^)]*)\\).*$", "\\1", x), NA_character_)
  suppressWarnings(as.numeric(p))
}
## half a unit in the last significant printed digit ("34,000" -> 500; "0.042" -> 0.0005)
half_unit <- function(s) {
  s <- cell_value_string(s)
  ifelse(grepl("\\.", s), 0.5 * 10^-nchar(sub("^.*\\.", "", s)),
         0.5 * 10^(nchar(s) - nchar(sub("0+$", "", s))))
}
tc_row <- function(check_id, basis, observed, printed, tolerance, note = "") {
  d <- observed - printed
  data.frame(check_id = check_id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = tolerance,
             status = ifelse(is.na(d), "not_evaluable",
                             ifelse(abs(d) <= tolerance + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

stopifnot(identical(snap[1, ], c("Record", "Group as printed", "Cell type as printed",
  "Measure (paper's wording)", "Value as printed", "Unit as printed", "Qualifier as printed",
  "Printed page", "PDF page", "Section", "Verbatim text", "Transcription note")))
txt <- as.data.frame(snap[-1, , drop = FALSE], stringsAsFactors = FALSE)
names(txt) <- snap[1, ]
stopifnot(nrow(txt) == 10L, identical(txt$Record, sprintf("T%02d", 1:10)))

## every printed value must occur verbatim inside its own verbatim sentence
stopifnot(all(mapply(function(v, s) grepl(v, s, fixed = TRUE), txt$`Value as printed`, txt$`Verbatim text`)))

role <- ifelse(txt$`Group as printed` == "control group", "healthy control",
        ifelse(txt$`Group as printed` == "alcoholic group", "alcoholic",
        ifelse(grepl("compared with controls", txt$`Group as printed`), "alcoholic vs control",
               "healthy control (paragraph context)")))
val  <- as.numeric(txt$`Value as printed`)
unit <- txt$`Unit as printed`
measure <- ifelse(txt$Record == "T01", "total number",
           ifelse(unit == "%" & role == "healthy control", "percent of total glia",
           ifelse(unit == "%", "relative reduction vs controls",
                  "glia/neuron ratio")))
printed_rows <- data.frame(
  record                = txt$Record,
  derived               = 0L,
  group_as_printed      = txt$`Group as printed`,
  group_role            = role,
  species_as_published  = "human",
  region                = "hippocampus (left)",
  cell_type_as_printed  = txt$`Cell type as printed`,
  measure               = measure,
  value_as_printed      = txt$`Value as printed`,
  value                 = val,
  unit_as_printed       = unit,
  ## project form of counts: 'million' x 1e6 = cells
  N_cells               = ifelse(unit == "million", val * 1e6, NA_real_),
  qualifier_as_printed  = txt$`Qualifier as printed`,
  printed_page          = txt$`Printed page`,
  derivation            = NA_character_,
  stringsAsFactors = FALSE, check.names = FALSE
)

## ---- derived control subtype numbers (not printed) ----------------------------
tot <- printed_rows$N_cells[printed_rows$record == "T01"]
pct <- printed_rows[printed_rows$record %in% c("T02", "T03", "T04"), ]
derived_rows <- data.frame(
  record                = sprintf("D%02d", 1:3),
  derived               = 1L,
  group_as_printed      = pct$group_as_printed,
  group_role            = pct$group_role,
  species_as_published  = "human",
  region                = "hippocampus (left)",
  cell_type_as_printed  = pct$cell_type_as_printed,
  measure               = "total number (derived)",
  value_as_printed      = NA_character_,
  value                 = tot * pct$value / 100 / 1e6,
  unit_as_printed       = "million",
  N_cells               = tot * pct$value / 100,
  qualifier_as_printed  = NA_character_,
  printed_page          = "166",
  derivation            = paste0("T01 x ", pct$record, " / 100 (256 million x printed %); not printed by the paper"),
  stringsAsFactors = FALSE, check.names = FALSE
)
final.dataframe <- rbind(printed_rows, derived_rows)

## ---- table checks ---------------------------------------------------------------
## The three printed glial percentages (T02-T04, whole numbers) should add to 100;
## tolerance 3 x 0.5 = 1.5 percentage points.
table_checks <- tc_row("glia_percent_sum", "T02 + T03 + T04 (astrocytes + oligodendrocytes + microglia, % of 256 million)",
                       sum(pct$value), 100, 1.5)
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])

## ---- outputs ----------------------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) --------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                         .name_repair = "minimal")
  reg_names <- registry[["Item name"]]
  item_encoded <- registry[["Item encoded"]][match(item_name, reg_names)]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "",
              fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
