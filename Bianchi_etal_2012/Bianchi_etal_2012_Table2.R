## Bianchi, Stimpson, Bauernfeind, Schapiro, Baze, McArthur, Bronson, Hopkins,
## Semendeferi, Jacobs, Hof & Sherwood (2012)
## Dendritic morphology of pyramidal neurons in the chimpanzee neocortex:
## regional specializations and comparison to humans
## Table 2. Dependent measures in areas 3b, 4, 18, and 10 in chimpanzees and humans
##
## Input  : Bianchi_etal_2012_Table2_snapshot.csv (printed measure rows by
##          area columns, with separate chimpanzee and human blocks)
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

source <- read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                   stringsAsFactors = FALSE, check.names = FALSE,
                   colClasses = "character", na.strings = character())
stopifnot(nrow(source) == 19L, ncol(source) == 5L,
          source[3, 1] == "Chimpanzee", source[12, 1] == "Human")
keys <- c("Cell_soma_area_um2", "Cell_soma_depth_um", "TDL_um", "MSL_um",
          "DSC", "DSN", "DSD", "Dendritic_trees_count")
parse_pair <- function(x) {
  parts <- strsplit(x, "\\s*±\\s*")[[1]]
  stopifnot(length(parts) == 2L)
  as.numeric(parts)
}
out <- list()
for (species in c("Chimpanzee", "Human")) {
  first <- if (species == "Chimpanzee") 4L else 13L
  n_measures <- if (species == "Chimpanzee") 8L else 7L
  for (area in seq_len(4L)) {
    record <- list(Species = species, Area = c("Area3b", "Area4", "Area18", "Area10")[area])
    for (measure in seq_len(8L)) {
      value <- if (measure <= n_measures) parse_pair(source[first + measure - 1L, area + 1L]) else c(NA_real_, NA_real_)
      record[[paste0(keys[measure], "_mean")]] <- value[1]
      record[[paste0(keys[measure], "_SD")]] <- value[2]
    }
    out[[length(out) + 1L]] <- record
  }
}
dat <- do.call(rbind.data.frame, c(out, stringsAsFactors = FALSE))

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
