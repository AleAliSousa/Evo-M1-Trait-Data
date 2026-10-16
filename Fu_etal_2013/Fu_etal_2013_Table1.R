## Fu, Rusznak, Herculano-Houzel, Watson & Paxinos (2013)
## Table 1. Age-dependent changes affecting the mouse central nervous system and pituitary
##
## Input  : Fu_etal_2013_Table1_snapshot.xlsx  (frozen snapshot; pre-transcribed from the article PDF)
## Output : Fu_etal_2013_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## The workbook is a hand-transcribed, verbatim copy of the printed Table 1 (7 structures,
## 6 metrics x 3 age-comparison windows = 18 data columns of significance-direction symbols).
## Output codes direction and significance tier as signed integers from -3 to +3; this is
## not an effect-size scale. The frozen snapshot retains the printed symbols verbatim.

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  source_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
  if (!is.null(source_file) && nzchar(source_file)) return(normalizePath(source_file))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    source_file <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(source_file)) source_file <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(source_file)) return(normalizePath(source_file))
  }
  stop("Run with Rscript file.R, source(file.R), or from a saved RStudio editor tab.", call. = FALSE)
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
  paste0(item_name, "_snapshot.xlsx"),
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

## Encode the printed symbol legend as a signed direction/significance score:
##   +1/+2/+3 = increase at p < 0.05/0.01/0.001
##    0        = no statistically significant change
##   -1/-2/-3 = decrease at p < 0.05/0.01/0.001
## NA remains not applicable. The score magnitude is not an effect size.
symbol_score <- c(
  "↑" = 1L, "↑↑" = 2L, "↑↑↑" = 3L,
  "–" = 0L,
  "↓" = -1L, "↓↓" = -2L, "↓↓↓" = -3L
)

data_columns <- setdiff(names(dat), "Structure")
observed_symbols <- unique(unlist(lapply(dat[data_columns], as.character)))
unknown_symbols <- setdiff(observed_symbols, c(names(symbol_score), "NA", "", NA_character_))

if (length(unknown_symbols)) {
  stop("Unknown Table 1 symbol(s): ", paste(unknown_symbols, collapse = ", "), call. = FALSE)
}

dat[data_columns] <- lapply(dat[data_columns], function(x) {
  x <- as.character(x)
  score <- unname(symbol_score[x])
  score[is.na(x) | x == "" | x == "NA"] <- NA_integer_
  as.integer(score)
})

csv_file <- paste0(item_name, ".csv")

write.csv(
  dat,
  csv_file,
  row.names = FALSE,
  na = "NA"
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
      na = "NA"
    )

    message("Wrote public file: ", item_encoded, ".tsv")
  }
}
