# Poulsen_etal_1997_Table2.R -------------------------------------------------
#
# Poulsen, Smith, Ostergaard, Danielsen, Gee, Hansen, Astrup & Gjedde (1997),
# J Neurosci Methods 77: 199-209. doi:10.1016/S0165-0270(97)00127-1
# Table 2 "Blood flow and metabolism: average (standard deviation in brackets
# (n = 7))", p. 205.
#
# Reads the frozen snapshot Poulsen_etal_1997_Table2_snapshot.csv (written by
# Poulsen_etal_1997_Table2_snapshot.R) and does all the cleaning:
#   - checks the printed caption, headers and row labels;
#   - folds the two printed lines of the Hemisphere row into one analysis row;
#   - splits every printed "mean (SD)" cell, and the "Multilinear:" /
#     "Graphical:" labels of the (1st) CMRglc column, into named columns;
#   - assigns the method of the UNLABELLED (2nd) CMRglc cells by printed line
#     (line 1 = multilinear, line 2 = graphical), which the Abstract and
#     Results 3.3 confirm (see table_checks);
#   - re-checks every Table 2 cell that the Abstract / Results restate, the
#     printed CBF/CMRO2 ranges against what mean, SD and n allow, and the
#     oxygen extraction fraction against Table 1 + Table 2 (table_checks).
# Observation level: ONE cohort of 7 anaesthetised pigs, two ROIs (separate
# hemispheres averaged; basal ganglia). Rows are ROI x cohort means.
# Units: kept as printed, per 100 cm^3 of TISSUE VOLUME (ml/100 cm^3/min;
# µmol/100 cm^3/min), not per 100 g. No density conversion is applied here;
# a merge that wants per-100 g must state its density assumption (1 g/cm^3
# makes the numbers identical; ~1.04 g/cm^3 lowers them by ~4%).
# No table value is typed in this script.

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
paper <- basename(folder)

suppressPackageStartupMessages(library(readxl))

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(6L, 6L)))
stopifnot(snap[1, 1] == "Table 2",
          grepl("standard deviation in brackets \\(n = 7\\)", snap[2, 1]))
stopifnot(identical(snap[3, ], c("", "CBF (ml/100 cm^3/min)", "CMRO2 (µmol/100 cm^3/min)",
                                 "(1^st) CMRglc (µmol/100 cm^3/min)",
                                 "(2^nd) CMRglc (µmol/100 cm^3/min)", "PaCO2 (kPa)")))
stopifnot(identical(snap[4:6, 1], c("Hemisphere", "", "Basal Ganglia")))

## ---- cell helpers --------------------------------------------------------------
## "Multilinear: 27 (3)" -> label "Multilinear", mean 27, SD 3; "" -> NA
label_of <- function(x) ifelse(grepl(":", x), trimws(sub(":.*$", "", x)), NA_character_)
strip_label <- function(x) trimws(sub("^[^:]*:", "", x))
mean_of <- function(x) { s <- strip_label(x)
  ifelse(nzchar(s), suppressWarnings(as.numeric(sub("^([-0-9.]+)\\s*\\(.*$", "\\1", s))), NA_real_) }
sd_of <- function(x) { s <- strip_label(x)
  ifelse(nzchar(s), suppressWarnings(as.numeric(sub("^.*\\(\\s*([0-9.]+)\\s*\\)$", "\\1", s))), NA_real_) }
n_printed <- as.integer(sub("^.*\\(n = ([0-9]+)\\).*$", "\\1", snap[2, 1]))

hem1 <- snap[4, ]; hem2 <- snap[5, ]; bg <- snap[6, ]
stopifnot(label_of(hem1[4]) == "Multilinear", label_of(hem2[4]) == "Graphical",
          label_of(bg[4]) == "Multilinear", !nzchar(bg[5]), !nzchar(bg[6]),
          all(!nzchar(hem2[c(1, 2, 3, 6)])))

row_of <- function(label, printed_rows, l1, l2) data.frame(
  printed_rows         = printed_rows,
  region_as_printed    = label,
  region_canonical_proposed = NA_character_,
  species_as_published = "pig",
  breed_as_published   = "Danish Yorkshire land race",
  n                    = n_printed,
  dispersion_type      = "SD",
  CBF.ml_100cm3_min      = mean_of(l1[2]), CBF_SD.ml_100cm3_min    = sd_of(l1[2]),
  CMRO2.umol_100cm3_min  = mean_of(l1[3]), CMRO2_SD.umol_100cm3_min = sd_of(l1[3]),
  CMRglc_s1_multilinear.umol_100cm3_min    = mean_of(l1[4]),
  CMRglc_s1_multilinear_SD.umol_100cm3_min = sd_of(l1[4]),
  CMRglc_s1_graphical.umol_100cm3_min      = mean_of(l2[4]),
  CMRglc_s1_graphical_SD.umol_100cm3_min   = sd_of(l2[4]),
  CMRglc_s2_multilinear.umol_100cm3_min    = mean_of(l1[5]),
  CMRglc_s2_multilinear_SD.umol_100cm3_min = sd_of(l1[5]),
  CMRglc_s2_graphical.umol_100cm3_min      = mean_of(l2[5]),
  CMRglc_s2_graphical_SD.umol_100cm3_min   = sd_of(l2[5]),
  PaCO2.kPa    = mean_of(l1[6]), PaCO2_SD.kPa = sd_of(l1[6]),
  note = NA_character_,
  stringsAsFactors = FALSE)

blank <- rep("", 6)
final.dataframe <- rbind(row_of("Hemisphere",    "4-5", hem1, hem2),
                         row_of("Basal Ganglia", "6",   bg,   blank))
## printed region -> canonical region of __merging_cerebral_metabolic_rate: a PROPOSAL, not applied
final.dataframe$region_canonical_proposed <- c(NA_character_, "Basal_ganglia")
final.dataframe$note <- c(
  paste("Average of the separate-hemisphere ROIs (Methods 2.4: grey and white matter not separable;",
        "PET co-registered to a T1 MR image of a pig brain). Extent of the hemispheric ROI",
        "(cerebellum/brainstem included or not) is not stated: a cerebral-hemisphere value, not",
        "a whole-brain value. (2nd) CMRglc methods assigned by printed line. CBF SD prints",
        "(4) here but '37 ± 3' in the Abstract: errata Poulsen_etal_1997-E001."),
  paste("'Basal Ganglia' ROI, constituent nuclei not specified. Only the session-1 multilinear",
        "CMRglc is printed; session-2 and graphical cells are blank in the print, as is PaCO2."))

## ---- table checks (HOWTO section 7a) -------------------------------------------
tx <- read_snapshot(file.path("reference_tables", paste0(paper, "_data_from_text_snapshot.csv")),
                    header = TRUE)
stopifnot(nrow(tx) == 28L, identical(tx$text_row, as.character(1:28)))
t1 <- read_snapshot(paste0(paper, "_Table1_snapshot.csv"))
stopifnot(t1[3, 6] == "O2 (mM)")
CaO2 <- mean_of(t1[4, 6])

txv <- function(r) as.numeric(tx$value_printed[tx$text_row == r])
txd <- function(r) as.numeric(tx$dispersion_printed[tx$text_row == r])
H <- final.dataframe[final.dataframe$region_as_printed == "Hemisphere", ]

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable",
                      ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
restate <- function(id, col, r, what = c("mean", "sd")) {
  what <- match.arg(what)
  pr <- if (what == "mean") txv(r) else txd(r)
  chk(paste0(id, "_", what, "_text", r),
      sprintf("Table 2 Hemisphere %s %s vs text row %s (%s, p. %s)", col, what, r,
              tx$location[tx$text_row == r], tx$page[tx$text_row == r]),
      H[[col]], pr, 0, "restatement: the same printed number must appear")
}
## Samuelson bound: no single value of n can lie more than SD*(n-1)/sqrt(n) from the mean
samuelson <- function(id, mean, sd, r, side) {
  bound <- mean + side * sd * (n_printed - 1) / sqrt(n_printed)
  x <- txv(r)
  ok <- if (side > 0) x <= bound + 0.5 else x >= bound - 0.5
  data.frame(check_id = id,
             basis = sprintf("text row %s (%s, p. %s) individual %s %s vs mean %s, SD %s, n %s",
                             r, tx$location[tx$text_row == r], tx$page[tx$text_row == r],
                             if (side > 0) "maximum" else "minimum", x, mean, sd, n_printed),
             observed = bound, printed = x, difference = bound - x, tolerance = 0.5,
             status = if (ok) "pass" else "mismatch",
             note = "observed = the largest (smallest) value any one of n animals can take given the printed mean and SD (Samuelson inequality), +/- half a printed unit",
             stringsAsFactors = FALSE)
}
oef_obs <- H$CMRO2.umol_100cm3_min / (H$CBF.ml_100cm3_min * CaO2)
oef_tol <- oef_obs * (0.5 / H$CMRO2.umol_100cm3_min + 0.5 / H$CBF.ml_100cm3_min + 0.05 / CaO2) + 0.005

table_checks <- rbind(
  restate("CMRO2", "CMRO2.umol_100cm3_min", "2", "mean"),
  restate("CMRO2", "CMRO2_SD.umol_100cm3_min", "2", "sd"),
  restate("CMRO2", "CMRO2.umol_100cm3_min", "17", "mean"),
  restate("CMRO2", "CMRO2_SD.umol_100cm3_min", "17", "sd"),
  restate("CBF", "CBF.ml_100cm3_min", "5", "mean"),
  restate("CBF", "CBF_SD.ml_100cm3_min", "5", "sd"),
  restate("CBF", "CBF.ml_100cm3_min", "20", "mean"),
  restate("PaCO2", "PaCO2.kPa", "6", "mean"),
  restate("PaCO2", "PaCO2_SD.kPa", "6", "sd"),
  restate("PaCO2", "PaCO2.kPa", "21", "mean"),
  restate("PaCO2", "PaCO2_SD.kPa", "21", "sd"),
  restate("CMRglc_s1_multilinear", "CMRglc_s1_multilinear.umol_100cm3_min", "8", "mean"),
  restate("CMRglc_s1_multilinear", "CMRglc_s1_multilinear_SD.umol_100cm3_min", "8", "sd"),
  restate("CMRglc_s1_graphical", "CMRglc_s1_graphical.umol_100cm3_min", "9", "mean"),
  restate("CMRglc_s1_graphical", "CMRglc_s1_graphical_SD.umol_100cm3_min", "9", "sd"),
  restate("CMRglc_s2_multilinear", "CMRglc_s2_multilinear.umol_100cm3_min", "10", "mean"),
  restate("CMRglc_s2_multilinear", "CMRglc_s2_multilinear_SD.umol_100cm3_min", "10", "sd"),
  restate("CMRglc_s2_graphical", "CMRglc_s2_graphical.umol_100cm3_min", "11", "mean"),
  restate("CMRglc_s2_graphical", "CMRglc_s2_graphical_SD.umol_100cm3_min", "11", "sd"),
  restate("CMRglc_s1_multilinear", "CMRglc_s1_multilinear.umol_100cm3_min", "25", "mean"),
  restate("CMRglc_s2_multilinear", "CMRglc_s2_multilinear.umol_100cm3_min", "25", "mean"),
  restate("CMRglc_s1_graphical", "CMRglc_s1_graphical.umol_100cm3_min", "26", "mean"),
  restate("CMRglc_s1_graphical", "CMRglc_s1_graphical_SD.umol_100cm3_min", "26", "sd"),
  restate("CMRglc_s2_graphical", "CMRglc_s2_graphical.umol_100cm3_min", "27", "mean"),
  restate("CMRglc_s2_graphical", "CMRglc_s2_graphical_SD.umol_100cm3_min", "27", "sd"),
  samuelson("CMRO2_range_min_text15", H$CMRO2.umol_100cm3_min, H$CMRO2_SD.umol_100cm3_min, "15", -1),
  samuelson("CMRO2_range_max_text16", H$CMRO2.umol_100cm3_min, H$CMRO2_SD.umol_100cm3_min, "16", +1),
  samuelson("CBF_range_min_text3",  H$CBF.ml_100cm3_min, H$CBF_SD.ml_100cm3_min, "3",  -1),
  samuelson("CBF_range_max_text4",  H$CBF.ml_100cm3_min, H$CBF_SD.ml_100cm3_min, "4",  +1),
  samuelson("CBF_range_min_text18", H$CBF.ml_100cm3_min, H$CBF_SD.ml_100cm3_min, "18", -1),
  samuelson("CBF_range_max_text19", H$CBF.ml_100cm3_min, H$CBF_SD.ml_100cm3_min, "19", +1),
  chk("OEF_fick_text12",
      "OEF = CMRO2 / (CBF x arterial O2): Table 2 Hemisphere CMRO2 / (CBF x Table 1 O2 (mM)) vs Abstract 0.46 (text row 12)",
      oef_obs, txv("12"), oef_tol,
      paste("Fick relation on the printed cohort means; ml/100 cm^3/min x mM = µmol/100 cm^3/min.",
            "Tolerance = rounding of the three printed inputs + half a unit of 0.46. A ratio of",
            "means differs from a mean of ratios, but with CVs of ~10% that cannot move 0.81 to 0.46.",
            "Errata Poulsen_etal_1997-E003."))
)

tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV (only once registered) ---------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
