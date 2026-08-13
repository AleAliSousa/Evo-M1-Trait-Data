# deSousa_etal_2010_compare_to_Visual_volumes.R
#
# Checking step (self-contained in comparison/). Visual_volumes.xlsx is an
# independently held copy of the de Sousa et al. (2010) visual-system species
# means. It carries FULL precision (e.g. Homo V1 = 15.247501158301159 cm3) where
# the published Supp. Table 2 prints 1 decimal, so every comparison here is
# rounding-aware: a value agrees if it rounds to the printed figure.
#
# Three checks are run:
#   (A) internal  - Sheet1 mm3 block == Sheet1 cm3 block * 1000, and
#                   Sheet1 mm3 block == Sheet2. Catches the mixed-unit LGN column
#                   and the Sheet1/Sheet2 disagreement in the Scandentia rows.
#   (B) vs SupTable2 - species means, cm3, 4 measures (brain, neocortex, V1, LGN).
#                   Rows whose SupTable2 `correction` field records a corrected
#                   neocortex value are expected to differ (the extraction fixed
#                   the prosimian neocortex figures mis-copied from Stephan);
#                   those are counted separately as expected_correction, not as
#                   mismatches.
#   (C) vs V1LGN  - the mm3 V1/LGN/brain compilation, matched on canonical name.
#                   Primate rows only; V1LGN is a primate compilation.
#
# The non-primate rows of Visual_volumes (Scandentia + the numerically coded
# insectivores) are outside de Sousa 2010 and are reported, not audited.
#
# Inputs : Visual_volumes.xlsx (Sheet1, Sheet2)
#          ../deSousa_etal_2010_SupTable2.csv
#          ../deSousa_etal_2010_V1LGN.csv
# Outputs: deSousa_etal_2010_Visual_volumes_internal_check_from_R.csv
#          deSousa_etal_2010_Visual_volumes_vs_SupTable2_report_from_R.csv
#          deSousa_etal_2010_Visual_volumes_vs_V1LGN_report_from_R.csv
#          deSousa_etal_2010_Visual_volumes_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})

## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/deSousa_etal_2010/comparison")

comparison_file <- "Visual_volumes.xlsx"
suptable2_file  <- "../deSousa_etal_2010_SupTable2.csv"
v1lgn_file      <- "../deSousa_etal_2010_V1LGN.csv"
out_internal    <- "deSousa_etal_2010_Visual_volumes_internal_check_from_R.csv"
out_suptable2   <- "deSousa_etal_2010_Visual_volumes_vs_SupTable2_report_from_R.csv"
out_v1lgn       <- "deSousa_etal_2010_Visual_volumes_vs_V1LGN_report_from_R.csv"
out_mismatches  <- "deSousa_etal_2010_Visual_volumes_mismatches_from_R.csv"
header_rows     <- 2L   # label row + Stephan variable-code row (991-994)

# ---------------------------------------------------------------- helpers ----
na_tokens <- c("", "-", "–", "—", "NA", "n.a.", "_", "__")
num <- function(x) suppressWarnings(parse_number(as.character(x), na = na_tokens))

# decimals printed in the reference CSV, used to set the rounding tolerance
dp_of <- function(s) ifelse(is.na(s) | !str_detect(s, "\\."), 0L,
                            nchar(str_extract(s, "(?<=\\.)\\d+")))
# TRUE when the full-precision value `a` rounds to the printed value `b`.
# NA (not FALSE) when the reference is blank but the comparison file has a value:
# there is nothing to check against, and the value is a candidate gap-filler.
rounds_to <- function(a, b_txt) {
  b <- num(b_txt); d <- dp_of(b_txt)
  as.logical(ifelse(is.na(a) & is.na(b), TRUE,
             ifelse(is.na(a) & !is.na(b), FALSE,
             ifelse(!is.na(a) & is.na(b), NA,
                    abs(a - b) <= 0.5 * 10^(-d) + 1e-9))))
}
rel_equal <- function(a, b, tol = 1e-6) {
  (is.na(a) & is.na(b)) |
    (!is.na(a) & !is.na(b) & abs(a - b) <= tol * pmax(1, abs(a), abs(b)))
}

# one canonical binomial for both sides (published spellings -> current usage)
canon_map <- c(
  "sanguinus midas"          = "saguinus midas",
  "sanguinus oedipus"        = "saguinus oedipus",
  "pithecus monachus"        = "pithecia monachus",
  "cercopithecus mitus"      = "cercopithecus mitis",
  "lagothix lagathricha"     = "lagothrix lagotricha",
  "lagothix lagothricha"     = "lagothrix lagotricha",
  "lagothrix lagothricha"    = "lagothrix lagotricha",
  "loris tardigradius"       = "loris tardigradus",
  "cebuella pygmaea"         = "callithrix pygmaea",
  "procolobus badius"        = "piliocolobus badius",
  "callicebus moloch"        = "plecturocebus moloch",
  "syndactylus symphalangus" = "symphalangus syndactylus"
)
canon <- function(x) {
  k <- str_squish(tolower(str_replace_all(as.character(x), "_", " ")))
  ifelse(k %in% names(canon_map), unname(canon_map[k]), k)
}

# ------------------------------------------- (A) Visual_volumes, internal ----
pos1 <- c("category", "species_file",
          "brain_cm3", "neo_cm3", "V1_cm3", "LGN_cm3",
          "brain_mm3", "neo_mm3", "V1_mm3", "LGN_mm3")
pos2 <- c("code", "species_file", "brain_s2", "neo_s2", "V1_s2", "LGN_s2")

s1 <- read_excel(comparison_file, sheet = "Sheet1", col_names = FALSE, col_types = "text") %>%
  slice(-seq_len(header_rows)) %>% `names<-`(pos1) %>%
  filter(!is.na(species_file), str_squish(species_file) != "") %>%
  mutate(row_id = row_number(), species_file = str_squish(species_file),
         species_key = canon(species_file),
         across(all_of(pos1[-(1:2)]), num))

s2 <- read_excel(comparison_file, sheet = "Sheet2", col_names = FALSE, col_types = "text") %>%
  slice(-seq_len(header_rows)) %>% `names<-`(pos2) %>%
  filter(!is.na(species_file), str_squish(species_file) != "") %>%
  mutate(row_id = row_number(), species_file = str_squish(species_file),
         across(all_of(pos2[-(1:2)]), num)) %>%
  select(row_id, species_s2 = species_file, brain_s2, neo_s2, V1_s2, LGN_s2)

vv <- left_join(s1, s2, by = "row_id")
measures <- c("brain", "neo", "V1", "LGN")

internal <- vv %>% select(row_id, category, species_file, species_s2, everything())
for (m in measures) {
  internal[[paste0(m, "_mm3_eq_cm3x1000")]] <-
    rel_equal(vv[[paste0(m, "_mm3")]], vv[[paste0(m, "_cm3")]] * 1000)
  internal[[paste0(m, "_sheet1_eq_sheet2")]] <-
    rel_equal(vv[[paste0(m, "_mm3")]], vv[[paste0(m, "_s2")]])
}
internal <- internal %>%
  mutate(species_rows_aligned = str_squish(species_file) == str_squish(species_s2),
         n_internal_problem = rowSums(!as.matrix(
           pick(c(ends_with("_mm3_eq_cm3x1000"), ends_with("_sheet1_eq_sheet2")))), na.rm = TRUE)) %>%
  relocate(row_id, category, species_file, species_s2, species_rows_aligned, n_internal_problem)
write_csv(internal, out_internal)

# --------------------------------------------------- (B) vs Supp. Table 2 ----
sup <- read_csv(suptable2_file, col_types = cols(.default = col_character())) %>%
  filter(!is.na(species), str_squish(species) != "") %>%
  mutate(species_key = canon(species),
         species_key_pub = canon(species_as_published),
         neocortex_was_corrected = str_detect(replace_na(correction, ""),
                                              "neocortex value corrected"))

# match on the canonical name, falling back to the published spelling
sup_keyed <- bind_rows(
  sup %>% mutate(join_key = species_key),
  sup %>% filter(species_key_pub != species_key) %>% mutate(join_key = species_key_pub)
) %>% distinct(join_key, .keep_all = TRUE)

vv_primate <- vv %>% filter(category %in% c("Simians", "Prosimians"))
vv_other   <- vv %>% filter(!category %in% c("Simians", "Prosimians"))

repB <- full_join(
  vv_primate %>% transmute(join_key = species_key, category, species_file,
                           brain_vv = brain_cm3, neo_vv = neo_cm3,
                           V1_vv = V1_cm3, LGN_vv = LGN_cm3),
  sup_keyed %>% transmute(join_key, species_sup = species,
                          species_as_published, neocortex_was_corrected,
                          brain_sup = brain_volume_cm3, neo_sup = neocortex_volume_cm3,
                          V1_sup = V1_area_striata_volume_cm3, LGN_sup = LGN_volume_cm3),
  by = "join_key")

sup_col <- c(brain = "brain_sup", neo = "neo_sup", V1 = "V1_sup", LGN = "LGN_sup")
for (m in measures) {
  repB[[paste0(m, "_match")]] <- rounds_to(repB[[paste0(m, "_vv")]], repB[[sup_col[[m]]]])
}
repB <- repB %>%
  mutate(neo_expected_correction = replace_na(neocortex_was_corrected, FALSE) & !neo_match,
         neo_match = ifelse(neo_expected_correction, NA, neo_match),
         status = case_when(
           is.na(species_sup)  ~ "comparison_only_not_in_SupTable2",
           is.na(species_file) ~ "SupTable2_only_not_in_comparison",
           TRUE                ~ "matched_by_species"),
         n_measure_mismatch = rowSums(!as.matrix(pick(all_of(paste0(measures, "_match")))), na.rm = TRUE),
         n_expected_correction = as.integer(replace_na(neo_expected_correction, FALSE))) %>%
  bind_rows(vv_other %>% transmute(
    join_key = species_key, category, species_file,
    brain_vv = brain_cm3, neo_vv = neo_cm3, V1_vv = V1_cm3, LGN_vv = LGN_cm3,
    status = "outside_deSousa_2010 (Stephan/Frahm rows in the comparison file)",
    n_measure_mismatch = 0L, n_expected_correction = 0L)) %>%
  arrange(status, join_key) %>%
  relocate(status, join_key, category, species_file, species_sup,
           n_measure_mismatch, n_expected_correction)
write_csv(repB, out_suptable2)

# --------------------------------------------------------- (C) vs V1LGN ------
v1l <- read_csv(v1lgn_file, col_types = cols(.default = col_character())) %>%
  filter(!is.na(species), str_squish(species) != "") %>%
  mutate(join_key = canon(species))

repC <- full_join(
  vv_primate %>% transmute(join_key = species_key, category, species_file,
                   V1_vv_mm3 = V1_mm3, LGN_vv_mm3 = LGN_mm3, brain_vv_mm3 = brain_mm3),
  v1l %>% transmute(join_key, species_v1lgn = species,
                    V1_ref = V1_area_striata_grey_mm3, LGN_ref = LGN_mm3,
                    brain_ref = brain_volume_mm3),
  by = "join_key")

ref_col <- c(V1 = "V1_ref", LGN = "LGN_ref", brain = "brain_ref")
for (m in names(ref_col)) {
  repC[[paste0(m, "_match")]] <- rounds_to(repC[[paste0(m, "_vv_mm3")]], repC[[ref_col[[m]]]])
}
repC <- repC %>%
  mutate(status = case_when(
           is.na(species_v1lgn) ~ "comparison_only_not_in_V1LGN",
           is.na(species_file)  ~ "V1LGN_only_not_in_comparison",
           TRUE                 ~ "matched_by_species"),
         n_measure_mismatch = rowSums(!as.matrix(pick(all_of(paste0(names(ref_col), "_match")))), na.rm = TRUE)) %>%
  arrange(status, join_key) %>%
  relocate(status, join_key, category, species_file, species_v1lgn, n_measure_mismatch)
write_csv(repC, out_v1lgn)

# ------------------------------------------------------------ mismatches -----
mismatches <- bind_rows(
  internal %>% filter(n_internal_problem > 0 | !replace_na(species_rows_aligned, TRUE)) %>%
    transmute(check = "internal_units_Sheet1_vs_Sheet2", key = species_file,
              detail = paste0("row ", row_id, "; ", n_internal_problem, " unit/alignment problem(s)")),
  repB %>% filter(!str_starts(status, "outside_deSousa_2010"),
                  status != "matched_by_species" | n_measure_mismatch > 0) %>%
    transmute(check = "vs_SupTable2", key = join_key,
              detail = paste0(status, "; ", n_measure_mismatch, " value mismatch(es)")),
  repC %>% filter(status != "matched_by_species" | n_measure_mismatch > 0) %>%
    transmute(check = "vs_V1LGN", key = join_key,
              detail = paste0(status, "; ", n_measure_mismatch, " value mismatch(es)"))
)
write_csv(mismatches, out_mismatches)

message("Visual_volumes rows: ", nrow(vv),
        " | internal problems: ", sum(internal$n_internal_problem > 0),
        " | SupTable2 matched: ", sum(repB$status == "matched_by_species"),
        ", value mismatches: ", sum(repB$status == "matched_by_species" & repB$n_measure_mismatch > 0),
        ", expected corrections: ", sum(repB$n_expected_correction, na.rm = TRUE),
        " | V1LGN matched: ", sum(repC$status == "matched_by_species"),
        ", value mismatches: ", sum(repC$status == "matched_by_species" & repC$n_measure_mismatch > 0))
