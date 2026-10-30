## Kochiyama_etal_2018 — Extended Data Figure 4
## Relative volumes (region volume / mean MH volume; MH = 1.0) of the 13 parcellated
## regions among NT, EH and MH under the individual-brain (4 x 1185) reconstruction,
## read from the Extended Data Figure 4 bar graphs (figure-digitized, +/-0.02).
##
## Reads the frozen snapshot Kochiyama_etal_2018_ExtendedDataFigure4_snapshot.csv
## (caption line, header, 13 region rows, one trailing Cohen's d note line).
## Wide layout is kept (one column per group: NT_rel / EH_rel / MH_rel); the taxon
## each column header stands for is recorded in
## reference_tables/Kochiyama_etal_2018_ExtendedDataFigure4_taxa.csv.
## Sibling items Figure3A / Figure3B / ExtendedDataTable1 / ExtendedDataTable3 have their own scripts.

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

raw <- read.csv(paste0(item_name, "_snapshot.csv"), skip = 1, fill = TRUE,
                colClasses = "character", check.names = FALSE, na.strings = c("", "NA"))
raw <- raw[raw$Region %in% names(structure_map), , drop = FALSE]   # drops the trailing Cohen's d note line
clean <- data.frame(
  Region_code = raw$Region,
  Structure = unname(structure_map[raw$Region]),
  Subregion = unname(subregion_map[raw$Region]),
  NT_rel = as_num(raw$NT_rel),
  EH_rel = as_num(raw$EH_rel),
  MH_rel = as_num(raw$MH_rel),
  source = "Kochiyama_etal_2018",
  note = "Ext Data Fig 4 (individual-brain recon); figure-digitized (+/-0.02)",
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
