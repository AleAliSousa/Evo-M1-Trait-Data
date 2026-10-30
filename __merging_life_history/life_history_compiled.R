## =============================================================================
## life_history_compiled.R -- reproductive life-history merge: Asdell's root compendium
## (Hayssen et al. 1993, per-value cited) + the compilations that cite it
## (PanTHERIA WR05, AnAge build 15, Ernest 2003, Myhrvold 2015 Amniote database).
## =============================================================================
## Everything is harvested from __Public/comparative-data (the registered TSVs); nothing
## is read across the public/private boundary. The comparison that judges these data
## against each other lives in Evo-M1-Trait-Data-restricted/__life_history_root_comparison.
##
## Outputs (this folder)
##   life_history_source_columns.csv   the crosswalk used: dataset, source column/topic ->
##                                     canonical Measure, unit scale, admission rule
##   life_history_unfiltered.csv       ONE ROW PER SOURCE RECORD, nothing dropped: every Hayssen
##                                     data line of a mapped topic and every compilation cell of a
##                                     mapped column, with value_canonical, admission + reason,
##                                     cites_hayssen, species resolution
##   life_history_long.csv             one row per Species x Measure: Hayssen summary (median,
##                                     n lines, range, cited reference numbers) and the pooled
##                                     value over INDEPENDENT parties (a compilation value whose
##                                     record cites Hayssen is derived, not independent)
##   life_history_wide.csv             Species x Measure matrix of the pooled value
##
## Pooling rule (compilation-aware). Parties for a Species x Measure are: the root (Hayssen,
## median of its admitted lines) and each compilation whose record does NOT cite Hayssen for
## that species. Value = median over parties. Records that cite Hayssen are counted
## (n_derived) and kept in the unfiltered table but do not enter the pooled value, because
## they re-export the root. No value is changed; disagreement between parties is flagged, not
## resolved (disagreement = max/min over parties > 1.25, or absolute difference > 1 for counts).
## Conventions: input problems stop(); every count is printed; CSVs written with a UTF-8 BOM.
## =============================================================================
options(stringsAsFactors = FALSE, scipen = 999, width = 200)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (!is.null(of) && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) { p <- rstudioapi::getActiveDocumentContext()$path; if (nzchar(p)) return(normalizePath(p)) }
  stop("Run with Rscript, or source() from a file.", call. = FALSE)
})
out <- dirname(.sp)
repo <- local({ d <- out; while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d); if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("repo root not found above ", out, call. = FALSE); d })
pub <- file.path(repo, "__Public", "comparative-data")
## a UTF-8 LC_CTYPE is required: in the C locale paste()/collapse mangles the non-ASCII folder name deMagalhães_etal_2024
## (embedded NUL bytes were written before this guard existed)
ctype_ok <- any(vapply(c("en_US.UTF-8", "C.UTF-8"), function(l) tryCatch({ Sys.setlocale("LC_CTYPE", l); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed = TRUE) }, error = function(e) FALSE), logical(1)))
if (!ctype_ok) stop("No UTF-8 LC_CTYPE locale available.", call. = FALSE)
for (p in c("readr", "dplyr", "stringr", "tidyr")) if (!requireNamespace(p, quietly = TRUE)) stop("Install package: ", p, call. = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr); library(tidyr) })
source(file.path(repo, "_keys", "resolve_species.R"))
read_bom <- function(f, delim = ",") { if (!file.exists(f)) stop("Missing input: ", f, call. = FALSE); d <- read_delim(f, delim = delim, show_col_types = FALSE, col_types = cols(.default = "c"), na = character(), progress = FALSE)
  pr <- problems(d); if (nrow(pr)) { print(as.data.frame(head(pr, 5))); stop("parsing problems in ", basename(f), call. = FALSE) }; d }
write_bom <- function(x, f) { write_excel_csv(x, f, na = ""); rb <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"), progress = FALSE)
  pr <- problems(rb); if (nrow(pr)) { print(as.data.frame(head(pr, 5))); stop("parsing problems reading back ", f, call. = FALSE) }
  if (nrow(rb) != nrow(x)) stop("row count changed on write: ", f, call. = FALSE); cat("  written", basename(f), nrow(x), "rows\n") }
num <- function(x) suppressWarnings(as.numeric(x))

## ---- canonical measures (names and units shared with the restricted comparison's trait crosswalk) ----
MEASURES <- tribble(~Measure, ~Units, ~measure_class,
  "neonate_body_mass_g",          "g",  "reproduction",
  "weaning_body_mass_g",          "g",  "reproduction",
  "litter_size_n",                "n",  "reproduction",
  "litters_per_year_n",           "n",  "reproduction",
  "gestation_d",                  "d",  "reproduction",
  "weaning_age_d",                "d",  "reproduction",
  "interbirth_interval_d",        "d",  "reproduction",
  "female_maturity_age_d",        "d",  "reproduction",
  "male_maturity_age_d",          "d",  "reproduction",
  "neonate_head_body_length_mm",  "mm", "reproduction",
  "weaning_head_body_length_mm",  "mm", "reproduction",
  "estrous_cycle_length_d",       "d",  "reproduction",
  "age_at_first_reproduction_d",  "d",  "reproduction",
  "maximum_longevity_y",          "y",  "longevity",
  "adult_body_mass_g",            "g",  "mass")
MO <- 365.25 / 12
UNIT_SCALE <- c(g = 1, kg = 1000, mg = 0.001, d = 1, wk = 7, mo = MO, yr = 365.25, h = 1/24, mm = 1, cm = 10)

## ---- 1. Hayssen et al. 1993: topic -> Measure, with the admission rule written down ------------------
## A data line is ADMITTED when it is a central numeric value of the measure as the compilations define it;
## everything else is kept in the unfiltered table with admission = FALSE and the reason.
HAYSSEN_MAP <- tribble(~topic, ~Measure, ~label_rule, ~label_set, ~sex_rule,
  "NEONATAL MASS",        "neonate_body_mass_g",         "none",      "",                         "any",
  "WEANING MASS",         "weaning_body_mass_g",         "none",      "",                         "any",
  "LITTER SIZE",          "litter_size_n",               "none",      "",                         "any",
  "LITTERS/YEAR",         "litters_per_year_n",          "none",      "",                         "any",
  "GESTATION",            "gestation_d",                 "none",      "",                         "any",
  "LACTATION",            "weaning_age_d",               "in_set",    "wean",                     "any",
  "INTERLITTER INTERVAL", "interbirth_interval_d",       "none",      "",                         "any",
  "INTERBIRTH INTERVAL",  "interbirth_interval_d",       "none",      "",                         "any",
  "SEXUAL MATURITY",      "female_maturity_age_d",       "none",      "",                         "f_or_unspecified",
  "SEXUAL MATURITY",      "male_maturity_age_d",         "none",      "",                         "m",
  "NEONATAL SIZE",        "neonate_head_body_length_mm", "in_set_or_none", "HB;CR",               "any",
  "WEANING SIZE",         "weaning_head_body_length_mm", "in_set_or_none", "HB;CR",               "any",
  "CYCLE LENGTH",         "estrous_cycle_length_d",      "none",      "",                         "any")
## count words that are a litter-size PROXY, not born young: kept, not admitted
LITTER_PROXY <- c("emb", "cl", "ps", "implantations", "blastocysts", "ova")
hay_files <- list.files(pub, pattern = "^ISBN%3A9780801417535_.*\\.tsv$", full.names = TRUE)
hay_files <- hay_files[!grepl("LiteratureCited", hay_files)]
if (length(hay_files) != 20L) stop("Expected 20 Hayssen order TSVs in __Public, found ", length(hay_files), call. = FALSE)
hay <- bind_rows(lapply(hay_files, function(f) read_bom(f, "\t") %>% mutate(tsv = basename(f))))
cat("Hayssen rows read:", nrow(hay), "from", length(hay_files), "order TSVs\n")
hay <- hay %>% filter(topic != "family_overview")
cat("  data lines:", nrow(hay), "\n")
hay_m <- hay %>% inner_join(HAYSSEN_MAP, by = "topic", relationship = "many-to-many")
## the two SEXUAL MATURITY rows of the map compete for one line: keep the one whose sex rule the line satisfies
sex_ok <- with(hay_m, case_when(sex_rule == "any" ~ TRUE,
                                sex_rule == "f_or_unspecified" ~ is.na(sex) | sex == "" | sex %in% c("f", "f/m", "m/f"),
                                sex_rule == "m" ~ sex %in% c("m"),
                                TRUE ~ FALSE))
hay_m <- hay_m[sex_ok, ]
in_set <- mapply(function(l, set) !is.na(l) && l != "" && l %in% str_split(set, ";")[[1]], hay_m$value_label, hay_m$label_set, USE.NAMES = FALSE)
no_label <- is.na(hay_m$value_label) | hay_m$value_label == ""
label_ok <- with(hay_m, case_when(label_rule == "none" ~ no_label,
                                  label_rule == "in_set" ~ in_set,
                                  label_rule == "in_set_or_none" ~ no_label | in_set,
                                  TRUE ~ FALSE))
unit_ok  <- with(hay_m, (Measure %in% c("litter_size_n", "litters_per_year_n") & value_unit == "count") |
                        (str_detect(Measure, "_g$") & value_unit %in% c("g", "kg", "mg")) |
                        (str_detect(Measure, "_d$") & value_unit %in% c("d", "wk", "mo", "yr", "h")) |
                        (str_detect(Measure, "_mm$") & value_unit %in% c("mm", "cm")))
central  <- hay_m$value_type %in% c("point", "mean", "mode", "median", "range")
proxy    <- hay_m$Measure == "litter_size_n" & !is.na(hay_m$count_unit) & hay_m$count_unit %in% LITTER_PROXY
compar   <- !is.na(hay_m$comparator) & hay_m$comparator != ""
hay_m <- hay_m %>% mutate(
  admitted = label_ok & unit_ok & central & !proxy & !compar,
  admission_reason = case_when(
    !label_ok ~ paste0("labelled sub-measure (", value_label, ") not the measure itself"),
    !unit_ok & value_type == "text" ~ "text value (no number)",
    !unit_ok ~ paste0("unit '", value_unit, "' not a unit of the measure"),
    !central ~ paste0("not a central value (value_type ", value_type, ")"),
    proxy ~ paste0("litter-size proxy count (", count_unit, "), not born young"),
    compar ~ paste0("bound with comparator '", comparator, "'"),
    TRUE ~ "admitted"),
  scale = unname(UNIT_SCALE[value_unit]),
  scale = ifelse(value_unit == "count", 1, scale),
  ## value_canonical_any: the same number for EVERY numeric line, admitted or not (the restricted comparison tests
  ## whether a compilation copied an unadmitted line -- a proxy count, a bound, a labelled sub-measure)
  ## a range is also what a 'mode 3-4' or 'median 11-13 yr' line carries (value_numeric empty, range_low/high set): midpoint too
  is_range = value_type == "range" | (is.na(num(value_numeric)) & !is.na(num(range_low)) & !is.na(num(range_high))),
  value_canonical_any = case_when(!unit_ok ~ NA_real_,
                                  is_range ~ (num(range_low) + num(range_high)) / 2 * scale,
                                  !is.na(num(value_numeric)) ~ num(value_numeric) * scale,
                                  TRUE ~ NA_real_),
  value_canonical = ifelse(admitted, value_canonical_any, NA_real_),
  derivation = case_when(!admitted ~ NA_character_,
                         is_range ~ sprintf("midpoint(%s, %s) x %s", range_low, range_high, scale),
                         scale != 1 ~ sprintf("%s x %s", value_numeric, scale),
                         TRUE ~ NA_character_))
hay_rec <- hay_m %>% transmute(
  dataset = "Hayssen_etal_1993", record_id = paste0("HAY:", tsv, ":", pdf_page_in_book, ":", row_number()),
  species_printed = species_printed, Measure, Units = MEASURES$Units[match(Measure, MEASURES$Measure)],
  source_column = topic, value_printed = value_text, value_canonical, value_canonical_any, derivation, value_type, value_label, sex, count_unit, n = n,
  admitted, admission_reason, role = "root_compendium", cited_work = ref_numbers, cited_work_system = "Hayssen Literature Cited number",
  cites_hayssen = NA, compilation_statistic = NA_character_, population_status, locator = paste0(tsv, " | printed p. ", printed_page))
cat("  mapped to a measure:", nrow(hay_rec), "; admitted:", sum(hay_rec$admitted), "\n")
print(hay_rec %>% count(Measure, admitted) %>% pivot_wider(names_from = admitted, values_from = n, values_fill = 0) %>% as.data.frame(), row.names = FALSE)

## ---- 2. compilations ---------------------------------------------------------------------------------
COMP_MAP <- tribble(~dataset, ~source_column, ~Measure, ~unit_scale, ~note,
  "Jones_etal_2009", "5-3_NeonateBodyMass_g",       "neonate_body_mass_g",         1,     "",
  "Jones_etal_2009", "5-4_WeaningBodyMass_g",       "weaning_body_mass_g",         1,     "",
  "Jones_etal_2009", "15-1_LitterSize",             "litter_size_n",               1,     "",
  "Jones_etal_2009", "16-1_LittersPerYear",         "litters_per_year_n",          1,     "",
  "Jones_etal_2009", "9-1_GestationLen_d",          "gestation_d",                 1,     "",
  "Jones_etal_2009", "25-1_WeaningAge_d",           "weaning_age_d",               1,     "",
  "Jones_etal_2009", "14-1_InterbirthInterval_d",   "interbirth_interval_d",       1,     "",
  "Jones_etal_2009", "23-1_SexualMaturityAge_d",    "female_maturity_age_d",       1,     "PanTHERIA pools the sexes; mapped to the female measure (definition narrower)",
  "Jones_etal_2009", "13-2_NeonateHeadBodyLen_mm",  "neonate_head_body_length_mm", 1,     "",
  "Jones_etal_2009", "13-3_WeaningHeadBodyLen_mm",  "weaning_head_body_length_mm", 1,     "",
  "Jones_etal_2009", "17-1_MaxLongevity_m",         "maximum_longevity_y",         1/12,  "months -> years",
  "Jones_etal_2009", "5-1_AdultBodyMass_g",         "adult_body_mass_g",           1,     "",
  "deMagalhães_etal_2024", "Birth_weight_g",                       "neonate_body_mass_g",    1, "",
  "deMagalhães_etal_2024", "Weaning_weight_g",                     "weaning_body_mass_g",    1, "",
  "deMagalhães_etal_2024", "Litter_Clutch_size",                   "litter_size_n",          1, "",
  "deMagalhães_etal_2024", "Litters_Clutches_per_year",            "litters_per_year_n",     1, "",
  "deMagalhães_etal_2024", "Gestation_Incubation_days",            "gestation_d",            1, "",
  "deMagalhães_etal_2024", "Weaning_days",                         "weaning_age_d",          1, "",
  "deMagalhães_etal_2024", "Inter_litter_Interbirth_interval_days","interbirth_interval_d",  1, "",
  "deMagalhães_etal_2024", "Female_maturity_days",                 "female_maturity_age_d",  1, "",
  "deMagalhães_etal_2024", "Male_maturity_days",                   "male_maturity_age_d",    1, "",
  "deMagalhães_etal_2024", "Maximum_longevity_yrs",                "maximum_longevity_y",    1, "",
  "deMagalhães_etal_2024", "Adult_weight_g",                       "adult_body_mass_g",      1, "",
  "Ernest__2003", "Newborn_mass_g",    "neonate_body_mass_g",         1,   "",
  "Ernest__2003", "Weaning_mass_g",    "weaning_body_mass_g",         1,   "",
  "Ernest__2003", "Litter_size",       "litter_size_n",               1,   "",
  "Ernest__2003", "Litters_per_year",  "litters_per_year_n",          1,   "",
  "Ernest__2003", "Gestation_mo",      "gestation_d",                 MO,  "months -> days",
  "Ernest__2003", "Weaning_age_mo",    "weaning_age_d",               MO,  "months -> days",
  "Ernest__2003", "AFR_mo",            "age_at_first_reproduction_d", MO,  "age at first reproduction (conception), not sexual maturity; own measure",
  "Ernest__2003", "Max_lifespan_mo",   "maximum_longevity_y",         1/12,"months -> years",
  "Ernest__2003", "Adult_mass_g",      "adult_body_mass_g",           1,   "",
  "Myhrvold_etal_2015", "birth_or_hatching_weight_g",          "neonate_body_mass_g",         1,      "",
  "Myhrvold_etal_2015", "weaning_weight_g",                    "weaning_body_mass_g",         1,      "",
  "Myhrvold_etal_2015", "litter_or_clutch_size_n",             "litter_size_n",               1,      "",
  "Myhrvold_etal_2015", "litters_or_clutches_per_y",           "litters_per_year_n",          1,      "",
  "Myhrvold_etal_2015", "gestation_d",                         "gestation_d",                 1,      "",
  "Myhrvold_etal_2015", "weaning_d",                           "weaning_age_d",               1,      "",
  "Myhrvold_etal_2015", "inter_litter_or_interbirth_interval_y","interbirth_interval_d",      365.25, "years -> days",
  "Myhrvold_etal_2015", "female_maturity_d",                   "female_maturity_age_d",       1,      "",
  "Myhrvold_etal_2015", "male_maturity_d",                     "male_maturity_age_d",         1,      "",
  "Myhrvold_etal_2015", "birth_or_hatching_svl_cm",            "neonate_head_body_length_mm", 10,     "cm -> mm",
  "Myhrvold_etal_2015", "maximum_longevity_y",                 "maximum_longevity_y",         1,      "",
  "Myhrvold_etal_2015", "adult_body_mass_g",                   "adult_body_mass_g",           1,      "")
if (!all(COMP_MAP$Measure %in% MEASURES$Measure)) stop("COMP_MAP names a measure not in MEASURES", call. = FALSE)
## Hayssen's key in each compilation's reference system (checked in each folder's reference_tables)
HAYSSEN_KEY <- c(Jones_etal_2009 = "1297", `deMagalhães_etal_2024` = "455", Ernest__2003 = "1", Myhrvold_etal_2015 = "Hayssen")
TSV <- c(Jones_etal_2009 = "10.1890%2F08-1494.1_PanTHERIA1-0WR05Aug2008.txt", `deMagalhães_etal_2024` = "10.1093%2Fnar%2Fgkad927_anagedata.txt.tsv",
         Ernest__2003 = "10.1890%2F02-9002_Mammallifehistoriesv2.txt.tsv", Myhrvold_etal_2015 = "10.1890%2F15-0846r.1_AmnioteDatabaseAug2015.tsv")
## the public TSV names follow the item's frozen-source file name and have been renamed once already
## (AmnioteDatabaseAug2015.csv.tsv -> AmnioteDatabaseAug2015.tsv, 2026-10-23): accept the one that exists
TSV[] <- vapply(TSV, function(f) {
  if (file.exists(file.path(pub, f))) return(f)
  alt <- c(sub("\\.tsv$", ".csv.tsv", f), sub("\\.csv\\.tsv$", ".tsv", f), sub("\\.txt\\.tsv$", ".tsv", f), sub("\\.txt$", ".txt.tsv", f))
  alt <- alt[alt != f & file.exists(file.path(pub, alt))]
  if (length(alt)) { message("  note: ", f, " not found; using ", alt[1]); alt[1] } else f
}, character(1))
has_key <- function(refs, key, sep) vapply(str_split(refs, sep), function(t) key %in% str_squish(t), logical(1))
ID_TAG <- c(Jones_etal_2009 = "PAN", `deMagalhães_etal_2024` = "ANAGE", Ernest__2003 = "ERNEST", Myhrvold_etal_2015 = "MYH")   # ASCII record-id prefixes
wide_to_records <- function(d, ds, species, refs, cites, stat, locator_prefix) {
  m <- COMP_MAP %>% filter(dataset == ds); tag <- unname(ID_TAG[ds])
  miss <- setdiff(m$source_column, names(d)); if (length(miss)) stop(ds, ": columns missing: ", paste(miss, collapse = ","), call. = FALSE)
  bind_rows(lapply(seq_len(nrow(m)), function(k) {
    v <- d[[m$source_column[k]]]; keep <- !is.na(v) & v != "" & v != "-999" & v != "-999.00"
    tibble(dataset = ds, record_id = paste0(tag, ":", which(keep), ":", m$source_column[k]), table_row = which(keep), species_printed = species[keep], Measure = m$Measure[k],
           Units = MEASURES$Units[match(m$Measure[k], MEASURES$Measure)], source_column = m$source_column[k], value_printed = v[keep],
           value_canonical = num(v[keep]) * m$unit_scale[k], derivation = if (m$unit_scale[k] != 1) paste0(v[keep], " x ", signif(m$unit_scale[k], 6)) else NA_character_,
           admitted = TRUE, admission_reason = "admitted", role = ifelse(cites[keep], "derived_from_root", "independent_compilation"),
           cited_work = refs[keep], cites_hayssen = cites[keep], compilation_statistic = stat, locator = paste0(locator_prefix, " | row ", which(keep), " | ", m$source_column[k]))
  }))
}
## PanTHERIA WR05 (per-species reference list, ';'-separated)
pan <- read_bom(file.path(pub, TSV["Jones_etal_2009"]), "\t")
pan_rec <- wide_to_records(pan, "Jones_etal_2009", pan$MSW05_Binomial, pan$References, has_key(pan$References, HAYSSEN_KEY["Jones_etal_2009"], ";"), "median over data lines (per-species reference list)", TSV["Jones_etal_2009"]) %>%
  mutate(cited_work_system = "PanTHERIA reference number", population_status = NA_character_)
## AnAge build 15, Mammalia (row-level References BIBLIOIDs, ','-separated; Source_ref is the longevity source)
ana <- read_bom(file.path(pub, TSV["deMagalhães_etal_2024"]), "\t") %>% filter(Class == "Mammalia")
ana_rec <- wide_to_records(ana, "deMagalhães_etal_2024", paste(ana$Genus, ana$Species), ana$References, has_key(str_remove_all(ana$References, "^0+|,0+") %>% str_replace_all(",0*", ","), HAYSSEN_KEY["deMagalhães_etal_2024"], ","), "curated species value (row-level reference list)", TSV["deMagalhães_etal_2024"]) %>%
  mutate(cited_work_system = "AnAge BIBLIOID", population_status = ana$Specimen_origin[table_row])
## Ernest 2003 (row-level refs, '; '-separated numbers 1-29)
ern <- read_bom(file.path(pub, TSV["Ernest__2003"]), "\t")
ern_rec <- wide_to_records(ern, "Ernest__2003", ern$Species_Ernest2003, ern$refs, has_key(ern$refs, HAYSSEN_KEY["Ernest__2003"], ";"), "unweighted mean across numbered sources (row-level reference list)", TSV["Ernest__2003"]) %>%
  mutate(cited_work_system = "Ernest 2003 reference number", population_status = NA_character_)
## Myhrvold 2015 Amniote database, Mammalia: already long; the reference string describes the derivation
myh <- read_bom(file.path(pub, TSV["Myhrvold_etal_2015"]), "\t") %>% filter(class == "Mammalia")
mm <- COMP_MAP %>% filter(dataset == "Myhrvold_etal_2015")
myh <- myh %>% filter(trait %in% mm$source_column, value != "-999", value != "")
myh_rec <- myh %>% mutate(k = match(trait, mm$source_column)) %>% transmute(
  dataset = "Myhrvold_etal_2015", record_id = paste0("MYH:", row_number(), ":", trait), table_row = row_number(), species_printed = paste(genus, species), Measure = mm$Measure[k],
  Units = MEASURES$Units[match(Measure, MEASURES$Measure)], source_column = trait, value_printed = value, value_canonical = num(value) * mm$unit_scale[k],
  derivation = ifelse(mm$unit_scale[k] != 1, paste0(value, " x ", signif(mm$unit_scale[k], 6)), NA_character_), admitted = TRUE, admission_reason = "admitted",
  cites_hayssen = str_detect(reference, fixed("Hayssen")), role = ifelse(cites_hayssen, "derived_from_root", "independent_compilation"),
  cited_work = reference, cited_work_system = "Amniote database reference string (derivation)", compilation_statistic = "median/mean over sparse-table records (see reference string)",
  locator = paste0(TSV["Myhrvold_etal_2015"], " | class Mammalia | ", trait), population_status = NA_character_)
comp_rec <- bind_rows(pan_rec, ana_rec, ern_rec, myh_rec)
cat("compilation records:", nrow(comp_rec), "\n"); print(comp_rec %>% count(dataset, cites_hayssen) %>% as.data.frame(), row.names = FALSE)

## ---- 3. unfiltered table + species resolution --------------------------------------------------------
unf <- bind_rows(hay_rec %>% mutate(cites_hayssen = as.logical(NA)), comp_rec) %>%
  mutate(measure_class = MEASURES$measure_class[match(Measure, MEASURES$Measure)])
rs <- resolve_species(unf$species_printed, source_publication = unf$dataset)
unf$Species <- rs$accepted_name; unf$species_basis <- ifelse(rs$unresolved, "unresolved", paste0(rs$match_level, ":", rs$species_basis)); unf$reidentified <- rs$reidentified
cat("unfiltered rows:", nrow(unf), "; species resolved through _keys:", sum(!rs$unresolved), "of", nrow(unf), "rows (", n_distinct(unf$Species[!rs$unresolved]), "accepted names )\n")
unf <- unf %>% mutate(value_canonical_any = coalesce(value_canonical_any, value_canonical)) %>%
  select(Species, species_printed, species_basis, reidentified, dataset, role, measure_class, Measure, Units, value_canonical, value_canonical_any, value_printed, derivation,
                      admitted, admission_reason, cites_hayssen, cited_work, cited_work_system, compilation_statistic, value_type, value_label, sex, count_unit, n,
                      population_status, source_column, record_id, locator)
if (any(vapply(unf, function(col) any(grepl("\\x00", col, useBytes = TRUE)), logical(1)))) stop("embedded NUL in the unfiltered table", call. = FALSE)
write_bom(unf, file.path(out, "life_history_unfiltered.csv"))

## ---- 4. pooled long table (species x measure), compilation-aware ---------------------------------------
adm <- unf %>% filter(admitted, !is.na(value_canonical))
hay_sum <- adm %>% filter(dataset == "Hayssen_etal_1993") %>% group_by(Species, Measure) %>%
  summarise(hayssen_median = median(value_canonical), hayssen_n_lines = n(), hayssen_min = min(value_canonical), hayssen_max = max(value_canonical),
            hayssen_refs = paste(sort(unique(unlist(str_split(cited_work[!is.na(cited_work) & cited_work != ""], ";")))), collapse = ";"), .groups = "drop")
comp_sum <- adm %>% filter(dataset != "Hayssen_etal_1993") %>% group_by(Species, Measure, dataset) %>%
  summarise(value = median(value_canonical), cites = any(cites_hayssen), n_rec = n(), .groups = "drop")   # several printed names of one accepted species -> median within dataset
parties <- bind_rows(hay_sum %>% transmute(Species, Measure, party = "Hayssen_etal_1993", value = hayssen_median, independent = TRUE, role = "root_compendium"),
                     comp_sum %>% transmute(Species, Measure, party = dataset, value, independent = !cites, role = ifelse(cites, "derived_from_root", "independent_compilation")))
long <- parties %>% group_by(Species, Measure) %>% summarise(
  Value = if (any(independent)) median(value[independent]) else NA_real_,
  n_sources = n(), n_independent = sum(independent), n_derived = sum(!independent),
  Teams = paste(party, collapse = "|"), roles = paste(role, collapse = "|"),
  value_min = if (any(independent)) min(value[independent]) else NA_real_, value_max = if (any(independent)) max(value[independent]) else NA_real_,
  derived_values = paste(signif(value[!independent], 6), collapse = "|"), .groups = "drop") %>%
  left_join(hay_sum, by = c("Species", "Measure")) %>%
  mutate(Units = MEASURES$Units[match(Measure, MEASURES$Measure)], measure_class = MEASURES$measure_class[match(Measure, MEASURES$Measure)],
         disagreement = n_independent > 1 & ((Units == "n" & (value_max - value_min) > 1) | (Units != "n" & value_max / value_min > 1.25)),
         derived_outside_root_range = !is.na(hayssen_median) & n_derived > 0 & vapply(seq_len(n()), function(i) { v <- num(str_split(derived_values[i], "\\|")[[1]]); any(!is.na(v) & (v < hayssen_min[i] * 0.995 | v > hayssen_max[i] * 1.005)) }, logical(1))) %>%
  select(Species, measure_class, Measure, Units, Value, n_sources, n_independent, n_derived, Teams, roles, value_min, value_max, disagreement,
         hayssen_median, hayssen_n_lines, hayssen_min, hayssen_max, hayssen_refs, derived_values, derived_outside_root_range) %>% arrange(Species, Measure)
write_bom(long, file.path(out, "life_history_long.csv"))
cat("long: species", n_distinct(long$Species), "; species x measure", nrow(long), "; with a Hayssen value", sum(!is.na(long$hayssen_median)),
    "; disagreement among independent parties", sum(long$disagreement), "; derived value outside the root's range", sum(long$derived_outside_root_range), "\n")
print(long %>% group_by(Measure) %>% summarise(species = n(), with_hayssen = sum(!is.na(hayssen_median)), derived = sum(n_derived > 0), disagree = sum(disagreement), derived_outside = sum(derived_outside_root_range)) %>% as.data.frame(), row.names = FALSE)
wide <- long %>% filter(!is.na(Value)) %>% select(Species, Measure, Value) %>% pivot_wider(names_from = Measure, values_from = Value) %>% arrange(Species)
write_bom(wide, file.path(out, "life_history_wide.csv"))
src_cols <- bind_rows(HAYSSEN_MAP %>% transmute(dataset = "Hayssen_etal_1993", source_column = topic, Measure, unit_scale = NA_real_, rule = paste0("label: ", label_rule, ifelse(nzchar(label_set), paste0(" [", label_set, "]"), ""), "; sex: ", sex_rule, "; central numeric values only (point/mean/mode/median; range -> midpoint); litter-size proxies (", paste(LITTER_PROXY, collapse = ","), ") not admitted")),
                      COMP_MAP %>% transmute(dataset, source_column, Measure, unit_scale, rule = ifelse(nzchar(note), note, "value as published; -999/blank = not published"))) %>%
  mutate(hayssen_key_in_reference_system = ifelse(dataset == "Hayssen_etal_1993", NA_character_, unname(HAYSSEN_KEY[dataset])))
write_bom(src_cols, file.path(out, "life_history_source_columns.csv"))

## ---- 5. species-alignment candidates (roadmap for _keys, not applied) ----------------------------------------
## Hayssen names that match no compilation species: OCR residue the within-family canonicalisation could not absorb
## (singletons: 'Aplodontia mfa'), 'spp' rows, and pre-MSW05 synonyms (the book follows Honacki et al. 1982). For each,
## the nearest compilation name within edit distance 2 after collapsing confusable glyphs is proposed; a reviewer adds
## the accepted rows to _keys/<collection>/species_key.csv -- the merge never applies these itself.
glyph <- function(k) { k <- tolower(gsub(" ", "", k)); k <- gsub("[uv]", "u", k); k <- gsub("[lti1!]", "l", k); k <- gsub("[ceo]", "o", k); k <- gsub("rn|ru|m", "m", k); gsub("rl|h", "h", k) }
hay_sp <- unique(unf$Species[unf$dataset == "Hayssen_etal_1993"]); comp_sp <- unique(unf$Species[unf$dataset != "Hayssen_etal_1993"])
unmatched <- setdiff(hay_sp, comp_sp)
cand <- bind_rows(lapply(unmatched, function(nm) {
  if (str_detect(nm, " spp$| spp | or |/")) return(tibble(hayssen_species = nm, candidate = NA_character_, edit_distance = NA_integer_, kind = "genus-level or multi-species row"))
  g <- str_extract(nm, "^[A-Z][a-z]+"); pool <- comp_sp[str_detect(comp_sp, paste0("^", g, " "))]
  d <- if (length(pool)) adist(glyph(nm), glyph(pool))[1, ] else integer(0)
  if (length(d) && min(d) <= 2) { j <- which(d == min(d)); tibble(hayssen_species = nm, candidate = paste(pool[j], collapse = " | "), edit_distance = as.integer(min(d)), kind = ifelse(length(j) == 1, "glyph-aware nearest name in the genus", "ambiguous")) }
  else tibble(hayssen_species = nm, candidate = NA_character_, edit_distance = NA_integer_, kind = ifelse(length(pool), "no near name in the genus (synonym or OCR)", "genus absent from the compilations (synonym or OCR)")) }))
cand <- cand %>% mutate(n_hayssen_lines = as.integer(table(unf$Species[unf$dataset == "Hayssen_etal_1993"])[hayssen_species])) %>% arrange(kind, hayssen_species)
write_bom(cand, file.path(out, "life_history_species_alignment_candidates.csv"))
cat("Hayssen species:", length(hay_sp), "; matched to a compilation species:", length(hay_sp) - length(unmatched), "; unmatched:", length(unmatched), "\n"); print(table(cand$kind))
cat("DONE\n")
