## Bianchi, Stimpson, Bauernfeind, Schapiro, Baze, McArthur, Bronson, Hopkins,
## Semendeferi, Jacobs, Hof & Sherwood (2012)
## Dendritic morphology of pyramidal neurons in the chimpanzee neocortex:
## regional specializations and comparison to humans
## Table 1. Demographic information for chimpanzee (N=7) and human samples (N=8)
##
## Input  : Bianchi_etal_2012_Table1_snapshot.csv (printed species blocks,
##          column positions, caption and footnote from Table 1)
## Output : Bianchi_etal_2012_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed; age, sex, post-mortem interval (PMI),
## and length of fixation are carried through as printed.

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

source <- read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                   stringsAsFactors = FALSE, check.names = FALSE,
                   colClasses = "character", na.strings = character())
stopifnot(nrow(source) == 20L, ncol(source) == 5L,
          source[3, 1] == "Chimpanzee #", source[11, 1] == "Human #")
data_rows <- c(4:10, 12:19)
dat <- data.frame(
  Species = c(rep("Chimpanzee", 7L), rep("Human", 8L)),
  Individual = as.integer(source[data_rows, 1]),
  Age_years = as.integer(source[data_rows, 2]),
  Sex = source[data_rows, 3],
  PMI_h = gsub("∼", "~", source[data_rows, 4], fixed = TRUE),
  Length_of_fixation = source[data_rows, 5],
  stringsAsFactors = FALSE
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
