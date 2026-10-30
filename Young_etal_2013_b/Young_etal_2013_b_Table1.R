## Young, Szabo, Phelix, Flaherty, Balaram, Foust-Yeoman, Collins & Kaas 2013, PNAS 110(47):19107-19112
## "Epileptic baboons have lower numbers of neurons in specific areas of cortex."
## doi:10.1073/pnas.1318894110 · Team Kaas · flow/isotropic fractionator.
##
## WITHIN-SPECIES DISEASE STUDY (not a comparative source). Four baboons: two neurologically NORMAL
## (09-27, 11-31) and two with EPILEPSY (10-04, 11-45). Data = whole-cortex + V1/S1/M1 cell & neuron
## numbers (Table S2) joined to case metadata (Table S1).
##
## PROVENANCE FLAGS (the point of building this):
##   * case 09-27 is the SAME baboon as Collins et al. 2010 (Dataset S1) -> specimen_duplicate_of,
##     comparative_use = exclude_duplicate_Collins2010.
##   * epileptic cases (10-04, 11-45) -> comparative_use = exclude_epileptic.
##   * only case 11-31 (normal, not previously published) is comparative_use = include.
## Snapshot frozen from Tables S1/S2; all cleaning here (golden rule).

options(scipen = 999)
## ---- paths: self-contained ----
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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))       # Young_etal_2013_b_Table1 (local name)
registry_item <- "Young_etal_2013_Table1"                       # __ReadMe Item name (shared w/ the M1 paper)
paper_doi     <- "10.1073%2Fpnas.1318894110"                    # disambiguates from the M1 paper
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

s1 <- as.data.frame(read_excel("Young_etal_2013_b_Table1_snapshot.xlsx", sheet = "TableS1"))
s1 <- s1[!is.na(s1$`Case #`) & grepl("-", s1$`Case #`), ]
s2 <- as.data.frame(read_excel("Young_etal_2013_b_Table1_snapshot.xlsx", sheet = "TableS2"))

## "4.67 billion" -> 4.67e9 ; "25.2 million" -> 2.52e7
num <- function(x) {
  x <- trimws(as.character(x)); mult <- ifelse(grepl("billion", x), 1e9, ifelse(grepl("million", x), 1e6, 1))
  suppressWarnings(as.numeric(sub("[^0-9.].*$", "", x)) * mult)
}
na_if <- function(x) ifelse(trimws(as.character(x)) %in% c("", "N/A", "NA"), NA, x)

comp <- c("09-27" = "exclude_duplicate_Collins2010", "11-31" = "include",
          "10-04" = "exclude_epileptic",            "11-45" = "exclude_epileptic")
dup  <- c("09-27" = "Collins_etal_2010_DatasetS1")
sp_pub <- c(PHA = "Papio hamadryas anubis", PHX = "Papio hamadryas anubis/cynocephalus hybrid")

m  <- s1[match(s2$`Case #`, s1$`Case #`), ]
clean <- data.frame(
  Species              = "Papio cynocephalus anubis",           # accepted; matches Collins 2010 & repo
  species_as_published = unname(sp_pub[m$Species]),             # PHA/PHX expansion from Table S1 legend
  species_code         = m$Species,
  case                 = s2$`Case #`,
  neurological_condition = s2$`Neurological condition`,
  region               = s2$Region,
  total_cells             = num(s2$`Total # cells`),
  cell_density_per_cm2    = num(s2$`Cell censity (cells/cm2)`),  # source header typo "censity"
  total_neurons           = num(s2$`Total # neurons`),
  neuron_density_per_cm2  = num(s2$`Neuron density`),
  pct_neurons             = as.numeric(s2$`Average % neurons`),
  age_y                = m$`Age (y)`,
  sex                  = m$Sex,
  body_weight_kg       = as.numeric(m$`Body weight (kg)`),
  brain_weight_g       = as.numeric(na_if(m$`Brain weight (g)`)),
  hemisphere           = m$Hemisphere,
  cortical_surface_area_cm2 = as.numeric(m$`Cortical surface area (cm2)`),
  perfusion_method     = m$`Perfusion method`,
  specimen_duplicate_of = unname(ifelse(s2$`Case #` %in% names(dup), dup[s2$`Case #`], "")),
  comparative_use      = unname(comp[s2$`Case #`]),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows (", length(unique(clean$case)), " cases x ",
        length(unique(clean$region)), " regions)")

## ---- public TSV (registry item name shared with the M1 paper -> match on DOI) ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit <- which(fc$`Item name` == registry_item & grepl(paper_doi, fc$`Item encoded`, fixed = TRUE))
  enc <- if (length(hit)) fc$`Item encoded`[hit[1]] else NA_character_
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(enc)) warning("No 'Item encoded' for the epileptic-baboon table; TSV skipped.")
  else if (!dir.exists(path.expand(tsv_dir))) warning("Shared folder not found; TSV skipped.")
  else { write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")),
                     sep = "\t", row.names = FALSE); message("Wrote ", enc, ".tsv") }
}

## NOTE: this table is deliberately NOT added to any comparative merge's item_name (within-species
## disease design; case 09-27 duplicates Collins 2010). Kept for provenance only.
