# Llorente_etal_2009_TableII.R ---------------------------------------------------------------
# Llorente, M., Mosquera, M., & Fabré, M. (2009). Manual laterality for simple reaching and bimanual coordinated task in naturalistic housed Pan troglodytes. International Journal of Primatology, 30(1), 183–197. https://doi.org/10.1007/s10764-009-9338-1
#
# Table II (pp. 190-191, spans two pages): "Laterality indices for tube task, simple reaching, and
# multitask evaluation": per chimpanzee (14 subjects), per measure; plus the printed group columns
# (Mean value, SE, SD, one-sample t-test t / df / p, Lateralized L/R/A counts).
# PRIMARY. Printed table -> checked snapshot Llorente_etal_2009_TableII_snapshot.csv (wide, as printed, blanks kept; frozen).
# The script reshapes it to long: one row per task x measure x subject (level = individual) and one row per
# task x measure x printed group statistic (level = group_summary). No value is typed here.

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
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(enc2utf8(x)) else enc2utf8(x)
item_dir  <- dirname(.sp); setwd(item_dir)
folder    <- nfc(basename(item_dir))
item_name <- nfc(sub("\\.R$", "", basename(.sp)))
base      <- item_name
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

read_snapshot <- function(file) read.csv(file, header = TRUE, colClasses = "character", na.strings = character(0),
                                         check.names = FALSE, strip.white = FALSE, encoding = "UTF-8", fileEncoding = "UTF-8-BOM")
key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"), colClasses = "character",
                na.strings = character(0), encoding = "UTF-8")
key <- key[nfc(trimws(key$source_publication)) == folder, , drop = FALSE]
if (!nrow(key)) stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
species_cols <- function(printed) {
  i <- match(printed, key$variant_name)
  if (anyNA(i)) stop("Unkeyed printed name: ", paste(unique(printed[is.na(i)]), collapse = "; "), call. = FALSE)
  data.frame(species_as_published = printed, Species = key$accepted_name[i], ncbi_taxid = key$ncbi_taxid[i],
             stringsAsFactors = FALSE)
}
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
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i], bad$basis[i],
                    bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
}
write_csv_bom <- function(df, path) {   # UTF-8 with BOM so Excel on macOS shows the accents (C6)
  txt <- enc2utf8(paste0(paste(utils::capture.output(utils::write.csv(df, stdout(), row.names = FALSE, na = "")),
                               collapse = "\n"), "\n"))
  con <- file(path, open = "wb"); writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con); writeBin(charToRaw(txt), con); close(con)
}

frozen <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
snap <- read_snapshot(frozen)
subjects <- c("Bongo","Charly","Julio","Juanito","Marco","Nico","Pancho","Romie","Sara","Tico","Toni","Toto","V\u00edctor","Waty")
stopifnot(identical(nfc(names(snap)), c("Task evaluation", "Value", nfc(subjects), "Mean value", "SE", "SD", "t", "df", "p", "Lateralized L/R/A")),
          nrow(snap) == 33L)
names(snap) <- c("task", "measure", paste0("s", seq_along(subjects)), "mean", "se", "sd", "t", "df", "p", "lat")
## task and measure labels are printed once per block: carry forward (a blank printed cell inherits the block heading)
snap$task_filled <- snap$task
for (i in seq_len(nrow(snap))) if (!nzchar(snap$task_filled[i])) snap$task_filled[i] <- snap$task_filled[i - 1L]
snap$measure_filled <- snap$measure
snap$measure_filled[snap$measure == ""] <- "binomial test (label not printed)"   # first row under the Tube task heading is unlabelled
snc <- paste0("s", seq_along(subjects))
ind <- do.call(rbind, lapply(seq_len(nrow(snap)), function(i)
  data.frame(printed_row = i, task = snap$task_filled[i], measure = snap$measure_filled[i], level = "individual",
             subject = nfc(subjects), value_printed = unlist(snap[i, snc], use.names = FALSE), stringsAsFactors = FALSE)))
st <- c(mean = "Mean value", se = "SE", sd = "SD", t = "t", df = "df", p = "p", lat = "Lateralized L/R/A")
grp <- do.call(rbind, lapply(seq_len(nrow(snap)), function(i)
  data.frame(printed_row = i, task = snap$task_filled[i], measure = snap$measure_filled[i], level = "group_summary",
             subject = unname(st), value_printed = unlist(snap[i, names(st)], use.names = FALSE), stringsAsFactors = FALSE)))
long <- rbind(ind, grp)
long <- long[nzchar(long$value_printed), , drop = FALSE]          # printed blanks are not values
long$value_numeric <- suppressWarnings(as.numeric(long$value_printed))
non_num_ok <- is.na(long$value_numeric) & (long$measure %in% c("Individual preference", "Consistency preference") | long$subject == "Lateralized L/R/A")
stopifnot(all(non_num_ok | !is.na(long$value_numeric)))
sp1 <- species_cols(rep("Pan troglodytes", nrow(long)))
final.dataframe <- data.frame(sp1, long[, c("printed_row", "task", "measure", "level", "subject", "value_printed", "value_numeric")],
  observation_level = ifelse(long$level == "individual", "individual chimpanzee (14 subjects) x measure", "printed group statistic of the 14 subjects"),
  source_locator = paste0("Table II, pp. 190-191, printed row ", long$printed_row),
  data_role = "primary", stringsAsFactors = FALSE)
rownames(final.dataframe) <- NULL

## ---- table checks (HOWTO 7a): printed Mean and SE against the printed individual values
## Mean of the printed individual values vs printed Mean: tolerance = half unit of the individual decimals + half unit of the Mean.
## SE vs SD / sqrt(n), n = number of printed individual values.
tc <- list()
for (i in seq_len(nrow(snap))) {
  v <- unlist(snap[i, snc], use.names = FALSE); v <- v[nzchar(v)]
  num <- suppressWarnings(as.numeric(v)); if (length(num) < 2L || anyNA(num) || !nzchar(snap$mean[i])) next
  m <- as.numeric(snap$mean[i]); n <- length(num)
  tc[[length(tc) + 1L]] <- chk(sprintf("mean_row%02d", i), sprintf("mean of %d printed individual values vs printed Mean, %s / %s", n, snap$task_filled[i], snap$measure_filled[i]),
                                mean(num), m, hu(v[1]) + hu(snap$mean[i]))
  if (nzchar(snap$sd[i]) && nzchar(snap$se[i]))
    tc[[length(tc) + 1L]] <- chk(sprintf("se_row%02d", i), sprintf("printed SE vs printed SD / sqrt(n = %d), %s / %s", n, snap$task_filled[i], snap$measure_filled[i]),
                                  as.numeric(snap$sd[i]) / sqrt(n), as.numeric(snap$se[i]), hu(snap$se[i]) + hu(snap$sd[i]) / sqrt(n))
}
table_checks <- do.call(rbind, tc)
report_checks(table_checks)

## ---- outputs: analysis CSV (UTF-8 + BOM) and public TSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write_csv_bom(final.dataframe, csv_path)
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
filecodes$`Item name` <- nfc(as.character(filecodes$`Item name`))
item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
tsv_path <- NA_character_
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written; check the registry row.", call. = FALSE)
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message("Wrote public TSV: ", tsv_path)
}
checks <- validate_dataset_item(
  csv_file = csv_path, tsv_file = tsv_path,
  readme_file = file.path(item_dir, paste0(item_name, ".README.md")),
  definitions_file = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen, registry = filecodes, item_name = item_name,
  item_encoded = if (is.na(tsv_path)) NULL else item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " rows; ", length(unique(final.dataframe$Species)), " species")
