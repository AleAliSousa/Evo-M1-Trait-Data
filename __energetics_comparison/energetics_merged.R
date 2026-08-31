# Energetics compiled merge (Part IV) -- mirror of __merging_volumes/volumes_compiled.R for
# brain metabolic rate. Builds a two-tier merge of the energetics papers from energetics_long.csv.
#
# Measures: CMRgl (glucose), CMRO2 (oxygen) in umol/100 g/min; CBF in mL/100 g/min.
# Sources in energetics_long.csv: Heiss_etal_2004 (Homo sapiens) and Kaufman__2004 (12 genera).
#   Karbowski 2007 is NOT in energetics_long.csv (source xlsx headers are OCR-garbled and were not
#   parsed); it stays excluded and is noted in the ReadMe, not merged here.
#
# Resolution (mirrors the volume merge): each independent series is its own Tier-2 team; values are
# averaged ACROSS teams per (Species, Region, Measure). Only Homo overlaps between Heiss and Kaufman.
# Kaufman means are the WEIGHTED means (the only ones present); any "unweighted" rows are dropped.

suppressPackageStartupMessages({ library(tidyverse) })
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__energetics_comparison")
base <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"

long <- read_csv("energetics_long.csv", show_col_types = FALSE)

## --- species harmonization (genus-level Kaufman vs binomial Heiss; only Homo overlaps) ---
species_canon <- c("Homo" = "Homo sapiens")
canon_species <- function(s) ifelse(s %in% names(species_canon), species_canon[s], s)

## --- region crosswalk: raw region -> canonical region label (harmonizes Heiss/Kaufman synonyms
##     so the same structure lines up for cross-team averaging) ---
region_canon <- c(
  # Heiss_etal_2004
  "Basal forebrain"                 = "Basal_forebrain",
  "Capsula interna"                 = "Capsula_interna",
  "Caudatum"                        = "Caudate_nucleus",
  "Centrum semiovale"               = "Centrum_semiovale",
  "Cerebellar cortex"               = "Cerebellar_cortex",
  "Cerebral cortex (global average)"= "Neocortex",
  "Colliculus inferior"             = "Colliculus_inferior",
  "Colliculus superior"             = "Colliculus_superior",
  "Corpus amygdaloideum"            = "Amygdala",
  "Corpus geniculatum laterale"     = "Corpus_geniculatum_laterale",
  "Corpus geniculatum mediale"      = "Corpus_geniculatum_mediale",
  "Frontal lobe"                    = "Frontal_cortex",
  "Hippocampus"                     = "Hippocampus",
  "Insular lobe"                    = "Insula",
  "Nucleus accumbens"               = "Nucleus_accumbens",
  "Nucleus dentatus cerebelli"      = "Nucleus_dentatus_cerebelli",
  "Nucleus medial thalami"          = "Thalamus_medial_nucleus",
  "Nucleus ruber"                   = "Nucleus_ruber",
  "Nucleus subthalamicus"           = "Nucleus_subthalamicus",
  "Occipital lobe"                  = "Occipital_cortex",
  "Pallidum"                        = "Pallidum",
  "Parietal lobe"                   = "Parietal_cortex",
  "Putamen"                         = "Putamen",
  "Substantia nigra"                = "Substantia_nigra",
  "Temporal lobe"                   = "Temporal_cortex",
  "Vermis"                          = "Vermis",
  # Kaufman__2004
  "Auditory Cortex"                 = "Auditory_cortex",
  "Basal Ganglia"                   = "Basal_ganglia",
  "Cerebellum"                      = "Cerebellum",
  "Cingulate Cortex"                = "Cingulate_cortex",
  "Cortex"                          = "Neocortex",
  "Frontal Cortex"                  = "Frontal_cortex",
  "Occipital Cortex"                = "Occipital_cortex",
  "Parietal Cortex"                 = "Parietal_cortex",
  "Sensorimotor Cortex"             = "Sensorimotor_cortex",
  "Temporal Cortex"                 = "Temporal_cortex",
  "Thalamus"                        = "Thalamus",
  "White Matter"                    = "White_matter",
  "Whole Brain"                     = "Whole_brain"
)
# NOTE: Heiss "Frontal/Occipital/Parietal/Temporal lobe" (anatomical lobe) is aligned to Kaufman's
# "* Cortex" (grey) under one canonical *_cortex label; for Homo this lets the two independent
# series be averaged. The lobe-vs-cortex distinction is an approximation recorded in the ReadMe.

## --- canonical region -> volume term (only where a clean single counterpart exists in the merge) ---
volume_term <- c(
  "Neocortex"                   = "Neocortex_Vol.mm3",
  "Cerebellum"                  = "Cerebellum_Vol.mm3",
  "Thalamus"                    = "Thalamus_Vol.mm3",
  "Hippocampus"                 = "Hippocampus_Vol.mm3",
  "Amygdala"                    = "Amygdala_Vol.mm3",
  "Pallidum"                    = "Pallidum_Vol.mm3",
  "Nucleus_subthalamicus"       = "Nucleus_subthalamicus_Vol.mm3",
  "Corpus_geniculatum_laterale" = "Corpus_geniculatum_laterale_Vol.mm3",
  "Whole_brain"                 = "Total_brain_net_volume_Vol.mm3"
)

## --- standardized measure units (CMRgl/CMRO2 -> umol/100g/min; CBF -> mL/100g/min) ---
measure_units <- c("CMRgl" = "umol/100g/min", "CMRO2" = "umol/100g/min", "CBF" = "mL/100g/min")

prepped <- long %>%
  filter(is.na(weighting) | weighting != "unweighted") %>%           # weighted preferred; drop unweighted
  mutate(
    Species   = canon_species(species),
    Region    = ifelse(region %in% names(region_canon), region_canon[region], region),
    Measure   = measure,
    Team      = reference,
    Units     = ifelse(Measure %in% names(measure_units), measure_units[Measure], units),
    Value     = suppressWarnings(as.numeric(value))
  ) %>%
  filter(!is.na(Value))

if (any(!prepped$region %in% names(region_canon)))
  warning("Unmapped energetics region(s): ",
          paste(sort(unique(prepped$region[!prepped$region %in% names(region_canon)])), collapse = "; "))

## --- Tier-2: mean within team, then average across teams (mirrors the volume merge) ---
per_team <- prepped %>%
  group_by(Species, Region, Measure, Units, Team) %>%
  summarise(Value = mean(Value), .groups = "drop")

merged_long <- per_team %>%
  group_by(Species, Region, Measure, Units) %>%
  summarise(Value    = mean(Value),
            Teams    = paste(sort(unique(Team)), collapse = "; "),
            n_teams  = n_distinct(Team),
            .groups  = "drop") %>%
  mutate(Volume_term = ifelse(Region %in% names(volume_term), volume_term[Region], NA_character_)) %>%
  arrange(Species, Region, Measure)
write_csv(merged_long, "energetics_merged_long.csv")

## --- wide view: one row per species, one column per Region x Measure (units consistent per column) ---
merged_wide <- merged_long %>%
  mutate(col = paste0(Region, "__", Measure)) %>%
  select(Species, col, Value) %>%
  pivot_wider(names_from = col, values_from = Value) %>%
  arrange(Species)
write_csv(merged_wide, "energetics_merged_wide.csv")

## --- short ReadMe ---
n_avg <- merged_long %>% filter(n_teams > 1) %>% nrow()
readme <- c(
  "# Energetics compiled merge (Part IV)",
  "",
  "`energetics_merged.R` builds a two-tier merge of brain metabolic rate from `energetics_long.csv`,",
  "mirroring `__merging_volumes/volumes_long.csv` for the volume data type.",
  "",
  "## Inputs",
  "- Heiss_etal_2004 - Homo sapiens regional CMRgl (PET).",
  "- Kaufman__2004 - 12 genera, weighted-mean CMRgl / CMRO2 / CBF.",
  "- Karbowski 2007 - NOT included: the source xlsx headers are OCR-garbled and were never parsed",
  "  into `energetics_long.csv`; it needs a dedicated extraction pass before it can be merged.",
  "",
  "## Schema (`energetics_merged_long.csv`)",
  "`Species, Region, Measure, Units, Value, Teams, n_teams, Volume_term`",
  "- Measure in {CMRgl, CMRO2, CBF}; Units = umol/100g/min (CMRgl, CMRO2) or mL/100g/min (CBF).",
  "- `Region` is a canonical label (Heiss/Kaufman synonyms harmonized); `Volume_term` links to the",
  "  matching `*_Vol.mm3` term in the volume merge where a clean single counterpart exists (else NA).",
  "",
  "## Resolution",
  "Each paper is an independent Tier-2 team; values are averaged within a team, then ACROSS teams per",
  "(Species, Region, Measure). Only Homo sapiens overlaps the two teams (Heiss + Kaufman), giving",
  sprintf("%d cross-team averaged cells. Kaufman values are the weighted means (unweighted dropped if present).", n_avg),
  "",
  "## Caveats",
  "- Heiss anatomical lobes (Frontal/Occipital/Parietal/Temporal lobe, incl. white matter) are aligned",
  "  to Kaufman's grey-matter '* Cortex' under one canonical `*_cortex` label so the two human series",
  "  can be averaged; treat those averaged cortical cells as lobe~cortex approximations.",
  "- Kaufman species are genus-level (e.g. `Macaca`, `Canis`); only `Homo` was harmonized to a binomial",
  "  (`Homo sapiens`) to align with Heiss. Genus-level rows are kept as-is.",
  "",
  "## Cross-check (independent human cortical CMRgl)",
  "Heiss cerebral-cortex global-average CMRgl (33.5) vs Kaufman Homo Cortex CMRgl (36.78) -> averaged",
  "in the merge; same order of magnitude, good agreement."
)
writeLines(readme, "energetics_merged.ReadMe.md")

## --- summary ---
spotchk <- merged_long %>% filter(Species == "Homo sapiens", Region == "Neocortex", Measure == "CMRgl")
message(nrow(merged_long), " merged cells | ", n_distinct(merged_long$Species), " species | ",
        nrow(merged_wide), " wide rows x ", ncol(merged_wide) - 1, " region-measure columns | ",
        n_avg, " cross-team averaged cells")
if (nrow(spotchk))
  message(sprintf("spot-check Homo Neocortex CMRgl = %.2f (mean of Heiss 33.5 & Kaufman 36.78), n_teams=%d",
                  spotchk$Value[1], spotchk$n_teams[1]))
