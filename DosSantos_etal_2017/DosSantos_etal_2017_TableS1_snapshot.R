# Original file:
# Dos Santos, S. E., Porfirio, J., da Cunha, F. B., Manger, P. R., Tavares, W., Pessoa, L., Raghanti, M. A., Sherwood, C. C., & Herculano-Houzel, S. (2017). Cellular Scaling Rules for the Brains of Marsupials: Not as "Primitive" as Expected. Brain Behav Evol. https://doi.org/10.1159/000452856 	
# Supplementary Material online
# 1. "Downloaded" from link (figshare via online article):
# https://ndownloader.figstatic.com/files/7428211
# 2. Open 452856_sm10.doc in MS Word (double click it)
# 3. Save as Plain Text (.txt)

## 1. READ FILE
# Set Working Directory. Store with the spreadsheet.

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
item_name <- table_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)

#Load readr
library(readr)
# Read the text version 
sheetfromtxt <- read_delim("452856_sm10.txt", 
                            delim = "\t", escape_double = FALSE, 
                            trim_ws = TRUE, skip = 1)

## 2. FIX FORMATTING ERROR TO ALIGN CELLS AND SAVE SNAPSHOT
# Delete 2 empty columns by column names #left one name since there will be shifting and hard to work with nameless column
sheetfromtxt <- sheetfromtxt[, !colnames(sheetfromtxt) %in% c("?", "...15")]
# Align column headers / Remove unwanted extra column header. Takes names from columns 1-7, adds next to them names from columns 9-last. Assigns new names to original df
names(sheetfromtxt) = c(names(sheetfromtxt)[1:7],  names(sheetfromtxt)[9:length(names(sheetfromtxt))])
# Delete empty columns that contain only NA values and have no header names.
sheetfromtxt <- sheetfromtxt[, colSums(is.na(sheetfromtxt)) != nrow(sheetfromtxt), drop = FALSE]
# rename column names
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...1"] ="_"
colnames(sheetfromtxt)[colnames(sheetfromtxt) == "...13"] ="Δ"
# rename string in column names
colnames(sheetfromtxt) = gsub("\\b..\\b", ". ", colnames(sheetfromtxt))
# Save it as snapshot
write.csv(sheetfromtxt, file = paste0(item_name, "_snapshot.csv"), row.names = FALSE)
