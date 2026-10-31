## Bjugn__1993_TABLEIII.R -- frozen printed TABLE III (p.29, PDF page 5) -> tidy analysis CSV + public TSV.
## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Run from the repo root: LANG=en_US.UTF-8 Rscript --vanilla <Folder>/Bjugn__1993_TABLEIII.R
self <- local({
  own_basename <- "Bjugn__1993_TABLEIII.R"
  candidates <- character()
  for (frame in rev(sys.frames())) {
    for (field in c("ofile", "file", "filename")) {
      candidate <- frame[[field]]
      if (is.character(candidate)) candidates <- c(candidates, candidate)
    }
  }
  args <- commandArgs(trailingOnly = FALSE)
  candidates <- c(candidates, sub("^--file=", "", args[grepl("^--file=", args)]))
  candidates <- candidates[!is.na(candidates) & nzchar(candidates)]
  candidates <- candidates[basename(candidates) == own_basename & file.exists(candidates)]
  if (!length(candidates)) stop("Cannot locate this script by its own basename.")
  normalizePath(candidates[[1L]], winslash = "/", mustWork = TRUE)
})
folder <- dirname(self)
base <- normalizePath(file.path(folder, ".."), winslash = "/", mustWork = TRUE)
item_name <- tools::file_path_sans_ext(basename(self))

snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                            colClasses = "character", check.names = FALSE, fill = TRUE,
                            blank.lines.skip = FALSE, na.strings = NULL, fileEncoding = "UTF-8")
if (snapshot[1L, 1L] != "TABLE III" || ncol(snapshot) != 8L) stop("Wrong printed table or layout.")
if (snapshot[4L, 1L] != "Slab") stop("Printed header row not where expected.")
body <- snapshot[grepl("^[0-9]+$", snapshot[[1L]]), , drop = FALSE]
if (!identical(body[[1L]], as.character(1:8))) stop("Expected printed slabs 1-8 in order.")
## printed en dash = no successor slab (B for slab 8; C for slabs 7-8) -> NA; anything else must be numeric
num <- function(x) {
  x[x == "\u2013"] <- NA_character_
  out <- suppressWarnings(as.numeric(x))
  if (any(is.na(out) & !is.na(x))) stop("Unparseable printed numeric cell.")
  out
}
codes <- c("slab", "Q_minus_cells_counted_oblique", "F_fields_counted", "P_points_transverse",
           "Xi_QminusP_over_F", "A_Xi_squared", "B_Xi_times_Xi_plus_1", "C_Xi_times_Xi_plus_2")
final.dataframe <- as.data.frame(lapply(body, num), check.names = FALSE)
names(final.dataframe) <- codes
## printed Sigma row: kept as columns (one value per series), not as a ninth slab
sigma <- snapshot[snapshot[[1L]] == "\u03a3", , drop = FALSE]
if (nrow(sigma) != 1L) stop("Printed Sigma row missing.")
sig <- as.numeric(gsub(",", "", sub("^.*= *", "", unlist(sigma[1L, 2:8]))))
names(sig) <- paste0("Sigma_", codes[2:8], "_as_printed")
for (k in names(sig)) final.dataframe[[k]] <- sig[[k]]
stopifnot(sum(final.dataframe$Q_minus_cells_counted_oblique) == sig[[1L]],
          sum(final.dataframe$F_fields_counted) == sig[[2L]],
          sum(final.dataframe$P_points_transverse) == sig[[3L]])
ce_line <- snapshot[grepl("^CE =", snapshot[[1L]]), 1L]
final.dataframe$CE_gray_matter_cell_number <- as.numeric(sub("^.*= *", "", ce_line))
final.dataframe$animal_id_as_published <- "1"
final.dataframe$species_as_published <- "mouse"
final.dataframe$strain_as_published <- "Bom:NMRI"
final.dataframe$tissue <- "spinal cord gray matter"
final.dataframe$observation_level <- "worked_example_single_animal"
final.dataframe$data_role <- "primary"
final.dataframe$source_table <- "TABLE III"
final.dataframe$source_printed_page <- 29L
final.dataframe$source_pdf_page <- 5L
final.dataframe$DOI <- "10.1016/0006-8993(93)90744-8"
final.dataframe$PMID <- 8293301L
final.dataframe$Reference <- item_name

## ---- species harmonisation: collection-scoped key, rows keyed by the paper FOLDER name ----
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"), colClasses = "character",
                       na.strings = NULL, check.names = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == basename(folder), , drop = FALSE]
if (nrow(key) == 0L) stop("species_key filter returned zero rows for source_publication = ", basename(folder))
lk <- stats::setNames(key$accepted_name, key$variant_name)
final.dataframe$Species <- unname(lk[final.dataframe$species_as_published])
if (anyNA(final.dataframe$Species))
  stop("Printed name(s) missing from species_key: ",
       paste(unique(final.dataframe$species_as_published[is.na(final.dataframe$Species)]), collapse = "; "))

final.dataframe <- final.dataframe[, c("Reference", "Species", "species_as_published", setdiff(names(final.dataframe), c("Reference", "Species", "species_as_published")))]

## ---- analysis CSV (paper folder) ----
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- public TSV: LIVE registry, matched by exact Item name (never by row position) ----
filecodes <- suppressMessages(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"))
matches <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
if (length(matches) != 1L) stop("Registry must contain exactly one Sheet1 row with Item name ", item_name)
item_encoded <- as.character(filecodes[["Item encoded"]][[matches]])
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$|[/\\\\]", item_encoded))
  stop("Registry Item encoded is missing or malformed for ", item_name)
txt <- vapply(final.dataframe, function(x) any(grepl("[\t\r\n]", as.character(x))), logical(1))
if (any(txt)) stop("Tab/newline inside a field would corrupt the unquoted TSV: ", paste(names(txt)[txt], collapse = ", "))
public <- file.path(base, "__Public", "comparative-data")
if (!dir.exists(public)) stop("Canonical __Public/comparative-data directory not mounted.")
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                   sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows -> ", item_name, ".csv and ", item_encoded, ".tsv")
