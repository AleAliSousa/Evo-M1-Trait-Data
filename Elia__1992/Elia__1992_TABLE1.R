# Elia__1992_TABLE1.R -------------------------------------------------------------
#
# Elia (1992), "Organ and tissue contribution to metabolic rate", in Kinney & Tucker (Eds.), Energy
# Metabolism: Tissue Determinants and Cellular Corollaries, Raven Press, New York, pp. 61-77 (PDF).
# TABLE 1 "Contribution of different organs and tissues to body weight and basal metabolic rate in the
# reference male, reference female, and a child", p. 63.   SECONDARY compilation (see README).
#
# Reads the frozen snapshot (Elia__1992_TABLE1_snapshot.csv, written by Elia__1992_extract_snapshot.R) and:
#   - reshapes to one analysis row per printed cell group (organ x subject: reference male / reference
#     female / child 0.5 y), in printed order, reading down each organ row; the 'Total' row is kept as
#     row_type 'total'; the 'Miscellaneous tissues by difference' row as row_type 'by_difference';
#   - keeps every printed number as text AND parsed; nothing is repaired;
#   - adds project-unit columns: body_mass.g, organ_mass.g (kg x 1000), Brain_Mass.mg (kg x 1e6),
#     organ_rate.umol_O2_100g_min and CMRO2_derived.umol_100g_min (brain rows only; kcal/kg/day -> umol O2/100 g/min
#     with 4.9 kcal per litre O2 and 44.64 umol per mL O2; the 4.9 is NOT printed here);
#   - re-runs the table's own arithmetic (section 7a) into table_checks;
#   - writes the analysis CSV and the public TSV.
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
locus <- sub(paste0("^", paper, "_"), "", item_name)

read_snapshot <- function(file) {
  x <- read.csv(file, header = FALSE, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
num_of <- function(x) suppressWarnings(as.numeric(gsub(",", "", gsub("\\s+", "", x))))
oneline <- function(x) trimws(gsub("\\s+", " ", x))        # printed line breaks inside a cell -> one space
ndec <- function(x) ifelse(grepl("\\.", x), nchar(sub("^.*\\.", "", gsub("[^0-9.]", "", x))), 0L)

## project conversion of energy to O2 (documented in the README and definitions):
## kcal/kg/day -> mL O2/100 g/min uses 4.9 kcal per litre O2 (the factor used by Holliday et al. 1967/1971
## and in the energetics comparison; NOT printed in this source); mL O2 -> umol O2 x 44.64.
kcal_per_L_O2  <- 4.9
umol_per_mL_O2 <- 44.64
kcal_kg_day_to_umol_100g_min <- function(x) x * 1000 / (kcal_per_L_O2 * 10 * 1440) * umol_per_mL_O2

## species key: collection General, rows proposed in reference_tables (the shared _keys file is not edited here)
key <- read.csv(file.path("reference_tables", paste0(paper, "_species_key_proposed.csv")), colClasses = "character",
                na.strings = character(0), encoding = "UTF-8")
key <- key[key$source_publication == paper, ]
if (nrow(key) == 0L) stop("no species-key rows for ", paper, call. = FALSE)
harmonise <- function(printed) {
  i <- match(printed, key$variant_name)
  if (anyNA(i)) stop("species variant(s) not in the key: ", paste(unique(printed[is.na(i)]), collapse = "; "), call. = FALSE)
  key$accepted_name[i]
}

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

isbn <- "9780881678710"     # Kinney & Tucker (Eds.) 1992, Raven Press (ISBN-10 0881678716)

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(15L, 11L)), snap[1, 1] == "TABLE 1", snap[4, 2] == "Reference\nmale",
          snap[12, 1] == "Total")
rows <- which(seq_len(nrow(snap)) > 4L & nzchar(snap[, 2]))
stopifnot(length(rows) == 8L)

groups <- data.frame(g = 1:3, group = oneline(snap[4, 2:4]), wcol = 2:4, pcol = 5:7, mcol = 9:11,
                     ref_key = c("2", "2", "2; 7; 8; 9"), stringsAsFactors = FALSE)
stopifnot(identical(groups$group, c("Reference male", "Reference female", "Child (0.5 y)")))

marks_of <- function(x) ifelse(grepl("\\^[a-z]$", x), sub("^.*\\^([a-z])$", "\\1", x), NA_character_)
strip_marks <- function(x) oneline(sub("\\^[a-z]$", "", x))

out <- list()
for (r in rows) {
  lab <- snap[r, 1]
  rt  <- if (lab == "Total") "total" else if (startsWith(lab, "Miscellaneous")) "by_difference" else "organ"
  for (k in seq_len(nrow(groups))) {
    mcell <- snap[r, groups$mcol[k]]
    out[[length(out) + 1L]] <- data.frame(
      printed_row = r, organ_order = r - 4L,
      organ_as_published = strip_marks(lab), footnote_marks = marks_of(lab), row_type = rt,
      group_as_published = groups$group[k],
      weight_kg_printed = snap[r, groups$wcol[k]], pct_body_weight_printed = snap[r, groups$pcol[k]],
      organ_rate_kcal_kg_day_printed = snap[r, 8], metabolic_pct_total_printed = oneline(mcell),
      ref_key = groups$ref_key[k], stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, out)
final.dataframe$species_as_published <- final.dataframe$group_as_published
final.dataframe$species              <- harmonise(final.dataframe$species_as_published)
final.dataframe$weight_kg                      <- num_of(final.dataframe$weight_kg_printed)
final.dataframe$pct_body_weight                <- num_of(final.dataframe$pct_body_weight_printed)
final.dataframe$organ_rate_kcal_kg_day         <- num_of(final.dataframe$organ_rate_kcal_kg_day_printed)
final.dataframe$metabolic_pct_total            <- num_of(sub("\\s*\\(.*$", "", final.dataframe$metabolic_pct_total_printed))
final.dataframe$total_kcal_day                 <- ifelse(final.dataframe$row_type == "total",
    num_of(sub("^.*\\(([0-9,]+) kcal.*$", "\\1", final.dataframe$metabolic_pct_total_printed)), NA_real_)

## project-unit columns
tot_kg <- final.dataframe$weight_kg[final.dataframe$row_type == "total"]
names(tot_kg) <- final.dataframe$group_as_published[final.dataframe$row_type == "total"]
final.dataframe$body_mass.g  <- unname(tot_kg[final.dataframe$group_as_published]) * 1000
final.dataframe$organ_mass.g <- ifelse(final.dataframe$row_type == "total", NA_real_, final.dataframe$weight_kg * 1000)
final.dataframe$Brain_Mass.mg <- ifelse(final.dataframe$organ_as_published == "Brain", final.dataframe$weight_kg * 1e6, NA_real_)
final.dataframe$organ_rate.umol_O2_100g_min <- kcal_kg_day_to_umol_100g_min(final.dataframe$organ_rate_kcal_kg_day)
final.dataframe$CMRO2_derived.umol_100g_min <- ifelse(final.dataframe$organ_as_published == "Brain",
                                              final.dataframe$organ_rate.umol_O2_100g_min, NA_real_)
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$organ_as_published == "Liver"] <-
  "Footnote c: several workers estimate the 'liver' at 25-32% of adult BMR (printed refs 10-13); probably overestimates, since they were usually calculated from O2 of liver plus portal drained viscera."
final.dataframe$note[final.dataframe$row_type == "by_difference"] <-
  "Printed as 'Miscellaneous tissues by difference (e.g., bone, skin, intestines, glands)': weight, % body weight and % metabolic rate are remainders, not measurements."
final.dataframe$note[final.dataframe$row_type == "total"] <-
  "Total row; the printed total kcal/day (1680 / 1340 / 390) is carried in total_kcal_day."
final.dataframe$note[final.dataframe$organ_as_published == "Brain"] <-
  "Organ metabolic rate 240 kcal/kg/day is one value for all three subjects (printed once). CMRO2_derived.umol_100g_min is DERIVED here (4.9 kcal/L O2), not printed."
stopifnot(nrow(final.dataframe) == 24L)

## ---- table checks (HOWTO section 7a) -------------------------------------------
fd <- final.dataframe
fn_b <- snap[startsWith(snap[, 1], "^b "), 1]
stopifnot(length(fn_b) == 1L)
vals_b <- regmatches(fn_b, gregexpr("the values are [0-9., and]+ kcal", fn_b))[[1]]
stopifnot(length(vals_b) == 2L)
per_kg  <- as.numeric(regmatches(vals_b[1], gregexpr("[0-9]+\\.[0-9]", vals_b[1]))[[1]])
per_ffm <- as.numeric(regmatches(vals_b[2], gregexpr("[0-9]+\\.[0-9]", vals_b[2]))[[1]])
ffm_kg  <- as.numeric(regmatches(fn_b, regexec("fat-free mass \\(([0-9.]+) kg for the reference male, ([0-9.]+) kg for reference female.*and ([0-9.]+) kg for child", fn_b))[[1]][2:4])
stopifnot(length(per_kg) == 3L, length(per_ffm) == 3L, length(ffm_kg) == 3L, !anyNA(ffm_kg))

ck <- list()
for (g in groups$group) {
  d   <- fd[fd$group_as_published == g, ]
  org <- d[d$row_type != "total", ]; tot <- d[d$row_type == "total", ]
  Wt  <- tot$weight_kg; Tk <- tot$total_kcal_day
  ck[[length(ck) + 1L]] <- chk(paste0("weight_sum_", g), paste0(g, ": sum of the 7 printed tissue weights vs printed Total weight (kg)"),
        sum(org$weight_kg), Wt, sum(0.5 * 10^-ndec(org$weight_kg_printed)),
        "tolerance = half a unit of each summed cell's last printed decimal")
  ck[[length(ck) + 1L]] <- chk(paste0("pct_body_weight_sum_", g), paste0(g, ": printed % body weight column sums to 100"),
        sum(org$pct_body_weight), 100, sum(0.5 * 10^-ndec(org$pct_body_weight_printed)))
  ck[[length(ck) + 1L]] <- chk(paste0("pct_metabolic_sum_", g), paste0(g, ": printed % metabolic rate column sums to 100"),
        sum(org$metabolic_pct_total), 100, sum(0.5 * 10^-ndec(sub("\\s*\\(.*$", "", org$metabolic_pct_total_printed))))
  for (i in seq_len(nrow(org))) {
    ck[[length(ck) + 1L]] <- chk(paste0("pct_body_weight_", g, "_", org$organ_as_published[i]),
        paste0(g, ", ", org$organ_as_published[i], ": 100 x weight / printed Total weight vs printed % body weight"),
        100 * org$weight_kg[i] / Wt, org$pct_body_weight[i],
        0.5 * 10^-ndec(org$pct_body_weight_printed[i]) + 100 * 0.5 * 10^-ndec(org$weight_kg_printed[i]) / Wt,
        "tolerance = half a unit of the printed % plus the rounding of the printed weight")
    if (org$row_type[i] == "organ") {
      ck[[length(ck) + 1L]] <- chk(paste0("pct_metabolic_", g, "_", org$organ_as_published[i]),
        paste0(g, ", ", org$organ_as_published[i], ": 100 x weight x organ rate / printed Total kcal/day vs printed % metabolic rate"),
        100 * org$weight_kg[i] * org$organ_rate_kcal_kg_day[i] / Tk, org$metabolic_pct_total[i], 0.5,
        "tolerance = half a unit of the printed integer percentage")
    }
  }
  oth <- org[org$row_type == "organ", ]; mis <- org[org$row_type == "by_difference", ]
  ck[[length(ck) + 1L]] <- chk(paste0("pct_metabolic_by_difference_", g), paste0(g, ": 100 minus the six printed organ percentages vs printed Miscellaneous percentage"),
        100 - sum(oth$metabolic_pct_total), mis$metabolic_pct_total, 0)
  ck[[length(ck) + 1L]] <- chk(paste0("total_kcal_vs_rows_", g),
        paste0(g, ": sum over rows of weight x organ rate (kcal/day) vs printed Total kcal/day (informational: the printed total is an independent standard-based value, footnote b, not built from the rows; tolerance 5% is a reading aid, not a printed rule)"),
        sum(org$weight_kg * org$organ_rate_kcal_kg_day), Tk, 0.05 * Tk)
}
for (k in 1:3) {
  g <- groups$group[k]; tot <- fd[fd$group_as_published == g & fd$row_type == "total", ]
  ck[[length(ck) + 1L]] <- chk(paste0("footnote_b_per_kg_", g), paste0("footnote b: printed Total kcal/day / printed Total weight vs the value printed for ", g, " (printed unit 'kcal/day', i.e. kcal/kg/day)"),
        tot$total_kcal_day / tot$weight_kg, per_kg[k],
        0.05, "tolerance = half a unit of the printed decimal; the printed weights (70.00, 58, 7.5) are taken as exact (the female rows sum to 57.999)")
  ck[[length(ck) + 1L]] <- chk(paste0("footnote_b_per_ffm_", g), paste0("footnote b: printed Total kcal/day / printed fat-free mass (", ffm_kg[k], " kg) vs the printed kcal/kg FFM/day for ", g),
        tot$total_kcal_day / ffm_kg[k], per_ffm[k], 0.05)
}
table_checks <- do.call(rbind, ck)
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not yet registered, the code is
## derived as the registry formula would build it (ISBN override in column C, "ISBN:<isbn-13>" percent-encoded,
## "_", item locus; the Baron_etal_1996 convention); the README says the item awaits registration.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0("ISBN%3A", isbn, "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ", item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
