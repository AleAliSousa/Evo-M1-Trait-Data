## MacLeod et al. 2003, J Hum Evol 44:401-429 — Table 1 (Yerkes sample)
## Snapshot -> clean. Per-specimen volumes (cm3): whole brain, cerebellum, vermis, hemispheres.
## Golden rule: the snapshot is frozen/faithful; ALL cleaning happens here.

options(scipen = 999)
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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

raw <- read.csv("MacLeod_etal_2003_Table1_snapshot.csv", check.names = FALSE, stringsAsFactors = FALSE)
spec <- raw$Specimen

# Footnote markers carried in the Specimen cell (Table 2 legend applies to both tables):
#   †  from the Stephan Collection   ‡  brain weight not known
#   *  horizontal sections           §  sagittal sections   (default: coronal)
has_star <- grepl("*", spec, fixed = TRUE)
has_sec  <- grepl("§", spec, fixed = TRUE)
clean_species <- function(s) {
  s  <- gsub("[*†‡§]", "", s); s <- trimws(sub("\\(.*$", "", s)); tk <- strsplit(s, "\\s+")[[1]]
  out <- trimws(paste(tk[1], if (length(tk) >= 2) tk[2] else ""))
  if (length(tk) >= 3 && grepl("^[a-z]+$", tk[3])) out <- paste(out, tk[3]); out
}
as_num <- function(x) suppressWarnings(as.numeric(x))

clean <- data.frame(
  species               = vapply(spec, clean_species, character(1), USE.NAMES = FALSE),
  specimen              = trimws(gsub("\\s*[*†‡§]+", "", spec)),
  sex                   = raw$Sex,
  sample                = "Yerkes",
  brain_volume_cm3      = as_num(raw[["Brain volume cm3"]]),
  cerebellum_volume_cm3 = as_num(raw[["Cerebellum volume cm3"]]),
  vermis_volume_cm3     = as_num(raw[["Vermis volume cm3"]]),
  hemisphere_volume_cm3 = as_num(raw[["Hemisphere volume cm3"]]),
  stephan_collection    = grepl("†", spec, fixed = TRUE),
  section_plane         = ifelse(has_star & has_sec, "mixed", ifelse(has_star, "horizontal", ifelse(has_sec, "sagittal", "coronal"))),
  brainweight_known     = !grepl("‡", spec, fixed = TRUE),
  source                = "MacLeod_etal_2003",
  stringsAsFactors = FALSE
)
## ---- local CSV: use this script's filename ----
csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx ----
tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(
    clean,
    tsv_file,
    sep = "\t",
    row.names = FALSE
  )
  message("Wrote ", tsv_file)
}