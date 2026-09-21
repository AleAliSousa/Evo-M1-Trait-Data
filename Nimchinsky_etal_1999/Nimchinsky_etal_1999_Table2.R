## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. Table 2.
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
##   and compares Table 2 with the frozen copy on disk: writes it if absent,
##   reports a verification if identical, writes *_REBUILD.csv and stops if it
##   differs, warns and carries on if the page cannot be read. Table 2 is flat
##   text, so .csv is the faithful medium (Table 1 needs .xlsx for its bold).
##
## Section 2 BUILD. Always reads the frozen .csv from disk - never the object
##   parsed in section 1 - so what is published is always what is committed.
##
## Input : Nimchinsky_etal_1999_Table2_snapshot.csv  (Species + 3 cell-type columns,
##         each printed "mean +/- SD" with significance markers attached)
## Output: <script stem>.csv   one row per species (5)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## Units. These are somata, not structures, so the project's mm3 standard does not
## apply: the paper's um3 is kept. Converting would put every value at 1e-6 mm3 and
## make the column unreadable next to the structure volumes it does not belong with.
## Measure is recorded as Vol.um3 in the definitions so it cannot be pooled with
## Vol.mm3 by accident.
##
## Markers. The caption defines them: *, P < 0.05 (spindle cells vs layer V
## pyramidal cells); +, P < 0.01 (spindle cells vs small layer VI fusiform
## neurons). Both are attached to the spindle-cell cell only, so each becomes its
## own logical column and the value column is left numeric.
##
## n. The caption gives the sample as 50 neurons in each layer from each case; it
## is constant across the table and is carried as a column so it travels with the
## values.

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
item_name    <- tools::file_path_sans_ext(basename(.sp))
source_name  <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
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


## =====================================================================
## SECTION 2 - BUILD: frozen copy on disk -> analysis CSV -> public TSV
## =====================================================================

if (!file.exists(snapshot_csv)) {
  stop("No frozen snapshot at ", snapshot_csv, " and the source could not be ",
       "read, so there is nothing to build from.", call. = FALSE)
}

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8")
stopifnot(nrow(snap) == 5L)
stopifnot(identical(names(snap),
                    c("Species", "Pyramidal cells", "Spindle cells", "Fusiform cells")))

## ---- helpers: split "1,951 +/- 913" and strip the caption's markers ----
strip_marks <- function(x) gsub("[*†‡]", "", x)
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
part <- function(x, i) {
  p <- strsplit(strip_marks(trimws(x)), "±", fixed = TRUE)
  num(vapply(p, function(v) { stopifnot(length(v) == 2L); v[i] }, character(1)))
}
has_mark <- function(x, mark) grepl(mark, x, fixed = TRUE)

## ---- species harmonisation via the collection key (never an inline map) ----
## Table 2 abbreviates the binomials ("P. pygmaeus"); those printed forms have
## their own rows in the key, so no expansion happens in this script.
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
species_accepted <- rep(NA_character_, nrow(snap))
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
  species_accepted <- unname(lk[tolower(trimws(snap$Species))])
  missing <- snap$Species[is.na(species_accepted)]
  if (length(missing)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(missing, collapse = "; "),
         ". Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

clean <- data.frame(
  species                  = species_accepted,
  species_as_published     = trimws(snap$Species),
  pyramidal_vol_um3_mean   = part(snap[["Pyramidal cells"]], 1),
  pyramidal_vol_um3_sd     = part(snap[["Pyramidal cells"]], 2),
  spindle_vol_um3_mean     = part(snap[["Spindle cells"]], 1),
  spindle_vol_um3_sd       = part(snap[["Spindle cells"]], 2),
  fusiform_vol_um3_mean    = part(snap[["Fusiform cells"]], 1),
  fusiform_vol_um3_sd      = part(snap[["Fusiform cells"]], 2),
  spindle_gt_pyramidal_p05 = has_mark(snap[["Spindle cells"]], "*"),
  spindle_gt_fusiform_p01  = has_mark(snap[["Spindle cells"]], "†"),
  n_neurons_per_layer      = 50L,
  source                   = source_name,
  stringsAsFactors = FALSE
)

## the markers are printed on the spindle-cell column only
stopifnot(!any(has_mark(snap[["Pyramidal cells"]], "*")),
          !any(has_mark(snap[["Fusiform cells"]], "*")),
          !any(has_mark(snap[["Pyramidal cells"]], "†")),
          !any(has_mark(snap[["Fusiform cells"]], "†")))
## every row is daggered; the asterisk is on Pongo, P. troglodytes and Homo
stopifnot(all(clean$spindle_gt_fusiform_p01), sum(clean$spindle_gt_pyramidal_p05) == 3L)
stopifnot(!any(is.na(clean[, grep("_um3_", names(clean))])))

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
