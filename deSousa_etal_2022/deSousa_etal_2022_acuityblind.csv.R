## de Sousa, Todorov & Proulx 2022, Neurosci Biobehav Rev 134:104550 — acuityblind.csv
## doi:10.1016/j.neubiorev.2022.104550 · "A natural history of vertebrate vision loss".
## DIGITAL-NATIVE source: `acuityblind.csv` (this folder) is the paper's own analysis dataset
## (Supplementary Information File 1 points to https://doi.org/10.17870/bathspa.10275875).
## No snapshot file (founder-TSV rule for digital-native sources); frozen source =
## acuityblind.csv, SHA-256 33ca27b69ae20b99950f762c16b37b84e98867d04a9b1659e2d7cb7dd7359baa.
## 120 mammal species = 114 with VA estimates + 6 subcutaneous-eyed species coded 0 cpd.
## MT: A = anatomical (n=63), B = behavioral (n=51), C = blind-coded-0 (n=6) — verified against
## SI Table 2 (mmc4.xlsx) per-order counts, and VA range 0–64.28 cpd against the paper text.
## SECONDARY compilation: VA is compiled from primaries (Veilleux & Kirk 2014 — see
## Veilleux_Kirk_2014_SupplementalTable1, values overlap; Kirk & Kay 2004; Heffner & Heffner).
## Prefer the primaries in merges; this item is the review's analysis layer.
## The PanTHERIA covariate columns (X*-coded) stay in the raw file only — they are PanTHERIA's
## data, not this paper's, and must never be ingested from here.

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
item_name <- tools::file_path_sans_ext(basename(.sp))         # deSousa_etal_2022_acuityblind.csv
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)

raw <- read.csv(file.path(folder, "acuityblind.csv"), stringsAsFactors = FALSE)
stopifnot(nrow(raw) == 120, all(c("MSW05_Binomial", "VA", "MT") %in% names(raw)))
stopifnot(all(sort(unique(raw$MT)) == c("A", "B", "C")))

mmap <- c(A = "anatomical (peak ganglion-cell density)",
          B = "behavioral",
          C = "blind (subcutaneous eyes; VA coded 0 cpd)")
note <- paste0("SECONDARY compilation - analysis dataset of a review; VA compiled from primaries ",
               "incl. Veilleux & Kirk 2014, Kirk & Kay 2004, Heffner & Heffner; prefer primaries ",
               "in merges")

clean <- data.frame(
  Species = gsub("_", " ", raw$MSW05_Binomial),
  order   = raw$MSW05_Order,
  family  = raw$MSW05_Family,
  visual_acuity_cpd = as.numeric(raw$VA),
  acuity_method     = unname(mmap[raw$MT]),
  note = note, source = item_name, stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(!anyNA(clean$visual_acuity_cpd))

csv_file <- file.path(folder, paste0(item_name, ".csv"))   # deSousa_etal_2022_acuityblind.csv.csv
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " species rows written")

## ---- public TSV ----
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(enc) && nzchar(enc) && dir.exists(path.expand(tsv_dir)))
    write.table(clean, file.path(path.expand(tsv_dir), paste0(enc, ".tsv")), sep = "\t", row.names = FALSE)
  else warning("Item encoded not found or shared folder missing; TSV skipped.")
}
