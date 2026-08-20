## Bush, E.C. & Allman, J.M. (2004). The scaling of frontal cortex in primates and carnivores.
## PNAS 101(11):3962-3966.  Table 2 = "Volumes for cortical regions for 55 species of mammals (cm3)".
## Source: HTML download from the PNAS site (05760table2.html). Snapshot -> clean -> harmonize -> compare.

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
library(rvest); library(readxl)

## 1. SNAPSHOT (faithful) - parse the published HTML table verbatim
tab <- html_table(read_html("05760table2.html"))[[1]]
colnames(tab) <- c("species","FrG","RoG","FrRat","WhBr","NeoG","NeoW","Act","Diet","Gr","Grsz")
tab <- tab[-1, ]                                   # drop the repeated header row
write.csv(tab, "Bush_Allman_2004_a_Table2_snapshot.csv", row.names = FALSE)

## 2. HARMONIZE species names to the project key
key <- read.csv("../_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
lookup <- setNames(key$accepted_name, tolower(key$variant_name))
lookup <- c(lookup, setNames(key$accepted_name, tolower(key$accepted_name)))
harm <- function(s){ s <- trimws(s); cand <- paste0(toupper(substr(s,1,1)), tolower(substr(s,2,nchar(s))))
  v <- lookup[tolower(s)]; if (is.na(v)) v <- lookup[tolower(cand)]; if (is.na(v)) cand else unname(v) }
num <- function(x) suppressWarnings(as.numeric(x))

## 3. CLEAN (rename to interpretable columns; cm3)
clean <- data.frame(
  species              = vapply(tab$species, harm, character(1)),
  species_as_published = tab$species,
  frontal_grey_cm3        = num(tab$FrG),  rest_of_cortex_grey_cm3 = num(tab$RoG),
  frontal_ratio           = num(tab$FrRat),whole_brain_cm3         = num(tab$WhBr),
  neocortex_grey_cm3      = num(tab$NeoG), neocortex_white_cm3     = num(tab$NeoW),
  activity = tab$Act, diet = tab$Diet, group_type = tab$Gr, group_size = tab$Grsz,
  source = "Bush_Allman_2004_a", stringsAsFactors = FALSE)
write.csv(clean, "Bush_Allman_2004_a_Table2.csv", row.names = FALSE)
message("Bush & Allman 2004a Table 2: ", nrow(clean), " species written.")

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't write a local-named TSV) ----
base_dir     <- base
item_name    <- "Bush_Allman_2004_a_Table2"
tsv_dir      <- file.path(base_dir, "__Public/comparative-data/")
filecodes    <- readxl::read_excel(file.path(base_dir, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}

## 4. COMPARE to the digitized copy in the private companion repo
##    -> restricted_checks/Bush_Allman_2004_a/comparison/check_Table2_vs_digitized.csv
## 5. COMPARE to a SIMILAR dataset: neocortex grey vs Frahm (Stephan_primates.csv NeoG_Frahm, mm3)
##    -> restricted_checks/Bush_Allman_2004_a/comparison/compare_NeoG_Bush_vs_Frahm.csv
##       (Bush runs ~3-12% smaller for shared primates)
## (both comparison CSVs are written by the accompanying build; see ReadMe.)
