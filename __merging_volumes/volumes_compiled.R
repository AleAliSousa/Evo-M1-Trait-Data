# Merging histologically-derived brain-structure VOLUMES  (two-tier resolution)
# Mirror of ../__merging_cellcounts/cellcounts_compiled.R for the volume data type.
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

## 1 Papers: item_name, team, year — the FULL volume collection ----
## Includes the DeCasien & Higham 2019 brain-volume sources (added at the end) PLUS the rest of the
## collection. The DeCasien-only subset and the merge-vs-DeCasien comparison live in
## volumes_compiled_DeCasien.R. No per-paper species token/column: the species COLUMN is found from
## the term map and species NAMES are resolved in step 4 (NCBI + curated overrides). See README.
papers <- tribble(
  ~item,                                  ~team,                ~year,
  # Stephan 1970 split one-item-per-printed-table (was bundled Tables1-6). Tables 1-3 =
  # fundamental parts in insectivores/prosimians/simians; Tables 4-6 = telencephalon components, same taxa.
  "Stephan_etal_1970_Table1",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table2",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table3",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table4",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table5",             "Stephan_collection", 1970,
  "Stephan_etal_1970_Table6",             "Stephan_collection", 1970,
  # Stephan 1981 split one-item-per-printed-table (was bundled TablesI-VI, which actually spanned I-XVI).
  "Stephan_etal_1981_TableI",             "Stephan_collection", 1981,
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
  "Stephan_etal_1982_Table1",             "Stephan_collection", 1982,
  "Stephan_etal_1984_Table1",             "Stephan_collection", 1984,
  "Stephan_etal_1987_Table1",             "Stephan_collection", 1987,
  "Frahm_etal_1982_Table2",               "Stephan_collection", 1982,
  "Frahm_etal_1984_Table1",               "Stephan_collection", 1984,
  "Frahm_Zilles_1994_Table1",             "Stephan_collection", 1994,
  "Frahm_etal_1997_Table1",               "Stephan_collection", 1997,
  "Frahm_etal_1998_Table1",               "Stephan_collection", 1998,
  "Baron_etal_1983_Table1",               "Stephan_collection", 1983,
  "Baron_etal_1987_Table1",               "Stephan_collection", 1987,
  "Baron_etal_1988_Table1",               "Stephan_collection", 1988,
  "Baron_etal_1990_Table1",               "Stephan_collection", 1990,
  "Matano_etal_1985_a_Table1",            "Stephan_collection", 1985,
  "Matano_etal_1985_b_Table1",            "Stephan_collection", 1985,
  "Zilles_Rehkämper_1988_Table12-2",      "Stephan_collection", 1988,
  "deSousa_etal_2010_Table1",             "Zilles",             2010,
  "deSousa_etal_2013_Table1",             "Zilles",             2013,
  "MacLeod_etal_2003_Table1",             "Zilles",             2003,
  "MacLeod_etal_2003_Table2",             "Zilles",             2003,
  "Bauernfeind_etal_2013_Table1",         "Zilles",             2013,
  "Bauernfeind_etal_2013_Table2",         "Zilles",             2013,
  "Bush_Allman_2003_Table1",              "Bush",               2003,
  "Bush_Allman_2004_b_TABLE1",            "Bush",               2004,
  "Bush_Allman_2004_a_Table2",            "Bush",               2004,  # ref 55 (frontal/neocortex GM+WM; 55 spp incl. Cheirogaleus/Mandrillus). Derives Neocortex_Vol.mm3 (GM+WM) in the reshape below. Same team 'Bush' as 2003/2004b (Tier-2, averaged).
  "Smaers_etal_2011_SupplementaryTable1", "Zilles",             2011,
  "Ashwell__2020_SupplementaryTable",     "Ashwell",            2020,
  "Semendeferi_etal_1998_Table2",         "Zilles",             1998,
  "Semendeferi_etal_2001_Table2",         "Zilles",             2001,
  "Sherwood_etal_2005_Table1",            "Zilles",             2005,
  "Barger_etal_2007_TABLE1",              "Zilles",             2007,

  # --- DeCasien & Higham 2019 brain-volume sources (so this master includes them too) ---
  # The DeCasien-only SUBSET + the merge-vs-DeCasien comparison live in volumes_compiled_DeCasien.R.
  "Sherwood_etal_2004_TABLEI",            "Sherwood",           2004,  # ref 64
  "Barks_etal_2014_TABLE1",               "Barks",              2014,  # ref 65
  "Rilling_Insel_1998_Table1",            "RillingInsel",       1998,  # ref 62
  "Stimpson_etal_2015_TableS1",           "Stimpson",           2015,  # ref 58
  # DeCasien-extracted (MOESM3); NB 62-63 NEOCORTEX is Rilling & Insel 1999 (ref 63), not 1998.
  "Barks_etal_2014_Fig4A",                "Barks",              2014,  # ref 65 regional volumes (Barks Fig 4A; replaces viaDeCasien)
  "Rilling_Insel_1999_Table1",       "RillingInsel",       1999,  # ref 63 (neocortex)
  "Stimpson_etal_2015_TableS2",       "Stimpson",           2015   # ref 58 (extra structures)
)
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
# Fallback encodings for items not yet given a row in __ReadMe.xlsx (the registry sheet is
# maintained by hand to preserve its formula columns). Remove an entry once its row exists.
enc_override <- c(# DOI-coded tables: registry resolves them, but keep DOI-encoded fallbacks so a
                  # registry rename/case-drift can't send them to NA.tsv.
                  "Rilling_Insel_1999_Table1" = "10.1006%2Fjhev.1999.0313_Table1",
                  "Barks_etal_2014_Fig4A"          = "10.1002%2Fajpa.22646_Fig4A",
                  "Stimpson_etal_2015_TableS2" = "10.1093%2Fscan%2Fnsv128_TableS2",
                  # DeCasien primaries: these DO have __ReadMe.xlsx rows, but keep fallbacks so a
                  # registry rename/case-drift can't silently send them to NA.tsv.
                  "Sherwood_etal_2004_TABLEI"   = "10.1002%2Fajp.20048_TABLEI",
                  "Barks_etal_2014_TABLE1"      = "10.1002%2Fajpa.22646_TABLE1",
                  "Bush_Allman_2004_a_Table2"   = "10.1073%2Fpnas.0305760101_Table2",
                  "Rilling_Insel_1998_Table1"   = "10.1159%2F000006575_Table1",
                  "Stimpson_etal_2015_TableS1"  = "10.1093%2Fscan%2Fnsv128_TableS1",
                  # Stephan 1970 split into 6 per-table items (ISBN-coded; The Primate Brain has no DOI).
                  "Stephan_etal_1970_Table1" = "ISBN%3A0390672505_TABLE1",
                  "Stephan_etal_1970_Table2" = "ISBN%3A0390672505_TABLE2",
                  "Stephan_etal_1970_Table3" = "ISBN%3A0390672505_TABLE3",
                  "Stephan_etal_1970_Table4" = "ISBN%3A0390672505_TABLE4",
                  "Stephan_etal_1970_Table5" = "ISBN%3A0390672505_TABLE5",
                  "Stephan_etal_1970_Table6" = "ISBN%3A0390672505_TABLE6",
                  # Stephan 1981 split into 16 per-table items. All share the paper's single DOI
                  # 10.1159/000155963; pin it here so the drifted VIII/IX/X registry encodings
                  # (000155964/5/6) can't send those tables to a missing TSV.
                  "Stephan_etal_1981_TableI"     = "10.1159%2F000155963_TableI",
                  "Stephan_etal_1981_TableII"    = "10.1159%2F000155963_TableII",
                  "Stephan_etal_1981_TableIII"   = "10.1159%2F000155963_TableIII",
                  "Stephan_etal_1981_TableIV"    = "10.1159%2F000155963_TableIV",
                  "Stephan_etal_1981_TableV"     = "10.1159%2F000155963_TableV",
                  "Stephan_etal_1981_TableVI"    = "10.1159%2F000155963_TableVI",
                  "Stephan_etal_1981_TableVII"   = "10.1159%2F000155963_TableVII",
                  "Stephan_etal_1981_TableVIII"  = "10.1159%2F000155963_TableVIII",
                  "Stephan_etal_1981_TableIX"    = "10.1159%2F000155963_TableIX",
                  "Stephan_etal_1981_TableX"     = "10.1159%2F000155963_TableX",
                  "Stephan_etal_1981_TableXI"    = "10.1159%2F000155963_TableXI",
                  "Stephan_etal_1981_TableXII"   = "10.1159%2F000155963_TableXII",
                  "Stephan_etal_1981_TableXIII"  = "10.1159%2F000155963_TableXIII",
                  "Stephan_etal_1981_TableXIV"   = "10.1159%2F000155963_TableXIV",
                  "Stephan_etal_1981_TableXV"    = "10.1159%2F000155963_TableXV",
                  "Stephan_etal_1981_TableXVI"   = "10.1159%2F000155963_TableXVI")
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
#                         carry the laterality suffix (_unilateral/_left/_right) so a one-side value
#                         can never be silently merged/averaged with a both-sides volume. If a
#                         both-sides partner is wanted, THIS MERGE builds it in step 7 and records
#                         `estimated_bilateral_from_unilateral`.
#   doubling = by_source  the PUBLISHED number is already 2x one side -- the paper's authors doubled
#                         it, with a stated symmetry argument (de Sousa 2010 V1/LGN; de Sousa 2013
#                         LGN). It is a deliberate both-sides ESTIMATE, so its term must carry NO
#                         laterality suffix, it is used exactly as published, and it must never be
#                         doubled a second time. Recorded as `published_bilateral_estimate`.
#
# BOTH are PROVENANCE, never vetoes: neither ever drops a value. Vetoes are a different mechanism
# entirely (volumes_select_value_flags.csv, action = skip).
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
  # Report only on the tables this merge actually reads, so the counts stay diagnostic.
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
  # doubling = by_source -> the published value already represents both sides, so the suffix is FORBIDDEN
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
  # Step 7b stamps `published_bilateral_estimate` from `long` (every contributing source). That is
  # sound for Tier-2, where teams are averaged so a contributor always contributes -- but NOT for
  # Tier-1, where most-recent-wins can discard a source that would still get flagged. Enforce the
  # assumption rather than leave it implicit.
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
  if (it %in% c("MacLeod_etal_2003_Table1", "MacLeod_etal_2003_Table2")) { # per-individual -> species means, cm3->mm3
    meas <- c("cerebellum_volume_cm3","vermis_volume_cm3","hemisphere_volume_cm3","brain_volume_cm3")
    df <- df %>% group_by(Species) %>% summarise(across(all_of(meas), ~mean(num(.x)*1000, na.rm=TRUE)), .groups="drop")
  }
  if (it == "Bush_Allman_2003_Table1")                           # cm3 -> mm3
    df <- df %>% mutate(across(ends_with("_cm3"), ~num(.x)*1000))
  if (it == "Bush_Allman_2004_b_TABLE1")                         # cm3 -> mm3 (V1 grey, LGN, whole brain, neocortex grey/white)
    df <- df %>% mutate(across(ends_with("_cm3"), ~num(.x)*1000))
  if (it == "Bush_Allman_2004_a_Table2")                         # derive combined Neocortex (GM+WM) before the generic cm3->mm3 pass picks it up (term map: neocortex_GMWM_cm3 -> Neocortex_Vol.mm3)
    df <- df %>% mutate(neocortex_GMWM_cm3 = num(neocortex_grey_cm3) + num(neocortex_white_cm3),
                        across(ends_with("_cm3"), ~num(.x)*1000))  # whole brain, neocortex grey/white/combined
  if (it == "deSousa_etal_2010_Table1")                          # per-specimen hominoid volumes: cm3 -> mm3 (per-specimen rows collapse to species mean in step 6). V1/LGN are LEFT-only and printed UNDOUBLED (laterality_known.csv, doubling = none); neocortex + whole-brain are both-hemisphere. The doubled 2x-left figures are the same paper's Supp. Table 2 (doubling = by_source), not merged here.
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
raw  <- long %>% distinct(Source, Species) %>% rename(Species_raw = Species)
uniq <- sort(unique(raw$Species_raw))

# (a) NCBI backbone (source-independent): preferred scientific name per raw name (NA if unmatched).
# OFFLINE FALLBACK: taxizedb needs a live NCBI taxdump. When it (or the network) is unavailable, read
# the committed backbone cache volumes_species_ids_cache.csv (raw -> NCBI_id/NCBI_name), so the merge
# regenerates without network. The cache is refreshed automatically on any successful live run (below).
cache_file <- "volumes_species_ids_cache.csv"
have_taxizedb <- suppressWarnings(requireNamespace("taxizedb", quietly = TRUE))
ncbi_live <- if (have_taxizedb) tryCatch({
  library(taxizedb)
  ids <- name2taxid(uniq, out_type = "summary")
  nm  <- tibble(Species_raw = uniq, NCBI_id = ids$id[match(uniq, ids$name)])
  nv  <- taxid2name(unique(na.omit(nm$NCBI_id)), out_type = "summary")
  names(nv) <- unique(na.omit(nm$NCBI_id))
  nm %>% mutate(NCBI_name = unname(nv[as.character(NCBI_id)]))
}, error = function(e) { message("taxizedb live resolution failed (", conditionMessage(e),
                                 ") -> using cache ", cache_file); NULL }) else {
  message("taxizedb not installed -> using NCBI backbone cache ", cache_file); NULL }
if (is.null(ncbi_live)) {
  if (!file.exists(cache_file))
    stop("Offline species resolution needs ", cache_file, " (taxizedb unavailable and no cache). ",
         "Run once with taxizedb installed to build it.", call. = FALSE)
  cache <- read.csv(cache_file, stringsAsFactors = FALSE, na.strings = c("NA", ""))
  # read.csv turns blank NCBI_name into "" unless na.strings catches it; force real NA so the
  # coalesce(curated, NCBI_name, Species_raw) below cannot be shadowed by an empty string
  # (that bug silently dropped every unresolved_raw name to Species_final = "").
  ncbi  <- cache %>% mutate(NCBI_name = ifelse(is.na(NCBI_name) | !nzchar(NCBI_name), NA_character_, NCBI_name)) %>%
    distinct(Species_raw, NCBI_id, NCBI_name)
  miss  <- setdiff(uniq, ncbi$Species_raw)
  if (length(miss))
    stop("NCBI backbone cache ", cache_file, " is missing ", length(miss), " raw name(s): ",
         paste(head(miss, 8), collapse = "; "), ". Refresh the cache with a live taxizedb run.",
         call. = FALSE)
  ncbi <- tibble(Species_raw = uniq) %>% left_join(ncbi, by = "Species_raw")
} else {
  ncbi <- ncbi_live
}

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
write_csv(resolved %>% arrange(Source, Species_raw), "volumes_source_species_ids.csv")
# Refresh the offline backbone cache ONLY on a successful live taxizedb run (never overwrite the
# committed cache from a cache-driven run, which would be circular).
if (!is.null(ncbi_live))
  write_csv(resolved %>% transmute(Source, Species_raw, curated, NCBI_id, NCBI_name,
                                   Species_final, name_source) %>% arrange(Source, Species_raw),
            cache_file)
if (any(resolved$flag_unresolved))
  warning("Species resolution: ", sum(resolved$flag_unresolved), " (source, name) pair(s) had no ",
          "curated override and no NCBI match -> kept raw. See volumes_source_species_ids.csv.")

# (d) apply resolved accepted names back to the long table (source-aware)
long <- long %>%
  left_join(resolved %>% select(Source, Species_raw, Species_final),
            by = c("Source", "Species" = "Species_raw")) %>%
  mutate(Species = Species_final) %>% select(-Species_final)

## 4b DeCasien Tier-2 gap-fill ----
## DeCasien & Higham 2019 is a COMPILATION of primaries, not an independent measurement, so it is
## ingested only where it fills a GENUINE coverage gap (a species x structure no primary in this
## corpus measures). The comparison script (DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R,
## run separately) writes DeCasien_gapfill_candidates.csv listing exactly those cells (DeCasien mean
## value, already on our canonical terms). We append them here as team "DeCasien" so they flow
## through the SAME Tier-2 cross-team average as every other independent series. Because the emitter
## tests coverage against non-DeCasien sources only, this loop is idempotent: re-running never
## double-counts, and as new primaries are wired in the corresponding gap-fills drop out on the next
## comparison run (primaries win). See DeCasien_ingestion_README.md. Missing file = no gap-fill
## (e.g. first-ever run before the comparison has been executed) -> skipped with a note.
gapfill_file <- file.path(base, "DeCasien_Higham_2019", "DeCasien_gapfill_candidates.csv")
if (file.exists(gapfill_file)) {
  gf <- read_csv(gapfill_file, show_col_types = FALSE)
  if (nrow(gf)) {
    gf_long <- gf %>% transmute(Species, Variable, Value,
                                Source = "DeCasien2019_MOESM3_meanvalue", Team = "DeCasien",
                                Year = 2019L)
    # never overwrite a species x variable a primary already provides (belt-and-braces vs the
    # emitter's own guard): drop any gap-fill row whose Species x Variable already exists in long
    gf_long <- gf_long %>% anti_join(long %>% distinct(Species, Variable), by = c("Species","Variable"))
    long <- bind_rows(long, gf_long)
    message("DeCasien gap-fill: ingested ", nrow(gf_long), " species x structure cell(s) as team 'DeCasien'.")
  } else message("DeCasien gap-fill: candidate file present but empty -> nothing to ingest.")
} else message("DeCasien gap-fill: no candidate file yet (run the comparison script) -> skipped.")

write_csv(long, "volumes_unfiltered.csv")
is_mass <- function(v) v %in% c("Body_Mass.g","Brain_Mass.mg")

## 5 Tier-1 resolution (Stephan_collection): most recent; mass -> Stephan 1981; flag deviations ----
flags <- tibble(Species=character(), Variable=character(), flag=character(), detail=character())
t1 <- long %>% filter(Team == "Stephan_collection") %>% arrange(Species, Variable, desc(Year))
t1res <- t1 %>% group_by(Species, Variable) %>% summarise(
  Value = if (is_mass(first(Variable))) {
            # Mass -> Stephan 1981 reference. Body/brain mass live in the 1981 fundamental tables,
            # split from the former bundled "Stephan_etal_1981_TablesI-VI" into per-taxon Tables I/II/III.
            s81 <- Value[grepl("^Stephan_etal_1981_Table(I{1,3})$", Source)]; if (length(s81)) s81[1] else Value[1]
          } else Value[1],
  .groups = "drop")
# flags: newest vs next within Tier-1 (non-mass)
t1 %>% group_by(Species, Variable) %>% filter(n() > 1, !is_mass(first(Variable))) %>%
  summarise(v0=Value[1], s0=Source[1], v1=Value[2], s1=Source[2], .groups="drop") %>%
  filter(abs(v0-v1)/abs(v1) > 0.5) %>%
  transmute(Species, Variable, flag="deviation", detail=paste0(s0,"=",v0," vs ",s1,"=",v1)) -> flags
write_csv(flags, "volumes_flags.csv")

## 6 Tier-2 (each its own team, mean within team) + cross-team average ----
t2 <- long %>% filter(Team != "Stephan_collection") %>%
  group_by(Species, Variable, Team) %>% summarise(Value = mean(Value), .groups="drop")
teamvals <- bind_rows(t1res %>% mutate(Team = "Stephan_collection"), t2)
volumes_long <- teamvals %>% group_by(Species, Variable) %>% summarise(
  Value = if (is_mass(first(Variable)))                       # mass: Stephan reference only (no cross-team avg)
            { sc <- Value[Team=="Stephan_collection"]; if (length(sc)) sc[1] else Value[1] }
          else mean(Value),
  Teams = paste(sort(unique(Team)), collapse="; "), n_teams = n_distinct(Team), .groups="drop") %>%
  arrange(Species, Variable)
write_csv(volumes_long, "volumes_long.csv")

## 7 Phase-4 hemisphere reconciliation -> whole-structure both-hemisphere volumes ----
## See README__merging.md "Hemispheres". For structures measured per hemisphere we add a
## whole-structure both-sides variable (no laterality suffix):
##   both sides measured -> SUM (left + right)         [Bauernfeind insula: Table 1 + Table 2]
##   one side only       -> ESTIMATE as 2x, flagged    [left-only insula species; Stephan vestibular]
## Estimates never overwrite the one-side value; they are added as new both-sides variables and
## recorded in volumes_flags.csv (flag = estimated_bilateral_from_unilateral).
wide_v <- volumes_long %>% select(Species, Variable, Value) %>%
  pivot_wider(names_from = Variable, values_from = Value)
mk <- function(stem) c(left = paste0(stem, "_left_Vol.mm3"),
                       right = paste0(stem, "_right_Vol.mm3"),
                       both = paste0(stem, "_Vol.mm3"))
insula_stems <- c("Granular_insular_cortex","Dysgranular_insular_cortex",
                  "Agranular_insular_cortex","fronto_insular_cortex","Insula")
vestib_unil  <- grep("_unilateral_Vol\\.mm3$", names(wide_v), value = TRUE)
getcol <- function(nm) if (nm %in% names(wide_v)) wide_v[[nm]] else rep(NA_real_, nrow(wide_v))

bilat <- list()
for (st in insula_stems) {                                   # left (+right) -> both
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
src_meta <- volumes_long %>% transmute(Species, src = Variable, Teams, n_teams)
bilat_long <- bilat %>% left_join(src_meta, by = c("Species","src")) %>%
  transmute(Species, Variable, Value, Teams, n_teams)
volumes_long <- bind_rows(volumes_long, bilat_long) %>% arrange(Species, Variable)
write_csv(volumes_long, "volumes_long.csv")

flags <- bind_rows(flags,
  bilat %>% filter(est) %>%
    transmute(Species, Variable, flag = "estimated_bilateral_from_unilateral",
              detail = paste0("both-hemisphere estimated as 2x ", src, " (only one side measured)")))

## Provenance for the OTHER kind of doubling: values whose PUBLISHED figure is already 2x one side.
## Not a veto -- the value is used exactly as published; this only records that the both-sides
## number is an author-side estimate rather than a both-sides measurement, so it is never doubled
## again and so anyone comparing it to a truly bilateral measurement knows what they are holding.
## NOTE this merge is multi-team, so a flagged cell is often a CROSS-TEAM MEAN in which the doubled
## source is one contributor of several (e.g. Corpus_geniculatum_laterale for Homo = de Sousa 2013 +
## Stephan_collection + Bush). The detail says which, so the flag never overclaims that the merged
## number is itself 2x one hemisphere.
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
write_csv(flags, "volumes_flags.csv")

volumes_wide <- volumes_long %>% pivot_wider(id_cols=Species, names_from=Variable, values_from=Value) %>% arrange(Species)
write_csv(volumes_wide, "volumes_wide.csv")
# inventory: which sources contributed each (resolved) species
long %>% group_by(Species_Name = Species) %>% summarise(n_sources=n_distinct(Source), Sources=paste(sort(unique(Source)),collapse="; ")) %>%
  write_csv("volumes_species_sources.csv")

message(nrow(volumes_wide), " species x ", ncol(volumes_wide)-1, " variables from ", nrow(papers),
        " tables | flags: ", nrow(flags))
