# Zhang_Sejnowski_2000_Figure2.R
# Source: Zhang & Sejnowski (2000), Figure 2; secondary compilation.
# Only numerically printed observations/results are captured; no plot coordinates invented.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(args)) {
  script <- normalizePath(sub("^--file=", "", args[1]))
} else if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
  script <- normalizePath(rstudioapi::getActiveDocumentContext()$path)
} else stop("Run with Rscript or source from a saved RStudio document")
folder <- dirname(script)
item_name <- tools::file_path_sans_ext(basename(script))
snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     stringsAsFactors=FALSE, check.names=FALSE)
stopifnot(identical(names(snapshot), c("species_as_published","G_mm3","W_mm3","source_as_printed","extraction_note")))
final.dataframe <- data.frame(Species_ZhangSejnowski2000=snapshot$species_as_published,
  Neocortical_gray_matter_Vol.mm3=as.numeric(snapshot$G_mm3),
  Adjacent_white_matter_Vol.mm3=as.numeric(snapshot$W_mm3),
  source_as_printed=snapshot$source_as_printed, extraction_note=snapshot$extraction_note,
  value_origin="printed_in_figure_caption", check.names=FALSE)
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
# The registry, not a guessed DOI stem, is authoritative for public TSV naming.
base <- folder
while (dirname(base) != base && !file.exists(file.path(base, "__ReadMe.xlsx"))) base <- dirname(base)
item_encoded <- NA_character_
if (file.exists(file.path(base, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly=TRUE)) {
  registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
  hit <- which(registry$`Item name` == item_name)
  if (length(hit)==1) item_encoded <- registry$`Item encoded`[hit]
}
if (length(item_encoded)!=1 || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$",item_encoded)) {
  warning("Registry Item encoded unavailable; writing provisional local item-name TSV only")
  tsv_path <- file.path(folder, paste0(item_name, ".tsv"))
} else {
  public <- file.path(base, "__Public", "comparative-data")
  if (dir.exists(public)) tsv_path <- file.path(public, paste0(item_encoded, ".tsv"))
  else { warning("Public folder not mounted; writing local encoded TSV"); tsv_path <- file.path(folder, paste0(item_encoded, ".tsv")) }
}
write.table(final.dataframe, tsv_path, sep="\t", row.names=FALSE, na="", quote=TRUE)
