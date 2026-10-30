## Semendeferi K, Armstrong E, Schleicher A, Zilles K, Van Hoesen GW (1998),
## Am J Phys Anthropol 106(2):129-155 — "Limbic Frontal Cortex in Hominoids: A Comparative Study of Area 13"
## Table 2: Volumes of the brain and area 13 (mm3). Snapshot -> clean.
options(scipen = 999)

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
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
csv_file     <- file.path(folder, paste0(item_name, ".csv"))

readme_xlsx <- file.path(base, "__ReadMe.xlsx")
tsv_dir     <- file.path(base, "__Public", "comparative-data")

if (!file.exists(snapshot_csv)) {
  stop("Snapshot CSV not found: ", snapshot_csv)
}

raw <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE)
binom <- c(Human="Homo sapiens", Chimpanzee="Pan troglodytes", Bonobo="Pan paniscus",
           Gorilla="Gorilla gorilla", Orangutan="Pongo pygmaeus", Gibbon="Hylobates lar")
num <- function(x) as.numeric(gsub(",", "", x))
clean <- data.frame(species = unname(binom[raw$Species]),
                    brain_volume_mm3 = num(raw$Brain),
                    area13_volume_mm3 = num(raw[["Area 13"]]),
                    area13_hemisphere = "right", n = 1L, source = "Semendeferi_etal_1998",
                    stringsAsFactors = FALSE)
# Footnotes: brain = total brain structure (mm3); area 13 = right hemisphere; one individual/species.
# ------------------------------------------------------------
# Local CSV
# ------------------------------------------------------------

write.csv(clean, csv_file, row.names = FALSE)

message(
  item_name,
  ": ",
  nrow(clean),
  " rows written to ",
  basename(csv_file)
)

# ------------------------------------------------------------
# Public TSV: look up encoded item name from __ReadMe.xlsx
# ------------------------------------------------------------

if (!file.exists(readme_xlsx)) {
  warning("__ReadMe.xlsx not found: ", readme_xlsx, "; TSV skipped.")
  
} else if (!dir.exists(tsv_dir)) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  
} else {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop("Package 'readxl' is required to read __ReadMe.xlsx.")
  }
  
  filecodes <- readxl::read_excel(readme_xlsx, sheet = "Sheet1")
  
  item_encoded <- as.character(
    filecodes$`Item encoded`[
      match(item_name, filecodes$`Item name`)
    ]
  )
  
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning(
      "No 'Item encoded' for '",
      item_name,
      "' in __ReadMe.xlsx; TSV skipped."
    )
    
  } else {
    tsv_file <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
    
    write.table(
      clean,
      tsv_file,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE
    )
    
    message("Wrote ", tsv_file)
  }
}