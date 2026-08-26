## Compile the comparative cortical-area dataset (number of areas + cortical surface area).
## Pattern mirrors __merging_volumes / __merging_cellcounts: read each source's public TSV, relabel
## its columns via the stacked standardized-term map, stack to long, summarise to wide.
## Outputs: cortical_areas_long.csv, cortical_areas_wide.csv, cortical_areas_source_species_ids.csv
suppressWarnings(suppressMessages(library(tidyverse)))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp))
base   <- normalizePath(file.path(dirname(.sp), ".."))
tsvdir <- file.path(base, "__Public", "comparative-data")

## which tables feed this merge (Item names) -> their measure roles handled below
item_name <- c("Changizi__2001_Figure3",
               "Finlay_etal_2006_Table6.1",
               "Collins_etal_2010_DatasetS1",       # surface via collins_2010_surface_from_paper.csv
               "Young_etal_2013_Table1",            # REGIONAL M1 surface area (M1_Surface_Area.mm2)
               "Turner_etal_2016_Table1",           # whole-cortex surface via turner_2016_surface.csv (case dedupe)
               "Collins_etal_2016_Table1",          # ADDED 2026-08-25: chimp cortex/V1/V2/M1 areas (bespoke block; M1 superseded by Young 2013 — same specimen KAAS-PAN-11_38)
               "Mota_Herculano-Houzel_2015_TableS1",# ADDED 2026-08-25: OWN columns only (AG total surface, MHH folding index, thickness; per ONE hemisphere). "_other" columns are secondary compilations — never merged.
               "Mota_etal_2019_SupplementaryTableS1",# ADDED 2026-08-25: AT/AE/T only (per one hemisphere). VT/VG/VW volumes HELD for a __merging_volumes overlap audit; N (cortical neurons) skipped as a compilation.
               "Smaers_etal_2017_TableS1part2",     # ADDED 2026-08-25 (owner decision): SECONDARY — Brodmann 1909 regional surfaces via Smaers 2017. Ingested deliberately (primary not built); a future Brodmann-1909 build supersedes it.
               "Brodmann__1913_Table1")             # ADDED 2026-08-25: PRIMARY — Brodmann 1913 total cortical surface, one hemisphere, 38 taxa (bespoke block: one human row kept).
## Krubitzer_Kaas_1990_Table1 is documented as a related reference only: it reports RELATIVE % of a
## fixed 8-field visual scheme, not comparable to Finlay's area counts and with no absolute surface —
## so it is NOT merged numerically (see README). Its term map keeps only Species.

## Species aliases — unify spelling variants across sources so the same animal joins on one Species.
## (Collins printed "Otolemur garnetti"/"Aotus nancymae"; Young the correct "garnettii"/"nancymaae";
##  the two Papio labels in Young are NCBI homotypic synonyms.)
sp_alias <- c("Otolemur garnetti" = "Otolemur garnettii",
              "Aotus nancymae"    = "Aotus nancymaae",
              "Papio hamadryas anubis" = "Papio cynocephalus anubis",
              ## Mota 2015/2019 printed-name repairs (2026-08-25). Mota 2019 re-reports the same
              ## hemisphere measurements (AT values identical to 2015's AG) under typo'd names;
              ## without these aliases the lineage supersede misses and one animal splits into two
              ## Species rows. Dasyprocta: both papers misspell D. prymnolopha (2015 "promnolopha",
              ## 2019 "primnolopha"). Papio: three labels, one olive-baboon taxon.
              "Girafa camelopardalis"     = "Giraffa camelopardalis",
              "Tragelaphus stripceros"    = "Tragelaphus strepsiceros",
              "Dasyprocta promnolopha"    = "Dasyprocta prymnolopha",
              "Dasyprocta primnolopha"    = "Dasyprocta prymnolopha",
              "Papio anubis"              = "Papio cynocephalus anubis",
              "Papio anubis cynocephalus" = "Papio cynocephalus anubis",
              ## Smaers 2017 part2 prints the chimp as a trinomial (2026-08-25). NOTE: its
              ## Papio_cynocephalus and Papio_hamadryas are two SEPARATE Brodmann taxa — neither
              ## is aliased to the Kaas-lab "Papio cynocephalus anubis" (different animals).
              "Pan troglodytes troglodytes" = "Pan troglodytes")
unify <- function(s) ifelse(s %in% names(sp_alias), sp_alias[s], s)

## Trait classes: whole-cortex vs regional. Regional traits are NEVER pooled with whole-cortex ones.
regional_terms <- c("M1_Surface_Area.mm2", "V1_Surface_Area.mm2", "V2_Surface_Area.mm2",
                    "Prefrontal_Surface_Area.mm2", "OtherAssociation_Surface_Area.mm2",
                    "FrontalMotor_Surface_Area.mm2")   # FrontalMotor = Brodmann's agranular frontal block, NOT M1

## HEMISPHERE CONVENTION (2026-08-25): every surface source in this merge measures ONE cortical
## hemisphere (Collins 2010/2016 flattened hemispheres, Turner per-hemisphere averaged per animal,
## Young M1 per hemisphere, Mota 2015/2019 "one cortical hemisphere only" per caption). So
## CorticalSurface_Area.mm2 and CorticalExposedSurface_Area.mm2 are PER-HEMISPHERE values —
## do not double to whole-brain without recording it (see laterality/doubling provenance policy).

terms  <- readr::read_csv("standardized_term_cortical_areas.csv", show_col_types = FALSE)
codes  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
enc    <- function(nm) {
  # Fail loudly on an unresolved item name. This used to return NA, and
  # file.path(tsvdir, paste0(NA, ".tsv")) is "NA.tsv" -- a path that really existed
  # in __Public/comparative-data/ as a stale artefact of an earlier unresolved
  # build. So a lost registry row did not stop the merge; it fed it the WRONG
  # table. (2026-08-20: exactly this happened to the gyrification merge.)
  e <- codes$`Item encoded`[match(nm, codes$`Item name`)]
  if (length(e) != 1L || is.na(e) || !nzchar(e))
    stop("enc('", nm, "'): no 'Item encoded' in __ReadMe.xlsx 'Item name'. ",
         "Add or repair the registry row.", call. = FALSE)
  f <- file.path(tsvdir, paste0(e, ".tsv"))
  if (!file.exists(f))
    stop("enc('", nm, "'): registry resolves to a TSV that is not on disk -> ", f,
         " (run that source's own build script, or fix 'Item encoded').", call. = FALSE)
  e
}

## ---- long: one row per (Species, Standardized_Term, source) ----
long <- list()

# generic count/surface sources read straight from their TSV (Changizi 2001, Finlay, Young M1,
# Changizi & Shimojo 2005). The Species join column is resolved from each source's term map (the
# Original_Term mapped to Standardized_Term == "Species"), since e.g. C&S 2005 prints it as species_sci.
for (nm in c("Changizi__2001_Figure3", "Finlay_etal_2006_Table6.1", "Young_etal_2013_Table1",
             "Changizi_Shimojo_2005_Table1",
             "Mota_Herculano-Houzel_2015_TableS1",     # own columns only (term map maps nothing else)
             "Mota_etal_2019_SupplementaryTableS1")) { # AT/AE/T only (term map maps nothing else)
  tsv <- file.path(tsvdir, paste0(enc(nm), ".tsv"))
  d   <- readr::read_tsv(tsv, show_col_types = FALSE)
  spcol <- terms$Original_Term[terms$Reference == nm & terms$Standardized_Term == "Species"]
  spcol <- if (length(spcol) && spcol %in% names(d)) spcol else "Species"
  tm  <- terms |> filter(Reference == nm, Standardized_Term != "Species")
  for (i in seq_len(nrow(tm))) {
    oc <- tm$Original_Term[i]; st <- tm$Standardized_Term[i]
    if (!oc %in% names(d)) next
    long[[paste(nm, st)]] <- tibble(
      Species = d[[spcol]], Standardized_Term = st,
      value = suppressWarnings(as.numeric(d[[oc]])), source = nm)
  }
}

# Collins: whole-hemisphere surface from the paper file (per-piece TSV undercounts galago #1)
cs <- readr::read_csv("collins_2010_surface_from_paper.csv", show_col_types = FALSE)
long[["Collins surface"]] <- tibble(Species = cs$Species, Standardized_Term = "CorticalSurface_Area.mm2",
                                    value = cs$`CorticalSurface_Area.mm2`, source = "Collins_etal_2010_DatasetS1")

# Turner 2016: whole-cortex ("brain") surface, CASE-LEVEL DEDUPE — drop cases that are the same
# specimen already contributed by another source (09-27 = Collins 2010 baboon). Multiple hemispheres/
# cases of one animal are averaged to one per-species-per-specimen value first, then to species.
ts <- readr::read_csv("turner_2016_surface.csv", show_col_types = FALSE) |>
  filter(dedupe_status == "include") |>
  group_by(Species, case) |> summarise(v = mean(`CorticalSurface_Area.mm2`), .groups = "drop")  # avg hemispheres of one animal
long[["Turner surface"]] <- tibble(Species = ts$Species, Standardized_Term = "CorticalSurface_Area.mm2",
                                   value = ts$v, source = "Turner_etal_2016_Table1")

# Collins 2016 (ADDED 2026-08-25): one chimp (Texas Biomedical, specimen crosswalk KAAS-PAN-11_38),
# right hemisphere, flattened-cortex areas by structure (cm2 -> mm2). Only architectonic regions are
# wired: whole cortex, V1, V2, M1. The "somatosensory/premotor block" and "Prefrontal Cortex" rows
# are dissection blocks with arbitrary boundaries — provenance only, not comparable areas.
# The left-hemisphere V1 serial-section row is a volume (no area) and is excluded by the area filter.
c16map <- c("cerebral cortex" = "CorticalSurface_Area.mm2",
            "V1"              = "V1_Surface_Area.mm2",
            "V2"              = "V2_Surface_Area.mm2",
            "M1"              = "M1_Surface_Area.mm2")
c16 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Collins_etal_2016_Table1"), ".tsv")),
                       show_col_types = FALSE) |>
  filter(method == "flattened", structure %in% names(c16map), !is.na(area_cm2))
long[["Collins 2016 areas"]] <- tibble(
  Species = c16$Species, Standardized_Term = unname(c16map[c16$structure]),
  value = c16$area_cm2 * 100, source = "Collins_etal_2016_Table1")

# Smaers 2017 part2 (ADDED 2026-08-25, owner decision): SECONDARY source — Brodmann 1909's
# 4-region surface partition (primary visual / prefrontal / other association / frontal motor),
# reproduced in Smaers 2017 Table S1. Ingested deliberately because the Brodmann-1909 primary is
# not built; if it ever is, it supersedes these rows. Species arrive underscore-joined.
# ADDITIVITY AUDIT (see README): the four regions sum EXACTLY to Brodmann 1913's per-hemisphere
# totals for marmoset, gibbon and chimp — confirming values are per ONE hemisphere. Mandrill is
# off by exactly +10,000 (sum 31,321 vs total 21,321): one of the two sources carries a misprint,
# most plausibly other_association 23422 -> 13422. That single cell is EXCLUDED below.
s17 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Smaers_etal_2017_TableS1part2"), ".tsv")),
                       show_col_types = FALSE) |>
  mutate(species = gsub("_", " ", species))
s17map <- c(primary_visual_surface    = "V1_Surface_Area.mm2",
            prefrontal_surface        = "Prefrontal_Surface_Area.mm2",
            other_association_surface = "OtherAssociation_Surface_Area.mm2",
            frontal_motor_surface     = "FrontalMotor_Surface_Area.mm2")
for (oc in names(s17map)) {
  long[[paste("Smaers17", oc)]] <- tibble(
    Species = s17$species, Standardized_Term = unname(s17map[oc]),
    value = suppressWarnings(as.numeric(s17[[oc]])), source = "Smaers_etal_2017_TableS1part2")
}

# Brodmann 1913 Table 1 (ADDED 2026-08-25): PRIMARY — total cortical surface of ONE hemisphere,
# 38 taxa across mammal orders (historical planimetry; expect method-level conflicts with modern
# sources, surfaced by conflict_flag). Of the five human rows only "Europäer: Durchschnitt"
# (112,471 mm2) enters the merge: Maximal-/Minimalwert are the envelope of the same series, and
# the "Naturmenschen"/"Idioten" rows are historical subset categories (the latter pathological) —
# all four are documented in the source folder, none is a species mean.
b13 <- readr::read_tsv(file.path(tsvdir, paste0(enc("Brodmann__1913_Table1"), ".tsv")),
                       show_col_types = FALSE) |>
  filter(Species != "Homo sapiens" | Species_Brodmann1913 == "Europäer: Durchschnitt")
long[["Brodmann 1913 surface"]] <- tibble(
  Species = b13$Species, Standardized_Term = "CorticalSurface_Area.mm2",
  value = b13$`CorticalSurface_1hemisphere.mm2`, source = "Brodmann__1913_Table1")

long <- bind_rows(long) |> filter(!is.na(value)) |>
  mutate(Species = unify(Species),                                  # harmonise spelling variants
         trait_class = ifelse(Standardized_Term %in% regional_terms, "regional", "whole_cortex"))

## Mota 2019 printed-thickness repair (2026-08-25). The paper defines mean thickness as
## T = VG/AG (gray volume / total surface), and 31 of 38 printed T values satisfy VG/AT exactly.
## In 6 rows (Cavia, Dasyprocta, Hydrochoerus, Callimico, Macaca radiata, M. fascicularis) the
## printed T instead DUPLICATES the AT/AE folding ratio (equal to 3 decimals) and in Sarcophilus
## it slips a decimal (printed 1198). Where the SAME hemisphere appears in Mota 2015 (AG = AT
## identical), the 2015 printed T equals VG/AT (Dasyprocta 1.846, Hydrochoerus 2.814, Callimico
## 1.600, M. fascicularis 1.411) — confirming VG/AT is the intended value. One nested error:
## Cavia's printed VG (412.4) fails VG + VW = VT (506.9 vs 906.9) — an additivity sweep of all 38
## rows finds ONLY Cavia — so its gray volume is recovered as VT − VW = 812.4, giving
## T = 812.4/536.1 = 1.515, exactly the 2015 printed T for the same hemisphere. So: where printed
## T deviates >5% from (repaired) VG/AT, the definitional value replaces it here. The frozen TSV
## keeps the printed numbers; this is an export/spreadsheet artefact repair, same policy as the
## Sherwood 2004 en-dashes.
m19tab <- readr::read_tsv(file.path(tsvdir, paste0(enc("Mota_etal_2019_SupplementaryTableS1"), ".tsv")),
                          show_col_types = FALSE) |>
  mutate(VG_use = ifelse(!is.na(VT_mm3) & !is.na(VW_mm3) & !is.na(VG_mm3) &
                         abs(VG_mm3 + VW_mm3 - VT_mm3) / VT_mm3 > 0.02,
                         VT_mm3 - VW_mm3, VG_mm3),
         T_def  = VG_use / AT_mm2) |>
  filter(!is.na(T_mm), !is.na(T_def), abs(T_mm - T_def) / T_def > 0.05)
if (nrow(m19tab)) {
  message("Mota 2019 thickness repaired for ", nrow(m19tab), " species (printed T != VG/AT): ",
          paste(m19tab$Species, collapse = ", "))
  for (i in seq_len(nrow(m19tab))) {
    sel <- long$source == "Mota_etal_2019_SupplementaryTableS1" &
           long$Standardized_Term == "CorticalThickness.mm" &
           long$Species == unify(m19tab$Species[i])
    long$value[sel] <- m19tab$T_def[i]
  }
}

## ---- supersede: within the Changizi lineage, C&S 2005 (areas_shown) supersedes Changizi 2001
## (Fig.3 n_areas) for the SAME species. Same author, revised counts -> not independent, don't average.
## Superseded rows are kept in _long with status = "superseded_by_Changizi_Shimojo_2005" but excluded
## from _wide. Changizi 2001's species that C&S 2005 lacks (e.g. Homo sapiens) stay active.
newer <- long$Species[long$source == "Changizi_Shimojo_2005_Table1" &
                       long$Standardized_Term == "n_cortical_areas"]
long$status <- "active"
long$status[long$source == "Changizi__2001_Figure3" &
            long$Standardized_Term == "n_cortical_areas" &
            long$Species %in% newer] <- "superseded_by_Changizi_Shimojo_2005"

## supersede: Kaas-lab chimp (2026-08-25). Collins 2016 and Young 2013 measured the SAME Texas
## Biomedical chimpanzee (specimen crosswalk KAAS-PAN-11_38; Young = probable link). Their M1 areas
## (2497 vs 2700 mm2) differ only by dissection boundary — NOT independent, never average. Young 2013
## is the M1-dedicated methods paper, so Young keeps M1; the Collins 2016 M1 row is retained in
## _long as superseded. Collins 2016's whole-cortex/V1/V2 areas have no Young counterpart -> active.
y_m1 <- long$Species[long$source == "Young_etal_2013_Table1" &
                     long$Standardized_Term == "M1_Surface_Area.mm2"]
long$status[long$source == "Collins_etal_2016_Table1" &
            long$Standardized_Term == "M1_Surface_Area.mm2" &
            long$Species %in% y_m1] <- "superseded_by_Young_etal_2013"

## supersede: Mota lineage (2026-08-25). Mota 2019 is the same lab's later, larger release of its
## own hemisphere measurements; where it reports the same species x term as Mota 2015's own columns
## (total surface, thickness), the 2015 value is not independent -> 2019 wins, 2015 kept as
## superseded. FoldingIndex_MHH exists only in 2015 and stays active; AE exists only in 2019.
for (tt in c("CorticalSurface_Area.mm2", "CorticalThickness.mm")) {
  m19 <- long$Species[long$source == "Mota_etal_2019_SupplementaryTableS1" &
                      long$Standardized_Term == tt]
  long$status[long$source == "Mota_Herculano-Houzel_2015_TableS1" &
              long$Standardized_Term == tt &
              long$Species %in% m19] <- "superseded_by_Mota_etal_2019"
}
## FLAG: the ENTIRE Finlay 2006 source (owner decision 2026-08-25). The source-attribution audit
## (Finlay_etal_2006/Finlay_etal_2006_Table6.1_source_attribution.csv) found its traced surfaces
## systematically low for small mammals/marsupials, several rows with no citable primary, and the
## owl monkey high; the counts rest partly on unpublished maps. ALL Finlay rows are therefore held
## out of _wide (kept in _long) until verified against the Project Kaskan remeasuring dataset once
## that is built (restricted repo; registry stage already says "Species -- wait for Project
## Kaskan"). NOTE the side effect: n_visual_areas / n_somatomotor_areas lose their only source and
## drop out of _wide entirely; n_cortical_areas keeps Changizi 2001 / C&S 2005.
long$status[long$source == "Finlay_etal_2006_Table6.1"] <- "flagged_pending_ProjectKaskan_check"

## exclude: Smaers/Brodmann mandrill other-association cell (2026-08-25) — fails the additivity
## check against Brodmann 1913's own mandrill total by exactly +10,000 (misprint in one of the two
## sources; candidate repair 23422 -> 13422 is NOT applied — kept in _long, excluded from _wide).
long$status[long$source == "Smaers_etal_2017_TableS1part2" &
            long$Standardized_Term == "OtherAssociation_Surface_Area.mm2" &
            long$Species == "Mandrillus sphinx"] <- "excluded_additivity_vs_Brodmann1913"
readr::write_csv(long, "cortical_areas_long.csv")

## ---- wide: species x trait, mean across ACTIVE sources + conflict flag ----
## regional traits (e.g. M1_Surface_Area.mm2) are kept as SEPARATE columns, never pooled into
## whole-cortex surface.
wide <- long |>
  filter(status == "active") |>
  group_by(Species, Standardized_Term) |>
  summarise(value_mean = mean(value), n_sources = n_distinct(source),
            sources = paste(sort(unique(source)), collapse = "; "),
            value_min = min(value), value_max = max(value),
            conflict_flag = ifelse(n_sources > 1 &
                                   (sd(value) / mean(value)) > 0.15, TRUE, FALSE),
            .groups = "drop") |>
  pivot_wider(id_cols = Species, names_from = Standardized_Term,
              values_from = value_mean)
readr::write_csv(wide, "cortical_areas_wide.csv")
message("cortical areas: ", nrow(long), " long rows, ", nrow(wide), " species")
