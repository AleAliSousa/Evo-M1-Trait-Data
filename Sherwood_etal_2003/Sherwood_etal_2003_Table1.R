## Sherwood, Lee, Rivara, Holloway, Gilissen, Simmons, Hakeem, Allman, Erwin & Hof 2003,
## Brain Behav Evol 61:28-44 — Table 1. doi:10.1159/000068879 ·
## "Evolution of specialized pyramidal cells in primate visual and motor cortex" (Betz + Meynert).
## 25 taxa (23 primates + Tupaia glis + Pteropus poliocephalus). LEFT block = this study's own
## soma volumes (um3; planar rotator; mean/SD/CV for M1 pyramids, Betz, V1 pyramids, Meynert) —
## PRIMARY. RIGHT block = literature-compiled neocortex volume (mm3), brain/body weight (g), EQ
## (Martin 1981), diet/habitat, group size, dexterity index — SECONDARY, with per-value refs
## resolved from column-header defaults (NC=Stephan1981, BW=Harvey1987, Body=Fleagle1999,
## diet/hab=Clutton-Brock&Harvey1980, group=Rowe1996, dext=Heffner&Masterton1983) overridden by
## per-cell superscripts, which the text extraction flattened — every cell was disambiguated
## against the page image (journal p.31). Dexterity cross-links the Heffner_Masterton_1983 folder.
## Snapshot frozen; all cleaning here (golden rule).

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
item_name <- tools::file_path_sans_ext(basename(.sp))            # Sherwood_etal_2003_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1"))
stopifnot(nrow(raw) == 25)
refs <- c("1"="Stephan et al. [1981]","2"="Baron et al. [1996]","3"="Zilles and Rehkämper [1988]",
          "4"="Harvey et al. [1987]","5"="personal observation (n=2)","6"="Fleagle [1999]",
          "7"="Rowe [1996]","8"="Groves [2001]","9"="Clutton-Brock and Harvey [1980]",
          "10"="Dunbar [1992]","11"="Heffner and Masterton [1983]")
rref <- function(cellref, default, value) {
  out <- ifelse(!is.na(cellref) & nzchar(as.character(cellref)),
                refs[as.character(cellref)], refs[default])
  ifelse(is.na(value), NA_character_, out)
}
num <- function(x) suppressWarnings(as.numeric(x))
note <- paste0("soma volumes = this study (primary); neocortex/brain/body/EQ/ecology columns are ",
               "literature-compiled (secondary) - refs resolved from header defaults + per-cell ",
               "superscripts (see definitions); dexterity index after Heffner & Masterton 1983")
clean <- data.frame(
  Species = raw$Taxon, n = num(raw$n),
  motor_pyramid_soma_um3_mean = num(raw[[3]]),  motor_pyramid_soma_um3_sd = num(raw[[4]]),  motor_pyramid_cv_pct = num(raw[[5]]),
  betz_soma_um3_mean = num(raw[[6]]),           betz_soma_um3_sd = num(raw[[7]]),           betz_cv_pct = num(raw[[8]]),
  visual_pyramid_soma_um3_mean = num(raw[[9]]), visual_pyramid_soma_um3_sd = num(raw[[10]]), visual_pyramid_cv_pct = num(raw[[11]]),
  meynert_soma_um3_mean = num(raw[[12]]),       meynert_soma_um3_sd = num(raw[[13]]),        meynert_cv_pct = num(raw[[14]]),
  neocortex_vol_mm3 = num(raw[[15]]), neocortex_vol_ref = rref(raw[[16]], "1", num(raw[[15]])),
  brain_weight_g = num(raw[[17]]),    brain_weight_ref  = rref(raw[[18]], "4", num(raw[[17]])),
  body_weight_g = num(raw[[19]]),     body_weight_ref   = rref(raw[[20]], "6", num(raw[[19]])),
  EQ = num(raw[[21]]),
  diet_category = raw[[22]],     diet_ref    = rref(raw[[23]], "9", raw[[22]]),
  habitat_category = raw[[24]],  habitat_ref = rref(raw[[25]], "9", raw[[24]]),
  group_size = num(raw[[26]]),   group_size_ref = rref(raw[[27]], "7", num(raw[[26]])),
  dexterity_index = num(raw[[28]]),
  note = note, source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(clean), " taxa written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
