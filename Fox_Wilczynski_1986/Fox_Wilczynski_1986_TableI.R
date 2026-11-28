## Fox, J. H., & Wilczynski, W. (1986)
## Allometry of major CNS divisions: towards a reevaluation of somatic
## brain-body scaling. Brain, Behavior and Evolution, 28(4), 157-169.
## Table I. Rodent weight data (means +/- SD)
##
## Input  : Fox_Wilczynski_1986_TableI_snapshot.csv (hand-transcribed, verbatim
##          copy of the printed Table I, p. 162 of the article PDF)
## Output : Fox_Wilczynski_1986_TableI.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## No numeric re-derivation is performed. Sample sizes (N) per species/sex
## group are taken from the Materials and Methods text (p. 161), since the
## printed table itself does not repeat N inline.

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

stopifnot(nrow(dat) == 5L, ncol(dat) == 7L)
labels <- c("F mouse", "M mouse", "M gerbil", "M hamster", "FSD rat")
stopifnot(identical(dat$Species, labels))
split_pm <- function(x) {
  pieces <- strsplit(as.character(x), "\\s*±\\s*")
  stopifnot(all(lengths(pieces) == 2L))
  cbind(as.numeric(vapply(pieces, `[`, "", 1)),
        as.numeric(vapply(pieces, `[`, "", 2)))
}
parts <- lapply(dat[-1], split_pm)
# Sex, sample size, and the expanded species labels come from the Methods
# paragraph, not from columns in the printed table.
dat <- data.frame(
  Species = c("Mouse (CD-1)", "Mouse (CD-1)", "Mongolian gerbil", "Hamster", "Sprague-Dawley rat"),
  Sex = c("F", "M", "M", "M", "F"), N = c(22L, 22L, 8L, 17L, 8L),
  Body_weight_g = parts[[1]][,1], Body_weight_SD_g = parts[[1]][,2],
  WB_weight_g = parts[[2]][,1], WB_weight_SD_g = parts[[2]][,2],
  BS_weight_g = parts[[3]][,1], BS_weight_SD_g = parts[[3]][,2],
  CB_weight_g = parts[[4]][,1], CB_weight_SD_g = parts[[4]][,2],
  FB_weight_g = parts[[5]][,1], FB_weight_SD_g = parts[[5]][,2],
  SCA_mm2 = parts[[6]][,1], SCA_SD_mm2 = parts[[6]][,2],
  stringsAsFactors = FALSE
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
