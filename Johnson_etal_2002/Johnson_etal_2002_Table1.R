## Johnson_etal_2002_Table1.R -- frozen snapshot -> analysis CSV + public TSV
##
## Johnson, V. E., Deaner, R. O., & van Schaik, C. P. (2002). Bayesian analysis of rank
## data with application to primate intelligence experiments. JASA 97(457):8-17.
## doi:10.1198/016214502753479185
##
## Table 1 (p. 9, printed rotated): 24 primate GENERA x 30 procedures in nine paradigms;
## 113 filled cells; entries are within-procedure performance RANKS (1 = best; x.5 = ties).
## The PDF text layer corrupts every fractional rank ("1.5" -> "105"); the frozen snapshot
## was therefore transcribed from the rendered page image (all 113 cells, every x.5 cell
## re-checked on a 500-dpi crop) -- see the item README. This script only READS it.
## Data role: both -- the ranks are the authors' own ordinal coding (first published here;
## re-published in Deaner_etal_2006_Table1), the underlying performance data are secondary
## (Table 1 NOTE: one or more original studies per procedure ->
## reference_tables/Johnson_etal_2002_Table1_references.csv, join on procedure_ref_key).

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  for (fr in rev(sys.frames())) if (!is.null(fr$ofile)) return(normalizePath(fr$ofile))
  cl <- sys.calls(); fs <- sys.frames()   # sys.source() (build_dataset_item) keeps the path in `file`
  for (i in rev(seq_along(cl))) if (identical(cl[[i]][[1]], quote(sys.source)) && is.character(fs[[i]]$file))
    return(normalizePath(fs[[i]]$file))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or source() the saved file.", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))      # "Johnson_etal_2002_Table1"
base      <- dirname(folder)
source_publication <- basename(folder)                     # species-key token = folder name

## 1. LOAD FROZEN SNAPSHOT (positional) -----------------------------
raw <- as.data.frame(readxl::read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1", col_names = FALSE, col_types = "text",
                                .name_repair = "unique_quiet"),
                     stringsAsFactors = FALSE)
stopifnot(ncol(raw) == 31L, trimws(raw[4, 1]) == "Genus",
          identical(suppressWarnings(as.integer(unlist(raw[4, 2:31]))), 1:30))

## paradigm header row is merged across its procedures -> carry forward
para <- unlist(raw[2, 2:31]); for (k in seq_along(para)) if (is.na(para[k])) para[k] <- para[k - 1]
body <- raw[5:nrow(raw), ]
body <- body[!grepl("^NOTE:", body[[1]]) | is.na(body[[1]]), ]
## printed groups are separated by blank rows; NOTE names them in order
grp_id <- cumsum(is.na(body[[1]])) + 1L
grp_lab <- c("great apes", "Hylobates (not categorized)", "Old World monkeys",
             "New World monkeys", "Prosimians")
keep <- !is.na(body[[1]])
body <- body[keep, ]; grp_id <- grp_id[keep]
stopifnot(nrow(body) == 24L, max(grp_id) == 5L)

## 2. LONG FORMAT ---------------------------------------------------
long <- do.call(rbind, lapply(seq_len(nrow(body)), function(i) {
  v <- unlist(body[i, 2:31]); k <- which(!is.na(v) & nzchar(trimws(v)))
  if (!length(k)) return(NULL)
  data.frame(genus_as_published = body[i, 1], taxonomic_group_note = grp_lab[grp_id[i]],
             paradigm = para[k], procedure = k, rank = as.numeric(v[k]),
             stringsAsFactors = FALSE)
}))
stopifnot(nrow(long) == 113L, !anyNA(long$rank), all(long$rank >= 1),
          all(long$rank * 2 == round(long$rank * 2)))   # integer or x.5 ties only

## 3. TAXON HARMONISATION via the collection key (_keys/General) -----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == source_publication, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", source_publication, "' in _keys/General/species_key.csv")
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
long$taxon_harmonised <- unname(lk[tolower(trimws(long$genus_as_published))])
if (anyNA(long$taxon_harmonised))
  stop("Unkeyed printed genus: ", paste(unique(long$genus_as_published[is.na(long$taxon_harmonised)]), collapse = ", "))
long$taxon_rank <- "genus"

## 4. SOURCE KEYS (Table 1 NOTE numbers the original studies by procedure) --
long$procedure_ref_key <- as.character(long$procedure)
long$source <- item_name
final.dataframe <- long[, c("genus_as_published", "taxon_harmonised", "taxon_rank",
                            "taxonomic_group_note", "paradigm", "procedure", "rank",
                            "procedure_ref_key", "source")]

## 5. WRITE CSV + PUBLIC TSV (registry is the naming authority) ------
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE,
          na = "", fileEncoding = "UTF-8")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " genus x procedure rows -> ", item_encoded, ".tsv")
