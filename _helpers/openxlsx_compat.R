# Compatibility helpers for project workbooks read with openxlsx.
#
# Microsoft/OneDrive may rewrite otherwise valid workbook XML in two ways that
# openxlsx 4.2.8 cannot currently read:
#   1. prefix the main spreadsheet namespace (`x:workbook`); and
#   2. expand a legacy cell note into newer AlternateContent markup.
#
# This helper never edits the source workbook. It returns either the original
# path or a normalized temporary copy. The only note it may remove is the
# script-generated M1 note about AUTO_Public_TSV_FileList; the visible M1 header
# now carries that ownership information without fragile comment metadata.

openxlsx_compatible_copy <- function(path) {
  stopifnot(length(path) == 1L, file.exists(path))

  read_zip_text <- function(member) {
    connection <- unz(path, member, open = "rb")
    on.exit(close(connection), add = TRUE)
    paste(readLines(connection, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  }

  members <- utils::unzip(path, list = TRUE)$Name
  workbook_xml <- read_zip_text("xl/workbook.xml")
  normalize_namespace <- grepl("<x:workbook", workbook_xml, fixed = TRUE)

  comments_member <- "xl/comments1.xml"
  remove_generated_note <- FALSE
  if (comments_member %in% members) {
    comments_xml <- read_zip_text(comments_member)
    refs <- regmatches(comments_xml, gregexpr("<comment[[:space:]][^>]*ref=", comments_xml, perl = TRUE))[[1]]
    remove_generated_note <- length(refs) == 1L &&
      grepl('ref="M1"', comments_xml, fixed = TRUE) &&
      grepl("AUTO_Public_TSV_FileList", comments_xml, fixed = TRUE)
  }

  if (!normalize_namespace && !remove_generated_note) return(path)
  if (!requireNamespace("zip", quietly = TRUE)) {
    stop("Package 'zip' is required to normalize this workbook for openxlsx.")
  }

  temp_dir <- tempfile("openxlsx_compat_")
  dir.create(temp_dir)
  utils::unzip(path, exdir = temp_dir)

  replace_file_text <- function(relative_path, transform) {
    full_path <- file.path(temp_dir, relative_path)
    value <- paste(readLines(full_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    writeLines(transform(value), full_path, useBytes = TRUE)
  }

  if (normalize_namespace) {
    replace_file_text("xl/workbook.xml", function(value) {
      value <- sub(
        'xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
        'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
        value,
        fixed = TRUE
      )
      value <- gsub("<x:", "<", value, fixed = TRUE)
      gsub("</x:", "</", value, fixed = TRUE)
    })
  }

  if (remove_generated_note) {
    comments_path <- file.path(temp_dir, comments_member)
    vml_member <- "xl/drawings/vmlDrawing1.vml"
    vml_path <- file.path(temp_dir, vml_member)
    unlink(c(comments_path, vml_path))
    other_vml_exists <- any(grepl(
      "\\.vml$",
      list.files(file.path(temp_dir, "xl"), recursive = TRUE, full.names = TRUE),
      ignore.case = TRUE
    ))

    replace_file_text("xl/worksheets/_rels/sheet1.xml.rels", function(value) {
      value <- gsub(
        '<Relationship[^>]+Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments"[^>]*/>',
        "", value, perl = TRUE
      )
      gsub(
        '<Relationship[^>]+Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing"[^>]*/>',
        "", value, perl = TRUE
      )
    })
    replace_file_text("xl/worksheets/sheet1.xml", function(value) {
      gsub('<legacyDrawing[^>]*/>', "", value, perl = TRUE)
    })
    replace_file_text("[Content_Types].xml", function(value) {
      value <- gsub(
        '<Override[^>]+PartName="/xl/comments1.xml"[^>]*/>',
        "", value, perl = TRUE
      )
      if (!other_vml_exists) {
        value <- gsub(
          '<Default[^>]+Extension="vml"[^>]*/>',
          "", value, perl = TRUE
        )
      }
      value
    })
  }

  output <- tempfile("openxlsx_compat_", fileext = ".xlsx")
  zip::zipr(
    output,
    files = c("[Content_Types].xml", "_rels", "docProps", "xl"),
    root = temp_dir,
    mode = "mirror"
  )
  attr(output, "openxlsx_compat_dir") <- temp_dir
  output
}
