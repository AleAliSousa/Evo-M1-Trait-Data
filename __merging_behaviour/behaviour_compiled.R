## Compile the comparative BEHAVIOUR dataset — several behavioural measure classes, each resolved to
## ONE value per species with full source provenance, following the SAME long-table schema as the
## other keyed merges (__merging_body_ecology / __merging_brain_mass): one row per (Species, Measure)
## with Value + n_sources + Teams + roles + value_min/value_max. The app reads it via std_merge().
##
## Per house rule (__HOWTO_build_a_dataset_file.md §10) different measure classes are never pooled
## into one value: each Measure is its own row/variable. Where a Measure has >1 source they are
## treated with keys (not duplicated): the value is resolved once and the contributing sources are
## listed. Two measures are multi-source & citation-dependent:
##   VocalRepertoire  Schniter_2026 (primary, updated) + ManyPrimates_2022 (secondary). Both draw on
##                    McComb & Semple 2005 -> never averaged; prefer Schniter. value_min/max show the
##                    spread; Value_median is informational only.
##   Dexterity        Heffner & Masterton 1975 (primary) + Iwaniuk 1999 (secondary; a re-analysis of
##                    the SAME data, identical on all shared species) -> prefer Heffner.
## The other measures are single-source (Wimberly gait, Granatosky locomotion, Caspar handedness,
## Heldstab manipulation).
##
## Inputs are the harmonised trait tables in ____EvoM1_TraitTable/ (species_sci-keyed). Dexterity has
## its own dedicated input tables (dexterity_heffner.xlsx / dexterity_iwaniuk.xlsx) written by the
## EvoM1_read_dexterity_corticospinal*.R scripts, because the corticospinal-tract trait tables that
## the app melts no longer carry the dexterity column (it would duplicate this merge).
##
## Outputs: behaviour_long.csv (keyed merge, app-facing), behaviour_observations_long.csv (raw
## per-source rows), behaviour_wide.csv (one row per species overview).
suppressWarnings(suppressMessages({library(tidyverse); library(readxl)}))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp)); base <- normalizePath(file.path(dirname(.sp), "..")); TT <- file.path(base, "____EvoM1_TraitTable")

rd <- function(f) as.data.frame(read_excel(file.path(TT, f), sheet = "Sheet1",
                 col_types = "text", .name_repair = "minimal"), check.names = FALSE)
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
spkey <- function(d) { sci <- if ("species_sci" %in% names(d)) d[["species_sci"]] else rep(NA, nrow(d))
  spp <- if ("Species" %in% names(d)) d[["Species"]] else d[[1]]
  clean_sp(ifelse(!is.na(sci) & nzchar(trimws(sci)) & tolower(trimws(sci)) != "none", sci, spp)) }
istxt <- function(x) !(is.na(x) | trimws(x) == "" | tolower(trimws(x)) %in% c("na","nan","none","-"))

TEAM <- c(schniter="Schniter", manyprimates="ManyPrimates", heffner="Heffner", iwaniuk="Iwaniuk",
          wimberly="Wimberly", granatosky="Granatosky", caspar="Caspar", heldstab="Heldstab",
          baker="Baker", reader="Reader", cst="Bortoff_Strick")
CATEG <- c("Gait","Foot_Posture","Arboreal_terrestrial","Tool_use","Extractive_foraging",
           "Tool_Manufacture","True_Tool_Use","CM_connection_inference")

## gather raw observations: one row per (Species, Measure, source)
grab <- function(file, col, measure, srckey) {
  d <- rd(file); k <- spkey(d); v <- d[[col]]
  keep <- istxt(v) & nzchar(trimws(k))
  if (!any(keep)) return(NULL)
  tibble(Species = k[keep], Measure = measure, src = srckey, Value = trimws(v[keep]))
}
obs <- bind_rows(
  grab("vocal_repertoire_schniter.xlsx","vocal_repertoire_size_updated","VocalRepertoire","schniter"),
  grab("vocal_repertoire_manyprimates.xlsx","vocal_repertoire_types","VocalRepertoire","manyprimates"),
  grab("dexterity_heffner.xlsx","Dexterity","Dexterity","heffner"),
  grab("dexterity_iwaniuk.xlsx","Dexterity","Dexterity","iwaniuk"),
  grab("gait.xlsx","Duty_Factor","Duty_Factor","wimberly"),
  grab("gait.xlsx","Phase","Phase","wimberly"),
  grab("gait.xlsx","Gait","Gait","wimberly"),
  grab("gait.xlsx","Foot_Posture","Foot_Posture","wimberly"),
  grab("locomotion.xlsx","Locomotor_diversity_index","Locomotor_diversity_index","granatosky"),
  grab("locomotion.xlsx","Intermembral_index","Intermembral_index","granatosky"),
  grab("locomotion.xlsx","Arboreal_terrestrial","Arboreal_terrestrial","granatosky"),
  grab("handedness.xlsx","Handedness_index_mean","Handedness_index_mean","caspar"),
  grab("handedness.xlsx","Handedness_strength_mean","Handedness_strength_mean","caspar"),
  grab("manipulation.xlsx","Manipulation_complexity","Manipulation_complexity","heldstab"),
  grab("manipulation.xlsx","Tool_use","Tool_use","heldstab"),
  grab("manipulation.xlsx","Extractive_foraging","Extractive_foraging","heldstab"),
  ## Reader 2011 — raw report counts, reduced-count sensitivity variables, and research effort.
  ## Explicit *_report_count names prevent accidental pooling with categorical Tool_use /
  ## Extractive_foraging above.
  grab("innovation_reader.xlsx","Innovation","Innovation_report_count","reader"),
  grab("innovation_reader.xlsx","Tool_use","Tool_use_report_count","reader"),
  grab("innovation_reader.xlsx","Extractive_foraging","Extractive_foraging_report_count","reader"),
  grab("innovation_reader.xlsx","Social_learning","Social_learning_report_count","reader"),
  grab("innovation_reader.xlsx","Innovation_reduced","Innovation_reduced_report_count","reader"),
  grab("innovation_reader.xlsx","Tool_use_reduced","Tool_use_reduced_report_count","reader"),
  grab("innovation_reader.xlsx","Extractive_foraging_reduced","Extractive_foraging_reduced_report_count","reader"),
  grab("innovation_reader.xlsx","Journal_search_article_count","Journal_search_article_count","reader"),
  grab("innovation_reader.xlsx","Zoological_record_article_count","Zoological_record_article_count","reader"),
  ## Bortoff & Strick 1993 (Bortoff_Strick_1993_Table1) - PRIMARY WGA-HRP tract tracing; the
  ## 0-2 grade is a curatorial coding of their own terminal-field description. The ordinal
  ## grade and the (all-NA) binary CM field are kept as separate measures on purpose.
  grab("corticospinal_terminations.xlsx","CST_termination_grade","CST_termination_grade","cst"),
  grab("corticospinal_terminations.xlsx","CM_monosynaptic","CM_monosynaptic","cst"),
  grab("corticospinal_terminations.xlsx","CM_connection_inference","CM_connection_inference","cst"),
  ## Baker 2025 — Tool_use keyed with Heldstab (heldstab primary); the rest Baker-only
  grab("dexterity_baker.xlsx","Tool_Use","Tool_use","baker"),
  grab("dexterity_baker.xlsx","Tool_Manufacture","Tool_Manufacture","baker"),
  grab("dexterity_baker.xlsx","True_Tool_Use","True_Tool_Use","baker"),
  grab("dexterity_baker.xlsx","peak_workspace","peak_workspace","baker"),
  grab("dexterity_baker.xlsx","relative_size","relative_size","baker"),
  grab("dexterity_baker.xlsx","real_size","real_size","baker"))
## Baker log10 hand-bone lengths (19 measures; Measure name == source column name)
bone_cols <- grep("^log10_.*_mm$", names(rd("dexterity_baker.xlsx")), value = TRUE)
obs <- bind_rows(obs, bind_rows(lapply(bone_cols, function(cc)
  grab("dexterity_baker.xlsx", cc, cc, "baker"))))
obs <- obs |> distinct(Species, Measure, src, .keep_all = TRUE)

## measure metadata: class, units, and priority-ordered (source, role)
META <- tribble(~Measure,~mclass,~Units,~prio,
 "VocalRepertoire","vocalization","count",list(c("schniter","primary"),c("manyprimates","secondary")),
 "Dexterity","dexterity","1-7 scale",list(c("heffner","primary"),c("iwaniuk","secondary")),
 "Duty_Factor","gait","percent",list(c("wimberly","primary")),
 "Phase","gait","percent",list(c("wimberly","primary")),
 "Gait","gait","category",list(c("wimberly","primary")),
 "Foot_Posture","gait","category",list(c("wimberly","primary")),
 "Locomotor_diversity_index","locomotion","index",list(c("granatosky","primary")),
 "Intermembral_index","locomotion","ratio",list(c("granatosky","primary")),
 "Arboreal_terrestrial","locomotion","category",list(c("granatosky","primary")),
 "Handedness_index_mean","handedness","HI",list(c("caspar","primary")),
 "Handedness_strength_mean","handedness","abs(HI)",list(c("caspar","primary")),
 "Manipulation_complexity","manipulation","score",list(c("heldstab","primary")),
 "Tool_use","manipulation","category",list(c("heldstab","primary"),c("baker","secondary")),
 "Extractive_foraging","manipulation","category",list(c("heldstab","primary")),
 "Tool_Manufacture","manipulation","category",list(c("baker","primary")),
 "True_Tool_Use","manipulation","category",list(c("baker","primary")),
 "peak_workspace","hand_morphology","index",list(c("baker","primary")),
 "relative_size","hand_morphology","index",list(c("baker","primary")),
 "real_size","hand_morphology","index",list(c("baker","primary")))
META <- bind_rows(META, tribble(
 ~Measure,~mclass,~Units,~prio,
 "Innovation_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Tool_use_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Extractive_foraging_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Social_learning_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Innovation_reduced_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Tool_use_reduced_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Extractive_foraging_reduced_report_count","behavioural_flexibility","reports",list(c("reader","primary")),
 "Journal_search_article_count","research_effort","articles",list(c("reader","primary")),
 "Zoological_record_article_count","research_effort","articles",list(c("reader","primary")),
 "CST_termination_grade","motor_pathway","ordinal 0-2",list(c("cst","primary")),
 "CM_monosynaptic","motor_pathway","binary 0/1",list(c("cst","primary")),
 "CM_connection_inference","motor_pathway","category",list(c("cst","primary"))
))
## Baker log10 hand-bone length measures (all single-source, baker primary)
META <- bind_rows(META, tibble(Measure = bone_cols, mclass = "hand_morphology",
  Units = "log10 mm", prio = lapply(bone_cols, function(x) list(c("baker","primary")))))

## observations long (raw) with role
role_of <- function(measure, src) { p <- META$prio[[match(measure, META$Measure)]]
  for (pr in p) if (pr[1] == src) return(pr[2]); NA_character_ }
obs$role <- mapply(role_of, obs$Measure, obs$src)
obs$Team <- TEAM[obs$src]
obs_out <- obs |> transmute(Species, measure_class = META$mclass[match(Measure, META$Measure)],
                            Measure, Team, role, Value) |> arrange(Species, Measure, Team)
readr::write_csv(obs_out, "behaviour_observations_long.csv")

## resolve to one value per (Species, Measure), keyed with provenance
resolve_one <- function(measure, sp_obs) {
  p <- META$prio[[match(measure, META$Measure)]]
  ordered <- Filter(function(pr) pr[1] %in% sp_obs$src, p)          # priority order, present only
  srcs <- vapply(ordered, `[`, character(1), 1); roles <- vapply(ordered, `[`, character(1), 2)
  vals <- sp_obs$Value[match(srcs, sp_obs$src)]
  nums <- suppressWarnings(as.numeric(vals)); nums <- nums[!is.na(nums)]
  is_cat <- measure %in% CATEG
  tibble(measure_class = META$mclass[match(measure, META$Measure)], Measure = measure,
         Units = META$Units[match(measure, META$Measure)], Value = vals[1],
         Value_median = if (!is_cat && length(nums)) as.character(median(nums)) else "",
         n_sources = length(srcs), n_teams = length(srcs),
         n_teams_primary = sum(roles == "primary"), primary_used = roles[1] == "primary",
         Teams = paste(TEAM[srcs], collapse = "; "), roles = paste(roles, collapse = "; "),
         value_min = if (!is_cat && length(nums)) as.character(min(nums)) else "",
         value_max = if (!is_cat && length(nums)) as.character(max(nums)) else "")
}
groups <- split(obs, interaction(obs$Species, obs$Measure, drop = TRUE, lex.order = TRUE))
long <- bind_rows(lapply(groups, function(sp_obs)
  bind_cols(tibble(Species = sp_obs$Species[1]),
            resolve_one(sp_obs$Measure[1], sp_obs)))) |>
  arrange(Species, Measure)
readr::write_csv(long, "behaviour_long.csv")

## wide overview: one row per species, resolved Value per Measure
wide <- long |> select(Species, Measure, Value) |>
  pivot_wider(names_from = Measure, values_from = Value) |> arrange(Species)
readr::write_csv(wide, "behaviour_wide.csv")

message("behaviour: ", nrow(long), " (Species x Measure) rows, ", length(unique(long$Species)),
        " species; multi-source: ", sum(long$n_sources > 1),
        " (VocalRepertoire ", sum(long$Measure=="VocalRepertoire" & long$n_sources>1),
        ", Dexterity ", sum(long$Measure=="Dexterity" & long$n_sources>1), ")")
