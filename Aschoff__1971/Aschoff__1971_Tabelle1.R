# Aschoff__1971_Tabelle1.R ----------------------------------------------------
#
# Aschoff (1971), "Temperaturregulation" in Aschoff, Guenther & Kramer, Energiehaushalt und
# Temperaturregulation, in Gauer, Kramer & Jung (eds) Physiologie des Menschen Bd 2.
# Tabelle 1 "Sauerstoffaufnahme bzw. Waermebildung der Organe im ruhenden Koerper
# (65 kg Gewicht, 270 cm3/min Sauerstoffaufnahme)", p. 44. SECONDARY compilation: the
# organ weights and rates are textbook estimates; the table cites no source per row.
#
# Reads the frozen snapshot (Aschoff__1971_Tabelle1_snapshot.csv) and:
#   - writes one analysis row per printed organ (7 rows; Splanchnikusgebiet = splanchnic
#     region, printed "Splanchnikus-\ngebiet");
#   - parses German numerals (thousands point in the weight column, decimal comma elsewhere);
#   - converts mL O2 to the project unit umol O2 (x 44.64) and keeps cal as printed;
#   - adds implied_cal_per_ml_O2 = printed cal / printed mL (derived, not printed);
#   - checks organ totals against weight x rate (table_checks, HOWTO 7a).
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

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## repo root (holds __ReadMe.xlsx) and the General species key for this paper folder
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                na.strings = character(0), encoding = "UTF-8")
key <- key[key$source_publication == paper, ]
if (!nrow(key)) stop("no rows for ", paper, " in _keys/General/species_key.csv", call. = FALSE)
species_cols <- function(printed) {
  i <- match(printed, key$variant_name)
  if (anyNA(i)) stop("species not in key: ", paste(unique(printed[is.na(i)]), collapse = "; "), call. = FALSE)
  data.frame(species_as_published = printed, species_accepted = key$accepted_name[i],
             ncbi_taxid = key$ncbi_taxid[i], stringsAsFactors = FALSE)
}
## half unit of the last printed decimal of a printed number string
hu <- function(s) { s <- gsub("[^0-9.]", "", s); d <- ifelse(grepl("\\.", s), nchar(sub("^.*\\.", "", s)), 0L); 0.5 * 10^(-d) }

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[[1]], "  mismatch=", tally[[2]], "  not_evaluable=", tally[[3]])
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
UMOL_PER_ML_O2 <- 44.64          # umol O2 per mL O2 (22.4 L/mol at STP: 1000/22.4)

code_src <- "Aschoff:1971:Energiehaushalt"   # no DOI: alternative code for registry col C (owner to confirm)

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(11L, 6L)), snap[5, 1] == "Haut", snap[11, 1] == "Splanchnikus-\ngebiet",
          snap[3, 3] == "ml", snap[4, 5] == "100 g · min")
rows <- 5:11
de_dec  <- function(x) as.numeric(sub(",", ".", x, fixed = TRUE))
hu_de   <- function(s) hu(sub(",", ".", s, fixed = TRUE))
de_thou <- function(x) as.numeric(gsub(".", "", x, fixed = TRUE))
sp <- species_cols(rep("human", length(rows)))
final.dataframe <- data.frame(
  printed_row = rows, organ_order = seq_along(rows),
  organ_as_published = gsub("\n", " ", snap[rows, 1], fixed = TRUE),
  sp,
  reference_body_mass_kg = 65, reference_whole_body_O2_ml_min = 270,
  weight_g_printed = snap[rows, 2], O2_ml_100g_min_printed = snap[rows, 3], O2_ml_organ_min_printed = snap[rows, 4],
  heat_cal_100g_min_printed = snap[rows, 5], heat_cal_organ_min_printed = snap[rows, 6],
  weight_g = de_thou(snap[rows, 2]),
  O2_ml_100g_min = de_dec(snap[rows, 3]), O2_ml_organ_min = de_dec(snap[rows, 4]),
  heat_cal_100g_min = de_dec(snap[rows, 5]), heat_cal_organ_min = de_dec(snap[rows, 6]),
  stringsAsFactors = FALSE)
final.dataframe$O2_umol_100g_min  <- round(final.dataframe$O2_ml_100g_min  * UMOL_PER_ML_O2, 2)
final.dataframe$O2_umol_organ_min <- round(final.dataframe$O2_ml_organ_min * UMOL_PER_ML_O2, 1)
final.dataframe$implied_cal_per_ml_O2 <- round(final.dataframe$heat_cal_100g_min / final.dataframe$O2_ml_100g_min, 3)
final.dataframe$unit_as_printed <- "weight g; O2 ml/(100 g min) and ml/(organ min); heat cal/(100 g min) and cal/(organ min)"
final.dataframe$ref_key <- NA_character_
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$organ_as_published == "Splanchnikus- gebiet"] <- "splanchnic region (abdominal viscera incl. liver); printed with a line break after the hyphen"
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 7L, !anyNA(final.dataframe[, c("weight_g", "O2_ml_100g_min", "heat_cal_organ_min")]))

## ---- table checks (HOWTO section 7a) ---------------------------------------------
## Relation: organ column = weight x per-100-g rate / 100. Tolerance = rounding of each
## printed factor (half a unit of its last decimal; weights taken to the nearest gram) plus
## half a unit of the printed product. A sum row is not printed; the caption total
## (270 ml/min, 65 kg) covers more tissue than the seven rows, so it is not evaluable.
d <- final.dataframe
tp <- function(w, hw, r, hr, hp) (hw * r + hr * w) / 100 + hp
table_checks <- rbind(
  do.call(rbind, lapply(seq_len(nrow(d)), function(i)
    chk(paste0("O2_organ_", i), paste0(d$organ_as_published[i], ": weight x O2 ml/100 g/min / 100 vs printed O2 ml/organ/min"),
        d$weight_g[i] * d$O2_ml_100g_min[i] / 100, d$O2_ml_organ_min[i],
        tp(d$weight_g[i], 0.5, d$O2_ml_100g_min[i], hu_de(d$O2_ml_100g_min_printed[i]), hu_de(d$O2_ml_organ_min_printed[i]))))),
  do.call(rbind, lapply(seq_len(nrow(d)), function(i)
    chk(paste0("heat_organ_", i), paste0(d$organ_as_published[i], ": weight x heat cal/100 g/min / 100 vs printed cal/organ/min"),
        d$weight_g[i] * d$heat_cal_100g_min[i] / 100, d$heat_cal_organ_min[i],
        tp(d$weight_g[i], 0.5, d$heat_cal_100g_min[i], hu_de(d$heat_cal_100g_min_printed[i]), hu_de(d$heat_cal_organ_min_printed[i]))))),
  chk("sum_O2_vs_caption", "sum of the 7 printed organ O2 ml/min vs caption whole-body 270 ml/min",
      sum(d$O2_ml_organ_min), 270, 0.5 * nrow(d) * 0.1,
      "not an arithmetic error: the table lists 7 tissues; the remainder (bone, fat, blood, other) is not tabulated"),
  chk("sum_weight_vs_caption", "sum of the 7 printed organ weights (kg) vs caption body weight 65 kg",
      sum(d$weight_g) / 1000, 65, 0.0035, "coverage gap, as above")
)
## the two coverage rows are descriptive, not tests: report them as not evaluable
table_checks$status[table_checks$check_id %in% c("sum_O2_vs_caption", "sum_weight_vs_caption")] <- "not_evaluable"
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not yet
## registered, the code is derived exactly as the registry formula builds it (DOI / col-C
## alternative code with "/" and ":" percent-encoded, "_", item locus); the registry
## stays the authority (rename the TSV if it differs after the owner pastes the row).
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub(":", "%3A", gsub("/", "%2F", code_src, fixed = TRUE), fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ", item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
