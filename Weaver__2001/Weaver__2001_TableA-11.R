## Weaver__2001 — Table A-11: PCF and CBLM Volume from MRI Scans
## Weaver, A. G. H. (2001). PhD dissertation, University of New Mexico. (UMI 3017523)
##
## Per-specimen posterior cranial fossa (PCF) volume and cerebellum (CBLM) volume
## measured from MRI scans, across hominoids (Hylobates, Pongo, Gorilla, Pan,
## Pan paniscus, Homo sapiens). PCF is a variable NOT present in Table A-15, so
## this is genuinely additive primary data.
##
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; ALL cleaning
## (taxon-code expansion, unit conversion) happens here. Transcribed from a
## high-resolution render of the scanned page and validated by CBLM/PCF = CBLM/PCF
## for every row.
##
## NOTE: not yet in __ReadMe.xlsx; TSV lookup warns/skips until a registry row +
## Item encoded is added (proposed: UMI%3A3017523_TableA-11).

options(scipen = 999)

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

## row 1 = caption, row 2 = header, rows 3+ = data
raw <- read.csv("Weaver__2001_TableA-11_snapshot.csv", header = FALSE, skip = 2,
                colClasses = "character", check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "NA"))
names(raw) <- c("Specimen", "Taxon_code", "PCF_cc", "CBLM_cc", "CBLM_PCF")

taxon_map <- c(
  "Gi" = "Hylobates (gibbon)", "O" = "Pongo (orangutan)", "Go" = "Gorilla",
  "C"  = "Pan (chimpanzee)",   "B" = "Pan paniscus (bonobo)", "H" = "Homo sapiens"
)
as_num <- function(x) suppressWarnings(as.numeric(x))

clean <- data.frame(
  Specimen      = raw$Specimen,
  Taxon_code    = raw$Taxon_code,
  Taxon         = unname(taxon_map[raw$Taxon_code]),
  PCF_cc        = as_num(raw$PCF_cc),
  PCF_Vol.mm3   = round(as_num(raw$PCF_cc) * 1000),    # posterior cranial fossa vol; cc -> mm3
  CBLM_cc       = as_num(raw$CBLM_cc),
  CBLM_Vol.mm3  = round(as_num(raw$CBLM_cc) * 1000),   # cerebellum vol; cc -> mm3
  CBLM_PCF      = as_num(raw$CBLM_PCF),
  source        = "Weaver__2001",
  stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 34L, !any(is.na(clean$Taxon)))
## sanity: printed ratio matches CBLM/PCF within rounding
stopifnot(all(abs(clean$CBLM_PCF - clean$CBLM_cc / clean$PCF_cc) < 0.01))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped ",
          "(add a registry row: proposed code UMI%3A3017523_TableA-11).")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
