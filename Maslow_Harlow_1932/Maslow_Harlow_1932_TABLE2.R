## Maslow_Harlow_1932_TABLE2 -- Summary of correct responses (p.106)
## Input : Maslow_Harlow_1932_TABLE2_snapshot.xlsx  (frozen; printed layout)
## Output: Maslow_Harlow_1932_TABLE2.csv + public TSV
## Reshaped LONG: one analysis row per animal x printed delay that carries any
## value, plus one row for each of the three animals whose entire data strip is
## a printed sentence instead of numbers.
##
## TABLE 2 names its animals by common name only and its row order and three of
## its names DISAGREE with TABLE 1 (no. 4 is the "guinea baboon" Papio papio in
## TABLE 1 but "Hamadryas baboon" here; TABLE 1's only baby, no. 7, is a DRILL
## but is "Baby mandrill" here).  The two tables are therefore NOT joined on
## row position or on name: the species comes from the label TABLE 2 itself
## prints, through _keys/General/species_key.csv, and the disagreements are
## recorded in Maslow_Harlow_1932_errata.csv (E001, E002).
options(scipen = 999, stringsAsFactors = FALSE)

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Repository root (__ReadMe.xlsx) not found above ", folder, call. = FALSE)
source(file.path(base, "_keys", "resolve_species.R"))

## numbers as printed -> numeric; blanks and the printed non-numeric tokens stay NA
num <- function(x) {
  x <- gsub("\u00a0", " ", as.character(x), fixed = TRUE)
  x <- gsub(",", "", trimws(x))
  x[x %in% c("", "-", "\u2013", "\u2014", "NA", "n.a.", "NR", "NE")] <- NA_character_
  suppressWarnings(as.numeric(x))
}

s <- as.data.frame(readxl::read_excel("Maslow_Harlow_1932_TABLE2_snapshot.xlsx",
                                      col_names = FALSE, .name_repair = "minimal"))
s[is.na(s)] <- ""
stopifnot(nrow(s) == 24L, ncol(s) == 17L)
delay_lab <- unlist(s[4, seq(2, 17, by = 2)], use.names = FALSE)
stopifnot(identical(delay_lab, c("0", "5", "10", "15", "30", "60", "120", "180")))
delay_s <- as.numeric(delay_lab)

d <- s[6:23, ]
stopifnot(nrow(d) == 18L, d[1, 1] == "Young chimpanzee",
          d[18, 1] == "Brown mongoose lemur")

out <- list()
for (i in seq_len(nrow(d))) {
  free_text <- is.na(num(d[i, 2])) && nzchar(d[i, 2])
  for (b in seq_len(8L)) {
    cells <- unlist(d[i, 2 * b + c(0, 1)], use.names = FALSE)
    if (free_text && b > 1L) next
    if (!free_text && all(cells == "")) next
    out[[length(out) + 1L]] <- data.frame(
      animal_number_printed = i,
      animal_as_published   = d[i, 1],
      delay_s               = if (free_text) NA_real_ else delay_s[b],
      n_trials              = if (free_text) NA_real_ else num(cells[1]),
      pct_correct           = if (free_text) NA_real_ else num(cells[2]),
      note_as_published     = if (free_text) d[i, 2] else NA_character_,
      row.names = NULL, check.names = FALSE)
  }
}
final.dataframe <- do.call(rbind, out)
sp <- resolve_species(final.dataframe$animal_as_published, "Maslow_Harlow_1932")
final.dataframe$species_printed <- final.dataframe$animal_as_published
final.dataframe$accepted_name   <- sp$accepted_name
final.dataframe$species_basis   <- sp$species_basis
final.dataframe$reidentified    <- sp$reidentified
final.dataframe$source          <- "Maslow_Harlow_1932_TABLE2"
stopifnot(!any(sp$unresolved), sum(!is.na(final.dataframe$note_as_published)) == 3L)

## ---- write the analysis CSV and the DOI-coded public TSV -----------------
stopifnot(is.data.frame(final.dataframe), nrow(final.dataframe) > 0L)
write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE, na = "")

fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(item_encoded)) stop("No registry row for Item name '", item_name, "'", call. = FALSE)
## Column A of Sheet1 has carried trailing whitespace, which the Item-name
## formula pastes into Item encoded ("10.1037%2Fh0073864<NBSP>_TABLE1").  No
## legitimate encoded stem contains a space, so strip every space (incl. NBSP)
## before using it as a filename.  Harmless once file_list.R has been re-run.
item_encoded <- gsub("[[:space:]]", "",
                     gsub("\u00a0", "", item_encoded, fixed = TRUE))
if (!nzchar(item_encoded)) stop("Empty 'Item encoded' for ", item_name, call. = FALSE)
out_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(out_dir)) {
  write.table(final.dataframe, file.path(out_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "")
} else warning("__Public/comparative-data not mounted; public TSV skipped.")
message(item_name, ": ", nrow(final.dataframe), " rows -> ", item_encoded, ".tsv")
