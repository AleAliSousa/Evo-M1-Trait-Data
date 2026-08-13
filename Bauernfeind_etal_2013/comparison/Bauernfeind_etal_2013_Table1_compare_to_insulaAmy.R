# Bauernfeind_etal_2013_Table1_compare_to_insulaAmy.R
#
# Checking step (self-contained in comparison/). insulaAmy.xls is an independently
# held per-INDIVIDUAL copy of the Bauernfeind et al. (2013) insula volumes, in cm3,
# with one row per hemisphere. Sheet1 columns are: Species | Brain Mass (g) |
# Hemisphere | Total (cm3) | "LR or 2x" (cm3). The species label and brain mass
# appear only on the first row of each individual, so records are rebuilt by
# forward block, not by fill-down. Sheet2 is a species-level digest.
#
# The project extraction (../Bauernfeind_etal_2013_Table1.csv) holds the LEFT
# hemisphere only, in mm3, as published. So:
#   individual check - insulaAmy `Total` on the Left/L row * 1000 vs total_insula_L_mm3,
#                      matched on canonical species + brain mass (g). Leftovers are
#                      paired within species by descending brain mass and flagged
#                      matched_by_species_rank, so a suspected row swap surfaces as a
#                      value mismatch rather than as two unmatched rows.
#   doubling audit   - "LR or 2x" should be L+R where both hemispheres were measured
#                      and 2x the measured hemisphere otherwise. The basis used is
#                      recorded (doubling is provenance, not a skip flag).
#   species check    - Sheet2 vs the mean of Sheet1 "LR or 2x" by species, and against
#                      the merge convention (mean of 2 x left) for reference. Where the
#                      two differ the cause is the doubling basis, not a value error.
#
# Inputs : insulaAmy.xls (Sheet1, Sheet2) ; ../Bauernfeind_etal_2013_Table1.csv
# Outputs: Bauernfeind_etal_2013_insulaAmy_individual_report_from_R.csv
#          Bauernfeind_etal_2013_insulaAmy_species_report_from_R.csv
#          Bauernfeind_etal_2013_insulaAmy_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})

## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Bauernfeind_etal_2013/comparison")

comparison_file  <- "insulaAmy.xls"
table1_file      <- "../Bauernfeind_etal_2013_Table1.csv"
out_individual   <- "Bauernfeind_etal_2013_insulaAmy_individual_report_from_R.csv"
out_species      <- "Bauernfeind_etal_2013_insulaAmy_species_report_from_R.csv"
out_mismatches   <- "Bauernfeind_etal_2013_insulaAmy_mismatches_from_R.csv"
tol_mm3          <- 1.0    # the published table is integer mm3
tol_mass_g       <- 0.05   # brain mass printed to 0.1 g

# ---------------------------------------------------------------- helpers ----
na_tokens <- c("", "-", "–", "—", "NA", "n.a.", "_", "__")
num <- function(x) suppressWarnings(parse_number(as.character(x), na = na_tokens))
canon_map <- c("pongo abelli" = "pongo abelii", "varecia variegatus" = "varecia variegata",
               "cebuella pygmaea" = "callithrix pygmaea",
               "procolobus badius" = "piliocolobus badius")
canon <- function(x) {
  k <- str_squish(tolower(str_replace_all(as.character(x), "_", " ")))
  ifelse(k %in% names(canon_map), unname(canon_map[k]), k)
}
close_to <- function(a, b, tol) (is.na(a) & is.na(b)) |
  (!is.na(a) & !is.na(b) & abs(a - b) <= tol)

# ------------------------------------------ comparison side: per individual --
pos <- c("species_file", "brain_mass_g", "hemisphere", "total_cm3", "doubled_cm3")
raw <- read_excel(comparison_file, sheet = "Sheet1", col_names = FALSE, col_types = "text")
raw <- raw[, seq_len(length(pos))] %>% `names<-`(pos) %>%
  filter(!(is.na(hemisphere) & is.na(total_cm3) & is.na(species_file)))
# drop the two header lines (blank line + labels)
raw <- raw %>% filter(is.na(hemisphere) | !str_detect(tolower(hemisphere), "^hemisphere"))

rec <- raw %>%
  mutate(is_start = !is.na(species_file) & str_squish(species_file) != "",
         record_id = cumsum(is_start)) %>%
  filter(record_id > 0) %>%
  group_by(record_id) %>%
  mutate(species_file = str_squish(first(species_file[is_start])),
         brain_mass_g = num(first(brain_mass_g[is_start])),
         doubled_cm3  = num(first(doubled_cm3))) %>%
  ungroup() %>%
  mutate(side = case_when(str_starts(str_squish(tolower(replace_na(hemisphere, ""))), "l") ~ "L",
                          str_starts(str_squish(tolower(replace_na(hemisphere, ""))), "r") ~ "R",
                          TRUE ~ NA_character_),
         total_cm3 = num(total_cm3))

# NB: not named `pick` - dplyr expands a top-level pick() call inside summarise()
# as a tidyselect selection, which would swallow this helper.
pick_side <- function(v, s, want) {
  i <- which(s == want & !is.na(v))
  if (length(i) == 0) NA_real_ else v[i[1]]
}
cmp <- rec %>% group_by(record_id, species_file, brain_mass_g, doubled_cm3) %>%
  summarise(left_cm3  = pick_side(total_cm3, side, "L"),
            right_cm3 = pick_side(total_cm3, side, "R"),
            n_hemispheres_listed = sum(!is.na(side)), .groups = "drop") %>%
  mutate(species_key = canon(species_file),
         left_mm3  = left_cm3 * 1000,
         right_mm3 = right_cm3 * 1000,
         doubling_basis = case_when(
           !is.na(left_cm3) & !is.na(right_cm3) ~ "L+R",
           !is.na(left_cm3)                     ~ "2 x left",
           !is.na(right_cm3)                    ~ "2 x right (left not measured)",
           TRUE                                 ~ NA_character_),
         doubled_expected = case_when(
           doubling_basis == "L+R" ~ left_cm3 + right_cm3,
           doubling_basis == "2 x left" ~ 2 * left_cm3,
           str_starts(replace_na(doubling_basis, ""), "2 x right") ~ 2 * right_cm3,
           TRUE ~ NA_real_),
         doubling_ok = close_to(doubled_cm3, doubled_expected, 1e-6))

# --------------------------------------------------- extraction side ---------
tab1 <- read_csv(table1_file, col_types = cols(.default = col_character())) %>%
  filter(!is.na(Species), str_squish(Species) != "") %>%
  transmute(individual = Individual, collection = Collection,
            species_csv = str_squish(Species), species_key = canon(Species),
            brain_mass_g_csv = num(brain_mass_mg) / 1000,
            total_insula_L_mm3 = num(total_insula_L_mm3))

# stage 1: species + brain mass ; stage 2: leftovers ranked within species
m1 <- cmp %>% inner_join(tab1, by = "species_key", relationship = "many-to-many") %>%
  filter(close_to(brain_mass_g, brain_mass_g_csv, tol_mass_g)) %>%
  distinct(record_id, .keep_all = TRUE) %>% distinct(individual, .keep_all = TRUE) %>%
  mutate(match_basis = "species + brain mass")

left_cmp <- cmp  %>% filter(!record_id %in% m1$record_id)
left_csv <- tab1 %>% filter(!individual %in% m1$individual)
m2 <- inner_join(
  left_cmp %>% group_by(species_key) %>% arrange(desc(brain_mass_g), .by_group = TRUE) %>%
    mutate(rk = row_number()) %>% ungroup(),
  left_csv %>% group_by(species_key) %>% arrange(desc(brain_mass_g_csv), .by_group = TRUE) %>%
    mutate(rk = row_number()) %>% ungroup(),
  by = c("species_key", "rk")) %>%
  select(-rk) %>% mutate(match_basis = "species + brain-mass rank (approximate)")

matched <- bind_rows(m1, m2)
individual_report <- bind_rows(
  matched %>% mutate(status = "matched"),
  left_cmp %>% filter(!record_id %in% m2$record_id) %>% mutate(status = "comparison_only_not_in_Table1"),
  left_csv %>% filter(!individual %in% m2$individual) %>% mutate(status = "Table1_only_not_in_comparison")
) %>%
  mutate(left_diff_mm3 = left_mm3 - total_insula_L_mm3,
         left_match = close_to(left_mm3, total_insula_L_mm3, tol_mm3),
         brain_mass_match = close_to(brain_mass_g, brain_mass_g_csv, tol_mass_g)) %>%
  arrange(status, species_key, desc(brain_mass_g)) %>%
  relocate(status, match_basis, species_key, species_file, species_csv, individual,
           brain_mass_g, brain_mass_g_csv, brain_mass_match,
           left_mm3, total_insula_L_mm3, left_diff_mm3, left_match,
           right_mm3, doubling_basis, doubled_cm3, doubled_expected, doubling_ok)
write_csv(individual_report, out_individual)

# --------------------------------------------------- species-level digest ----
sheet2 <- read_excel(comparison_file, sheet = "Sheet2", col_names = FALSE, col_types = "text") %>%
  `names<-`(c("species_file", "insula_cm3")) %>%
  filter(!is.na(species_file),
         !str_detect(tolower(str_squish(species_file)), "^species$")) %>%
  transmute(species_key = canon(species_file), sheet2_species = str_squish(species_file),
            sheet2_insula_cm3 = num(insula_cm3))

sheet1_sp <- cmp %>% group_by(species_key) %>%
  summarise(n_individuals_cmp = n(),
            sheet1_mean_doubled_cm3 = mean(doubled_cm3, na.rm = TRUE),
            doubling_bases = paste(sort(unique(na.omit(doubling_basis))), collapse = "; "),
            .groups = "drop")

# a species-level digest row can also be a genus-pooled (sensu lato) mean, e.g.
# "Pongo pygmaeus" covering P. pygmaeus + P. abelii. Compute that too, so the
# basis of each digest value is identified rather than reported as a mismatch.
genus_mean <- cmp %>% mutate(genus = word(species_key, 1)) %>% group_by(genus) %>%
  summarise(n_individuals_genus = n(),
            genus_mean_doubled_cm3 = mean(doubled_cm3, na.rm = TRUE),
            congeners = paste(sort(unique(species_key)), collapse = " + "), .groups = "drop")

csv_sp <- tab1 %>% group_by(species_key) %>%
  summarise(n_individuals_csv = n(),
            csv_mean_2x_left_cm3 = mean(2 * total_insula_L_mm3, na.rm = TRUE) / 1000,
            .groups = "drop") %>%
  mutate(csv_mean_2x_left_cm3 = ifelse(is.nan(csv_mean_2x_left_cm3), NA_real_, csv_mean_2x_left_cm3))

species_report <- sheet2 %>%
  full_join(sheet1_sp, by = "species_key") %>%
  full_join(csv_sp,    by = "species_key") %>%
  mutate(genus = word(species_key, 1)) %>%
  left_join(genus_mean, by = "genus") %>%
  mutate(sheet2_eq_sheet1_mean = close_to(sheet2_insula_cm3, sheet1_mean_doubled_cm3, 1e-6),
         sheet2_eq_genus_mean  = close_to(sheet2_insula_cm3, genus_mean_doubled_cm3, 1e-6),
         sheet2_basis = case_when(
           is.na(sheet2_insula_cm3)   ~ NA_character_,
           sheet2_eq_sheet1_mean      ~ "species mean of the doubled values",
           sheet2_eq_genus_mean       ~ paste0("GENUS-POOLED (sensu lato) mean over ", congeners),
           TRUE                       ~ "unresolved - neither the species nor the genus mean"),
         sheet2_vs_csv_diff_cm3 = sheet2_insula_cm3 - csv_mean_2x_left_cm3,
         note = case_when(
           is.na(sheet2_insula_cm3) & is.na(n_individuals_cmp) ~ "in Table1 only (not in the comparison file)",
           is.na(sheet2_insula_cm3) ~ "no Sheet2 digest row for this species",
           is.na(csv_mean_2x_left_cm3) ~ "in comparison file only",
           !sheet2_eq_sheet1_mean ~ "digest label is broader than the species - do not read as a species mean",
           str_detect(replace_na(doubling_bases, ""), "L\\+R") ~
             "expected offset: digest doubles as L+R, merge convention doubles the left",
           TRUE ~ "same doubling basis")) %>%
  arrange(species_key) %>%
  relocate(species_key, sheet2_species, n_individuals_cmp, n_individuals_csv,
           sheet2_insula_cm3, sheet1_mean_doubled_cm3, sheet2_eq_sheet1_mean,
           sheet2_basis, csv_mean_2x_left_cm3, sheet2_vs_csv_diff_cm3,
           doubling_bases, note)
write_csv(species_report, out_species)

# ------------------------------------------------------------ mismatches -----
mismatches <- bind_rows(
  individual_report %>%
    filter(status != "matched" | !replace_na(left_match, FALSE) |
             !replace_na(doubling_ok, TRUE) | !replace_na(brain_mass_match, TRUE)) %>%
    transmute(check = "individual", key = coalesce(species_key, species_csv),
              detail = paste0(status,
                              ifelse(replace_na(left_match, TRUE), "",
                                     paste0("; left insula ", round(left_mm3, 1), " vs ",
                                            total_insula_L_mm3, " mm3")),
                              ifelse(replace_na(doubling_ok, TRUE), "", "; doubling not reproduced"))),
  species_report %>% filter(!is.na(sheet2_insula_cm3),
                            !replace_na(sheet2_eq_sheet1_mean, TRUE)) %>%
    transmute(check = "species_digest", key = species_key,
              detail = paste0("Sheet2 value is not the species mean of the Sheet1 doubled values; ",
                              sheet2_basis))
)
write_csv(mismatches, out_mismatches)

message("comparison individuals: ", nrow(cmp), " | Table1 individuals: ", nrow(tab1),
        " | matched: ", sum(individual_report$status == "matched"),
        " (by mass: ", sum(replace_na(individual_report$match_basis, "") == "species + brain mass"), ")",
        " | left-volume mismatches: ",
        sum(individual_report$status == "matched" & !replace_na(individual_report$left_match, FALSE)),
        " | comparison-only: ", sum(individual_report$status == "comparison_only_not_in_Table1"),
        " | Table1-only: ", sum(individual_report$status == "Table1_only_not_in_comparison"))
