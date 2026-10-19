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
final.dataframe <- do.call(rbind, lapply(seq_len(nrow(snapshot)), function(i) {
  do.call(rbind, lapply(seq.int(2L, ncol(snapshot)), function(j) {
    label <- names(snapshot)[j]
    data.frame(species_as_published = context$species_as_published, area_as_published = sub("_[23]D$", "", gsub("V2L_TeA", "V2L/TeA", label)),
      analysis_dimension = sub(".*_([23])D$", "\\1-D", label), distance_from_soma_um = snapshot$distance_um[i],
      sholl_intersections_mean_approx = as.numeric(snapshot[i, j]), n_individuals = as.integer(context$n_individuals),
      n_cells_per_area = as.integer(context$n_per_area_per_mouse) * as.integer(context$n_individuals), hemisphere = context$hemisphere, cortical_layer = context$cortical_layer, data_role = "primary",
      method = "Sholl analysis; 2-D circles or 3-D Neurolucida spheres at 25 µm intervals",
      value_basis = "approximate digitized figure point; not author-supplied numeric data",
      source_locus = "Figure 3A, PDF p. 4, printed p. 406", stringsAsFactors = FALSE)
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
