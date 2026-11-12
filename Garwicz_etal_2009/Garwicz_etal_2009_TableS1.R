## Garwicz_etal_2009_TableS1.R -- reads Garwicz_etal_2009_TableS1_snapshot.csv and Garwicz_etal_2009_TableS2_snapshot.csv; builds the analysis CSV + public TSV.
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

paper_dir <- here::here("Garwicz_etal_2009")
dataset_root  <- dirname(paper_dir)
table_name    <- "Garwicz_etal_2009_TableS1"
snapshot_s1   <- file.path(paper_dir, "Garwicz_etal_2009_TableS1_snapshot.csv")
snapshot_s2   <- file.path(paper_dir, "Garwicz_etal_2009_TableS2_snapshot.csv")
final_csv     <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx   <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir<- file.path(dataset_root, "__Public", "comparative-data")
## 1. PACKAGES ---------------------------------------------------------------
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
## 2. READ SNAPSHOTS --------------------------------------------------------
# Frozen snapshots: TableS1_snapshot.csv (written by Garwicz_etal_2009_TableS1_snapshot.R) and
# TableS2_snapshot.csv (written by Garwicz_etal_2009_TableS2_snapshot.R); this script only reads them.
df2 <- read.csv(snapshot_s1, colClasses = "character", check.names = FALSE)
df1 <- read.csv(snapshot_s2, colClasses = "character", check.names = FALSE)
## 3. MAKE DATA READABLE -----------------------------------------------------
# Merge taxonomy (S1) onto the database (S2) by the common (lay) name.
colnames(df2)[colnames(df2) == "Lay term"] <- "Common name"
colnames(df1)[colnames(df1) == "Species (lay term)"] <- "Common name"
tog <- merge(df1, df2[, c("Common name", "Genus/species")], by = "Common name", all.x = TRUE)
# Spell out abbreviations; use the binomial (Genus/species) as Species.
tog <- tog %>%
  rename(
    `Absolute Brain Mass (g)`             = `AbsBrM, g`,
    `Neonatal Brain Mass (g)`             = `NeoBrM (1), g`,
    `Body Mass (g)`                       = `BoM, g`,
    `Gestation (days)`                    = `Gest., days`,
    `Walking onset (Postnatal days)`      = `WO, days_PN`,
    `Walking onset (Postconception days)` = `WO, days_PC`,
    `Precocial/Altricial`                 = `Pre/Alt`,
    `Hindlimb Standing Position`          = `HSP`,
    Species                               = `Genus/species`
  ) %>%
  select(Species, everything())
# Split the literature reference "(n)" out of the value columns into "<col> Ref".
separate_ref <- function(df, col) {
  df %>%
    mutate(
      !!sym(paste0(col, " Ref")) := str_extract(!!sym(col), "\\(([^)]+)\\)"),
      !!sym(col)                 := str_remove(!!sym(col), " \\([^)]*\\)")
    )
}
tog <- tog %>%
  separate_ref("Absolute Brain Mass (g)") %>%
  separate_ref("Body Mass (g)") %>%
  separate_ref("Gestation (days)") %>%
  separate_ref("Walking onset (Postnatal days)")
# "—" means no value for neonatal brain mass.
tog$`Neonatal Brain Mass (g)` <- ifelse(tog$`Neonatal Brain Mass (g)` == "—", NA, tog$`Neonatal Brain Mass (g)`)
# Remove commas and coerce the six measure columns (positions 3:8) to numeric.
for (col in 3:8) tog[[col]] <- gsub(",", "", tog[[col]])
tog[, 3:8] <- lapply(tog[, 3:8], as.numeric)
options(scipen = 999)
## 4. SAVE (LOCAL CSV + PUBLIC TSV) ------------------------------------------
final.dataframe <- tog
filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
if (is.na(item_encoded)) stop("No 'Item encoded' in __ReadMe.xlsx for: ", table_name)
write.csv(final.dataframe, final_csv, row.names = FALSE)
dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
write.table(
  final.dataframe,
  file = file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
  sep = "\t", row.names = FALSE
)
