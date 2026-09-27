## load_dataset_builder.R — single entry point for the _tools/dataset_builder/ layer.
##
## Usage (from any working directory):
##   source("_tools/dataset_builder/load_dataset_builder.R")
##   root <- repo_root()
##   audit_dataset_item(item_dir)
##   build_dataset_item(item_dir, item_name, dry_run = TRUE)
##
## After sourcing, three functions are available in the global environment:
##   validate_dataset_item()  — check 7 invariants for one dataset item
##   audit_dataset_item()     — pre-build 4-file convention + orphan-TSV scan
##   build_dataset_item()     — run the item's build script and validate output
## Plus the helper:
##   repo_root()              — walk up to the directory containing __ReadMe.xlsx

## ---- locate this file's own directory (Rscript / source() / RStudio) -------
## This file is normally source()d FROM a build script, so the innermost
## source() frame -- not Rscript's --file= (that is the calling build script) and
## not sys.frames()[[1]] (the outermost source) -- is the one that points here.
## Checking --file= first made .ldb_dir the caller's paper folder, so the three
## component scripts below were looked for in the wrong directory.
.ldb_dir <- local({
  me <- "load_dataset_builder.R"
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me && file.exists(of))
      return(dirname(normalizePath(of)))
  }
  argv <- commandArgs(FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(dirname(normalizePath(f)))
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(dirname(normalizePath(p)))
  }
  ## last resort: assume the caller's cwd contains this script
  normalizePath(getwd())
})

## ---- source the three component scripts in dependency order -----------------
source(file.path(.ldb_dir, "validate_dataset_item.R"))
source(file.path(.ldb_dir, "audit_dataset_item.R"))
source(file.path(.ldb_dir, "build_dataset_item.R"))

## ---- repo_root() helper -----------------------------------------------------
## Walk up from `from` (default: current working directory) until a directory
## containing __ReadMe.xlsx is found. Returns the path, or NULL (with a
## warning) if the sentinel file is not found.
repo_root <- function(from = getwd()) {
  d <- normalizePath(from, mustWork = FALSE)
  while (dirname(d) != d) {
    if (file.exists(file.path(d, "__ReadMe.xlsx"))) return(d)
    d <- dirname(d)
  }
  warning("__ReadMe.xlsx not found walking up from: ", from)
  invisible(NULL)
}
