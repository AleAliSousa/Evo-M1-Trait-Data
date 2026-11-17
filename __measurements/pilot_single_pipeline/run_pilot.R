# One-command ten-paper pilot from an already built measurement inventory.
# This intentionally runs only the qualification and direct-selection path.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __measurements/pilot_single_pipeline/run_pilot.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
inventory <- file.path(root, "__measurements", "measurements.sqlite")
if (!file.exists(inventory))
  stop("Build __measurements/measurements.sqlite before running the ten-paper pilot")
rscript <- Sys.which("Rscript")
if (!nzchar(rscript)) stop("Rscript is not on PATH")
steps <- list(
  list(path = "__metadata/pilot/build_catalog.R", args = character()),
  list(path = "__metadata/pilot/build_folder_metadata.R", args = character()),
  list(path = "__measurements/pilot_metadata/build_pilot.R",
       args = "--qualification-only"),
  list(path = "__metadata/pilot/build_assertion_audit.R", args = character()),
  list(path = "__measurements/pilot_single_pipeline/test_direct_selection.R",
       args = character()),
  list(path = "__measurements/pilot_metadata/check_pilot.R",
       args = "--qualification-only"),
  list(path = "__metadata/pilot/build_file_registry.R", args = character())
)
for (i in seq_along(steps)) {
  step <- steps[[i]]
  cat(sprintf("[%d/%d] %s %s\n", i, length(steps), step$path,
              paste(step$args, collapse = " ")))
  path <- file.path(root, step$path)
  if (!file.exists(path)) stop("Missing pilot step: ", path)
  for (attempt in seq_len(3L)) {
    stdout_file <- tempfile("pilot_stdout_")
    stderr_file <- tempfile("pilot_stderr_")
    status <- system2(rscript, args = c(shQuote(path), step$args),
                      stdout = stdout_file, stderr = stderr_file)
    output <- c(readLines(stdout_file, warn = FALSE),
                readLines(stderr_file, warn = FALSE))
    unlink(c(stdout_file, stderr_file))
    if (length(output)) cat(paste(output, collapse = "\n"), "\n", sep = "")
    if (!is.null(status) && status == 0L) break
    locked <- any(grepl("database is locked", output, fixed = TRUE))
    if (!locked || attempt == 3L)
      stop("Ten-paper pilot failed at ", step$path,
           " (exit status ", status, ")")
    cat("SQLite file is temporarily locked; retrying this step\n")
    Sys.sleep(attempt)
  }
}
cat("Ten-paper no-merge pilot completed.\n")
