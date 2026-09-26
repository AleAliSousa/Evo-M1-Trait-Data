## Hakeem, A. Y., Hof, P. R., Sherwood, C. C., Switzer, R. C., III,
## Rasmussen, L. E. L., & Allman, J. M. (2005)
## Brain of the African elephant (Loxodonta africana): Neuroanatomy from
## magnetic resonance images. The Anatomical Record Part A, 287A, 1117-1127.
## Table 2. Elephant brain volume measurements
##
## Input  : Hakeem_etal_2005_Table2_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 2, p. 1126 of the article PDF)
## Output : Hakeem_etal_2005_Table2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. This is a single-specimen table
## (one adult female African elephant); no replicate/SD values are printed.

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
