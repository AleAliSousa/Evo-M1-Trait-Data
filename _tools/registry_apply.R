# registry_apply.R -- apply registry changes from a CSV instead of pasting by hand.
#
# WHY THIS EXISTS
#   Two mechanisms were tried and both are bad. Pasting rows into Sheet1 by hand is
#   slow and error-prone at this volume. Editing __ReadMe.xlsx with a generic XML/
#   python writer corrupted the workbook on 2026-10-31 and the owner had to repair it.
#   This script uses the SAME path file_list.R has always used safely: openxlsx
#   loadWorkbook -> writeData -> saveWorkbook, via _helpers/openxlsx_compat.R, run
#   from RStudio with Excel closed.
#
# WHAT IT DOES
#   Reads a plain CSV of requested changes and applies them to Sheet1:
#     action=edit  set one cell on an existing row, located BY ITEM NAME
#     action=new   append one new row
#   Owner-owned columns only: A, C, D and N..AH. The generated band B and E..M is
#   refused outright -- those are formulas owned by file_list.R.
#
# USAGE (from the repo root, Excel CLOSED)
#   Rscript --vanilla _tools/registry_apply.R                  # dry run, changes nothing
#   Rscript --vanilla _tools/registry_apply.R --apply          # write
#   Rscript --vanilla _tools/registry_apply.R --apply --csv=my_changes.csv
#   then run _tools/file_list.R to refresh the E:L formula band.
#
# CSV COLUMNS
#   action        edit | new
#   item_name     for edit: the Sheet1 Item name to find. for new: the name you
#                 EXPECT the formula to derive, recorded so the result can be checked.
#   column        for edit: the Sheet1 header text, e.g. "Progress stage"
#   value         the value to write
#   note          free text, ignored by the script
#   For action=new, give one row per CELL (same item_name, different column), the
#   same way edits are written. The script groups them into a single appended row.
#
# SAFETY
#   - dry run by default; --apply is explicit
#   - timestamped backup before writing
#   - refuses an edit whose item_name is missing, or matches more than one row
#   - refuses any write to B or E..M
#   - every written cell is shaded light blue (FFD9E8FB) so changes are reviewable
#   - re-reads and verifies every cell after saving; reports a failure loudly
#   - idempotent: a cell already holding the requested value is reported as a no-op

suppressWarnings(suppressMessages(library(openxlsx)))

args      <- commandArgs(trailingOnly = TRUE)
do_apply  <- "--apply" %in% args
csv_arg   <- grep("^--csv=", args, value = TRUE)

self <- tryCatch(normalizePath(sub("^--file=", "",
         grep("^--file=", commandArgs(FALSE), value = TRUE)[1])), error = function(e) NA)
if (is.na(self)) stop("Run this saved script with Rscript.")
root_dir    <- dirname(dirname(self))
readme_xlsx <- file.path(root_dir, "__ReadMe.xlsx")
csv_path    <- if (length(csv_arg)) sub("^--csv=", "", csv_arg[1]) else
                 file.path(root_dir, "_checks", "registry_pending.csv")
if (!file.exists(readme_xlsx)) stop("No __ReadMe.xlsx at ", readme_xlsx)
if (!file.exists(csv_path))    stop("No change CSV at ", csv_path)

source(file.path(root_dir, "_helpers", "openxlsx_compat.R"))
compat <- openxlsx_compatible_copy(readme_xlsx)

changes <- read.csv(csv_path, stringsAsFactors = FALSE, check.names = FALSE,
                    colClasses = "character", na.strings = NULL, encoding = "UTF-8")
need <- c("action", "item_name", "column", "value")
if (!all(need %in% names(changes))) stop("CSV must have columns: ", paste(need, collapse = ", "))
changes <- changes[trimws(changes$action) != "", , drop = FALSE]
if (!nrow(changes)) { message("No change rows in ", csv_path); quit(save = "no") }
changes$action <- tolower(trimws(changes$action))
if (!all(changes$action %in% c("edit", "new")))
  stop("action must be 'edit' or 'new'; saw: ",
       paste(unique(setdiff(changes$action, c("edit", "new"))), collapse = ", "))

header <- as.character(read.xlsx(compat, sheet = "Sheet1", rows = 1, colNames = FALSE))
sheet  <- read.xlsx(compat, sheet = "Sheet1", colNames = TRUE, skipEmptyRows = FALSE,
                    skipEmptyCols = FALSE, sep.names = " ")
name_col <- match("Item name", header)
if (is.na(name_col)) stop("Sheet1 has no 'Item name' column")

# Generated band: B and E..M belong to file_list.R.
GENERATED <- c(2L, 5:13)
col_of <- function(h) {
  i <- match(h, header)
  if (is.na(i)) stop("No Sheet1 column named '", h, "'")
  if (i %in% GENERATED)
    stop("Refusing to write '", h, "' (column ", int2col(i),
         "): it is a generated formula owned by file_list.R.")
  i
}
# Sheet1 data starts at row 2; read.xlsx row i is Sheet1 row i+1.
item_names <- as.character(sheet[[name_col]])
row_of <- function(nm) {
  hit <- which(!is.na(item_names) & trimws(item_names) == trimws(nm))
  if (!length(hit)) stop("No Sheet1 row with Item name '", nm, "'")
  if (length(hit) > 1L)
    stop("Item name '", nm, "' matches ", length(hit),
         " Sheet1 rows; resolve by hand (the #n multi-row convention needs an explicit row).")
  hit[1L] + 1L
}
last_row <- max(which(apply(sheet, 1, function(r) any(!is.na(r) & trimws(r) != "")))) + 1L

plan <- list()
# ---- edits
ed <- changes[changes$action == "edit", , drop = FALSE]
for (i in seq_len(nrow(ed))) {
  ci <- col_of(ed$column[i]); ri <- row_of(ed$item_name[i])
  cur <- sheet[ri - 1L, ci]; cur <- if (is.na(cur)) "" else as.character(cur)
  plan[[length(plan) + 1L]] <- list(row = ri, col = ci, item = ed$item_name[i],
    header = ed$column[i], before = cur, after = ed$value[i],
    kind = if (identical(trimws(cur), trimws(ed$value[i]))) "no-op"
           else if (!nzchar(trimws(cur))) "fill" else "overwrite")
}
# ---- new rows, grouped by item_name
nw <- changes[changes$action == "new", , drop = FALSE]
new_items <- unique(nw$item_name)
for (k in seq_along(new_items)) {
  ri <- last_row + k
  sub <- nw[nw$item_name == new_items[k], , drop = FALSE]
  for (i in seq_len(nrow(sub))) {
    ci <- col_of(sub$column[i])
    plan[[length(plan) + 1L]] <- list(row = ri, col = ci, item = new_items[k],
      header = sub$column[i], before = "", after = sub$value[i], kind = "new row")
  }
}

kinds <- vapply(plan, function(p) p$kind, "")
cat(sprintf("%s: %d cell(s) -- %d new-row cell(s) across %d new row(s), %d fill, %d overwrite, %d no-op\n",
            basename(csv_path), length(plan), sum(kinds == "new row"), length(new_items),
            sum(kinds == "fill"), sum(kinds == "overwrite"), sum(kinds == "no-op")))
for (p in plan[kinds == "overwrite"])
  cat(sprintf("  OVERWRITE %s!%s%d  %-34s '%s' -> '%s'\n", "Sheet1", int2col(p$col), p$row,
              substr(p$header, 1, 34), substr(p$before, 1, 40), substr(p$after, 1, 40)))

todo <- plan[kinds != "no-op"]
if (!length(todo)) { message("Nothing to do; every requested value is already in place."); quit(save = "no") }
if (!do_apply) {
  message("\nDRY RUN -- nothing written. Re-run with --apply to write these ", length(todo), " cell(s).")
  quit(save = "no")
}

stamp  <- format(Sys.time(), "%Y%m%d_%H%M%S")
backup <- file.path(root_dir, "_checks", sprintf("__ReadMe_backup_%s.xlsx", stamp))
file.copy(readme_xlsx, backup, overwrite = FALSE)
message("Backup: ", sub(paste0(root_dir, "/"), "", backup, fixed = TRUE))

wb <- loadWorkbook(compat)
mark <- createStyle(fgFill = "#D9E8FB")
for (p in todo) {
  writeData(wb, sheet = "Sheet1", x = p$after, startRow = p$row, startCol = p$col,
            colNames = FALSE, rowNames = FALSE)
  addStyle(wb, sheet = "Sheet1", style = mark, rows = p$row, cols = p$col,
           gridExpand = FALSE, stack = TRUE)
}
# Make Excel recompute the formula band the next time it opens the file.
wb$workbook$calcPr <- '<calcPr calcId="191029" calcMode="auto" fullCalcOnLoad="1" forceFullCalc="1"/>'
saveWorkbook(wb, readme_xlsx, overwrite = TRUE)

# ---- verify from disk
check  <- read.xlsx(openxlsx_compatible_copy(readme_xlsx), sheet = "Sheet1",
                    colNames = TRUE, skipEmptyRows = FALSE, skipEmptyCols = FALSE, sep.names = " ")
bad <- character()
for (p in todo) {
  got <- check[p$row - 1L, p$col]; got <- if (is.na(got)) "" else as.character(got)
  if (!identical(trimws(got), trimws(p$after)))
    bad <- c(bad, sprintf("%s%d (wanted '%s', found '%s')", int2col(p$col), p$row, p$after, got))
}
if (length(bad)) {
  stop("WROTE BUT COULD NOT VERIFY ", length(bad), " cell(s). Restore from ", backup, ":\n  ",
       paste(bad, collapse = "\n  "))
}
message("Applied and verified ", length(todo), " cell(s); all shaded light blue.")
if (length(new_items))
  message("Appended ", length(new_items), " row(s) at Sheet1 rows ",
          last_row + 1L, "-", last_row + length(new_items), ".")
message("Now run _tools/file_list.R to refresh the E:L formula band, then check column K.")
