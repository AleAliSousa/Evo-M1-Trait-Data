## Barger N, Stefanacci L, Semendeferi K (2007), Am J Phys Anthropol 134(3):392-403
## "A comparative volumetric analysis of the amygdaloid complex and basolateral division
##  in the human and ape brain."  Table 1 (per-specimen volumes, cm3).
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; cleaning happens here.

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
options(scipen = 999)

raw <- read.csv("Barger_etal_2007_Table1_snapshot.csv", check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "NA"))

binom <- c(Human="Homo sapiens", Chimpanzee="Pan troglodytes", Bonobo="Pan paniscus",
           Gorilla="Gorilla gorilla", Orangutan="Pongo pygmaeus", Gibbon="Hylobates lar")

# Forward-fill species from the group-header rows; keep only specimen rows.
grp <- NA_character_; keep <- logical(nrow(raw)); sp <- character(nrow(raw))
for (i in seq_len(nrow(raw))) {
  g <- raw[["Species_group"]][i]
  if (!is.na(g) && g %in% names(binom)) { grp <- unname(binom[g]); keep[i] <- FALSE }
  else { keep[i] <- !is.na(raw[["Specimen ID"]][i]); sp[i] <- grp }
}
d <- raw[keep, ]; species <- sp[keep]

# Footnote markers on Specimen ID:  d = axial sections (subnuclei not collected);
#   e = basal & accessory basal not discriminable; f = left damaged, right doubled in analysis.
sid <- d[["Specimen ID"]]
marker <- ifelse(grepl("[def]$", sid), sub("^.*([def])$", "\\1", sid), "")
specimen <- sub("[def]$", "", sid)

en <- function(x) suppressWarnings(as.numeric(ifelse(x %in% c("–","-"), NA, x)))
tot <- function(a, b) ifelse(is.na(en(a)) | is.na(en(b)), NA_real_, round(en(a) + en(b), 4))

clean <- data.frame(
  species, specimen, age = d$Age, sex = d$Sex,
  hemispheres_cm3 = en(d[["Hemi cm3"]]),
  amygdaloid_complex_L = en(d[["Amygdaloid complex L"]]), amygdaloid_complex_R = en(d[["Amygdaloid complex R"]]),
  amygdaloid_complex_total = tot(d[["Amygdaloid complex L"]], d[["Amygdaloid complex R"]]),
  basolateral_L = en(d[["Basolateral L"]]), basolateral_R = en(d[["Basolateral R"]]),
  basolateral_total = tot(d[["Basolateral L"]], d[["Basolateral R"]]),
  lateral_L = en(d[["Lateral L"]]), lateral_R = en(d[["Lateral R"]]),
  lateral_total = tot(d[["Lateral L"]], d[["Lateral R"]]),
  basal_L = en(d[["Basal L"]]), basal_R = en(d[["Basal R"]]),
  basal_total = tot(d[["Basal L"]], d[["Basal R"]]),
  accessory_basal_L = en(d[["Accessory basal L"]]), accessory_basal_R = en(d[["Accessory basal R"]]),
  accessory_basal_total = tot(d[["Accessory basal L"]], d[["Accessory basal R"]]),
  section_plane = ifelse(marker == "d", "axial", "coronal"),
  note = ifelse(marker == "", "",
              c(d="axial sections; subnuclei not collected",
              e="basal & accessory basal not discriminable (tissue damage)",
              f="left temporal damage; left subnuclei not collected (right hemisphere doubled in Barger's analysis)"
              )[marker]),
  source = "Barger_etal_2007", stringsAsFactors = FALSE
)
# amygdaloid_complex_total (whole amygdaloid complex, both hemispheres) is the column that maps to the
# Stephan "Amygdala". Species still to reconcile to _keys/Stephan/species_key.csv.
write.csv(clean, "Barger_etal_2007_Table1.csv", row.names = FALSE)

## ---- also write the DOI-coded TSV to __Public/comparative-data/ (consumed by __merging_volumes) ----
## The volume merge reads per-specimen rows and aggregates to species means (cm3 -> mm3) itself,
## using amygdaloid_complex_total -> Amygdala_Vol.mm3. Keep item_name == the "Item name" in __ReadMe.xlsx.
item_name <- "Barger_etal_2007_TABLE1"
tsv_dir   <- file.path(base, "__Public/comparative-data")
enc <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$"Item encoded"[match(item_name, fc$"Item name")]
} else NA_character_
if (is.na(enc) || !nzchar(enc)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file = file.path(tsv_dir, paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
}
