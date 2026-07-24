## Genoud, Isler & Martin (2018) Biol. Rev. 93:404-438 — Table S2 (BMR database)
## Build: frozen source -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Frozen source (digital-native): the journal's supplementary workbook, kept verbatim —
##   brv12350-sup-0003-tables2.xlsx  (sheet "Feuil1"). No derived snapshot (§0a invariant 1).
## Column meanings are in brv12350-sup-0002-tables1.pdf (Table S1 legend).
## Body mass is already in g (project unit). BMR is in ml O2/h (source unit, left
## unconverted — whole-body BMR is a separate measure class from cerebral MR).
## This is a COMPILATION: each row's value comes from the primary source in
## `Authors`. Data role = secondary -> built for provenance, NOT merged.

## 0. PATHS -- self-contained (Rscript or RStudio; full repo or lone folder) ----
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
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Genoud_etal_2018_TableS2
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

src_xlsx       <- file.path(folder, "brv12350-sup-0003-tables2.xlsx")  # frozen source (verbatim)
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(readxl)

## 2. READ FROZEN SOURCE (digital-native: the untouched journal download) ----
# The supplementary workbook is machine-readable, so it IS the frozen source —
# no derived snapshot (see __HOWTO_build_a_dataset_file.md §0a invariant 1). Kept
# verbatim in the folder; never edited. Read with no header so the caption + two
# header rows are preserved for locating the real header.
snap  <- read_excel(src_xlsx, sheet = 1, col_names = FALSE, .name_repair = "minimal")

## 3. REFORMAT source -> analysis data --------------------------------------
# Header is the row whose first cell is "No"; data are the rows below it.
hrow  <- which(snap[[1]] == "No")[1]
dat   <- snap[(hrow + 1):nrow(snap), , drop = FALSE]
dat   <- dat[!is.na(dat[[1]]), , drop = FALSE]              # keep real entries (col A = No)

# Name the 38 columns by position (legend order A..AL), then select/rename.
names(dat)[1:38] <- c(
  "No","Species_WR","Subsp_WR","Species_original","Species_Nexus","Order","Domestic",
  "Authors","Cited_value","Source_unavailable","Secondary_reference","body_mass","BMR",
  "BMR_pct","a","b","b1","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q",
  "Ecrit","E","Accepted","ALL","SELECT","SPOILED")

out <- data.frame(
  No                  = dat$No,
  Species             = dat$Species_WR,           # accepted (Wilson & Reeder 2005)
  Species_Genoud2018  = dat$Species_original,     # printed name preserved (invariant)
  Subspecies          = dat$Subsp_WR,
  Species_Nexus       = dat$Species_Nexus,
  Order               = dat$Order,
  Domestic            = dat$Domestic,
  Authors             = dat$Authors,
  Cited_value         = dat$Cited_value,
  Source_unavailable  = dat$Source_unavailable,
  Secondary_reference = dat$Secondary_reference,
  Body_mass.g         = suppressWarnings(as.numeric(gsub(",", "", dat$body_mass))),  # already g
  BMR.mlO2_h          = suppressWarnings(as.numeric(gsub(",", "", dat$BMR))),        # ml O2/h
  BMR_pct             = suppressWarnings(as.numeric(dat$BMR_pct)),
  sample_size         = dat$a,                     # kept verbatim (may carry "?")
  stringsAsFactors = FALSE
)
# quality-criteria / concern / evaluation / selection flags, verbatim
for (nm in c("b","b1","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q",
             "Ecrit","E","Accepted","ALL","SELECT","SPOILED"))
  out[[nm]] <- dat[[nm]]

# treat 'NA'/'n.a.' text as missing (blanks already NA)
out[] <- lapply(out, function(x) { if (is.character(x)) x[trimws(x) %in% c("NA","na","n.a.")] <- NA; x })

## 4. SAVE  (local CSV + DOI-coded public TSV) ------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, na = "")

filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", item_name)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")

message("Wrote ", nrow(out), " rows -> ", basename(final_csv),
        " and ", item_encoded, ".tsv")
