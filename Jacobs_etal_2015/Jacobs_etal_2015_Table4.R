## Jacobs et al. (2015) - The neocortex of cetartiodactyls II: neuronal morphology
## of visual and motor cortices in the giraffe (Giraffa camelopardalis)
## Table 4. Demographics of species in pyramidal neuron comparisons
##
## Input  : Jacobs_etal_2015_Table4_snapshot.csv  (hand-transcribed, verbatim copy
##          of the printed Table 4, p. 2868 of the PDF)
## Output : Jacobs_etal_2015_Table4.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## Table 4 reports per-species sample demographics (age/sex, fixation method,
## region sampled, mean soma depth/size, mean brain mass, and pyramidal-neuron
## count) for the five-species cross-species comparison (giraffe plus four
## comparison species from other published studies). No numeric re-derivation
## is performed; values are carried through as printed, arranged by species
## (rows) instead of the paper's printed by-species columns.

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

dat <- read.csv(
  paste0(item_name, "_snapshot.csv"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

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
