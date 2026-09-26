## Baron, G., Stephan, H., & Frahm, H. D. (1996)
## Comparative Neurobiology in Chiroptera: Macromorphology, Brain Structures,
## Tables, and Atlases. Birkhauser. ISBN 978-3-7643-5370-4.
## Table 2. Linear measures of brains in mm (PDF pp. 4-11, printed pp. 266-273)
##
## Input  : Baron_etal_1996_Table2_snapshot.csv (frozen transcription; see
##          Baron_etal_1996_Table2_extract.py for the reproducible extraction
##          pipeline and Baron_etal_1996_Table2.README.md for the full record)
## Output : Baron_etal_1996_Table2.csv
##          __Public/comparative-data/<Item encoded>.tsv
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
