## Barger et al. (2012) J. Comp. Neurol. 520(13):3035-3054
## Table 3 — average amygdala neuron numbers per nucleus per species (stereology)
## Build: frozen snapshot -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Source is a PRINTED PDF table -> hand-verified snapshot is the frozen source (§0a invariant 1):
##   Barger_etal_2012_Table3_snapshot.xlsx (sheet "Table3"), printed as "mean (SD)" x10^6.
## Species-level means. Two taxonomy caveats (see README / taxon_concept column):
##   - "Gibbon" is a POOLED mean over 3 species (H. muelleri + white-cheeked Nomascus + H. lar)
##     -> accepted Hylobatidae sp., decomposable = FALSE (do not assign to one species).
##   - "Orangutan" = Pongo pygmaeus, island/subspecies not stated, pooled n=4 -> flag (s.l.).

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
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Barger_etal_2012_Table3
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SNAPSHOT ---------------------------------------------------
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table3", .name_repair = "minimal"),
                      check.names = FALSE)   # ROI_nucleus + "<Species>_millions_mean_SD" cols

## 3. REFORMAT -> species-rows, absolute counts -----------------------------
species  <- sub("_millions_mean_SD$", "", names(snap)[-1])
acc <- c(Human="Homo sapiens", Chimpanzee="Pan troglodytes", Bonobo="Pan paniscus",
         Gorilla="Gorilla gorilla", Orangutan="Pongo pygmaeus",
         Gibbon="Hylobatidae sp.", Macaque="Macaca fascicularis")
n_spec <- c(Human=11, Chimpanzee=5, Bonobo=4, Gorilla=5, Orangutan=4, Gibbon=3, Macaque=3)
concept <- c(Orangutan="Pongo pygmaeus (s.l.); island/subspecies not stated; pooled n=4",
             Gibbon="POOLED Hylobatidae: H. muelleri + white-cheeked (Nomascus) + H. lar; decomposable=FALSE")
parse_ms <- function(x) {                      # "13.27 (3.70)" -> c(mean, sd) in millions
  m  <- as.numeric(sub("\\s*\\(.*$", "", x))
  sd <- as.numeric(gsub(".*\\(([-0-9.]+)\\).*", "\\1", x))
  c(m, sd)
}
nuclei <- snap$ROI_nucleus
out <- data.frame(Species = unname(acc[species]), Species_Barger2012 = species,
                  n_specimens = unname(n_spec[species]),
                  taxon_concept = ifelse(species %in% names(concept), concept[species], ""),
                  stringsAsFactors = FALSE, check.names = FALSE)
for (i in seq_along(nuclei)) {
  nuc <- nuclei[i]
  ms  <- t(vapply(snap[[i + 1]], parse_ms, numeric(2)))   # per species
  out[[paste0(nuc, "_neurons")]]    <- round(ms[, 1] * 1e6)   # millions -> absolute
  out[[paste0(nuc, "_neurons_SD")]] <- round(ms[, 2] * 1e6)
}

## 4. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, na = "")
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name,
                              " (add a Barger 2012 row with Item number = 'Table 3')")
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")
message("Wrote ", nrow(out), " species -> ", basename(final_csv), " and ", item_encoded, ".tsv")
