## Isler et al. (2008). Endocranial volumes of primate species:
## scaling analyses using a comprehensive and reliable data set.
## Journal of Human Evolution 55:967-978. DOI: 10.1016/j.jhevol.2008.08.004
## TableS2
##
## Build step only: frozen snapshot -> DOI-coded public TSV.
## The snapshot is copied byte-for-byte so the public TSV retains the attached
## multirow headers, column names, quoting, blank cells, Unicode, and precision.
##
## Input : Isler_etal_2008_TableS2_snapshot.tsv
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
snapshot <- file.path(folder, "Isler_etal_2008_TableS2_snapshot.tsv")
stopifnot(file.exists(snapshot), file.info(snapshot)$size > 0)
raw <- readBin(snapshot, what = "raw", n = file.info(snapshot)$size)
local_tsv <- file.path(folder, paste0(item_name, ".tsv"))
con <- file(local_tsv, "wb"); writeBin(raw, con); close(con)
stopifnot(identical(unname(tools::md5sum(snapshot)), unname(tools::md5sum(local_tsv))))
message(item_name, ": wrote byte-identical local TSV")

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
    out <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
    con <- file(out, "wb"); writeBin(raw, con); close(con)
    stopifnot(identical(unname(tools::md5sum(snapshot)), unname(tools::md5sum(out))))
    message("Wrote byte-identical ", out)
  }
}
