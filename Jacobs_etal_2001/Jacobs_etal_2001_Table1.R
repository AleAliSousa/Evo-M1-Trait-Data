## Jacobs, Schall, Prather, Kapler, Driscoll, Baca, Jacobs, Ford, Wainwright &
## Treml (2001). Regional dendritic and spine variation in human cerebral
## cortex: a quantitative Golgi study. Cerebral Cortex, 11(6), 558-571.
## Table 1. Subject summary
##
## Input  : Jacobs_etal_2001_Table1_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 1, p. 2 of the article PDF)
## Output : Jacobs_etal_2001_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Body weight and autolysis time are
## carried through as printed; blank cells correspond to an em dash in the
## source (value not reported for that subject). Per the table's own
## footnote, BA10 tissue from all subjects except F11 and F15 was used
## previously in Jacobs et al. (1997) -- this item does not re-flag which
## individual rows overlap; see the source footnote for that detail.

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
