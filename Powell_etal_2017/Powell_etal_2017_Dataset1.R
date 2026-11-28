# Load libraries

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

library(readxl)
library(rstudioapi)

#1. Source
#setwd(paste0(base, "/"))
setwd(paste0(base, "/"))

#2. Table 1

## 1. Read direct from xl
folder_path <- paste0(folder, "/")
tabledirectxl <- read_excel(paste0(folder_path,"Powell_etal_2017_Dataset1_snapshot.xlsx"), skip = 1)

## 2. Convert columns to numerical
tabledirectxl$`Terrestriality` <- as.numeric(tabledirectxl$`Terrestriality`)
tabledirectxl$`Sleeping group size` <- as.numeric(tabledirectxl$`Sleeping group size`)
tabledirectxl$`HR range` <- as.numeric(tabledirectxl$`HR range`)
tabledirectxl$`Source Home range size` <- as.numeric(tabledirectxl$`Source Home range size`)

#3. Save

# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension

item_name <- gsub("\\.R$", "", basename(.sp))

# Get Item encoded
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- paste0(file.path(base, "__Public", "comparative-data"), "/")
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)

# Day range - 96 - convert from km to m? But what to do with f and m? 
# the convertion works but got a warning saying - NAs introduced by coercion
### ANSWER -- if NAs introduced by coercion check if any data is lost. It might not be a problem. It could me strings with characters are lost.
