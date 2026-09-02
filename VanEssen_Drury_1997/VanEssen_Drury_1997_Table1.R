## Van Essen & Drury 1997, J Neurosci 17(18):7079-7102 — Table 1 + text V1 values
## doi:10.1523/JNEUROSCI.17-18-07079.1997 · surface-based atlas of the Visible Man.
## ONE individual: the Visible Man (Visible Human Project, NLM) — a digital atlas built from
## 1 mm section images of a single adult male cadaver. Areas are tile-area sums on the 3-D
## reconstructions (NOT flat-map areas; authors call their total a likely slight underestimate).
## Table 1: per-hemisphere neocortex + 5 lobes + sulcal/gyral totals. Text adds V1 L/R
## ("average-sized V1" from Rademacher et al. 1993 architectonic extents mapped onto the atlas).
## REGISTRY NOTE: the Sheet1 row is currently named `VanEssen_etal_1997_Table1` with artifact
## author "New Collective, A."; the paper has exactly two authors (verified against the PDF).
## Rename the row to `VanEssen_Drury_1997_Table1` (roadmap item 1) — until then the registry
## lookup below warns and skips the TSV. Encoded key (DOI-based) is unaffected.
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
meth_v1 <- paste0("surface reconstruction; average-sized V1 (Rademacher et al. 1993 ",
                  "architectonic extents mapped to Visible Man)")

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

## ---- text V1 rows ----
v1 <- data.frame(structure = "V1", hemisphere = c("right", "left"),
                 area_cm2 = c(22, 26), pct_neocortex = c(2.7, 3.4),
                 method = meth_v1,
                 where_in_paper = "text (Results, 'Estimating the extent of area V1')",
                 stringsAsFactors = FALSE)

both <- rbind(t1, v1)
clean <- data.frame(
  Species = "Homo sapiens", common_name = "human", specimen = spec,
  structure = both$structure, hemisphere = both$hemisphere, method = both$method,
  area_cm2 = both$area_cm2, pct_neocortex = both$pct_neocortex,
  where_in_paper = both$where_in_paper,
  source = item_name, stringsAsFactors = FALSE, check.names = FALSE
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
  else warning("Item encoded not found (registry row still named VanEssen_etal_1997_Table1?); TSV skipped.")
}
