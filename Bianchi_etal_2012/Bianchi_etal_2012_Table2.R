## Bianchi, Stimpson, Bauernfeind, Schapiro, Baze, McArthur, Bronson, Hopkins,
## Semendeferi, Jacobs, Hof & Sherwood (2012)
## Dendritic morphology of pyramidal neurons in the chimpanzee neocortex:
## regional specializations and comparison to humans
## Table 2. Dependent measures in areas 3b, 4, 18, and 10 in chimpanzees and humans
##
## Input  : Bianchi_etal_2012_Table2_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 2, p. 4 of the article PDF)
## Output : Bianchi_etal_2012_Table2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed; cell soma area/depth, total dendritic
## length (TDL), mean segment length (MSL), dendritic segment count (DSC),
## dendritic spine number (DSN), dendritic spine density (DSD), and dendritic
## tree count are carried through as printed (dendritic-tree counts reported
## for chimpanzees only; not reported for humans in this table).

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
