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
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- frozen source: digital-native journal supplement, untouched (Elsevier mmc1, sheet "Table S3") ----
## PalomeroGallagher_Zilles_2018_TableS3_snapshot.xlsx is a byte-identical copy-rename of
## 1-s2.0-S0010945218302958-mmc1.xlsx (md5-verified); never edited.
raw <- readxl::read_excel("PalomeroGallagher_Zilles_2018_TableS3_snapshot.xlsx",
                           sheet = "Table S3", skip = 2, col_names = FALSE)
names(raw) <- c("area", "specimen_as_published", "GLI_pct_mean_all_layers",
                "GLI_pct_mean_supragranular", "GLI_pct_mean_granular", "GLI_pct_mean_infragranular")
raw <- raw[!is.na(raw$area), ]

## ---- specimen -> species_as_published (strip individual-specimen suffixes) ----
raw$species_as_published <- tolower(sub("^([a-z]+).*$", "\\1", tolower(raw$specimen_as_published)))
raw$species_as_published[grepl("^human", tolower(raw$specimen_as_published))] <- "human"
raw$species_as_published[grepl("^macaque", tolower(raw$specimen_as_published))] <- "macaque"

## ---- species harmonisation via the Stephan-collection key (PalomeroGallagher2018 token) ----
key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_pg <- key[key$source_publication == "PalomeroGallagher2018", ]
lk <- setNames(key_pg$accepted_name, tolower(key_pg$variant_name))
raw$Species <- lk[raw$species_as_published]
stopifnot(!any(is.na(raw$Species)))

raw$area_as_published <- paste0("area", raw$area)
raw$n_specimens <- 1L   ## Table S3 is per-specimen; human (4 specimens) and macaque (2-3) appear as
                         ## multiple rows, one per specimen -- no within-species averaging done here
raw$source_location <- "Supplementary Table S3 (mmc1.xlsx, sheet 'Table S3'); values pertain Fig. 12"
raw$data_role <- "primary"

out <- raw[, c("Species", "species_as_published", "specimen_as_published", "area_as_published",
               "n_specimens", "GLI_pct_mean_all_layers", "GLI_pct_mean_supragranular",
               "GLI_pct_mean_granular", "GLI_pct_mean_infragranular", "source_location", "data_role")]

readr::write_csv(out, "PalomeroGallagher_Zilles_2018_TableS3.csv", na = "")
message(item_name, ": ", nrow(out), " rows written")

## ---- public TSV: look up Item encoded from __ReadMe.xlsx ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)]
} else NA_character_

if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx yet; TSV skipped. ",
          "Paste the registry row (PalomeroGallagher_Zilles_2018_TableS3_registry_row.xlsx) first.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(out, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
