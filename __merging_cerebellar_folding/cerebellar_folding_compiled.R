#!/usr/bin/env Rscript
# Cerebellar-folding measurements as a dedicated merge: Heuer 2023 section
# measures, plus Ashwell 2020's cerebellar foliation index and its two surface
# areas as SEPARATE Measures (different procedure, never pooled with Heuer's;
# see the Ashwell block below and README.md).

suppressWarnings(suppressMessages(library(tidyverse)))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript cerebellar_folding_compiled.R", call. = FALSE)
})
merge_dir <- dirname(.sp)
root <- normalizePath(file.path(merge_dir, ".."))
d <- read.csv(file.path(root, "Heuer_etal_2023", "Heuer_etal_2023_Data.csv"),
              stringsAsFactors = FALSE, check.names = FALSE)

meta <- tribble(
  ~Measure, ~Units,
  "Cerebellar_section_area", "mm2",
  "Cerebellar_section_length", "mm",
  "Cerebral_section_area", "mm2",
  "Cerebral_section_length", "mm",
  "Folial_width_median", "mm",
  "Folial_perimeter_median", "mm",
  "Molecular_layer_thickness_median", "mm"
)
source_cols <- paste0(meta$Measure, ifelse(meta$Units == "mm2", "_mm2", "_mm"))

long <- bind_rows(lapply(seq_len(nrow(meta)), function(i) {
  v <- suppressWarnings(as.numeric(d[[source_cols[i]]]))
  keep <- !is.na(v)
  tibble(
    Species = d$species_sci[keep],
    measure_class = "cerebellar_folding",
    Measure = meta$Measure[i],
    Units = meta$Units[i],
    Value = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    Value_median = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    n_sources = 1L,
    n_teams = 1L,
    n_teams_primary = 1L,
    primary_used = TRUE,
    Teams = "Heuer2023",
    roles = "primary",
    value_min = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    value_max = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12)
  )
})) |> arrange(Species, Measure)
## Species naming columns (SPECIES_NAMING.md v1): Species stays the printed species_sci; the shared
## resolver adds the identity anchor + basis without changing the join column of this merge.
source(file.path(root, "_keys", "resolve_species.R"))
rs <- resolve_species(long$Species, source_publication = "Heuer_etal_2023")
long <- long |> mutate(species_printed = Species, accepted_name = rs$accepted_name,
                       species_basis = rs$species_basis, reidentified = rs$reidentified)

## ---- Ashwell 2020 cerebellar foliation (added 2026-11-19) ------------------
## Ashwell 2020's foliation index = total pial surface area (PSA, including all
## sulci and fissures) / external surface area (ESA, the convex polygon
## enclosing the cerebellum), both estimated from histological sections. It is
## a different quantity from Heuer 2023's mid-section measures above and is
## NEVER pooled with them: it is carried in this same dataset file under its
## own Measure names, with Teams = "Ashwell2020", exactly so the app shows it
## as a separate variable in the "Cerebellar folding" dataset. PSA and ESA are
## emitted alongside the index so the ratio stays auditable.
ash <- read.csv(file.path(root, "Ashwell__2020", "Ashwell__2020_SupplementaryTable.csv"),
                stringsAsFactors = FALSE, check.names = FALSE)
ameta <- tribble(
  ~Measure, ~Units, ~col,
  "Cerebellar_foliation_index",      "ratio", "foliation_index",
  "Cerebellar_pial_surface_area",    "mm2",   "cb_pial_surface_psa_mm2",
  "Cerebellar_external_surface_area", "mm2",  "cb_ext_surface_esa_mm2"
)
along <- bind_rows(lapply(seq_len(nrow(ameta)), function(i) {
  v <- suppressWarnings(as.numeric(ash[[ameta$col[i]]]))
  keep <- !is.na(v)
  tibble(
    Species = ash$species[keep],
    measure_class = "cerebellar_folding",
    Measure = ameta$Measure[i],
    Units = ameta$Units[i],
    Value = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    Value_median = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    n_sources = 1L,
    n_teams = 1L,
    n_teams_primary = 1L,
    primary_used = TRUE,
    Teams = "Ashwell2020",
    roles = "primary",
    value_min = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    value_max = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12)
  )
}))
rs_ash <- resolve_species(along$Species, source_publication = "Ashwell__2020")
along <- along |> mutate(species_printed = Species, accepted_name = rs_ash$accepted_name,
                         species_basis = rs_ash$species_basis, reidentified = rs_ash$reidentified)

long <- bind_rows(long, along) |> arrange(Species, Measure)

write_csv(long, file.path(merge_dir, "cerebellar_folding_long.csv"))
wide <- long |> select(Species, Measure, Value) |>
  pivot_wider(names_from = Measure, values_from = Value) |> arrange(Species)
write_csv(wide, file.path(merge_dir, "cerebellar_folding_wide.csv"))
message("cerebellar folding: ", nrow(long), " observations across ",
        n_distinct(long$Species), " species (Heuer2023: ",
        sum(long$Teams == "Heuer2023"), " rows; Ashwell2020 foliation: ",
        sum(long$Teams == "Ashwell2020"), " rows across ",
        n_distinct(long$Species[long$Teams == "Ashwell2020"]), " species)")
