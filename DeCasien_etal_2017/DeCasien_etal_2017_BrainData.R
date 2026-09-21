# DeCasien_etal_2017_BrainData.R
#
# Preparation step. Reformat the digital-native supplementary workbook for
# DeCasien, Williams & Higham (2017), "Primate brain size is predicted by diet
# but not sociality", preserving the source rows from worksheet "Brain Data".
#
# Source : 41559_2017_BFs415590170112_MOESM250_ESM.xls
# Sheet  : Brain Data
# Output : DeCasien_etal_2017_BrainData.csv
#          <Item encoded>.tsv under __Public/comparative-data/
#
# No derived snapshot is made: the journal XLS is the frozen digital-native source.

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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

source_file <- "41559_2017_BFs415590170112_MOESM250_ESM.xls"
source_sheet <- "Brain Data"
expected <- c("CHECK", "KEY", "Genus", "Species", "Brain Vol", "BV SD",
              "Brain Mass", "BM SD", "Body", "Body SD", "Sex", "N", "Age",
              "Reference", "Source", "Notes")

raw <- read_excel(source_file, sheet = source_sheet, col_types = "text", na = "")
if (!identical(names(raw), expected)) {
  stop("Unexpected Brain Data headers: ", paste(names(raw), collapse = ", "), call. = FALSE)
}

# Retain source rows only. KEY is the workbook's taxon identifier; all 838
# source records have a value here. Empty formatting rows are not retained.
final.dataframe <- raw %>%
  filter(!is.na(KEY), nzchar(str_squish(KEY))) %>%
  mutate(
    CHECK = na_if(str_squish(CHECK), ""),
    KEY = str_squish(KEY),
    Genus = na_if(str_squish(Genus), ""),
    Species = na_if(str_squish(Species), ""),
    across(c(`Brain Vol`, `BV SD`, `Brain Mass`, `BM SD`, Body, `Body SD`, N, Reference),
           ~ parse_double(.x, na = c("", "NA"))),
    across(c(Sex, Age, Source, Notes), ~ na_if(str_squish(.x), ""))
  )

if (nrow(final.dataframe) != 838L) {
  stop("Expected 838 Brain Data rows; found ", nrow(final.dataframe), ".", call. = FALSE)
}
if (!setequal(na.omit(unique(final.dataframe$Reference)), c(47, 48))) {
  stop("Unexpected Brain Data reference numbers.", call. = FALSE)
}
if (!all(final.dataframe$N[!is.na(final.dataframe$N)] > 0)) {
  stop("Non-positive sample size found in N.", call. = FALSE)
}

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
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " rows)")
