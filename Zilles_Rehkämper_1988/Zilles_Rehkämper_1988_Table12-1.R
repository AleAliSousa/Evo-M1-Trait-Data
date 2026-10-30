# Zilles_Rehkämper_1988_Table12-1.R
#
# Preparation step. Turns the journal-faithful snapshot of Zilles & Rehkämper
# (1988) Table 12-1, "Brain and Body Weights from Literature", into a lean CSV.
# Output comes from the snapshot only. Blank printed cells remain NA.

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr); library(tidyr)
})

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
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- "Zilles_Rehkämper_1988_Table12-1_snapshot.xlsx"
snapshot_sheet <- "Table12-1"
registry_item_name <- "Zilles_Rehkämper_1988_Table12-1"
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, skip = 1, col_types = "text")
names(raw) <- c("Author", "Sex", "Body_weight_g", "Brain_weight_g", "Origin_of_data")

final.dataframe <- raw %>%
  filter(!str_detect(coalesce(Author, ""), "^M = male")) %>%
  fill(Author) %>%
  transmute(
    Species = "Pongo sp.",
    Author = str_squish(Author),
    Sex = na_if(str_squish(Sex), ""),
    Body_weight_g = num(Body_weight_g),
    Brain_weight_g = num(Brain_weight_g),
    Origin_of_data = na_if(str_squish(Origin_of_data), "")
  ) %>%
  filter(!is.na(Body_weight_g) | !is.na(Brain_weight_g))

write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(registry_item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", registry_item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
