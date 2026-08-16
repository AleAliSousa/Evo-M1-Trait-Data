# Navarrete et al. 2016 Dryad data: primate innovation classifications.

suppressPackageStartupMessages(library(readxl))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

source_file <- file.path(paper_dir, "ESMNavarreteReaderStreetWhalenLaland_dataset.csv")
source_md5 <- unname(tools::md5sum(source_file))
if (!identical(source_md5, "74eefe75e9e0bb2abcb84010e6317b87")) {
  stop("Unexpected source-file checksum: ", source_md5)
}

source <- read.csv(source_file, check.names = FALSE, stringsAsFactors = FALSE,
                   na.strings = c("", "NA"))
stopifnot(nrow(source) == 167L, ncol(source) == 17L)

final.dataframe <- data.frame(
  source_row = as.integer(source[["Nr."]]),
  parvorder_printed = source[["Parvorder"]],
  family_printed = source[["Family"]],
  Species_Navarrete2016 = source[["Species (Arnold et al. 2010)"]],
  Species_Isler2008 = source[["Species (Isler et al. 2008)"]],
  Species_Reader2011 = source[["Species (Reader et al. 2011)"]],
  innovator = source[["Innovator?"]],
  technical_innovation_count = source[["Technical innovation rate (nr)"]],
  nontechnical_innovation_count = source[["Non-technical innovation rate (nr)"]],
  technical_innovation_plus_extractive_foraging_count =
    source[["Technical innovation rate including extractive foraging (nr)"]],
  nontechnical_innovation_excluding_extractive_foraging_count =
    source[["Non-technical innovation rate excluding extractive foraging (nr)"]],
  foraging_innovation_count = source[["Foraging innovation (nr)"]],
  technical_foraging_innovation_count = source[["Technical foraging innovation (nr)"]],
  nontechnical_foraging_innovation_count = source[["Non-technical foraging innovation (nr)"]],
  technical_foraging_plus_extractive_foraging_count =
    source[["Technical foraging innovation including extractive foraging (nr)"]],
  nontechnical_foraging_excluding_extractive_foraging_count =
    source[["Non-technical foraging innovation rate excluding extractive foraging (nr)"]],
  life_history_composite = source[["Life history composite"]],
  stringsAsFactors = FALSE
)

count_cols <- grep("_count$", names(final.dataframe), value = TRUE)
if (any(vapply(final.dataframe[count_cols], function(x) any(is.na(x) | x < 0 | x != floor(x)), logical(1)))) {
  stop("Innovation-count columns must contain non-negative integers")
}
if (any((final.dataframe$technical_innovation_count +
         final.dataframe$nontechnical_innovation_count > 0) !=
        (final.dataframe$innovator == "Yes"))) {
  stop("Innovator flag is inconsistent with the source innovation counts")
}
if (any(final.dataframe$foraging_innovation_count !=
        final.dataframe$technical_foraging_innovation_count +
        final.dataframe$nontechnical_foraging_innovation_count)) {
  stop("Foraging innovation counts do not reproduce the printed partition")
}
if (any(final.dataframe$foraging_innovation_count !=
        final.dataframe$technical_foraging_plus_extractive_foraging_count +
        final.dataframe$nontechnical_foraging_excluding_extractive_foraging_count)) {
  stop("Reclassified foraging counts do not reproduce the printed partition")
}

local_csv <- file.path(paper_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, local_csv, row.names = FALSE, na = "")

registry <- read_excel(file.path(root_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop("No cached Item encoded value for ", item_name, " in __ReadMe.xlsx")
}
public_tsv <- file.path(root_dir, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, public_tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "")
message("Wrote ", local_csv, " and ", public_tsv, " (", nrow(final.dataframe), " rows)")
