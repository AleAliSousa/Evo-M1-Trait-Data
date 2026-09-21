## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. Table 1. PMC21853.
##
## One script for the whole item: source -> frozen snapshot -> analysis CSV ->
## public TSV. Replaces the earlier arrangement, where extraction for both tables
## lived in Nimchinsky_etal_1999_extract_snapshot.R.
##
## Why that split was a problem. The extract script wrote a snapshot only when the
## file was absent; once the frozen copies were committed, every later run took
## the "already matches" branch, printed one line and produced nothing. Verifying
## the frozen copy against the source is the useful thing it does, and it was
## invisible. Each table now owns its own extraction, every outcome is reported in
## words, and the CSV is written on every run whatever happens upstream.
##
## Section 1 SNAPSHOT. Reads the open-access PMC HTML (snapshot HOWTO method 2)
##   and compares Table 1 with the frozen copy on disk.
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
##
## Section 2 BUILD. Always reads the frozen .xlsx from disk - never the object
##   parsed in section 1 - so what is published is always what is committed.
##
## Input : Nimchinsky_etal_1999_Table1_snapshot.xlsx  (sheet "Table1": Taxonomy,
##         Spindle cells, N; 48 rows as printed, including the 20 clade rows)
## Output: <script stem>.csv   one row per species (28)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## The printed table nests species under clade rows. Those rows are unnested here
## into suborder / superfamily / family columns; the caption gives the ranks
## ("within their families, superfamilies, and suborders"). Rank is read off the
## name: -idae = family, otherwise superfamily, except the two printed suborders,
## which are named as anchors because "Anthropoidea" also ends in -oidea.
##
## The caption marks the taxa with spindle cells in bold. For the species rows
## that is the same information as the printed "Spindle cells" value, so
## spindle_cells_present is derived from the value, not from the formatting;
## section 1 checks the two agree before freezing the snapshot.

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
item_name    <- tools::file_path_sans_ext(basename(.sp))   # matches __ReadMe.xlsx
source_name  <- sub("_Table[^_]*$", "", item_name)          # Nimchinsky_etal_1999
snapshot_xlsx<- paste0(item_name, "_snapshot.xlsx")
output_csv   <- paste0(item_name, ".csv")
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


## =====================================================================
## SECTION 2 - BUILD: frozen copy on disk -> analysis CSV -> public TSV
## =====================================================================

if (!file.exists(snapshot_xlsx)) {
  stop("No frozen snapshot at ", snapshot_xlsx, " and the source could not be ",
       "read, so there is nothing to build from.", call. = FALSE)
}

## ---- read the frozen snapshot (verbatim headers, everything as text) ----
snap <- as.data.frame(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                         col_types = "text"),
                      check.names = FALSE)
snap[is.na(snap)] <- ""
stopifnot(nrow(snap) == 48L)

taxon <- trimws(snap[["Taxonomy"]])

## ---- unnest the clade rows into rank columns ----
suborders_printed <- c("Prosimii", "Anthropoidea")   # as printed; see header note
is_species <- nzchar(trimws(snap[["Spindle cells"]]))
rank <- ifelse(is_species, "species",
        ifelse(taxon %in% suborders_printed, "suborder",
        ifelse(grepl("idae$", taxon), "family", "superfamily")))

suborder <- superfamily <- family <- rep(NA_character_, length(taxon))
cur_sub <- cur_sup <- cur_fam <- NA_character_
for (i in seq_along(taxon)) {
  if (rank[i] == "suborder")    { cur_sub <- taxon[i]; cur_sup <- NA_character_; cur_fam <- NA_character_ }
  if (rank[i] == "superfamily") { cur_sup <- taxon[i]; cur_fam <- NA_character_ }
  if (rank[i] == "family")      { cur_fam <- taxon[i] }
  suborder[i] <- cur_sub; superfamily[i] <- cur_sup; family[i] <- cur_fam
}

## ---- keep the species rows ----
keep <- which(is_species)
stopifnot(length(keep) == 28L)                      # "28 primate species" (Specimens)
stopifnot(!any(is.na(family[keep])))                 # every species sits under a family

spindle <- trimws(snap[["Spindle cells"]][keep])
stopifnot(all(spindle %in% c("None", "Rare", "Frequent", "Abundant", "Abundant/clusters")))

## ---- species harmonisation via the collection key (never an inline map) ----
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
species_accepted <- rep(NA_character_, length(keep))
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
  species_accepted <- unname(lk[tolower(taxon[keep])])
  missing <- taxon[keep][is.na(species_accepted)]
  if (length(missing)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(missing, collapse = "; "),
         ". Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

clean <- data.frame(
  species               = species_accepted,
  species_as_published  = taxon[keep],
  suborder              = suborder[keep],
  superfamily           = superfamily[keep],
  family                = family[keep],
  spindle_cells         = spindle,
  spindle_cells_present = spindle != "None",
  n_specimens           = as.integer(trimws(snap[["N"]][keep])),
  source                = source_name,
  stringsAsFactors = FALSE
)
stopifnot(sum(clean$n_specimens) == 74L)             # specimen total across the 28 species
stopifnot(sum(clean$spindle_cells_present) == 5L)    # Pongo, Gorilla, both Pan, Homo

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
