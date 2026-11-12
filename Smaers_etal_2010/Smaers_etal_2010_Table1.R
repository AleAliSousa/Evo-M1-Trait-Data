## Smaers JB, Schleicher A, Zilles K, Vinicius L (2010), PLoS ONE 5(2):e9123
## "Frontal White Matter Volume Is Associated with Brain Enlargement and Higher Structural Connectivity in Anthropoid Primates"
## DOI: 10.1371/journal.pone.0009123
##
## Table 1 -> reproducible source-to-snapshot-to-clean-data pipeline.
## Reads the published PDF directly (no hand transcription and no Acrobat export).
## Table values are volumes in mm3: e.g. chimpanzee Brain = 444981 mm3 = 444.981 cm3.
##
## Reads the frozen snapshot (written by Smaers_etal_2010_Table1_snapshot.R); never writes it.
##
## Outputs beside this script:
##   Smaers_etal_2010_Table1.csv           analysis-ready data
## and, when run inside the full Evo-M1-Trait-Data repo, the DOI-coded TSV in
##   __Public/comparative-data/

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
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
options(scipen = 999)

library(readxl)

## ---- read snapshot (written by Smaers_etal_2010_Table1_snapshot.R) -----------------
snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     colClasses = c(Species = "character", `Specimen #` = "character",
                                    `Fr/Neo (%) Semendeferi 1997` = "character",
                                    `Fr/Neo (%) Semendeferi 2002` = "character"),
                     na.strings = "", check.names = FALSE, stringsAsFactors = FALSE)

## ---- validate, then write ---------------------------------------------------
## Expand only the abbreviations used in the printed Species column. Keep the
## printed label too, so every normalization remains auditable back to the PDF.
species_lookup <- c(
  "Pan troglodytes"  = "Pan troglodytes",
  "Pan paniscus"     = "Pan paniscus",
  "Gorilla gorilla"  = "Gorilla gorilla",
  "Pongo pygm."      = "Pongo pygmaeus",
  "Hylobates lar"    = "Hylobates lar",
  "Papio anubis"     = "Papio anubis",
  "Cercoceb. alb."   = "Cercocebus albigena",
  "Cercopith. Mit."  = "Cercopithecus mitis",
  "Cercopith. asc."  = "Cercopithecus ascanius",
  "Erythroceb. p."   = "Erythrocebus patas",
  "Miopith. tal."    = "Miopithecus talapoin",
  "Nasalis larv."    = "Nasalis larvatus",
  "Procol. bad."     = "Procolobus badius",
  "Alouatta sen."    = "Alouatta seniculus",
  "Ateles geoffroyi" = "Ateles geoffroyi",
  "Lagothr.lagotr."  = "Lagothrix lagotricha",
  "Pith. monachus"   = "Pithecia monachus",
  "Cebus albifrons"  = "Cebus albifrons"
)

## A shifted row still yields 18 rows, so the count check alone cannot catch a bad
## parse. These two checks can, and both run before anything reaches disk: a
## corrupted row loses its Species label and blanks at least one of the columns
## that Table 1 populates for every species.
species <- unname(species_lookup[snapshot$Species])
if (anyNA(species)) {
  stop("Unmapped printed species label(s): ",
       paste(unique(snapshot$Species[is.na(species)]), collapse = ", "),
       call. = FALSE)
}

## ---- clean ------------------------------------------------------------------
clean <- data.frame(
  species = species,
  species_printed = snapshot$Species,
  catalogue_number = snapshot[["Specimen #"]],
  neopallium_volume_mm3 = snapshot$N,
  neopallium_white_matter_volume_mm3 = snapshot$Nw,
  neopallium_grey_matter_volume_mm3 = snapshot$Ng,
  frontal_lobe_volume_mm3 = snapshot$FR,
  frontal_white_matter_volume_mm3 = snapshot$FRw,
  frontal_grey_matter_volume_mm3 = snapshot$FRg,
  frontal_neopallium_percent = snapshot[["Fr/Neo (%) Current study"]],
  semendeferi_1997_frontal_neopallium_percent = snapshot[["Fr/Neo (%) Semendeferi 1997"]],
  semendeferi_2002_frontal_neopallium_reported = snapshot[["Fr/Neo (%) Semendeferi 2002"]],
  stephan_unpublished_neopallium_volume_mm3 = snapshot[["Stephan unpublished N"]],
  total_brain_volume_mm3 = snapshot$Brain,
  basal_ganglia_volume_mm3 = snapshot$BG,
  source = "Smaers_etal_2010",
  stringsAsFactors = FALSE
)

## Derived non-frontal values used in the paper's analyses.
clean$nonfrontal_lobe_volume_mm3 <- clean$neopallium_volume_mm3 - clean$frontal_lobe_volume_mm3
clean$nonfrontal_white_matter_volume_mm3 <- clean$neopallium_white_matter_volume_mm3 - clean$frontal_white_matter_volume_mm3
clean$nonfrontal_grey_matter_volume_mm3 <- clean$neopallium_grey_matter_volume_mm3 - clean$frontal_grey_matter_volume_mm3

## Internal arithmetic check. Published component totals occasionally differ by 1
## mm3 because of rounding, so only larger discrepancies are flagged.
check_n  <- abs(clean$neopallium_volume_mm3 -
                (clean$neopallium_white_matter_volume_mm3 + clean$neopallium_grey_matter_volume_mm3))
check_fr <- abs(clean$frontal_lobe_volume_mm3 -
                (clean$frontal_white_matter_volume_mm3 + clean$frontal_grey_matter_volume_mm3))
if (any(check_n > 1, na.rm = TRUE) || any(check_fr > 1, na.rm = TRUE)) {
  warning("One or more component sums differ from the printed total by >1 mm3.")
}

## ---- save: local CSV + DOI-named TSV ---------------------------------------
final.dataframe <- clean
write.csv(final.dataframe,
          file = file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE,
          na = "")
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " rows).")

if (is.na(base)) {
  warning("Repo root not found; TSV skipped.")
} else {
  readme_file <- file.path(base, "__ReadMe.xlsx")
  tsv_dir     <- file.path(base, "__Public", "comparative-data")
  filecodes   <- read_excel(readme_file, sheet = "Sheet1")

  norm_key <- function(x) tolower(gsub("[ _]", "", as.character(x)))
  item_encoded <- filecodes$"Item encoded"[
    match(norm_key(item_name), norm_key(filecodes$"Item name"))
  ]

  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write.table(final.dataframe,
                file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "")
    message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
  }
}
