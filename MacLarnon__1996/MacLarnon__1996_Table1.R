## Install and load necessary libraries

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
#1. Source
setwd(folder)

library(dplyr) 
library(readxl)
library(rstudioapi)
library(tidyr)
library(stringr)

#2. Table 1
## Read direct from xl
folder_path <- paste0(folder, "/") #Note there are two underscores in the file name -- this is because there is a single author.  See __ReadMe.xlsx
tabledirectxl <- read_excel(paste0(folder_path,"MacLarnon__1996_Table1_snapshot.xlsx"))



## Create a new "Order" column 
Order_column <- rep(NA, nrow(tabledirectxl))
tabledirectxl <- cbind(Order = Order_column, tabledirectxl)

## Remove the rows with order names
rows_to_delete <- c(1, 23, 29, 36, 41, 50)
tabledirectxl <- tabledirectxl %>%
  slice(-rows_to_delete)

## Add order names
tabledirectxl$Order[1:21] <- "Primate"
tabledirectxl$Order[22:26] <- "Cetacean"
tabledirectxl$Order[27:32] <- "Rodent"
tabledirectxl$Order[33:36] <- "Lagomorph"
tabledirectxl$Order[37:44] <- "Bird"
tabledirectxl$Order[45] <- "Amphibian"

## Create a new "Subspecies size" column
tabledirectxl <- tabledirectxl %>%
  mutate(`Subspecies size` = NA) %>%
  relocate(`Subspecies size`, .after = `Species`)

## Adding Subspecies Size
tabledirectxl$`Subspecies size`[28:29] <- "Small"
tabledirectxl$`Subspecies size`[30:31] <- "Large"
tabledirectxl$`Subspecies size`[33:34] <- "Small"
tabledirectxl$`Subspecies size`[35:36] <- "Large"

## Removing Subspecies size from Species column 
tabledirectxl[which(tabledirectxl$Species == "Rattus  norvegicus  (small subspecies)"), "Species"] <- "Rattus  norvegicus"
tabledirectxl[which(tabledirectxl$Species == "Rattus  norvegicus  (large subspecies)"), "Species"] <- "Rattus  norvegicus"
tabledirectxl[which(tabledirectxl$Species == "Oryctolagus  cuniculus  (small subspecies)"), "Species"] <- "Oryctolagus  cuniculus"
tabledirectxl[which(tabledirectxl$Species == "Oryctolagus  cuniculus  (large subspecies)"), "Species"] <- "Oryctolagus  cuniculus"

## Delete last row and Ref's column as references will be added directly in the table
tabledirectxl <- tabledirectxl[1:(nrow(tabledirectxl)-1), ]
tabledirectxl <- tabledirectxl %>%
  select(-Refs)

## Dividing Spinal cord length (mm) (Dissection//ΣDCL) into Dissections and ΣDCL

## Preprocess to ensure there are values to split, replace missing with NA
tabledirectxl <- tabledirectxl %>%
  mutate(`Spinal cord length (mm) (Dissection//ΣDCL)` = ifelse(is.na(`Spinal cord length (mm) (Dissection//ΣDCL)`) | 
  `Spinal cord length (mm) (Dissection//ΣDCL)` == "", "NA//NA", `Spinal cord length (mm) (Dissection//ΣDCL)`))
## Identify and inspect rows with unexpected number of pieces
irregular_rows <- tabledirectxl %>%
  filter(str_count(`Spinal cord length (mm) (Dissection//ΣDCL)`, "/") != 1)
print(irregular_rows)
## Separate the "Spinal cord length (mm) (Dissection//ΣDCL)" column
tabledirectxl <- tabledirectxl %>%
  separate(`Spinal cord length (mm) (Dissection//ΣDCL)`, 
           into = c("Spinal cord length (mm): Dissection", "Spinal cord length (mm): ΣDCL"), sep = "/", fill = "right")

## Remove all the — to change to auto NA
tabledirectxl <- tabledirectxl %>%
  mutate(across(everything(),~ ifelse(. %in%c("—"),NA, .)))

## Add Data Source columns
tabledirectxl <- tabledirectxl %>%
  mutate(`Body weight (g): Data Source` = NA) %>%
  relocate(`Body weight (g): Data Source`, .after = `Body weight (g)`)

tabledirectxl <- tabledirectxl %>%
  mutate(`Brain weight (mg): Data Source` = NA) %>%
  relocate(`Brain weight (mg): Data Source`, .after = `Brain weight (mg)`)

tabledirectxl <- tabledirectxl %>%
  mutate(`Spinal cord weight (mg): Data Source` = NA) %>%
  relocate(`Spinal cord weight (mg): Data Source`, .after = `Spinal cord weight (mg)`)

tabledirectxl <- tabledirectxl %>%
  mutate(`Spinal cord length (mm): Dissection: Data Source` = NA) %>%
  relocate(`Spinal cord length (mm): Dissection: Data Source`, .after = `Spinal cord length (mm): Dissection`)

tabledirectxl <- tabledirectxl %>%
  mutate(`Spinal cord length (mm): ΣDCL: Data Source` = NA) %>%
  relocate(`Spinal cord length (mm): ΣDCL: Data Source`, .after = `Spinal cord length (mm): ΣDCL`)

## Add Data Source and References 
tabledirectxl$`Body weight (g): Data Source`[c(1, 3, 4, 7, 12, 14:21)] <- "Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Body weight (g): Data Source`[c(5, 6, 8, 9, 10, 13)] <- "Present study (Formol–saline subset)"
tabledirectxl$`Body weight (g): Data Source`[11] <- "Hopf & Claussen  (1971)"
tabledirectxl$`Body weight (g): Data Source`[c(27:29, 37:45)] <- "Krompecher & Lipák  (1966)"
tabledirectxl$`Body weight (g): Data Source`[22:26] <- "Ridgway et al. (1966)"
tabledirectxl$`Body weight (g): Data Source`[30:31] <- "Donaldson & Hatai (1911)"
tabledirectxl$`Body weight (g): Data Source`[32] <- "Latimer (1950)"
tabledirectxl$`Body weight (g): Data Source`[33:34] <- "Latimer & Sawin (1955)"
tabledirectxl$`Body weight (g): Data Source`[35:36] <- "Latimer & Sawin (1957)"
tabledirectxl$`Body weight (g): Data Source`[2] <- "Nayak (1933)"

tabledirectxl$`Brain weight (mg): Data Source`[c(3:5, 7:9, 13:19, 21)] <- "Martin & MacLarnon (unpublished data collection)"
tabledirectxl$`Brain weight (mg): Data Source`[c(6, 10, 20)] <- "Present study (Formol–saline subset)"
tabledirectxl$`Brain weight (mg): Data Source`[11:12] <- "Hopf & Claussen  (1971)"
tabledirectxl$`Brain weight (mg): Data Source`[c(27:29, 37:45)] <- "Krompecher & Lipák  (1966)"
tabledirectxl$`Brain weight (mg): Data Source`[22:26] <- "Ridgway et al. (1966)"
tabledirectxl$`Brain weight (mg): Data Source`[30:31] <- "Donaldson & Hatai (1911)"
tabledirectxl$`Brain weight (mg): Data Source`[32] <- "Latimer (1950)"
tabledirectxl$`Brain weight (mg): Data Source`[33:34] <- "Latimer & Sawin (1955)"
tabledirectxl$`Brain weight (mg): Data Source`[35:36] <- "Latimer & Sawin (1957)"

tabledirectxl$`Spinal cord weight (mg): Data Source`[c(3, 5:10, 13, 20)] <- "Present study (Formol–saline subset)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[c(4, 14, 15)] <- "Present study (Non-Formol–saline subset)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[c(11, 12, 16:19)] <- "Hopf & Claussen  (1971)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[c(27:29, 37:45)] <- "Krompecher & Lipák  (1966)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[22:26] <- "Ridgway et al. (1966)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[30:31] <- "Donaldson & Hatai (1911)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[32] <- "Latimer (1950)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[33:34] <- "Latimer & Sawin (1955)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[35:36] <- "Latimer & Sawin (1957)"
tabledirectxl$`Spinal cord weight (mg): Data Source`[21] <- "Present study (Non-Formol–saline subset); Krompecher & Lipák (1966); Ravenel (1877)"

tabledirectxl$`Spinal cord length (mm): Dissection: Data Source`[c(3, 5:9, 13, 20)] <- "Present study (Formol–saline subset)"
tabledirectxl$`Spinal cord length (mm): Dissection: Data Source`[c(4, 14, 15)] <- "Present study (Non-Formol–saline subset)"
tabledirectxl$`Spinal cord length (mm): Dissection: Data Source`[32] <- "Latimer (1950)"
tabledirectxl$`Spinal cord length (mm): Dissection: Data Source`[21] <- "Present study (Non-Formol–saline subset); Krompecher & Lipák (1966); Ravenel (1877)"

tabledirectxl$`Spinal cord length (mm): ΣDCL: Data Source`[c(3, 5:10, 13, 20)] <- "Present study (Formol–saline subset)"
tabledirectxl$`Spinal cord length (mm): ΣDCL: Data Source`[c(4, 14, 15)] <- "Present study (Non-Formol–saline subset)"
tabledirectxl$`Spinal cord length (mm): ΣDCL: Data Source`[32] <- "Latimer (1950)"
tabledirectxl$`Spinal cord length (mm): ΣDCL: Data Source`[1:2] <- "Nayak (1933)"
tabledirectxl$`Spinal cord length (mm): ΣDCL: Data Source`[21] <- "Present study (Non-Formol–saline subset); Krompecher & Lipák (1966); Ravenel (1877)"

## Seperate Male and Female Column for Spinal cord length (mm): Dissection
## Duplicate row 21 insert it after row 21 
tabledirectxl <- tabledirectxl %>%
  add_row(.after = 21, !!!tabledirectxl[21, ])

## Create a new "Spinal cord length (mm): Dissection: Sex (specified)" column
tabledirectxl <- tabledirectxl %>%
  mutate(`Spinal cord length (mm): Dissection: Sex (specified)` = NA) %>%
  relocate(`Spinal cord length (mm): Dissection: Sex (specified)`, .after = `Brain weight (mg): Data Source`)

## Adding the Sex and removing it from Spinal cord length (mm): Dissection column
tabledirectxl$`Spinal cord length (mm): Dissection: Sex (specified)`[21] <- "M"
tabledirectxl$`Spinal cord length (mm): Dissection: Sex (specified)`[22] <- "F"
tabledirectxl$`Spinal cord length (mm): Dissection: Sex (specified)`[33] <- "M"
tabledirectxl$`Spinal cord length (mm): Dissection`[21] <- "448"
tabledirectxl$`Spinal cord length (mm): Dissection`[22] <- "413"
tabledirectxl$`Spinal cord length (mm): Dissection`[33] <- "162.98"

## Remove asterisks from all columns
tabledirectxl$"Body weight (g)" <- gsub("\\*", "", tabledirectxl$"Body weight (g)")
tabledirectxl$"Brain weight (mg)" <- gsub("\\*", "", tabledirectxl$"Brain weight (mg)")

## Remove space(a character) from in between numbers
tabledirectxl$"Body weight (g)" <- gsub(" ", "", tabledirectxl$"Body weight (g)")
tabledirectxl$"Brain weight (mg)" <- gsub(" ", "", tabledirectxl$"Brain weight (mg)")
tabledirectxl$"Spinal cord weight (mg)" <- gsub(" ", "", tabledirectxl$"Spinal cord weight (mg)")
tabledirectxl$"Spinal cord length (mm): Dissection" <- gsub(" ", "", tabledirectxl$"Spinal cord length (mm): Dissection")
tabledirectxl$"Spinal cord length (mm): ΣDCL" <- gsub(" ", "", tabledirectxl$"Spinal cord length (mm): ΣDCL")

## Remove ·(a character) from in between numbers
tabledirectxl$"Body weight (g)" <- gsub("·", ".", tabledirectxl$"Body weight (g)")
tabledirectxl$"Brain weight (mg)" <- gsub("·", ".", tabledirectxl$"Brain weight (mg)")
tabledirectxl$"Spinal cord weight (mg)" <- gsub("·", ".", tabledirectxl$"Spinal cord weight (mg)")
tabledirectxl$"Spinal cord length (mm): Dissection" <- gsub("·", ".", tabledirectxl$"Spinal cord length (mm): Dissection")
tabledirectxl$"Spinal cord length (mm): ΣDCL" <- gsub("·", ".", tabledirectxl$"Spinal cord length (mm): ΣDCL")

## Convert columns from chr to numerical
tabledirectxl$`Body weight (g)`<- as.numeric(tabledirectxl$`Body weight (g)`)
tabledirectxl$`Brain weight (mg)` <- as.numeric(tabledirectxl$`Brain weight (mg)`)
tabledirectxl$`Spinal cord weight (mg)` <- as.numeric(tabledirectxl$`Spinal cord weight (mg)`)
tabledirectxl$`Spinal cord length (mm): Dissection` <- as.numeric(tabledirectxl$`Spinal cord length (mm): Dissection`)
tabledirectxl$`Spinal cord length (mm): ΣDCL` <- as.numeric(tabledirectxl$`Spinal cord length (mm): ΣDCL`)

## ---- Source check of the rabbit rows (added 2026-11-06; no change to the data) ----
## "Oryctolagus cuniculus (small subspecies)" cites Latimer & Sawin (1955) J Comp Neurol 103:513-539
## (PDF in ../Latimer_Sawin_1955/). All six values match that paper's NORMAL (non-dwarf) race X groups,
## gross body weight, read on the page images:
##   males,   n = 35: body 1972.3 g (Table 1, panel B), spinal cord 3.945 g (Table 7), brain 9.265 g (Table 4)
##   females, n = 30: body 2480.0 g (Table 1, panel C), spinal cord 4.537 g (Table 7), brain 9.755 g (Table 5)
## Mink et al. (1981) Table 1 pairs the female body and brain weights with the male cord weight; that is
## recorded on the Mink item (erratum Mink_etal_1981-E005), not here. The guard stops the build if these
## rows ever change.
r_rab55 <- which(tabledirectxl$Species == "Oryctolagus  cuniculus" & tabledirectxl$`Subspecies size` %in% "Small")
stopifnot(length(r_rab55) == 2L,
          identical(tabledirectxl$Sex[r_rab55], c("M", "F")),
          isTRUE(all.equal(tabledirectxl$`Body weight (g)`[r_rab55], c(1972, 2480))),
          isTRUE(all.equal(tabledirectxl$`Spinal cord weight (mg)`[r_rab55], c(3945, 4537))),
          isTRUE(all.equal(tabledirectxl$`Brain weight (mg)`[r_rab55], c(9265, 9755))))

#3. Save

## Finalize dataframe (UPDATE!!!)
final.dataframe <- tabledirectxl

## Get Item name: Get Path of the current script, Extract the file name, Remove the ".R" extension
item_name <- gsub("\\.R$", "", basename(.sp))

## Get Item encoded
filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

## Save dataframe to a CSV file
write.csv(final.dataframe, file = paste0(folder_path, item_name, ".csv"), row.names = FALSE)

## Save dataframe to a TSV file in the online database
tsv_file_path <- paste0(file.path(base, "__Public", "comparative-data"), "/")
write.table(final.dataframe, file = paste0(tsv_file_path, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)