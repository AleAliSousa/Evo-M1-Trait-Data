## Chaplin, Yu, Soares, Gattass & Rosa 2013, J Neurosci 33(38):15120-15125 — Results text
## doi:10.1523/JNEUROSCI.2909-13.2013 · Teams Rosa (Monash) + Gattass (UFRJ).
## "A conserved pattern of differential expansion of cortical areas in simian primates."
## No numbered data table — the three cortical surface areas are printed in the Results text
## (made-a-table case, cf. Collins_etal_2016 text item; item-number precedent:
## Kochiyama_etal_2018_FossilSpecimensText). ONE individual per species:
##   marmoset  (Callithrix jacchus, 500 g female; Paxinos et al. 2012 atlas model)   963 mm2
##   capuchin  (Cebus apella, 3.3 kg male; unpublished Gattass-lab histology)       6796 mm2
##   macaque   (Macaca mulatta, F99 atlas individual; body mass not reported)     11,876 mm2
## Areas are MID-THICKNESS contour models in CARET (not pial), single hemisphere (L/R not
## stated). Capuchin corrected for post-fixation but NOT perfusion shrinkage. The F99 macaque
## is a widely reused atlas specimen — specimen-crosswalk before independence claims.
## Snapshot frozen from the curator's transcription of the folder PDF; all cleaning here.

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # Chaplin_etal_2013_ResultsText
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "made_a_table"))
raw <- raw[!is.na(raw$Species) & !grepl("^Transcribed", raw$Species), ]
num <- function(x) as.numeric(gsub("[^0-9.]", "", x))             # "11,876" -> 11876

specimen <- c(
  "Callithrix jacchus" = "single female, 500 g; model reconstructed from the Paxinos et al. 2012 marmoset atlas",
  "Cebus apella"       = "single male, 3.3 kg; unpublished Gattass-lab histology dataset",
  "Macaca mulatta"     = "F99 atlas individual (Van Essen 2004); body mass not reported")
hemi <- c(
  "Callithrix jacchus" = "one hemisphere (not stated; single-hemisphere CARET model)",
  "Cebus apella"       = "one hemisphere (not stated; single-hemisphere CARET model)",
  "Macaca mulatta"     = "one hemisphere (F99 is a single-hemisphere atlas model)")
note <- c(
  "Callithrix jacchus" = "n=1; mid-thickness (not pial) surface",
  "Cebus apella"       = paste0("n=1; corrected for post-fixation shrinkage but NOT perfusion ",
                                "shrinkage - possible slight underestimate; mid-thickness surface"),
  "Macaca mulatta"     = paste0("n=1; atlas specimen widely reused across the literature - check ",
                                "specimen crosswalk before treating as independent of other ",
                                "F99-derived values; mid-thickness surface"))
mass <- c("Callithrix jacchus" = 500, "Cebus apella" = 3300, "Macaca mulatta" = NA)

clean <- data.frame(
  Species     = raw$Species,
  common_name = raw$`Common name`,
  specimen    = unname(specimen[raw$Species]),
  structure   = "cerebral cortex",
  hemisphere  = unname(hemi[raw$Species]),
  method      = "mid-thickness contour surface model in CARET; serial reconstruction from coronal sections",
  surface_area_mm2 = num(raw$`Surface area (mm2)`),
  body_mass_g      = unname(mass[raw$Species]),
  note = unname(note[raw$Species]),
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " species rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found (Item number cell still blank?); TSV skipped.")
}
