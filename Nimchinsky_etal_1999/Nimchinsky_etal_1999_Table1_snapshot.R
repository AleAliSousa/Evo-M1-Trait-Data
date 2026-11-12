## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. Table 1. PMC21853.
##
## Snapshot script for Table 1 (one script per item: this one writes only
## Nimchinsky_etal_1999_Table1_snapshot.xlsx; Nimchinsky_etal_1999_Table1.R reads it).
## Reads the open-access PMC HTML (snapshot HOWTO method 2) and compares Table 1
## with the frozen copy on disk.
##     absent   -> write it
##     matches  -> say so, with the dimensions checked
##     differs  -> write *_REBUILD.xlsx and stop, so the frozen copy is never
##                 silently replaced
##     no page  -> warn and carry on; the build does not depend on the network
##   No table values are typed into this section. The only printed literals are
##   the three clade names the caption itself names, used as anchors.
##
##   .xlsx, not .csv, because the caption defines a value by typography:
##   "Spindle cells ... are observed with certainty only among hominoids, in all
##   extant pongid and hominid species (shown in bold)". CSV cannot hold that, so
##   per __HOWTO_make_a_snapshot.md ("Choosing the format") Excel is the faithful
##   medium. The caption's claim is asserted before anything is written.
##   The caption's bold/species claim is checked before anything is written.

options(scipen = 999)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder       <- dirname(.sp)
item_name    <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Nimchinsky_etal_1999_Table1
source_name  <- sub("_Table[^_]*$", "", item_name)          # Nimchinsky_etal_1999
snapshot_xlsx<- paste0(item_name, "_snapshot.xlsx")
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

say <- function(...) message("[", item_name, "] ", ...)


## =====================================================================
## SECTION 1 - SNAPSHOT: source page -> frozen copy, or verify against it
## =====================================================================

src_url    <- "https://pmc.ncbi.nlm.nih.gov/articles/PMC21853/"
local_html <- "Nimchinsky_etal_1999_PMC21853.html"   # optional offline copy of the page

have_pkgs <- all(vapply(c("rvest", "xml2", "openxlsx", "readxl"),
                        requireNamespace, logical(1), quietly = TRUE))

parsed <- NULL
if (!have_pkgs) {
  say("snapshot: rvest/xml2/openxlsx/readxl not all installed - ",
      "verification skipped, building from the frozen copy.")
} else {
  parsed <- tryCatch({
    doc <- if (file.exists(local_html)) {
      say("snapshot: reading local copy ", local_html)
      xml2::read_html(local_html, encoding = "UTF-8")
    } else {
      say("snapshot: fetching ", src_url)
      xml2::read_html(src_url)
    }

    ## read a table element into text + bold flags, nothing else
    tbl <- rvest::html_element(doc, "section#T1 table")
    if (inherits(tbl, "xml_missing")) stop("Table 1 not found on the page")
    rows <- rvest::html_elements(tbl, "tr")
    out <- lapply(rows, function(r) {
      cells <- rvest::html_elements(r, "td, th")
      txt <- vapply(cells, function(c) {
        s <- gsub(" ", " ", rvest::html_text2(c))
        trimws(gsub("[[:space:]]+", " ", s))
      }, character(1))
      bold <- vapply(cells, function(c)
        length(rvest::html_elements(c, "b, strong")) > 0, logical(1))
      list(txt = txt, bold = bold)
    })
    nc  <- max(vapply(out, function(x) length(x$txt), integer(1)))
    pad <- function(v, fill) c(v, rep(fill, nc - length(v)))
    t1  <- list(txt  = do.call(rbind, lapply(out, function(x) pad(x$txt,  ""))),
                bold = do.call(rbind, lapply(out, function(x) pad(x$bold, FALSE))))

    stopifnot(identical(as.character(t1$txt[1, ]), c("Taxonomy", "Spindle cells", "N")))
    stopifnot(nrow(t1$txt) == 49L)                     # header + 48 printed rows

    body_txt   <- t1$txt[-1, , drop = FALSE]
    body_bold  <- t1$bold[-1, , drop = FALSE]
    is_sp      <- nzchar(body_txt[, 2])
    stopifnot(sum(is_sp) == 28L)                       # "28 primate species" (Specimens)

    ## the caption's claim, checked rather than assumed:
    ## bold marks exactly the taxa with spindle cells present.
    clades_in_bold <- c("Hominoidea", "Pongidae", "Hominidae")   # named in the caption
    row_bold <- body_bold[, 1]
    stopifnot(all(row_bold[is_sp] == (body_txt[is_sp, 2] != "None")))
    stopifnot(setequal(body_txt[!is_sp & row_bold, 1], clades_in_bold))

    list(head = as.character(t1$txt[1, ]), body = body_txt, bold = row_bold)
  }, error = function(e) {
    say("snapshot: source not read (", conditionMessage(e), ").")
    say("snapshot: verification skipped - building from the frozen copy on disk.")
    NULL
  })
}

if (!is.null(parsed)) {
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Table1")
  openxlsx::writeData(wb, "Table1", as.data.frame(t(parsed$head)),
                      startRow = 1, colNames = FALSE)
  openxlsx::writeData(wb, "Table1", as.data.frame(parsed$body),
                      startRow = 2, colNames = FALSE)
  openxlsx::addStyle(wb, "Table1", openxlsx::createStyle(textDecoration = "bold"),
                     rows = 1, cols = 1:3, gridExpand = TRUE)
  for (i in which(parsed$bold)) {
    openxlsx::addStyle(wb, "Table1", openxlsx::createStyle(textDecoration = "bold"),
                       rows = i + 1L, cols = 1:3, gridExpand = TRUE)
  }
  openxlsx::setColWidths(wb, "Table1", cols = 1:3, widths = c(30, 18, 8))

  if (!file.exists(snapshot_xlsx)) {
    openxlsx::saveWorkbook(wb, snapshot_xlsx, overwrite = FALSE)
    say("snapshot: WRITTEN from source - ", nrow(parsed$body), " printed rows x ",
        ncol(parsed$body), " columns, ", sum(parsed$bold), " bold, first build.")
  } else {
    frozen <- as.matrix(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                           col_types = "text", col_names = TRUE,
                                           .name_repair = "minimal"))
    frozen[is.na(frozen)] <- ""
    if (identical(unname(frozen), unname(parsed$body))) {
      say("snapshot: VERIFIED against source on ", format(Sys.Date()), " - all ",
          nrow(parsed$body) * ncol(parsed$body), " cells (", nrow(parsed$body),
          " x ", ncol(parsed$body), ") identical; caption's bold claim holds on ",
          sum(parsed$bold), " rows.")
    } else {
      rebuild <- sub("\\.xlsx$", "_REBUILD.xlsx", snapshot_xlsx)
      openxlsx::saveWorkbook(wb, rebuild, overwrite = TRUE)
      d <- which(unname(frozen) != unname(parsed$body), arr.ind = TRUE)
      stop("Frozen Table 1 differs from the source page in ", nrow(d),
           " cell(s); first at printed row ", d[1, "row"], ", column ", d[1, "col"],
           ". Wrote ", basename(rebuild),
           " - compare the two before replacing anything. The frozen copy has ",
           "NOT been touched.", call. = FALSE)
    }
  }
}
