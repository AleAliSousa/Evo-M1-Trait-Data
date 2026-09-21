# DeCasien_etal_2017_referencesbraindata.R
#
# Reference key for the numeric Reference values used by worksheet "Brain Data"
# in 41559_2017_BFs415590170112_MOESM250_ESM.xls. The workbook uses 47 and 48;
# its Source column identifies these compilations as Boddy et al. and Isler et al.
# The article bibliography numbers the same publications 48 and 49, respectively.
#
# Input : DeCasien-2017-Primate brain size i.pdf (bibliographic source)
# Output: DeCasien_etal_2017_referencesbraindata.csv
#         <Item encoded>.tsv under __Public/comparative-data/

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr)
})

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
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)

dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

pdf_file <- "DeCasien-2017-Primate brain size i.pdf"
if (!file.exists(pdf_file)) stop("Missing source PDF: ", pdf_file, call. = FALSE)

# Journal-faithful citation text from the article bibliography. workbook_ref is
# the numbering printed in Brain Data; article_ref records the PDF numbering.
final.dataframe <- tibble::tribble(
  ~ref_number, ~article_ref_number, ~source_label, ~citation,
  47L, 48L, "Boddy et al. 2012",
  "Boddy, A. M. et al. Comparative analysis of encephalization in mammals reveals relaxed constraints on anthropoid primate and cetacean brain scaling. J. Evol. Biol. 25, 981-994 (2012).",
  48L, 49L, "Isler et al. 2008",
  "Isler, K. et al. Endocranial volumes of primate species: scaling analyses using a comprehensive and reliable data set. J. Hum. Evol. 55, 967-978 (2008)."
)

if (!identical(final.dataframe$ref_number, c(47L, 48L))) stop("Reference-key construction failed.", call. = FALSE)
write_csv(final.dataframe, paste0(item_name, ".csv"), na = "")

if (is.na(dataset_root)) {
  warning("Repository root containing __ReadMe.xlsx was not found; public TSV skipped.")
} else {
  registry <- read_excel(file.path(dataset_root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
    stop("No 'Item encoded' for ", item_name, " in __ReadMe.xlsx; fix the registry row first.", call. = FALSE)
  }
  public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  tsv_file <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
  write_tsv(final.dataframe, tsv_file, na = "")
  message("Wrote ", tsv_file)
}
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " references)")
