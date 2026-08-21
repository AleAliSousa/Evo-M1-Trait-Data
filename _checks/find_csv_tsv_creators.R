## find_csv_tsv_creators.R
## Search this project for .R scripts that likely created existing .csv/.tsv files.
## Put this script in the project root and run it from RStudio, source(), or Rscript.

options(stringsAsFactors = FALSE)

## -----------------------------------------------------------------------------
## 1. Locate this script and project root
## -----------------------------------------------------------------------------
script_path <- local({
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

## project root = nearest ancestor containing __ReadMe.xlsx (works whether this
## script sits at the project root or in a subfolder such as _tools/)
project_root <- local({
  d <- if (file.exists(script_path)) dirname(script_path) else normalizePath(getwd())
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d
  else if (file.exists(script_path)) dirname(script_path) else normalizePath(getwd())
})
setwd(project_root)
checks_dir <- file.path(project_root, "_checks")
dir.create(checks_dir, showWarnings = FALSE, recursive = TRUE)

## -----------------------------------------------------------------------------
## 2. Optional: restrict to specific mysterious files
## -----------------------------------------------------------------------------
## Leave this empty to check every .csv/.tsv file in the project.
## Or add names like:
##mysterious_files <- c("Rilling_Insel_1999_viaDeCasien.tsv")
mysterious_files <- character(0)

## -----------------------------------------------------------------------------
## 3. Find files and scripts
## -----------------------------------------------------------------------------
data_files <- list.files(
  project_root,
  pattern = "\\.(csv|tsv)$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = TRUE
)

data_files <- data_files[!grepl("(^|/)(\\.git|renv|packrat)(/|$)", data_files)]

if (length(mysterious_files) > 0L) {
  data_files <- data_files[basename(data_files) %in% mysterious_files]
}

r_scripts <- list.files(
  project_root,
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = FALSE
)

r_scripts <- r_scripts[!grepl("(^|/)(\\.git|renv|packrat)(/|$)", r_scripts)]
r_scripts <- setdiff(normalizePath(r_scripts), normalizePath(script_path))

## -----------------------------------------------------------------------------
## 4. Helpers
## -----------------------------------------------------------------------------
read_text <- function(path) {
  x <- tryCatch(readLines(path, warn = FALSE, encoding = "UTF-8"), error = function(e) character(0))
  if (!length(x)) {
    x <- tryCatch(readLines(path, warn = FALSE), error = function(e) character(0))
  }
  x
}

regex_escape <- function(x) {
  gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", x)
}

context_lines <- function(lines, hits, n = 1L) {
  if (!length(hits)) return(NA_character_)
  chunks <- vapply(hits, function(i) {
    lo <- max(1L, i - n)
    hi <- min(length(lines), i + n)
    paste(sprintf("%d: %s", lo:hi, lines[lo:hi]), collapse = " | ")
  }, character(1))
  paste(chunks, collapse = " || ")
}

classify_hit <- function(lines, hit_lines, file_name) {
  if (!length(hit_lines)) return(NA_character_)
  nearby <- unlist(lapply(hit_lines, function(i) {
    lo <- max(1L, i - 2L)
    hi <- min(length(lines), i + 2L)
    lines[lo:hi]
  }), use.names = FALSE)

  writer_patterns <- c(
    "write\\.csv", "write\\.table", "write_csv", "write_tsv",
    "write_delim", "fwrite", "write_excel_csv", "saveRDS"
  )
  reader_patterns <- c(
    "read\\.csv", "read\\.table", "read_csv", "read_tsv",
    "read_delim", "fread", "readRDS", "read_excel"
  )

  if (any(grepl(paste(writer_patterns, collapse = "|"), nearby))) return("likely writer")
  if (any(grepl(paste(reader_patterns, collapse = "|"), nearby))) return("likely reader")
  if (any(grepl(regex_escape(file_name), nearby, fixed = FALSE))) return("mentions exact filename")
  "mentions related name"
}

## -----------------------------------------------------------------------------
## 5. Search scripts for each data file
## -----------------------------------------------------------------------------
results <- list()
k <- 0L

for (data_file in data_files) {
  file_name <- basename(data_file)
  file_stem <- sub("\\.(csv|tsv)$", "", file_name, ignore.case = TRUE)
  rel_data_file <- sub(paste0("^", regex_escape(project_root), "/?"), "", normalizePath(data_file))

  exact_pat <- regex_escape(file_name)
  stem_pat  <- regex_escape(file_stem)

  for (script in r_scripts) {
    lines <- read_text(script)
    if (!length(lines)) next

    exact_hits <- grep(exact_pat, lines)
    stem_hits  <- grep(stem_pat, lines)
    hit_lines  <- sort(unique(c(exact_hits, stem_hits)))

    if (!length(hit_lines)) next

    k <- k + 1L
    results[[k]] <- data.frame(
      data_file = rel_data_file,
      data_filename = file_name,
      candidate_script = sub(paste0("^", regex_escape(project_root), "/?"), "", normalizePath(script)),
      match_type = classify_hit(lines, hit_lines, file_name),
      exact_filename_match = length(exact_hits) > 0L,
      stem_match = length(stem_hits) > 0L,
      matched_line_numbers = paste(hit_lines, collapse = ";"),
      context = context_lines(lines, hit_lines, n = 1L),
      stringsAsFactors = FALSE
    )
  }
}

out <- if (length(results)) do.call(rbind, results) else data.frame(
  data_file = character(0),
  data_filename = character(0),
  candidate_script = character(0),
  match_type = character(0),
  exact_filename_match = logical(0),
  stem_match = logical(0),
  matched_line_numbers = character(0),
  context = character(0)
)

## Order likely writers first, then exact filename matches.
if (nrow(out)) {
  rank <- match(out$match_type, c("likely writer", "mentions exact filename", "likely reader", "mentions related name"))
  out <- out[order(rank, out$data_filename, out$candidate_script), ]
  rownames(out) <- NULL
}

## -----------------------------------------------------------------------------
## 6. Also list data files with no matching script
## -----------------------------------------------------------------------------
all_data <- data.frame(
  data_file = sub(paste0("^", regex_escape(project_root), "/?"), "", normalizePath(data_files)),
  data_filename = basename(data_files),
  stringsAsFactors = FALSE
)

unmatched <- all_data[!all_data$data_file %in% out$data_file, ]
rownames(unmatched) <- NULL

## -----------------------------------------------------------------------------
## 7. Write reports
## -----------------------------------------------------------------------------
write.csv(out, file.path(checks_dir, "csv_tsv_candidate_creators.csv"), row.names = FALSE)
write.csv(unmatched, file.path(checks_dir, "csv_tsv_no_candidate_script_found.csv"), row.names = FALSE)

cat("Project root:", project_root, "\n")
cat("Data files checked:", length(data_files), "\n")
cat("R scripts searched:", length(r_scripts), "\n")
cat("Candidate script matches:", nrow(out), "\n")
cat("Data files with no candidate script found:", nrow(unmatched), "\n")
cat("\nWrote:\n")
cat("  csv_tsv_candidate_creators.csv\n")
cat("  csv_tsv_no_candidate_script_found.csv\n")

if (nrow(out)) {
  cat("\nLikely writers found:\n")
  print(out[out$match_type == "likely writer", c("data_filename", "candidate_script", "matched_line_numbers")], row.names = FALSE)
}
