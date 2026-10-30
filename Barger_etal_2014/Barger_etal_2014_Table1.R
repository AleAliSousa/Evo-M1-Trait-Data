# Barger_etal_2014_Table1.R
#
# Barger, N., Hanson, K. L., Teffer, K., Schenker-Ahmed, N. M., & Semendeferi, K. (2014).
# Evidence for evolutionary specialization in human limbic structures. Front Hum Neurosci, 8, 277.
# https://doi.org/10.3389/fnhum.2014.00277  (__ReadMe item: Barger_etal_2014 / "Table 1").
#
# Table 1 = stereological volumes (cubic centimetres, cc) of the amygdala (lateral, basal,
# accessory basal, central nuclei, and whole-amygdala total), hippocampus and striatum in
# individual hominoid specimens. NB: values are for ONE HEMISPHERE per specimen (footnote),
# i.e. NOT both-hemisphere sums -- so they are not directly comparable to Barger 2007 _total
# or the Stephan both-hemisphere volumes without accounting for this.
#
# Species carry footnote markers: '*' = case included in Barger et al. 2007; trailing 'a' =
# paraffin-embedded (Semendeferi 1998 / Barger 2007), 'b' = cryosectioned (Barger 2012). A
# dash (-) = not measured/included for that case. Multiple individuals per species.
# Output comes from the snapshot only.
#
# Input  : Barger_etal_2014_Table1_snapshot.xlsx        sheet: Table1
# Outputs: Barger_etal_2014_Table1.csv                  one row per specimen (20)
#          <DOI>_Table1.tsv in __Public/comparative-data/  (named from __ReadMe.xlsx)

suppressPackageStartupMessages({
  library(readxl); library(readr); library(dplyr); library(stringr)
})
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
## NOTE: the previous `if (rstudioapi::isAvailable()) setwd(...)` guard silently did nothing
## when run non-interactively via Rscript (as in run_all_scripts_v2.R), leaving the working
## directory at the repo root and breaking every relative path below.
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

snapshot_file  <- "Barger_etal_2014_Table1_snapshot.xlsx"
snapshot_sheet <- "Table1"
output_file    <- "Barger_etal_2014_Table1.csv"
header_rows    <- 3L

pos <- c("species_disp","lateral","basal","accessory_basal","central","total","hippocampus","striatum")
num <- function(x) parse_number(as.character(x), na = c("", "-", "–", "—", "NA", "n.a."))

raw <- read_excel(snapshot_file, sheet = snapshot_sheet, col_names = FALSE, col_types = "text")
dat <- raw %>% slice(-(seq_len(header_rows)))
names(dat)[seq_along(pos)] <- pos

val_cols <- c("lateral","basal","accessory_basal","central","total","hippocampus","striatum")

clean <- dat %>%
  filter(!is.na(species_disp), species_disp != "",
         rowSums(!is.na(sapply(across(all_of(val_cols)), num))) > 0)   # keep rows with >=1 numeric value (drops footnote)

# species markers: '*'/star = in Barger 2007; trailing a/b = processing (paraffin/cryo)
nomark <- str_squish(str_remove_all(clean$species_disp, "[∗*,]"))
m      <- str_match(nomark, "^(.*?)\\s*([ab])\\s*$")
binom  <- ifelse(is.na(m[,2]), nomark, str_squish(m[,2]))
proc   <- m[,3]

final.dataframe <- tibble(
  case_index                  = seq_len(nrow(clean)),
  species                     = binom,
  processing                  = proc,                                   # a = paraffin, b = cryosectioned
  in_barger2007               = ifelse(str_detect(clean$species_disp, "∗|\\*"), "Y", "N"),
  amygdala_lateral_cc         = num(clean$lateral),
  amygdala_basal_cc           = num(clean$basal),
  amygdala_accessory_basal_cc = num(clean$accessory_basal),
  amygdala_central_cc         = num(clean$central),
  amygdala_total_cc           = num(clean$total),
  hippocampus_cc              = num(clean$hippocampus),
  striatum_cc                 = num(clean$striatum),
  source                      = "Barger_etal_2014"
)

options(scipen = 999)

## ---- SAVE: local CSV + DOI-named TSV (named from __ReadMe.xlsx 'Item encoded') ----
## item_name already resolved above (self-contained path block) -- matches this file's name.
write.csv(final.dataframe, file = paste0(item_name, ".csv"), row.names = FALSE)
message("Wrote ", item_name, ".csv  (", nrow(final.dataframe), " rows)")

readme_file <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__ReadMe.xlsx"
tsv_dir     <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__Public/comparative-data/"
filecodes    <- read_excel(readme_file, sheet = "Sheet1")
norm_key     <- function(x) tolower(gsub("[ _]", "", as.character(x)))
item_encoded <- filecodes$"Item encoded"[match(norm_key(item_name), norm_key(filecodes$"Item name"))]
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(final.dataframe, file = paste0(tsv_dir, item_encoded, ".tsv"), sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_dir, item_encoded, ".tsv")
}
