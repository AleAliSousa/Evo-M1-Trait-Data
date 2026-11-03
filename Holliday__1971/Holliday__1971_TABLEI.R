# Holliday__1971_TABLEI.R ---------------------------------------------------------
#
# Holliday (1971), Pediatrics 47(1) Suppl. 2: 169-179. TABLE I "VO2, organ metabolic rate
# (OMR/kilogram body weight), metabolic rate and percent BMR derived from each organ system
# in adult man", p. 170. SECONDARY compilation: the VO2 of each organ is taken from a cited
# primary (Brain^6 Kennedy & Sokoloff 1957; Liver^7 Brauer 1963; Heart^8 Rowe et al. 1959;
# Kidney^9 Crosley et al. 1961; Muscle^4 Andres et al. 1956); weights from standard organ
# weights; the conversion uses 4.9 kcal/L O2 (R.Q. 0.9; footnote dagger, ref 10).
#
# Reads the frozen snapshot (Holliday__1971_TABLEI_snapshot.csv) and:
#   - writes one analysis row per printed row (4 organs, Total 1-4, Muscle, Total 1-5,
#     70 kg man) = 8 rows; row number "1)" and superscript ref marks are split out
#     (ref_key = the printed footnote number; join to reference_tables/..._references.csv);
#   - strips the thousands commas, the asterisk and the dagger from the numbers (the marks
#     are kept in rate_mark / weight_mark);
#   - converts VO2 mL/100 g/min to the project unit umol O2/100 g/min (x 44.64);
#   - checks the table against its own arithmetic (table_checks, HOWTO 7a).
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

code_src <- "PMID:5551034"

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(14L, 6L)), snap[5, 1] == "1) Brain^6", snap[10, 1] == "5) Muscle^4", snap[12, 1] == "70 kg man",
          grepl("^\\* OMR/kg OW", snap[13, 1]), grepl("^† Metabolic rate", snap[14, 1]))
rws <- 5:12
lab <- snap[rws, 1]
nm <- function(x) suppressWarnings(as.numeric(gsub("[,*†]", "", gsub("—", "", x))))
sp <- species_cols(rep("Man", length(rws)))
final.dataframe <- data.frame(
  printed_row = rws,
  row_type = c("organ", "organ", "organ", "organ", "total_organs_1_4", "organ", "total_organs_1_5", "whole_body"),
  row_number_printed = ifelse(grepl("^[0-9]\\)", lab), sub("^([0-9]\\)).*$", "\\1", lab), NA_character_),
  organ_as_published = trimws(sub("\\^[0-9]+$", "", sub("^[0-9]\\)\\s*", "", lab))),
  ref_key = ifelse(grepl("\\^[0-9]+$", lab), sub("^.*\\^([0-9]+)$", "\\1", lab), NA_character_),
  sp,
  VO2_ml_100g_min_printed = snap[rws, 2], rate_kcal_kg_OW_day_printed = snap[rws, 3], weight_kg_printed = snap[rws, 4],
  OMR_kcal_day_printed = snap[rws, 5], pct_BMR_printed = snap[rws, 6], stringsAsFactors = FALSE)
f <- final.dataframe
final.dataframe$VO2_ml_100g_min <- nm(f$VO2_ml_100g_min_printed)
final.dataframe$VO2.umol_100g_min <- round(final.dataframe$VO2_ml_100g_min * UMOL_PER_ML_O2, 2)
final.dataframe$rate_kcal_kg_OW_day <- nm(f$rate_kcal_kg_OW_day_printed)
final.dataframe$rate_mark <- ifelse(grepl("\\*", f$rate_kcal_kg_OW_day_printed), "*", NA_character_)
final.dataframe$weight_kg <- nm(f$weight_kg_printed)
final.dataframe$weight_g <- final.dataframe$weight_kg * 1000
final.dataframe$weight_mark <- ifelse(grepl("†", f$weight_kg_printed), "†", NA_character_)
final.dataframe$OMR_kcal_day <- nm(f$OMR_kcal_day_printed)
final.dataframe$pct_BMR <- nm(f$pct_BMR_printed)
final.dataframe$unit_as_printed <- "VO2 ml/min/100 gm; rate kcal/kg OW/day; weight kg; OMR kcal/day; % BMR"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$row_type == "whole_body"] <- "printed 25.5 kcal/kg/day; 1,780/70 = 25.4"
final.dataframe$note[final.dataframe$organ_as_published == "Kidney"] <- "% BMR printed 7.1; 116/1,780 = 6.5% (the printed total 66.7 carries the 7.1)"
final.dataframe$note[final.dataframe$organ_as_published == "Muscle"] <- "rate 17.6 kcal/kg/day vs VO2 0.26 ml/min/100 g x 70.56 = 18.3; superscript mark of this row is faint in the scan (read as 4)"
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 8L, final.dataframe$OMR_kcal_day[8] == 1780)

## ---- table checks (HOWTO section 7a) ---------------------------------------------
## (a) rate = VO2 x 10 x 1,440 / 1,000 x 4.9 = VO2 x 70.56 (footnote dagger), tolerance
## = half a unit of the printed VO2 x 70.56 + half a unit of the rate; (b) OMR = rate x
## weight (half-unit of each printed factor + half unit of the product); (c) sums of
## OMR / weight / %; (d) % BMR = 100 x OMR / 1,780 (one unit of the last decimal); (e)
## 70 kg man rate = 1,780 / 70; (f) Total 1-4 rate = 1,177 / 3.60 (footnote asterisk).
d <- final.dataframe; o4 <- d[d$row_type == "organ", ][1:4, ]; mu <- d[d$organ_as_published == "Muscle", ]
t14 <- d[d$row_type == "total_organs_1_4", ]; t15 <- d[d$row_type == "total_organs_1_5", ]; man <- d[d$row_type == "whole_body", ]
org <- d[d$row_type == "organ", ]
table_checks <- rbind(
  do.call(rbind, lapply(seq_len(nrow(org)), function(i)
    chk(paste0("rate_from_VO2_", i), paste0(org$organ_as_published[i], ": VO2 x 70.56 vs printed rate kcal/kg OW/day"), org$VO2_ml_100g_min[i] * 70.56, org$rate_kcal_kg_OW_day[i],
        hu(org$VO2_ml_100g_min_printed[i]) * 70.56 + 0.5))),
  do.call(rbind, lapply(seq_len(nrow(org)), function(i)
    chk(paste0("OMR_from_rate_", i), paste0(org$organ_as_published[i], ": rate x weight vs printed OMR kcal/day"), org$rate_kcal_kg_OW_day[i] * org$weight_kg[i], org$OMR_kcal_day[i],
        hu(org$rate_kcal_kg_OW_day_printed[i]) * org$weight_kg[i] + hu(org$weight_kg_printed[i]) * org$rate_kcal_kg_OW_day[i] + 0.5))),
  chk("sum_OMR_1_4", "sum of OMR of organs 1-4 vs printed Total 1-4", sum(o4$OMR_kcal_day), t14$OMR_kcal_day, 0.5 * 5),
  chk("sum_weight_1_4", "sum of weights of organs 1-4 vs printed Total 1-4 (kg)", sum(o4$weight_kg), t14$weight_kg, 0.5 * 5 * 0.01),
  chk("rate_total_1_4", "printed Total 1-4 OMR / printed Total 1-4 weight vs printed 327 (footnote asterisk)", t14$OMR_kcal_day / t14$weight_kg, t14$rate_kcal_kg_OW_day, 0.5 + 0.5 * t14$OMR_kcal_day / t14$weight_kg / 3.6 * 0.02),
  chk("sum_OMR_1_5", "printed Total 1-4 + Muscle OMR vs printed Total 1-5", t14$OMR_kcal_day + mu$OMR_kcal_day, t15$OMR_kcal_day, 1),
  chk("sum_OMR_1_5_rows", "sum of the five organ OMR vs printed Total 1-5", sum(org$OMR_kcal_day), t15$OMR_kcal_day, 0.5 * 6),
  do.call(rbind, lapply(seq_len(nrow(d) - 1L), function(i)
    chk(paste0("pct_", d$row_type[i], "_", i), paste0(d$organ_as_published[i], ": 100 x printed OMR / 1,780 vs printed % BMR"), 100 * d$OMR_kcal_day[i] / man$OMR_kcal_day, d$pct_BMR[i], 0.1,
        if (d$organ_as_published[i] == "Kidney") "116/1,780 = 6.5; printed 7.1" else NA_character_))),
  chk("sum_pct_1_4", "sum of the printed % of organs 1-4 vs printed Total 1-4 %", sum(o4$pct_BMR), t14$pct_BMR, 0.2),
  chk("sum_pct_1_5", "printed Total 1-4 % + Muscle % vs printed Total 1-5 %", t14$pct_BMR + mu$pct_BMR, t15$pct_BMR, 0.2,
      "66.7 + 28.1 = 94.8; printed 94.2 = 1,677/1,780: the printed Total 1-4 % (66.7) and the kidney % (7.1) disagree with the OMR column"),
  chk("rate_70kg_man", "printed 1,780 kcal/day / 70 kg vs printed 25.5 kcal/kg/day", man$OMR_kcal_day / 70, man$rate_kcal_kg_OW_day, 0.05)
)
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
