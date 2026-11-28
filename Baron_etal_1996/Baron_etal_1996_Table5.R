## Baron, G., Stephan, H., & Frahm, H. D. (1996)
## Comparative Neurobiology in Chiroptera: Macromorphology, Brain Structures,
## Tables, and Atlases. Birkhauser. ISBN 978-3-7643-5370-4.
## Table 5. Average body weights (BoW) and brain weights (BrW) of 342
## species and/or subspecies of bats. (PDF pp. 22-32, printed pp. 284-294)
##
## Input  : Baron_etal_1996_Table5_snapshot.csv (frozen transcription; see
##          Baron_etal_1996_Table5_snapshot.R for the reproducible extraction
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

## The snapshot sketches all printed lines, including family headings and the
## sex-specific / literature-comparison sublines. The analysis map identifies
## only the 342 bold standard rows; its original_order controls output order.
grid <- read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                 colClasses = "character", na.strings = NULL,
                 stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
analysis_map <- read.csv(file.path("reference_tables", paste0(item_name, "_analysis_map.csv")),
                         stringsAsFactors = FALSE)
stopifnot(nrow(analysis_map) == 342L,
          identical(analysis_map$analysis_order, seq_len(342L)),
          all(analysis_map$source_grid_row <= nrow(grid)))
standard <- grid[analysis_map$source_grid_row, , drop = FALSE]
num <- function(x) suppressWarnings(as.numeric(x))
dat <- data.frame(species_row = analysis_map$analysis_order,
                  source_pdf_page = analysis_map$source_pdf_page,
                  species_printed = trimws(standard[[1]]),
                  BoW_g = num(standard[[2]]),
                  CV_BoW_pct = num(standard[[3]]),
                  BrW_mg = num(standard[[4]]),
                  CV_BrW_pct = num(standard[[5]]),
                  n_BoW = num(standard[[6]]),
                  n_BrW = num(standard[[7]]),
                  Source = standard[[8]], stringsAsFactors = FALSE)
if (nrow(dat) != 342L || any(is.na(dat$species_printed) | !nzchar(dat$species_printed)))
  stop("Baron_etal_1996_Table5: expected 342 named species rows after dropping headers, got ", nrow(dat), call. = FALSE)
message("Printed grid rows retained in snapshot: ", nrow(grid))

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
