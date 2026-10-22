## Weisbecker V, Goswami A (2010). Brain size, life history, and metabolism at the marsupial/placental dichotomy.
## Proc Natl Acad Sci USA 107(37):16216-16221. SI Appendix Table S6 (parameters used in the partial correlation
## and residual regression analyses of marsupials; 52 species).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV (if registered).
## Species are written exactly as published (incl. printed misspellings); harmonisation happens downstream.
##
## Input : Weisbecker_Goswami_2010_TableS6_snapshot.csv  (transcribed from SI PDF p.5 of pnas.200906486si.pdf)
## Output: <script stem>.csv                 one row per species (52)
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
source_name <- sub("_Table[^_]*$", "", item_name)         # <Folder>_Table<N> -> <Folder>
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers; blanks stay blank) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, na.strings = character(0), colClasses = "character")
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))   # "1,354" -> 1354; em-dash -> NA

clean <- data.frame(
  species                    = trimws(snap$Species),          # as published
  body_mass_with_brain_g     = num(snap[[2]]),                # body weight published with the brain weight
  brain_mass_g               = num(snap[[3]]),
  gestation_length_d         = num(snap[[4]]),                # em-dash (not available) -> NA
  lactation_d                = num(snap[[5]]),                # text calls this weaning age
  litter_size                = num(snap[[6]]),
  body_mass_with_BMR_g       = num(snap[[7]]),                # body weight published with the BMR
  BMR_kJ_per_h               = num(snap[[8]]),
  source                     = source_name,
  stringsAsFactors = FALSE
)

## ---- table checks (paper text: 45 marsupials with gestation; 7 more without) ----
cat("rows:", nrow(clean), "| with gestation:", sum(!is.na(clean$gestation_length_d)), "| without:", sum(is.na(clean$gestation_length_d)), "\n")
cat("duplicate species:", sum(duplicated(clean$species)), "| NA in other numeric columns:", sum(is.na(clean[, c(2, 3, 5, 6, 7, 8)])), "\n")
cat("brain <= body mass in all rows:", all(clean$brain_mass_g < clean$body_mass_with_brain_g), "\n")

write.csv(clean, output_csv, row.names = FALSE)
cat(nrow(clean), "rows written to", output_csv, "\n")

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
