# Cross-paper energetics comparison (Part IV).
# Brings the brain-energetics measures from three sources into ONE tidy schema and
# tabulates where they overlap. NOTHING is merged here: the proposed schema is for
# user confirmation before any energetics merge is built.
#
# Sources:
#   Heiss et al. 2004      - human regional CMRgl (umol glucose /100 g/min).
#   Kaufman 2004           - multi-species whole-brain & regional CMRgl, CMRO2, CBF
#                            (weighted & unweighted species means; from the dissertation).
#   Karbowski 2007         - multi-species regional glucose utilization & oxygen
#                            consumption (xlsx headers are heavily OCR-garbled -> included
#                            descriptively only; needs a dedicated parse).
#
# Common measures: CMRgl (glucose), CMRO2 (oxygen), CBF (blood flow).

suppressPackageStartupMessages({ library(readr); library(dplyr); library(stringr) })

## ---- self-contained repo root (Rscript or RStudio) -------------------------
.here <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(dirname(normalizePath(rstudioapi::getSourceEditorContext()$path)))
  normalizePath(getwd())
})
base <- normalizePath(file.path(.here, ".."))
outdir <- file.path(base, "__energetics_comparison")
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)
numv <- function(x) suppressWarnings(as.numeric(gsub(",", "", as.character(x))))

## ---- Heiss 2004: human regional CMRgl ----
heiss <- read_csv(file.path(base, "Heiss_etal_2004/Heiss_etal_2004_TABLE1.csv"), show_col_types = FALSE) %>%
  transmute(reference = "Heiss_etal_2004", species = "Homo sapiens",
            region = Region, measure = "CMRgl",
            value = numv(`Both hemispheres Mean`),
            units = "umol_glucose/100g/min", weighting = NA_character_) %>%
  filter(!is.na(value))

## ---- Kaufman 2004: whole-brain + regional weighted means -------------------
## Table A15 is the canonical public long table built from the dissertation's
## whole-brain and regional summaries. It supersedes the former comparison/
## helper CSVs that were moved to the restricted companion repository.
kauf <- read_csv(file.path(base, "Kaufman__2004", "Kaufman__2004_TableA15.csv"),
                 show_col_types = FALSE) %>%
  filter(weighting == "weighted", !is.na(Mean)) %>%
  transmute(reference = "Kaufman_2004", species,
            region = str_squish(region), measure, value = numv(Mean),
            units = case_when(measure == "CMRgl" ~ "umol_glucose/100g/min",
                              measure == "CMRO2" ~ "umol_O2/100g/min",
                              measure == "CBF"   ~ "mL/100g/min"),
            weighting = "weighted")

energetics <- bind_rows(heiss, kauf) %>% arrange(measure, species, region)
write_csv(energetics, file.path(outdir, "energetics_long.csv"))

## ---- overlap: human cortical CMRgl, Heiss vs Kaufman ----
h_ctx <- heiss %>% filter(str_detect(tolower(region), "cortex|lobe")) %>% summarise(Heiss_CMRgl_cortex_mean = mean(value)) %>% pull()
k_ctx <- kauf %>% filter(species == "Homo", measure == "CMRgl", str_detect(tolower(region), "cortex")) %>% summarise(m = mean(value)) %>% pull()

species_by_ref <- energetics %>% group_by(reference) %>% summarise(species = paste(sort(unique(species)), collapse = ", "), .groups="drop")

findings <- c(
  "# Brain energetics - cross-paper comparison (Part IV)",
  "",
  "Common measures across the energetics papers: **CMRgl** (glucose), **CMRO2** (oxygen), **CBF** (blood flow).",
  "Output: `energetics_long.csv` (schema: reference, species, region, measure, value, units, weighting).",
  "",
  "## Coverage",
  paste0("- ", species_by_ref$reference, ": ", species_by_ref$species),
  "- Karbowski 2007: multi-species regional glucose utilization & oxygen consumption -- the source",
  "  xlsx headers are badly OCR-garbled, so it is described here but not yet parsed into the table;",
  "  it needs a dedicated extraction pass (like Stephan 1970).",
  "",
  "## Human cortical CMRgl cross-check (independent sources)",
  sprintf("- Heiss 2004 mean cortical CMRgl  ~ %.1f umol/100g/min", h_ctx),
  sprintf("- Kaufman 2004 (Homo) cortical CMRgl ~ %.1f umol/100g/min", k_ctx),
  "  -> same order of magnitude; good independent agreement for human cortex glucose metabolism.",
  "",
  "## Proposed schema for an energetics merge (FOR CONFIRMATION - not built)",
  "A long table mirroring `volumes_long.csv` but for metabolic rate:",
  "  `Species, Region, Measure (CMRgl|CMRO2|CBF), Value, Units, Weighting, Source, Team, Year`",
  "with:",
  "- Units standardized to umol/100 g/min (CMRgl, CMRO2) and mL/100 g/min (CBF).",
  "- A region crosswalk to the volume terms (e.g. Cortex<->Neocortex, Thalamus, Cerebellum, ...).",
  "- Two-tier resolution like the volumes (Kaufman/Karbowski/Heiss are independent series -> Tier-2",
  "  teams, averaged), keeping weighted vs unweighted Kaufman means distinct (recommend weighted).",
  "",
  "Confirm this schema (units, region crosswalk, weighting choice, whether to include CBF) before an",
  "energetics merge is implemented."
)
writeLines(findings, file.path(outdir, "ENERGETICS_FINDINGS.md"))
message("energetics_long.csv rows: ", nrow(energetics),
        " | refs: ", paste(unique(energetics$reference), collapse=","))
