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
# Parse the printed mean±SEM, range, sex counts and gram body-mass range.
numbers <- function(x) as.numeric(regmatches(x, gregexpr("[0-9]+(?:\\.[0-9]+)?", x, perl = TRUE))[[1L]])
sex <- numbers(snapshot[[3L]])
body <- numbers(snapshot[[4L]])
acuity <- numbers(snapshot[[6L]])
limits <- numbers(snapshot[[7L]])
final.dataframe <- data.frame(species_as_published = snapshot[[1L]],
  n_individuals = as.integer(snapshot[[2L]]), n_male = as.integer(sex[1L]), n_female = as.integer(sex[2L]),
  body_mass_min_g = body[1L], body_mass_max_g = body[2L], acuity_metric = snapshot[[5L]],
  visual_acuity_mean_cpd = acuity[1L], visual_acuity_sem_cpd = acuity[2L],
  visual_acuity_min_cpd = limits[1L], visual_acuity_max_cpd = limits[2L],
  method = snapshot[[8L]], distance_correction = snapshot[[9L]],
  observation_level = "species-level summary of individual maxima", data_role = "primary",
  source_locus = "Results p. 4; Methods pp. 2–3", source_pdf = snapshot[[10L]], source_doi = snapshot[[11L]],
  stringsAsFactors = FALSE)

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
