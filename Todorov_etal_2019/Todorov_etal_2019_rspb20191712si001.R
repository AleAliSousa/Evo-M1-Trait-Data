#!/usr/bin/env Rscript

# Build the public, publication-supplied sexual-dimorphism table.
# This script never reads the restricted Frahm specimen files.

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script_file <- normalizePath(sub("^--file=", "", script_arg[[1]]))
source_dir <- dirname(script_file)

archive <- file.path(source_dir, "rspb20191712_si_001.zip")
inner_file <- "dimorphdata.csv"
output <- file.path(source_dir, "Todorov_etal_2019_rspb20191712si001.csv")

if (!file.exists(archive)) stop("Missing source archive: ", archive)
if (!inner_file %in% unzip(archive, list = TRUE)$Name) {
  stop("The source archive does not contain ", inner_file)
}

x <- read.csv(
  unz(archive, inner_file),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

expected_columns <- c(
  "Species", "BoW", "BrW", "BrVol", "VEN", "REST", "NET", "OBL",
  "CER", "MES", "DIE", "TEL", "BOL", "PAL", "SEP", "STR", "SCH",
  "HIP", "NEO", "TOT"
)

stopifnot(
  identical(names(x), expected_columns),
  nrow(x) == 12L,
  !anyDuplicated(x$Species),
  all(vapply(x[-1], is.numeric, logical(1)))
)

write.csv(x, output, row.names = FALSE, na = "")
message("wrote ", output, " (", nrow(x), " species x ", ncol(x) - 1L,
        " dimorphism variables)")
