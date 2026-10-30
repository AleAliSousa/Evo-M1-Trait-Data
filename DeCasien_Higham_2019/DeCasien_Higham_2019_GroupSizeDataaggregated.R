# DeCasien & Higham 2019 - Group Size Data (aggregated)
# House pipeline: digital-native supplementary workbook -> harmonise species (when present)
# -> analysis CSV + DOI-coded public TSV.
# The journal workbook 41559_2019_969_MOESM3_ESM.xlsx is the frozen source, kept verbatim.

library(readxl)

# ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).",
       call. = FALSE)
})

folder <- paper_dir <- dirname(.sp)
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))

base <- dataset_root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Could not find the repository root containing __ReadMe.xlsx.", call. = FALSE)
setwd(base)

# ---- species resolver (single source of truth = _keys) ----------------------
ref <- read.csv(file.path(base, "_keys", "species_reference.csv"),
                stringsAsFactors = FALSE)$accepted_name
key_files <- list.files(file.path(base, "_keys"), pattern = "species_key\\.csv$",
                        recursive = TRUE, full.names = TRUE)
km <- list()
for (kf in key_files) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (all(c("variant_name", "accepted_name") %in% names(k))) {
    for (i in seq_len(nrow(k))) {
      v <- tolower(trimws(k$variant_name[i]))
      if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
    }
  }
}
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) {
  c <- clean_sp(x)
  hit <- match(tolower(c), tolower(ref))
  if (!is.na(hit)) return(ref[hit])
  a <- km[[tolower(c)]]
  if (!is.null(a)) return(a)
  c
}

# ---- read frozen digital-native workbook ------------------------------------
source_file <- file.path(folder, "41559_2019_969_MOESM3_ESM.xlsx")
snap <- read_excel(source_file, sheet = "Group Size Data (aggregated)", col_names = TRUE)

# Remove only wholly empty rows/columns introduced by worksheet formatting.
is_blank <- function(x) is.na(x) | trimws(as.character(x)) == ""
keep_rows <- apply(as.data.frame(lapply(snap, is_blank)), 1, function(z) !all(z))
if (length(keep_rows)) snap <- snap[keep_rows, , drop = FALSE]
keep_cols <- vapply(snap, function(x) !all(is_blank(x)), logical(1))
snap <- snap[, keep_cols, drop = FALSE]

df <- cbind(species_sci = vapply(snap$Taxon, resolve, character(1)),
            snap, stringsAsFactors = FALSE)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE,
          fileEncoding = "UTF-8", na = "")
filecodes <- tryCatch(read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"),
                      error = function(e) NULL)
item_encoded <- if (!is.null(filecodes))
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")] else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded))
  item_encoded <- "10.1038%2Fs41559-019-0969-0_GroupSizeDataaggregated"
tsv_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(df, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
              row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8", na = "")
}
cat("DeCasien & Higham 2019 - Group Size Data (aggregated):", nrow(df), "rows written\n")
