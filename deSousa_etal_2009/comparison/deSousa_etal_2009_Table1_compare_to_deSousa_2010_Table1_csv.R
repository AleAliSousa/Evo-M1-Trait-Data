## =============================================================================
## deSousa_etal_2009_Table1_compare_to_deSousa_2010_Table1_csv.R
## -----------------------------------------------------------------------------
## Checking step (__HOWTO_build_a_dataset_file.md section 7). de Sousa et al. 2009
## Table 1 and de Sousa et al. 2010 Table 1 report THE SAME NINE SPECIMENS of the
## Zilles/Dusseldorf collection. 2009 prints left V1 and left LGN in whole mm3;
## 2010 prints the same measurements in cm3 to one decimal place. So 2010 is the
## curated, already-audited copy to check this build against -- and the check is
## also the evidence that the two items are not two independent measurements.
##
## Three blocks are run and written to one report:
##   A. value audit vs deSousa_etal_2010_Table1.csv, matched by specimen
##   B. specimen identity vs _keys/specimen_crosswalk/collection_specimens_parsed.csv
##      (the 2009 "code" column is the catalog's "my working code"), checking sex/age
##   C. internal consistency: does the printed EQ reproduce from the printed masses?
##
## Match rule (block A): the two prints have different precision, so a value counts
## as matching when it agrees to half of the LAST PRINTED DIGIT OF THE COARSER print
## (tol = 0.05 cm3 where 2010 prints 1 d.p.; 0.5 where 2009 prints a whole number).
## Rounding differences are therefore matches; anything larger is a real mismatch.
##
## Run from comparison/.  Outputs:
##   deSousa_etal_2009_Table1_comparison_report_from_R.csv
##   deSousa_etal_2009_Table1_mismatches_from_R.csv
## =============================================================================

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr); library(tidyr); library(purrr)
})

folder <- if (basename(getwd()) == "comparison") dirname(getwd()) else getwd()
base   <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
out_dir <- file.path(folder, "comparison")

d09 <- read_csv(file.path(folder, "deSousa_etal_2009_Table1.csv"), show_col_types = FALSE)
d10 <- read_csv(file.path(base, "deSousa_etal_2010", "deSousa_etal_2010_Table1.csv"),
                show_col_types = FALSE)

## ---- specimen key ------------------------------------------------------------
## 2009 prints the bare archive number ("YN82-140", "Disco"); 2010 prints the same
## specimen with an en dash and/or the accession fraction ("YN82-140", "Disco 3/97").
## Normalise: lowercase, en/em dash -> hyphen, drop spaces, drop a trailing n/nn.
norm_specimen <- function(x) {
  x <- str_to_lower(as.character(x))
  x <- str_replace_all(x, "[–—]", "-")
  x <- str_replace_all(x, "\\s+", "")
  str_replace(x, "\\d+/\\d+$", "")
}

a09 <- d09 %>% mutate(key = norm_specimen(archive_number))
a10 <- d10 %>% mutate(key = norm_specimen(code))
stopifnot(!any(duplicated(a09$key)), all(a09$key %in% a10$key))

## ---- block A: value audit ----------------------------------------------------
## variable, the 2009 column, its conversion into the 2010 unit, the 2010 column,
## and the tolerance implied by the coarser print.
vars <- tibble::tribble(
  ~variable,      ~col09,                  ~to_2010_unit, ~col10,                 ~tol,
  "left V1",      "left_V1_volume_mm3",    1/1000,        "left_V1_volume_cm3",   0.05,
  "left LGN",     "left_LGN_volume_mm3",   1/1000,        "left_LGN_volume_cm3",  0.05,
  "neocortex",    "neocortex_volume_mm3",  1/1000,        "neocortex_volume_cm3", 0.5,
  "brain mass",   "brain_mass_mg",         1/1000,        "brain_mass_g",         0.5
)

blockA <- vars %>%
  mutate(rows = pmap(list(col09, to_2010_unit, col10, tol, variable),
    function(c9, f, c10, tol, variable) {
      a09 %>%
        transmute(key, code, archive_number, species,
                  value_2009_converted = .data[[c9]] * f) %>%
        left_join(a10 %>% transmute(key, code_2010 = code, value_2010 = .data[[c10]]), by = "key") %>%
        mutate(
          variable = variable,
          diff  = value_2009_converted - value_2010,
          status = case_when(
            is.na(value_2009_converted) & is.na(value_2010) ~ "both missing",
            is.na(value_2010)                              ~ "2009 only",
            is.na(value_2009_converted)                    ~ "2010 only",
            abs(diff) <= tol + 1e-9                        ~ "match",
            TRUE                                           ~ "MISMATCH"
          ),
          tolerance = tol
        )
    })) %>%
  select(rows) %>% unnest(rows) %>%
  mutate(check = "A value audit vs deSousa_etal_2010_Table1") %>%
  select(check, variable, code, archive_number, code_2010, species,
         value_2009_converted, value_2010, diff, tolerance, status)

## ---- block B: specimen identity vs the collection catalog --------------------
cat_path <- file.path(base, "_keys", "specimen_crosswalk", "collection_specimens_parsed.csv")
blockB <- if (file.exists(cat_path)) {
  cat09 <- read_csv(cat_path, show_col_types = FALSE) %>%
    select(canonical_specimen, cat_species = species, cat_code = `my working code`,
           cat_sex = Sex, cat_age = `Age (Yr)`)
  d09 %>%
    left_join(cat09, by = c("code" = "cat_code")) %>%
    transmute(check = "B specimen identity vs collection catalog",
              variable = "sex / age / species",
              code, archive_number, code_2010 = canonical_specimen, species,
              value_2009_converted = age_yrs, value_2010 = suppressWarnings(as.numeric(cat_age)),
              diff = NA_real_, tolerance = NA_real_,
              status = case_when(
                is.na(canonical_specimen) ~ "MISMATCH",
                !is.na(sex) & !is.na(cat_sex) & !cat_sex %in% "U" & sex != cat_sex ~ "MISMATCH",
                is.na(sex) | is.na(cat_sex) | cat_sex %in% "U" ~ "match (sex unknown in one source)",
                TRUE ~ "match"
              ))
} else NULL

## ---- block C: does the printed EQ reproduce from the printed masses? --------
## EQ after Martin (1981) / Ruff et al. (1997): EQ = brain mass (g) / (11.22 * body mass (kg)^0.75).
## The masses are printed rounded, so agreement is expected only to ~0.06.
blockC <- d09 %>%
  transmute(check = "C internal consistency: printed EQ vs recomputed",
            variable = "EQ",
            code, archive_number, code_2010 = NA_character_, species,
            value_2009_converted = EQ,
            value_2010 = round((brain_mass_mg / 1000) / (11.22 * (body_mass_g / 1000)^0.75), 3),
            diff = value_2009_converted - value_2010,
            tolerance = 0.06,
            status = if_else(abs(diff) <= 0.06, "match (within printed-mass rounding)", "MISMATCH"))

report <- bind_rows(blockA, blockB, blockC)
write_csv(report, file.path(out_dir, "deSousa_etal_2009_Table1_comparison_report_from_R.csv"))

mismatches <- report %>% filter(status == "MISMATCH")
write_csv(mismatches, file.path(out_dir, "deSousa_etal_2009_Table1_mismatches_from_R.csv"))

message(sprintf("value audit: %d match, %d mismatch, %d one-sided; EQ: %d/%d reproduce",
                sum(blockA$status == "match"), sum(blockA$status == "MISMATCH"),
                sum(blockA$status %in% c("2009 only", "2010 only", "both missing")),
                sum(str_starts(blockC$status, "match")), nrow(blockC)))
if (nrow(mismatches)) message("MISMATCHES (expected: 1, the ppz/Zahlia neocortex -- see README):\n",
                              paste(capture.output(print(as.data.frame(mismatches))), collapse = "\n"))
