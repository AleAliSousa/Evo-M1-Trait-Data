## Elston, Elston, Casagrande, Kaas, Van Essen & Lund [Elston et al.] (2006).
## Specializations of the granular prefrontal cortex of primates: implications
## for cognitive processing. The Anatomical Record Part A, 288A(1), 26-35.
## Table 1. Cortical surface area (CSA), basal dendritic field area (BDFA)
## and total number of spines (TNS) for pyramidal cells in the primary (V1)
## and second (V2) visual areas and granular prefrontal cortex (gPFC)
##
## Input  : Elston_etal_2006_Table1_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 1, p. 4 of the article PDF)
## Output : Elston_etal_2006_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Each of CSA/BDFA/TNS carries its own
## footnote-letter column pointing to the per-cell literature source cited in
## the table (a-w; see the article's own footnote key). Missing cells in the
## source table (an em dash) are preserved as blank, not zero or NA-inferred.

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

source_grid <- read.csv(
  paste0(item_name, "_snapshot.csv"),
  skip = 2, nrows = 9,
  stringsAsFactors = FALSE,
  check.names = FALSE, colClasses = "character"
)
stopifnot(nrow(source_grid) == 9L)
source_grid$Cortex <- ifelse(nzchar(source_grid$Cortex),
                             source_grid$Cortex, NA_character_)
for (i in seq_len(nrow(source_grid)))
  if (i > 1L && is.na(source_grid$Cortex[i]))
    source_grid$Cortex[i] <- source_grid$Cortex[i - 1L]
source_species <- names(source_grid)[-(1:2)]
measure <- function(cell) {
  if (is.na(cell) || cell == "—") return(c(NA_character_, NA_character_))
  parts <- strsplit(cell, "\\^", fixed = FALSE)[[1]]
  c(parts[1], if (length(parts) > 1L) parts[2] else NA_character_)
}
rows <- lapply(unique(source_grid$Cortex), function(cortex) {
  block <- source_grid[source_grid$Cortex == cortex, , drop = FALSE]
  lapply(source_species, function(species) {
    cells <- lapply(block[[species]], measure)
    data.frame(Cortex = cortex, Species = species,
               CSA = as.numeric(cells[[1]][1]), CSA_Ref = cells[[1]][2],
               BDFA = as.numeric(cells[[2]][1]), BDFA_Ref = cells[[2]][2],
               TNS = as.numeric(cells[[3]][1]), TNS_Ref = cells[[3]][2])
  })
})
dat <- do.call(rbind, unlist(rows, recursive = FALSE))
stopifnot(nrow(dat) == 21L)

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
