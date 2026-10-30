## MacLeod et al. 2003, J Hum Evol 44:401-429 — Table 2
## Hirnforschung sample
## Snapshot -> clean.
## Per-specimen volumes (cm3): whole brain, cerebellum, vermis, hemispheres.
## Golden rule: the snapshot is frozen/faithful; ALL cleaning happens here.

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

options(scipen = 999)

# ------------------------------------------------------------
# Paths: use this R script's filename and folder
# ------------------------------------------------------------

is_blank <- function(x) {
  length(x) == 0 || is.na(x[1]) || !nzchar(x[1])
}

get_script_path <- function() {
  path <- NA_character_
  
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- .sp
  }
  
  if (is_blank(path)) {
    args <- commandArgs(FALSE)
    file_arg <- sub("^--file=", "", args[grepl("^--file=", args)])
    
    if (!is_blank(file_arg)) {
      path <- file_arg[1]
    }
  }
  
  if (is_blank(path)) {
    stop("Save the R script before running it.")
  }
  
  normalizePath(path, mustWork = TRUE)
}

script_path <- get_script_path()

folder    <- dirname(script_path)
base      <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(script_path))

snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
csv_file     <- file.path(folder, paste0(item_name, ".csv"))

readme_xlsx <- file.path(base, "__ReadMe.xlsx")
tsv_dir     <- file.path(base, "__Public", "comparative-data")

if (!file.exists(snapshot_csv)) {
  stop("Snapshot CSV not found: ", snapshot_csv)
}

# ------------------------------------------------------------
# Load snapshot
# ------------------------------------------------------------

raw <- read.csv(
  snapshot_csv,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

get_col <- function(possible_names) {
  hit <- possible_names[possible_names %in% names(raw)]
  
  if (!length(hit)) {
    stop(
      "Missing required column. Tried: ",
      paste(possible_names, collapse = ", ")
    )
  }
  
  raw[[hit[1]]]
}

spec <- as.character(get_col("Specimen"))
spec_for_flags <- spec
spec_for_flags[is.na(spec_for_flags)] <- ""

# Footnote markers carried in the Specimen cell:
#   †  from the Stephan Collection
#   ‡  brain weight not known
#   *  horizontal sections
#   §  sagittal sections
#   default: coronal sections

has_star <- grepl("*", spec_for_flags, fixed = TRUE)
has_sec  <- grepl("§", spec_for_flags, fixed = TRUE)

# ------------------------------------------------------------
# Cleaning helpers
# ------------------------------------------------------------

clean_species <- function(s) {
  if (is_blank(s)) {
    return(NA_character_)
  }
  
  s <- gsub("[*†‡§]", "", s)
  s <- trimws(sub("\\(.*$", "", s))
  
  if (!nzchar(s)) {
    return(NA_character_)
  }
  
  tk <- strsplit(s, "\\s+")[[1]]
  
  if (!length(tk) || is.na(tk[1])) {
    return(NA_character_)
  }
  
  out <- tk[1]
  
  if (length(tk) >= 2) {
    out <- paste(out, tk[2])
  }
  
  if (length(tk) >= 3 && grepl("^[a-z]+$", tk[3])) {
    out <- paste(out, tk[3])
  }
  
  trimws(out)
}

strip_flags <- function(x) {
  y <- gsub("[*†‡§]", "", as.character(x))
  y <- trimws(y)
  
  empty <- is.na(y) | !nzchar(ifelse(is.na(y), "", y))
  y[empty] <- NA_character_
  
  y
}

as_num <- function(x) {
  x <- gsub(",", "", as.character(x))
  x[is.na(x)] <- ""
  
  m <- regexpr("-?[0-9]+\\.?[0-9]*", x)
  
  out <- rep(NA_real_, length(x))
  hit <- m > 0
  
  out[hit] <- suppressWarnings(as.numeric(regmatches(x, m)))
  
  out
}

# ------------------------------------------------------------
# Clean data
# ------------------------------------------------------------

clean <- data.frame(
  species = vapply(
    spec,
    clean_species,
    character(1),
    USE.NAMES = FALSE
  ),
  
  specimen = strip_flags(spec),
  
  sex = trimws(as.character(get_col("Sex"))),
  
  sample = "Hirnforschung",
  
  brain_volume_cm3 = as_num(
    get_col(c("Brain volume cm3", "Brain volume (cm3)"))
  ),
  
  cerebellum_volume_cm3 = as_num(
    get_col(c("Cerebellum volume cm3", "Cerebellum volume (cm3)"))
  ),
  
  vermis_volume_cm3 = as_num(
    get_col(c("Vermis volume cm3", "Vermis volume (cm3)"))
  ),
  
  hemisphere_volume_cm3 = as_num(
    get_col(c(
      "Hemisphere volume cm3",
      "Hemispheres volume cm3",
      "Hemisphere volume (cm3)",
      "Hemispheres volume (cm3)"
    ))
  ),
  
  stephan_collection = grepl("†", spec_for_flags, fixed = TRUE),
  
  section_plane = ifelse(
    has_star & has_sec,
    "mixed",
    ifelse(
      has_star,
      "horizontal",
      ifelse(has_sec, "sagittal", "coronal")
    )
  ),
  
  brainweight_known = !grepl("‡", spec_for_flags, fixed = TRUE),
  
  source = "MacLeod_etal_2003",
  
  stringsAsFactors = FALSE
)

# Remove completely blank/non-data rows, if any
clean <- clean[!is.na(clean$species) | !is.na(clean$specimen), ]

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