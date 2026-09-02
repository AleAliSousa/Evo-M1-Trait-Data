# Register the 2026-08-24 Armstrong, Campos & Welker, and Halley & Krubitzer
# dispositions without round-tripping the full registry through openxlsx.
#
# The workbook contains Microsoft/OneDrive XML that openxlsx can realign when it
# saves. This script therefore replaces only named cells in sheet1.xml and then
# proves that every other readable workbook cell is unchanged.

suppressPackageStartupMessages(library(readxl))

if (!requireNamespace("zip", quietly = TRUE)) {
  stop("Package 'zip' is required.")
}

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)[1]
script <- normalizePath(sub("^--file=", "", script_arg))
root <- normalizePath(file.path(dirname(script), ".."))
workbook <- file.path(root, "__ReadMe.xlsx")

updates <- data.frame(
  row = c(
    rep(3L, 6),
    rep(41L, 6),
    rep(95L, 5)
  ),
  column = c(
    "N", "P", "Q", "S", "T", "U",
    "N", "P", "Q", "S", "T", "U",
    "P", "Q", "S", "T", "U"
  ),
  value = c(
    "10.1002%2Fajpa.1330510308_Tables1-9.tsv",
    "BUILT: 106 source rows transcribed from Tables 1-9; volume, neuronal density/count, and neuronal perikaryal-volume products written. Hylo.-s and Hylo.-h are linked as hemispheres of one gibbon.",
    "FINISHED",
    "Armstrong__1979_Tables1-9_snapshot.csv",
    "Literature-comparison rows tagged secondary; one-gibbon hemisphere crosswalk added; printed source discrepancies retained and documented.",
    "Armstrong__1979_Tables1-9.csv",
    "10.1159%2F000123814_Table1.tsv",
    "BUILT: 2 specimens x 20 measures; separate volume, cortical-morphometry, and cell-count products plus a combined public TSV.",
    "FINISHED",
    "Campos_Welker_1976_Table1_snapshot.csv",
    "Mixed measures normalized to a long table and split by datatype; printed guinea-pig cortico-thalamic and caudate-density discrepancies retained and documented.",
    "Campos_Welker_1976_Table1.csv",
    "DOCUMENTED SKIP: source audit reconstructs all 39 plotted values (37 Stephan et al. 1981; 2 Campos & Welker 1976), so digitizing Figure 1 would duplicate upstream data.",
    "DOCUMENTED SKIP",
    "Halley_Krubitzer_2019_Figure1_source_map.csv",
    "All seven printed ratios reproduce; caption/reference and marmoset-label inconsistencies documented in the README and audit output.",
    "Halley_Krubitzer_2019_Figure1_source_audit.csv"
  ),
  stringsAsFactors = FALSE
)

expected_items <- c(
  `3` = "Armstrong__1979_Tables1-9",
  `41` = "Campos_Welker_1976_Table1",
  `95` = "Halley_Krubitzer_2019_Figure1"
)
allowed_stages <- list(
  `3` = c("PLANNED", "FINISHED"),
  `41` = c("PLANNED", "FINISHED"),
  `95` = c("PLANNED - SOURCE AUDIT", "DOCUMENTED SKIP")
)

read_registry <- function(path) {
  suppressMessages(read_excel(
    path,
    sheet = "Sheet1",
    col_names = FALSE,
    col_types = "text",
    .name_repair = "minimal"
  ))
}

before <- read_registry(workbook)
for (row_text in names(expected_items)) {
  row <- as.integer(row_text)
  if (!identical(before[[12]][row], unname(expected_items[row_text]))) {
    stop("Registry row guard failed at row ", row, ": expected Item name '",
         expected_items[row_text], "'.")
  }
  if (!(before[[17]][row] %in% allowed_stages[[row_text]])) {
    stop("Registry stage guard failed at row ", row, ": '", before[[17]][row], "'.")
  }
}

xml_escape <- function(value) {
  value <- gsub("&", "&amp;", value, fixed = TRUE)
  value <- gsub("<", "&lt;", value, fixed = TRUE)
  value <- gsub(">", "&gt;", value, fixed = TRUE)
  value <- gsub("\"", "&quot;", value, fixed = TRUE)
  gsub("'", "&apos;", value, fixed = TRUE)
}

column_number <- function(column) {
  letters <- utf8ToInt(column) - utf8ToInt("A") + 1L
  as.integer(sum(letters * 26L ^ rev(seq_along(letters) - 1L)))
}

expected_changed_coordinates <- vapply(
  which(vapply(seq_len(nrow(updates)), function(i) {
    old <- before[[column_number(updates$column[i])]][updates$row[i]]
    is.na(old) || old != updates$value[i]
  }, logical(1))),
  function(i) paste(updates$row[i], updates$column[i], sep = ":"),
  character(1)
)

replace_range <- function(text, start, length, replacement) {
  paste0(
    if (start > 1L) substr(text, 1L, start - 1L) else "",
    replacement,
    substr(text, start + length, nchar(text))
  )
}

replace_cell <- function(xml, row_number, column, value) {
  row_pattern <- sprintf(
    "(?s)<row\\b[^>]*\\br=\"%d\"[^>]*>.*?</row>",
    row_number
  )
  row_match <- regexpr(row_pattern, xml, perl = TRUE)
  if (row_match[1] < 0L) stop("Could not find worksheet row ", row_number, ".")
  row_xml <- regmatches(xml, row_match)
  reference <- paste0(column, row_number)
  cell_pattern <- sprintf(
    "(?s)<c\\b[^>]*\\br=\"%s\"[^>]*(?:/>|>.*?</c>)",
    reference
  )
  cell_match <- regexpr(cell_pattern, row_xml, perl = TRUE)

  style <- ""
  if (cell_match[1] >= 0L) {
    old_cell <- regmatches(row_xml, cell_match)
    style_match <- regexec("\\bs=\"([^\"]+)\"", old_cell, perl = TRUE)
    style_parts <- regmatches(old_cell, style_match)[[1]]
    if (length(style_parts) == 2L) style <- paste0(" s=\"", style_parts[2], "\"")
  }
  replacement <- paste0(
    "<c r=\"", reference, "\"", style, " t=\"inlineStr\"><is><t>",
    xml_escape(value), "</t></is></c>"
  )

  if (cell_match[1] >= 0L) {
    row_xml <- replace_range(
      row_xml,
      cell_match[1],
      attr(cell_match, "match.length"),
      replacement
    )
  } else {
    all_pattern <- "<c\\b[^>]*\\br=\"([A-Z]+)[0-9]+\""
    all_match <- gregexpr(all_pattern, row_xml, perl = TRUE)[[1]]
    inserted <- FALSE
    if (all_match[1] >= 0L) {
      all_tags <- regmatches(row_xml, list(all_match))[[1]]
      all_columns <- sub(all_pattern, "\\1", all_tags, perl = TRUE)
      later <- which(vapply(all_columns, column_number, integer(1)) > column_number(column))[1]
      if (!is.na(later)) {
        row_xml <- replace_range(row_xml, all_match[later], 0L, replacement)
        inserted <- TRUE
      }
    }
    if (!inserted) row_xml <- sub("</row>$", paste0(replacement, "</row>"), row_xml)
  }

  replace_range(xml, row_match[1], attr(row_match, "match.length"), row_xml)
}

unpacked <- tempfile("registry_exact_cells_")
dir.create(unpacked)
utils::unzip(workbook, exdir = unpacked)
sheet_path <- file.path(unpacked, "xl", "worksheets", "sheet1.xml")
connection <- file(sheet_path, open = "rb")
xml <- paste(readLines(connection, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
close(connection)

for (i in seq_len(nrow(updates))) {
  xml <- replace_cell(xml, updates$row[i], updates$column[i], updates$value[i])
}
writeLines(xml, sheet_path, useBytes = TRUE)

candidate <- tempfile("registry_exact_cells_", fileext = ".xlsx")
zip::zipr(
  candidate,
  files = c("[Content_Types].xml", "_rels", "docProps", "xl"),
  root = unpacked,
  mode = "mirror"
)
invisible(utils::unzip(candidate, list = TRUE))
after <- read_registry(candidate)

if (!identical(dim(before), dim(after))) stop("Workbook dimensions changed.")
actual_coordinates <- character()
for (column in seq_len(ncol(before))) {
  old <- before[[column]]
  new <- after[[column]]
  changed <- which((is.na(old) != is.na(new)) | (!is.na(old) & !is.na(new) & old != new))
  if (length(changed)) {
    column_letters <- character()
    number <- column
    while (number > 0L) {
      remainder <- (number - 1L) %% 26L
      column_letters <- c(intToUtf8(utf8ToInt("A") + remainder), column_letters)
      number <- (number - 1L) %/% 26L
    }
    actual_coordinates <- c(actual_coordinates, paste(changed, paste(column_letters, collapse = ""), sep = ":"))
  }
}
if (!setequal(actual_coordinates, expected_changed_coordinates)) {
  stop(
    "Unexpected changed cell set. Expected: ", paste(sort(expected_changed_coordinates), collapse = ", "),
    "; observed: ", paste(sort(actual_coordinates), collapse = ", ")
  )
}
for (i in seq_len(nrow(updates))) {
  column <- column_number(updates$column[i])
  if (!identical(after[[column]][updates$row[i]], updates$value[i])) {
    stop("Validation failed for cell ", updates$column[i], updates$row[i], ".")
  }
}

backup <- tempfile("registry_before_exact_cells_", fileext = ".xlsx")
if (!file.copy(workbook, backup)) stop("Could not make a temporary workbook backup.")
success <- FALSE
on.exit({
  if (!success) file.copy(backup, workbook, overwrite = TRUE)
}, add = TRUE)
if (!file.copy(candidate, workbook, overwrite = TRUE)) stop("Could not replace registry workbook.")
success <- TRUE

message("Verified 17 exact registry targets; every other readable Sheet1 cell is unchanged.")
