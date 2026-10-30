# Seymour_etal_2015_TableS1.R
#
# Purpose
#   Build Seymour et al. (2015) Table S1 into a lean, analysis-ready CSV.
#   One row per species: taxonomy, sample size, body mass, brain volume,
#   the ICA morphometrics (foramen/lumen radii, shear stress) and the derived
#   flow terms (total QICA, Q/Vbr). Everything comes from the paper's own
#   supplementary spreadsheet (TableS1.xlsx) -- no crosswalk, no comparison
#   files. Body-mass reference numbers (1-12) are kept as a separate key.
#
#   Seymour RS, Bosiocic V, Snelling EP (2015). Scaling of cerebral blood
#   perfusion in primates and marsupials. J. Exp. Biol.
#
# Input
#   Seymour_etal_2015_TableS1_snapshot.xlsx        sheet: TableS1
#     Frozen, journal-faithful copy of the supplement's TableS1.xlsx (all cleaning
#     happens here in R, never in the snapshot). Rows carry section markers
#     (Primates / Haplorrhini / Strepsirrhini / Diprotodontia), two header rows per
#     block, the species data rows, and footnote lines "1  Smith, R. J., ..."
#     holding the body-mass references.
#
# Outputs
#   Seymour_etal_2015_TableS1.csv                  one row per species (60 rows)
#   Seymour_etal_2015_TableS1_references.csv       body-mass reference key (1-12)
#   <DOI>.tsv in __Public/comparative-data/        tab-separated copy named by the
#                                                  item's encoded DOI (from __ReadMe.xlsx)
#
# Column definitions (from the paper):
#   Mb   = body mass (g);            Vbr  = brain volume (ml);
#   rICF = foramen radius (cm);      rICA = lumen radius (cm);
#   tau  = shear stress (dyne cm-2); QICA = total internal carotid flow (cm3 s-1),
#          summed over both arteries, Q = (tau * pi * r^3) / (4 * eta);
#   Q/Vbr = flow per unit brain volume (cm3 s-1 ml-1).
#
# Cleaning: body mass and brain volume carried float-representation noise in the
# source (e.g. 371.5000000000003, 7929.999999999999); both are rounded to 6
# significant figures to recover the intended values. The morphometric and flow
# columns are kept at full precision. Section markers set Clade/Suborder; the
# spaced binomial is emitted as the canonical `Species` column.

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

source_file  <- "Seymour_etal_2015_TableS1_snapshot.xlsx"
source_sheet <- "TableS1"
output_file  <- paste0(item_name, ".csv")
ref_file     <- paste0(item_name, "_references.csv")

# ---- helpers ---------------------------------------------------------------

parse_value <- function(x) parse_number(x, na = c("", "-", "NA", "n.a."))
clean6      <- function(x) signif(x, 6)   # strip float-representation noise
is_int_str  <- function(x) str_detect(replace_na(x, ""), "^[0-9]+$")

# Curated short labels for the 12 body-mass references (footnote key).
ref_short <- c(
  "1"  = "Smith & Jungers 1997",       "2"  = "Milton & May 1976",
  "3"  = "Soligo 2006",                "4"  = "Geiser & Baudinette 1990",
  "5"  = "White, Phillips & Seymour 2006", "6" = "Goudberg 1990",
  "7"  = "Sander, Short & Turner 1997","8"  = "Myers 2001",
  "9"  = "Dawson & Degabriele 1973",   "10" = "McNab 2002",
  "11" = "Tyndale-Biscoe 2005",        "12" = "Damuth & MacFadden 1990"
)

# ---- read the raw sheet (all text; we control parsing) ---------------------

raw <- read_excel(source_file, sheet = source_sheet,
                  col_names = FALSE, col_types = "text", na = c(""))
# Fixed 12-column layout: Species, Common name, Family, Number, Body mass,
# Reference, Brain volume, Foramen radius, Lumen radius, Shear stress,
# Total QICA, Total Q/Vbr.
names(raw) <- paste0("V", seq_len(ncol(raw)))
raw <- raw %>% mutate(c1 = str_squish(V1))

# ---- carry the clade / suborder section markers downward -------------------

sec <- raw %>%
  mutate(
    clade_set    = case_when(
      c1 == "Primates"                          ~ "Primates",
      c1 %in% c("Haplorrhini", "Strepsirrhini") ~ "Primates",
      c1 == "Diprotodontia"                     ~ "Diprotodontia",
      TRUE                                      ~ NA_character_
    ),
    suborder_set = case_when(
      c1 %in% c("Haplorrhini", "Strepsirrhini") ~ c1,
      c1 == "Diprotodontia"                     ~ "Diprotodontia",
      TRUE                                      ~ NA_character_
    )
  ) %>%
  fill(clade_set, suborder_set, .direction = "down") %>%
  rename(Clade = clade_set, Suborder = suborder_set)

# ---- species data rows: Family present (not the header) + integer Number ---

data_rows <- sec %>%
  filter(!is.na(V3), V3 != "Family", is_int_str(V4))

final.dataframe <- data_rows %>%
  transmute(
    Species                 = str_squish(V1),          # canonical spaced binomial
    Common_name             = str_squish(V2),
    Family                  = str_squish(V3),
    Clade,
    Suborder,
    N_individuals           = as.integer(parse_value(V4)),
    Body_mass_g             = clean6(parse_value(V5)),  # noise-stripped
    Body_mass_ref           = as.integer(parse_value(V6)),
    Body_mass_ref_short     = unname(ref_short[as.character(as.integer(parse_value(V6)))]),
    Brain_volume_ml         = clean6(parse_value(V7)),  # noise-stripped
    Foramen_radius_cm       = parse_value(V8),          # full precision
    Lumen_radius_cm         = parse_value(V9),
    Shear_stress_dyne_cm2   = parse_value(V10),
    Total_QICA_cm3_s        = parse_value(V11),
    Total_Q_per_Vbr_cm3_s_ml = parse_value(V12)
  )

# ---- body-mass reference key: parse the footnote lines ---------------------
# Footnote rows are "<n>  <full citation>" in column A with no Family value.

references <- sec %>%
  filter(is.na(V3), str_detect(replace_na(V1, ""), "^\\s*[0-9]+\\s+\\S")) %>%
  transmute(
    ref_number    = as.integer(str_match(V1, "^\\s*([0-9]+)")[, 2]),
    full_citation = str_squish(str_remove(V1, "^\\s*[0-9]+\\s+"))
  ) %>%
  filter(!is.na(ref_number)) %>%
  distinct(ref_number, .keep_all = TRUE) %>%
  arrange(ref_number) %>%
  transmute(ref_number,
            short = unname(ref_short[as.character(ref_number)]),
            full_citation)

options(scipen = 999)

## ---- SAVE: local CSVs + DOI-named TSV in the shared database folder --------

write.csv(final.dataframe, file = output_file, row.names = FALSE)
message("Wrote ", output_file, "  (", nrow(final.dataframe), " rows)")
write.csv(references, file = ref_file, row.names = FALSE)
message("Wrote ", ref_file, "  (", nrow(references), " references)")

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
        " | references: ", nrow(references))
counts <- final.dataframe %>% count(Clade, Suborder, name = "n_species")
print(as.data.frame(counts), row.names = FALSE)
