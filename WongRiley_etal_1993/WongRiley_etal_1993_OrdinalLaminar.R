# WongRiley_etal_1993_OrdinalLaminar.R -----------------------------------
#
# Wong-Riley et al. (1993) Visual Neuroscience 10: 41-58, doi 10.1017/S0952523800003217. Human V1 / V2 /
# extrastriate cortex by developmental stage; the IVcα vs IVcβ percent differences are in WongRiley_etal_1993_Text.
# Constructed ORDINAL item: reads the frozen snapshot WongRiley_etal_1993_OrdinalLaminar_snapshot.csv
# (one row per printed qualitative statement about cytochrome-oxidase (CO)
# reactivity of a layer / laminar compartment / area; written by
# WongRiley_etal_1993_OrdinalLaminar_snapshot.R) and produces the analysis CSV in the
# Preuss_etal_1999 statement-row schema (house precedent for ordinal data) plus
# an ordinal rank column.
#
# THESE ARE ORDINAL READINGS OF THE AUTHORS' OWN WORDS, NOT MEASUREMENTS. The
# script holds no printed value; it holds only the coding vocabulary:
#   - absolute states (printed adjective -> state, state_score 1..7, 7 = darkest):
#       darkest / highest = 7, dark / relatively dark / particularly high = 6,
#       moderate-to-dark = 5, moderate = 4, light-to-moderate = 3,
#       light / relatively low = 2, pale / relatively pale / least reactive / lightest = 1;
#   - relative states (X than ..., similar to ...) keep comparison_target and
#     get NO score; presence states (present / absent / not distinguishable /
#     reduced / most reduced / value) get no score;
#   - other features with an absolute adjective (cell types, CO/2-DG concordance,
#     method remarks) get trait CO_other_intensity / CO_other_relative and NO rank;
#   - ordinal_rank (1 = darkest) is a DENSE rank of state_score, descending,
#     among the rows that share Species x cortical_area x subfield x condition
#     and have an absolute state for feature "CO reactivity" (rank_scope
#     "layers within area"); area-level rows (feature "overall CO activity of
#     area") are ranked across areas within Species x condition (rank_scope
#     "areas within species"). Ties share a rank. Rows without an absolute
#     state have NA rank; a row whose snapshot note starts "restatement" is
#     excluded from ranking (rank_scope "excluded (restatement)"), and a group
#     with a single rankable row gets no rank ("single statement (no ranking)").
#   - species_as_published = taxon_in_methods (else taxon_as_printed); Species
#     via _keys/General/species_key.csv rows for this folder (stop if none).
#   - data_role primary (authors' own observations) throughout.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base  <- item_name

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

snap <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
snap_cols <- c("row", "page", "section", "taxon_as_printed", "taxon_in_methods", "cortical_area", "subfield",
               "layer", "compartment", "condition", "feature", "state_as_read", "comparison_target",
               "value_low", "value_high", "unit", "n_as_printed", "printed_wording", "evidence", "note")
if (!identical(names(snap), snap_cols)) stop("unexpected snapshot columns in ", base, "_snapshot.csv", call. = FALSE)
stopifnot(nrow(snap) == 55L, identical(snap$row, as.character(1:55)))
snap[] <- lapply(snap, function(x) trimws(gsub("[[:space:]]+", " ", x)))

## ---- coding vocabulary (checked, never extended silently) -------------------------
abs_states <- c(darkest = 7, highest = 7, dark = 6, `relatively dark` = 6, `particularly high` = 6,
                `moderate-to-dark` = 5, moderate = 4, `light-to-moderate` = 3, light = 2, `relatively low` = 2,
                pale = 1, `relatively pale` = 1, `least reactive` = 1, lightest = 1)
rel_states <- c("darker than", "slightly darker than", "somewhat higher than", "higher than", "less reactive than",
                "slightly less reactive than", "somewhat less reactive than", "lighter than", "much lighter than",
                "slightly lighter than", "slightly paler than", "somewhat paler than", "lower than",
                "somewhat lower than", "similar to", "increasing toward", "sometimes darker than")
pres_states <- c("present", "absent", "not distinguishable", "reduced", "most reduced", "value")
st <- snap$state_as_read
bad <- !(st %in% names(abs_states) | st %in% rel_states | st %in% pres_states) |
       (st %in% rel_states & !nzchar(snap$comparison_target)) |
       (st == "value" & (!nzchar(snap$value_low) | !nzchar(snap$unit)))
if (any(bad)) stop("unexpected state_as_read / missing comparison target in snapshot row(s) ",
                   paste(snap$row[bad], collapse = ", "), call. = FALSE)

## feature -> trait code
trait_of <- function(feature, state) {
  ifelse(feature == "CO reactivity" & state %in% names(abs_states), "CO_laminar_intensity",
  ifelse(feature == "CO reactivity" & state %in% rel_states, "CO_relative_intensity",
  ifelse(feature == "overall CO activity of area" & state %in% names(abs_states), "CO_area_overall_intensity",
  ifelse(feature == "overall CO activity of area", "CO_area_relative_intensity",
  ifelse(feature == "CO change after TTX", "CO_change_TTX",
  ifelse(state == "value", "CO_module_dimension_or_count",
  ifelse(state %in% pres_states, "CO_pattern_presence",
  ifelse(state %in% names(abs_states), "CO_other_intensity", "CO_other_relative"))))))))
}
trait <- trait_of(snap$feature, st)
stopifnot(!anyNA(trait))

## ---- species: printed name kept, accepted binomial from the collection key ----------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[trimws(species_key$source_publication) == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(trimws(species_key$accepted_name), tolower(trimws(species_key$variant_name)))
species_as_published <- ifelse(nzchar(snap$taxon_in_methods), snap$taxon_in_methods, snap$taxon_as_printed)
Species <- unname(lk[tolower(species_as_published)])
if (anyNA(Species)) stop("Unkeyed printed name(s): ", paste(unique(species_as_published[is.na(Species)]), collapse = ", "), call. = FALSE)
taxon_level <- ifelse(grepl(" sp\\.$", Species), "genus", "species")

## ---- states, scores, ranks ---------------------------------------------------------
state_score <- unname(abs_states[st])          # NA for relative / presence states
na_if_blank <- function(x) ifelse(nzchar(x), x, NA_character_)
is_restatement <- grepl("^restatement", snap$note)   # a later re-wording of a layer already ranked: not a new level
rank_scope <- ifelse(trait == "CO_laminar_intensity" & !is_restatement, "layers within area",
              ifelse(trait == "CO_area_overall_intensity" & !is_restatement, "areas within species",
              ifelse(is_restatement & trait %in% c("CO_laminar_intensity", "CO_area_overall_intensity"),
                     "excluded (restatement)", NA_character_)))
grp <- ifelse(rank_scope == "layers within area",
              paste(Species, snap$cortical_area, snap$subfield, snap$condition, sep = " || "),
              paste(Species, snap$condition, "AREA-LEVEL", sep = " || "))
ordinal_rank <- rep(NA_integer_, nrow(snap))
rankable <- rank_scope %in% c("layers within area", "areas within species")
for (g in unique(grp[rankable])) {
  i <- which(grp == g & rankable)
  if (length(i) < 2L) { rank_scope[i] <- "single statement (no ranking)"; next }
  ordinal_rank[i] <- as.integer(match(state_score[i], sort(unique(state_score[i]), decreasing = TRUE)))
}

final.dataframe <- data.frame(
  row = as.integer(snap$row), row_type = "statement",
  taxon_as_printed = snap$taxon_as_printed, taxon_in_methods = na_if_blank(snap$taxon_in_methods),
  species_as_published = species_as_published, Species = Species, taxon_level = taxon_level,
  cortical_area = snap$cortical_area, layer = snap$layer, marker = "CO",
  feature = snap$feature, trait = trait,
  state = ifelse(st == "value", NA_character_, st),
  value_low = suppressWarnings(as.numeric(snap$value_low)), value_high = suppressWarnings(as.numeric(snap$value_high)),
  unit = na_if_blank(snap$unit), n_individuals = suppressWarnings(as.integer(snap$n_as_printed)),
  state_basis = paste0("stated (", snap$evidence, ")"),
  printed_wording = snap$printed_wording,
  source_locator = paste0(snap$evidence, ", p. ", snap$page, " (", snap$section, ")"),
  observation_level = "taxon (pooled over the individuals examined)", data_role = "primary",
  note = na_if_blank(snap$note),
  subfield = na_if_blank(snap$subfield), compartment = na_if_blank(snap$compartment), condition = snap$condition,
  comparison_target = na_if_blank(snap$comparison_target), state_score = state_score,
  ordinal_rank = ordinal_rank, rank_scope = rank_scope,
  source = item_name, stringsAsFactors = FALSE)

message(item_name, ": ", nrow(final.dataframe), " statement rows; ", sum(!is.na(ordinal_rank)),
        " ranked (absolute states), ", sum(trait == "CO_relative_intensity"), " relative, ",
        sum(trait == "CO_pattern_presence"), " presence, ", sum(st == "value"), " value rows")

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
