## Branstetter_etal_2017_TableI.R -- snapshot -> analysis CSV + public TSV
##
## Branstetter, B. K., St Leger, J., Acton, D., Stewart, J., Houser, D.,
## Finneran, J. J., & Jenkins, K. (2017). Killer whale (Orcinus orca)
## behavioral audiograms. J Acoust Soc Am, 141, 2387-2398.
## doi:10.1121/1.4979116
##
## Table I (printed p. 2390) is the raw per-subject behavioral threshold
## matrix underlying the O. orca composite audiogram summarised in Table IV
## (registered separately): 23 printed test frequencies x 10 killer whales
## (A-H measured here; Vigga and Yakka taken from Szymanski et al., 1999),
## with the printed row Mean, Median, N and SD. Killer whales A and B are
## printed but, per the table caption, excluded from the row statistics
## because of hearing loss.
##
## The snapshot is the printed wide matrix (blank cells as printed). This
## script melts it to one row per (frequency x subject) printed threshold
## and carries the printed row statistics as row-level metadata columns.

## 0. PATHS --------------------------------------------------------
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Branstetter_etal_2017_TableI"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
library(tidyverse)
library(readxl)

## 2. LOAD ----------------------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 23)
subjects        <- c("A","B","C","D","E","F","G","H","Vigga","Yakka")
excluded_by_cap <- c("A","B")   # caption: hearing loss; not in Mean/Median/N/SD
szymanski       <- c("Vigga","Yakka")
stopifnot(all(c("kHz", subjects, "Mean","Median","N","SD") %in% names(snap)))

## 3. SPECIES (single-species paper; name from title/abstract) -------
## Collection key is the single source of truth even for one species.
key_file <- if (!is.na(base)) file.path(base, "_keys", "General", "species_key.csv") else NA
if (is.na(key_file) || !file.exists(key_file))
  stop("General collection species key not found.", call. = FALSE)
key <- read.csv(key_file, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == "Branstetter_etal_2017", , drop = FALSE]
if (nrow(key) == 0L)
  stop("No _keys/General/species_key.csv rows for source_publication == \"Branstetter_etal_2017\"; ",
       "key rows are scoped to the paper folder name.", call. = FALSE)
species_as_published <- "Orcinus orca"
species_accepted <- key$accepted_name[match(species_as_published, key$variant_name)]
if (is.na(species_accepted)) stop("Printed species absent from the General species key.", call. = FALSE)

## 4. MELT ----------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(ifelse(is.na(x) | x == "", NA, x)))
long <- snap %>%
  select(kHz, all_of(subjects)) %>%
  pivot_longer(all_of(subjects), names_to = "subject", values_to = "threshold_printed") %>%
  filter(!is.na(threshold_printed), threshold_printed != "")

final.dataframe <- tibble(
  species_as_published = species_as_published,
  Species              = species_accepted,
  common_name          = "Killer whale",
  frequency_khz        = num(long$kHz),
  subject              = long$subject,
  threshold_db_re_1uPa = num(long$threshold_printed),
  threshold_printed    = long$threshold_printed,
  subject_data_role    = ifelse(long$subject %in% szymanski, "secondary", "primary"),
  subject_source       = ifelse(long$subject %in% szymanski,
                                "Szymanski et al. (1999)", "this study"),
  included_in_row_statistics = !(long$subject %in% excluded_by_cap)
) %>%
  left_join(
    tibble(frequency_khz   = num(snap$kHz),
           row_mean_db     = num(snap$Mean),
           row_median_db   = num(snap$Median),
           row_n_printed   = as.integer(num(snap$N)),
           row_sd_db       = num(snap$SD)),
    by = "frequency_khz") %>%
  arrange(frequency_khz, match(subject, subjects))

## 5. TABLE CHECKS (sec 7a) -----------------------------------------
## The table checks itself: Mean / Median / N are recomputable from the
## printed thresholds of the eight summary subjects (C-H, Vigga, Yakka).
## SD is NOT evaluable -- the printed statistics were computed on the
## unrounded thresholds, so SD cannot be reproduced from printed integers
## (e.g. 0.5 kHz: sample SD of the printed cells is 5.4, printed SD is 6).
summary_subjects <- setdiff(subjects, excluded_by_cap)
table_checks <- bind_rows(lapply(seq_len(nrow(snap)), function(i) {
  v <- num(unlist(snap[i, summary_subjects], use.names = FALSE))
  v <- v[!is.na(v)]
  f <- snap$kHz[i]
  tibble(
    check_id = c(paste0("n_", f), paste0("mean_", f), paste0("median_", f), paste0("sd_", f)),
    basis = c(sprintf("count of printed thresholds in columns %s", paste(summary_subjects, collapse = "/")),
              "arithmetic mean of those printed thresholds vs printed Mean",
              "median of those printed thresholds vs printed Median",
              "SD of those printed thresholds vs printed SD"),
    observed  = c(length(v), mean(v), median(v), if (length(v) > 1) sd(v) else NA_real_),
    printed   = num(c(snap$N[i], snap$Mean[i], snap$Median[i], snap$SD[i])),
    tolerance = c(0, 1, 1, NA_real_),
    status    = NA_character_,
    note      = c("", "cell rounding: +-0.5 on the recomputed mean plus +-0.5 on the printed mean",
                  "cell rounding: +-0.5", "not evaluable: printed statistics computed on unrounded thresholds")
  )
}))
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$status <- ifelse(grepl("^sd_", table_checks$check_id), "not_evaluable",
                       ifelse(abs(table_checks$difference) <= table_checks$tolerance, "pass", "mismatch"))
table_checks <- table_checks[, c("check_id","basis","observed","printed","difference","tolerance","status","note")]
if (any(table_checks$status == "mismatch"))
  warning("Table I row-statistic check mismatch; printed values kept as printed.")
message(sprintf("table_checks: %d pass, %d mismatch, %d not_evaluable",
                sum(table_checks$status == "pass"), sum(table_checks$status == "mismatch"),
                sum(table_checks$status == "not_evaluable")))

## 6. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(sprintf("%s: %d rows written", item_name, nrow(final.dataframe)))
