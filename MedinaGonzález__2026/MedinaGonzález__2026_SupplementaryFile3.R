# Medina-González 2026 — Supplementary File 3 (Joint Excursion, TAE, Angular Excursion Efficiency)
# -> analysis CSV + public TSV.
# Frozen source (digital-native, no derived snapshot; see __HOWTO_build_a_dataset_file.md §0a
# invariant 1): the untouched Wiley online-article download
# "jez70069-sup-0003-supplementary_file_3.xlsx", obtained from
# https://onlinelibrary.wiley.com/doi/10.1002/jez.70069 (the Zenodo deposit 10.5281/zenodo.15425733
# remains restricted; this is a DIFFERENT, publicly-accessible copy of part of the same
# supplementary material, supplied by the journal itself).
#
# Granularity: PER-RECORD (182 rows / 77 species; many species have >1 individual/source row) —
# kept at that granularity here per §3 ("aggregate to species means in the comparison/merge step,
# not in the reformat"). The trait-table reader (EvoM1_read_gait_excursion_medina.R) aggregates to
# one row per species for ____EvoM1_TraitTable/gait_excursion_medina.xlsx.
#
# AUI (angular utilization index) per the paper's own definition (Abstract): "AUI % = TAE/∑JAE" —
# reported separately per limb as "FL Angular Excursion Efficiency(%)" (forelimb) and
# "HL Angular Excursion Efficiency(%)" (hindlimb); there is no single combined AUI column in the
# source. Both are kept and exposed to the trait table (see README).

invisible(suppressWarnings(Sys.setlocale("LC_CTYPE", "en_US.UTF-8")))  # non-ASCII paths need a UTF-8 CTYPE locale
library(readxl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder    <- list.files(".", pattern = "^MedinaGonz.*lez__2026$")[1]
item_name <- "MedinaGonzález__2026_SupplementaryFile3"
src_file  <- file.path(folder, "jez70069-sup-0003-supplementary_file_3.xlsx")

# ---- species resolver (single source of truth = _keys), same pattern as Wimberly_etal_2021 -------
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) {
  c <- clean_sp(x)
  hit <- match(tolower(c), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a))
  c
}

# ---- read frozen source (digital-native, verbatim; header row 2, descriptive title row 1) --------
raw <- as.data.frame(read_excel(src_file, sheet = "Hoja1", skip = 1, .name_repair = "minimal"),
                     stringsAsFactors = FALSE, check.names = FALSE)
raw <- raw[!is.na(raw$Specie) & nzchar(trimws(raw$Specie)), ]

numify <- function(v) suppressWarnings(as.numeric(v))

df <- data.frame(
  Record_ID                                 = as.integer(raw$ID),
  species_sci                               = vapply(raw$Specie, resolve, character(1)),
  Species                                   = clean_sp(raw$Specie),
  Order                                     = raw$Order,
  Posture                                   = trimws(raw$Posture),
  Body_mass_kg                              = numify(raw$`Body mass (Kg)`),
  Body_mass_g                               = numify(raw$`Body mass (Kg)`) * 1000,   # project unit (g)
  Body_mass_ln                              = numify(raw$`Body mass ln`),
  Body_mass_class                           = trimws(raw$`Body mass`),
  Top_speed_class                           = trimws(raw[[grep("^Top speed", names(raw), value = TRUE)[1]]]),
  Locomotor_habit                           = trimws(raw[[grep("^Locomotor Habit", names(raw), value = TRUE)[1]]]),
  Shoulder_TD_deg                           = numify(raw$`Shoulder TD (°)`),
  Shoulder_MS_deg                           = numify(raw$`Shoulder MS (°)`),
  Shoulder_TO_deg                           = numify(raw$`Shoulder TO (°)`),
  Elbow_TD_deg                              = numify(raw$`Elbow TD (°)`),
  Elbow_MS_deg                              = numify(raw$`Elbow MS (°)`),
  Elbow_TO_deg                              = numify(raw$`Elbow TO (°)`),
  Wrist_TD_deg                              = numify(raw$`Wrist TD (°)`),
  Wrist_MS_deg                              = numify(raw$`Wrist MS (°)`),
  Wrist_TO_deg                              = numify(raw$`Wrist TO (°)`),
  TAE_FL_deg                                = numify(raw$`TAE FL (°)`),
  Sum_RoM_FL_deg                            = numify(raw$`∑ RoM FL (°)`),
  FL_Angular_Excursion_Efficiency_pct       = numify(raw$`FL Angular Excursion Efficiency(%)`),
  Hip_TD_deg                                = numify(raw$`Hip TD (°)`),
  Hip_MS_deg                                = numify(raw$`Hip MS (°)`),
  Hip_TO_deg                                = numify(raw$`Hip TO (°)`),
  Knee_TD_deg                               = numify(raw$`Knee TD (°)`),
  Knee_MS_deg                               = numify(raw$`Knee MS (°)`),
  Knee_TO_deg                               = numify(raw$`Knee TO (°)`),
  Ankle_TD_deg                              = numify(raw$`Ankle TD (°)`),
  Ankle_MS_deg                              = numify(raw$`Ankle MS (°)`),
  Ankle_TO_deg                              = numify(raw$`Ankle TO (°)`),
  TAE_HL_deg                                = numify(raw$`TAE HL (°)`),
  Sum_RoM_HL_deg                            = numify(raw$`∑ RoM HL (°)`),
  HL_Angular_Excursion_Efficiency_pct       = numify(raw$`HL Angular Excursion Efficiency(%)`),
  Shoulder_Angular_Excursion_deg            = numify(raw$`Shoulder Angular Excursion (°)`),
  Elbow_Angular_Excursion_deg               = numify(raw$`Elbow Angular Excursion (°)`),
  Wrist_Angular_Excursion_deg               = numify(raw$`Wrist Angular Excursion (°)`),
  Hip_Angular_Excursion_deg                 = numify(raw$`Hip Angular Excursion (°)`),
  Knee_Angular_Excursion_deg                = numify(raw$`Knee Angular Excursion (°)`),
  Ankle_Angular_Excursion_deg               = numify(raw$`Ankle Angular Excursion (°)`),
  Relation_SumRoM_FL_HL                     = numify(raw$`Relation ∑RoM FL/∑RoM HL`),
  Relation_TAE_FL_HL                        = numify(raw$`Relation TAE FL /TAE HL`),
  Shoulder_Relative_Angular_Excursion_pct   = numify(raw$`Shoulder Relative Angular Excursion (%)`),
  Elbow_Relative_Angular_Excursion_pct      = numify(raw$`Elbow Relative Angular Excursion (%)`),
  Wrist_Relative_Angular_Excursion_pct      = numify(raw$`Wrist Relative Angular Excursion (%)`),
  Hip_Relative_Angular_Excursion_pct        = numify(raw$`Hip Relative Angular Excursion (%)`),
  Knee_Relative_Angular_Excursion_pct       = numify(raw$`Knee Relative Angular Excursion (%)`),
  Ankle_Relative_Angular_Excursion_pct      = numify(raw$`Ankle Relative Angular Excursion (%)`),
  Stride_length_m                           = numify(raw$`Stride lenght (m)`),
  Stride_length_norm                        = numify(raw[[grep("^Stride.*norm$", names(raw), value = TRUE)[1]]]),
  stringsAsFactors = FALSE, check.names = FALSE
)

stopifnot(nrow(df) == 182)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- read_excel("__ReadMe.xlsx", sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (length(item_encoded) == 0 || is.na(item_encoded)) {
  item_encoded <- "10.1002%2Fjez.70069_SupplementaryFile3"  # fallback matching __ReadMe.xlsx row 260
  warning("Item not yet resolved from __ReadMe.xlsx cache; using known encoded name (registry row 260 exists).")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

cat("MedinaGonzález__2026_SupplementaryFile3:", nrow(df), "records /", length(unique(df$Species)), "species written\n")
