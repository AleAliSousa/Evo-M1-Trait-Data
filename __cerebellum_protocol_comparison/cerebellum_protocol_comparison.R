# =============================================================================
# cerebellum_protocol_comparison.R
#
# Cross-publication check: which cerebellum PROTOCOL does each downstream
# compilation's "cerebellum" column actually carry, and do any of them pool
# incompatible protocols in a single column?
#
# Every input is a public table in this repository, so per REPO_BOUNDARY.md
# section 3 this check lives here rather than in restricted_checks/_cross_table/.
#
# Three distinct compositions exist in the literature this repo indexes:
#   (a) cerebellum + peduncles + basal pons  -- Stephan et al. 1981 (code 7:
#       "Included are brachium and nuclei pontis"), Stephan et al. 1970
#   (b) cerebellum + peduncles, pons measured separately -- Zilles & Rehkamper
#       1988 Table 12-2 prints "Cerebellum (without pons)" and "Pons" as rows
#   (c) cerebellum only, no peduncles, no brain stem -- MacLeod et al. 2003
#       ("our study excluded the peduncles at the borders of the cerebellar
#       cortex, and did not include any brain stem structures"), MacLeod 2000
#
# All three are currently mapped to the standardized term `Cerebellum`.
#
# Outputs (written beside this script):
#   cerebellum_protocol_pooling_detail.csv
#   cerebellum_protocol_pooling_summary.csv
# =============================================================================

suppressPackageStartupMessages({
  library(readxl); library(dplyr); library(tidyr); library(readr); library(stringr)
})

SCRIPT_DIR <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else getwd()
})
REPO <- normalizePath(file.path(SCRIPT_DIR, ".."), mustWork = TRUE)
OUT  <- SCRIPT_DIR

norm_sp <- function(x) {
  x <- iconv(as.character(x), to = "ASCII//TRANSLIT", sub = "")
  x <- tolower(gsub("_", " ", trimws(x)))
  trimws(gsub(" +", " ", gsub("[^a-z ]", "", x)))
}
pct_diff <- function(a, b) ifelse(is.na(a) | is.na(b), NA_real_,
                                 round(100 * abs(a - b) / pmax(abs(a), abs(b)), 1))

## --- reference protocols ----------------------------------------------------
stephan <- read_csv(file.path(REPO, "Stephan_etal_1981",
                              "Stephan_etal_1981_TablesI-VI.csv"), show_col_types = FALSE) %>%
  transmute(k = norm_sp(Species), stephan = suppressWarnings(as.numeric(Cerebellum))) %>%
  filter(!is.na(stephan)) %>% group_by(k) %>%
  summarise(stephan = mean(stephan), .groups = "drop")

## Matano et al. 1985b ventral pons: the subtrahend that would convert a
## Stephan (pons-inclusive) cerebellum into a MacLeod-comparable one. MacLeod
## 2000 p.57 notes Matano performed this subtraction but never published the
## resulting cerebellar volumes.
matano <- read_csv(file.path(REPO, "Matano_etal_1985_b",
                             "Matano_etal_1985_b_Table1.csv"), show_col_types = FALSE) %>%
  transmute(k = norm_sp(Species), pons = suppressWarnings(as.numeric(ventral_pons_mm3))) %>%
  filter(!is.na(pons)) %>% group_by(k) %>%
  summarise(pons = mean(pons), .groups = "drop")

macleod <- read_csv(file.path(REPO, "MacLeod_etal_2003",
                              "MacLeod_etal_2003_Table1.csv"), show_col_types = FALSE) %>%
  transmute(k = norm_sp(species),
            macleod = suppressWarnings(as.numeric(cerebellum_volume_cm3)) * 1000) %>%
  filter(!is.na(macleod)) %>% group_by(k) %>%
  summarise(macleod = mean(macleod), .groups = "drop")

annotate_protocols <- function(df) {
  df %>%
    left_join(stephan, by = "k") %>%
    left_join(matano,  by = "k") %>%
    left_join(macleod, by = "k") %>%
    mutate(stephan_minus_pons_mm3 = ifelse(is.na(stephan) | is.na(pons), NA_real_,
                                           stephan - pons),
           pct_vs_stephan_raw        = pct_diff(dataset_value_mm3, stephan),
           pct_vs_stephan_minus_pons = pct_diff(dataset_value_mm3, stephan_minus_pons_mm3),
           pct_vs_macleod            = pct_diff(dataset_value_mm3, macleod),
           in_macleod_table          = !is.na(macleod))
}

## --- DeCasien & Higham 2019 -------------------------------------------------
## The supplement's own "Brain Region Data Notes" sheet, note A: "Removed
## cerebellum, replaced with measurement from [61]" -- ref 61 = MacLeod et al.
## 2003. Ref 24 = Stephan et al. 1981. BOTH appear in the same Cerebellum column.
dec <- read_excel(file.path(REPO, "DeCasien_Higham_2019",
                            "41559_2019_969_MOESM3_ESM.xlsx"),
                  sheet = "Brain Region Data (mm3)") %>%
  mutate(cb = suppressWarnings(as.numeric(Cerebellum)), refs = as.character(References)) %>%
  filter(!is.na(cb)) %>%
  rowwise() %>%
  mutate(ids = list(as.integer(unlist(str_extract_all(refs, "[0-9]+")))),
         r24 = 24L %in% ids, r61 = 61L %in% ids) %>%
  ungroup() %>%
  mutate(k = norm_sp(Taxon)) %>%
  group_by(k, r24, r61) %>%
  summarise(dataset_value_mm3 = round(mean(cb), 1), .groups = "drop") %>%
  mutate(dataset = "DeCasien_Higham_2019",
         cited_source = case_when(r24 ~ "Stephan_etal_1981 (ref 24)",
                                  r61 ~ "MacLeod_etal_2003 (ref 61)",
                                  TRUE ~ "other"),
         protocol_implied = case_when(r24 ~ "with_pons_and_peduncles",
                                      r61 ~ "sensu_stricto_no_pons_no_peduncles",
                                      TRUE ~ "unstated")) %>%
  select(-r24, -r61) %>% annotate_protocols()

## --- Smaers et al. 2018 -----------------------------------------------------
## Carries a per-row `Source` column (MacLeod et al. 2003 / Maseko et al. 2012 /
## Smaers et al. 2011), all pooled in one Cerebellum_Vol.mm3 column.
sma <- read_csv(file.path(REPO, "Smaers_etal_2018",
                          "Smaers_etal_2018_Figure2-data1.csv"), show_col_types = FALSE) %>%
  mutate(dataset_value_mm3 = suppressWarnings(as.numeric(`Cerebellum_Vol.mm3`)),
         k = norm_sp(Species_Smaers2018)) %>%
  filter(!is.na(dataset_value_mm3)) %>%
  transmute(dataset = "Smaers_etal_2018", k, dataset_value_mm3,
            cited_source = Source,
            protocol_implied = ifelse(grepl("MacLeod", Source),
                                      "sensu_stricto_no_pons_no_peduncles", "unstated")) %>%
  annotate_protocols()

DETAIL <- bind_rows(dec, sma) %>%
  transmute(dataset, species_key = k, cited_source, protocol_implied,
            dataset_value_mm3,
            stephan_1981_cerebellum_mm3   = stephan,
            matano_1985b_ventral_pons_mm3 = pons,
            stephan_minus_pons_mm3,
            macleod_2003_cerebellum_mm3   = round(macleod, 1),
            pct_vs_stephan_raw, pct_vs_stephan_minus_pons, pct_vs_macleod,
            in_macleod_table) %>%
  arrange(dataset, cited_source, species_key)

write_csv(DETAIL, file.path(OUT, "cerebellum_protocol_pooling_detail.csv"))

SUMMARY <- DETAIL %>%
  group_by(dataset, cited_source, protocol_implied) %>%
  summarise(n_species = n_distinct(species_key),
            n_in_macleod_table        = sum(in_macleod_table),
            median_pct_vs_stephan_raw = median(pct_vs_stephan_raw, na.rm = TRUE),
            median_pct_vs_macleod     = median(pct_vs_macleod, na.rm = TRUE),
            .groups = "drop")
write_csv(SUMMARY, file.path(OUT, "cerebellum_protocol_pooling_summary.csv"))

## --- the allometry behind the "pons is negligible" justification ------------
allo <- inner_join(stephan, matano, by = "k") %>%
  filter(stephan > 0, pons > 0) %>% mutate(pct = 100 * pons / stephan)
fit <- lm(log10(pons) ~ log10(stephan), data = allo)
ci  <- confint(fit)[2, ]
rho <- suppressWarnings(cor(log10(allo$stephan), allo$pct, method = "spearman"))

message("\n== cerebellum protocol pooling ==")
print(as.data.frame(SUMMARY))
message(sprintf(
  "\nventral pons as %% of Stephan cerebellum (n=%d): median %.1f%%, range %.1f-%.1f%%",
  nrow(allo), median(allo$pct), min(allo$pct), max(allo$pct)))
message(sprintf(
  "allometric slope log10(pons)~log10(cerebellum) = %.3f [%.3f, %.3f]; Spearman rho = %.3f",
  coef(fit)[2], ci[1], ci[2], rho))
message("slope > 1 => the excluded pons is a LARGER share in larger cerebella, so the")
message("'negligible, especially in larger-brained primates' justification inverts the gradient.")
