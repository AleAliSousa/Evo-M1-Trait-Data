
## relative_absolute_helpers.R -- combine RELATIVE (% of a denominator) and ABSOLUTE (mm2)
## cortical surface areas in the cortical-areas merge.  Sourced by cortical_areas_compiled.R.
##
## Policy (owner decisions 2026-10-21):
##  * Relative values are standardized terms in their own right:
##      <Region>_Surface_Area.pct_<Denominator>   e.g. V1_Surface_Area.pct_Neocortex
##    Each row carries denominator_term (the absolute term it is a fraction of) and the source's
##    own denominator_definition.  trait_class = "regional_relative".
##  * A relative value is converted to an absolute one INSIDE the merge only when the denominator
##    is measured on the SAME SPECIMEN: same source + specimen id, or a pair declared in
##    specimen_links.csv.  That conversion is exact arithmetic (pct x denominator / 100) and the
##    derived row carries value_basis = "derived_same_specimen" plus a derivation string that
##    re-evaluates to the value.  Derived rows pool with printed absolutes in _wide; the
##    composition sidecar records per cell how many values are printed vs derived.
##  * Where the source prints BOTH the absolute and the percentage for one specimen, the printed
##    absolute is kept and the percentage is re-derived as a consistency check
##    (cortical_areas_conversion_checks.csv).  Nothing is recomputed into the printed value.
##  * Where only a region's absolute and its percentage are printed (no denominator), the
##    denominator is derived by inversion (abs / pct x 100) with value_basis =
##    "derived_inverse_from_pct" and status "derived_inverse_held" -- visible in _long, OUT of
##    _wide, because printed percentages are rounded.
##  * Every other relative value (species/group means, no same-specimen denominator, held status)
##    is listed in cortical_areas_relative_unconverted.csv.  Conversions that need a species-mean
##    or cross-source denominator are assumption-bearing and happen OUTSIDE this repo
##    (Flatmap_SurfaceArea_Project/surface_area_analysis/preanalysis/).

pct_term_regex <- "_Surface_Area\\.pct_"
pct_to_abs_term <- function(term) sub("\\.pct_.*$", ".mm2", term)
region_of_term  <- function(term) sub("_Surface_Area\\..*$", "", term)

## Read the specimen crosswalk used to match a denominator measured on the same animal in a
## different table.  Columns: source_a, specimen_a, source_b, specimen_b, link_status, note.
## Only link_status == "confirmed" is used for conversion.
read_specimen_links <- function(path = "specimen_links.csv") {
  if (!file.exists(path)) return(tibble(source_a = character(), specimen_a = character(),
                                        source_b = character(), specimen_b = character(),
                                        link_status = character(), note = character()))
  readr::read_csv(path, show_col_types = FALSE, col_types = readr::cols(.default = "c")) |>
    filter(!is.na(source_a), !is.na(source_b))
}

fmt <- function(x) as.character(signif(x, 7))

## Main entry.  `long` must already carry: Species, Standardized_Term, value, source, specimen,
## grain, status, value_basis, denominator_term, denominator_definition.
## Returns list(long = long with derived rows appended, checks = tibble, unconverted = tibble).
convert_relative_same_specimen <- function(long, links) {
  stopifnot(all(c("specimen", "grain", "status", "value_basis", "denominator_term") %in% names(long)))
  rel <- long |> filter(str_detect(Standardized_Term, pct_term_regex), !is.na(value))
  if (!nrow(rel)) return(list(long = long, checks = tibble(), unconverted = tibble()))

  abs_printed <- long |> filter(!str_detect(Standardized_Term, pct_term_regex),
                                value_basis == "printed", !is.na(value), !is.na(specimen)) |>
    select(Species, Standardized_Term, source, specimen, abs_value = value, abs_status = status)

  ## candidate denominators for each relative row: same source+specimen first, then confirmed links
  links_c <- links |> filter(link_status == "confirmed")
  links_sym <- bind_rows(links_c,
                         links_c |> rename(source_a = source_b, specimen_a = specimen_b,
                                           source_b = source_a, specimen_b = specimen_a))
  rel <- rel |> mutate(abs_term = pct_to_abs_term(Standardized_Term))

  ## (1) same source + specimen
  den_same <- abs_printed |> rename(denominator_term = Standardized_Term, den_value = abs_value,
                                    den_status = abs_status) |>
    mutate(den_source = source, den_specimen = specimen, den_match = "same_source_same_specimen")
  r1 <- rel |> filter(!is.na(specimen)) |>
    inner_join(den_same, by = c("Species", "source", "specimen", "denominator_term"))
  ## (2) linked specimen in another source
  r2 <- rel |> filter(!is.na(specimen)) |>
    anti_join(r1, by = c("Species", "Standardized_Term", "source", "specimen")) |>
    inner_join(links_sym, by = c("source" = "source_a", "specimen" = "specimen_a")) |>
    inner_join(abs_printed |> rename(denominator_term = Standardized_Term, den_value = abs_value,
                                     den_status = abs_status, den_source = source, den_specimen = specimen),
               by = c("Species", "source_b" = "den_source", "specimen_b" = "den_specimen", "denominator_term")) |>
    mutate(den_source = source_b, den_specimen = specimen_b, den_match = "linked_specimen_other_source") |>
    select(-source_b, -specimen_b, -link_status, -note)
  matched <- bind_rows(r1, r2)

  ## does the source already print the absolute for this region & specimen?
  matched <- matched |>
    left_join(abs_printed |> rename(abs_term = Standardized_Term, printed_abs = abs_value) |>
                select(Species, source, specimen, abs_term, printed_abs),
              by = c("Species", "source", "specimen", "abs_term"))

  checks <- matched |> filter(!is.na(printed_abs)) |>
    transmute(Species, source, specimen, region_term = abs_term, relative_term = Standardized_Term,
              printed_pct = value, printed_abs, denominator_term, den_value, den_source, den_match,
              recomputed_pct = printed_abs / den_value * 100,
              pct_discrepancy_points = recomputed_pct - printed_pct,
              relative_discrepancy = (recomputed_pct - printed_pct) / printed_pct,
              check = case_when(abs(relative_discrepancy) <= 0.05 ~ "consistent (<=5%)",
                                abs(relative_discrepancy) <= 0.15 ~ "rounding-level discrepancy (5-15%)",
                                TRUE ~ "ARITHMETIC MISMATCH (>15%)"))

  derived <- matched |> filter(is.na(printed_abs)) |>
    transmute(Species, Standardized_Term = abs_term,
              value = value * den_value / 100, source,
              source_flags = as.character(ifelse(is.na(source_flags) | source_flags == "", "derived_from_relative_same_specimen",
                                    paste0(source_flags, "|derived_from_relative_same_specimen"))),
              source_issue_note = source_issue_note,
              specimen, grain, n, value_status = as.character(ifelse(value_status == "approximate" | den_status != "active",
                                                        "approximate", value_status)),
              value_basis = "derived_same_specimen",
              derivation = sprintf("%s %s %% x %s %s mm2 / 100 [%s; denominator %s::%s]",
                                   Standardized_Term, fmt(value), denominator_term, fmt(den_value),
                                   den_match, den_source, den_specimen),
              denominator_term, denominator_definition, denominator_source = den_source,
              denominator_specimen = den_specimen, denominator_match = den_match,
              status = as.character(ifelse(status == "active" & den_status == "active", "active",
                              paste0("held_from_", ifelse(status != "active", status, den_status)))),
              species_printed, trait_class = "regional")
  ## check 3 (skill): derivation re-evaluates to the value
  if (nrow(derived)) {
    re <- as.numeric(str_match(derived$derivation, "^\\S+ (\\S+) % x \\S+ (\\S+) mm2")[, 2]) *
          as.numeric(str_match(derived$derivation, "^\\S+ (\\S+) % x \\S+ (\\S+) mm2")[, 3]) / 100
    bad <- abs(re - derived$value) / derived$value > 1e-4
    if (any(bad)) stop("derivation string does not re-evaluate for: ",
                       paste(derived$Species[bad], derived$Standardized_Term[bad], collapse = "; "))
  }

  ## inverse derivation: printed region absolute + pct, but no denominator for that specimen
  inv <- rel |> filter(!is.na(specimen)) |>
    anti_join(matched, by = c("Species", "Standardized_Term", "source", "specimen")) |>
    inner_join(abs_printed |> rename(abs_term = Standardized_Term, printed_abs = abs_value) |>
                 select(Species, source, specimen, abs_term, printed_abs),
               by = c("Species", "source", "specimen", "abs_term")) |>
    mutate(.pct_term = Standardized_Term, .pct = value) |>
    transmute(Species, Standardized_Term = denominator_term, value = printed_abs / .pct * 100, source,
              source_flags = "derived_inverse_from_pct", source_issue_note,
              specimen, grain, n, value_status = "approximate", value_basis = "derived_inverse_from_pct",
              derivation = sprintf("%s %s mm2 / %s %s %% x 100", abs_term, fmt(printed_abs), .pct_term, fmt(.pct)),
              denominator_term = NA_character_, denominator_definition,
              denominator_source = NA_character_, denominator_specimen = NA_character_,
              denominator_match = NA_character_,
              status = "derived_inverse_held", species_printed, trait_class = "whole_cortex")

  converted_keys <- matched |> distinct(Species, Standardized_Term, source, specimen)
  unconverted <- rel |> anti_join(converted_keys, by = c("Species", "Standardized_Term", "source", "specimen")) |>
    transmute(Species, Standardized_Term, value, source, specimen, grain, status, value_status,
              needed_denominator_term = denominator_term, denominator_definition,
              reason = case_when(
                status != "active" ~ paste0("held in merge (status = ", status, ")"),
                is.na(specimen) | grain %in% c("species_mean", "group_mean", "composite") ~
                  "species/group-level value: denominator must come from a species mean (assumption-bearing)",
                TRUE ~ "no denominator measured on this specimen in any admitted source (add a specimen_links.csv row if one exists)"))

  list(long = bind_rows(long, derived, inv), checks = checks, unconverted = unconverted)
}
