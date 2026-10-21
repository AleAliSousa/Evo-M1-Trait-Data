## =============================================================================
## Myhrvold et al. (2015) Amniote database <-> Jones et al. (2009) PanTHERIA crosswalks
## =============================================================================
##
## 1. Variable crosswalk  -> reference_tables/Myhrvold_etal_2015_PanTHERIA_variable_crosswalk.csv
##    Amniote trait definitions are transcribed from Supplemental_Table_9_Dataset_Field_Information.csv;
##    PanTHERIA definitions are parsed from Jones_etal_2009/metadata.htm (the per-variable
##    "(n) <code>_<Name>_<unit>: <definition>" table cells, unit = the following cell). Nothing
##    is quoted from memory: the script stops if a referenced trait/variable is not found in
##    its source. The mapping and the definition_match judgement are declared in MAP below,
##    each with a note citing the two texts.
## 2. Species crosswalk   -> reference_tables/Myhrvold_etal_2015_PanTHERIA_species_crosswalk.csv
##    every Mammalia Database row -> PanTHERIA MSW05_Binomial, match_basis tiers in order:
##      exact_binomial | supp_table_4_transformation | supp_table_7_synonym | species_key | unresolved
##    + reference_tables/Myhrvold_etal_2015_PanTHERIA_species_unresolved.csv
## =============================================================================

options(stringsAsFactors = FALSE, scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- sub("\\.R$","",basename(.sp)); setwd(folder)
base <- local({ d<-folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
if (is.na(base)) stop("Repository root (__ReadMe.xlsx) not found; the PanTHERIA folder and _keys cannot be located.", call.=FALSE)

ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "en_US.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "C.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) stop("No UTF-8 LC_CTYPE locale available.", call.=FALSE)

req <- c("readr", "dplyr", "xml2")
miss <- req[!vapply(req, requireNamespace, logical(1), quietly=TRUE)]
if (length(miss)) stop("Install the required package(s): ", paste(miss, collapse=", "), call.=FALSE)
suppressPackageStartupMessages({ library(readr); library(dplyr); library(xml2) })

out_dir <- file.path(folder, "reference_tables")
f_t9   <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_9_Dataset_Field_Information.csv")
f_t4   <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_4_Mammalia_Name_Transformations.csv")
f_t7   <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_7_Mammalia_Synonyms.csv")
f_vals <- file.path(folder, "Data_Files", "Amniote_Database_Aug_2015.csv")
f_meta <- file.path(base, "Jones_etal_2009", "metadata.htm")
f_pan  <- file.path(base, "Jones_etal_2009", "Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.csv")
f_resolver <- file.path(base, "_keys", "resolve_species.R")
for (f in c(f_t9, f_t4, f_t7, f_vals, f_meta, f_pan, f_resolver)) if (!file.exists(f)) stop("Missing input: ", f, call.=FALSE)

PANTHERIA_T7_KEY <- "Jones, K., Bielby, J., Cardillo, M. et al., 2009"

## =============================================================================
## 1. Variable crosswalk
## =============================================================================
t9 <- read_csv(f_t9, col_types=cols(.default="c"), skip=1, col_names=c("field_number","field_name","units","taxonomic_group","description"), progress=FALSE) %>%
  filter(!is.na(field_name), grepl("^[0-9]+$", field_number))
if (nrow(t9) != 36L) stop("Supplemental Table 9: expected 36 fields, found ", nrow(t9))
amn_traits <- t9 %>% filter(as.integer(field_number) >= 8)
if (nrow(amn_traits) != 29L) stop("Supplemental Table 9: expected 29 trait fields.")

## PanTHERIA definitions from metadata.htm
h <- read_html(f_meta)
tds <- trimws(gsub("\\s+", " ", xml_text(xml_find_all(h, "//td"))))
tds <- gsub("\u00a0", " ", tds)
hit <- grep("^\\([0-9]+\\) [0-9]+-\\s?[0-9]+_\\S+\\s?: ", tds)
pan_defs <- tibble(printed = tds[hit], unit_cell = tds[hit + 1L]) %>%
  mutate(code = sub("^\\([0-9]+\\) ([0-9]+-\\s?[0-9]+)_.*$", "\\1", printed),
         code = gsub("\\s", "", code),
         pantheria_name_in_metadata = sub("^\\([0-9]+\\) ([0-9]+-\\s?[0-9]+_\\S+)\\s?: .*$", "\\1", printed),
         pantheria_definition = sub("^\\([0-9]+\\) [0-9]+-\\s?[0-9]+_\\S+\\s?: ", "", printed),
         pantheria_unit = unit_cell) %>%
  distinct(code, .keep_all = TRUE)
cat("PanTHERIA variable definitions parsed from metadata.htm:", nrow(pan_defs), "\n")
if (nrow(pan_defs) < 30L) stop("Fewer than 30 PanTHERIA definitions parsed from metadata.htm.")
pan_cols <- names(read_csv(f_pan, col_types=cols(.default="c"), n_max=1, progress=FALSE))
pan_code_of <- function(v) sub("^([0-9]+-[0-9]+)_.*$", "\\1", v)

## Declared mapping. unit_scale multiplies an Amniote value to give PanTHERIA units.
## Convention: 1 year = 365.25 days = 12 months; 1 cm = 10 mm.
Y2D <- 365.25; Y2M <- 12; CM2MM <- 10
MAP <- tribble(
  ~amniote_trait, ~pantheria_variable, ~unit_scale, ~definition_match, ~note,
  "female_maturity_d", "23-1_SexualMaturityAge_d", 1, "narrower",
    "Amniote 'Age at first conception.' is one of several operational definitions PanTHERIA pools ('age at first estrus or age at first pregnancy (females only)', 'age at first mating', 'physically sexually mature'), and PanTHERIA pools 'male, female, or sex unspecified individuals'.",
  "female_maturity_d", "3-1_AgeatFirstBirth_d", 1, "different_statistic",
    "Alternate counterpart: PanTHERIA 'Age at which females give birth to their first litter' = first conception + gestation; not the same event as Amniote 'Age at first conception.'",
  "litter_or_clutch_size_n", "15-1_LitterSize", 1, "same",
    "Amniote 'Number of offspring per litter or number of eggs per clutch.' vs PanTHERIA 'Number of offspring born per litter per female, either counted before birth, at birth or after birth'; for Mammalia the litter sense applies.",
  "litters_or_clutches_per_y", "16-1_LittersPerYear", 1, "same",
    "Amniote 'Number of litters or clutches produced per year.' vs PanTHERIA 'Number of litters per female per year using non-captive, wild, provisioned, or unspecified populations'.",
  "adult_body_mass_g", "5-1_AdultBodyMass_g", 1, "same",
    "Amniote 'Body mass using data from males, females, and/or unspecified adults.' vs PanTHERIA 'Mass of adult (or age unspecified) ... specimens (excluding pregnant females) ...; male, female, or sex unspecified individuals'. Both pool sexes.",
  "female_body_mass_g", "5-1_AdultBodyMass_g", 1, "narrower",
    "Amniote 'Body mass of female adults.' is the female subset of PanTHERIA's sex-pooled adult mass.",
  "male_body_mass_g", "5-1_AdultBodyMass_g", 1, "narrower",
    "Amniote 'Body mass of male adults.' is the male subset of PanTHERIA's sex-pooled adult mass.",
  "no_sex_body_mass_g", "5-1_AdultBodyMass_g", 1, "narrower",
    "Amniote 'Body mass of unspecified adults.' is the sex-unspecified subset of PanTHERIA's sex-pooled adult mass.",
  "maximum_longevity_y", "17-1_MaxLongevity_m", Y2M, "same",
    "Amniote 'Maximum recorded longevity for species.' vs PanTHERIA 'Maximum adult age measured either through direct observation, capture-recapture estimates, projected from physical wear or unspecified'. Years -> months x 12.",
  "longevity_y", "17-1_MaxLongevity_m", Y2M, "different_statistic",
    "Amniote 'Age at death.' is not defined as a maximum; PanTHERIA records the 'Maximum adult age'. Years -> months x 12.",
  "gestation_d", "9-1_GestationLen_d", 1, "narrower",
    "Amniote 'Length of time from conception or fertilization to birth.' vs PanTHERIA 'Length of time of non-inactive fetal growth' measured between pooled start points ('conception, fertilization, first observed copulation, ... implantation, ... palpably pregnant, removal of pouch young, capture ... or unspecified') and end points.",
  "weaning_d", "25-1_WeaningAge_d", 1, "narrower",
    "Amniote 'Age at which the species becomes dependent on food other than its mother's milk.' vs PanTHERIA 'Age when primary nutritional dependency on the mother ends ...' measured as any of 'weaning/lactation length, nutritionally independent, first solid food, last observed nursing, age at first flight (bats only), age at pouch exit or length of teat Attachment (marsupials only) or unspecified definition'.",
  "birth_or_hatching_weight_g", "5-3_NeonateBodyMass_g", 1, "narrower",
    "Amniote 'Weight at birth or at hatching.' vs PanTHERIA 'Mass of ... infants at either a near term embryonic stage, birth, immediately after birth or up to an age of seven days after birth'.",
  "weaning_weight_g", "5-4_WeaningBodyMass_g", 1, "same",
    "Amniote 'Weight at weaning.' vs PanTHERIA 'Mass of live or freshly-killed specimens of weanlings'.",
  "male_maturity_d", "23-1_SexualMaturityAge_d", 1, "narrower",
    "Amniote 'Age of sexual maturity for males.' is the male subset of PanTHERIA's sex-pooled maturity age (which also pools several operational definitions).",
  "no_sex_maturity_d", "23-1_SexualMaturityAge_d", 1, "narrower",
    "Amniote 'Age at sexual maturity for unspecified adults.' is the sex-unspecified subset of PanTHERIA's sex-pooled maturity age.",
  "inter_litter_or_interbirth_interval_y", "14-1_InterbirthInterval_d", Y2D, "same",
    "Amniote 'Interval between successive births or ovipositions.' vs PanTHERIA 'The length of time between successive births of the same female(s) after a successful or unspecified litter'. Years -> days x 365.25.",
  "adult_svl_cm", "13-1_AdultHeadBodyLen_mm", CM2MM, "same",
    "Amniote 'Measure from tip of the snout to ... tail base (mammals) for male, female, and/or unspecified adults.' vs PanTHERIA 'Total length from tip of nose to anus or base of tail of adult (or age unspecified) ... specimens'. cm -> mm x 10.",
  "male_svl_cm", "13-1_AdultHeadBodyLen_mm", CM2MM, "narrower",
    "Amniote male-only snout-to-tail-base length vs PanTHERIA sex-pooled head-body length. cm -> mm x 10.",
  "female_svl_cm", "13-1_AdultHeadBodyLen_mm", CM2MM, "narrower",
    "Amniote female-only snout-to-tail-base length vs PanTHERIA sex-pooled head-body length. cm -> mm x 10.",
  "no_sex_svl_cm", "13-1_AdultHeadBodyLen_mm", CM2MM, "narrower",
    "Amniote sex-unspecified snout-to-tail-base length vs PanTHERIA sex-pooled head-body length. cm -> mm x 10.",
  "birth_or_hatching_svl_cm", "13-2_NeonateHeadBodyLen_mm", CM2MM, "narrower",
    "Amniote 'at the time of hatching' (birth) vs PanTHERIA 'infants at either a near term embryonic stage, birth, immediately after birth or up to an age of seven days after birth'. cm -> mm x 10.",
  "female_svl_at_maturity_cm", NA, NA, "no_counterpart", "PanTHERIA has no length-at-maturity variable (its length variables are adult, neonate and weaning head-body length).",
  "female_body_mass_at_maturity_g", NA, NA, "no_counterpart", "PanTHERIA has no mass-at-maturity variable (adult, neonate, weaning body mass only).",
  "egg_mass_g", NA, NA, "no_counterpart", "Egg trait (Supplemental Table 9 taxonomic group B,R); PanTHERIA is mammal-only.",
  "incubation_d", NA, NA, "no_counterpart", "Egg trait (B,R); PanTHERIA gestation (9-1) ends at 'birth, hatching or unspecified' for monotremes but Amniote records incubation only for birds/reptiles.",
  "fledging_age_d", NA, NA, "no_counterpart", "Bird-only trait (B).",
  "egg_width_mm", NA, NA, "no_counterpart", "Egg trait (B,R).",
  "egg_length_mm", NA, NA, "no_counterpart", "Egg trait (B,R).",
  "fledging_mass_g", NA, NA, "no_counterpart", "Bird-only trait (B).")

missing_tr <- setdiff(amn_traits$field_name, MAP$amniote_trait)
if (length(missing_tr)) stop("Amniote traits without a crosswalk row: ", paste(missing_tr, collapse=", "))
bad_tr <- setdiff(MAP$amniote_trait, amn_traits$field_name)
if (length(bad_tr)) stop("Crosswalk names traits not in Supplemental Table 9: ", paste(bad_tr, collapse=", "))
pv <- unique(na.omit(MAP$pantheria_variable))
if (!all(pv %in% pan_cols)) stop("PanTHERIA variables not in the PanTHERIA CSV: ", paste(setdiff(pv, pan_cols), collapse=", "))
if (!all(pan_code_of(pv) %in% pan_defs$code)) stop("PanTHERIA variables without a metadata.htm definition: ", paste(pv[!pan_code_of(pv) %in% pan_defs$code], collapse=", "))

xw <- MAP %>%
  left_join(amn_traits %>% transmute(amniote_trait = field_name, amniote_field_number = as.integer(field_number),
                                     amniote_definition = description, amniote_unit = units, amniote_taxonomic_group = taxonomic_group), by="amniote_trait") %>%
  mutate(code = ifelse(is.na(pantheria_variable), NA, pan_code_of(pantheria_variable))) %>%
  left_join(pan_defs %>% select(code, pantheria_name_in_metadata, pantheria_definition, pantheria_unit), by="code") %>%
  select(amniote_trait, amniote_field_number, amniote_definition, amniote_unit, amniote_taxonomic_group,
         pantheria_variable, pantheria_name_in_metadata, pantheria_definition, pantheria_unit, unit_scale, definition_match, note) %>%
  arrange(amniote_field_number)
## every mapped row must carry both definition texts
if (any(is.na(xw$amniote_definition))) stop("Amniote definition missing for a crosswalk row.")
if (any(!is.na(xw$pantheria_variable) & (is.na(xw$pantheria_definition) | !nzchar(xw$pantheria_definition)))) stop("PanTHERIA definition missing for a mapped row.")
## unit sanity: declared unit_scale must agree with the two unit strings
unit_pair <- paste(tolower(xw$amniote_unit), tolower(xw$pantheria_unit))
expected <- c("years months" = Y2M, "years days" = Y2D, "centimeters mm" = CM2MM, "grams grams" = 1, "days days" = 1,
              "number no. of offspring" = 1, "number per year no. of litters" = 1)
chk <- !is.na(xw$pantheria_variable)
if (any(is.na(expected[unit_pair[chk]]))) stop("Undeclared unit pair: ", paste(unique(unit_pair[chk][is.na(expected[unit_pair[chk]])]), collapse=" | "))
if (any(expected[unit_pair[chk]] != xw$unit_scale[chk])) stop("unit_scale disagrees with the unit strings for: ", paste(xw$amniote_trait[chk][expected[unit_pair[chk]] != xw$unit_scale[chk]], collapse=", "))
cat("\nVariable crosswalk rows:", nrow(xw), "| definition_match counts:\n"); print(table(xw$definition_match))
f_xw <- file.path(out_dir, "Myhrvold_etal_2015_PanTHERIA_variable_crosswalk.csv")
write_csv(xw, f_xw, na="")

## =============================================================================
## 2. Species crosswalk (Mammalia rows -> PanTHERIA MSW05_Binomial)
## =============================================================================
vals <- read_csv(f_vals, col_types=cols(.default="c"), na=character(), progress=FALSE)
if (nrow(vals) != 21322L) stop("Unexpected Database row count.")
mam <- vals %>% mutate(row_id = row_number()) %>% filter(class == "Mammalia") %>%
  transmute(row_id, order, family, genus, species, subspecies, amniote_binomial = paste(genus, species),
            amniote_name = ifelse(subspecies == "-999", amniote_binomial, paste(genus, species, subspecies)))
pan <- read_csv(f_pan, col_types=cols(.default="c"), progress=FALSE)
pan_bin <- unique(pan$MSW05_Binomial)
cat("\nAmniote Mammalia rows:", nrow(mam), "| with subspecies:", sum(mam$subspecies != "-999"), "| PanTHERIA WR05 binomials:", length(pan_bin), "\n")

## tier 2: Supplemental Table 4 (Original Name -> Transformed Name); reverse lookup
t4 <- read_csv(f_t4, col_types=cols(.default="c"), col_names=FALSE, skip=1, progress=FALSE)
if (ncol(t4) != 9L || !all(trimws(t4$X5) == "->")) stop("Supplemental Table 4: unexpected layout.")
tw <- function(x) { x <- trimws(x); x[is.na(x)] <- ""; x }
t4 <- t4 %>% transmute(og = tw(X1), os = tw(X2), tg = tw(X7), ts = tw(X8))
t4_sp <- t4 %>% filter(nzchar(os), nzchar(ts)) %>% transmute(original = paste(og, os), transformed = paste(tg, ts)) %>% distinct()
t4_gen <- t4 %>% filter(!nzchar(os), !nzchar(ts), nzchar(og), nzchar(tg)) %>% transmute(og, tg) %>% distinct()
cat("Supplemental Table 4: species-level transformations:", nrow(t4_sp), "| genus-level:", nrow(t4_gen), "\n")

## tier 3: Supplemental Table 7 synonyms. Direction verified below: genus/species = the name as
## printed in ref_name's source; synonymous_genus/species = the Amniote database name.
t7 <- read_csv(f_t7, col_types=cols(.default="c"), progress=FALSE)
t7 <- t7 %>% transmute(src = paste(genus, species), amn = paste(synonymous_genus, synonymous_species), ref_name) %>% distinct()
t7p <- t7 %>% filter(ref_name == PANTHERIA_T7_KEY)
dir_src_in_pan <- mean(t7p$src %in% pan_bin); dir_amn_in_db <- mean(t7p$amn %in% mam$amniote_binomial)
cat(sprintf("Supplemental Table 7 PanTHERIA rows: %d | 'genus species' found in PanTHERIA: %.4f | 'synonymous_*' found in Amniote Mammalia: %.4f\n", nrow(t7p), dir_src_in_pan, dir_amn_in_db))
if (dir_src_in_pan < 0.99 || dir_amn_in_db < 0.99) stop("Supplemental Table 7 direction assumption not supported by the data.")

## tier 4: project species key (identity resolver)
source(f_resolver)
res_amn <- resolve_species(mam$amniote_binomial, source_publication = "Myhrvold_etal_2015")
res_pan <- resolve_species(pan_bin, source_publication = "Jones_etal_2009")
pan_by_acc <- tibble(pan_bin, acc = res_pan$accepted_name, unresolved = res_pan$unresolved, lvl = res_pan$match_level) %>%
  filter(!unresolved, lvl != "ambiguous")

cands_join <- function(x) if (length(x)) paste(sort(unique(x)), collapse=" | ") else NA_character_
rows <- vector("list", nrow(mam))
for (i in seq_len(nrow(mam))) {
  ab <- mam$amniote_binomial[i]
  if (ab %in% pan_bin) { rows[[i]] <- list(basis="exact_binomial", cand=ab, n=1L, detail=""); next }
  ## T4: originals that were transformed into this binomial, plus genus-level transformations
  o1 <- t4_sp$original[t4_sp$transformed == ab]
  o2 <- paste(t4_gen$og[t4_gen$tg == mam$genus[i]], mam$species[i])
  c4 <- unique(c(o1, o2)); c4 <- c4[c4 %in% pan_bin]
  if (length(c4)) { rows[[i]] <- list(basis="supp_table_4_transformation", cand=cands_join(c4), n=length(c4), detail=paste("T4 originals:", cands_join(unique(c(o1,o2))))); next }
  ## T7: PanTHERIA-sourced synonym rows first, then any source
  c7p <- unique(t7p$src[t7p$amn == ab]); c7p <- c7p[c7p %in% pan_bin]
  if (length(c7p)) { rows[[i]] <- list(basis="supp_table_7_synonym", cand=cands_join(c7p), n=length(c7p), detail="T7 row(s) with ref_name = PanTHERIA"); next }
  c7 <- unique(t7$src[t7$amn == ab]); c7 <- c7[c7 %in% pan_bin]
  if (length(c7)) { rows[[i]] <- list(basis="supp_table_7_synonym", cand=cands_join(c7), n=length(c7), detail=paste("T7 row(s) with ref_name:", cands_join(t7$ref_name[t7$amn == ab & t7$src %in% c7]))); next }
  ## species key
  if (!res_amn$unresolved[i] && res_amn$match_level[i] != "ambiguous") {
    ck <- pan_by_acc$pan_bin[pan_by_acc$acc == res_amn$accepted_name[i]]
    if (length(ck)) { rows[[i]] <- list(basis="species_key", cand=cands_join(ck), n=length(ck), detail=paste0("accepted_name=", res_amn$accepted_name[i], "; basis=", res_amn$species_basis[i], "; level=", res_amn$match_level[i])); next }
  }
  rows[[i]] <- list(basis="unresolved", cand=NA_character_, n=0L, detail="")
}
spx <- bind_cols(mam, bind_rows(lapply(rows, as_tibble))) %>%
  rename(match_basis = basis, pantheria_msw05_binomial = cand, n_candidates = n, match_detail = detail) %>%
  mutate(is_subspecies_row = subspecies != "-999")
basis_counts <- spx %>% count(match_basis) %>% arrange(match(match_basis, c("exact_binomial","supp_table_4_transformation","supp_table_7_synonym","species_key","unresolved")))
cat("\nSpecies crosswalk match_basis counts:\n"); print(as.data.frame(basis_counts), row.names=FALSE)
cat("rows with > 1 PanTHERIA candidate:", sum(spx$n_candidates > 1), "| distinct PanTHERIA binomials reached:", n_distinct(unlist(strsplit(na.omit(spx$pantheria_msw05_binomial), " \\| "))),
    "| PanTHERIA binomials not reached by any Amniote row:", sum(!pan_bin %in% unlist(strsplit(na.omit(spx$pantheria_msw05_binomial), " \\| "))), "\n")
unres <- spx %>% filter(match_basis == "unresolved") %>% select(row_id, order, family, genus, species, subspecies, amniote_binomial)
cat("unresolved Amniote Mammalia names:", nrow(unres), "\n"); if (nrow(unres)) print(as.data.frame(unres), row.names=FALSE)
if (nrow(spx) != nrow(mam)) stop("Species crosswalk row count != Mammalia rows.")

f_spx <- file.path(out_dir, "Myhrvold_etal_2015_PanTHERIA_species_crosswalk.csv")
write_csv(spx, f_spx, na="")
write_csv(unres, file.path(out_dir, "Myhrvold_etal_2015_PanTHERIA_species_unresolved.csv"), na="")
for (f in c(f_xw, f_spx)) { b <- read_csv(f, col_types=cols(.default="c"), progress=FALSE); if (!nrow(b)) stop("Read-back failed: ", f) }

## ---- definitions --------------------------------------------------------------------------
def <- function(code, definition, role="info", taxon="Mammalia", ref, note="")
  data.frame(Code=code, Definition=definition, Structure="", Measure="", Stat="", role=role, taxon=taxon, Reference=ref, Note=note, `Source Note`="", check.names=FALSE)
R1 <- "Myhrvold_etal_2015_PanTHERIA_variable_crosswalk"
defs_v <- rbind(
  def("amniote_trait", "Amniote database trait column (Supplemental Table 9 field name)", taxon="Aves; Reptilia; Mammalia", ref=R1),
  def("amniote_field_number", "Supplemental Table 9 field number", taxon="", ref=R1),
  def("amniote_definition", "verbatim 'Description' from Supplemental_Table_9_Dataset_Field_Information.csv", taxon="", ref=R1),
  def("amniote_unit", "verbatim 'Units' from Supplemental Table 9", taxon="", ref=R1),
  def("amniote_taxonomic_group", "verbatim 'Taxonomic Group' (B/R/M) from Supplemental Table 9", taxon="", ref=R1),
  def("pantheria_variable", "PanTHERIA 1.0 column name (Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt.csv); empty for no_counterpart rows", taxon="", ref=R1),
  def("pantheria_name_in_metadata", "the variable name as printed in metadata.htm's definition table (differs from the column name for 5-3: 'NeonatalBodyMass' vs 'NeonateBodyMass', and 14-1: 'InterBirthInterval' vs 'InterbirthInterval'); joined on the numeric code", taxon="", ref=R1),
  def("pantheria_definition", "verbatim definition text parsed from Jones_etal_2009/metadata.htm (the '(n) <variable>: ...' table cell)", taxon="", ref=R1),
  def("pantheria_unit", "the unit cell following the definition in metadata.htm", taxon="", ref=R1),
  def("unit_scale", "multiply an Amniote value by this to express it in PanTHERIA units; convention 1 year = 365.25 days = 12 months, 1 cm = 10 mm; checked against the two unit strings by the script", taxon="", ref=R1),
  def("definition_match", "same | narrower (Amniote is a subset -- e.g. one sex, one operational definition -- of what PanTHERIA pools) | broader | different_statistic | no_counterpart; a judgement from the two definition texts quoted in note", taxon="", ref=R1),
  def("note", "justification citing both definition texts", taxon="", ref=R1),
  def("Method:scope", "one row per Amniote trait (29) plus one alternate-counterpart row (female_maturity_d <-> 3-1_AgeatFirstBirth_d); PanTHERIA-only variables (e.g. 13-3_WeaningHeadBodyLen_mm) have no row", role="method", taxon="", ref=R1))
write_csv(defs_v, file.path(out_dir, paste0(R1, "_definitions.csv")), na="")
R2 <- "Myhrvold_etal_2015_PanTHERIA_species_crosswalk"
defs_s <- rbind(
  def("row_id", "1-based row in Data_Files/Amniote_Database_Aug_2015.csv", ref=R2),
  def("order / family / genus / species / subspecies", "as printed in the Amniote database row (subspecies -999 = none)", ref=R2),
  def("amniote_binomial", "paste(genus, species)", ref=R2),
  def("amniote_name", "binomial, or trinomial when a subspecies is recorded", ref=R2),
  def("match_basis", "exact_binomial (amniote_binomial is a PanTHERIA MSW05_Binomial) | supp_table_4_transformation (a Supplemental Table 4 'Original Name' transformed into this binomial is a PanTHERIA binomial) | supp_table_7_synonym (a Supplemental Table 7 row lists this binomial as the synonym of a PanTHERIA binomial; PanTHERIA-sourced rows preferred) | species_key (both names resolve to the same accepted_name via _keys/resolve_species.R) | unresolved. Tiers tried in this order; first hit wins", ref=R2),
  def("pantheria_msw05_binomial", "the PanTHERIA MSW05_Binomial(s) reached; ' | '-separated when more than one candidate", ref=R2),
  def("n_candidates", "number of distinct PanTHERIA binomials reached under the winning tier", ref=R2),
  def("match_detail", "evidence for the tier (T4 originals, T7 ref_name, species-key accepted_name/basis/level)", ref=R2),
  def("is_subspecies_row", "TRUE when the Amniote row is a subspecies (mapped at binomial level)", ref=R2))
write_csv(defs_s, file.path(out_dir, paste0(R2, "_definitions.csv")), na="")
defs_u <- def("row_id / order / family / genus / species / subspecies / amniote_binomial", "Amniote Mammalia rows with match_basis = unresolved (may be empty)", ref="Myhrvold_etal_2015_PanTHERIA_species_unresolved")
write_csv(defs_u, file.path(out_dir, "Myhrvold_etal_2015_PanTHERIA_species_unresolved_definitions.csv"), na="")
cat(sprintf("\nWrote %s (%d rows) and %s (%d rows)\n", f_xw, nrow(xw), f_spx, nrow(spx)))
