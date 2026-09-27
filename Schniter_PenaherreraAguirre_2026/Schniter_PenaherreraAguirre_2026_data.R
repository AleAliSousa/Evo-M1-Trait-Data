# Schniter_Penaherrera-Aguirre_2026_data.R
#
# Purpose
#   Snapshot preparation. Turn the faithful snapshot of the Schniter &
#   Penaherrera-Aguirre (2026) Zenodo `data` sheet into a lean, analysis-ready
#   CSV of primate vocal repertoire size (number of vocalization types).
#   Two repertoire columns are carried: the original McComb & Semple (2005)
#   values and the paper's contemporary update (with its per-species reference).
#   Column meanings are documented in
#   reference_tables/Schniter_Penaherrera-Aguirre_2026_data_definitions.csv.
#
# Input
#   Schniter_Penaherrera-Aguirre_2026_data_snapshot.xlsx   sheet: data_snapshot
#
# Outputs
#   Schniter_Penaherrera-Aguirre_2026_data.csv             one row per species (42 rows)
#   <DOI>_data.tsv in __Public/comparative-data/           DOI-named tab-separated copy

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # = Schniter..._data
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- "Schniter_Penaherrera-Aguirre_2026_data_snapshot.xlsx"
snapshot_sheet <- "data_snapshot"

# ---- read snapshot: row 1 = title, row 2 = header ----
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                  col_types = "text", na = character())
header <- as.character(unlist(raw[2, ], use.names = FALSE))
dat <- raw[-c(1, 2), , drop = FALSE]
names(dat) <- header
dat <- dat[!is.na(dat$BinomialNomenclature) & nzchar(trimws(dat$BinomialNomenclature)), , drop = FALSE]

na_txt <- function(x) ifelse(is.na(x) | trimws(x) %in% c("", "NA", "N/A"), NA_character_, trimws(x))

final.dataframe <- dat %>%
  transmute(
    Species                       = trimws(BinomialNomenclature),
    Species_alt                   = na_txt(BinomialNomenclatureAlternative),
    Species_MS                    = na_txt(MSBinomialNomenclature),
    Clade                         = na_txt(Clade),
    Family                        = na_txt(Family),
    vocal_repertoire_size_MS2005  = na_txt(`MSrepertoire size`),
    vocal_repertoire_size_updated = na_txt(`Updatedrepertoire size`),
    repertoire_update_reference   = na_txt(RepertoireUpdateReference),
    source                        = "Schniter_Penaherrera-Aguirre_2026"
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
message("Rows: ", nrow(final.dataframe))
