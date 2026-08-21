#!/usr/bin/env Rscript
# check_item_name_resolution.R
# -----------------------------------------------------------------------------
# Can every item name a merge asks for actually resolve to a TSV?
#
# This reproduces the resolution logic the merges use -- read_item() in
# __merging_volumes/* and enc() in the other __merging_* scripts -- against
# __ReadMe.xlsx and the files actually present in __Public/comparative-data.
# It reads the registry with readxl, which is the same call the merges make, so
# it sees exactly what they see (cached formula values, not recalculated ones).
#
# It answers one question: would this item name reach a real TSV, or nothing?
# "Nothing" used to mean NA.tsv -- a stale byte-identical duplicate of the
# Sherwood 2004 table that really sat in comparative-data/ -- so an unresolved
# name read the WRONG data in silence rather than stopping. That file is gone
# and the merges now fail loudly, but this check is what catches the next lost
# registry row before a merge does.
#
# Three things are reported:
#   1. item names referenced by a merge that do not resolve to a TSV on disk;
#   2. ORPHANED TSVs -- files in comparative-data/ claimed by no registry row.
#      A TSV is only written after a build script resolved its encoding, so an
#      orphan proves a row was there when the file was built and is not there
#      now. This is the earliest possible warning: it fires before any merge
#      happens to reference the item. (_tools/file_list.R prints the same list
#      as part of its run; this script is the read-only, pass/fail form.)
#   3. rows whose citation is present but whose Item name/encoded are blank --
#      the signature of a row added without running _tools/file_list.R, which
#      owns the E:M formula family.
#
# Read-only: never opens the workbook for writing.
# Exit status is 1 if anything is wrong, so this can gate a script sweep.
#
# Usage:  Rscript _checks/check_item_name_resolution.R
# -----------------------------------------------------------------------------

suppressPackageStartupMessages(library(readxl))

# ---- Paths ------------------------------------------------------------------
## project root = nearest ancestor containing __ReadMe.xlsx (works from _checks/
## or root, and on any clone, via Rscript / source() / RStudio)
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
readme_xlsx <- file.path(root_dir, "__ReadMe.xlsx")
tsv_dir     <- file.path(root_dir, "__Public", "comparative-data")

# ---- Registry ---------------------------------------------------------------
registry <- read_excel(readme_xlsx, sheet = "Sheet1")
reg_name <- as.character(registry[["Item name"]])
reg_enc  <- as.character(registry[["Item encoded"]])
reg_cite <- as.character(registry[[1]])

## read_item() matches CASE-INSENSITIVELY and with spaces stripped, because the
## registry drifts between e.g. Table2 and TABLE2; the encoding keeps its own
## case, since DOIs and filenames are case-sensitive.
norm <- function(x) tolower(gsub(" ", "", x))
have_row <- !is.na(reg_name) & nzchar(reg_name)
lookup   <- setNames(reg_enc[have_row], norm(reg_name[have_row]))

tsv_files <- list.files(tsv_dir, pattern = "\\.tsv$")
on_disk   <- function(enc) paste0(enc, ".tsv") %in% tsv_files

# ---- Which item names does a merge reference? -------------------------------
## Deliberately loose and encoding-proof: an item name is "<Publication>_<Item
## number>" and a Publication name always carries a 4-digit year as its own
## segment, so "contains _YYYY_" is the whole test. A regex over letter classes
## would be the obvious alternative but stumbles on Rehkämper. Three exclusions
## keep it honest: file names, R regex literals (e.g. "^Stephan_etal_1981_..$"),
## and strings ending in "_" (sub() prefixes -- and a trailing underscore is
## itself the col-D-went-empty symptom, which the orphan check already covers).
referenced_items <- function(path) {
  src <- readLines(path, warn = FALSE, encoding = "UTF-8")
  src <- sub("#.*$", "", src)                       # comments never request an item
  hits <- unlist(regmatches(src, gregexpr('"[^"\n]*"', src)))
  hits <- gsub('^"|"$', "", hits)
  hits <- unique(hits[nzchar(hits)])
  keep <- grepl("_[0-9]{4}[a-z]?_", hits) &
    !grepl("[[:space:]]", hits) &
    !grepl("_$", hits) &
    !grepl("\\.(csv|tsv|r|xlsx|xls|md|txt|pdf|nex|tre)$", hits, ignore.case = TRUE) &
    # perl = TRUE deliberately: POSIX/TRE does not define backslash escapes
    # inside a bracket expression, so this class is only reliable under PCRE.
    !grepl("[\\^$()\\[\\]{}|*+?\\\\]", hits, perl = TRUE)
  sort(hits[keep])
}

## Each merge may carry its own enc_override fallback list. Take the block from
## "enc_override <- c(" until its parentheses balance, counting only parentheses
## OUTSIDE quotes -- several encodings contain them, e.g. s0047-2484(03)00028-9.
read_overrides <- function(path) {
  src <- readLines(path, warn = FALSE, encoding = "UTF-8")
  start <- grep("enc_override\\s*<-\\s*c\\(", src)
  if (!length(start)) return(character())
  depth <- 0L
  block <- character()
  for (i in seq(start[1], length(src))) {
    line <- sub("#.*$", "", src[i])
    block <- c(block, line)
    bare <- gsub('"[^"]*"', "", line)               # ignore parens inside strings
    depth <- depth + lengths(regmatches(bare, gregexpr("(", bare, fixed = TRUE))) -
      lengths(regmatches(bare, gregexpr(")", bare, fixed = TRUE)))
    if (depth <= 0L) break
  }
  block <- paste(block, collapse = "\n")
  pairs <- unlist(regmatches(block, gregexpr('"[^"]+"\\s*=\\s*"[^"]+"', block)))
  if (!length(pairs)) return(character())
  keys <- gsub('^"([^"]+)".*$', "\\1", pairs)
  vals <- gsub('^.*=\\s*"([^"]+)"$', "\\1", pairs)
  setNames(vals, keys)
}

## Mirror of read_item(): registry first, enc_override both as a fallback when
## the registry gives nothing AND as a repair when the registry resolves to a
## file that is not on disk.
resolve <- function(item, override) {
  enc <- unname(lookup[norm(item)])
  if (!is.na(enc)) enc <- gsub(" ", "", enc)
  if ((is.na(enc) || !nzchar(enc)) && item %in% names(override)) enc <- override[[item]]
  if (!is.na(enc) && nzchar(enc) && item %in% names(override) && !on_disk(enc))
    enc <- override[[item]]
  if (is.na(enc) || !nzchar(enc))
    return(list(enc = NA_character_,
                why = "no encoding (not in __ReadMe.xlsx 'Item name', no enc_override)"))
  if (!on_disk(enc)) return(list(enc = enc, why = "TSV not on disk"))
  list(enc = enc, why = NA_character_)
}

# ---- Run --------------------------------------------------------------------
merge_dirs <- list.dirs(root_dir, recursive = FALSE, full.names = TRUE)
merge_dirs <- merge_dirs[grepl("/__merging_[^/]+$", merge_dirs)]
scripts <- sort(unlist(lapply(merge_dirs, function(d)
  list.files(d, pattern = "_compiled(_select|_DeCasien)?\\.R$", full.names = TRUE))))

cat(sprintf("registry Item names: %d   |   TSVs on disk: %d   |   NA.tsv present: %s\n\n",
            sum(have_row), length(tsv_files),
            if ("NA.tsv" %in% tsv_files) "YES -- REMOVE IT" else "no"))

failures <- 0L
for (path in scripts) {
  rel      <- sub(paste0(root_dir, "/"), "", path, fixed = TRUE)
  override <- read_overrides(path)
  items    <- referenced_items(path)
  bad      <- list()
  for (it in items) {
    r <- resolve(it, override)
    if (!is.na(r$why)) bad[[length(bad) + 1L]] <- c(item = it, enc = r$enc, why = r$why)
  }
  cat(sprintf("%-58s %3d item name(s) referenced   %s\n", rel, length(items),
              if (!length(bad)) "OK" else sprintf("%d UNRESOLVED", length(bad))))
  for (b in bad)
    cat(sprintf("      %-46s -> %s%s\n", b[["item"]], b[["why"]],
                if (is.na(b[["enc"]])) "" else sprintf("  [%s]", b[["enc"]])))
  failures <- failures + length(bad)
}

# ---- Orphaned TSVs: the fingerprint of a lost registry row ------------------
claimed <- trimws(reg_enc[!is.na(reg_enc) & nzchar(reg_enc)])
orphans <- sort(setdiff(sub("\\.tsv$", "", tsv_files), claimed))
cat(sprintf("\norphaned TSVs (on disk, claimed by no registry row): %d\n", length(orphans)))
for (o in orphans)
  cat(sprintf("      %s.tsv   <- a registry row was lost after this file was built\n", o))

# ---- Rows added without running file_list.R -------------------------------
half_written <- which(!is.na(reg_cite) & nzchar(trimws(reg_cite)) &
                        (is.na(reg_name) | !nzchar(reg_name)))
cat(sprintf("rows with a citation but no Item name (need _tools/file_list.R): %d\n",
            length(half_written)))
for (i in half_written)
  cat(sprintf("      Sheet1 row %d: %s...\n", i + 1L, substr(reg_cite[i], 1, 60)))

cat(sprintf("\n%s\n", if (!failures) "all referenced item names resolve to a TSV on disk."
                      else sprintf("%d unresolved reference(s).", failures)))
if (length(orphans) || length(half_written))
  cat("run _tools/restore_registry_rows.R (adding any new row to its ROWS list),",
      "then _tools/file_list.R.\n")

status <- as.integer(failures > 0L || length(orphans) > 0L || length(half_written) > 0L)
if (!interactive()) quit(status = status)
invisible(status)
