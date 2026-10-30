## Kochiyama_etal_2018 — Extended Data Table 1
## Correspondence between the AAL atlas regions and the 13 parcellated brain regions.
## Atlas-correspondence table: no per-taxon rows, so no species column applies.
##
## Reads the frozen snapshot Kochiyama_etal_2018_ExtendedDataTable1_snapshot.csv
## (caption line, header, 13 rows: Region, Subregion, AAL_atlas_regions, Abbreviation).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

structure_map <- c("Fr SM"="FrontalLobe","Fr I"="FrontalLobe","Fr O"="FrontalLobe",
  "Sm"="SensorimotorCortex","Pa SI"="ParietalLobe","Pa TP"="ParietalLobe",
  "Te SM"="TemporalLobe","Te I"="TemporalLobe","Oc SM"="OccipitalLobe",
  "Oc I"="OccipitalLobe","Ce V"="Cerebellum","Ce A"="Cerebellum","Ce P"="Cerebellum")
subregion_map <- c("Fr SM"="superior and middle","Fr I"="inferior","Fr O"="orbitofrontal",
  "Sm"="whole (sensorimotor)","Pa SI"="superior and inferior","Pa TP"="temporo-parietal junction",
  "Te SM"="superior and middle","Te I"="inferior/medial","Oc SM"="superior and middle",
  "Oc I"="inferior","Ce V"="vermis","Ce A"="anterior","Ce P"="posterior")
as_num <- function(x) suppressWarnings(as.numeric(x))

raw <- read.csv(paste0(item_name, "_snapshot.csv"), skip = 1,
                colClasses = "character", check.names = FALSE, na.strings = c("", "NA"))
clean <- data.frame(
  Region_code = raw$Abbreviation,
  Structure = unname(structure_map[raw$Abbreviation]),
  Subregion = unname(subregion_map[raw$Abbreviation]),
  AAL_atlas_regions = raw$AAL_atlas_regions,
  n_AAL_regions = lengths(strsplit(raw$AAL_atlas_regions, ";", fixed = TRUE)),
  source = "Kochiyama_etal_2018",
  stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 13L, !anyNA(clean$Structure), !anyNA(clean$Subregion))

write.csv(clean, paste0(item_name, ".csv"), row.names = FALSE)

## public TSV: Item encoded looked up by Item name in __ReadMe.xlsx, written to __Public/comparative-data/
if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx was not found; public TSV skipped.")
} else {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else {
    write.table(clean, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = FALSE)
  }
}
message(item_name, ": ", nrow(clean), " rows")
