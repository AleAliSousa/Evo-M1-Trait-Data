# Stephan_etal_1982_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Stephan, Baron & Frahm
# (1982) Table 1 (accessory olfactory bulb, AOB) into a lean, analysis-ready CSV.
# Output comes from the snapshot only.
#
# Snapshot layout (matches the printed Table 1): one leading "species" column
# carrying the taxonomic hierarchy as rows -- grade headers (Basal Insectivora,
# ...), family headers (Tenrecinae, ...), the species (indented), the subfamily
# subtotal rows ("n = 4") and the Mean rows ("Mean Basal Insectivora (n = 12)"),
# with footnotes at the foot -- followed by the n column and the 15 measure
# columns. Header: row1 caption, rows2-4 the multi-tier journal header, row5 the
# printed column numbers (1)-(15); data from row 6.
#
# THIS script keeps the 61 species rows (the only rows with a numeric AOB volume),
# splits the name superscript into former_name_ref + former_name, and the n marker
# into n_note. Group/family are NOT carried into the output (taxonomy is applied
# downstream via ../_keys/Stephan/).
#
# Input  : Stephan_etal_1982_Table1_snapshot.xlsx       sheet: Table1
# Outputs: Stephan_etal_1982_Table1.csv                 one row per species (61)
#          <DOI/PMID>.tsv in __Public/comparative-data/  named from __ReadMe.xlsx

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
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
snapshot_file  <- "Stephan_etal_1982_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1"
output_file    <- "Stephan_etal_1982_Table1.csv"
header_rows    <- 5L

pos <- c("species_disp","n_raw","volume","SEM_pct","size_index","permille_net_brain","permille_MOB",
  "AOB_layer_1_2","AOB_layer_3_5","AOB_layer_6","pct_AOB_1_2","pct_AOB_3_5","pct_AOB_6",
  "size_index_1_2","size_index_3_5","size_index_6")
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))

sup_to_digit <- c("¹"="1","²"="2","³"="3","⁴"="4","⁵"="5","⁶"="6","⁷"="7","⁸"="8","⁹"="9","⁰"="0")
sup_class    <- "[¹²³⁴⁵⁶⁷⁸⁹⁰]"
former_name_legend <- c("1"="Aethechinus algirus","2"="Crocidura occidentalis","3"="Nesogale dobsoni",
  "4"="Nesogale talazaci","5"="Chlorotalpa stuhlmanni","6"="Rhynchocyon stuhlmanni","7"="Lemur fulvus",
  "8"="Lemur variegatus","9"="Galago crassicaudatus","10"="Galago demidovii","11"="Saguinus tamarin")
extract_ref <- function(x) { m <- str_extract_all(x, sup_class)[[1]]
  if (length(m) == 0) NA_character_ else paste(sup_to_digit[m], collapse = "") }
strip_sup <- function(x) str_squish(str_remove_all(x, sup_class))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

final.dataframe <- dat %>%
  filter(!is.na(species_disp), !is.na(num(volume))) %>%   # species rows = numeric AOB volume (drops grade/family/Mean/footnote rows)
  transmute(
    Species = strip_sup(species_disp),
    former_name_ref     = vapply(species_disp, extract_ref, character(1), USE.NAMES = FALSE),
    former_name         = unname(former_name_legend[former_name_ref]),
    n_note              = str_extract(n_raw, "[*•¥]"),
    n                   = as.integer(num(n_raw)),
    AOB_volume_mm3      = num(volume),
    SEM_pct             = num(SEM_pct),
    size_index          = num(size_index),
    permille_net_brain  = num(permille_net_brain),
    permille_MOB        = num(permille_MOB),
    AOB_layer_1_2_mm3   = num(AOB_layer_1_2),
    AOB_layer_3_5_mm3   = num(AOB_layer_3_5),
    AOB_layer_6_mm3     = num(AOB_layer_6),
    pct_AOB_1_2         = num(pct_AOB_1_2),
    pct_AOB_3_5         = num(pct_AOB_3_5),
    pct_AOB_6           = num(pct_AOB_6),
    size_index_1_2      = num(size_index_1_2),
    size_index_3_5      = num(size_index_3_5),
    size_index_6        = num(size_index_6)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI/PMID-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "	", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
