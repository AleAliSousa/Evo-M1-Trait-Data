# Baker_etal_2025_SupplementaryData1.R
#
# Baker J, Barton RA, Venditti C (2025). Macroevolutionary brain scaling is a
# microevolutionary metaphenomenon. Nature Communications 17.
# doi:10.1038/s41467-025-66843-0
#
# Item: Supplementary Data 1 -- species-level body mass (bd_g) and whole-brain
# mass (br_g) for 4,679 species across seven animal classes, each row carrying
# the literature source the value was compiled from (sheet "Data S1"), plus a
# "Reference List" sheet giving the full citations for the compilation sources.
#
# Frozen source (digital-native, __HOWTO_build_a_dataset_file.md invariant 1):
# the untouched publisher download 41467_2025_66843_MOESM3_ESM.xlsx in this
# folder. No derived snapshot is made; this script reads the download directly.
#
# Evo-M1 scope is mammals, so the analysis CSV/TSV keep the mammal rows only
# (1,684 species). The frozen source retains all 4,679 rows for audit.
#
# Cleaning done here (and nowhere else):
#   * filter class == "mammals"
#   * species_sci added (printed name with underscores replaced by spaces);
#     the printed name is preserved verbatim in Species_Baker2025
#   * masses kept in grams (project unit for body mass; brain mass also in g,
#     following the Burger_etal_2019 SD1 precedent) and rounded to 4 decimal
#     places to strip binary float noise carried in the publisher file
#     (e.g. 58560.0000000006 -> 58560)
#   * Source whitespace normalised to single spaces
#
# Registry note: the public TSV name below is the expected Item encoded
# (10.1038%2Fs41467-025-66843-0_SupplementaryData1). The registry row in
# __ReadMe.xlsx Sheet1 is PENDING (owner to add; cols E-L are formulas and are
# never edited by hand). Until the row exists, the lookup warns and the script
# falls back to the expected encoded name.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
})

folder    <- tryCatch(dirname(rstudioapi::getActiveDocumentContext()$path),
                      error = function(e) getwd())
base      <- basename(folder)
item_name <- paste0(base, "_SupplementaryData1")
src_file  <- file.path(folder, "41467_2025_66843_MOESM3_ESM.xlsx")

raw <- read_excel(src_file, sheet = "Data S1")

stopifnot(all(c("Species", "class", "subclade", "sub-subclade",
                "bd_g", "br_g", "Source") %in% names(raw)))

mam <- raw[raw$class == "mammals", ]

df <- data.frame(
  species_sci       = gsub("_", " ", mam$Species, fixed = TRUE),
  Species_Baker2025 = mam$Species,                 # printed name, verbatim
  class             = mam$class,
  subclade          = mam$subclade,
  sub_subclade      = mam$`sub-subclade`,
  Body_mass_g       = round(as.numeric(mam$bd_g), 4),
  Brain_mass_g      = round(as.numeric(mam$br_g), 4),
  Source            = gsub("\\s+", " ", mam$Source),
  stringsAsFactors  = FALSE
)
df <- df[order(df$species_sci), ]

# Table checks (section 7a): the published table has no printed totals, so the
# checks are structural -- one row per species, no missing masses.
table_checks <- data.frame(
  check_id   = c("one_row_per_species", "no_missing_masses"),
  basis      = c("Data S1 mammal rows keyed by Species",
                 "bd_g / br_g non-missing on every mammal row"),
  observed   = c(nrow(df), sum(is.na(df$Body_mass_g) | is.na(df$Brain_mass_g))),
  printed    = c(1684, 0),
  difference = c(nrow(df) - 1684,
                 sum(is.na(df$Body_mass_g) | is.na(df$Brain_mass_g))),
  tolerance  = c(0, 0),
  status     = c(if (nrow(df) == 1684 && !anyDuplicated(df$species_sci)) "pass" else "mismatch",
                 if (!any(is.na(df$Body_mass_g) | is.na(df$Brain_mass_g))) "pass" else "mismatch"),
  note       = c("Publisher file verified 2026-11-16: 4,679 rows, 1,684 mammals, no duplicate mammal species",
                 "All 1,684 mammal rows carry both masses in the publisher file"),
  stringsAsFactors = FALSE
)
print(table_checks)

write_csv(df, file.path(folder, paste0(item_name, ".csv")))

# Public TSV (invariant 2): DOI-coded copy in __Public/comparative-data/.
item_encoded <- "10.1038%2Fs41467-025-66843-0_SupplementaryData1"
registry <- file.path(folder, "..", "__ReadMe.xlsx")
if (file.exists(registry)) {
  filecodes <- tryCatch(read_excel(registry, sheet = "Sheet1"),
                        error = function(e) NULL)
  if (!is.null(filecodes) && item_name %in% filecodes[["Item name"]]) {
    item_encoded <- filecodes[["Item encoded"]][match(item_name, filecodes[["Item name"]])]
  } else {
    warning("Item ", item_name, " not yet in __ReadMe.xlsx Sheet1 -- ",
            "using the expected Item encoded; owner to add the registry row.")
  }
}
tsv_dir <- file.path(folder, "..", "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write_tsv(df, file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else {
  write_tsv(df, file.path(folder, paste0(item_encoded, ".tsv")))
  warning("__Public/comparative-data not found next to the repo root -- ",
          "TSV written to the paper folder; copy it over.")
}
