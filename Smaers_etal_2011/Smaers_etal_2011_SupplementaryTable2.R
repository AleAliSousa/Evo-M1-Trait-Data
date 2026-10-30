## Smaers JB et al. (2011) Brain Behav Evol 77:67-78 — Supplementary Table 2
## Cumulative white/grey volume (cm3) up to the 5th section of the anterior frontal (Figs 2,4,5).
## Source: 000323671_sm_suppltables.pdf (p.2). Snapshot -> clean.

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)
options(scipen = 999)
raw <- read.csv("Smaers_etal_2011_SupplementaryTable2_snapshot.csv", check.names = FALSE, stringsAsFactors = FALSE)
sp  <- sub("^([A-Z][a-z]+ [a-z]+).*$", "\\1", raw$Individual)
cat <- trimws(sub("^[A-Z][a-z]+ [a-z]+", "", raw$Individual))
g <- function(col) raw[[col]]
clean <- data.frame(species=sp, catalogue_number=cat,
  sec5_white_left_cm3=g("Section interval 5 left white"), sec5_grey_left_cm3=g("Section interval 5 left grey"),
  sec5_white_right_cm3=g("Section interval 5 right white"), sec5_grey_right_cm3=g("Section interval 5 right grey"),
  sec5_white_total_cm3=g("Section interval 5 left white")+g("Section interval 5 right white"),
  sec5_grey_total_cm3 =g("Section interval 5 left grey") +g("Section interval 5 right grey"),
  source="Smaers_etal_2011", stringsAsFactors=FALSE)

## ---- SAVE: local CSV + DOI-named TSV ----
library(readxl)
final.dataframe <- clean
write.csv(final.dataframe, file = file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

if (is.na(base)) {
  warning("Repo root not found; TSV skipped.")
} else {
  readme_file <- file.path(base, "__ReadMe.xlsx")
  tsv_dir     <- file.path(base, "__Public", "comparative-data")
  
  filecodes <- read_excel(readme_file, sheet = "Sheet1")
  
  norm_key <- function(x) tolower(gsub("[ _]", "", as.character(x)))
  item_encoded <- filecodes$"Item encoded"[match(norm_key(item_name), norm_key(filecodes$"Item name"))]
  
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write.table(final.dataframe,
                file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
    message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
  }
}