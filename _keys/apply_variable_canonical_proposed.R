#!/usr/bin/env Rscript
# =============================================================================
# apply_variable_canonical_proposed.R
#
# Move adjudicated rows from _keys/variable_canonical_PROPOSED.csv into
# _keys/variable_canonical.csv. Replaces copy-pasting between spreadsheets.
#
# HOW TO USE
#   1. Open _keys/variable_canonical_PROPOSED.csv.
#   2. For each row you accept, put `supersede` or `keep_separate` in the
#      `action` column. Leave `action` BLANK for anything you have not decided
#      -- blank rows are ignored and stay in the file for next time.
#   3. Rscript _keys/apply_variable_canonical_proposed.R --dry-run    (preview)
#      Rscript _keys/apply_variable_canonical_proposed.R              (apply)
#
# Applied rows are appended to variable_canonical.csv and REMOVED from the
# proposal, so the proposal always shows only what is still outstanding.
#
# The app reads _keys/variable_canonical.csv from GitHub at runtime, so a
# `git push` is what makes an applied decision live. No rebuild is needed for
# variable_canonical itself.
# =============================================================================

args    <- commandArgs(trailingOnly = TRUE)
dry_run <- "--dry-run" %in% args

file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
keys_dir <- if (length(file_arg)) dirname(normalizePath(sub("^--file=", "", file_arg[1]))) else getwd()
key_path <- file.path(keys_dir, "variable_canonical.csv")
prop_path <- file.path(keys_dir, "variable_canonical_PROPOSED.csv")
for (p in c(key_path, prop_path))
  if (!file.exists(p)) stop("Missing ", basename(p), " in ", keys_dir)

rd <- function(p) read.csv(p, stringsAsFactors = FALSE, check.names = FALSE,
                           colClasses = "character", encoding = "UTF-8")
key  <- rd(key_path)
prop <- rd(prop_path)
trim <- function(x) trimws(as.character(x))

if (!identical(names(prop), names(key)))
  stop("Column mismatch between the proposal and variable_canonical.csv.\n",
       "  key     : ", paste(names(key),  collapse = ", "), "\n",
       "  proposal: ", paste(names(prop), collapse = ", "))

VALID <- c("supersede", "keep_separate", "structure_alias")
prop$action <- trim(prop$action)
ready   <- prop[nzchar(prop$action), , drop = FALSE]
pending <- prop[!nzchar(prop$action), , drop = FALSE]

bad <- setdiff(unique(ready$action), VALID)
if (length(bad))
  stop("Unrecognised action(s): ", paste(bad, collapse = ", "),
       "\nUse one of: ", paste(VALID, collapse = ", "))

# A raw_variable already in the key would silently double-apply on a second run.
clash <- intersect(trim(ready$raw_variable), trim(key$raw_variable))
if (length(clash))
  stop("These raw_variable values are already in variable_canonical.csv:\n  ",
       paste(clash, collapse = "\n  "),
       "\nRemove them from the proposal, or edit the existing row instead.")

if (!nrow(ready)) {
  message("Nothing to apply: every row in the proposal still has a blank `action`.")
  message("Rows awaiting a decision: ", nrow(pending))
  quit(save = "no")
}

message("Ready to apply (", nrow(ready), "):")
for (i in seq_len(nrow(ready)))
  message("  ", ready$raw_variable[i], "  ->  ", ready$canonical_variable[i],
          "   [", ready$action[i], "]")
message("Still pending: ", nrow(pending))

if (dry_run) {
  message("\n--dry-run: nothing written.")
  quit(save = "no")
}

# Write raw UTF-8 bytes, bypassing the session locale (Rscript often runs in C,
# where write.csv turns an en-dash into a "<U+2013>" escape). Each file KEEPS the
# BOM state it already had: variable_canonical.csv has none, the proposal has one
# because it is meant to be opened in Excel. Appending a row must not silently
# change a file's encoding.
has_bom <- function(path)
  file.exists(path) && identical(readBin(path, "raw", 3L), as.raw(c(0xEF, 0xBB, 0xBF)))

write_csv_keep_bom <- function(df, path, bom) {
  fld <- function(x) {
    x <- ifelse(is.na(x), "", as.character(x))
    n  <- grepl('[",\n\r]', x)
    x[n] <- paste0('"', gsub('"', '""', x[n]), '"')
    x
  }
  lines <- c(paste(fld(names(df)), collapse = ","),
             do.call(paste, c(lapply(df, fld), sep = ",")))
  con <- file(path, open = "wb")
  on.exit(close(con))
  if (bom) writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
}

key_bom  <- has_bom(key_path)
prop_bom <- has_bom(prop_path)
write_csv_keep_bom(rbind(key, ready), key_path,  key_bom)
write_csv_keep_bom(pending,           prop_path, prop_bom)
if (!identical(has_bom(key_path), key_bom) || !identical(has_bom(prop_path), prop_bom))
  stop("BOM state changed on write -- aborting before the convention drifts.")

after <- rd(key_path)
stopifnot(nrow(after) == nrow(key) + nrow(ready),
          all(trim(ready$raw_variable) %in% trim(after$raw_variable)))
message("\nvariable_canonical.csv: ", nrow(key), " -> ", nrow(after), " rows")
message("proposal now holds ", nrow(pending), " undecided row(s).")
message("Commit and push to make the change live in the app.")
