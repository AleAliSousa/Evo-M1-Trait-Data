# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cellcounts")

## 1 Get data for cell count analyses
## 2 Change to standardized terminology for all variables in those dataframes
## 3 Calculate variables to match them across datasets before filtering
## 4 Rename Species via the shared resolver (_keys/resolve_species.R)
## 5 Filter: Remove flagged data in cellcounts_data_list
## 6 Filter: Annex to Metadata any contingent variables
## 7 Filter: Consider averaging variables if samples differ between teams  ## Check for variables measured by more than one team
## 8 Filter: Melt dataframe and address conflicting datapoints across datasets using priority  ## Within each team ## And across team averaging
## 9.1 Calculate: within-team between-tables values using filtered dataset
## 9.2 Calculate: between-team averages using filtered dataset

## 1 Get data for cell count analyses
library(tidyverse)
library(readxl)

## Create a list with all the dataframes for cell count analyses
item_name <- c(
  "AvelinodeSouza_etal_2025_TABLE1",
  "Burish_etal_2010_Table1",
  "DosSantos_etal_2017_TableS1",
 # "DosSantos_etal_2020_Table1",   # EXCLUDED: published Table 1 (main PDF) has transcription typos in cell
                                  #   counts (some impossible, e.g. Tragelaphus strepsiceros whole-brain cells
                                  #   ~1000x too small). Superseded by the authors' unpublished data (next line).
                                  #   See DosSantos_etal_2020 ReadMes + DosSantos_etal_2020_Table1_check.R.
  "DosSantos_etal_2020_unpublished",   # USED INSTEAD of Table 1: authors' unpublished spreadsheet; internally
                                       #   consistent and matches older pubs (HH 2015). Contributes microglia/cell
                                       #   (I/C, *_I.p.C) ratios; cell NUMBERS for these species come from older sources.
  "HerculanoHouzel_etal_2015_Table1",
  "HerculanoHouzel_etal_2015_Table2",
  "HerculanoHouzel_etal_2015_Table3",
  "HerculanoHouzel_etal_2015_Table4",
  "HerculanoHouzel_etal_2015_Table5",
  "HerculanoHouzel_etal_2020_TABLE1",
  "HerculanoHouzel_etal_2020_TABLE2",
  "JardimMesseder_etal_2017_Table1",
  "Kazu_etal_2015_TABLE1",        # LIVE 2026-08-06. Herculano-Houzel team, so the team rule in
                                  #   sec 8.2.H resolves it - NO manual de-duplication needed.
                                  #   Its 5 artiodactyls are also in HH 2015 Tables 1-5; both are
                                  #   dated 2015, so the date ties and the tie-break on number of
                                  #   species hands the SHARED whole-structure variables to HH
                                  #   (many more species). Kazu then contributes only what HH does
                                  #   not carry: the SUB-STRUCTURES (hippocampus, cortical grey,
                                  #   diencephalon+basal ganglia, mesencephalon, pons+medulla).
                                  #   This is the 2015 CORRIGENDUM, which supersedes the 2014
                                  #   printing (71 of 184 shared cells changed); Kazu_etal_2014_Table1
                                  #   stays out - see below.
  "Kverkova_etal_2018_TableS1",
  "Kverkova_etal_2018_TableS5"

  # ---- SCAFFOLDED, NOT YET LIVE (Herculano-Houzel coverage-gap audit, 2026-07) ----
  # Each is blocked on: its PDF/data + registration in __ReadMe.xlsx + a completed
  # standardized_term_by_reference/ file (stubs already committed). Uncomment one at a
  # time only after its build is real, then re-run standardized_term.R first.
  # See __merging_cellcounts/HH_coverage_gaps_scaffold.md for status and blockers.
  #
  # Kazu_etal_2014_Table1 is intentionally NOT listed and never will be: it is the printing the
  #   2015 corrigendum replaces (71 of the 184 cells present in both changed, and its
  #   N_BR != N_CXT+N_CB+N_RoB by up to -22%). Kazu_etal_2015_TABLE1 is live above instead.
  #   __ReadMe.xlsx carries the same instruction in its Flags active (skips) column.
  # , "Gabi_etal_2016_Table1"                      # NEW REGIONS: prefrontal vs rest-of-cortex counts (needs regional-term decision)
  # , "HerculanoHouzel_etal_2013_Table1-a"         # NEW REGIONS: mouse 18 cortical areas (data built; needs long->wide area reshape — see WIRING_into_cellcounts.md)
  # , "Ribeiro_etal_2013_Table1"                   # NEW REGIONS: human cortical zones (within-human; granularity + include/reference decision pending)
  # Olkowicz_etal_2016_TableS1 is intentionally NOT listed: non-mammal (28 birds), blocked on
  #   the MDD/mammal-only taxonomy resolver (PROJECT_SCOPE_AND_DATASET_ROADMAP.md Part 3, steps 1 & 4).
)

# Initialize an empty list to store data frames with cell counts data
cellcounts_data_list <- list()

# Read Excel file with item name and item encoded TSVs
filecodes <- read_excel("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx", sheet = "Sheet1")

# Loop through item names, read tables from TSVs, and store as dataframes in the list
for (i in seq_along(item_name)) {
  item_encoded <- filecodes$"Item encoded"[match(item_name[i], filecodes$"Item name")]
  # Fail loudly on an unresolved item name. Without this, item_encoded is NA, the
  # path below becomes ".../comparative-data/NA.tsv", and that file really existed
  # in this repo as a stale artefact of an earlier unresolved build -- so a lost
  # registry row would feed the merge the WRONG table instead of stopping it.
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded))
    stop("read of '", item_name[i], "': no 'Item encoded' in __ReadMe.xlsx 'Item name'. ",
         "Add or repair the registry row.", call. = FALSE)
  item_tsv <- paste0("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/",
                     item_encoded, ".tsv")
  if (!file.exists(path.expand(item_tsv)))
    stop("read of '", item_name[i], "': registry resolves to a TSV that is not on disk -> ",
         item_tsv, " (run that source's own build script, or fix 'Item encoded').", call. = FALSE)
  item_data <- read.table(file = item_tsv,
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

  # Store the data frame in the list with the corresponding item name
  cellcounts_data_list[[item_name[i]]] <- item_data
}

## 2 Change to standardized terminology for all variables in those dataframes

# Read standardized terms
standardized_term_cellcounts <- read.csv("standardized_term_cellcounts.csv", check.names=FALSE)

# Loop through each data frame to apply standardized terms
for (i in seq_along(item_name)) {
  df <- cellcounts_data_list[[item_name[i]]]
  indices <- match(colnames(df), standardized_term_cellcounts$Original_Term[standardized_term_cellcounts$Reference == item_name[i]])
  colnames(df) <- (standardized_term_cellcounts$Standardized_Term[standardized_term_cellcounts$Reference == item_name[i]])[indices]
  cellcounts_data_list[[item_name[i]]] <- df
}

## 3 Calculate variables to match them across datasets before filtering

# 3.1 Inspect data: Get an alphabetized list of variables from all datasets in alphabetical order to examine. Q. Can any variables be converted?
# Initialize an empty vector to store all column names
all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- cellcounts_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector # Sort the column names alphabetically and view
  all_variables <- sort(unique(c(all_variables, variables_in_df)))
}

# 3.2 Different "whole brain" definitions were used by different teams. Kverkova Team included olfactory bulb, whereas Herculano-Houzel Team did not (see definitions).
# "WholeBrainOlfactoryBulb" denotes the whole brain including the olfactory bulb
# Formula: "WholeBrain_" = "WholeBrainOlfactoryBulb_" - "OlfactoryBulb_"

# Loop: Calculate "WholeBrain_" from "WholeBrainOlfactoryBulb_" and "OlfactoryBulb_" columns
for (i in seq_along(item_name)) {
  # Extract the dataframe
  df <- cellcounts_data_list[[i]]
  # Check if there are columns starting with "WholeBrainOlfactoryBulb_"
  wholebrainolfactorybulb <- grep("^WholeBrainOlfactoryBulb_", colnames(df), value = TRUE)
  # Loop through matching columns and calculate differences
  for (matching in wholebrainolfactorybulb) {
    # Extract the common suffix
    suffix <- sub("^WholeBrainOlfactoryBulb_", "", matching)
    # Check if corresponding "OlfactoryBulb_" column exists
    olfactorybulb_check <- paste0("OlfactoryBulb_", suffix)
    if (olfactorybulb_check %in% colnames(df)) {
      # Calculate the differences and store in the corresponding "WholeBrain_" columns
      new_col_wholebrain <- paste0("WholeBrain_", suffix)
      df[[new_col_wholebrain]] <- df[[matching]] - df[[olfactorybulb_check]]
    }
  }
  # Update the data frame in the list
  cellcounts_data_list[[i]] <- df
}

# 3.3 Add a column converting mass from kg to g
# Formula: "_Mass.g" = "_Mass.kg" x 1000

# Loop: Calculate "_Mass.g" from "_Mass.kg" columns
for (i in seq_along(item_name)) {
  # Extract the dataframe
  df <- cellcounts_data_list[[i]]
  # Check if there are columns ending with "_Mass.kg"
  Mass.kg <- grep("_Mass.kg$", colnames(df), value = TRUE)
  # Loop through matching columns and calculate differences
  for (matching in Mass.kg) {
    # Extract the prefix, the part of the string that appears before "_Mass.kg"
    prefix <- sub("_Mass.kg$", "", matching)
    # Calculate the Mass in g and store in new and corresponding "_Mass.g" columns
    new_col_Mass.g <- paste0(prefix, "_Mass.g")
    df[[new_col_Mass.g]] <- df[[matching]] * 1000
  }
  # Update the data frame in the list
  cellcounts_data_list[[i]] <- df
}

# 3.4 Derive regional Mass.g for Herculano-Houzel et al. 2020 TABLE 2
#     (CerebralCortex_Mass.g, Cerebellum_Mass.g, RoB_Mass.g). That table does not
#     report these masses, but they can be back-calculated from the neuron count
#     and neuronal density it does report.
#
#     UNITS: _N.p.mg is neurons per MILLIGRAM, so
#         _N.n / _N.p.mg = neurons / (neurons per mg) = mass in mg,
#     which must be divided by 1000 to give grams:
#         _Mass.g = (_N.n / _N.p.mg) / 1000
#
#     NOTE (corrected 2026-06): this step previously MULTIPLIED by 1000, which
#     inflated the derived cortex/cerebellum/RoB masses of the ~13 HH-2020 bats by
#     10^6 (mg x 1000 instead of mg / 1000). Whole-brain masses were reported
#     directly and were never affected.
#
#     Fill _Mass.g only where it is absent but both _N.n and _N.p.mg are present.
df <- cellcounts_data_list$HerculanoHouzel_etal_2020_TABLE2
prefixes <- unique(sub("_.*", "", colnames(df)))
for (prefix in prefixes) {
  mass_column <- paste0(prefix, "_Mass.g")
  if (!(mass_column %in% colnames(df))) {
    nn_column  <- paste0(prefix, "_N.n")
    npm_column <- paste0(prefix, "_N.p.mg")
    if (nn_column %in% colnames(df) && npm_column %in% colnames(df) &&
        !any(is.na(df[[nn_column]])) && !any(is.na(df[[npm_column]]))) {
      df[[mass_column]] <- (df[[nn_column]] / df[[npm_column]]) / 1000  # mg -> g
    }
  }
}
cellcounts_data_list$HerculanoHouzel_etal_2020_TABLE2 <- df

# 3.4b Unit fix for Burish et al. 2010: cell COUNTS were tabulated in MILLIONS
#      (e.g. Macaca mulatta brain "6380" = 6.38e9 neurons; the spinal-cord neuron and
#      other-cell counts likewise). Convert to absolute counts to match every other
#      dataset. Masses (g), densities (per mg) and percentages are already absolute and
#      are left unchanged. (Burish's "Brain" = whole brain, so NBR is mapped to
#      WholeBrain_N.n in its standardized-terms file; here we only rescale the counts.)
df <- cellcounts_data_list$Burish_etal_2010_Table1
for (col in c("WholeBrain_N.n", "SpinalCord_N.n", "SpinalCord_N.n_SD",
              "SpinalCord_O.n", "SpinalCord_O.n_SD")) {
  if (col %in% colnames(df)) df[[col]] <- df[[col]] * 1e6
}
cellcounts_data_list$Burish_etal_2010_Table1 <- df

# 3.4c Laterality-basis fix for Jardim-Messeder et al. 2017 Table 1: Procyon lotor hippocampus mass.
#      The published raccoon hippocampus row is internally inconsistent by exactly a factor of two:
#      printed DNHP (16,076 /mg) is half of NHP / MHP (15.34e6 / 477 mg = 32,159 /mg). The printed
#      O/NHP (4.564) equals OHP / NHP (70.00e6 / 15.34e6), so NHP and OHP are tied to each other,
#      leaving two candidate readings -- a halved mass, or both counts doubled. A density is
#      basis-invariant (N/M is the same for one side as for both), so DNHP cannot be corrupted by a
#      side error, and every test points to MHP as the single printed error -- the mass of ONE
#      hippocampus printed against bilateral counts:
#        - Of the 42 checkable N.p.mg cells in this table, 41 agree with NHP/MHP to within 0.4%.
#          This row is the only 2x cell, so it is not a table-wide convention.
#        - Felis catus has almost the same brain mass (34.86 g vs 34.19 g). Its hippocampus is 2.51%
#          of brain (dog 2.32%); the printed raccoon value is 1.40%, and doubled it is 2.79%.
#        - OHP / MHP as printed is 146,751 /mg, the highest in the table by 1.65x; doubling the mass
#          gives 73,375 /mg, between cat (63,870) and ferret (89,088).
#        - Printed NHP is 0.71% of NBR, in line with ferret 0.79% and cat 0.66%. Halving the counts
#          instead would drop it to 0.36%, so the counts look right.
#        - DIRECT CONFIRMATION, same species and method: Jacob et al. 2021 (DOI 10.1002/cne.25197;
#          Herculano-Houzel a co-author of both) reports raccoon hippocampus mass AND hippocampal
#          nuclei counts by isotropic fractionation for ONE hemisphere: pooled mass 474.01 mg
#          (n=18), total nuclei 42.60e6 (n=18). The printed mass matches Jacob's unilateral mass to
#          0.6%; the printed total cell count is 2x Jacob's unilateral count to 0.3%; and on the
#          doubled mass the total-cell density agrees with Jacob to 0.5% (89,455 vs 89,874 /mg),
#          where on the printed mass it is off by exactly 2x. The neuronal/nonneuronal split does
#          NOT agree (18.0% vs 13.4% neurons) but Jacob's neuron count is a difference of means
#          over non-identical samples (n=18 vs 17), so it is not used as evidence. Check:
#          restricted_checks/_cross_table/JardimMesseder_2017_vs_Jacob_2021_raccoon/
#        - Congener cross-check: Reep et al. 2007 gives Procyon cancrivorus
#          Hippocampus_Vol.mm3 = 1,025.76 at a comparable brain size (36,858 mm3 summed, vs 34,100
#          for P. lotor), and __merging_volumes/laterality_known.csv records Reep values as already
#          bilateral. Across size-comparable congeneric pairs, this table's mass / Reep volume runs
#          0.72-1.14 (Canis 0.904, Panthera leo 0.788, P. leo vs pardus 1.135, Ursus 0.717). The
#          raccoon sits at 0.451; doubled it is 0.902. (The Mustela pair is excluded -- ferret
#          against the much smaller weasel is not size-matched.)
#      So MHP is doubled to the bilateral basis of the counts. DNHP -- and therefore the reported
#      Hippocampus_N.p.mg the merge carries -- is correct and untouched; what this fixes is
#      Hippocampus_Mass.g itself and everything 3.7 derives from it (Hippocampus_O.p.mg was
#      146,751 /mg on the halved mass and becomes 73,375 /mg). _C.n and _p.C.N are unaffected.
#      The frozen source snapshot is deliberately NOT edited: it is the record of what the paper
#      printed, and the printed value is confirmed verbatim from the PDF (Table 1, p. 6).
#      NOT confirmed by the authors -- inferred. Revise if the Jardim-Messeder team supplies the
#      underlying mass. Separately unresolved: this raccoon's CerebralCortex fails the same
#      density check by 3.4%, which this correction does not explain.
jardimmesseder_df <- cellcounts_data_list$JardimMesseder_etal_2017_Table1
if (!is.null(jardimmesseder_df)) {
  raccoon <- !is.na(jardimmesseder_df$Species) & jardimmesseder_df$Species == "Procyon lotor"
  if (!("Hippocampus_Mass.g" %in% colnames(jardimmesseder_df)) || sum(raccoon) != 1L)
    stop("3.4c: expected exactly one 'Procyon lotor' row with a Hippocampus_Mass.g column in ",
         "JardimMesseder_etal_2017_Table1; found ", sum(raccoon), " row(s). The source table or ",
         "its standardized terms changed -- re-check this correction before applying it.",
         call. = FALSE)
  printed_mass <- suppressWarnings(as.numeric(jardimmesseder_df$Hippocampus_Mass.g[raccoon]))
  if (!isTRUE(all.equal(printed_mass, 0.477, tolerance = 1e-6)))
    stop("3.4c: expected the printed Procyon lotor Hippocampus_Mass.g of 0.477 g, found ",
         printed_mass, ". The source table changed -- re-check this correction before applying it.",
         call. = FALSE)
  jardimmesseder_df$Hippocampus_Mass.g[raccoon] <- printed_mass * 2
  cellcounts_data_list$JardimMesseder_etal_2017_Table1 <- jardimmesseder_df
}
rm(jardimmesseder_df)

### DosSantos_etal_2020_Table1 omit ###
# # 3.5 Calculate microglia per cells (I/C) data which was not reported in Dos Santos et al. 2020 Table 1 but must have been their primary data
# # Formula: _I.p.C = _I.n/_C.n
#   
#   # Extract the specific dataframe
#   df <- cellcounts_data_list$DosSantos_etal_2020_Table1
#   # Extract unique prefixes from column names
#   prefixes <- unique(sub("_.*", "", colnames(df)))
#   # Add an initial step to create the _I.p.C column if the condition is satisfied
#   for (prefix in prefixes) {
#     In_column <- paste0(prefix, "_I.n")
#     Cn_column <- paste0(prefix, "_C.n")
#     IpC_column <- paste0(prefix, "_I.p.C")
#     if (In_column %in% colnames(df) && Cn_column %in% colnames(df) && 
#         !any(is.na(df[[In_column]])) && !any(is.na(df[[Cn_column]]))) {
#       df[[IpC_column]] <- df[[In_column]] / df[[Cn_column]]
#     }
#   }
#   # Loop through each unique prefix to handle remaining rows
#   for (prefix in prefixes) {
#     # Define column names
#     In_column <- paste0(prefix, "_I.n")
#     Cn_column <- paste0(prefix, "_C.n")
#     IpC_column <- paste0(prefix, "_I.p.C")
#     # Check if both In_column and Cn_column exist
#     if (In_column %in% colnames(df) && Cn_column %in% colnames(df)) {
#       # Check for NA values in both columns
#       if (!any(is.na(df[[In_column]])) && !any(is.na(df[[Cn_column]]))) {
#         # Skip rows with NA values and already calculated _I.p.C values
#         next
#       }
#       # Calculate _I.p.C based on the given formula
#       df[[IpC_column]] <- df[[In_column]] / df[[Cn_column]]
#     }
#   }
#   # Update the dataframe in the list
#   cellcounts_data_list$DosSantos_etal_2020_Table1 <- df
#   cellcounts_data_list$DosSantos_etal_2020_Table1$WholeBrain_I.p.C
### DosSantos_etal_2020_Table1 omit ### 

# 3.6 Calculate Cell number where not already available (it was only reported in Dos Santos et al., 2020)
# Formula _C.n = _N.n + _O.n
#
#   CORRECTED 2026-09: `prefixes` used to be computed ONCE, outside the loop, from whatever
#   dataframe the variable `df` happened to be left holding by the preceding step (3.4b,
#   Burish et al. 2010). Burish only has WholeBrain / SpinalCord / Body prefixes, so those
#   were the only structures this step ever tried -- every regional _C.n was silently never
#   derived (195 species x structure cells: Cerebellum 50, CerebralCortex 49, RoB 49,
#   OlfactoryBulb 31, Hippocampus 9, and 7 single-species structures -- Amygdala,
#   CerebralCortexGrey, CerebralCortexWhite, DiencephalonStriatum, Medulla, Mesencephalon,
#   Pons). `prefixes` is now rebuilt from each dataframe in turn.
#
#   Also relaxed the NA test. `!any(is.na(df[[col]]))` gated the WHOLE column on a single
#   missing row, so one blank species suppressed _C.n for every species in that table. The
#   fill is now row-wise: derive where both inputs are present, leave NA elsewhere, and
#   never overwrite a value the source itself reports.
  for (i in seq_along(cellcounts_data_list)) {
    # Extract the dataframe
    df <- cellcounts_data_list[[i]]
    # Extract unique prefixes from THIS dataframe's column names
    prefixes <- unique(sub("_.*", "", colnames(df)))
    # Loop through each unique prefix
    for (prefix in prefixes) {
      # Define column names
      Nn_column <- paste0(prefix, "_N.n")
      On_column <- paste0(prefix, "_O.n")
      Cn_column <- paste0(prefix, "_C.n")
      # Both inputs must exist as columns
      if (Nn_column %in% colnames(df) && On_column %in% colnames(df)) {
        Nn <- suppressWarnings(as.numeric(df[[Nn_column]]))
        On <- suppressWarnings(as.numeric(df[[On_column]]))
        derived <- ifelse(!is.na(Nn) & !is.na(On), Nn + On, NA_real_)
        if (!(Cn_column %in% colnames(df))) df[[Cn_column]] <- NA_real_
        reported <- suppressWarnings(as.numeric(df[[Cn_column]]))
        # Fill only where _C.n is absent; a reported _C.n always wins
        df[[Cn_column]] <- ifelse(is.na(reported), derived, reported)
        # Update the dataframe in the list
        cellcounts_data_list[[i]] <- df
      }
    }
  }

# 3.7 Derive the cellular densities and ratios WITHIN each source, from that source's own primaries.
#
#     Why this step exists. The ratio variables are not reported on a common footing across the
#     literature. Isotropic fractionation measures a density in each DISSECTED piece, so the
#     Herculano-Houzel-team tables print densities per structure (cerebral cortex, cerebellum,
#     rest of brain) and print whole-brain TOTALS -- but no whole-brain density, because the whole
#     brain is not a dissected piece. The consequence, before this step, was that
#     WholeBrain_N.p.mg had exactly ONE value in cellcounts_long (Avelino de Souza et al. 2025,
#     the only table that tabulates a whole-brain density row) while WholeBrain_N.n and
#     WholeBrain_Mass.g were present in seven sources. The ratio was not missing from the data;
#     it was simply never computed.
#
#     Formulae (see _keys/glossary.csv for the measure codes):
#       _N.p.mg = _N.n   / (_Mass.g * 1000)   neurons per mg of tissue
#       _O.p.mg = _O.n   / (_Mass.g * 1000)   non-neuronal ("other") cells per mg
#       _I.p.mg = _I.n   / (_Mass.g * 1000)   microglia per mg
#       _O.p.N  = _O.n   / _N.n               non-neuronal cells per neuron
#       _I.p.C  = _I.n   / _C.n               microglia per cell
#       _p.C.N  = 100 * _N.n / _C.n           percent of cells that are neurons
#       _I.n    = _I.p.C * _C.n               microglia NUMBER -- the inverse direction, because
#                                             the microglia source reports the ratio, not the count
#
#     FILL-ONLY. A value the source itself reports is never overwritten, and the fill is row-wise
#     so one blank species never suppresses a column. Rationale: for isotropic-fractionation data
#     the density is the measured quantity and the count is density x mass, so a printed density
#     carries the authors' precision while a back-calculation from a rounded printed count and
#     mass does not. Where a reported and a derivable value coexist they agree to a median
#     |difference| of 0.02-0.24%; the handful that do not (85 species-cells above 2%, worst
#     Procyon lotor Hippocampus_N.p.mg at 100%, i.e. a factor of two) are source-table
#     inconsistencies worth inspecting, not values to silently overwrite.
#
#     Deriving here, inside each source, keeps a species x structure ratio tied to ONE paper's own
#     specimens, and lets it compete in the section 8 within-team priority resolution exactly as a
#     reported value would. Cross-table derivation -- unavoidable for microglia, whose ratio and
#     whose cell counts come from different papers -- happens later, in 9.1, and only for cells
#     that are still empty after filtering.

# Combine two measures of the same structure into a third: (a <op> b) * scale, element-wise.
# op is "/" for every ratio and density, and "*" for the one inverse rule (_I.n = _I.p.C * _C.n).
# A zero or negative denominator yields NA rather than an Inf.
combine_measures <- function(a, b, scale, op) {
  usable <- !is.na(a) & !is.na(b) & (op == "*" | b > 0)
  ifelse(usable, if (op == "*") a * b * scale else a / b * scale, NA_real_)
}

# Fill df[[prefix_target]] from (prefix_a <op> prefix_b) * scale, row-wise, only where the target
# is absent or NA. Returns df unchanged if either input column is missing.
fill_derived <- function(df, prefix, target, a, b, scale = 1, op = "/") {
  target_column <- paste0(prefix, "_", target)
  a_column      <- paste0(prefix, "_", a)
  b_column      <- paste0(prefix, "_", b)
  if (!(a_column %in% colnames(df)) || !(b_column %in% colnames(df))) return(df)
  derived <- combine_measures(suppressWarnings(as.numeric(df[[a_column]])),
                              suppressWarnings(as.numeric(df[[b_column]])), scale, op)
  if (!(target_column %in% colnames(df))) df[[target_column]] <- NA_real_
  reported <- suppressWarnings(as.numeric(df[[target_column]]))
  df[[target_column]] <- ifelse(is.na(reported), derived, reported)
  df
}

# target, a, b, scale, op. Order matters: _C.n is already in place from 3.6, so _I.n can be built
# from _I.p.C * _C.n, and _I.p.mg can then be built from the new _I.n.
cellcounts_derivations <- list(
  c("I.n",    "I.p.C", "C.n",    "1",     "*"),
  c("N.p.mg", "N.n",   "Mass.g", "0.001", "/"),
  c("O.p.mg", "O.n",   "Mass.g", "0.001", "/"),
  c("I.p.mg", "I.n",   "Mass.g", "0.001", "/"),
  c("O.p.N",  "O.n",   "N.n",    "1",     "/"),
  c("I.p.C",  "I.n",   "C.n",    "1",     "/"),
  c("p.C.N",  "N.n",   "C.n",    "100",   "/")
)

for (i in seq_along(cellcounts_data_list)) {
  df <- cellcounts_data_list[[i]]
  prefixes <- unique(sub("_.*", "", colnames(df)))
  for (derivation in cellcounts_derivations) {
    for (prefix in prefixes) {
      df <- fill_derived(df, prefix,
                         target = derivation[1],
                         a      = derivation[2],
                         b      = derivation[3],
                         scale  = as.numeric(derivation[4]),
                         op     = derivation[5])
    }
  }
  cellcounts_data_list[[i]] <- df
}

# Note: the published Dos Santos et al. (2020) Table 1 has transcription typos in its cell counts
#   (e.g. Tragelaphus strepsiceros whole-brain cells). RESOLVED upstream: Table 1 is excluded from
#   item_name (above) and the authors' unpublished data is used instead. Verification:
#   DosSantos_etal_2020/DosSantos_etal_2020_Table1_check.R + DosSantos_etal_2020_comparison_summary.md.
  
## 4 Rename Species using the shared resolver (_keys/resolve_species.R; SPECIES_NAMING.md v1)
## The former live NCBI name2taxid()/taxid2name() lookup and the hand edits below it were migrated
## into the spoke keys (_keys/HerculanoHouzel/species_key.csv etc., basis/note per row) on
## 2026-09-28. cellcounts_source_species_ids.csv is left on disk as the pre-migration record and is
## no longer read or written here; the reviewable mapping now goes to cellcounts_species_resolution.csv.

# 4.1 Resolve every (item, printed name) pair through the spoke keys + hub -- offline, source-aware
source(file.path("..", "_keys/resolve_species.R"))
source_species_ids <- do.call(rbind, lapply(names(cellcounts_data_list), function(item) {
  printed <- sort(unique(cellcounts_data_list[[item]]$Species))
  r <- resolve_species(printed, source_publication = paper_folder_of_item(item, ".."))
  data.frame(Source_Species = item, source_publication = paper_folder_of_item(item, ".."),
             Species_Name_Source = printed, Species_Name = r$accepted_name,
             species_basis = r$species_basis, reidentified = r$reidentified,
             match_level = r$match_level, unresolved = r$unresolved, stringsAsFactors = FALSE)
}))
# Save the data frame as a CSV file (one row per item x printed name)
write.csv(source_species_ids, "cellcounts_species_resolution.csv", row.names = FALSE)
if (any(source_species_ids$unresolved))
  warning("cellcounts species resolution: ", sum(source_species_ids$unresolved),
          " (item, printed name) pair(s) matched no spoke row or hub name -> kept the printed name. ",
          "See cellcounts_species_resolution.csv.")

# 4.3 Duplicate "Species" in all dataframes in cellcounts_data_list and call it "Species_Source", so that "Species" can be edited
# Loop through each data frame in the list. Duplicate the "Species" column and rename it to "Species_Source"
for (i in seq_along(cellcounts_data_list)) {
  cellcounts_data_list[[i]]$Species_Source <- cellcounts_data_list[[i]]$Species
}

# Loop through each data frame in the list and update the "Species" column from the item's own resolution rows
for (i in seq_along(cellcounts_data_list)) {
  m <- source_species_ids[source_species_ids$Source_Species == names(cellcounts_data_list)[i], ]
  cellcounts_data_list[[i]]$Species <- m$Species_Name[match(cellcounts_data_list[[i]]$Species_Source, m$Species_Name_Source)]
}

# 4.4 Save a long unfiltered list for conflict check
cellcounts_unfiltered <- lapply(names(cellcounts_data_list), function(source) {
  df_uf <- cellcounts_data_list[[source]]
  # Convert all columns to character strings
  df_uf[] <- lapply(df_uf, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df_uf %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
cellcounts_unfiltered <- bind_rows(cellcounts_unfiltered)
write.csv(cellcounts_unfiltered, file = "cellcounts_unfiltered.csv", row.names = FALSE)

## 5 Filter: Remove flagged data in cellcounts_data_list

# Create a copy of cellcounts_data_list to filter
filtered_cellcounts_data_list <- lapply(cellcounts_data_list, data.frame)
# ### DosSantos_etal_2020_Table1 omit ###
# # Extract suffixes from DosSantos_etal_2020_Table1 to determine secondary data variables to exclude.
# suffixes <- unique(sub(".*_", "", grep(".*_.*", colnames(cellcounts_data_list$DosSantos_etal_2020_Table1), value = TRUE)))
# # Ignore '_I.p.C' and '_S.n' which estimates the primary data and Species_Source which is not really a variable.
# suffixes <- suffixes[!(suffixes %in% c("I.p.C", "Source", "S.n"))]
# paste0("_",suffixes, collapse = "|") # Manually change the double quotes for single in the script
# ### DosSantos_etal_2020_Table1 omit ###
## 5.1 Flag problematic data for removal

# Initialize metadata_flags for each dataframe with names from filtered_cellcounts_data_list
metadata_flags <- list()
for (df_name in names(filtered_cellcounts_data_list)) {
  metadata_flags[[df_name]] <- data.frame(
    Flag_Description = c(NA),
    Flag_Condition = c(NA),
    Flag_Condition_Type = c(NA)
  )
}
# ### DosSantos_etal_2020_Table1 omit ###
# # Modify metadata_flags DosSantos_etal_2020_Table1 to include multiple rows for flag conditions and descriptions
# metadata_flags$DosSantos_etal_2020_Table1 <- list(
#   Flag_Condition = c(
#     "filtered_cellcounts_data_list[[df_name]]$Species == 'Tragelaphus strepsiceros'",
#     "grepl('_C.n|_I.n|_I.p.mg|_I.p.N|_N.n|_N.p.mg|_n.S|_Mass.g', colnames(filtered_cellcounts_data_list[[df_name]]))"
#   ),
#   Flag_Description = c(
#     "Omit Row Species == Tragelaphus strepsiceros due to impossible numbers",
#     "Omit secondary data columns due to some typos/conflicts with primary sources, and illogical values."
#   ),
#   Flag_Condition_Type = c(
#     "row",
#     "column"
#   )
# )
# ### DosSantos_etal_2020_Table1 omit ###
## Delete flagged data
# Loop through every dataframe in filtered_cellcounts_data_list
for (df_name in names(filtered_cellcounts_data_list)) {
  # Find the corresponding metadata_flags dataframe
  flag_df <- metadata_flags[[df_name]]
  # Loop through each Flag_Condition in the flag_df
  for (i in seq_along(flag_df$Flag_Condition)) {  
    # Extract Flag_Condition, Flag_Description, and Flag_Condition_Type
    condition <- flag_df$Flag_Condition[i]
    description <- flag_df$Flag_Description[i]
    Flag_Condition_Type <- flag_df$Flag_Condition_Type[i]
    # If Flag_Condition is a string, use it as an R script
    if (is.character(condition)) {
      # Assuming your R script is a valid condition
      subset_condition <- eval(parse(text = condition), envir = filtered_cellcounts_data_list[[df_name]])
      # Determine if columns, rows or values should be excluded based on Flag_Condition_Type
      if (length(subset_condition) > 0) {
        if (Flag_Condition_Type == "column") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching columns
              filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][, !subset_condition]
            } else {}
          } else {}
        } else if (Flag_Condition_Type == "row") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching rows
              filtered_cellcounts_data_list[[df_name]] <- filtered_cellcounts_data_list[[df_name]][!subset_condition, ]
            } else {}
          } else {}
        } else if (Flag_Condition_Type == "value") {
          if (any(subset_condition)) {
            # Make matching values NA to exclude them
            indices <- filtered_cellcounts_data_list[[df_name]] == subset_condition
            filtered_cellcounts_data_list[[df_name]][indices] <- NA
          } else {}
        } else {}
      } else {}
    }
  }
}

## 6 Filter: Annex to Metadata any contingent variables

# Initialize an empty vector to store all column names, filtered
filtered_all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- filtered_cellcounts_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector
  filtered_all_variables <- unique(c(filtered_all_variables, variables_in_df))
}
# Sort the column names alphabetically and view
filtered_all_variables <- sort(filtered_all_variables)
filtered_all_variables

# Move specific variables from the main dataset, filtered_cellcounts_data_list, to the list annexed_metadata.
# Redundant variables created here: "Body_Mass.kg"
# Extra taxonomic variables: "Species_Source", "Family", "Order", "Clade", "CommonName", "Micro.or.mega"    
# Data Sources variables: variables ending in "_Source"
# Sample information: "SampleInfo"
# Statistics around means: "_SD", _n", "_S.n"
# Structure fractions still annexed: variables ending in "_p.C.Brain"
#
# The cellular ratios are NO LONGER annexed. "_N.p.mg", "_O.p.mg", "_O.p.N" (previously commented
# out below) and "_p.C.N" (uncommented 2026-09) are cellular-composition measures in their own
# right, they are now derived on a common basis in 3.7 and 9.1, and they are what the trait table
# needs. Annexing them was what left WholeBrain_N.p.mg with a single value.
#
# "_p.C.Brain" (Kverkova et al. 2018 Table S1) stays annexed, deliberately: it is a STRUCTURE
# fraction, not a cellular ratio, and _keys/glossary.csv defines it as a volume fraction while the
# masses and counts carried here would give a mass or neuron fraction. Restoring it needs its basis
# pinned to the source table first, otherwise it would merge three different quantities under one
# column. Note that Burish's "_p.C.CNS.mass", "_p.C.CNS.neurons" and "_p.C.Body.mass" were never
# caught by the "_p.C.N" pattern and have always passed through.

# Initialize annexed_metadata as a named list
annexed_metadata <- setNames(vector("list", length(filtered_cellcounts_data_list)), names(filtered_cellcounts_data_list))
# Initialize variables_to_move as an empty vector
variables_to_move <- character(0)
# Iterate through the dataframes
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Update variables_to_move including variables ending in "_Source" for each dataframe
  variables_to_move <- c("Body_Mass.kg", "Family", "Order", "Clade", "CommonName", "Micro.or.mega", "SampleInfo",
                         grep("_Source$", names(filtered_cellcounts_data_list[[i]]), value = TRUE), 
                         grep("_S.n$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_SD$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         grep("_n$", names(filtered_cellcounts_data_list[[i]]), value = TRUE),
                         # Cellular ratios kept in the merge (see the note above), NOT annexed:
                         #   "_N.p.mg", "_O.p.mg", "_I.p.mg", "_O.p.N", "_I.p.C", "_p.C.N"
                         grep("_p.C.Brain", names(filtered_cellcounts_data_list[[i]]), value = TRUE))

  # Check if any of the variables to move are present in the dataframe
  present_variables <- intersect(variables_to_move, names(filtered_cellcounts_data_list[[i]]))
  if (length(present_variables) > 0) {
    # Create a new dataframe with only the specified variables
    annexed_data <- filtered_cellcounts_data_list[[i]][, present_variables, drop = FALSE]
    # Remove the specified variables from the original dataframe
    filtered_cellcounts_data_list[[i]] <- filtered_cellcounts_data_list[[i]][, !(names(filtered_cellcounts_data_list[[i]]) %in% present_variables), drop = FALSE]
    # Add the new dataframe to annexed_metadata list
    annexed_metadata[[names(filtered_cellcounts_data_list)[i]]] <- annexed_data
  } else {
    # Skip if none of the variables are present in the dataframe
  }
}

## 7 Filter: Consider averaging variables if samples differ between teams ## Check for variables measured by more than one team

## Check for variables found in dataframes both from Kverkova team and Herculano-Houzel team, which are different teams

# Create a full dataframe to inspect Kverkova Team variables
Kverkova_etal_2018_variables <- data.frame(Dataframe_Name = character(), Variable_Name = character(), stringsAsFactors = FALSE)
# Loop through each dataframe in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  df_name <- names(filtered_cellcounts_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cellcounts_data_list[[i]]  # Get the dataframe itself
  # Check if the dataframe name starts with "Kverkova_etal_2018"
  if (startsWith(df_name, "Kverkova_etal_2018")) {
    # Extract variables in "Kverkova_etal_2018", which are all the column names except the first one
    selected_vars <- colnames(df)[-1]
    # Create a data frame with the results for the current dataframe
    df_result <- data.frame(Dataframe_Name = rep(df_name, length(selected_vars)),
                            Team_Name = rep("Kverkova_etal_2018", length(selected_vars)),
                            Variable_Name = selected_vars,
                            stringsAsFactors = FALSE)
    # Append the results to the overall Kverkova_etal_2018_variables
    Kverkova_etal_2018_variables <- rbind(Kverkova_etal_2018_variables, df_result)
  }
}
Kverkova_etal_2018_variables
# Create a list of Kverkova Team dataframes 
Kverkova_Team_dataframes <- unique(Kverkova_etal_2018_variables$Dataframe_Name)
# Create a reduced Kverkova Team variables list for comparison
Kverkova_Team_variables <- unique(Kverkova_etal_2018_variables[, !names(Kverkova_etal_2018_variables) %in% "Dataframe_Name"])
Kverkova_Team_variables

# Create a full dataframe to inspect the other team's variables
Other_Team_variables <- data.frame(Dataframe_Name = character(), Team_Name = character(), Variable_Name = character(), stringsAsFactors = FALSE)
# Loop through each dataframe in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  df_name <- names(filtered_cellcounts_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cellcounts_data_list[[i]]  # Get the dataframe itself
  # Check if the dataframe name does not start with "Kverkova_etal_2018"
  if (!startsWith(df_name, "Kverkova_etal_2018")) {
    # Extract variables, excluding the first column
    selected_vars <- colnames(df)[-1]
    # Create a data frame with the results for the current dataframe
    df_result <- data.frame(Dataframe_Name = rep(df_name, length(selected_vars)),
                            Team_Name = rep("NOT_Kverkova_etal_2018", length(selected_vars)),
                            Variable_Name = selected_vars,
                            stringsAsFactors = FALSE)
    # Append the results to the overall Other_Team_variables
    Other_Team_variables <- rbind(Other_Team_variables, df_result)
  }
}
Other_Team_variables
# Create a list of HerculanoHouzel Team dataframes 
HerculanoHouzel_Team_dataframes <- unique(Other_Team_variables$Dataframe_Name)
# Create a reduced HerculanoHouzel Team variables list for comparison
HerculanoHouzel_Team_variables <- unique(Other_Team_variables[, !names(Other_Team_variables) %in% "Dataframe_Name"])
HerculanoHouzel_Team_variables

# Merge and compare
Variables_shared_across_teams <- merge(Kverkova_Team_variables, HerculanoHouzel_Team_variables, "Variable_Name")
Variables_in_both_teams <- Variables_shared_across_teams$Variable_Name

## 8 Filter: Melt dataframe and address conflicting datapoints across datasets using priority ## Within each team ## And across team averaging

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(Kverkova_Team_dataframes)) {
  # Use match to find the dataframe in filtered_cellcounts_data_list with the same name as  i in seq_along(Kverkova_Team_dataframes
  Kverkova_Team_dfmatch <- filtered_cellcounts_data_list[[i]][, names(filtered_cellcounts_data_list[[i]]) %in% Kverkova_Team_dataframes]
  # Store the data frame in the list with the corresponding name
  Kverkova_Team_df_list[[Kverkova_Team_dataframes[i]]] <- Kverkova_Team_dfmatch
}

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Check if the name of the dataframe is in Kverkova_Team_dataframes
  if (names(filtered_cellcounts_data_list)[i] %in% Kverkova_Team_dataframes) {
    # Assign the entire dataframe to Kverkova_Team_dfmatch
    Kverkova_Team_dfmatch <- filtered_cellcounts_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    Kverkova_Team_df_list[[names(filtered_cellcounts_data_list)[i]]] <- Kverkova_Team_dfmatch
  }
}

# Create a new list of dataframes from the list of dataframes filtered_cellcounts_data_list with only HerculanoHouzel_Team dataframes
# Initialize an empty list to store matching dataframes
HerculanoHouzel_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cellcounts_data_list)) {
  # Check if the name of the dataframe is in HerculanoHouzel_Team_dataframes
  if (names(filtered_cellcounts_data_list)[i] %in% HerculanoHouzel_Team_dataframes) {
    # Assign the entire dataframe to HerculanoHouzel_Team_dfmatch
    HerculanoHouzel_Team_dfmatch <- filtered_cellcounts_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    HerculanoHouzel_Team_df_list[[names(filtered_cellcounts_data_list)[i]]] <- HerculanoHouzel_Team_dfmatch
  }
}

###### 8.1 - 8.3 KVERKOVA TEAM
## 8.1.K Combine all data in all dataframes in Kverkova_Team_df_list as a long dataframe
combined_data <- lapply(names(Kverkova_Team_df_list), function(source) {
  df <- Kverkova_Team_df_list[[source]]
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
# Combine all dataframes in the list into a single dataframe
combined_data <- bind_rows(combined_data)

## 8.2.K Address conflicting datapoints across datasets using priority
# Determine worth order for dataframes to give priority
worth_dataframe <- data.frame(source = character(),
                              date = numeric(),
                              number_species = numeric(),
                              stringsAsFactors = FALSE)
# Iterate over the dataframes in Kverkova_Team_df_list
for (df_name in names(Kverkova_Team_df_list)) {
  # Extract date from the dataframe name
  date <- as.numeric(str_extract(df_name, "[0-9]+"))
  # Extract number of species from the dataframe
  number_species <- nrow(Kverkova_Team_df_list[[df_name]]) - 1  # Subtract 1 for the header
  # Append the information to the summary dataframe
  worth_dataframe <- rbind(worth_dataframe, data.frame(source = df_name,
                                                       date = date,
                                                       number_species = number_species))
}
# Sort (highest to lowest) by date first , then by number_species
worth_dataframe <- worth_dataframe[order(-worth_dataframe$date, -worth_dataframe$number_species), ]
# Reset row names
rownames(worth_dataframe) <- NULL
# Add a new column called "priority" with row numbers as values
worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

## 8.3.K Limit dataset to best available data
# remove any NA values in combined_data
intermediate_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
# Add a blank column "DECISION"
intermediate_data$DECISION <- ""
# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))
# Create a loop to update "DECISION" based on the priority condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  # Check if there are non-missing values in priority_values
  if (any(!is.na(priority_values))) {
    # Update "DECISION" based on the specified condition
    df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values, na.rm = TRUE)] <- "WORSE"
  } else {
    # Handle the case where all values are missing
    df_list[[i]]$DECISION <- NA
  }
}

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
Kverkova_Team_data_long <- do.call(rbind, df_list)
Kverkova_Team_data_long <- Kverkova_Team_data_long[Kverkova_Team_data_long$DECISION != "WORSE", ]
# Delete the 'priority' and 'DECISION' columns if they will not be used again # These are not available for mixed sources 
Kverkova_Team_data_long <- Kverkova_Team_data_long[, !(names(Kverkova_Team_data_long) %in% c("priority", "DECISION"))]

###### 8.1 - 8.3 HH TEAM  
# 8.1.H Combine all data in all dataframes in HerculanoHouzel_Team_df_list as a long dataframe
combined_data <- lapply(names(HerculanoHouzel_Team_df_list), function(source) {
  df <- HerculanoHouzel_Team_df_list[[source]]
  # Convert all columns to character strings
  df[] <- lapply(df, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
# Combine all dataframes in the list into a single dataframe
combined_data <- bind_rows(combined_data)

## 8.2.H Address conflicting datapoints across datasets using priority
# Determine worth order for dataframes to give priority
# Initialize an empty dataframe to store the summary
worth_dataframe <- data.frame(source = character(),
                              date = numeric(),
                              number_species = numeric(),
                              stringsAsFactors = FALSE)

# Iterate over the dataframes in HerculanoHouzel_Team_df_list
for (df_name in names(HerculanoHouzel_Team_df_list)) {
  # Extract date from the dataframe name
  date <- as.numeric(str_extract(df_name, "[0-9]+"))
  # Extract number of species from the dataframe
  number_species <- nrow(HerculanoHouzel_Team_df_list[[df_name]]) - 1  # Subtract 1 for the header
  # Append the information to the summary dataframe
  worth_dataframe <- rbind(worth_dataframe, data.frame(source = df_name,
                                                       date = date,
                                                       number_species = number_species))
}
# Sort (highest to lowest) by date first , then by number_species
worth_dataframe <- worth_dataframe[order(-worth_dataframe$date, -worth_dataframe$number_species), ]
# Reset row names
rownames(worth_dataframe) <- NULL
# Add a new column called "priority" with row numbers as values
worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

## 8.3.H Limit dataset to best available data
# remove any NA values in combined_data
intermediate_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
# Add a blank column "DECISION"
intermediate_data$DECISION <- ""
# Convert dataframe to a list of dataframes
df_list <- split(intermediate_data, list(intermediate_data$Species, intermediate_data$Variable))
# Create a loop to update "DECISION" based on the priority condition
for (i in seq_along(df_list)) {
  priority_values <- df_list[[i]]$priority
  # Check if there are non-missing values in priority_values
  if (any(!is.na(priority_values))) {
    # Update "DECISION" based on the specified condition
    df_list[[i]]$DECISION[df_list[[i]]$priority > min(priority_values, na.rm = TRUE)] <- "WORSE"
  } else {
    # Handle the case where all values are missing
    df_list[[i]]$DECISION <- NA
  }
}

# Combine all rows from df_list into one dataframe excluding rows with DECISION:WORSE
HerculanoHouzel_Team_data_long <- do.call(rbind, df_list)
HerculanoHouzel_Team_data_long <- HerculanoHouzel_Team_data_long[HerculanoHouzel_Team_data_long$DECISION != "WORSE", ]
# Delete the 'priority' and 'DECISION' columns if they will not be used again # These are not available for mixed sources 
HerculanoHouzel_Team_data_long <- HerculanoHouzel_Team_data_long[, !(names(HerculanoHouzel_Team_data_long) %in% c("priority", "DECISION"))]

#### 9.1 Calculate: within-team between-tables values using the filtered dataset
#
#     Fill any cellular ratio still empty after the 8.3 priority resolution, using primaries that
#     survived filtering for the SAME species and SAME structure within the SAME team -- even when
#     the two inputs came from different tables. 3.7 has already covered everything derivable
#     inside a single source, so this step only reaches cells that no one paper can supply on its
#     own. The Source string becomes the two contributing sources joined, so a cross-table value is
#     never mistaken for a single-source measurement.
#
#     This is the step that yields microglia numbers and densities. Dos Santos et al. 2020
#     (unpublished) reports only the microglia/cell RATIO (_I.p.C); the cell counts (_C.n) and
#     masses (_Mass.g) for those same species come from other Herculano-Houzel-team tables, so
#     _I.n = _I.p.C * _C.n and _I.p.mg = _I.n / (_Mass.g * 1000) are only reachable here. This is
#     also why "_I.p.mg" had no values at all: no live source reports it, and the excluded
#     Dos Santos published Table 1 was the only table that ever printed one.
#
#     FILL-ONLY, on the same terms as 3.7: nothing already present is replaced, and a denominator
#     of zero or a missing input yields no row rather than an Inf or a NaN.

# Fill missing Species x Structure ratios in a team's long dataframe from its own primaries.
# df_long has columns Species, Variable, Source, Value (Value character, as built in 8.1).
# derivations: list of c(target, a, b, scale, op), applied in order, so a value derived by an
# earlier rule is available to a later one.
derive_within_team <- function(df_long, derivations) {
  if (!nrow(df_long)) return(df_long)
  measured <- df_long[grepl("_", df_long$Variable, fixed = TRUE), , drop = FALSE]
  measured$Structure <- sub("_[^_]*$", "", measured$Variable)
  measured$Measure   <- sub("^.*_",    "", measured$Variable)
  measured$Numeric   <- suppressWarnings(as.numeric(measured$Value))
  measured <- measured[!is.na(measured$Numeric), , drop = FALSE]
  if (!nrow(measured)) return(df_long)

  # Species \r Structure \r Measure -> value, and -> the source it came from
  key         <- paste(measured$Species, measured$Structure, measured$Measure, sep = "\r")
  value_of    <- setNames(measured$Numeric, key)
  source_of   <- setNames(measured$Source,  key)
  combination <- unique(paste(measured$Species, measured$Structure, sep = "\r"))
  added       <- df_long[0, , drop = FALSE]

  for (derivation in derivations) {
    target <- derivation[1]; a <- derivation[2]; b <- derivation[3]
    scale  <- as.numeric(derivation[4]); op <- derivation[5]
    target_key <- paste(combination, target, sep = "\r")
    a_key      <- paste(combination, a,      sep = "\r")
    b_key      <- paste(combination, b,      sep = "\r")
    derived  <- combine_measures(value_of[a_key], value_of[b_key], scale, op)
    fillable <- is.na(value_of[target_key]) & !is.na(derived)
    fillable[is.na(fillable)] <- FALSE
    if (!any(fillable)) next
    split_keys <- strsplit(combination[fillable], "\r", fixed = TRUE)
    new_rows <- data.frame(
      Species  = vapply(split_keys, `[`, character(1), 1L),
      Variable = paste0(vapply(split_keys, `[`, character(1), 2L), "_", target),
      Source   = mapply(function(x, y) paste(unique(c(x, y)), collapse = "_"),
                        source_of[a_key[fillable]],
                        source_of[b_key[fillable]], USE.NAMES = FALSE),
      Value    = as.character(derived[fillable]),
      stringsAsFactors = FALSE)
    # make the new values visible to the remaining derivations in this same pass
    refresh_key <- paste(new_rows$Species, sub("_[^_]*$", "", new_rows$Variable), target, sep = "\r")
    value_of[refresh_key]  <- as.numeric(new_rows$Value)
    source_of[refresh_key] <- new_rows$Source
    added <- rbind(added, new_rows[, names(df_long), drop = FALSE])
  }
  rbind(df_long, added)
}

HerculanoHouzel_Team_data_long <- derive_within_team(HerculanoHouzel_Team_data_long,
                                                     cellcounts_derivations)
Kverkova_Team_data_long        <- derive_within_team(Kverkova_Team_data_long,
                                                     cellcounts_derivations)

#### 9.2 Calculate: between-team averages using filtered dataset
## Finalize dataset
# Stack the dataframes lengthwise
stacked_long_dataframe <- rbind(HerculanoHouzel_Team_data_long, Kverkova_Team_data_long)
# remove any NA values in stacked_long_dataframe
stacked_long_dataframe <- stacked_long_dataframe[!is.na(stacked_long_dataframe$Value), , drop = FALSE]
# make Values numeric in stacked_long_dataframe
stacked_long_dataframe$Value <- as.numeric(stacked_long_dataframe$Value)

# Calculate averages and create the new long dataframe
cellcounts_long <- stacked_long_dataframe %>%
  group_by(Species, Variable) %>%
  summarize(Value = mean(Value),
            Source = paste0(unique(Source), collapse = "_"))
## Species naming columns (SPECIES_NAMING.md v1): cellcounts_long is one row per species x variable
## with sources collapsed, so species_printed / species_basis list every distinct printed name / basis
## that resolved to this Species across the items (from source_species_ids, step 4.1);
## accepted_name == Species; reidentified = any of those rows was a reident.
sp_cols <- species_columns_summary(
  transform(source_species_ids, species_printed = Species_Name_Source, accepted_name = Species_Name,
            Species = Species_Name), "Species")
cellcounts_long <- cellcounts_long %>%
  left_join(sp_cols %>% select(Species, species_printed, species_basis, reidentified), by = "Species") %>%
  mutate(accepted_name = Species) %>%
  relocate(species_printed, accepted_name, species_basis, reidentified, .after = Source)
write_csv(cellcounts_long, "cellcounts_long.csv")

# Convert to wide dataframe
cellcounts_wide <- arrange(pivot_wider(cellcounts_long, id_cols = Species, names_from = Variable, values_from = Value), Species)
# # keep a record of sources for the datapoints
# cellcounts_sources_wide <- arrange(pivot_wider(cellcounts_long, id_cols = Species, names_from = Variable, values_from = Source), Species)
write_csv(cellcounts_wide, "cellcounts_wide.csv")
