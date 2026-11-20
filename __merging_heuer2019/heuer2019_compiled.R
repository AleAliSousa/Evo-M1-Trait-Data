#!/usr/bin/env Rscript
# Heuer et al. 2019 neocortical folding (3-D MRI surface reconstructions) as a
# dedicated merge: specimen-level source data aggregated to species means.
#
# Heuer 2019's measures are a DIFFERENT method from the Zilles 2-D
# coronal-contour gyrification index and from the Mota & Herculano-Houzel
# folding index. Owner decision (2026-07-31): the three are kept completely
# separate and never combined -- hence this separate merge folder and dataset
# ("Neocortical folding (MRI)"), NOT an addition to __merging_gyrification.
#
# Source item: Heuer_etal_2019/Heuer_etal_2019_Data.csv (65 specimens x 34
# species), built from the authors' own archive at
# github.com/neuroanatomy/34primates (data/derived/stats/stats.csv joined to
# src/10kTrees_34PrimateSpecies.tsv). The Zenodo record cited in the paper
# folder (10.5281/zenodo.2538751) holds only Figure-2 poster PDFs, no data.
#
# Hemisphere basis: surface area and volume are WHOLE-CEREBRUM values (both
# hemispheres combined). The surface column is therefore NOT pooled into
# __merging_cortical_areas, whose canonical total surface is per hemisphere;
# a halved join would be a separate curator decision.
#
# Aggregation: arithmetic mean of specimens within each printed species, per
# measure (median/min/max/n carried alongside). Values are kept verbatim --
# in particular the one small negative fold depth (Delta = -0.0824343,
# Microcebus murinus specimen MicrocebeMignonM_ca6c), which the authors' own
# analysis scripts clip to 0; the merge does not clip.

suppressWarnings(suppressMessages(library(tidyverse)))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript heuer2019_compiled.R", call. = FALSE)
})
merge_dir <- dirname(.sp)
root <- normalizePath(file.path(merge_dir, ".."))
d <- read.csv(file.path(root, "Heuer_etal_2019", "Heuer_etal_2019_Data.csv"),
              stringsAsFactors = FALSE, check.names = FALSE)

meta <- tribble(
  ~Measure, ~Units, ~col,
  "Cerebral_surface_area",       "mm2",   "Cerebral_surface_area_mm2",
  "Cerebral_volume",             "mm3",   "Cerebral_volume_mm3",
  "Absolute_gyrification_index", "ratio", "Absolute_gyrification_index",
  "Folding_length",              "mm",    "Folding_length_mm",
  "Folding_number",              "count", "Folding_number",
  "Fold_wavelength",             "mm",    "Fold_wavelength_mm",
  "Fold_depth",                  "mm",    "Fold_depth_mm"
)

fmt <- function(v) format(v, scientific = FALSE, trim = TRUE, digits = 12)

long <- bind_rows(lapply(seq_len(nrow(meta)), function(i) {
  v <- suppressWarnings(as.numeric(d[[meta$col[i]]]))
  tibble(Species = d$species_sci, .v = v) |>
    filter(!is.na(.v)) |>
    group_by(Species) |>
    summarise(
      Measure = meta$Measure[i],
      Units = meta$Units[i],
      Value = fmt(mean(.v)),
      Value_median = fmt(median(.v)),
      value_min = fmt(min(.v)),
      value_max = fmt(max(.v)),
      n_specimens = n(),
      source = "Heuer_etal_2019",
      .groups = "drop")
})) |> arrange(Species, Measure)

## Species naming columns (SPECIES_NAMING.md v1): Species stays the printed
## species_sci; the shared resolver adds the identity anchor + basis without
## changing the join column of this merge. Unresolved names stay under their
## printed form (species_basis = "unresolved") and are never dropped.
source(file.path(root, "_keys", "resolve_species.R"))
rs <- resolve_species(long$Species, source_publication = "Heuer_etal_2019")
long <- long |> mutate(species_printed = Species, accepted_name = rs$accepted_name,
                       species_basis = rs$species_basis, reidentified = rs$reidentified)

write_csv(long, file.path(merge_dir, "heuer2019_long.csv"))
wide <- long |> select(Species, Measure, Value) |>
  pivot_wider(names_from = Measure, values_from = Value) |> arrange(Species)
write_csv(wide, file.path(merge_dir, "heuer2019_wide.csv"))

## Source-species audit: which specimens sit behind each species row, and how
## each printed name resolved.
ids <- d |> distinct(species_sci, SpecimenID) |>
  group_by(Species = species_sci) |>
  summarise(n_specimens = n(),
            specimen_ids = paste(sort(SpecimenID), collapse = "; "),
            .groups = "drop")
rsi <- resolve_species(ids$Species, source_publication = "Heuer_etal_2019")
ids <- ids |> mutate(source = "Heuer_etal_2019", accepted_name = rsi$accepted_name,
                     species_basis = rsi$species_basis, reidentified = rsi$reidentified) |>
  select(source, Species, accepted_name, species_basis, reidentified,
         n_specimens, specimen_ids) |> arrange(Species)
write_csv(ids, file.path(merge_dir, "heuer2019_source_species_ids.csv"))

message("heuer2019: ", nrow(long), " observations across ",
        n_distinct(long$Species), " species (from ", nrow(d), " specimens); ",
        sum(rsi$species_basis == "unresolved"), " printed names unresolved")
