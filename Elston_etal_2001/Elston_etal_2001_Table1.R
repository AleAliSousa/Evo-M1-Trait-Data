## Elston, Benavides-Piccione & DeFelipe (2001). The pyramidal cell in
## cognition: a comparative study in human and monkey. The Journal of
## Neuroscience, 21:RC163 (1-5).
## Table 1. Peak branching complexity, size, and spine density of the basal
## dendrites of layer III pyramidal cells
##
## Input  : Elston_etal_2001_Table1_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 1, p. 2 of the article PDF)
## Output : Elston_etal_2001_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed; peak branching complexity, basal
## dendritic field area, and maximum spine density are carried through as
## printed for each of 3 species x 3 cortical regions.

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
