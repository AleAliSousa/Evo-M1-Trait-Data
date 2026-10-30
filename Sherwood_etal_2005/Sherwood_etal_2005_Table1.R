# Sherwood et al. 2005 - Table 1 reformat
# Sherwood CC, Holloway RL, Erwin JM, Schleicher A, Zilles K, Hof PR (2005).
# "Cortical orofacial motor representation in Old World monkeys, great apes,
#  and humans..." (Brain Behav Evol) -- Table 1: medulla + orofacial motor
# nuclei volumes (left side only) (mm3).
#
# Reads the frozen faithful snapshot and writes the clean analysis CSV plus a
# DOI/stem-coded TSV for the volume merge. Medulla = whole structure; Vmo, VII,
# XII = LEFT side only (paper: "Only one side was analyzed because ... cranial
# nerve motor nuclei do not exhibit morphometric asymmetries").

library(tidyverse)
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

snap <- read.csv(file.path(folder, "Sherwood_etal_2005_Table1_snapshot.csv"),
                 stringsAsFactors = FALSE, check.names = FALSE)
numv <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

clean <- tibble(
  species               = trimws(snap$species),
  N                     = numv(snap$N),
  medulla_oblongata_mm3 = numv(snap$Medulla_volume_Mean),
  medulla_oblongata_SD  = numv(snap$Medulla_volume_SD),
  trigeminal_motor_Vmo_mm3 = numv(snap$Vmo_volume_Mean),   # left side only
  trigeminal_motor_Vmo_SD  = numv(snap$Vmo_volume_SD),
  facial_VII_mm3        = numv(snap$VII_volume_Mean),       # left side only
  facial_VII_SD         = numv(snap$VII_volume_SD),
  hypoglossal_XII_mm3   = numv(snap$XII_volume_Mean),       # left side only
  hypoglossal_XII_SD    = numv(snap$XII_volume_SD),
  source                = "Sherwood_2005"
)

write_csv(clean, file.path(folder, "Sherwood_etal_2005_Table1.csv"))
message("Sherwood 2005 Table 1: ", nrow(clean), " species written.")

## ---- TSV for the merge: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
item_name    <- "Sherwood_etal_2005_Table1"
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write_tsv(clean, file.path(tsv_dir, paste0(item_encoded, ".tsv")))
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}
