# Hevner_etal_1995_OrdinalLaminar_snapshot.R -----------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Hevner, Liu & Wong-Riley (1995) "A
# metabolic map of cytochrome oxidase in the rat brain: histochemical,
# densitometric and biochemical studies", Neuroscience 65: 313-342,
# doi 10.1016/0306-4522(94)00514-6.
#
#   Hevner_etal_1995_OrdinalLaminar_snapshot.csv
#       one row per printed QUALITATIVE statement about cytochrome-oxidase (CO)
#       reactivity of a cortical layer, laminar compartment or area:
#       rat cerebral cortex: the laminar statements printed in RESULTS
#       "Cerebral cortex" (p. 335), the Fig. 29 legend (p. 332), DISCUSSION
#       pp. 339 and 341, and the area-level ordinal statements of pp. 332-335
#       (highest / moderate / relatively low areas).
#
# The laminar content of this paper is ORDINAL: no layer is given an optical
# density anywhere in it (the quantified values the paper does print are in the
# sibling item(s) of this folder). Every row is an ordinal reading of the
# authors' own words (state_as_read = our coding of the printed adjective;
# printed_wording = the sentence or clause it comes from). Follows the
# Preuss_etal_1999 statement-row convention (house precedent for ordinal data).
#
# Words were cross-read from the PDF text layer; laminar adjectives and layer
# labels were checked on page renders of pp. 332, 334, 335, 339, 341
# (__HOWTO_make_a_snapshot.md method 5). This script writes the frozen file and
# refuses to overwrite a frozen copy that differs; the build script READS it.
# No cleaning happens here.
#
# Fidelity decisions:
#  * A sentence giving states for several layers gives one row per layer.
#  * Relative statements ("less reactive than the puffs") keep the comparison
#    target in comparison_target and get no absolute state.
#  * Printed "high" / "CO-rich" are coded dark; "relatively low" is kept as
#    printed; the printed word is always kept in printed_wording.
#  * The paper does NOT describe CO layer by layer for individual areas
#    (Fr1/Fr2, Par1, Te1, Oc1, Oc2, cingulate, retrosplenial, insular,
#    piriform, hippocampal strata): it prints one general rule (layers III-IV
#    darkest in most areas, e.g. limb sensorimotor cortex) plus the entorhinal
#    exception, the barrel / septa and granular / dysgranular contrasts, and
#    the lateral entorhinal islands. Those are the laminar rows; the area-level
#    rows carry layer = 'all layers (area-level)'. Nothing was invented.
#  * n = 7 (male Sprague-Dawley rats used for histochemistry; EXPERIMENTAL
#    PROCEDURES p. 314).
#
# Transcribed by an AI assistant (Claude) on 2026-11-18 from the PDF text layer
# and page renders. Human visual check pending.
# ---------------------------------------------------------------------------

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
paper  <- basename(folder)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_text <- r"-[
row|page|section|taxon_as_printed|taxon_in_methods|cortical_area|subfield|layer|compartment|condition|feature|state_as_read|comparison_target|value_low|value_high|unit|n_as_printed|printed_wording|evidence|note
1|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|cerebral cortex, most areas (e.g. forelimb and hindlimb sensorimotor cortex)||III-IV|whole layers|adult|CO reactivity|darkest|||||7|The cortical layers with the darkest CO reactivity were, in most areas, layers III-IV (e.g. in forelimb and hindlimb sensorimotor cortex; Figs 7-9, 14-16, 29)|Results|darkest layers within the area
2|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|entorhinal cortex||II|whole layer|adult|CO reactivity|darkest|||||7|One exception to this rule was the entorhinal cortex (Figs 2, 3, 10, 18-21), where CO reactivity was darkest in layer II, and in layer V in the ventral medial portion of this area (Fig. 10), as we have described previously|Results|cites Hevner & Wong-Riley 1992 (ref. 14)
3|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|entorhinal cortex, ventral medial portion||V|whole layer|adult|CO reactivity|darkest|||||7|where CO reactivity was darkest in layer II, and in layer V in the ventral medial portion of this area (Fig. 10)|Results|
4|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|limb sensorimotor areas (hindlimb and forelimb)||IV|granular zones|adult|CO reactivity|somewhat higher than|dysgranular (or agranular) zones of layer IV||||7|in the limb sensorimotor areas (hindlimb and forelimb), the granular zones of layer IV had somewhat higher CO reactivity than did the dysgranular (or agranular) zones (Fig. 29)|Results|
5|332|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|somatomotor cortex (forelimb/hindlimb border zone)||IV|granular zones|adult|CO reactivity|slightly darker than|dysgranular (or agranular) zones||||7|the aggregates of granule cells (granular zones) in layer IV (A, below arrows) stain slightly darker for CO (B, below arrows) than do the intervening dysgranular (or agranular) zones|Fig. 29 legend|
6|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|primary somatosensory cortex (barrel field)||IV|whisker barrels|adult|CO reactivity|dark|||||7|In the primary somatosensory cortex, whisker barrels were darkly CO-reactive, and were separated by zones of lighter CO reactivity in the barrel septa (Figs 3, 10, 13-16)|Results|
7|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|primary somatosensory cortex (barrel field)||IV|barrel septa|adult|CO reactivity|lighter than|whisker barrels||||7|were separated by zones of lighter CO reactivity in the barrel septa|Results|
8|339|DISCUSSION: Modular and columnar patterns|rat|Sprague-Dawley rat|primary somatosensory cortex (barrel field)||IV|barrel septa|adult|CO reactivity|relatively pale|||||7|Barrel centers were darkly CO-reactive, while barrel septa were relatively pale|Discussion|
9|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|lateral entorhinal cortex||II|cell clusters (CO-reactive islands)|adult|CO reactivity|dark|||||7|In the lateral entorhinal cortex, the cell clusters in layer II formed darkly CO-reactive islands separated by less reactive interstices (Figs 1, 2, 20)|Results|
10|335|RESULTS: Cerebral cortex|rat|Sprague-Dawley rat|lateral entorhinal cortex||II|interstices|adult|CO reactivity|less reactive than|cell-cluster islands||||7|formed darkly CO-reactive islands separated by less reactive interstices|Results|
11|339|DISCUSSION: Modular and columnar patterns|rat|Sprague-Dawley rat|lateral entorhinal cortex||II|neuropil surrounding cell islands|adult|CO reactivity|moderate|||||7|darkly reactive cell islands in layer II were surrounded by moderately reactive neuropil|Discussion|
12|341|DISCUSSION: Comparison with 2-deoxyglucose|rat|Sprague-Dawley rat|cerebral cortex (general)||III and IV|whole layers|adult|metabolic activity by CO and 2-DG|particularly high|||||7|Examples of areas with particularly high metabolic activity by both methods include the habenula, mammillary bodies, interpeduncular nucleus, inferior olive, and cortical layers III and IV|Discussion|concordance statement, CO and 2-DG
13|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|hindlimb and forelimb sensorimotor cortex||all layers (area-level)|whole area|adult|overall CO activity of area|highest|||||7|The highest overall levels of CO activity were seen in the primary sensory and motor areas, including the hindlimb and forelimb sensorimotor cortex (Figs 7-9, 14-16, 29), the primary somatosensory cortex (Figs 3, 10, 13-17), the primary visual cortex (including monocular and binocular subdivisions; Figs 8-10, 19, 20) and the primary auditory cortex (Figs 3, 17, 18)|Results|
14|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|primary somatosensory cortex||all layers (area-level)|whole area|adult|overall CO activity of area|highest|||||7|The highest overall levels of CO activity were seen in the primary sensory and motor areas, including ... the primary somatosensory cortex|Results|
15|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|primary visual cortex (monocular and binocular subdivisions)||all layers (area-level)|whole area|adult|overall CO activity of area|highest|||||7|The highest overall levels of CO activity were seen in the primary sensory and motor areas, including ... the primary visual cortex (including monocular and binocular subdivisions; Figs 8-10, 19, 20)|Results|no layer-by-layer description of Oc1 is printed; the general 'layers III-IV darkest in most areas' rule applies by the authors' wording
16|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|primary auditory cortex||all layers (area-level)|whole area|adult|overall CO activity of area|highest|||||7|The highest overall levels of CO activity were seen in the primary sensory and motor areas, including ... the primary auditory cortex (Figs 3, 17, 18)|Results|p. 332 describes auditory cortex differently (next row)
17|332|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|primary auditory cortex||all layers (area-level)|whole area|adult|overall CO activity of area|somewhat lower than|darkly reactive auditory nuclei||||7|Somewhat lower overall levels of CO activity, focally ranging from low to moderate or high, were present in the medial geniculate nucleus (Figs 3, 9, 18, 19), inferior colliculus (Figs 3-9, 20) and primary auditory cortex (Figs 3, 17)|Results|relative to the darkly reactive auditory brainstem nuclei; apparent tension with p. 335 'highest overall levels'
18|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|piriform cortex (primary olfactory)||all layers (area-level)|whole area|adult|overall CO activity of area|moderate|||||7|the primary olfactory, or piriform cortex (Figs 8-10, 13-17), had only moderate overall CO levels, similar to those in associational and limbic areas|Results|
19|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|retrosplenial cortex||all layers (area-level)|whole area|adult|overall CO activity of area|relatively dark|||||7|The retrosplenial cortex was also relatively dark (Figs 5, 6, 15-20)|Results|listed among limbic areas with uncharacteristically dark CO
20|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|cingulate cortex||all layers (area-level)|whole area|adult|overall CO activity of area|moderate|||||7|the majority of limbic structures contained overall moderate levels of CO reactivity, including the cingulate cortex (Figs 4, 13, 14)|Results|
21|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|hippocampal formation (HC, PaS, PrS, S, CA1, CA3, DG)||all layers (area-level)|whole formation|adult|overall CO activity of area|moderate|||||7|the majority of limbic structures contained overall moderate levels of CO reactivity, including ... the hippocampal formation (HC, PaS, PrS, S, CA1, CA3, DG; Figs 2, 3, 5-9, 15-19)|Results|considerable heterogeneity within, including some darkly stained structures; no stratum-by-stratum CO description is printed
22|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|parietal cortex area 2||all layers (area-level)|whole area|adult|overall CO activity of area|relatively low|other cortical areas||||7|Associational areas of cortex such as parietal cortex area 2 (Figs 3, 14-16), occipital cortex area 2 (Figs 7-10, 17-19) and temporal cortex area 3 (Figs 2, 17-19) were also relatively low in CO reactivity, compared to other cortical areas|Results|
23|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|occipital cortex area 2||all layers (area-level)|whole area|adult|overall CO activity of area|relatively low|other cortical areas||||7|Associational areas of cortex such as parietal cortex area 2 (Figs 3, 14-16), occipital cortex area 2 (Figs 7-10, 17-19) and temporal cortex area 3 (Figs 2, 17-19) were also relatively low in CO reactivity, compared to other cortical areas|Results|
24|334|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|temporal cortex area 3||all layers (area-level)|whole area|adult|overall CO activity of area|relatively low|other cortical areas||||7|Associational areas of cortex such as parietal cortex area 2 (Figs 3, 14-16), occipital cortex area 2 (Figs 7-10, 17-19) and temporal cortex area 3 (Figs 2, 17-19) were also relatively low in CO reactivity, compared to other cortical areas|Results|
25|335|RESULTS: Neural systems / Cerebral cortex (area-level)|rat|Sprague-Dawley rat|cerebral cortex (general)||all layers (area-level)|neuron types: hippocampal CA1 pyramids, dentate granule cells, cerebellar granule cells|adult|CO reactivity of neuron types|pale|||||7|mesencephalic trigeminal and thalamic reticular neurons appeared very dark, while cerebellar granule cells, dentate granule cells and hippocampal CA1 pyramids appeared quite pale|Results|cell-type, not laminar; quantified perikaryal ODs are in Hevner_etal_1995_Figure32
]-"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- trimws(strsplit(line, "|", fixed = TRUE)[[1]])
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g
}

freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

grid_tx <- to_grid(printed_text, 20L)

stopifnot(nrow(grid_tx) == 26L)                      # header + 25 rows
stopifnot(identical(grid_tx[-1, 1], as.character(1:25)))
stopifnot(identical(grid_tx[1, 1], "row"))

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
