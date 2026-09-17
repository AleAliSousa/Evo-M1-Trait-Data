## Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). Total number and
## volume of Von Economo neurons in the cerebral cortex of cetaceans.
## J Comp Neurol 515(2):243-259. Table 5.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Butti_etal_2009_Table5_snapshot.csv
##         9 printed rows, species x ROI. The species name is printed once per
##         block and blank on the rows beneath it, as on the page.
## Output: <script stem>.csv   one row per printed row (9)
##         <Item encoded>.tsv in __Public/comparative-data/
##
## Hemispheres. The footnote says the estimates come from "the only available
## hemisphere in each specimen": the right hemisphere of T. truncatus and the
## left hemispheres of the other three were not available. So exactly one of the
## two printed count columns is filled on every row. Both columns are kept, as
## printed, and hemisphere_available records which one it was. The script checks
## that the filled column matches the footnote on every row.
##
## Underestimates. The same footnote: "VEN numbers in the odontocetes represent
## only the available blocks from the ROI and are therefore underestimates."
## The odontocetes here are T. truncatus, G. griseus and D. leucas; the humpback
## is a mysticete. Carried as the underestimate flag.
##
## The percentages are transcribed exactly where they are printed. Three of the
## five sit on rows for which the paper's Table 3 gives no total-neuron sampling
## parameters - see the Method:percentage_placement row in the definitions. That
## is recorded, not reconciled.

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
folder       <- dirname(.sp)
item_name    <- tools::file_path_sans_ext(basename(.sp))
source_name  <- sub("_Table[^_]*$", "", item_name)
snapshot_csv <- paste0(item_name, "_snapshot.csv")
output_csv   <- paste0(item_name, ".csv")
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers) ----
snap <- read.csv(snapshot_csv, check.names = FALSE, stringsAsFactors = FALSE,
                 colClasses = "character", encoding = "UTF-8")
snap[is.na(snap)] <- ""
stopifnot(nrow(snap) == 9L, ncol(snap) == 6L)
stopifnot(identical(names(snap), c("Species", "ROI", "Estimated VENs RH",
                                   "Estimated VENs LH", "VENs (%)", "CE")))

## ---- carry the species name down its printed block ----
sp <- trimws(snap$Species)
for (i in seq_along(sp)) if (!nzchar(sp[i])) sp[i] <- sp[i - 1]
stopifnot(all(nzchar(sp)))

num <- function(x) {
  x <- trimws(x); x[!nzchar(x)] <- NA
  suppressWarnings(as.numeric(gsub(",", "", x)))
}
rh  <- num(snap[["Estimated VENs RH"]])
lh  <- num(snap[["Estimated VENs LH"]])
pct <- num(snap[["VENs (%)"]])
ce  <- num(snap$CE)
stopifnot(!anyNA(ce))
## exactly one hemisphere per printed row
stopifnot(all(xor(is.na(rh), is.na(lh))))

## ---- the footnote's hemisphere availability, as anchored printed literals ----
## "The right hemisphere of T. truncatus and the left hemispheres of G. griseus,
## D. leucas, and M. novaeangliae ... were not available."
avail <- ifelse(sp == "T. truncatus", "L", "R")
stopifnot(all((avail == "R") == !is.na(rh)))   # the filled column matches the footnote

## "VEN numbers in the odontocetes ... are therefore underestimates."
odontocetes <- c("T. truncatus", "G. griseus", "D. leucas")
stopifnot(all(odontocetes %in% sp))

## ---- species harmonisation via the collection key (never an inline map) ----
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
if (is.na(key_path) || !file.exists(key_path)) {
  stop("Species key not found. Run this script from inside a clone of the ",
       "repository, so this folder sits under the one holding __ReadMe.xlsx.",
       call. = FALSE)
}
key <- read.csv(key_path, stringsAsFactors = FALSE)
key <- key[key$source_publication == source_name, ]
lk  <- setNames(key$accepted_name, tolower(key$variant_name))
species_accepted <- unname(lk[tolower(sp)])
if (anyNA(species_accepted)) {
  stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
       paste(unique(sp[is.na(species_accepted)]), collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)
}

clean <- data.frame(
  species              = species_accepted,
  species_as_published = sp,
  roi                  = trimws(snap$ROI),
  ven_n_RH             = as.integer(rh),
  ven_n_LH             = as.integer(lh),
  ven_pct              = pct,
  ce                   = ce,
  hemisphere_available = avail,
  underestimate        = sp %in% odontocetes,
  source               = source_name,
  stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 9L, !anyNA(clean$species))
stopifnot(all(clean$roi %in% c("ACC", "SUBG", "AI", "FP")))
stopifnot(sum(!is.na(clean$ven_pct)) == 5L)      # five printed percentages
stopifnot(sum(clean$ce > 0.1) == 3L)             # the caption flags CE > 0.1 as not optimal

write.csv(clean, output_csv, row.names = FALSE)

## ---- public TSV: look up the DOI/PMID code from __ReadMe.xlsx (don't hardcode) ----
tsv_dir      <- file.path(base, "__Public/comparative-data/")
item_encoded <- if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
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
