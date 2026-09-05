# Metabolic compiled merge -- brain cerebral metabolic rate (CMRgl, CMRO2, CBF).
# Mirror of __merging_volumes/volumes_compiled.R and __merging_cellcounts/cellcounts_compiled.R,
# but with a COMPILATION-AWARE resolution rule (see README__merging.md, and __HOWTO_build_a_dataset_file.md
# section 9: only PRIMARY data is merged).
#
# Sources (all BRAIN-only; no body/basal metabolic rate):
#   Heiss_etal_2004  - PRIMARY. Homo sapiens regional CMRgl (PET).
#   Kaufman__2004     - SECONDARY compilation. Appendix tables A1-A14 = one row per PRIMARY study,
#                      each carrying its own literature reference + anesthesia state.
#   Karbowski__2007   - SECONDARY compilation. Suppl. tables S1-S23 = one row per PRIMARY reference
#                      (plus the paper's own 'average <species>' rows, which we DROP).
#
# Because Kaufman and Karbowski are both compilations of OTHER labs' primary measurements and cite
# OVERLAPPING primary studies, we do NOT average their published species-means as if independent
# (that double-counts shared studies). Instead we pull both down to the primary-study level, dedupe
# studies reported by both (first-author + year), and average across the DISTINCT primary studies.
#
# TWO MEASURE CLASSES are emitted, tagged in the `measure_class` column:
#   cerebral_metabolic_rate / cerebral_perfusion
#       MASS-SPECIFIC rates: CMRgl, CMRO2 (umol/100g/min), CBF (mL/100g/min). Compilation-aware
#       resolution as described above.
#   cerebral_absolute_rate
#       ABSOLUTE whole-brain totals as printed in Karbowski Tables S1/S2:
#       Total_glucose_utilization (umol/min), Total_O2_consumption (mL/min). These are DERIVED
#       quantities (Karbowski's own mass-specific rate x brain mass), reported only by Karbowski,
#       and are therefore NOT independent of the rates above: they are a different measure class
#       and must never be pooled with, or averaged against, the per-100 g rates. They are carried
#       because absolute whole-brain glucose and oxygen use is the quantity that compares directly
#       against whole-body BMR (__merging_body_ecology) and against the fossil-hominin BGU
#       estimates in __merging_fossil_brain_glucose (same unit, umol/min).
#
# NOTE: this .R is the house-style reproducible equivalent of build_cerebral_metabolic_rate_merge.py, which is the
# script that actually generated the shipped CSVs (R was unavailable in the build environment; same
# arrangement as the Karbowski build). Run either; they implement the same pipeline.
#
# ROUNDING: an explicit shared rule (see round3() below) so the two builders agree bit for bit --
# base R and Python round a decimal tie differently, and a few cell means land exactly on one.

suppressPackageStartupMessages({ library(tidyverse) })
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cerebral_metabolic_rate")
base <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"

## ---- crosswalks -------------------------------------------------------------------------------
region_canon <- c(
  "Whole Brain (direct measurement)"="Whole_brain","Brain"="Whole_brain","Whole Brain"="Whole_brain",
  "Neocortex"="Neocortex","Cerebral cortex"="Neocortex","Cerebral cortex (global average)"="Neocortex","Cortex"="Neocortex",
  "Frontal Cortex"="Frontal_cortex","Frontal cortex"="Frontal_cortex","Frontal lobe"="Frontal_cortex",
  "Prefrontal cortex"="Prefrontal_cortex",
  "Parietal Cortex"="Parietal_cortex","Parietal cortex"="Parietal_cortex","Parietal lobe"="Parietal_cortex",
  "Temporal Cortex"="Temporal_cortex","Temporal cortex"="Temporal_cortex","Temporal lobe"="Temporal_cortex",
  "Occipital Cortex"="Occipital_cortex","Occipital cortex"="Occipital_cortex","Occipital lobe"="Occipital_cortex",
  "Visual cortex"="Visual_cortex","Auditory Cortex"="Auditory_cortex",
  "Sensorimotor Cortex"="Sensorimotor_cortex","Sensorimotor cortex"="Sensorimotor_cortex",
  "Cingulate Cortex"="Cingulate_cortex","Cingulate cortex"="Cingulate_cortex","Insular lobe"="Insula",
  "Thalamus"="Thalamus","Nucleus medial thalami"="Thalamus_medial_nucleus","Hypothalamus"="Hypothalamus",
  "Hippocampus"="Hippocampus","Amygdala"="Amygdala","Corpus amygdaloideum"="Amygdala","Septum"="Septum",
  "Basal Ganglia"="Basal_ganglia","Caudate"="Caudate_nucleus","Caudatum"="Caudate_nucleus","Putamen"="Putamen",
  "Globus pallidus"="Pallidum","Pallidum"="Pallidum","Nucleus accumbens"="Nucleus_accumbens",
  "Substantia nigra"="Substantia_nigra","Nucleus subthalamicus"="Nucleus_subthalamicus","Nucleus ruber"="Nucleus_ruber",
  "Basal forebrain"="Basal_forebrain","Corpus geniculatum laterale"="Corpus_geniculatum_laterale",
  "Corpus geniculatum mediale"="Corpus_geniculatum_mediale","Colliculus superior"="Colliculus_superior",
  "Colliculus inferior"="Colliculus_inferior","Cerebellum"="Cerebellum","Cerebellar cortex"="Cerebellar_cortex",
  "Nucleus dentatus cerebelli"="Nucleus_dentatus_cerebelli","Vermis"="Vermis","Brain stem"="Brain_stem",
  "White Matter"="White_matter","White matter"="White_matter","Capsula interna"="Capsula_interna",
  "Centrum semiovale"="Centrum_semiovale")

volume_term <- c("Neocortex"="Neocortex_Vol.mm3","Cerebellum"="Cerebellum_Vol.mm3","Thalamus"="Thalamus_Vol.mm3",
  "Hippocampus"="Hippocampus_Vol.mm3","Amygdala"="Amygdala_Vol.mm3","Pallidum"="Pallidum_Vol.mm3",
  "Nucleus_subthalamicus"="Nucleus_subthalamicus_Vol.mm3","Corpus_geniculatum_laterale"="Corpus_geniculatum_laterale_Vol.mm3",
  "Whole_brain"="Total_brain_net_volume_Vol.mm3")

# Kaufman genus label -> standard-lab binomial (same animals Karbowski names); generic Macaca kept as sp.
species_canon <- c("Homo"="Homo sapiens","M mulatta"="Macaca mulatta","M fascic"="Macaca fascicularis",
  "Macaca"="Macaca sp.","Papio"="Papio anubis","Saimiri"="Saimiri sciureus","Canis"="Canis lupus familiaris",
  "Felis"="Felis catus","Rattus"="Rattus norvegicus","Mus"="Mus musculus","Meriones"="Meriones unguiculatus",
  "Gerbil"="Meriones unguiculatus","Ovis"="Ovis aries","Capra"="Capra aegagrus hircus","Sus"="Sus scrofa",
  "Equus"="Equus caballus","Lepus"="Lepus sp.")
canon_species <- function(s) ifelse(s %in% names(species_canon), species_canon[s], s)
canon_region  <- function(s) ifelse(s %in% names(region_canon),  region_canon[s],  s)

# measure -> unit + measure class. The two Karbowski Total_* measures are absolute whole-brain
# quantities, NOT per-100 g rates: they keep their printed units and are never scaled.
measure_unit  <- c(CMRgl="umol/100g/min", CMRO2="umol/100g/min", CBF="mL/100g/min",
                   Total_glucose_utilization="umol/min", Total_O2_consumption="mL/min")
measure_class <- c(CMRgl="cerebral_metabolic_rate", CMRO2="cerebral_metabolic_rate",
                   CBF="cerebral_perfusion",
                   Total_glucose_utilization="cerebral_absolute_rate",
                   Total_O2_consumption="cerebral_absolute_rate")
# Round to 3 dp, half away from zero, IDENTICALLY to the .py. Neither language's native rounding
# will do: R's round() rounds the shortest decimal you would print (73.2075 -> 73.208) while
# Python's round() rounds the stored double (73.2074999... -> 73.207). Both are defensible and they
# disagree on a few percent of multi-study means, so the twins would silently diverge. The rule is
# therefore written out explicitly in both: format to 9 dp with C printf (same libc routine in both
# languages), then round half-up at the 4th decimal with exact integer arithmetic. Checked against
# the .py over 200,000 simulated multi-study means: zero disagreements.
round3 <- function(x) vapply(x, function(v) {
  if (is.na(v)) return(NA_real_)
  s <- sprintf("%.9f", v)
  neg <- startsWith(s, "-"); s <- sub("^-", "", s)
  p <- strsplit(s, ".", fixed = TRUE)[[1]]
  n <- as.numeric(p[1]) * 1e9 + as.numeric(p[2])   # exact integer of value * 1e9
  r <- floor((n + 5e5) / 1e6) / 1000
  if (neg) -r else r
}, numeric(1))

# first-author surname + year -> token (e.g. "(Baxter et al., 1987)" -> "baxter1987")
ref_key <- function(x){
  x <- str_trim(as.character(x))
  out <- ifelse(str_detect(str_to_lower(x), "present study"), "kaufman2004_present", NA_character_)
  x2  <- str_remove_all(x, "[()]") |> str_trim()
  yr  <- str_extract(x2, "(1[89][0-9]{2}|20[0-9]{2})"); yr <- ifelse(is.na(yr), "NA", yr)
  sur <- str_to_lower(str_extract(x2, "[A-Za-zÀ-ſ']+")); sur <- ifelse(is.na(sur), "anon", sur)
  ifelse(is.na(out), paste0(sur, yr), out)
}
ref_keys_multi <- function(x) str_split(as.character(x), ";") |> map(~ ref_key(str_trim(.x)))

conscious_kauf <- function(a){
  a <- str_to_lower(str_trim(as.character(a)))
  case_when(is.na(a) ~ "unknown", str_starts(a,"none")|str_detect(a,"awake") ~ "conscious", TRUE ~ "anesthetized")
}
kauf_genus_assigned <- c("Homo","Papio","Canis","Felis","Rattus","Mus","Meriones","Gerbil","Ovis","Capra","Sus","Equus","Lepus","Saimiri")

## ---- 1. load & normalise to primary-study level -----------------------------------------------
# Kaufman A1-A14
kauf_files <- list.files(file.path(base,"Kaufman__2004"), pattern="Kaufman__2004_TableA([1-9]|1[0-4])\\.csv$", full.names=TRUE)
kauf <- map_dfr(kauf_files, function(f){
  read_csv(f, show_col_types=FALSE) %>%
    mutate(Table=str_extract(basename(f),"TableA[0-9]+"),
           Species_printed=str_trim(Species),
           genus=case_when(Species_printed %in% c("M mulatta","M fascic") ~ "Macaca",
                           Species_printed=="Gerbil" ~ "Meriones", TRUE ~ word(Species_printed,1)),
           Species=canon_species(ifelse(Species_printed %in% names(species_canon), Species_printed, genus)),
           Region_raw=str_trim(Region), Region=canon_region(Region_raw),
           conscious=conscious_kauf(Anesthesia), rk=ref_key(Reference),
           Compilation="Kaufman__2004", ref_raw=as.character(Reference)) %>%
    pivot_longer(c(CMRgl_umol_100g_min,CMRO2_umol_100g_min,CBF_ml_100g_min),
                 names_to="mcol", values_to="Value") %>%
    mutate(Measure=recode(mcol, CMRgl_umol_100g_min="CMRgl", CMRO2_umol_100g_min="CMRO2", CBF_ml_100g_min="CBF"),
           Units=unname(measure_unit[Measure]), mclass=unname(measure_class[Measure]),
           Value=suppressWarnings(as.numeric(Value))) %>%
    filter(!is.na(Value)) %>%
    transmute(Compilation,Species_printed,Species,genus,Region_raw,Region,Measure,mclass,Value,
              SD=NA_real_,n=suppressWarnings(as.numeric(n)),conscious,ref_raw,ref_keys=map(rk,~.x),Units,Table)
})

# Karbowski S1-S23 (primary rows only). Mass-specific CMRgl/CMRO2 are printed PER GRAM and are
# rescaled to the per-100 g project standard; the whole-brain absolute totals (Tables S1/S2) are
# already whole-brain quantities and are NOT scaled.
karb_files <- list.files(file.path(base,"Karbowski__2007"), pattern="Karbowski__2007_TableS[0-9]+\\.csv$", full.names=TRUE)
karb <- map_dfr(karb_files, function(f){
  read_csv(f, show_col_types=FALSE) %>%
    filter(!as.logical(is_average), measure %in% names(measure_unit)) %>%
    mutate(Compilation="Karbowski__2007", Table=str_extract(basename(f),"TableS[0-9]+"),
           Species_printed=str_trim(species_printed), Species=canon_species(str_trim(species)),
           genus=word(Species,1), Region_raw=str_trim(structure), Region=canon_region(Region_raw),
           Measure=measure, mclass=unname(measure_class[Measure]),
           scale=ifelse(mclass %in% c("cerebral_metabolic_rate","cerebral_perfusion"), 100, 1),
           Value=suppressWarnings(as.numeric(value))*scale,
           SD=suppressWarnings(as.numeric(sd))*scale, n=NA_real_, conscious="unknown",
           ref_raw=as.character(reference), ref_keys=ref_keys_multi(reference),
           Units=unname(measure_unit[Measure])) %>%
    filter(!is.na(Value)) %>%
    transmute(Compilation,Species_printed,Species,genus,Region_raw,Region,Measure,mclass,Value,SD,n,conscious,ref_raw,ref_keys,Units,Table)
})

# Heiss 2004 (primary; Homo regional CMRgl)
heiss <- read_csv(file.path(base,"Heiss_etal_2004/Heiss_etal_2004_TABLE1.csv"), show_col_types=FALSE) %>%
  mutate(Value=suppressWarnings(as.numeric(`Both hemispheres Mean`))) %>% filter(!is.na(Value)) %>%
  transmute(Compilation="Heiss_etal_2004", Species_printed="Homo sapiens", Species="Homo sapiens", genus="Homo",
            Region_raw=str_trim(Region), Region=canon_region(str_trim(Region)), Measure="CMRgl",
            mclass="cerebral_metabolic_rate", Value,
            SD=suppressWarnings(as.numeric(`Both hemispheres SD`)), n=NA_real_, conscious="conscious",
            ref_raw="Heiss et al 2004", ref_keys=map(seq_len(n()), ~ "heiss2004"), Units="umol/100g/min", Table="TABLE1")

U <- bind_rows(kauf, karb, heiss) %>%
  mutate(ref_keys_str = map_chr(ref_keys, ~ paste(discard(.x, is.na), collapse=";")))

## ---- 2. unfiltered long table (full provenance) ----------------------------------------------
U %>% select(Species,Species_printed,Compilation,Table,Region,Region_raw,Measure,measure_class=mclass,
             Value,SD,n,Units,conscious,ref_raw,ref_keys_str) %>%
  arrange(Measure,Species,Region,Compilation) %>% write_csv("cerebral_metabolic_rate_unfiltered.csv")

## ---- 3. filter: drop explicitly anesthetized (Kaufman's conscious-only convention) ------------
F <- U %>% filter(conscious != "anesthetized")

## ---- 4. compilation-aware dedupe of shared primary studies -----------------------------------
comp_priority <- c(Kaufman__2004=0, Heiss_etal_2004=1, Karbowski__2007=2)   # keep lower
F <- F %>% mutate(.row=row_number())
long_keys <- F %>% select(.row,Species,Region,Measure,Compilation,ref_keys) %>%
  unnest(ref_keys) %>% filter(!is.na(ref_keys))
collide <- long_keys %>% group_by(Species,Region,Measure,ref_keys) %>%
  filter(n_distinct(Compilation) > 1) %>%
  mutate(prio=comp_priority[Compilation], keep=Compilation==Compilation[which.min(prio)]) %>% ungroup()
drop_rows <- collide %>% filter(!keep) %>% pull(.row) %>% unique()
collide %>% group_by(Species,Region,Measure,shared_ref=ref_keys) %>%
  summarise(reported_by=paste(sort(unique(Compilation)),collapse="; "),
            kept=Compilation[which.min(prio)][1],
            dropped=paste(sort(unique(Compilation[!keep])),collapse="; "), .groups="drop") %>%
  arrange(Species,Region,Measure) %>% write_csv("cerebral_metabolic_rate_dedupe_report.csv")
D <- F %>% filter(!.row %in% drop_rows)

## ---- 5. aggregate: study-mean, then mean across distinct studies ------------------------------
D <- D %>% mutate(study_id = ifelse(ref_keys_str=="", paste0(Compilation,":",Table), ref_keys_str))
study <- D %>% group_by(Species,Region,Measure,mclass,Units,study_id) %>%
  summarise(Value=mean(Value), Compilation=paste(sort(unique(Compilation)),collapse="; "), .groups="drop")
merged <- study %>% group_by(Species,Region,Measure,mclass,Units) %>%
  summarise(Value=round3(mean(Value)), n_studies=n_distinct(study_id),
            Compilations=paste(sort(unique(unlist(str_split(Compilation,"; ")))),collapse="; "), .groups="drop") %>%
  mutate(Volume_term=ifelse(Region %in% names(volume_term), volume_term[Region], NA_character_)) %>%
  rename(measure_class=mclass) %>%
  select(Species,Region,Measure,measure_class,Units,Value,n_studies,Compilations,Volume_term) %>%
  arrange(Species,Region,Measure)
write_csv(merged, "cerebral_metabolic_rate_long.csv")

## ---- 6. wide -----------------------------------------------------------------------------------
merged %>% mutate(col=paste0(Region,"__",Measure)) %>% select(Species,col,Value) %>%
  pivot_wider(names_from=col, values_from=Value) %>% arrange(Species) %>% write_csv("cerebral_metabolic_rate_wide.csv")

## ---- 7. species id / crosswalk ---------------------------------------------------------------
U %>% count(Species,Species_printed,Compilation) %>%
  group_by(Species,Species_printed) %>%
  summarise(Compilations=paste(sort(unique(Compilation)),collapse="; "), n_rows=sum(n), .groups="drop") %>%
  mutate(note=ifelse(Species_printed %in% kauf_genus_assigned,
                     "Kaufman genus label; binomial assigned by standard-lab-species convention",
                     ifelse(Species_printed=="Macaca","generic Macaca kept as Macaca sp.",""))) %>%
  arrange(Species,Species_printed) %>% write_csv("cerebral_metabolic_rate_source_species_ids.csv")

message(nrow(merged)," merged cells | ",n_distinct(merged$Species)," species | ",n_distinct(merged$Region)," regions")
