## Compile the comparative GYRIFICATION dataset (whole-cortex gyrification index, GI).
## Pattern mirrors __merging_cortical_areas / __merging_volumes: read each source's public TSV,
## relabel its columns via the stacked standardized-term map, stack to long, summarise to wide.
##
## Scope: GI ONLY. GI = Zilles-method ratio of total to exposed cortical contour. The Mota &
## Herculano-Houzel folding index (FI) is a DIFFERENT measure and is deliberately NOT included.
##
## Sources / teams:
##   Lewitus_2014  = Lewitus_etal_2014_TableS1 (primary, 102 spp) + _TableS8 (adds 11 spp; identical
##                   GI where shared with S1). Same team -> S1 authoritative, S8 fills gaps only.
##   Zilles_2013   = Zilles_etal_2013_Table1 (45 non-primate mammals; 1-3 GI values per species).
##   Zilles_1989   = Zilles_etal_1989_Table1 (the original Zilles GI paper; 56 individual nonhuman
##                   primates, 43 species as printed). GI is printed per hemisphere (R / L); the
##                   merge's observation is the per-individual mean of the available hemispheres.
##   Manger_2012   = Manger_etal_2012_Table1 (28 species, 30 rows). Per-row GI_source: 1 = the
##                   paper's own measurements (21 rows); 2 = re-reports of Pillay & Manger 2007
##                   (9 rows, secondary; that paper has no folder of its own).
##
## Dependency: Zilles-2013 Table 1 is compiled partly FROM Lewitus 2014 (its ref [7]) and both use
## the Zilles GI method -> the two teams are CITATION-DEPENDENT. They are therefore NEVER averaged.
## Rule: prefer Lewitus (the primary compilation); use Zilles only for species Lewitus lacks. Every
## overlap keeps both raw values and is flagged (citation_dependency = TRUE) for inspection.
##
## Dependency (added 2026-11-19): Lewitus 2014's primate GI values are re-reports of Zilles 1989
## (Lewitus's reference [1] is Zilles et al. 1989; on the 41 shared species the values agree to a
## median |difference| of 0.000). Zilles 1989 is therefore the PRIMARY source for the species it
## covers and Lewitus is the dependent carrier: the merged GI prefers the Zilles 1989 species mean,
## Lewitus's value is retained alongside and the overlap is flagged citation_dependency = TRUE.
## Manger 2012's own measurements are an independent team; its Pillay & Manger 2007 re-reports are
## secondary and are used only when no other team covers the species. Merged-value preference:
## Zilles_1989 > Lewitus_2014 > Zilles_2013 > Manger_2012 (own) > Manger_2012 (P&M re-report).
##
## Outputs: gyrification_long.csv, gyrification_wide.csv, gyrification_source_species_ids.csv
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

item_name <- c("Lewitus_etal_2014_TableS1",
               "Lewitus_etal_2014_TableS8",
               "Zilles_etal_2013_Table1",
               "Zilles_etal_1989_Table1",
               "Manger_etal_2012_Table1")

## Species aliases — unify unambiguous same-species spelling variants so the SAME animal joins
## across sources (and Lewitus's printed "Odocoileus virginiatus" typo is corrected). Genuinely
## distinct congeners (Bos taurus vs B. t. indicus, Ursus arctos vs maritimus, Tursiops aduncus vs
## truncatus, Globicephala melas vs macrorhynchus, Phoca sp.) are left SEPARATE.
sp_alias <- c("Felis domestica"        = "Felis catus",
              "Sus scrofa domestica"   = "Sus scrofa domesticus",
              "Equus burchelii"        = "Equus burchelli",
              "Capra aegagrus hircus"  = "Capra hircus domestica",
              "Lama glama"             = "Lama glama domesticus",
              "Odocoileus virginiatus" = "Odocoileus virginianus",
              ## Zilles_etal_1989_Table1 prints abbreviated names (unique to that table in this
              ## merge); expand each to the full name the other sources use so the same animal
              ## joins. Trinomina roll to species level, as the merge is species-level; the two
              ## genus-level prints stay genus-level (cf. Phoca sp. / Marmosa sp. below).
              "Alouatta senic."        = "Alouatta seniculus",
              "Avahi lan. lan."        = "Avahi laniger",
              "Avahi lan. occ."        = "Avahi occidentalis",
              "Cercocebus alb."        = "Lophocebus albigena",
              "Cercopithecus spec."    = "Cercopithecus sp.",
              "Colobus badius"         = "Piliocolobus badius",
              "Daubentonia mad."       = "Daubentonia madagascariensis",
              "Galago demidovii"       = "Galago demidoff",
              "Galago senegal."        = "Galago senegalensis",
              "Lagothrix lagothr."     = "Lagothrix lagothricha",
              "Lemur alb.fulvus"       = "Eulemur fulvus",
              "Lemur mongoz"           = "Eulemur mongoz",
              "Miopithecus tal."       = "Miopithecus talapoin",
              "Nycticebus couc."       = "Nycticebus coucang",
              "Otolemur crassic."      = "Otolemur crassicaudatus",
              "Papio spp."             = "Papio sp.",
              "Propithecus verr."      = "Propithecus verreauxi",
              "Pygathrix nem."         = "Pygathrix nemaeus",
              "Saguinus mid. tam."     = "Saguinus midas",
              ## Manger_etal_2012_Table1 prints the bare binomen for its (Pillay & Manger 2007)
              ## domestic-pig row (common name "Domestic pig"); no source in this merge prints
              ## bare "Sus scrofa" for a wild animal.
              "Sus scrofa"             = "Sus scrofa domesticus")
unify <- function(s) ifelse(s %in% names(sp_alias), sp_alias[s], s)

terms <- readr::read_csv("standardized_term_gyrification.csv", show_col_types = FALSE)
codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
enc   <- function(nm) {
  # Fail loudly on an unresolved item name. This used to return NA, and
  # file.path(tsvdir, paste0(NA, ".tsv")) is "NA.tsv" -- a path that really existed
  # in __Public/comparative-data/ as a stale artefact of an earlier unresolved
  # build. So a lost registry row did not stop the merge; it fed it the WRONG
  # table. (2026-08-20: exactly this happened to Zilles_etal_2013_Table1.)
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
team_of <- c(Lewitus_etal_2014_TableS1 = "Lewitus_2014",
             Lewitus_etal_2014_TableS8 = "Lewitus_2014",
             Zilles_etal_2013_Table1   = "Zilles_2013",
             Zilles_etal_1989_Table1   = "Zilles_1989",
             Manger_etal_2012_Table1   = "Manger_2012")

## ---- long: one row per (Species, source) GI observation --------------------
long <- list()
for (nm in item_name) {
  tsv <- file.path(tsvdir, paste0(enc(nm), ".tsv"))
  d   <- readr::read_tsv(tsv, show_col_types = FALSE)
  if (nm == "Zilles_etal_1989_Table1") {
    ## GI is printed per hemisphere; the observation is the per-individual mean of the
    ## available hemispheres (5 of 56 individuals have one hemisphere only; none has
    ## neither, checked 2026-11-19). One long row per individual.
    d$GI <- rowMeans(cbind(suppressWarnings(as.numeric(d$Gyrification_index_R)),
                           suppressWarnings(as.numeric(d$Gyrification_index_L))),
                     na.rm = TRUE)
    d$species_sci <- d$species_as_published
  } else if (nm == "Manger_etal_2012_Table1") {
    d$species_sci <- d$species
  }
  d$GI <- suppressWarnings(as.numeric(d$GI))
  d <- d[!is.na(d$GI), ]
  if (nm == "Zilles_etal_1989_Table1") {
    refcol <- "Table1"
    depcol <- "Zilles_GI_lineage"
  } else if (nm == "Manger_etal_2012_Table1") {
    ## GI_source: 1 = this study (own measurements, independent team); 2 = re-report of
    ## Pillay & Manger 2007 (secondary). (The definitions also allow 3 = Zilles et al.
    ## 1989; no such row occurs in the current table.)
    refcol <- ifelse(d$GI_source == 2, "Pillay & Manger 2007", "this study")
    depcol <- ifelse(d$GI_source == 2, "Pillay_Manger_2007_secondary",
                     "Manger_2012_independent")
  } else {
    refcol <- if (nm == "Zilles_etal_2013_Table1") d$Ref else sub("Lewitus_etal_2014_", "", nm)
    depcol <- "Zilles_GI_lineage"
  }
  long[[nm]] <- tibble(
    Species = unify(d$species_sci), Standardized_Term = "GI",
    GI = d$GI, source = nm, team = team_of[[nm]],
    ref = refcol, dependency_group = depcol,
    species_printed = d$species_sci)
}
long <- bind_rows(long)
## Species naming columns (SPECIES_NAMING.md v1): Species keeps this merge's unify() label; the shared
## resolver adds the identity anchor + basis from the printed name, keyed by paper folder.
source(file.path(base, "_keys", "resolve_species.R"))
rs <- resolve_species(long$species_printed, source_publication = paper_folder_of_item(long$source, base))
long <- long |> mutate(accepted_name = rs$accepted_name, species_basis = rs$species_basis,
                       reidentified = rs$reidentified)
readr::write_csv(long, "gyrification_long.csv")
readr::write_csv(long |> transmute(source, Species, GI), "gyrification_source_species_ids.csv")

## ---- wide: one row per species, team-aware + citation-dependency-aware ------
## Merged-value preference (see header): Zilles_1989 (primary measurement) > Lewitus_2014
## (S1, then S8) > Zilles_2013 (dependent on Lewitus) > Manger_2012 own measurements
## (independent team) > Manger_2012's Pillay & Manger 2007 re-reports (secondary, last
## resort). Dependent teams are never averaged; every team's value is retained in its
## own column. citation_dependency flags species with values from >= 2 teams of the
## Zilles GI lineage (Lewitus / Zilles_2013 / Zilles_1989).
lew_s1 <- long |> filter(source == "Lewitus_etal_2014_TableS1") |>
  group_by(Species) |> summarise(v = first(GI), .groups = "drop")
lew_s8 <- long |> filter(source == "Lewitus_etal_2014_TableS8") |>
  group_by(Species) |> summarise(v = first(GI), .groups = "drop")
zil <- long |> filter(team == "Zilles_2013") |>
  group_by(Species) |> summarise(mean = round(mean(GI), 4), n = n(),
                                 min = round(min(GI), 3), max = round(max(GI), 3), .groups = "drop")
z89 <- long |> filter(team == "Zilles_1989") |>
  group_by(Species) |> summarise(z89_mean = round(mean(GI), 4), z89_n = n(),
                                 z89_min = round(min(GI), 3), z89_max = round(max(GI), 3),
                                 .groups = "drop")
man_own <- long |> filter(team == "Manger_2012", ref == "this study") |>
  group_by(Species) |> summarise(man_mean = round(mean(GI), 4), man_n = n(), .groups = "drop")
man_pm <- long |> filter(team == "Manger_2012", ref == "Pillay & Manger 2007") |>
  group_by(Species) |> summarise(man_pm_v = first(GI), .groups = "drop")

wide <- tibble(Species = sort(unique(long$Species))) |>
  left_join(lew_s1 |> rename(gi_s1 = v), by = "Species") |>
  left_join(lew_s8 |> rename(gi_s8 = v), by = "Species") |>
  left_join(zil, by = "Species") |>
  left_join(z89, by = "Species") |>
  left_join(man_own, by = "Species") |>
  left_join(man_pm, by = "Species") |>
  mutate(
    GI_Lewitus2014     = ifelse(!is.na(gi_s1), gi_s1, gi_s8),
    lew_src            = ifelse(!is.na(gi_s1), "Lewitus_etal_2014_TableS1",
                         ifelse(!is.na(gi_s8), "Lewitus_etal_2014_TableS8", NA)),
    GI_Zilles2013_mean = mean,
    GI_Zilles1989_mean = z89_mean,
    GI_Manger2012_own_mean = man_mean,
    GI_Manger2012_PM2007   = man_pm_v,
    GI                 = case_when(!is.na(GI_Zilles1989_mean)   ~ GI_Zilles1989_mean,
                                   !is.na(GI_Lewitus2014)       ~ GI_Lewitus2014,
                                   !is.na(GI_Zilles2013_mean)   ~ GI_Zilles2013_mean,
                                   !is.na(GI_Manger2012_own_mean) ~ GI_Manger2012_own_mean,
                                   TRUE                         ~ GI_Manger2012_PM2007),
    source_used        = case_when(!is.na(GI_Zilles1989_mean)   ~ "Zilles_etal_1989_Table1",
                                   !is.na(GI_Lewitus2014)       ~ lew_src,
                                   !is.na(GI_Zilles2013_mean)   ~ "Zilles_etal_2013_Table1",
                                   TRUE                         ~ "Manger_etal_2012_Table1"),
    manger_value_role  = case_when(source_used != "Manger_etal_2012_Table1" ~ NA_character_,
                                   !is.na(GI_Manger2012_own_mean) ~ "own measurement",
                                   TRUE ~ "Pillay & Manger 2007 re-report (secondary)"),
    n_lineage          = (!is.na(GI_Lewitus2014)) + (!is.na(GI_Zilles2013_mean)) +
                         (!is.na(GI_Zilles1989_mean)),
    n_teams            = n_lineage + ((!is.na(GI_Manger2012_own_mean)) |
                                      (!is.na(GI_Manger2012_PM2007))),
    citation_dependency= n_lineage >= 2,
    GI_abs_diff        = ifelse((!is.na(GI_Lewitus2014)) & (!is.na(GI_Zilles2013_mean)),
                                round(abs(GI_Lewitus2014 - GI_Zilles2013_mean), 3), NA),
    GI_diff_Z1989_Lewitus = ifelse((!is.na(GI_Zilles1989_mean)) & (!is.na(GI_Lewitus2014)),
                                round(abs(GI_Zilles1989_mean - GI_Lewitus2014), 3), NA)) |>
  transmute(Species, GI, source_used, GI_Lewitus2014, GI_Zilles2013_mean,
            GI_Zilles2013_n = n, GI_Zilles2013_min = min, GI_Zilles2013_max = max,
            GI_Zilles1989_mean, GI_Zilles1989_n = z89_n,
            GI_Zilles1989_min = z89_min, GI_Zilles1989_max = z89_max,
            GI_Manger2012_own_mean, GI_Manger2012_own_n = man_n,
            GI_Manger2012_PM2007, manger_value_role,
            n_teams, citation_dependency, GI_abs_diff, GI_diff_Z1989_Lewitus)
readr::write_csv(wide, "gyrification_wide.csv")
message("gyrification: ", nrow(long), " long rows, ", nrow(wide), " species (",
        sum(wide$source_used == "Zilles_etal_1989_Table1"), " Zilles 1989, ",
        sum(grepl("Lewitus", wide$source_used)), " Lewitus, ",
        sum(wide$source_used == "Zilles_etal_2013_Table1"), " Zilles 2013 only, ",
        sum(wide$source_used == "Manger_etal_2012_Table1"), " Manger 2012, ",
        sum(wide$citation_dependency), " dependent overlaps)")
