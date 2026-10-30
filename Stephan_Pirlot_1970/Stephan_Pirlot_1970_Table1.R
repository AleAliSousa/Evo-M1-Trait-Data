## Stephan & Pirlot 1970, Z zool Syst Evolutionsforsch 8(1):200-236 — Table 1
## doi:10.1111/j.1439-0469.1970.tb00876.x · "Volumetric comparisons of brain structures in bats."
## Team Stephan (MPI Frankfurt) + Pirlot (Montreal). 18 bat species, 8 families; n=1 brain per
## species EXCEPT Asellia tridens AND Glossophaga soricina (n=2; Methods p.206 — the registry
## note names only Asellia, update it). Absolute volumes in mm3, NET values (pure tissue:
## ventricles/meninges/nerves excluded), corrected to fresh standard brain volume (Pirlot &
## Stephan 1970 standard weights / specific brain weight 1.036). Schizocortex (Rose) =
## entorhinal + perirhinal + praesubicular. 'Palaeocortex + NA' = palaeocortex + nucleus
## amygdalae complex. Species names AS PUBLISHED (Chaerophon leucostigma, Vampyrops helleri are
## historical - paper-scoped key resolves). Additivity verified: telencephalon = cols 5-11,
## total brain = cols 1-4 + 12, all 18 species.
## Snapshot transcribed from the rotated Table 1 (journal p.205 = PDF p.6, 300 dpi, both column
## halves cross-checked). All cleaning here (golden rule).

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
item_name <- tools::file_path_sans_ext(basename(.sp))           # Stephan_Pirlot_1970_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1"))
stopifnot(nrow(raw) == 18, ncol(raw) == 15)
num <- function(x) as.numeric(x)

clean <- data.frame(
  Species = raw$Species,
  medulla_oblongata_mm3          = num(raw[[2]]),
  cerebellum_mm3                 = num(raw[[3]]),
  mesencephalon_mm3              = num(raw[[4]]),
  diencephalon_mm3               = num(raw[[5]]),
  bulbus_olfactorius_mm3         = num(raw[[6]]),
  palaeocortex_plus_amygdala_mm3 = num(raw[[7]]),
  septum_mm3                     = num(raw[[8]]),
  striatum_mm3                   = num(raw[[9]]),
  schizocortex_mm3               = num(raw[[10]]),
  hippocampus_mm3                = num(raw[[11]]),
  neocortex_mm3                  = num(raw[[12]]),
  telencephalon_total_mm3        = num(raw[[13]]),
  total_brain_mm3                = num(raw[[14]]),
  body_weight_g                  = num(raw[[15]]),
  n_brains = ifelse(raw$Species %in% c("Asellia tridens", "Glossophaga soricina"), 2L, 1L),
  note = paste0("net volumes (pure tissue: ventricles, meninges, nerves excluded), corrected to ",
                "fresh standard brain volume (Pirlot & Stephan 1970 standard weights / 1.036); ",
                "schizocortex (Rose) = regio entorhinalis + perirhinalis + praesubicularis; ",
                "species names as published"),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

## additivity guards (tolerance for printed rounding)
tel <- rowSums(clean[, c("bulbus_olfactorius_mm3", "palaeocortex_plus_amygdala_mm3", "septum_mm3",
                         "striatum_mm3", "schizocortex_mm3", "hippocampus_mm3", "neocortex_mm3")])
tot <- rowSums(clean[, c("medulla_oblongata_mm3", "cerebellum_mm3", "mesencephalon_mm3",
                         "diencephalon_mm3", "telencephalon_total_mm3")])
stopifnot(all(abs(tel - clean$telencephalon_total_mm3) <= 0.35),
          all(abs(tot - clean$total_brain_mm3) <= 0.35))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " bat species rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
