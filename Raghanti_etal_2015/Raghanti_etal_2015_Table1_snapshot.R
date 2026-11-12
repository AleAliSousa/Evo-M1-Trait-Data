## Raghanti MA, Spurlock LB, Treichler FR, Weigel SE, Stimmelmayr R, Butti C,
## Thewissen JGM, Hof PR (2015). An analysis of von Economo neurons in the
## cerebral cortex of cetaceans, artiodactyls, and perissodactyls.
## Brain Struct Funct 220(4):2303-2314. Table 1.
##
## Raghanti_etal_2015_Table1_snapshot.R: writes ONLY Raghanti_etal_2015_Table1_snapshot.xlsx.
## The analysis script Raghanti_etal_2015_Table1.R reads that frozen file and never writes it.
##
## Section 1 SNAPSHOT. Reads the publisher's HTML table page (snapshot HOWTO
##   method 2) and compares it with the frozen copy on disk.
##     absent   -> write it
##     matches  -> say so, with the dimensions checked
##     differs  -> write *_REBUILD.xlsx and stop, so the frozen copy is never
##                 silently replaced
##     no page  -> warn and carry on; the build does not depend on the network
##   No table values are typed into this section. The printed literals used are
##   the four region names and the two measure names, as anchors for the scrape.
##
## .xlsx, not .csv: the header is two tiers deep - each of the four cortical
## regions spans a "% VEN" and a "% Fork cells" column, and "Species" spans both
## header rows. CSV flattens that. The merges are reproduced.

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
folder        <- dirname(.sp)
item_name     <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
base          <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

say <- function(...) message("[", item_name, "] ", ...)


## =====================================================================
## SECTION 1 - SNAPSHOT: source page -> frozen copy, or verify against it
## =====================================================================

src_url    <- "https://link.springer.com/article/10.1007/s00429-014-0792-y/tables/1"
local_html <- "Raghanti_etal_2015_Table1.html"   # optional offline copy of the table page
regions    <- c("Frontal pole", "ACC", "Anterior insula", "Occipital pole")
measures   <- c("% VEN", "% Fork cells")

have_pkgs <- all(vapply(c("rvest", "xml2", "openxlsx", "readxl"),
                        requireNamespace, logical(1), quietly = TRUE))

scraped <- NULL
if (!have_pkgs) {
  say("snapshot: rvest/xml2/openxlsx/readxl not all installed - ",
      "verification skipped, building from the frozen copy.")
} else {
  scraped <- tryCatch({
    doc <- if (file.exists(local_html)) {
      say("snapshot: reading local copy ", local_html)
      xml2::read_html(local_html, encoding = "UTF-8")
    } else {
      say("snapshot: fetching ", src_url)
      xml2::read_html(src_url)
    }

    tbl <- rvest::html_element(doc, "table")
    if (inherits(tbl, "xml_missing")) stop("no table element on the page")
    rows <- rvest::html_elements(tbl, "tr")
    if (length(rows) < 3L) stop("page has fewer than three table rows")

    cell_text <- function(c) {
      s <- gsub(" ", " ", rvest::html_text2(c))
      trimws(gsub("[[:space:]]+", " ", s))
    }

    ## header: two tiers, read from the spans rather than assumed
    h1     <- rvest::html_elements(rows[[1]], "td, th")
    h2     <- rvest::html_elements(rows[[2]], "td, th")
    h1_txt <- vapply(h1, cell_text, character(1))
    h1_cs  <- as.integer(ifelse(is.na(rvest::html_attr(h1, "colspan")), 1, rvest::html_attr(h1, "colspan")))
    h1_rs  <- as.integer(ifelse(is.na(rvest::html_attr(h1, "rowspan")), 1, rvest::html_attr(h1, "rowspan")))

    stopifnot(h1_txt[1] == "Species", h1_rs[1] == 2L)   # Species spans both header rows
    stopifnot(identical(h1_txt[-1], regions))            # four regions, in printed order
    stopifnot(all(h1_cs[-1] == 2L))                      # each spanning two columns
    stopifnot(identical(vapply(h2, cell_text, character(1)),
                        rep(measures, times = 4)))       # % VEN, % Fork cells, x4

    bod <- lapply(rows[-(1:2)], function(r)
      vapply(rvest::html_elements(r, "td, th"), cell_text, character(1)))
    stopifnot(all(lengths(bod) == 9L))
    bod <- do.call(rbind, bod)
    stopifnot(nrow(bod) == 8L)                           # eight species, one individual each
    bod
  }, error = function(e) {
    say("snapshot: source not read (", conditionMessage(e), ").")
    say("snapshot: verification skipped - building from the frozen copy on disk.")
    NULL
  })
}

## build the workbook the page implies, so it can be written or compared
if (!is.null(scraped)) {
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Table1")
  openxlsx::writeData(wb, "Table1", "Species", startRow = 1, startCol = 1, colNames = FALSE)
  for (i in seq_along(regions)) {
    cl <- 2 + 2 * (i - 1)
    openxlsx::writeData(wb, "Table1", regions[i], startRow = 1, startCol = cl, colNames = FALSE)
    openxlsx::writeData(wb, "Table1", t(measures), startRow = 2, startCol = cl, colNames = FALSE)
    openxlsx::mergeCells(wb, "Table1", cols = cl:(cl + 1), rows = 1)
  }
  openxlsx::mergeCells(wb, "Table1", cols = 1, rows = 1:2)
  openxlsx::writeData(wb, "Table1", as.data.frame(scraped), startRow = 3, colNames = FALSE)
  openxlsx::addStyle(wb, "Table1", openxlsx::createStyle(textDecoration = "bold"),
                     rows = 1:2, cols = 1:9, gridExpand = TRUE)
  openxlsx::setColWidths(wb, "Table1", cols = 1:9, widths = c(16, rep(13, 8)))

  if (!file.exists(snapshot_xlsx)) {
    openxlsx::saveWorkbook(wb, snapshot_xlsx, overwrite = FALSE)
    say("snapshot: WRITTEN from source - ", nrow(scraped), " rows x ",
        ncol(scraped), " columns, first build.")
  } else {
    frozen <- as.matrix(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                           col_types = "text", col_names = FALSE,
                                           skip = 2, .name_repair = "minimal"))
    frozen[is.na(frozen)] <- ""
    if (identical(unname(frozen), unname(scraped))) {
      say("snapshot: VERIFIED against source on ", format(Sys.Date()), " - all ",
          nrow(scraped) * ncol(scraped), " body cells (", nrow(scraped), " x ",
          ncol(scraped), ") identical, headers and merges as printed.")
    } else {
      rebuild <- sub("\\.xlsx$", "_REBUILD.xlsx", snapshot_xlsx)
      openxlsx::saveWorkbook(wb, rebuild, overwrite = TRUE)
      d <- which(unname(frozen) != unname(scraped), arr.ind = TRUE)
      stop("Frozen snapshot differs from the source page in ", nrow(d),
           " cell(s); first at row ", d[1, "row"], ", column ", d[1, "col"],
           ". Wrote ", basename(rebuild),
           " - compare the two before replacing anything. The frozen copy has ",
           "NOT been touched.", call. = FALSE)
    }
  }
}
