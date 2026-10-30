## Bush EC, Allman JM (2004). Three-dimensional structure and evolution of primate
## primary visual cortex. Anat Rec A 281A(1):1088-1094. TABLE 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream (__merging_volumes).
## QA against the compiled/de Sousa copies lives in the private companion repo (run those
## scripts on their own; this build does not perform the comparison).
##
## Input : Bush_Allman_2004_b_TABLE1_snapshot.csv  (species + V1G,LGN,V1surf,Hmerid,Wb,NeoW,NeoG)
## Output: Bush_Allman_2004_b_TABLE1.csv           one row per species (21)
##         <Item encoded>.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

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

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv("Bush_Allman_2004_b_TABLE1_snapshot.csv",
                 check.names = FALSE, stringsAsFactors = FALSE,
                 na.strings = c("", "NA", "n.a.", "-", "--"))

## ---- build writes the PUBLISHED species name only ----
## Species-key harmonisation (against _keys/Allman/species_key.csv) is NOT done here;
## it is applied downstream in __merging_volumes/volumes_compiled.R (token "Bush_Allman_2004_b").
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

## ---- clean (units kept as printed: volumes cm3, V1 surface cm2, meridian mm) ----
clean <- data.frame(
  species                = trimws(snap$species),   # name exactly as published
  V1_grey_cm3            = num(snap$V1G),
  LGN_cm3                = num(snap$LGN),
  V1_surface_cm2         = num(snap$V1surf),
  horizontal_meridian_mm = num(snap$Hmerid),
  whole_brain_cm3        = num(snap$Wb),
  neocortex_white_cm3    = num(snap$NeoW),
  neocortex_grey_cm3     = num(snap$NeoG),
  source                 = "Bush_Allman_2004_b",
  stringsAsFactors = FALSE
)

## ---- local CSV: use this R script's filename ----
csv_file <- file.path(folder, paste0(item_name, ".csv"))

write.csv(clean, csv_file, row.names = FALSE)

message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))


## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx ----

tsv_dir <- file.path(base, "__Public", "comparative-data")

item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  
  write.table(
    clean,
    tsv_file,
    sep = "\t",
    row.names = FALSE
  )
  
  message("Wrote ", tsv_file)
}
