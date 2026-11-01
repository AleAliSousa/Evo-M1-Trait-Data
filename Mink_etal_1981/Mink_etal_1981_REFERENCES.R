# Mink_etal_1981_REFERENCES.R -------------------------------------------------
#
# The printed REFERENCES list of Mink, Blumenschine & Adams (1981), Am J Physiol
# 241: R211-R212 (PDF pages 10-11): 92 numbered entries, in printed order.
#
# This is the lookup layer that makes TABLE 1's per-cell citations resolvable:
# every parenthesised number in TABLE 1 ("0.097 (20)") is a reference number in
# this list. reference_tables/Mink_etal_1981_TABLE1_references.csv is built from
# this item by Mink_etal_1981_TABLE1.R.
#
# Reads the frozen snapshot; no citation text is typed in this script.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base <- item_name

snap <- read.csv(paste0(base, "_snapshot.csv"), check.names = FALSE,
                 stringsAsFactors = FALSE, encoding = "UTF-8")

## ---- guards on the frozen source -------------------------------------------
stopifnot(identical(names(snap), c("ref_number", "reference_as_printed")))
stopifnot(nrow(snap) == 92L)
stopifnot(identical(as.integer(snap$ref_number), 1:92))   # one row per printed number, in order
stopifnot(all(nzchar(trimws(snap$reference_as_printed))))

## ---- analysis view ---------------------------------------------------------
## Verbatim citation kept; the only derived field is the publication year, taken
## as the LAST 4-digit year in the entry (the printed entries end on the year,
## except the book entries where it is still the final year printed).
final_year <- function(x) {
  m <- regmatches(x, gregexpr("\\b(1[6-9][0-9]{2}|20[0-2][0-9])\\b", x))
  vapply(m, function(y) if (length(y)) as.integer(y[length(y)]) else NA_integer_, integer(1))
}

final.dataframe <- data.frame(
  ref_number = as.integer(snap$ref_number),
  citation   = snap$reference_as_printed,
  year       = final_year(snap$reference_as_printed),
  stringsAsFactors = FALSE
)

stopifnot(!anyNA(final.dataframe$year))
stopifnot(!anyDuplicated(final.dataframe$ref_number))

write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " numbered references written (",
        min(final.dataframe$year), "-", max(final.dataframe$year), ")")

## ---- public TSV ------------------------------------------------------------
## `Item encoded` is read from __ReadMe.xlsx BY ITEM NAME -- the registry is the
## authority for the filename. _tools/file_list.R only INDEXES existing TSVs.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
      !grepl("_$", item_encoded)) {
    tsv_dir <- file.path(root, "__Public", "comparative-data")
    dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
    write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "",
                fileEncoding = "UTF-8")
    message(item_name, ": public TSV ", item_encoded, ".tsv")
  } else {
    warning(item_name, ": no usable 'Item encoded' in __ReadMe.xlsx. Public TSV not written.")
  }
}
