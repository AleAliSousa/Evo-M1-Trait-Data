# Hevner_WongRiley_1990_OrdinalLaminar_snapshot.R ------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Hevner & Wong-Riley (1990) "Regulation of
# cytochrome oxidase protein levels by functional activity in the macaque monkey
# visual system", J Neurosci 10: 1331-1340, doi 10.1523/JNEUROSCI.10-04-01331.1990.
#
#   Hevner_WongRiley_1990_OrdinalLaminar_snapshot.csv
#       one row per printed QUALITATIVE statement about cytochrome-oxidase (CO)
#       reactivity of a cortical layer, laminar compartment or area:
#       macaque LGN laminae and striate cortex (V1) layers, normal (7 Macaca
#       fascicularis) and after 3-4 weeks of monocular TTX (3 macaques): RESULTS
#       pp. 1333-1335 and the legends of Figs. 3, 5, 6 (pp. 1334, 1337, 1338).
#       Retina statements are not rowed (outside the V1 / LGN scope).
#
# The laminar content of this paper is ORDINAL: no layer is given an optical
# density anywhere in it (the quantified values the paper does print are in the
# sibling item(s) of this folder). Every row is an ordinal reading of the
# authors' own words (state_as_read = our coding of the printed adjective;
# printed_wording = the sentence or clause it comes from). Follows the
# Preuss_etal_1999 statement-row convention (house precedent for ordinal data).
#
# Words were cross-read from the PDF text layer; laminar adjectives and layer
# labels were checked on page renders of pp. 1333-1335
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
#  * The paper gives NO complete laminar ranking of normal V1: it states only
#    the puff > interpuff contrast (quantified in Table 1), the beaded layer 4A
#    band and a methodological layer 1 / 6 remark. TTX changes are rows with
#    condition = TTX and feature 'CO change after TTX'.
#  * Layer labels as printed (Arabic: 2, 3, 4A/4a, 4C, 5, 6; LGN laminae 1-6).
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
1|1333|RESULTS: Lateral geniculate nucleus|normal macaques|Macaca fascicularis|LGN||cellular laminae 1-6|neuropil and many cell bodies|normal|CO reactivity|dark|||||7|In the normal LGN, CO histochemistry (Fig. 3C) and immunohistochemistry (Fig. 3D) showed similar patterns, with the cellular laminae being darkly reactive throughout the neuropil and in many cell bodies|Results|six cellular laminae separated by zones of white matter
2|1333|RESULTS: Lateral geniculate nucleus|normal macaques|Macaca fascicularis|LGN||lamina 6|superior and medial portions|normal|CO reactivity|relatively dark|||||7|relatively dark reactivity was seen in the superior and medial portions of lamina 6, and in lamina 3, by both histochemistry (Fig. 3C) and immunohistochemistry (Fig. 3D)|Results|intralaminar variation
3|1333|RESULTS: Lateral geniculate nucleus|normal macaques|Macaca fascicularis|LGN||lamina 3|whole lamina|normal|CO reactivity|relatively dark|||||7|relatively dark reactivity was seen in the superior and medial portions of lamina 6, and in lamina 3|Results|
4|1334|RESULTS: Lateral geniculate nucleus|normal macaques|Macaca fascicularis|LGN||lamina 6|superior-medial portion|normal|CO reactivity|darkest|||||7|the superior-medial portion of lamina 6 is darkest stained by both methods|Fig. 3 legend|darkest within the LGN section shown
5|1333|RESULTS: Lateral geniculate nucleus|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|LGN (ipsilateral to the TTX-treated eye)||laminae 2, 3, and 5|whole laminae|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|laminae 1, 4, and 6 (contralateral-eye laminae)||||3|TTX-treated animals showed marked reductions in CO activity (Fig. 3E) and amount (Fig. 3F) in LGN laminae innervated by the treated retina. The LGN shown in Figure 3, E and F, was ipsilateral to the treated retina and had low CO levels in laminae 2, 3, and 5|Results|laminae 2, 3, 5 driven by the ipsilateral retina; 1, 4, 6 by the contralateral retina; effects more striking in the ipsilateral than the contralateral LGN
6|1334|RESULTS: Lateral geniculate nucleus|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|LGN (ipsilateral to the TTX-treated eye)||laminae 2, 3, and 5|whole laminae|TTX (3-4 weeks, left eye)|CO reactivity|pale|||||3|note that laminae 2, 3, and 5 are relatively pale; these laminae received their input from the TTX-treated eye|Fig. 3 legend|printed 'relatively pale'
7|1334|RESULTS: Primary visual cortex|normal macaques|Macaca fascicularis|V1||2 and 3|puffs|normal|CO reactivity|darker than|interpuffs||||7|The puffs are zones of high CO activity in cortical layers 2 and 3 that, despite their high levels of CO activity relative to interpuff regions, appear histologically identical to interpuff regions in a simple Nissl stain|Results|quantified in Hevner_WongRiley_1990_Table1: puffs 1.32 (histochemistry) / 1.19 (immunohistochemistry) x interpuff OD
8|1334|RESULTS: Primary visual cortex|normal macaques|Macaca fascicularis|V1||2 and 3|puffs|normal|CO-rich puffs (activity and protein)|present|||||7|Staining of adjacent normal sections by CO histochemistry (Fig. 4B) and immunohistochemistry (Fig. 4C) revealed that the puffs were enriched in CO protein as well as activity|Results|
9|1334|RESULTS: Primary visual cortex|normal macaques|Macaca fascicularis|V1||4A|whole layer|normal|broken, beaded CO band (cross-section) / reticulated pattern (tangential)|present|||||7|Layer 4A, which is noted for its broken, beaded pattern of CO histochemical staining in cross-section and its reticulated pattern of staining in tangential section, was stained immunohistochemically with those same patterns in both planes of section|Results|
10|1334|RESULTS: Primary visual cortex|normal macaques|Macaca fascicularis|V1||1 and 6|whole layers|normal|immunohistochemical vs histochemical staining intensity|sometimes darker than|the same layers stained histochemically||||7|Another apparent difference was that layers 1 and 6 of the cortex were sometimes more intensely stained immunohistochemically than histochemically (Fig. 4, B, C), but such differences were not seen consistently|Results|methodological, not a laminar CO level; layer 1 possibly edge effects
11|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||4C|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|most reduced|dark (untreated-eye) columns||||3|The decreases in CO protein (and activity) were most prominent in layer 4C|Results|quantified in Hevner_WongRiley_1990_Table1: light columns 0.80 / 0.79 x dark-column OD
12|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||2|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|dark (untreated-eye) columns||||3|but were also visible in layers 2, 3, 4A, 5, and 6|Results|decrease visible but less prominent than in 4C
13|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||3|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|dark (untreated-eye) columns||||3|but were also visible in layers 2, 3, 4A, 5, and 6|Results|decrease visible but less prominent than in 4C
14|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||4A|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|dark (untreated-eye) columns||||3|but were also visible in layers 2, 3, 4A, 5, and 6|Results|decrease visible but less prominent than in 4C
15|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||5|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|dark (untreated-eye) columns||||3|but were also visible in layers 2, 3, 4A, 5, and 6|Results|decrease visible but less prominent than in 4C
16|1335|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1 (treated-eye ocular dominance columns)||6|light columns|TTX (3-4 weeks, left eye)|CO change after TTX|reduced|dark (untreated-eye) columns||||3|but were also visible in layers 2, 3, 4A, 5, and 6|Results|decrease visible but less prominent than in 4C
17|1337|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1||4C and 6|ocular dominance stripes|TTX (3-4 weeks, left eye)|ocular dominance stripes visible by CO|present|||||3|In the experimental cortex, ocular dominance stripes are visible in layers 4C and 6 (arrowheads in D and E) by both histochemistry and immunohistochemistry|Fig. 5 legend|
18|1338|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1||4a|whole layer|TTX (3-4 weeks, left eye)|layer 4a broken into ocular dominance columns|present|||||3|Layer 4a (arrowheads in C and D) is broken into ocular dominance columns in the cortex from the TTX-treated animal|Fig. 6 legend|
19|1338|RESULTS: Primary visual cortex|TTX-treated macaques|TTX-treated macaques (2 M. radiata, 1 M. fascicularis)|V1||2 and 3|puffs (alternating rows)|TTX (3-4 weeks, left eye)|alternating rows of small pale and large dark puffs|present|||||3|In the experimental cortex, note the alternating rows of small, pale puffs and large, dark puffs, visible both histochemically and immunohistochemically|Fig. 6 legend|small pale puffs in treated-eye columns
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

stopifnot(nrow(grid_tx) == 20L)                      # header + 19 rows
stopifnot(identical(grid_tx[-1, 1], as.character(1:19)))
stopifnot(identical(grid_tx[1, 1], "row"))

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
