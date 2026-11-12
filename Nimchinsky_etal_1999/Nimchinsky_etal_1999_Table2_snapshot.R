## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. Table 2.
##
## Snapshot script for Table 2 (one script per item: this one writes only
## Nimchinsky_etal_1999_Table2_snapshot.csv; Nimchinsky_etal_1999_Table2.R reads it).
## Reads the open-access PMC HTML (snapshot HOWTO method 2) and compares Table 2
## with the frozen copy on disk: writes it if absent, reports a verification if
## identical, writes *_REBUILD.csv and stops if it differs, warns and carries on
## if the page cannot be read. Table 2 is flat text, so .csv is the faithful
## medium (Table 1 needs .xlsx for its bold).

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
item_name    <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Nimchinsky_etal_1999_Table2
source_name  <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
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

have_pkgs <- all(vapply(c("rvest", "xml2"), requireNamespace, logical(1), quietly = TRUE))

scraped <- NULL
if (!have_pkgs) {
  say("snapshot: rvest/xml2 not installed - verification skipped, ",
      "building from the frozen copy.")
} else {
  scraped <- tryCatch({
    doc <- if (file.exists(local_html)) {
      say("snapshot: reading local copy ", local_html)
      xml2::read_html(local_html, encoding = "UTF-8")
    } else {
      say("snapshot: fetching ", src_url)
      xml2::read_html(src_url)
    }

    tbl <- rvest::html_element(doc, "section#T2 table")
    if (inherits(tbl, "xml_missing")) stop("Table 2 not found on the page")
    rows <- rvest::html_elements(tbl, "tr")
    out <- lapply(rows, function(r) {
      vapply(rvest::html_elements(r, "td, th"), function(c) {
        s <- gsub(" ", " ", rvest::html_text2(c))
        trimws(gsub("[[:space:]]+", " ", s))
      }, character(1))
    })
    nc  <- max(vapply(out, length, integer(1)))
    m   <- do.call(rbind, lapply(out, function(v) c(v, rep("", nc - length(v)))))

    stopifnot(identical(as.character(m[1, ]),
                        c("Species", "Pyramidal cells", "Spindle cells", "Fusiform cells")))
    stopifnot(nrow(m) == 6L)                     # header + 5 hominoid species
    m
  }, error = function(e) {
    say("snapshot: source not read (", conditionMessage(e), ").")
    say("snapshot: verification skipped - building from the frozen copy on disk.")
    NULL
  })
}

if (!is.null(scraped)) {
  if (!file.exists(snapshot_csv)) {
    write.table(scraped, snapshot_csv, sep = ",", row.names = FALSE,
                col.names = FALSE, qmethod = "double", fileEncoding = "UTF-8")
    say("snapshot: WRITTEN from source - ", nrow(scraped) - 1L, " species rows x ",
        ncol(scraped), " columns, first build.")
  } else {
    frozen <- as.matrix(read.csv(snapshot_csv, header = FALSE, colClasses = "character",
                                 check.names = FALSE, encoding = "UTF-8"))
    if (identical(unname(frozen), unname(scraped))) {
      say("snapshot: VERIFIED against source on ", format(Sys.Date()), " - all ",
          nrow(scraped) * ncol(scraped), " cells (", nrow(scraped), " x ",
          ncol(scraped), ") identical, markers and headers as printed.")
    } else {
      rebuild <- sub("\\.csv$", "_REBUILD.csv", snapshot_csv)
      write.table(scraped, rebuild, sep = ",", row.names = FALSE,
                  col.names = FALSE, qmethod = "double", fileEncoding = "UTF-8")
      d <- which(unname(frozen) != unname(scraped), arr.ind = TRUE)
      stop("Frozen Table 2 differs from the source page in ", nrow(d),
           " cell(s); first at row ", d[1, "row"], ", column ", d[1, "col"],
           ". Wrote ", basename(rebuild),
           " - compare the two before replacing anything. The frozen copy has ",
           "NOT been touched.", call. = FALSE)
    }
  }
}
