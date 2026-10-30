# Ricklefs__2010_Appendix6.R
#
# Reformat: frozen snapshot -> analysis CSV -> public TSV
#
# Source: Ricklefs, R. E. (2010). Life-history connections to rates of aging in terrestrial vertebrates.
# PNAS, 107(22), 10314-10319. https://doi.org/10.1073/pnas.1005862107 -- Supporting Information
# (sapp.pdf), APPENDIX 6 (SI pp. 19-29): "Life history variables for the species used in this analysis.
# Data are from the AnAge database and references therein" (ref 7 = de Magalhaes & Costa 2009).
# Three printed sections with different columns: Mammals, Birds, Reptiles and amphibians.
#
# Frozen source: Ricklefs__2010_Appendix6_snapshot.csv, written from the SI text layer by
# Ricklefs__2010_SIAppendices_extract_snapshot.R (sections stacked; headers as printed per section).
# This script reads it; it never contains table values.

## ---- 0. Paths: self-locating, so it runs from any working directory ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))

folder    <- basename(item_dir)
item_name <- sub("\\.R$", "", basename(.sp))     # "Ricklefs__2010_Appendix6" = __ReadMe.xlsx "Item name"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
pdf_file  <- file.path(item_dir, "sapp.pdf")

# ---- 1. Read the frozen snapshot (all character, as printed) ----
snap <- read.csv(frozen, check.names = FALSE, colClasses = "character", na.strings = character(0), encoding = "UTF-8")
if (nrow(snap) != 425L) stop("expected 425 printed rows, got ", nrow(snap), call. = FALSE)

# ---- 2. Clean: one analysis column per quantity across the three printed sections ----
## "." = no value (as printed) and an empty cell -> NA. Units as printed: d, g, m, y (project units for
## mass already g). Section-specific headers are mapped below; a quantity a section does not print is NA.
num  <- function(x) { x[x %in% c("", ".")] <- NA; as.numeric(x) }
pick <- function(...) { v <- rep("", nrow(snap)); for (cl in c(...)) v <- ifelse(nzchar(v), v, snap[[cl]]); num(v) }
final.dataframe <- data.frame(
  Class_group          = snap$section,
  Class                = snap$Class,                         # printed in the reptile/amphibian section only
  Order                = snap$Order,
  Family               = snap$Family,
  Genus                = snap$Genus,
  Species              = snap$Species,
  Species_Ricklefs2010 = paste(snap$Genus, snap$Species),
  Female_maturity_d    = pick("Age at maturity (d) Females", "Female age at maturity (d)"),
  Adult_mass_g         = pick("Mass (g) Adult", "Adult mass (g)", "Adult body mass (g)"),
  Neonate_mass_g       = pick("Mass (g) Neonate"),
  Weaning_mass_g       = pick("Mass (g) Weaning"),
  Egg_mass_g           = pick("Egg mass (g)"),
  Gestation_d          = pick("Period (d) Gestation"),
  Weaning_d            = pick("Period (d) Weaning"),
  Incubation_d         = pick("Incubation period (d)"),
  ## mammals print "Growth rate k (1/d)"; birds print "Growth rate k (d)" -- same quantity, the bird
  ## header unit is a misprint (bird values 0.023-0.52 are rates, not durations; AnAge growth rate is 1/days)
  Growth_rate_k_per_d  = pick("Growth rate k (1/d)", "Growth rate k (d)"),
  Adult_length_m       = pick("Adult length (m)"),
  ## mammals and birds print "Oldest (y)", reptiles/amphibians "Longevity (y)"
  Max_longevity_y      = pick("Oldest (y)", "Longevity (y)"),
  stringsAsFactors = FALSE)

# ---- 3. Check: every species here has Weibull parameters in Appendix 4 (same analysis set) ----
a4 <- file.path(item_dir, paste0(folder, "_Appendix4_snapshot.csv"))
if (file.exists(a4)) {
  a4s <- read.csv(a4, check.names = FALSE, colClasses = "character", encoding = "UTF-8")
  in4 <- final.dataframe$Species_Ricklefs2010 %in% paste(a4s$Genus, a4s$Species)
  cat("species also in Appendix 4 (exact printed binomial):", sum(in4), "/", nrow(final.dataframe), "\n")
}

# ---- 4. References (citation filled from the SI list below) ----
references <- data.frame(ref_key = "7", cited_in_column = "(caption)", citation = "",
  note = "caption: 'Data are from the AnAge database and references therein'; applies to every row (no per-row keys printed)",
  stringsAsFactors = FALSE)
references$n_rows <- nrow(final.dataframe)

# ---- References: SI "References" list (sapp.pdf p. 38), verbatim; only the works this item cites ----
si_txt <- pdftools::pdf_text(pdf_file)
ref_page  <- which(grepl("(?m)^\\s*References\\s*$", si_txt, perl = TRUE))[1]
ref_lines <- strsplit(si_txt[ref_page], "\n")[[1]]
ref_lines <- ref_lines[seq(grep("^\\s*References\\s*$", ref_lines)[1] + 1L, length(ref_lines))]
ref_lines <- trimws(ref_lines[nzchar(trimws(ref_lines))])
starts <- grepl("^[0-9]+\\.\\s", ref_lines)
bib <- vapply(split(ref_lines, cumsum(starts)), function(x) paste(x, collapse = " "), "")
bib <- setNames(sub("^[0-9]+\\.\\s+", "", bib), sub("^([0-9]+)\\..*", "\\1", bib))
if (!all(as.character(1:13) %in% names(bib))) stop("SI reference list did not parse to entries 1-13", call. = FALSE)
references$citation <- ifelse(references$ref_key %in% names(bib), unname(bib[references$ref_key]), references$citation)
if (any(!nzchar(references$citation))) stop("unresolved reference key(s)", call. = FALSE)
write.csv(references, file.path(item_dir, "reference_tables", paste0(item_name, "_references.csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

# ---- Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- refusing to write NA.tsv", call. = FALSE)
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- Validate ----
readme_file <- file.path(item_dir, paste0(item_name, ".README.md"))
checks <- validate_dataset_item(
  csv_file           = csv_path,
  tsv_file           = tsv_path,
  readme_file        = readme_file,
  definitions_file   = file.path(item_dir, "reference_tables", paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen,
  registry           = filecodes,
  item_name          = item_name,
  item_encoded       = item_encoded
)
print(checks, row.names = FALSE)
if (any(checks$status == "FAIL"))
  stop("validation failed for ", item_name, ": ",
       paste(checks$check[checks$status == "FAIL"], collapse = ", "), call. = FALSE)
message("Built ", item_name, ": ", nrow(final.dataframe), " rows -> CSV + ", basename(tsv_path),
        "; ", nrow(references), " references")
