## Chugani_etal_1987_Table2.R -- frozen snapshot -> analysis CSV + public TSV
##
## Chugani, H. T., Phelps, M. E., & Mazziotta, J. C. (1987). Positron emission tomography
## study of human brain functional development. Ann. Neurol. 22, 487-497.
## doi:10.1002/ana.410220408
##
## TABLE 2 (p. 493), "Local Cerebral Metabolic Rates for Glucose (lCMRGlc) in
## umol/min/100 gm and as a Ratio to Adult Rates for Selected Brain Regions During
## Development": 14 structures x 4 developmental age bins (n = 7 / 4 / 12 / 6, the 29
## patients of Table 1) plus a normal adult group (19-30 years, n = 7). Each cell is
## printed "mean +/- SEM"; a Ratio column accompanies each developmental bin.
## data_role = primary.
##
## The snapshot keeps the printed two-tier header, the three section rows (Cerebral
## cortex / Basal ganglia and thalamus / Cerebellum) and the two footnotes. This script
## drops the section and footnote rows, splits "mean +/- SEM", and reshapes the five
## printed column pairs to LONG form: one row per structure x age group.
## Units are already the project-relevant umol/min/100 g -- no conversion.
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
raw <- read.csv(snapshot_csv, header = FALSE, stringsAsFactors = FALSE,
                check.names = FALSE, encoding = "UTF-8", colClasses = "character")
stopifnot(nrow(raw) == 22L, ncol(raw) == 10L)   ## caption + 2 header rows + 19 printed rows
group_hdr <- as.character(raw[2, ])            ## spanning header, blank-padded
body      <- raw[4:nrow(raw), , drop = FALSE]

## 3. CLEAN -------------------------------------------------------------
sem_split <- function(x) {
  x <- trimws(x)
  list(mean = suppressWarnings(as.numeric(trimws(sub("\u00b1.*$", "", x)))),
       sem  = suppressWarnings(as.numeric(trimws(sub("^.*\u00b1", "", x)))))
}
## printed structure rows carry a value in column 2; section rows and footnotes do not
is_data <- nzchar(trimws(body[[2]]))
dat <- body[is_data, , drop = FALSE]
stopifnot(nrow(dat) == 14L)

## the printed section that each structure sits under (blank for the ungrouped rows)
section <- character(nrow(body)); cur <- ""
for (i in seq_len(nrow(body))) {
  if (!nzchar(trimws(body[i, 2])) && nzchar(trimws(body[i, 1])) && !grepl("^\\^", body[i, 1]))
    cur <- trimws(body[i, 1])
  section[i] <- if (nzchar(trimws(body[i, 2]))) cur else NA_character_
}
section <- section[is_data]
## "Cerebral hemisphere" and "Brainstem" are printed flush left, above/below the sections
section[c(1, 14)] <- ""

grp_cols <- list(c(2, 3), c(4, 5), c(6, 7), c(8, 9), c(10, NA))
grp_name <- c(trimws(group_hdr[2]), trimws(group_hdr[4]), trimws(group_hdr[6]),
              trimws(group_hdr[8]), trimws(group_hdr[10]))

out <- list()
for (g in seq_along(grp_cols)) {
  v  <- sem_split(dat[[grp_cols[[g]][1]]])
  rt <- if (is.na(grp_cols[[g]][2])) rep(NA_real_, nrow(dat))
        else suppressWarnings(as.numeric(dat[[grp_cols[[g]][2]]]))
  out[[g]] <- tibble::tibble(
    structure_as_printed = trimws(dat[[1]]),
    printed_section      = section,
    age_group_as_printed = sub("\\s*\\(n = .*$", "", grp_name[g]),
    n_subjects           = as.integer(sub("^.*\\(n = ([0-9]+)\\).*$", "\\1", grp_name[g])),
    lCMRGlc_mean.umol_min_100g = v$mean,
    lCMRGlc_SEM.umol_min_100g  = v$sem,
    ratio_to_adult_as_printed  = rt)
}
final.dataframe <- dplyr::bind_rows(out) %>%
  mutate(species_as_published = "human",
         Species = resolve("human"),
         species_basis = resolve_basis("human"),
         is_adult_reference_group = age_group_as_printed == "Adult 19\u201330 years",
         value_origin = "printed_in_table",
         data_role = "primary") %>%
  select(structure_as_printed, printed_section, species_as_published, Species, species_basis,
         age_group_as_printed, n_subjects, is_adult_reference_group,
         lCMRGlc_mean.umol_min_100g, lCMRGlc_SEM.umol_min_100g, ratio_to_adult_as_printed,
         value_origin, data_role)
stopifnot(nrow(final.dataframe) == 70L)

## 4. TABLE CHECKS (HOWTO 7a) ------------------------------------------
## Footnote b says the Ratio is the ratio to the mean adult lCMRGlc, so every printed
## ratio is recomputable from two printed cells of the same row. Both are printed to
## 2 dp, so the tolerance is half a unit of the last printed decimal (0.005) plus the
## propagated rounding of the two means (<= 0.0004 over this range) -> 0.0055.
adult <- final.dataframe %>% filter(is_adult_reference_group) %>%
  select(structure_as_printed, adult_mean = lCMRGlc_mean.umol_min_100g)
chk <- final.dataframe %>% filter(!is_adult_reference_group) %>%
  left_join(adult, by = "structure_as_printed") %>%
  transmute(check_id = paste0("ratio_", gsub("[^A-Za-z0-9]+", "", structure_as_printed), "_",
                              gsub("[^A-Za-z0-9]+", "", age_group_as_printed)),
            basis = paste0("printed Ratio vs mean/", "adult mean: ", structure_as_printed,
                           ", ", age_group_as_printed),
            observed = round(lCMRGlc_mean.umol_min_100g / adult_mean, 4),
            printed = ratio_to_adult_as_printed,
            tolerance = 0.0055,
            note = "")
table_checks <- chk %>%
  mutate(difference = round(observed - printed, 4),
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch")) %>%
  select(check_id, basis, observed, printed, difference, tolerance, status, note)
## recorded as Chugani_etal_1987-E001 in reference_tables/Chugani_etal_1987_errata.csv

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
