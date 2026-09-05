# file_list.R
# -----------------------------------------------------------------------------
# 1. Validates the Sheet1 E:M naming/check formula family and fills only missing
#    formulas for populated registry rows. Existing formulas are never silently
#    replaced. Excel is asked to perform a full recalculation on next open.
# 2. Rebuilds the auto-generated "AUTO_Public_TSV_FileList" sheet in
#    __ReadMe.xlsx from the .tsv files in __Public/comparative-data (one file
#    name per row, no header). The directory is the sole source of truth; never
#    edit this worksheet manually.
# 3. Reports (to the R console only) the .tsv files in that folder whose name
#    is NOT catalogued in Sheet1 column L ("Item encoded"). These are orphan
#    data files (e.g. a .tsv that was renamed and no longer matches its encoded
#    entry in the ReadMe). No FileStrays sheet is written; any leftover
#    FileStrays sheet from a previous run is removed.
#
# Re-running is safe: the generated sheet is rebuilt each time; all other
# sheets (except the legacy FileList and stale FileStrays sheets) are preserved.
# -----------------------------------------------------------------------------

library(openxlsx)

# ---- Paths ------------------------------------------------------------------
## project root = nearest ancestor containing __ReadMe.xlsx (works from _tools/ or root,
## and on any clone, via Rscript / source() / RStudio)
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
file_dir    <- file.path(root_dir, "__Public", "comparative-data")
filelist_sheet <- "AUTO_Public_TSV_FileList"
source(file.path(root_dir, "_helpers", "openxlsx_compat.R"))
openxlsx_input <- openxlsx_compatible_copy(readme_xlsx)

# ---- .tsv files in the folder -----------------------------------------------
tsv_files <- list.files(file_dir, pattern = "\\.tsv$", ignore.case = TRUE)

# ---- Catalogued names from Sheet1's "Item encoded" column -------------------
# Read Sheet1 keeping the exact column positions (skipEmptyCols = FALSE), then
# locate "Item encoded" by header name rather than assuming a fixed column
# letter/index (the sheet has drifted from earlier fixed-position assumptions).
sheet1 <- read.xlsx(
  openxlsx_input,
  sheet         = "Sheet1",
  colNames      = TRUE,
  skipEmptyCols = FALSE,
  skipEmptyRows = FALSE
)

col_star_index <- which(grepl("Item.?encoded", names(sheet1), ignore.case = TRUE))[1]  # column with the Item encoded
if (is.na(col_star_index)) {
  warning("No column matching 'Item encoded' found in Sheet1's header row. Check column alignment.")
}
col_star_name <- if (!is.na(col_star_index)) names(sheet1)[col_star_index] else NA_character_

# Reproduce the E:L naming formulas in R. This gives deterministic cache values
# even when a row was just added and Excel has not opened/recalculated the file.
as_text <- function(x) if (length(x) == 0L || is.na(x)) "" else as.character(x)
text_before <- function(x, delimiter) {
  p <- regexpr(delimiter, x, fixed = TRUE)[1]
  if (p < 0L) "" else substr(x, 1L, p - 1L)
}
text_after <- function(x, delimiter) {
  p <- regexpr(delimiter, x, fixed = TRUE)[1]
  if (p < 0L) "" else substr(x, p + nchar(delimiter), nchar(x))
}
derive_formula_values <- function(data_row) {
  citation <- as_text(sheet1[data_row, 1])
  sequence <- as_text(sheet1[data_row, 2])
  doi_alt <- as_text(sheet1[data_row, 3])
  item_number <- as_text(sheet1[data_row, 4])
  year <- text_before(text_after(citation, "("), ")")
  authors <- text_before(citation, paste0(" (", year, ")"))
  first_author <- gsub("[- ]", "", text_before(citation, ","))
  has_amp <- grepl("&", authors, fixed = TRUE)
  other_author <- ""
  if (has_amp) {
    before_amp <- text_before(authors, "&")
    comma_count <- nchar(before_amp) - nchar(gsub(",", "", before_amp, fixed = TRUE))
    other_author <- if (comma_count > 2L) "etal" else trimws(text_before(text_after(authors, "& "), ","))
  }
  publication_name <- paste0(
    first_author,
    if (nzchar(other_author)) paste0("_", other_author) else "_",
    if (nzchar(year)) paste0("_", year) else "_",
    if (nzchar(sequence)) paste0("_", sequence) else ""
  )
  doi <- if (nzchar(doi_alt)) doi_alt else text_after(citation, "https://doi.org/")
  doi <- gsub("/", "%2F", doi, fixed = TRUE)
  doi <- gsub(":", "%3A", doi, fixed = TRUE)
  doi <- gsub("<", "%3C", doi, fixed = TRUE)
  doi <- gsub(">", "%3E", doi, fixed = TRUE)
  item_clean <- gsub("\u00a0", "", item_number, fixed = TRUE)
  item_clean <- gsub(" ", "", item_clean, fixed = TRUE)
  item_clean <- gsub("_", "", item_clean, fixed = TRUE)
  c(
    end = if (nzchar(citation)) substr(citation, nchar(citation), nchar(citation)) else "",
    publication_name = publication_name,
    first_author = first_author,
    other_authors = other_author,
    year = year,
    doi_encoded = doi,
    item_name = paste(publication_name, item_clean, sep = "_"),
    item_encoded = paste0(doi, "_", item_clean)
  )
}

populated_data_rows <- which(!is.na(sheet1[[1]]) & nzchar(trimws(as.character(sheet1[[1]]))))
populated_rows <- populated_data_rows + 1L
derived_cache <- setNames(lapply(populated_data_rows, derive_formula_values), populated_rows)
encoded <- unique(vapply(derived_cache, function(x) unname(x["item_encoded"]), character(1)))
encoded <- encoded[nzchar(encoded)]

# ---- Orphan .tsv check (console only) ---------------------------------------
# A .tsv is a match if its name without the extension is in column L.
# Also allow a full-name match, in case an L entry includes the extension.
tsv_stems <- tools::file_path_sans_ext(tsv_files)
is_match  <- tsv_stems %in% encoded | tsv_files %in% encoded
strays    <- tsv_files[!is_match]

# ---- Rebuild generated file list; migrate old formula references ------------
wb <- loadWorkbook(openxlsx_input)

# Sheet1 naming formulas are a protected convention. Audit every explicit
# (non-shared-continuation) formula against the canonical family, and fill only
# genuinely missing formula cells on rows whose citation in column A is present.
formula_family <- function(r) c(
  sprintf('SUBSTITUTE(SUBSTITUTE(_xlfn.TEXTBEFORE(A%d,","), "-", ""), " ", "")', r),   # E: 1st Author
  paste0(                                                                              # F: other author(s)
    "_xlfn.LET(\n",
    sprintf('_xlpm.authors,_xlfn.TEXTBEFORE(A%d," ("&G%d&")"),\n', r, r),
    '_xlpm.hasAmp,ISNUMBER(SEARCH("&",_xlpm.authors)),\n',
    '_xlpm.commasBeforeAmp,IF(_xlpm.hasAmp,LEN(_xlfn.TEXTBEFORE(_xlpm.authors,"&"))-LEN(SUBSTITUTE(_xlfn.TEXTBEFORE(_xlpm.authors,"&"),",","")),0),\n',
    'IF(NOT(_xlpm.hasAmp),"",IF(_xlpm.commasBeforeAmp>2,"etal",TRIM(_xlfn.TEXTBEFORE(_xlfn.TEXTAFTER(_xlpm.authors,"& "),","))))\n',
    ")"
  ),
  sprintf('_xlfn.TEXTBEFORE(_xlfn.TEXTAFTER(A%d, "("), ")")', r),                       # G: year
  sprintf('E%d & IF(F%d<>"", "_" & F%d, "_") & IF(G%d<>"", "_" & G%d, "_") & IF(B%d<>"", "_" & B%d, "")',
          r, r, r, r, r, r, r),                                                        # H: Publication name
  paste0(                                                                              # I: DOI (or Alt)
    "_xlfn.LET(\n",
    sprintf('_xlpm.doi,IF(C%d<>"",C%d,_xlfn.TEXTAFTER(A%d,"https://doi.org/")),\n', r, r, r),
    "SUBSTITUTE(\nSUBSTITUTE(\nSUBSTITUTE(\nSUBSTITUTE(\n",
    '_xlpm.doi,\n"/","%2F"),\n":","%3A"),\n"<","%3C"),\n">","%3E")\n',
    ")"
  ),
  sprintf('TRIM(_xlfn.TEXTJOIN("_",FALSE(),H%d,(SUBSTITUTE(SUBSTITUTE(D%d," ",""), "_", ""))))', r, r),  # J: Item name
  sprintf('I%d & "_" & SUBSTITUTE(SUBSTITUTE(SUBSTITUTE(D%d,CHAR(160),""), " ", ""), "_", "")', r, r),   # K: Item encoded
  sprintf("IFERROR(INDEX('%s'!$A$1:$A$1000,MATCH(TRUE(),EXACT(K%d,IFERROR(_xlfn.TEXTBEFORE('%s'!$A$1:$A$1000,\".tsv\"),\"\")),0)),\"notfound\")",
          filelist_sheet, r, filelist_sheet)                                           # L: Public TSV match
)
normalize_formula <- function(x) {
  x <- gsub("'AUTO_Public_TSV_FileList'!", "AUTO_Public_TSV_FileList!", x, fixed = TRUE)
  gsub("[[:space:]]+", "", x)
}
formula_text <- function(xml) {
  x <- sub("^<f[^>]*>", "", xml)
  x <- sub("</f>$", "", x)
  x <- gsub("&quot;", '"', x, fixed = TRUE)
  x <- gsub("&apos;", "'", x, fixed = TRUE)
  x <- gsub("&#10;", "\n", x, fixed = TRUE)
  x <- gsub("&lt;", "<", x, fixed = TRUE)
  x <- gsub("&gt;", ">", x, fixed = TRUE)
  gsub("&amp;", "&", x, fixed = TRUE)
}

sheet1_index <- match("Sheet1", names(wb))
sheet_data <- wb$worksheets[[sheet1_index]]$sheet_data

# Migrate only the historical sheet token `FileList!`; do not perform a bare
# substring replacement because that also matches the end of the new sheet
# name. The first two replacements repair files produced by the older unsafe
# migration before the formula audit runs.
formula_cells <- !is.na(sheet_data$f)
if (any(formula_cells)) {
  formulas <- sheet_data$f[formula_cells]
  formulas <- gsub(
    "AUTO_Public_TSV_'AUTO_Public_TSV_FileList'!",
    "'AUTO_Public_TSV_FileList'!",
    formulas,
    fixed = TRUE
  )
  formulas <- gsub(
    "AUTO_Public_TSV_&apos;AUTO_Public_TSV_FileList&apos;!",
    "&apos;AUTO_Public_TSV_FileList&apos;!",
    formulas,
    fixed = TRUE
  )
  formulas <- gsub(
    "(?<![[:alnum:]_])(?:&apos;|')?FileList(?:&apos;|')?!",
    "&apos;AUTO_Public_TSV_FileList&apos;!",
    formulas,
    perl = TRUE
  )
  sheet_data$f[formula_cells] <- formulas
  wb$worksheets[[sheet1_index]]$sheet_data <- sheet_data
}

missing_formulas <- list()
formula_mismatches <- character()
for (r in populated_rows) {
  expected <- formula_family(r)
  for (j in seq_along(expected)) {
    c <- j + 4L
    hit <- which(sheet_data$rows == r & sheet_data$cols == c)
    xml <- if (length(hit)) sheet_data$f[hit[1]] else NA_character_
    if (!length(hit) || is.na(xml) || !nzchar(xml)) {
      missing_formulas[[length(missing_formulas) + 1L]] <- c(row = r, col = c, formula = expected[j])
      next
    }
    actual <- formula_text(xml)
    # Empty text is a valid continuation of an Excel shared-formula block.
    if (nzchar(actual) && !identical(normalize_formula(actual), normalize_formula(expected[j]))) {
      formula_mismatches <- c(formula_mismatches, sprintf("%s%d", int2col(c), r))
    }
  }
}
if (length(formula_mismatches)) {
  stop("Non-canonical Sheet1 naming formula(s): ", paste(formula_mismatches, collapse = ", "),
       ". Review explicitly; file_list.R will not overwrite them.")
}
if (length(missing_formulas)) {
  for (entry in missing_formulas) {
    writeFormula(wb, sheet = "Sheet1", x = unname(entry["formula"]),
                 startRow = as.integer(entry["row"]), startCol = as.integer(entry["col"]),
                 array = as.integer(entry["col"]) == 13L)
  }
}
# openxlsx does not calculate formulas; require Excel to refresh their cached
# values (including column M's file-existence check) the next time it opens.
wb$workbook$calcPr <- '<calcPr calcId="191029" calcMode="auto" fullCalcOnLoad="1" forceFullCalc="1"/>'

# E:L and M are deterministic, so refresh their cached values directly while
# retaining every Excel formula. Non-Excel readers are therefore accurate
# immediately after this script runs.
sheet_data <- wb$worksheets[[sheet1_index]]$sheet_data
m_found <- 0L
for (r in populated_rows) {
  values <- derived_cache[[as.character(r)]]
  for (j in seq_along(values)) {
    c <- j + 4L
    hit <- which(sheet_data$rows == r & sheet_data$cols == c)
    if (length(hit)) {
      sheet_data$t[hit[1]] <- 3L
      sheet_data$v[hit[1]] <- if (nzchar(values[j])) unname(values[j]) else NA_character_
    }
  }
  encoded_value <- unname(values["item_encoded"])
  expected_file <- if (is.na(encoded_value) || !nzchar(encoded_value)) {
    NA_character_
  } else if (grepl("\\.tsv$", encoded_value, ignore.case = TRUE)) {
    encoded_value
  } else {
    paste0(encoded_value, ".tsv")
  }
  cache_value <- if (!is.na(expected_file) && expected_file %in% tsv_files) expected_file else "notfound"
  m_found <- m_found + as.integer(cache_value != "notfound")
  hit <- which(sheet_data$rows == r & sheet_data$cols == 13L)
  if (length(hit)) {
    sheet_data$t[hit[1]] <- 3L
    sheet_data$v[hit[1]] <- cache_value
  }
}
wb$worksheets[[sheet1_index]]$sheet_data <- sheet_data

for (sheet_name in c(filelist_sheet, "FileList", "FileStrays")) {
  if (sheet_name %in% names(wb)) removeWorksheet(wb, sheet_name)
}

addWorksheet(wb, filelist_sheet)
writeData(
  wb,
  sheet    = filelist_sheet,
  x        = data.frame(tsv_files, stringsAsFactors = FALSE),
  colNames = FALSE
)

# Make the maintenance rule visible from the main registry without duplicating
# the generated list or adding a header row to it.
writeData(
  wb,
  sheet    = "Sheet1",
  x        = "Public TSV match from AUTO_Public_TSV_FileList (generated by _tools/file_list.R; do not edit manually)",
  startCol = 13,
  startRow = 1,
  colNames = FALSE
)
setColWidths(wb, sheet = "Sheet1", cols = 13, widths = 52)
removeComment(wb, sheet = "Sheet1", cols = 13, rows = 1)

# The historical workbook contains empty drawing relationships whose target
# files do not exist. openxlsx tolerates them, but stricter workbook readers do
# not. Retain real drawings/VML objects and drop only relationships with no
# corresponding in-memory object.
for (sheet_index in seq_along(wb$worksheets_rels)) {
  relationships <- wb$worksheets_rels[[sheet_index]]
  if (length(wb$drawings[[sheet_index]]) == 0L) {
    relationships <- relationships[!grepl("/drawing\"", relationships)]
  }
  if (length(wb$vml[[sheet_index]]) == 0L && length(wb$comments[[sheet_index]]) == 0L) {
    relationships <- relationships[!grepl("/vmlDrawing\"", relationships)]
  }
  wb$worksheets_rels[[sheet_index]] <- relationships
}

saveWorkbook(wb, readme_xlsx, overwrite = TRUE)

# ---- Console summary --------------------------------------------------------
cat(sprintf("%s: %d .tsv files written to __ReadMe.xlsx (no header)\n",
            filelist_sheet, length(tsv_files)))
cat(sprintf("Sheet1 naming formulas: %d missing cell(s) filled; existing formulas validated\n",
            length(missing_formulas)))
cat(sprintf("Sheet1 E:L cache: %d populated registry row(s) refreshed from A:D\n",
            length(populated_rows)))
cat(sprintf("Sheet1 column M cache: %d populated registry item(s) matched a public TSV\n", m_found))
cat(sprintf("Orphan .tsv file(s) not found in Sheet1 column L: %d\n", length(strays)))
if (length(strays) > 0) {
  cat(paste0("  - ", strays, collapse = "\n"), "\n")
} else {
  cat("  (none)\n")
}
