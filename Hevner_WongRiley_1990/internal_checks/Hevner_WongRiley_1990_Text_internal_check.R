# Hevner_WongRiley_1990_Text_internal_check.R ---------------------------------------------
#
# Cross-item check (HOWTO 7b): the four percentages printed in RESULTS "Densitometric
# analyses" (Hevner_WongRiley_1990_Text_snapshot.csv) against the relative optical densities
# printed in Table 1 (Hevner_WongRiley_1990_Table1_snapshot.csv):
#   puff enrichment      = 100 x (puff relOD - 1)           vs printed 32 % (histo), 19 % (immuno)
#   light-column decline = 100 x (1 - light-column relOD)   vs printed 20 % (histo), 21 % (immuno)
# Reads both snapshots; writes only Hevner_WongRiley_1990_Text_internal_check.csv next to
# this script. Never changes a value. Tolerance 0.5 (percent values printed as integers).

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
folder <- dirname(dirname(.sp))          # the paper folder (this script sits in internal_checks/)
base <- sub("_internal_check$", "", sub("\\.R$", "", basename(.sp)))
item_name <- base
sibling <- sub("_Text$", "_Table1", item_name)

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))
mean_of_cell <- function(x) num_of(sub("\\s*±.*$", "", x))

tx   <- read_snapshot(file.path(folder, paste0(item_name, "_snapshot.csv")), header = TRUE)
snap <- read_snapshot(file.path(folder, paste0(sibling, "_snapshot.csv")))
stopifnot(nrow(tx) == 4L, identical(dim(snap), c(10L, 3L)),
          snap[6, 1] == "Puff", snap[9, 1] == "Light column",
          snap[3, 2] == "Histochemistry")

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
v <- function(r) num_of(tx$value_printed[tx$text_row == as.character(r)])

internal_checks <- rbind(
  chk("puff_enrichment_histochemistry",
      "Table 1 Puff / Histochemistry: 100 x (relOD - 1) vs RESULTS p. 1335 'Puffs stained histochemically were 32% darker'",
      100 * (mean_of_cell(snap[6, 2]) - 1), v(1), 0.5),
  chk("puff_enrichment_immunohistochemistry",
      "Table 1 Puff / Immunohistochemistry: 100 x (relOD - 1) vs RESULTS p. 1335 '19% darker'",
      100 * (mean_of_cell(snap[6, 3]) - 1), v(2), 0.5),
  chk("light_column_decline_histochemistry",
      "Table 1 Light column / Histochemistry: 100 x (1 - relOD) vs RESULTS p. 1337 '20% decreased'",
      100 * (1 - mean_of_cell(snap[9, 2])), v(3), 0.5),
  chk("light_column_decline_immunohistochemistry",
      "Table 1 Light column / Immunohistochemistry: 100 x (1 - relOD) vs RESULTS p. 1337 'the decrease was 21%'",
      100 * (1 - mean_of_cell(snap[9, 3])), v(4), 0.5)
)
tally <- table(factor(internal_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": internal checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- internal_checks[internal_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
write.csv(internal_checks, file.path(dirname(.sp), paste0(item_name, "_internal_check.csv")),
          row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
