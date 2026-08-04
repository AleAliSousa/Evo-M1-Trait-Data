# check_Zilles_Rehkamper_1988_provenance.R
#
# Provenance / anachronism check. Zilles, K. & Rehkamper, G. (1988), "The brain,
# with special reference to the telencephalon", in Orang-Utan Biology, contributes
# the ORANG-UTAN (Pongo). Pongo brain data was added into several dataset CSVs
# without recording that source. Any Pongo data in a paper's OWN data columns when
# that paper PREDATES 1988 can NOT have come from the original paper -- it is a
# later addition from Zilles & Rehkamper 1988, and will show up as
# "csv_only_not_in_snapshot" in that paper's comparison. Flagging these makes
# mismatch review faster: such rows are expected, not transcription errors.
#
# The check separates a paper's OWN data columns from the shared "_current"
# reference block (which carries Pongo for every dataset and is never compared),
# so only genuine, comparison-relevant anachronisms are flagged.
#
# Run from the repo root (Evo-M1-Trait-Data) or set `csv_dir`.
# Output: _checks/Zilles_Rehkamper_1988_provenance_report.csv

suppressPackageStartupMessages({ library(readr); library(dplyr); library(stringr); library(purrr); library(tidyr) })  # tidyr: replace_na()
## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_checks")
repo_root    <- "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
source_paper <- "Zilles & Rehkamper (1988), Orang-Utan Biology"
source_taxon <- "pongo"
source_year  <- 1988L
out_file     <- "Zilles_Rehkamper_1988_provenance_report.csv"

# NOTE: this check was originally written against a consolidated staging folder
# ("Stephan_temp_to_organize/csvs") that has since been retired -- those single-paper CSVs
# now live one per paper, in <Paper>/comparison/<Paper_year>.csv. Scan those instead.
files <- list.files(repo_root, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
files <- files[grepl("/comparison/[^/]+\\.csv$", files)]  # directly under comparison/, skip nested subfolders (e.g. Kaufman__2004's extra subfolder)
files <- files[!grepl("_comparison_(report|mismatches)(_from_R)?\\.csv$", basename(files))]  # drop this pipeline's own generated audit outputs
files <- files[basename(files) != "Stephan_sort.csv"]   # the old master merge, not a single-paper dataset (kept for safety)

scan_one <- function(path) {
  fn <- basename(path)
  yr <- suppressWarnings(as.integer(str_extract(fn, "(19|20)\\d{2}")))
  df <- tryCatch(read_csv(path, col_types = cols(.default = col_character()), na = c("")),
                 error = function(e) NULL)
  if (is.null(df) || !"Species" %in% names(df)) return(NULL)
  prows <- df %>% filter(!str_starts(replace_na(Species, ""), "AAAA_"),
                         str_detect(replace_na(tolower(Species), ""), source_taxon))
  if (nrow(prows) == 0)
    return(tibble(dataset = fn, paper_year = yr, predates_1988 = !is.na(yr) & yr < source_year,
                  pongo_paper_data_cols = 0L, paper_data_columns = "", pongo_current_only = FALSE,
                  verdict = "no Pongo row"))
  nm <- names(prows)
  is_paper <- !str_detect(nm, "_source$|_current$") & nm != "Species" &
              !str_detect(nm, "^(Species_|Number_|code_)")
  is_cur   <- str_detect(nm, "_current$")
  has_num  <- function(cols) cols[map_lgl(cols, ~ any(str_detect(replace_na(prows[[.x]], ""), "[0-9]")))]
  pdata <- has_num(nm[is_paper]); pcur <- has_num(nm[is_cur])
  predates <- !is.na(yr) & yr < source_year
  verdict <- if (length(pdata) > 0 && isTRUE(predates))
               "ANACHRONISTIC: Pongo in paper data -> Zilles & Rehkamper 1988 (expect csv_only in comparison)"
             else if (length(pdata) > 0) "Pongo in paper data; paper postdates 1988 (may cite Zilles & Rehkamper 1988)"
             else if (length(pcur) > 0 && isTRUE(predates)) "Pongo only in _current reference block (NOT a comparison issue)"
             else if (length(pcur) > 0) "Pongo only in _current reference block"
             else "Pongo row present but empty"
  tibble(dataset = fn, paper_year = yr, predates_1988 = predates,
         pongo_paper_data_cols = length(pdata), paper_data_columns = paste(pdata, collapse = "; "),
         pongo_current_only = (length(pcur) > 0 && length(pdata) == 0), verdict = verdict)
}

report <- map_dfr(files, scan_one) %>%
  arrange(!(predates_1988 & pongo_paper_data_cols > 0), paper_year)
write_csv(report, out_file)

anach <- report %>% filter(predates_1988, pongo_paper_data_cols > 0)
message("Scanned ", length(files), " single-paper CSVs for Pongo (", source_paper, ").")
message("Pre-1988 datasets with Pongo in their OWN data (anachronistic -> expected csv_only): ", nrow(anach))
if (nrow(anach)) for (i in seq_len(nrow(anach)))
  message("  ", anach$dataset[i], " (", anach$paper_year[i], "): ", anach$paper_data_columns[i])
message("Full report -> ", out_file)
