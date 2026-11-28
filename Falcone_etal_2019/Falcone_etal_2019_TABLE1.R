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

setwd(paste0(base, "/"))

library(readr)
library(tidyverse)

# TABLE 1
## 1. Read direct from csv
folder_path <- paste0(folder, "/")
tabledirectcsv <- read_csv(paste0(folder_path,"Falcone_etal_2019_TABLE1_snapshot.csv"),
                           skip=1L, col_types=cols(.default=col_character()),
                           na=character(), name_repair="minimal")
tabledirectcsv[is.na(tabledirectcsv)] <- ""
section <- tabledirectcsv$Infraclass %in% c("Metatheria (marsupials)", "Eutheria (Placentals)") &
           apply(as.matrix(tabledirectcsv[-1L]) == "", 1L, all)
infraclass <- ifelse(section, sub(" \\(.*$", "", tabledirectcsv$Infraclass), "")
for (i in seq_along(infraclass)) if (infraclass[i] == "" && i > 1L) infraclass[i] <- infraclass[i-1L]
tabledirectcsv <- tabledirectcsv[!section, , drop=FALSE]
tabledirectcsv$Infraclass <- infraclass[!section]
for (field in c("Order", "Suborder", "Parvorder", "Family")) {
  for (i in seq_len(nrow(tabledirectcsv))) {
    if (tabledirectcsv[[field]][i] == "" && i > 1L &&
        tabledirectcsv$Infraclass[i] == tabledirectcsv$Infraclass[i-1L] &&
        (field == "Order" || tabledirectcsv$Order[i] == tabledirectcsv$Order[i-1L]) &&
        (field != "Family" || tabledirectcsv$Suborder[i] == tabledirectcsv$Suborder[i-1L]))
      tabledirectcsv[[field]][i] <- tabledirectcsv[[field]][i-1L]
  }
}
for (field in names(tabledirectcsv)[7:10])
  tabledirectcsv[[field]][tabledirectcsv[[field]] == "r"] <- "rudimetary"
tabledirectcsv$Parvorder[tabledirectcsv$Parvorder == "Catarhhini"] <- "Catarhini"
tabledirectcsv$Suborder[tabledirectcsv$Suborder == "Whippo-morpha"] <- "Whippomorpha"
tabledirectcsv[tabledirectcsv == ""] <- NA_character_

## 2. Replace "-" with NA in sheet
tabledirectcsv <- tabledirectcsv %>%
  mutate_all(~na_if(., "-"))

## 3. Correction to Order, should not have the "-"
tabledirectcsv$Order[tabledirectcsv$Order == "Didelphi-morphia"] <- "Didelphimorphia"

# Set the scipen option to a high value to turn off scientific notation
options(scipen = 999)

## 8. Save
# Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectcsv

# Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
library(rstudioapi)
item_name <- gsub("\\.R$", "", basename(.sp))

# Get Item encoded
library(readxl) 
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

# Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

# Save dataframe to a TSV file in the online database
tsv_file_path <- paste0(file.path(base, "__Public", "comparative-data"), "/")
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
