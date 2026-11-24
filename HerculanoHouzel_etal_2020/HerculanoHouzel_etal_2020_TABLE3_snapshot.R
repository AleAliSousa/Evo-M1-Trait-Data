## HerculanoHouzel_etal_2020_TABLE3_snapshot.R: extracts the snapshot from the PDF; writes only HerculanoHouzel_etal_2020_TABLE3_snapshot.csv.
## 0. PATHS (NO setwd) -------------------------------------------------------

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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
# --- YOU SET THIS MANUALLY ---
pdf_file <- file.path(paper_dir, "Herculano-Houze-2020-Microchiropterans have a.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# 'tabulapdf' (the maintained successor of 'tabulizer'), as for TABLE1 and TABLE2.
library(rJava)
library(tabulapdf)
## 2. EXTRACT TABLE 3 --------------------------------------------------------
# Table 3 is at the top of page 5 (journal p. 2982). Target the 13 data rows
# (caption + header excluded) with fixed column separators (PDF points from
# top-left): area = c(top, left, bottom, right); columns = x of the 8
# separators between the 9 columns. No value is typed in this script.
tables1 <- extract_tables(
  pdf_file,
  pages   = 5,
  guess   = FALSE,
  area    = list(c(91, 48, 275, 548)),
  columns = list(c(145, 200, 272, 320, 366, 413, 459, 506)),
  output  = "matrix"
)
df1 <- as.data.frame(tables1[[1]], stringsAsFactors = FALSE)
if (nrow(df1) != 13L || ncol(df1) != 9L)
  stop("Table 3: expected 13 rows x 9 columns from the PDF, got ", nrow(df1), " x ", ncol(df1),
       ". Check the page, area and column separators.", call. = FALSE)
# Column headers exactly as printed (subscripts written on the line: M_CX/M_BR -> MCX/MBR).
colnames(df1) <- c(
  "Species", "Micro/mega", "Family",
  "MCX/MBR", "NCX/NBR", "MCB/MBR", "NCB/NBR", "MCX/MCB", "NCB/NCX"
)
## 3. SAVE SNAPSHOT ----------------------------------------------------------
# A frozen snapshot that differs from this extraction is not overwritten.
if (file.exists(snapshot_csv)) {
  frozen <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE)
  if (!identical(dim(frozen), dim(df1)) || !identical(colnames(frozen), colnames(df1)) ||
      !all(as.matrix(frozen) == as.matrix(df1)))
    stop("The frozen ", basename(snapshot_csv), " differs from this extraction; not overwritten. ",
         "Compare both with the PDF before replacing the snapshot.", call. = FALSE)
}
write.csv(df1, snapshot_csv, row.names = FALSE)
