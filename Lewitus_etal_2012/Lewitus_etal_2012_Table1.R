## Lewitus E, Sherwood CC, Hof PR (2012). Cellular signatures in the primary visual cortex of phylogeny and
## placentation. Brain Struct Funct 217(2):531-547. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Species are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Lewitus_etal_2012_Table1_snapshot.csv  (transcribed from PDF p.5)
## Output: <script stem>.csv   one row per species (71)
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
source_name <- sub("_Table[^_]*$", "", item_name)         # Lewitus_etal_2012_Table1 -> Lewitus_etal_2012
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")                 # project convention: output derives from script name
base        <- local({                                   # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, na.strings = c("", "NA"))
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(as.character(x)))))

## fill down the merged group / subgroup cells (printed once per block)
fill <- function(v) { v[is.na(v)] <- ""; cur <- ""; for (i in seq_along(v)) { if (nzchar(v[i])) cur <- v[i] else v[i] <- cur }; v }
grp <- fill(snap[[1]])
## Subgroup is blank for the Shrew-to-Whale block: fill down only inside a taxonomic group
sub <- snap[[2]]; sub[is.na(sub)] <- ""; cur <- ""
for (i in seq_len(nrow(snap))) { if (!is.na(snap[[1]][i]) && nzchar(snap[[1]][i])) cur <- ""; if (nzchar(sub[i])) cur <- sub[i] else sub[i] <- cur }
sp  <- trimws(snap[[3]])
n   <- suppressWarnings(as.numeric(sub("^.*\\((\\d+)\\).*$", "\\1", ifelse(grepl("\\(\\d+\\)", sp), sp, NA))))
n[is.na(n)] <- 1                                         # footnote: no number listed = one individual
euth <- grepl("\\^a$", sp)                              # footnote a: species included in Eutheria group
name <- trimws(sub("\\^a$", "", trimws(sub("\\s*\\(\\d+\\)", "", sp))))
## SW rows carry the label in the Taxonomic group column; subgroup left blank
clean <- data.frame(
  species = name, taxonomic_group = grp, subgroup = ifelse(nzchar(sub), sub, NA),
  n_individuals_sampled = n, in_eutheria_group = euth,
  source = source_name, stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 71, sum(clean$in_eutheria_group) == 31)
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
