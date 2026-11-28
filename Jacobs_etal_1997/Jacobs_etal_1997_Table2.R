## Jacobs, Driscoll & Schall (1997). Life-span dendritic and spine changes in
## areas 10 and 18 of human cortex: a quantitative Golgi study. The Journal of
## Comparative Neurology, 386(4), 661-680.
## Table 2. Laminar and Sampled Soma Depths (um) and Soma Size (um2)
##
## Input  : Jacobs_etal_1997_Table2_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table 2, p. 5 of the article PDF)
## Output : Jacobs_etal_1997_Table2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## Printed mean ± SD cells are split and the source matrix is transposed here.

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
stopifnot(ncol(grid) == 5L, nrow(grid) == 10L,
          grepl("^TABLE 2\\.", grid[[1]][1]))
keys <- c("Layer_I_II_junction_um", "Layer_II_III_junction_um",
          "Sampled_soma_depth_um", "Sampled_soma_size_um2",
          "Layer_III_IV_junction_um", "Gray_white_matter_junction_um")
split_cell <- function(x) {
  y <- gsub("[(),]", "", x)
  parts <- strsplit(y, " ± ", fixed = TRUE)[[1]]
  stopifnot(length(parts) == 2L)
  as.integer(parts)
}
rows <- lapply(seq_len(4L), function(j) {
  out <- list(AgeGroup = if (j <= 2L) "Younger(<=50y)" else "Older(>50y)",
              Area = if (j %% 2L) "Area10" else "Area18")
  for (k in seq_along(keys)) {
    v <- split_cell(grid[[j + 1L]][k + 3L])
    out[[paste0(keys[k], "_mean")]] <- v[1]
    out[[paste0(keys[k], "_SD")]] <- v[2]
  }
  as.data.frame(out, check.names = FALSE)
})
dat <- do.call(rbind, rows)

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
