# Lewitus et al. 2014 — Table S1 (physiological & life-history variables) -> CSV + TSV
#
# DIGITAL-NATIVE build (no snapshot). The source is the journal's own machine-
# readable supplement (pbio.1002000.s013.xlsx); per house convention a digital-
# native source is already the durable, faithful copy, so we read it DIRECTLY and
# skip the snapshot step. All cleaning is reproducible from that source file.
#   doi:10.1371/journal.pbio.1002000
#
# 104 mammal species; 40 physiological / life-history columns. The journal's own
# header carries three spelling typos, corrected here (documented in the README):
#   Neuronal_denisty -> Neuronal_density
#   Glial_cell_denisty -> Glial_cell_density
#   Basal_metaboic_rate -> Basal_metabolic_rate
#
# Source : Lewitus_etal_2014/pbio.1002000.s013.xlsx   (sheet "Sheet1")
# Outputs: Lewitus_etal_2014_TableS1.csv              (104 species)
#          10.1371%2Fjournal.pbio.1002000_TableS1.tsv in __Public/comparative-data/
# QA     : comparison/Lewitus_etal_2014_TableS1_compare_to_public_tsv.R
#          audits this output against the founder public TSV (0 mismatches).

library(readxl)

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))          # = "Lewitus_etal_2014_TableS1"
base      <- local({                                           # repo root; NA if run alone
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

source_file <- "pbio.1002000.s013.xlsx"    # digital-native journal supplement (kept in-folder)

## ---- species resolver (single source of truth = _keys) ----------------------
resolve <- local({
  keydir <- if (!is.na(base)) base else folder
  key <- read.csv(file.path(keydir, "_keys/Stephan/species_key.csv"), stringsAsFactors = FALSE)
  ref <- read.csv(file.path(keydir, "_keys/species_reference.csv"),   stringsAsFactors = FALSE)$accepted_name
  km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
  clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
  function(x) { c <- clean_sp(x)
    h <- match(tolower(c), tolower(ref)); if (!is.na(h)) return(ref[h])
    a <- km[tolower(c)]; if (!is.na(a)) return(unname(a)); c }
})

## ---- read the source directly (row 1 = title, row 2 = header) ----------------
src <- read_excel(source_file, sheet = "Sheet1", skip = 1, .name_repair = "minimal")
src <- as.data.frame(src, check.names = FALSE)
src <- src[!is.na(src$Species) & nzchar(trimws(src$Species)), ]   # drop any trailing blank rows

## ---- correct the journal's header typos (documented in README) --------------
typo_fix <- c(Neuronal_denisty = "Neuronal_density",
              Glial_cell_denisty = "Glial_cell_density",
              Basal_metaboic_rate = "Basal_metabolic_rate")
nm <- names(src); hit <- nm %in% names(typo_fix)
nm[hit] <- typo_fix[nm[hit]]; names(src) <- nm

## ---- harmonise species (printed name kept as Species) -----------------------
df <- cbind(species_sci = vapply(src$Species, resolve, character(1)),
            src, stringsAsFactors = FALSE)

## ---- write analysis CSV + DOI-coded public TSV -------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

item_encoded <- if (!is.na(base)) {
  fc <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$"Item encoded"[match(item_name, fc$"Item name")]
} else NA_character_
tsv_dir <- if (!is.na(base)) file.path(base, "__Public/comparative-data") else NA_character_
if (!is.na(item_encoded) && !is.na(tsv_dir) && dir.exists(tsv_dir)) {
  write.table(df, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
} else {
  warning("Public TSV not written (item_encoded or __Public missing); wrote local CSV only.")
}
cat("Lewitus TableS1 (digital-native):", nrow(df), "species written\n")
