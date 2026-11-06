## __rename_cell_counts_20261104.R -- one-off rename of the isotropic-fractionator cell-count merge
## (owner decisions RV-2026-004 and RV-2026-011, 4 Nov 2026; see _keys/cell_count_methods/README.md).
##
## DRY RUN BY DEFAULT: it prints what it would change and changes nothing. To apply, set
## dry_run <- FALSE below (or run with EVOM1_APPLY_RENAME=YES), with nothing open from these folders
## (RStudio tabs, Excel), then commit the whole result as one commit.
##
##   1. The merge folder becomes __merging_cell_counts_isotropic_fractionator. It may currently carry
##      its original name (cellcounts) or the interim hand rename of 4 Nov 2026 (cell_counts); both
##      are handled. The imputation folder becomes __imputing_cell_counts.
##   2. INSIDE the merge folder, every "cellcounts" becomes "cell_counts_isotropic_fractionator":
##      file names (cellcounts_long.csv -> cell_counts_isotropic_fractionator_long.csv, ...), R
##      object names, messages and notes (owner decision RV-2026-011).
##   3. EVERYWHERE ELSE, references to the merge folder and to its files follow the new names
##      (app paths, scripts, READMEs, the HOWTO, per-paper WIRING notes). A bare "cellcounts" outside
##      the merge folder is left alone: R object names such as GH$cellcounts in the app, and the
##      anatomy_crosswalk domain value "cellcounts".
##   Text files are .R .Rmd .qmd .py .md .csv .txt .json .yml .yaml .sh .html. Skipped: __Public/
##   (published data), hidden files and folders (.git, .Rhistory), this script and its log, and
##   generated reports in _checks/ (they regenerate).
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

dry_run <- FALSE
if (identical(Sys.getenv("EVOM1_APPLY_RENAME"), "YES")) dry_run <- FALSE

TARGET     <- "__merging_cell_counts_isotropic_fractionator"
MERGE_OLD  <- c("__merging_cellcounts", "__merging_cell_counts")      # original; interim hand rename
IMPUTE_OLD <- "__imputing_cellcounts"; IMPUTE_NEW <- "__imputing_cell_counts"
TERM_OLD   <- "cellcounts";            TERM_NEW   <- "cell_counts_isotropic_fractionator"

## literal replacements applied everywhere, in this order, to file contents and file names
literal <- c(
  "__merging_cellcounts"              = TARGET,
  "__imputing_cellcounts"             = IMPUTE_NEW,
  "standardized_term_cellcounts"      = "standardized_term_cell_counts_isotropic_fractionator",
  "cellcounts_compiled"               = "cell_counts_isotropic_fractionator_compiled",
  "cellcounts_long"                   = "cell_counts_isotropic_fractionator_long",
  "cellcounts_wide"                   = "cell_counts_isotropic_fractionator_wide",
  "cellcounts_unfiltered"             = "cell_counts_isotropic_fractionator_unfiltered",
  "cellcounts_species_resolution"     = "cell_counts_isotropic_fractionator_species_resolution",
  "cellcounts_source_species_ids"     = "cell_counts_isotropic_fractionator_source_species_ids",
  "cellcounts_conflictcheck"          = "cell_counts_isotropic_fractionator_conflictcheck",
  "cellcounts_imputations_diagnostic" = "cell_counts_isotropic_fractionator_imputations_diagnostic",
  "WIRING_into_cellcounts"            = "WIRING_into_cell_counts_isotropic_fractionator")
## the interim name, only where it is the whole folder name (never __merging_cell_counts_histology)
interim_rx <- "__merging_cell_counts(?![A-Za-z0-9_])"
## text that records a former name on purpose and must survive later runs
protected <- c("Former names: `__merging_cellcounts` and `__merging_cell_counts`",
               "former name: `__merging_cellcounts`", "former name: `__imputing_cellcounts`")
text_ext  <- c("r", "rmd", "qmd", "py", "md", "csv", "txt", "json", "yml", "yaml", "sh", "html")
self_rel  <- "_tools/__rename_cell_counts_20261104.R"
log_rel   <- "_tools/__rename_cell_counts_20261104_log.csv"

in_merge <- function(rel) {
  top <- sub("/.*$", "", rel)
  top %in% c(MERGE_OLD, TARGET) & grepl("/", rel, fixed = TRUE)
}
replace_all <- function(x, inside) {
  for (k in seq_along(protected)) x <- gsub(protected[k], sprintf("@@PROTECTED_%d@@", k), x, fixed = TRUE, useBytes = TRUE)
  x <- gsub(interim_rx, TARGET, x, perl = TRUE, useBytes = TRUE)
  for (old in names(literal)) x <- gsub(old, literal[[old]], x, fixed = TRUE, useBytes = TRUE)
  if (inside) x <- gsub(TERM_OLD, TERM_NEW, x, fixed = TRUE, useBytes = TRUE)
  for (k in seq_along(protected)) x <- gsub(sprintf("@@PROTECTED_%d@@", k), protected[k], x, fixed = TRUE, useBytes = TRUE)
  x
}
## old names still present (protected records of former names not counted)
count_old <- function(x, inside) {
  for (p in protected) x <- gsub(p, "", x, fixed = TRUE, useBytes = TRUE)
  n_hits <- function(m) if (m[1] == -1L) 0L else length(m)
  n <- n_hits(gregexpr(interim_rx, x, perl = TRUE, useBytes = TRUE)[[1]])
  n <- n + sum(vapply(names(literal), function(old)
    n_hits(gregexpr(old, x, fixed = TRUE, useBytes = TRUE)[[1]]), integer(1)))
  if (inside) n <- n + n_hits(gregexpr(TERM_OLD, x, fixed = TRUE, useBytes = TRUE)[[1]])
  n
}
## generated reports in _checks/ (registry snapshot, sweep logs, audits) mirror other files or
## record history: they are regenerated, not edited. Scripts and notes there are edited.
editable <- function(rel_path) {
  ext <- tolower(tools::file_ext(rel_path))
  ext %in% text_ext && (!startsWith(rel_path, "_checks/") || ext %in% c("r", "rmd", "py", "md"))
}
list_repo <- function() {
  f <- list.files(root, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
  r <- substring(f, nchar(root) + 2L)
  keep <- !grepl("(^|/)\\.", r) & !startsWith(r, "__Public/") & !r %in% c(self_rel, log_rel) &
          normalizePath(f, mustWork = FALSE) != .script_path & !dir.exists(f)
  list(full = f[keep], rel = r[keep])
}

## ---- 0. which merge folder is there now ----------------------------------------------------
present <- MERGE_OLD[dir.exists(file.path(root, MERGE_OLD))]
if (length(present) > 1L) stop("Both ", paste(present, collapse = " and "), " exist; merge them by hand first.")
if (length(present) && dir.exists(file.path(root, TARGET)))
  stop("Both ", present, " and ", TARGET, " exist; merge them by hand first.")
if (dir.exists(file.path(root, IMPUTE_OLD)) && dir.exists(file.path(root, IMPUTE_NEW)))
  stop("Both ", IMPUTE_OLD, " and ", IMPUTE_NEW, " exist; merge them by hand first.")

repo <- list_repo(); files <- repo$full; rel <- repo$rel
inside <- in_merge(rel)

## ---- 1. plan content edits -----------------------------------------------------------------
plan_text <- data.frame(rel = character(), occurrences = integer(), stringsAsFactors = FALSE)
new_content <- list(); skipped <- character()
for (i in which(vapply(rel, editable, logical(1)))) {
  size <- file.info(files[i])$size
  if (is.na(size) || size == 0) next
  txt <- readChar(files[i], nchars = size, useBytes = TRUE)
  if (nchar(txt, type = "bytes") != size) { skipped <- c(skipped, rel[i]); next }   # embedded NUL: not text
  new_txt <- replace_all(txt, inside[i])
  if (!identical(txt, new_txt)) {
    plan_text[nrow(plan_text) + 1L, ] <- list(rel[i], count_old(txt, inside[i]))
    new_content[[rel[i]]] <- new_txt
  }
}

## ---- 2. plan file renames (inside their current folders) ------------------------------------
new_base <- vapply(seq_along(rel), function(i) replace_all(basename(rel[i]), inside[i]), character(1))
ren <- new_base != basename(rel)
plan_files <- data.frame(from = rel[ren], to = file.path(dirname(rel[ren]), new_base[ren]), stringsAsFactors = FALSE)
plan_files$to <- sub("^\\./", "", plan_files$to)
clash <- file.exists(file.path(root, plan_files$to))
if (any(clash)) stop("File rename would overwrite: ", paste(plan_files$to[clash], collapse = "; "))
if (anyDuplicated(plan_files$to)) stop("File renames collide: ", paste(plan_files$to[duplicated(plan_files$to)], collapse = "; "))

## ---- 3. plan folder renames ----------------------------------------------------------------
plan_dirs <- data.frame(from = character(), to = character(), stringsAsFactors = FALSE)
if (length(present)) {
  plan_dirs[nrow(plan_dirs) + 1L, ] <- list(present, TARGET)
} else if (dir.exists(file.path(root, TARGET))) {
  message("merge folder: already ", TARGET)
}
if (dir.exists(file.path(root, IMPUTE_OLD))) plan_dirs[nrow(plan_dirs) + 1L, ] <- list(IMPUTE_OLD, IMPUTE_NEW)
## sub-folders inside the merge folder whose names carry the term (not the merge folder itself)
merge_dir <- file.path(root, c(present, TARGET)[1])
sub_dirs <- setdiff(list.dirs(merge_dir, recursive = TRUE, full.names = TRUE), merge_dir)
sub_dirs <- sub_dirs[grepl(TERM_OLD, basename(sub_dirs), fixed = TRUE) &
                     !grepl("(^|/)\\.", substring(sub_dirs, nchar(root) + 2L))]
for (d in rev(sub_dirs)) {
  r <- substring(d, nchar(root) + 2L)
  plan_dirs[nrow(plan_dirs) + 1L, ] <- list(r, file.path(dirname(r), gsub(TERM_OLD, TERM_NEW, basename(r), fixed = TRUE)))
}

## ---- preview -------------------------------------------------------------------------------
cat(sprintf("\nRepository: %s\n", root))
cat(sprintf("Folders to rename: %d\n", nrow(plan_dirs)))
if (nrow(plan_dirs)) cat(paste0("  ", plan_dirs$from, "  ->  ", plan_dirs$to, collapse = "\n"), "\n")
cat(sprintf("Files to rename: %d\n", nrow(plan_files)))
if (nrow(plan_files)) cat(paste0("  ", plan_files$from, "  ->  ", basename(plan_files$to), collapse = "\n"), "\n")
cat(sprintf("Files whose text changes: %d (%d old names)\n", nrow(plan_text), sum(plan_text$occurrences)))
if (nrow(plan_text)) cat(paste0("  ", plan_text$rel, "  (", plan_text$occurrences, ")", collapse = "\n"), "\n")
if (length(skipped)) cat("Skipped (not plain text):", paste(skipped, collapse = "; "), "\n")

if (dry_run) {
  message("\nDry run only: nothing changed. Set dry_run <- FALSE (or EVOM1_APPLY_RENAME=YES) to apply.")
} else if (!nrow(plan_dirs) && !nrow(plan_files) && !nrow(plan_text)) {
  message("\nNothing to do: the rename has already been applied.")
} else {
  ## contents first (old paths), then file names, then folders (deepest first)
  for (r in names(new_content)) {
    con <- file(file.path(root, r), open = "wb")
    writeChar(new_content[[r]], con, eos = NULL, useBytes = TRUE)
    close(con)
  }
  ok <- file.rename(file.path(root, plan_files$from), file.path(root, plan_files$to))
  if (!all(ok)) stop("File renames failed: ", paste(plan_files$from[!ok], collapse = "; "))
  ord <- order(-nchar(gsub("[^/]", "", plan_dirs$from)))
  ok <- file.rename(file.path(root, plan_dirs$from[ord]), file.path(root, plan_dirs$to[ord]))
  if (!all(ok)) stop("Folder renames failed: ", paste(plan_dirs$from[ord][!ok], collapse = "; "))

  ## record the rename in the merge README (once)
  readme <- file.path(root, TARGET, "README__merging.md")
  if (file.exists(readme)) {
    txt <- readChar(readme, file.info(readme)$size, useBytes = TRUE)
    if (!grepl(protected[1], txt, fixed = TRUE)) {
      note <- paste0("\n\n## Renamed 4 Nov 2026\n\n",
                     protected[1], " (renamed by `", self_rel, "`, owner decisions RV-2026-004 and ",
                     "RV-2026-011). Inside this folder the term became `", TERM_NEW, "` (file names, R object ",
                     "names, notes). It holds isotropic- and flow-fractionator counts only; counts made in tissue ",
                     "sections go to `__merging_cell_counts_histology`. Each source's counting method, treatment ",
                     "and flags: `_keys/cell_count_methods/source_methods.csv`.\n")
      con <- file(readme, open = "ab"); writeChar(note, con, eos = NULL, useBytes = TRUE); close(con)
    }
  }
  mk <- function(action, from, to, refs) if (length(from))
    data.frame(action = action, from = from, to = to, references = refs, stringsAsFactors = FALSE)
  log <- rbind(mk("rename_folder", plan_dirs$from, plan_dirs$to, rep(NA_integer_, nrow(plan_dirs))),
               mk("rename_file", plan_files$from, plan_files$to, rep(NA_integer_, nrow(plan_files))),
               mk("edit_text", plan_text$rel, rep("", nrow(plan_text)), plan_text$occurrences))
  utils::write.csv(log, file.path(root, log_rel), row.names = FALSE)

  ## verify: no old names left in text files (outside __Public/, hidden files and reports)
  after <- list_repo(); left <- 0L
  for (i in seq_along(after$rel)) {
    r <- after$rel[i]; if (!editable(r)) next
    s <- file.info(after$full[i])$size; if (is.na(s) || s == 0) next
    left <- left + count_old(readChar(after$full[i], s, useBytes = TRUE), in_merge(r))
  }
  message(sprintf("\nApplied. Log: %s. Old names left in text files: %d.", log_rel, left))
  message("Next: re-run nothing; commit everything in one commit, then push so the app follows the new paths.")
}
