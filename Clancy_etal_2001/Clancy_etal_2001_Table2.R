## Clancy B, Darlington RB, Finlay BL (2001). Translating developmental time across mammalian species.
## Neuroscience 105(1):7-17. Table 2 (journal p. 12): translation table - rat days (PC) matched to the equivalent
## post-conception / postnatal day in 8 other species; macaque and human in three columns (limbic, other, cortex).
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Clancy_etal_2001_Table2_snapshot.csv  (transcribed from PDF p.6; 50 printed rows x 13 columns)
## Output: <script stem>.csv   LONG: one row per table row x column that holds a value
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
folder      <- dirname(.sp)                              # this paper's folder
item_name   <- tools::file_path_sans_ext(basename(.sp))  # = file name, matches __ReadMe.xlsx
source_name <- sub("_Table[^_]*$", "", item_name)         # Clancy_etal_2001_Table2 -> Clancy_etal_2001
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", na.strings = c("", "NA"))
stopifnot(nrow(snap) == 50, ncol(snap) == 13)

## header "<species> [<region>] (G<gestation days>)" -> species, region, gestation
hd <- names(snap)
gest <- as.numeric(sub(".*\\(G([0-9.]+)\\)$", "\\1", hd))
lab  <- trimws(sub("\\s*\\(G[0-9.]+\\)$", "", hd))
region  <- ifelse(grepl("^(macaque|human) ", lab), sub("^(macaque|human) ", "", lab), NA_character_)
species <- sub(" (limbic|other|cortex)$", "", lab)

out <- list()
for (j in seq_along(hd)) {
  v <- snap[[j]]; keep <- !is.na(v)
  period <- ifelse(v[keep] == "BIRTH", "birth", ifelse(startsWith(v[keep], "P"), "postnatal", "prenatal"))
  pval <- suppressWarnings(as.numeric(sub("^P", "", v[keep])))          # printed number (PC day or P day)
  pcd  <- ifelse(period == "prenatal", pval, ifelse(period == "birth", gest[j], gest[j] + pval))
  out[[j]] <- data.frame(
    table_row            = which(keep),
    species              = species[j],
    brain_region_class   = region[j],                   # macaque/human only (limbic / other / cortex)
    rat_day_printed      = snap[[1]][keep],             # first column: rat PC day, BIRTH, or P day
    time_printed         = v[keep],
    period               = period,
    time_days_as_printed = pval,                        # NA for BIRTH
    gestation_days       = gest[j],
    PC_day_equivalent    = pcd,                         # DERIVED: prenatal = printed; birth = G; postnatal = G + P
    stringsAsFactors = FALSE)
}
clean <- do.call(rbind, out)
clean$source <- source_name
write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
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
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
