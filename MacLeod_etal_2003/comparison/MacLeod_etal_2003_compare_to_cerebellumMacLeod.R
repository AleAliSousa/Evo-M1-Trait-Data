# MacLeod_etal_2003_compare_to_cerebellumMacLeod.R
#
# Checking step (self-contained in comparison/). cerebellumMacLeod.xlsx is an
# independently held copy of the MacLeod et al. (2003) cerebellar volumes:
#   sheet `specimens` - one row per specimen (Species | Brain | Cerebellum |
#                       Vermis | Hemisphere, all cm3), NO specimen identifier,
#                       Table 2 (Hirnforschung) block first, then Table 1 (Yerkes).
#   sheet `species`   - species means.
# The project extraction keeps the two published tables apart and carries the
# specimen labels, so two independent specimen matches are run:
#   positional - the comparison sheet against Table2 then Table1 in file order.
#                This is what assigns a specimen label to each comparison row.
#   value      - greedy one-to-one pairing within species on all four volumes.
#                Needed because e.g. Pan troglodytes (YN89-278) and
#                (Schimpanse 278) share a brain volume of 405.4 cm3, so a naive
#                key join would double-count them.
# Disagreement between the two matches is the signal worth reading.
# Species means are recomputed from the extraction with na.rm = TRUE (the
# comparison file averages over the specimens that have the measure, e.g. vermis
# for Pan troglodytes over 13 of 14 specimens) and compared rounding-aware.
#
# Inputs : cerebellumMacLeod.xlsx (sheets `specimens`, `species`)
#          ../MacLeod_etal_2003_Table1.csv ; ../MacLeod_etal_2003_Table2.csv
# Outputs: MacLeod_etal_2003_cerebellumMacLeod_specimen_report_from_R.csv
#          MacLeod_etal_2003_cerebellumMacLeod_species_report_from_R.csv
#          MacLeod_etal_2003_cerebellumMacLeod_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})

## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/MacLeod_etal_2003/comparison")

comparison_file <- "cerebellumMacLeod.xlsx"
table1_file     <- "../MacLeod_etal_2003_Table1.csv"   # Yerkes
table2_file     <- "../MacLeod_etal_2003_Table2.csv"   # Hirnforschung
out_specimen    <- "MacLeod_etal_2003_cerebellumMacLeod_specimen_report_from_R.csv"
out_species     <- "MacLeod_etal_2003_cerebellumMacLeod_species_report_from_R.csv"
out_mismatches  <- "MacLeod_etal_2003_cerebellumMacLeod_mismatches_from_R.csv"
tol             <- 0.05    # published to 1 decimal place

measures <- c("brain", "cerebellum", "vermis", "hemisphere")

# ---------------------------------------------------------------- helpers ----
na_tokens <- c("", "-", "–", "—", "NA", "n.a.", "_", "__")
num <- function(x) suppressWarnings(parse_number(as.character(x), na = na_tokens))
key <- function(x) str_squish(tolower(as.character(x)))
close_to <- function(a, b, tol) (is.na(a) & is.na(b)) |
  (!is.na(a) & !is.na(b) & abs(a - b) <= tol)
dp_of <- function(s) ifelse(is.na(s) | !str_detect(s, "\\."), 0L,
                            nchar(str_extract(s, "(?<=\\.)\\d+")))
# NA (not FALSE) when the extraction is blank but the comparison file has a value
rounds_to <- function(a, b_txt) {
  b <- num(b_txt); d <- dp_of(b_txt)
  as.logical(ifelse(is.na(a) & is.na(b), TRUE,
             ifelse(is.na(a) & !is.na(b), FALSE,
             ifelse(!is.na(a) & is.na(b), NA,
                    abs(a - b) <= 0.5 * 10^(-d) + 1e-9))))
}
# signature used for value matching: all four volumes at the printed precision
sig <- function(d) paste(sapply(d[paste0(measures, "_cmp")], function(v)
  ifelse(is.na(v), "NA", formatC(round(v, 1), format = "f", digits = 1))), collapse = "|")

# ------------------------------------------------- comparison side -----------
pos <- c("species_file", "brain_cmp", "cerebellum_cmp", "vermis_cmp", "hemisphere_cmp")
cmp <- read_excel(comparison_file, sheet = "specimens", col_names = FALSE, col_types = "text") %>%
  `names<-`(pos) %>%
  filter(!is.na(species_file), key(species_file) != "species") %>%
  mutate(cmp_row = row_number(), species_file = str_squish(species_file),
         species_key = key(species_file), across(all_of(pos[-1]), num))
cmp$sig <- vapply(seq_len(nrow(cmp)), function(i) sig(cmp[i, ]), character(1))

# ------------------------------------------------- extraction side -----------
read_tab <- function(f, tbl) read_csv(f, col_types = cols(.default = col_character())) %>%
  filter(!is.na(species), str_squish(species) != "") %>%
  transmute(table = tbl, species_csv = str_squish(species), species_key = key(species),
            specimen, sample,
            brain_csv_txt = brain_volume_cm3, cerebellum_csv_txt = cerebellum_volume_cm3,
            vermis_csv_txt = vermis_volume_cm3, hemisphere_csv_txt = hemisphere_volume_cm3,
            brain_csv = num(brain_volume_cm3), cerebellum_csv = num(cerebellum_volume_cm3),
            vermis_csv = num(vermis_volume_cm3), hemisphere_csv = num(hemisphere_volume_cm3))

# file order in the comparison sheet is Table 2 first, then Table 1
csv <- bind_rows(read_tab(table2_file, "Table2"), read_tab(table1_file, "Table1")) %>%
  mutate(csv_row = row_number())
csv$sig <- vapply(seq_len(nrow(csv)), function(i)
  paste(sapply(csv[i, paste0(measures, "_csv")], function(v)
    ifelse(is.na(v), "NA", formatC(round(v, 1), format = "f", digits = 1))), collapse = "|"),
  character(1))

# --- (1) positional match ----------------------------------------------------
positional <- full_join(cmp, csv, by = c("cmp_row" = "csv_row"), suffix = c("", "_csv2")) %>%
  rename(row_index = cmp_row) %>%
  mutate(positional_species_agree = key(species_file) == key(species_csv))

# --- (2) value match, greedy one-to-one within species -----------------------
pairs <- inner_join(cmp %>% select(cmp_row, species_key, sig),
                    csv %>% select(csv_row, species_key, sig, specimen, table),
                    by = c("species_key", "sig"), relationship = "many-to-many") %>%
  arrange(cmp_row, csv_row)
used_c <- integer(0); used_s <- integer(0); keep <- logical(nrow(pairs))
for (i in seq_len(nrow(pairs))) {
  if (!(pairs$cmp_row[i] %in% used_c) && !(pairs$csv_row[i] %in% used_s)) {
    keep[i] <- TRUE; used_c <- c(used_c, pairs$cmp_row[i]); used_s <- c(used_s, pairs$csv_row[i])
  }
}
value_pairs <- pairs[keep, ] %>% select(cmp_row, csv_row, value_specimen = specimen, value_table = table)

specimen_report <- positional %>%
  left_join(value_pairs, by = c("row_index" = "cmp_row")) %>%
  mutate(status = case_when(
    is.na(species_csv)  ~ "comparison_only_not_in_extraction",
    is.na(species_file) ~ "extraction_only_not_in_comparison",
    TRUE                ~ "matched_positionally"),
    value_match_found = !is.na(value_specimen),
    positional_eq_value_match = replace_na(specimen == value_specimen, FALSE))
for (m in measures) {
  specimen_report[[paste0(m, "_match")]] <-
    rounds_to(specimen_report[[paste0(m, "_cmp")]], specimen_report[[paste0(m, "_csv_txt")]])
}
specimen_report <- specimen_report %>%
  mutate(n_measure_mismatch = rowSums(!as.matrix(pick(all_of(paste0(measures, "_match")))), na.rm = TRUE)) %>%
  arrange(row_index) %>%
  relocate(status, row_index, table, specimen, species_file, species_csv,
           positional_species_agree, value_match_found, value_specimen,
           positional_eq_value_match, n_measure_mismatch)
write_csv(specimen_report, out_specimen)

# --- species means -----------------------------------------------------------
cmp_sp <- read_excel(comparison_file, sheet = "species", col_names = FALSE, col_types = "text") %>%
  `names<-`(pos) %>%
  filter(!is.na(species_file), key(species_file) != "species") %>%
  mutate(species_file = str_squish(species_file), species_key = key(species_file),
         across(all_of(pos[-1]), num))

csv_sp <- csv %>% group_by(species_key) %>%
  summarise(species_csv = first(species_csv), n_specimens_csv = n(),
            across(all_of(paste0(measures, "_csv")),
                   ~ { v <- mean(.x, na.rm = TRUE); ifelse(is.nan(v), NA_real_, v) }),
            .groups = "drop")

# the comparison file's own specimen sheet, aggregated the same way. If the
# digest disagrees with BOTH this and the extraction, the digest itself dropped a
# specimen; if it disagrees with the extraction only, the values differ.
cmp_own <- cmp %>% group_by(species_key) %>%
  summarise(n_specimens_cmp = n(),
            across(all_of(paste0(measures, "_cmp")),
                   ~ { v <- mean(.x, na.rm = TRUE); ifelse(is.nan(v), NA_real_, v) },
                   .names = "{.col}_from_specimens"),
            .groups = "drop")

species_report <- cmp_sp %>%
  full_join(cmp_own, by = "species_key") %>%
  full_join(csv_sp,  by = "species_key")
for (m in measures) {
  species_report[[paste0(m, "_match")]] <-
    close_to(species_report[[paste0(m, "_cmp")]], species_report[[paste0(m, "_csv")]], 1e-6)
  species_report[[paste0(m, "_digest_eq_own_specimens")]] <-
    close_to(species_report[[paste0(m, "_cmp")]],
             species_report[[paste0(m, "_cmp_from_specimens")]], 1e-6)
}
species_report <- species_report %>%
  mutate(status = case_when(is.na(species_csv)  ~ "comparison_only_not_in_extraction",
                            is.na(species_file) ~ "extraction_only_not_in_comparison",
                            TRUE                ~ "matched_by_species"),
         n_measure_mismatch = rowSums(!as.matrix(pick(all_of(paste0(measures, "_match")))), na.rm = TRUE),
         n_digest_self_mismatch = rowSums(!as.matrix(pick(all_of(paste0(measures, "_digest_eq_own_specimens")))), na.rm = TRUE),
         mean_note = case_when(
           n_measure_mismatch == 0 ~ "means agree",
           n_digest_self_mismatch > 0 ~ paste0("digest does not average this file's own ",
                                               n_specimens_cmp, " specimen rows - specimen(s) dropped from the digest"),
           TRUE ~ "digest reproduces this file's specimens but differs from the extraction")) %>%
  arrange(species_key) %>%
  relocate(status, species_key, species_file, species_csv,
           n_specimens_cmp, n_specimens_csv, n_measure_mismatch,
           n_digest_self_mismatch, mean_note)
write_csv(species_report, out_species)

# ------------------------------------------------------------ mismatches -----
mismatches <- bind_rows(
  specimen_report %>%
    filter(status != "matched_positionally" | n_measure_mismatch > 0 |
             !replace_na(positional_species_agree, FALSE) | !value_match_found) %>%
    transmute(check = "specimen", key = coalesce(species_file, species_csv),
              detail = paste0(status, "; row ", row_index, "; ", specimen,
                              "; ", n_measure_mismatch, " value mismatch(es)",
                              ifelse(value_match_found, "", "; no one-to-one value match"))),
  species_report %>% filter(status != "matched_by_species" | n_measure_mismatch > 0) %>%
    transmute(check = "species_mean", key = species_key,
              detail = paste0(status, "; ", n_measure_mismatch, " mean mismatch(es); ", mean_note))
)
write_csv(mismatches, out_mismatches)

message("comparison specimens: ", nrow(cmp), " | extraction specimens: ", nrow(csv),
        " | positional value mismatches: ",
        sum(specimen_report$status == "matched_positionally" & specimen_report$n_measure_mismatch > 0),
        " | rows without a one-to-one value match: ", sum(!specimen_report$value_match_found),
        " | positional == value match: ", sum(specimen_report$positional_eq_value_match),
        " | species means matched: ", sum(species_report$status == "matched_by_species" &
                                            species_report$n_measure_mismatch == 0),
        "/", nrow(species_report))
