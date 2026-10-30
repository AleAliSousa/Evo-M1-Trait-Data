## Smaers, Turner, Gómez-Robles & Sherwood (2018) eLife 7:e35696
## Figure 2 — Source data 1 ("Brain data used in the analyses")
## Build: frozen source -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Frozen source (digital-native): the journal's Figure-2 source-data document, kept verbatim —
##   elife-35696-fig2-data1-v2.docx  (single table). No derived snapshot (§0a invariant 1).
## COMPILATION: every row's volumes come from the primary source in `Source`
## (Maseko et al. 2012 / Smaers et al. 2011 / MacLeod et al. 2003). Data role = both;
## these overlap sources already in the repo, so treat as provenance and do NOT double-count.

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
item_name     <- tools::file_path_sans_ext(basename(.sp))          # Smaers_etal_2018_Figure2-data1
dataset_root  <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

src_docx       <- file.path(folder, "elife-35696-fig2-data1-v2.docx")  # frozen source (verbatim)
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

## 1. PACKAGES ---------------------------------------------------------------
library(docxtractr)   # read the .docx table directly (the frozen source)
library(readxl)       # for the __ReadMe.xlsx Item-encoded lookup

## 2. READ FROZEN SOURCE (digital-native docx: the untouched journal download) --
doc <- read_docx(src_docx)
raw <- docx_extract_tbl(doc, 1, header = TRUE)          # cols: Species, Brain, Medial, Cerebellum, Source
raw <- as.data.frame(raw, stringsAsFactors = FALSE, check.names = FALSE)

## 3. REFORMAT source -> analysis data --------------------------------------
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
brain <- num(raw$Brain); med <- num(raw$Medial); cer <- num(raw$Cerebellum)  # cm3
out <- data.frame(
  Species                   = raw$Species,          # accepted (printed binomial)
  Species_Smaers2018        = raw$Species,          # printed name preserved (invariant)
  Brain_Vol.mm3             = brain * 1000,          # cm3 -> mm3
  MedialCerebellum_Vol.mm3  = med   * 1000,
  Cerebellum_Vol.mm3        = cer   * 1000,
  LateralCerebellum_Vol.mm3 = (cer - med) * 1000,    # derived: total - medial
  Source                    = raw$Source,
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
message("Wrote ", nrow(out), " species -> ", basename(final_csv), " and ", item_encoded, ".tsv")
