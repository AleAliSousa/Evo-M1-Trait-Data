# Matano__1992_Table3.R
#
# Purpose
#   Build ONE printed table of Matano (1992) into a lean, analysis-ready CSV: one row
#   per species with body weight and the four inferior-olivary-nucleus volumes.
#
#   Table 3. Body weight, volumes of the inferior olivary nuclei and eco-ethological
#   characteristics in Old World monkeys (10 species).
#
#   The paper splits the same schema across four tables by grade; each printed table is
#   its own registry item (project convention -- see Stephan_etal_1970 / Stephan_etal_1981,
#   split the same way). The taxon block the table was captioned by is carried in `group`.
#
#   This is the inferior olive -- a structure absent from the rest of the Stephan
#   collection (the Baron/Frahm/Stephan series covers the vestibular (VIII) and trigeminal
#   (IX) complexes but never the olive), so nothing here duplicates existing data.
#
#   Matano, S. (1992). A Comparative Neuroprimatological Study on the Inferior Olivary
#   Nuclei (from the Stephan Collection). J. Anthropol. Soc. Nippon 100(1), 69-82.
#   DOI 10.1537/ase1911.100.69
#
# Input
#   Matano__1992_Table3_snapshot.csv   journal-faithful transcription of the printed
#     table (the data rows are scanned images with no text layer, so this hand-read
#     snapshot is the frozen source).
#
# Outputs
#   Matano__1992_Table3.csv                          10 species
#   10.1537%2Fase1911.100.69_Table3.tsv              in __Public/comparative-data/
#
# Structures (measure = Vol.mm3, both sides as measured):
#   IOPr     = principal inferior olivary nucleus         (col "Inf.Oliv. Principal")
#   IOAcMed  = medial accessory inferior olivary nucleus  (col "Inf.Oliv. Acc.Med.")
#   IOAcDors = dorsal accessory inferior olivary nucleus  (col "Inf.Oliv. Acc.Dors.")
#   IOAc     = accessory inferior olivary nuclei          (col "Med.+Dorsal" = Med + Dors)
# IOPr and IOAc are the two headline nuclei (Figs 1-2 and 3-4). Body weight and the
# eco-ethological columns (activity/diet/locomotor, after Napier & Napier 1967) are
# secondary/external.
#
# Taxonomy: journal names are kept verbatim in `Species` (HOWTO invariant 3);
# harmonisation is applied centrally via ../_keys/Stephan/species_key.csv, token
# Matano1992 (paper-scoped, shared by all four tables).

suppressPackageStartupMessages(library(readr))

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
## Do NOT read the snapshot by a bare relative name -- that resolves against whatever
## the working directory happens to be (this is what produced the
## "... does not exist in current working directory: /Users/crossmodal/Desktop" error).
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

# Read EVERY column as character. Matano prints 3 significant figures and the trailing
# zeros are meaningful ("0.380", "8.50", "0.8000"); parsing to double would silently
# drop them and rewrite the already-published CSV/TSV. Numeric coercion happens below,
# for the integrity check only.
snap <- read_csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 col_types = cols(.default = col_character()))

out <- data.frame(
  Species        = snap$Species,
  group          = "Old World monkey",
  n              = snap$Specimens_n,
  body_weight_g  = snap$Body_weight_g,
  IOPr_mm3       = snap$InfOliv_Principal_mm3,
  IOAcMed_mm3    = snap$InfOliv_AccMed_mm3,
  IOAcDors_mm3   = snap$InfOliv_AccDors_mm3,
  IOAc_mm3       = snap$Med_plus_Dorsal_mm3,
  activity_time  = snap$Activity_Time,
  diet           = sub("\\.$", "", snap$Diet),
  locomotor_type = snap$Locomotor_Type,
  stringsAsFactors = FALSE
)

# integrity check: printed Med.+Dorsal must equal AccMed + AccDors (to printed precision)
resid <- abs((as.numeric(out$IOAcMed_mm3) + as.numeric(out$IOAcDors_mm3)) - as.numeric(out$IOAc_mm3))
stopifnot(nrow(out) == 10L, max(resid) <= 0.06)

write_csv(out, file.path(folder, paste0(item_name, ".csv")))
cat("Wrote ", item_name, ".csv: ", nrow(out), " species; max accessory-sum residual ",
    round(max(resid), 3), "\n", sep = "")

## ---- DOI-coded public TSV (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) ----
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA_character_
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
} else {
  # quote the text columns only (cols 1,2,9,10,11) -- keeps the measure columns bare,
  # as in every other __Public TSV, while the values stay at printed precision.
  write.table(out, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = c(1L, 2L, 9L, 10L, 11L))
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
