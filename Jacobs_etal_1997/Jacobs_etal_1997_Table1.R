## Jacobs, Driscoll & Schall (1997). Life-span dendritic and spine changes in
## areas 10 and 18 of human cortex: a quantitative Golgi study. The Journal of
## Comparative Neurology, 386(4), 661-680.
## Table 1. Subject Summary
##
## Input  : Jacobs_etal_1997_Table1_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 1, p. 3 of the article PDF)
## Output : Jacobs_etal_1997_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Body weight and autolysis time are
## carried through as printed; blank cells correspond to an em dash in the
## source (value not reported for that subject).

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

grid <- read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                 stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", na.strings = character(0))
stopifnot(ncol(grid) == 5L, nrow(grid) == 30L,
          grepl("^TABLE 1\\.", grid[[1]][1]))
body <- grid[3:28, , drop = FALSE]
subject <- body[[1]]
dat <- data.frame(
  Subject = subject,
  Sex = substr(subject, 1L, 1L),
  Age_years = as.integer(sub("^[MF]([0-9]+).*", "\\1", subject)),
  Body_weight_kg = suppressWarnings(as.numeric(body[[2]])),
  Autolysis_time_h = suppressWarnings(as.numeric(body[[3]])),
  Cause_of_death = body[[4]],
  Occupation_education = body[[5]],
  Ethnicity = ifelse(subject == "M69.2", "Hispanic",
                     ifelse(subject == "F106", "African-American", "Caucasian")),
  stringsAsFactors = FALSE, check.names = FALSE
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
