# Kappeler_Pereira_2003_Appendix.R -- extract the Kappeler & Pereira (2003)
# primate life-history appendix workbook without interpreting multi-value cells.
#
# Input : LH_appendix.xls (the workbook as received from Peter Kappeler;
#         preserved unchanged alongside this script)
# Output: LH_appendix_cells.csv -- one row per nonempty trait cell, with the
#         printed value and the per-cell source key carried by the workbook's
#         font colours (see the workbook's trailing notes):
#           automatic/black -> Smith_Jungers_1997
#           blue            -> Ross_chapter_11
#           magenta         -> Godfrey_etal_2001
#           green           -> Lee_Kappeler_chapter_3
#           red             -> Smith_Leigh_1998
#
# This is the R replacement for the original extract_cells.py (retired
# 2026-11-25; repo build scripts are R). Output is identical to the Python
# extraction: 1,181 cells, no unresolved font colours.
#
# How it reads an .xls: no R package reads BIFF (.xls) font colours, so the
# workbook is first converted to .xlsx with LibreOffice headless (the .xls
# itself is never modified), and the converted file's XML is read with xml2.
# If a LH_appendix.xlsx already sits next to this script it is used as-is and
# LibreOffice is not needed. Requires: R package xml2; LibreOffice (soffice)
# only when no .xlsx copy is present.

suppressWarnings(suppressMessages(library(xml2)))

self <- tryCatch(normalizePath(sub("^--file=", "",
         grep("^--file=", commandArgs(FALSE), value = TRUE)[1])),
         error = function(e) NA)
here <- if (!is.na(self)) dirname(self) else getwd()

workbook_xls  <- file.path(here, "LH_appendix.xls")
workbook_xlsx <- file.path(here, "LH_appendix.xlsx")
output_csv    <- file.path(here, "LH_appendix_cells.csv")
stopifnot(file.exists(workbook_xls))

work <- tempfile("kp2003_"); dir.create(work)
if (!file.exists(workbook_xlsx)) {
  soffice <- Sys.which("soffice")
  if (!nzchar(soffice)) soffice <- Sys.which("libreoffice")
  if (!nzchar(soffice))
    stop("No LH_appendix.xlsx next to this script and no LibreOffice ",
         "(soffice) on PATH to convert LH_appendix.xls.")
  # R sessions often clobber LD_LIBRARY_PATH, which breaks the soffice
  # launcher; hand it its own program directory explicitly.
  lo_dir <- dirname(normalizePath(soffice))
  lo_env <- paste0("LD_LIBRARY_PATH=", lo_dir, ":",
                   Sys.getenv("LD_LIBRARY_PATH"))
  status <- system2(soffice, c("--headless", "--convert-to", "xlsx",
                               "--outdir", work, workbook_xls),
                    env = lo_env, stdout = FALSE, stderr = FALSE)
  workbook_xlsx <- file.path(work, "LH_appendix.xlsx")
  if (!file.exists(workbook_xlsx))
    stop("LibreOffice conversion of LH_appendix.xls failed (status ", status, ").")
}
unzipped <- file.path(work, "xlsx")
utils::unzip(workbook_xlsx, exdir = unzipped)

NS <- c(x = "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
        r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships")

# ---- locate the Tabelle1 sheet through workbook.xml + its rels -------------
wb_xml   <- read_xml(file.path(unzipped, "xl", "workbook.xml"))
rels_xml <- read_xml(file.path(unzipped, "xl", "_rels", "workbook.xml.rels"))
rel_target <- function(rid) {
  node <- xml_find_first(rels_xml, sprintf("//*[local-name()='Relationship'][@Id='%s']", rid))
  xml_attr(node, "Target")
}
sheet_file <- NULL
for (sh in xml_find_all(wb_xml, "//x:sheets/x:sheet", NS)) {
  if (xml_attr(sh, "name") == "Tabelle1") {
    rid <- xml_text(xml_find_first(sh, "@*[local-name()='id']"))
    target <- rel_target(rid)
    sheet_file <- file.path(unzipped, "xl",
                            sub("^/?xl/", "", sub("^/?", "", target)))
    if (!file.exists(sheet_file))
      sheet_file <- file.path(unzipped, "xl", basename(target))
  }
}
stopifnot(!is.null(sheet_file), file.exists(sheet_file))

# ---- shared strings ---------------------------------------------------------
ss_path <- file.path(unzipped, "xl", "sharedStrings.xml")
shared <- character()
if (file.exists(ss_path)) {
  ss <- read_xml(ss_path)
  shared <- vapply(xml_find_all(ss, "//x:si", NS),
                   function(si) paste(xml_text(xml_find_all(si, ".//x:t", NS)),
                                      collapse = ""),
                   "")
}

# ---- styles: cellXfs -> fontId -> font colour ARGB --------------------------
styles <- read_xml(file.path(unzipped, "xl", "styles.xml"))
font_argb <- vapply(xml_find_all(styles, "//x:fonts/x:font", NS), function(f) {
  col <- xml_find_first(f, "./x:color", NS)
  if (inherits(col, "xml_missing")) NA_character_ else xml_attr(col, "rgb")
}, "")
xf_font <- vapply(xml_find_all(styles, "//x:cellXfs/x:xf", NS),
                  function(xf) as.integer(xml_attr(xf, "fontId")), integer(1))
xf_numfmt <- vapply(xml_find_all(styles, "//x:cellXfs/x:xf", NS),
                    function(xf) as.integer(xml_attr(xf, "numFmtId")), integer(1))
# Which number formats are dates? (the Python extraction printed a
# date-formatted cell's raw serial via str(float); see the note in the
# value-formatting code below). Built-in date ids plus custom codes whose
# format string carries date letters outside [brackets] and "quotes".
numfmt_code <- vapply(xml_find_all(styles, "//x:numFmts/x:numFmt", NS),
                      function(nf) xml_attr(nf, "formatCode"), "")
names(numfmt_code) <- vapply(xml_find_all(styles, "//x:numFmts/x:numFmt", NS),
                             function(nf) xml_attr(nf, "numFmtId"), "")
is_date_numfmt <- function(id) {
  if (is.na(id)) return(FALSE)
  if (id %in% c(14:22, 27:36, 45:47, 50L, 57L)) return(TRUE)
  code <- numfmt_code[as.character(id)]
  if (is.na(code)) return(FALSE)
  code <- gsub("\\[[^]]*\\]", "", code)
  code <- gsub('"[^"]*"', "", code)
  grepl("[dymhs]", code)
}

# Standard Excel palette indices for the colours this workbook uses, so the
# font_colour_index column matches the original xlrd-based extraction.
PALETTE_INDEX <- c(FF0000FF = 12L, FF3366FF = 48L, FFFF00FF = 14L,
                   FF00FF00 = 11L, FFFF0000 = 10L)
SOURCE_BY_ARGB <- c(FF0000FF = "Ross_chapter_11",
                    FF3366FF = "Ross_chapter_11",
                    FFFF00FF = "Godfrey_etal_2001",
                    FF00FF00 = "Lee_Kappeler_chapter_3",
                    FFFF0000 = "Smith_Leigh_1998")

argb_to_rgb <- function(argb) {
  if (is.na(argb) || argb == "FF000000") return("")
  paste(strtoi(substr(argb, 3, 4), 16L), strtoi(substr(argb, 5, 6), 16L),
        strtoi(substr(argb, 7, 8), 16L), sep = ",")
}

# ---- read the sheet's cells --------------------------------------------------
sheet <- read_xml(sheet_file)
cell_nodes <- xml_find_all(sheet, "//x:sheetData/x:row/x:c", NS)
cells <- data.frame(
  row = integer(), col = integer(), text = character(),
  argb = character(), stringsAsFactors = FALSE)
col_of_ref <- function(ref) {
  letters <- gsub("[0-9]", "", ref)
  n <- 0L; for (ch in strsplit(letters, "")[[1]]) n <- n * 26L + match(ch, LETTERS)
  n
}
for (cn in cell_nodes) {
  ref <- xml_attr(cn, "r")
  r <- as.integer(gsub("[A-Z]", "", ref)); cl <- col_of_ref(ref)
  s_idx <- xml_attr(cn, "s"); t <- xml_attr(cn, "t")
  cell_argb <- NA_character_
  if (!is.na(s_idx)) {
    fid <- xf_font[as.integer(s_idx) + 1L]
    if (!is.na(fid)) cell_argb <- font_argb[fid + 1L]
  }
  v <- xml_find_first(cn, "./x:v", NS)
  txt <- ""
  if (!inherits(v, "xml_missing")) {
    raw <- xml_text(v)
    if (!is.na(t) && t == "s") {
      txt <- shared[as.integer(raw) + 1L]
      txt <- trimws(txt)
    } else if (!is.na(t) && t %in% c("str", "inlineStr")) {
      txt <- trimws(raw)
    } else if (!is.na(s_idx) && is_date_numfmt(xf_numfmt[as.integer(s_idx) + 1L])) {
      # Date-formatted numeric cell: xlrd reports these as DATE, not NUMBER,
      # so the Python extraction fell through to str(float) on the raw Excel
      # serial. Reproduce that exactly (one cell in this workbook: K90,
      # Tarsius syrichta birth weight, serial 36944.0 -- preserved as-is,
      # it is not a plausible birth weight).
      txt <- sprintf("%.15g", as.numeric(raw))
      if (!grepl("[.eE]", txt)) txt <- paste0(txt, ".0")
    } else {
      txt <- sprintf("%.15g", as.numeric(raw))
    }
  } else {
    is_node <- xml_find_first(cn, "./x:is", NS)
    if (!inherits(is_node, "xml_missing"))
      txt <- trimws(paste(xml_text(xml_find_all(is_node, ".//x:t", NS)),
                          collapse = ""))
  }
  cells[nrow(cells) + 1L, ] <- list(r, cl, txt,
                                    ifelse(is.na(cell_argb), "", cell_argb))
}
stopifnot(max(cells$row) == 318L, max(cells$col) == 16L)

cell_at <- function(r, cl) {
  hit <- cells[cells$row == r & cells$col == cl, ]
  if (!nrow(hit)) list(text = "", argb = "") else hit[1, ]
}
headers <- vapply(1:16, function(cl) sub("\\*+$", "", cell_at(2L, cl)$text), "")

rows <- list()
for (r in 3:311) {                       # Excel rows 3-311; notes begin at 312
  fam <- cell_at(r, 1L)$text; gen <- cell_at(r, 2L)$text; spe <- cell_at(r, 3L)$text
  stopifnot(nzchar(fam), nzchar(gen), nzchar(spe))
  for (cl in 4:16) {
    ca <- cell_at(r, cl)
    if (!nzchar(ca$text)) next
    argb <- ca$argb
    if (!nzchar(argb) || argb == "FF000000") {
      rgb <- ""; idx <- 32767L; source <- "Smith_Jungers_1997"
    } else if (argb %in% names(SOURCE_BY_ARGB)) {
      rgb <- argb_to_rgb(argb); idx <- PALETTE_INDEX[[argb]]
      source <- SOURCE_BY_ARGB[[argb]]
    } else {
      rgb <- argb_to_rgb(argb); idx <- NA_integer_; source <- "unresolved_colour"
    }
    rows[[length(rows) + 1L]] <- data.frame(
      workbook_row = r, workbook_column = cl,
      family_printed = fam, genus_printed = gen, species_printed = spe,
      trait_printed = headers[cl], value_printed = ca$text,
      font_colour_index = idx, font_rgb = rgb, source_key = source,
      stringsAsFactors = FALSE)
  }
}
out <- do.call(rbind, rows)
utils::write.csv(out, output_csv, row.names = FALSE, quote = TRUE,
                 fileEncoding = "UTF-8")
cat(sprintf("%d nonempty trait cells from 309 species rows -> %s\n",
            nrow(out), output_csv))
cat(sprintf("Unresolved source colors: %d\n",
            sum(out$source_key == "unresolved_colour")))
