## Semendeferi & Damasio (2000) J. Hum. Evol. 38:317-332
## Table 2 — individual absolute volumes of the brain and major subdivisions (hominoids, MRI)
## Build: frozen snapshot -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Source is a PRINTED PDF table, so a hand-verified snapshot is the frozen source (§0a invariant 1):
##   Semendeferi_Damasio_2000_Table2_snapshot.xlsx (sheet "Table2"), values in cm3 with the source's
##   European "·" decimal rendered as ".". Per-individual (29 animals); aggregate to species at merge.
## Taxonomy: pre-2001 "Orang-utan" -> Pongo pygmaeus flagged to the taxon_concept
##   "Pongo pygmaeus (s.l.)" (Bornean+Sumatran, NOT resolvable to a modern species); "Gibbon" ->
##   Hylobates sp. (species not stated in the paper). Printed taxa preserved as Species_Semendeferi2000.

## 0. PATHS -- self-contained ------------------------------------------------
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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Semendeferi_Damasio_2000_Table2
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
species_key    <- file.path(dataset_root, "_keys", "Stephan", "species_key.csv")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SNAPSHOT ---------------------------------------------------
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table2", .name_repair = "minimal"),
                      check.names = FALSE)
# Specimen -> printed taxon (strip the trailing individual number)
printed <- sub("\\s+\\d+$", "", snap$Specimen)

## 3. HARMONISE species (single source of truth = _keys) --------------------
key <- read.csv(species_key, stringsAsFactors = FALSE)
key <- key[key$source_publication == "Semendeferi2000", ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
accepted <- unname(lk[tolower(printed)])
concept  <- ifelse(printed == "Orang-utan", "Pongo pygmaeus (s.l.)", "")   # pre-2001 s.l.

## 4. REFORMAT snapshot -> analysis data (cm3 -> mm3) -----------------------
vmap <- c(WholeBrain="WholeBrain_cm3", Cerebellum="Cerebellum_cm3", Hemispheres="Hemispheres_cm3",
          Frontal="Frontal_cm3", Temporal="Temporal_cm3", Insula="Insula_cm3",
          ParietoOccipital="ParietoOccipital_cm3", Core="Core_cm3")
out <- data.frame(Species = accepted, Species_Semendeferi2000 = printed,
                  Specimen = snap$Specimen, taxon_concept = concept,
                  stringsAsFactors = FALSE, check.names = FALSE)
for (nm in names(vmap)) out[[paste0(nm, "_Vol.mm3")]] <- as.numeric(snap[[vmap[nm]]]) * 1000

## 5. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, na = "")
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name,
                              " (set Item number = 'Table 2' on the Semendeferi & Damasio 2000 row)")
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")
message("Wrote ", nrow(out), " individuals -> ", basename(final_csv), " and ", item_encoded, ".tsv")
