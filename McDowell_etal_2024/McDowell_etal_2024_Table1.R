library(readxl)
library(dplyr)

# --------------------------------------------------
# Paths: self-contained
# --------------------------------------------------

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  
  if (length(a)) {
    return(normalizePath(sub("^--file=", "", a[1])))
  }
  
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
    "Run with Rscript file.R, or open in RStudio and click Source (save first).",
    call. = FALSE
  )
})

folder <- paper_dir <- dirname(.sp)

item_name <- table_name <-
  tools::file_path_sans_ext(basename(.sp))

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

setwd(folder)

# --------------------------------------------------
# Read snapshot
# --------------------------------------------------

raw <- read_excel(
  paste0(item_name, "_snapshot.xlsx"),
  col_names = FALSE
)

# --------------------------------------------------
# Extract species data rows
# --------------------------------------------------

dat <- raw[5:17, ]

# --------------------------------------------------
# Apply clean column names
# --------------------------------------------------

colnames(dat) <- c(
  "Species_Common",
  "Species_binomial",
  "S_Cone_LambdaMax_nm",
  "Melanopsin_LambdaMax_nm",
  "Rhodopsin_LambdaMax_nm",
  "M_Cone_LambdaMax_nm",
  "L_Cone_LambdaMax_nm"
)

# --------------------------------------------------
# Remove footnote markers
# --------------------------------------------------

dat <- dat %>%
  mutate(
    across(
      c(
        S_Cone_LambdaMax_nm,
        Melanopsin_LambdaMax_nm,
        Rhodopsin_LambdaMax_nm,
        M_Cone_LambdaMax_nm,
        L_Cone_LambdaMax_nm
      ),
      ~ gsub("[a-z]$", "", .x)
    )
  )

# --------------------------------------------------
# Convert dashes to missing values
# --------------------------------------------------

dat <- dat %>%
  mutate(
    across(
      c(
        S_Cone_LambdaMax_nm,
        Melanopsin_LambdaMax_nm,
        Rhodopsin_LambdaMax_nm,
        M_Cone_LambdaMax_nm,
        L_Cone_LambdaMax_nm
      ),
      ~ ifelse(. %in% c("-", "–", "—", "--"), NA, .)
    )
  )

# --------------------------------------------------
# Convert wavelength columns to numeric
# --------------------------------------------------

dat <- dat %>%
  mutate(
    across(
      c(
        S_Cone_LambdaMax_nm,
        Melanopsin_LambdaMax_nm,
        Rhodopsin_LambdaMax_nm,
        M_Cone_LambdaMax_nm,
        L_Cone_LambdaMax_nm
      ),
      as.numeric
    )
  )

# --------------------------------------------------
# Standardise numeric precision
# --------------------------------------------------

dat <- dat %>%
  mutate(
    across(
      c(
        S_Cone_LambdaMax_nm,
        Melanopsin_LambdaMax_nm,
        Rhodopsin_LambdaMax_nm,
        M_Cone_LambdaMax_nm,
        L_Cone_LambdaMax_nm
      ),
      ~ round(., 1)
    )
  )

# --------------------------------------------------
# Add source tracking
# --------------------------------------------------

dat$Source <- item_name

# --------------------------------------------------
# Final column order
# --------------------------------------------------

final.dataframe <- dat %>%
  select(
    Species_Common,
    Species_binomial,
    S_Cone_LambdaMax_nm,
    Melanopsin_LambdaMax_nm,
    Rhodopsin_LambdaMax_nm,
    M_Cone_LambdaMax_nm,
    L_Cone_LambdaMax_nm,
    Source
  )

# --------------------------------------------------
# Get encoded item name
# --------------------------------------------------

filecodes <- read_excel(
  file.path(base, "__ReadMe.xlsx"),
  sheet = "Sheet1"
)

item_encoded <- filecodes$`Item encoded`[
  match(item_name, filecodes$`Item name`)
]

# --------------------------------------------------
# Export CSV beside the R script
# --------------------------------------------------

write.csv(
  final.dataframe,
  file = paste0(item_name, ".csv"),
  row.names = FALSE
)

# --------------------------------------------------
# Export encoded TSV to the online database
# --------------------------------------------------

tsv_file_path <- paste0(
  file.path(base, "__Public", "comparative-data"),
  "/"
)

write.table(
  final.dataframe,
  file = paste0(tsv_file_path, item_encoded, ".tsv"),
  sep = "\t",
  row.names = FALSE,
  quote = FALSE
)

# --------------------------------------------------
# Checks
# --------------------------------------------------

cat(
  "\nAnalysis-ready CSV created:\n",
  paste0(item_name, ".csv\n\n")
)

cat(
  "TSV created:\n",
  paste0(tsv_file_path, item_encoded, ".tsv\n\n")
)

cat(
  "Rows:",
  nrow(final.dataframe),
  "\n"
)

cat(
  "Columns:",
  ncol(final.dataframe),
  "\n"
)

head(final.dataframe)