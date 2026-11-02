## Mackes et al. 2020 - ERABIS cortical parcel group summaries
## Complete author-provided workbook snapshot -> analysis-ready public table.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source.", call. = FALSE)
})
folder <- dirname(.sp)
setwd(folder)
options(scipen = 999, stringsAsFactors = FALSE)
suppressMessages(library(readxl))

snapshot <- "Mackes_etal_2020_ERABIS_snapshot.xlsx"
expected_sheets <- c("UK adoptees", "Romanian adoptees")
actual_sheets <- excel_sheets(snapshot)
if (!all(expected_sheets %in% actual_sheets)) {
  stop("ERABIS snapshot must contain sheets: ", paste(expected_sheets, collapse = ", "), call. = FALSE)
}

clean <- function(x) {
  x <- as.character(x)
  x <- gsub("[\u00a0\u2007\u202f]", " ", x)
  trimws(x)
}
num <- function(x) suppressWarnings(as.numeric(clean(x)))
parse_sheet <- function(sheet, group) {
  dat <- suppressMessages(read_excel(snapshot, sheet = sheet, skip = 2,
                                     col_names = FALSE, .name_repair = "minimal"))
  label <- clean(dat[[1]])
  keep <- !is.na(label) & nzchar(label)
  dat <- dat[keep, , drop = FALSE]
  label <- label[keep]
  region_raw <- sub("_volume$", "", label)
  hemisphere <- ifelse(grepl("^lh_", region_raw), "L",
                        ifelse(grepl("^rh_", region_raw), "R", NA_character_))
  structure <- sub("^(lh_|rh_)", "", region_raw)
  out <- data.frame(
    Group = group,
    Region_raw = region_raw,
    Structure = structure,
    Hemisphere = hemisphere,
    n = as.integer(round(num(dat[[3]]))),
    mean.mm3 = round(num(dat[[4]]), 3),
    sd.mm3 = round(num(dat[[5]]), 3),
    se.mm3 = round(num(dat[[14]]), 3),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  if (nrow(out) != 70L) stop("Expected 70 ERABIS rows in sheet '", sheet, "'.", call. = FALSE)
  out
}

final <- rbind(parse_sheet("UK adoptees", "UK"),
               parse_sheet("Romanian adoptees", "Romanian"))
stopifnot(nrow(final) == 140L,
          identical(sort(unique(final$n)), c(21L, 67L)))
write.csv(final, "Mackes_etal_2020_ERABIS.csv", row.names = FALSE, na = "NA")

root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (!is.na(root)) {
  tsv <- file.path(root, "__Public", "comparative-data",
                   "10.1073%2Fpnas.1911264116_ERABIS(cortical).tsv")
  write.table(final, tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "NA", eol = "\n")
}
cat("Wrote", nrow(final), "cortical parcel summary rows.\n")
