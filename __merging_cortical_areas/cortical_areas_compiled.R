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
               "Turner_etal_2016_Table1")           # whole-cortex surface via turner_2016_surface.csv (case dedupe)
## Krubitzer_Kaas_1990_Table1 is documented as a related reference only: it reports RELATIVE % of a
## fixed 8-field visual scheme, not comparable to Finlay's area counts and with no absolute surface —
## so it is NOT merged numerically (see README). Its term map keeps only Species.

## Species aliases — unify spelling variants across sources so the same animal joins on one Species.
## (Collins printed "Otolemur garnetti"/"Aotus nancymae"; Young the correct "garnettii"/"nancymaae";
##  the two Papio labels in Young are NCBI homotypic synonyms.)
sp_alias <- c("Otolemur garnetti" = "Otolemur garnettii",
              "Aotus nancymae"    = "Aotus nancymaae",
              "Papio hamadryas anubis" = "Papio cynocephalus anubis")
unify <- function(s) ifelse(s %in% names(sp_alias), sp_alias[s], s)

## Trait classes: whole-cortex vs regional. Regional traits are NEVER pooled with whole-cortex ones.
regional_terms <- c("M1_Surface_Area.mm2")

terms  <- readr::read_csv("standardized_term_cortical_areas.csv", show_col_types = FALSE)
codes  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
enc    <- function(nm) codes$`Item encoded`[match(nm, codes$`Item name`)]

## ---- long: one row per (Species, Standardized_Term, source) ----
long <- list()

# generic count/surface sources read straight from their TSV (Changizi 2001, Finlay, Young M1,
# Changizi & Shimojo 2005). The Species join column is resolved from each source's term map (the
# Original_Term mapped to Standardized_Term == "Species"), since e.g. C&S 2005 prints it as species_sci.
for (nm in c("Changizi__2001_Figure3", "Finlay_etal_2006_Table6.1", "Young_etal_2013_Table1",
             "Changizi_Shimojo_2005_Table1")) {
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

long <- bind_rows(long) |> filter(!is.na(value)) |>
  mutate(Species = unify(Species),                                  # harmonise spelling variants
         trait_class = ifelse(Standardized_Term %in% regional_terms, "regional", "whole_cortex"))

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
