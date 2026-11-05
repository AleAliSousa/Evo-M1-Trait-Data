## __rename_cell_counts_20261104.R -- one-off rename "cellcounts" -> "cell_counts" (owner decision
## RV-2026-004, 4 Nov 2026; see _keys/cell_count_methods/README.md).
##
## DRY RUN BY DEFAULT: it prints what it would change and changes nothing. To apply, set
## dry_run <- FALSE below (or run with EVOM1_APPLY_RENAME=YES), with nothing open from the two
## folders (RStudio tabs, Excel), then commit the whole result as one commit.
##
##   1. Folders   __merging_cellcounts  -> __merging_cell_counts_isotropic_fractionator
##                __imputing_cellcounts -> __imputing_cell_counts
##   2. File names that contain an old name (cellcounts_compiled.R, cellcounts_long.csv, ...)
##   3. Every reference to an old name inside text files (.R .Rmd .qmd .py .md .csv .txt .json
##      .yml .yaml .sh .html) anywhere in the repository, except __Public/ (published data),
##      hidden folders (.git), this script, and generated reports in _checks/ (they regenerate).
## Bare "cellcounts" (R object names, the anatomy_crosswalk domain value "cellcounts") is left alone.
## Idempotent: once applied, a re-run finds nothing to do -- safe if the sweep picks it up.
## The app follows the new paths once the commit reaches GitHub. The restricted repository is
## separate: if any of its scripts read files from this merge, update them by hand.

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
root <- local({
  d <- if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("Repository root (folder with __ReadMe.xlsx) not found.")
  normalizePath(d)
})

dry_run <- TRUE
if (identical(Sys.getenv("EVOM1_APPLY_RENAME"), "YES")) dry_run <- FALSE

dir_renames <- c("__merging_cellcounts"  = "__merging_cell_counts_isotropic_fractionator",
                 "__imputing_cellcounts" = "__imputing_cell_counts")
## applied in this order to file contents and file names (exact text, case-sensitive)
replacements <- c(
  "__merging_cellcounts"              = "__merging_cell_counts_isotropic_fractionator",
  "__imputing_cellcounts"             = "__imputing_cell_counts",
  "standardized_term_cellcounts"      = "standardized_term_cell_counts",
  "cellcounts_compiled"               = "cell_counts_compiled",
  "cellcounts_long"                   = "cell_counts_long",
  "cellcounts_wide"                   = "cell_counts_wide",
  "cellcounts_unfiltered"             = "cell_counts_unfiltered",
  "cellcounts_species_resolution"     = "cell_counts_species_resolution",
  "cellcounts_source_species_ids"     = "cell_counts_source_species_ids",
  "cellcounts_conflictcheck"          = "cell_counts_conflictcheck",
  "cellcounts_imputations_diagnostic" = "cell_counts_imputations_diagnostic",
  "WIRING_into_cellcounts"            = "WIRING_into_cell_counts")
## text that records the old name on purpose and must survive later runs
protected <- c("former name: `__merging_cellcounts`", "former name: `__imputing_cellcounts`")
text_ext  <- c("r", "rmd", "qmd", "py", "md", "csv", "txt", "json", "yml", "yaml", "sh", "html")
log_rel   <- "_tools/__rename_cell_counts_20261104_log.csv"

replace_all <- function(x) {
  for (k in seq_along(protected)) x <- gsub(protected[k], sprintf("@@PROTECTED_%d@@", k), x, fixed = TRUE, useBytes = TRUE)
  for (old in names(replacements)) x <- gsub(old, replacements[[old]], x, fixed = TRUE, useBytes = TRUE)
  for (k in seq_along(protected)) x <- gsub(sprintf("@@PROTECTED_%d@@", k), protected[k], x, fixed = TRUE, useBytes = TRUE)
  x
}
strip_protected <- function(x) {
  for (p in protected) x <- gsub(p, "", x, fixed = TRUE, useBytes = TRUE)
  x
}
## old names still present, not counting the protected records of the former name
count_tokens <- function(x) {
  x <- strip_protected(x)
  sum(vapply(names(replacements), function(old) {
    m <- gregexpr(old, x, fixed = TRUE, useBytes = TRUE)[[1]]; if (m[1] == -1L) 0L else length(m)
  }, integer(1)))
}
## generated reports in _checks/ (registry snapshot, sweep logs, audits) mirror other files or
## record history: they are regenerated, not edited. Scripts and notes there are edited.
editable <- function(rel_path) {
  ext <- tolower(tools::file_ext(rel_path))
  ext %in% text_ext && (!startsWith(rel_path, "_checks/") || ext %in% c("r", "rmd", "py", "md"))
}

all_files <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
rel <- substring(all_files, nchar(root) + 2L)
self_rel <- "_tools/__rename_cell_counts_20261104.R"
keep <- !grepl("(^|/)\\.", rel) & !startsWith(rel, "__Public/") &
        normalizePath(all_files, mustWork = FALSE) != .script_path & !rel %in% c(self_rel, log_rel) &
        !dir.exists(all_files)
files <- all_files[keep]; rel <- rel[keep]

## ---- 1. plan content edits -------------------------------------------------------
is_text <- vapply(rel, editable, logical(1))
plan_text <- data.frame(rel = character(), occurrences = integer(), stringsAsFactors = FALSE)
new_content <- list(); skipped <- character()
for (i in which(is_text)) {
  size <- file.info(files[i])$size
  if (is.na(size) || size == 0) next
  txt <- readChar(files[i], nchars = size, useBytes = TRUE)
  if (nchar(txt, type = "bytes") != size) { skipped <- c(skipped, rel[i]); next }   # embedded NUL: not text
  new_txt <- replace_all(txt)
  if (!identical(txt, new_txt)) {
    plan_text[nrow(plan_text) + 1L, ] <- list(rel[i], count_tokens(txt))
    new_content[[rel[i]]] <- new_txt
  }
}

## ---- 2. plan file renames ---------------------------------------------------------
new_base <- replace_all(basename(files))
ren <- new_base != basename(files)
plan_files <- data.frame(from = rel[ren], to = file.path(dirname(rel[ren]), new_base[ren]), stringsAsFactors = FALSE)
plan_files$to <- sub("^\\./", "", plan_files$to)
clash <- file.exists(file.path(root, plan_files$to))
if (any(clash)) stop("File rename would overwrite: ", paste(plan_files$to[clash], collapse = "; "))
if (anyDuplicated(plan_files$to)) stop("File renames collide: ", paste(plan_files$to[duplicated(plan_files$to)], collapse = "; "))

## ---- 3. plan folder renames -------------------------------------------------------
plan_dirs <- data.frame(from = character(), to = character(), stringsAsFactors = FALSE)
for (old in names(dir_renames)) {
  new <- dir_renames[[old]]
  has_old <- dir.exists(file.path(root, old)); has_new <- dir.exists(file.path(root, new))
  if (has_old && has_new) stop("Both ", old, " and ", new, " exist; merge them by hand first.")
  if (has_old) plan_dirs[nrow(plan_dirs) + 1L, ] <- list(old, new)
  else if (has_new) message(old, ": already renamed to ", new)
}

## ---- preview ----------------------------------------------------------------------
cat(sprintf("\nRepository: %s\n", root))
cat(sprintf("Folders to rename: %d\n", nrow(plan_dirs)))
if (nrow(plan_dirs)) cat(paste0("  ", plan_dirs$from, "  ->  ", plan_dirs$to, collapse = "\n"), "\n")
cat(sprintf("Files to rename: %d\n", nrow(plan_files)))
if (nrow(plan_files)) cat(paste0("  ", plan_files$from, "  ->  ", basename(plan_files$to), collapse = "\n"), "\n")
cat(sprintf("Files whose text changes: %d (%d references)\n", nrow(plan_text), sum(plan_text$occurrences)))
if (nrow(plan_text)) cat(paste0("  ", plan_text$rel, "  (", plan_text$occurrences, ")", collapse = "\n"), "\n")
if (length(skipped)) cat("Skipped (not plain text):", paste(skipped, collapse = "; "), "\n")

if (dry_run) {
  message("\nDry run only: nothing changed. Set dry_run <- FALSE (or EVOM1_APPLY_RENAME=YES) to apply.")
} else if (!nrow(plan_dirs) && !nrow(plan_files) && !nrow(plan_text)) {
  message("\nNothing to do: the rename has already been applied.")
} else {
  ## contents first (old paths), then file names, then folders
  for (r in names(new_content)) {
    con <- file(file.path(root, r), open = "wb")
    writeChar(new_content[[r]], con, eos = NULL, useBytes = TRUE)
    close(con)
  }
  ok <- file.rename(file.path(root, plan_files$from), file.path(root, plan_files$to))
  if (!all(ok)) stop("File renames failed: ", paste(plan_files$from[!ok], collapse = "; "))
  ok <- file.rename(file.path(root, plan_dirs$from), file.path(root, plan_dirs$to))
  if (!all(ok)) stop("Folder renames failed: ", paste(plan_dirs$from[!ok], collapse = "; "))

  ## record the rename in the merge README (once)
  readme <- file.path(root, "__merging_cell_counts_isotropic_fractionator", "README__merging.md")
  if (file.exists(readme)) {
    txt <- readChar(readme, file.info(readme)$size, useBytes = TRUE)
    if (!grepl("former name: `__merging_cellcounts`", txt, fixed = TRUE)) {
      note <- paste0("\n\n## Renamed 4 Nov 2026\n\n",
                     "This folder's former name: `__merging_cellcounts` (renamed by ",
                     "`_tools/__rename_cell_counts_20261104.R`, owner decision RV-2026-004). It holds ",
                     "isotropic- and flow-fractionator counts only; counts made in tissue sections go to ",
                     "`__merging_cell_counts_histology`. Each source's counting method, treatment and flags: ",
                     "`_keys/cell_count_methods/source_methods.csv`.\n")
      con <- file(readme, open = "ab"); writeChar(note, con, eos = NULL, useBytes = TRUE); close(con)
    }
  }
  mk <- function(action, from, to, refs) if (length(from))
    data.frame(action = action, from = from, to = to, references = refs, stringsAsFactors = FALSE)
  log <- rbind(mk("rename_folder", plan_dirs$from, plan_dirs$to, rep(NA_integer_, nrow(plan_dirs))),
               mk("rename_file", plan_files$from, plan_files$to, rep(NA_integer_, nrow(plan_files))),
               mk("edit_text", plan_text$rel, rep("", nrow(plan_text)), plan_text$occurrences))
  utils::write.csv(log, file.path(root, log_rel), row.names = FALSE)

  ## verify: no old names left in text files outside __Public/
  left <- 0L
  for (f in list.files(root, recursive = TRUE, full.names = TRUE)) {
    r <- substring(f, nchar(root) + 2L)
    if (grepl("(^|/)\\.", r) || startsWith(r, "__Public/") || r %in% c(self_rel, log_rel) ||
        normalizePath(f, mustWork = FALSE) == .script_path || !editable(r)) next
    s <- file.info(f)$size; if (is.na(s) || s == 0) next
    left <- left + count_tokens(readChar(f, s, useBytes = TRUE))
  }
  message(sprintf("\nApplied. Log: %s. Old names left in text files: %d.", log_rel, left))
  message("Next: commit everything in one commit, then push so the app follows the new paths.")
}
