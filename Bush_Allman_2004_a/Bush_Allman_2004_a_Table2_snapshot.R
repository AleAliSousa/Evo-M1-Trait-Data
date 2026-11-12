## Bush_Allman_2004_a_Table2_snapshot.R -- writes the snapshot of Table 2 from the downloaded PNAS HTML (05760table2.html).

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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = file name minus _snapshot (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

options(scipen = 999)
library(rvest)

## 1. SNAPSHOT (faithful) - parse the published HTML table verbatim
tab <- html_table(read_html("05760table2.html"))[[1]]
colnames(tab) <- c("species","FrG","RoG","FrRat","WhBr","NeoG","NeoW","Act","Diet","Gr","Grsz")
tab <- tab[-1, ]                                   # drop the repeated header row
write.csv(tab, paste0(item_name, "_snapshot.csv"), row.names = FALSE)
