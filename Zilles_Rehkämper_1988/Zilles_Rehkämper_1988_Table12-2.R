# Zilles_Rehkämper_1988_Table12-2.R
#
# Preparation step. Turn the journal-faithful snapshot of Zilles & Rehkamper
# (1988) Table 12-2 -- the fresh volumes of the brain components of the ORANG-
# UTAN (Pongo) and their percentage of total brain volume -- into a lean,
# analysis-ready CSV. Output comes from the snapshot only.
#
# Layout note (this table is NOT the usual species-as-rows table): Table 12-2 is
# a SINGLE-SPECIMEN table for Pongo with the brain STRUCTURES down the rows and
# two value columns (Fresh Volume in cc3 = cm3, and percentage of total brain
# volume). The snapshot keeps that printed orientation, the printed indentation
# of sub-components (e.g. White matter under Neocortex), the caption and the
# "excluding ventricles and nerves" footnote. There are no species-name
# superscripts to translate (the single "1" superscript is the footnote marker
# on the percentage header).
#
# THIS script reads past the caption+header (data from row 3), drops the footnote
# row (no numeric volume), squishes the structure label (removing the indentation
# the snapshot uses for the printed sub-rows), converts the printed cc3 volumes to
# the project unit mm3 (x1000), and writes one row per structure for Pongo.
#
# HIERARCHY (added 2026-09-18). Squishing the label threw away the printed
# indentation, and with it the fact that several rows are COMPONENTS of the row
# above them -- which is exactly what a consumer needs to know before treating
# "Paleocortex" (2.4) as comparable with a Stephan palaeocortex (it is not: the
# indented "Corpus amygdaloideum" 1.4 is part of it). The CSV now carries:
#   printed_indent    0/1 -- was the label indented on the printed page (taken
#                     from the snapshot's leading spaces, i.e. as printed)
#   parent_structure  the row this one is a component of, or "" for a
#                     top-level component of the whole brain
#   component_of_parent_check  for every parent, the components below it sum to
#                     the parent's printed volume; asserted at build time
# The printed indentation is followed EXCEPT for one row: "Gray (without area
# striata)" is printed flush-left, yet Gray (without area striata) 129.9 + Gray
# area striata 8.4 + White matter 81.5 = Neocortex 219.8 exactly, so it is a
# Neocortex component and is recorded as such (printed_indent = 0 preserves
# what the page shows). Likewise the six flush-left brain divisions sum to the
# whole brain, and Telencephalon = its six flush-left telencephalic components.
#
# Input  : Zilles_Rehkämper_1988_Table12-2_snapshot.xlsx   sheet: Table12-2
# Outputs: Zilles_Rehkämper_1988_Table12-2.csv             one row per structure (18)
#          <DOI/PMID>.tsv in __Public/comparative-data/      named from __ReadMe.xlsx

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
snapshot_file  <- "Zilles_Rehkämper_1988_Table12-2_snapshot.xlsx"
snapshot_sheet <- "Table12-2"
output_file    <- "Zilles_Rehkämper_1988_Table12-2.csv"
header_rows    <- 2L   # row1 caption + row2 header; data (and the footnote) from row 3

pos <- c("structure_disp","fresh_volume_cc3","pct_total_brain")
num <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "__"))
sup_class <- "[¹²³⁴⁵⁶⁷⁸⁹⁰]"

## trim_ws = FALSE: the leading spaces ARE data here (the printed indentation
## that printed_indent records); readxl strips them by default.
raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text", trim_ws = FALSE)
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

## ---- the printed hierarchy ---------------------------------------------------
## parent_structure per printed label. Sub-components are the indented rows of the
## snapshot plus the one flush-left component explained in the header. The
## telencephalic components are the flush-left rows between Telencephalon and the
## end of the table; the six brain divisions have no parent ("").
PARENT <- c(
  "Medulla oblongata"           = "",
  "Cerebellum (without pons)"   = "",
  "Pons"                        = "",
  "Mesencephalon"               = "",
  "Diencephalon"                = "",
  "Telencephalon"               = "",
  "Neocortex"                   = "Telencephalon",
  "Gray (without area striata)" = "Neocortex",     # printed flush-left; component by arithmetic (see header)
  "Gray area striata"           = "Neocortex",
  "White matter"                = "Neocortex",
  "Hippocampus"                 = "Telencephalon",
  "Regio entorhinalis"          = "Telencephalon",
  "Paleocortex"                 = "Telencephalon",
  "Regio praepiriformis"        = "Paleocortex",
  "Corpus amygdaloideum"        = "Paleocortex",
  "Septum"                      = "Telencephalon",
  "Corpus striatum"             = "Telencephalon",
  "Globus pallidus"             = "Corpus striatum"  # printed indented under Corpus striatum
)

final.dataframe <- dat %>%
  filter(!is.na(structure_disp), !is.na(num(fresh_volume_cc3))) %>%   # structure rows = numeric volume (drops footnote)
  transmute(
    Species = "Pongo sp.",
    structure          = str_squish(str_remove_all(structure_disp, sup_class)),  # squish removes the printed indentation
    fresh_volume_cc3   = num(fresh_volume_cc3),
    volume_mm3         = num(fresh_volume_cc3) * 1000,                # cc3 (=cm3) -> mm3 (project unit)
    pct_total_brain    = num(pct_total_brain),
    printed_indent     = as.integer(grepl("^\\s", structure_disp)),  # 1 = indented on the printed page
    parent_structure   = unname(PARENT[structure])
  )

## Every printed label must be in the hierarchy map (a renamed snapshot cell would
## otherwise silently get an NA parent), and every parent must be reproduced by
## the sum of its components -- that arithmetic is the evidence for the map.
stopifnot(!anyNA(final.dataframe$parent_structure))
stopifnot(setequal(final.dataframe$structure, names(PARENT)))
tol <- 0.051   # printed to 1 dp; sums of 1-dp values can drift by < 0.05
for (p in setdiff(unique(final.dataframe$parent_structure), "")) {
  parts <- final.dataframe$fresh_volume_cc3[final.dataframe$parent_structure == p]
  whole <- final.dataframe$fresh_volume_cc3[final.dataframe$structure == p]
  ## Corpus striatum (11.5) is not the sum of its single indented sub-row
  ## (Globus pallidus 1.8) -- the pallidum is a PART of it, the caudate/putamen
  ## remainder is not printed separately. Only parents whose components are
  ## printed in full are checked as sums.
  if (p == "Corpus striatum") { stopifnot(sum(parts) < whole); next }
  if (abs(sum(parts) - whole) > tol)
    stop("components of '", p, "' sum to ", sum(parts), " but the parent prints ", whole, call. = FALSE)
}
## the six brain divisions sum to the whole brain the percentages are relative to
top <- final.dataframe %>% filter(parent_structure == "")
stopifnot(abs(sum(top$pct_total_brain) - 100) <= 0.15)
## the snapshot's indentation must have survived the read (trim_ws = FALSE above)
## and must sit exactly on the five rows the printed page indents
stopifnot(identical(final.dataframe$structure[final.dataframe$printed_indent == 1L],
                    c("Gray area striata", "White matter", "Regio praepiriformis",
                      "Corpus amygdaloideum", "Globus pallidus")))
message("hierarchy check: ", sum(final.dataframe$parent_structure != ""), " component rows under ",
        n_distinct(final.dataframe$parent_structure[final.dataframe$parent_structure != ""]),
        " parents; all component sums reproduce their parent (whole brain = ",
        format(sum(top$fresh_volume_cc3)), " cc3)")

options(scipen = 999)

## ---- SAVE: local CSV + DOI/PMID-named TSV ----
# The on-disk files follow the folder name (ASCII "Zilles__Rehkamper"); the
# __ReadMe.xlsx registry Item name uses the umlaut + single underscore, so the
# registry key is set explicitly for the Item-encoded (DOI/ISBN) lookup (override).
registry_item_name <- "Zilles_Rehkämper_1988_Table12-2"   # as printed in __ReadMe.xlsx (Item name)
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

## ---- also write the DOI/PMID-coded TSV to __Public/comparative-data/ (skipped if shared repo absent) ----
tsv_dir <- file.path(base, "__Public/comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(registry_item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI/ISBN) for '", registry_item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}
