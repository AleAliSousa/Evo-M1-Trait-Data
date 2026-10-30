## Sawaguchi T (1988). Correlations of cerebral indices for 'extra' cortical parts and ecological
## variables in primates. Brain Behav Evol 32(3):129-140. Appendix (p. 137-138).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written as published (incl. printed misspellings); harmonisation happens downstream.
##
## Input : Sawaguchi__1988_Appendix_snapshot.csv  (hand transcription from the PDF, p. 137-138)
## Output: <script stem>.csv                 one row per species (47)
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

options(scipen = 999)
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
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- "Sawaguchi__1988"
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA"))
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

TS  <- num(snap[["TS"]]);  HRt <- num(snap[["HRt ha"]]); HRi <- num(snap[["HRi ha"]])
P   <- num(snap[["P g"]]); E   <- num(snap[["E g"]])

## ---- cerebral indices: NOT printed in the Appendix; recomputed from P and E with the formulae
## printed in the Methods (p. 130; Jerison 1973 / Hofman 1982). P = body weight g, E = brain weight g.
## Nc is the number of 'extra' neurons; Ve extra cortical volume; Se extra cortical surface (units as in Hofman 1982).
Nc <- (E^(2/3) - (0.03 * P^(2/3))^(2/3)) * 8 * 1e7
Ve <- 0.03 * P^0.732 * ((E / (0.015 * P^0.732))^1.273 - 1)
Se <- 0.065 * P^(2/3) * (E / (0.015 * P^0.732) - 1)

clean <- data.frame(
  species              = trimws(snap$Species),
  taxon_group          = trimws(snap$Group),
  superfamily          = trimws(snap$Superfamily),
  troop_size           = TS,
  troop_home_range_ha  = HRt,
  indiv_home_range_ha  = HRi,
  body_weight_g        = P,
  brain_weight_g       = E,
  Nc_extra_neurons_derived = Nc,
  Ve_extra_cortical_volume_derived = Ve,
  Se_extra_cortical_surface_derived = Se,
  source               = source_name,
  stringsAsFactors = FALSE
)

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
