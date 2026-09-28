## Chen_Wiens_2020 — Supplementary Data 3
## Chen, Z. & Wiens, J. J. (2020). The origins of acoustic communication in vertebrates.
## Nature Communications 11:369. DOI 10.1038/s41467-020-14356-3.
##
## Data on acoustic communication (State 0 = absent, 1 = present) for 1799 tetrapod
## species, with the per-row literature/database reference as printed.
##
## Frozen source (born digital): the journal xlsx 41467_2020_14356_MOESM6_ESM.xlsx,
## copy-renamed bytes-untouched to Chen_Wiens_2020_SupplementaryData3_snapshot.xlsx
## (sheet "Supplementary Data_3"; sheets "Metadata" and "References" carry the state
## coding and the reference list). This script replaces the earlier hand-made TSV
## (a Numbers export that carried a "Table 1" title line and therefore parsed as a
## single column); all cleaning happens here.
##
## Species: kept exactly as printed (Genus_species with underscore) in Species_printed;
## Species_binomial is the same name with the underscore replaced by a space
## (species_basis = spelling). No taxonomic harmonisation here (SPECIES_NAMING §2).

options(scipen = 999)
suppressPackageStartupMessages({
  library(readxl)
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
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- paste0(item_name, "_snapshot.xlsx")

## ---- read the frozen source -------------------------------------------------
raw <- as.data.frame(read_excel(snapshot_file, sheet = "Supplementary Data_3",
                                col_names = TRUE, col_types = "text"),
                     stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(identical(names(raw), c("Species", "Family", "Order", "Class", "State", "References")))
raw <- raw[!is.na(raw$Species) & nzchar(trimws(raw$Species)), , drop = FALSE]

final.dataframe <- data.frame(
  Species_printed  = raw$Species,                          # exactly as printed (Genus_species)
  Species_binomial = gsub("_", " ", raw$Species, fixed = TRUE),
  species_basis    = "spelling",                           # underscore -> space only
  Family           = raw$Family,
  Order            = raw$Order,
  Class            = raw$Class,
  State            = as.integer(raw$State),                # 0 = absent, 1 = present (Metadata sheet)
  References       = raw$References,                       # per-row source(s) as printed
  source           = "Chen_Wiens_2020",
  stringsAsFactors = FALSE
)

stopifnot(nrow(final.dataframe) == 1799L)                  # Metadata sheet: 1799 species
stopifnot(all(final.dataframe$State %in% c(0L, 1L)))

## ---- local CSV ---------------------------------------------------------------
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written")

## ---- public TSV: Item encoded looked up by Item name in __ReadMe.xlsx ---------
tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  write.table(final.dataframe, tsv_file, sep = "\t", row.names = FALSE, na = "",
              quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", tsv_file)
}
