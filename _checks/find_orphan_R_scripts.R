## find_orphan_R_scripts.R
## Search this project for .R scripts that do not appear to be associated with
## any existing .csv/.tsv files, plus a reverse map of scripts -> data files.
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
## 2. Optional: folders to ignore
## -----------------------------------------------------------------------------
ignore_dir_regex <- "(^|/)(\\.git|renv|packrat)(/|$)"

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
data_files <- data_files[!grepl(ignore_dir_regex, data_files)]

r_scripts <- list.files(
  project_root,
  pattern = "\\.R$",
  recursive = TRUE,
  full.names = TRUE,
  ignore.case = FALSE
)
r_scripts <- r_scripts[!grepl(ignore_dir_regex, r_scripts)]
r_scripts <- setdiff(normalizePath(r_scripts), normalizePath(script_path))

## Also avoid treating the companion creator-finder as project data logic.
r_scripts <- r_scripts[basename(r_scripts) != "find_csv_tsv_creators.R"]

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

rel_path <- function(path) {
  sub(paste0("^", regex_escape(project_root), "/?"), "", normalizePath(path))
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

script_io_summary <- function(lines) {
  writer_patterns <- c(
    "write\\.csv", "write\\.table", "write_csv", "write_tsv",
    "write_delim", "fwrite", "write_excel_csv", "saveRDS", "save\\("
  )
  reader_patterns <- c(
    "read\\.csv", "read\\.table", "read_csv", "read_tsv",
    "read_delim", "fread", "readRDS", "read_excel", "load\\("
  )

  data.frame(
    has_data_writer_call = any(grepl(paste(writer_patterns, collapse = "|"), lines)),
    has_data_reader_call = any(grepl(paste(reader_patterns, collapse = "|"), lines)),
    mentions_csv_or_tsv_literal = any(grepl("\\.(csv|tsv)\\b", lines, ignore.case = TRUE)),
    stringsAsFactors = FALSE
  )
}

## -----------------------------------------------------------------------------
## 5. Build reverse map: scripts -> existing csv/tsv files they mention
## -----------------------------------------------------------------------------
associations <- list()
k <- 0L

script_cache <- setNames(lapply(r_scripts, read_text), r_scripts)

for (script in r_scripts) {
  lines <- script_cache[[script]]
  if (!length(lines)) next

  for (data_file in data_files) {
    file_name <- basename(data_file)
    file_stem <- sub("\\.(csv|tsv)$", "", file_name, ignore.case = TRUE)

    exact_hits <- grep(regex_escape(file_name), lines)
    stem_hits <- grep(regex_escape(file_stem), lines)
    hit_lines <- sort(unique(c(exact_hits, stem_hits)))

    if (!length(hit_lines)) next

    k <- k + 1L
    associations[[k]] <- data.frame(
      script = rel_path(script),
      associated_data_file = rel_path(data_file),
      associated_data_filename = file_name,
      match_type = classify_hit(lines, hit_lines, file_name),
      exact_filename_match = length(exact_hits) > 0L,
      stem_match = length(stem_hits) > 0L,
      matched_line_numbers = paste(hit_lines, collapse = ";"),
      context = context_lines(lines, hit_lines, n = 1L),
      stringsAsFactors = FALSE
    )
  }
}

script_data_associations <- if (length(associations)) do.call(rbind, associations) else data.frame(
  script = character(0),
  associated_data_file = character(0),
  associated_data_filename = character(0),
  match_type = character(0),
  exact_filename_match = logical(0),
  stem_match = logical(0),
  matched_line_numbers = character(0),
  context = character(0),
  stringsAsFactors = FALSE
)

if (nrow(script_data_associations)) {
  rank <- match(script_data_associations$match_type, c("likely writer", "mentions exact filename", "likely reader", "mentions related name"))
  script_data_associations <- script_data_associations[order(rank, script_data_associations$script, script_data_associations$associated_data_filename), ]
  rownames(script_data_associations) <- NULL
}

## -----------------------------------------------------------------------------
## 6. List scripts with no association to any existing csv/tsv
## -----------------------------------------------------------------------------
associated_scripts <- unique(script_data_associations$script)
all_scripts <- data.frame(script = rel_path(r_scripts), stringsAsFactors = FALSE)

io_bits <- do.call(rbind, lapply(r_scripts, function(s) {
  cbind(data.frame(script = rel_path(s), stringsAsFactors = FALSE), script_io_summary(script_cache[[s]]))
}))

orphan_scripts <- merge(all_scripts, io_bits, by = "script", all.x = TRUE, sort = FALSE)
orphan_scripts <- orphan_scripts[!orphan_scripts$script %in% associated_scripts, ]
orphan_scripts <- orphan_scripts[order(orphan_scripts$script), ]
rownames(orphan_scripts) <- NULL

## A stricter subset: scripts that also do not appear to read/write/mention csv/tsv/RDS-like files.
very_orphan_scripts <- orphan_scripts[
  !orphan_scripts$has_data_writer_call &
    !orphan_scripts$has_data_reader_call &
    !orphan_scripts$mentions_csv_or_tsv_literal,
]
rownames(very_orphan_scripts) <- NULL

## -----------------------------------------------------------------------------
## 7. Write reports
## -----------------------------------------------------------------------------
write.csv(script_data_associations, file.path(checks_dir, "r_script_data_file_associations.csv"), row.names = FALSE)
write.csv(orphan_scripts, file.path(checks_dir, "orphan_R_scripts_no_csv_tsv_association.csv"), row.names = FALSE)
write.csv(very_orphan_scripts, file.path(checks_dir, "orphan_R_scripts_no_data_io_signals.csv"), row.names = FALSE)

cat("Project root:", project_root, "\n")
cat("R scripts checked:", length(r_scripts), "\n")
cat("Data files checked:", length(data_files), "\n")
cat("Script/data associations:", nrow(script_data_associations), "\n")
cat("R scripts with no csv/tsv association:", nrow(orphan_scripts), "\n")
cat("R scripts with no data-I/O signals:", nrow(very_orphan_scripts), "\n")
cat("\nWrote:\n")
cat("  r_script_data_file_associations.csv\n")
cat("  orphan_R_scripts_no_csv_tsv_association.csv\n")
cat("  orphan_R_scripts_no_data_io_signals.csv\n")
