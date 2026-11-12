# Nykjær_etal_2017_Table2.R ------------------------------------------------------
#
# Nykjær CH, Brudek T, Salvesen L & Pakkenberg B (2017), Changes in the cell population
# in brain white matter in multiple system atrophy. Mov Disord 32(7): 1074-1082.
# TABLE 2 "Estimate of total cell number" (p. 1078, PDF page 5).
#
# Reads the frozen snapshot Nykjær_etal_2017_Table2_snapshot.csv (transcription of the
# typeset table, printed layout incl. the two-level Control / MSA header) and:
#   - reshapes to one row per cell type x printed group (Control, MSA), labels kept
#     exactly as printed; Control is the healthy-control group (11 subjects), MSA the
#     disease group (10 patients);
#   - parses "38.7 x 10^9" into the printed mantissa (10^9 cells) and the absolute
#     count; keeps the CV and the printed P value with its "**" mark;
#   - writes the analysis CSV and, once registered, the public TSV.
# Counts are bilateral: Nv x uncorrected (paraffin) reference volume of one
# hemisphere x 2 (Methods p. 1076). Table 2 prints no totals, so there is no
# table_checks frame.
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

stopifnot(ncol(snap) == 6L, nrow(snap) == 8L)
stopifnot(identical(snap[2, c(2, 4)], c("Control", "MSA")),
          identical(snap[3, 2:6], c("Total number", "CV", "Total number", "CV", "P value")))
cells <- snap[4:7, 1]
stopifnot(identical(cells, c("Neurons", "Oligodendrocytes", "Astrocytes", "Microglia")))

mantissa <- function(x) {
  stopifnot(all(grepl("^[0-9.]+ \u00d7 10\\^9$", x)))   # every cell printed as "a x 10^9"
  as.numeric(sub(" \u00d7 10\\^9$", "", x))
}
n_by_group <- c(Control = 11L, MSA = 10L)    # Methods p. 1075 / Fig. 2 legend
blocks <- list(Control = 2:3, MSA = 4:5)
final.dataframe <- do.call(rbind, lapply(seq_along(cells), function(i) {
  do.call(rbind, lapply(names(blocks), function(gname) {
    cc <- blocks[[gname]]
    data.frame(
      printed_row           = i,
      cell_type_as_printed  = cells[i],
      cell_class            = ifelse(cells[i] == "Neurons", "neuron", "glia"),
      group_as_printed      = gname,
      is_healthy_control    = as.integer(gname == "Control"),
      n_subjects            = n_by_group[[gname]],
      species_as_published  = "human",
      structure             = "cerebral white matter (bilateral)",
      value_as_printed      = snap[i + 3L, cc[1]],
      N_cells.1e9           = mantissa(snap[i + 3L, cc[1]]),
      N_cells               = mantissa(snap[i + 3L, cc[1]]) * 1e9,  # printed "x 10^9" -> cells
      CV                    = as.numeric(snap[i + 3L, cc[2]]),
      P_value_as_printed    = snap[i + 3L, 6],
      P_value               = as.numeric(sub("\\*+$", "", snap[i + 3L, 6])),
      stringsAsFactors = FALSE, check.names = FALSE)
  }))
}))
rownames(final.dataframe) <- NULL

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
  ## the folder name carries a diacritic (ae ligature): compare in Unicode NFC so a
  ## decomposed file-system name still matches the registry's formula-built name
  if (requireNamespace("stringi", quietly = TRUE)) reg_names <- stringi::stri_trans_nfc(reg_names)
  key <- if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(item_name) else item_name
  item_encoded <- registry[["Item encoded"]][match(key, reg_names)]
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
