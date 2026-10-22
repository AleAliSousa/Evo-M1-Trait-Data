## Sacher GA, Staffeldt EF (1974). Relation of gestation time to brain weight for placental
## mammals: implications for the theory of vertebrate growth. Am Nat 108(963):593-615. Appendix table.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written as published (case normalised); harmonisation to the project key happens downstream.
##
## Input : Sacher_Staffeldt_1974_Appendix_snapshot.csv  (transcribed from the scanned print, pp. 609-612)
## Output: <script stem>.csv                 one row per printed table row (105)
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
source_name <- sub("_Appendix$", "", item_name)           # Sacher_Staffeldt_1974_Appendix -> Sacher_Staffeldt_1974
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv,
                 check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA", "n.a.", "-", "--"))

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

## printed names are upper case; an asterisk marks the 13 species the authors excluded from their analysis
printed  <- trimws(snap$Species)
excluded <- grepl("\\*\\s*$", printed)
nm       <- trimws(sub("\\*\\s*$", "", printed))
sentence <- paste0(substr(nm, 1, 1), tolower(substring(nm, 2)))

## ---- clean (gestation in days; weights in g, as printed) ----
clean <- data.frame(
  species                = sentence,
  species_as_printed     = printed,
  excluded_from_analysis = excluded,
  taxon_group            = trimws(snap[["Taxon group"]]),
  placental_type         = trimws(snap[["Placental type"]]),
  gestation_days         = num(snap[["Gest. time"]]),
  litter_size            = num(snap[["Litter size"]]),
  neonatal_brain_g       = num(snap[["Neonatal brain weight"]]),
  neonatal_body_g        = num(snap[["Neonatal body weight"]]),
  adult_brain_g          = num(snap[["Adult brain weight"]]),
  adult_body_g           = num(snap[["Adult body weight"]]),
  advancement_brain      = num(snap[["Advancement brain"]]),
  advancement_body       = num(snap[["Advancement body"]]),
  reference_numbers      = trimws(snap[["Reference numbers"]]),
  source                 = source_name,
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
