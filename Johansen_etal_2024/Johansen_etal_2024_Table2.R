## Johansen, Beliveau, et al. (2024) J. Neurosci. 44(33):e1750232024
## Table 2 — Summary of SV2A Bmax (pmol/mL) by brain region (in vivo human synaptic-density atlas)
## Build: frozen snapshot -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Source is a PRINTED PDF table (a picture of the data), so a hand-verified snapshot is the frozen
## source (§0a invariant 1): Johansen_etal_2024_Table2_snapshot.xlsx (sheet "Table2"), captured from
## Table 2 (p.5) and validated cell-by-cell against the page.
## SINGLE-SPECIES (Homo sapiens): a human regional reference atlas. Data role = primary. The M1 datum
## is the Precentral region (is_M1 = 1); lobe "(total)" rows are aggregates (is_lobe_total = 1).

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
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Johansen_etal_2024_Table2
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
snap <- read_excel(snapshot_xlsx, sheet = "Table2", .name_repair = "minimal")
snap <- as.data.frame(snap, check.names = FALSE)

## 3. REFORMAT snapshot -> analysis data ------------------------------------
# Forward-fill the Lobe column (blank on continuation rows in the snapshot).
lobe <- snap$Lobe
for (i in seq_along(lobe)) if (is.na(lobe[i]) || !nzchar(lobe[i])) lobe[i] <- lobe[i-1]
numcols <- c("Total_Mean","Total_SD","Total_COV","L_Mean","L_SD","L_COV",
             "R_Mean","R_SD","R_COV","LR_Mean","LR_SD","LR_COV")
for (nm in numcols) snap[[nm]] <- suppressWarnings(as.numeric(snap[[nm]]))

out <- data.frame(
  Species              = "Homo sapiens",
  Species_Johansen2024 = "Homo sapiens",
  Lobe                 = lobe,
  Region               = snap$Region,
  is_lobe_total        = as.integer(grepl("total", snap$Region, ignore.case = TRUE)),
  is_M1                = as.integer(tolower(trimws(snap$Region)) == "precentral"),
  `SV2A_total.pmol_mL` = snap$Total_Mean, SV2A_total_SD = snap$Total_SD, SV2A_total_COV = snap$Total_COV,
  `SV2A_L.pmol_mL`     = snap$L_Mean,     SV2A_L_SD     = snap$L_SD,     SV2A_L_COV     = snap$L_COV,
  `SV2A_R.pmol_mL`     = snap$R_Mean,     SV2A_R_SD     = snap$R_SD,     SV2A_R_COV     = snap$R_COV,
  LR_ratio             = snap$LR_Mean,    LR_ratio_SD   = snap$LR_SD,    LR_ratio_COV   = snap$LR_COV,
  stringsAsFactors = FALSE, check.names = FALSE
)

## 4. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, na = "")
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")
message("Wrote ", nrow(out), " regions -> ", basename(final_csv), " and ", item_encoded, ".tsv")
