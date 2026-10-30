# Stephan_etal_1970_Table2.R
# Preparation step for ONE printed table of Stephan, Bauchot & Andy (1970),
# "Data on Size of the Brain and of Various Brain Parts in Insectivores and Primates"
# (The Primate Brain, Advances in Primatology vol. 1, pp. 289-297; DeCasien ref 51).
#
# Table 2. Body weight, brain weight, total brain net volume and fundamental brain parts (mm3) in prosimians
# Taxon group: Prosimian. All volumes in mm3; body weight in g; brain weight in mg.
#
# One snapshot per printed table (project convention; matches HerculanoHouzel_etal_2015).
# The taxon each source table was captioned by is carried in the `group` column.
#
# Input : Stephan_etal_1970_Table2_snapshot.csv
# Output: Stephan_etal_1970_Table2.csv  +  ISBN-encoded TSV in __Public/comparative-data/
suppressPackageStartupMessages(library(tidyverse))

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- read_csv(file.path(folder, "Stephan_etal_1970_Table2_snapshot.csv"), show_col_types = FALSE)

# Keep species + this table's structure columns; carry `group` as a taxon label.
clean <- snap %>%
  transmute(species, group,
            body_weight_g, brain_weight_mg, total_brain_net_mm3, medulla_oblongata_mm3, cerebellum_mm3, mesencephalon_mm3, diencephalon_mm3, telencephalon_mm3,
            source = "Stephan_etal_1970_Table2")

write_csv(clean, file.path(folder, paste0(item_name, ".csv")))
message("Wrote ", item_name, ".csv  (", nrow(clean), " rows x ", ncol(clean), " cols)")

## public TSV for the volume merge (ISBN-encoded; matches __ReadMe.xlsx + volumes_compiled.R)
item_encoded <- "ISBN%3A0390672505_TABLE2"
if (!is.na(base)) {
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  dir.create(tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(clean, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else warning("Project root not found; shared TSV skipped (local CSV still written).")
