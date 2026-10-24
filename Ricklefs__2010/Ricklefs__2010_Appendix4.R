# Ricklefs__2010_Appendix4.R
#
# Reformat: frozen snapshot -> analysis CSV -> public TSV
#
# Source: Ricklefs, R. E. (2010). Life-history connections to rates of aging in terrestrial vertebrates.
# PNAS, 107(22), 10314-10319. https://doi.org/10.1073/pnas.1005862107 -- Supporting Information
# (sapp.pdf), APPENDIX 4 (SI pp. 5-17): parameters of Weibull functions m_x = m0 + a x^b fitted to
# survivorship, with omega = a^(1/(b+1)) the rate of actuarial aging; mammals (zoo and wild), birds and
# reptiles/amphibians (all captive). Zoo data: ISIS; wild: Ricklefs 1998 (ref 4), Lynch & Fagan 2009
# (ref 5, Note a), Loison et al. 1999 (ref 6, Note b).
#
# Frozen source: Ricklefs__2010_Appendix4_snapshot.csv, written from the SI text layer by
# Ricklefs__2010_SIAppendices_extract_snapshot.R. This script reads it; it never contains table values.

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
item_name <- sub("\\.R$", "", basename(.sp))     # "Ricklefs__2010_Appendix4" = __ReadMe.xlsx "Item name"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
pdf_file  <- file.path(item_dir, "sapp.pdf")

# ---- 1. Read the frozen snapshot (all character, as printed) ----
snap <- read.csv(frozen, check.names = FALSE, colClasses = "character", na.strings = character(0), encoding = "UTF-8")
if (nrow(snap) != 487L) stop("expected 487 printed rows, got ", nrow(snap), call. = FALSE)

# ---- 2. Clean ----
## "." = no value (as printed) and an empty cell -> NA. One m0 cell is printed "*.2827" (Myodes
## glareolus, wild, Note a): the asterisk is unexplained in the SI; the number is kept (0.2827) and the
## printed text recorded in value_flags.
num <- function(x) { x <- sub("^\\*", "", x); x[x %in% c("", ".")] <- NA; as.numeric(x) }
flag <- ifelse(grepl("^\\*", snap$m0), paste0("m0 printed '", snap$m0, "'"), "")
final.dataframe <- data.frame(
  Class_group          = snap$section,                       # printed section heading
  Order                = snap$Order,
  Family               = snap$Family,
  Genus                = snap$Genus,
  Species              = snap$Species,
  Species_Ricklefs2010 = paste(snap$Genus, snap$Species),    # printed binomial (spelling as printed)
  Status               = snap$Status,                        # printed for mammals only
  ## Birds and reptiles/amphibians: section notes "All data are from captive populations" -> zoo
  Population           = ifelse(nzchar(snap$Status), snap$Status, "zoo"),
  Weibull_b            = num(snap$b),
  Weibull_a            = num(snap$a),
  m0_per_y             = num(snap$m0),
  omega_per_y          = num(snap[["\u03c9"]]),
  n_deaths             = num(snap$n),
  oldest_y             = num(snap$oldest),
  Notes                = snap$Notes,
  stringsAsFactors = FALSE)
## Source per caption: zoo = ISIS; wild = ref 4 (Ricklefs 1998) unless Note a (ref 5) or b (ref 6)
final.dataframe$Source_ref <- with(final.dataframe, ifelse(Population == "zoo", "ISIS",
                                     ifelse(Notes == "a", "5", ifelse(Notes == "b", "6", "4"))))
final.dataframe$value_flags <- flag

# ---- 3. Table check: omega = a^(1/(b+1)) (caption), where a and b are printed ----
tc <- final.dataframe[!is.na(final.dataframe$Weibull_a) & !is.na(final.dataframe$Weibull_b) & !is.na(final.dataframe$omega_per_y),
                      c("Class_group", "Species_Ricklefs2010", "Population", "Weibull_a", "Weibull_b", "omega_per_y")]
tc$omega_computed <- tc$Weibull_a^(1 / (tc$Weibull_b + 1))
tc$rel_diff <- abs(tc$omega_computed - tc$omega_per_y) / tc$omega_per_y
## a is printed to 3 significant figures and omega to 3 decimals: allow 2% plus 0.001 absolute
tc$status <- ifelse(abs(tc$omega_computed - tc$omega_per_y) <= 0.02 * tc$omega_per_y + 0.001, "PASS", "CHECK")
table_checks <- tc
write.csv(table_checks, file.path(item_dir, "reference_tables", paste0(item_name, "_table_checks.csv")),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("omega check:", sum(tc$status == "PASS"), "PASS /", nrow(tc), "rows with a, b and omega;",
    sum(tc$status == "CHECK"), "CHECK\n")
print(tc[tc$status == "CHECK", ], row.names = FALSE)

# ---- 4. References (citations filled from the SI list below) ----
references <- data.frame(
  ref_key = c("ISIS", "4", "5", "6"), cited_in_column = "Source_ref",
  citation = c("International Species Information System (ISIS; www.isis.org/) -- zoo data (Appendix 4 caption)", "", "", ""),
  note = c("not a numbered reference; all rows with Population = zoo",
           "caption: Weibull parameters for wild populations obtained from Ricklefs (4); wild rows without a Note",
           "caption: fitted to data in Lynch and Fagan (5) -- printed Note a (caption prints 'Lunch and Fagan')",
           "caption: fitted to data in Loison et al. (6) -- printed Note b"),
  stringsAsFactors = FALSE)
references$n_rows <- vapply(references$ref_key, function(k) sum(final.dataframe$Source_ref == k), 0L)

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
