# Hevner_etal_1995_Figure32.R ---------------------------------------------------
#
# Hevner R. F., Liu S. & Wong-Riley M. T. T. (1995) Neuroscience 65(2): 313-342.
# Fig. 32 (p. 338): optical density of CO histochemical staining in the perikarya
# of 11 neuron types (2 µm aperture; n = 5 rats; mean ± S.E.M.).
#
# Reads the constructed, frozen snapshot Hevner_etal_1995_Figure32_snapshot.csv
# (one row per printed bar, digitised from the 600-dpi page render by
# Hevner_etal_1995_Figure32_snapshot.R) and writes the analysis CSV, one row per
# neuron type: digitised mean / sem, sd = sem * sqrt(5), the printed text values
# for CA3 and CA1 (p. 337) in *_printed_in_text (they take precedence), the
# parent structure of each cell type, the printed species wording and the
# accepted binomial from _keys/General/species_key.csv.
# Observation level: group mean across 5 animals per cell type; not a species mean.
# No digitised value is typed in this script.

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

root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(species_key$accepted_name, tolower(species_key$variant_name))

read_snapshot <- function(file) read.csv(file, header = TRUE, colClasses = "character",
                                         na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
          "  not_evaluable=", tally[["not_evaluable"]])
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

sn <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(nrow(sn) == 11L)

## parent structure of each printed cell type (curator mapping; printed label kept)
parent <- c("mesencephalic nucleus of V" = "mesencephalic trigeminal nucleus",
            "reticular nucleus of thalamus" = "thalamic reticular nucleus",
            "interpeduncular nucleus" = "interpeduncular nucleus",
            "oculomotor nucleus of III" = "oculomotor nucleus",
            "medial mammillary nucleus" = "medial mammillary nucleus",
            "CA3 hippocampal pyramid" = "hippocampus, field CA3 (pyramidal layer)",
            "Purkinje cell" = "cerebellar cortex (Purkinje cell layer)",
            "motor nucleus of V" = "motor trigeminal nucleus",
            "cerebellar granule cell" = "cerebellar cortex (granular layer)",
            "CA1 hippocampal pyramid" = "hippocampus, field CA1 (pyramidal layer)",
            "dentate granule cell" = "dentate gyrus (granule cell layer)")
stopifnot(all(sn$cell_type_as_printed %in% names(parent)))

final.dataframe <- data.frame(
  rank_as_printed        = seq_len(nrow(sn)),
  cell_type_as_printed   = sn$cell_type_as_printed,
  structure              = unname(parent[sn$cell_type_as_printed]),
  measure                = "OD_CO_perikaryon_2um.au",
  measure_as_printed     = sn$measure_as_printed,
  units                  = sn$units_as_printed,
  n                      = as.integer(sn$n_from_legend),
  mean                   = num_of(sn$mean_digitised),
  sem                    = num_of(sn$sem_digitised),
  stringsAsFactors = FALSE)
final.dataframe$sd <- round(final.dataframe$sem * sqrt(final.dataframe$n), 4)
final.dataframe$method <- "optical densitometry of perikarya in CO-stained 30 µm sections, 2 µm aperture, x25 objective, background-subtracted; 5 sections per animal"
final.dataframe$value_source               <- sn$value_source
final.dataframe$mean_printed_in_text       <- num_of(sn$mean_printed_in_text)
final.dataframe$dispersion_printed_in_text <- num_of(sn$dispersion_printed_in_text)
final.dataframe$dispersion_type_in_text    <- ifelse(nzchar(sn$dispersion_type_in_text), sn$dispersion_type_in_text, NA_character_)
final.dataframe$page_in_text               <- ifelse(nzchar(sn$page_in_text), sn$page_in_text, NA_character_)
final.dataframe$resolution_units_per_px    <- num_of(sn$units_per_px)
final.dataframe$tick_fit_resid_max         <- num_of(sn$tick_fit_resid_max)
final.dataframe$observation_level <- "group mean across animals (one value per cell type)"
final.dataframe$species_as_published <- "albino rat"
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
final.dataframe$data_role <- "primary"
final.dataframe$source_locus <- "Fig. 32, p. 338 (digitised); legend p. 338 (n)"
stopifnot(!anyNA(final.dataframe$Species), !anyNA(final.dataframe$mean))

## ---- table checks (own snapshot only) -----------------------------------------------------
v <- function(cell, col = "mean") final.dataframe[[col]][final.dataframe$cell_type_as_printed == cell]
table_checks <- rbind(
  chk("anchor_CA3_mean", "Fig. 32 CA3 hippocampal pyramid (digitised) vs RESULTS p. 337 '0.495 ± 0.017'", v("CA3 hippocampal pyramid"), v("CA3 hippocampal pyramid", "mean_printed_in_text"), 0.0015, "tolerance = 0.0005 (printed to 3 dp) + 2 px"),
  chk("anchor_CA3_sem", "Fig. 32 CA3 S.E.M. (digitised) vs printed 0.017", v("CA3 hippocampal pyramid", "sem"), v("CA3 hippocampal pyramid", "dispersion_printed_in_text"), 0.0025, "tolerance = 0.0005 + half cap thickness"),
  chk("anchor_CA1_mean", "Fig. 32 CA1 hippocampal pyramid (digitised) vs RESULTS p. 337 '0.357 ± 0.005'", v("CA1 hippocampal pyramid"), v("CA1 hippocampal pyramid", "mean_printed_in_text"), 0.0015, "tolerance = 0.0005 + 2 px"),
  chk("anchor_CA1_sem", "Fig. 32 CA1 S.E.M. (digitised) vs printed 0.005", v("CA1 hippocampal pyramid", "sem"), v("CA1 hippocampal pyramid", "dispersion_printed_in_text"), 0.0025, "tolerance = 0.0005 + half cap thickness"),
  chk("mesV_vs_dentate_percent", "100 * (mesencephalic V / dentate granule - 1) vs RESULTS p. 337 '78% higher'", 100 * (v("mesencephalic nucleus of V") / v("dentate granule cell") - 1), 78, 1.0, "tolerance = 0.5 (printed integer) + digitising (~0.3 %); the authors may have used unrounded means"),
  chk("bars_descend_as_printed", "number of adjacent pairs (top to bottom) where the lower bar exceeds the upper one; printed order is descending", sum(diff(final.dataframe$mean) > 0), 0, 0),
  chk("range_almost_two_fold", "max / min across the 11 cell types vs Abstract 'nearly a two-fold range' (printed = 2, tolerance 0.3)", max(final.dataframe$mean) / min(final.dataframe$mean), 2, 0.3)
)
report_checks(table_checks)

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
