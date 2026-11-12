# Korbo__1999_Table1.R -----------------------------------------------------------
#
# Korbo L (1999), Glial cell loss in the hippocampus of alcoholics.
# Alcohol Clin Exp Res 23(1): 164-168.
# Table 1 "Mean Total Number of Neurons (10^6) in Five Subregions of Hippocampus in
# Alcoholics and Controls" (p. 166, PDF page 3).
#
# Reads the frozen snapshot Korbo__1999_Table1_snapshot.csv (hand transcription of the
# page image, printed layout) and:
#   - reshapes to one row per subregion x printed group (Controls, Alcoholics), group
#     labels kept exactly as printed; Controls is the healthy-control group;
#   - splits "value (CV)" and adds the absolute count (10^6 neurons x 1e6);
#   - re-adds the five subregions per group against "Total hippocampus" (table_checks);
#   - writes the analysis CSV and, once registered, the public TSV.
# Left hippocampus only (Methods p. 165: "The left hemisphere was embedded ...").
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

stopifnot(ncol(snap) == 3L, nrow(snap) == 9L)
stopifnot(identical(snap[2, 2:3], c("Controls", "Alcoholics")))
sub_lab <- snap[3:8, 1]
stopifnot(identical(sub_lab, c("Granule", "Hilus", "CA3/2", "CA1", "Subiculum", "Total hippocampus")))
groups <- snap[2, 2:3]
## Counting territory for neurons (Methods p. 165): (1) granule cell layer of the dentate
## gyrus, (2) hilus of the dentate gyrus, (3) pyramidal cell layer of CA3 and CA2,
## (4) pyramidal cell layer of CA1, (5) cellular layer of subiculum.
g <- expand.grid(j = seq_along(groups), i = seq_along(sub_lab))
printed <- snap[cbind(g$i + 2L, g$j + 1L)]
final.dataframe <- data.frame(
  printed_row           = g$i,
  subregion_as_printed  = sub_lab[g$i],
  is_total              = as.integer(sub_lab[g$i] == "Total hippocampus"),
  group_as_printed      = groups[g$j],
  is_healthy_control    = as.integer(groups[g$j] == "Controls"),
  n_subjects            = 5L,
  sex                   = "male",
  hemisphere            = "left",
  species_as_published  = "human",
  cell_type             = "neurons",
  value_as_printed      = printed,
  N_neurons.1e6         = cell_value(printed),
  N_neurons             = cell_value(printed) * 1e6,   # printed unit 10^6 neurons -> neurons
  CV                    = cell_paren(printed),
  stringsAsFactors = FALSE, check.names = FALSE
)
rownames(final.dataframe) <- NULL

## ---- table checks (build HOWTO 7a) --------------------------------------------
## Total hippocampus = sum of the five subregions, per group. Tolerance: half a unit
## of the last significant printed digit of each summand + half a unit of the total.
table_checks <- do.call(rbind, lapply(seq_along(groups), function(j) {
  x_str <- snap[3:7, j + 1L]; t_str <- snap[8, j + 1L]
  tc_row(paste0("subregion_sum_", groups[j]),
         paste0("Total hippocampus vs sum of the five subregions, column '", groups[j], "' (10^6)"),
         sum(cell_value(x_str)), cell_value(t_str),
         sum(half_unit(x_str)) + half_unit(t_str))
}))
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
