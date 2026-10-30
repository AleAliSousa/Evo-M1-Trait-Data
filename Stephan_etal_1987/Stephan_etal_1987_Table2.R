## Stephan H, Frahm HD, Baron G (1987), J Hirnforsch 28(5):571-584
## "Comparison of Brain Structure Volumes in Insectivora and Primates. VII. Amygdaloid Components."
## Table 2 (Primates: 18 prosimians + 26 simians + man).  Volumes in mm^3.
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful to print; cleaning happens here.

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)
options(scipen = 999)

raw <- read.csv("Stephan_etal_1987_Table2_snapshot.csv", check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "NA", "-"))

## --- harmonize species to the canonical key (variants registered under Stephan1987) ---
key <- read.csv("../_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
key <- key[key$source_publication == "Stephan_etal_1987", ]
if (nrow(key) == 0L)
  stop("No species_key.csv rows for source_publication == \"Stephan_etal_1987\" -- key rows are scoped to the paper folder name (_keys/SPECIES_NAMING.md sec 3b)", call. = FALSE)
norm <- function(x) tolower(gsub("[^a-z]+", " ", tolower(sub("1\\.", "l.", x))))
lk <- setNames(key$accepted_name, trimws(norm(key$variant_name)))
species <- unname(lk[trimws(norm(raw$species))])
if (any(is.na(species)))
  warning("unmatched species: ", paste(raw$species[is.na(species)], collapse = "; "))

## AMY = LAM + MAM (the two main components). MCB is a subset of LAM; NTO sits within MAM.
## NTO = 0 in higher primates is "not determinable with certainty" (printed note), not a true zero.
clean <- data.frame(
  species                         = species,
  group                           = raw$group,
  amygdala_total_mm3              = raw$AMY_mm3,   # AMY = amygdaloid complex -> Stephan "Amygdala"
  corticobasolateral_LAM_mm3     = raw$LAM_mm3,
  magnocellular_basal_MCB_mm3    = raw$MCB_mm3,
  centromedial_MAM_mm3           = raw$MAM_mm3,
  olfactory_tract_nucleus_NTO_mm3 = raw$NTO_mm3,
  species_printed                 = raw$species,
  source                          = "Stephan_etal_1987",
  stringsAsFactors = FALSE
)

write.csv(clean, "Stephan_etal_1987_Table2.csv", row.names = FALSE)
