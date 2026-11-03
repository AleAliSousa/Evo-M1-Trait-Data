# Meguro_etal_1999_Table2.R ---------------------------------------------------
#
# Meguro et al. (1999), Brain 122: 1519-1531. Table 2 "Regional CMRglc values in
# the 19 brain regions in each group (n = 3 per group; analysis II) at the four
# time points", p. 1525. Papio anubis baboons, PET under light anaesthesia/
# analgesia (phencyclidine 7 µg/kg/min i.v. + N2O:O2 2:1) with muscle relaxation.
#
# Reads the frozen snapshot (Meguro_etal_1999_Table2_snapshot.csv) and:
#   - writes one analysis row per printed mean (SD) cell: 19 regions x 2 groups
#     (RH = bilateral rhinal-cortex lesion, SH = sham) x 4 time points
#     (Baseline = before surgery; Day 30, 45, 80 after surgery) = 152 rows;
#   - carries the region name down to the SH line, and keeps the printed ANOVA
#     and post hoc cells on every row of the region;
#   - parses "mean (SD)"; a malformed printed SD ("(4.)") is kept and parsed as NA;
#   - converts mg glucose/100 g/min to the project unit µmol/100 g/min:
#     x 1000 / 180.16 (glucose molar mass, g/mol) = x 5.5506.
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

## ---- cell helpers: a printed cell "57 ± 5^b,c" / "- 9.2 ± 9.84" / "34.1**" ---------
## is split into its printed mean lexeme, printed dispersion lexeme and footnote
## marks; the numbers are parsed from those lexemes. Nothing is repaired.
marks_of <- function(x) {
  m <- ifelse(grepl("\\^[a-z](,[a-z])*$", x), sub("^.*\\^([a-z](,[a-z])*)$", "\\1", x),
       ifelse(grepl("\\*+$", x), sub("^.*?(\\*+)$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*±.*$", "", s)) }
disp_lexeme <- function(x) { s <- strip_marks(x); ifelse(grepl("±", s), trimws(sub("^.*±\\s*", "", s)), NA_character_) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 9.2" -> -9.2, "+ 7.4" -> 7.4

long_cells <- function(snap, rows, arms, section, species, structure = snap[rows, 1]) {
  out <- do.call(rbind, lapply(seq_len(nrow(arms)), function(k) {
    cell <- snap[rows, arms$col[k]]
    data.frame(printed_row = rows, structure_order = seq_along(rows),
               section_as_published = section[rows],
               structure_as_published = gsub("\n", " ", structure, fixed = TRUE),
               group_as_published = arms$group[k], column_as_published = arms$column[k],
               arm_id = arms$arm_id[k], n = arms$n[k],
               cell_as_printed = cell, mean_printed = mean_lexeme(cell),
               dispersion_printed = disp_lexeme(cell), dispersion_type = arms$disp_type[k],
               footnote_marks = marks_of(cell), measure = arms$measure[k],
               unit_as_printed = arms$unit[k], stringsAsFactors = FALSE)
  }))
  out$value_numeric        <- num_of(out$mean_printed)
  out$dispersion_numeric   <- num_of(out$dispersion_printed)
  out$CMRglc.umol_100g_min <- ifelse(out$measure == "CMRglc", out$value_numeric, NA_real_)
  out$species_as_published <- species
  out$note <- NA_character_
  out <- out[order(out$structure_order, match(out$arm_id, arms$arm_id)), ]
  rownames(out) <- NULL
  out
}


MG_TO_UMOL <- 1000 / 180.16     # µmol glucose per mg

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(42L, 9L)), snap[2, 1] == "Region", snap[2, 2] == "Group",
          identical(snap[3, 8:9], c("Day 30", "Day 4")))
rows <- 4:41
region <- snap[rows, 1]; for (i in seq_along(region)) if (!nzchar(region[i])) region[i] <- region[i - 1]
anova  <- snap[rows, 7]; ph30 <- snap[rows, 8]; ph4 <- snap[rows, 9]
for (i in seq_along(rows)) if (snap[rows[i], 2] == "SH") { anova[i] <- anova[i - 1]; ph30[i] <- ph30[i - 1]; ph4[i] <- ph4[i - 1] }
times <- c("Baseline", "Day 30", "Day 45", "Day 80")
final.dataframe <- do.call(rbind, lapply(seq_along(rows), function(i) {
  g <- snap[rows[i], 2]
  do.call(rbind, lapply(1:4, function(k) {
    cell <- snap[rows[i], 2 + k]
    data.frame(printed_row = rows[i], structure_order = ceiling(i / 2),
               structure_as_published = region[i], group_as_published = g,
               column_as_published = gsub("\n", " ", snap[2, 2 + k], fixed = TRUE),
               arm_id = paste0(g, "_", tolower(gsub(" ", "", times[k]))),
               surgery = ifelse(g == "RH", "bilateral neurotoxic rhinal-cortex lesion", "sham operation"),
               time_point = times[k], pre_or_post_surgery = ifelse(k == 1, "pre-surgery", "post-surgery"),
               n = 3L, cell_as_printed = cell,
               mean_printed = sub("^([0-9.]+) \\(.*$", "\\1", cell),
               dispersion_printed = sub("^.*\\((.*)\\)$", "\\1", cell),
               dispersion_type = "SD", measure = "CMRglc", unit_as_printed = "mg/100 g/min",
               anova_as_printed = anova[i], posthoc_day30_as_printed = ph30[i], posthoc_day4_as_printed = ph4[i],
               stringsAsFactors = FALSE)
  }))
}))
final.dataframe$value_numeric      <- suppressWarnings(as.numeric(final.dataframe$mean_printed))
final.dataframe$dispersion_numeric <- suppressWarnings(as.numeric(sub("\\.$", "", final.dataframe$dispersion_printed)))
final.dataframe$dispersion_numeric[!grepl("^[0-9]+\\.[0-9]+$", final.dataframe$dispersion_printed)] <- NA_real_
final.dataframe$CMRglc.mg_100g_min   <- final.dataframe$value_numeric
final.dataframe$CMRglc.umol_100g_min <- round(final.dataframe$value_numeric * MG_TO_UMOL, 2)
final.dataframe$SD.umol_100g_min     <- round(final.dataframe$dispersion_numeric * MG_TO_UMOL, 2)
final.dataframe$species_as_published <- "Papio anubis"
final.dataframe$note <- NA_character_
bad_sd <- !grepl("^[0-9]+\\.[0-9]+$", final.dataframe$dispersion_printed)
final.dataframe$note[bad_sd] <- "SD printed as '(4.)': a digit is missing in the print; dispersion set to NA."
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 152L, !anyNA(final.dataframe$value_numeric), sum(bad_sd) == 1L)

## ---- table checks (HOWTO section 7a) ------------------------------------------
## No totals are printed. The RESULTS text allows: (1) 19 regions; (2) "the mean
## CMRglc values were consistently lower in the RH than the SH group
## postoperatively, whatever the time point and region" -> count post-operative
## cells where RH >= SH (expected 0); (3) baseline: "no significant difference
## ... except for the thalamus where the CMRglc was slightly lower in the RH"
## -> the thalamus baseline RH < SH. A malformed SD cell is not evaluable.

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}


w <- reshape(final.dataframe[, c("structure_order", "structure_as_published", "group_as_published", "time_point", "value_numeric")],
             idvar = c("structure_order", "structure_as_published", "time_point"), timevar = "group_as_published", direction = "wide")
post <- w[w$time_point != "Baseline", ]
viol <- post[post$value_numeric.RH >= post$value_numeric.SH, ]
thal <- w[w$structure_as_published == "Thalamus" & w$time_point == "Baseline", ]
table_checks <- rbind(
  chk("n_regions", "distinct regions vs Table 2 title '19 brain regions'", length(unique(final.dataframe$structure_as_published)), 19, 0),
  chk("rh_lower_postop", "post-operative region x time cells with RH >= SH (RESULTS: 'consistently lower in the RH than the SH group postoperatively')",
      nrow(viol), 0, 0, if (nrow(viol)) paste("exceptions:", paste(viol$structure_as_published, viol$time_point, collapse = "; ")) else NA_character_),
  chk("thalamus_baseline_rh_lower", "Thalamus baseline RH - SH < 0 (RESULTS: slightly lower in RH); observed = 1 if RH < SH",
      as.numeric(thal$value_numeric.RH < thal$value_numeric.SH), 1, 0),
  chk("malformed_sd", "SD cells not of the form d.d", sum(bad_sd), 0, 0, "Anterior cingulate, SH, Day 30 prints '(4.)'")
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

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived exactly as the registry formula would
## build it (DOI with "/" percent-encoded, "_", item locus) and the README says
## the item awaits registration; the registry stays the authority.
doi <- "10.1093/brain/122.8.1519"
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub("/", "%2F", doi, fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
