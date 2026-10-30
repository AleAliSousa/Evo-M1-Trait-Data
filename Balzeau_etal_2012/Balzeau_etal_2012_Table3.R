## Balzeau_etal_2012 — Table 3
## Size-corrected dimensions for the surface of the frontal, parieto-temporal
## and occipital lobes in the different analysed samples (Homo).
##
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; ALL cleaning
## happens here. The printed table has a two-tier header (sample group over
## n / Mean / V*), so it is read POSITIONALLY (col_names = FALSE) and reshaped to
## one tidy row per (sample x lobe).
##
## Note on measure: these are SIZE-CORRECTED surface dimensions (relative,
## dimensionless), not absolute surfaces or volumes. They are therefore NOT fed
## into __merging_volumes; the definitions record them as size-corrected.

options(scipen = 999)

suppressPackageStartupMessages({
  library(readr)
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

snapshot_file <- "Balzeau_etal_2012_Table3_snapshot.csv"

## ---- read the snapshot positionally ---------------------------------------
## Row 1 = caption, row 2 = sample-group tier, row 3 = n/Mean/V* tier,
## rows 4-6 = the three lobe rows. 5 samples x (n, Mean, V*) = 15 value columns.
raw <- read.csv(snapshot_file, header = FALSE, colClasses = "character",
                check.names = FALSE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

samples <- c(
  "Homo habilis s.l.",
  "African and Georgian Homo erectus s.l.",
  "Asian Homo erectus",
  "Neandertals s.l.",
  "AMH"
)

# canonical structure names for the three cortical lobes (surface)
lobe_map <- c(
  "Frontal lobes"          = "FrontalLobe",
  "Parieto-temporal lobes" = "Parieto-TemporalLobe",
  "Occipital lobes"        = "OccipitalLobe"
)

data_rows <- raw[4:6, , drop = FALSE]
as_num <- function(x) suppressWarnings(as.numeric(x))

out <- list()
for (i in seq_len(nrow(data_rows))) {
  lobe_printed <- trimws(data_rows[i, 1])
  for (s in seq_along(samples)) {
    off <- 1 + (s - 1) * 3            # first value column for this sample block
    out[[length(out) + 1]] <- data.frame(
      Sample_printed               = samples[s],
      Structure_Balzeau2012        = lobe_printed,
      Structure                    = unname(lobe_map[lobe_printed]),
      n                            = as.integer(as_num(data_rows[i, off + 1])),
      Mean_surface_sizecorrected   = as_num(data_rows[i, off + 2]),
      V_star                       = as_num(data_rows[i, off + 3]),
      source                       = "Balzeau_etal_2012",
      stringsAsFactors = FALSE
    )
  }
}
clean <- do.call(rbind, out)

stopifnot(nrow(clean) == length(samples) * nrow(data_rows))  # 15 rows

## ---- taxon assignment for the printed sample labels -------------------------
## Printed labels are fossil-group hypotheses (s.l.), kept verbatim in Sample_printed.
## The binomial, its basis and the taxon type come from the item-scoped lookup
## reference_tables/<item>_taxa.csv (one row per printed label).
taxa <- read.csv(file.path("reference_tables", paste0(item_name, "_taxa.csv")),
                 stringsAsFactors = FALSE, na.strings = c("", "NA"))
ti <- match(clean$Sample_printed, taxa$printed_name)
stopifnot(!anyNA(ti))
clean$Taxon_binomial <- taxa$Taxon_binomial[ti]
clean$species_basis  <- taxa$species_basis[ti]
clean$taxon_type     <- taxa$taxon_type[ti]

## ---- local CSV ------------------------------------------------------------
csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx --------------
tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
