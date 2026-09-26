# Mota_etal_2015_TableS1.R
#
# Preparation step. Turn the journal-faithful snapshot of Mota & Herculano-Houzel
# (2015) Table S1 -- "Datasets used in this study. All values refer to one
# cortical hemisphere only." -- into a lean, analysis-ready CSV. Output comes
# from the snapshot only. doi:10.1126/science.aaa9101
#
# Measures (cortical folding, per hemisphere):
#   AG = exposed (pial/grey) cortical surface area, mm2
#   FI = folding index (Mota & Herculano-Houzel definition; NOT the Zilles GI)
#   T  = mean cortical thickness, mm
# The table has TWO measurement blocks per species: "Our dataset" (columns
# AG/FI/T) and "Other datasets" (columns AG/FI/T + a Reference code). Both are
# kept, suffixed _own / _other.
#
# Layout notes preserved by the snapshot: taxonomic section headers as bare rows
# (Marsupialia, Afrotheria, ...); the species "Globicephala macrorhyncha" printed
# split across two rows; a newline inside "Cercopithecus aethiops"; "n.a." for
# missing values; and the paper's reference list after the data.
#
# THIS script reads the snapshot, drops the two title/group rows + header, tracks
# the running taxon_group, re-joins the split Globicephala row, repairs the
# in-cell newline, maps "n.a." -> NA, resolves species (species_sci), keeps one
# row per printed species record (duplicate species with >1 record are kept),
# and stops at the reference list.
#
# Input  : Mota_etal_2015_TableS1_snapshot.xlsx   sheet: TableS1
# Outputs: Mota_etal_2015_TableS1.csv             one row per species record (66)
#          <DOI>_TableS1.tsv in __Public/comparative-data/  (registry override key)

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr); library(tidyr)
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
item_name <- tools::file_path_sans_ext(basename(.sp))              # = "Mota_etal_2015_TableS1"
registry_item_name <- "Mota_Herculano-Houzel_2015_TableS1"         # __ReadMe.xlsx Item name (override)
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "TableS1"

## ---- species resolver (single source of truth = _keys) ----------------------
resolve <- local({
  if (is.na(base)) return(function(x) str_squish(gsub("_", " ", gsub("\\*", "", x))))
  key <- read.csv(file.path(base, "_keys/Stephan/species_key.csv"), stringsAsFactors = FALSE)
  ref <- read.csv(file.path(base, "_keys/species_reference.csv"),   stringsAsFactors = FALSE)$accepted_name
  km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
  clean <- function(x) str_squish(gsub("_", " ", gsub("\\*", "", x)))
  function(x) { c <- clean(x)
    h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
    a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }
})

groups <- c("Marsupialia","Afrotheria","Glires","Scandentia","Primata","Eulipotyphla",
            "Carnivora","Artiodactyla","Perissodactyla","Cetacea")
num <- function(x) suppressWarnings(as.numeric(ifelse(x %in% c("n.a.",""), NA, x)))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
raw <- raw[-(1:3), ]                                     # drop title + group + header rows
names(raw)[1:8] <- c("Species","AG_own_mm2","FI_own","T_own_mm",
                     "AG_other_mm2","FI_other","T_other_mm","Reference")
raw$Species <- str_squish(gsub("\n", " ", raw$Species))

out <- list(); group <- NA_character_; i <- 1L
while (i <= nrow(raw)) {
  nm <- raw$Species[i]
  if (is.na(nm) || !nzchar(nm)) { i <- i + 1L; next }
  if (grepl("^References", nm)) break
  if (nm %in% groups) { group <- nm; i <- i + 1L; next }
  skip <- 1L
  if (nm == "Globicephala" && i < nrow(raw) && identical(raw$Species[i+1L], "macrorhyncha")) {
    nm <- "Globicephala macrorhyncha"; skip <- 2L
  } else if (nm == "macrorhyncha") { i <- i + 1L; next }
  r <- raw[i, ]
  out[[length(out)+1L]] <- tibble(
    species_sci = resolve(nm), Species = nm, taxon_group = group,
    AG_own_mm2 = num(r$AG_own_mm2), FI_own = num(r$FI_own), T_own_mm = num(r$T_own_mm),
    AG_other_mm2 = num(r$AG_other_mm2), FI_other = num(r$FI_other), T_other_mm = num(r$T_other_mm),
    Reference = ifelse(is.na(r$Reference), "", sub("\\.0$", "", r$Reference)))
  i <- i + skip
}
df <- bind_rows(out)

options(scipen = 999)
write.csv(df, paste0(item_name, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
message("Wrote ", item_name, ".csv  (", nrow(df), " records, ",
        length(unique(df$Species)), " species)")

## ---- DOI-coded TSV (registry override key) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base)) {
  fc <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$"Item encoded"[match(registry_item_name, fc$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", registry_item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(df, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
