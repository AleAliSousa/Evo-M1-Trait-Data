# Wegiel_etal_2014_Table1.R ----------------------------------------------------
#
# Wegiel J, Flory M, Kuchna I, Nowicki K, Ma SY, Imaki H, Wegiel J, Cohen IL,
# London E, Wisniewski T, Brown WT (2014). Acta Neuropathol Commun 2:141.
# doi:10.1186/s40478-014-0141-7
#
# Table 1 "Parameters and procedures applied to estimate the volume of brain
# subdivisions and number of neurons" (p. 6).
# NOTE: this paper's Table 1 is the STEREOLOGY-PARAMETERS table, not a subject
# table; the paper prints no subject table (demographics are referred to its
# ref. [35]). The cohort facts printed in prose are kept in
# reference_tables/Wegiel_etal_2014_cohort_data_from_text.csv.
#
# Reads the frozen snapshot (Wegiel_etal_2014_Table1_snapshot.xlsx, written by
# Wegiel_etal_2014_Table1_snapshot.R from the PDF text layer) and:
#   - drops the printed group row "Entorhinal c." into a structure_group column
#     for the four layer rows it heads (LII, LIII, LV, LVI);
#   - splits "1000 × 1000" grid and "80 × 80 × 10" counting-frame cells into
#     numeric x / y (/ height) in um; keeps the printed cells verbatim;
#   - strips the "x" from objective magnifications and thousands commas;
#   - keeps blank CE cells blank (NA) - see errata E003/E004 for the two blanks
#     the Methods text fills;
#   - writes the analysis CSV, and the public TSV only once the item is
#     registered in __ReadMe.xlsx.
# The parameters apply to both groups (Autism and Control) alike; per case.
# UNITS: um (grid, counting frame), counts, unitless CE. No conversion needed.
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
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))   # keep printed multiplication signs as UTF-8 under Rscript

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table1", col_names = FALSE,
                             col_types = "text", .name_repair = "minimal"))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 9L, nrow(snap) == 29L, identical(snap[2, 9], "CE*"))

dat <- snap[3:25, , drop = FALSE]          # the 23 printed body rows (incl. 1 group row)
stopifnot(nrow(dat) == 23L, all(!is.na(dat[, 1])))

## ---- cell helpers -------------------------------------------------------------
num_of <- function(x) {
  s <- trimws(gsub(",", "", sub("x$", "", x), fixed = FALSE))
  s[s %in% c("", "NA")] <- NA_character_
  suppressWarnings(as.numeric(s))
}
part_of <- function(x, i) vapply(strsplit(x, "\\s*\u00d7\\s*"),
                                 function(p) if (length(p) >= i) p[i] else NA_character_, character(1))

## ---- group row -> structure_group ---------------------------------------------
is_group <- is.na(dat[, 2])
group    <- rep(NA_character_, nrow(dat)); cur <- NA_character_
for (i in seq_len(nrow(dat))) {
  if (is_group[i]) cur <- dat[i, 1]
  else if (grepl("^L[IVX]+$", dat[i, 1])) group[i] <- cur   # the printed layer rows under the group row
}
keep <- which(!is_group)

d <- dat[keep, , drop = FALSE]
final.dataframe <- data.frame(
  printed_row                    = keep,
  Species                        = "Homo sapiens",
  species_as_published           = "Homo sapiens",
  structure_as_published         = d[, 1],
  structure_group_as_published   = group[keep],
  applies_to_groups              = "Autism and Control",
  hemisphere                     = "one hemisphere (side not stated)",
  n_sections_examined_per_case   = num_of(d[, 2]),
  objective_volumetry_x          = num_of(d[, 3]),
  objective_counting_x           = num_of(d[, 4]),
  printed_grid_size_um           = d[, 5],
  grid_x.um                      = num_of(part_of(d[, 5], 1)),
  grid_y.um                      = num_of(part_of(d[, 5], 2)),
  printed_counting_frame_um      = d[, 6],
  counting_frame_x.um            = num_of(part_of(d[, 6], 1)),
  counting_frame_y.um            = num_of(part_of(d[, 6], 2)),
  counting_frame_height.um       = num_of(part_of(d[, 6], 3)),
  n_counting_spaces_per_case     = num_of(d[, 7]),
  n_neurons_counted_per_case     = num_of(d[, 8]),
  CE_printed                     = d[, 9],
  CE                             = num_of(d[, 9]),
  stringsAsFactors = FALSE, check.names = FALSE)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 22L, sum(!is.na(final.dataframe$structure_group_as_published)) == 4L,
          !anyNA(final.dataframe$counting_frame_height.um), !anyNA(final.dataframe$n_neurons_counted_per_case))

options(scipen = 999)   # write p = 0.0001 as printed, not 1e-04
## ---- write the analysis CSV ------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) --------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) && !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
