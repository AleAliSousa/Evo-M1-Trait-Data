## Smaers JB, Schleicher A, Zilles K, Vinicius L (2010), PLoS ONE 5(2):e9123
## "Frontal White Matter Volume Is Associated with Brain Enlargement and Higher Structural Connectivity in Anthropoid Primates"
## DOI: 10.1371/journal.pone.0009123
##
## Table 1 -> reproducible source-to-snapshot-to-clean-data pipeline.
## Reads the published PDF directly (no hand transcription and no Acrobat export).
## Table values are volumes in mm3: e.g. chimpanzee Brain = 444981 mm3 = 444.981 cm3.
##
## Outputs beside this script:
##   Smaers_etal_2010_Table1_snapshot.csv  raw values as printed in Table 1
##   Smaers_etal_2010_Table1.csv           analysis-ready data
## and, when run inside the full Evo-M1-Trait-Data repo, the DOI-coded TSV in
##   __Public/comparative-data/

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
options(scipen = 999)

suppressPackageStartupMessages({
  library(pdftools)
  library(readxl)
})

## ---- locate source PDF -------------------------------------------------------
pdfs <- list.files(folder, pattern = "\\.pdf$", full.names = TRUE, ignore.case = TRUE)
if (length(pdfs) != 1L) {
  stop("Expected exactly one PDF in ", folder, "; found ", length(pdfs), ".", call. = FALSE)
}
pdf_file <- pdfs[1]

## ---- extract Table 1 directly from PDF --------------------------------------
## pdf_text() preserves the fixed-width table layout. Find the page by caption
## rather than assuming that Table 1 will always be PDF page 3.
pages <- pdftools::pdf_text(pdf_file)
table_page <- which(grepl(
  "Table 1\\. Volumetric measurements of neopallium and frontal lobe white and grey matter",
  pages,
  fixed = FALSE
))

if (length(table_page) != 1L) {
  stop("Could not uniquely locate Table 1 in the PDF.", call. = FALSE)
}

lines <- strsplit(pages[table_page], "\\n", fixed = FALSE)[[1]]

first_row <- which(grepl("^\\s*Pan troglodytes\\s+280\\s+321677", lines))[1]
last_row  <- which(grepl("^\\s*Cebus albifrons\\s+1200\\s+52450", lines))[1]

if (is.na(first_row) || is.na(last_row) || last_row < first_row) {
  stop("Could not identify the Table 1 data rows in the PDF text.", call. = FALSE)
}

rows <- lines[first_row:last_row]
rows <- rows[nzchar(trimws(rows))]

## ---- absolute column origin --------------------------------------------------
## Table 1 is printed rotated, so the rotated page furniture -- the page number
## and the "PLoS ONE | www.plosone.org" running head -- is typeset in the left
## margin of the table's own text block. Depending on the poppler build behind
## pdftools it either occupies a line of its own or is merged onto the
## Cercopithecus ascanius line.
##
## Do NOT re-origin rows with sub("^\\s+", "", ...). That assumes every row is
## indented identically. The merged line is not, so stripping shifts its
## fixed-width fields ~45 characters and silently corrupts the row while still
## leaving 18 rows for the count check to pass. Slice against the absolute column
## where the Species labels start instead: anything sitting in the left margin
## then falls outside every field window and is ignored.
origin <- as.integer(regexpr("Pan troglodytes", lines[first_row], fixed = TRUE))
if (is.na(origin) || origin < 1L) {
  stop("Could not locate the Species column origin in the PDF text.", call. = FALSE)
}

## Fixed-width starts, measured from the Species column origin rather than from
## character 1 of the line. These preserve blank cells in the Semendeferi and
## Stephan columns, unlike a simple whitespace split, which would shift columns
## whenever a value is absent.
field <- function(x, first, last = 10000L) {
  trimws(substr(x, origin - 1L + first, origin - 1L + last))
}
num <- function(x) {
  x[x == ""] <- NA_character_
  suppressWarnings(as.numeric(x))
}

## Keep only lines carrying a label in the Species window. This drops a page
## number or running head that poppler left alone in the left margin.
rows <- rows[nzchar(field(rows, 1, 23))]

if (length(rows) != 18L) {
  stop("Expected 18 species rows in Table 1; extracted ", length(rows), ".", call. = FALSE)
}

snapshot <- data.frame(
  Species                         = field(rows,   1,  23),
  `Specimen #`                    = field(rows,  24,  42),
  N                               = num(field(rows,  43,  63)),
  Nw                              = num(field(rows,  64,  75)),
  Ng                              = num(field(rows,  76,  89)),
  FR                              = num(field(rows,  90, 103)),
  FRw                             = num(field(rows, 104, 115)),
  FRg                             = num(field(rows, 116, 126)),
  `Fr/Neo (%) Current study`      = num(field(rows, 127, 150)),
  `Fr/Neo (%) Semendeferi 1997`   = field(rows, 151, 171),
  `Fr/Neo (%) Semendeferi 2002`   = field(rows, 172, 192),
  `Stephan unpublished N`         = num(field(rows, 193, 213)),
  Brain                           = num(field(rows, 214, 227)),
  BG                              = num(field(rows, 228, 10000)),
  check.names = FALSE,
  stringsAsFactors = FALSE
)

snapshot[["Fr/Neo (%) Semendeferi 1997"]][snapshot[["Fr/Neo (%) Semendeferi 1997"]] == ""] <- NA_character_
snapshot[["Fr/Neo (%) Semendeferi 2002"]][snapshot[["Fr/Neo (%) Semendeferi 2002"]] == ""] <- NA_character_

## ---- validate, then write ---------------------------------------------------
## Expand only the abbreviations used in the printed Species column. Keep the
## printed label too, so every normalization remains auditable back to the PDF.
species_lookup <- c(
  "Pan troglodytes"  = "Pan troglodytes",
  "Pan paniscus"     = "Pan paniscus",
  "Gorilla gorilla"  = "Gorilla gorilla",
  "Pongo pygm."      = "Pongo pygmaeus",
  "Hylobates lar"    = "Hylobates lar",
  "Papio anubis"     = "Papio anubis",
  "Cercoceb. alb."   = "Cercocebus albigena",
  "Cercopith. Mit."  = "Cercopithecus mitis",
  "Cercopith. asc."  = "Cercopithecus ascanius",
  "Erythroceb. p."   = "Erythrocebus patas",
  "Miopith. tal."    = "Miopithecus talapoin",
  "Nasalis larv."    = "Nasalis larvatus",
  "Procol. bad."     = "Procolobus badius",
  "Alouatta sen."    = "Alouatta seniculus",
  "Ateles geoffroyi" = "Ateles geoffroyi",
  "Lagothr.lagotr."  = "Lagothrix lagotricha",
  "Pith. monachus"   = "Pithecia monachus",
  "Cebus albifrons"  = "Cebus albifrons"
)

## A shifted row still yields 18 rows, so the count check alone cannot catch a bad
## parse. These two checks can, and both run before anything reaches disk: a
## corrupted row loses its Species label and blanks at least one of the columns
## that Table 1 populates for every species.
species <- unname(species_lookup[snapshot$Species])
if (anyNA(species)) {
  stop("Unmapped printed species label(s): ",
       paste(unique(snapshot$Species[is.na(species)]), collapse = ", "),
       call. = FALSE)
}

## Stephan unpublished N and BG are legitimately blank for some species, so they
## are deliberately not required here.
required   <- c("N", "Nw", "Ng", "FR", "FRw", "FRg", "Brain")
incomplete <- vapply(snapshot[required], anyNA, logical(1))
if (any(incomplete)) {
  stop("Table 1 prints a value for every species in ",
       paste(required[incomplete], collapse = ", "),
       "; the parse lost some. Check the fixed-width offsets.", call. = FALSE)
}

write.csv(snapshot,
          file = file.path(folder, paste0(item_name, "_snapshot.csv")),
          row.names = FALSE,
          na = "")

## ---- clean ------------------------------------------------------------------
clean <- data.frame(
  species = species,
  species_printed = snapshot$Species,
  catalogue_number = snapshot[["Specimen #"]],
  neopallium_volume_mm3 = snapshot$N,
  neopallium_white_matter_volume_mm3 = snapshot$Nw,
  neopallium_grey_matter_volume_mm3 = snapshot$Ng,
  frontal_lobe_volume_mm3 = snapshot$FR,
  frontal_white_matter_volume_mm3 = snapshot$FRw,
  frontal_grey_matter_volume_mm3 = snapshot$FRg,
  frontal_neopallium_percent = snapshot[["Fr/Neo (%) Current study"]],
  semendeferi_1997_frontal_neopallium_percent = snapshot[["Fr/Neo (%) Semendeferi 1997"]],
  semendeferi_2002_frontal_neopallium_reported = snapshot[["Fr/Neo (%) Semendeferi 2002"]],
  stephan_unpublished_neopallium_volume_mm3 = snapshot[["Stephan unpublished N"]],
  total_brain_volume_mm3 = snapshot$Brain,
  basal_ganglia_volume_mm3 = snapshot$BG,
  source = "Smaers_etal_2010",
  stringsAsFactors = FALSE
)

## Derived non-frontal values used in the paper's analyses.
clean$nonfrontal_lobe_volume_mm3 <- clean$neopallium_volume_mm3 - clean$frontal_lobe_volume_mm3
clean$nonfrontal_white_matter_volume_mm3 <- clean$neopallium_white_matter_volume_mm3 - clean$frontal_white_matter_volume_mm3
clean$nonfrontal_grey_matter_volume_mm3 <- clean$neopallium_grey_matter_volume_mm3 - clean$frontal_grey_matter_volume_mm3

## Internal arithmetic check. Published component totals occasionally differ by 1
## mm3 because of rounding, so only larger discrepancies are flagged.
check_n  <- abs(clean$neopallium_volume_mm3 -
                (clean$neopallium_white_matter_volume_mm3 + clean$neopallium_grey_matter_volume_mm3))
check_fr <- abs(clean$frontal_lobe_volume_mm3 -
                (clean$frontal_white_matter_volume_mm3 + clean$frontal_grey_matter_volume_mm3))
if (any(check_n > 1, na.rm = TRUE) || any(check_fr > 1, na.rm = TRUE)) {
  warning("One or more component sums differ from the printed total by >1 mm3.")
}

## ---- save: local CSV + DOI-named TSV ---------------------------------------
final.dataframe <- clean
write.csv(final.dataframe,
          file = file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE,
          na = "")
message("Wrote ", item_name, "_snapshot.csv and ", item_name, ".csv (", nrow(final.dataframe), " rows).")

if (is.na(base)) {
  warning("Repo root not found; TSV skipped.")
} else {
  readme_file <- file.path(base, "__ReadMe.xlsx")
  tsv_dir     <- file.path(base, "__Public", "comparative-data")
  filecodes   <- read_excel(readme_file, sheet = "Sheet1")

  norm_key <- function(x) tolower(gsub("[ _]", "", as.character(x)))
  item_encoded <- filecodes$"Item encoded"[
    match(norm_key(item_name), norm_key(filecodes$"Item name"))
  ]

  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' (DOI) for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(tsv_dir)) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    write.table(final.dataframe,
                file = file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "")
    message("Wrote ", file.path(tsv_dir, paste0(item_encoded, ".tsv")))
  }
}
