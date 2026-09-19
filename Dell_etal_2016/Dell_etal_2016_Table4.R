library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

# ------------------------------------------------------------------
# Paths: self-contained for Rscript or RStudio
# ------------------------------------------------------------------

.sp <- local({
  # Running with: Rscript file.R
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  
  if (length(a)) {
    return(normalizePath(sub("^--file=", "", a[1])))
  }
  
  # Running from RStudio
  if (
    requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()
  ) {
    p <- rstudioapi::getSourceEditorContext()$path
    
    if (!nzchar(p)) {
      p <- rstudioapi::getActiveDocumentContext()$path
    }
    
    if (nzchar(p)) {
      return(normalizePath(p))
    }
  }
  
  stop(
    paste(
      "Run with Rscript file.R, or open the saved script",
      "in RStudio and click Source."
    ),
    call. = FALSE
  )
})

# This paper's folder
folder <- paper_dir <- dirname(.sp)

# Script filename without ".R"
# For this script: Dell_etal_2016_Table4
item_name <- table_name <-
  tools::file_path_sans_ext(basename(.sp))

# Locate repository root using __ReadMe.xlsx
base <- dataset_root <- local({
  d <- folder
  
  while (
    dirname(d) != d &&
    !file.exists(file.path(d, "__ReadMe.xlsx"))
  ) {
    d <- dirname(d)
  }
  
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) {
    d
  } else {
    NA_character_
  }
})

# All relative paths now start in the paper folder
setwd(folder)

# ------------------------------------------------------------------
# Input and output paths
# ------------------------------------------------------------------

# Derived automatically from the script filename
snapshot_file <- file.path(
  folder,
  paste0(item_name, "_snapshot.xlsx")
)

csv_file <- file.path(
  folder,
  paste0(item_name, ".csv")
)

# ------------------------------------------------------------------
# Read frozen snapshot
# ------------------------------------------------------------------

if (!file.exists(snapshot_file)) {
  stop(
    "Snapshot file not found: ",
    snapshot_file,
    call. = FALSE
  )
}

raw <- read_excel(
  snapshot_file,
  col_names = FALSE
)

# ------------------------------------------------------------------
# Extract table rows from snapshot
# ------------------------------------------------------------------

dat <- raw[5:27, 1:7]

colnames(dat) <- c(
  "Nucleus",
  "CB_Neurons",
  "CB_Terminal",
  "CR_Neurons",
  "CR_Terminal",
  "PV_Neurons",
  "PV_Terminal"
)

# ------------------------------------------------------------------
# Add system/group labels
# ------------------------------------------------------------------

dat$System <- NA_character_

dat$System[1]  <- "Cholinergic"
dat$System[7]  <- "Catecholaminergic"
dat$System[11] <- "Serotonergic"
dat$System[18] <- "Orexinergic"

dat <- dat %>%
  fill(System, .direction = "down")

# ------------------------------------------------------------------
# Remove category rows
# ------------------------------------------------------------------

group_rows <- c(
  "Cholinergic",
  "Catecholaminergic",
  "Serotonergic",
  "Orexinergic"
)

dat <- dat %>%
  filter(!Nucleus %in% group_rows)

# ------------------------------------------------------------------
# Convert from wide to long format
# ------------------------------------------------------------------

long <- dat %>%
  pivot_longer(
    cols = c(
      CB_Neurons,
      CB_Terminal,
      CR_Neurons,
      CR_Terminal,
      PV_Neurons,
      PV_Terminal
    ),
    names_to = "Variable",
    values_to = "Density"
  )

# ------------------------------------------------------------------
# Create Protein and Measure_Type columns
# ------------------------------------------------------------------

long <- long %>%
  mutate(
    Protein = case_when(
      str_detect(Variable, "^CB") ~ "Calbindin",
      str_detect(Variable, "^CR") ~ "Calretinin",
      str_detect(Variable, "^PV") ~ "Parvalbumin",
      TRUE ~ NA_character_
    ),
    
    Measure_Type = case_when(
      str_detect(Variable, "Neurons")  ~ "Neurons",
      str_detect(Variable, "Terminal") ~ "Terminal_networks",
      TRUE ~ NA_character_
    )
  )

# ------------------------------------------------------------------
# Preserve journal species name
# ------------------------------------------------------------------

long$Species_Dell2016 <- "Phocoena phocoena"

# ------------------------------------------------------------------
# Create numeric density score and qualitative description
# ------------------------------------------------------------------

long <- long %>%
  mutate(
    Density_Score = case_when(
      Density == "-"   ~ 0,
      Density == "+"   ~ 1,
      Density == "++"  ~ 2,
      Density == "+++" ~ 3,
      TRUE ~ NA_real_
    ),
    
    Density_Description = case_when(
      Density == "-"   ~ "Absent",
      Density == "+"   ~ "Low density",
      Density == "++"  ~ "Moderate density",
      Density == "+++" ~ "High density",
      TRUE ~ NA_character_
    )
  )

# ------------------------------------------------------------------
# Handle thalamic reticular nucleus
# ------------------------------------------------------------------

long$System[
  long$Nucleus == "Thalamic reticular nucleus"
] <- "Thalamic reticular nucleus"

# ------------------------------------------------------------------
# Final column order
# ------------------------------------------------------------------

final.dataframe <- long %>%
  select(
    Species_Dell2016,
    System,
    Nucleus,
    Protein,
    Measure_Type,
    Density,
    Density_Score,
    Density_Description
  )

# ------------------------------------------------------------------
# Retrieve encoded item name from the registry
# ------------------------------------------------------------------

if (is.na(base)) {
  stop(
    paste(
      "Repository root could not be located.",
      "The TSV cannot be named or written without __ReadMe.xlsx."
    ),
    call. = FALSE
  )
}

registry_file <- file.path(base, "__ReadMe.xlsx")

filecodes <- read_excel(
  registry_file,
  sheet = "Sheet1"
)

item_encoded <- filecodes$`Item encoded`[
  match(item_name, filecodes$`Item name`)
]

if (length(item_encoded) != 1 || is.na(item_encoded) || !nzchar(item_encoded)) {
  stop(
    "No Item encoded value found in __ReadMe.xlsx for: ",
    item_name,
    call. = FALSE
  )
}

# ------------------------------------------------------------------
# Output paths
# ------------------------------------------------------------------

tsv_directory <- file.path(
  base,
  "__Public",
  "comparative-data"
)

if (!dir.exists(tsv_directory)) {
  stop(
    "TSV output directory not found: ",
    tsv_directory,
    call. = FALSE
  )
}

tsv_file <- file.path(
  tsv_directory,
  paste0(item_encoded, ".tsv")
)

# ------------------------------------------------------------------
# Write outputs
# ------------------------------------------------------------------

# CSV uses the script filename and stays beside the script
write.csv(
  final.dataframe,
  file = csv_file,
  row.names = FALSE
)

# TSV uses Item encoded and goes into the public comparative database
write.table(
  final.dataframe,
  file = tsv_file,
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

# ------------------------------------------------------------------
# Quick checks
# ------------------------------------------------------------------

cat("\nOutputs created:\n")
cat("CSV:", csv_file, "\n")
cat("TSV:", tsv_file, "\n\n")

cat("Item name:", item_name, "\n")
cat("Item encoded:", item_encoded, "\n")
cat("Rows:", nrow(final.dataframe), "\n")
cat("Columns:", ncol(final.dataframe), "\n\n")

print(head(final.dataframe))