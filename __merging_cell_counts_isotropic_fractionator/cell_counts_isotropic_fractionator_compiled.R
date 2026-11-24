# Set Working Directory
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_cell_counts_isotropic_fractionator")

## 1 Get data for cell count analyses  (1.5-1.11 reshape long-format and per-area source tables; 1.6b the not-served register)
##   Hemispheres: laterality_known.csv (guard in sec 2), doubling in sec 3.5, flags file in sec 9.3
## 2 Change to standardized terminology for all variables in those dataframes
## 3 Calculate variables to match them across datasets before filtering
## 4 Rename Species via the shared resolver (_keys/resolve_species.R)
## 5 Filter: Remove flagged data in cell_counts_isotropic_fractionator_data_list
## 6 Filter: Annex to Metadata any contingent variables
## 7 Filter: Consider averaging variables if samples differ between teams  ## Check for variables measured by more than one team
## 8 Filter: Melt dataframe and address conflicting datapoints across datasets using priority  ## Within each team ## And across team averaging
## 9.1 Calculate: within-team between-tables values using filtered dataset
## 9.2 Calculate: between-team averages using filtered dataset
## 9.3 Hemisphere provenance: write cell_counts_isotropic_fractionator_flags.csv

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
  "HerculanoHouzel_etal_2007_Table1",   # PRIMARY source (primate brains, whole brain only) for
                                       #   the rows HH 2015 cites to it in 245 cells: pinned
                                       #   above the 2015 tables in sec 8.2.H, so its printed
                                       #   DIRECT whole-brain totals take the WholeBrain rows
                                       #   for Tupaia glis and the six primate species (the
                                       #   HH 2006 / D1 precedent). The structure-level values
                                       #   behind most 2015 citations are in the paper's SI
                                       #   Table 2 (online only, not built); the 2015 tables
                                       #   keep every structure row. Rebuilt to standard
                                       #   2026-11-23 from the PMC full text (PMC1805542),
                                       #   superseding the 2026-10-21 eye-read build.
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
  "Kverkova_etal_2018_TableS5",
  "Seelke_etal_2014_Table3",            # LIVE 2026-11-23 (owner decision of that day; see
  "Seelke_etal_2014_Table4",            #   WIRING_into_cell_counts_isotropic_fractionator.md).
  "Seelke_etal_2014_Table5",            #   Seelke, Dooley & Krubitzer 2014: Monodelphis domestica,
                                        #   isotropic fractionator (flow cytometry), group means of
                                        #   5 animals. The FIRST PER-AREA items of this merge and a
                                        #   NEW TEAM ("Krubitzer", sec 7-8). What comes in:
                                        #   - Table 3 weights -> _Mass.g; Table 4 cells, neurons,
                                        #     non-neurons, % neurons -> _C.n, _N.n, _O.n, _p.C.N;
                                        #     Table 5 cells, neurons, non-neurons per g -> _C.p.mg
                                        #     (new code), _N.p.mg, _O.p.mg;
                                        #   - four structures: Neocortex (the "Whole neocortex"
                                        #     row), V1, S1, A1. Sec 1.7 reshapes the three
                                        #     long-by-area TSVs. Not served, each with a registered
                                        #     status in not_served.csv: the "Sigma neocortex" row
                                        #     (a second measurement of the neocortex), "Rem Ctx"
                                        #     (not a structure of the database) and Table 3's
                                        #     % of Sigma-neocortex weight (no measure code);
                                        #   - units converted in sec 3.4n (millions -> counts;
                                        #     millions per g -> per mg);
                                        #   - HEMISPHERE: every weight and count was measured in
                                        #     ONE hemisphere. Under the merge's hemisphere rule
                                        #     (laterality_known.csv; sec 2 guard, sec 3.5) each is
                                        #     served twice: as measured under <Structure>_unilateral_
                                        #     and as 2x under the plain label, the both-hemisphere
                                        #     estimate, marked in
                                        #     cell_counts_isotropic_fractionator_flags.csv (sec 9.3).
                                        #     Densities, % neurons and ratios are never doubled;
                                        #   - the printed +/- is not labelled SD or SEM in the
                                        #     tables; it is carried as "_pm" and annexed in sec 6.

  "HerculanoHouzel_etal_2013_Table1-a", # LIVE 2026-11-24 (owner, 2026-11-23: the per-area decision
                                        #   also covers the queued Herculano-Houzel 2013 and Kaas-lab
                                        #   sources). Mouse, 18 cortical areas, neurons and other
                                        #   cells of ONE hemisphere -> hemisphere rule. Reshaped in
                                        #   sec 1.8. Herculano-Houzel team (sec 8.H). Table 1-b (the
                                        #   7 functional groups) and Figure2TopLeft repeat Table 1-a
                                        #   and are NOT listed. Neurons per mm2 and per mm3
                                        #   (atlas denominators) served since 2026-11-24 (step 7b).
  "Young_etal_2013_a_Table1",           # LIVE 2026-11-24. Young, Collins & Kaas 2013: M1 of six
                                        #   primate species, mass and cell/neuron densities per g
                                        #   and per mm2. The two baboon cases (09-27, 11-31) are
                                        #   served as ONE row, their mean (owner, 2026-11-24;
                                        #   sec 1.9); units in sec 3.4p. NEW TEAM "Kaas" (sec 7-8).
  "Collins_etal_2016_Table1",           # LIVE 2026-11-24. Collins et al. 2016: one chimpanzee, right
                                        #   hemisphere. Neocortex, V1, V2 and M1 (sec 1.10). M1 is
                                        #   the same animal as Young's chimpanzee: the specimen
                                        #   rule (sec 6b) counts each shared measure once. Team Kaas.
  "Collins_etal_2010_DatasetS1"         # LIVE 2026-11-24 (step 7b; owner: "wire it as I said").
                                        #   Collins et al. 2010 Dataset S1: 244 tissue pieces of one
                                        #   cortical hemisphere from five primates. Served: the named
                                        #   areas of galago 08-07 and owl monkey 07-78, and the whole
                                        #   neocortex of a case as the SUM of its pieces where that
                                        #   sum agrees with the paper's text (sec 1.11). Animals
                                        #   shared with Young 2013: specimen rule (sec 6b). Team Kaas.

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
  # HerculanoHouzel_etal_2013_Table1-a went live on 2026-11-24 (listed above; reshape in sec 1.8).
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

## 1.6b Rows and columns that are not served: not_served.csv
##     (2026-11-24, step 7b. Owner: "i do not really understand the concept of hold. We should
##     register ...".) Nothing is "held". Every row and every column of the per-area tables wired
##     since 2026-11-23 that does not reach this merge is REGISTERED in not_served.csv
##     (Reference, kind = row | column, name, status, same_as, reason), with one status from the
##     short vocabulary below and a plain reason. README__merging.md "What is not served, and
##     why" defines each status.
##     The reshapes of sec 1.7-1.11 report here what they leave out, and the merge STOPS if that
##     differs from the register: a row or column cannot be dropped without a registered reason,
##     and a registered row cannot be served by accident. (Values that the specimen rule of
##     sec 6b finds to be the same data as a served value are not listed by hand: that step
##     writes them to cell_counts_isotropic_fractionator_same_data.csv on every run.)
not_served_statuses <- c("same_data", "derived_from_registered", "second_measurement",
                         "no_measure_code", "not_a_database_structure", "other_merge",
                         "excluded", "disagrees_with_text", "descriptive")
if (!file.exists("not_served.csv"))
  stop("1.6b: not_served.csv not found in ", getwd(), call. = FALSE)
not_served <- read.csv("not_served.csv", stringsAsFactors = FALSE, check.names = FALSE)
if (!identical(colnames(not_served), c("Reference", "kind", "name", "status", "same_as", "reason")))
  stop("not_served.csv must have exactly the columns Reference, kind, name, status, same_as, reason",
       call. = FALSE)
not_served$same_as[is.na(not_served$same_as)] <- ""
if (length(setdiff(unique(not_served$kind), c("row", "column"))) ||
    length(setdiff(unique(not_served$status), not_served_statuses)) ||
    any(is.na(not_served$reason) | !nzchar(not_served$reason)) ||
    any(not_served$status %in% c("same_data", "other_merge") & !nzchar(not_served$same_as)) ||
    anyDuplicated(not_served[, c("Reference", "kind", "name")]))
  stop("not_served.csv: every row needs kind = row or column, a status from {",
       paste(not_served_statuses, collapse = ", "), "}, a reason, a same_as for same_data and ",
       "other_merge, and a unique Reference + kind + name", call. = FALSE)
not_served_checked <- character(0)
check_not_served <- function(item, rows = character(0), columns = character(0)) {
  registered <- not_served[not_served$Reference == item, , drop = FALSE]
  for (kind in c("row", "column")) {
    left_out <- if (kind == "row") rows else columns
    in_register <- registered$name[registered$kind == kind]
    if (!setequal(left_out, in_register))
      stop("1.6b: ", item, ": the ", kind, "s this merge leaves out and the ", kind, "s registered in ",
           "not_served.csv differ. Left out but not registered: ",
           paste(setdiff(left_out, in_register), collapse = " | "), ". Registered but not left out: ",
           paste(setdiff(in_register, left_out), collapse = " | "),
           ". Register a status and reason for each, or serve it.", call. = FALSE)
  }
  not_served_checked <<- c(not_served_checked, item)
  invisible(TRUE)
}
# Source details (2026-11-24, step 7b): a plain note that travels with a served value into the
# Source_detail column of cell_counts_isotropic_fractionator_long.csv (and from there into the
# compiled table's Source_details). One row per note: the item, the species name the item itself
# uses, a regular expression for the standardized labels it applies to, and the note. Filled in
# sec 1.9, 1.11 and 6b; joined to the served rows in sec 9.2.
source_detail_notes <- data.frame(Source = character(0), Species_Name_Source = character(0),
                                  label_pattern = character(0), detail = character(0),
                                  stringsAsFactors = FALSE)

## 1.7 Reshape the per-area tables of Seelke, Dooley & Krubitzer 2014 (Tables 3-5)
##     (2026-11-23 wiring; owner decision of that day, recorded in
##     WIRING_into_cell_counts_isotropic_fractionator.md).
##     The three public TSVs are LONG by cortical area: one row per printed area
##     ("Whole neocortex", "Sigma neocortex" printed with the Greek capital sigma, "Rem Ctx",
##     "V1", "S1", "A1"), all for one species, Monodelphis domestica. Every other item is
##     one row per species, so each table becomes ONE row with one column per
##     area x printed column, named "<area as printed> <TSV column>"; the item's
##     standardized-term file then maps those names as usual.
##       served : "Whole neocortex" -> Neocortex_ ; "V1" -> V1_ ; "S1" -> S1_ ; "A1" -> A1_
##       not served (status and reason for each in not_served.csv, checked in this step):
##                "Sigma neocortex" -- second_measurement: the neocortex of the OTHER hemisphere
##                of the same animals, dissected, its pieces summed; the neocortex is served
##                from the intact hemisphere ("Whole neocortex");
##                "Rem Ctx" (remaining cortex) -- not_a_database_structure;
##                Table 3's "% of Sigma neocortex" weight share -- no_measure_code
##                (_p.C.Brain is a different quantity and is annexed anyway).
##                These rows stay in the public TSVs; nothing of them enters this merge.
##     HEMISPHERE BASIS. One neocortical hemisphere was kept intact ("Whole neocortex")
##     and the other was dissected into V1, S1, A1 and the remaining cortex (Methods;
##     Results: "One intact neocortical hemisphere contained 3.03 +/- 0.21 million
##     cells"). So every weight and count printed in these tables is ONE hemisphere.
##     This step changes no value. The weight and count columns are registered in
##     laterality_known.csv (doubling = none), their standardized terms carry the
##     _unilateral suffix, and sec 3.5 adds the both-hemisphere estimate (2x) under the
##     plain label. The basis is also written to the SampleInfo column, which sec 6
##     annexes and cell_counts_isotropic_fractionator_unfiltered.csv keeps -- the same place
##     HerculanoHouzel_etal_2020_TABLE1 records "(1H each)". Densities and percentages
##     do not depend on the basis and are never doubled.
##     The printed "+/-" columns ("_pm") are carried through unchanged in meaning: the
##     tables do not say SD or SEM (the figure captions say SEM), so they are NOT named _SD.
##     The guards stop the merge unless each table still has exactly the six printed
##     areas, one species and n = 5.
reshape_seelke2014 <- function(d, item) {
  areas_served <- c("Whole neocortex" = "Whole neocortex", "V1" = "V1", "S1" = "S1", "A1" = "A1")
  area_not_served <- "Rem Ctx"         # plus the one Sigma-neocortex row, matched below
  need <- c("area", "species", "n_animals")
  if (!all(need %in% colnames(d)))
    stop("1.7: ", item, " lacks column(s) ", paste(setdiff(need, colnames(d)), collapse = ", "),
         ". The source table changed -- re-check this reshape before applying it.", call. = FALSE)
  sigma <- grepl("neocortex", d$area, fixed = TRUE) & d$area != "Whole neocortex"
  if (nrow(d) != 6L || sum(sigma) != 1L ||
      !setequal(d$area[!sigma], c(names(areas_served), area_not_served)) ||
      length(unique(d$species)) != 1L || !all(suppressWarnings(as.numeric(d$n_animals)) == 5))
    stop("1.7: expected ", item, " to have exactly the six printed areas (Whole neocortex, ",
         "Sigma neocortex, Rem Ctx, V1, S1, A1) for one species with n = 5; found areas ",
         paste(d$area, collapse = " | "), ". The source table changed -- re-check this ",
         "reshape before applying it.", call. = FALSE)
  value_cols <- setdiff(colnames(d), c(need, "source",
                                       "pct_of_sigma_neocortex", "pct_of_sigma_neocortex_pm"))
  # what is left out must be exactly what not_served.csv registers for this table (sec 1.6b);
  # the Greek-sigma row is registered under the plain name "Sigma neocortex"
  check_not_served(item, rows = c("Sigma neocortex", area_not_served),
                   columns = setdiff(colnames(d), c(need, value_cols)))
  w <- data.frame(Species = unique(d$species), n_animals = 5,
                  SampleInfo = paste0("(1H) measured in one hemisphere: Neocortex = the intact ",
                                      "neocortical hemisphere; V1, S1, A1 = dissected from the ",
                                      "other hemisphere. _unilateral_ weights and counts = as ",
                                      "measured; the plain weight and count labels = 2x, the ",
                                      "both-hemisphere estimate made by this merge. Group means ",
                                      "of 5 animals; _pm = the printed +/- of the as-measured ",
                                      "value (not labelled SD or SEM in the table; figure ",
                                      "captions: SEM)"),
                  stringsAsFactors = FALSE, check.names = FALSE)
  for (a in names(areas_served)) {
    r <- which(d$area == a)
    for (vc in value_cols)
      w[[paste(areas_served[[a]], vc)]] <- suppressWarnings(as.numeric(d[[vc]][r]))
  }
  w
}
for (seelke_item in c("Seelke_etal_2014_Table3", "Seelke_etal_2014_Table4", "Seelke_etal_2014_Table5")) {
  if (!is.null(cell_counts_isotropic_fractionator_data_list[[seelke_item]]))
    cell_counts_isotropic_fractionator_data_list[[seelke_item]] <-
      reshape_seelke2014(cell_counts_isotropic_fractionator_data_list[[seelke_item]], seelke_item)
}
rm(reshape_seelke2014, seelke_item)

## 1.8 Reshape Herculano-Houzel, Watson & Paxinos 2013 Table 1-a (mouse, 18 cortical areas)
##     (2026-11-24; the per-area decision of 2026-11-23 covers this source.)
##     The public TSV is LONG BY AREA: 18 rows, all Mus musculus. Each area becomes a structure
##     of its own (<Area> <column>), one row for the species, as in sec 1.7.
##     WHAT THE TABLE CONTAINS (paper, Materials and Methods and the Table 1 footnote): four male
##     C57Bl/6J mice. In each, one hemisphere was cut into 200-um coronal sections and the GREY
##     MATTER dissected into 18 areas by matching each section to the Franklin & Paxinos (2007)
##     atlas; the pieces of an area were pooled and counted by isotropic fractionator. "Numbers
##     are corrected to compensate for losses due to sectioning and thus reflect total numbers
##     per functional area in one cortical hemisphere +/- standard error of the mean" (correction
##     factors 1.466, 1.426, 1.480, 1.320, from the unsectioned hemisphere of the same mouse).
##     SERVED: Neurons and Other cells (absolute numbers, ONE hemisphere -> registered in
##             laterality_known.csv, doubled in sec 3.5), with their printed SEM ("_SEM", annexed
##             in sec 6). Total cells are not printed; "Cells (Neurons + OtherCells)" is the sum
##             of the two printed means of the row, built here so that the both-hemisphere cell
##             number is made and flagged by the hemisphere rule like the other two, instead of
##             by sec 3.6 from two estimates without a flag.
##             Since 2026-11-24 (step 7b; owner: "N.p.mm2 ... and N.p.mm3 is good"): N/mm2 and
##             N/mm3, as printed, under the new codes _N.p.mm2 and _N.p.mm3. Their NUMERATOR is
##             the measured neuron number of the area; their DENOMINATORS are the surface area
##             and the volume of the area in the Franklin & Paxinos (2007) ATLAS, not
##             measurements of these mice (paper, Methods). Densities: never doubled.
##     NOT SERVED (status and reason for each in not_served.csv, checked in this step): T (mm),
##             the three % columns, the atlas-area list and the two descriptive columns. The
##             printed Total row is not in the TSV.
##     n = 4 is from the paper, not from the TSV.
##     The guard stops the merge unless the table still has exactly the 18 printed areas for one
##     species.
hh2013_item <- "HerculanoHouzel_etal_2013_Table1-a"
if (!is.null(cell_counts_isotropic_fractionator_data_list[[hh2013_item]])) {
  d <- cell_counts_isotropic_fractionator_data_list[[hh2013_item]]
  hh2013_areas <- c("Infralimbic", "Cingulate", "Retrosplenial", "Parietal", "Motor", "Frontal", "V2M",
                    "V1", "V2L", "S1-limb", "S1-face", "S2", "Auditory", "Insula", "Orbital",
                    "Ectorhinal", "Entorhinal", "Piriform")
  need <- c("Species", "Area", "Neurons", "Neurons_SEM", "OtherCells", "OtherCells_SEM",
            "N_per_mm2", "N_per_mm3")
  if (!all(need %in% colnames(d)) || nrow(d) != 18L || !setequal(d$Area, hh2013_areas) ||
      length(unique(d$Species)) != 1L)
    stop("1.8: expected ", hh2013_item, " to have exactly the 18 printed areas for one species, ",
         "with columns ", paste(need, collapse = ", "), "; found areas ", paste(d$Area, collapse = " | "),
         ". The source table changed -- re-check this reshape before applying it.", call. = FALSE)
  check_not_served(hh2013_item, columns = setdiff(colnames(d), need))
  # unit guard for the two surface/volume densities: printed as neurons per mm2 and per mm3
  per_mm2 <- suppressWarnings(as.numeric(d$N_per_mm2)); per_mm3 <- suppressWarnings(as.numeric(d$N_per_mm3))
  if (anyNA(c(per_mm2, per_mm3)) || any(per_mm2 < 1e4 | per_mm2 > 3e5) || any(per_mm3 < 2e4 | per_mm3 > 4e5))
    stop("1.8: ", hh2013_item, " N_per_mm2 / N_per_mm3 are no longer neurons per mm2 (expected ",
         "1e4-3e5) and per mm3 (expected 2e4-4e5); re-check the source before serving them.", call. = FALSE)
  w <- data.frame(Species = unique(d$Species), n_animals = 4,
                  SampleInfo = paste0("(1H) 4 mice; grey matter of each area dissected from 200-um ",
                                      "coronal sections of ONE hemisphere (Franklin & Paxinos 2007 ",
                                      "atlas), numbers corrected for sectioning losses. _unilateral_ ",
                                      "numbers = as printed (one hemisphere); the plain number labels ",
                                      "= 2x, the both-hemisphere estimate made by this merge. _SEM = ",
                                      "the printed standard error of the mean of the as-printed value"),
                  stringsAsFactors = FALSE, check.names = FALSE)
  for (a in hh2013_areas) {
    r <- which(d$Area == a)
    neurons <- suppressWarnings(as.numeric(d$Neurons[r]))
    others  <- suppressWarnings(as.numeric(d$OtherCells[r]))
    w[[paste(a, "Neurons")]]        <- neurons
    w[[paste(a, "Neurons_SEM")]]    <- suppressWarnings(as.numeric(d$Neurons_SEM[r]))
    w[[paste(a, "OtherCells")]]     <- others
    w[[paste(a, "OtherCells_SEM")]] <- suppressWarnings(as.numeric(d$OtherCells_SEM[r]))
    w[[paste(a, "Cells (Neurons + OtherCells)")]] <- neurons + others
    w[[paste(a, "N_per_mm2")]]      <- per_mm2[r]
    w[[paste(a, "N_per_mm3")]]      <- per_mm3[r]
  }
  cell_counts_isotropic_fractionator_data_list[[hh2013_item]] <- w
  rm(d, hh2013_areas, need, w, a, r, neurons, others, per_mm2, per_mm3)
}
rm(hh2013_item)

## 1.9 Young, Collins & Kaas 2013 Table 1 (primary motor cortex, M1): columns served; the two
##     baboon cases as one row
##     (2026-11-24.) The public TSV is one row per species except for the baboons, and it
##     carries columns this merge does not serve.
##     WHAT THE TABLE CONTAINS (paper, Materials and Methods and the Table 1 footnote): "All brains
##     were bisected and one cortical hemisphere was separated from the subcortical structures
##     ... M1 was dissected from the flattened hemispheres"; counted by flow / isotropic
##     fractionator. "All values are reported as mean +/- standard deviation where applicable.
##     The n value refers the number of cortical hemispheres available for study."
##     SERVED: M1 mass (g, ONE hemisphere -> laterality_known.csv, doubled in sec 3.5), cells per
##             g and neurons per g (printed in millions; per mg in sec 3.4p), cells and neurons
##             under 1 mm2 of cortical surface (printed in millions per mm2; codes _C.p.mm2 and
##             _N.p.mm2, owner 2026-11-24; sec 3.4p), % neurons, their SD, and n (hemispheres).
##     THE TWO BABOONS (owner, 2026-11-24: "if 'Papio cynocephalus anubis' (case 09-27) and
##             'Papio hamadryas anubis' (case 11-31) are the same species we can average them
##             for the merging"). The table prints one row per case. Both names are the olive
##             baboon: the shared resolver gives both the same NCBI taxon (checked below; the
##             merge stops if it ever does not). They are served as ONE row -- for each M1
##             measure the unweighted mean of the two cases -- under the name the table prints
##             for case 09-27, with n = 2 hemispheres and no SD (none is printed for a single
##             case, and none is invented). Both cases are neurologically normal
##             (Young_etal_2013_b/Young_etal_2013_b_Table1.README.md). SampleInfo and the
##             source details say "mean of two cases (09-27, 11-31)".
##     NOT SERVED (status and reason for each in not_served.csv, checked in this step): M1 area
##             (belongs to __merging_cortical_areas, M1_Surface_Area.mm2); % of total mass, % of
##             total area, % neuron difference from the cortical average (no measure code); the
##             descriptive columns (names as published, specimen notes).
##     The guard stops the merge unless the table still has its seven printed rows.
young_item <- "Young_etal_2013_a_Table1"
if (!is.null(cell_counts_isotropic_fractionator_data_list[[young_item]])) {
  d <- cell_counts_isotropic_fractionator_data_list[[young_item]]
  young_measures <- c("M1_mass_g", "M1_cell_density_per_g_M", "M1_cell_density_per_mm2_M",
                      "M1_pct_neurons", "M1_neuron_density_per_g_M", "M1_neuron_density_per_mm2_M")
  young_served <- c("Species", "n_hemispheres", as.vector(rbind(young_measures, paste0(young_measures, "_sd"))))
  young_baboons <- c("Papio cynocephalus anubis" = "09-27", "Papio hamadryas anubis" = "11-31")
  baboon <- d$species_as_published %in% names(young_baboons)
  if (!all(c(young_served, "species_as_published", "specimen_identity") %in% colnames(d)) || nrow(d) != 7L ||
      sum(baboon) != 2L || anyDuplicated(d$species_as_published[baboon]) || anyDuplicated(d$Species[!baboon]))
    stop("1.9: expected ", young_item, " to have its seven printed rows (five species once each, ",
         "plus one row for each of the two baboon cases) and the columns ", paste(young_served, collapse = ", "),
         ". The source table changed -- re-check this step before applying it.", call. = FALSE)
  check_not_served(young_item, columns = setdiff(colnames(d), young_served))
  # the two baboon cases -> one row, the mean of the two for each measure
  b <- d[match(names(young_baboons), d$species_as_published), , drop = FALSE]
  if (!all(mapply(function(identity, case) grepl(case, identity, fixed = TRUE), b$specimen_identity, young_baboons)) ||
      !all(suppressWarnings(as.numeric(b$n_hemispheres)) == 1))
    stop("1.9: the two baboon rows of ", young_item, " are no longer case 09-27 and case 11-31, one ",
         "hemisphere each (columns specimen_identity, n_hemispheres); re-check before averaging them.",
         call. = FALSE)
  source(file.path("..", "_keys/resolve_species.R"))
  # (suppressWarnings: the resolver's standing note about duplicate spoke rows; its result is checked here)
  baboon_taxa <- suppressWarnings(resolve_species(b$Species, source_publication = paper_folder_of_item(young_item, "..")))
  if (any(baboon_taxa$unresolved) || anyNA(baboon_taxa$ncbi_taxid) || length(unique(baboon_taxa$ncbi_taxid)) != 1L)
    stop("1.9: the two baboon rows of ", young_item, " (", paste(b$Species, collapse = "; "), ") do not ",
         "resolve to one NCBI taxon in _keys (", paste(baboon_taxa$ncbi_taxid, collapse = ", "), "). The ",
         "owner's condition for averaging them (same species) is not met -- decide before re-running.",
         call. = FALSE)
  baboon_mean <- b[1, young_served, drop = FALSE]       # keeps the name printed for case 09-27
  for (col in young_measures) {
    cases <- suppressWarnings(as.numeric(b[[col]]))
    if (anyNA(cases)) stop("1.9: a baboon case has no value for ", col, call. = FALSE)
    baboon_mean[[col]] <- round(mean(cases), 6)
    baboon_mean[[paste0(col, "_sd")]] <- NA               # one hemisphere per case: no SD printed
  }
  baboon_mean$n_hemispheres <- 2
  w <- rbind(d[!baboon, young_served, drop = FALSE], baboon_mean)
  w$SampleInfo <- paste0("(1H) M1 dissected from one flattened cortical hemisphere per brain; n = ",
                         "number of hemispheres (one per animal). M1_unilateral_Mass.g = as printed ",
                         "(one hemisphere); M1_Mass.g = 2x, the both-hemisphere estimate made by ",
                         "this merge. _SD = the printed standard deviation")
  is_mean <- w$Species == baboon_mean$Species
  w$SampleInfo[is_mean] <- paste0("(1H) mean of two cases (", paste(young_baboons, collapse = ", "), "), one ",
                                  "hemisphere each: every M1 value of this row is the mean of the two ",
                                  "printed rows (\"", paste(names(young_baboons), collapse = "\" and \""),
                                  "\"), made by this merge; no SD is printed for a single case. ",
                                  "M1_unilateral_Mass.g = that mean (one hemisphere); M1_Mass.g = 2x, the ",
                                  "both-hemisphere estimate made by this merge")
  source_detail_notes <- rbind(source_detail_notes, data.frame(
    Source = young_item, Species_Name_Source = baboon_mean$Species, label_pattern = "^M1_",
    detail = paste0("mean of two cases (", paste(young_baboons, collapse = ", "), ")"), stringsAsFactors = FALSE))
  rownames(w) <- NULL
  cell_counts_isotropic_fractionator_data_list[[young_item]] <- w
  rm(d, young_measures, young_served, young_baboons, baboon, b, baboon_taxa, baboon_mean, col, cases, w, is_mean)
}
rm(young_item)

## 1.10 Reshape Collins et al. 2016 (one chimpanzee, right hemisphere)
##     (2026-11-24.) The public TSV is LONG BY REGION: 8 rows, all Pan troglodytes.
##     WHAT IT CONTAINS (paper, Results and Methods): one 53-year-old female. "The unfixed cortex
##     of the right hemisphere was separated from the underlying structures and most of the white
##     matter", flattened, cut into 742 pieces, each assigned to a cortical area when possible
##     and counted by flow / isotropic fractionator. "The neocortex contained an estimated 9.51
##     billion cells ... of which about 3.71 billion, or 39%, were neurons."
##     SERVED: "cerebral cortex" (the flattened neocortex of the right hemisphere; structure
##             Neocortex, as for Seelke et al. 2014), V1, V2 and M1: cells and neurons (RIGHT
##             hemisphere -> laterality_known.csv with side = right, doubled in sec 3.5),
##             fraction of neurons, cells and neurons per g, and cells and neurons per cm2 of
##             cortical surface (served per mm2 under _C.p.mm2 / _N.p.mm2; units in sec 3.4p).
##     M1 (owner, 2026-11-24: "We should register, and just indicate they are the same data
##             when it is registered, so that it never double counts"). The animal is the same
##             chimpanzee as the Young et al. 2013 M1 row (specimen KAAS-PAN-11_38 in
##             _keys/specimen_crosswalk/). The M1 row enters like the others; the specimen rule
##             of sec 6b then counts each measure that both tables give ONCE (served from Young,
##             the Collins value recorded as the same data) and serves the measures only this
##             table prints: the M1 cell and neuron numbers.
##     NOT SERVED (status and reason for each in not_served.csv, checked in this step):
##             "somatosensory block", "premotor block" and "Prefrontal Cortex" (dissection
##             blocks, not structures of the database); the left-hemisphere V1 row (a volume from
##             serial sections). Columns: surface area (belongs to __merging_cortical_areas), V1
##             volume, % of neocortical area, brain and body mass, the descriptive columns.
##     The guard stops the merge unless the table still has exactly these eight rows.
collins2016_item <- "Collins_etal_2016_Table1"
if (!is.null(cell_counts_isotropic_fractionator_data_list[[collins2016_item]])) {
  d <- cell_counts_isotropic_fractionator_data_list[[collins2016_item]]
  collins_served     <- c("cerebral cortex", "V1", "V2", "M1")
  collins_not_served <- c("somatosensory block", "premotor block", "Prefrontal Cortex")
  collins_values <- c("n_cells", "n_neurons", "pct_neurons", "cells_per_g", "neurons_per_g",
                      "cells_per_cm2", "neurons_per_cm2")
  need <- c("Species", "structure", "hemisphere", "method", collins_values)
  flat <- d$hemisphere == "right" & d$method == "flattened"
  if (!all(need %in% colnames(d)) || nrow(d) != 8L || length(unique(d$Species)) != 1L ||
      !setequal(d$structure[flat], c(collins_served, collins_not_served)) || sum(flat) != 7L ||
      !identical(d$structure[!flat], "V1") || !identical(d$hemisphere[!flat], "left"))
    stop("1.10: expected ", collins2016_item, " to have seven right-hemisphere flattened rows (",
         paste(c(collins_served, collins_not_served), collapse = ", "), ") and one left-hemisphere V1 row ",
         "for one species. The source table changed -- re-check this reshape before applying it.",
         call. = FALSE)
  check_not_served(collins2016_item,
                   rows = c(collins_not_served, "V1 (left hemisphere, serial sections)"),
                   columns = setdiff(colnames(d), need))
  w <- data.frame(Species = unique(d$Species), n_animals = 1,
                  SampleInfo = paste0("(1H, right) one chimpanzee, female, 53 y; flattened neocortex ",
                                      "of the RIGHT hemisphere. _right_ numbers = as printed (one ",
                                      "hemisphere); the plain number labels = 2x, the both-hemisphere ",
                                      "estimate made by this merge"),
                  stringsAsFactors = FALSE, check.names = FALSE)
  for (a in collins_served) {
    r <- which(flat & d$structure == a)
    for (vc in collins_values) {
      v <- suppressWarnings(as.numeric(d[[vc]][r]))
      if (!is.na(v)) w[[paste(a, vc)]] <- v      # the whole-cortex row prints no density
    }
  }
  cell_counts_isotropic_fractionator_data_list[[collins2016_item]] <- w
  rm(d, collins_served, collins_not_served, collins_values, need, flat, w, a, r, vc, v)
}
rm(collins2016_item)

## 1.11 Reshape Collins et al. 2010 Dataset S1 (five cases, one cortical hemisphere each)
##     (2026-11-24, step 7b; owner: "wire it as I said. we can see they are the same data and
##     just register that to avoid double counting.")
##     WHAT IT CONTAINS (paper, Results and SI Methods; item README): the raw counts for every
##     tissue piece of ONE flattened cortical hemisphere ("cortex", "the cortical sheet";
##     separated from the subcortical structures, pia removed) of five animals, counted by the
##     isotropic fractionator with flow cytometry:
##       galago 07-104 (Otolemur garnetti, left)   36 grid pieces
##       galago 08-07  (Otolemur garnetti, right)  12 pieces = named areas + the rest
##       owl monkey 07-78 (Aotus nancymae, left)   12 pieces = named areas + the rest
##       macaque 08-59 (Macaca mulatta, right)     42 pieces (not flattened; no surface areas)
##       baboon 09-27 (Papio cynocephalus anubis)  142 grid pieces
##     The supplement gives pieces only; it prints no total of its own. The whole-hemisphere
##     totals are figures in the paper's running text.
##     SERVED
##     (i)  PER AREA, for the two cases dissected into named areas (08-07, 07-78): V1, V2, S1,
##          M1, A1, MT and DL under the database's labels, dV3 and vV3 under the supplement's
##          names. Per area: tissue weight, cells, neurons (ONE hemisphere -> hemisphere rule),
##          share of neurons (served as %), cells and neurons per g (served per mg) and under
##          1 mm2 of cortical surface. The surface area of each piece belongs to
##          __merging_cortical_areas and is not served here.
##     (ii) WHOLE NEOCORTEX PER CASE = THE SUM OF THE SUPPLEMENT'S PIECES of that case (weight,
##          cells, neurons). This sum is made by this project, not printed by the paper. It is
##          served ONLY where it agrees with every whole-hemisphere figure the paper's text gives
##          for the case (Collins_etal_2010_text_totals.csv; within 1 %): today galago 08-07,
##          owl monkey 07-78 and baboon 09-27. For macaque 08-59 and galago 07-104 the sum and
##          the text disagree: both figures are registered (the comparison is written on every
##          run to cell_counts_isotropic_fractionator_sums_vs_text.csv) and NO total is served.
##     (iii) ONE ROW PER SPECIES. Where several cases of a species give the same measure, the
##          row is their unweighted mean. Today each served measure comes from one case only:
##          galago 07-104 serves nothing (no named areas; its sum disagrees with the text), so
##          the Otolemur row is case 08-07 alone. Two cases measured on DIFFERENT sides would
##          need a label that is neither _left_ nor _right_: the merge stops there, undecided.
##     (iv) SIDE PER CASE. The side is the case's own (item column `hemisphere`; where the item
##          gives none -- baboon 09-27 -- laterality_case_side.csv, with its evidence). The
##          weight and number columns are built per side ("V1 total_cells (right hemisphere)",
##          "... (left hemisphere)"), so one printed column can be a right hemisphere for one
##          case and a left for another while laterality_known.csv stays one row per column
##          with one side; sec 3.5 doubles each into the same plain label.
##     (v)  ANIMALS SHARED WITH YOUNG ET AL. 2013: specimen_key.csv and the specimen rule, sec 6b.
##     NOT SERVED (status and reason for each in not_served.csv, checked in this step): the
##          pieces "premotor", "Remain Ctx" and "Surr Ctx" of the two area cases as structures
##          of their own (they are counted inside the whole-neocortex sum); single grid pieces;
##          the whole-hemisphere totals of 07-104 and 08-59; surface area and the descriptive
##          columns.
##     The guard stops the merge unless the table still has its five cases and 244 pieces.
collins2010_item <- "Collins_etal_2010_DatasetS1"
sums_vs_text <- NULL
if (!is.null(cell_counts_isotropic_fractionator_data_list[[collins2010_item]])) {
  d <- cell_counts_isotropic_fractionator_data_list[[collins2010_item]]
  c10_pieces <- c("07-104" = 36L, "08-07" = 12L, "07-78" = 12L, "08-59" = 42L, "09-27" = 142L)
  c10_area_cases <- c("08-07", "07-78")
  c10_areas <- c("V1", "V2", "dV3", "vV3", "S1", "M1", "A1", "MT", "DL")
  c10_other_pieces <- c("premotor", "Remain Ctx", "Surr Ctx")
  c10_extensive <- c("tissue_weight_g", "total_cells", "total_neurons")
  c10_intensive <- c("neun_ratio", "cell_density_per_g", "neuron_density_per_g",
                     "cell_density_per_mm2", "neuron_density_per_mm2")
  need <- c("Species", "specimen", "hemisphere", "piece_id", "piece_type", c10_extensive, c10_intensive)
  d$specimen <- as.character(d$specimen); d$piece_id <- as.character(d$piece_id)
  if (!all(need %in% colnames(d)) || nrow(d) != 244L || !setequal(unique(d$specimen), names(c10_pieces)) ||
      !all(table(d$specimen)[names(c10_pieces)] == c10_pieces) ||
      !all(vapply(c10_area_cases, function(s) setequal(d$piece_id[d$specimen == s], c(c10_areas, c10_other_pieces)), logical(1))) ||
      any(tapply(d$Species, d$specimen, function(x) length(unique(x))) != 1L))
    stop("1.11: expected ", collins2010_item, " to have 244 pieces in five cases (",
         paste(names(c10_pieces), c10_pieces, sep = ": ", collapse = "; "), "), with cases ",
         paste(c10_area_cases, collapse = " and "), " dissected into ", paste(c(c10_areas, c10_other_pieces), collapse = ", "),
         ". The source table changed -- re-check this reshape before applying it.", call. = FALSE)
  for (col in c(c10_extensive, c10_intensive)) d[[col]] <- suppressWarnings(as.numeric(d[[col]]))
  if (anyNA(d[, c10_extensive]))
    stop("1.11: a piece of ", collins2010_item, " has no weight, cell or neuron number; the sums of ",
         "pieces would be incomplete.", call. = FALSE)
  # side per case: the item's own column; where it gives none, laterality_case_side.csv
  c10_species <- tapply(d$Species, d$specimen, function(x) x[1])
  c10_side <- tapply(d$hemisphere, d$specimen, function(x) unique(as.character(x))[1])
  case_side <- read.csv("laterality_case_side.csv", stringsAsFactors = FALSE, check.names = FALSE,
                        colClasses = "character")
  if (!identical(colnames(case_side), c("Reference", "case", "side", "evidence")) ||
      length(setdiff(case_side$side, c("left", "right"))) || any(!nzchar(case_side$evidence)))
    stop("laterality_case_side.csv must have exactly the columns Reference, case, side, evidence, ",
         "side = left or right, and an evidence text for every row", call. = FALSE)
  case_side <- case_side[case_side$Reference == collins2010_item, , drop = FALSE]
  if (any(!is.na(c10_side[case_side$case])))
    stop("1.11: laterality_case_side.csv gives a side for a case whose side is now in the item's own ",
         "table (", paste(case_side$case[!is.na(c10_side[case_side$case])], collapse = ", "),
         "); remove the row.", call. = FALSE)
  c10_side[case_side$case] <- case_side$side
  # (ii) sum of the pieces of each case, against every whole-hemisphere figure in the paper's text
  text_totals <- read.csv("Collins_etal_2010_text_totals.csv", stringsAsFactors = FALSE, check.names = FALSE,
                          colClasses = c(specimen = "character"))
  if (!identical(colnames(text_totals), c("specimen", "quantity", "text_value", "as_printed", "where")) ||
      !setequal(unique(text_totals$specimen), names(c10_pieces)) ||
      length(setdiff(text_totals$quantity, c("total_cells", "total_neurons"))))
    stop("Collins_etal_2010_text_totals.csv must have the columns specimen, quantity, text_value, ",
         "as_printed, where; a row for each of the five cases; quantity = total_cells or total_neurons",
         call. = FALSE)
  piece_sum <- function(case, col) sum(d[[col]][d$specimen == case])
  sums_vs_text <- text_totals
  sums_vs_text$sum_of_pieces <- mapply(piece_sum, text_totals$specimen, text_totals$quantity)
  sums_vs_text$n_pieces <- as.integer(c10_pieces[text_totals$specimen])
  sums_vs_text$difference_pct <- round(100 * (sums_vs_text$sum_of_pieces - sums_vs_text$text_value) / sums_vs_text$text_value, 2)
  sums_vs_text$agrees <- abs(sums_vs_text$difference_pct) <= 1
  c10_sum_cases <- names(c10_pieces)[vapply(names(c10_pieces), function(s)
    all(sums_vs_text$agrees[sums_vs_text$specimen == s]) &&
      setequal(sums_vs_text$quantity[sums_vs_text$specimen == s], c("total_cells", "total_neurons")), logical(1))]
  sums_vs_text$total_served <- sums_vs_text$specimen %in% c10_sum_cases
  sums_vs_text <- data.frame(Source = collins2010_item, Species = as.vector(c10_species[sums_vs_text$specimen]),
                             sums_vs_text[, c("specimen", "n_pieces", "quantity", "sum_of_pieces", "text_value",
                                              "as_printed", "where", "difference_pct", "agrees", "total_served")],
                             stringsAsFactors = FALSE)
  # what is left out must be exactly what not_served.csv registers (sec 1.6b)
  check_not_served(collins2010_item,
                   rows = c(as.vector(outer(c10_area_cases, c10_other_pieces, paste)),
                            paste(setdiff(names(c10_pieces), c10_area_cases), "single pieces"),
                            paste(setdiff(names(c10_pieces), c10_sum_cases), "whole-hemisphere total")),
                   columns = setdiff(colnames(d), need))
  # one row per case, then one row per species
  per_case <- lapply(names(c10_pieces), function(case) {
    side <- c10_side[[case]]
    if (is.na(side)) stop("1.11: no side for case ", case, " in the item or in laterality_case_side.csv", call. = FALSE)
    row <- list()
    if (case %in% c10_area_cases)
      for (a in c10_areas) {
        r <- which(d$specimen == case & d$piece_id == a)
        for (col in c10_extensive) row[[sprintf("%s %s (%s hemisphere)", a, col, side)]] <- d[[col]][r]
        for (col in c10_intensive) row[[paste(a, col)]] <- d[[col]][r]
      }
    if (case %in% c10_sum_cases)
      for (col in c10_extensive)
        row[[sprintf("Neocortex sum of pieces %s (%s hemisphere)", col, side)]] <- piece_sum(case, col)
    if (!length(row)) return(NULL)
    data.frame(Species = c10_species[[case]], case = case, side = side, as.data.frame(row, check.names = FALSE),
               stringsAsFactors = FALSE, check.names = FALSE)
  })
  per_case <- per_case[!vapply(per_case, is.null, logical(1))]
  w <- bind_rows(lapply(unique(vapply(per_case, function(x) x$Species, character(1))), function(sp) {
    cases <- per_case[vapply(per_case, function(x) x$Species == sp, logical(1))]
    if (length(unique(vapply(cases, function(x) x$side, character(1)))) > 1L)
      stop("1.11: two cases of ", sp, " measured on different sides would be averaged; the label and ",
           "register row for such a mean are not decided (README__merging.md, Collins et al. 2010).",
           call. = FALSE)
    value_cols <- unique(unlist(lapply(cases, function(x) setdiff(colnames(x), c("Species", "case", "side")))))
    row <- data.frame(Species = sp, n_animals = length(cases), stringsAsFactors = FALSE, check.names = FALSE)
    for (col in value_cols)
      row[[col]] <- mean(unlist(lapply(cases, function(x) if (col %in% colnames(x)) x[[col]] else NULL)))
    case_ids <- vapply(cases, function(x) x$case, character(1))
    row$SampleInfo <- paste0("(1H, ", cases[[1]]$side, ") case ", paste(case_ids, collapse = ", "),
                             "; one flattened cortical hemisphere (", cases[[1]]$side, "). _", cases[[1]]$side,
                             "_ weights and numbers = as measured (one hemisphere); the plain weight and ",
                             "number labels = 2x, the both-hemisphere estimate made by this merge. ",
                             "Neocortex_ = the sum of all ", sum(c10_pieces[case_ids]), " tissue pieces of the ",
                             "case in Dataset S1, made by this project")
    row
  }))
  w <- as.data.frame(w, stringsAsFactors = FALSE, check.names = FALSE)
  for (case in c10_sum_cases)
    source_detail_notes <- rbind(source_detail_notes, data.frame(
      Source = collins2010_item, Species_Name_Source = c10_species[[case]], label_pattern = "^Neocortex_",
      detail = paste0("from the sum of the ", c10_pieces[[case]], " tissue pieces of case ", case,
                      " in Dataset S1; the sum is made by this project (the supplement prints no total)"),
      stringsAsFactors = FALSE))
  w <- w[, c("Species", "n_animals", "SampleInfo", setdiff(colnames(w), c("Species", "n_animals", "SampleInfo"))), drop = FALSE]
  rownames(w) <- NULL
  cell_counts_isotropic_fractionator_data_list[[collins2010_item]] <- w
  rm(d, c10_pieces, c10_area_cases, c10_areas, c10_other_pieces, c10_extensive, c10_intensive, need, col,
     c10_species, c10_side, case_side, text_totals, piece_sum, c10_sum_cases, per_case, w, case)
}
rm(collins2010_item)

# every live table that has rows in not_served.csv must have been checked by its reshape
if (length(setdiff(intersect(unique(not_served$Reference), item_name), not_served_checked)))
  stop("1.6b: not_served.csv has rows for table(s) no reshape step checks: ",
       paste(setdiff(intersect(unique(not_served$Reference), item_name), not_served_checked), collapse = ", "),
       call. = FALSE)

## 2 Change to standardized terminology for all variables in those dataframes

# Read standardized terms
standardized_term_cell_counts_isotropic_fractionator <- read.csv("standardized_term_cell_counts_isotropic_fractionator.csv", check.names=FALSE)

# Laterality guard (2026-11-23; the hemisphere rule of this merge, the same convention as
# __merging_volumes -- see README__merging.md "Hemispheres" in both folders).
# laterality_known.csv records, for every source column measured from ONE SIDE, which side it was
# and WHO did any doubling:
#
#   doubling = none       the printed number is one side AS MEASURED. Its standardized term MUST
#                         carry the laterality suffix (_unilateral/_left/_right) immediately before
#                         the measure code (Neocortex_unilateral_N.n), so a one-side value can never
#                         be merged with a both-sides value. THIS MERGE then builds the both-sides
#                         partner in sec 3.5 -- 2x, under the plain label (Neocortex_N.n) -- and
#                         sec 9.3 records it as `estimated_bilateral_from_unilateral`.
#   doubling = by_source  the PUBLISHED number is already 2x one side: the paper's authors doubled
#                         it. Its term must carry NO laterality suffix, it is used exactly as
#                         published and never doubled again. Recorded as `published_bilateral_estimate`.
#
# Only EXTENSIVE measures (a weight, a volume, a number of cells) depend on the hemisphere basis
# and may be registered. Densities, percentages and ratios are a different kind of value: the same
# for one side as for both, never doubled, never suffixed.
# BOTH flags are PROVENANCE, never vetoes: neither ever drops a value.
# Unlike the volumes guard this one STOPS on every inconsistency, because here the register drives
# the doubling: a row that does not resolve would silently leave a one-side value undoubled.
# The next one-hemisphere source is a row in laterality_known.csv plus suffixed terms in its
# standardized-term file -- not new code. (A single one-side CELL inside an otherwise both-sides
# column cannot be a register row; the one such case, the raccoon hippocampus mass, is sec 3.4c.)
laterality_suffix_pattern <- "_(unilateral|left|right)"
laterality_extensive_codes <- c("Mass.g", "Vol.mm3", "C.n", "N.n", "O.n", "I.n")
laterality_one_side  <- data.frame(Reference = character(0), Standardized_Term = character(0),
                                   Plain_Term = character(0), stringsAsFactors = FALSE)
laterality_by_source <- data.frame(Reference = character(0), Standardized_Term = character(0),
                                   stringsAsFactors = FALSE)
# every both-hemisphere estimate this run makes: item, the item's own species name, the plain
# label that carries 2x, and the _unilateral label that carries the measured value (filled in sec
# 3.4c and 3.5, written out in sec 9.3)
laterality_estimates <- data.frame(Source = character(0), Species_Name_Source = character(0),
                                   Variable = character(0), unilateral = character(0),
                                   stringsAsFactors = FALSE)
if (!file.exists("laterality_known.csv"))
  stop("laterality guard: laterality_known.csv not found in ", getwd(), call. = FALSE)
lat_known <- read.csv("laterality_known.csv", stringsAsFactors = FALSE, check.names = FALSE)
lat_cols <- c("Reference", "Original_Term", "side", "doubling", "required_suffix", "note")
if (!identical(colnames(lat_known), lat_cols))
  stop("laterality_known.csv must have exactly the columns ", paste(lat_cols, collapse = ", "),
       call. = FALSE)
lat_known$doubling[is.na(lat_known$doubling) | !nzchar(lat_known$doubling)] <- "none"
lat_known$required_suffix[is.na(lat_known$required_suffix)] <- ""
bad_dbl <- setdiff(unique(lat_known$doubling), c("none", "by_source"))
if (length(bad_dbl))
  stop("laterality_known.csv: unknown doubling value(s) ", paste(bad_dbl, collapse = ", "),
       ". Use `none` (one side as measured) or `by_source` (published as 2x one side).",
       call. = FALSE)
# Only the tables this merge reads (a row for an item that is not live resolves to nothing yet).
lat_known <- lat_known[lat_known$Reference %in% item_name, , drop = FALSE]
live_terms <- standardized_term_cell_counts_isotropic_fractionator[
  standardized_term_cell_counts_isotropic_fractionator$Reference %in% item_name, , drop = FALSE]
lat_chk <- merge(lat_known, live_terms, by = c("Reference", "Original_Term"), all.x = TRUE)
lat_fail <- function(rows, what)
  if (nrow(rows)) stop("laterality guard: ", what, " -> ",
                       paste(sprintf("%s:%s (%s)", rows$Reference, rows$Original_Term,
                                     ifelse(is.na(rows$Standardized_Term), "no term", rows$Standardized_Term)),
                             collapse = "; "), call. = FALSE)
lat_fail(lat_chk[is.na(lat_chk$Standardized_Term), , drop = FALSE],
         "registered column(s) have no standardized term")
lat_code <- sub("^.*_", "", lat_chk$Standardized_Term)
lat_fail(lat_chk[!(lat_code %in% laterality_extensive_codes), , drop = FALSE],
         paste0("registered column(s) are not extensive measures (", paste(laterality_extensive_codes, collapse = ", "),
                "); a density, percentage or ratio is never registered or doubled"))
lat_one <- lat_chk[lat_chk$doubling == "none", , drop = FALSE]
lat_fail(lat_one[!grepl(paste0("^", laterality_suffix_pattern, "$"), lat_one$required_suffix), , drop = FALSE],
         "doubling = none row(s) without a required_suffix of _unilateral, _left or _right")
lat_fail(lat_one[!mapply(function(term, suffix) grepl(paste0(suffix, "_[^_]+$"), term),
                         lat_one$Standardized_Term, lat_one$required_suffix), , drop = FALSE],
         "one-side column(s) whose term lacks the required suffix immediately before the measure code")
lat_src <- lat_chk[lat_chk$doubling == "by_source", , drop = FALSE]
lat_fail(lat_src[grepl(paste0(laterality_suffix_pattern, "_"), lat_src$Standardized_Term), , drop = FALSE],
         "author-doubled column(s) carry a laterality suffix they should not")
if (nrow(lat_one))
  laterality_one_side <- data.frame(
    Reference = lat_one$Reference, Standardized_Term = lat_one$Standardized_Term,
    Plain_Term = mapply(function(term, suffix) sub(paste0(suffix, "_([^_]+)$"), "_\\1", term),
                        lat_one$Standardized_Term, lat_one$required_suffix, USE.NAMES = FALSE),
    stringsAsFactors = FALSE)
if (nrow(lat_src))
  laterality_by_source <- unique(data.frame(Reference = lat_src$Reference,
                                            Standardized_Term = lat_src$Standardized_Term,
                                            stringsAsFactors = FALSE))
# Species-level exceptions to a doubling = by_source row (2026-11-24): laterality_known_exceptions.csv
# (Reference, Species, basis, note). A register row is a whole column; where the paper says that
# one species of an author-doubled column was measured on BOTH sides, that species is listed here
# (Species = the name the item itself uses) and gets no published_bilateral_estimate flag. The
# only basis allowed is `both_sides_measured`. No value is changed either way -- only the flag.
laterality_exceptions <- data.frame(Reference = character(0), Species = character(0), stringsAsFactors = FALSE)
if (file.exists("laterality_known_exceptions.csv")) {
  lat_exc <- read.csv("laterality_known_exceptions.csv", stringsAsFactors = FALSE, check.names = FALSE)
  if (!identical(colnames(lat_exc), c("Reference", "Species", "basis", "note")))
    stop("laterality_known_exceptions.csv must have exactly the columns Reference, Species, basis, note",
         call. = FALSE)
  if (length(setdiff(unique(lat_exc$basis), "both_sides_measured")))
    stop("laterality_known_exceptions.csv: unknown basis ",
         paste(setdiff(unique(lat_exc$basis), "both_sides_measured"), collapse = ", "),
         ". The only exception is `both_sides_measured`.", call. = FALSE)
  lat_exc <- lat_exc[lat_exc$Reference %in% item_name, , drop = FALSE]
  if (length(setdiff(lat_exc$Reference, laterality_by_source$Reference)))
    stop("laterality_known_exceptions.csv: exception(s) for item(s) that have no doubling = by_source ",
         "row in laterality_known.csv: ",
         paste(setdiff(lat_exc$Reference, laterality_by_source$Reference), collapse = ", "), call. = FALSE)
  laterality_exceptions <- unique(lat_exc[, c("Reference", "Species")])
  rm(lat_exc)
}
# The other direction: a term that carries a laterality suffix must be a registered one-side
# column (or the printed dispersion of one, "_pm" / "_SD" / "_SEM"), so a suffix cannot be typed into a
# term file without the register knowing.
lat_suffixed <- live_terms[grepl(paste0(laterality_suffix_pattern, "_"), live_terms$Standardized_Term), , drop = FALSE]
lat_fail(lat_suffixed[!(paste(lat_suffixed$Reference, sub("_(pm|SD|SEM)$", "", lat_suffixed$Standardized_Term)) %in%
                          paste(laterality_one_side$Reference, laterality_one_side$Standardized_Term)), , drop = FALSE],
         "term(s) carry a laterality suffix but are not registered in laterality_known.csv")
message("Laterality guard OK: ", nrow(laterality_one_side), " one-side column(s) correctly suffixed, ",
        nrow(laterality_by_source), " author-doubled column(s) correctly unsuffixed (of the tables this merge reads).")
rm(lat_known, lat_cols, bad_dbl, live_terms, lat_chk, lat_fail, lat_code, lat_one, lat_src, lat_suffixed)

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
  # 2026-11-23, hemisphere rule (owner: "do like with the raccoon ... make it clear it is doubled;
  # and also offer single"). The doubled value above is unchanged. Two things are added so this
  # case is marked like every other one-side value of the merge:
  #   - the printed one-hemisphere mass is offered as Hippocampus_unilateral_Mass.g, for this
  #     species only (NA for the other species of the table, whose printed masses are both sides);
  #   - the doubled cell is recorded, and sec 9.3 writes it to
  #     cell_counts_isotropic_fractionator_flags.csv as estimated_bilateral_from_unilateral.
  # It stays here, not in laterality_known.csv: the register describes whole columns, and this is
  # one cell of a column that is otherwise both hemispheres.
  jardimmesseder_df$Hippocampus_unilateral_Mass.g <- NA_real_
  jardimmesseder_df$Hippocampus_unilateral_Mass.g[raccoon] <- printed_mass
  laterality_estimates <- rbind(laterality_estimates,
                                data.frame(Source = "JardimMesseder_etal_2017_Table1",
                                           Species_Name_Source = "Procyon lotor",
                                           Variable = "Hippocampus_Mass.g",
                                           unilateral = "Hippocampus_unilateral_Mass.g",
                                           stringsAsFactors = FALSE))
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

# 3.4n Unit conversion for Seelke, Dooley & Krubitzer 2014 (2026-11-23 wiring).
#      Table 4 prints cells, neurons and non-neurons in MILLIONS; Table 5 prints densities
#      in MILLIONS PER GRAM. This merge carries absolute counts and densities per MILLIGRAM:
#        _C.n, _N.n, _O.n        = printed x 1e6          (e.g. 3.03 million  -> 3,030,000)
#        _C.p.mg, _N.p.mg, _O.p.mg = printed x 1e6 / 1000 (e.g. 41.70 million/g -> 41,700 /mg)
#      The printed +/- ("_pm") of each is converted with the same factor. Weights (g) and
#      % neurons are already in the merge's units. Both tables print two decimals, so every
#      converted value is a whole number; round() only removes binary floating-point noise
#      (3.03 * 1e6 is not exactly 3030000 in double precision) and changes no printed digit.
#      _C.p.mg (cells per mg) is a code this merge did not have: no other source prints a
#      total-cell density. It is deliberately NOT added to the sec 3.7 derivations, so it is
#      served only where a source prints it and no value appears for any other species.
#      The glossary codes C.p.g / N.p.g / O.p.g stay as the record of the printed unit.
#      Guards: the merge stops unless the columns are still in the printed units (counts
#      below 100 million, densities below 1000 million per g), so a source build that starts
#      writing absolute numbers cannot be multiplied twice.
for (seelke_item in c("Seelke_etal_2014_Table4", "Seelke_etal_2014_Table5")) {
  df <- cell_counts_isotropic_fractionator_data_list[[seelke_item]]
  if (is.null(df)) next
  count_cols   <- grep("_(C|N|O)\\.n(_pm)?$",      colnames(df), value = TRUE)
  density_cols <- grep("_(C|N|O)\\.p\\.mg(_pm)?$", colnames(df), value = TRUE)
  expected <- if (seelke_item == "Seelke_etal_2014_Table4") c(24L, 0L) else c(0L, 24L)
  if (!identical(c(length(count_cols), length(density_cols)), expected))
    stop("3.4n: expected ", expected[1], " count and ", expected[2], " density columns in ",
         seelke_item, "; found ", length(count_cols), " and ", length(density_cols),
         ". The source table or its standardized terms changed -- re-check this conversion.",
         call. = FALSE)
  printed <- unlist(df[c(count_cols, density_cols)])
  if (anyNA(printed) || any(printed <= 0) ||
      any(unlist(df[count_cols]) >= 100) || any(unlist(df[density_cols]) >= 1000))
    stop("3.4n: ", seelke_item, " is not in the printed units (millions; millions per g). ",
         "The source table changed -- re-check this conversion before applying it.", call. = FALSE)
  for (col in count_cols)   df[[col]] <- round(df[[col]] * 1e6)
  for (col in density_cols) df[[col]] <- round(df[[col]] * 1e6 / 1000)
  cell_counts_isotropic_fractionator_data_list[[seelke_item]] <- df
}
suppressWarnings(rm(seelke_item, count_cols, density_cols, expected, printed))

# 3.4p Unit conversions for the Kaas-lab tables (2026-11-24 wiring; per-mm2 densities and
#      Collins et al. 2010 added the same day, step 7b).
#      Young_etal_2013_a_Table1 prints densities in MILLIONS per gram (per mg = x 1e6 / 1000)
#      and in MILLIONS per mm2 of cortical surface (per mm2 = x 1e6).
#      Collins_etal_2016_Table1's public TSV gives densities as absolute numbers per gram
#      (per mg = / 1000) and per cm2 (per mm2 = / 100), and the share of neurons as a FRACTION
#      (percent = x 100).
#      Collins_etal_2010_DatasetS1 gives densities as absolute numbers per gram (per mg = / 1000)
#      and per mm2 (served as they are), and the share of neurons as a FRACTION (x 100).
#      Mass, cell and neuron numbers are already in g and absolute numbers. Nothing here is a
#      hemisphere operation (that is sec 3.5). The guards stop the merge if a column is no
#      longer in the unit this step expects.
if ("Young_etal_2013_a_Table1" %in% item_name) {
  df <- cell_counts_isotropic_fractionator_data_list[["Young_etal_2013_a_Table1"]]
  density_cols <- grep("_(C|N)\\.p\\.mg(_SD)?$", colnames(df), value = TRUE)
  surface_cols <- grep("_(C|N)\\.p\\.mm2(_SD)?$", colnames(df), value = TRUE)
  if (length(density_cols) != 4L || length(surface_cols) != 4L)
    stop("3.4p: expected 4 per-g density columns (M1_C.p.mg, M1_N.p.mg and their _SD) and 4 per-mm2 ",
         "columns (M1_C.p.mm2, M1_N.p.mm2 and their _SD) in Young_etal_2013_a_Table1, found ",
         length(density_cols), " and ", length(surface_cols), call. = FALSE)
  for (col in c(density_cols, surface_cols)) df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
  means <- unlist(df[, grep("_SD$", density_cols, value = TRUE, invert = TRUE)], use.names = FALSE)
  if (any(is.na(means)) || any(means < 10 | means > 500))
    stop("3.4p: Young_etal_2013_a_Table1 densities are no longer in millions per gram ",
         "(expected 10-500); re-check the source before converting.", call. = FALSE)
  surface_means <- unlist(df[, grep("_SD$", surface_cols, value = TRUE, invert = TRUE)], use.names = FALSE)
  surface_means <- surface_means[!is.na(surface_means)]      # not printed for Macaca nemestrina
  if (!length(surface_means) || any(surface_means < 0.01 | surface_means > 1))
    stop("3.4p: Young_etal_2013_a_Table1 per-mm2 densities are no longer in millions per mm2 ",
         "(expected 0.01-1); re-check the source before converting.", call. = FALSE)
  for (col in density_cols) df[[col]] <- round(df[[col]] * 1e6 / 1000, 6)
  for (col in surface_cols) df[[col]] <- round(df[[col]] * 1e6, 6)
  cell_counts_isotropic_fractionator_data_list[["Young_etal_2013_a_Table1"]] <- df
  rm(df, density_cols, surface_cols, means, surface_means, col)
}
if ("Collins_etal_2016_Table1" %in% item_name) {
  df <- cell_counts_isotropic_fractionator_data_list[["Collins_etal_2016_Table1"]]
  density_cols  <- grep("_(C|N)\\.p\\.mg$", colnames(df), value = TRUE)
  surface_cols  <- grep("_(C|N)\\.p\\.mm2$", colnames(df), value = TRUE)
  fraction_cols <- grep("_p\\.C\\.N$", colnames(df), value = TRUE)
  if (length(density_cols) != 6L || length(surface_cols) != 6L || length(fraction_cols) != 4L)
    stop("3.4p: expected 6 per-g density columns, 6 per-cm2 density columns and 4 neuron-share ",
         "columns in Collins_etal_2016_Table1, found ", length(density_cols), ", ",
         length(surface_cols), " and ", length(fraction_cols), call. = FALSE)
  for (col in c(density_cols, surface_cols, fraction_cols)) df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
  if (any(is.na(unlist(df[, c(density_cols, surface_cols, fraction_cols)]))) ||
      any(unlist(df[, density_cols]) < 1e7 | unlist(df[, density_cols]) > 5e8) ||
      any(unlist(df[, surface_cols]) < 1e6 | unlist(df[, surface_cols]) > 1e8) ||
      any(unlist(df[, fraction_cols]) <= 0 | unlist(df[, fraction_cols]) >= 1))
    stop("3.4p: Collins_etal_2016_Table1 densities are no longer absolute numbers per gram ",
         "(expected 1e7-5e8) and per cm2 (expected 1e6-1e8), or the neuron share is no longer a ",
         "fraction; re-check the source before converting.", call. = FALSE)
  for (col in density_cols)  df[[col]] <- round(df[[col]] / 1000, 6)
  for (col in surface_cols)  df[[col]] <- round(df[[col]] / 100, 6)
  for (col in fraction_cols) df[[col]] <- round(df[[col]] * 100, 6)
  cell_counts_isotropic_fractionator_data_list[["Collins_etal_2016_Table1"]] <- df
  rm(df, density_cols, surface_cols, fraction_cols, col)
}
if ("Collins_etal_2010_DatasetS1" %in% item_name) {
  df <- cell_counts_isotropic_fractionator_data_list[["Collins_etal_2010_DatasetS1"]]
  density_cols  <- grep("_(C|N)\\.p\\.mg$", colnames(df), value = TRUE)
  surface_cols  <- grep("_(C|N)\\.p\\.mm2$", colnames(df), value = TRUE)
  fraction_cols <- grep("_p\\.C\\.N$", colnames(df), value = TRUE)
  if (length(density_cols) != 18L || length(surface_cols) != 18L || length(fraction_cols) != 9L)
    stop("3.4p: expected 18 per-g density columns, 18 per-mm2 density columns and 9 neuron-share ",
         "columns (nine areas) in Collins_etal_2010_DatasetS1, found ", length(density_cols), ", ",
         length(surface_cols), " and ", length(fraction_cols), call. = FALSE)
  for (col in c(density_cols, surface_cols, fraction_cols)) df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
  printed <- function(cols) { v <- unlist(df[, cols], use.names = FALSE); v[!is.na(v)] }
  if (any(printed(density_cols) < 1e7 | printed(density_cols) > 5e8) ||
      any(printed(surface_cols) < 1e4 | printed(surface_cols) > 1e6) ||
      any(printed(fraction_cols) <= 0 | printed(fraction_cols) >= 1))
    stop("3.4p: Collins_etal_2010_DatasetS1 densities are no longer absolute numbers per gram ",
         "(expected 1e7-5e8) and per mm2 (expected 1e4-1e6), or the neuron share is no longer a ",
         "fraction; re-check the source before converting.", call. = FALSE)
  for (col in density_cols)  df[[col]] <- round(df[[col]] / 1000, 6)
  for (col in fraction_cols) df[[col]] <- round(df[[col]] * 100, 6)
  cell_counts_isotropic_fractionator_data_list[["Collins_etal_2010_DatasetS1"]] <- df
  rm(df, density_cols, surface_cols, fraction_cols, col, printed)
}

# 3.4o Guard: Herculano-Houzel et al. 2020 (bats), hemisphere basis per species (2026-11-24).
#      Methods 2.1: "For all specimens except Chaerophon pumilus, we had only one hemisphere
#      available for quantitative analysis ... data are necessarily expressed as twice the numbers
#      obtained for the available hemisphere ...; for C. pumilus, numbers provided refer to the sum
#      of both hemispheres." Table 1 prints the same per species in its n column: "(1H each)" or
#      "(2H each)", kept here as SampleInfo. The neuron-number columns of Tables 1 and 2 are
#      therefore registered doubling = by_source in laterality_known.csv, with the "(2H each)"
#      species listed in laterality_known_exceptions.csv. So is the brain mass of Table 1
#      (MBRAIN): the paper's own tables show it is the sum of the dissected structures, on the
#      same basis as the neuron numbers, not a brain weighed whole
#      (HerculanoHouzel_etal_2020/internal_checks/). NO VALUE IS CHANGED: the numbers are
#      used exactly as published; sec 9.3 only marks them published_bilateral_estimate.
#      This guard stops the merge if the table and the two register files stop agreeing.
if ("HerculanoHouzel_etal_2020_TABLE1" %in% item_name) {
  df <- cell_counts_isotropic_fractionator_data_list[["HerculanoHouzel_etal_2020_TABLE1"]]
  one_h <- grepl("1H", df$SampleInfo, fixed = TRUE)
  two_h <- grepl("2H", df$SampleInfo, fixed = TRUE)
  if (!all(xor(one_h, two_h)))
    stop("3.4o: HerculanoHouzel_etal_2020_TABLE1 SampleInfo no longer says 1H or 2H for every species",
         call. = FALSE)
  for (hh20_item in c("HerculanoHouzel_etal_2020_TABLE1", "HerculanoHouzel_etal_2020_TABLE2")) {
    if (!(hh20_item %in% item_name)) next
    if (!(hh20_item %in% laterality_by_source$Reference))
      stop("3.4o: ", hh20_item, " has no doubling = by_source row in laterality_known.csv", call. = FALSE)
    if (!setequal(laterality_exceptions$Species[laterality_exceptions$Reference == hh20_item], df$Species[two_h]))
      stop("3.4o: laterality_known_exceptions.csv for ", hh20_item, " must list exactly the species ",
           "Table 1 marks (2H each): ", paste(df$Species[two_h], collapse = ", "), call. = FALSE)
  }
  rm(df, one_h, two_h, hh20_item)
}

# 3.5 Hemisphere rule: build the both-hemisphere estimate of every registered one-side column.
#     (2026-11-23, owner decision: "serve both hemisphere in the comparison but make it clear it
#     is doubled; and also offer single ... we should just always do it the same way unless there
#     is a specific note that it is a different kind of value".)
#     For each column that laterality_known.csv registers with doubling = none (guard: sec 2):
#       <Structure>_unilateral_<code>   keeps the printed value, one hemisphere, as measured;
#       <Structure>_<code>              = 2 x that value: the both-hemisphere ESTIMATE, made here.
#     The plain label is what the other species of the merge carry (both hemispheres), so it is
#     the one to compare across species; sec 9.3 marks every such value in
#     cell_counts_isotropic_fractionator_flags.csv (estimated_bilateral_from_unilateral).
#     Fill-only: where the same item already has a both-sides value under the plain label for a
#     species, that value stays and no estimate is made. The printed +/- ("_pm") stays with the
#     as-measured value; no dispersion is invented for the estimate.
#     This runs after every unit conversion and correction (3.3-3.4n) and BEFORE the derivations
#     (3.6, 3.7), which read the plain labels only: a ratio or density derived from two doubled
#     counts (_O.p.N = 2 x O / 2 x N) is the same number as from the measured ones, and nothing is
#     derived under a _unilateral label (3.6/3.7 build their column names from the structure
#     before the FIRST underscore; sec 9.1 skips suffixed labels).
#     Columns registered doubling = by_source are not touched: used exactly as published.
for (k in seq_len(nrow(laterality_one_side))) {
  lat_item <- laterality_one_side$Reference[k]
  lat_term <- laterality_one_side$Standardized_Term[k]
  lat_plain <- laterality_one_side$Plain_Term[k]
  df <- cell_counts_isotropic_fractionator_data_list[[lat_item]]
  if (is.null(df) || !(lat_term %in% colnames(df)))
    stop("3.5: registered one-side column ", lat_term, " not found in ", lat_item,
         ". The source table or its standardized terms changed -- re-check laterality_known.csv.",
         call. = FALSE)
  measured <- suppressWarnings(as.numeric(df[[lat_term]]))
  existing <- if (lat_plain %in% colnames(df)) suppressWarnings(as.numeric(df[[lat_plain]])) else rep(NA_real_, nrow(df))
  estimate <- is.na(existing) & !is.na(measured)
  df[[lat_plain]] <- ifelse(estimate, 2 * measured, existing)
  if (any(estimate))
    laterality_estimates <- rbind(laterality_estimates,
                                  data.frame(Source = lat_item, Species_Name_Source = df$Species[estimate],
                                             Variable = lat_plain, unilateral = lat_term,
                                             stringsAsFactors = FALSE))
  cell_counts_isotropic_fractionator_data_list[[lat_item]] <- df
}
suppressWarnings(rm(k, lat_item, lat_term, lat_plain, measured, existing, estimate))

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

# 4.3b Specimen identifiers (2026-11-24, step 7b): which animal a row is.
#      Owner, 2026-11-24: "We should register, and just indicate they are the same data when it
#      is registered, so that it never double counts. Like a code for different data points
#      which are actually the same data." The code is the repository's own specimen identifier,
#      `canonical_specimen` in _keys/specimen_crosswalk/specimen_crosswalk.csv (KAAS-PAN-11_38 ...).
#      specimen_key.csv (this folder) only POINTS at those identifiers, one row per table x
#      species row x animal:
#        Reference, Species (the name the table itself uses), canonical_specimen,
#        crosswalk_item_reference (the crosswalk's own name for the table: it still calls the
#        Young table Young_etal_2013_Table1), relation, serve_rank, note
#        relation = is             the row is that one animal
#                 = mean_includes  the row is a mean over animals that include it
#        serve_rank                which table serves a measure that two tables give for the
#                                  same animal (1 = serves; used in sec 6b)
#      Nothing of the crosswalk is copied: how strong each link is (`match`: matched, probable)
#      is read from the crosswalk here, at run time. The merge stops if a key row points at an
#      identifier the crosswalk does not have for that table, or at a species row the table
#      does not have. Each keyed table gets a `Specimen` column -- identifier and link strength
#      -- so the code is visible in cell_counts_isotropic_fractionator_unfiltered.csv; sec 6
#      annexes it, like SampleInfo.
specimen_key <- read.csv("specimen_key.csv", stringsAsFactors = FALSE, check.names = FALSE)
if (!identical(colnames(specimen_key), c("Reference", "Species", "canonical_specimen",
                                         "crosswalk_item_reference", "relation", "serve_rank", "note")) ||
    length(setdiff(specimen_key$relation, c("is", "mean_includes"))) ||
    anyNA(suppressWarnings(as.integer(specimen_key$serve_rank))) ||
    anyDuplicated(specimen_key[, c("Reference", "Species", "canonical_specimen")]))
  stop("specimen_key.csv must have exactly the columns Reference, Species, canonical_specimen, ",
       "crosswalk_item_reference, relation, serve_rank, note; relation = is or mean_includes; an ",
       "integer serve_rank; and no repeated Reference + Species + canonical_specimen", call. = FALSE)
specimen_key <- specimen_key[specimen_key$Reference %in% item_name, , drop = FALSE]   # live tables only
specimen_key$link <- character(nrow(specimen_key)); specimen_key$Species_Resolved <- character(nrow(specimen_key))
if (nrow(specimen_key)) {
  crosswalk_file <- file.path("..", "_keys", "specimen_crosswalk", "specimen_crosswalk.csv")
  if (!file.exists(crosswalk_file)) stop("4.3b: ", crosswalk_file, " not found", call. = FALSE)
  specimen_crosswalk <- read.csv(crosswalk_file, stringsAsFactors = FALSE, check.names = FALSE)
  in_crosswalk <- match(paste(specimen_key$canonical_specimen, specimen_key$crosswalk_item_reference, sep = "\r"),
                        paste(specimen_crosswalk$canonical_specimen, specimen_crosswalk$item_reference, sep = "\r"))
  if (anyNA(in_crosswalk))
    stop("4.3b: specimen_key.csv points at identifier(s) the specimen crosswalk does not have for that table: ",
         paste(sprintf("%s / %s", specimen_key$canonical_specimen, specimen_key$crosswalk_item_reference)[is.na(in_crosswalk)],
               collapse = "; "), ". Fix the key; the crosswalk is the authority.", call. = FALSE)
  specimen_key$link <- specimen_crosswalk$match[in_crosswalk]
  if (any(!(specimen_key$link %in% c("matched", "probable"))))
    stop("4.3b: a specimen link is neither `matched` nor `probable` in the crosswalk: ",
         paste(unique(specimen_key$canonical_specimen[!(specimen_key$link %in% c("matched", "probable"))]), collapse = ", "),
         ". Only those two count as the same animal.", call. = FALSE)
  for (k in seq_len(nrow(specimen_key))) {
    df <- cell_counts_isotropic_fractionator_data_list[[specimen_key$Reference[k]]]
    r <- which(df$Species_Source == specimen_key$Species[k])
    if (length(r) != 1L)
      stop("4.3b: specimen_key.csv names a species row its table does not have (or has twice): ",
           specimen_key$Reference[k], " / ", specimen_key$Species[k], call. = FALSE)
    specimen_key$Species_Resolved[k] <- df$Species[r]
    code <- sprintf("%s%s (link: %s)", if (specimen_key$relation[k] == "mean_includes") "mean includes " else "",
                    specimen_key$canonical_specimen[k], specimen_key$link[k])
    if (!("Specimen" %in% colnames(df))) df$Specimen <- NA_character_
    df$Specimen[r] <- if (is.na(df$Specimen[r])) code else paste(df$Specimen[r], code, sep = "; ")
    cell_counts_isotropic_fractionator_data_list[[specimen_key$Reference[k]]] <- df
  }
  rm(crosswalk_file, specimen_crosswalk, in_crosswalk, k, df, r, code)
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
# Sample information: "SampleInfo"; "Specimen" (the animal's identifier, sec 4.3b)
# Statistics around means: "_SD", _n", "_S.n"; "_pm" = a printed +/- the source does not label as
#   SD or SEM (Seelke et al. 2014; added 2026-11-23 -- no earlier item has a column ending in "_pm")
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
                         "Specimen",   # specimen identifier and link strength (sec 4.3b; 2026-11-24)
                         grep("_Source$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE), 
                         grep("_S.n$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_SD$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_n$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_pm$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),
                         grep("_SEM$", names(filtered_cell_counts_isotropic_fractionator_data_list[[i]]), value = TRUE),   # printed SEM (HH 2013 Table 1-a; 2026-11-24)
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

## 6b The specimen rule: the same data are counted once (2026-11-24, step 7b)
##    Owner, 2026-11-24: "We should register, and just indicate they are the same data when it
##    is registered, so that it never double counts"; "we can see they are the same data and
##    just register that to avoid double counting."
##    Two tables give THE SAME DATA where their rows for a species share an animal
##    (canonical_specimen, sec 4.3b) and both give a value for the same measure of the same
##    structure. Labels are compared without their hemisphere suffix, so a one-side value
##    (M1_left_Mass.g) and its 2x estimate (M1_Mass.g) in one table are the same data as
##    M1_unilateral_Mass.g and M1_Mass.g in the other. Then:
##      - the value is SERVED ONCE, from the table with the lower serve_rank in specimen_key.csv;
##      - the other table's value is taken out of the merge here, before any team resolution,
##        and written to cell_counts_isotropic_fractionator_same_data.csv with both values,
##        both tables, the identifier and the strength of each link;
##      - the served row names both tables in its Source_detail (sec 9.2);
##      - a measure that only one of the tables gives is not touched: it is served.
##    A `probable` link counts as the same animal, exactly like `matched`; the strength stays on
##    record in the Specimen column, the same-data file and the source details.
##    A mean that INCLUDES the animal (relation = mean_includes; Young's three galagos) is
##    treated the same way and is never taken apart: the mean is served, the single animal's
##    value for that measure is recorded as the same data.
##    Nothing is averaged here and no value is changed. An overlap between two tables that is
##    NOT explained by a shared identifier is left alone by this step and still stops the merge
##    (sec 8.Y for two Kaas-lab tables; sec 9.2 between teams).
plain_label <- function(x) sub(paste0(laterality_suffix_pattern, "_([^_]+)$"), "_\\2", x)
same_data <- data.frame(Species = character(0), Variable = character(0), served_from = character(0),
                        served_label = character(0), served_value = numeric(0), same_data_in = character(0),
                        same_data_value = numeric(0), canonical_specimen = character(0),
                        served_link = character(0), same_data_link = character(0),
                        relation = character(0), stringsAsFactors = FALSE)
for (sp in unique(specimen_key$Species_Resolved)) {
  keyed <- specimen_key[specimen_key$Species_Resolved == sp, , drop = FALSE]
  tables <- unique(keyed$Reference[order(keyed$serve_rank)])
  for (i in seq_along(tables)) for (j in seq_along(tables)) {
    if (j <= i) next
    first <- keyed[keyed$Reference == tables[i], , drop = FALSE]
    other <- keyed[keyed$Reference == tables[j], , drop = FALSE]
    shared <- intersect(first$canonical_specimen, other$canonical_specimen)
    if (!length(shared)) next
    if (first$serve_rank[1] == other$serve_rank[1])
      stop("6b: ", tables[i], " and ", tables[j], " share ", paste(shared, collapse = ", "), " for ", sp,
           " and have the same serve_rank in specimen_key.csv; say which one serves.", call. = FALSE)
    df_first <- filtered_cell_counts_isotropic_fractionator_data_list[[tables[i]]]
    df_other <- filtered_cell_counts_isotropic_fractionator_data_list[[tables[j]]]
    row_first <- which(df_first$Species == sp); row_other <- which(df_other$Species == sp)
    if (length(row_first) != 1L || length(row_other) != 1L)
      stop("6b: expected one row for ", sp, " in ", tables[i], " and in ", tables[j], call. = FALSE)
    for (label in setdiff(colnames(df_other), "Species")) {
      value_other <- suppressWarnings(as.numeric(df_other[[label]][row_other]))
      if (is.na(value_other)) next
      match_first <- setdiff(colnames(df_first)[plain_label(colnames(df_first)) == plain_label(label)], "Species")
      match_first <- match_first[!is.na(suppressWarnings(as.numeric(unlist(df_first[row_first, match_first]))))]
      if (!length(match_first)) next                      # only this table gives the measure: served
      served_label <- if (label %in% match_first) label else if (plain_label(label) != label)
        setdiff(match_first, plain_label(label))[1] else match_first[1]
      if (is.na(served_label)) served_label <- match_first[1]
      same_data <- rbind(same_data, data.frame(
        Species = sp, Variable = label, served_from = tables[i], served_label = served_label,
        served_value = as.numeric(df_first[[served_label]][row_first]), same_data_in = tables[j],
        same_data_value = value_other, canonical_specimen = paste(shared, collapse = "; "),
        served_link = paste(unique(first$link[first$canonical_specimen %in% shared]), collapse = "; "),
        same_data_link = paste(unique(other$link[other$canonical_specimen %in% shared]), collapse = "; "),
        relation = if (any(c(first$relation, other$relation)[c(first$canonical_specimen, other$canonical_specimen) %in% shared] == "mean_includes"))
          "the served value is a mean that includes this animal" else "the same animal",
        stringsAsFactors = FALSE))
      df_other[[label]][row_other] <- NA
    }
    filtered_cell_counts_isotropic_fractionator_data_list[[tables[j]]] <- df_other
    # the measures of the same structures that only the other table gives stay served: say on
    # them that the animal is the one whose other values come from the first table
    pair <- same_data$Species == sp & same_data$served_from == tables[i] & same_data$same_data_in == tables[j]
    for (structure in unique(sub("_.*$", "", same_data$Variable[pair]))) {
      still_served <- grep(paste0("^", structure, "_"), setdiff(colnames(df_other), "Species"), value = TRUE)
      still_served <- still_served[!is.na(suppressWarnings(as.numeric(unlist(df_other[row_other, still_served]))))]
      if (length(still_served))
        source_detail_notes <- rbind(source_detail_notes, data.frame(
          Source = tables[j], Species_Name_Source = other$Species[1],
          label_pattern = paste0("^(", paste(gsub(".", "\\.", still_served, fixed = TRUE), collapse = "|"), ")$"),
          detail = sprintf("only this table gives this measure; its animal (specimen %s) is %s the other %s values, served from %s",
                           paste(shared, collapse = "; "),
                           if (any(first$relation[first$canonical_specimen %in% shared] == "mean_includes"))
                             "one of the animals in the mean behind" else "the animal behind",
                           structure, tables[i]),
          stringsAsFactors = FALSE))
    }
  }
}
suppressWarnings(rm(sp, keyed, tables, i, j, first, other, shared, df_first, df_other, row_first, row_other,
                    label, value_other, match_first, served_label, pair, structure, still_served))
write.csv(same_data, "cell_counts_isotropic_fractionator_same_data.csv", row.names = FALSE)
if (!is.null(sums_vs_text)) {
  for (col in c("sum_of_pieces", "text_value"))     # plain numbers, not 3.5e+09
    sums_vs_text[[col]] <- vapply(sums_vs_text[[col]], function(v)
      format(v, digits = 15, scientific = FALSE, drop0trailing = TRUE, trim = TRUE), character(1))
  write.csv(sums_vs_text, "cell_counts_isotropic_fractionator_sums_vs_text.csv", row.names = FALSE)
  rm(col)
}
if (nrow(same_data))
  source_detail_notes <- rbind(source_detail_notes, data.frame(
    Source = same_data$served_from,
    Species_Name_Source = specimen_key$Species[match(paste(same_data$served_from, same_data$Species, sep = "\r"),
                                                     paste(specimen_key$Reference, specimen_key$Species_Resolved, sep = "\r"))],
    label_pattern = paste0("^", gsub(".", "\\.", same_data$served_label, fixed = TRUE), "$"),
    detail = sprintf("same data also in %s (%s = %s; specimen %s; link: %s here, %s there; %s): counted once",
                     same_data$same_data_in, same_data$Variable, vapply(same_data$same_data_value, function(v) format(v, digits = 15, scientific = FALSE, drop0trailing = TRUE, trim = TRUE), character(1)),
                     same_data$canonical_specimen, same_data$served_link, same_data$same_data_link, same_data$relation),
    stringsAsFactors = FALSE))

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

# Krubitzer team (2026-11-23): Seelke, Dooley & Krubitzer 2014 is neither Kverkova-team nor
# Herculano-Houzel-team work. Its items are taken OUT of the "not Kverkova" block built above, so
# they never enter the Herculano-Houzel worth order of sec 8.2.H (no priority number, pin or
# demotion there moves), and are resolved as a team of their own in sec 8.1-8.3.S. Sec 9.2 stops
# the merge if this team ever gives a Species x Variable that another team also gives, so nothing
# it adds can change, or be averaged with, a value that is already served.
Krubitzer_Team_dataframes <- grep("^Seelke_etal_2014_", names(filtered_cell_counts_isotropic_fractionator_data_list), value = TRUE)
Other_Team_variables <- Other_Team_variables[!(Other_Team_variables$Dataframe_Name %in% Krubitzer_Team_dataframes), , drop = FALSE]
HerculanoHouzel_Team_dataframes <- setdiff(HerculanoHouzel_Team_dataframes, Krubitzer_Team_dataframes)
HerculanoHouzel_Team_variables <- unique(Other_Team_variables[, !names(Other_Team_variables) %in% "Dataframe_Name"])

# Kaas team (2026-11-24): Young, Collins & Kaas 2013, Collins et al. 2016 and Collins et al. 2010
# are Kaas-lab (Vanderbilt) flow / isotropic-fractionator work. Same pattern as the Krubitzer
# team: taken out of the "not Kverkova" block and resolved as a team of their own in sec
# 8.1-8.3.Y. Animals these tables share are handled by the specimen rule (sec 6b), before any
# team step. What that rule does not explain still stops the merge: two Kaas-lab tables that
# give the same Species x Variable (sec 8.Y), or this team and another (sec 9.2).
# HerculanoHouzel_etal_2013_Table1-a is Herculano-Houzel-team work and stays in that block.
Kaas_Team_dataframes <- grep("^(Young_etal_2013_a_|Collins_etal_2016_|Collins_etal_2010_)", names(filtered_cell_counts_isotropic_fractionator_data_list), value = TRUE)
Other_Team_variables <- Other_Team_variables[!(Other_Team_variables$Dataframe_Name %in% Kaas_Team_dataframes), , drop = FALSE]
HerculanoHouzel_Team_dataframes <- setdiff(HerculanoHouzel_Team_dataframes, Kaas_Team_dataframes)
HerculanoHouzel_Team_variables <- unique(Other_Team_variables[, !names(Other_Team_variables) %in% "Dataframe_Name"])

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
# 2011 Table 2 (ape cerebellar totals). Herculano-Houzel et al. 2007 (primate brains,
# whole brain only) joins the block in the 2026-11-23 follow-up round: it is the most-
# cited source in the 2015 tables (245 cells) and, on the same D1 basis as HH 2006, its
# printed direct whole-brain totals take the WholeBrain rows for its seven species over
# the 2015 re-reports. It shares no species x variable cells with the other block
# members (its species overlap the HH & Kaas compiled rows, which carry cerebellar
# totals only, and Ribeiro's Tupaia row, which is olfactory-bulb only), so its position
# inside the block cannot matter. Under the compilation rule each takes
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
               "HerculanoHouzel_etal_2007_Table1",
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

###### 8.1 - 8.3 KRUBITZER TEAM (Seelke, Dooley & Krubitzer 2014; added 2026-11-23)
# Same resolution as the Kverkova team: melt, rank the team's items by date then number of
# species, keep the best-priority non-NA value per Species x Variable. The three tables share no
# Species x Variable (Table 3 weights, Table 4 counts and % neurons, Table 5 densities), so today
# the ranking decides nothing; it is here so that a later Krubitzer-lab item is resolved inside
# its own team and not against another team's tables.
Krubitzer_Team_df_list <- filtered_cell_counts_isotropic_fractionator_data_list[Krubitzer_Team_dataframes]
Krubitzer_Team_data_long <- data.frame(Species = character(0), Variable = character(0),
                                       Source = character(0), Value = character(0),
                                       stringsAsFactors = FALSE)
if (length(Krubitzer_Team_df_list)) {
  ## 8.1.S Combine all data in all dataframes in Krubitzer_Team_df_list as a long dataframe
  combined_data <- bind_rows(lapply(names(Krubitzer_Team_df_list), function(source) {
    df <- Krubitzer_Team_df_list[[source]]
    df[] <- lapply(df, as.character)
    df %>%
      pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
      mutate(Source = source) %>%
      select(Species, Variable, Source, Value)
  }))
  ## 8.2.S Priority: date (highest first), then number of species
  worth_dataframe <- data.frame(source = names(Krubitzer_Team_df_list),
                                date = as.numeric(str_extract(names(Krubitzer_Team_df_list), "[0-9]+")),
                                number_species = vapply(Krubitzer_Team_df_list, nrow, integer(1)) - 1,
                                stringsAsFactors = FALSE)
  worth_dataframe <- worth_dataframe[order(-worth_dataframe$date, -worth_dataframe$number_species), ]
  rownames(worth_dataframe) <- NULL
  worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
  combined_data$priority <- worth_dataframe$priority[match(combined_data$Source, worth_dataframe$source)]
  ## 8.3.S Limit dataset to best available data
  combined_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
  best_priority <- ave(combined_data$priority, combined_data$Species, combined_data$Variable, FUN = min)
  Krubitzer_Team_data_long <- as.data.frame(combined_data[combined_data$priority == best_priority,
                                                          c("Species", "Variable", "Source", "Value")],
                                            stringsAsFactors = FALSE)
  rm(best_priority)
}

###### 8.1 - 8.3 KAAS TEAM (Young, Collins & Kaas 2013; Collins et al. 2016; Collins et al. 2010;
###### added 2026-11-24)
# Same resolution as the Krubitzer team: melt, rank the team's items by date then number of
# species, keep the best-priority non-NA value per Species x Variable.
# These tables share animals (the chimpanzee, an owl monkey, a galago, a baboon). The specimen
# rule of sec 6b has already taken every value that is the same data as a served one out of the
# merge, so no animal is served twice under one label and the ranking below decides nothing.
# GUARD: if two of these tables still give the same species and measure, the overlap is NOT
# explained by a shared specimen identifier, and the merge stops instead of letting the ranking
# choose silently. (Labels are compared without their hemisphere suffix, as in sec 6b.)
Kaas_Team_df_list <- filtered_cell_counts_isotropic_fractionator_data_list[Kaas_Team_dataframes]
Kaas_Team_data_long <- data.frame(Species = character(0), Variable = character(0),
                                       Source = character(0), Value = character(0),
                                       stringsAsFactors = FALSE)
if (length(Kaas_Team_df_list)) {
  ## 8.1.Y Combine all data in all dataframes in Kaas_Team_df_list as a long dataframe
  combined_data <- bind_rows(lapply(names(Kaas_Team_df_list), function(source) {
    df <- Kaas_Team_df_list[[source]]
    df[] <- lapply(df, as.character)
    df %>%
      pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value") %>%
      mutate(Source = source) %>%
      select(Species, Variable, Source, Value)
  }))
  given <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
  given_cell <- paste(given$Species, plain_label(given$Variable), sep = " / ")
  n_tables <- tapply(given$Source, given_cell, function(x) length(unique(x)))
  if (any(n_tables > 1L))
    stop("8.Y Kaas-team guard: ", sum(n_tables > 1L), " Species x Variable cell(s) are given by more than ",
         "one Kaas-lab table and no shared specimen is registered for them in specimen_key.csv: ",
         paste(names(n_tables)[n_tables > 1L], collapse = "; "),
         ". If the tables measured the same animal, register it (specimen_key.csv, from ",
         "_keys/specimen_crosswalk/); if not, decide which is served before re-running.", call. = FALSE)
  rm(given, given_cell, n_tables)
  ## 8.2.Y Priority: date (highest first), then number of species
  worth_dataframe <- data.frame(source = names(Kaas_Team_df_list),
                                date = as.numeric(str_extract(names(Kaas_Team_df_list), "[0-9]+")),
                                number_species = vapply(Kaas_Team_df_list, nrow, integer(1)) - 1,
                                stringsAsFactors = FALSE)
  worth_dataframe <- worth_dataframe[order(-worth_dataframe$date, -worth_dataframe$number_species), ]
  rownames(worth_dataframe) <- NULL
  worth_dataframe$priority <- seq_len(nrow(worth_dataframe))
  combined_data$priority <- worth_dataframe$priority[match(combined_data$Source, worth_dataframe$source)]
  ## 8.3.Y Limit dataset to best available data
  combined_data <- combined_data[!is.na(combined_data$Value), , drop = FALSE]
  best_priority <- ave(combined_data$priority, combined_data$Species, combined_data$Variable, FUN = min)
  Kaas_Team_data_long <- as.data.frame(combined_data[combined_data$priority == best_priority,
                                                          c("Species", "Variable", "Source", "Value")],
                                            stringsAsFactors = FALSE)
  rm(best_priority)
}

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
  # Hemisphere rule (2026-11-23): a label with a laterality suffix (<Structure>_unilateral_<code>)
  # is a one-side value kept for the record. Ratios and densities are derived from the plain,
  # both-hemisphere labels only, so nothing like Neocortex_unilateral_O.p.N is ever built here.
  # No label of the merge carried such a suffix before, so this line changes no earlier value.
  measured <- measured[!grepl(paste0(laterality_suffix_pattern, "_[^_]+$"), measured$Variable), , drop = FALSE]
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
# Krubitzer team: same rule. Today it fills nothing -- Seelke Table 5 prints the densities and
# sec 3.7 has already filled _O.p.N inside Table 4 -- but the team is treated like the others.
Krubitzer_Team_data_long       <- derive_within_team(Krubitzer_Team_data_long,
                                                     cell_counts_isotropic_fractionator_derivations)
# Kaas team: same rule. Today it fills nothing: every ratio this step could build for these
# tables (_N.p.mg from neurons and mass, _p.C.N from neurons and cells) is already printed or was
# derived inside one table in sec 3.7.
Kaas_Team_data_long            <- derive_within_team(Kaas_Team_data_long,
                                                     cell_counts_isotropic_fractionator_derivations)

# The specimen rule also applies after the derivations (2026-11-24, step 7b). Sec 6b took a value
# out of a table because the same animal's value for that measure is served from another table.
# Step 9.1 fills a ratio that its team lacks from that team's own numbers -- so where the two
# tables are in DIFFERENT teams it would build the removed value again (a share of neurons from
# the table's own cell and neuron numbers) and the two teams would then meet in sec 9.2. A value
# that sec 6b recorded as the same data is therefore not rebuilt from the table it was taken out
# of. Today every keyed table is in team Kaas and this removes nothing.
drop_same_data_again <- function(df_long) {
  if (!nrow(same_data) || !nrow(df_long)) return(df_long)
  again <- rep(FALSE, nrow(df_long))
  for (k in seq_len(nrow(same_data)))
    again <- again | (df_long$Species == same_data$Species[k] &
                        plain_label(df_long$Variable) == plain_label(same_data$Variable[k]) &
                        grepl(same_data$same_data_in[k], df_long$Source, fixed = TRUE))
  df_long[!again, , drop = FALSE]
}
HerculanoHouzel_Team_data_long <- drop_same_data_again(HerculanoHouzel_Team_data_long)
Kverkova_Team_data_long        <- drop_same_data_again(Kverkova_Team_data_long)
Krubitzer_Team_data_long       <- drop_same_data_again(Krubitzer_Team_data_long)
Kaas_Team_data_long            <- drop_same_data_again(Kaas_Team_data_long)

#### 9.2 Calculate: between-team averages using filtered dataset
## Finalize dataset
# Krubitzer-team guard (2026-11-23): the mean below averages a Species x Variable that two teams
# both give. This team must never be averaged with, or displace, another team's value (owner
# decision of 2026-11-23: nothing it adds may change which value is served for an existing
# species), so the merge stops instead if the two ever meet. Resolve by an explicit decision in
# this script (a precedence, or a separate label), not by the mean.
krubitzer_cells <- paste(Krubitzer_Team_data_long$Species, Krubitzer_Team_data_long$Variable, sep = "\r")
other_team_cells <- c(paste(HerculanoHouzel_Team_data_long$Species, HerculanoHouzel_Team_data_long$Variable, sep = "\r"),
                      paste(Kverkova_Team_data_long$Species, Kverkova_Team_data_long$Variable, sep = "\r"))
if (any(krubitzer_cells %in% other_team_cells))
  stop("9.2 Krubitzer-team guard: ", sum(unique(krubitzer_cells) %in% other_team_cells),
       " Species x Variable cell(s) are given by the Krubitzer team AND by another team, e.g. ",
       sub("\r", " / ", unique(krubitzer_cells)[unique(krubitzer_cells) %in% other_team_cells][1], fixed = TRUE),
       ". They would be averaged. Decide which is served before re-running.", call. = FALSE)
rm(krubitzer_cells, other_team_cells)
# Kaas-team guard (2026-11-24): the same rule for the Kaas team, against every other team
# (Herculano-Houzel, Kverkova, Krubitzer). If it fires, the cells are listed and nothing is averaged.
# An animal shared with a table of another team is handled before this point by the specimen rule
# (sec 6b: specimen_key.csv is not limited to one team), so what stops here is an overlap that
# no shared specimen identifier explains.
kaas_cells <- paste(Kaas_Team_data_long$Species, Kaas_Team_data_long$Variable, sep = "\r")
other_team_cells <- c(paste(HerculanoHouzel_Team_data_long$Species, HerculanoHouzel_Team_data_long$Variable, sep = "\r"),
                      paste(Kverkova_Team_data_long$Species, Kverkova_Team_data_long$Variable, sep = "\r"),
                      paste(Krubitzer_Team_data_long$Species, Krubitzer_Team_data_long$Variable, sep = "\r"))
if (any(kaas_cells %in% other_team_cells))
  stop("9.2 Kaas-team guard: ", sum(unique(kaas_cells) %in% other_team_cells),
       " Species x Variable cell(s) are given by the Kaas team AND by another team, and no shared ",
       "specimen is registered for them in specimen_key.csv: ",
       paste(sub("\r", " / ", unique(kaas_cells)[unique(kaas_cells) %in% other_team_cells], fixed = TRUE), collapse = "; "),
       ". They would be averaged. Decide which is served before re-running.", call. = FALSE)
rm(kaas_cells, other_team_cells)
# Stack the dataframes lengthwise
stacked_long_dataframe <- rbind(HerculanoHouzel_Team_data_long, Kverkova_Team_data_long,
                                Krubitzer_Team_data_long, Kaas_Team_data_long)
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
## Source_detail (2026-11-24, step 7b): the notes collected in source_detail_notes (sec 1.6b),
## for the rows they belong to: the served value comes from that table, for that species, under
## a label the note names. Empty for every other row. The compiled table reads this column into
## its Source_details. No value, source or row is changed by it.
cell_counts_isotropic_fractionator_long$Source_detail <- ""
if (nrow(source_detail_notes)) {
  note_species <- source_species_ids$Species_Name[match(
    paste(source_detail_notes$Source, source_detail_notes$Species_Name_Source, sep = "\r"),
    paste(source_species_ids$Source_Species, source_species_ids$Species_Name_Source, sep = "\r"))]
  if (anyNA(note_species))
    stop("9.2: a source detail names a species its table does not have: ",
         paste(unique(paste(source_detail_notes$Source, source_detail_notes$Species_Name_Source)[is.na(note_species)]),
               collapse = "; "), call. = FALSE)
  for (k in seq_len(nrow(source_detail_notes))) {
    hit <- cell_counts_isotropic_fractionator_long$Source == source_detail_notes$Source[k] &
      cell_counts_isotropic_fractionator_long$Species == note_species[k] &
      grepl(source_detail_notes$label_pattern[k], cell_counts_isotropic_fractionator_long$Variable)
    cell_counts_isotropic_fractionator_long$Source_detail[hit] <- ifelse(
      nzchar(cell_counts_isotropic_fractionator_long$Source_detail[hit]),
      paste(cell_counts_isotropic_fractionator_long$Source_detail[hit], source_detail_notes$detail[k], sep = "; "),
      source_detail_notes$detail[k])
  }
  rm(note_species, k, hit)
}
write_csv(cell_counts_isotropic_fractionator_long, "cell_counts_isotropic_fractionator_long.csv")

# Convert to wide dataframe
cell_counts_isotropic_fractionator_wide <- arrange(pivot_wider(cell_counts_isotropic_fractionator_long, id_cols = Species, names_from = Variable, values_from = Value), Species)
# # keep a record of sources for the datapoints
# cell_counts_isotropic_fractionator_sources_wide <- arrange(pivot_wider(cell_counts_isotropic_fractionator_long, id_cols = Species, names_from = Variable, values_from = Source), Species)
write_csv(cell_counts_isotropic_fractionator_wide, "cell_counts_isotropic_fractionator_wide.csv")

#### 9.3 Hemisphere provenance: cell_counts_isotropic_fractionator_flags.csv (written on every run)
## One row per SERVED value that is a both-hemisphere estimate, in the format of
## __merging_volumes/volumes_flags.csv (Species, Variable, flag, detail). Species and Variable
## are those of cell_counts_isotropic_fractionator_long.csv, so the file joins to it directly.
##   estimated_bilateral_from_unilateral  2x one measured hemisphere, doubled by THIS merge
##                                        (sec 3.5 from laterality_known.csv; sec 3.4c)
##   published_bilateral_estimate         2x one hemisphere, doubled by the SOURCE and used as
##                                        published (laterality_known.csv, doubling = by_source;
##                                        not for a species listed in laterality_known_exceptions.csv)
## Provenance, never a veto: no value is removed here. A value is flagged only where the item
## that made the estimate is the one the merge serves for that Species x Variable (sec 8); the
## guard stops the merge unless every flagged value is exactly 2x the _unilateral value served
## beside it. Values DERIVED from an estimate (a density over a doubled mass) are not flagged:
## the flag marks the estimate itself.
long_key <- paste(cell_counts_isotropic_fractionator_long$Species, cell_counts_isotropic_fractionator_long$Variable, sep = "\r")
cell_counts_isotropic_fractionator_flags <- data.frame(Species = character(0), Variable = character(0),
                                                       flag = character(0), detail = character(0),
                                                       stringsAsFactors = FALSE)
if (nrow(laterality_estimates)) {
  est <- unique(laterality_estimates)
  est$Species <- source_species_ids$Species_Name[match(paste(est$Source, est$Species_Name_Source, sep = "\r"),
                                                       paste(source_species_ids$Source_Species,
                                                             source_species_ids$Species_Name_Source, sep = "\r"))]
  if (anyNA(est$Species))
    stop("9.3: a both-hemisphere estimate names a species its item does not have: ",
         paste(unique(paste(est$Source, est$Species_Name_Source)[is.na(est$Species)]), collapse = "; "),
         call. = FALSE)
  served <- match(paste(est$Species, est$Variable, sep = "\r"), long_key)
  est <- est[!is.na(served) & cell_counts_isotropic_fractionator_long$Source[served] == est$Source, , drop = FALSE]
  if (nrow(est)) {
    both_sides <- cell_counts_isotropic_fractionator_long$Value[match(paste(est$Species, est$Variable, sep = "\r"), long_key)]
    one_side   <- cell_counts_isotropic_fractionator_long$Value[match(paste(est$Species, est$unilateral, sep = "\r"), long_key)]
    not_double <- is.na(one_side) | !(abs(both_sides - 2 * one_side) <= 1e-9 * abs(both_sides))
    if (any(not_double))
      stop("9.3: served value(s) recorded as a both-hemisphere estimate are not 2x the one-side ",
           "value served beside them: ",
           paste(sprintf("%s %s", est$Species[not_double], est$Variable[not_double]), collapse = "; "),
           call. = FALSE)
    cell_counts_isotropic_fractionator_flags <- rbind(cell_counts_isotropic_fractionator_flags, data.frame(
      Species = est$Species, Variable = est$Variable, flag = "estimated_bilateral_from_unilateral",
      detail = paste0("both-hemisphere estimated as 2x ", est$unilateral, " (only one side measured)"),
      stringsAsFactors = FALSE))
    rm(both_sides, one_side, not_double)
  }
  rm(est, served)
}
if (nrow(laterality_by_source)) {
  pub <- merge(as.data.frame(cell_counts_isotropic_fractionator_long[, c("Species", "Variable", "Source")]),
               laterality_by_source, by.x = c("Source", "Variable"), by.y = c("Reference", "Standardized_Term"))
  if (nrow(laterality_exceptions)) {
    # species the paper measured on both sides inside an author-doubled column: no flag
    exc_species <- source_species_ids$Species_Name[match(
      paste(laterality_exceptions$Reference, laterality_exceptions$Species, sep = "\r"),
      paste(source_species_ids$Source_Species, source_species_ids$Species_Name_Source, sep = "\r"))]
    if (anyNA(exc_species))
      stop("9.3: laterality_known_exceptions.csv names a species its item does not have: ",
           paste(paste(laterality_exceptions$Reference, laterality_exceptions$Species)[is.na(exc_species)],
                 collapse = "; "), call. = FALSE)
    pub <- pub[!(paste(pub$Source, pub$Species, sep = "\r") %in%
                   paste(laterality_exceptions$Reference, exc_species, sep = "\r")), , drop = FALSE]
    rm(exc_species)
  }
  if (nrow(pub))
    cell_counts_isotropic_fractionator_flags <- rbind(cell_counts_isotropic_fractionator_flags, data.frame(
      Species = pub$Species, Variable = pub$Variable, flag = "published_bilateral_estimate",
      detail = paste0("published value is 2x one hemisphere, doubled by the source (not by ",
                      "this merge): ", pub$Source, " -- see laterality_known.csv"),
      stringsAsFactors = FALSE))
  rm(pub)
}
cell_counts_isotropic_fractionator_flags <- cell_counts_isotropic_fractionator_flags[
  order(cell_counts_isotropic_fractionator_flags$Species, cell_counts_isotropic_fractionator_flags$Variable,
        method = "radix"), , drop = FALSE]
write_csv(cell_counts_isotropic_fractionator_flags, "cell_counts_isotropic_fractionator_flags.csv")
rm(long_key)

# Validate the draft ontology pilot against current rule tables and merge outputs.
# This writes a QA alignment report; draft decisions do not alter selected values.
pilot_status <- system2("python3", file.path("..", "_checks", "check_ontology_pilot.py"))
if (pilot_status != 0L) stop("Ontology pilot QA failed", call. = FALSE)
