# Hevner_etal_1995_Figure31.R ---------------------------------------------------
#
# Hevner R. F., Liu S. & Wong-Riley M. T. T. (1995) Neuroscience 65(2): 313-342.
# Fig. 31 (p. 336): CO activity content (A, mU/mg tissue wet weight), CO specific
# activity (B, mU/mg protein) and optical density of CO histochemical staining
# (C, 625 µm aperture, arbitrary units) in the whole brain, eight gray-matter
# regions and three white-matter regions of the adult albino rat; mean ± S.E.M.
#
# Reads the constructed, frozen snapshot Hevner_etal_1995_Figure31_snapshot.csv
# (one row per printed bar, digitised from the 600-dpi page render by
# Hevner_etal_1995_Figure31_snapshot.R) and writes the long analysis CSV: one
# row per bar with a numeric measure (the printed "N.D." position is dropped).
#   - mean / sem are the digitised values; sd = sem * sqrt(n) with n from the legend;
#   - where the RESULTS text prints the same quantity (4 bars) the printed value is
#     carried in *_printed_in_text and `value_source` says so; the printed value takes
#     precedence over the digitised one for any downstream use;
#   - units are kept as printed (mU = nmol cytochrome c oxidized/min; mU/mg tissue
#     = U/g tissue); no project-unit conversion applies to enzyme activities;
#   - species_as_published keeps the paper's wording ("albino rat"); Species is the
#     accepted binomial from _keys/General/species_key.csv (rows for this folder).
# Observation level: group mean across animals per region (n = 3-6), not a species
# mean; one value per region per measure.
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
stopifnot(nrow(sn) == 36L, identical(sort(unique(sn$panel)), c("A", "B", "C")))

measure_code <- c(A = "CO_activity_content.mU_per_mg_tissue", B = "CO_specific_activity.mU_per_mg_protein", C = "OD_CO_625um.au")
keep <- nzchar(sn$mean_digitised)
final.dataframe <- data.frame(
  panel                 = sn$panel[keep],
  measure               = unname(measure_code[sn$panel[keep]]),
  measure_as_printed    = sn$measure_as_printed[keep],
  units                 = sn$units_as_printed[keep],
  region_as_printed     = sn$region_as_printed[keep],
  tissue_class          = ifelse(nzchar(sn$tissue_class_as_printed[keep]), sn$tissue_class_as_printed[keep], "whole brain"),
  n                     = as.integer(sn$n_from_legend[keep]),
  mean                  = num_of(sn$mean_digitised[keep]),
  sem                   = num_of(sn$sem_digitised[keep]),
  stringsAsFactors = FALSE)
final.dataframe$sd <- round(final.dataframe$sem * sqrt(final.dataframe$n),
                            ifelse(final.dataframe$panel == "A", 1, ifelse(final.dataframe$panel == "B", 0, 5)))
final.dataframe$method <- ifelse(final.dataframe$panel == "C",
                                 "optical densitometry of CO-stained 30 µm sections, 625 µm aperture, x4 objective, background-subtracted; 3-18 readings per region per animal",
                                 "spectrophotometric CO assay of deoxycholate-solubilized 20 % homogenates (Hevner et al. 1993 method); protein by BCA")
final.dataframe$value_source               <- sn$value_source[keep]
final.dataframe$mean_printed_in_text       <- num_of(sn$mean_printed_in_text[keep])
final.dataframe$dispersion_printed_in_text <- num_of(sn$dispersion_printed_in_text[keep])
final.dataframe$dispersion_type_in_text    <- ifelse(nzchar(sn$dispersion_type_in_text[keep]), sn$dispersion_type_in_text[keep], NA_character_)
final.dataframe$page_in_text               <- ifelse(nzchar(sn$page_in_text[keep]), sn$page_in_text[keep], NA_character_)
final.dataframe$resolution_units_per_px    <- num_of(sn$units_per_px[keep])
final.dataframe$tick_fit_resid_max         <- num_of(sn$tick_fit_resid_max[keep])
final.dataframe$observation_level <- "group mean across animals (one value per region)"
final.dataframe$species_as_published <- "albino rat"
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
final.dataframe$data_role <- "primary"
final.dataframe$source_locus <- "Fig. 31, p. 336 (digitised); legend p. 336 (n)"
stopifnot(!anyNA(final.dataframe$Species), !anyNA(final.dataframe$mean), nrow(final.dataframe) == 35L)

## ---- table checks (own snapshot only) -----------------------------------------------------
v <- function(p, r, col = "mean") final.dataframe[[col]][final.dataframe$panel == p & final.dataframe$region_as_printed == r]
gw <- function(p) { d <- final.dataframe[final.dataframe$panel == p, ]
  mean(d$mean[d$tissue_class == "gray matter"]) / mean(d$mean[d$tissue_class == "white matter"]) }
table_checks <- rbind(
  ## the four values the text prints for bars of this figure (printed_in_text columns of the snapshot)
  chk("anchor_A_whole_brain_mean", "Fig. 31A whole brain (digitised) vs RESULTS p. 335 '158 ± 12 mU/mg tissue'", v("A", "whole brain"), v("A", "whole brain", "mean_printed_in_text"), 1.0, "tolerance = 0.5 (printed integer) + 2 px"),
  chk("anchor_A_whole_brain_sem", "Fig. 31A whole brain S.E.M. (digitised) vs printed S.D. 12 / sqrt(6)", v("A", "whole brain", "sem"), v("A", "whole brain", "dispersion_printed_in_text") / sqrt(v("A", "whole brain", "n")), 1.0, "p. 335 gives mean ± S.D.; the figure plots S.E.M. (legend)"),
  chk("anchor_A_cerebellar_cortex_mean", "Fig. 31A cerebellar cortex (digitised) vs RESULTS p. 336 '157 ± 17 mU/mg tissue, mean ± S.E.M.'", v("A", "cerebellar cortex"), v("A", "cerebellar cortex", "mean_printed_in_text"), 1.0, "tolerance = 0.5 + 2 px"),
  chk("anchor_A_cerebellar_cortex_sem", "Fig. 31A cerebellar cortex S.E.M. (digitised) vs printed 17", v("A", "cerebellar cortex", "sem"), v("A", "cerebellar cortex", "dispersion_printed_in_text"), 1.5, "tolerance = 0.5 + half the cap-line thickness (4 px)"),
  chk("anchor_B_whole_brain_mean", "Fig. 31B whole brain (digitised) vs RESULTS p. 335 '1760 ± 100 mU/mg protein'", v("B", "whole brain"), v("B", "whole brain", "mean_printed_in_text"), 15, "tolerance = 5 (printed to 3 s.f.) + ~4 px incl. tick-fit residual"),
  chk("anchor_B_whole_brain_sem", "Fig. 31B whole brain S.E.M. (digitised) vs printed S.D. 100 / sqrt(6)", v("B", "whole brain", "sem"), v("B", "whole brain", "dispersion_printed_in_text") / sqrt(v("B", "whole brain", "n")), 10, "p. 335 gives mean ± S.D.; the figure plots S.E.M. (legend)"),
  chk("anchor_B_visual_cortex_mean", "Fig. 31B visual cortex (digitised) vs RESULTS p. 336 '1760 ± 150 mU/mg protein'", v("B", "visual cortex"), v("B", "visual cortex", "mean_printed_in_text"), 15, "tolerance = 5 + ~4 px"),
  chk("anchor_B_visual_cortex_sem", "Fig. 31B visual cortex S.E.M. (digitised) vs printed 150", v("B", "visual cortex", "sem"), v("B", "visual cortex", "dispersion_printed_in_text"), 15, "tolerance = 5 + ~4 px"),
  ## statements of the RESULTS text about this figure
  chk("highest_A_is_cerebellar_cortex", "highest panel-A region bar is cerebellar cortex (RESULTS p. 336); observed = rank of cerebellar cortex among the 11 regions", which(order(-final.dataframe$mean[final.dataframe$panel == "A" & final.dataframe$tissue_class != "whole brain"]) == 1), 1, 0),
  chk("highest_B_is_visual_cortex", "highest panel-B region bar is visual cortex (RESULTS p. 336); observed = rank of visual cortex among the 11 regions", which(order(-final.dataframe$mean[final.dataframe$panel == "B" & final.dataframe$tissue_class != "whole brain"]) == 2), 1, 0),
  chk("gray_white_ratio_A", "mean of 8 gray bars / mean of 3 white bars (A) vs RESULTS p. 336 'about 10- to 12-fold' (printed = range midpoint 11, tolerance 1)", gw("A"), 11, 1),
  chk("gray_white_ratio_B", "mean of 8 gray bars / mean of 3 white bars (B) vs RESULTS p. 336 'about eight- to 10-fold' (printed = midpoint 9, tolerance 1)", gw("B"), 9, 1),
  chk("gray_white_ratio_C", "mean of 8 gray bars / mean of 3 white bars (C) vs RESULTS p. 337 'about four to five times' (printed = midpoint 4.5, tolerance 0.5)", gw("C"), 4.5, 0.5, "the authors may have formed the ratio differently (e.g. per pair); kept as digitised")
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
