# Aschoff__1971_Text.R ---------------------------------------------------------
#
# Aschoff (1971), Temperaturregulation (Physiologie des Menschen Bd 2), pp. 44-45.
# CONSTRUCTED text-derived item: values printed in Abb. 1 (a figure with printed numbers:
# share of heat production at rest / at work and share of body weight for brain, thoracic +
# abdominal viscera, skin + muscle, remainder; shading legend in cal/100 g/min) and the
# percentages quoted in the running text of Orte der Waermebildung (p. 44) and p. 45.
# SECONDARY: textbook figure, "aus Aschoff u. Wever, Naturwissenschaften 45 (1958) 477";
# the text cites [1] (bibliography not part of the scanned excerpt).
#
# Reads the constructed snapshot (Aschoff__1971_Text_snapshot.csv) and parses the printed
# values; derives `variable` (a controlled label) and numeric value; no unit conversion is
# needed (all values are % or cal/100 g/min or cm-1). Table checks: Abb. 1 columns add to
# 100; text statements agree with Abb. 1; Abb. 1 vs Tabelle 1 (analysis CSV of this folder).
# No value is typed in this script.

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

code_src <- "ISBN:9783541051816"   # chapter has no DOI: ISBN-13 of the book (Physiologie des Menschen Bd. 2, Urban & Schwarzenberg 1971); registry col C must match

snap <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(identical(dim(snap), c(29L, 10L)), identical(names(snap)[1:5], c("text_row", "page", "location", "passage_as_printed", "value_printed")))
snap$value_numeric <- suppressWarnings(as.numeric(sub(",", ".", gsub("[^0-9,]", "", snap$value_printed))))
snap$state_as_printed <- gsub("\n", " ", snap$state_as_printed, fixed = TRUE)
snap$region_as_printed <- gsub("\n", " ", snap$region_as_printed, fixed = TRUE)
snap$bound_as_printed <- ifelse(grepl("über", snap$units_printed), "lower bound (über)", ifelse(grepl("etwa|rund", snap$units_printed), "approximate (etwa/rund)", NA_character_))
snap$units_clean <- trimws(sub("\\s*\\(.*\\)$", "", snap$units_printed))
snap$variable <- with(snap, ifelse(grepl("^Abb. 1, column", location) & grepl("in Ruhe", location), "heat_share_pct_rest",
                    ifelse(grepl("^Abb. 1, column", location) & grepl("bei Arbeit", location), "heat_share_pct_work",
                    ifelse(grepl("^Abb. 1, column", location), "weight_share_pct",
                    ifelse(grepl("legend", location), "shading_class_cal_100g_min",
                    ifelse(grepl("Oberfläche", location), "surface_to_volume_cm-1",
                    ifelse(grepl("caption", location) & units_clean == "kg", "reference_body_mass_kg",
                    ifelse(grepl("caption", location), "reference_whole_body_O2_ml_min",
                    ifelse(grepl("Wärme|Umsatz|Anteil", quantity_as_printed), "text_share_heat_or_turnover_pct", "text_share_body_mass_pct")))))))))
sp <- species_cols(rep("human", nrow(snap)))
final.dataframe <- data.frame(snap[, c("text_row", "page", "location", "passage_as_printed", "value_printed")], sp,
                              variable = snap$variable, value_numeric = snap$value_numeric, units_as_printed = snap$units_printed,
                              bound_as_printed = snap$bound_as_printed,
                              quantity_as_printed = snap$quantity_as_printed, state_as_printed = snap$state_as_printed,
                              region_as_printed = snap$region_as_printed, ref_key = snap$ref_key_printed,
                              stringsAsFactors = FALSE)
final.dataframe$ref_key[!nzchar(final.dataframe$ref_key)] <- NA_character_
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$variable == "surface_to_volume_cm-1"] <- "leader lines to body parts; the part is not named in print"
final.dataframe$note[final.dataframe$variable == "shading_class_cal_100g_min"] <- "legend of the shading classes in the figure, not an organ value"
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 29L, !anyNA(final.dataframe$value_numeric))

## ---- table checks (HOWTO section 7a) ---------------------------------------------
v <- function(var, region = NULL, loc = NULL) {
  i <- final.dataframe$variable == var
  if (!is.null(region)) i <- i & final.dataframe$region_as_printed == region
  x <- final.dataframe$value_numeric[i]; stopifnot(length(x) >= 1L); x
}
col_sum <- function(var) sum(v(var)[1:4])
rest <- final.dataframe$variable == "heat_share_pct_rest"; work <- final.dataframe$variable == "heat_share_pct_work"; wt <- final.dataframe$variable == "weight_share_pct"
table_checks <- rbind(
  chk("abb1_heat_rest_sum", "Abb. 1: heat share at rest, 4 rows, sums to 100", sum(final.dataframe$value_numeric[rest]), 100, 0.5 * 4),
  chk("abb1_heat_work_sum", "Abb. 1: heat share at work, 4 rows, sums to 100", sum(final.dataframe$value_numeric[work]), 100, 0.5 * 4),
  chk("abb1_weight_sum", "Abb. 1: body weight share, 4 rows, sums to 100", sum(final.dataframe$value_numeric[wt]), 100, 0.5 * 4),
  chk("text_8pct_vs_abb1", "text 'etwa 8% der Koerpermasse' (organs of high metabolism) vs Abb. 1 Gehirn + Brust/Bauch weight 2 + 6",
      final.dataframe$value_numeric[wt][1] + final.dataframe$value_numeric[wt][2], v("text_share_body_mass_pct")[1], 0.5),
  chk("text_70pct_vs_abb1", "text 'ueber 70%' of resting turnover vs Abb. 1 Gehirn + Brust/Bauch heat at rest 16 + 56 (lower bound: observed >= printed)",
      min(final.dataframe$value_numeric[rest][1] + final.dataframe$value_numeric[rest][2], v("text_share_heat_or_turnover_pct")[1]), v("text_share_heat_or_turnover_pct")[1], 0, "lower-bound statement; pass if the Abb. 1 sum is >= 70"),
  chk("text_52pct_vs_abb1", "text 'etwa 52%' of body weight (Schale) vs Abb. 1 Haut und Muskel weight", v("weight_share_pct", "Haut und Muskel"), v("text_share_body_mass_pct")[2], 0.5),
  chk("text_18pct_vs_abb1", "text 'rund 18%' of total heat (Schale) vs Abb. 1 Haut und Muskel heat at rest", v("heat_share_pct_rest", "Haut und Muskel"), v("text_share_heat_or_turnover_pct")[2], 0.5)
)
## cross-check against the Tabelle 1 analysis CSV of this folder (when built)
t1f <- file.path(folder, paste0(paper, "_Tabelle1.csv"))
if (file.exists(t1f)) {
  t1 <- read.csv(t1f, encoding = "UTF-8", stringsAsFactors = FALSE)
  o2 <- setNames(t1$O2_ml_organ_min, t1$organ_as_published); wg <- setNames(t1$weight_g, t1$organ_as_published)
  core <- c("Gehirn", "Lunge", "Herz", "Nieren", "Splanchnikus- gebiet")
  table_checks <- rbind(table_checks,
    chk("abb1_brain_heat_vs_tab1", "Abb. 1 Gehirn heat share at rest (16) vs Tabelle 1 Gehirn O2 ml/min / 270 (printed O2 share)", 100 * o2[["Gehirn"]] / 270, v("heat_share_pct_rest", "Gehirn"), 0.5,
        "Tabelle 1 O2 share used as a proxy for heat share (cal columns are consistent with O2 within 4.7-4.9 cal/ml)"),
    chk("abb1_brain_weight_vs_tab1", "Abb. 1 Gehirn weight share (2) vs Tabelle 1 1,350 g / 65 kg", 100 * wg[["Gehirn"]] / 65000, v("weight_share_pct", "Gehirn"), 0.5),
    chk("abb1_core_heat_vs_tab1", "Abb. 1 Gehirn + Brust/Bauch heat at rest (72) vs Tabelle 1 core organs (Gehirn, Lunge, Herz, Nieren, Splanchnikus) O2 / 270",
        100 * sum(o2[core]) / 270, v("heat_share_pct_rest")[1] + v("heat_share_pct_rest")[2], 0.5),
    chk("abb1_core_weight_vs_tab1", "Abb. 1 Gehirn + Brust/Bauch weight (8) vs Tabelle 1 core organs weight / 65 kg",
        100 * sum(wg[core]) / 65000, v("weight_share_pct")[1] + v("weight_share_pct")[2], 0.5),
    chk("abb1_skinmuscle_weight_vs_tab1", "Abb. 1 Haut und Muskel weight share (52) vs Tabelle 1 Haut + Muskel (5.000 + 27.000 g) / 65 kg",
        100 * (wg[["Haut"]] + wg[["Muskel"]]) / 65000, v("weight_share_pct", "Haut und Muskel"), 0.5,
        "Abb. 1 'Haut und Muskel' (52%) is larger than the two tabulated tissues (49.2%); not an arithmetic error, a different grouping")
  )
} else message(item_name, ": ", basename(t1f), " not found; Abb. 1 vs Tabelle 1 cross-checks skipped (build Tabelle 1 first)")
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
