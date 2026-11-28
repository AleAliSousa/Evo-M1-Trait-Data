## Elston, Benavides-Piccione & DeFelipe (2001). The pyramidal cell in
## cognition: a comparative study in human and monkey. The Journal of
## Neuroscience, 21:RC163 (1-5).
## Table 1. Peak branching complexity, size, and spine density of the basal
## dendrites of layer III pyramidal cells
##
## Input  : Elston_etal_2001_Table1_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 1, p. 2 of the article PDF)
## Output : Elston_etal_2001_Table1.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed; peak branching complexity, basal
## dendritic field area, and maximum spine density are carried through as
## printed for each of 3 species x 3 cortical regions.

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
metric <- rep(NA_character_, nrow(dat))
for (i in seq_len(nrow(dat))) {
  if (dat[[1L]][i] %in% c("Peak branching complexity (mean ± SD)",
                            "Basal dendritic field areas (× 10⁴ µm²) (mean ± SD)",
                            "Maximum spine density per 10 µm (mean ± SEM)")) {
    metric[i] <- dat[[1L]][i]
  } else if (i > 1L) metric[i] <- metric[i - 1L]
}
keep <- dat[[1L]] %in% c("Marmoset", "Macaque", "Human")
source_rows <- dat[keep, , drop = FALSE]
metric <- metric[keep]
species_order <- c("Marmoset", "Macaque", "Human")
region_order <- c("Occipital", "Temporal", "Prefrontal")
split_cell <- function(x) as.numeric(trimws(strsplit(x, "±", fixed = TRUE)[[1L]]))
out <- list()
for (sp in species_order) for (region in region_order) {
  row <- list(Species = sp, Region = region)
  for (m in seq_len(3L)) {
    val <- split_cell(source_rows[source_rows[[1L]] == sp & metric == unique(metric)[m], region][[1L]])
    stem <- c("Peak_branching_complexity", "Basal_dendritic_field_area_1e4um2",
              "Max_spine_density_per_10um")[m]
    row[[paste0(stem, "_mean")]] <- val[1L]
    row[[paste0(stem, if (m == 3L) "_SEM" else "_SD")]] <- val[2L]
  }
  out[[length(out) + 1L]] <- row
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
