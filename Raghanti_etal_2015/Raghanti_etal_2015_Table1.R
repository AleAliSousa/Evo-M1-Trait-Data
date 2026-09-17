## Raghanti MA, Spurlock LB, Treichler FR, Weigel SE, Stimmelmayr R, Butti C,
## Thewissen JGM, Hof PR (2015). An analysis of von Economo neurons in the
## cerebral cortex of cetaceans, artiodactyls, and perissodactyls.
## Brain Struct Funct 220(4):2303-2314. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## The snapshot is built by Raghanti_etal_2015_extract_snapshot.R; this script
## only reads it.
##
## Input : Raghanti_etal_2015_Table1_snapshot.xlsx (sheet "Table1"): two header
##         rows, then 8 species x (4 regions x 2 cell types)
## Output: <script stem>.csv   one row per species (8)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## Values are percentages as published. Normally a ratio would not be
## transcribed - it would be recomputed downstream from its numerator and
## denominator - but here the VEN, fork cell and total neuron population
## estimates are published only as scatterplots (Figs 6-8), so the percentage in
## Table 1 is the only tabulated form of this result. Flagged in the definitions
## and in the ReadMe rather than silently treated as a measured quantity.
##
## Two qualifiers come from Materials and methods, not from the table, because
## the table has no column for either. Both are quoted in the definitions:
##   "Only one individual per species was analyzed in this study."
##   "These brains were all from adults, with the exception of the cow."

options(scipen = 999)

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
folder        <- dirname(.sp)
item_name     <- tools::file_path_sans_ext(basename(.sp))
source_name   <- sub("_Table[^_]*$", "", item_name)
snapshot_xlsx <- paste0(item_name, "_snapshot.xlsx")
output_csv    <- paste0(item_name, ".csv")
base          <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot, both header tiers, everything as text ----
raw <- as.data.frame(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                        col_names = FALSE, col_types = "text"),
                     check.names = FALSE)
raw[is.na(raw)] <- ""
stopifnot(ncol(raw) == 9L, nrow(raw) == 10L)     # 2 header rows + 8 species

tier1 <- trimws(as.character(raw[1, ]))
tier2 <- trimws(as.character(raw[2, ]))
body  <- raw[-(1:2), , drop = FALSE]

## the merged region cell only carries text in its first column; carry it across
for (i in seq_along(tier1)) if (!nzchar(tier1[i]) && i > 1) tier1[i] <- tier1[i - 1]

## ---- column names from the printed headers, not from a hardcoded list ----
snake <- function(x) gsub("_+", "_", gsub("[^a-z0-9]+", "_", tolower(trimws(x))))
meas  <- c("% VEN" = "ven_pct", "% Fork cells" = "fork_pct")
stopifnot(all(tier2[-1] %in% names(meas)))
codes <- paste0(snake(tier1[-1]), "_", meas[tier2[-1]])
stopifnot(!anyDuplicated(codes), length(codes) == 8L)

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
vals <- as.data.frame(lapply(body[-1], num))
names(vals) <- codes
stopifnot(!any(is.na(vals)))                     # printed zeros are absences, not blanks
stopifnot(all(vals >= 0 & vals <= 100))

species_printed <- trimws(body[[1]])
stopifnot(length(species_printed) == 8L)

## ---- species harmonisation via the collection key (never an inline map) ----
## The table prints common names; the binomials are in Materials and methods and
## live in the key as variant_name rows, so no common-to-binomial map appears here.
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
species_accepted <- rep(NA_character_, length(species_printed))
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx. ",
       "Run it from a loose folder and the species column comes out empty - ",
       "which is how the first version of this file was committed with no ",
       "species names in it.", call. = FALSE)
}
{
  key <- read.csv(key_path, stringsAsFactors = FALSE)
  key <- key[key$source_publication == source_name, ]
  lk  <- setNames(key$accepted_name, tolower(key$variant_name))
  species_accepted <- unname(lk[tolower(species_printed)])
  missing <- species_printed[is.na(species_accepted)]
  if (length(missing)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(missing, collapse = "; "),
         "\n  Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

## ---- qualifiers from Materials and methods (see header note) ----
non_adult <- "Cow"
stopifnot(non_adult %in% species_printed)        # break loudly if the label changes

clean <- data.frame(
  species              = species_accepted,
  species_as_published = species_printed,
  vals,
  cortical_layer       = "V",
  n_individuals        = 1L,
  adult                = !(species_printed %in% non_adult),
  source               = source_name,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(sum(!clean$adult) == 1L)
stopifnot(all(vals[species_printed == "Rock hyrax", ] == 0))   # the paper's key negative

stopifnot(!anyNA(clean$species))   # never write a file with an empty species column

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]
} else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  write.table(clean, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE)
}
