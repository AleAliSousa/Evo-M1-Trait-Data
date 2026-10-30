# Stephan_etal_1981_TableVI.R
# Preparation step for ONE printed table of Stephan, Frahm & Baron (1981),
# "New and revised data on volumes of brain structures in insectivores and primates"
# (Folia Primatologica 35:1-29).
#
# Table VI. Volumes of the telencephalon and of its components (mm3) in simians
# Taxon scope: Simian. All volumes in mm3; body weight g; brain weight mg.
#
# One snapshot per printed table (project convention; matches HerculanoHouzel_etal_2015).
# The taxon each source table was captioned by is carried in the `group` column.
# NB: the 1981 volume data span 16 printed tables (I-XVI) with three taxon granularities:
# I-VI & XIV-XVI split insectivore/prosimian/simian; VII/X/XII are insectivore-only with a
# pooled-"primates" partner (VIII/XI/XIII); IX (visual) is primates-only.
#
# Input : Stephan_etal_1981_TableVI_snapshot.xlsx
# Output: Stephan_etal_1981_TableVI.csv  +  DOI-encoded TSV in __Public/comparative-data/
suppressPackageStartupMessages({ library(readxl); library(readr); library(dplyr); library(stringr) })

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

num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))
# strip the " (code)" suffix the snapshot header carries on each structure column
clean_hdr <- function(h) str_squish(str_remove(h, "\\s*\\(\\d+\\)$"))

snap <- read_excel(file.path(folder, "Stephan_etal_1981_TableVI_snapshot.xlsx"),
                   sheet = "TableVI", skip = 1)   # row 1 is the caption
names(snap) <- clean_hdr(names(snap))

# type the structure columns numeric; keep species/group as identifiers
id <- c("code", "group", "species")
clean <- snap %>%
  mutate(across(-all_of(id), num)) %>%
  transmute(species, group, Bulbus_olfactorius, Bulbus_olfactorius_accessorius, Lobus_piriformis, Septum, Striatum, Schizo_cortex, Hippocampus, Neocortex) %>%
  mutate(source = "Stephan_etal_1981_TableVI")

options(scipen = 999)
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(clean), " rows x ", ncol(clean), " cols)")

## public TSV for the volume merge (DOI-encoded; matches enc_override in volumes_compiled.R)
item_encoded <- "10.1159%2F000155963_TableVI"
if (!is.na(base)) {
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(clean, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else warning("Project root not found; shared TSV skipped (local CSV still written).")
