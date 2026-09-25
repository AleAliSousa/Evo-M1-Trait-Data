## Fu, Rusznak, Herculano-Houzel, Watson & Paxinos (2013)
## Table 1. Age-dependent changes affecting the mouse central nervous system and pituitary
##
## Input  : Fu_etal_2013_Table1.xlsx  (frozen snapshot; pre-transcribed from the article PDF)
## Output : Fu_etal_2013_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## The workbook is a hand-transcribed, verbatim copy of the printed Table 1 (7 structures,
## 6 metrics x 3 age-comparison windows = 18 data columns of significance-direction symbols).
## No numeric re-derivation is performed; the arrows/dashes/NA codes are carried through as-is.

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

dat <- readxl::read_excel(
  paste0(item_name, ".xlsx"),
  sheet = "Sheet1",
  col_names = FALSE
)

## Flatten the two-row printed header (metric name row + age-window row) into single
## column names of the form <Metric>_wk<start>to<end>.
metrics <- c(
  "Mass", "NumNeurons", "NumNonNeurons",
  "DensityNeurons", "DensityNonNeurons", "NNNratio"
)
windows <- c("wk4to15", "wk15to40", "wk4to40")

col_names <- c(
  "Structure",
  unlist(lapply(metrics, function(m) paste0(m, "_", windows)))
)

dat <- dat[3:nrow(dat), ]
names(dat) <- col_names

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
