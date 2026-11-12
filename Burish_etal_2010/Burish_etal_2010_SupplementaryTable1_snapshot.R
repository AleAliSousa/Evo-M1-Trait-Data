## Burish_etal_2010_SupplementaryTable1_snapshot.R -- writes ONLY Burish_etal_2010_SupplementaryTable1_snapshot.csv (PDF extraction); the item script reads it.
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

paper_dir <- here::here("Burish_etal_2010")
dataset_root  <- dirname(paper_dir)
table_name    <- "Burish_etal_2010_SupplementaryTable1"
snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
# --- YOU SET THIS MANUALLY ---
# Original source (the old script fetched this URL directly):
#   https://ndownloader.figstatic.com/files/8705821
pdf_file <- file.path(paper_dir, "000319019_sm_Table.pdf")
## 1. PACKAGES ---------------------------------------------------------------
# Migrated from the retired 'tabulizer' package to 'tabulapdf' (its maintained
# successor). Both wrap the same tabula-java engine.
library(rJava)
library(tabulapdf)
library(dplyr)
library(readxl)
## 2. EXTRACT (4 pages) ------------------------------------------------------
# The dataset spans pages 1-4 (one auto-detected table per page; the header is
# only on page 1). Let tabula guess each page's table, then stack them.
tables1 <- extract_tables(pdf_file, pages = c(1:4), guess = TRUE, output = "matrix")
combined <- as.data.frame(do.call(rbind, tables1), stringsAsFactors = FALSE)
# Drop the two stacked header rows (top of page 1) and assign names directly.
combined <- combined[-c(1, 2), , drop = FALSE]
colnames(combined) <- c(
  "Species", "Case", "cord mass (g)", "body mass (g)", "# cells",
  "% neurons", "# neurons", "# non-neurons", "length (mm)", "sex", "age (years)"
)
row.names(combined) <- NULL
## 3. FOLD WRAPPED ROWS + SAVE SNAPSHOT --------------------------------------
# Two kinds of cell wrap onto a separate line and must be folded into the next
# row (this replaces the old hard-coded, row-number-specific fixes):
#   (a) a Case prefix "07-" sitting alone above its number  -> "07-" + number
#   (b) a Species name's first word sitting alone above the rest of its row
is_blank <- function(x) is.na(x) | trimws(x) == ""
res <- vector("list", 0)
i <- 1
n <- nrow(combined)
while (i <= n) {
  sp   <- trimws(combined$Species[i])
  case <- trimws(combined$Case[i])
  data_empty <- all(is_blank(unlist(combined[i, 3:11], use.names = FALSE)))
  if (i < n && case == "07-" && sp == "") {
    nxt <- combined[i + 1, ]
    nxt$Case <- paste0("07-", trimws(nxt$Case))
    res[[length(res) + 1]] <- nxt
    i <- i + 2
  } else if (i < n && sp != "" && case == "" && data_empty) {
    nxt <- combined[i + 1, ]
    nxt$Species <- trimws(paste(sp, nxt$Species))
    res[[length(res) + 1]] <- nxt
    i <- i + 2
  } else {
    res[[length(res) + 1]] <- combined[i, ]
    i <- i + 1
  }
}
combined_df <- do.call(rbind, res)
row.names(combined_df) <- NULL
write.csv(combined_df, snapshot_csv, row.names = FALSE)
