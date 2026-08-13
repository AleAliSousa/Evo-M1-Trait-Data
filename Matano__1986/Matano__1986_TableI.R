# Matano__1986_TableI.R
#
# Preparation step. Turn the journal-faithful snapshot of Matano, S. (1986),
# "A volumetric comparison of the vestibular nuclei in primates" (Folia Primatol.
# 47(4):189-203, DOI 10.1159/000156277) Table I into a lean, analysis-ready CSV.
# Output comes from the snapshot only.
#
# LATERALITY -- IMPORTANT. These are ONE-SIDE (unilateral) volumes, so every
# volume column carries the _unilateral suffix and the merge terms do too.
# The paper does not state a side, but three lines of evidence fix it:
#   (1) the Methods say "The data of Stephan et al. [1981] have been incorporated
#       in the present study", and for the 27 species shared with Stephan et al.
#       1981 Table XIII all four nuclei are identical to the printed digit (0/27
#       mismatches; only the re-summed `complex` column differs by 1 ulp on 6 spp.);
#   (2) Baron et al. (1988) state of those earlier data: "the volumes of the
#       vestibular nuclei were measured in 33 species ... but from one side only.
#       Since the present data are from new measurements that included new
#       individuals and are from both sides, the volumes are not merely a simple
#       duplication of the former data";
#   (3) Baron 1988 (both sides) / Matano 1986 behaves the same for the 27 known
#       one-side species (mean 2.02, sd 0.18) as for the 19 species new here
#       (mean 1.92, sd 0.17) -- so the new material was measured the same way.
#
# PRIMARY vs SECONDARY. `Data role` = both. The 27 species shared with Stephan
# et al. 1981 Table XIII are that paper's data re-printed (secondary); the 19
# species listed in the README are Matano's own new measurements (primary).
# No suppression is coded here: the merge is Tier-1 `Stephan_collection`, where
# the most recent publication supersedes, so Stephan 1981 (1981) is superseded by
# this table (1986) and this table is in turn superseded by Baron et al. 1988
# (1988), which measured all 46 of these species bilaterally.
#
# Snapshot layout (the volumes columns of the printed Table I): row1 caption,
# rows2-3 headers, then species rows in printed order with grade header rows
# (Scandentia / Primates, prosimians / Primates, simians). Only the body-weight
# and volume columns are transcribed; the printed size-index (Table II) and
# ratio (Table III) columns are derived and recomputed downstream -- they are
# used only as the QA anchor in comparison/ (see the README).
#
# Input  : Matano__1986_TableI_snapshot.xlsx                sheet: TableI
# Outputs: Matano__1986_TableI.csv                          one row per species (46)
#          <DOI>.tsv in __Public/comparative-data/          named from __ReadMe.xlsx

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
snapshot_file  <- "Matano__1986_TableI_snapshot.xlsx"
snapshot_sheet <- "TableI"
header_rows    <- 3L

pos <- c("species_disp","n_raw","body_weight_g",
         "superior","lateral","medial","descending","complex")
num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a.", "__"))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

final.dataframe <- dat %>%
  filter(!is.na(num(complex))) %>%   # species rows = numeric complex volume (drops grade headers)
  transmute(
    # printed name kept verbatim (HOWTO invariant 3); abbreviated genera are as
    # printed -- "C. medius", "A. l. occidentalis", "S. oedipus", "C. mitis".
    # Harmonisation is central, via _keys/Stephan/species_key.csv token Matano1986.
    Species_Matano1986                                = str_squish(species_disp),
    n                                                 = as.integer(num(n_raw)),
    body_weight_g                                     = num(body_weight_g),
    Nucleus_vestibularis_superior_unilateral_mm3      = num(superior),
    Nucleus_vestibularis_lateralis_unilateral_mm3     = num(lateral),
    Nucleus_vestibularis_medialis_unilateral_mm3      = num(medial),
    Nucleus_vestibularis_descendens_unilateral_mm3    = num(descending),
    Complexus_vestibularis_unilateral_mm3             = num(complex)
  )

# Units are already the project standard: volumes mm3 (as printed), body weight g
# (as printed; thousands separators stripped by parse_number).

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (standard registry lookup by Item name) ----
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " species)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
