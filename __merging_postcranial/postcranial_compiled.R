#!/usr/bin/env Rscript
# Postcranial anatomy, hand-use and limb-function merge (scaffold).
#
# Reads `postcranial_sources.csv` (one row per source column) and writes:
#   postcranial_species_long.csv      numeric, extant species-level values, pooled per (species, Measure, method)
#   postcranial_species_wide.csv      one column per Measure x method, median value
#   postcranial_specimen_long.csv     numeric, specimen-level rows (extant or fossil, `fossil` flag), never pooled
#   postcranial_record_long.csv       numeric, one row per source record/sample (video, study sample), never pooled
#   postcranial_categorical_long.csv  categorical values (species-, specimen- or record-level), never pooled
#
# measure_class (set per source column in the registry):
#   postcranial_morphology  bone lengths, indices, limb proportions
#   hand_use                handedness and dexterity scores
#   limb_function           gait, limb posture, joint kinematics
#
# Defaults (agreed 2026-11-19; change in postcranial_sources.csv, not here):
#   * species-, specimen- and record-level rows stay in separate tables; fossils are specimen/taxon rows
#     in the specimen table and never enter the extant species pool;
#   * methods stay separate: values pool only when (species, measure_class, Measure, Units, method) match;
#   * raw lengths and derived indices are both kept, labelled by `value_type`
#     (raw | derived | model_inference);
#   * `cross_listed_from` marks a column that is ALSO carried by another merge (copies, not links), as
#     "<merge>:<Measure>:<Team>". Never pool this merge with the one named there. The script checks that
#     the named Measure/Team exists in that merge and warns if not.
# Where a species has only secondary rows the pooled Value comes from them with primary_used = FALSE.
# `postcranial_fossil_taxa.csv` lists extinct taxa per source item (printed names): they are routed to the
# specimen table with fossil = TRUE. A source with level = "mixed" pools rows whose id column is "taxon-level"
# at species level and keeps rows with specimen IDs at specimen level.

suppressWarnings(suppressMessages(library(tidyverse)))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript postcranial_compiled.R", call. = FALSE)
})
merge_dir <- dirname(.sp)
root <- normalizePath(file.path(merge_dir, ".."))
source(file.path(root, "_keys", "resolve_species.R"))

## read a UTF-8 CSV as all-character columns without relying on the locale (C-locale R would otherwise write
## non-ASCII text back out as "<c3><a1>" escapes)
read_utf8 <- function(f) {
  txt <- rawToChar(readBin(f, "raw", file.info(f)$size)); Encoding(txt) <- "UTF-8"
  as.data.frame(readr::read_csv(I(txt), col_types = readr::cols(.default = "c"), na = c("", "NA"), progress = FALSE,
                                name_repair = "minimal"), check.names = FALSE)
}
src <- read_utf8(file.path(merge_dir, "postcranial_sources.csv"))
src[is.na(src)] <- ""
stopifnot(all(src$level %in% c("species", "specimen", "record", "mixed")),
          all(src$value_type %in% c("raw", "derived", "model_inference")),
          all(src$type %in% c("numeric", "categorical")),
          all(src$measure_class %in% c("postcranial_morphology", "hand_use", "limb_function")))
fossil_taxa <- read_utf8(file.path(merge_dir, "postcranial_fossil_taxa.csv"))
squish <- function(x) trimws(gsub("[[:space:]]+", " ", x))
fmt <- function(v) format(v, scientific = FALSE, trim = TRUE, digits = 12)

## cross-listing check: every named Measure/Team must exist in the other merge's observations file
xl <- unique(src$cross_listed_from[nzchar(src$cross_listed_from)])
xl_files <- c(behaviour = file.path(root, "__merging_behaviour", "behaviour_observations_long.csv"),
              supplementary = file.path(root, "__merging_supplementary", "supplementary_long.csv"))
xl_seen <- lapply(xl_files, function(f) if (file.exists(f)) {
  o <- read_utf8(f); paste(o$Measure, if ("Team" %in% names(o)) o$Team else o$Teams, sep = ":") } else NULL)
for (x in xl) {
  p <- strsplit(x, ":", fixed = TRUE)[[1]]
  if (length(p) != 3 || !p[1] %in% names(xl_files)) { warning("cross_listed_from not understood: ", x); next }
  if (is.null(xl_seen[[p[1]]])) { warning("cross-list file for '", p[1], "' not found; not verified: ", x); next }
  if (!paste(p[2], p[3], sep = ":") %in% xl_seen[[p[1]]]) warning("cross_listed_from not found in ", p[1], " merge: ", x)
}

## Accented folder/file names can be stored decomposed (NFD) on disk but composed (NFC) in the registry; match
## by an ASCII transliteration when the exact path does not exist.
ascii_key <- function(x) tolower(iconv(x, "UTF-8", "ASCII//TRANSLIT", sub = ""))
find_path <- function(folder, file) {
  f <- file.path(root, folder, file); if (file.exists(f)) return(f)
  dirs <- list.dirs(root, recursive = FALSE, full.names = FALSE)
  dm <- dirs[ascii_key(dirs) == ascii_key(folder)]
  if (length(dm) == 1L) {
    fs <- list.files(file.path(root, dm))
    fm <- fs[ascii_key(fs) == ascii_key(file)]
    if (length(fm) == 1L) return(file.path(root, dm, fm))
  }
  f
}

rows <- list()
for (i in seq_len(nrow(src))) {
  s <- src[i, ]
  f <- find_path(s$folder, paste0(s$item, ".csv"))
  if (!file.exists(f)) stop("Missing source file for ", s$item, ": ", f, call. = FALSE)
  d <- read_utf8(f)
  for (col in c(s$species_col, s$source_col)) if (!col %in% names(d)) stop(s$item, ": column '", col, "' not found", call. = FALSE)
  if (nzchar(s$specimen_col) && !s$specimen_col %in% names(d)) stop(s$item, ": column '", s$specimen_col, "' not found", call. = FALSE)
  raw <- d[[s$source_col]]
  sp_ok <- !is.na(d[[s$species_col]]) & nzchar(squish(as.character(d[[s$species_col]])))   # rows with no species name cannot be merged
  if (s$type == "numeric") {
    v <- suppressWarnings(as.numeric(raw)); keep <- !is.na(v) & sp_ok; val_num <- v[keep]; val_chr <- rep(NA_character_, sum(keep))
  } else {
    cv <- squish(as.character(raw)); keep <- !is.na(raw) & nzchar(cv) & !tolower(cv) %in% c("na", "n.a.", "nan") & sp_ok; val_num <- rep(NA_real_, sum(keep)); val_chr <- cv[keep]
  }
  printed <- as.character(d[[s$species_col]])[keep]
  rs <- resolve_species(printed, source_publication = s$folder)
  sid <- if (nzchar(s$specimen_col)) as.character(d[[s$specimen_col]])[keep] else rep(NA_character_, sum(keep))
  pn <- squish(printed)
  is_fossil <- pn %in% squish(fossil_taxa$species_printed[fossil_taxa$item == s$item]) | as.logical(s$fossil)
  lvl <- if (s$level == "mixed") ifelse(is.na(sid) | sid == "" | sid == "taxon-level", "species", "specimen") else rep(s$level, sum(keep))
  lvl[is_fossil] <- "specimen"               # fossils never enter the extant species pool
  sid[!is.na(sid) & sid == "taxon-level"] <- NA_character_
  rows[[i]] <- tibble(
    species_printed = pn,
    accepted_name = rs$accepted_name, species_basis = rs$species_basis, reidentified = rs$reidentified,
    specimen_id = sid,
    measure_class = s$measure_class, Measure = s$Measure, Units = s$Units, type = s$type,
    value = val_num, value_chr = val_chr,
    value_type = s$value_type, method = s$method, fossil = is_fossil,
    level = lvl, Teams = s$item, roles = s$role, cross_listed_from = s$cross_listed_from)
}
all_rows <- bind_rows(rows) |> mutate(Species = accepted_name)
num <- all_rows |> filter(type == "numeric")
cat_ <- all_rows |> filter(type == "categorical")

# ---- specimen- and record-level numeric tables: never pooled ----------------
unpooled <- function(x, idcol) x |>
  transmute(Species, measure_class, Measure, Units, Value = fmt(value), value_type, method, fossil,
            !!idcol := specimen_id, Teams, roles, cross_listed_from, species_printed, accepted_name,
            species_basis, reidentified) |>
  arrange(Species, .data[[idcol]], Measure)
write_csv(unpooled(filter(num, level == "specimen"), "specimen_id"), file.path(merge_dir, "postcranial_specimen_long.csv"))
write_csv(unpooled(filter(num, level == "record"), "record_id"), file.path(merge_dir, "postcranial_record_long.csv"))

# ---- species-level pool: extant only, numeric ------------------------------
sp <- num |> filter(level == "species")
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
    cross_listed_from = paste(sort(unique(cross_listed_from[nzchar(cross_listed_from)])), collapse = "; "),
    species_printed = paste(sort(unique(species_printed)), collapse = "; "),
    accepted_name = first(accepted_name), species_basis = first(species_basis),
    reidentified = any(reidentified), .groups = "drop") |>
  mutate(Value_median = Value) |>
  select(Species, measure_class, Measure, Units, value_type, method, Value, Value_median, n_sources, n_teams,
         n_teams_primary, primary_used, Teams, roles, value_min, value_max, cross_listed_from, species_printed,
         accepted_name, species_basis, reidentified) |>
  arrange(Species, measure_class, Measure)
write_csv(pooled, file.path(merge_dir, "postcranial_species_long.csv"))

wide <- pooled |> mutate(col = paste(Measure, "[", method, "]")) |>
  select(Species, col, Value) |> pivot_wider(names_from = col, values_from = Value) |> arrange(Species)
write_csv(wide, file.path(merge_dir, "postcranial_species_wide.csv"))

# ---- categorical table: no pooling; identical (species, Measure, Value, source) rows collapsed -------------
categ <- cat_ |>
  transmute(Species, measure_class, Measure, Units, Value = value_chr, value_type, method, level, fossil,
            specimen_or_record_id = specimen_id, Teams, roles, cross_listed_from, species_printed, accepted_name,
            species_basis, reidentified) |>
  distinct(Species, Measure, Value, Teams, specimen_or_record_id, .keep_all = TRUE) |>
  arrange(Species, Measure)
write_csv(categ, file.path(merge_dir, "postcranial_categorical_long.csv"))

message("postcranial: ", nrow(pooled), " species-level values across ", n_distinct(pooled$Species), " species; ",
        nrow(filter(num, level == "specimen")), " specimen-level rows (", sum(filter(num, level == "specimen")$fossil), " fossil); ",
        nrow(filter(num, level == "record")), " record-level rows; ", nrow(categ), " categorical rows")
unres <- all_rows |> filter(species_basis == "unresolved") |> distinct(Teams, species_printed)
if (nrow(unres)) message("unresolved species labels: ", nrow(unres))
