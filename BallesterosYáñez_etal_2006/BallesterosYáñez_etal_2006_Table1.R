folder <- local({
  for (fr in rev(sys.frames())) {
    p <- fr$ofile
    if (is.null(p)) p <- fr$file
    if (is.character(p) && length(p) == 1L && file.exists(p) &&
        grepl("\\.R$", p) && startsWith(basename(p), basename(dirname(normalizePath(p)))))
      return(normalizePath(p))
  }
  argv <- commandArgs(FALSE)
  p <- sub("^--file=", "", argv[grepl("^--file=", argv)])
  if (length(p) == 1L && file.exists(p)) return(normalizePath(p))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Cannot locate this build script; use Rscript or source().")
})
base <- sub("\\.R$", "", basename(folder))
folder <- dirname(folder)
item_name <- base
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
  root <- dirname(root)
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
## NFC on both sides: macOS may hand back the accented folder/file name decomposed (NFD).
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes[["Item encoded"]][match(nfc(item_name), nfc(filecodes[["Item name"]]))]
stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), !grepl("_$", item_encoded))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                           check.names = FALSE, stringsAsFactors = FALSE, na.strings = "", fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")), stringsAsFactors = FALSE, fileEncoding = "UTF-8")
# The frozen table retains caption, original column order, mean±SEM, n and footnote.
names(snapshot) <- as.character(snapshot[1L, ])
rows <- snapshot[seq.int(2L, 5L), , drop = FALSE]
numbers <- function(x) as.numeric(regmatches(x, gregexpr("[0-9]+(?:\\.[0-9]+)?", x, perl = TRUE))[[1L]])
final.dataframe <- do.call(rbind, lapply(seq_len(nrow(rows)), function(i) {
  do.call(rbind, lapply(seq.int(2L, 4L), function(j) {
    values <- numbers(rows[i, j])
    parameter <- rows[i, 1L]
    data.frame(species_as_published = context$species_as_published, area_as_published = names(rows)[j],
      parameter_as_published = parameter, mean_as_published = values[1L], sem_as_published = values[2L],
      unit_as_published = if (grepl("²", parameter)) "µm²" else "µm", n_spines = as.integer(values[3L]),
      n_individuals = as.integer(context$n_individuals), sex = context$sex, age_months = as.integer(context$age_months), hemisphere = context$hemisphere, cortical_layer = context$cortical_layer,
      data_role = if (names(rows)[j] == "M2") "primary" else "secondary",
      source_ref_key = if (names(rows)[j] == "M2") NA_character_ else "Benavides-Piccione, et al. (2002)",
      method = "Lucifer Yellow injection; lateral spine reconstruction; morphometry",
      source_locus = "Table 1, PDF p. 5, printed p. 407; Methods pp. 404–405", stringsAsFactors = FALSE)
  }))
}))

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
dir.create(file.path(root, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
# Never silently replace a different pre-existing public table.
p <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
if (file.exists(p)) {
  old <- utils::read.delim(p, check.names = FALSE, stringsAsFactors = FALSE, na.strings = "", fileEncoding = "UTF-8")
  stopifnot(isTRUE(all.equal(old, final.dataframe, check.attributes = FALSE)))
} else {
  utils::write.table(final.dataframe, p, sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
}
