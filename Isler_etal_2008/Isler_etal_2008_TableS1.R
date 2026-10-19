## Isler et al. (2008). Endocranial volumes of primate species:
## scaling analyses using a comprehensive and reliable data set.
## Journal of Human Evolution 55:967-978. DOI: 10.1016/j.jhevol.2008.08.004
## TableS1
##
## Build step only: frozen snapshot -> DOI-coded public TSV.
## The snapshot is copied byte-for-byte so the public TSV retains the attached
## multirow headers, column names, quoting, blank cells, Unicode, and precision.
##
## Input : Isler_etal_2008_TableS1_snapshot.tsv
## Output: <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
## Snapshot and local working copy are comma-delimited CSV. Only the copy written to
## __Public/comparative-data/ is tab-delimited -- that conversion happens at write time
## below, reading every field as literal text (no type guessing, no NA substitution) so
## values, blanks, and Unicode pass through unchanged; only the delimiter/quoting style
## changes relative to the frozen CSV snapshot.
suppressPackageStartupMessages(library(readr))
snapshot <- file.path(folder, "Isler_etal_2008_TableS1_snapshot.csv")
stopifnot(file.exists(snapshot), file.info(snapshot)$size > 0)
local_csv <- file.path(folder, paste0(item_name, ".csv"))
file.copy(snapshot, local_csv, overwrite = TRUE)
stopifnot(identical(unname(tools::md5sum(snapshot)), unname(tools::md5sum(local_csv))))
message(item_name, ": wrote byte-identical local CSV")

if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx not found; public TSV skipped.")
} else {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
  } else {
    ## readr::write_tsv() mis-escapes a field whose text literally begins or ends with a
    ## quote character (it doubles only the boundary quote instead of wrapping the whole
    ## field in an outer quote pair, per RFC4180) -- verified against this table's own
    ## data (a locality field quoted in the original export, "La Naboke North"). Write
    ## TSV fields by hand instead, quoting exactly when RFC4180 requires it.
    write_tsv_safe <- function(df, path) {
      mat <- as.matrix(df)
      mat[is.na(mat)] <- ""
      mat[] <- enc2utf8(mat)
      needs_quote <- function(x) grepl("\t", x, fixed = TRUE) | grepl("\"", x, fixed = TRUE) | grepl("[\r\n]", x)
      nq <- apply(mat, c(1, 2), needs_quote)
      mat[nq] <- paste0("\"", gsub("\"", "\"\"", mat[nq], fixed = TRUE), "\"")
      lines <- apply(mat, 1, paste, collapse = "\t")
      con <- file(path, "wb")
      writeLines(enc2utf8(lines), con, sep = "\r\n", useBytes = TRUE)
      close(con)
    }
    raw <- read_csv(snapshot, col_names = FALSE, col_types = cols(.default = "c"), na = character(), trim_ws = FALSE)
    out <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
    write_tsv_safe(raw, out)
    message("Wrote ", out)
  }
}
