# Elia__1992_TABLE3.R -------------------------------------------------------------
#
# Elia (1992), "Organ and tissue contribution to metabolic rate", Raven Press, pp. 61-77 (PDF).
# TABLE 3 "Relation of organ weight to body weight (organ weight = K x body weight^x) in approximately
# mature mammals", p. 66.   Footnote a: "Calculated using data from Brody (17)" = Brody (1945),
# Bioenergetics and Growth.  SECONDARY compilation (see README).
#
# Reads the frozen snapshot (Elia__1992_TABLE3_snapshot.csv, written by Elia__1992_extract_snapshot.R) and:
#   - one analysis row per printed species row (11), in printed order; every printed cell is kept as
#     text (*_as_printed for the two cells whose print needs it) AND parsed, nothing is repaired;
#   - the printed Lung of the elephant is in parentheses "(6,650)": parsed, flagged in lung_in_parentheses;
#   - the two cut-off cells of the last column (scan edge, "39.[cut]", "17.[cut]") parse to NA;
#   - units: body g (as printed), organ weights g (as printed), Brain_Mass.mg = brain g x 1000 (project unit);
#   - writes the printed K x W^x row and correlation row as reference_tables/Elia__1992_TABLE3_allometry_as_printed.csv
#     (a fit-statistics row, not species data);
#   - re-runs the table's own arithmetic and re-fits the printed power laws (section 7a) into table_checks;
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
stopifnot(identical(dim(snap), c(19L, 9L)), snap[1, 1] == "TABLE 3", snap[3, 3] == "Liver\n(g)")
rows <- which(grepl("^[0-9,]+$", snap[, 2]))
stopifnot(length(rows) == 11L, identical(rows, 4:14))
kw_row <- which(startsWith(snap[, 1], "KW")); r_row <- which(startsWith(snap[, 1], "Correlation"))
stopifnot(length(kw_row) == 1L, length(r_row) == 1L)

organ_cols <- c(liver = 3L, kidneys = 4L, brain = 5L, heart = 6L, lung = 7L, all5 = 8L, all_minus_lung = 9L)
cellnum <- function(x) {                       # "(6,650)" -> 6650 ; "39.[cut]" -> NA
  x <- gsub("[()]", "", x)
  ifelse(grepl("[cut]", x, fixed = TRUE), NA_real_, num_of(x))
}
final.dataframe <- data.frame(
  printed_row = rows, species_order = seq_along(rows),
  species_as_published = snap[rows, 1], stringsAsFactors = FALSE)
final.dataframe$species <- harmonise(final.dataframe$species_as_published)
final.dataframe$body_mass.g <- cellnum(snap[rows, 2])
for (nm in names(organ_cols)) final.dataframe[[paste0(nm, "_mass.g")]] <- cellnum(snap[rows, organ_cols[[nm]]])
final.dataframe$Brain_Mass.mg <- final.dataframe$brain_mass.g * 1000
names(final.dataframe)[names(final.dataframe) == "all5_mass.g"] <- "all5_printed.g"
names(final.dataframe)[names(final.dataframe) == "all_minus_lung_mass.g"] <- "all_minus_lung_printed.g"
final.dataframe$lung_in_parentheses <- grepl("^\\(", snap[rows, organ_cols[["lung"]]])
final.dataframe$all_minus_lung_as_printed <- snap[rows, organ_cols[["all_minus_lung"]]]
final.dataframe$ref_key <- "17"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$lung_in_parentheses] <-
  "Lung printed in parentheses: '(6,650)', no explanation printed; parsed as 6650 g and flagged."
cut <- grepl("[cut]", final.dataframe$all_minus_lung_as_printed, fixed = TRUE)
final.dataframe$note[cut] <- "'All organs minus lung' cell cut off at the right edge of the scan ('39.' / '17.' visible); value not read, NA."
stopifnot(nrow(final.dataframe) == 11L, sum(cut) == 2L)

## printed fit row (K x W^x) and correlation row, kept apart from the species rows
kw <- snap[kw_row, organ_cols]; rr <- snap[r_row, organ_cols]
hdr <- oneline(snap[3, organ_cols])
allom <- data.frame(organ_as_published = sub(" \\(g\\)$", "", hdr), KWx_as_printed = kw, correlation_as_printed = rr,
                    stringsAsFactors = FALSE)
m <- regmatches(kw, regexec("^([0-9.]+)W\\^([0-9.]+)$", kw))
allom$K_printed        <- vapply(m, function(z) if (length(z) == 3L) as.numeric(z[2]) else NA_real_, 0)
allom$exponent_printed <- vapply(m, function(z) if (length(z) == 3L) as.numeric(z[3]) else NA_real_, 0)
allom$correlation_printed <- cellnum(rr)
allom$note <- ifelse(is.na(allom$K_printed), "cut off at the right edge of the scan", NA_character_)
write.csv(allom, file.path("reference_tables", paste0(paper, "_TABLE3_allometry_as_printed.csv")), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")

## ---- table checks (HOWTO section 7a) -------------------------------------------
fd <- final.dataframe
dec5 <- function(i) ndec(snap[rows[i], organ_cols[c("liver", "kidneys", "brain", "heart", "lung")]])
ck <- list()
for (i in seq_len(nrow(fd))) {
  five <- c(fd$liver_mass.g[i], fd$kidneys_mass.g[i], fd$brain_mass.g[i], fd$heart_mass.g[i], fd$lung_mass.g[i])
  tol5 <- sum(0.5 * 10^-dec5(i)); tol4 <- sum(0.5 * 10^-dec5(i)[1:4])
  sp <- fd$species_as_published[i]
  ck[[length(ck) + 1L]] <- chk(paste0("all5_sum_", sp), paste0(sp, ": liver + kidneys + brain + heart + lung vs printed 'All 5 organs'"),
        sum(five), fd$all5_printed.g[i], tol5, "tolerance = half a unit of each summed cell's last printed decimal")
  ck[[length(ck) + 1L]] <- chk(paste0("minus_lung_sum_", sp), paste0(sp, ": liver + kidneys + brain + heart vs printed 'All organs minus lung'"),
        sum(five[1:4]), fd$all_minus_lung_printed.g[i], tol4,
        if (is.na(fd$all_minus_lung_printed.g[i])) "printed cell cut off at the scan edge; recomputed value shown as 'observed' only" else NA_character_)
}
swap <- sum(abs(sapply(seq_len(nrow(fd)), function(i) sum(c(fd$liver_mass.g[i], fd$kidneys_mass.g[i], fd$brain_mass.g[i], fd$heart_mass.g[i], fd$lung_mass.g[i])) - fd$all_minus_lung_printed.g[i])) < 1e-6 &
           abs(sapply(seq_len(nrow(fd)), function(i) sum(c(fd$liver_mass.g[i], fd$kidneys_mass.g[i], fd$brain_mass.g[i], fd$heart_mass.g[i])) - fd$all5_printed.g[i])) < 1e-6, na.rm = TRUE)
ck[[length(ck) + 1L]] <- chk("columns_swapped_rows", "rows in which the printed 'All 5 organs' equals the 4-organ sum and the printed 'All organs minus lung' equals the 5-organ sum (the two printed columns swapped); observed = count",
        swap, 0, 0, "Horse: printed 13,220 under 'All 5 organs' is the 4-organ sum; printed 18,620 under 'All organs minus lung' is the 5-organ sum")
## re-fit the printed power laws on the printed species rows (lung of the elephant taken as 6650; 5-organ sum recomputed)
fit_y <- list(liver = fd$liver_mass.g, kidneys = fd$kidneys_mass.g, brain = fd$brain_mass.g, heart = fd$heart_mass.g, lung = fd$lung_mass.g,
              all5 = fd$liver_mass.g + fd$kidneys_mass.g + fd$brain_mass.g + fd$heart_mass.g + fd$lung_mass.g)
for (nm in names(fit_y)) {
  j <- match(nm, c("liver", "kidneys", "brain", "heart", "lung", "all5"))
  f <- lm(log(fit_y[[nm]]) ~ log(fd$body_mass.g)); b <- unname(coef(f)[2]); K <- unname(exp(coef(f)[1])); r <- cor(log(fit_y[[nm]]), log(fd$body_mass.g))
  ck[[length(ck) + 1L]] <- chk(paste0("refit_exponent_", nm), paste0(nm, ": OLS exponent of log(organ g) on log(body g), 11 printed rows, vs printed exponent"),
        b, allom$exponent_printed[j], 0.005, "tolerance = half a unit of the printed 2-decimal exponent")
  ck[[length(ck) + 1L]] <- chk(paste0("refit_K_", nm), paste0(nm, ": OLS constant K from the same fit vs printed K (relative difference, observed - printed relative to printed)"),
        (K - allom$K_printed[j]) / allom$K_printed[j], 0, 0.05, "tolerance 5% relative = reading aid for the 2-3 significant figures printed; observed = relative difference")
  ck[[length(ck) + 1L]] <- chk(paste0("refit_r_", nm), paste0(nm, ": correlation of the log-log fit vs printed correlation coefficient"),
        r, allom$correlation_printed[j], 0.005 + 0.005, "tolerance = half a unit of the printed 2-decimal r plus 0.005 for the fit's data rounding")
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
