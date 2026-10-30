# Baker_etal_2025_SupplementaryData1.R
#
# Purpose
#   Snapshot preparation. Baker, Barton & Venditti (2025) is a SECONDARY
#   compilation: the hand-bone, brain/body and behavioural values are drawn from
#   many primary sources listed on the supplement's second sheet ("References").
#   This script turns the faithful snapshot of Supplementary Data 1 into a lean,
#   analysis-ready CSV in which the numeric reference tokens carried in the
#   "Bone References" / "Brain References" columns are RESOLVED to their primary
#   citations (from the References sheet). Column meanings and units are
#   documented in reference_tables/Baker_etal_2025_definitions.csv; the full
#   primary references are in reference_tables/Baker_etal_2025_references.csv.
#
# Input
#   Baker_etal_2025_SupplementaryData1_snapshot.xlsx   sheets: Data, References
#     (a faithful copy of the published supplement 42003_2025_8686_MOESM3_ESM.xlsx)
#
# Outputs
#   Baker_etal_2025_SupplementaryData1.csv             one row per taxon (178 rows)
#   <DOI>.tsv in __Public/comparative-data/            tab-separated copy named by the
#                                                      item's encoded DOI (from __ReadMe.xlsx)
#
# Only obvious in-place fixes are applied: values parsed to numbers; the
# restricted-data placeholder "*" (Lemelin 1996) parsed to NA and flagged;
# reference tokens split on ';'/',', the trailing '*' on "40*" stripped, and each
# token mapped to a short primary citation. Nothing is invented -- every value and
# every citation comes from the paper via the snapshot.

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

snapshot_file <- paste0(item_name, "_snapshot.xlsx")
output_file   <- paste0(item_name, ".csv")

# ---- helpers ---------------------------------------------------------------

# numeric parse; blanks and the "*" restricted-data placeholder -> NA
parse_value <- function(x) parse_number(as.character(x), na = c("", "-", "NA", "n.a.", "*"))
as_int      <- function(x) suppressWarnings(as.integer(as.character(x)))

# ---- primary-reference map (built from the "References" sheet) --------------
# short citations keyed by the reference number used in the Data sheet.
ref_short <- c(
  "1"="Boyer et al. 2016","2"="Boyer et al. 2013","3"="Almecija et al. 2012","4"="Patel 2010",
  "5"="Almecija et al. 2015","6"="Rolian (pers. comm.; Rolian 2009; Nelson et al. 2011)",
  "7"="Prang et al. 2021","8"="Tague 1997","9"="Feix et al. 2015","10"="Almecija et al. 2014",
  "11"="Hart 2018","12"="Kirk et al. 2008","13"="Jungers et al. 2005","14"="Drapeau & Ward 2007",
  "15"="Green & Gordon 2008","16"="Kivell et al. 2020","17"="Kivell et al. 2011","18"="Frost et al. 2015",
  "19"="Kivell et al. 2015","20"="Ward et al. 2014","21"="Moya-Sola et al. 2005","22"="Richmond et al. 2020",
  "23"="Gebo et al. 2015","24"="Jablonski et al. 2002","25"="MacPhee & Meldrum 2006","26"="Harrington et al. 2016",
  "27"="Venditti et al. 2024","28"="Barton & Venditti 2014","29"="Snodgrass et al. 2007","30"="Schwartz et al. 2005",
  "31"="Puschel et al. 2024","32"="Frahm et al. 1982; Stephan et al. 1981; Stephan et al. 1984",
  "33"="Aristide et al. 2015","34"="Jones et al. 2009 (PanTHERIA)","35"="Isler et al. 2008",
  "36"="Gonzales et al. 2015","37"="Gingerich & Gunnell 2005","38"="Halenar-Price & Tallman 2019",
  "39"="Perry et al. 2018","40"="Lemelin 1996 (restricted)"
)
resolve_refs <- function(x) {
  vapply(x, function(v) {
    if (is.na(v) || !nzchar(v)) return(NA_character_)
    toks <- str_trim(str_split(v, "[;,]")[[1]])
    toks <- str_remove(toks[nzchar(toks)], "\\*$")            # drop the '*' on "40*"
    paste(ifelse(toks %in% names(ref_short), ref_short[toks], toks), collapse = "; ")
  }, character(1))
}
clean_refs <- function(x) {                                    # keep numeric tokens, drop '*'
  vapply(x, function(v) {
    if (is.na(v) || !nzchar(v)) return(NA_character_)
    toks <- str_trim(str_split(v, "[;,]")[[1]])
    paste(str_remove(toks[nzchar(toks)], "\\*$"), collapse = ";")
  }, character(1))
}

# ---- read the snapshot Data sheet ------------------------------------------
dat <- read_excel(snapshot_file, sheet = "Data", col_types = "text", na = c(""))

bone_log <- grep("^log10_(mc|pp|ip|dp)[0-9]_mm$", names(dat), value = TRUE)

# ---- assemble the lean table (snapshot only) -------------------------------
final.dataframe <- dat %>%
  mutate(
    bone_data_restricted = if_else(rowSums(across(all_of(bone_log), ~ .x == "*"),
                                           na.rm = TRUE) > 0, "TRUE", "FALSE")
  ) %>%
  transmute(
    Species                  = str_replace_all(`Tree Name`, "_", " "),
    Tree_Name                = `Tree Name`,
    Tree_Clade,
    Individuals              = `Individual(s)`,
    Sex, Side,
    across(all_of(bone_log), parse_value),
    Bone_References          = clean_refs(`Bone References`),
    Bone_References_resolved = resolve_refs(`Bone References`),
    bone_data_restricted,
    log10_brain_g            = parse_value(log10_brain_g),
    brain_notes,
    log10_body_g             = parse_value(log10_body_g),
    body_notes,
    log10_neocortex_cm3      = parse_value(log10_neocortex_cm3),
    log10_cerebellum_cm3     = parse_value(log10_cerebellum_cm3),
    Brain_References          = clean_refs(`Brain References`),
    Brain_References_resolved = resolve_refs(`Brain References`),
    Tool_Use                 = as_int(`Tool-Use`),
    Single_Individual        = as_int(`Single Individual?`),
    Captive_Only             = as_int(`Captive Only?`),
    Tool_Manufacture         = as_int(`Tool-Manufacture`),
    True_Tool_Use            = as_int(`True-Tool-Use`),
    Binocularity             = parse_value(Binocularity),
    peak_workspace           = parse_value(peak_workspace),
    relative_size            = parse_value(relative_size),
    real_size                = parse_value(real_size)
  )

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV in the shared database folder --------
write.csv(final.dataframe, file = output_file, row.names = FALSE, na = "")
message("Wrote ", output_file, "  (", nrow(final.dataframe), " rows)")

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
              sep = "\t", row.names = FALSE, na = "")
  message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
}

message("Rows: ", nrow(final.dataframe),
        " | rows with restricted bone data: ", sum(final.dataframe$bone_data_restricted == "TRUE"))
