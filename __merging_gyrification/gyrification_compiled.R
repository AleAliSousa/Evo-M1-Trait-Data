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
##
## Dependency: Zilles-2013 Table 1 is compiled partly FROM Lewitus 2014 (its ref [7]) and both use
## the Zilles GI method -> the two teams are CITATION-DEPENDENT. They are therefore NEVER averaged.
## Rule: prefer Lewitus (the primary compilation); use Zilles only for species Lewitus lacks. Every
## overlap keeps both raw values and is flagged (citation_dependency = TRUE) for inspection.
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
               "Zilles_etal_2013_Table1")

## Species aliases — unify unambiguous same-species spelling variants so the SAME animal joins
## across sources (and Lewitus's printed "Odocoileus virginiatus" typo is corrected). Genuinely
## distinct congeners (Bos taurus vs B. t. indicus, Ursus arctos vs maritimus, Tursiops aduncus vs
## truncatus, Globicephala melas vs macrorhynchus, Phoca sp.) are left SEPARATE.
sp_alias <- c("Felis domestica"        = "Felis catus",
              "Sus scrofa domestica"   = "Sus scrofa domesticus",
              "Equus burchelii"        = "Equus burchelli",
              "Capra aegagrus hircus"  = "Capra hircus domestica",
              "Lama glama"             = "Lama glama domesticus",
              "Odocoileus virginiatus" = "Odocoileus virginianus")
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
             Zilles_etal_2013_Table1   = "Zilles_2013")

## ---- long: one row per (Species, source) GI observation --------------------
long <- list()
for (nm in item_name) {
  tsv <- file.path(tsvdir, paste0(enc(nm), ".tsv"))
  d   <- readr::read_tsv(tsv, show_col_types = FALSE)
  d$GI <- suppressWarnings(as.numeric(d$GI))
  d <- d[!is.na(d$GI), ]
  refcol <- if (nm == "Zilles_etal_2013_Table1") d$Ref else sub("Lewitus_etal_2014_", "", nm)
  long[[nm]] <- tibble(
    Species = unify(d$species_sci), Standardized_Term = "GI",
    GI = d$GI, source = nm, team = team_of[[nm]],
    ref = refcol, dependency_group = "Zilles_GI_lineage")
}
long <- bind_rows(long)
readr::write_csv(long, "gyrification_long.csv")
readr::write_csv(long |> transmute(source, Species, GI), "gyrification_source_species_ids.csv")

## ---- wide: one row per species, team-aware + citation-dependency-aware ------
lew_s1 <- long |> filter(source == "Lewitus_etal_2014_TableS1") |>
  group_by(Species) |> summarise(v = first(GI), .groups = "drop")
lew_s8 <- long |> filter(source == "Lewitus_etal_2014_TableS8") |>
  group_by(Species) |> summarise(v = first(GI), .groups = "drop")
zil <- long |> filter(team == "Zilles_2013") |>
  group_by(Species) |> summarise(mean = round(mean(GI), 4), n = n(),
                                 min = round(min(GI), 3), max = round(max(GI), 3), .groups = "drop")

wide <- tibble(Species = sort(unique(long$Species))) |>
  left_join(lew_s1 |> rename(gi_s1 = v), by = "Species") |>
  left_join(lew_s8 |> rename(gi_s8 = v), by = "Species") |>
  left_join(zil, by = "Species") |>
  mutate(
    GI_Lewitus2014     = ifelse(!is.na(gi_s1), gi_s1, gi_s8),
    lew_src            = ifelse(!is.na(gi_s1), "Lewitus_etal_2014_TableS1",
                         ifelse(!is.na(gi_s8), "Lewitus_etal_2014_TableS8", NA)),
    GI_Zilles2013_mean = mean,
    GI                 = ifelse(!is.na(GI_Lewitus2014), GI_Lewitus2014, GI_Zilles2013_mean),
    source_used        = ifelse(!is.na(GI_Lewitus2014), lew_src, "Zilles_etal_2013_Table1"),
    n_teams            = (!is.na(GI_Lewitus2014)) + (!is.na(GI_Zilles2013_mean)),
    citation_dependency= (!is.na(GI_Lewitus2014)) & (!is.na(GI_Zilles2013_mean)),
    GI_abs_diff        = ifelse(citation_dependency, round(abs(GI_Lewitus2014 - GI_Zilles2013_mean), 3), NA)) |>
  transmute(Species, GI, source_used, GI_Lewitus2014, GI_Zilles2013_mean,
            GI_Zilles2013_n = n, GI_Zilles2013_min = min, GI_Zilles2013_max = max,
            n_teams, citation_dependency, GI_abs_diff)
readr::write_csv(wide, "gyrification_wide.csv")
message("gyrification: ", nrow(long), " long rows, ", nrow(wide), " species (",
        sum(grepl("Lewitus", wide$source_used)), " Lewitus, ",
        sum(grepl("Zilles",  wide$source_used)), " Zilles-only, ",
        sum(wide$citation_dependency), " dependent overlaps)")
