## Balzeau_etal_2012 — Table 5
## Percentage contribution of frontal, parieto-temporal and occipital lobes to
## the hemispheres (Homo).
##
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; ALL cleaning
## happens here. Two-tier header (sample group over n / Mean / V*), read
## POSITIONALLY and reshaped to one tidy row per (sample x lobe).
##
## Note on measure: these are PERCENTAGES (each sample's three lobes sum to 100%).
## They are derived/relative and NOT fed into __merging_volumes.

options(scipen = 999)

suppressPackageStartupMessages({
  library(readr)
})

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snapshot_file <- "Balzeau_etal_2012_Table5_snapshot.csv"

raw <- read.csv(snapshot_file, header = FALSE, colClasses = "character",
                check.names = FALSE, stringsAsFactors = FALSE, na.strings = c("", "NA"))

samples <- c(
  "Homo habilis s.l.",
  "African and Georgian Homo erectus s.l.",
  "Asian Homo erectus",
  "Neandertals s.l.",
  "AMH"
)

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
    off <- 1 + (s - 1) * 3
    out[[length(out) + 1]] <- data.frame(
      Sample_printed          = samples[s],
      Structure_Balzeau2012   = lobe_printed,
      Structure               = unname(lobe_map[lobe_printed]),
      n                       = as.integer(as_num(data_rows[i, off + 1])),
      Mean_pct_of_hemisphere  = as_num(data_rows[i, off + 2]),
      V_star                  = as_num(data_rows[i, off + 3]),
      source                  = "Balzeau_etal_2012",
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

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

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
