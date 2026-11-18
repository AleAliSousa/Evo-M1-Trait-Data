# GonzalezVoyer_etal_2016_BrainData.R
#
# Gonzalez-Voyer A, Gonzalez-Suarez M, Vila C, Revilla E (2016). Larger
# brain size indirectly increases vulnerability to extinction in mammals.
# Evolution 70: 1364-1375. doi:10.1111/evo.12943
# Data package: Dryad doi:10.5061/dryad.m2tj3
#
# Item: the Dryad data file -- species-level brain mass, body mass and
# life-history / ecology traits for 596 mammal species, each row naming
# the literature sources its values were compiled from.
#
# Frozen source (digital-native): the Dryad download
# Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv in this folder, kept
# verbatim, together with the package's README PDF. Downloaded from
# datadryad.org on 2026-11-18.
#
# Why this item is in Evo-M1: it is the openly released, expanded
# descendant of the 493-species brain/body database of Gonzalez-Lagos,
# Sol & Reader (2010) -- the dataset behind the encephalization index Ei
# used by Castillo-Morales et al. (2016). The 2010 file itself was never
# deposited in any repository (checked 2026-11-18: no Dryad/figshare/
# DataCite record; the journal page carries no supporting-information
# file). Data role: SECONDARY compilation.
#
# Cleaning done here (and nowhere else):
#   * species_sci added (printed name with underscores replaced by
#     spaces); the printed name is preserved verbatim in Species_name
#   * no value changes: masses kept in grams at full printed precision
#     (the long decimals are the authors' cross-source means)
#
# Outputs:
#   GonzalezVoyer_etal_2016_BrainData.csv          (this folder)
#   public_tsv/10.1111%2Fevo.12943_BrainData.tsv   (for __Public/comparative-data/)
#
# Registry note: the public TSV name is the expected Item encoded
# (10.1111%2Fevo.12943_BrainData). The registry row in __ReadMe.xlsx is
# an owner step.

d <- read.csv("Gonzalez-Voyer_et_al_Evolution_Brain_Data.csv",
              stringsAsFactors = FALSE, check.names = FALSE)
d$species_sci <- gsub("_", " ", d$Species_name)
d <- d[, c("species_sci", setdiff(names(d), "species_sci"))]
stopifnot(nrow(d) == 596, !anyDuplicated(d$species_sci),
          all(!is.na(d$Brain_mass_g)), all(!is.na(d$Adult_body_mass_g)))

write.csv(d, "GonzalezVoyer_etal_2016_BrainData.csv", row.names = FALSE)
write.table(d, "public_tsv/10.1111%2Fevo.12943_BrainData.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
