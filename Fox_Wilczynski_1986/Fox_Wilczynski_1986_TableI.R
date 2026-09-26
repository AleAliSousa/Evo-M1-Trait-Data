## Fox, J. H., & Wilczynski, W. (1986)
## Allometry of major CNS divisions: towards a reevaluation of somatic
## brain-body scaling. Brain, Behavior and Evolution, 28(4), 157-169.
## Table I. Rodent weight data (means +/- SD)
##
## Input  : Fox_Wilczynski_1986_TableI_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table I, p. 162 of the article PDF)
## Output : Fox_Wilczynski_1986_TableI.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Sample sizes (N) per species/sex
## group are taken from the Materials and Methods text (p. 161), since the
## printed table itself does not repeat N inline.

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
