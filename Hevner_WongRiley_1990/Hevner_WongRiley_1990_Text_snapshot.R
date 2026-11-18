# Hevner_WongRiley_1990_Text_snapshot.R ----------------------------------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of the CO densitometry values that
# Hevner & Wong-Riley (1990), Journal of Neuroscience 10(4): 1331-1340
# (doi 10.1523/JNEUROSCI.10-04-01331.1990) print only in running text:
#
#   Hevner_WongRiley_1990_Text_snapshot.csv   RESULTS, "Densitometric analyses",
#                                         p. 1335 right column (PDF page 5) and
#                                         p. 1337 left column, top (PDF page 7)
#
# There is no printed table for these values: the paper states the puff/interpuff
# enrichment and the TTX light/dark-column decline as percentages in prose
# (Table 1 prints the underlying relative optical densities; see the Table1 item).
# Following __HOWTO_make_a_snapshot.md "When there is no table", the snapshot is a
# table WE construct: one row per printed value, with the journal page, the
# location, and the sentence it comes from quoted verbatim. The significance
# statement that follows each sentence is kept in its own column.
#
# The OCR text layer of this scanned paper breaks digits ("2 1%", "0.00 1") so the
# values were read from 200-dpi page renders (zoomed crops of the two passages),
# HOWTO method 5. This script writes the frozen file and refuses to overwrite a
# frozen copy that differs; the build script READS it. No cleaning happens here.
#
# Transcribed and checked by an AI assistant (Claude) on 2026-11-18.
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

printed_text <- "
text_row|page|location|passage_as_printed|value_printed|units_printed|subjects_as_printed|region_as_printed|stain_method_as_printed|significance_as_printed|cited_ref
1|1335|RESULTS, Densitometric analyses, right column|Puffs stained histochemically were 32% darker than interpuffs, while puffs stained immunohistochemically were 19% darker than interpuffs.|32|% darker than interpuffs|normal cortex|puff and interpuff optical densities were read in histochemically and immunohistochemically stained tangential sections of normal cortex|histochemically|In both cases, staining differences between puffs and interpuffs were significant (p < 0.001).|
2|1335|RESULTS, Densitometric analyses, right column|Puffs stained histochemically were 32% darker than interpuffs, while puffs stained immunohistochemically were 19% darker than interpuffs.|19|% darker than interpuffs|normal cortex|puff and interpuff optical densities were read in histochemically and immunohistochemically stained tangential sections of normal cortex|immunohistochemically|In both cases, staining differences between puffs and interpuffs were significant (p < 0.001).|
3|1337|RESULTS, Densitometric analyses, left column (top)|Light-column (low in CO) staining density was 20% decreased relative to dark-column (high in CO) staining density in histochemically stained sections; in immunohistochemically stained sections, the decrease was 21%.|20|% decreased relative to dark-column staining density|TTX-treated animals|the optical densities of dark and light columns in cortical layer 4C were read in sections from TTX-treated animals|histochemically|Differences between light- and dark-column staining densities were significant (p < 0.001) by both methods.|
4|1337|RESULTS, Densitometric analyses, left column (top)|Light-column (low in CO) staining density was 20% decreased relative to dark-column (high in CO) staining density in histochemically stained sections; in immunohistochemically stained sections, the decrease was 21%.|21|% decreased relative to dark-column staining density|TTX-treated animals|the optical densities of dark and light columns in cortical layer 4C were read in sections from TTX-treated animals|immunohistochemically|Differences between light- and dark-column staining densities were significant (p < 0.001) by both methods.|
"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
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

grid_tx <- to_grid(printed_text, 11L)
stopifnot(nrow(grid_tx) == 5L, identical(grid_tx[-1, 1], as.character(1:4)),
          identical(grid_tx[-1, 5], c("32", "19", "20", "21")))

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
