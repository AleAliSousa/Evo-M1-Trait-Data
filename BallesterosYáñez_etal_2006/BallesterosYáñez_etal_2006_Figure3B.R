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
item_encoded <- filecodes[["Item encoded"]][match(item_name, filecodes[["Item name"]])]
stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), !grepl("_$", item_encoded))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                           check.names = FALSE, stringsAsFactors = FALSE, na.strings = "", fileEncoding = "UTF-8")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")), stringsAsFactors = FALSE, fileEncoding = "UTF-8")
final.dataframe <- do.call(rbind, lapply(seq_len(nrow(snapshot)), function(i) {
  do.call(rbind, lapply(seq.int(2L, 4L), function(j) {
    if (is.na(snapshot[i, j])) return(NULL)
    data.frame(species_as_published = context$species_as_published, area_as_published = gsub("V2L_TeA", "V2L/TeA", names(snapshot)[j]),
      distance_from_soma_um = snapshot$distance_um[i], spines_per_10um_approx = as.numeric(snapshot[i, j]),
      n_individuals = as.integer(context$n_individuals), n_dendrites_per_area = as.integer(context$n_per_area_per_mouse) * as.integer(context$n_individuals), hemisphere = context$hemisphere, cortical_layer = context$cortical_layer,
      data_role = "primary", method = "high-power reconstruction of horizontal basal dendrites; no correction factor",
      value_basis = "approximate digitized figure point; not author-supplied numeric data",
      source_locus = "Figure 3B, PDF p. 4, printed p. 406", source_note = snapshot$note[i], stringsAsFactors = FALSE)
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
