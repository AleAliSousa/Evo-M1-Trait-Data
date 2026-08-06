# Matano__1992_Tables1to4.R
#
# Purpose
#   Build Matano (1992) Tables 1-4 into a lean, analysis-ready CSV: one row per
#   species with body weight and the inferior-olivary-nucleus volumes. The paper
#   splits the same schema across four tables by grade (Table 1 Scandentia +
#   prosimians, Table 2 New World monkeys, Table 3 Old World monkeys, Table 4 apes
#   and man); they are stacked here with a `group` column. This is the inferior
#   olive -- a structure absent from the rest of the Stephan collection (the Baron/
#   Frahm/Stephan series covers vestibular (VIII) and trigeminal (IX) but never the
#   olive), so nothing here duplicates existing data.
#
#   Matano, S. (1992). A Comparative Neuroprimatological Study on the Inferior
#   Olivary Nuclei (from the Stephan Collection). J. Anthropol. Soc. Nippon 100(1),
#   69-82. DOI 10.1537/ase1911.100.69
#
# Input
#   Matano__1992_Tables1to4_snapshot.csv   journal-faithful transcription of the
#     four printed tables (numbers read directly from the scanned tables; the data
#     rows are images with no text layer, so this snapshot is the frozen source).
#
# Outputs
#   Matano__1992_Tables1to4.csv            one row per species (45 rows)
#   (downstream) <DOI>.tsv in __Public/comparative-data/ named by the encoded DOI
#
# Structures (measure = Vol.mm3, both sides as measured):
#   IOPr    = principal inferior olivary nucleus            (col "Inf.Oliv. Principal")
#   IOAcMed = medial accessory inferior olivary nucleus     (col "Inf.Oliv. Acc.Med.")
#   IOAcDors= dorsal accessory inferior olivary nucleus     (col "Inf.Oliv. Acc.Dors.")
#   IOAc    = accessory inferior olivary nuclei (med+dors)  (col "Med.+Dorsal")
# IOPr and IOAc are the two headline nuclei (Figs 1-2 and 3-4); IOAc = IOAcMed +
# IOAcDors (verified on every row). Body weight and the eco-ethological columns
# (activity/diet/locomotor, after Napier & Napier 1967) are secondary/external.
#
# Taxonomy: journal names are kept in `Species`; harmonisation to accepted names is
# applied later via ../_keys/Stephan/species_key.csv (token Matano1992). All 45
# species already resolve there (Matano 1992 is a subset of the Matano 1985a set).

suppressPackageStartupMessages(library(readr))

snap <- read_csv("Matano__1992_Tables1to4_snapshot.csv", show_col_types = FALSE)

grp <- c("Table 1" = NA)  # group carried per-row below; Table 1 mixes Scandentia + prosimians
group_of <- function(tbl, sp) {
  ifelse(tbl == "Table 2", "New World monkey",
  ifelse(tbl == "Table 3", "Old World monkey",
  ifelse(tbl == "Table 4", "Ape/Human",
         ifelse(sp %in% c("Tupaia glis", "Urogale everetti"), "Scandentia", "Prosimian"))))
}

out <- data.frame(
  Species        = snap$Species,
  group          = group_of(snap$Table, snap$Species),
  n              = snap$Specimens_n,
  body_weight_g  = snap$Body_weight_g,
  IOPr_mm3       = snap$InfOliv_Principal_mm3,
  IOAcMed_mm3    = snap$InfOliv_AccMed_mm3,
  IOAcDors_mm3   = snap$InfOliv_AccDors_mm3,
  IOAc_mm3       = snap$Med_plus_Dorsal_mm3,
  activity_time  = snap$Activity_Time,
  diet           = sub("\\.$", "", snap$Diet),
  locomotor_type = snap$Locomotor_Type,
  stringsAsFactors = FALSE
)

# integrity check: printed Med.+Dorsal must equal AccMed + AccDors (to printed precision)
resid <- abs((as.numeric(out$IOAcMed_mm3) + as.numeric(out$IOAcDors_mm3)) - as.numeric(out$IOAc_mm3))
stopifnot(nrow(out) == 45L, max(resid) <= 0.06)

write_csv(out, "Matano__1992_Tables1to4.csv")
cat("Wrote Matano__1992_Tables1to4.csv:", nrow(out), "species; max accessory-sum residual",
    round(max(resid), 3), "\n")

## ---- DOI-coded public TSV (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) -----------
## Added 2026-08-05 together with the registry Item number ("Tables1to4"), which had been
## blank - so the lookup returned nothing and the table was built but never published.
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA_character_
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
} else {
  write.table(out, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
