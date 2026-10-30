## Raghanti MA, Spurlock LB, Treichler FR, Weigel SE, Stimmelmayr R, Butti C,
## Thewissen JGM, Hof PR (2015). An analysis of von Economo neurons in the
## cerebral cortex of cetaceans, artiodactyls, and perissodactyls.
## Brain Struct Funct 220(4):2303-2314. Table 1.
##
## One script for the whole item: source -> frozen snapshot -> analysis CSV ->
## public TSV. Replaces the earlier pair of scripts, where the extract step lived
## in Raghanti_etal_2015_extract_snapshot.R.
##
## Why that split was a problem. The extract script wrote the snapshot only when
## the file was absent; once the frozen copy was committed, every later run took
## the "already matches" branch, printed one line and produced nothing. Verifying
## the frozen copy against the source is the useful thing it does, and it was
## invisible. Here the two steps are separate sections of one file, every outcome
## is reported in words, and the CSV is written on every run whatever happens
## upstream.
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
## Section 2 BUILD. Always reads the frozen .xlsx from disk - never the object
##   parsed in section 1 - so what is published is always what is committed.
##
## Input : Raghanti_etal_2015_Table1_snapshot.xlsx (sheet "Table1"): two header
##         rows, then 8 species x (4 regions x 2 cell types)
## Output: <script stem>.csv   one row per species (8)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## .xlsx, not .csv: the header is two tiers deep - each of the four cortical
## regions spans a "% VEN" and a "% Fork cells" column, and "Species" spans both
## header rows. CSV flattens that. The merges are reproduced.
##
## Values are percentages as published. Normally a ratio would not be
## transcribed - it would be recomputed downstream from its numerator and
## denominator - but here the VEN, fork cell and total neuron population
## estimates are published only as scatterplots (Figs 6-8), so the percentage in
## Table 1 is the only tabulated form of this result. Flagged in the definitions
## and in the ReadMe rather than silently treated as a measured quantity.
##
## Two qualifiers come from Materials and methods, not from the table, because
## the table has no column for either. Both are quoted in the definitions:
##   "Only one individual per species was analyzed in this study."
##   "These brains were all from adults, with the exception of the cow."

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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))
source_name   <- sub("_Table[^_]*$", "", item_name)
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv    <- paste0(item_name, ".csv")
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


## =====================================================================
## SECTION 2 - BUILD: frozen copy on disk -> analysis CSV -> public TSV
## =====================================================================

if (!file.exists(snapshot_xlsx)) {
  stop("No frozen snapshot at ", snapshot_xlsx, " and the source could not be ",
       "read, so there is nothing to build from.", call. = FALSE)
}

## read the frozen snapshot, both header tiers, everything as text
raw <- as.data.frame(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                        col_names = FALSE, col_types = "text"),
                     check.names = FALSE)
raw[is.na(raw)] <- ""
stopifnot(ncol(raw) == 9L, nrow(raw) == 10L)     # 2 header rows + 8 species

tier1 <- trimws(as.character(raw[1, ]))
tier2 <- trimws(as.character(raw[2, ]))
body  <- raw[-(1:2), , drop = FALSE]

## the merged region cell only carries text in its first column; carry it across
for (i in seq_along(tier1)) if (!nzchar(tier1[i]) && i > 1) tier1[i] <- tier1[i - 1]

## ---- column names from the printed headers, not from a hardcoded list ----
snake <- function(x) gsub("_+", "_", gsub("[^a-z0-9]+", "_", tolower(trimws(x))))
meas  <- c("% VEN" = "ven_pct", "% Fork cells" = "fork_pct")
stopifnot(all(tier2[-1] %in% names(meas)))
codes <- paste0(snake(tier1[-1]), "_", meas[tier2[-1]])
stopifnot(!anyDuplicated(codes), length(codes) == 8L)

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
vals <- as.data.frame(lapply(body[-1], num))
names(vals) <- codes
stopifnot(!any(is.na(vals)))                     # printed zeros are absences, not blanks
stopifnot(all(vals >= 0 & vals <= 100))

species_printed <- trimws(body[[1]])
stopifnot(length(species_printed) == 8L)

## ---- species harmonisation via the collection key (never an inline map) ----
## The table prints common names; the binomials are in Materials and methods and
## live in the key as variant_name rows, so no common-to-binomial map appears here.
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
species_accepted <- rep(NA_character_, length(species_printed))
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx. ",
       "Run it from a loose folder and the species column comes out empty - ",
       "which is how the first version of this file was committed with no ",
       "species names in it.", call. = FALSE)
}
{
  key <- read.csv(key_path, stringsAsFactors = FALSE)
  key <- key[key$source_publication == source_name, ]
  lk  <- setNames(key$accepted_name, tolower(key$variant_name))
  species_accepted <- unname(lk[tolower(species_printed)])
  missing <- species_printed[is.na(species_accepted)]
  if (length(missing)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(missing, collapse = "; "),
         ". Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

## ---- qualifiers from Materials and methods (see header note) ----
non_adult <- "Cow"
stopifnot(non_adult %in% species_printed)        # break loudly if the label changes

clean <- data.frame(
  species              = species_accepted,
  species_as_published = species_printed,
  vals,
  cortical_layer       = "V",
  n_individuals        = 1L,
  adult                = !(species_printed %in% non_adult),
  source               = source_name,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(sum(!clean$adult) == 1L)
stopifnot(all(vals[species_printed == "Rock hyrax", ] == 0))   # the paper's key negative

stopifnot(!anyNA(clean$species))   # never write a file with an empty species column

write.csv(clean, output_csv, row.names = FALSE)
say("built: ", output_csv, " - ", nrow(clean), " rows x ", ncol(clean), " columns.")

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  say("built: ", item_encoded, ".tsv in __Public/comparative-data/")
}
