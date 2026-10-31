## Nudo_Masterton_1990_IV_Figure2A.R -- frozen printed Fig. 2A (p.587, PDF page 4) -> analysis CSV + public TSV
##
## Nudo, R. J., & Masterton, R. B. (1990). Descending pathways to the spinal cord, IV: Some
## factors related to the amount of cortex devoted to the corticospinal tract. J Comp Neurol
## 296(4):584-597. doi:10.1002/cne.902960406
##
## Fig. 2A is a numeric table printed inside the figure: areas (sq. mm) of the cortical regions
## originating corticospinal fibres (Reg. A, B, C, C'), their sum ("CST cortex"), total neocortex
## and the percentage, for 22 mammals in descending order of the percentage.
## 2026-10-30: snapshot headings restored to the printed headings ("ANIMAL NAME - G.S.", "REG. A",
## ..., "% CST/TOT.CORT.") and ".9"/".4" cells to their printed form; the inline name map of the
## staged build was replaced by the collection key (_keys/General/species_key.csv), and the public
## TSV is now written (owner decision 2026-10-16 for this Nudo/Masterton series: TSV written with
## the CSV). Table checks: A+B+C+C' = CST cortex; 100*CST/total = printed %.

## 0. PATHS --------------------------------------------------------
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Nudo_Masterton_1990_IV_Figure2A"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
refs_csv     <- file.path(folder, "reference_tables", paste0(item_name, "_references.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## UTF-8 output even under Rscript in a C locale (printed labels carry µ, °, −)
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
library(readxl)

## SPECIES KEY (collection-scoped: _keys/General/species_key.csv, rows with
## source_publication == this folder's name). No mapping is hand-coded here.
key_file <- file.path(base, "_keys", "General", "species_key.csv")
key <- read.csv(key_file, stringsAsFactors = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == basename(folder), , drop = FALSE]
if (nrow(key) == 0L)
  stop("No species_key rows for source_publication == '", basename(folder),
       "' in ", key_file, call. = FALSE)
resolve <- function(x) {
  out <- key$accepted_name[match(tolower(trimws(x)), tolower(trimws(key$variant_name)))]
  bad <- unique(x[is.na(out) & !is.na(x) & nzchar(x)])
  if (length(bad)) stop("Printed names missing from species key: ",
                        paste(bad, collapse = "; "), call. = FALSE)
  out
}

## 2. LOAD -------------------------------------------------------------
snap <- utils::read.csv(snapshot_csv, header = FALSE, colClasses = "character", check.names = FALSE,
                        fill = TRUE, blank.lines.skip = FALSE, na.strings = NULL, skip = 2,
                        fileEncoding = "UTF-8")
names(snap) <- as.character(snap[1, ])
body <- snap[-1, , drop = FALSE]
stopifnot(nrow(body) == 22L, identical(names(snap)[2], "ANIMAL NAME - G.S."))

## 3. CLEAN -------------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(x))
final.dataframe <- tibble(
  rank = num(body[[1]]),
  animal_name_as_published = body[["ANIMAL NAME - G.S."]],
  species = resolve(body[["ANIMAL NAME - G.S."]]),
  species_key_basis = key$basis[match(tolower(trimws(body[["ANIMAL NAME - G.S."]])), tolower(trimws(key$variant_name)))],
  REG_A_sqmm = num(body[["REG. A"]]), REG_B_sqmm = num(body[["REG. B"]]),
  REG_C_sqmm = num(body[["REG. C"]]), REG_Cprime_sqmm = num(body[["REG. C'"]]),
  CST_cortex_sqmm = num(body[["CST CORTEX"]]), total_cortex_sqmm = num(body[["TOTAL CORTEX"]]),
  pct_CST_over_total_cortex = num(body[["% CST/TOT.CORT."]]),
  data_role = "primary",
  source_table = "Figure 2A", source_printed_page = 587L, source_pdf_page = 4L,
  DOI = "10.1002/cne.902960406")

## 7a. TABLE CHECKS ------------------------------------------------------
with(final.dataframe, {
  stopifnot(all(abs((REG_A_sqmm + REG_B_sqmm + REG_C_sqmm + REG_Cprime_sqmm) - CST_cortex_sqmm) < 0.05))
  stopifnot(all(abs(round(100 * CST_cortex_sqmm / total_cortex_sqmm, 1) - pct_CST_over_total_cortex) < 0.15))
  stopifnot(!is.unsorted(rev(pct_CST_over_total_cortex)))
})
cat("table_checks: 22/22 region sums = CST cortex; 22/22 pct reproduced; descending order OK\n")

## WRITE CSV + PUBLIC TSV ---------------------------------------------
final.dataframe <- final.dataframe %>% mutate(across(where(is.character), ~replace_na(., "")))
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
} else warning("__Public not mounted; TSV not written -- copy later")
cat("Built", item_name, ":", nrow(final.dataframe), "rows x", ncol(final.dataframe), "cols\n")
