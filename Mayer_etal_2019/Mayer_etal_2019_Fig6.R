# Rebuild only values transcribed from the article PDF Results text.
# 2026-11-09: made self-locating (the run_all sweep runs from the repo root) and given the house
# public-TSV step; the transcription file, the checks and the CSV output are unchanged.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir  <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
source <- read.csv(file.path(item_dir, "Mayer_etal_2019_Fig6_pdf_transcription.csv"), stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(source) == 3L, identical(source$case_number, c("15-01", "15-03", "15-04")))
write.csv(source, file.path(item_dir, "Mayer_etal_2019_Fig6.csv"), row.names = FALSE, na = "")

## Public TSV (added 2026-11-09): Item encoded looked up from __ReadMe.xlsx by Item name.
if (is.na(root)) {
  warning("No __ReadMe.xlsx above ", item_dir, " -- public TSV NOT written.", call. = FALSE)
} else {
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- public TSV NOT written.", call. = FALSE)
  } else {
    utils::write.table(source, file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                       sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
    message("Wrote public TSV: ", item_encoded, ".tsv")
  }
}
