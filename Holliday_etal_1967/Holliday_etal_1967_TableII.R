# Holliday_etal_1967_TableII.R -------------------------------------------------
#
# Holliday, Potter, Jarrah & Bearg (1967), Pediatric Research 1: 185-195. Table II "Organ
# metabolic rate, OMR, cal/day compared to whole body BMR for a 10 kg infant and a 70 kg
# adult", p. 189. SECONDARY compilation: each organ rate is taken from a cited primary
# (Brain [21] Kety & Schmidt 1948; Heart [39] Rowe et al. 1959; Kidney [11] Crosley et al.
# 1961; Liver (splanchnic) [6] Brauer 1963; Lung estimated from in-vitro QO2).
#
# Reads the frozen snapshot (Holliday_etal_1967_TableII_snapshot.csv) and:
#   - writes one analysis row per printed row and age group (organs, "Total derived from
#     5 organs", "Total BMR") = 7 rows x 2 groups = 14 rows (printed layout: infant and
#     adult side by side; here long);
#   - splits the printed reference "[21]" into ref_key (join to reference_tables/..._references.csv);
#   - keeps the printed "cal" (the text shows it means kcal: "BMR ... 25 cal/kg/day") in the
#     *_printed columns and names the numeric columns kcal; a parenthesised rate "(200)" is
#     an estimate (rate_is_estimate = TRUE);
#   - converts the organ rate to the project unit: kcal/kg/day -> mL O2/100 g/min at the
#     paper's own factor 4.9 kcal/L O2 (text p. 188): / 4.9 / 1.44 / 10 = / 70.56; then
#     umol O2 = mL x 44.64;
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

code_src <- "10.1203/00006450-196705000-00005"

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(11L, 9L)), snap[4, 1] == "Brain [21]", snap[8, 1] == "Lung (estimated)",
          snap[10, 1] == "Total derived from 5 organs", snap[11, 1] == "Total BMR", snap[2, 2] == "10 kg infant", snap[2, 6] == "70 kg adult")
grp <- data.frame(group = c("10 kg infant", "70 kg adult"), body_kg = c(10, 70),
                  c_rate = c(2L, 6L), c_w = c(3L, 7L), c_tot = c(4L, 8L), c_pct = c(5L, 9L), stringsAsFactors = FALSE)
rws <- c(4:8, 10, 11)
num <- function(x) suppressWarnings(as.numeric(gsub("[(),]", "", x)))
final.dataframe <- do.call(rbind, lapply(seq_len(nrow(grp)), function(g) do.call(rbind, lapply(rws, function(r) {
  lab <- snap[r, 1]
  data.frame(printed_row = r,
             row_type = ifelse(r %in% 4:8, "organ", ifelse(r == 10, "total_derived_5_organs", "total_BMR")),
             organ_as_published = trimws(sub("\\s*\\[[0-9]+\\]$", "", lab)),
             ref_key = ifelse(grepl("\\[[0-9]+\\]$", lab), sub("^.*(\\[[0-9]+\\])$", "\\1", lab), NA_character_),
             group_as_published = grp$group[g], body_mass_kg = grp$body_kg[g],
             OMR_per_kg_printed = snap[r, grp$c_rate[g]], weight_kg_printed = snap[r, grp$c_w[g]],
             OMR_total_printed = snap[r, grp$c_tot[g]], pct_BMR_printed = snap[r, grp$c_pct[g]],
             stringsAsFactors = FALSE)
}))))
sp <- species_cols(rep("human", nrow(final.dataframe)))
final.dataframe <- cbind(final.dataframe[, 1:5], sp, final.dataframe[, 6:10])
f <- final.dataframe
final.dataframe$rate_is_estimate <- grepl("^\\(", f$OMR_per_kg_printed)
final.dataframe$OMR_kcal_kg_day <- num(f$OMR_per_kg_printed)
final.dataframe$weight_kg       <- num(f$weight_kg_printed)
final.dataframe$weight_g        <- final.dataframe$weight_kg * 1000
final.dataframe$OMR_kcal_day    <- num(f$OMR_total_printed)
final.dataframe$pct_BMR         <- num(f$pct_BMR_printed)
final.dataframe$O2_ml_100g_min  <- round(final.dataframe$OMR_kcal_kg_day / 70.56, 4)
final.dataframe$O2_umol_100g_min <- round(final.dataframe$O2_ml_100g_min * UMOL_PER_ML_O2, 2)
final.dataframe$unit_as_printed <- "OMR/kg cal/kg/day; weight kg; OMR cal/organ/day (cal = kcal in the text); % of whole-body BMR"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$rate_is_estimate] <- "rate printed in parentheses: lung rate is an estimate, not a measurement"
i <- final.dataframe$organ_as_published == "Lung (estimated)" & final.dataframe$group_as_published == "10 kg infant"
final.dataframe$note[i] <- paste0(final.dataframe$note[i], "; weight printed '12' without a decimal point (kg); the printed total weight 1.46 kg implies .12; kept as printed")
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 14L)

## ---- table checks (HOWTO section 7a) ---------------------------------------------
## (a) organ OMR = rate x weight (tolerance: half a unit of each printed factor + half a unit
## of the product); (b) sum of the 5 organ weights / OMR / % = printed totals (half a unit
## per summed cell); (c) printed % = OMR / total BMR (one unit, HOWTO 7a); (d) text p. 188
## ("BMR of the whole body is 25 cal/kg/day in adults and 56 cal/kg/day in infants").
d <- final.dataframe; chks <- list()
for (g in grp$group) {
  o <- d[d$group_as_published == g & d$row_type == "organ", ]
  tot <- d[d$group_as_published == g & d$row_type == "total_derived_5_organs", ]
  bmr <- d[d$group_as_published == g & d$row_type == "total_BMR", ]
  tag <- ifelse(g == "10 kg infant", "inf", "adu")
  for (k in seq_len(nrow(o)))
    chks[[length(chks) + 1]] <- chk(paste0("OMR_", tag, "_", k), paste0(g, ", ", o$organ_as_published[k], ": rate x weight vs printed OMR cal/organ/day"),
        o$OMR_kcal_kg_day[k] * o$weight_kg[k], o$OMR_kcal_day[k],
        hu(o$weight_kg_printed[k]) * o$OMR_kcal_kg_day[k] + 0.5 * o$weight_kg[k] + 0.5,
        if (g == "10 kg infant" && o$weight_kg_printed[k] == "12") "printed lung weight '12' (kg) vs .12 intended: the product is 100x the printed 24" else NA_character_)
  chks[[length(chks) + 1]] <- chk(paste0("sum_weight_", tag), paste0(g, ": sum of the 5 organ weights (kg) vs printed total"), sum(o$weight_kg), tot$weight_kg, sum(sapply(o$weight_kg_printed, hu)) + hu(tot$weight_kg_printed),
        if (g == "10 kg infant") "uses the lung weight as printed (12); with .12 the sum is 1.46" else NA_character_)
  chks[[length(chks) + 1]] <- chk(paste0("sum_OMR_", tag), paste0(g, ": sum of the 5 organ OMR vs printed total derived"), sum(o$OMR_kcal_day), tot$OMR_kcal_day, 0.5 * (nrow(o) + 1))
  chks[[length(chks) + 1]] <- chk(paste0("sum_pct_", tag), paste0(g, ": sum of the 5 printed organ % vs printed total %"), sum(o$pct_BMR), tot$pct_BMR, 0.5 * (nrow(o) + 1))
  for (k in seq_len(nrow(o)))
    chks[[length(chks) + 1]] <- chk(paste0("pct_", tag, "_", k), paste0(g, ", ", o$organ_as_published[k], ": 100 x OMR / total BMR vs printed %"), 100 * o$OMR_kcal_day[k] / bmr$OMR_kcal_day, o$pct_BMR[k], 1)
  chks[[length(chks) + 1]] <- chk(paste0("pct_total_", tag), paste0(g, ": 100 x printed total derived OMR / total BMR vs printed total %"), 100 * tot$OMR_kcal_day / bmr$OMR_kcal_day, tot$pct_BMR, 1,
        if (g == "70 kg adult") "1385/1780 = 77.8%, printed 79 (which is the sum of the printed organ %)" else NA_character_)
  chks[[length(chks) + 1]] <- chk(paste0("BMR_per_kg_", tag), paste0(g, ": total BMR / body mass vs text p. 188 (adult 25, infant 56 cal/kg/day)"), bmr$OMR_kcal_day / bmr$body_mass_kg, ifelse(g == "10 kg infant", 56, 25), 0.5,
        "text relation (Postulate 2 discussion), not a table cell")
}
table_checks <- do.call(rbind, chks)
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
