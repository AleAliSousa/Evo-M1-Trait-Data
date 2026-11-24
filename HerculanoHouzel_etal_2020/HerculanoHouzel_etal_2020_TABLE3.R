## HerculanoHouzel_etal_2020_TABLE3.R: frozen snapshot -> data-readable CSV (+ public TSV once the item is registered).
## Reads only HerculanoHouzel_etal_2020_TABLE3_snapshot.csv (written by HerculanoHouzel_etal_2020_TABLE3_snapshot.R).
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
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_csv  <- file.path(paper_dir, paste0(table_name, "_snapshot.csv"))
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(tidyverse)
library(readxl)
## 2. READ SNAPSHOT (written by HerculanoHouzel_etal_2020_TABLE3_snapshot.R; never regenerated here) ----
df1 <- read.csv(snapshot_csv, colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE)
## 3. TABLE CHECKS (build HOWTO 7a) ------------------------------------------
# The table can check itself in two places: each printed ratio is the quotient of two of its own
# percentage columns.
#   MCX/MCB = (MCX/MBR) / (MCB/MBR)        NCB/NCX = (NCB/NBR) / (NCX/NBR)
# Tolerance = what rounding of the printed cells can explain: half a unit of the last printed
# decimal on each percentage (0.05), carried through the quotient, plus half a unit on the printed
# ratio (0.005). Nothing is changed to make a check pass; a mismatch is warned and kept as printed.
pct <- function(x) as.numeric(x)
ratio_check <- function(id, top, bottom, ratio) {
  a <- pct(df1[[top]]); b <- pct(df1[[bottom]]); printed <- pct(df1[[ratio]])
  observed  <- a / b
  tolerance <- observed * (0.05 / a + 0.05 / b) + 0.005
  data.frame(
    check_id   = paste0(id, "_", gsub(" ", "_", df1$Species)),
    basis      = paste0("'", ratio, "' vs '", top, "' / '", bottom, "', row ", df1$Species),
    observed   = round(observed, 4), printed = printed,
    difference = round(observed - printed, 4), tolerance = round(tolerance, 4),
    status     = ifelse(abs(observed - printed) <= tolerance, "pass", "mismatch"),
    note       = "quotient of two printed percentages; tolerance = rounding of the three printed cells",
    stringsAsFactors = FALSE)
}
table_checks <- rbind(
  ratio_check("mass_ratio_CX_CB",   "MCX/MBR", "MCB/MBR", "MCX/MCB"),
  ratio_check("neuron_ratio_CB_CX", "NCB/NBR", "NCX/NBR", "NCB/NCX"))
if (any(table_checks$status != "pass"))
  warning("Table 3: ", sum(table_checks$status != "pass"), " ratio check(s) outside rounding -- kept as printed.", call. = FALSE)
## 4. MAKE DATA READABLE -----------------------------------------------------
# Percentages and ratios stay as printed (no unit conversion applies); text -> numeric.
num_cols <- c("MCX/MBR", "NCX/NBR", "MCB/MBR", "NCB/NBR", "MCX/MCB", "NCB/NCX")
result_df <- df1 %>%
  mutate(across(all_of(num_cols), ~ as.numeric(gsub(",", "", .x)))) %>%
  # correct species-name typo (see paper text), as in TABLE1 and TABLE2
  mutate(Species = if_else(Species == "Hypsignathus mostrosus",
                           "Hypsignathus monstrosus", Species))
options(scipen = 999)
## 5. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- result_df
write.csv(final.dataframe, final_csv, row.names = FALSE)
# Public TSV: named by 'Item encoded', looked up by 'Item name'. Until the item has its row in
# __ReadMe.xlsx there is no code: the TSV is skipped with a warning (the CSV above is written).
item_encoded <- if (!is.na(dataset_root)) {
  filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")
  filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' in __ReadMe.xlsx for: ", table_name, "; public TSV skipped. Register the item, then re-run.", call. = FALSE)
} else {
  dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
  write.table(
    final.dataframe,
    file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
    sep = "\t", row.names = FALSE
  )
}
