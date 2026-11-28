## Jacobs, Schall, Prather, Kapler, Driscoll, Baca, Jacobs, Ford, Wainwright &
## Treml (2001). Regional dendritic and spine variation in human cerebral
## cortex: a quantitative Golgi study. Cerebral Cortex, 11(6), 558-571.
## Table 2. Laminar and sampled soma depths (um) and soma size (um2)
##
## Input  : Jacobs_etal_2001_Table2_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 2, p. 4 of the article PDF)
## Output : Jacobs_etal_2001_Table2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Laminar/soma depths (um) and soma
## size (um2) are carried through as printed (mean +/- SD), summarized by
## integration level (Low = primary + unimodal regions; High = heteromodal +
## supramodal regions), per the table's own footnote a.

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
  check.names = FALSE,
  colClasses = "character"
)
source_rows <- dat
parse_cell <- function(x) as.numeric(trimws(strsplit(x, "±", fixed = TRUE)[[1L]]))
vals <- lapply(source_rows[-1L], function(col) t(vapply(col, parse_cell, numeric(2L))))
dat <- data.frame(IntegrationLevel = c("Low", "High"), check.names = FALSE)
stems <- c("Layer_I_II_junction_um", "Layer_II_III_junction_um",
           "Sampled_soma_depth_um", "Sampled_soma_size_um2",
           "Layer_III_IV_junction_um", "Gray_white_matter_junction_um")
for (i in seq_along(stems)) {
  dat[[paste0(stems[i], "_mean")]] <- c(vals[[1L]][i, 1L], vals[[2L]][i, 1L])
  dat[[paste0(stems[i], "_SD")]] <- c(vals[[1L]][i, 2L], vals[[2L]][i, 2L])
}

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
