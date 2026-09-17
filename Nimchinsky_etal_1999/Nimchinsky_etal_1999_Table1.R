## Nimchinsky EA, Gilissen E, Allman JM, Perl DP, Erwin JM, Hof PR (1999).
## A neuronal morphologic type unique to humans and great apes.
## Proc Natl Acad Sci USA 96(9):5268-5273. Table 1.
##
## Build step only: frozen snapshot -> clean analysis CSV -> DOI-coded public TSV.
## The snapshot is built by Nimchinsky_etal_1999_extract_snapshot.R; this script
## only reads it.
##
## Input : Nimchinsky_etal_1999_Table1_snapshot.xlsx  (sheet "Table1": Taxonomy,
##         Spindle cells, N; 48 rows as printed, including the 20 clade rows)
## Output: <script stem>.csv   one row per species (28)
##         <Item encoded>.tsv in __Public/comparative-data/ (named from __ReadMe.xlsx)
##
## The printed table nests species under clade rows. Those rows are unnested here
## into suborder / superfamily / family columns; the caption gives the ranks
## ("within their families, superfamilies, and suborders"). Rank is read off the
## name: -idae = family, otherwise superfamily, except the two printed suborders,
## which are named as anchors because "Anthropoidea" also ends in -oidea.
##
## The caption marks the taxa with spindle cells in bold. For the species rows
## that is the same information as the printed "Spindle cells" value, so
## spindle_cells_present is derived from the value, not from the formatting; the
## extract script checks the two agree before freezing the snapshot.

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
item_name    <- tools::file_path_sans_ext(basename(.sp))   # matches __ReadMe.xlsx
source_name  <- sub("_Table[^_]*$", "", item_name)          # Nimchinsky_etal_1999
snapshot_xlsx<- paste0(item_name, "_snapshot.xlsx")
output_csv   <- paste0(item_name, ".csv")
base         <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- read the frozen snapshot (verbatim headers, everything as text) ----
snap <- as.data.frame(readxl::read_excel(snapshot_xlsx, sheet = "Table1",
                                         col_types = "text"),
                      check.names = FALSE)
snap[is.na(snap)] <- ""
stopifnot(nrow(snap) == 48L)

taxon <- trimws(snap[["Taxonomy"]])

## ---- unnest the clade rows into rank columns ----
suborders_printed <- c("Prosimii", "Anthropoidea")   # as printed; see header note
is_species <- nzchar(trimws(snap[["Spindle cells"]]))
rank <- ifelse(is_species, "species",
        ifelse(taxon %in% suborders_printed, "suborder",
        ifelse(grepl("idae$", taxon), "family", "superfamily")))

suborder <- superfamily <- family <- rep(NA_character_, length(taxon))
cur_sub <- cur_sup <- cur_fam <- NA_character_
for (i in seq_along(taxon)) {
  if (rank[i] == "suborder")    { cur_sub <- taxon[i]; cur_sup <- NA_character_; cur_fam <- NA_character_ }
  if (rank[i] == "superfamily") { cur_sup <- taxon[i]; cur_fam <- NA_character_ }
  if (rank[i] == "family")      { cur_fam <- taxon[i] }
  suborder[i] <- cur_sub; superfamily[i] <- cur_sup; family[i] <- cur_fam
}

## ---- keep the species rows ----
keep <- which(is_species)
stopifnot(length(keep) == 28L)                      # "28 primate species" (Specimens)
stopifnot(!any(is.na(family[keep])))                 # every species sits under a family

spindle <- trimws(snap[["Spindle cells"]][keep])
stopifnot(all(spindle %in% c("None", "Rare", "Frequent", "Abundant", "Abundant/clusters")))

## ---- species harmonisation via the collection key (never an inline map) ----
key_path <- if (!is.na(base)) file.path(base, "_keys", "Hof", "species_key.csv") else NA_character_
species_accepted <- rep(NA_character_, length(keep))
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
  species_accepted <- unname(lk[tolower(taxon[keep])])
  missing <- taxon[keep][is.na(species_accepted)]
  if (length(missing)) {
    stop("Not in _keys/Hof/species_key.csv for ", source_name, ": ",
         paste(missing, collapse = "; "),
         "\n  Add the rows to the key file, not to this script.", call. = FALSE)
  }
}

clean <- data.frame(
  species               = species_accepted,
  species_as_published  = taxon[keep],
  suborder              = suborder[keep],
  superfamily           = superfamily[keep],
  family                = family[keep],
  spindle_cells         = spindle,
  spindle_cells_present = spindle != "None",
  n_specimens           = as.integer(trimws(snap[["N"]][keep])),
  source                = source_name,
  stringsAsFactors = FALSE
)
stopifnot(sum(clean$n_specimens) == 74L)             # specimen total across the 28 species
stopifnot(sum(clean$spindle_cells_present) == 5L)    # Pongo, Gorilla, both Pan, Homo

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
