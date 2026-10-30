# Burger et al. 2019 — Supplementary Data SD1 (brain & body mass, 1552 mammals)
# House pipeline: frozen source -> harmonise species -> analysis CSV + DOI-coded public TSV.
# Digital-native source: the journal download gyz043_suppl_Supplement_Data.csv IS the frozen
# source (kept verbatim; no derived snapshot). See __HOWTO_build_a_dataset_file.md §0a invariant 1.
# SD1 is a COMPILATION (secondary): brain mass with per-species literature references,
# standardised to the taxonomy of Wilson & Reeder (2005).

library(readxl)   # for the __ReadMe.xlsx Item-encoded lookup only

# ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).",
       call. = FALSE)
})

folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # matches __ReadMe.xlsx

base <- dataset_root <- local({                                      # repo root; NA if lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) {
    d <- dirname(d)
  }
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

if (is.na(base)) {
  stop("Could not find the repository root containing __ReadMe.xlsx.", call. = FALSE)
}

setwd(base)

# ---- species resolver (single source of truth = _keys) ----------------------
ref <- read.csv(file.path(base, "_keys", "species_reference.csv"),
                stringsAsFactors = FALSE)$accepted_name

key_files <- list.files(
  file.path(base, "_keys"),
  pattern = "species_key\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

km <- list()
for (kf in key_files) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (all(c("variant_name", "accepted_name") %in% names(k))) {
    for (i in seq_len(nrow(k))) {
      v <- tolower(trimws(k$variant_name[i]))
      if (nzchar(v) && is.null(km[[v]])) km[[v]] <- k$accepted_name[i]
    }
  }
}

clean_sp <- function(x) {
  trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
}

resolve <- function(x) {
  c <- clean_sp(x)
  hit <- match(tolower(c), tolower(ref))
  if (!is.na(hit)) return(ref[hit])
  a <- km[[tolower(c)]]
  if (!is.null(a)) return(a)
  c
}

# ---- read frozen source (digital-native: untouched journal download) --------
snap <- read.csv(
  file.path(folder, "gyz043_suppl_Supplement_Data.csv"),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

df <- cbind(
  species_sci = vapply(snap$Binomial, resolve, character(1)),
  snap,
  stringsAsFactors = FALSE
)

# ---- write analysis CSV + DOI-coded public TSV ------------------------------
write.csv(
  df,
  file.path(folder, paste0(item_name, ".csv")),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

filecodes <- tryCatch(
  read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1"),
  error = function(e) NULL
)

item_encoded <- if (!is.null(filecodes)) {
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else {
  NA_character_
}

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- "10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1"
}

tsv_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(
    df,
    file.path(tsv_dir, paste0(item_encoded, ".tsv")),
    sep = "\t",
    row.names = FALSE,
    quote = TRUE,
    fileEncoding = "UTF-8"
  )
}

cat("Burger SD1:", nrow(df), "species written\n")
