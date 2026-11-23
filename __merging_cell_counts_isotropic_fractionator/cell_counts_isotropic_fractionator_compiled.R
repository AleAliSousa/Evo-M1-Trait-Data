# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cell_counts_isotropic_fractionator")

## 1 Get data for cell count analyses
## 2 Change to standardized terminology for all variables in those dataframes
## 3 Calculate variables to match them across datasets before filtering
## 4 Rename Species via the shared resolver (_keys/resolve_species.R)
## 5 Filter: Remove flagged data in cell_counts_isotropic_fractionator_data_list
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
  "DosSantos_etal_2020_Table1",   # LIVE again 2026-11 (curator decision: the PUBLISHED table is the source).
                                  #   Herculano-Houzel team, microglia. What it contributes:
                                  #   - its own microglia measures: _I.p.mg and _I.p.N (measured), _I.n (printed,
                                  #     = I/N x N) and, derived in sec 3.7, _I.p.C = _I.n / _C.n;
                                  #   - _Mass.g, _C.n, _N.n, _N.p.mg ONLY as a fallback: Table 1's footnote says
                                  #     these are values published previously, so the primary tables outrank
                                  #     it for them (compilation rule, sec 8.2.H "Dos Santos 2020 demotion").
                                  #   Ten printed cells are wrong and are corrected in sec 3.4e, each guarded and
                                  #   tied to DosSantos_etal_2020/reference_tables/DosSantos_etal_2020_errata.csv.
                                  #   The authors' unpublished table (DosSantos_etal_2020_unpublished), used here
                                  #   until 2026-11 instead of Table 1, is no longer an item and is not in this repo.
  "HerculanoHouzel_etal_2015_Table1",
  "HerculanoHouzel_etal_2015_Table2",
  "HerculanoHouzel_etal_2015_Table3",
  "HerculanoHouzel_etal_2015_Table4",
  "HerculanoHouzel_etal_2015_Table5",
  "HerculanoHouzel_etal_2014_Table1",   # PRIMARY source for the elephant rows HH 2015 re-reported:
                                       #   pinned above the 2015 tables in sec 8.2.H (compilation
                                       #   rule). Corrects the 2015 Table 1 cortex O misprint.
                                       #   Its TSV is long-format; sec 1.5 reshapes it. Two
                                       #   thousands-separator capture artefacts are fixed
                                       #   in sec 3.4h.
  "Sarko_etal_2009_Table1",             # PRIMARY source for the five eulipotyphlan species HH 2015
                                       #   re-reported (whole brain incl. olfactory bulb): pinned
                                       #   above the 2015 tables in sec 8.2.H. Long-format TSV;
                                       #   sec 1.5 reshapes it.
  "Sarko_etal_2009_Table2",             # PRIMARY per-structure companion to Sarko Table 1: pinned
                                       #   above the 2015 tables in sec 8.2.H; carries one guarded
                                       #   misprint fix in sec 3.4f (Blarina cortex neurons).
                                       #   Long-format TSV; sec 1.5 reshapes it.
  "HerculanoHouzel_etal_2011_Table1",   # PRIMARY source for the Glires rows HH 2015 re-reported:
                                       #   pinned above the 2015 tables in sec 8.2.H (compilation
                                       #   rule) and carries one guarded misprint fix in sec 3.4d.
  "HerculanoHouzel_etal_2006_Table1",   # PRIMARY source (rodents, whole brain only) for the rows
                                       #   HH 2015 cites to it in 30 cells: pinned above BOTH the
                                       #   2015 tables and the 2011 table in sec 8.2.H, so its
                                       #   printed DIRECT whole-brain totals take the WholeBrain
                                       #   rows for the six rodent species (decision D1); the
                                       #   2011 structure sums keep every other variable.
  "Azevedo_etal_2009_Table1",           # PRIMARY source for the Homo sapiens rows HH 2015
                                       #   re-reported: pinned above the 2015 tables in sec 8.2.H.
                                       #   Observed columns only (the table's Expected columns
                                       #   stay in the snapshot). Prints no SDs, so HH 2015's
                                       #   human SDs stay with the 2015 items; one of them is
                                       #   corrected in sec 3.4l.
  "Gabi_etal_2010_Table1",              # PRIMARY source for five primate species HH 2015
                                       #   re-reported: pinned above the 2015 tables in
                                       #   sec 8.2.H. Two printed cells are corrected in
                                       #   sec 3.4i / 3.4j (decision D2). Prints no SDs.
  "Neves_etal_2014_Table1",             # PRIMARY source for the five afrotherian species HH 2015
                                       #   re-reported: pinned above the 2015 tables in
                                       #   sec 8.2.H (decision D3). Terminology (see the item's
                                       #   standardized-term file): its "Cerebral cortex total"
                                       #   (CxT, cortex INCLUDING hippocampus) maps to
                                       #   CerebralCortex_; its "Cerebral cortex" (CX, EXCLUDING
                                       #   hippocampus) maps to CerebralCortexNoHippocampus_;
                                       #   its hippocampus maps to Hippocampus_. One guarded
                                       #   fix in sec 3.4k.
  "Ribeiro_etal_2014_Table1",           # PRIMARY source for the olfactory-bulb rows HH 2015
                                       #   Table 4 cites to it (five primates), plus the rat,
                                       #   squirrel and Tupaia rows Table 4 carries at this
                                       #   paper's values under other citations: pinned above
                                       #   the 2015 tables AND the 2011 table in sec 8.2.H
                                       #   (decision D5). Sec 1.6 keeps only this paper's 8
                                       #   own-measurement species; its 15 compiled rows stay
                                       #   with their source items (compilation rule).
  "HerculanoHouzel_Kaas_2011_Table2",   # PRIMARY source for the Gorilla and Pongo cerebellar
                                       #   totals HH 2015's ape rows rest on: pinned above the
                                       #   2015 tables in sec 8.2.H (decision D6). Sec 1.6 keeps
                                       #   only the two own-measurement species; the neuron /
                                       #   non-neuron splits HH 2015 took from this paper's
                                       #   TEXT stay with the 2015 items, unsourced to here.
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
  # See __merging_cell_counts_isotropic_fractionator/HH_coverage_gaps_scaffold.md for status and blockers.
  #
  # Kazu_etal_2014_Table1 is intentionally NOT listed and never will be: it is the printing the
  #   2015 corrigendum replaces (71 of the 184 cells present in both changed, and its
  #   N_BR != N_CXT+N_CB+N_RoB by up to -22%). Kazu_etal_2015_TABLE1 is live above instead.
  #   __ReadMe.xlsx carries the same instruction in its Flags active (skips) column.
  # , "Gabi_etal_2016_Table1"                      # NEW REGIONS: prefrontal vs rest-of-cortex counts (needs regional-term decision)
  # , "HerculanoHouzel_etal_2013_Table1-a"         # NEW REGIONS: mouse 18 cortical areas (data built; needs long->wide area reshape — see WIRING_into_cell_counts_isotropic_fractionator.md)
  # , "Ribeiro_etal_2013_Table1"                   # NEW REGIONS: human cortical zones (within-human; granularity + include/reference decision pending)
  # Olkowicz_etal_2016_TableS1 is intentionally NOT listed: non-mammal (28 birds), blocked on
  #   the MDD/mammal-only taxonomy resolver (PROJECT_SCOPE_AND_DATASET_ROADMAP.md Part 3, steps 1 & 4).
)

# Initialize an empty list to store data frames with cell counts data
cell_counts_isotropic_fractionator_data_list <- list()

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
  # sep = "\t" (2026-11 wiring): the files ARE tab-separated, and read.table's default
  # whitespace splitting silently collapses EMPTY fields -- the 2026-11 builds of the
  # six HH 2015 primary sources write missing values as empty fields, where every
  # earlier build writes "NA", so the default read cannot read the new TSVs at all
  # (scan error: "line N did not have M elements"). Verified 2026-11: reading all 19
  # pre-existing items with sep = "\t" gives data frames identical to the default read.
  item_data <- read.table(file = item_tsv, sep = "\t",
                          header = TRUE, stringsAsFactors = FALSE, check.names = FALSE)

  # Store the data frame in the list with the corresponding item name
  cell_counts_isotropic_fractionator_data_list[[item_name[i]]] <- item_data
}


## 1.5 Reshape the long-format primary TSVs (HH2014 Table 1; Sarko 2009 Tables 1-2)
# The 2026-11 builds of these three items are LONG (one row per structure);
# every other item in this merge is wide (one row per species), and sec 2's
# column-name standardization assumes the wide layout. This step converts
# the three data frames in place, producing exactly the column sets of the
# verified wide builds of the same tables, so the standardized-term files
# and every downstream section apply unchanged. Sarko Table 2's TOTAL CORTEX
# and TOTAL HIPPOCAMPUS blocks are summed into "Cerebral cortex" (the
# convention Herculano-Houzel et al. 2015 used for this paper); the combined
# SDs and densities are not printed and stay NA -- sec 3.7 derives them.

reshape_primaries <- function(lst) {

  ## ---- Herculano-Houzel et al. 2014, Table 1 (long -> wide) -------------
  d <- lst$HerculanoHouzel_etal_2014_Table1
  if (!is.null(d) && "Structure_as_published" %in% colnames(d)) {
    smap <- c("Whole brain" = "Whole brain",
              "Cerebral cortex, GM + WM*" = "Cerebral cortex",
              "Cerebral cortex, GM**" = "Cerebral cortex GM",
              "Cerebral cortex, WM" = "Cerebral cortex WM",
              "Cerebellum" = "Cerebellum", "Rest of brain" = "Rest of brain",
              "Hippocampus" = "Hippocampus", "Amygdala" = "Amygdala",
              "Striatum" = "Striatum", "Diencephalon" = "Diencephalon",
              "Mesencephalon" = "Mesencephalon", "Pons" = "Pons",
              "Medulla" = "Medulla", "Olfactory bulb" = "Olfactory bulb")
    mmap <- c("Mass.g" = "Mass, g", "N.n" = "N, n", "O.n" = "O, n",
              "N.p.mg" = "N/mg", "O.p.mg" = "O/mg", "O.p.N" = "O/N")
    if (!all(d$Structure_as_published %in% names(smap)))
      stop("1.5 reshape: unmapped Structure_as_published in HerculanoHouzel_etal_2014_Table1: ",
           paste(setdiff(d$Structure_as_published, names(smap)), collapse = ", "), call. = FALSE)
    w <- data.frame(Species = unique(d$Species), Order = "Afrotheria",
                    stringsAsFactors = FALSE, check.names = FALSE)
    for (i in seq_len(nrow(d))) {
      s <- smap[[d$Structure_as_published[i]]]
      for (mc in names(mmap)) {
        w[[paste(s, mmap[[mc]])]][1] <- suppressWarnings(as.numeric(d[[mc]][i]))
      }
    }
    lst$HerculanoHouzel_etal_2014_Table1 <- w
  }

  ## ---- Sarko et al. 2009, Table 1 (column renaming + derived O) ---------
  d <- lst$Sarko_etal_2009_Table1
  if (!is.null(d) && "WholeBrain_Mass.g" %in% colnames(d)) {
    ## The long Table 1 build carries no n column; the paper's per-species n
    ## is printed in Table 2 (same animals, one n per species across blocks).
    wb_n <- d$WholeBrain_n
    if (is.null(wb_n)) {
      t2 <- lst$Sarko_etal_2009_Table2
      wb_n <- vapply(d$Species, function(sp) {
        ns <- unique(suppressWarnings(as.numeric(t2$n[t2$Species == sp])))
        ns <- ns[!is.na(ns)]
        if (length(ns) != 1L)
          stop("1.5 reshape: expected one n for ", sp, " in Sarko_etal_2009_Table2; found ",
               paste(ns, collapse = ", "), ".", call. = FALSE)
        ns
      }, numeric(1))
    }
    w <- data.frame(Species = d$Species, Order = "Eulipotyphla",
                    "Common name" = d$species_as_published,
                    "Whole brain n" = wb_n,
                    "Body mass, g" = d$Body_Mass.g,
                    "Body mass, g SD" = d$Body_Mass.g_plusminus_reported,
                    "Brain mass, g" = d$WholeBrain_Mass.g,
                    "Brain mass, g SD" = d$WholeBrain_Mass.g_plusminus_reported,
                    "Whole brain Cells" = d$WholeBrain_Cells.n,
                    "Whole brain Cells SD" = d$WholeBrain_Cells.n_plusminus_reported,
                    "Whole brain Neurons" = d$WholeBrain_N.n,
                    "Whole brain Neurons SD" = d$WholeBrain_N.n_plusminus_reported,
                    # Not printed in the paper; total cells - total neurons
                    # (exact on the printed means), as in the verified build.
                    "Whole brain Other cells" = d$WholeBrain_Cells.n - d$WholeBrain_N.n,
                    "Whole brain Other cells SD" = NA_real_,
                    "Whole brain Source" = "Sarko et al., 2009",
                    stringsAsFactors = FALSE, check.names = FALSE)
    lst$Sarko_etal_2009_Table1 <- w
  }

  ## ---- Sarko et al. 2009, Table 2 (long -> wide, cortex+hippocampus) ----
  d <- lst$Sarko_etal_2009_Table2
  if (!is.null(d) && "Structure_as_published" %in% colnames(d)) {
    mmap <- c("Mass.g" = "Mass, g", "Mass.g_plusminus_reported" = "Mass, g SD",
              "N.n" = "N, n", "N.n_plusminus_reported" = "N, n SD",
              "N.p.mg" = "N/mg", "N.p.mg_plusminus_reported" = "N/mg SD",
              "O.n" = "O, n", "O.n_plusminus_reported" = "O, n SD",
              "O.p.mg" = "O/mg", "O.p.mg_plusminus_reported" = "O/mg SD")
    blocks <- list("Cerebellum" = "CEREBELLUM", "RoB" = "REMAINING AREAS",
                   "Olfactory bulb" = "TOTAL OLFACTORY BULBS")
    species <- unique(d$Species)
    w <- data.frame(Species = species, Order = "Eulipotyphla",
                    stringsAsFactors = FALSE, check.names = FALSE)
    for (sp in species) {
      r <- match(sp, species)
      ## Cerebral cortex = TOTAL CORTEX + TOTAL HIPPOCAMPUS (sums of the
      ## printed means; SDs and densities of the sum are not printed -> NA)
      cx <- d[d$Species == sp & d$Structure_as_published == "TOTAL CORTEX", , drop = FALSE]
      hp <- d[d$Species == sp & d$Structure_as_published == "TOTAL HIPPOCAMPUS", , drop = FALSE]
      if (nrow(cx) != 1L || nrow(hp) != 1L)
        stop("1.5 reshape: expected one TOTAL CORTEX and one TOTAL HIPPOCAMPUS row for ",
             sp, " in Sarko_etal_2009_Table2.", call. = FALSE)
      for (mc in c("Mass.g", "N.n", "O.n"))
        w[[paste("Cerebral cortex", mmap[[mc]])]][r] <-
          suppressWarnings(as.numeric(cx[[mc]])) + suppressWarnings(as.numeric(hp[[mc]]))
      for (mc in c("Mass.g_plusminus_reported", "N.n_plusminus_reported",
                   "N.p.mg", "N.p.mg_plusminus_reported",
                   "O.n_plusminus_reported", "O.p.mg", "O.p.mg_plusminus_reported"))
        w[[paste("Cerebral cortex", mmap[[mc]])]][r] <- NA_real_
      w[["Cerebral cortex O/N"]][r] <- NA_real_
      w[["Cerebral cortex O/N SD"]][r] <- NA_real_
      w[["Cerebral cortex Source"]][r] <- "Sarko et al., 2009"
      ## Remaining structures map block-by-block
      for (s in names(blocks)) {
        b <- d[d$Species == sp & d$Structure_as_published == blocks[[s]], , drop = FALSE]
        if (nrow(b) != 1L)
          stop("1.5 reshape: expected one ", blocks[[s]], " row for ", sp,
               " in Sarko_etal_2009_Table2.", call. = FALSE)
        for (mc in names(mmap))
          w[[paste(s, mmap[[mc]])]][r] <- suppressWarnings(as.numeric(b[[mc]]))
        w[[paste(s, "O/N")]][r] <- NA_real_      # not printed in the paper
        w[[paste(s, "O/N SD")]][r] <- NA_real_
        w[[paste(s, "Source")]][r] <- "Sarko et al., 2009"
      }
    }
    lst$Sarko_etal_2009_Table2 <- w
  }
  lst
}

cell_counts_isotropic_fractionator_data_list <- reshape_primaries(cell_counts_isotropic_fractionator_data_list)
rm(reshape_primaries)

## 1.6 Scope restrictions for compilation-bearing primaries (2026-11 wiring of the six
##     HH 2015 primary sources; decisions D5 and D6).
##     Two of the six newly wired items are themselves part-compilations: most of their
##     rows re-report an earlier item that is also wired here. Under the compilation
##     rule those rows must not enter from the compiling item -- that would double-count
##     the source paper and, through the sec 8.2.H pins, could outrank it -- so each
##     item is cut to its own-measurement species BEFORE standardisation. The cuts are
##     guarded on the exact row counts and species sets recorded in the builds (the
##     per-row provenance is carried in each build's Source column).

# Ribeiro et al. 2014, Table 1 (olfactory bulb): own measurements for 8 of 23 species
# -- the five primates, Tupaia glis, and the rat and squirrel at larger samples than
# HH 2011 (rat n = 5, squirrel n = 9). The other 15 rows re-report HH 2011 (7 glires),
# Sarko et al. 2009 (5 eulipotyphlans) and Neves et al. 2014 (3 afrotherians) and stay
# with those items.
rib_df <- cell_counts_isotropic_fractionator_data_list$Ribeiro_etal_2014_Table1
if (!is.null(rib_df)) {
  rib_own <- c("Rattus norvegicus", "Sciurus carolinensis", "Microcebus murinus",
               "Callithrix jacchus", "Otolemur garnettii", "Aotus trivirgatus",
               "Macaca mulatta", "Tupaia glis")
  if (nrow(rib_df) != 23L || !all(rib_own %in% rib_df$Species))
    stop("1.6: expected the full 23-row Ribeiro_etal_2014_Table1 including its 8 ",
         "own-measurement species. The source table changed -- re-check the D5 scope ",
         "restriction before applying it.", call. = FALSE)
  rib_df <- rib_df[rib_df$Species %in% rib_own, , drop = FALSE]
  if (nrow(rib_df) != 8L)
    stop("1.6: Ribeiro scope restriction kept ", nrow(rib_df), " rows, expected 8.",
         call. = FALSE)
  cell_counts_isotropic_fractionator_data_list$Ribeiro_etal_2014_Table1 <- rib_df
}
rm(rib_df)

# Herculano-Houzel & Kaas 2011, Table 2 (cerebellar totals): own measurements for 2 of
# 9 species -- Gorilla gorilla (n = 1) and Pongo pygmaeus (n = 3), Yerkes cerebella.
# The Homo sapiens row compiles Azevedo et al. 2009 (and enters from that item
# instead); the other six rows compile Herculano-Houzel et al. 2007, which is not an
# item here, and stay out.
hhk_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_Kaas_2011_Table2
if (!is.null(hhk_df)) {
  hhk_own <- c("Gorilla gorilla", "Pongo pygmaeus")
  if (nrow(hhk_df) != 9L || !all(hhk_own %in% hhk_df$Species))
    stop("1.6: expected the full 9-row HerculanoHouzel_Kaas_2011_Table2 including ",
         "Gorilla gorilla and Pongo pygmaeus. The source table changed -- re-check ",
         "the D6 scope restriction before applying it.", call. = FALSE)
  hhk_df <- hhk_df[hhk_df$Species %in% hhk_own, , drop = FALSE]
  if (nrow(hhk_df) != 2L)
    stop("1.6: HH & Kaas scope restriction kept ", nrow(hhk_df), " rows, expected 2.",
         call. = FALSE)
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_Kaas_2011_Table2 <- hhk_df
}
rm(hhk_df)

## 2 Change to standardized terminology for all variables in those dataframes

# Read standardized terms
standardized_term_cell_counts_isotropic_fractionator <- read.csv("standardized_term_cell_counts_isotropic_fractionator.csv", check.names=FALSE)

# Loop through each data frame to apply standardized terms
for (i in seq_along(item_name)) {
  df <- cell_counts_isotropic_fractionator_data_list[[item_name[i]]]
  indices <- match(colnames(df), standardized_term_cell_counts_isotropic_fractionator$Original_Term[standardized_term_cell_counts_isotropic_fractionator$Reference == item_name[i]])
  colnames(df) <- (standardized_term_cell_counts_isotropic_fractionator$Standardized_Term[standardized_term_cell_counts_isotropic_fractionator$Reference == item_name[i]])[indices]
  cell_counts_isotropic_fractionator_data_list[[item_name[i]]] <- df
}

## 3 Calculate variables to match them across datasets before filtering

# 3.1 Inspect data: Get an alphabetized list of variables from all datasets in alphabetical order to examine. Q. Can any variables be converted?
# Initialize an empty vector to store all column names
all_variables <- character(0)
# Loop through each data frame
for (i in seq_along(item_name)) {
  # Get the data frame associated with the current name
  df <- cell_counts_isotropic_fractionator_data_list[[item_name[i]]]
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
  df <- cell_counts_isotropic_fractionator_data_list[[i]]
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
  cell_counts_isotropic_fractionator_data_list[[i]] <- df
}

# 3.3 Add a column converting mass from kg to g
# Formula: "_Mass.g" = "_Mass.kg" x 1000

# Loop: Calculate "_Mass.g" from "_Mass.kg" columns
for (i in seq_along(item_name)) {
  # Extract the dataframe
  df <- cell_counts_isotropic_fractionator_data_list[[i]]
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
  cell_counts_isotropic_fractionator_data_list[[i]] <- df
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
df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2020_TABLE2
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
cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2020_TABLE2 <- df

# 3.4b Unit fix for Burish et al. 2010: cell COUNTS were tabulated in MILLIONS
#      (e.g. Macaca mulatta brain "6380" = 6.38e9 neurons; the spinal-cord neuron and
#      other-cell counts likewise). Convert to absolute counts to match every other
#      dataset. Masses (g), densities (per mg) and percentages are already absolute and
#      are left unchanged. (Burish's "Brain" = whole brain, so NBR is mapped to
#      WholeBrain_N.n in its standardized-terms file; here we only rescale the counts.)
df <- cell_counts_isotropic_fractionator_data_list$Burish_etal_2010_Table1
for (col in c("WholeBrain_N.n", "SpinalCord_N.n", "SpinalCord_N.n_SD",
              "SpinalCord_O.n", "SpinalCord_O.n_SD")) {
  if (col %in% colnames(df)) df[[col]] <- df[[col]] * 1e6
}
cell_counts_isotropic_fractionator_data_list$Burish_etal_2010_Table1 <- df

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
jardimmesseder_df <- cell_counts_isotropic_fractionator_data_list$JardimMesseder_etal_2017_Table1
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
  cell_counts_isotropic_fractionator_data_list$JardimMesseder_etal_2017_Table1 <- jardimmesseder_df
}
rm(jardimmesseder_df)

# 3.4d Misprint fix for Herculano-Houzel et al. 2011 Table 1: Cynomys sp. whole-brain neurons.
#      The 2011 table prints prairie dog "Brain neurons" as 473.94 +/- 78.74 x 10^6, but its own
#      cortical + cerebellar + RoB neuron counts sum to 437.94 x 10^6 (53.77 + 350.08 + 34.09),
#      and Herculano-Houzel et al. 2015 (Table 5) print 437,943,767 with the SAME SD (78,742,230):
#      the 2011 mean is a digit transposition (473.94 for 437.94). The frozen snapshot and the
#      built TSV stay verbatim -- this is the record of the misprint -- and the value is corrected
#      here, to the parts sum of the same table, before any derivation (3.6/3.7) consumes it.
#      NOT a rounding adjustment: the guards below stop the merge unless the printed value and
#      the parts sum are exactly the expected ones. (The reverse case -- a compilation's misprint
#      corrected by this primary source -- is the rabbit Cerebellum_O.p.N: HH 2015 Table 2 prints
#      1.222, its own olfactory-bulb ratio duplicated; the 2011 counts derive 0.314 in sec 3.7 once
#      the sec 8.2.H precedence pin puts this item above the 2015 tables.)
hh2011_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2011_Table1
if (!is.null(hh2011_df)) {
  pdog <- !is.na(hh2011_df$Species) & hh2011_df$Species == "Cynomys sp."
  if (!("WholeBrain_N.n" %in% colnames(hh2011_df)) || sum(pdog) != 1L)
    stop("3.4d: expected exactly one 'Cynomys sp.' row with a WholeBrain_N.n column in ",
         "HerculanoHouzel_etal_2011_Table1; found ", sum(pdog), " row(s). The source table or ",
         "its standardized terms changed -- re-check this correction before applying it.",
         call. = FALSE)
  printed_wb <- suppressWarnings(as.numeric(hh2011_df$WholeBrain_N.n[pdog]))
  parts_wb <- sum(suppressWarnings(as.numeric(c(hh2011_df$CerebralCortex_N.n[pdog],
                                                hh2011_df$Cerebellum_N.n[pdog],
                                                hh2011_df$RoB_N.n[pdog]))))
  if (!isTRUE(all.equal(printed_wb, 473940000, tolerance = 1e-9)) ||
      !isTRUE(all.equal(parts_wb, 437940000, tolerance = 1e-9)))
    stop("3.4d: expected the printed Cynomys sp. WholeBrain_N.n of 473940000 and a parts sum of ",
         "437940000; found ", printed_wb, " and ", parts_wb, ". The source table changed -- ",
         "re-check this correction before applying it.", call. = FALSE)
  hh2011_df$WholeBrain_N.n[pdog] <- parts_wb
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2011_Table1 <- hh2011_df
}
rm(hh2011_df)


# 3.4e Misprint fixes for Dos Santos et al. 2020 Table 1 (ten cells).
#      The published Table 1 is used as printed except for ten cells that the paper's own evidence
#      shows to be wrong: its arithmetic (a count above the total, a ratio that is not the quotient
#      its footnote defines, densities that are not mass-additive), its Table 5 and its Figure 5.
#      Where the corrected value comes from, in the curator's order of preference (2026-11):
#      (1) a published table, (2) calculation from published numbers, (3) the authors' unpublished
#      table, named as the source, (4) a figure. Eight values come from (1) or (2). Two, E007 and
#      E008, come from (3): no published table carries those two cortex samples and the published
#      numbers do not fix them exactly; the Figure 5 readings agree within 0.4%.
#      Check: DosSantos_etal_2020/internal_checks/DosSantos_etal_2020_Table1_internal_check.R
#      (33 major or impossible failures as printed; 12 with these values applied, all of them
#      documented non-errors). Decision and evidence per cell:
#      DosSantos_etal_2020/reference_tables/DosSantos_etal_2020_errata.csv (E001-E010).
#      The authors' unpublished data agrees with the eight publication-derived values to within
#      0.7% (private check: Evo-M1-Trait-Data-restricted/restricted_checks/_cross_table/
#      DosSantos_2020_published_vs_authors_unpublished/).
#        E001 Tragelaphus strepsiceros WholeBrain_C.n     21,751,929 -> 21,888,835,128  (= Cx + Cb + RoB; print lost 3 digits)
#        E002 Procavia capensis        Cerebellum_N.n  4,883,703,000 ->    488,373,000  (stray digit; N exceeded C)
#        E003 Mungos mungo             RoB_I.p.mg              1.915 ->          1,915  (decimal point for thousands space)
#        E004 Dendrohyrax dorsalis     WholeBrain_I.p.mg      10,129 ->          2,123  (= I / mass; above all its parts)
#        E005 Tragelaphus strepsiceros Hippocampus_I.p.N       3.946 ->          1.034  (= I / N, the footnote's identity)
#        E006 Tragelaphus strepsiceros Hippocampus_I.p.mg      4,710 ->          2,682  (= I / mass; mass-additivity)
#        E007 Sapajus apella (printed Cebus apella)  CerebralCortex_C.n  3,035,947,220 -> 3,707,354,000  (authors' unpublished workbook)
#        E008 Papio anubis cynocephalus              CerebralCortex_C.n  4,934,116,014 -> 6,740,084,000  (authors' unpublished workbook)
#        E009 Petrodromus tetradactylus RoB_I.n            1,217,665 ->      1,649,430  (= I/mg x mass; Table 5)
#        E010 Petrodromus tetradactylus Hippocampus_I.n    1,067,062 ->        824,704  (= I/mg x mass)
#      The corrections are made HERE, before 3.6/3.7 derive anything, so the within-source
#      microglia-per-cell ratio (_I.p.C = _I.n / _C.n) is built on the corrected cells. The frozen
#      snapshot, the item CSV and the public TSV stay verbatim. The guards stop the merge unless
#      each printed value is exactly the expected one AND the errata file still proposes exactly
#      the value applied here (withdraw an erratum there and this step stops until it is removed).
#      E007/E008 change only that derived ratio in the merged output: merged cortex total cells for
#      those species come from the primary source (sec 8.2.H demotion).
dossantos_df <- cell_counts_isotropic_fractionator_data_list$DosSantos_etal_2020_Table1
if (!is.null(dossantos_df)) {
  dossantos_fixes <- data.frame(
    errata_id = sprintf("DosSantos_etal_2020-E%03d", 1:10),
    species   = c("Tragelaphus strepsiceros", "Procavia capensis", "Mungos mungo", "Dendrohyrax dorsalis",
                  "Tragelaphus strepsiceros", "Tragelaphus strepsiceros", "Cebus apella",
                  "Papio anubis cynocephalus", "Petrodromus tetradactylus", "Petrodromus tetradactylus"),
    variable  = c("WholeBrain_C.n", "Cerebellum_N.n", "RoB_I.p.mg", "WholeBrain_I.p.mg", "Hippocampus_I.p.N",
                  "Hippocampus_I.p.mg", "CerebralCortex_C.n", "CerebralCortex_C.n", "RoB_I.n", "Hippocampus_I.n"),
    printed   = c(21751929, 4883703000, 1.915, 10129, 3.946, 4710, 3035947220, 4934116014, 1217665, 1067062),
    corrected = c(21888835128, 488373000, 1915, 2123, 1.034, 2682, 3707354000, 6740084000, 1649430, 824704),
    stringsAsFactors = FALSE)
  dossantos_errata_file <- file.path("..", "DosSantos_etal_2020", "reference_tables", "DosSantos_etal_2020_errata.csv")
  if (!file.exists(dossantos_errata_file))
    stop("3.4e: ", dossantos_errata_file, " not found. These corrections are only applied against ",
         "their errata file.", call. = FALSE)
  dossantos_errata <- read.csv(dossantos_errata_file, colClasses = "character", check.names = FALSE)
  for (k in seq_len(nrow(dossantos_fixes))) {
    fix <- dossantos_fixes[k, ]
    erratum <- dossantos_errata[dossantos_errata$errata_id == fix$errata_id, , drop = FALSE]
    if (nrow(erratum) != 1L || erratum$status == "withdrawn" ||
        !isTRUE(all.equal(suppressWarnings(as.numeric(erratum$proposed_value)), fix$corrected, tolerance = 1e-12)))
      stop("3.4e: ", fix$errata_id, " in DosSantos_etal_2020_errata.csv is missing, withdrawn, or no longer ",
           "proposes ", format(fix$corrected, scientific = FALSE), ". Re-check this correction ",
           "before applying it.", call. = FALSE)
    target <- !is.na(dossantos_df$Species) & dossantos_df$Species == fix$species
    if (!(fix$variable %in% colnames(dossantos_df)) || sum(target) != 1L)
      stop("3.4e: expected exactly one '", fix$species, "' row with a ", fix$variable, " column in ",
           "DosSantos_etal_2020_Table1; found ", sum(target), " row(s). The source table or its ",
           "standardized terms changed -- re-check this correction before applying it.", call. = FALSE)
    printed_value <- suppressWarnings(as.numeric(dossantos_df[[fix$variable]][target]))
    if (!isTRUE(all.equal(printed_value, fix$printed, tolerance = 1e-12)))
      stop("3.4e: expected the printed ", fix$species, " ", fix$variable, " of ",
           format(fix$printed, scientific = FALSE), ", found ", printed_value, ". The source table ",
           "changed -- re-check this correction (", fix$errata_id, ") before applying it.", call. = FALSE)
    dossantos_df[[fix$variable]][target] <- fix$corrected
  }
  cell_counts_isotropic_fractionator_data_list$DosSantos_etal_2020_Table1 <- dossantos_df
  rm(dossantos_fixes, dossantos_errata_file, dossantos_errata, fix, erratum, target, printed_value)
}
rm(dossantos_df)

# 3.4f Misprint fix for Sarko et al. 2009 Table 2: Blarina brevicauda cerebral cortex neurons.
#      In the printed TOTAL CORTEX block, the number of neurons for the short-tailed shrew
#      (14.20 +/- 1.04 x 10^6) duplicates the number of non-neuronal cells in the same row
#      (also 14.20 +/- 1.04). The paper's own neuronal density (59.28 x 10^3/mg over a
#      0.1794 g cortex = 10.64 x 10^6), its percentage of neurons (42.82% of 24.86 x 10^6
#      total cells = 10.65 x 10^6) and total minus non-neurons (24.86 - 14.20 = 10.66 x 10^6)
#      all give ~10.64-10.66 x 10^6, and Herculano-Houzel et al. 2015 -- whose "Cerebral
#      cortex" for this species is the cortex + hippocampus sum of this table -- used
#      11,876,000 for the combined structure, i.e. the correct underlying value. The frozen
#      snapshot and the built TSV stay verbatim (combined cortex + hippocampus neurons
#      = 14.20 + 1.2206 = 15.4206 x 10^6); the value is corrected here, before any derivation
#      (3.6/3.7) consumes it, to the combined value implied by the paper's internally
#      consistent cells: (24.86 - 14.20) + 1.2206 = 11.8806 x 10^6. The guards below stop
#      the merge unless the as-printed combined value is exactly the expected one.
sarko2009_t2_df <- cell_counts_isotropic_fractionator_data_list$Sarko_etal_2009_Table2
if (!is.null(sarko2009_t2_df)) {
  blarina <- !is.na(sarko2009_t2_df$Species) & sarko2009_t2_df$Species == "Blarina brevicauda"
  if (!("CerebralCortex_N.n" %in% colnames(sarko2009_t2_df)) || sum(blarina) != 1L)
    stop("3.4f: expected exactly one 'Blarina brevicauda' row with a CerebralCortex_N.n column in ",
         "Sarko_etal_2009_Table2; found ", sum(blarina), " row(s). The source table or ",
         "its standardized terms changed -- re-check this correction before applying it.",
         call. = FALSE)
  printed_ctx <- suppressWarnings(as.numeric(sarko2009_t2_df$CerebralCortex_N.n[blarina]))
  if (!isTRUE(all.equal(printed_ctx, 15420600, tolerance = 1e-9)))
    stop("3.4f: expected the as-printed combined Blarina brevicauda CerebralCortex_N.n of ",
         "15420600; found ", printed_ctx, ". The source table changed -- ",
         "re-check this correction before applying it.", call. = FALSE)
  sarko2009_t2_df$CerebralCortex_N.n[blarina] <- 11880600
  cell_counts_isotropic_fractionator_data_list$Sarko_etal_2009_Table2 <- sarko2009_t2_df
}
rm(sarko2009_t2_df)

# 3.4g Undo sec 3.2's density/ratio subtraction for Herculano-Houzel et al. 2014 Table 1.
#      Sec 3.2 derives "WholeBrain_" from "WholeBrainOlfactoryBulb_" minus "OlfactoryBulb_"
#      for EVERY shared suffix. That is right for masses and cell counts, but this item is
#      the first to report whole-brain DENSITIES and the O/N ratio alongside the bulb's:
#      subtraction there is meaningless and yields impossible values (WholeBrain_O.p.mg
#      = 47,130 - 68,230 = -21,100; WholeBrain_O.p.N = 0.841 - 3.146 = -2.305). The three
#      affected columns are blanked here, before sec 3.7, which re-derives them from this
#      item's (correctly subtracted) whole-brain counts and mass. The printed
#      WholeBrainOlfactoryBulb densities themselves (56,071 / 47,130 / 0.841) are untouched.
#      Guards stop the merge unless the subtracted values are exactly the expected ones.
hh2014_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2014_Table1
if (!is.null(hh2014_df)) {
  ele <- !is.na(hh2014_df$Species) & hh2014_df$Species == "Loxodonta africana"
  need <- c("WholeBrain_N.p.mg", "WholeBrain_O.p.mg", "WholeBrain_O.p.N")
  if (!all(need %in% colnames(hh2014_df)) || sum(ele) != 1L)
    stop("3.4g: expected exactly one 'Loxodonta africana' row with WholeBrain density/ratio ",
         "columns in HerculanoHouzel_etal_2014_Table1; found ", sum(ele), " row(s). The source ",
         "table or its standardized terms changed -- re-check this correction before applying ",
         "it.", call. = FALSE)
  got <- suppressWarnings(as.numeric(c(hh2014_df$WholeBrain_N.p.mg[ele],
                                       hh2014_df$WholeBrain_O.p.mg[ele],
                                       hh2014_df$WholeBrain_O.p.N[ele])))
  if (!isTRUE(all.equal(got, c(34384, -21100, -2.305), tolerance = 1e-9)))
    stop("3.4g: expected the sec-3.2-subtracted WholeBrain densities/ratio 34384, -21100, ",
         "-2.305; found ", paste(got, collapse = ", "), ". The source table changed -- ",
         "re-check this correction before applying it.", call. = FALSE)
  hh2014_df$WholeBrain_N.p.mg[ele] <- NA
  hh2014_df$WholeBrain_O.p.mg[ele] <- NA
  hh2014_df$WholeBrain_O.p.N[ele]  <- NA
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2014_Table1 <- hh2014_df
}
rm(hh2014_df)

# 3.4h Thousands-separator fixes for Herculano-Houzel et al. 2014 Table 1 (2026-11 build).
#      Two printed densities in the elephant table use a comma as the thousands
#      separator -- cortical GM neurons/mg "3,661" and rest-of-brain O/N "36,948" --
#      and the 2026-11 long-format build captured them literally as 3.661 and 36948
#      (the registry row flags both as retained-as-printed). Every other source
#      agrees on the intended readings: the PMC rendering of the same table, and
#      Herculano-Houzel et al. 2015, which re-reports this table. A density of
#      3.661 neurons/mg beside 38,910 other-cells/mg in the same row, and an O/N
#      ratio of 36,948 beside this paper's 0.154-54.195 range, are impossible.
#      The frozen TSV keeps the literal captures; the values are corrected here,
#      guarded on the exact artefact values.
hh2014b_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2014_Table1
if (!is.null(hh2014b_df)) {
  ele <- !is.na(hh2014b_df$Species) & hh2014b_df$Species == "Loxodonta africana"
  if (sum(ele) != 1L ||
      !all(c("CerebralCortexGrey_N.p.mg", "RoB_O.p.N") %in% colnames(hh2014b_df)))
    stop("3.4h: expected exactly one 'Loxodonta africana' row with CerebralCortexGrey_N.p.mg ",
         "and RoB_O.p.N columns in HerculanoHouzel_etal_2014_Table1. The source table or ",
         "its standardized terms changed -- re-check these corrections before applying them.",
         call. = FALSE)
  gm_npmg <- suppressWarnings(as.numeric(hh2014b_df$CerebralCortexGrey_N.p.mg[ele]))
  rob_opn <- suppressWarnings(as.numeric(hh2014b_df$RoB_O.p.N[ele]))
  if (!isTRUE(all.equal(gm_npmg, 3.661, tolerance = 1e-9)) ||
      !isTRUE(all.equal(rob_opn, 36948, tolerance = 1e-9)))
    stop("3.4h: expected the captured artefacts CerebralCortexGrey_N.p.mg = 3.661 and ",
         "RoB_O.p.N = 36948; found ", gm_npmg, " and ", rob_opn, ". The source table ",
         "changed -- re-check these corrections before applying them.", call. = FALSE)
  hh2014b_df$CerebralCortexGrey_N.p.mg[ele] <- 3661
  hh2014b_df$RoB_O.p.N[ele] <- 36.948
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2014_Table1 <- hh2014b_df
}
rm(hh2014b_df)

# 3.4i Gabi et al. 2010 Table 1: Macaca radiata whole-brain neurons (2026-11 wiring,
#      decision D2). The table prints 3.78 x 10^9 whole-brain neurons, but its own
#      structure values sum to 3,761,360,000, and its printed % neuronal cells (43.5)
#      and O/N (1.299) both fit the sum, not the printed total; Herculano-Houzel
#      et al. 2015 likewise carries the sum (unrounded). The frozen TSV keeps the
#      printed total; the structure sum is adopted here, guarded on both numbers.
gabi_df <- cell_counts_isotropic_fractionator_data_list$Gabi_etal_2010_Table1
if (!is.null(gabi_df)) {
  rad <- !is.na(gabi_df$Species) & gabi_df$Species == "Macaca radiata"
  if (sum(rad) != 1L || !all(c("WholeBrain_N.n", "CerebralCortex_N.n", "Cerebellum_N.n",
                               "RoB_N.n") %in% colnames(gabi_df)))
    stop("3.4i: expected exactly one 'Macaca radiata' row with whole-brain and structure ",
         "neuron columns in Gabi_etal_2010_Table1. The source table or its standardized ",
         "terms changed -- re-check this correction before applying it.", call. = FALSE)
  wb_n <- suppressWarnings(as.numeric(gabi_df$WholeBrain_N.n[rad]))
  parts <- sum(suppressWarnings(as.numeric(gabi_df$CerebralCortex_N.n[rad])),
               suppressWarnings(as.numeric(gabi_df$Cerebellum_N.n[rad])),
               suppressWarnings(as.numeric(gabi_df$RoB_N.n[rad])))
  if (!isTRUE(all.equal(wb_n, 3780000000)) || !isTRUE(all.equal(parts, 3761360000)))
    stop("3.4i: expected printed WholeBrain_N.n = 3780000000 and structure sum ",
         "3761360000 for Macaca radiata; found ", wb_n, " and ", parts, ". The source ",
         "table changed -- re-check this correction before applying it.", call. = FALSE)
  gabi_df$WholeBrain_N.n[rad] <- parts
  cell_counts_isotropic_fractionator_data_list$Gabi_etal_2010_Table1 <- gabi_df
}
rm(gabi_df)

# 3.4j Gabi et al. 2010 Table 1: Microcebus murinus rest-of-brain non-neuronal density
#      (2026-11 wiring, decision D2). The table prints 93,254 other cells/mg --
#      digit-for-digit the Callimico goeldii value beside it -- where the printed
#      count and mass give 101,731/mg, the value that also reproduces the printed
#      total cells exactly ((22,029 + 101,731) x 500 mg) and the value HH 2015
#      carries. The frozen TSV keeps the printed density; 101,731 is adopted here,
#      guarded on the printed value.
gabi2_df <- cell_counts_isotropic_fractionator_data_list$Gabi_etal_2010_Table1
if (!is.null(gabi2_df)) {
  mic <- !is.na(gabi2_df$Species) & gabi2_df$Species == "Microcebus murinus"
  if (sum(mic) != 1L || !"RoB_O.p.mg" %in% colnames(gabi2_df))
    stop("3.4j: expected exactly one 'Microcebus murinus' row with a RoB_O.p.mg column ",
         "in Gabi_etal_2010_Table1. The source table or its standardized terms ",
         "changed -- re-check this correction before applying it.", call. = FALSE)
  rob_opmg <- suppressWarnings(as.numeric(gabi2_df$RoB_O.p.mg[mic]))
  if (!isTRUE(all.equal(rob_opmg, 93254)))
    stop("3.4j: expected the printed RoB_O.p.mg = 93254 for Microcebus murinus; found ",
         rob_opmg, ". The source table changed -- re-check this correction before ",
         "applying it.", call. = FALSE)
  gabi2_df$RoB_O.p.mg[mic] <- 101731
  cell_counts_isotropic_fractionator_data_list$Gabi_etal_2010_Table1 <- gabi2_df
}
rm(gabi2_df)

# 3.4k Neves et al. 2014 Table 1: Procavia capensis olfactory-bulb mass (2026-11
#      wiring, decision D3). Neves prints 0.290 g, but its own bulb count and density
#      (20,909,000 neurons at 73,110 neurons/mg) imply 0.286 g; Ribeiro et al. 2014
#      prints 0.286 g and HH 2015 Table 4 carries 0.286 g. The frozen TSV keeps
#      0.290 g as printed in Neves; 0.286 g is adopted here, guarded on the printed
#      value, so wiring the primary does not reintroduce the inconsistent mass over
#      the compilation's consistent one.
neves_df <- cell_counts_isotropic_fractionator_data_list$Neves_etal_2014_Table1
if (!is.null(neves_df)) {
  pcap <- !is.na(neves_df$Species) & neves_df$Species == "Procavia capensis"
  if (sum(pcap) != 1L || !"OlfactoryBulb_Mass.g" %in% colnames(neves_df))
    stop("3.4k: expected exactly one 'Procavia capensis' row with an OlfactoryBulb_Mass.g ",
         "column in Neves_etal_2014_Table1. The source table or its standardized terms ",
         "changed -- re-check this correction before applying it.", call. = FALSE)
  ob_mass <- suppressWarnings(as.numeric(neves_df$OlfactoryBulb_Mass.g[pcap]))
  if (!isTRUE(all.equal(ob_mass, 0.29, tolerance = 1e-9)))
    stop("3.4k: expected the printed OlfactoryBulb_Mass.g = 0.29 for Procavia capensis; ",
         "found ", ob_mass, ". The source table changed -- re-check this correction ",
         "before applying it.", call. = FALSE)
  neves_df$OlfactoryBulb_Mass.g[pcap] <- 0.286
  cell_counts_isotropic_fractionator_data_list$Neves_etal_2014_Table1 <- neves_df
}
rm(neves_df)

# 3.4l Herculano-Houzel et al. 2015 Table 2: Homo sapiens cerebellar other-cells SD
#      (2026-11 wiring, decision D4). Table 2 prints the SD as 2,170,000; Azevedo
#      et al. 2009, the primary source for the human row, gives 16.04 +/- 2.17
#      BILLION other cells in its text -- the 2015 table dropped three zeros. The
#      frozen HH 2015 build keeps the printed SD; it is corrected here, guarded on
#      the printed value. (SD columns are annexed to metadata in sec 6, so this
#      changes the unfiltered table, not the filtered long table.)
hh2015t2_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2015_Table2
if (!is.null(hh2015t2_df)) {
  hum <- !is.na(hh2015t2_df$Species) & hh2015t2_df$Species == "Homo sapiens"
  if (sum(hum) != 1L || !"Cerebellum_O.n_SD" %in% colnames(hh2015t2_df))
    stop("3.4l: expected exactly one 'Homo sapiens' row with a Cerebellum_O.n_SD column ",
         "in HerculanoHouzel_etal_2015_Table2. The source table or its standardized ",
         "terms changed -- re-check this correction before applying it.", call. = FALSE)
  cb_o_sd <- suppressWarnings(as.numeric(hh2015t2_df$Cerebellum_O.n_SD[hum]))
  if (!isTRUE(all.equal(cb_o_sd, 2170000)))
    stop("3.4l: expected the printed Cerebellum_O.n_SD = 2170000 for Homo sapiens; ",
         "found ", cb_o_sd, ". The source table changed -- re-check this correction ",
         "before applying it.", call. = FALSE)
  hh2015t2_df$Cerebellum_O.n_SD[hum] <- 2170000000
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2015_Table2 <- hh2015t2_df
}
rm(hh2015t2_df)

# ================================================================================
# 3.4m DECISION D7 -- SEPARATELY REMOVABLE GUARD (2026-11 wiring).
#      Herculano-Houzel et al. 2015 Table 5: Blarina brevicauda whole-brain neurons.
#      Table 5 prints 55,190,000, but the paper's own structure tables (Tables 1-4)
#      sum to 51,646,000 and Sarko et al. 2009 -- the primary source for this
#      species, wired above -- corroborates the structure sum (51,646,400). The
#      HH 2015 internal checks diagnose the Table 5 value as the misprint. The
#      frozen build keeps the printed value; the structure sum is adopted here,
#      guarded on the printed value.
#      TO STRIKE D7: delete this whole block (from this banner to the matching
#      rm() below). Nothing else in the wiring depends on it.
# ================================================================================
hh2015t5_df <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2015_Table5
if (!is.null(hh2015t5_df)) {
  bla <- !is.na(hh2015t5_df$Species) & hh2015t5_df$Species == "Blarina brevicauda"
  if (sum(bla) != 1L || !"WholeBrain_N.n" %in% colnames(hh2015t5_df))
    stop("3.4m (D7): expected exactly one 'Blarina brevicauda' row with a WholeBrain_N.n ",
         "column in HerculanoHouzel_etal_2015_Table5. The source table or its ",
         "standardized terms changed -- re-check this correction before applying it.",
         call. = FALSE)
  bla_n <- suppressWarnings(as.numeric(hh2015t5_df$WholeBrain_N.n[bla]))
  if (!isTRUE(all.equal(bla_n, 55190000)))
    stop("3.4m (D7): expected the printed WholeBrain_N.n = 55190000 for Blarina ",
         "brevicauda; found ", bla_n, ". The source table changed -- re-check this ",
         "correction before applying it.", call. = FALSE)
  hh2015t5_df$WholeBrain_N.n[bla] <- 51646000
  cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2015_Table5 <- hh2015t5_df
}
rm(hh2015t5_df)
# ============================ end of D7 block ===================================

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
  for (i in seq_along(cell_counts_isotropic_fractionator_data_list)) {
    # Extract the dataframe
    df <- cell_counts_isotropic_fractionator_data_list[[i]]
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
        cell_counts_isotropic_fractionator_data_list[[i]] <- df
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
#     WholeBrain_N.p.mg had exactly ONE value in cell_counts_isotropic_fractionator_long (Avelino de Souza et al. 2025,
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
cell_counts_isotropic_fractionator_derivations <- list(
  c("I.n",    "I.p.C", "C.n",    "1",     "*"),
  c("N.p.mg", "N.n",   "Mass.g", "0.001", "/"),
  c("O.p.mg", "O.n",   "Mass.g", "0.001", "/"),
  c("I.p.mg", "I.n",   "Mass.g", "0.001", "/"),
  c("O.p.N",  "O.n",   "N.n",    "1",     "/"),
  c("I.p.C",  "I.n",   "C.n",    "1",     "/"),
  c("p.C.N",  "N.n",   "C.n",    "100",   "/")
)

for (i in seq_along(cell_counts_isotropic_fractionator_data_list)) {
  df <- cell_counts_isotropic_fractionator_data_list[[i]]
  prefixes <- unique(sub("_.*", "", colnames(df)))
  for (derivation in cell_counts_isotropic_fractionator_derivations) {
    for (prefix in prefixes) {
      df <- fill_derived(df, prefix,
                         target = derivation[1],
                         a      = derivation[2],
                         b      = derivation[3],
                         scale  = as.numeric(derivation[4]),
                         op     = derivation[5])
    }
  }
  cell_counts_isotropic_fractionator_data_list[[i]] <- df
}

## 4 Rename Species using the shared resolver (_keys/resolve_species.R; SPECIES_NAMING.md v1)
## The former live NCBI name2taxid()/taxid2name() lookup and the hand edits below it were migrated
## into the spoke keys (_keys/HerculanoHouzel/species_key.csv etc., basis/note per row) on
## 2026-09-28. cell_counts_isotropic_fractionator_source_species_ids.csv is left on disk as the pre-migration record and is
## no longer read or written here; the reviewable mapping now goes to cell_counts_isotropic_fractionator_species_resolution.csv.

# 4.1 Resolve every (item, printed name) pair through the spoke keys + hub -- offline, source-aware
source(file.path("..", "_keys/resolve_species.R"))
source_species_ids <- do.call(rbind, lapply(names(cell_counts_isotropic_fractionator_data_list), function(item) {
  printed <- sort(unique(cell_counts_isotropic_fractionator_data_list[[item]]$Species))
  r <- resolve_species(printed, source_publication = paper_folder_of_item(item, ".."))
  data.frame(Source_Species = item, source_publication = paper_folder_of_item(item, ".."),
             Species_Name_Source = printed, Species_Name = r$accepted_name,
             species_basis = r$species_basis, reidentified = r$reidentified,
             match_level = r$match_level, unresolved = r$unresolved, stringsAsFactors = FALSE)
}))
# Save the data frame as a CSV file (one row per item x printed name)
write.csv(source_species_ids, "cell_counts_isotropic_fractionator_species_resolution.csv", row.names = FALSE)
if (any(source_species_ids$unresolved))
  warning("cell_counts_isotropic_fractionator species resolution: ", sum(source_species_ids$unresolved),
          " (item, printed name) pair(s) matched no spoke row or hub name -> kept the printed name. ",
          "See cell_counts_isotropic_fractionator_species_resolution.csv.")

# 4.3 Duplicate "Species" in all dataframes in cell_counts_isotropic_fractionator_data_list and call it "Species_Source", so that "Species" can be edited
# Loop through each data frame in the list. Duplicate the "Species" column and rename it to "Species_Source"
for (i in seq_along(cell_counts_isotropic_fractionator_data_list)) {
  cell_counts_isotropic_fractionator_data_list[[i]]$Species_Source <- cell_counts_isotropic_fractionator_data_list[[i]]$Species
}

# Loop through each data frame in the list and update the "Species" column from the item's own resolution rows
for (i in seq_along(cell_counts_isotropic_fractionator_data_list)) {
  m <- source_species_ids[source_species_ids$Source_Species == names(cell_counts_isotropic_fractionator_data_list)[i], ]
  cell_counts_isotropic_fractionator_data_list[[i]]$Species <- m$Species_Name[match(cell_counts_isotropic_fractionator_data_list[[i]]$Species_Source, m$Species_Name_Source)]
}

# 4.4 Save a long unfiltered list for conflict check
cell_counts_isotropic_fractionator_unfiltered <- lapply(names(cell_counts_isotropic_fractionator_data_list), function(source) {
  df_uf <- cell_counts_isotropic_fractionator_data_list[[source]]
  # Convert all columns to character strings
  df_uf[] <- lapply(df_uf, as.character)
  # Combine "Species," "Variable," "Source," and "Value" columns
  df_long <- df_uf %>%
    pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
    mutate(Source = source) %>%
    select(Species, Variable, Source, Value)
  return(df_long)
})
cell_counts_isotropic_fractionator_unfiltered <- bind_rows(cell_counts_isotropic_fractionator_unfiltered)
write.csv(cell_counts_isotropic_fractionator_unfiltered, file = "cell_counts_isotropic_fractionator_unfiltered.csv", row.names = FALSE)

## 5 Filter: Remove flagged data in cell_counts_isotropic_fractionator_data_list

# Create a copy of cell_counts_isotropic_fractionator_data_list to filter
filtered_cell_counts_isotropic_fractionator_data_list <- lapply(cell_counts_isotropic_fractionator_data_list, data.frame)
## 5.1 Flag problematic data for removal

# Initialize metadata_flags for each dataframe with names from filtered_cell_counts_isotropic_fractionator_data_list
metadata_flags <- list()
for (df_name in names(filtered_cell_counts_isotropic_fractionator_data_list)) {
  metadata_flags[[df_name]] <- data.frame(
    Flag_Description = c(NA),
    Flag_Condition = c(NA),
    Flag_Condition_Type = c(NA)
  )
}
## Delete flagged data
# Loop through every dataframe in filtered_cell_counts_isotropic_fractionator_data_list
for (df_name in names(filtered_cell_counts_isotropic_fractionator_data_list)) {
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
      subset_condition <- eval(parse(text = condition), envir = filtered_cell_counts_isotropic_fractionator_data_list[[df_name]])
      # Determine if columns, rows or values should be excluded based on Flag_Condition_Type
      if (length(subset_condition) > 0) {
        if (Flag_Condition_Type == "column") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching columns
              filtered_cell_counts_isotropic_fractionator_data_list[[df_name]] <- filtered_cell_counts_isotropic_fractionator_data_list[[df_name]][, !subset_condition]
            } else {}
          } else {}
        } else if (Flag_Condition_Type == "row") {
          if (is.logical(subset_condition)) {
            if (any(subset_condition)) {
              # Exclude matching rows
              filtered_cell_counts_isotropic_fractionator_data_list[[df_name]] <- filtered_cell_counts_isotropic_fractionator_data_list[[df_name]][!subset_condition, ]
            } else {}
          } else {}
        } else if (Flag_Condition_Type == "value") {
          if (any(subset_condition)) {
            # Make matching values NA to exclude them
            indices <- filtered_cell_counts_isotropic_fractionator_data_list[[df_name]] == subset_condition
            filtered_cell_counts_isotropic_fractionator_data_list[[df_name]][indices] <- NA
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
  df <- filtered_cell_counts_isotropic_fractionator_data_list[[item_name[i]]]
  # Extract column names (variables) from the current data frame
  variables_in_df <- colnames(df)
  # Combine unique column names with the existing vector
  filtered_all_variables <- unique(c(filtered_all_variables, variables_in_df))
}
# Sort the column names alphabetically and view
filtered_all_variables <- sort(filtered_all_variables)
filtered_all_variables

# Move specific variables from the main dataset, filtered_cell_counts_isotropic_fractionator_data_list, to the list annexed_metadata.
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
annexed_metadata <- setNames(vector("list", length(filtered_cell_counts_isotropic_fractionator_data_list)), names(filtered_cell_counts_isotropic_fractionator_data_list))
# Initialize variables_to_move as an empty vector
variables_to_move <- character(0)
# Iterate through the dataframes
for (i in seq_along(filtered_cell_counts_isotropic_fractionator_data_list)) {
  # Update variables_to_move including variables ending in "_Source" for each dataframe
  variables_to_move <- c("Body_Mass.kg", "Family", "Order", "Clade", "CommonName", "Micro.or.mega", "SampleInfo",
                         grep("_Source$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE), 
                         grep("_S.n$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_SD$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_n$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         # Cellular ratios kept in the merge (see the note above), NOT annexed:
                         #   "_N.p.mg", "_O.p.mg", "_I.p.mg", "_O.p.N", "_I.p.C", "_p.C.N"
                         grep("_p.C.Brain", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE))

  # Check if any of the variables to move are present in the dataframe
  present_variables <- intersect(variables_to_move, names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]))
  if (length(present_variables) > 0) {
    # Create a new dataframe with only the specified variables
    annexed_data <- filtered_cell_counts_isotropic_fractionator_data_list[[i]][, present_variables, drop = FALSE]
    # Remove the specified variables from the original dataframe
    filtered_cell_counts_isotropic_fractionator_data_list[[i]] <- filtered_cell_counts_isotropic_fractionator_data_list[[i]][, !(names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]) %in% present_variables), drop = FALSE]
    # Add the new dataframe to annexed_metadata list
    annexed_metadata[[names(filtered_cell_counts_isotropic_fractionator_data_list)[i]]] <- annexed_data
  } else {
    # Skip if none of the variables are present in the dataframe
  }
}

## 7 Filter: Consider averaging variables if samples differ between teams ## Check for variables measured by more than one team

## Check for variables found in dataframes both from Kverkova team and Herculano-Houzel team, which are different teams

# Create a full dataframe to inspect Kverkova Team variables
Kverkova_etal_2018_variables <- data.frame(Dataframe_Name = character(), Variable_Name = character(), stringsAsFactors = FALSE)
# Loop through each dataframe in the list
for (i in seq_along(filtered_cell_counts_isotropic_fractionator_data_list)) {
  df_name <- names(filtered_cell_counts_isotropic_fractionator_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cell_counts_isotropic_fractionator_data_list[[i]]  # Get the dataframe itself
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
for (i in seq_along(filtered_cell_counts_isotropic_fractionator_data_list)) {
  df_name <- names(filtered_cell_counts_isotropic_fractionator_data_list)[i]  # Get the name of the dataframe
  df <- filtered_cell_counts_isotropic_fractionator_data_list[[i]]  # Get the dataframe itself
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

# Create a new list of dataframes from the list of dataframes filtered_cell_counts_isotropic_fractionator_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(Kverkova_Team_dataframes)) {
  # Use match to find the dataframe in filtered_cell_counts_isotropic_fractionator_data_list with the same name as  i in seq_along(Kverkova_Team_dataframes
  Kverkova_Team_dfmatch <- filtered_cell_counts_isotropic_fractionator_data_list[[i]][, names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]) %in% Kverkova_Team_dataframes]
  # Store the data frame in the list with the corresponding name
  Kverkova_Team_df_list[[Kverkova_Team_dataframes[i]]] <- Kverkova_Team_dfmatch
}

# Create a new list of dataframes from the list of dataframes filtered_cell_counts_isotropic_fractionator_data_list with only Kverkova_Team dataframes
# Initialize an empty list to store matching dataframes
Kverkova_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cell_counts_isotropic_fractionator_data_list)) {
  # Check if the name of the dataframe is in Kverkova_Team_dataframes
  if (names(filtered_cell_counts_isotropic_fractionator_data_list)[i] %in% Kverkova_Team_dataframes) {
    # Assign the entire dataframe to Kverkova_Team_dfmatch
    Kverkova_Team_dfmatch <- filtered_cell_counts_isotropic_fractionator_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    Kverkova_Team_df_list[[names(filtered_cell_counts_isotropic_fractionator_data_list)[i]]] <- Kverkova_Team_dfmatch
  }
}

# Create a new list of dataframes from the list of dataframes filtered_cell_counts_isotropic_fractionator_data_list with only HerculanoHouzel_Team dataframes
# Initialize an empty list to store matching dataframes
HerculanoHouzel_Team_df_list <- list()
# Loop through and store as dataframes in the list
for (i in seq_along(filtered_cell_counts_isotropic_fractionator_data_list)) {
  # Check if the name of the dataframe is in HerculanoHouzel_Team_dataframes
  if (names(filtered_cell_counts_isotropic_fractionator_data_list)[i] %in% HerculanoHouzel_Team_dataframes) {
    # Assign the entire dataframe to HerculanoHouzel_Team_dfmatch
    HerculanoHouzel_Team_dfmatch <- filtered_cell_counts_isotropic_fractionator_data_list[[i]]
    # Store the data frame in the list with the corresponding name
    HerculanoHouzel_Team_df_list[[names(filtered_cell_counts_isotropic_fractionator_data_list)[i]]] <- HerculanoHouzel_Team_dfmatch
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
# HH2011 precedence pin (2026-11): Herculano-Houzel et al. 2011 Table 1 is the PRIMARY publication
# of the Glires cell counts that Herculano-Houzel et al. 2015 re-reported in its Tables 1-5 -- the
# 2015 tables' own Source columns cite the 2011 paper for Heterocephalus glaber, Proechimys
# cayennensis, Cynomys sp., Sciurus carolinensis and Oryctolagus cuniculus, and Herculano-Houzel
# et al. 2006 for the other six species (averages recalculated in the 2011 paper; no 2006 dataset
# exists in Evo-M1). Under the project's compilation rule the primary source outranks the
# compilation for shared cells, so the 2011 item is pinned directly above the 2015 tables in this
# worth order, overriding the date rule for this pair only; the 2015 tables remain the fallback
# wherever the 2011 table lacks a cell (sec 8.3 keeps the best-priority non-NA value per cell).
# This pin is what corrects the rabbit Cerebellum_O.p.N: HH 2015 Table 2 prints 1.222 (its own
# olfactory-bulb ratio, duplicated in its cerebellum row), while the 2011 table prints no ratio
# and its counts derive 0.314 in sec 3.7.
# One scoped exception to the pin follows the priority match below: the olfactory-bulb carve-out.
if ("HerculanoHouzel_etal_2011_Table1" %in% worth_dataframe$source) {
  hh2015_tables <- paste0("HerculanoHouzel_etal_2015_Table", 1:5)
  if (!all(hh2015_tables %in% worth_dataframe$source))
    stop("8.2.H pin: expected all five HerculanoHouzel_etal_2015 tables in the HH-team worth ",
         "table. The item list changed -- re-check the HH2011 precedence pin.", call. = FALSE)
  pin_row <- worth_dataframe[worth_dataframe$source == "HerculanoHouzel_etal_2011_Table1", , drop = FALSE]
  worth_dataframe <- worth_dataframe[worth_dataframe$source != "HerculanoHouzel_etal_2011_Table1", , drop = FALSE]
  insert_at <- min(which(worth_dataframe$source %in% hh2015_tables))
  worth_dataframe <- rbind(worth_dataframe[seq_len(insert_at - 1), , drop = FALSE],
                           pin_row,
                           worth_dataframe[insert_at:nrow(worth_dataframe), , drop = FALSE])
  rownames(worth_dataframe) <- NULL
  worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
}

# HH2014 / Sarko2009 precedence pin (2026-11): Herculano-Houzel et al. 2014 (the elephant
# paper) and Sarko et al. 2009 (the insectivore paper) are the PRIMARY publications of the
# cell counts that Herculano-Houzel et al. 2015 re-reported in its Tables 1-5 -- the 2015
# tables' own Source columns cite them. Under the project's compilation rule the primary
# source outranks the compilation for shared cells, so the three primary items are pinned
# directly above the 2015 tables in this worth order (HH2014 first, then the two Sarko
# tables), overriding the date rule for these pairs only; the 2015 tables remain the
# fallback wherever a primary lacks a cell (sec 8.3 keeps the best-priority non-NA value
# per cell). This pin is what corrects the elephant CerebralCortex_O.n: HH 2015 Table 1
# prints 55,698,998,687 (the 2014 paper's grey-matter-only value) where the 2014 GM+WM
# value is 150.15 x 10^9, as the 2015 table's own O/N (26.844) and O/mg (52,721) confirm.
pin_items <- c("HerculanoHouzel_etal_2014_Table1",
               "Sarko_etal_2009_Table1",
               "Sarko_etal_2009_Table2")
pin_items <- pin_items[pin_items %in% worth_dataframe$source]
if (length(pin_items)) {
  hh2015_tables <- paste0("HerculanoHouzel_etal_2015_Table", 1:5)
  if (!all(hh2015_tables %in% worth_dataframe$source))
    stop("8.2.H pin: expected all five HerculanoHouzel_etal_2015 tables in the HH-team worth ",
         "table. The item list changed -- re-check the HH2014/Sarko2009 precedence pin.",
         call. = FALSE)
  pin_rows <- worth_dataframe[match(pin_items, worth_dataframe$source), , drop = FALSE]
  worth_dataframe <- worth_dataframe[!(worth_dataframe$source %in% pin_items), , drop = FALSE]
  insert_at <- min(which(worth_dataframe$source %in% hh2015_tables))
  worth_dataframe <- rbind(worth_dataframe[seq_len(insert_at - 1), , drop = FALSE],
                           pin_rows,
                           worth_dataframe[insert_at:nrow(worth_dataframe), , drop = FALSE])
  rownames(worth_dataframe) <- NULL
  worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
}

# HH2015-primaries precedence pin (2026-11): the six primary sources Herculano-Houzel
# et al. 2015 re-reported from, wired as items in this round -- Herculano-Houzel et al.
# 2006 (rodents), Azevedo et al. 2009 (human), Gabi et al. 2010 (primates), Neves et al.
# 2014 (afrotherians), Ribeiro et al. 2014 (olfactory bulb) and Herculano-Houzel & Kaas
# 2011 Table 2 (ape cerebellar totals). Under the compilation rule each takes
# precedence over the 2015 tables for the cells it measures, so the block is inserted
# directly above the 2015 tables -- and also above HerculanoHouzel_etal_2011_Table1,
# for two cell groups: HH 2006's printed DIRECT whole-brain totals take the WholeBrain
# rows of its six rodent species over the 2011 structure sums (decision D1), and
# Ribeiro 2014's rat and squirrel bulb rows (larger samples than 2011; the values
# HH 2015 Table 4 already carries under other citations) take the bulb rows over both
# the 2011 table and the 2015 table (decision D5). The block sits below the HH2014 /
# Sarko pin: those items share no species with the six, so the relative order cannot
# matter. Within the block, Neves precedes Ribeiro so Neves keeps precedence for the
# afrotherian bulb cells the two share (decision D5); after the sec 1.6 scope
# restrictions the six otherwise share no species x variable cells with each other.
pin_items <- c("HerculanoHouzel_etal_2006_Table1",
               "Azevedo_etal_2009_Table1",
               "Gabi_etal_2010_Table1",
               "Neves_etal_2014_Table1",
               "Ribeiro_etal_2014_Table1",
               "HerculanoHouzel_Kaas_2011_Table2")
pin_items <- pin_items[pin_items %in% worth_dataframe$source]
if (length(pin_items)) {
  hh2015_tables <- paste0("HerculanoHouzel_etal_2015_Table", 1:5)
  if (!all(hh2015_tables %in% worth_dataframe$source) ||
      !"HerculanoHouzel_etal_2011_Table1" %in% worth_dataframe$source)
    stop("8.2.H pin: expected all five HerculanoHouzel_etal_2015 tables and ",
         "HerculanoHouzel_etal_2011_Table1 in the HH-team worth table. The item list ",
         "changed -- re-check the HH2015-primaries precedence pin.", call. = FALSE)
  pin_rows <- worth_dataframe[match(pin_items, worth_dataframe$source), , drop = FALSE]
  worth_dataframe <- worth_dataframe[!(worth_dataframe$source %in% pin_items), , drop = FALSE]
  insert_at <- min(which(worth_dataframe$source %in%
                           c("HerculanoHouzel_etal_2011_Table1", hh2015_tables)))
  worth_dataframe <- rbind(worth_dataframe[seq_len(insert_at - 1), , drop = FALSE],
                           pin_rows,
                           worth_dataframe[insert_at:nrow(worth_dataframe), , drop = FALSE])
  rownames(worth_dataframe) <- NULL
  worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
}

# Append a "priority" column to the "combined_data" dataframe by matching "Source" values with "source" in "worth_dataframe"
combined_data$priority <- match(combined_data$Source,  worth_dataframe$source, worth_dataframe$priority)

# HH2011 olfactory-bulb carve-out (2026-11, curator decision): the pin above makes the 2011
# primary outrank the 2015 compilation for every shared cell, but HH 2015 Table 4 (olfactory
# bulb) is NOT a pure re-carriage of the 2011 bulb data. Its per-species bulb n differs from the
# 2011 study for three species -- rat 5 vs 4, spiny rat 1 vs 2, grey squirrel 9 vs 3 -- while
# every other structure's n matches 2011 exactly, so the 2015 bulb means for rat and squirrel
# rest on LARGER samples than the 2011 paper published (the team's fuller bulb dataset, still
# cited to "Herculano-Houzel et al., 2011" in Table 4's own Source column). Decision: for
# olfactory-bulb cells only, the larger sample wins. Where Table 4's printed bulb n exceeds the
# 2011 paper's printed n for a species, the 2011 rows for that species' OlfactoryBulb_ variables
# are demoted here to half a priority step below Table 4, so sec 8.3 keeps the 2015 bulb values;
# where the 2011 n is equal or larger (spiny rat, and every other shared species), the pin
# stands and the primary wins as before. Demotion by half a step (not removal) keeps the 2011
# value as the fallback wherever Table 4 lacks a cell. WholeBrainOlfactoryBulb_ variables are
# whole-brain values, not bulb cells, and are NOT carved out.
# The species set is COMPUTED from the two tables' printed n values -- Table 4's bulb-specific
# "OlfactoryBulb_n" against the 2011 table's "Sample_n" (the 2011 paper prints one n per
# species; the same animals supplied every structure) -- read from
# cell_counts_isotropic_fractionator_data_list, whose columns sec 6 annexed out of the filtered
# dataframes the worth order is built from. The guards stop the merge if the printed n values
# are not exactly the ones this exception was written for.
if ("HerculanoHouzel_etal_2011_Table1" %in% worth_dataframe$source) {
  bulb_t4 <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2015_Table4
  bulb_11 <- cell_counts_isotropic_fractionator_data_list$HerculanoHouzel_etal_2011_Table1
  if (is.null(bulb_t4) || is.null(bulb_11) ||
      !("OlfactoryBulb_n" %in% colnames(bulb_t4)) || !("Sample_n" %in% colnames(bulb_11)) ||
      !("OlfactoryBulb_N.n" %in% colnames(bulb_11)))
    stop("8.2.H bulb carve-out: expected OlfactoryBulb_n in HerculanoHouzel_etal_2015_Table4 ",
         "and Sample_n + OlfactoryBulb_N.n in HerculanoHouzel_etal_2011_Table1. The source ",
         "tables or their standardized terms changed -- re-check this exception before ",
         "applying it.", call. = FALSE)
  n_t4 <- setNames(suppressWarnings(as.numeric(bulb_t4$OlfactoryBulb_n)), bulb_t4$Species)
  n_11 <- setNames(suppressWarnings(as.numeric(bulb_11$Sample_n)), bulb_11$Species)
  bulb_measured_11 <- bulb_11$Species[!is.na(suppressWarnings(as.numeric(bulb_11$OlfactoryBulb_N.n)))]
  shared_bulb_species <- intersect(intersect(names(n_t4)[!is.na(n_t4)], names(n_11)[!is.na(n_11)]),
                                   bulb_measured_11)
  n_diff_bulb <- n_t4[shared_bulb_species] - n_11[shared_bulb_species]
  expected_n_diff_bulb <- c("Rattus norvegicus" = 1, "Proechimys guyannensis" = -1,
                            "Sciurus carolinensis" = 6)
  if (length(shared_bulb_species) != 10L ||
      !isTRUE(all.equal(n_diff_bulb[names(expected_n_diff_bulb)], expected_n_diff_bulb,
                        check.attributes = FALSE)) ||
      any(n_diff_bulb[!(names(n_diff_bulb) %in% names(expected_n_diff_bulb))] != 0))
    stop("8.2.H bulb carve-out: expected the printed bulb n of the two tables to differ only ",
         "for Rattus norvegicus (5 vs 4), Proechimys guyannensis (1 vs 2) and Sciurus ",
         "carolinensis (9 vs 3), with equal n for the other seven shared bulb species; found ",
         "differences (2015 minus 2011) of ",
         paste0(names(n_diff_bulb), " ", n_diff_bulb, collapse = ", "),
         ". The source tables changed -- re-check this exception before applying it.",
         call. = FALSE)
  carve_out_species <- names(n_diff_bulb)[n_diff_bulb > 0]
  if (!setequal(carve_out_species, c("Rattus norvegicus", "Sciurus carolinensis")))
    stop("8.2.H bulb carve-out: expected the larger-2015-sample species to be exactly Rattus ",
         "norvegicus and Sciurus carolinensis; computed ",
         paste(carve_out_species, collapse = ", "), ". Re-check this exception before ",
         "applying it.", call. = FALSE)
  t4_priority <- worth_dataframe$priority[worth_dataframe$source == "HerculanoHouzel_etal_2015_Table4"]
  carve_out_rows <- combined_data$Source == "HerculanoHouzel_etal_2011_Table1" &
                    combined_data$Species %in% carve_out_species &
                    startsWith(combined_data$Variable, "OlfactoryBulb_")
  if (!any(carve_out_rows))
    stop("8.2.H bulb carve-out: no HerculanoHouzel_etal_2011_Table1 olfactory-bulb rows found ",
         "for the carve-out species in combined_data. The melt changed -- re-check this ",
         "exception before applying it.", call. = FALSE)
  combined_data$priority[carve_out_rows] <- t4_priority + 0.5
  rm(bulb_t4, bulb_11, n_t4, n_11, bulb_measured_11, shared_bulb_species, n_diff_bulb,
     expected_n_diff_bulb, carve_out_species, t4_priority, carve_out_rows)
}

# Dos Santos 2020 demotion (2026-11, curator decision): compilation rule for re-reported measures.
# Dos Santos et al. 2020 Table 1 is dated 2020, so the date rule above ranks it over every
# earlier Herculano-Houzel-team table. But its footnote a (p. 4627) states that structure mass,
# C, N and N/mg "list the values published previously" (Ribeiro et al. 2013; Herculano-Houzel et
# al. 2014; Kazu et al. 2014; Neves et al. 2014; Gabi et al. 2016; Dos Santos et al. 2017;
# Jardim-Messeder et al. 2017): for those measures it is a compilation, and under the project's
# compilation rule the primary source outranks the compilation for shared cells (the same rule
# as the HH2011 pin above). The re-reports are not always the primary's value either. Computed by
# checks/DosSantos_2020_rereported_vs_primaries.R (output beside it): of the 433 mass, C, N and
# N/mg cells Table 1 shares with a primary table (after the sec 3.4e corrections), 375 agree
# within 0.1%, 25 differ by 0.1-2% and 33 by more than 2% (23 by more than 10%). Of the 33, 28
# are cerebral cortex and 5 whole brain: 22 belong to six primates, 8 to Elephantulus myurus
# (whose Table 1 rows mix a single specimen with the species average), 2 to Loxodonta africana
# and 1 to Sus scrofa domesticus -- e.g. Homo sapiens cortex mass 696.708 g in Table 1 against
# 1,232.93 g in Herculano-Houzel et al. 2015 Table 1. Letting Table 1 win by date would have
# replaced those primary values with figures on a different sample basis.
# So every Table 1 row that is NOT one of its own microglia measures is demoted below all other
# Herculano-Houzel-team sources: _Mass.g, _C.n, _N.n, _N.p.mg, and _p.C.N (derived in sec 3.7
# from the re-reported N and C). Demotion, not removal: sec 8.3 keeps the best-priority non-NA
# value per cell, so Table 1 still supplies these measures wherever no primary table has the
# cell (cortex without hippocampus, pons + medulla, several hippocampi).
# Its microglia measures keep their date priority and have no competitor: _I.p.mg and _I.p.N
# (measured), _I.n (printed) and _I.p.C (derived in sec 3.7 from Table 1's own I and C).
# The guard stops the merge if Table 1 carries a measure this rule was not written for.
if ("DosSantos_etal_2020_Table1" %in% worth_dataframe$source) {
  dossantos_rows <- combined_data$Source == "DosSantos_etal_2020_Table1"
  dossantos_measure <- sub("^[^_]*_", "", combined_data$Variable[dossantos_rows])
  own_measures      <- c("I.n", "I.p.mg", "I.p.N", "I.p.C")
  rereported_measures <- c("Mass.g", "C.n", "N.n", "N.p.mg", "p.C.N")
  unexpected <- setdiff(unique(dossantos_measure), c(own_measures, rereported_measures))
  if (length(unexpected) || !all(c(own_measures, rereported_measures) %in% dossantos_measure))
    stop("8.2.H Dos Santos 2020 demotion: expected DosSantos_etal_2020_Table1 to carry exactly the ",
         "measures ", paste(c(own_measures, rereported_measures), collapse = ", "), "; found ",
         paste(sort(unique(dossantos_measure)), collapse = ", "), ". The source table, its ",
         "standardized terms or the sec 3.7 derivations changed -- re-check this rule before ",
         "applying it.", call. = FALSE)
  combined_data$priority[dossantos_rows][dossantos_measure %in% rereported_measures] <-
    max(worth_dataframe$priority) + 1
  rm(dossantos_rows, dossantos_measure, own_measures, rereported_measures, unexpected)
}

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
                                                     cell_counts_isotropic_fractionator_derivations)
Kverkova_Team_data_long        <- derive_within_team(Kverkova_Team_data_long,
                                                     cell_counts_isotropic_fractionator_derivations)

#### 9.2 Calculate: between-team averages using filtered dataset
## Finalize dataset
# Stack the dataframes lengthwise
stacked_long_dataframe <- rbind(HerculanoHouzel_Team_data_long, Kverkova_Team_data_long)
# remove any NA values in stacked_long_dataframe
stacked_long_dataframe <- stacked_long_dataframe[!is.na(stacked_long_dataframe$Value), , drop = FALSE]
# make Values numeric in stacked_long_dataframe
stacked_long_dataframe$Value <- as.numeric(stacked_long_dataframe$Value)

# Calculate averages and create the new long dataframe
cell_counts_isotropic_fractionator_long <- stacked_long_dataframe %>%
  group_by(Species, Variable) %>%
  summarize(Value = mean(Value),
            Source = paste0(unique(Source), collapse = "_"))
## Species naming columns (SPECIES_NAMING.md v1): cell_counts_isotropic_fractionator_long is one row per species x variable
## with sources collapsed, so species_printed / species_basis list every distinct printed name / basis
## that resolved to this Species across the items (from source_species_ids, step 4.1);
## accepted_name == Species; reidentified = any of those rows was a reident.
sp_cols <- species_columns_summary(
  transform(source_species_ids, species_printed = Species_Name_Source, accepted_name = Species_Name,
            Species = Species_Name), "Species")
cell_counts_isotropic_fractionator_long <- cell_counts_isotropic_fractionator_long %>%
  left_join(sp_cols %>% select(Species, species_printed, species_basis, reidentified), by = "Species") %>%
  mutate(accepted_name = Species) %>%
  relocate(species_printed, accepted_name, species_basis, reidentified, .after = Source)
write_csv(cell_counts_isotropic_fractionator_long, "cell_counts_isotropic_fractionator_long.csv")

# Convert to wide dataframe
cell_counts_isotropic_fractionator_wide <- arrange(pivot_wider(cell_counts_isotropic_fractionator_long, id_cols = Species, names_from = Variable, values_from = Value), Species)
# # keep a record of sources for the datapoints
# cell_counts_isotropic_fractionator_sources_wide <- arrange(pivot_wider(cell_counts_isotropic_fractionator_long, id_cols = Species, names_from = Variable, values_from = Source), Species)
write_csv(cell_counts_isotropic_fractionator_wide, "cell_counts_isotropic_fractionator_wide.csv")

# Validate the draft ontology pilot against current rule tables and merge outputs.
# This writes a QA alignment report; draft decisions do not alter selected values.
pilot_status <- system2("python3", file.path("..", "_checks", "check_ontology_pilot.py"))
if (pilot_status != 0L) stop("Ontology pilot QA failed", call. = FALSE)
