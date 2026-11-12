# Andersen_etal_1992_Table5.R ---------------------------------------------------
#
# Andersen, Korbo & Pakkenberg (1992), J Comp Neurol 326: 549-560.
# TABLE 5 "Surface and Volume in Five Human Cerebella" (p. 559, PDF page 11).
#
# Reads the frozen snapshot Andersen_etal_1992_Table5_snapshot.csv (hand transcription
# of the scanned page; indented sub-rows keep their two leading spaces) and:
#   - forward-fills the printed section headings (cerebellar volume, average thickness
#     of molecular layer, average thickness of granular layer) onto their rows;
#   - splits "value (CV)" and records the printed unit of each section;
#   - converts volumes to the project unit mm^3 (cm^3 x 1000); surface (cm^2) and
#     layer thickness (um) stay in their printed units;
#   - re-adds the cortex parts and the whole-cerebellum volume (table_checks);
#   - writes the analysis CSV and, once registered, the public TSV.
#
# No table value is typed in this script.

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

stopifnot(ncol(snap) == 2L, nrow(snap) == 22L)
stopifnot(identical(snap[c(2, 3, 12, 17), 1],
                    c("Pial surface (cm^2)", "Cerebellar volume (cm^3)",
                      "Average thickness of molecular layer (\u00b5m)",
                      "Average thickness of granular layer (\u00b5m)")))

data_rows <- which(nzchar(snap[, 2]))            # rows that carry a printed value
data_rows <- data_rows[data_rows >= 2 & data_rows <= 21]
section <- character(nrow(snap)); cur <- ""
for (i in 2:21) {
  if (!nzchar(snap[i, 2])) cur <- snap[i, 1]       # a heading row (no value)
  section[i] <- if (i == 2) snap[2, 1] else cur
}
label     <- snap[data_rows, 1]
indented  <- grepl("^  ", label)
struct    <- trimws(label)
sect      <- section[data_rows]
unit_prt  <- sub("^.*\\(([^)]*)\\)$", "\\1", sect)          # cm^2 / cm^3 / um
measure   <- ifelse(grepl("^Pial surface", sect), "pial surface area",
             ifelse(grepl("^Cerebellar volume", sect), "volume",
             ifelse(grepl("molecular layer", sect), "average thickness of molecular layer",
                    "average thickness of granular layer")))
## parent: in the volume block the four indented rows sit under "Cortex"
parent    <- ifelse(measure == "volume" & indented, "Cortex", NA_character_)
val       <- cell_value(snap[data_rows, 2])

final.dataframe <- data.frame(
  printed_row           = data_rows - 1L,
  section_as_printed    = sect,
  structure_as_printed  = struct,
  parent_as_printed     = parent,
  species_as_published  = "human",
  observation_level     = "group mean",
  n_brains              = 5L,
  measure               = measure,
  value_as_printed      = snap[data_rows, 2],
  value.printed_unit    = val,
  unit_as_printed       = unit_prt,
  CV                    = cell_paren(snap[data_rows, 2]),
  ## project unit: volume cm^3 x 1000 = mm^3; other measures carried in printed unit
  Vol.mm3               = ifelse(measure == "volume", val * 1000, NA_real_),
  stringsAsFactors = FALSE, check.names = FALSE
)
rownames(final.dataframe) <- NULL

## ---- table checks (build HOWTO 7a) --------------------------------------------
## (1) Cortex = Pars anterior + Pars posterior + Vermis + Flocculonodular lobe
## (2) Total  = Cortex + Dentate nuclei + White matter
## Tolerance: half a unit of the last significant printed digit of each summand plus
## half a unit of the printed total.
vol <- final.dataframe[final.dataframe$measure == "volume", ]
g   <- function(s) vol$value.printed_unit[vol$structure_as_printed == s]
gs  <- function(s) vol$value_as_printed[vol$structure_as_printed == s]
parts1 <- c("Pars anterior", "Pars posterior", "Vermis", "Flocculonodular lobe")
parts2 <- c("Cortex", "Dentate nuclei", "White matter")
table_checks <- rbind(
  tc_row("volume_cortex_sum", "Cortex vs sum of its four indented regions (cm^3)",
         sum(sapply(parts1, g)), g("Cortex"),
         sum(half_unit(sapply(parts1, gs))) + half_unit(gs("Cortex"))),
  tc_row("volume_total_sum", "Total vs Cortex + Dentate nuclei + White matter (cm^3)",
         sum(sapply(parts2, g)), g("Total"),
         sum(half_unit(sapply(parts2, gs))) + half_unit(gs("Total")))
)
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

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
