# DeCasien comparison merge = ONLY the brain-volume source papers DeCasien & Higham 2019 used
# (the refs in DeCasien_Higham_2019/DeCasien_Higham_2019_references_braindata.csv that we hold a
# table for). Full audit (2026-07-04): all 18 refs (24,34,43,51,52,53,54,55,56,57,58,59,60,61,62,
# 63,64,65) are now covered -- ref 52 (Stephan/Baron/Frahm 1988, Comparative Primate Biology Vol.4)
# is the umbrella Stephan-collection citation with no separate table of its own (its data is the
# same Stephan collection carried via refs 24/51/34/59); every other ref has a table below,
# including 55 (Bush & Allman 2004 PNAS frontal, added as Bush_Allman_2004_a_Table2) and 57
# (Barger 2014, Barger_etal_2014_Table1). This SUBSET is for
# reproducing/comparing DeCasien; the FULL collection lives in volumes_compiled.R. Shares the same
# engine as volumes_compiled.R — differs only in the papers tribble, the output suffix, and the
# step-9 comparison call. Outputs are written with output_suffix to stay separate from the canonical
# volumes_*.csv.
#
# RULE (see README__merging.md):
#  Tier 1 "Stephan_collection" (coauthor group, same Vogt specimens; one evolving
#    dataset): resolve duplicate (species x structure) by MOST RECENT date; flag if a
#    superseding value deviates >50% from the one it replaces. Body/brain weight is the
#    exception -> keep the Stephan 1981 reference (fill gaps only; not averaged).
#  Tier 2 (independent series; different specimens/labs): each is its own team; across
#    teams AVERAGE the surviving values with the Tier-1 result.
#
# Steps: 1 read TSVs  2 standardized terms  3 reshape/convert (Zilles, Bauernfeind,
#        MacLeod, Bush)  4 harmonize species  5 Tier-1 resolve  6 Tier-2 average -> long/wide/flags

library(tidyverse); library(readxl)

## ---- paths: self-contained (Rscript or RStudio; needs the full repo) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)                                                # __merging_volumes
base   <- local({                                                     # repo root (marker: __ReadMe.xlsx)
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base))
  stop("Repo root (__ReadMe.xlsx) not found above ", folder, " — this merge script needs the full ",
       "repository (it reads __Public/comparative-data and _keys).", call. = FALSE)
setwd(folder)

# Dedicated output suffix for this DeCasien script. Keep every file written here
# separate from the canonical volumes_compiled.R outputs.
output_suffix <- "_DeCasien"
DeCasien_csv  <- function(stem) paste0(stem, output_suffix, ".csv")

## 1 Papers: ONLY the volume-source papers DeCasien & Higham 2019 used ----
## = the refs in DeCasien_Higham_2019/DeCasien_Higham_2019_references_braindata.csv that we hold a
## table for. Omitted: ref 52 (Stephan 1988 = the Stephan collection, no separate table). ref 55
## (Bush & Allman 2004 PNAS frontal, DOI 10.1073/pnas.0305760101 Table 2) IS now included -- it was
## previously marked "not carried as a volume table" but the snapshot/csv already existed locally
## (Bush_Allman_2004_a/Bush_Allman_2004_a_Table2.csv) and its whole_brain/neocortex_grey/white
## values reproduce DeCasien's Cheirogaleus/Daubentonia/Mandrillus/Propithecus figures exactly. ref
## 57 (Barger 2014) IS also included (Table 1: ape hippocampus/amygdala/striatum, one-hemisphere
## cc -> x2 -> mm3, species mean). See DeCasien_reference_audit.csv. The FULL collection is
## volumes_compiled.R.
papers <- tribble(
  ~item,                                  ~team,                ~year,
  # Refs 51 and 24 are stored one item per printed table. Keep the split names in lockstep with
  # the canonical reader/term maps; the former bundled item names no longer have term-map rows.
  "Stephan_etal_1970_Table1",             "Stephan_collection", 1970,  # ref 51
  "Stephan_etal_1970_Table2",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table3",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table4",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table5",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table6",             "Stephan_collection", 1970,
  "Stephan_etal_1981_TableI",             "Stephan_collection", 1981,  # ref 24
  "Stephan_etal_1981_TableII",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableIII",           "Stephan_collection", 1981,
  "Stephan_etal_1981_TableIV",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableV",             "Stephan_collection", 1981,
  "Stephan_etal_1981_TableVI",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableVII",           "Stephan_collection", 1981,
  "Stephan_etal_1981_TableVIII",          "Stephan_collection", 1981,
  "Stephan_etal_1981_TableIX",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableX",             "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXI",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXII",           "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXIII",          "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXIV",           "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXV",            "Stephan_collection", 1981,
  "Stephan_etal_1981_TableXVI",           "Stephan_collection", 1981,
  "Frahm_etal_1984_Table1",               "Stephan_collection", 1984,  # ref 34 (area striata)
  "Zilles_Rehkämper_1988_Table12-2",      "Stephan_collection", 1988,  # ref 59
  "deSousa_etal_2010_Table1",             "Zilles",             2010,  # ref 60
  "MacLeod_etal_2003_Table1",             "Zilles",             2003,  # ref 61 (Table1 = Yerkes sample)
  "MacLeod_etal_2003_Table2",             "Zilles",             2003,  # ref 61 (Table2 = Hirnforschung sample; was omitted -- has Alouatta/Aotus/etc DeCasien needs)
  "Bauernfeind_etal_2013_Table1",         "Zilles",             2013,  # ref 43
  "Bauernfeind_etal_2013_Table2",         "Zilles",             2013,  # ref 43
  "Barger_etal_2007_TABLE1",              "Zilles",             2007,  # ref 56
  "Barger_etal_2014_Table1",              "Zilles",             2014,  # ref 57 (ape hippocampus/amygdala/striatum; specimens overlap Barger 2007 -> same "Zilles" team so amygdala averages rather than double-counts)
  "Bush_Allman_2004_b_TABLE1",            "Bush",               2004,  # ref 54 (V1)
  "Bush_Allman_2004_a_Table2",            "Bush",               2004,  # ref 55 (frontal/neocortex GM+WM; 55 species incl. Cheirogaleus/Daubentonia/Mandrillus/Propithecus)
  "Sherwood_etal_2005_Table1",            "Sherwood",           2005,  # ref 53 (brainstem motor)
  "Sherwood_etal_2004_TABLEI",            "Sherwood",           2004,  # ref 64 (great apes)
  "Rilling_Insel_1998_Table1",            "RillingInsel",       1998,  # ref 62 (cerebellum + BV)
  "Rilling_Insel_1999_Table1",      "RillingInsel",       1999,  # ref 63 (neocortex via MRI; DOI-coded Table 1)
  "Barks_etal_2014_TABLE1",               "Barks",              2014,  # ref 65 (gorillas; print 2015)
  "Barks_etal_2014_Fig4A",                "Barks",              2014,  # ref 65 regional volumes (Barks Fig 4A; replaces viaDeCasien)
  "Stimpson_etal_2015_TableS1",      "Stimpson",           2015,  # ref 58 (amygdala)
  "Stimpson_etal_2015_TableS2",      "Stimpson",           2015   # ref 58 (amygdala; DOI-coded Table S2)
)
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
# Fallback encodings for items not yet given a row in __ReadMe.xlsx (the registry sheet is
# maintained by hand to preserve its formula columns). Remove an entry once its row exists.
enc_override <- c("Bauernfeind_etal_2013_Table2" = "10.1016%2Fj.jhevol.2012.12.003_Table2",
                  "Stephan_etal_1970_Table1" = "ISBN%3A0390672505_TABLE1",
                  "Stephan_etal_1970_Table2" = "ISBN%3A0390672505_TABLE2",
                  "Stephan_etal_1970_Table3" = "ISBN%3A0390672505_TABLE3",
                  "Stephan_etal_1970_Table4" = "ISBN%3A0390672505_TABLE4",
                  "Stephan_etal_1970_Table5" = "ISBN%3A0390672505_TABLE5",
                  "Stephan_etal_1970_Table6" = "ISBN%3A0390672505_TABLE6",
                  # All 16 printed Stephan 1981 tables share the paper's single DOI. Pin the
                  # encodings so registry drift cannot send VIII/IX/X to obsolete DOI variants.
                  "Stephan_etal_1981_TableI"    = "10.1159%2F000155963_TableI",
                  "Stephan_etal_1981_TableII"   = "10.1159%2F000155963_TableII",
                  "Stephan_etal_1981_TableIII"  = "10.1159%2F000155963_TableIII",
                  "Stephan_etal_1981_TableIV"   = "10.1159%2F000155963_TableIV",
                  "Stephan_etal_1981_TableV"    = "10.1159%2F000155963_TableV",
                  "Stephan_etal_1981_TableVI"   = "10.1159%2F000155963_TableVI",
                  "Stephan_etal_1981_TableVII"  = "10.1159%2F000155963_TableVII",
                  "Stephan_etal_1981_TableVIII" = "10.1159%2F000155963_TableVIII",
                  "Stephan_etal_1981_TableIX"   = "10.1159%2F000155963_TableIX",
                  "Stephan_etal_1981_TableX"    = "10.1159%2F000155963_TableX",
                  "Stephan_etal_1981_TableXI"   = "10.1159%2F000155963_TableXI",
                  "Stephan_etal_1981_TableXII"  = "10.1159%2F000155963_TableXII",
                  "Stephan_etal_1981_TableXIII" = "10.1159%2F000155963_TableXIII",
                  "Stephan_etal_1981_TableXIV"  = "10.1159%2F000155963_TableXIV",
                  "Stephan_etal_1981_TableXV"   = "10.1159%2F000155963_TableXV",
                  "Stephan_etal_1981_TableXVI"  = "10.1159%2F000155963_TableXVI",
                  "MacLeod_etal_2003_Table1" = "10.1016%2Fs0047-2484(03)00028-9_Table1",
                  "MacLeod_etal_2003_Table2" = "10.1016%2Fs0047-2484(03)00028-9_Table2",
                  "Semendeferi_etal_1998_Table2" = "10.1002%2F(SICI)1096-8644(199806)106%3A2%3C129%3A%3AAID-AJPA3%3E3.0.CO;2-L_TABLE2",
                  "Semendeferi_etal_2001_Table2" = "10.1002%2F1096-8644(200103)114%3A3%3C224%3A%3AAID-AJPA1022%3E3.0.CO;2-I_TABLE2",
                  # DeCasien primaries: have __ReadMe.xlsx rows, but keep fallbacks against registry drift.
                  "Sherwood_etal_2004_TABLEI"   = "10.1002%2Fajp.20048_TABLEI",
                  "Barks_etal_2014_TABLE1"      = "10.1002%2Fajpa.22646_TABLE1",
                  "Barger_etal_2014_Table1"     = "10.3389%2Ffnhum.2014.00277_Table1",
                  "Bush_Allman_2004_a_Table2"   = "10.1073%2Fpnas.0305760101_Table2",
                  "Rilling_Insel_1998_Table1"   = "10.1159%2F000006575_Table1",
                  "Stimpson_etal_2015_TableS1" = "10.1093%2Fscan%2Fnsv128_TableS1",
                  # DOI-coded/derived sources and non-registry extras resolved here.
                  "Rilling_Insel_1999_Table1" = "10.1006%2Fjhev.1999.0313_Table1",
                  "Barks_etal_2014_Fig4A"           = "10.1002%2Fajpa.22646_Fig4A",
                  "Stimpson_etal_2015_TableS2" = "10.1093%2Fscan%2Fnsv128_TableS2")
read_item <- function(it) {
  # Match item names CASE-INSENSITIVELY (registry drifts e.g. Table2 vs TABLE2) and
  # strip stray spaces from the encoding (cloud-edit typos like "ISBN%3A 0390..."),
  # but keep the encoding's case (DOIs/filenames are case-sensitive).
  norm <- function(x) tolower(gsub(" ", "", x))
  i   <- match(norm(it), norm(filecodes$"Item name"))
  enc <- if (!is.na(i)) gsub(" ", "", filecodes$"Item encoded"[i]) else NA_character_
  if ((is.na(enc) || !nzchar(enc)) && it %in% names(enc_override)) enc <- enc_override[[it]]
  # robustness: if the registry-resolved file is missing but we have a manual
  # override, prefer the override (guards against mid-migration filename drift).
  if (!is.na(enc) && nzchar(enc) && it %in% names(enc_override) &&
      !file.exists(file.path(base, "__Public/comparative-data", paste0(enc, ".tsv"))))
    enc <- enc_override[[it]]
  # fail loudly instead of silently reading "NA.tsv" when nothing resolved
  if (is.na(enc) || !nzchar(enc))
    stop("read_item('", it, "'): no encoding (not in __ReadMe.xlsx 'Item name' and no enc_override). ",
         "Add a registry row or an enc_override fallback.", call. = FALSE)
  f <- file.path(base, "__Public/comparative-data", paste0(enc, ".tsv"))
  if (!file.exists(f)) stop("read_item('", it, "'): TSV not found -> ", f, call. = FALSE)
  read.table(f, header = TRUE, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
}

## 2 Standardized terms + 3 reshape/convert -> long (Species, Variable, Value) per paper ----
terms <- read.csv("standardized_term_volumes.csv", check.names = FALSE)
# Laterality guard (see README__merging.md "Hemispheres"). laterality_known.csv records, for every
# source column measured from ONE SIDE, which side it was and -- crucially -- WHO did any doubling:
#
#   doubling = none       the printed number is one side AS MEASURED. Its standardized term MUST
#                         carry the laterality suffix (_unilateral/_left/_right), so a one-side value
#                         can never be silently merged/averaged with a both-sides volume. Any
#                         both-sides partner is built in step 7 -> `estimated_bilateral_from_unilateral`.
#   doubling = by_source  the PUBLISHED number is already 2x one side, doubled by the paper's authors
#                         with a stated symmetry argument (de Sousa 2010 V1/LGN; de Sousa 2013 LGN).
#                         It is a deliberate both-sides ESTIMATE, so its term must carry NO laterality
#                         suffix, it is used as published, and it is never doubled again ->
#                         `published_bilateral_estimate`.
#
# BOTH are PROVENANCE, never vetoes: neither ever drops a value. Kept in step with the guard in
# volumes_compiled.R / volumes_compiled_select.R -- change all three together.
lat_known <- tryCatch(read.csv("laterality_known.csv", stringsAsFactors = FALSE),
                      error = function(e) NULL)
lat_src_doubled <- data.frame(Reference = character(), Standardized_Term = character())
if (!is.null(lat_known) && nrow(lat_known)) {
  if (is.null(lat_known$doubling)) lat_known$doubling <- "none"      # pre-`doubling` registries
  lat_known$doubling[is.na(lat_known$doubling) | !nzchar(lat_known$doubling)] <- "none"
  bad_dbl <- setdiff(unique(lat_known$doubling), c("none", "by_source"))
  if (length(bad_dbl))
    stop("laterality_known.csv: unknown doubling value(s) ", paste(bad_dbl, collapse = ", "),
         ". Use `none` (one side as measured) or `by_source` (published as 2x one side).",
         call. = FALSE)
  lat_known <- lat_known[lat_known$Reference %in% papers$item, , drop = FALSE]
  chk <- merge(lat_known, terms, by = c("Reference", "Original_Term"), all.x = TRUE)
  unmapped <- chk[is.na(chk$Standardized_Term), ]
  if (nrow(unmapped))
    warning("Laterality guard: ", nrow(unmapped), " registered column(s) have no standardized term -> ",
            paste(sprintf("%s:%s", unmapped$Reference, unmapped$Original_Term), collapse = "; "))
  # doubling = none -> the suffix is REQUIRED
  one <- chk[chk$doubling == "none" & !is.na(chk$Standardized_Term), ]
  blank <- one[is.na(one$required_suffix) | !nzchar(one$required_suffix), ]
  if (nrow(blank))                                   # a registry error, not a term-map error
    warning("Laterality guard: ", nrow(blank), " row(s) have doubling=none but no required_suffix ",
            "(a one-side column must declare its suffix; use doubling=by_source if the published ",
            "value already represents both sides) -> ",
            paste(sprintf("%s:%s", blank$Reference, blank$Original_Term), collapse = "; "))
  one <- one[!(is.na(one$required_suffix) | !nzchar(one$required_suffix)), ]
  # Anchored, so the suffix must sit immediately before _Vol.mm3 -- symmetric with the by_source
  # test below, and it catches a suffix in the wrong position rather than anywhere in the string.
  bad <- one[!mapply(function(s, suf) grepl(paste0(suf, "_Vol.mm3$"), s),
                     one$Standardized_Term, one$required_suffix), , drop = FALSE]
  if (nrow(bad))
    warning("Laterality guard: ", nrow(bad), " one-side column(s) missing the required suffix -> ",
            paste(sprintf("%s:%s (want %s, got %s)", bad$Reference, bad$Original_Term,
                          bad$required_suffix, bad$Standardized_Term), collapse = "; "))
  # doubling = by_source -> the published value already represents both sides, suffix FORBIDDEN
  src <- chk[chk$doubling == "by_source" & !is.na(chk$Standardized_Term), ]
  bad2 <- src[grepl("_(unilateral|left|right)_Vol\\.mm3$", src$Standardized_Term), ]
  if (nrow(bad2))
    warning("Laterality guard: ", nrow(bad2), " author-doubled column(s) carry a laterality suffix ",
            "they should not (the published value already represents both sides) -> ",
            paste(sprintf("%s:%s (%s)", bad2$Reference, bad2$Original_Term,
                          bad2$Standardized_Term), collapse = "; "))
  if (!nrow(bad) && !nrow(bad2) && !nrow(unmapped) && !nrow(blank))
    message("Laterality guard OK: ", nrow(one), " one-side column(s) correctly suffixed, ",
            nrow(src), " author-doubled column(s) correctly unsuffixed (of the tables this merge reads).")
  lat_src_doubled <- unique(src[, c("Reference", "Standardized_Term")])  # stamped in step 7
  # Step 7b stamps `published_bilateral_estimate` from `long` (every contributing source). Sound for
  # Tier-2, where teams are averaged; NOT for Tier-1, where most-recent-wins can discard a source
  # that would still get flagged. Enforce the assumption rather than leave it implicit.
  .t1_doubled <- intersect(lat_src_doubled$Reference,
                           papers$item[papers$team == "Stephan_collection"])
  if (length(.t1_doubled))
    stop("laterality_known.csv: `doubling = by_source` on Tier-1 (Stephan_collection) table(s) ",
         paste(.t1_doubled, collapse = ", "), ". Step 7b stamps from `long`, so a Tier-1 source ",
         "that loses the most-recent-wins pick would still be flagged. Stamp from `t1res` first.",
         call. = FALSE)
  # NOTE the registry is filtered to this merge's tables above, so rows for unselected sources are
  # not validated here. Registry-wide validation lives in _checks/check_laterality_doubling.py.
}
# Species-name normaliser (used by the step-4 curated-override matcher).
nrm <- function(x) tolower(trimws(gsub("\\s+"," ", gsub("[._]"," ", x))))
num <- function(x) suppressWarnings(as.numeric(gsub(",","", as.character(x))))

paper_long <- function(row) {
  it <- row$item; df <- read_item(it); tmap <- terms %>% filter(Reference == it)

  # Canonicalize column headers to the term map's Original_Term spelling up front. TSV headers drift
  # in case/punctuation after re-encoding (e.g. nucleus_tractus_olfactorius_mm3 vs the term map's
  # Nucleus_..._mm3), which would otherwise break the paper-specific reshapes below (they reference
  # the term-map spelling) and the generic matcher. Columns absent from the term map are left as-is.
  # Then fold a bare species / "Species name" header into "Species".
  .ck <- function(x) tolower(gsub("[ ._]+", "", x))
  .canon <- tmap$Original_Term[match(.ck(names(df)), .ck(tmap$Original_Term))]
  names(df) <- ifelse(is.na(.canon), names(df), .canon)
  .sp0 <- names(df)[tolower(names(df)) %in% c("species", "species name")]
  if (length(.sp0)) names(df)[names(df) == .sp0[1]] <- "Species"
  # --- paper-specific reshapes (step 3) ---
  if (it == "Zilles_Rehkämper_1988_Table12-2") {                # structure-rows -> one Pongo row
    z <- df %>% transmute(Species = as.character(Species),   # raw; resolved in step 4
                          Variable = tmap$Standardized_Term[match(structure, tmap$Original_Term)],
                          Value = num(volume_mm3)) %>% filter(!is.na(Variable))
    return(z %>% mutate(Source = it, Team = row$team, Year = row$year))
  }
  if (it == "Bauernfeind_etal_2013_Table1") {                   # per-individual -> species means (Pongo merge), mg->g
    df <- df %>% mutate(lab = ifelse(Species %in% c("Pongo abelii","Pongo pygmaeus"),
                                     "Pongo pygmaeus and Pongo abelii", Species))
    meas <- c("granular_L_mm3","dysgranular_L_mm3","agranular_L_mm3","FI_L_mm3","total_insula_L_mm3","brain_volume_mm3","brain_mass_mg","body_mass_g")
    spm <- df %>% group_by(Species, lab) %>% summarise(across(all_of(meas), ~mean(num(.x), na.rm=TRUE)), .groups="drop")
    df  <- spm %>% group_by(lab) %>% summarise(across(all_of(meas), ~mean(.x, na.rm=TRUE)), .groups="drop") %>%
           mutate(brain_mass_mg = brain_mass_mg/1000) %>% rename(Species = lab)
  }
  if (it == "Bauernfeind_etal_2013_Table2") {                   # per-individual RIGHT insula -> species means (Pongo merge), already mm3
    df <- df %>% mutate(lab = ifelse(Species %in% c("Pongo abelii","Pongo pygmaeus"),
                                     "Pongo pygmaeus and Pongo abelii", Species))
    meas <- c("granular_R_mm3","dysgranular_R_mm3","agranular_R_mm3","FI_R_mm3","total_insula_R_mm3")
    spm <- df %>% group_by(Species, lab) %>% summarise(across(all_of(meas), ~mean(num(.x), na.rm=TRUE)), .groups="drop")
    df  <- spm %>% group_by(lab) %>% summarise(across(all_of(meas), ~mean(.x, na.rm=TRUE)), .groups="drop") %>%
           rename(Species = lab)
  }
  if (it %in% c("MacLeod_etal_2003_Table1", "MacLeod_etal_2003_Table2")) {  # per-individual -> species means, cm3->mm3
    meas <- c("cerebellum_volume_cm3","vermis_volume_cm3","hemisphere_volume_cm3","brain_volume_cm3")
    df <- df %>% group_by(Species) %>% summarise(across(all_of(meas), ~mean(num(.x)*1000, na.rm=TRUE)), .groups="drop")
  }
  if (it == "Bush_Allman_2003_Table1")                           # cm3 -> mm3
    df <- df %>% mutate(across(ends_with("_cm3"), ~num(.x)*1000))
  if (it == "Bush_Allman_2004_a_Table2")                         # derive combined Neocortex (GM+WM) before the generic cm3->mm3 pass below picks it up
    df <- df %>% mutate(neocortex_GMWM_cm3 = num(neocortex_grey_cm3) + num(neocortex_white_cm3))
  if (it %in% c("Bush_Allman_2004_b_TABLE1", "Bush_Allman_2004_a_Table2"))  # cm3 -> mm3 (whole brain, neocortex grey/white/combined; V1 grey, LGN for _b)
    df <- df %>% mutate(across(ends_with("_cm3"), ~num(.x)*1000))
  if (it == "deSousa_etal_2010_Table1")                          # PER-SPECIMEN cm3 -> mm3. The TSV holds brain_volume_cm3, neocortex_volume_cm3, and LEFT-side left_V1_volume_cm3 / left_LGN_volume_cm3 (cm3); the Table-1 term map maps V1/LGN to *_left_Vol.mm3 (left hemisphere only, printed UNDOUBLED -- the paper's Supp. Table 2 carries the authors' doubled 2x-left ESTIMATES, not bilateral measurements; see laterality_known.csv `doubling`). This line does real work (converts all four _cm3 columns to mm3); it is NOT a no-op.
    df <- df %>% mutate(across(ends_with("_cm3"), ~num(.x)*1000))
  if (it == "Smaers_etal_2011_SupplementaryTable1") {            # per-individual frontal -> species means of COMBINED L+R (cm3->mm3)
    fix <- c("Cercopithecus ascianus"="Cercopithecus ascanius","Cercocebus albigena"="Lophocebus albigena",
             "Procolobus badius"="Piliocolobus badius","Lagothrix lagotricha"="Lagothrix lagothricha")
    df <- df %>% mutate(Species = ifelse(Species %in% names(fix), fix[Species], Species)) %>%
      group_by(Species) %>%
      summarise(frontal_white_total_cm3 = mean(num(frontal_white_total_cm3)*1000, na.rm = TRUE),
                frontal_grey_total_cm3  = mean(num(frontal_grey_total_cm3) *1000, na.rm = TRUE), .groups = "drop")
  }
  if (it == "Stephan_etal_1987_Table1")                          # NTO printed "0" = "not determinable with certainty" (data dictionary), not a true zero -> NA
    df <- df %>% mutate(Nucleus_tractus_olfactorius_mm3 =
            ifelse(num(Nucleus_tractus_olfactorius_mm3) == 0, NA_real_, num(Nucleus_tractus_olfactorius_mm3)))
  if (it == "Barger_etal_2007_TABLE1") {                         # per-specimen amygdala subnuclei (both-hemisphere _total) -> species means; cm3 -> mm3
    meas <- c("hemispheres_cm3","amygdaloid_complex_total","basolateral_total","lateral_total","basal_total","accessory_basal_total")
    df <- df %>% group_by(Species) %>%
      summarise(across(all_of(meas), ~ mean(num(.x) * 1000, na.rm = TRUE)), .groups = "drop")
  }
  if (it == "Barger_etal_2014_Table1") {                         # per-specimen ONE-HEMISPHERE volumes (cc): x2 -> both sides, cc->mm3, species-mean
    # Table 1 footnote: every printed volume is a SINGLE hemisphere. DeCasien reports these regions
    # bilaterally (their ape hippocampus/amygdala/striatum == 2x Barger's one-side value, confirmed
    # e.g. Hylobates lar hippocampus 0.805 cc -> 2*0.805*1000 = 1610 mm3). So double to both-sides
    # (matches our both-sides "_Vol.mm3" terms and Barger 2007's both-hemisphere totals) and convert
    # cc->mm3. NOTE: like MacLeod/Bauernfeind, multi-specimen species are averaged to a species mean,
    # so DeCasien's PER-SPECIMEN ape values (e.g. Pan hippocampus 3544 & 3040) match only where a
    # species has a single specimen (e.g. Hylobates lar, Nomascus concolor).
    meas <- c("amygdala_total_cc","hippocampus_cc","striatum_cc",
              "amygdala_lateral_cc","amygdala_basal_cc","amygdala_accessory_basal_cc",
              "amygdala_central_cc")
    df <- df %>% group_by(Species) %>%
      summarise(across(all_of(meas), ~ mean(num(.x) * 2 * 1000, na.rm = TRUE)), .groups = "drop")
  }
  if (it == "Sherwood_etal_2004_TABLEI") {                       # per-specimen great-ape volumes (cm3): fill species (NA = same as above),
    meas <- c("Whole Brain","Neocortex","Hippocampus","Striatum","Thalamus","Cerebellum")  #  species-mean, cm3->mm3
    df <- df %>%
      mutate(Species = na_if(str_squish(as.character(Species)), "NA")) %>%
      fill(Species, .direction = "down") %>%
      mutate(Species = word(Species, 1, 2)) %>%
      group_by(Species) %>%
      summarise(across(all_of(meas), ~ mean(num(.x) * 1000, na.rm = TRUE)), .groups = "drop")
  }
  if (it == "Barks_etal_2014_TABLE1") {                          # per-specimen gorilla brain volume (cm3): subspecies->binomial, species-mean, cm3->mm3
    df <- df %>% mutate(Species = word(str_squish(Species), 1, 2)) %>%
      group_by(Species) %>%
      summarise(`Brain volume (cm3)` = mean(num(`Brain volume (cm3)`) * 1000, na.rm = TRUE), .groups = "drop")
  }
  if (it == "Rilling_Insel_1998_Table1") {                       # one row/species; cc->mm3 (vol) and kg->g (body mass); harmonize Cercocebus
    df <- df %>%
      mutate(Species = ifelse(Species == "Cercocebus atys", "Cercocebus torquatus", Species),
             brain_volume_cc      = num(brain_volume_cc)      * 1000,
             cerebellum_volume_cc = num(cerebellum_volume_cc) * 1000,
             body_weight_kg       = num(body_weight_kg)       * 1000)
  }
  if (it == "Rilling_Insel_1999_Table1") {                 # one row/species; derive total neocortex grey+white; convert MEANS and SDs
    # cc->mm3 and kg->g for both the mean and its SD (SD scales linearly). Spinal-cord area
    # mean/SD are already mm2 -> left for the generic num() (no conversion). No combined-neocortex
    # SD is derived (SD of GM+WM needs the covariance, which the table does not report).
    df <- df %>%
      mutate(Species = ifelse(Species == "Cercocebus atys", "Cercocebus torquatus", Species),
             Neocortex_GMWM = (num(neocortical_gray_matter_cc_mean) + num(cerebral_white_matter_cc_mean)) * 1000,
             across(c(neocortical_gray_matter_cc_mean, cerebral_white_matter_cc_mean,
                      brain_volume_cc_mean, body_weight_kg_mean,
                      neocortical_gray_matter_cc_sd, cerebral_white_matter_cc_sd,
                      brain_volume_cc_sd, body_weight_kg_sd), ~ num(.x) * 1000))
  }
  if (it == "Stimpson_etal_2015_TableS2") {                 # per-subject one-side amygdala volumes (whole + 4 subnuclei)
    # The TSV carries one clean volume_cm3 per (subject, structure); SERT axon density is a
    # separate column (ignored here) and the control regions (MTG, caudate) have no volume.
    # Species mean of bilateral volume (one-side x2), cm3->mm3. Rows with no volume (control
    # regions; subjects missing a volume) drop out via the NA filter. Columns pivot back to the
    # raw structure names, which the term map maps to Amygdala[_<nucleus>]_Vol.mm3 (Barger naming).
    df <- df %>%
      mutate(volume_cm3 = num(volume_cm3)) %>%
      filter(!is.na(volume_cm3)) %>%
      group_by(Species, structure) %>%
      summarise(v = mean(volume_cm3 * 2 * 1000, na.rm = TRUE), .groups = "drop") %>%
      pivot_wider(names_from = structure, values_from = v)
  }
  if (it == "Stimpson_etal_2015_TableS1") {                 # per-subject brain MASS (g): species-mean, g->mg
    df <- df %>% group_by(Species) %>%
      summarise(brain_mass_g = mean(num(brain_mass_g) * 1000, na.rm = TRUE), .groups = "drop")
  }
  # --- generic wide -> long via standardized terms ---
  # The species column is found from the term map (the Original_Term whose Standardized_Term ==
  # "Species") — no hand-coded spcol. Raw species names are kept here and harmonized in step 4
  # (NCBI + curated overrides). Excluding spcol from `keep` also stops num() from coercing the
  # species NAMES to NA doubles (the old Sherwood_2004 "Species" -> <double> bind_rows crash).
  # Species column: the up-front normalizer already renamed it to "Species"; fall back to the term-map
  # Species row / a case-insensitive "species" column just in case. Error loudly if absent.
  spcand <- tmap$Original_Term[tmap$Standardized_Term == "Species"]
  spcol  <- spcand[spcand %in% names(df)][1]
  if (is.na(spcol)) spcol <- names(df)[match(TRUE, tolower(names(df)) == "species")]
  if (is.na(spcol)) spcol <- grep("^species", names(df), ignore.case = TRUE, value = TRUE)[1]
  if (is.na(spcol)) stop("paper_long('", it, "'): no species column found. Columns: ",
                         paste(names(df), collapse = ", "), call. = FALSE)
  # Match data columns to term-map Original_Terms CASE/SEPARATOR-INSENSITIVELY: re-encoded TSVs drift
  # in case/punctuation (e.g. corpus_geniculatum_laterale_mm3 vs Corpus_...). Exclude the species col.
  ckey <- function(x) tolower(gsub("[ ._]+", "", x))
  tkey <- ckey(tmap$Original_Term)
  keep <- names(df)[ckey(names(df)) %in% tkey & names(df) != spcol]
  if (!length(keep))
    stop("paper_long('", it, "'): no measured columns matched the term map. df cols: ",
         paste(names(df), collapse = ", "), call. = FALSE)
  df %>% transmute(Species = as.character(.data[[spcol]]),
                   across(all_of(keep), num)) %>%
    pivot_longer(-Species, names_to="orig", values_to="Value") %>%
    filter(!is.na(Value)) %>%
    mutate(Variable = tmap$Standardized_Term[match(ckey(orig), tkey)],
           Source = it, Team = row$team, Year = row$year) %>%
    select(Species, Variable, Value, Source, Team, Year)
}
long <- bind_rows(lapply(seq_len(nrow(papers)), function(i) paper_long(papers[i, ])))

## 4 Species resolution: NCBI backbone + curated, source-aware overrides ----
## Mirrors ../__merging_cellcounts §4 (NCBI preferred names via taxizedb) but ADDS:
##  (i)   curated project decisions WIN over NCBI (e.g. Gorilla sp., subspecies->binomial, synonyms);
##  (ii)  resolution is SOURCE-AWARE — curated overrides are keyed by Reference (= item name) AND the
##        raw variant name, so the same label can resolve differently in different papers;
##  (iii) a reviewable mapping table is written (raw -> NCBI -> curated -> final, with flags);
##  (iv)  variants that now collapse to one accepted name are aggregated/averaged in steps 5-6.
library(taxizedb)
raw  <- long %>% distinct(Source, Species) %>% rename(Species_raw = Species)
uniq <- sort(unique(raw$Species_raw))

# (a) NCBI backbone (source-independent): preferred scientific name per raw name (NA if unmatched)
ncbi_ids <- name2taxid(uniq, out_type = "summary")
ncbi <- tibble(
  Species_raw = uniq,
  NCBI_id = ncbi_ids$id[match(uniq, ncbi_ids$name)]
)
ncbi_name_vec <- taxid2name(unique(na.omit(ncbi$NCBI_id)), out_type = "summary")
names(ncbi_name_vec) <- unique(na.omit(ncbi$NCBI_id))
ncbi <- ncbi %>%
  mutate(NCBI_name = unname(ncbi_name_vec[as.character(NCBI_id)]))

# (b) curated overrides (source-aware), keyed by Reference (= item name) + variant name
ov <- read.csv(file.path(base, "_keys/volumes_species_overrides.csv"), stringsAsFactors = FALSE) %>%
  transmute(Source = Reference, key = nrm(variant_name), curated = accepted_name) %>%
  distinct(Source, key, .keep_all = TRUE)

# (c) resolve: curated WINS, else NCBI preferred, else the raw name (flagged)
resolved <- raw %>%
  mutate(key = nrm(Species_raw)) %>%
  left_join(ov,   by = c("Source", "key")) %>%
  left_join(ncbi, by = "Species_raw") %>%
  mutate(Species_final = dplyr::coalesce(curated, NCBI_name, Species_raw),
         name_source   = dplyr::case_when(!is.na(curated)   ~ "curated",
                                          !is.na(NCBI_name) ~ "NCBI",
                                          TRUE              ~ "unresolved_raw"),
         flag_curated_overrides_ncbi = !is.na(curated) & !is.na(NCBI_name) & nrm(curated) != nrm(NCBI_name),
         flag_unresolved             = is.na(curated) & is.na(NCBI_name)) %>%
  select(-key)
write_csv(resolved %>% arrange(Source, Species_raw), DeCasien_csv("volumes_source_species_ids"))
if (any(resolved$flag_unresolved))
  warning("Species resolution: ", sum(resolved$flag_unresolved), " (source, name) pair(s) had no ",
          "curated override and no NCBI match -> kept raw. See volumes_source_species_ids_DeCasien.csv.")

# (d) apply resolved accepted names back to the long table (source-aware)
long <- long %>%
  left_join(resolved %>% select(Source, Species_raw, Species_final),
            by = c("Source", "Species" = "Species_raw")) %>%
  mutate(Species = Species_final) %>% select(-Species_final)

write_csv(long, DeCasien_csv("volumes_unfiltered"))
is_mass <- function(v) v %in% c("Body_Mass.g","Brain_Mass.mg")

## 5 Tier-1 resolution (Stephan_collection): most recent; mass -> Stephan 1981; flag deviations ----
flags <- tibble(Species=character(), Variable=character(), flag=character(), detail=character())
t1 <- long %>% filter(Team == "Stephan_collection") %>% arrange(Species, Variable, desc(Year))
## `keep_i` is the index of the row actually taken, so Source/Year can be stamped from the SAME row
## as Value (never re-derived) -- what makes the Sources column real provenance rather than a guess.
t1res <- t1 %>% group_by(Species, Variable) %>% summarise(
  keep_i = if (is_mass(first(Variable))) {
             s81 <- which(grepl("^Stephan_etal_1981_Table(I{1,3})$", Source))
             if (length(s81)) s81[1] else 1L
           } else 1L,
  Value = Value[keep_i], Source = Source[keep_i], Year = Year[keep_i],
  .groups = "drop") %>% select(-keep_i)
# flags: newest vs next within Tier-1 (non-mass)
t1 %>% group_by(Species, Variable) %>% filter(n() > 1, !is_mass(first(Variable))) %>%
  summarise(v0=Value[1], s0=Source[1], v1=Value[2], s1=Source[2], .groups="drop") %>%
  filter(abs(v0-v1)/abs(v1) > 0.5) %>%
  transmute(Species, Variable, flag="deviation", detail=paste0(s0,"=",v0," vs ",s1,"=",v1)) -> flags
write_csv(flags, DeCasien_csv("volumes_flags"))

## 6 Tier-2 (each its own team, mean within team) + cross-team average ----
## Within a Tier-2 team the value is the MEAN over that team's tables, so its provenance is a SET of
## item names, not one: keep them all (" + "), plus the newest year among them.
t2 <- long %>% filter(Team != "Stephan_collection") %>%
  group_by(Species, Variable, Team) %>% summarise(
    Value = mean(Value),
    Source = paste(sort(unique(Source)), collapse = " + "),
    Year = max(Year), .groups="drop")
teamvals <- bind_rows(t1res %>% mutate(Team = "Stephan_collection"), t2)

## ---- 6b Per-cell source provenance (mirrors step 6b of volumes_compiled.R) --------------------
## `Teams` is a lab/collection grouping, not a reference, so it cannot be cited. These columns name
## the actual TABLES behind each number: Sources / n_sources / Source_detail ("Team: item | ...") /
## Year_used. Item name -> APA citation is volumes_source_citations_DeCasien.csv (step 8b).
volumes_long <- teamvals %>% group_by(Species, Variable) %>% summarise(
  # mass: Stephan reference only (no cross-team avg) -> take that team's row wholesale, so Sources
  # names the reference table actually used rather than every team that reports a mass.
  keep_i = if (is_mass(first(Variable)))
             { sc <- which(Team == "Stephan_collection"); if (length(sc)) sc[1] else 1L } else NA_integer_,
  Value = if (is.na(keep_i)) mean(Value) else Value[keep_i],
  Teams = if (is.na(keep_i)) paste(sort(unique(Team)), collapse="; ") else Team[keep_i],
  n_teams = if (is.na(keep_i)) n_distinct(Team) else 1L,
  # always a "; " list of INDIVIDUAL item names: a Tier-2 team that averaged several of its own
  # tables arrives as "A + B", so split before re-collapsing.
  Sources = { s <- if (is.na(keep_i)) Source else Source[keep_i]
              paste(sort(unique(trimws(unlist(strsplit(s, " + ", fixed = TRUE))))), collapse = "; ") },
  n_sources = { s <- if (is.na(keep_i)) Source else Source[keep_i]
                n_distinct(trimws(unlist(strsplit(s, " + ", fixed = TRUE)))) },
  Source_detail = { i <- if (is.na(keep_i)) order(Team) else keep_i
                    paste(paste0(Team[i], ": ", Source[i]), collapse = " | ") },
  Year_used = if (is.na(keep_i)) max(Year) else Year[keep_i],
  .groups="drop") %>%
  select(-keep_i) %>%
  arrange(Species, Variable)
write_csv(volumes_long, DeCasien_csv("volumes_long"))

## 7 Phase-4 hemisphere reconciliation -> whole-structure both-hemisphere volumes ----
## See README__merging.md "Hemispheres". For structures measured per hemisphere we add a
## whole-structure both-sides variable (no laterality suffix):
##   both sides measured -> SUM (left + right)         [Bauernfeind insula: Table 1 + Table 2]
##   one side only       -> ESTIMATE as 2x, flagged    [left-only insula species; Stephan vestibular;
##                                                       Sherwood_etal_2005_Table1 cranial motor nuclei
##                                                       (Vmo/VII/XII -- see laterality_known.csv,
##                                                       "measured on the left side only")]
## Estimates never overwrite the one-side value; they are added as new both-sides variables and
## recorded in volumes_flags_DeCasien.csv (flag = estimated_bilateral_from_unilateral).
wide_v <- volumes_long %>% select(Species, Variable, Value) %>%
  pivot_wider(names_from = Variable, values_from = Value)
mk <- function(stem) c(left = paste0(stem, "_left_Vol.mm3"),
                       right = paste0(stem, "_right_Vol.mm3"),
                       both = paste0(stem, "_Vol.mm3"))
bilateral_stems <- c("Granular_insular_cortex","Dysgranular_insular_cortex",
                  "Agranular_insular_cortex","fronto_insular_cortex","Insula",
                  # cranial motor nuclei (Sherwood 2005): left-only, like the vestibular nuclei
                  # below, but named with the standard _left suffix rather than _unilateral, so
                  # they need to be in this loop (not the vestib_unil one) to get a both-sides
                  # Vol.mm3 built. R (right) never exists for these -> always falls to the 2x-
                  # estimate branch, exactly like a one-side-only insula species.
                  "Trigeminal_motor_nucleus","Facial_motor_nucleus","Hypoglossal_nucleus")
vestib_unil  <- grep("_unilateral_Vol\\.mm3$", names(wide_v), value = TRUE)
getcol <- function(nm) if (nm %in% names(wide_v)) wide_v[[nm]] else rep(NA_real_, nrow(wide_v))

bilat <- list()
for (st in bilateral_stems) {                                # left (+right) -> both
  m <- mk(st); L <- getcol(m["left"]); R <- getcol(m["right"])
  both <- ifelse(!is.na(L) & !is.na(R), L + R,
          ifelse(!is.na(L), 2*L, ifelse(!is.na(R), 2*R, NA_real_)))
  est  <- xor(!is.na(L), !is.na(R))                          # only one side present -> doubled
  src  <- ifelse(!is.na(L), m["left"], m["right"])
  k <- !is.na(both)
  bilat[[unname(m["both"])]] <- tibble(Species = wide_v$Species[k], Variable = unname(m["both"]),
                                       Value = both[k], est = est[k], src = src[k])
}
for (uv in vestib_unil) {                                    # one side only -> 2x (flagged)
  bv <- sub("_unilateral_Vol\\.mm3$", "_Vol.mm3", uv); U <- getcol(uv); k <- !is.na(U)
  bilat[[bv]] <- tibble(Species = wide_v$Species[k], Variable = bv, Value = 2*U[k],
                        est = TRUE, src = uv)
}
bilat <- bind_rows(bilat)
# Prefer a real both-sides value over a doubled estimate: drop any estimate whose both-sides
# variable already exists for that species (e.g. Baron 1988 measured the vestibular complex
# bilaterally, so its real value wins over 2x the Stephan one-side figure).
bilat <- bilat %>% anti_join(volumes_long %>% distinct(Species, Variable), by = c("Species","Variable"))
## A derived both-sides value inherits the provenance of the one-side variable it was built from --
## that is the paper a reader must cite for it, even though the arithmetic happened here.
src_meta <- volumes_long %>% transmute(Species, src = Variable, Teams, n_teams,
                                       Sources, n_sources, Source_detail, Year_used)
bilat_long <- bilat %>% left_join(src_meta, by = c("Species","src")) %>%
  transmute(Species, Variable, Value, Teams, n_teams)
volumes_long <- bind_rows(volumes_long, bilat_long) %>% arrange(Species, Variable)
write_csv(volumes_long, DeCasien_csv("volumes_long"))

flags <- bind_rows(flags,
  bilat %>% filter(est) %>%
    transmute(Species, Variable, flag = "estimated_bilateral_from_unilateral",
              detail = paste0("both-hemisphere estimated as 2x ", src, " (only one side measured)")))

## Provenance for the OTHER kind of doubling: values whose PUBLISHED figure is already 2x one side.
## Not a veto -- the value is used exactly as published. Mirrors step 7b of volumes_compiled.R;
## because this merge is multi-team a flagged cell is often a cross-team mean in which the doubled
## source is one contributor of several, so the detail says which.
if (nrow(lat_src_doubled)) {
  flags <- bind_rows(flags,
    long %>%
      inner_join(lat_src_doubled, by = c("Source" = "Reference", "Variable" = "Standardized_Term")) %>%
      distinct(Species, Variable, Source) %>%
      group_by(Species, Variable) %>%                       # 2 refs can share one term -> one row
      summarise(Source = paste(sort(unique(Source)), collapse = " + "), .groups = "drop") %>%
      left_join(volumes_long %>% select(Species, Variable, Teams, n_teams),
                by = c("Species", "Variable")) %>%
      transmute(Species, Variable, flag = "published_bilateral_estimate",
                detail = ifelse(
                  coalesce(n_teams, 1L) > 1L,
                  paste0("a contributing source publishes its figure as 2x one hemisphere, doubled ",
                         "by the source (not by this merge): ", Source, "; the merged value is the ",
                         "mean across ", n_teams, " teams (", Teams, ") -- see laterality_known.csv"),
                  paste0("published value is 2x one hemisphere, doubled by the source (not by ",
                         "this merge): ", Source, " -- see laterality_known.csv"))))
}
write_csv(flags, DeCasien_csv("volumes_flags"))

volumes_wide <- volumes_long %>% pivot_wider(id_cols=Species, names_from=Variable, values_from=Value) %>% arrange(Species)
write_csv(volumes_wide, DeCasien_csv("volumes_wide"))
# inventory: which sources contributed each (resolved) species
long %>% group_by(Species_Name = Species) %>% summarise(n_sources=n_distinct(Source), Sources=paste(sort(unique(Source)),collapse="; ")) %>%
  write_csv(DeCasien_csv("volumes_species_sources"))

## ---- 8b Publication provenance: contributions + citations (mirrors volumes_compiled.R 8b) -----
##   volumes_source_contributions_DeCasien.csv  one row per species x variable x CONTRIBUTING TABLE
##   volumes_source_citations_DeCasien.csv      item name -> APA citation, DOI/ISBN, WHICH TABLE
contrib <- volumes_long %>%
  select(Species, Variable, merged_Value = Value, Sources, Teams, n_teams, n_sources, Year_used) %>%
  separate_longer_delim(Sources, delim = "; ") %>%
  rename(Source = Sources) %>%
  left_join(long %>% group_by(Species, Variable, Source, Team, Year) %>%
              summarise(source_Value = mean(Value), n_rows_in_source = n(), .groups = "drop"),
            by = c("Species","Variable","Source")) %>%
  mutate(role = case_when(
           # step 7's both-sides variables are arithmetic on a one-side table, which prints no figure
           # for this term: source_Value is legitimately absent, not missing data.
           is.na(source_Value) ~ paste0("derived both-hemisphere value (step 7: left+right, or 2x a ",
                                        "one-side measurement); cite this source for the one-side figure"),
           is_mass(Variable) ~ "reference table used (mass rule: other sources not averaged in)",
           n_sources == 1L   ~ "sole source",
           TRUE              ~ "averaged into the merged value"),
         pct_diff_from_merged = ifelse(!is.na(source_Value) & merged_Value != 0,
                                       round(100 * (source_Value - merged_Value) / merged_Value, 2),
                                       NA_real_)) %>%
  select(Species, Variable, Source, Team, Year, source_Value, merged_Value,
         pct_diff_from_merged, role, n_rows_in_source, Teams, n_teams, n_sources, Year_used) %>%
  arrange(Species, Variable, Source)
source(file.path(folder, "source_citations.R"))
citations <- source_citations(base, unique(c(long$Source, contrib$Source)))
write_csv(citations, DeCasien_csv("volumes_source_citations"))
contrib <- contrib %>%
  left_join(citations %>% select(Source, Cited_as, DOI_or_ISBN), by = "Source") %>%
  relocate(Cited_as, DOI_or_ISBN, .after = Source)
write_csv(contrib, DeCasien_csv("volumes_source_contributions"))
message("[DeCasien] Provenance: ", nrow(contrib), " contribution(s) from ", nrow(citations),
        " citable source table(s); ", sum(is.na(citations$Citation)), " without a registry citation.")

message("[DeCasien] ", nrow(volumes_wide), " species x ", ncol(volumes_wide)-1, " variables from ",
        nrow(papers), " tables | flags: ", nrow(flags), " | outputs: volumes_*_DeCasien.csv")

## 9 Compare this DeCasien merge against DeCasien & Higham 2019 ----
## Reuse the maintained value-match comparison (no duplicated logic), pointed at the DeCasien outputs.
## Writes DeCasien_Higham_2019/DeCasien_vs_merge_comparison_DeCasien.csv (+ _DeCasien findings/taxonomy).
merge_suffix <- output_suffix
decasien_comparison_script_path <- file.path(
  base, "DeCasien_Higham_2019", "DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R")
source(decasien_comparison_script_path)
