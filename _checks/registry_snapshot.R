#!/usr/bin/env Rscript
# registry_snapshot.R
# -----------------------------------------------------------------------------
# A git-trackable CSV copy of __ReadMe.xlsx Sheet1, so a row that disappears
# leaves a trace.
#
# WHY THIS EXISTS
#   The workbook loses whole rows. Six were found gone on 2026-08-20 -- two
#   Zilles, two Young, Upham, Winkler -- and one of them (Upham) had written its
#   TSV at 12:20 that same morning, during the sweep, so the row was alive at
#   12:20 and gone by mid-afternoon. Nothing recorded the loss: the workbook is
#   binary, so `git diff` says only "__ReadMe.xlsx changed", and the merges that
#   depended on those rows either halted with an unhelpful message or silently
#   read the wrong file. A plain-text snapshot makes the same loss show up as a
#   deleted line in a diff you can actually read.
#
# WHAT IT WRITES
#   _checks/registry_snapshot.csv          every cell of Sheet1, as text
#   _checks/registry_snapshot_changes.csv  what moved since the last run
#
#   Rows are sorted by Item name, NOT left in sheet order, because Sheet1
#   re-sorts itself -- an unsorted dump would show every re-sort as a huge diff
#   and bury the one line that matters. Every value is read as text so a year
#   never turns into 1988.0 and a diff never fires on number formatting.
#
# WHAT IT DOES ON A DELETION
#   Prints a banner naming every Item name that vanished, and records it in the
#   changes file. It does NOT fail: this runs inside a ~300-script sweep, and a
#   deliberate removal should not halt the run. The banner plus `git diff
#   _checks/registry_snapshot.csv` is the signal.
#
# Read-only with respect to the workbook. Runs in run_all_scripts_v2.R by
# virtue of living here; within _checks/ it sorts after file_list.R, which is
# what you want -- file_list.R fills Sheet1's generated E:M columns, so
# snapshotting afterwards records the settled values rather than blanks that
# would show up as a spurious change on the next run.
# -----------------------------------------------------------------------------

suppressPackageStartupMessages(library(readxl))

HERE <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(dirname(normalizePath(f)))
  sf <- tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) NULL)
  if (!is.null(sf)) return(sf)
  normalizePath(getwd())
})
root_dir <- local({
  d <- HERE
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else HERE
})
readme_xlsx  <- file.path(root_dir, "__ReadMe.xlsx")
snapshot_csv <- file.path(HERE, "registry_snapshot.csv")
changes_csv  <- file.path(HERE, "registry_snapshot_changes.csv")

## col_types = "text" throughout: a faithful copy, and it stops readxl coercing
## years and counts into doubles that would render as 1988.0 in the CSV.
sheet <- read_excel(readme_xlsx, sheet = "Sheet1", col_types = "text",
                    .name_repair = "minimal")
sheet <- as.data.frame(sheet, stringsAsFactors = FALSE, check.names = FALSE)
for (j in seq_along(sheet)) {
  v <- as.character(sheet[[j]])
  v[is.na(v)] <- ""
  sheet[[j]] <- v
}

item  <- if ("Item name" %in% names(sheet)) sheet[["Item name"]] else rep("", nrow(sheet))
cite  <- sheet[[1]]

## Row identity. Item name is the natural key, but planned rows have none yet and
## a duplicated Item name is possible (Young et al. 2013 was registered twice
## before column B was used to separate them), so fall back to the citation and
## number any remaining collisions. Deterministic, which is the only requirement.
key <- ifelse(nzchar(item), item,
              paste0("(no item name) ", substr(cite, 1, 60)))
dup <- ave(seq_along(key), key, FUN = seq_along)
key <- ifelse(dup > 1L, paste0(key, " #", dup), key)

keep <- nzchar(trimws(cite)) | nzchar(trimws(item))
sheet <- sheet[keep, , drop = FALSE]
key   <- key[keep]

ord   <- order(key, method = "radix")
sheet <- sheet[ord, , drop = FALSE]
key   <- key[ord]
out   <- cbind(registry_key = key, sheet, stringsAsFactors = FALSE)

# ---- compare with the previous run ------------------------------------------
prev <- if (file.exists(snapshot_csv)) {
  read.csv(snapshot_csv, colClasses = "character", check.names = FALSE,
           na.strings = character(0))
} else NULL

changes <- data.frame(change = character(), registry_key = character(),
                      column = character(), was = character(), now = character(),
                      stringsAsFactors = FALSE)
removed <- character()

if (is.null(prev)) {
  cat("registry_snapshot: no previous snapshot -- writing the first one.\n")
} else {
  prev_key <- prev[["registry_key"]]
  removed  <- setdiff(prev_key, key)
  added    <- setdiff(key, prev_key)

  if (length(removed))
    changes <- rbind(changes, data.frame(change = "ROW REMOVED", registry_key = removed,
                                         column = "", was = "", now = "",
                                         stringsAsFactors = FALSE))
  if (length(added))
    changes <- rbind(changes, data.frame(change = "row added", registry_key = added,
                                         column = "", was = "", now = "",
                                         stringsAsFactors = FALSE))

  ## Cell-level changes on rows present in both, for columns present in both.
  both <- intersect(prev_key, key)
  cols <- intersect(names(prev), names(out))
  cols <- setdiff(cols, "registry_key")
  if (length(both) && length(cols)) {
    pi <- match(both, prev_key); ni <- match(both, key)
    for (cn in cols) {
      a <- as.character(prev[[cn]])[pi]
      b <- as.character(out[[cn]])[ni]
      a[is.na(a)] <- ""; b[is.na(b)] <- ""
      d <- which(a != b)
      if (length(d))
        changes <- rbind(changes, data.frame(
          change = ifelse(nzchar(a[d]) & !nzchar(b[d]), "CELL EMPTIED", "cell changed"),
          registry_key = both[d], column = cn, was = a[d], now = b[d],
          stringsAsFactors = FALSE))
    }
  }
}

write.csv(out, snapshot_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(changes, changes_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- report ------------------------------------------------------------------
emptied <- sum(changes$change == "CELL EMPTIED")
cat(sprintf("registry_snapshot: %d row(s) x %d column(s) -> %s\n",
            nrow(out), ncol(out) - 1L, basename(snapshot_csv)))

if (length(removed)) {
  cat("\n")
  cat(strrep("=", 78), "\n", sep = "")
  cat(sprintf("  %d REGISTRY ROW(S) DISAPPEARED FROM __ReadMe.xlsx SINCE THE LAST SNAPSHOT\n",
              length(removed)))
  cat(strrep("=", 78), "\n", sep = "")
  for (k in sort(removed, method = "radix")) cat("  - ", k, "\n", sep = "")
  cat("\n  If any of them has a TSV in __Public/comparative-data, the merges will read\n")
  cat("  the wrong file or halt. Restore with _tools/restore_registry_rows.R, then\n")
  cat("  confirm with _checks/check_item_name_resolution.R.\n")
  cat("  `git diff ", basename(snapshot_csv), "` shows exactly what the rows held.\n\n", sep = "")
} else if (!is.null(prev)) {
  cat("registry_snapshot: no rows removed.\n")
}
if (emptied)
  cat(sprintf("registry_snapshot: %d cell(s) went from a value to empty -- see %s\n",
              emptied, basename(changes_csv)))
if (nrow(changes))
  cat(sprintf("registry_snapshot: %d change(s) recorded in %s\n",
              nrow(changes), basename(changes_csv)))
