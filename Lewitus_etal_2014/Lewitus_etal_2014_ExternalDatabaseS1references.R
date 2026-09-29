# Lewitus_etal_2014_ExternalDatabaseS1references.R
#
# Lewitus et al. 2014 -- External Database S1, numbered reference list -> CSV + TSV
#   doi:10.1371/journal.pbio.1002000   (supplement pbio.1002000.s021.doc)
#
# SNAPSHOT build. The source is a Word 97-2003 document, not a machine-readable
# table: the reference numbers are EndNote field results and R cannot read a .doc.
# The snapshot freezes the document's text layer verbatim (field results kept,
# field codes dropped); this script reads ONLY the snapshot.
#
# Snapshot layout (sheet "References"): row 1 the document title, row 2 the printed
# intro paragraph (it names refs 1-15 and 16 as dataset-wide sources), row 3 column
# labels (added: the printed list has none), then one row per reference -- the
# number as printed ("1.") and the citation as printed.
#
# Cleaning removes EndNote export artefacts only; wording, typos and punctuation stay:
#   " (Translated from eng)"   removed wherever it occurs
#   " (in eng)."               removed at the end of a citation, with its full stop
#   runs of spaces             squeezed to one (refs 55 and 79 carry four)
#
# Input  : Lewitus_etal_2014_ExternalDatabaseS1references_snapshot.xlsx   sheet: References
# Outputs: Lewitus_etal_2014_ExternalDatabaseS1references.csv             one row per reference (88)
#          <Item encoded>.tsv in __Public/comparative-data/               named from __ReadMe.xlsx
# Next   : Lewitus_etal_2014_ExternalDatabaseS1variablesources.R reads this CSV for citations.
# Checks : restricted repo, restricted_checks/Lewitus_etal_2014/comparison/ (source audit,
#          per-species provenance and neocortex attribution).

library(readxl)
options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_file  <- paste0(item_name, "_snapshot.xlsx")
snapshot_sheet <- "References"
header_rows    <- 3L   # title, intro paragraph, column labels

## ---- read the snapshot (all text, untrimmed: cleaning is done explicitly below) ----
raw <- suppressMessages(read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE,
                                   col_types = "text", trim_ws = FALSE))
dat <- as.data.frame(raw[-seq_len(header_rows), 1:2], stringsAsFactors = FALSE)
names(dat) <- c("no_printed", "citation_printed")
dat <- dat[!is.na(dat$no_printed) & nzchar(trimws(dat$no_printed)), ]

clean_citation <- function(x) {
  x <- gsub(" \\(Translated from [^)]*\\)", "", x, perl = TRUE)
  x <- sub(" \\(in [A-Za-z]+\\)\\.$", "", x, perl = TRUE)
  x <- gsub("[ \t]+", " ", x, perl = TRUE)
  trimws(x)
}

final.dataframe <- data.frame(
  ref_number = as.integer(sub("\\.$", "", trimws(dat$no_printed))),
  citation   = clean_citation(dat$citation_printed),
  stringsAsFactors = FALSE
)
if (!identical(final.dataframe$ref_number, seq_len(nrow(final.dataframe))))
  stop("Reference numbers are not 1..n in order; check the snapshot.", call. = FALSE)
if (any(grepl("Translated from|\\(in [A-Za-z]+\\)", final.dataframe$citation)))
  warning("An EndNote artefact survived cleaning; check the snapshot.")

## ---- SAVE: local CSV + DOI-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE, fileEncoding = "UTF-8")
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " references)")

tsv_dir <- if (!is.na(base)) file.path(base, "__Public/comparative-data") else NA_character_
item_encoded <- if (!is.na(base)) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
