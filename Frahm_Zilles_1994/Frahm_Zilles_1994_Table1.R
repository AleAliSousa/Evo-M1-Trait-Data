# Frahm_Zilles_1994_Table1.R
#
# Preparation step. Turn the journal-faithful snapshot of Frahm & Zilles (1994),
# "Volumetric comparison of hippocampal regions in 44 primate species"
# (J. Hirnforsch. 35:343-354), into a lean, analysis-ready CSV. Output comes from
# the snapshot only.
#
# The paper splits the data over TWO printed tables, both reproduced as sheets of
# the one snapshot workbook:
#   - sheet "Table1": body weight + the main hippocampal volumes -- total
#     hippocampus, HP+HS fibres (pre-/supra-commissural hippocampus + fimbria/
#     fornix fibres), and the retrocommissural hippocampus.
#   - sheet "Table2": the six retrohippocampal region volumes -- subiculum, CA1,
#     CA2, CA3, hilus, fascia dentata. (retrocommissural = their sum; total
#     hippocampus = retrocommissural + HP+HS fibres.)
# All volumes are in mm3 (no conversion). Body weights are re-used from Stephan et
# al. (1981; Insectivora 1991). Species run in the printed taxonomic order with
# blank rows separating Insectivora / Prosimians / Simians (no grade headers, no n
# column -- as printed).
#
# THIS script reads past the 2 header rows on each sheet, keeps the species rows
# (numeric volume; drops blank separators + footnote), and joins the two sheets by
# species into one row per species (48).
#
# Input  : Frahm_Zilles_1994_Table1_snapshot.xlsx   sheets: Table1, Table2
# Outputs: Frahm_Zilles_1994_Table1.csv             one row per species (48)
#          <PMID>.tsv in __Public/comparative-data/   named from __ReadMe.xlsx

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
snapshot_file <- "Frahm_Zilles_1994_Table1_snapshot.xlsx"
output_file   <- "Frahm_Zilles_1994_Table1.csv"
header_rows   <- 2L   # caption + column header on each sheet

num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))

# --- sheet Table1: main hippocampal volumes ---
pos1 <- c("species_disp","body_weight_g","hippocampus_total_mm3","HP_HS_fibers_mm3","hippocampus_retrocommissuralis_mm3")
t1 <- read_excel(snapshot_file, sheet = "Table1", col_names = FALSE, col_types = "text") %>%
  slice(-(seq_len(header_rows))) %>% `names<-`(c(pos1, rep(NA, max(0, ncol(.) - length(pos1)))))
t1 <- t1 %>% filter(!is.na(species_disp), !is.na(num(hippocampus_total_mm3))) %>%
  transmute(Species = str_squish(species_disp),
            body_weight_g = num(body_weight_g),
            hippocampus_total_mm3 = num(hippocampus_total_mm3),
            HP_HS_fibers_mm3 = num(HP_HS_fibers_mm3),
            hippocampus_retrocommissuralis_mm3 = num(hippocampus_retrocommissuralis_mm3))

# --- sheet Table2: retrohippocampal subfields ---
pos2 <- c("species_disp","subiculum_mm3","CA1_mm3","CA2_mm3","CA3_mm3","hilus_mm3","fascia_dentata_mm3")
t2 <- read_excel(snapshot_file, sheet = "Table2", col_names = FALSE, col_types = "text") %>%
  slice(-(seq_len(header_rows))) %>% `names<-`(c(pos2, rep(NA, max(0, ncol(.) - length(pos2)))))
t2 <- t2 %>% filter(!is.na(species_disp), !is.na(num(CA1_mm3))) %>%
  transmute(Species = str_squish(species_disp),
            subiculum_mm3 = num(subiculum_mm3), CA1_mm3 = num(CA1_mm3), CA2_mm3 = num(CA2_mm3),
            CA3_mm3 = num(CA3_mm3), hilus_mm3 = num(hilus_mm3), fascia_dentata_mm3 = num(fascia_dentata_mm3))

final.dataframe <- left_join(t1, t2, by = "Species")

options(scipen = 999)

## ---- SAVE: local CSV + PMID-named TSV ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " species)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (PMID) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
