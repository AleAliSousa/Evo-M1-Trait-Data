## Kverkova_etal_2018_TableS5_snapshot.R -- extracts the frozen snapshot Kverkova_etal_2018_TableS5_snapshot.csv from the publisher's supplement (docx).
## Split from Kverkova_etal_2018_TableS5.R (one script per output): this script writes ONLY the snapshot; Kverkova_etal_2018_TableS5.R reads it.
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
item_name <- sub("_snapshot$", "", item_name)   # = Kverkova_etal_2018_TableS5

# Read directly from online docx file
# Load docxtractr
library(docxtractr)
# Define the PDF file path
# The publisher's supplement is already in this folder as the untouched download; read that and
# fall back to the URL only if it is missing, so the build no longer needs the network (2026-10-31).
docx_url   <- "https://static-content.springer.com/esm/art%3A10.1038%2Fs41598-018-26062-8/MediaObjects/41598_2018_26062_MOESM1_ESM.docx"
docx_local <- file.path(folder, "41598_2018_26062_MOESM1_ESM.docx")
docx <- read_docx(if (file.exists(docx_local)) docx_local else docx_url)
# Use docx_extract_all_tbls
tables5 <- docx_extract_all_tbls(docx,guess_header=TRUE,preserve=FALSE,trim=TRUE)

# Replace any "." with "" in the column names
colnames(tables5[[5]]) <- gsub("\\.", " ", colnames(tables5[[5]]))
# Replace any "106" with ", x 10ˆ6" in the column names with a single space before "x"
colnames(tables5[[5]]) <- gsub("\\s*106", ", x 10ˆ6", colnames(tables5[[5]]))

# Replace any "±" "± " or " ±" without both a space before/after to " ± " with spaces both before and after in data of tables1[[1]]
tables5[[5]] <- apply(tables5[[5]], 2, function(x) gsub("(?<![[:space:]])±( |%)|(?<![[:space:]])± | ±(?![[:space:]])", " ± ", x, perl=TRUE))

# Save the data frame to a "primary or equivalent" to a CSV file
write.csv(tables5[[5]], file = paste0(item_name, "_snapshot.csv"), row.names = FALSE)

