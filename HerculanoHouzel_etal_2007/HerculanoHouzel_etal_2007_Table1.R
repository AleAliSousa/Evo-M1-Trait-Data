## Herculano-Houzel S, Collins CE, Wong P, Kaas JH (2007). Cellular scaling rules for primate brains.
## Proc Natl Acad Sci USA 104(9):3562-3567. Table 1 (isotropic fractionator; tree shrew + 6 primates).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as printed (vernacular); binomials from the Fig. 1 legend are carried
## in a separate column. Harmonisation to the project key happens downstream.
##
## Input : HerculanoHouzel_etal_2007_Table1_snapshot.csv  (transcribed from PDF p.2; 7 species + variation row)
## Output: <script stem>.csv                 one row per species (7; the 'Variation' row is dropped)
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
folder      <- dirname(.sp)
item_name   <- tools::file_path_sans_ext(basename(.sp))
source_name <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")
base        <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character")
snap <- snap[!grepl("^Variation", snap$Species), ]            # summary row, not a species

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
## "mean ± SD" cells -> mean / SD (SD NA where only a mean is printed)
mean_of <- function(x) num(sub("\\s*±.*$", "", x))
sd_of   <- function(x) ifelse(grepl("±", x), num(sub("^.*±\\s*", "", x)), NA_real_)

## binomials given only in the Fig. 1 legend (Tu, Ca, Ot, Ao, Sa, Ce, Ma)
binom <- c("Tree shrew" = "Tupaia glis", "Marmoset" = "Callithrix jacchus", "Galago" = "Otolemur garnettii",
           "Owl monkey" = "Aotus trivirgatus", "Squirrel monkey" = "Saimiri sciureus",
           "Capuchin monkey" = "Cebus apella", "Macaque monkey" = "Macaca fascicularis")

## ---- clean: neuron / non-neuron counts printed in x10^6 -> absolute counts (x 1e6) ----
clean <- data.frame(
  species                 = trimws(snap$Species),           # name exactly as published
  species_binomial_fig1   = unname(binom[trimws(snap$Species)]),
  body_mass_g             = mean_of(snap[[2]]),
  body_mass_SD            = sd_of(snap[[2]]),
  brain_mass_g            = mean_of(snap[[3]]),
  brain_mass_SD           = sd_of(snap[[3]]),
  total_neurons_n         = mean_of(snap[[4]]) * 1e6,
  total_neurons_SD        = sd_of(snap[[4]]) * 1e6,
  total_nonneurons_n      = mean_of(snap[[5]]) * 1e6,
  total_nonneurons_SD     = sd_of(snap[[5]]) * 1e6,
  source                  = source_name,
  stringsAsFactors = FALSE
)
cnt <- grep("^total_", names(clean))          # counts: remove floating-point dust from x1e6
clean[, cnt] <- lapply(clean[, cnt], round)

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
