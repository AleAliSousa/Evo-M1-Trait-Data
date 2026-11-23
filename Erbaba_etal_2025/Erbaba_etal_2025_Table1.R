#!/usr/bin/env Rscript
suppressPackageStartupMessages(library(readr))
args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
if (length(file_arg)) {
  script_path <- normalizePath(sub("^--file=", "", file_arg[1]))
} else if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  script_path <- normalizePath(rstudioapi::getSourceEditorContext()$path)
} else stop("Run with Rscript or from a saved script in RStudio.")
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
snapshot <- file.path(folder, paste0(item_name, "_snapshot.csv"))
x <- read_csv(snapshot, show_col_types = FALSE, na = c("", "NA"))
name_map <- c("Gorilla"="Gorilla gorilla", "Bonobo"="Pan paniscus", "Chimpanzee"="Pan troglodytes", "Orangutan"="Pongo sp.")
sex_map <- c("Female"="F", "Male"="M")
parse_age <- function(z) {
  out <- rep(NA_real_, length(z));
  out[grepl("^[0-9]+ year", z)] <- as.numeric(sub(" year.*", "", z[grepl("^[0-9]+ year", z)]))
  out[grepl("^[0-9]+ months", z)] <- as.numeric(sub(" months.*", "", z[grepl("^[0-9]+ months", z)]))/12
  out[grepl("^[0-9]+ weeks", z)] <- as.numeric(sub(" weeks.*", "", z[grepl("^[0-9]+ weeks", z)]))/52.1429
  out
}
final.dataframe <- data.frame(
  ape_name=x[["Ape name"]], reference_key=x[["Reference"]], species_printed=x[["Species"]],
  species_unresolved=unname(name_map[x[["Species"]]]), sex=unname(sex_map[x[["Sex"]]]),
  first_exposure_printed=x[["Age of first exposure to sign/symbols"]],
  first_exposure_age_years=parse_age(x[["Age of first exposure to sign/symbols"]]),
  language_type=x[["Type of language (ASL/Lexigram)"]],
  age_status_printed=x[["Age at death/current age"]], source="Erbaba_etal_2025", stringsAsFactors=FALSE)
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
# Registry-derived public name must replace this provisional stem after registration.
write_tsv(final.dataframe, file.path(folder, "10_1002_evan_70018_Table1.tsv"), na="")
