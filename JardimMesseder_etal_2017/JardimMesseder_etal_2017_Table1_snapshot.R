## JardimMesseder_etal_2017_Table1_snapshot.R: writes ONLY JardimMesseder_etal_2017_Table1_snapshot.csv
## (read by JardimMesseder_etal_2017_Table1.R)
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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)

# Table 1
# Open pdf in Adobe Acrobat
# Export >  Microsoft Excel Workbook > Settings: Create Worksheet for each Table
# Copy and paste all rows containing Table 1

# Read direct from xl
library(readxl)
tabledirectxl <- read_excel("Jardim-Messeder-2017-Dogs Have the Most N_Tables.xlsx", sheet=6)


## 2. FIX FORMATTING AND SAVE SNAPSHOT
# Remove table name header and bottom note
# Set the next row as the new header
colnames(tabledirectxl) <- as.character(unlist(tabledirectxl[1, ]))
# Remove the first row since it's now the header
tabledirectxl <- tabledirectxl[-1, ]
# Remove the last 4 rows which are notes and other things
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-4), ]

# Delete empty columns that contain only NA values and have no header names.
tabledirectxl <- tabledirectxl[, colSums(is.na(tabledirectxl)) != nrow(tabledirectxl), drop = FALSE]

# Save snapshot to a CSV file 
write.csv(tabledirectxl, file = paste0(item_name, "_snapshot.csv"), row.names = FALSE)
