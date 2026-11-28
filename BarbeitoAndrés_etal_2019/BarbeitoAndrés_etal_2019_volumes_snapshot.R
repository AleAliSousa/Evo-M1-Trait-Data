# Rebuild the volumes source-grid CSV and TSV snapshots from data_figshare.xlsx.
args <- commandArgs(FALSE)
script <- sub("^--file=", "", grep("^--file=", args, value = TRUE)[1])
if (is.na(script) || !nzchar(script)) stop("Run with Rscript file.R")
helper <- file.path(dirname(normalizePath(script)), "_snapshot_source_grid.py")
status <- system2("python3", c(shQuote(helper), "volumes"))
if (status != 0L) stop("Source-grid snapshot build failed")
