## Chugani_etal_1987_Table1.R -- frozen snapshot -> analysis CSV + public TSV
##
## Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). Positron emission tomography
## study of human brain functional development. Ann. Neurol. 22, 487-497.
## doi:10.1002/ana.410220408
##
## TABLE 1 (pp. 488-489), "Patient Summary": the 29 infants and children studied with
## FDG-PET, one printed row each, with age and sex, clinical information, laboratory
## data, medication on the day of study, and length of follow-up. The table carries NO
## lCMRGlc value: it is the subject roster that gives the ABSCISSA of Figure 2 (every
## plotted point in Fig. 2 belongs to one of these 29 patients) and the membership of
## the age bins of Table 2 (n = 7 / 4 / 12 / 6).
## data_role = primary (this paper's own patients).
##
## Ages are printed in days, weeks, months and years; the snapshot keeps the printed
## string and this script adds the decimal-year conversion (days/365.25, weeks*7/365.25,
## months/12) used to place the Figure 2 abscissa.
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
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse); library(readxl) })

## 1b. SPECIES KEY (collection-scoped: _keys/General, source_publication = folder name)
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder), "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ", paste(bad, collapse = "; "), call. = FALSE)
  out
}
resolve_basis <- function(x) key$basis[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]

## 2. LOAD (frozen snapshot) -------------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                 encoding = "UTF-8", colClasses = "character")
stopifnot(nrow(snap) == 31L)   ## 29 patients + the "(Continued)" header + the footnote

## 3. CLEAN -------------------------------------------------------------
## drop the two non-data printed rows (continuation header, footnote); they stay in the
## snapshot so that snapshot row n is page row n.
pat <- snap[grepl(",\\s*[MF]$", snap[["Age, Sex"]]), , drop = FALSE]
stopifnot(nrow(pat) == 29L)

age_to_years <- function(x) {
  n <- as.numeric(sub("^([0-9.]+)\\s+.*$", "\\1", x))
  u <- sub("^[0-9.]+\\s+", "", x)
  ifelse(grepl("^day",   u), n / 365.25,
  ifelse(grepl("^week",  u), n * 7 / 365.25,
  ifelse(grepl("^month", u), n / 12,
  ifelse(grepl("^year",  u), n, NA_real_))))
}
followup_months <- function(x) {
  n <- as.numeric(sub("^([0-9.]+)\\s+.*$", "\\1", x))
  ifelse(grepl("year", x), n * 12, n)
}
age_str <- trimws(sub(",.*$", "", pat[["Age, Sex"]]))
sex     <- trimws(sub("^.*,\\s*", "", pat[["Age, Sex"]]))

final.dataframe <- tibble::tibble(
  patient_id            = sprintf("P%02d", seq_len(nrow(pat))),
  species_as_published  = "human",
  Species               = resolve("human"),
  species_basis         = resolve_basis("human"),
  age_as_printed        = age_str,
  age_years             = round(age_to_years(age_str), 4),
  sex                   = sex,
  age_group_Table2      = cut(round(age_to_years(age_str), 4),
                              breaks = c(-Inf, 0.99, 2.5, 8.99, Inf),
                              labels = c("Birth-1 year", "1-2 years", "3-8 years", "9-15 years")),
  clinical_information  = pat[["Clinical Information"]],
  laboratory_data       = pat[["Laboratory Data"]],
  medication_on_day_of_study = pat[["Medication on Day of Study"]],
  on_anticonvulsant     = ifelse(tolower(pat[["Medication on Day of Study"]]) == "none", "no", "yes"),
  followup_as_printed   = pat[["Period of Follow-Up after Onset of Neurological Event"]],
  followup_months       = followup_months(pat[["Period of Follow-Up after Onset of Neurological Event"]]),
  value_origin          = "printed_in_table",
  data_role             = "primary")

## 4. TABLE CHECKS (HOWTO 7a) -- the table's own counts against the paper's text -------
n_bins <- as.integer(table(final.dataframe$age_group_Table2))
table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance,
  "n_patients",   "rows carrying an 'Age, Sex' value",                     nrow(final.dataframe), 29, 0,
  "n_male",       "sex == M (Methods p. 489: '16 males and 13 females')",  sum(final.dataframe$sex == "M"), 16, 0,
  "n_female",     "sex == F (Methods p. 489)",                             sum(final.dataframe$sex == "F"), 13, 0,
  "n_on_drugs",   "medication != None (Methods p. 489: '18 of the 29 subjects were taking daily anticonvulsants')",
                                                                           sum(final.dataframe$on_anticonvulsant == "yes"), 18, 0,
  ## age_years is stored rounded to 4 dp, so the tolerance is half a unit of that
  "age_min_years","youngest age (Methods p. 489: 'ages ranged from 5 days')",   min(final.dataframe$age_years), 5/365.25, 5e-5,
  "age_max_years","oldest age (Methods p. 489: 'to 15.1 years')",               max(final.dataframe$age_years), 15.1, 5e-5,
  "n_bin1",       "Table 2 age bin Birth-1 year (n = 7)",                  n_bins[1], 7, 0,
  "n_bin2",       "Table 2 age bin 1-2 years (n = 4)",                     n_bins[2], 4, 0,
  "n_bin3",       "Table 2 age bin 3-8 years (n = 12)",                    n_bins[3], 12, 0,
  "n_bin4",       "Table 2 age bin 9-15 years (n = 6)",                    n_bins[4], 6, 0) %>%
  mutate(difference = observed - printed,
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch"),
         note = "")

## WRITE CSV + PUBLIC TSV ---------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
if (exists("table_checks")) {
  bad <- table_checks[table_checks$status != "pass", , drop = FALSE]
  cat("table_checks:", nrow(table_checks), "checks,", nrow(bad), "not pass\n")
  if (nrow(bad)) print(as.data.frame(bad), row.names = FALSE)
}
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
