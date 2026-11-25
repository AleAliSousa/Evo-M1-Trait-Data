#!/usr/bin/env Rscript
# check_compiled_current.R
# -----------------------------------------------------------------------------
# Is __compiled/compiled_long.csv.gz -- the ONE table both apps read -- what the
# merges and keys in this checkout produce today?
#
# Both apps take every trait value from that file, so a merge that was rebuilt
# without rebuilding the file changes nothing the apps show, and nothing else
# says so. This check rebuilds the table into a temporary folder with
# __compiled/build_compiled.R and compares it with the committed file. It reads
# and reports; it never replaces the committed file.
#
# The comparison is on the unzipped content (the CSV text), not the .gz bytes,
# so a different zlib on another machine cannot fail it.
#
# Exit non-zero if the committed file is missing or differs.
# Fix: Rscript __compiled/build_compiled.R   (or Rscript __ShinyApp/build_data.R,
# which runs it), then commit __compiled/compiled_long.csv.gz.
#
#   Rscript _checks/check_compiled_current.R [repo]
# -----------------------------------------------------------------------------

.self_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else getwd()
})
.args <- commandArgs(trailingOnly = TRUE)
repo  <- normalizePath(if (length(.args) >= 1) .args[1] else file.path(.self_dir, ".."))
committed <- file.path(repo, "__compiled", "compiled_long.csv.gz")
builder   <- file.path(repo, "__compiled", "build_compiled.R")
fail <- function(...) { cat("FAIL: ", ..., "\n", sep = ""); quit(status = 1, save = "no") }

if (!file.exists(builder))   fail("__compiled/build_compiled.R not found in ", repo)
if (!file.exists(committed)) fail("__compiled/compiled_long.csv.gz does not exist. Run: Rscript __compiled/build_compiled.R")

tmp <- tempfile("compiled_check_"); dir.create(tmp); on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
log <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                c(shQuote(builder), shQuote(repo), shQuote(tmp)),
                                stdout = TRUE, stderr = TRUE))
rebuilt <- file.path(tmp, "compiled_long.csv.gz")
if (!is.null(attr(log, "status")) && attr(log, "status") != 0 || !file.exists(rebuilt))
  fail("the rebuild itself failed, so the committed file cannot be checked:\n  ",
       paste(utils::tail(log, 6), collapse = "\n  "))

# unzipped content, as lines of raw text (no re-encoding)
content <- function(f) {
  con <- gzfile(f, open = "rb"); on.exit(close(con))
  x <- tryCatch(readLines(con, warn = FALSE, encoding = "bytes"), error = function(e) NULL)
  if (is.null(x)) return(NULL)
  Encoding(x) <- "bytes"; x
}
old <- content(committed); new <- content(rebuilt)
if (is.null(old) || !length(old)) fail("__compiled/compiled_long.csv.gz is not a readable gzip file.")

if (identical(old, new)) {
  cat(sprintf("OK: __compiled/compiled_long.csv.gz is current (%d rows; rebuilt content identical).\n",
              length(new) - 1L))
  ## the data points of the one route, written beside the table by the same build
  dp_old <- file.path(repo, "__compiled", "datapoints.csv.gz"); dp_new <- file.path(tmp, "datapoints.csv.gz")
  if (file.exists(dp_new)) {
    if (!file.exists(dp_old)) fail("__compiled/datapoints.csv.gz does not exist. Run: Rscript __compiled/build_compiled.R")
    a <- content(dp_old); b <- content(dp_new)
    if (!identical(a, b)) fail("__compiled/datapoints.csv.gz is STALE (committed ", length(a) - 1L, " rows, rebuilt ",
                               length(b) - 1L, "). Run: Rscript __compiled/build_compiled.R  and commit it.")
    cat(sprintf("OK: __compiled/datapoints.csv.gz is current (%d data points).\n", length(b) - 1L))
  }
  quit(status = 0, save = "no")
}
n <- min(length(old), length(new))
differ <- which(old[seq_len(n)] != new[seq_len(n)])
cat(sprintf("committed: %d rows   rebuilt now: %d rows\n", length(old) - 1L, length(new) - 1L))
if (length(differ))
  cat(sprintf("%d line(s) differ in place; first at line %d:\n  committed: %s\n  rebuilt:   %s\n",
              length(differ), differ[1], substr(old[differ[1]], 1, 300), substr(new[differ[1]], 1, 300)))
fail("__compiled/compiled_long.csv.gz is STALE: it is not what the merges and keys in this checkout ",
     "produce. Run: Rscript __compiled/build_compiled.R  and commit the file.")
