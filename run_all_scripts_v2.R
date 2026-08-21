## Run every ingest/check script in the repo under Rscript and log the outcome.
##
## Usage
##   Rscript run_all_scripts_v2.R                  # full sweep
##   EVOM1_ONLY='merging_volumes' Rscript run_all_scripts_v2.R   # only matching paths
##
## Statuses written to _checks/script_execution_log.csv
##   NOT_RUN  pre-filled; still NOT_RUN after the run == the sweep was interrupted here
##   RUNNING  in flight at the moment the log was last written
##   SUCCESS  exit status 0
##   FAILED   non-zero exit status; stdout+stderr captured in `error`
##   TIMEOUT  exceeded TIMEOUT_SEC (exit 124)
##   SKIPPED  matched SKIP_PATTERNS -- never executed (see `error` for the reason)

## project root = nearest ancestor containing __ReadMe.xlsx (clone-safe; Rscript/source/RStudio)
.script_path <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(normalizePath(f))
  sf <- tryCatch(normalizePath(sys.frames()[[1]]$ofile), error = function(e) NULL)
  if (!is.null(sf) && nzchar(sf)) return(sf)
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  normalizePath(getwd())
})
root_dir <- local({
  d <- if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d
  else if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
})
checks_dir <- file.path(root_dir, "_checks")
dir.create(checks_dir, showWarnings = FALSE, recursive = TRUE)

TIMEOUT_SEC <- 300

## ---- scripts that must never run unattended -------------------------------
## Each entry is a regex matched against the repo-relative path, plus the reason
## recorded in the log so a SKIPPED row is self-explaining.
SKIP_PATTERNS <- c(
  "(^|/)run_all_scripts"        = "this runner",
  "(^|/)safely_guard_setwd"     = "sourced helper, not a standalone script",
  "(^|/)update_shinyapp\\.R$"   = "publishes to shinyapps.io (rsconnect::deployApp)",
  "^__ShinyApp/app\\.R$"        = "ends in shinyApp(); blocks forever under Rscript",
  "(^|/)__edit_all_directories\\.R$" = "mass find/replace + rename utility; run deliberately, not in a sweep",
  ## list.files() below is recursive from the repo root, so a retired script would
  ## keep running -- and keep failing -- for as long as it sat in _archive/.
  "^_archive/"                  = "retired; kept for the record, not for running",
  ## Sourced libraries, not scripts. Running one standalone just defines functions
  ## and exits -- harmless but meaningless, and it made them look like tools.
  "^_helpers/"                  = "sourced helper library, not a standalone script",
  "(^|/)parity_R_vs_py\\.R$"    = "manual R-vs-Python port check; shells out to Rscript and python3",
  ## DESTRUCTIVE ON RE-RUN. It writes Jacobs/Johnson/Peruffo into __ReadMe.xlsx rows
  ## 299, 300 and 301 by HARD-CODED number, and Sheet1 re-sorts itself -- so on any
  ## sweep after a re-sort it overwrites whatever three sources have landed there.
  ## It also writes only its own field list, so a column it does not name (e.g. C,
  ## "DOI if different") keeps the OVERWRITTEN row's value: that is how the Zilles &
  ## Rehkamper 1988 ISBN ended up stranded on the Johnson et al. 2016 row, and why
  ## rows 302 and 303 are duplicate Johnson and Peruffo entries. Its registration was
  ## done on 2026-08-15; re-running it can only do harm. Retire it, or rewrite it to
  ## locate rows with match() on Item name the way __update_remaining_builds does.
  "(^|/)__register_cortical_layer_builds_20260815\\.R$" =
    "writes hard-coded Sheet1 rows 299-301; Sheet1 re-sorts, so a re-run overwrites other sources"
)

r_scripts <- list.files(root_dir, pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
## list.files(root_dir, full.names = TRUE) always returns root_dir/<rest>, so a
## plain substring is safer here than regex-escaping the root path.

rel_paths <- substring(r_scripts, nchar(root_dir) + 2L)

skip_reason <- rep(NA_character_, length(r_scripts))
for (pat in names(SKIP_PATTERNS)) {
  hit <- grepl(pat, rel_paths) & is.na(skip_reason)
  skip_reason[hit] <- SKIP_PATTERNS[[pat]]
}
## Scaffolds/stubs call stop() on purpose (no data yet) -- record as SKIPPED so they
## don't pollute the failure log. Nothing changes length here, and it runs before
## the EVOM1_ONLY filter, so r_scripts / rel_paths / skip_reason stay aligned.
is_scaffold <- vapply(r_scripts, function(f) {
  hdr <- tryCatch(readLines(f, n = 40, warn = FALSE), error = function(e) character())
  any(grepl("SCAFFOLD|\\[STUB\\]", hdr))
}, logical(1), USE.NAMES = FALSE)
skip_reason[is_scaffold & is.na(skip_reason)] <- "scaffold/stub -- no data yet"

## optional filter: EVOM1_ONLY is a regex; non-matching scripts are dropped entirely
only <- Sys.getenv("EVOM1_ONLY", "")
if (nzchar(only)) {
  keep <- grepl(only, rel_paths)
  cat(sprintf("EVOM1_ONLY='%s' -> %d of %d scripts selected\n",
              only, sum(keep), length(keep)))
  r_scripts  <- r_scripts[keep]
  rel_paths  <- rel_paths[keep]
  skip_reason <- skip_reason[keep]
}

log_file <- file.path(checks_dir, "script_execution_log.csv")

run_log <- data.frame(
  script         = r_scripts,
  status         = ifelse(is.na(skip_reason), "NOT_RUN", "SKIPPED"),
  error          = ifelse(is.na(skip_reason), "", paste("skipped:", skip_reason)),
  start_time     = rep(NA_character_, length(r_scripts)),
  end_time       = rep(NA_character_, length(r_scripts)),
  elapsed_seconds = rep(NA_real_, length(r_scripts)),
  stringsAsFactors = FALSE
)

write.csv(run_log, log_file, row.names = FALSE)

n_skip <- sum(run_log$status == "SKIPPED")
if (n_skip) {
  cat(sprintf("\nSkipping %d script(s):\n", n_skip))
  for (i in which(run_log$status == "SKIPPED"))
    cat(sprintf("  - %s  (%s)\n", rel_paths[i], skip_reason[i]))
}

todo <- which(run_log$status == "NOT_RUN")

for (k in seq_along(todo)) {
  i <- todo[k]
  script <- r_scripts[i]

  cat(sprintf("\n[%d/%d] Running: %s\n", k, length(todo), rel_paths[i]))

  start <- Sys.time()
  run_log$start_time[i] <- as.character(start)
  run_log$status[i] <- "RUNNING"
  write.csv(run_log, log_file, row.names = FALSE)

  result <- system2(
    command = file.path(R.home("bin"), "Rscript"),
    args = shQuote(script),
    stdout = TRUE,
    stderr = TRUE,
    timeout = TIMEOUT_SEC
  )

  exit_status <- attr(result, "status")
  if (is.null(exit_status)) exit_status <- 0

  end <- Sys.time()

  run_log$end_time[i] <- as.character(end)
  run_log$elapsed_seconds[i] <- as.numeric(difftime(end, start, units = "secs"))

  if (exit_status == 0) {
    run_log$status[i] <- "SUCCESS"
    run_log$error[i] <- ""
  } else {
    run_log$status[i] <- if (exit_status == 124L) "TIMEOUT" else "FAILED"
    run_log$error[i] <- paste(result, collapse = "\n")
  }

  write.csv(run_log, log_file, row.names = FALSE)
}

cat("\nFinished. Log saved to:\n", log_file, "\n")

## ---- Summarise results ----

if (file.exists(log_file)) {

  log <- read.csv(log_file, stringsAsFactors = FALSE)

  failed     <- subset(log, status %in% c("FAILED", "TIMEOUT"))
  successful <- subset(log, status == "SUCCESS")
  skipped    <- subset(log, status == "SKIPPED")
  not_run    <- subset(log, status %in% c("NOT_RUN", "RUNNING"))

  write.csv(
    failed,
    file.path(checks_dir, "script_failures_only.csv"),
    row.names = FALSE
  )

  cat("\n=====================================\n")
  cat("Finished!\n")
  cat("=====================================\n")
  cat("Total scripts: ", nrow(log), "\n", sep = "")
  cat("Successful:    ", nrow(successful), "\n", sep = "")
  cat("Failed:        ", nrow(failed), "\n", sep = "")
  cat("Skipped:       ", nrow(skipped), "\n", sep = "")
  cat("Not run:       ", nrow(not_run), "\n", sep = "")
  cat("\nFailure log written to:\n")
  cat(file.path(checks_dir, "script_failures_only.csv"), "\n")

  if (nrow(not_run) > 0) {
    cat("\nNOTE: ", nrow(not_run), " script(s) never completed -- the sweep was ",
        "interrupted. Re-run, or use EVOM1_ONLY to finish the remainder.\n", sep = "")
  }

  if (nrow(failed) > 0) {
    cat("\nFailed scripts:\n\n")
    print(failed[, c("script", "status")], row.names = FALSE)
  } else {
    cat("\nAll executed scripts completed successfully.\n")
  }

}

cat("\nFull execution log:\n")
cat(log_file, "\n")
