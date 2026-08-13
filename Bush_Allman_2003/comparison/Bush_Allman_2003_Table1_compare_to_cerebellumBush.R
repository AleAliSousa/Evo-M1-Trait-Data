# Bush_Allman_2003_Table1_compare_to_cerebellumBush.R
#
# Checking step (self-contained in comparison/). cerebellumBush.xls (sheet
# `table_bush.txt`) is an independently held copy of Bush & Allman (2003) Table 1:
# two grouping columns (order, then the primate sub-clade) followed by Species |
# Cer_White | Cer_Gray | Neo_White | Neo_Gray, all cm3 and all at the published
# 3-significant-figure precision. The project extraction
# (../Bush_Allman_2003_Table1.csv) holds the same four measures with a single
# `group` column using the paper's analysis grade (Apes / Old World Monkeys /
# New World Monkeys / Tarsier / Strepsirrhines / ...). The two labelling schemes
# are reported side by side and NOT asserted equal; only the four volumes are
# audited. Comparison is rounding-aware against the precision printed in the CSV.
#
# Inputs : cerebellumBush.xls (sheet `table_bush.txt`) ; ../Bush_Allman_2003_Table1.csv
# Outputs: Bush_Allman_2003_cerebellumBush_report_from_R.csv
#          Bush_Allman_2003_cerebellumBush_mismatches_from_R.csv

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(tidyr); library(stringr)
})

## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/Bush_Allman_2003/comparison")

comparison_file <- "cerebellumBush.xls"
comparison_sheet <- "table_bush.txt"
table1_file     <- "../Bush_Allman_2003_Table1.csv"
out_report      <- "Bush_Allman_2003_cerebellumBush_report_from_R.csv"
out_mismatches  <- "Bush_Allman_2003_cerebellumBush_mismatches_from_R.csv"

measures <- c("cer_white", "cer_gray", "neo_white", "neo_gray")

# ---------------------------------------------------------------- helpers ----
na_tokens <- c("", "-", "–", "—", "NA", "n.a.", "_", "__")
num <- function(x) suppressWarnings(parse_number(as.character(x), na = na_tokens))
key <- function(x) str_squish(tolower(str_replace_all(as.character(x), "_", " ")))
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

# ------------------------------------------------- comparison side -----------
pos <- c("order_file", "clade_file", "species_file",
         "cer_white_cmp", "cer_gray_cmp", "neo_white_cmp", "neo_gray_cmp")
cmp <- read_excel(comparison_file, sheet = comparison_sheet,
                  col_names = FALSE, col_types = "text") %>%
  `names<-`(pos) %>%
  filter(!is.na(species_file), key(species_file) != "species") %>%
  mutate(species_file = str_squish(species_file), species_key = key(species_file),
         across(all_of(pos[4:7]), num))

# ------------------------------------------------- extraction side -----------
csv <- read_csv(table1_file, col_types = cols(.default = col_character())) %>%
  filter(!is.na(species), str_squish(species) != "") %>%
  transmute(species_csv = str_squish(species), species_key = key(species), group_csv = group,
            cer_white_txt = cer_white_cm3, cer_gray_txt = cer_gray_cm3,
            neo_white_txt = neo_white_cm3, neo_gray_txt = neo_gray_cm3)

# ---------------------------------------------------------------- compare ----
report <- full_join(cmp, csv, by = "species_key")
for (m in measures) {
  report[[paste0(m, "_match")]] <-
    rounds_to(report[[paste0(m, "_cmp")]], report[[paste0(m, "_txt")]])
}
report <- report %>%
  mutate(status = case_when(is.na(species_csv)  ~ "comparison_only_not_in_Table1",
                            is.na(species_file) ~ "Table1_only_not_in_comparison",
                            TRUE                ~ "matched_by_species"),
         n_measure_mismatch = rowSums(!as.matrix(pick(all_of(paste0(measures, "_match")))), na.rm = TRUE)) %>%
  arrange(status, species_key) %>%
  relocate(status, species_key, species_file, species_csv, n_measure_mismatch,
           order_file, clade_file, group_csv)
write_csv(report, out_report)

mismatches <- report %>% filter(status != "matched_by_species" | n_measure_mismatch > 0)
write_csv(mismatches, out_mismatches)

message("comparison species: ", nrow(cmp), " | Table1 species: ", nrow(csv),
        " | matched: ", sum(report$status == "matched_by_species"),
        " | value mismatches: ", sum(report$status == "matched_by_species" & report$n_measure_mismatch > 0),
        " | comparison-only: ", sum(report$status == "comparison_only_not_in_Table1"),
        " | Table1-only: ", sum(report$status == "Table1_only_not_in_comparison"))
