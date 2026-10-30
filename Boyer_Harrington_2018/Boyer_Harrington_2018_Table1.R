# Boyer_Harrington_2018_Table1.R
#
# Purpose
#   Build Boyer & Harrington (2018) Table 1 ("Taxon list and species mean
#   values") into a lean, analysis-ready CSV. One row per species: the two
#   sample sizes, the doubled transverse-foramen and promontorial-canal
#   cross-sectional areas and their sum, endocranial volume, body mass, basal
#   metabolic rate, and the data-source code(s). Everything comes from the
#   paper's own Table 1 -- no crosswalk, no comparison files.
#
#   Boyer DM, Harrington AR (2018). Scaling of bony canals for encephalic
#   vessels in euarchontans: Implications for the role of the vertebral artery
#   and brain metabolism. J. Hum. Evol. 114, 85-101.
#
# Input
#   Boyer_Harrington_2018_Table1_snapshot.xlsx     sheet: Table1
#     Frozen, journal-faithful transcription of Table 1 as printed in the paper
#     (reconstructed from the PDF text layer; all cleaning happens here in R,
#     never in the snapshot). Row 1 is the header. Taxonomic-group names
#     (Hominoidea, Cercopithecoidea, Platyrrhini, Tarsiidae, Lemuriformes
#     (Cheirogaleidae), Lemuriformes (non-Cheirogaleidae), Lorisiformes,
#     Non-primates (Dermoptera), Non-primates (Scandentia)) sit on their own
#     rows and are carried down into `Taxonomic_group`. The superscript "a"
#     footnote (brain-component values available from Stephan et al. 1981) is
#     transcribed into the `Stephan1981_note` column.
#
# Outputs
#   Boyer_Harrington_2018_Table1.csv               one row per species (49 rows)
#   Boyer_Harrington_2018_Table1_references.csv    data-source key (1-4)
#   <DOI>.tsv in __Public/comparative-data/        tab-separated copy named by the
#                                                  item's encoded DOI (from __ReadMe.xlsx)
#
# Column definitions (from the Table 1 legend):
#   nTFA / nPA = number of individuals for which transverse-foramen / promontorial-
#                canal diameters were measured;
#   DTFA_mm2   = doubled transverse-foramen cross-sectional area (sum of both
#                vertebral arteries), mm^2;
#   DPA_mm2    = doubled promontorial-canal CSA (sum of both internal carotids), mm^2;
#   ACA_mm2    = total arterial canal area = DTFA + DPA, mm^2;
#   ECV_ml     = endocranial volume, mL;
#   BM_g       = body mass, g;
#   BMR_kcal_day = basal metabolic rate, Kcal/day;
#   Source     = data-source code(s) for DPA/ECV/BM/BMR (see the references file).
#
# All DTFA values were measured in this study. The genus abbreviation the table
# uses (D. = Daubentonia) is expanded here into the full binomial; the spaced
# binomial is emitted as the canonical `Species` column. Missing cells (e.g.
# BMR shown as "-") are preserved as NA.

suppressPackageStartupMessages({
  library(readxl)
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
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

source_file  <- "Boyer_Harrington_2018_Table1_snapshot.xlsx"   # frozen, journal-faithful copy
source_sheet <- "Table1"
output_file  <- paste0(item_name, ".csv")
ref_file     <- paste0(item_name, "_references.csv")

# ---- helpers ---------------------------------------------------------------

parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a.", "e"))

# Complete the paper's own genus abbreviation (do not change taxonomy); the
# expansion (D. = Daubentonia) is printed in the Table 1 legend.
abbrev_fixes  <- c("D. madagascariensis" = "Daubentonia madagascariensis")
complete_name <- function(x) ifelse(x %in% names(abbrev_fixes), abbrev_fixes[x], x)

# Data-source key, transcribed from the Table 1 legend.
source_key <- c(
  "1" = "Boyer et al. (2016)",
  "2" = "McNab (2008)",
  "3" = "Pontzer et al. (2016)",
  "4" = "Leonard et al. (2003)"
)

# ---- read the raw sheet (all text; we control parsing) ---------------------

raw <- read_excel(source_file, sheet = source_sheet, col_types = "text", na = c(""))

# ---- carry the taxonomic-group section markers downward --------------------
# Section rows carry a group name in Species and are blank in every data column
# (nTFA is present for every real species row).

sec <- raw %>%
  mutate(
    Species          = str_squish(Species),
    Taxonomic_group  = if_else(is.na(nTFA), Species, NA_character_)
  ) %>%
  fill(Taxonomic_group, .direction = "down")

# ---- species data rows -----------------------------------------------------

final.dataframe <- sec %>%
  filter(!is.na(nTFA)) %>%
  transmute(
    Species          = unname(complete_name(Species)),   # canonical spaced binomial
    Taxonomic_group,
    nTFA             = as.integer(parse_value(nTFA)),
    nPA              = as.integer(parse_value(nPA)),
    DTFA_mm2         = parse_value(DTFA),
    DPA_mm2          = parse_value(DPA),
    ACA_mm2          = parse_value(ACA),
    ECV_ml           = parse_value(ECV),
    BM_g             = parse_value(BM),
    BMR_kcal_day     = parse_value(BMR),
    Source           = str_squish(Source),
    Stephan1981_note = str_squish(Stephan1981_note)
  )

# ---- data-source key: only the codes that actually appear ------------------

used_codes <- final.dataframe$Source
used_codes <- str_squish(unlist(str_split(used_codes[!is.na(used_codes)], ",")))
used_codes <- sort(unique(used_codes[nzchar(used_codes)]))

references <- tibble(
  source_number = as.integer(used_codes),
  citation      = unname(source_key[used_codes])
) %>% arrange(source_number)

options(scipen = 999)

## ---- SAVE: local CSVs + DOI-named TSV in the shared database folder --------

write.csv(final.dataframe, file = output_file, row.names = FALSE)
message("Wrote ", output_file, "  (", nrow(final.dataframe), " rows)")
write.csv(references, file = ref_file, row.names = FALSE)
message("Wrote ", ref_file, "  (", nrow(references), " sources)")

tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) found for '", item_name, "' in __ReadMe.xlsx; TSV copy skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV copy skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

# ---- run summary -----------------------------------------------------------

message("Rows: ", nrow(final.dataframe),
        " | Stephan-1981 flagged: ", sum(!is.na(final.dataframe$Stephan1981_note)),
        " | groups: ", dplyr::n_distinct(final.dataframe$Taxonomic_group))
print(as.data.frame(count(final.dataframe, Taxonomic_group, name = "n_species")), row.names = FALSE)
