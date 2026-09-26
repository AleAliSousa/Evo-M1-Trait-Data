## Elston (2000). Pyramidal cells of the frontal lobe: all the more spinous
## to think with. The Journal of Neuroscience, 20:RC95 (1-4).
##
## No printed table in this paper. Figure 2 (panels A-C: basal dendritic
## field area, branching complexity, and spine density, by cortical area) is
## a set of plots/frequency distributions with no per-point values or axis
## data printed. However, several summary statistics ARE stated as explicit
## numbers in the running Results text (not read off the figure), for basal
## dendritic field area (areas 10, 11, 12), maximum branch count at 75 um
## from the soma (areas 10, 11), and total estimated basal-dendritic-field
## spine count per "average" neuron (areas 10, 11, 12, V1, 7a, TE).
##
## Input  : Elston__2000_Figure2_snapshot.csv (hand-transcribed from the
##          stated sentences in the Results section, p. 2 of the PDF)
## Output : Elston__2000_Figure2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## What is NOT included: the continuous Sholl branching curves, the
## per-distance spine-density curves, and the frequency-distribution
## histograms in Figure 2 itself -- these have no printed per-point values or
## axis data and would require digitizing the plot, which this build does not
## attempt (per the same policy applied to Fritsches_etal_2005_Fig2 and the
## Halley_Krubitzer_2019_Figure1 documented skip). Field-area means/SDs for
## V1, 7a, and TE are also not printed as numbers in the text (only
## significance, "p < 0.01"), so those cells are blank rather than inferred.

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
