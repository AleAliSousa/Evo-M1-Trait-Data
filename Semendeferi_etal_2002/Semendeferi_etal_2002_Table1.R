## Semendeferi K, Lu A, Schenker N, Damasio H (2002), Nat Neurosci 5(3):272-276
## "Humans and great apes share a large frontal cortex." Table 1: relative size of frontal cortex.
## NB: values are PERCENT of cerebral cortex (not absolute mm3). Snapshot -> clean.

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

setwd(folder)
options(scipen = 999)
raw <- read.csv("Semendeferi_etal_2002_Table1_snapshot.csv", check.names = FALSE, stringsAsFactors = FALSE)
binom <- c(Human="Homo sapiens", Chimpanzee="Pan troglodytes", Bonobo="Pan paniscus",
           Gorilla="Gorilla gorilla", Orangutan="Pongo pygmaeus", Gibbon="Hylobates lar",
           Macaque="Macaca sp.", Cebus="Cebus sp.")
ps <- raw[["Present study volume %"]]
parse_mean <- function(x) if (grepl(" and ", x)) round(mean(as.numeric(strsplit(x," and ")[[1]])),3) else as.numeric(sub("^([0-9.]+).*$","\\1",x))
parse_sd   <- function(x) { m <- regmatches(x, regexpr("[0-9.]+(?=\\))", x, perl=TRUE)); if (length(m)) as.numeric(m) else NA_real_ }
opt <- function(x) suppressWarnings(as.numeric(ifelse(x=="NA","",x)))
clean <- data.frame(species = unname(binom[raw$Species]),
                    frontal_cortex_pct_of_cortex_volume = vapply(ps, parse_mean, numeric(1)),
                    sd = vapply(ps, parse_sd, numeric(1)),
                    brodmann1909_surface_pct = opt(raw[["Brodmann (1909) surface %"]]),
                    blinkov_glezer1965_surface_pct = opt(raw[["Blinkov & Glezer (1965) surface %"]]),
                    note = ifelse(grepl(" and ", ps), "n=2 (two specimens)", ""),
                    source = "Semendeferi_etal_2002", stringsAsFactors = FALSE)
write.csv(clean, "Semendeferi_etal_2002_Table1.csv", row.names = FALSE)

## ---- DOI-coded public TSV (__HOWTO_build_a_dataset_file.md sec 4, invariant 2) -----------
## Added 2026-08-05: the script wrote the analysis CSV but never the public TSV, so the table
## was built but unpublished. Same object, same columns - only the separator differs.
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA_character_
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; public TSV skipped.")
} else if (is.na(tsv_dir) || !dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; public TSV skipped.")
} else {
  write.table(clean, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
