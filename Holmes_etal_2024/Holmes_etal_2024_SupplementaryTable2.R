# Holmes_etal_2024_SupplementaryTable2.R -----------------------------------------
#
# Holmes, Honhar, Tinaz, ... Carson & Matuskey (2024). Synaptic loss and its
# association with symptom severity in Parkinson's disease.
# npj Parkinson's Disease 10:42. https://doi.org/10.1038/s41531-024-00655-9
# Supplementary Table 2 "BPND values across HC and PD groups. Reported values are
# Mean (SD)." (journal supplement 41531_2024_655_MOESM1_ESM.pdf, p. 2), plus the
# reference-region (centrum semiovale) VT and K1 printed only in the Methods text.
#
# Reads the two frozen sources written by
# Holmes_etal_2024_SupplementaryTable2_snapshot.R:
#   Holmes_etal_2024_SupplementaryTable2_snapshot.xlsx   (printed table layout)
#   Holmes_etal_2024_data_from_text_snapshot.csv         (Methods p. 7 passage)
# and does all the cleaning:
#   - splits the printed "mean (SD)" cells into numeric mean and SD;
#   - keeps the printed region labels, section (Primary/Secondary) and group
#     labels; one row per region x group (HC, PD), long format with a
#     `measure` column (BPND for the table; VT and K1 for the CSO text rows);
#   - carries the bold (= Bonferroni-significant, per the table footnote) flag
#     read from the snapshot's cell styles;
#   - re-derives the printed % Difference and Cohen's d from the printed
#     means/SDs into `table_checks` (interval arithmetic over printed rounding);
#   - writes the analysis CSV, and the public TSV only once the item is
#     registered in __ReadMe.xlsx.
#
# Units: BPND is unitless (SRTM2, centrum semiovale reference). VT mL/cm3 and
# K1 mL/min/cm3 are kept in the printed units; the project units (mm3, g, mg)
# do not apply to these measures, so no conversion is made.
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
base <- item_name
paper <- basename(folder)                                   # Holmes_etal_2024

suppressPackageStartupMessages({ library(readxl); library(openxlsx); library(readr) })

## ---- read the frozen snapshot (positional) ------------------------------------
snap_file <- paste0(base, "_snapshot.xlsx")
snap <- as.matrix(read_excel(snap_file, sheet = "SupplementaryTable2", col_names = FALSE,
                             col_types = "text", .name_repair = "minimal"))
snap[is.na(snap)] <- ""; dimnames(snap) <- NULL
stopifnot(ncol(snap) == 6L, nrow(snap) == 32L,
          startsWith(snap[1, 1], "Supplementary Table 2."),
          identical(snap[2, 1:4], c("Region", "HC group", "PD group", "p-value")),
          identical(snap[3, 2:3], c("(n=30)", "(n=30)")),
          identical(snap[4, 1], "Primary"), identical(snap[10, 1], "Secondary"),
          startsWith(snap[32, 1], "Values in bold"))

## bold rows (footnote: bold = significant after Bonferroni correction)
wb <- loadWorkbook(snap_file)
bold_rows <- unique(unlist(lapply(wb$styleObjects, function(so)
  if ("BOLD" %in% toupper(so$style$fontDecoration) && "SupplementaryTable2" %in% so$sheet) so$rows)))
bold_rows <- setdiff(bold_rows, 1L)                         # row 1 = caption

data_rows <- c(5:9, 11:31)
section <- ifelse(data_rows <= 9L, snap[4, 1], snap[10, 1])
dat <- snap[data_rows, , drop = FALSE]
stopifnot(nrow(dat) == 26L, all(nzchar(dat[, 1])))

mean_of <- function(x) as.numeric(sub("^\\s*(-?[0-9.]+)\\s*\\(.*$", "\\1", x))
sd_of   <- function(x) as.numeric(sub("^.*\\(\\s*([0-9.]+)\\s*\\)\\s*$", "\\1", x))
n_of    <- function(h) as.integer(sub("^\\(n=([0-9]+)\\)$", "\\1", h))

one_group <- function(col, glabel, is_hc) data.frame(
  source_locus          = "Supplementary Table 2 (supplement p. 2)",
  printed_row           = seq_len(nrow(dat)),
  section_as_published  = section,
  region_as_published   = dat[, 1],
  group_as_published    = snap[2, col],
  group                 = glabel,
  is_healthy_control    = is_hc,
  n                     = n_of(snap[3, col]),
  species_as_published  = "Homo sapiens",
  measure               = "BPND",
  outcome_model         = "SRTM2, centrum semiovale reference, fixed population k2'",
  value_printed         = dat[, col],
  mean                  = mean_of(dat[, col]),
  sd                    = sd_of(dat[, col]),
  unit                  = "unitless",
  unit_printed          = "",
  HC_vs_PD_p_value          = as.numeric(dat[, 4]),
  HC_vs_PD_pct_difference   = as.numeric(dat[, 5]),
  HC_vs_PD_cohens_d         = as.numeric(dat[, 6]),
  HC_vs_PD_bonferroni_bold  = as.integer(data_rows %in% bold_rows),
  stringsAsFactors = FALSE)

tab <- rbind(one_group(2L, "HC", 1L), one_group(3L, "PD", 0L))
tab <- tab[order(tab$printed_row, -tab$is_healthy_control), ]

## ---- read the frozen text snapshot (Methods p. 7) -----------------------------
txt <- as.data.frame(read_csv(paste0(paper, "_data_from_text_snapshot.csv"),
                              col_types = cols(.default = "c"), na = character()))
stopifnot(nrow(txt) == 4L, all(grepl("\u00b1", txt$value_as_printed)))
pm <- strsplit(txt$value_as_printed, "\\s*\u00b1\\s*")
is_vt <- grepl("volume of distribution", txt$quantity_as_printed)
txt_rows <- data.frame(
  source_locus          = txt$locus,
  printed_row           = NA_integer_,
  section_as_published  = NA_character_,
  region_as_published   = txt$region_as_printed,
  group_as_published    = txt$group_as_printed,
  group                 = txt$group_as_printed,
  is_healthy_control    = as.integer(txt$group_as_printed == "HC"),
  n                     = as.integer(txt$n_as_printed),
  species_as_published  = "Homo sapiens",
  measure               = ifelse(is_vt, "VT", "K1"),
  outcome_model         = "1TCM with arterial input (arterial-sampling subset)",
  value_printed         = txt$value_as_printed,
  mean                  = as.numeric(vapply(pm, `[`, "", 1)),
  sd                    = as.numeric(vapply(pm, `[`, "", 2)),
  unit                  = ifelse(is_vt, "mL/cm3", "mL/min/cm3"),   # printed mL min-1 cm-3 = mL/min/cm3
  unit_printed          = txt$unit_as_printed,
  HC_vs_PD_p_value          = as.numeric(txt$p_value_as_printed),
  HC_vs_PD_pct_difference   = NA_real_,
  HC_vs_PD_cohens_d         = NA_real_,
  HC_vs_PD_bonferroni_bold  = NA_integer_,
  stringsAsFactors = FALSE)
txt_rows <- txt_rows[order(txt_rows$measure != "VT", -txt_rows$is_healthy_control), ]

final.dataframe <- rbind(tab, txt_rows)
rownames(final.dataframe) <- NULL

## ---- table checks: % Difference and Cohen's d vs the printed means/SDs ---------
## Each printed mean/SD is known to +/- half a unit of its last decimal; the
## recomputed quantity is evaluated over that box (grid incl. corners) and the
## printed value passes if it lies inside the range widened by half a unit of
## its own last printed decimal. % Difference = 100 (PD - HC) / HC;
## Cohen's d = |HC - PD| / sqrt((SD_HC^2 + SD_PD^2) / 2)  (equal n = 30).
half_unit <- function(s) { d <- nchar(sub("^[^.]*\\.?", "", s)); 0.5 * 10^(-d) }
grid_range <- function(f, ...) {
  g <- expand.grid(lapply(list(...), function(v) seq(v[1], v[2], length.out = 5)))
  r <- range(do.call(mapply, c(list(FUN = f), unname(as.list(g)))))
  r
}
tc <- list()
for (i in seq_len(nrow(dat))) {
  hc <- dat[i, 2]; pd <- dat[i, 3]
  mh <- mean_of(hc); sh <- sd_of(hc); mp <- mean_of(pd); sp <- sd_of(pd)
  e  <- 0.005                                              # all means/SDs print 2 decimals
  stopifnot(half_unit(sub(" .*", "", hc)) == e, half_unit(sub(" .*", "", pd)) == e)
  r_pct <- grid_range(function(a, b) 100 * (b - a) / a, c(mh - e, mh + e), c(mp - e, mp + e))
  r_d   <- grid_range(function(a, b, s1, s2) abs(a - b) / sqrt((s1^2 + s2^2) / 2),
                      c(mh - e, mh + e), c(mp - e, mp + e), c(sh - e, sh + e), c(sp - e, sp + e))
  if (mh - e <= mp + e && mp - e <= mh + e) r_d[1] <- 0    # means overlap: |diff| can be 0
  for (k in list(list(id = "pct_difference", col = 5L, r = r_pct,
                      basis = "% Difference = 100 (PD - HC) / HC"),
                 list(id = "cohens_d", col = 6L, r = r_d,
                      basis = "Cohen's d = |HC - PD| / pooled SD (equal n)"))) {
    pr <- as.numeric(dat[i, k$col]); hu <- half_unit(dat[i, k$col])
    lo <- k$r[1] - hu; hi <- k$r[2] + hu
    obs <- if (k$id == "pct_difference") 100 * (mp - mh) / mh else abs(mh - mp) / sqrt((sh^2 + sp^2) / 2)
    tc[[length(tc) + 1L]] <- data.frame(
      check_id = paste0(k$id, "_", i), basis = paste0(k$basis, "; row '", dat[i, 1], "'"),
      observed = obs, printed = pr, difference = obs - pr,
      tolerance = max(abs(c(lo, hi) - obs)),
      status = if (pr >= lo && pr <= hi) "pass" else "mismatch",
      note = sprintf("admissible range from printed rounding [%.4g, %.4g]", lo, hi),
      stringsAsFactors = FALSE)
  }
}
table_checks <- do.call(rbind, tc)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.4g vs printed %.4g (%s)", bad$check_id[i], bad$basis[i],
                    bad$observed[i], bad$printed[i], bad$note[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write_csv(final.dataframe, paste0(base, ".csv"), na = "")    # readr: UTF-8 in any locale
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once registered) -----------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
