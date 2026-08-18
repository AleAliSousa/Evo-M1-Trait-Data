#!/usr/bin/env Rscript
# Build the frozen snapshot for Bortoff & Strick (1993) - Table 1 (curated).
#
#   Bortoff, G. A., & Strick, P. L. (1993). Corticospinal terminations in two New-World
#   primates: further evidence that corticomotoneuronal connections provide part of the
#   neural substrate for manual dexterity. J Neurosci 13(12):5105-5118.
#   DOI 10.1523/JNEUROSCI.13-12-05105.1993.
#   PDF in this folder: Bortoff_Strick_1993.pdf (open-access copy retrieved from Europe PMC
#   on 2026-08-15, SHA-256 bbb7baad6b0777f600e973dbd0911a5540ec7868528b5446fe1ae654e6f81e0c).
#
# WHY THIS SNAPSHOT LOOKS DIFFERENT FROM THE OTHERS
# -------------------------------------------------
# The paper prints NO species x trait table. The comparative result lives in the Results
# prose and in Figures 3-11: for each of the two species the authors describe where the
# corticospinal terminal field sits in the spinal grey. So there is no printed table to
# reproduce faithfully, and the frozen copy is instead a CURATORIAL capture - one row per
# species, each cell traceable to a named page or figure of the PDF.
#
# It is still a snapshot in the sense that matters (__HOWTO_build_a_dataset_file.md
# invariant 1): it is frozen, hand-verified against the PDF, and every downstream value is
# reproducible from it. Nothing is cleaned, resolved or converted here - species-name
# harmonisation happens in Bortoff_Strick_1993_Table1.R through _keys/Stephan/species_key.csv
# (invariant 3 / sec 5), never in this file.
#
# CODING RUBRIC for CST_termination_grade (deliberately coarse - three levels only):
#   0  absent or virtually absent from ventral horn / lamina IX
#   1  sparse or highly restricted ventral-horn / lamina IX termination
#   2  dense and extensive ventral-horn / lamina IX termination
#
# CM_monosynaptic is left BLANK for both species on purpose. The paper states outright
# (Discussion, pp. 5110-5111) that light-microscopic terminal fields cannot establish the
# presence or absence of a direct monosynaptic contact. The authors' softer reading is kept
# separately in CM_connection_inference ("likely" / "against") so an inference is never
# promoted to a fact.
#
# Replaces create_snapshot.mjs, which required the @oai/artifact-tool runtime and could not
# be re-run inside this repo.
#
# Run:  Rscript Bortoff_Strick_1993/Bortoff_Strick_1993_extract_snapshot.R

suppressWarnings(suppressMessages(library(openxlsx)))

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
paper_dir <- dirname(.sp)
out_xlsx  <- file.path(paper_dir, "Bortoff_Strick_1993_Table1_snapshot.xlsx")

## ---- the curated rows -------------------------------------------------------
## NOTE: the printed species name is kept EXACTLY as the paper prints it ("Cebus apella").
## The modern combination (Sapajus apella) is NOT written here - it is resolved downstream
## from species_key.csv under the Bortoff1993 token.
snap <- data.frame(
  Species_printed = c("Cebus apella", "Saimiri sciureus"),
  CST_termination_grade = c(2L, 1L),
  CM_monosynaptic = c(NA, NA),
  CM_connection_inference = c("likely", "against"),
  Segment_summary = c(
    "C8-T1: dense/extensive lamina IX and ventral-horn terminations",
    "C8-T1: sparse at best; termination mainly in two intermediate-zone regions"),
  Method = rep("WGA-HRP anterograde tract tracing from primary motor cortex", 2),
  Source = rep("Bortoff & Strick 1993", 2),
  DOI = rep("10.1523/JNEUROSCI.13-12-05105.1993", 2),
  Source_location = c(
    "Abstract; Results pp. 5108-5111; Figures 3, 5-11",
    "Abstract; Results pp. 5109-5111; Figures 4, 6, 10-11"),
  Evidence_summary = c(
    "Three termination zones; the ventral-horn projection is dense and extensively overlaps lamina IX at C8-T1.",
    "Two main intermediate-zone termination fields; lamina IX labeling is absent or sparse and highly restricted."),
  Curatorial_note = c(
    "Anatomical terminal fields support, but do not prove, a monosynaptic CM connection.",
    "The paper argues against a CM connection but notes that light microscopy cannot establish monosynaptic absence."),
  stringsAsFactors = FALSE)

stopifnot(nrow(snap) == 2, all(snap$CST_termination_grade %in% 0:2))

## ---- write ------------------------------------------------------------------
wb <- createWorkbook()
addWorksheet(wb, "Table1", gridLines = FALSE)
writeData(wb, "Table1", snap, headerStyle = createStyle(
  fgFill = "#1F4E78", fontColour = "#FFFFFF", textDecoration = "bold",
  wrapText = TRUE, valign = "center", border = "TopBottomLeftRight",
  borderColour = "#B4C6E7", borderStyle = "thin"))
addStyle(wb, "Table1", createStyle(fgFill = "#F7FAFC", wrapText = TRUE, valign = "top",
                                   border = "TopBottomLeftRight",
                                   borderColour = "#D9E2F3", borderStyle = "thin"),
         rows = 2:(nrow(snap) + 1), cols = seq_along(snap), gridExpand = TRUE)
addStyle(wb, "Table1", createStyle(halign = "center"), rows = 2:(nrow(snap) + 1),
         cols = 2:3, gridExpand = TRUE, stack = TRUE)
setColWidths(wb, "Table1", cols = seq_along(snap),
             widths = c(18, 18, 18, 20, 34, 34, 24, 34, 42, 58, 58))
setRowHeights(wb, "Table1", rows = 1, heights = 36)
freezePane(wb, "Table1", firstRow = TRUE)
saveWorkbook(wb, out_xlsx, overwrite = TRUE)

cat(sprintf("snapshot written: %s (%d rows x %d cols)\n", basename(out_xlsx),
            nrow(snap), ncol(snap)))
