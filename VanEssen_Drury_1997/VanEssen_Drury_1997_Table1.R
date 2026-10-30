## Van Essen & Drury 1997, J Neurosci 17(18):7079-7102 — Table 1 + text values
## doi:10.1523/JNEUROSCI.17-18-07079.1997 · surface-based atlas of the Visible Man.
## ONE individual: the Visible Man (Visible Human Project, NLM) — a digital atlas built from
## 1 mm section images of a single adult male cadaver. Areas are tile-area sums on the 3-D
## reconstructions (NOT flat-map areas; authors call their total a likely slight underestimate).
## Table 1: per-hemisphere neocortex + 5 lobes + sulcal/gyral totals. A separate frozen text
## snapshot adds human V1 and visual-cortex estimates plus the macaque case 79-0 comparison.
## Snapshot frozen from the curator's transcription; all cleaning here (golden rule).

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
item_name <- tools::file_path_sans_ext(basename(.sp))            # VanEssen_Drury_1997_Table1
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
library(readxl)

spec <- paste0("Visible Man (Visible Human Project, National Library of Medicine; ",
               "single adult male cadaver digital atlas)")
meth_t1 <- paste0("surface reconstruction from Visible Man digital images (1 mm sections); ",
                  "tile-area sum on 3-D reconstruction")

## ---- Table 1 sheet: split "766 (100)" into value + percent ----
raw <- as.data.frame(read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                                sheet = "Table1"))
raw <- raw[!is.na(raw$Region) & !grepl("^Footnote", raw$Region), ]
num <- function(x) as.numeric(sub("^\\s*([0-9.]+).*$", "\\1", x))
pct <- function(x) as.numeric(sub("^.*\\(([0-9.]+)\\).*$", "\\1", x))
structure_map <- c("Total neocortex" = "cerebral neocortex", "Frontal" = "frontal lobe",
                   "Temporal" = "temporal lobe", "Parietal" = "parietal lobe",
                   "Occipital" = "occipital lobe", "Limbic" = "limbic lobe",
                   "Total sulcal" = "sulcal cortex (total)", "Total gyral" = "gyral cortex (total)")
t1 <- do.call(rbind, lapply(seq_len(nrow(raw)), function(i) {
  data.frame(structure  = structure_map[[raw$Region[i]]],
             hemisphere = c("left", "right"),
             area_cm2   = c(num(raw[i, 2]), num(raw[i, 3])),
             pct_neocortex = c(pct(raw[i, 2]), pct(raw[i, 3])),
             method = meth_t1, where_in_paper = "Table 1", stringsAsFactors = FALSE)
}))

table_clean <- data.frame(
  Species = "Homo sapiens", common_name = "human", specimen = spec,
  structure = t1$structure, hemisphere = t1$hemisphere, method = t1$method,
  area_cm2 = t1$area_cm2, pct_neocortex = t1$pct_neocortex,
  where_in_paper = t1$where_in_paper, data_role = "primary",
  source_note = "Table 1 tile-area sum on this atlas",
  stringsAsFactors = FALSE, check.names = FALSE
)

text_clean <- read.csv(file.path(folder, paste0(item_name, "_text_snapshot.csv")),
                       stringsAsFactors = FALSE, na.strings = "")
clean <- rbind(table_clean, text_clean[names(table_clean)])
clean$source <- item_name
append_flag <- function(x, flag) ifelse(!nzchar(x), flag, paste(x, flag, sep = "|"))
append_note <- function(x, note) ifelse(!nzchar(x), note, paste(x, note, sep = " "))
clean$source_flags <- ""
clean$source_issue_note <- ""

human <- clean$Species == "Homo sapiens"
clean$source_flags[human] <- append_flag(clean$source_flags[human], "single_atlas_individual")
clean$source_issue_note[human] <- append_note(
  clean$source_issue_note[human],
  "Human values come from one adult male cadaver digital atlas and do not estimate population variance."
)
table_rows <- human & clean$where_in_paper == "Table 1"
clean$source_flags[table_rows] <- append_flag(clean$source_flags[table_rows], "3d_reconstruction_not_flatmap")
clean$source_flags[table_rows] <- append_flag(clean$source_flags[table_rows], "total_likely_slight_underestimate")
clean$source_issue_note[table_rows] <- append_note(
  clean$source_issue_note[table_rows],
  "Areas are tile sums on a 3-D reconstruction, not flat-map areas; the authors describe total area as a likely slight underestimate."
)
human_v1 <- human & clean$structure == "V1"
clean$source_flags[human_v1] <- append_flag(clean$source_flags[human_v1], "secondary_value")

macaque <- clean$Species == "Macaca sp."
clean$source_flags[macaque] <- "secondary_reconstruction|single_case|species_unspecified|cross_study_macaque_total_conflict|cross_study_v2_fraction_conflict"
clean$source_issue_note[macaque] <- paste0(
  "This paper identifies the animal only as macaque and reuses case 79-0 from Drury et al. 1996a. ",
  "Its 72 cm2 neocortex differs from Felleman & Van Essen's 99.40 cm2 text / 99.70 cm2 table composite, ",
  "and its text gives V2 as approximately 9% versus 12.2% in Felleman & Van Essen Table 2. ",
  "Do not pool without reconciling specimen, method, and denominator."
)

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found; TSV skipped.")
}
