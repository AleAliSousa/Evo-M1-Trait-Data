# WongRiley_etal_1993_OrdinalLaminar_snapshot.R --------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Wong-Riley, Hevner, Cutlan, Earnest,
# Egan, Frost & Nguyen (1993) "Cytochrome oxidase in the human visual cortex:
# Distribution in the developing and the adult brain", Visual Neuroscience 10:
# 41-58, doi 10.1017/S0952523800003217.
#
#   WongRiley_etal_1993_OrdinalLaminar_snapshot.csv
#       one row per printed QUALITATIVE statement about cytochrome-oxidase (CO)
#       reactivity of a cortical layer, laminar compartment or area:
#       human V1 (fetal zones at 26 weeks; at birth; postnatal day 24; 4 months;
#       adult: I, II/III puffs and interpuffs, IVa, IVb, IVc, IVcα, IVcβ, V, VI),
#       V2 (birth, adult) and extrastriate occipital cortex (adult): RESULTS
#       pp. 42-49 and the legends of Figs. 1 and 4.
#
# The laminar content of this paper is ORDINAL: no layer is given an optical
# density anywhere in it (the quantified values the paper does print are in the
# sibling item(s) of this folder). Every row is an ordinal reading of the
# authors' own words (state_as_read = our coding of the printed adjective;
# printed_wording = the sentence or clause it comes from). Follows the
# Preuss_etal_1999 statement-row convention (house precedent for ordinal data).
#
# Words were cross-read from the PDF text layer; laminar adjectives and layer
# labels were checked on page renders of pp. 42, 44, 45, 47, 49
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
#  * Greek sublayer subscripts are written IVcα / IVcβ (the OCR layer drops
#    them); their identity was read from the page image (p. 44).
#  * The Fig. 1 legend calls the 26-week cortical plate 'dark' while the Results
#    text calls it 'moderately reactive'; both rows are kept and cross-noted.
#  * Developmental stages are separate rows (condition column), as the task
#    requires; n per stage from METHODS p. 42 (24 adults, 2 newborns, 1 each
#    for the fetus, day-24 and 4-month infants).
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
1|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||ventricular zone|whole zone|26 weeks of gestation|CO reactivity|light|||||1|CO staining is light in the ventricular (VZ) and subventricular (SV) zones|Fig. 1 legend|
2|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||subventricular zone|whole zone|26 weeks of gestation|CO reactivity|light|||||1|CO staining is light in the ventricular (VZ) and subventricular (SV) zones|Fig. 1 legend|
3|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||intermediate zone|lower part|26 weeks of gestation|CO reactivity|moderate|||||1|moderate in the lower intermediate zone (IZ)|Fig. 1 legend|
4|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||intermediate zone|upper part|26 weeks of gestation|CO reactivity|dark|||||1|dark in the upper IZ and the cortical plate (CP)|Fig. 1 legend|
5|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||cortical plate|whole plate|26 weeks of gestation|CO reactivity|dark|||||1|dark in the upper IZ and the cortical plate (CP)|Fig. 1 legend|the Results text (p. 44) calls the cortical plate 'moderately reactive' (next row): legend and text disagree
6|44|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||cortical plate|whole plate|26 weeks of gestation|CO reactivity|moderate|||||1|The cortical plate itself was moderately reactive for CO, as were most of its neurons, while a few neurons had higher levels of CO|Results|conflicts with the Fig. 1 legend 'dark'; both kept
7|42|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||marginal zone|whole zone|26 weeks of gestation|CO reactivity|light|||||1|and light again in the marginal zone (MZ)|Fig. 1 legend|text p. 44: primarily neuropil labeling with a few reactive neurons in the cell-rich portion
8|44|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||ventricular and subventricular zones|whole zones|26 weeks of gestation|CO reactivity|light|||||1|Both the ventricular and subventricular zones had relatively low levels of CO|Results|printed 'relatively low'; coded light
9|44|RESULTS: Prenatal development|human|human|occipital lobe (future V1)||intermediate zone|neuropil (several tiers)|26 weeks of gestation|CO reactivity|moderate|||||1|The intermediate zone exhibited moderate levels of CO activity mainly in the neuropil, and appeared to be subdivided into several tiers separated by less-reactive bands|Results|
10|44|RESULTS: Neonatal visual cortex|human|human|V1||IVc|whole layer (dense band)|at birth (2 and 3 days)|CO reactivity|dark|||||2|lamina IVc, which measured 0.4 mm wide, was highlighted by a dense band of CO staining|Results|legend p. 42: 'lamina IVc is darkly stained by either CO histochemistry (F) or CO immunohistochemistry (G)'
11|44|RESULTS: Neonatal visual cortex|human|human|V1||IVcα|whole sublayer|at birth (2 and 3 days)|CO reactivity|darker than|IVcβ (major part)||||2|Lamina IVcα, and often the base of IVcβ, were more darkly reactive than the major part of IVcβ, which was densely packed with cells|Results|quantified in Hevner_WongRiley_1993_Text row 27: IVcβ proper 7% lower than IVcα (P < 0.01)
12|44|RESULTS: Neonatal visual cortex|human|human|V1||IVcβ|base of sublayer|at birth (2 and 3 days)|CO reactivity|darker than|IVcβ (major part)||||2|Lamina IVcα, and often the base of IVcβ, were more darkly reactive than the major part of IVcβ|Results|'often'
13|44|RESULTS: Neonatal visual cortex|human|human|V1||IVb|whole layer|at birth (2 and 3 days)|CO reactivity|light|||||2|Lamina IVb was lightly reactive for CO|Results|
14|44|RESULTS: Neonatal visual cortex|human|human|V1||IVa|whole layer|at birth (2 and 3 days)|CO-dense band in IVa|absent|||||2|there was no discernible band of reactivity in IVa, which is so prominent in the monkey striate cortex|Results|
15|44|RESULTS: Neonatal visual cortex|human|human|V1||VI|whole layer (especially upper half)|at birth (2 and 3 days)|CO reactivity|moderate|||||2|Lamina VI, especially its upper half, was moderately reactive|Results|
16|44|RESULTS: Neonatal visual cortex|human|human|V1||V|whole layer|at birth (2 and 3 days)|CO reactivity|light-to-moderate|||||2|while laminae V, III, II, and I were only light-to-moderately reactive|Results|
17|44|RESULTS: Neonatal visual cortex|human|human|V1||III|whole layer|at birth (2 and 3 days)|CO reactivity|light-to-moderate|||||2|while laminae V, III, II, and I were only light-to-moderately reactive|Results|
18|44|RESULTS: Neonatal visual cortex|human|human|V1||II|whole layer|at birth (2 and 3 days)|CO reactivity|light-to-moderate|||||2|while laminae V, III, II, and I were only light-to-moderately reactive|Results|
19|44|RESULTS: Neonatal visual cortex|human|human|V1||I|whole layer|at birth (2 and 3 days)|CO reactivity|light-to-moderate|||||2|while laminae V, III, II, and I were only light-to-moderately reactive|Results|
20|44|RESULTS: Neonatal visual cortex|human|human|V1||I|inner third|at birth (2 and 3 days)|CO reactivity|least reactive|||||2|The inner third of lamina I was the least reactive|Results|least reactive of the layers listed
21|44|RESULTS: Neonatal visual cortex|human|human|V1||II-III|supragranular puffs|at birth (2 and 3 days)|CO-rich supragranular puffs (orderly array)|absent|||||2|we did not see an orderly array of supragranular CO-rich puffs observable in slightly later stages of development|Results|
22|47|RESULTS: The second visual cortical area (V2)|human|human|V2||III to mid IV|globular zones|at birth (2 and 3 days)|CO reactivity|dark|||||2|globular zones of high CO activity were sometimes observed in the adjacent secondary visual area of V2 (Fig. 4A). These zones extended from lamina III to mid lamina IV|Results|printed 'high'; coded dark; sometimes merged into a continuous zone (Fig. 4B,D)
23|47|RESULTS: The second visual cortical area (V2)|human|human|V2||III and IV|whole layers|at birth (2 and 3 days)|CO reactivity|dark|||||2|high CO reactivity predominates in layers III and the cell-dense layer IV of V2|Fig. 4 legend|printed 'high'; coded dark
24|44|RESULTS: Postnatal visual cortex|human|human|V1||II-III|supragranular puffs|postnatal day 24|CO-rich supragranular puffs|present|||||1|At postnatal day 24, supragranular puffs were readily observed (Fig. 1J)|Results|smaller and more variable than adult; no row patterning
25|44|RESULTS: Postnatal visual cortex|human|human|V1||IVcα|whole sublayer|postnatal day 24|CO reactivity|darker than|IVcβ||||1|Lamina IVcα remained more darkly reactive that IVcβ|Results|printed 'that' (sic, 'than')
26|44|RESULTS: Postnatal visual cortex|human|human|V1||V|whole layer|postnatal day 24|CO reactivity|light|||||1|lamina V and VI retained their respective light and moderate levels of reactivity (not shown)|Results|
27|44|RESULTS: Postnatal visual cortex|human|human|V1||VI|whole layer|postnatal day 24|CO reactivity|moderate|||||1|lamina V and VI retained their respective light and moderate levels of reactivity (not shown)|Results|
28|44|RESULTS: Postnatal visual cortex|human|human|V1||I|whole layer|fourth postnatal month|CO reactivity|light|||||1|Lamina I (0.15 mm) remained lightly stained for CO, except for the pial border which might have an artifactual accumulation of reaction product|Results|
29|44|RESULTS: Postnatal visual cortex|human|human|V1||IVcα|whole sublayer|fourth postnatal month|CO reactivity|lower than|IVcβ||||1|IVcα had optical densitometric values for CO that were 10% lower than those of IVcβ, and this difference was statistically significant (P < 0.01)|Results|quantified in WongRiley_etal_1993_Text row 36
30|44|RESULTS: Postnatal visual cortex|human|human|V1||IVb|whole layer|fourth postnatal month|CO reactivity|light|||||1|Lamina IVb (0.19 mm) remained lightly reactive|Results|
31|44|RESULTS: Postnatal visual cortex|human|human|V1||IVa|whole layer|fourth postnatal month|CO-dense band in IVa|absent|||||1|lamina IVa was again not discernable in CO-reacted sections|Results|
32|44|RESULTS: Postnatal visual cortex|human|human|V1||V|whole layer|fourth postnatal month|CO reactivity|light|||||1|Lamina V (0.33 mm) was lightly reactive while lamina VI (0.51 mm) was moderate to darkly reactive|Results|
33|44|RESULTS: Postnatal visual cortex|human|human|V1||VI|whole layer|fourth postnatal month|CO reactivity|moderate-to-dark|||||1|Lamina V (0.33 mm) was lightly reactive while lamina VI (0.51 mm) was moderate to darkly reactive|Results|
34|44|RESULTS: Postnatal visual cortex|human|human|V1||II-III|supragranular puffs|fourth postnatal month|CO-rich supragranular puffs|present|||||1|CO-rich supragranular puffs were prominent at this age and were regularly arrayed|Results|
35|42|RESULTS: Postnatal visual cortex|human|human|V1||IVcβ|whole sublayer|fourth postnatal month|CO reactivity|slightly darker than|IVcα||||1|IVcβ is now slightly more darkly reactive than IVcα|Fig. 1 legend|Fig. 1K; 4 months
36|44|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||I|whole layer|adult|CO reactivity|light|||||24|Lamina I (approximately 0.2 mm) was rather lightly reactive|Results|printed 'rather lightly'
37|44|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||II/III|puffs|adult|CO reactivity|darker than|interpuffs||||24|Laminae II/III (0.75-0.77 mm) were decorated with a regular array of CO-reactive puffs against the less-reactive interpuffs|Results|puffs best differentiated in lower II and through the depth of III; often extend to the top of II and across IVb to the top of IVc (p. 45)
38|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||II/III|interpuffs|adult|CO reactivity|less reactive than|puffs||||24|a regular array of CO-reactive puffs against the less-reactive interpuffs|Results|
39|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||IVa|whole layer|adult|CO-distinct layer IVa|absent|||||24|Layer IVa was discernible in Nissl preparation (Fig. 2A), but was not demonstrable as a distinct layer in CO-histochemical (Fig. 2B) or immunohistochemical sections (Fig. 2C)|Results|even tangential sections failed to reveal the monkey honeycomb pattern
40|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||IVb|whole layer|adult|CO reactivity|similar to|interpuff areas||||24|The lack of a distinct lamina IVa in CO preparations indirectly obscured the upper boundary of IVb (0.11-0.16 mm), which tended to blend in with interpuff areas|Results|no absolute level printed for adult IVb; it 'blends' with the interpuffs
41|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||IVc|whole layer|adult|CO reactivity|darkest|||||24|Lamina IVc was the most darkly reactive|Results|most darkly reactive layer of adult V1
42|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||IVcα|whole sublayer|adult|CO reactivity|less reactive than|IVcβ||||24|but IVcα (0.21-0.27 mm) was less reactive than IVcβ (0.3-0.35 mm)|Results|quantified: 5-14% lower OD in every adult case (WongRiley_etal_1993_Text row 61)
43|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||IVcβ|lower half to three-fourths|adult|CO reactivity|darkest|||||24|with the lower half to three-fourths of IVcβ being the darkest (Figs. 2B and 2C)|Results|darkest sub-band of the darkest layer
44|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||V|whole layer|adult|CO reactivity|light-to-moderate|||||24|Lamina V (0.16-0.24 mm) was again light-to-moderately reactive|Results|
45|45|RESULTS: Adult primary visual cortex (area 17)|human|human|V1||VI|whole layer|adult|CO reactivity|moderate-to-dark|||||24|and lamina VI (0.3-0.48 mm) was moderate-to-darkly reactive|Results|
46|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|V1||IVc|whole layer|adult|CO reactivity|dark|||||24|V1 showed the characteristic CO pattern of supragranular puffs, darkly reactive layer IVc, and moderately reactive layer VI|Results|restatement
47|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|V1||VI|whole layer|adult|CO reactivity|moderate|||||24|V1 showed the characteristic CO pattern of supragranular puffs, darkly reactive layer IVc, and moderately reactive layer VI|Results|restatement; p. 45 says 'moderate-to-darkly'
48|47|RESULTS: The second visual cortical area (V2)|human|human|V2||III|band (background to globular zones)|adult|CO reactivity|moderate|||||24|Superimposed upon a moderately reactive band in layer III of V2 were puff-like globular zones of high CO activity|Results|
49|47|RESULTS: The second visual cortical area (V2)|human|human|V2||lower II to mid IV|globular zones (islands within stripes)|adult|CO reactivity|dark|||||24|puff-like globular zones of high CO activity extending from lower II to mid layer IV, and they were organized into stripes perpendicular to the V1/V2 border (Figs. 4F-4G)|Results|printed 'high'; coded dark; stripes not always demarcated into thin and thick
50|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|V2||III and IV|globular zones|adult|CO reactivity|dark|||||24|the dark band in IVc abruptly ended, and CO-rich globular zones decorated mainly layers III and IV of V2|Results|printed 'CO-rich'; coded dark
51|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|extrastriate (single-asterisk zone anterior to V2)||III and IV|whole layers (continuous)|adult|CO reactivity|dark|||||24|Cytochrome-oxidase activity remained high in layers III and IV, but the pattern was much more continuous than that in the adjacent portion of V2|Results|printed 'high'; coded dark; area identity undetermined
52|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|extrastriate (double-asterisk gyrus; Brodmann area 19)||III and IV|whole layers (continuous)|adult|CO reactivity|dark|||||24|Cytochrome oxidase remained high in layers III and IV, where the staining was again more continuous than globular|Results|printed 'high'; coded dark
53|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|extrastriate (anteriormost occipital lobe; four asterisks)||III/IV|whole layers|adult|CO reactivity|lightest|||||24|the anteriormost portion having the lightest reactivity for CO|Results|lightest among the occipital areas compared
54|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|occipital lobe (entire, V1 to anterior extrastriate)||VI|whole layer|adult|CO reactivity|moderate|||||24|The infragranular layer VI of the entire occipital lobe often assumed a moderate level of CO staining, while layer V tended to be less reactive for CO|Results|'often'
55|49|RESULTS: Comparison of striate and extrastriate cortical areas|human|human|occipital lobe (entire, V1 to anterior extrastriate)||V|whole layer|adult|CO reactivity|less reactive than|VI||||24|The infragranular layer VI of the entire occipital lobe often assumed a moderate level of CO staining, while layer V tended to be less reactive for CO|Results|
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

stopifnot(nrow(grid_tx) == 56L)                      # header + 55 rows
stopifnot(identical(grid_tx[-1, 1], as.character(1:55)))
stopifnot(identical(grid_tx[1, 1], "row"))

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
