## Butti C, Sherwood CC, Hakeem AY, Allman JM, Hof PR (2009). Total number and
## volume of Von Economo neurons in the cerebral cortex of cetaceans.
## J Comp Neurol 515(2):243-259. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
##
## Input : Butti_etal_2009_Table1_snapshot.csv   (4 species, as printed)
## Output: <script stem>.csv   one row per species (4)
##
## SECONDARY DATA. The footnote reads: "Brain weight and body weight were
## unavailable for most of the specimens in this study. These values were taken
## from Marino et al. (2004) and Hof et al. (2005)." So none of this was measured
## here. Set Data role = secondary in __ReadMe.xlsx and keep it out of the merges.
##
## EQ is an index, not a measurement. The paper does not print its formula, but
## brain_g / (0.12 * body_g^0.67) reproduces all four printed values to two
## decimal places, so the formula is identified and the script uses it as a check
## on the transcription. It is recorded as a check, not as the paper's own
## statement of method.

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
stopifnot(nrow(snap) == 4L, ncol(snap) == 4L)
stopifnot(identical(names(snap),
                    c("Species", "Brain weight (g)", "Body weight (g)", "EQ")))

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x))))
sp      <- trimws(snap$Species)
brain_g <- num(snap[["Brain weight (g)"]])
body_g  <- num(snap[["Body weight (g)"]])
eq      <- num(snap$EQ)
stopifnot(!anyNA(c(brain_g, body_g, eq)))

## the printed EQ is the transcription's own check
eq_recomputed <- round(brain_g / (0.12 * body_g^0.67), 2)
stopifnot(all(abs(eq_recomputed - eq) < 0.005))

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
       paste(sp[is.na(species_accepted)], collapse = "; "),
       ". Add the rows to the key file, not to this script.", call. = FALSE)
}

clean <- data.frame(
  species                   = species_accepted,
  species_as_published      = sp,
  brain_mass_mg             = as.integer(round(brain_g * 1000)),   # project unit
  brain_mass_g_as_published = brain_g,
  body_mass_g               = body_g,                              # already the project unit
  eq_as_published           = eq,
  eq_recomputed             = eq_recomputed,
  source                    = source_name,
  stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 4L, !anyNA(clean$species))

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
