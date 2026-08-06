## 1. SOURCE

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

setwd(paste0(base, "/"))
folder_path <- paste0(folder, "/")

## 2. PARSE
## The .txt (see Iwaniuk_etal_1999_References.md: copied from the PDF into TextEdit and
## saved as Plain Text) is not tab-delimited data -- it is the References section as one
## run of prose, with each entry marked "[N] ...", and classic Mac (CR-only) line breaks.
## read_delim() with delim = "\t" never matched that layout (and the bare filename above
## also was not resolved against folder_path, so the file could not be found either way).
## Parse it directly: split on the "[N]" markers into ref_number/citation pairs.
references_file <- paste0(folder_path, "Iwaniuk_etal_1999_References.txt")
output_file     <- paste0(folder_path, "Iwaniuk_etal_1999_References.csv")

raw <- readChar(references_file, file.info(references_file)$size, useBytes = TRUE)
raw <- gsub("\r\n|\r", "\n", raw)                    # normalise CR-only / CRLF to LF
raw <- sub("^\\s*References\\s*", "", raw)           # drop the leading "References" heading

# A running page header/footer ("A.N. Iwaniuk et al. : ...") got embedded mid-text at a
# page break, right before reference [44]; strip it so it doesn't get glued onto [43]'s citation.
raw <- gsub("A\\.N\\. Iwaniuk et al\\.[^\\[]*(?=\\[44\\])", "", raw, perl = TRUE)

# Mark each "[N]" reference start with control characters, then split on them.
marked <- gsub("\\[(\\d{1,3})\\]\\s*", "\x01\\1\x02", raw)
pieces <- strsplit(marked, "\x01", fixed = TRUE)[[1]]
pieces <- pieces[nzchar(trimws(pieces))]

ref_number <- as.integer(sub("^(\\d+)\x02.*$", "\\1", pieces))
citation   <- sub("^\\d+\x02", "", pieces)
citation   <- trimws(gsub("\\s+", " ", citation))

references <- data.frame(ref_number = ref_number, citation = citation, stringsAsFactors = FALSE)
references <- references[order(references$ref_number), ]

## 3. SAVE
write.csv(references, output_file, row.names = FALSE)
message("Wrote ", nrow(references), " reference rows to: ", output_file)

## ---- DOI-coded public TSV (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) -----------
## Added 2026-08-05: the script wrote the analysis CSV but never the public TSV, so the table
## was built but unpublished. Same object, same columns - only the separator differs.
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA_character_
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
} else {
  write.table(references, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
