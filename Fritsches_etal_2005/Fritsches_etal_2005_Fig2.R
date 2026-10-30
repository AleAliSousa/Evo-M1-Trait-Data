## Fritsches KA, Brill RW, Warrant EJ (2005). Warm eyes provide superior vision
## in swordfishes. Curr Biol 15(1):55-58. Figure 2 and text, p. 55.
##
## Build step only: frozen source -> clean analysis CSV -> DOI-coded public TSV.
##
## Why this script was rewritten (2026-09-16). The snapshot was corrected in
## September: the swordfish n was filled in as 6, and two flicker-fusion columns
## were removed because the paper does not report those values. The old script
## still renamed "FFF at 10C (Hz)" and "FFF at 20C (Hz)", columns that no longer
## exist, so it stopped on the first rename. It now reads the columns the
## snapshot actually has.
##
## Constructed snapshot. Fritsches et al. publish no table; these values are in
## the running text on p. 55 and in the Figure 2 legends. Under the snapshot
## HOWTO that makes this a constructed snapshot, so the locus is "Fig2" and the
## ReadMe records which sentences each value came from.
##
## Input : Fritsches_etal_2005_Fig2_snapshot.csv
## Output: <script stem>.csv   one row per species (3)
##         <Item encoded>.tsv in __Public/comparative-data/

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
source_name  <- sub("_(Fig|Table)[^_]*$", "", item_name)
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
stopifnot(identical(names(snap),
                    c("Common name", "Species", "Habitat descriptor as printed",
                      "Retinal Q10 (light-adapted)", "n", "r-squared", "Source in paper")))
stopifnot(nrow(snap) == 3L)

num <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "-", "–", "—", "NA", "n.a.")] <- NA
  suppressWarnings(as.numeric(x))
}
blank_to_na <- function(x) { x <- trimws(x); x[!nzchar(x)] <- NA; x }

## The binomial is printed in the text alongside each common name, so it is
## already in the snapshot; the key still holds the mapping so other papers can
## reuse it. Nothing here maps a common name to a binomial by hand.
clean <- data.frame(
  species                   = trimws(snap$Species),
  common_name_printed       = trimws(snap[["Common name"]]),
  common_name               = tolower(trimws(snap[["Common name"]])),
  habitat_descriptor        = blank_to_na(snap[["Habitat descriptor as printed"]]),
  retinal_q10_light_adapted = num(snap[["Retinal Q10 (light-adapted)"]]),
  n                         = as.integer(num(snap$n)),
  r_squared                 = num(snap[["r-squared"]]),
  source_in_paper           = trimws(snap[["Source in paper"]]),
  source                    = source_name,
  stringsAsFactors = FALSE
)

stopifnot(!anyNA(clean$species), !anyNA(clean$retinal_q10_light_adapted),
          !anyNA(clean$n), !anyNA(clean$r_squared))
## the swordfish is the paper's claim: a much higher retinal Q10 than either tuna
stopifnot(clean$retinal_q10_light_adapted[clean$species == "Xiphias gladius"] >
          max(clean$retinal_q10_light_adapted[clean$species != "Xiphias gladius"]))
## the habitat descriptor is printed for the two tunas only
stopifnot(sum(is.na(clean$habitat_descriptor)) == 1L)

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
