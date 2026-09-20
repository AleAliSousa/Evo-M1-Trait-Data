library(tidyverse)
library(ape)
#library(ggtree)
library(rtrees)
library(piggyback)

## Run from this folder regardless of the caller's working directory (Rscript from the repo root,
## source() from RStudio): all paths below (raw_VPOD/, opsin_explorer_data.RData) are relative to it.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  NA_character_
})
if (!is.na(.sp)) setwd(dirname(.sp))

if (!file.exists("raw_VPOD/vert_meta.tsv")) {
  stop("raw_VPOD/vert_meta.tsv not found.")
}

opsins <- read_tsv("raw_VPOD/vert_meta.tsv")

# -----------------------------
# CLEAN VPOD DATA
# -----------------------------

opsins_clean <- opsins %>%
  filter(
    !grepl("Anc|ancestor|pigment", Species, ignore.case = TRUE)
  )

opsins_tree <- opsins_clean %>%
  filter(
    !Species %in% c(
      "Archosaur_sp.",
      "Aulonocara_sp.",
      "Haplochromis_sp.",
      "Pseudotropheus_sp.",
      "Bos,Sebastolobus_taurus,altivelis",
      "Gekko,Anolis_gecko,carolinensis",
      "Homo,Mus_sapiens,musculus"
    )
  ) %>%
  mutate(
    Species = case_when(
      Species == "Bos_tarus" ~ "Bos_taurus",
      Species == "latipes_latipes" ~ "Oryzias_latipes",
      Species == "Zalophus_califomianus" ~ "Zalophus_californianus",
      TRUE ~ Species
    ),
    Class = case_when(
      Species == "Oryzias_latipes" ~ "Actinopteri",
      TRUE ~ Class
    )
  )

# -----------------------------
# CREATE SPECIES-LEVEL DATA
# -----------------------------

species_data <- opsins_tree %>%
  distinct(Species, Opsin_Family, Lambda_Max, Class) %>%
  group_by(Species) %>%
  summarise(
    family_label_diversity = n_distinct(Opsin_Family),
    min_lambda = min(Lambda_Max, na.rm = TRUE),
    max_lambda = max(Lambda_Max, na.rm = TRUE),
    spectral_range = max_lambda - min_lambda,
    Class = first(Class),
    .groups = "drop"
  )

# Remove any previous record-count columns
species_data <- species_data %>%
  select(
    -any_of(c(
      "n_opsin_records",
      "n_opsin_records.x",
      "n_opsin_records.y"
    ))
  )

# Count the number of VPOD opsin records for each species
record_count <- opsins_tree %>%
  count(Species, name = "n_opsin_records")

# Add record count to the species-level dataset
species_data <- species_data %>%
  left_join(record_count, by = "Species")

# -----------------------------
# SELECT MAMMAL SPECIES
# -----------------------------

mammal_species <- species_data %>%
  filter(Class == "Mammalia") %>%
  pull(Species)

# -----------------------------
# GET MAMMALIAN PHYLOGENY
# -----------------------------

mammal_tree <- get_tree(
  sp_list = mammal_species,
  taxon = "mammal",
  show_grafted = TRUE
)

# -----------------------------
# MATCH VPOD SPECIES TO TREE
# -----------------------------

mammal_tree_vpod <- ape::keep.tip(
  mammal_tree[[1]],
  mammal_species[mammal_species %in% mammal_tree[[1]]$tip.label]
)

mammal_tree_vpod$tip.label <- gsub("\\*", "", mammal_tree_vpod$tip.label)

# -----------------------------
# MATCH SPECIES DATA TO TREE
# -----------------------------

mammal_vpod_data <- species_data %>%
  filter(Species %in% mammal_tree_vpod$tip.label) %>%
  mutate(
    display_name = gsub("_", " ", Species)
  )

# -----------------------------
# PRECOMPUTE STATISTICS
# -----------------------------

pearson_test <- cor.test(
  species_data$family_label_diversity,
  species_data$spectral_range,
  method = "pearson"
)

spearman_test <- cor.test(
  species_data$family_label_diversity,
  species_data$spectral_range,
  method = "spearman"
)

opsin_model <- lm(
  spectral_range ~ family_label_diversity + n_opsin_records,
  data = species_data
)

# -----------------------------
# SAVE UPDATED DATA FOR SHINY APP
# -----------------------------

save(
  opsins_tree,
  species_data,
  mammal_species,
  mammal_tree_vpod,
  mammal_vpod_data,
  pearson_test,
  spearman_test,
  opsin_model,
  file = "opsin_explorer_data.RData"
)