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

library(dplyr)
library(readxl)
library(readr)
library(stringr)

# ------------------------------------------------------------
# Paths: works from RStudio or Rscript
# ------------------------------------------------------------

get_script_path <- function() {
  args <- commandArgs(FALSE)
  file_arg <- sub("^--file=", "", args[grepl("^--file=", args)])
  
  if (length(file_arg) && nzchar(file_arg[1])) {
    return(normalizePath(file_arg[1]))
  }
  
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- .sp
    if (nzchar(path)) return(normalizePath(path))
  }
  
  NA_character_
}

script_path <- get_script_path()

if (is.na(script_path)) {
  stop("Could not identify script path. Save the script or run it with Rscript --file=...")
}

paper_dir    <- dirname(script_path)
dataset_root <- dirname(paper_dir)
table_name   <- tools::file_path_sans_ext(basename(script_path))

input_xlsx     <- file.path(paper_dir, "rilling_insel_1998.xlsx")
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

# ------------------------------------------------------------
# Species lookup
# ------------------------------------------------------------

binom <- c(
  "H. sapiens"      = "Homo sapiens",
  "P. paniscus"     = "Pan paniscus",
  "P. troglodytes"  = "Pan troglodytes",
  "G. gorilla"      = "Gorilla gorilla",
  "P. pygmaeus"     = "Pongo pygmaeus",
  "H. lar"          = "Hylobates lar",
  "P. cynocephalus" = "Papio cynocephalus",
  "M. mulatta"      = "Macaca mulatta",
  "C. atys"         = "Cercocebus atys",
  "C. apella"       = "Cebus apella",
  "S. sciureus"     = "Saimiri sciureus"
)

nth_number <- function(x, i) {
  nums <- str_extract_all(gsub(",", "", as.character(x)), "-?[0-9]+\\.?[0-9]*")
  
  vapply(
    nums,
    function(v) {
      if (length(v) >= i) as.numeric(v[i]) else NA_real_
    },
    numeric(1)
  )
}

int_value <- function(x) {
  as.integer(str_extract(as.character(x), "[0-9]+"))
}

# ------------------------------------------------------------
# Read and clean table
# ------------------------------------------------------------

raw <- read_excel(
  input_xlsx,
  sheet = "Table 2",
  col_names = FALSE,
  skip = 2,
  col_types = "text",
  .name_repair = "minimal"
)

names(raw)[1:8] <- c(
  "sp_abbrev",
  "common_name",
  "males",
  "females",
  "body_kg",
  "blank",
  "brain_cc",
  "cerebellum_cc"
)

clean <- raw %>%
  mutate(sp_abbrev = str_squish(sp_abbrev)) %>%
  filter(sp_abbrev %in% names(binom)) %>%
  transmute(
    species              = unname(binom[sp_abbrev]),
    species_abbrev       = sp_abbrev,
    common_name          = str_squish(common_name),
    
    n_males              = int_value(males),
    n_females            = int_value(females),
    
    body_weight_kg       = nth_number(body_kg, 1),
    body_weight_kg_SEM   = nth_number(body_kg, 2),
    
    brain_volume_cc      = nth_number(brain_cc, 1),
    brain_volume_cc_SEM  = nth_number(brain_cc, 2),
    
    cerebellum_volume_cc     = nth_number(cerebellum_cc, 1),
    cerebellum_volume_cc_SEM = nth_number(cerebellum_cc, 2),
    
    source = "Rilling_Insel_1998"
  )

# ------------------------------------------------------------
# Save local CSV and public TSV
# ------------------------------------------------------------

filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")

item_encoded <- filecodes$`Item encoded`[
  match(table_name, filecodes$`Item name`)
]

if (is.na(item_encoded)) {
  stop("No matching 'Item encoded' found for: ", table_name)
}

write_csv(clean, final_csv)

dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)

write_tsv(
  clean,
  file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
)