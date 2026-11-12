# Varnäs_etal_2020_Table1.R --------------------------------------------------------
#
# Varnäs, K., Stepanov, V., & Halldin, C. (2020). Autoradiographic mapping of
# synaptic vesicle glycoprotein 2A in non-human primate and human brain.
# Synapse 74(10): e22157. https://doi.org/10.1002/syn.22157
# TABLE 1 "Binding of [11C]UCB-J to synaptic vesicle glycoprotein 2A in
# non-human primate and human brain" (p. 4 of 6).
#
# Reads the frozen snapshot Varnäs_etal_2020_Table1_snapshot.xlsx (written by
# Varnäs_etal_2020_Table1_snapshot.R) and does all the cleaning:
#   - one row per printed region x species group (Non-human primate, Human),
#     printed region and group labels kept; printed blanks (Occipital cortex has
#     no non-human-primate values, White matter no ratio) stay NA;
#   - splits the printed "mean (range)" cells into mean, range min, range max;
#   - adds species_as_published from Methods 2.2.1: the binomial token
#     "Macaca Fascicularis" (printed capitalisation; full phrase "five cynomolgus
#     monkeys (Macaca Fascicularis)") for the NHP columns, and "Human" (the
#     table header; Methods prints "Human brains", no binomial) for the human
#     columns; the table's own group header is kept in species_group_as_published;
#   - checks the printed means against their printed ranges into `table_checks`
#     (n = 2: mean = midpoint of the range; n >= 3: min <= mean <= max);
#   - writes the analysis CSV, and the public TSV only once registered.
#
# Units: specific binding kept in the printed kBq/mm2 (in vitro autoradiography,
# radioactivity per section area at one radioligand concentration); the ratio is
# unitless. Project units (mm3, g, mg) do not apply; no conversion is made.
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

suppressPackageStartupMessages({ library(readxl); library(readr) })

## ---- read the frozen snapshot (positional) ------------------------------------
snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "Table1", col_names = FALSE,
                             col_types = "text", .name_repair = "minimal"))
snap[is.na(snap)] <- ""; dimnames(snap) <- NULL
stopifnot(ncol(snap) == 7L, nrow(snap) == 18L,
          startsWith(snap[1, 1], "TABLE 1 Binding of [11C]UCB-J"),
          identical(snap[2, c(2, 5)], c("Non-human primate", "Human")),
          identical(snap[3, 1], "Brain region"), identical(snap[3, c(2, 5)], c("n", "n")),
          all(grepl("^Specific binding \\(kBq/mm", snap[3, c(3, 6)])),
          all(grepl("^Ratio region/", snap[3, c(4, 7)])),
          startsWith(snap[18, 1], "Note:"))
dat <- snap[4:17, , drop = FALSE]

split_mr <- function(x) {             # "636 (584–665)" -> mean, min, max ; "585" -> mean only
  x <- trimws(x)
  mean <- suppressWarnings(as.numeric(sub("^([0-9.]+).*$", "\\1", x)))
  has_r <- grepl("\\(", x)
  lo <- ifelse(has_r, suppressWarnings(as.numeric(sub("^.*\\(([0-9.]+)\u2013.*$", "\\1", x))), NA_real_)
  hi <- ifelse(has_r, suppressWarnings(as.numeric(sub("^.*\u2013([0-9.]+)\\).*$", "\\1", x))), NA_real_)
  mean[x == ""] <- NA_real_
  list(mean = mean, min = lo, max = hi)
}

## species names as printed in Methods 2.2.1 (not in the table itself)
species_methods <- c("Non-human primate" = "Macaca Fascicularis", "Human" = "Human")

one_group <- function(cols, group) {
  sb <- split_mr(dat[, cols[2]]); ra <- split_mr(dat[, cols[3]])
  data.frame(
    printed_row                         = seq_len(nrow(dat)),
    region_as_published                 = dat[, 1],
    species_group_as_published          = group,
    species_as_published                = unname(species_methods[group]),
    n                                   = suppressWarnings(as.integer(dat[, cols[1]])),
    specific_binding_printed            = dat[, cols[2]],
    specific_binding_mean.kBq_mm2       = sb$mean,
    specific_binding_range_min.kBq_mm2  = sb$min,
    specific_binding_range_max.kBq_mm2  = sb$max,
    ratio_to_white_matter_printed       = dat[, cols[3]],
    ratio_to_white_matter_mean          = ra$mean,
    ratio_to_white_matter_range_min     = ra$min,
    ratio_to_white_matter_range_max     = ra$max,
    is_white_matter_reference           = as.integer(dat[, 1] == "White matter"),
    stringsAsFactors = FALSE)
}
final.dataframe <- rbind(one_group(2:4, snap[2, 2]), one_group(5:7, snap[2, 5]))
final.dataframe <- final.dataframe[order(final.dataframe$printed_row,
                                         final.dataframe$species_group_as_published == "Human"), ]  # printed order: NHP, Human
## printed blank cells (no data) are dropped as rows only when the whole group cell set is blank
blank <- is.na(final.dataframe$n) & final.dataframe$specific_binding_printed == "" &
         final.dataframe$ratio_to_white_matter_printed == ""
stopifnot(sum(blank) == 1L)                         # Occipital cortex, non-human primate
final.dataframe <- final.dataframe[!blank, ]
rownames(final.dataframe) <- NULL

## ---- table checks: printed mean vs printed range -----------------------------------
## Compared in units of the printed decimals: each printed number is known to
## +/- half a unit of its last decimal. n = 2: mean must equal (min + max) / 2
## within hu(mean) + (hu(min) + hu(max)) / 2. n >= 3: min - hu(min) <= mean
## <= max + hu(max). n = 1 rows print no range: not evaluable.
hu <- function(s) { d <- nchar(sub("^[^.]*\\.?", "", s)); 0.5 * 10^(-d) }
num_parts <- function(s) regmatches(s, gregexpr("[0-9.]+", s))[[1]]
tc <- list()
for (i in seq_len(nrow(final.dataframe))) {
  r <- final.dataframe[i, ]
  for (m in c("specific_binding", "ratio_to_white_matter")) {
    pr <- r[[paste0(m, "_printed")]]
    if (pr == "") next
    p <- num_parts(pr)
    id <- paste0(m, "_", r$printed_row, "_", ifelse(r$species_group_as_published == "Human", "human", "nhp"))
    basis <- paste0(m, " '", pr, "', ", r$species_group_as_published, ", row '", r$region_as_published,
                    "', n = ", r$n)
    if (length(p) == 1L) {
      tc[[length(tc) + 1L]] <- data.frame(check_id = id, basis = basis, observed = NA_real_,
        printed = as.numeric(p[1]), difference = NA_real_, tolerance = NA_real_,
        status = "not_evaluable", note = "single value printed (n = 1), no range", stringsAsFactors = FALSE)
      next
    }
    mn <- as.numeric(p[1]); lo <- as.numeric(p[2]); hi <- as.numeric(p[3])
    if (r$n == 2L) {
      mid <- (lo + hi) / 2; tol <- hu(p[1]) + (hu(p[2]) + hu(p[3])) / 2
      ok <- abs(mn - mid) <= tol + 1e-9
      tc[[length(tc) + 1L]] <- data.frame(check_id = id, basis = paste0(basis, ": mean = midpoint of range"),
        observed = mid, printed = mn, difference = mid - mn, tolerance = tol,
        status = if (ok) "pass" else "mismatch", note = "n = 2: the mean of two values is the midpoint of their range",
        stringsAsFactors = FALSE)
    } else {
      ok <- mn >= lo - hu(p[2]) - 1e-9 && mn <= hi + hu(p[3]) + 1e-9
      tc[[length(tc) + 1L]] <- data.frame(check_id = id, basis = paste0(basis, ": min <= mean <= max"),
        observed = NA_real_, printed = mn, difference = NA_real_, tolerance = NA_real_,
        status = if (ok) "pass" else "mismatch", note = sprintf("range [%s, %s]", p[2], p[3]),
        stringsAsFactors = FALSE)
    }
  }
}
table_checks <- do.call(rbind, tc)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad))) warning(bad$check_id[i], ": ", bad$basis[i], call. = FALSE)
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
