# Elia__1997_TABLE8.R -------------------------------------------------------------
#
# Elia (1997), "Tissue distribution and energetics in weight loss and undernutrition", in Kinney &
# Tucker (Eds.), Physiology, Stress, and Malnutrition: Functional Correlates, Nutritional Intervention,
# Lippincott-Raven, pp. 383-411.  TABLE 8 "Energy expenditure of the whole body, FFM brain, and FFM
# (FFM - brain) other than brain of a normal child and a marasmic child before nutritional therapy and
# at peak hypermetabolism during recovery", p. 401.
# SECONDARY / MODEL table: the brain rate (225 kcal/kg/day in the normal child; assumed ranges in the
# marasmic child) is an ASSUMPTION of the author (footnote a), the weights are his scenario values.
#
# Reads the frozen snapshot (Elia__1997_TABLE8_snapshot.csv) and:
#   - one analysis row per printed brain-rate line (6): Normal (1), Marasmus before treatment (3 stacked
#     assumptions), Marasmus during treatment at peak hypermetabolism (2 stacked assumptions); block-level
#     cells printed once per scenario (weights, body kcal/day, body kcal/kg/day) are repeated on each line;
#   - splits "302.5 (-45%)" into the printed value and the printed % change (relative to the normal child);
#   - adds derived columns (labelled _derived): Brain_Mass.mg, body_mass.g, CMRO2_derived.umol_100g_min
#     (kcal/kg/day -> umol O2/100 g/min, 4.9 kcal per litre O2, 44.64 umol per mL O2; 4.9 NOT printed),
#     brain_share_body_kcal_pct_derived (100 x brain kcal/day / body kcal/day);
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

isbn <- "9780397587636"     # Kinney & Tucker (Eds.) 1997, Lippincott-Raven (ISBN-10 0397587635)

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(16L, 11L)), snap[1, 1] == "TABLE 8", snap[6, 1] == "Normal",
          startsWith(snap[15, 1], "These calculations"), startsWith(snap[16, 1], "^a "))
data_rows <- 6:14
starts <- data_rows[nzchar(snap[data_rows, 2])]
stopifnot(identical(starts, c(6L, 8L, 11L)))
ends <- c(starts[-1] - 1L, max(data_rows))

split_cell <- function(x) list(value = num_of(sub("\\s*\\(.*$", "", x)),
                               pct = ifelse(grepl("\\(", x), num_of(sub("^.*\\(([-+]?[0-9.]+)%\\).*$", "\\1", x)), NA_real_))
fat <- regmatches(snap[16, 1], gregexpr("\\+{1,3}, [0-9.]+% fat", snap[16, 1]))[[1]]
fat_pct <- setNames(as.numeric(sub("^.*, ([0-9.]+)% fat$", "\\1", fat)), sub(",.*$", "", fat))
stopifnot(identical(names(fat_pct), c("+", "++", "+++")))

scen_id <- c("normal", "marasmus_before_treatment", "marasmus_peak_hypermetabolism")
sp_pub  <- c("normal child", "marasmic child", "marasmic child")
out <- list()
for (b in seq_along(starts)) {
  rr <- starts[b]:ends[b]
  label <- oneline(paste(snap[rr, 1], collapse = " "))
  var_rows <- rr[nzchar(snap[rr, 8])]
  w <- snap[starts[b], 2:5]
  mark <- ifelse(grepl("\\^", w[1]), sub("^.*\\^", "", w[1]), NA_character_)
  body_kg <- num_of(sub("\\^.*$", "", w[1]))
  bk <- split_cell(snap[starts[b], 6]); bkk <- split_cell(snap[starts[b], 7])
  for (v in seq_along(var_rows)) {
    r <- var_rows[v]
    br <- split_cell(snap[r, 8]); bd <- split_cell(snap[r, 9]); fd <- split_cell(snap[r, 10]); fk <- split_cell(snap[r, 11])
    out[[length(out) + 1L]] <- data.frame(
      printed_row = r, scenario_id = scen_id[b], scenario_as_published = label, variant_in_scenario = v,
      species_as_published = sp_pub[b], age_months = 12,
      body_weight_kg = body_kg, body_weight_footnote_mark = mark, fat_pct_per_footnote = unname(fat_pct[mark]),
      ffm_kg = num_of(w[2]), brain_kg = num_of(w[3]), ffm_minus_brain_kg = num_of(w[4]),
      body_kcal_day_printed = snap[starts[b], 6], body_kcal_day = bk$value, body_kcal_day_pct_change = bk$pct,
      body_kcal_kg_day_printed = snap[starts[b], 7], body_kcal_kg_day = bkk$value, body_kcal_kg_day_pct_change = bkk$pct,
      brain_rate_kcal_kg_day_printed = snap[r, 8], brain_rate_kcal_kg_day = br$value, brain_rate_pct_change = br$pct,
      brain_kcal_day_printed = snap[r, 9], brain_kcal_day = bd$value, brain_kcal_day_pct_change = bd$pct,
      ffm_minus_brain_kcal_day_printed = snap[r, 10], ffm_minus_brain_kcal_day = fd$value, ffm_minus_brain_kcal_day_pct_change = fd$pct,
      ffm_minus_brain_kcal_kg_day_printed = snap[r, 11], ffm_minus_brain_kcal_kg_day = fk$value, ffm_minus_brain_kcal_kg_day_pct_change = fk$pct,
      stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, out)
final.dataframe$species <- harmonise(final.dataframe$species_as_published)
final.dataframe$body_mass.g <- final.dataframe$body_weight_kg * 1000
final.dataframe$Brain_Mass.mg <- final.dataframe$brain_kg * 1e6
final.dataframe$CMRO2_derived.umol_100g_min <- kcal_kg_day_to_umol_100g_min(final.dataframe$brain_rate_kcal_kg_day)
final.dataframe$brain_share_body_kcal_pct_derived <- 100 * final.dataframe$brain_kcal_day / final.dataframe$body_kcal_day
final.dataframe$note <- "Model scenario, not a measurement: brain rate assumed (footnote a: 225 kcal/kg/day for the normal brain, ranges for marasmus). CMRO2_derived and brain_share are computed here, not printed."
stopifnot(nrow(final.dataframe) == 6L)

## ---- table checks (HOWTO section 7a) -------------------------------------------
fd <- final.dataframe; nrm <- fd[fd$scenario_id == "normal", ]
ck <- list()
for (i in seq_len(nrow(fd))) {
  id <- paste0(fd$scenario_id[i], "_v", fd$variant_in_scenario[i])
  ck[[length(ck) + 1L]] <- chk(paste0("brain_kcal_day_", id), paste0(id, ": brain kcal/kg/day x brain kg vs printed brain kcal/day  [(7) x (3)]"),
        fd$brain_rate_kcal_kg_day[i] * fd$brain_kg[i], fd$brain_kcal_day[i], 0.05)
  ck[[length(ck) + 1L]] <- chk(paste0("ffm_minus_brain_kcal_day_", id), paste0(id, ": body kcal/day - brain kcal/day vs printed FFM-brain kcal/day  [(5) - (8)]"),
        fd$body_kcal_day[i] - fd$brain_kcal_day[i], fd$ffm_minus_brain_kcal_day[i], 0.05)
  ck[[length(ck) + 1L]] <- chk(paste0("ffm_minus_brain_kcal_kg_day_", id), paste0(id, ": FFM-brain kcal/day / FFM-brain kg vs printed kcal/kg/day  [(9) / (4)]"),
        fd$ffm_minus_brain_kcal_day[i] / fd$ffm_minus_brain_kg[i], fd$ffm_minus_brain_kcal_kg_day[i], 0.05 + 0.05 / fd$ffm_minus_brain_kg[i],
        "tolerance = half a unit of the printed decimal plus the rounding of the printed FFM-brain kcal/day")
  pctcol <- c(brain_rate_kcal_kg_day = "brain_rate_pct_change", brain_kcal_day = "brain_kcal_day_pct_change",
              ffm_minus_brain_kcal_day = "ffm_minus_brain_kcal_day_pct_change",
              ffm_minus_brain_kcal_kg_day = "ffm_minus_brain_kcal_kg_day_pct_change")
  for (m in names(pctcol)) {
    if (fd$scenario_id[i] != "normal")
      ck[[length(ck) + 1L]] <- chk(paste0("pct_change_", m, "_", id), paste0(id, ": 100 x (", m, " / normal child value - 1) vs printed % change"),
            100 * (fd[[m]][i] / nrm[[m]][1] - 1), fd[[pctcol[[m]]]][i], 0.5,
            "tolerance = half a unit of the printed integer percentage")
  }
}
for (b in unique(fd$scenario_id)) {
  d <- fd[fd$scenario_id == b, ][1, ]
  ck[[length(ck) + 1L]] <- chk(paste0("body_kcal_kg_day_", b), paste0(b, ": body kcal/day / body kg vs printed body kcal/kg/day"), d$body_kcal_day / d$body_weight_kg, d$body_kcal_kg_day, 0.05)
  ck[[length(ck) + 1L]] <- chk(paste0("ffm_from_fat_", b), paste0(b, ": body kg x (1 - fat%/100) vs printed FFM kg (fat % from footnote a)"), d$body_weight_kg * (1 - d$fat_pct_per_footnote / 100), d$ffm_kg, 0.005)
  ck[[length(ck) + 1L]] <- chk(paste0("ffm_minus_brain_kg_", b), paste0(b, ": FFM kg - brain kg vs printed FFM-brain kg"), d$ffm_kg - d$brain_kg, d$ffm_minus_brain_kg, 0.005)
  if (b != "normal") {
    ck[[length(ck) + 1L]] <- chk(paste0("pct_change_body_kcal_day_", b), paste0(b, ": 100 x (body kcal/day / normal - 1) vs printed % change"), 100 * (d$body_kcal_day / nrm$body_kcal_day[1] - 1), d$body_kcal_day_pct_change, 0.5)
    ck[[length(ck) + 1L]] <- chk(paste0("pct_change_body_kcal_kg_day_", b), paste0(b, ": 100 x (body kcal/kg/day / normal - 1) vs printed % change"), 100 * (d$body_kcal_kg_day / nrm$body_kcal_kg_day[1] - 1), d$body_kcal_kg_day_pct_change, 0.5)
  }
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
