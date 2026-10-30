## van Haarlem, Hynes, Jackson, Mitchell, O'Connell & Healy 2026, Nat Ecol Evol — CFF dataset
## doi:10.1038/s41559-026-02994-7 · "Pace of ecology drives the tempo of visual perception
## across the animal kingdom."
## DIGITAL-NATIVE source: `Haarlem_et_al_cff_dataset_21_10_2025.csv` (this folder; UTF-8 BOM).
## No snapshot file (founder-TSV rule); frozen source SHA-256
## bc9bfd6f923c4e58e69e7aafefe02d1793d5a3a62c7d673d835747205afc1f26.
## 280 published critical-flicker-fusion measurements, 237 species, 16 classes (22 species have
## multiple rows = multiple primary studies). SECONDARY compilation (registry Taxon group:
## review): CFF_reference names each value's primary study — the per-primary audit hook; prefer
## primaries if CFF is ever promoted to a merged trait. Ecology covariates (habitat, light
## level, mode of life) are the authors' own categorizations.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # Haarlem_etal_2026_CFFdataset
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)

raw <- read.csv(file.path(folder, "Haarlem_et_al_cff_dataset_21_10_2025.csv"),
                stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
stopifnot(nrow(raw) == 280, all(c("CFF_reference", "Species_phylo", "CFF", "Method") %in% names(raw)))

note <- paste0("SECONDARY compilation (review dataset); one row per published CFF measurement - ",
               "237 species, 22 with multiple rows; primary_reference names the source study; ",
               "prefer primaries if CFF is ever merged; body mass unit per authors' dataset (g)")

clean <- data.frame(
  Species = gsub("_", " ", raw$Species_phylo),
  species_phylo_verbatim = raw$Species_phylo,
  common_name = raw$Spname_common,
  class   = raw$Class,
  habitat = raw$habitat,
  forage_light_level = raw$forage_light_level,
  mode_of_life       = raw$mode_of_life,
  mode_of_life_ref   = raw$mode_of_life_ref,
  body_mass_g        = as.numeric(raw$body_mass),
  body_mass_ref      = raw$body_mass_ref,
  method             = raw$Method,
  cff_hz             = as.numeric(raw$CFF),
  primary_reference  = gsub("\\s+", " ", raw$CFF_reference),
  note = note, source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(!anyNA(clean$cff_hz), !anyNA(clean$body_mass_g),
          length(unique(clean$Species)) == 237)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " measurement rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
