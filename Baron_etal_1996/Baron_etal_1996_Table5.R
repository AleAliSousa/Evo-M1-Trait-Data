## Baron, G., Stephan, H., & Frahm, H. D. (1996)
## Comparative Neurobiology in Chiroptera: Macromorphology, Brain Structures,
## Tables, and Atlases. Birkhauser. ISBN 978-3-7643-5370-4.
## Table 5. Average body weights (BoW) and brain weights (BrW) of 342
## species and/or subspecies of bats. (PDF pp. 22-32, printed pp. 284-294)
##
## Input  : Baron_etal_1996_Table5_snapshot.csv (frozen transcription; see
##          Baron_etal_1996_Table5_extract.py for the reproducible extraction
##          pipeline and Baron_etal_1996_Table5.README.md for the full record)
## Output : Baron_etal_1996_Table5.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## Only the first ("standard"/bold-faced) line per species is built - the
## table's own notes state this line "includes the pairs of body and brain
## weights used to establish the standards." Sex-differentiated sub-lines
## (males/females/median inter sexes) and additional literature-comparison
## values printed below a species' first line are the source's own supporting
## detail for that same standard value and are not transcribed as separate
## rows, per the registry's own caution to avoid double-counting multi-line
## sex rows.
##
## No numeric re-derivation is performed.

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) {
    d <- dirname(d)
  }
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

setwd(folder)

snapshot <- read.csv(
  paste0(item_name, "_snapshot.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE,
  encoding = "UTF-8"
)

## The snapshot preserves the source's own printed family/subfamily section
## headings as their own rows (is_header == "TRUE"), and indents
## species_printed to mirror the printed page's family/subfamily/species
## visual hierarchy, so the frozen snapshot reads as a faithful mirror of
## the printed table for a human skimming it. The analysis CSV/public TSV
## are species data only and unindented: header rows are dropped,
## species_printed has its leading hierarchy-indent whitespace trimmed,
## species_row is renumbered 1..342 over species rows alone, and columns
## are restored to this item's original (pre-header-preservation) order.
dat <- snapshot[snapshot$is_header != "TRUE", ]
dat$species_printed <- trimws(dat$species_printed)
dat$species_row <- seq_len(nrow(dat))
dat <- dat[, c("species_row", "source_pdf_page", "species_printed",
               "BoW_g", "CV_BoW_pct", "BrW_mg", "CV_BrW_pct",
               "n_BoW", "n_BrW", "Source")]

message("Section headers preserved in snapshot: ", sum(snapshot$is_header == "TRUE"))

csv_file <- paste0(item_name, ".csv")

write.csv(
  dat,
  csv_file,
  row.names = FALSE,
  na = ""
)

message("Rows: ", nrow(dat))
message("CSV: ", basename(csv_file))

if (!is.na(base)) {

  filecodes <- readxl::read_excel(
    file.path(base, "__ReadMe.xlsx")
  )

  item_encoded <- filecodes$`Item encoded`[
    match(item_name, filecodes$`Item name`)
  ]

  if (!is.na(item_encoded) && nzchar(item_encoded)) {

    write.table(
      dat,
      file.path(
        base,
        "__Public",
        "comparative-data",
        paste0(item_encoded, ".tsv")
      ),
      sep = "\t",
      row.names = FALSE,
      quote = TRUE,
      na = ""
    )

    message("Wrote public file: ", item_encoded, ".tsv")
  }
}
