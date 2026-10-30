## Manger PR, Prowse M, Haagensen M, Hemingway J (2012). Quantitative analysis of neocortical gyrencephaly in
## African elephants (Loxodonta africana) and six species of cetaceans: comparison with other mammals.
## J Comp Neurol 520(11):2430-2439. Table 1: species, brain mass and gyrification indices.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## Names are written exactly as published; harmonisation to the project key happens downstream.
##
## Input : Manger_etal_2012_Table1_snapshot.csv  (transcribed from PDF p.3; 30 individual/species rows + 5 order
##         header rows + 1 primate summary row)
## Output: <script stem>.csv                 one row per listed animal (30): 3 elephant individuals + 27 species rows
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
folder      <- dirname(.sp)
item_name   <- tools::file_path_sans_ext(basename(.sp))
source_name <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv  <- paste0(item_name, ".csv")
base        <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE, colClasses = "character")
num  <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))

## order header rows have blank Common name / Brain mass; carry them down as 'order_group'
is_hdr <- !nzchar(trimws(snap[[2]])) & !nzchar(trimws(snap[[3]]))
grp <- cumsum(is_hdr); order_group <- snap[[1]][is_hdr][grp]
keep <- !is_hdr & !grepl("^Sixty-one", snap[[1]])      # primate summary row (ranges only) is not a species row
snap <- snap[keep, ]; order_group <- order_group[keep]

common <- trimws(snap[[2]])
## ---- clean (brain mass g as printed; GI = pial contour perimeter / outer contour perimeter) ----
clean <- data.frame(
  species          = trimws(snap[[1]]),                         # name exactly as published
  common_name      = sub("\\s*\\(LA[0-9]\\)$", "", common),
  specimen_id      = ifelse(grepl("\\(LA[0-9]\\)$", common), sub("^.*\\((LA[0-9])\\)$", "\\1", common), NA),
  order_group      = order_group,
  brain_mass_g     = num(snap[[3]]),
  GI               = num(snap[[4]]),
  GI_source        = num(snap[[5]]),                            # 1 this study; 2 Pillay & Manger 2007; 3 Zilles et al. 1989
  source           = source_name,
  stringsAsFactors = FALSE
)

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
