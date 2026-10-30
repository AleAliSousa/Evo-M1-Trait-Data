#!/usr/bin/env Rscript
# parity_R_vs_py.R
# -----------------------------------------------------------------------------
# TEMPORARY SCAFFOLDING. Delete this together with the .py files it compares.
#
# One check was written in Python and has now been ported to R:
#
#     _checks/check_laterality_doubling.{py,R}
#
# (A second pair, check_body_ecology_against_fixture, was ported the same day and
# then retired outright a few hours later -- both sides now sit in
# _archive/body_ecology_fixture_check_20260820/, so there is nothing left to
# compare there.)
#
# The port was written in a sandbox with no R, so it has never been executed.
# This runs the pair against the same inputs and diffs their stdout and exit
# status, which is the evidence needed before the .py can go. It is the same
# method the 2026-08-07 builder retirement used -- prove agreement, then delete
# one side. See _checks/R_vs_python_builders.md for that precedent.
#
#     Rscript _checks/parity_R_vs_py.R
#
# Exit 0 if every pair agrees. On disagreement the two outputs are written to
# a temp directory and the differing lines printed.
#
# NOT a general R-vs-Python harness: it only knows about these two pairs, and it
# exists to be thrown away.
#
# ONE KNOWN FALSE ALARM. In check_laterality_doubling, the detail string for the
# "no author-doubled column is skipped" FAIL is built by iterating a Python SET,
# whose order is arbitrary; the R iterates in registry order. If that single line
# is the only difference AND both sides report the same number of skips, the two
# agree. Every other line is order-stable in both.
#
# WHY THE PORTS EXIST AT ALL. Python in this repo is fine when it is a labelled
# offline MIRROR of a canonical .R -- that is what __merging_trees/build_mammal_tree.py
# is, and it should stay. These two were different: Python was the only
# implementation of a check the R merges cite by name, which put a check the
# pipeline depends on in a language the pipeline does not otherwise use.
# -----------------------------------------------------------------------------

HERE <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(dirname(normalizePath(f)))
  normalizePath(getwd())
})
REPO <- dirname(HERE)

PAIRS <- list(
  list(r = "_checks/check_laterality_doubling.R",
       py = "_checks/check_laterality_doubling.py")
)

## Run and capture stdout + exit status. stderr is deliberately dropped: R and
## Python word their startup and warning noise differently, and neither check
## carries meaning there.
run <- function(cmd, args) {
  out <- suppressWarnings(system2(cmd, args, stdout = TRUE, stderr = FALSE))
  st  <- attr(out, "status")
  list(lines = as.character(out), status = if (is.null(st)) 0L else as.integer(st))
}
## Trailing whitespace is not a disagreement.
norm <- function(lines) sub("[ \t]+$", "", lines)

tmp <- file.path(tempdir(), "parity_R_vs_py")
dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
failures <- 0L

for (p in PAIRS) {
  rp  <- file.path(REPO, p$r)
  pyp <- file.path(REPO, p$py)
  cat(sprintf("\n%s\n", basename(p$r)))
  if (!file.exists(rp) || !file.exists(pyp)) {
    cat("  SKIP   one side is missing (already retired?)\n")
    next
  }

  a <- run("Rscript", shQuote(rp))
  b <- run("python3", shQuote(pyp))
  la <- norm(a$lines); lb <- norm(b$lines)

  same_status <- a$status == b$status
  same_text   <- identical(la, lb)

  cat(sprintf("  exit status   R=%d  py=%d   %s\n", a$status, b$status,
              if (same_status) "match" else "DIFFER"))
  cat(sprintf("  stdout        %d vs %d line(s)   %s\n", length(la), length(lb),
              if (same_text) "identical" else "DIFFER"))

  if (!same_text) {
    fa <- file.path(tmp, paste0(basename(p$r), ".R.out"))
    fb <- file.path(tmp, paste0(basename(p$r), ".py.out"))
    writeLines(la, fa); writeLines(lb, fb)
    n <- max(length(la), length(lb))
    shown <- 0L
    for (i in seq_len(n)) {
      x <- if (i <= length(la)) la[i] else "<no line>"
      y <- if (i <= length(lb)) lb[i] else "<no line>"
      if (!identical(x, y)) {
        shown <- shown + 1L
        if (shown <= 10L) {
          cat(sprintf("    line %d\n      R : %s\n      py: %s\n", i, x, y))
        }
      }
    }
    if (shown > 10L) cat(sprintf("    ... and %d more differing line(s)\n", shown - 10L))
    cat(sprintf("    full output: %s\n                 %s\n", fa, fb))
  }

  if (!same_status || !same_text) failures <- failures + 1L
}

cat("\n")
if (failures) {
  cat(sprintf("%d pair(s) disagree -- do NOT delete the .py yet.\n", failures))
  cat("Check the known false alarm in this script's header before treating it as a real difference.\n")
} else {
  cat("The pair agrees. Safe to retire:\n")
  cat("  rm _checks/check_laterality_doubling.py\n")
  cat("  rm _checks/parity_R_vs_py.R                  # this file\n")
  cat("\nThen update the three comments that still name the .py:\n")
  cat("  __merging_volumes/volumes_compiled.R\n")
  cat("  __merging_volumes/volumes_compiled_DeCasien.R\n")
  cat("  __merging_volumes/volumes_compiled_select.R\n")
}
if (!interactive()) quit(status = if (failures) 1L else 0L)
