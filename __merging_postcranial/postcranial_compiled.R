#!/usr/bin/env Rscript
# Postcranial anatomy merge (scaffold).
#
# Reads `postcranial_sources.csv` (one row per source column) and writes:
#   postcranial_species_long.csv    extant species-level values, pooled per (species, Measure, method)
#   postcranial_species_wide.csv    one column per Measure x method, median value
#   postcranial_specimen_long.csv   specimen-level rows (extant or fossil, `fossil` flag), NEVER pooled
#
# Defaults (agreed 2026-11-19; change in postcranial_sources.csv, not here):
#   * species-level and specimen-level rows stay in separate tables; fossils are specimen/taxon rows
#     in the specimen table and never enter the extant species pool;
#   * methods stay separate: values pool only when (species, Measure, Units, method) are identical;
#   * raw lengths and derived indices are both kept, labelled by `value_type`
#     (raw | derived | model_inference).
# Only primary-role rows set the pooled Value; where a species has only secondary rows the pooled Value comes from
# them with primary_used = FALSE.
# `postcranial_fossil_taxa.csv` lists extinct taxa per source item (printed names): they are routed to the
# specimen table with fossil = TRUE. A source with level = "mixed" pools rows whose id column is "taxon-level" at
# species level and keeps rows with specimen IDs at specimen level.

suppressWarnings(suppressMessages(library(tidyverse)))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript postcranial_compiled.R", call. = FALSE)
})
merge_dir <- dirname(.sp)
root <- normalizePath(file.path(merge_dir, ".."))
source(file.path(root, "_keys", "resolve_species.R"))

src <- read.csv(file.path(merge_dir, "postcranial_sources.csv"), stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(all(src$level %in% c("species", "specimen", "mixed")), all(src$value_type %in% c("raw", "derived", "model_inference")))
fossil_taxa <- read.csv(file.path(merge_dir, "postcranial_fossil_taxa.csv"), stringsAsFactors = FALSE)
squish <- function(x) trimws(gsub("[[:space:]]+", " ", x))
fmt <- function(v) format(v, scientific = FALSE, trim = TRUE, digits = 12)

rows <- list()
for (i in seq_len(nrow(src))) {
  s <- src[i, ]
  f <- file.path(root, s$folder, paste0(s$item, ".csv"))
  if (!file.exists(f)) stop("Missing source file for ", s$item, ": ", f, call. = FALSE)
  d <- read.csv(f, stringsAsFactors = FALSE, check.names = FALSE)
  for (col in c(s$species_col, s$source_col)) if (!col %in% names(d)) stop(s$item, ": column '", col, "' not found", call. = FALSE)
  if (nzchar(s$specimen_col) && !s$specimen_col %in% names(d)) stop(s$item, ": column '", s$specimen_col, "' not found", call. = FALSE)
  v <- suppressWarnings(as.numeric(d[[s$source_col]])); keep <- !is.na(v)
  printed <- as.character(d[[s$species_col]])[keep]
  rs <- resolve_species(printed, source_publication = s$folder)
  sid <- if (nzchar(s$specimen_col)) as.character(d[[s$specimen_col]])[keep] else rep(NA_character_, sum(keep))
  pn <- squish(printed)
  is_fossil <- pn %in% squish(fossil_taxa$species_printed[fossil_taxa$item == s$item]) | as.logical(s$fossil)
  # level: 'mixed' sources pool at species level only for rows whose id column says taxon-level
  lvl <- if (s$level == "mixed") ifelse(is.na(sid) | sid == "" | sid == "taxon-level", "species", "specimen") else rep(s$level, sum(keep))
  lvl[is_fossil] <- "specimen"               # fossils never enter the extant species pool
  sid[!is.na(sid) & sid == "taxon-level"] <- NA_character_
  rows[[i]] <- tibble(
    species_printed = pn,
    accepted_name = rs$accepted_name, species_basis = rs$species_basis, reidentified = rs$reidentified,
    specimen_id = sid,
    measure_class = "postcranial", Measure = s$Measure, Units = s$Units, value = v[keep],
    value_type = s$value_type, method = s$method, fossil = is_fossil,
    level = lvl, Teams = s$item, roles = s$role)
}
all_rows <- bind_rows(rows) |> mutate(Species = accepted_name)

# ---- specimen-level table: never pooled ------------------------------------
specimen <- all_rows |> filter(level == "specimen") |>
  transmute(Species, measure_class, Measure, Units, Value = fmt(value), value_type, method, fossil,
            specimen_id, Teams, roles, species_printed, accepted_name, species_basis, reidentified) |>
  arrange(Species, specimen_id, Measure)
write_csv(specimen, file.path(merge_dir, "postcranial_specimen_long.csv"))

# ---- species-level pool: extant only, primary rows pooled -------------------
sp <- all_rows |> filter(level == "species")
if (any(sp$fossil)) stop("Fossil rows must be specimen-level; found fossil = TRUE at species level", call. = FALSE)
pooled <- sp |>
  group_by(Species, measure_class, Measure, Units, value_type, method) |>
  summarise(
    primary_used = any(roles == "primary"),
    Value = fmt(median(if (any(roles == "primary")) value[roles == "primary"] else value)),
    n_sources = n_distinct(Teams), n_teams = n_distinct(Teams),
    n_teams_primary = n_distinct(Teams[roles == "primary"]),
    Teams = paste(sort(unique(Teams)), collapse = "; "), roles = paste(sort(unique(roles)), collapse = "; "),
    value_min = fmt(min(value)), value_max = fmt(max(value)),
    species_printed = paste(sort(unique(species_printed)), collapse = "; "),
    accepted_name = first(accepted_name), species_basis = first(species_basis),
    reidentified = any(reidentified), .groups = "drop") |>
  mutate(Value_median = Value) |>
  select(Species, measure_class, Measure, Units, value_type, method, Value, Value_median, n_sources, n_teams,
         n_teams_primary, primary_used, Teams, roles, value_min, value_max, species_printed, accepted_name,
         species_basis, reidentified) |>
  arrange(Species, Measure)
write_csv(pooled, file.path(merge_dir, "postcranial_species_long.csv"))

wide <- pooled |> mutate(col = paste(Measure, "[", method, "]")) |>
  select(Species, col, Value) |> pivot_wider(names_from = col, values_from = Value) |> arrange(Species)
write_csv(wide, file.path(merge_dir, "postcranial_species_wide.csv"))

message("postcranial: ", nrow(pooled), " species-level values across ", n_distinct(pooled$Species), " species; ",
        nrow(specimen), " specimen-level rows across ", n_distinct(specimen$Species), " taxa (",
        sum(specimen$fossil), " fossil)")
unres <- all_rows |> filter(species_basis == "unresolved") |> distinct(Teams, species_printed)
if (nrow(unres)) message("unresolved species labels: ", nrow(unres))
