## Young, Collins & Kaas 2013, Front Neural Circuits 7:30 — Table 1
## doi:10.3389/fncir.2013.00030 · Team Kaas (Vanderbilt) · flow/isotropic fractionator.
## PRIMARY MOTOR CORTEX (M1) mass, surface area, and cell/neuron densities for 6 primate species
## (7 rows: two Papio labels = homotypic synonyms). This is a REGIONAL (M1) companion to
## Collins et al. 2010 (whole cortex), Young et al. 2013b (baboons), and Collins et al. 2016
## (chimpanzee). Specimen overlap is explicit below. The snapshot is frozen; its added `Specimen`
## column contains an older curator assignment, so the analysis-ready institution is reconstructed
## from the paper's Materials and Methods rather than silently editing the frozen file.

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # Young_etal_2013_Table1
paper_doi <- "10.3389%2Ffncir.2013.00030"                      # disambiguates the 2 Young_etal_2013_Table1 rows
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel("Young_etal_2013_Table1_snapshot.xlsx", sheet = "reformatted"))
raw <- raw[!is.na(raw$Species), ]

## helpers: values printed "N/A" -> NA; SD printed " ± 0.02" -> 0.02
num <- function(x) suppressWarnings(as.numeric(ifelse(trimws(x) %in% c("", "N/A", "NA"), NA, x)))
sdn <- function(x) suppressWarnings(as.numeric(sub(".*?([-+]?[0-9]*\\.?[0-9]+).*", "\\1",
                     ifelse(trimws(x) %in% c("", "N/A", "NA"), NA, x))))

sp_fix <- c("Saimiri sciuresis" = "Saimiri sciureus")            # printed typo

## Provenance stated in Materials and Methods (p. 2), not in printed Table 1:
## Vanderbilt: galagos + New World monkeys; Washington NPRC: macaques + P. cynocephalus 09-27;
## Texas Biomedical: P. hamadryas 11-31 + chimpanzee.
institution <- c(
  "Otolemur garnettii" = "Vanderbilt University",
  "Aotus nancymaae" = "Vanderbilt University",
  "Saimiri sciureus" = "Vanderbilt University",
  "Macaca nemestrina" = "Washington National Primate Research Center",
  "Papio cynocephalus anubis" = "Washington National Primate Research Center",
  "Papio hamadryas anubis" = "Texas Biomedical Research Institute",
  "Pan troglodytes" = "Texas Biomedical Research Institute"
)

specimen_identity <- c(
  "Otolemur garnettii" = "three-animal mean; includes Collins 2010 case 08-07 plus two unresolved galagos",
  "Aotus nancymaae" = "probable Collins 2010 case 07-78",
  "Saimiri sciureus" = "single unresolved Vanderbilt squirrel monkey",
  "Macaca nemestrina" = "two unresolved Washington NPRC macaques",
  "Papio cynocephalus anubis" = "case 09-27",
  "Papio hamadryas anubis" = "case 11-31",
  "Pan troglodytes" = "probable KAAS-PAN-11_38"
)

match_status <- c(
  "Otolemur garnettii" = "partial_overlap",
  "Aotus nancymaae" = "probable",
  "Saimiri sciureus" = "no_known_overlap",
  "Macaca nemestrina" = "no_known_overlap",
  "Papio cynocephalus anubis" = "probable",
  "Papio hamadryas anubis" = "probable",
  "Pan troglodytes" = "probable"
)

overlap <- c(
  "Otolemur garnettii" = "partial: case 08-07 is one of the three; the species mean is not decomposable",
  "Aotus nancymaae" = "probable same owl monkey as Collins 2010 case 07-78",
  "Saimiri sciureus" = "no",
  "Macaca nemestrina" = "no (Collins 2010 macaque is M. mulatta case 08-59)",
  "Papio cynocephalus anubis" = "same normal baboon as Collins 2010 case 09-27",
  "Papio hamadryas anubis" = "no",
  "Pan troglodytes" = "no"
)

other_overlap <- c(
  "Otolemur garnettii" = NA_character_,
  "Aotus nancymaae" = NA_character_,
  "Saimiri sciureus" = NA_character_,
  "Macaca nemestrina" = NA_character_,
  "Papio cynocephalus anubis" = "same case 09-27 as Young 2013b and Turner 2016",
  "Papio hamadryas anubis" = "same case 11-31 as Young 2013b and Turner 2016",
  "Pan troglodytes" = "high-confidence probable same chimp as Collins 2016 (KAAS-PAN-11_38)"
)

acc <- ifelse(raw$Species %in% names(sp_fix), sp_fix[raw$Species], raw$Species)

clean <- data.frame(
  Species              = acc,
  species_as_published = raw$`Species published`,
  species_note         = raw$`Species note`,
  specimen_source      = unname(institution[acc]),
  specimen_identity    = unname(specimen_identity[acc]),
  specimen_match_status = unname(match_status[acc]),
  n_hemispheres        = num(raw$`n cortical hemispheres`),
  M1_mass_g                 = num(raw$`M1 Mass (g)`),                       M1_mass_g_sd = sdn(raw$`M1 Mass (g) SD`),
  M1_pct_total_mass         = num(raw$`M1 Percent total mass`),             M1_pct_total_mass_sd = sdn(raw$`M1 Percent total mass SD`),
  M1_area_mm2               = num(raw$`M1 Area (mm2)`),                     M1_area_mm2_sd = sdn(raw$`M1 Area (mm2) SD`),
  M1_pct_total_area         = num(raw$`M1 Percent total area`),             M1_pct_total_area_sd = sdn(raw$`M1 Percent total area SD`),
  M1_cell_density_per_g_M   = num(raw$`M1 Cell density (millions) Cells/g`),M1_cell_density_per_g_M_sd = sdn(raw$`M1 Cell density (millions) Cells/g SD`),
  M1_cell_density_per_mm2_M = num(raw$`M1 Cell density (millions) Cells/mm2`),M1_cell_density_per_mm2_M_sd = sdn(raw$`M1 Cell density (millions) Cells/mm2 SD`),
  M1_pct_neurons            = num(raw$`Percent neurons in M1 (%)`),         M1_pct_neurons_sd = sdn(raw$`Percent neurons in M1 (%) SD`),
  M1_neuron_density_per_g_M = num(raw$`Neuron density (millions) Neurons/g`),M1_neuron_density_per_g_M_sd = sdn(raw$`Neuron density (millions) Neurons/g SD`),
  M1_neuron_density_per_mm2_M = num(raw$`Neuron density (millions) Neurons/mm2`),M1_neuron_density_per_mm2_M_sd = sdn(raw$`Neuron density (millions) Neurons/mm2 SD`),
  M1_pct_neuron_diff_from_avg = num(raw$`Percent neuron difference from total average (%)`),
  M1_pct_neuron_diff_from_avg_sd = sdn(raw$`Percent neuron difference from total average (%) SD`),
  specimen_overlap_Collins2010 = unname(overlap[acc]),
  specimen_overlap_other = unname(other_overlap[acc]),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

## ---- public TSV: resolve the code by (Item name AND this paper's DOI) — the name is shared by the
##      epileptic-baboon table (folder _b), so match on DOI to pick the M1 row ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  hit <- which(fc$`Item name` == item_name & grepl(paper_doi, fc$`Item encoded`, fixed = TRUE))
  item_encoded <- if (length(hit)) fc$`Item encoded`[hit[1]] else NA_character_
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(item_encoded)) warning("No M1 'Item encoded' found; TSV skipped.")
  else if (!dir.exists(path.expand(tsv_dir))) warning("Shared folder not found; TSV skipped.")
  else {
    write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
    message("Wrote ", item_encoded, ".tsv")
  }
}
