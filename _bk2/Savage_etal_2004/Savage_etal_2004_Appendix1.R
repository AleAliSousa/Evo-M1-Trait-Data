# Savage_etal_2004_Appendix1.R
#
# Reformat: frozen snapshot -> analysis CSV -> public TSV
#
# Source: Savage, V. M., Gillooly, J. F., Woodruff, W. H., West, G. B., Allen, A. P., Enquist, B. J.,
# & Brown, J. H. (2004). The predominance of quarter-power scaling in biology. Functional Ecology,
# 18(2), 257-282. https://doi.org/10.1111/j.0269-8463.2004.00856.x
# Appendix 1 (printed pp. 268-281): mammalian basal metabolic rate (BMR, W) and body mass (g),
# one printed row per literature measurement, with the species average (mean of the logarithms,
# back-transformed) printed on the first row of each species -- 626 species.
#
# Frozen source: Savage_etal_2004_Appendix1_snapshot.csv, written from the PDF text layer by
# Savage_etal_2004_Appendix1_extract_snapshot.R (values exactly as printed: "·" decimal, spaced
# thousands). This script reads it; it never contains table values.
# The bibliography (printed pp. 265-267) is read from the same journal PDF for the references table.

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
item_name <- sub("\\.R$", "", basename(.sp))     # "Savage_etal_2004_Appendix1" = __ReadMe.xlsx "Item name"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))
pdf_file  <- file.path(item_dir, "Savage-2004-The predominance of quarter-power.pdf")

# ---- 1. Read the frozen snapshot (header read; values as printed, all character) ----
snap <- read.csv(frozen, check.names = FALSE, colClasses = "character", na.strings = character(0),
                 encoding = "UTF-8")
if (nrow(snap) != 1006L) stop("expected 1,006 printed measurement rows, got ", nrow(snap), call. = FALSE)

# ---- 2. Clean: printed number "34 779·3" -> 34779.3 (strip thousands spaces, "·" -> ".") ----
num <- function(x) {
  x <- gsub(" ", "", gsub("\u00b7", ".", x, fixed = TRUE), fixed = TRUE)
  x[x %in% c("", "-", "\u2013", "\u2014", "NA", "n.a.")] <- NA
  as.numeric(x)
}
final.dataframe <- data.frame(
  Order              = snap$Order,
  Family             = snap$Family,
  Species_Savage2004 = snap$Species,             # printed binomial, kept verbatim
  Mass_g             = num(snap$`Mass (g)`),     # g = project body-mass unit; no conversion
  BMR_W              = num(snap$`BMR (W)`),      # watts, as printed
  Species_avg_mass_g = num(snap$`Species avg. mass (g)`),
  Species_avg_BMR_W  = num(snap$`Species avg. BMR (W)`),
  References         = gsub(",\\s*(?=[A-Z])", "; ", snap$References, perl = TRUE),  # house "; " separator
  stringsAsFactors = FALSE)
## Observation level: one row per printed literature measurement. The species average is printed
## once, on the first row of each species; species_block numbers those printed groups so the
## average can be carried to every row of its species without re-deriving it.
final.dataframe$species_block <- cumsum(!is.na(final.dataframe$Species_avg_mass_g))
final.dataframe$is_species_avg_row <- !is.na(final.dataframe$Species_avg_mass_g)
if (any(is.na(final.dataframe$Mass_g) | is.na(final.dataframe$BMR_W)))
  stop("a printed row lost its mass or BMR in cleaning", call. = FALSE)

# ---- 3. Table check: printed species average = back-transformed mean of logs, at print precision ----
## Methods (p. 259): "...averaged the logarithms for each species, resulting in values for 626 species".
## Mass average is printed to 1 decimal: recomputed from the printed rows it must round to the print
## (tolerance 0.05 g). BMR average is printed to 3 decimals, but the per-row BMRs it is averaged from
## are themselves printed rounded to 3 decimals, so recomputing from the printed rows can drift by up
## to one unit in the last place: tolerance 0.001 W (41 multi-row species fall between 0.0005 and 0.001).
blocks <- split(final.dataframe, final.dataframe$species_block)
table_checks <- do.call(rbind, lapply(blocks, function(b) data.frame(
  species_block = b$species_block[1], Species_Savage2004 = b$Species_Savage2004[1], n_rows = nrow(b),
  one_species_in_block = length(unique(b$Species_Savage2004)) == 1L,
  printed_avg_mass_g = b$Species_avg_mass_g[1], computed_avg_mass_g = exp(mean(log(b$Mass_g))),
  printed_avg_BMR_W  = b$Species_avg_BMR_W[1],  computed_avg_BMR_W  = exp(mean(log(b$BMR_W))))))
table_checks$mass_check <- ifelse(abs(table_checks$computed_avg_mass_g - table_checks$printed_avg_mass_g) <= 0.05 + 1e-9, "PASS", "FAIL")
table_checks$BMR_check  <- ifelse(abs(table_checks$computed_avg_BMR_W  - table_checks$printed_avg_BMR_W)  <= 0.001 + 1e-9, "PASS", "FAIL")
cat("species blocks:", nrow(table_checks), "| single-species blocks:", sum(table_checks$one_species_in_block),
    "| mass PASS:", sum(table_checks$mass_check == "PASS"), "| BMR PASS:", sum(table_checks$BMR_check == "PASS"), "\n")
if (nrow(table_checks) != 626L) stop("expected 626 species averages (Methods p. 259)", call. = FALSE)
write.csv(table_checks, file.path(item_dir, "reference_tables", paste0(item_name, "_table_checks.csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

# ---- 4. References table: one row per printed key, citation verbatim from the bibliography ----
W <- pdftools::pdf_data(pdf_file)
bib_pages <- which(vapply(pdftools::pdf_text(pdf_file), function(t) grepl("Banavar, J\\.R\\.|Weiner, J\\. \\(1977\\)|Calder, W\\.A\\.", t), TRUE))
lines <- character(0)
for (pg in bib_pages) {
  d <- as.data.frame(W[[pg]], stringsAsFactors = FALSE)
  d <- d[d$height <= 7 & d$y > 20 & d$x > 100, ]            # drop left-margin running head
  for (s in list(d[d$x < 330, ], d[d$x >= 330, ])) {        # two text columns
    s <- s[order(s$y, s$x), ]; g <- cumsum(c(TRUE, diff(s$y) > 2))
    lines <- c(lines, vapply(split(s, g), function(w) paste(w$text[order(w$x)], collapse = " "), ""))
  }
}
starts <- grepl("^[A-Z][A-Za-z'\u2019 -]+, (?:[A-Z]\\.)+", lines, perl = TRUE)
entries <- vapply(split(lines[cumsum(starts) > 0], cumsum(starts)[cumsum(starts) > 0]),
                  function(x) Reduce(function(a, b) if (grepl("-$", a) && grepl("^[a-z]", b)) paste0(sub("-$", "", a), b) else paste(a, b), x), "")
keys <- unique(trimws(unlist(strsplit(final.dataframe$References, "; ", fixed = TRUE))))
find_entry <- function(k) {
  yr <- sub(".*\\(([0-9]{4}[a-z]?)\\)$", "\\1", k)
  au <- trimws(strsplit(sub("\\s*(et al\\.)?\\s*\\(.*$", "", k), " & ", fixed = TRUE)[[1]])
  hit <- entries[startsWith(entries, paste0(au[1], ",")) & grepl(paste0("(", yr, ")"), entries, fixed = TRUE)]
  if (length(au) > 1) hit <- hit[grepl(paste0("& ", au[2], ","), hit, fixed = TRUE)]
  if (grepl("et al\\.", k)) hit <- hit[grepl(",.*,.*&", sub("\\(.*$", "", hit))]
  hit
}
references <- do.call(rbind, lapply(keys, function(k) {
  h <- find_entry(k)
  data.frame(ref_key = k, cited_in_column = "References",
             citation = if (length(h) == 1L) h else "",
             note = if (length(h) == 1L) "" else if (length(h) == 0L) "cited in Appendix 1 but no matching entry found in the printed bibliography" else "several bibliography entries match; resolve by hand",
             stringsAsFactors = FALSE)
}))
references$n_rows <- vapply(references$ref_key, function(k)
  sum(vapply(strsplit(final.dataframe$References, "; ", fixed = TRUE), function(x) k %in% x, TRUE)), 0L)
print(references[, c("ref_key", "n_rows", "note")], row.names = FALSE)
write.csv(references, file.path(item_dir, "reference_tables", paste0(item_name, "_references.csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

# ---- 5. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 6. Public TSV: look up Item encoded from __ReadMe.xlsx by Item name, write TSV ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- refusing to write NA.tsv", call. = FALSE)
tsv_dir  <- file.path(root, "__Public", "comparative-data")
tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 7. Validate ----
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
if (any(table_checks$mass_check == "FAIL" | table_checks$BMR_check == "FAIL" | !table_checks$one_species_in_block))
  stop("species-average table check failed -- see reference_tables/", item_name, "_table_checks.csv", call. = FALSE)
if (any(!nzchar(references$citation))) stop("unresolved reference key(s)", call. = FALSE)
if (any(checks$status == "FAIL"))
  stop("validation failed for ", item_name, ": ",
       paste(checks$check[checks$status == "FAIL"], collapse = ", "), call. = FALSE)
message("Built ", item_name, ": ", nrow(final.dataframe), " rows (", nrow(table_checks), " species) -> CSV + ",
        basename(tsv_path), "; ", nrow(references), " references")
