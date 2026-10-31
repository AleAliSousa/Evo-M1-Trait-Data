## Jones et al. (2009), PanTHERIA 1.0 -- frozen source (digital-native) -> long analysis CSV -> public TSV
##
## Source: Jones KE, Bielby J, Cardillo M, et al. (2009). PanTHERIA: a species-level database of life
##   history, ecology, and geography of extant and recently extinct mammals. Ecology 90:2648.
##   Ecological Archives E090-184. https://doi.org/10.1890/08-1494.1
## Frozen source: <item_name>_snapshot.txt = the published tab-delimited file, copy-renamed, bytes
##   untouched (WR05: PanTHERIA_1-0_WR05_Aug2008.txt, SHA-256 a98aa973...d4f6df6;
##   WR93: PanTHERIA_1-0_WR93_Aug2008.txt, SHA-256 dd98b18a...0661478796). The original-named files
##   stay in the folder and are read by the reference_tables scripts.
## Depends on reference_tables/Jones_etal_2009_references.csv and
##   reference_tables/Jones_etal_2009_References_malformed_tokens.csv (run Jones_etal_2009_references.R first)
##   and reference_tables/Jones_etal_2009_definitions.csv (Measure = Table 1 units).
## The same script body serves WR05 and WR93; the taxonomy is taken from item_name.
## Rebuilt 2026-10-30: previously this script wrote a wide CSV with -999 kept and copied the raw .txt
## to __Public under the bare Item encoded (no .tsv); that copy is left for the owner to remove.

options(scipen = 999)
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
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))
source(file.path(root, "_keys", "resolve_species.R"))

folder    <- basename(item_dir)                     # "Jones_etal_2009" = species_key source_publication
item_name <- sub("\\.R$", "", basename(.sp))
taxonomy  <- regmatches(item_name, regexpr("WR(05|93)", item_name))
msw       <- sub("WR", "MSW", taxonomy)
n_expected <- c(WR05 = 5416L, WR93 = 4629L)[[taxonomy]]
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.txt"))
reftab    <- file.path(item_dir, "reference_tables")

# ---- 1. Read the frozen source (all character; -999 kept until step 3) ----
dat <- read.delim(frozen, sep = "\t", quote = "", check.names = FALSE, colClasses = "character",
                  na.strings = character(0), comment.char = "")
if (nrow(dat) != n_expected || ncol(dat) != 55L)
  stop("expected ", n_expected, " x 55, got ", nrow(dat), " x ", ncol(dat), call. = FALSE)
tax_cols <- paste0(msw, c("_Order", "_Family", "_Genus", "_Species", "_Binomial"))
if (!identical(names(dat)[1:5], tax_cols) || names(dat)[36] != "References")
  stop("unexpected header in frozen source", call. = FALSE)
if (anyDuplicated(dat[[tax_cols[5]]])) stop("duplicate binomials", call. = FALSE)

# ---- 2. Species harmonisation (_keys/General, source_publication = folder) ----
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                       check.names = FALSE, encoding = "UTF-8")
if (sum(trimws(key$source_publication) == folder) == 0L)
  stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
rs <- resolve_species(dat[[tax_cols[5]]], source_publication = folder)
## 'paper' = variant rows for this folder (identity mappings adopted from curated key rows);
## 'variant'/'hub' = printed name already resolvable in the project keys/hub; 'unresolved' = outside
## the project's species hub (printed name kept, species_harmonised NA); 'ambiguous' left NA.
species_harmonised <- ifelse(rs$match_level %in% c("paper", "variant", "hub"), rs$accepted_name, NA_character_)

# ---- 3. Long table: species x variable, non-missing values only ----
## Variables: metadata Table 1 source variables (cols 6-35) and EXT/spatial derived variables (37-55);
## col 36 References is per species and carried on every row. Missing sentinel -999 / -999.00 dropped.
## Units are PanTHERIA's own (Measure from Jones_etal_2009_definitions.csv, matched by column position
## to the WR05 code); body masses are already g (project unit), so no conversion.
defs  <- utils::read.csv(file.path(reftab, "Jones_etal_2009_definitions.csv"), stringsAsFactors = FALSE,
                         check.names = FALSE, encoding = "UTF-8")
wr05_codes <- defs$Code[1:55]
if (wr05_codes[36] != "References") stop("definitions file column order changed", call. = FALSE)
var_idx <- c(6:35, 37:55)
refs_printed <- dat$References
refs_house   <- ifelse(refs_printed %in% c("-999", "-999.00"), NA_character_,
                       gsub("\\s*;\\s*", "; ", trimws(refs_printed)))
long <- do.call(rbind, lapply(var_idx, function(j) {
  v <- dat[[j]]
  keep <- !grepl("^-999(\\.0+)?$", v)
  if (!any(keep)) return(NULL)
  data.frame(source_row = which(keep), column_position = j, variable_as_published = names(dat)[j],
             variable_code_WR05 = wr05_codes[j], value_as_published = v[keep],
             stringsAsFactors = FALSE)
}))
long$value <- suppressWarnings(as.numeric(long$value_as_published))
if (anyNA(long$value))
  stop("non-numeric value cells: ", paste(head(unique(long$value_as_published[is.na(long$value)])), collapse = ", "), call. = FALSE)
long$unit <- defs$Measure[match(long$variable_code_WR05, defs$Code)]
long$variable_group <- ifelse(long$column_position <= 35, "source_variable",
                         ifelse(long$column_position <= 40, "EXT_extrapolated", "spatial_derived"))
long <- long[order(long$source_row, long$column_position), ]

final.dataframe <- data.frame(
  source_row            = long$source_row,
  Order                 = dat[[tax_cols[1]]][long$source_row],
  Family                = dat[[tax_cols[2]]][long$source_row],
  Genus                 = dat[[tax_cols[3]]][long$source_row],
  Species_epithet       = dat[[tax_cols[4]]][long$source_row],
  Species_Jones2009     = dat[[tax_cols[5]]][long$source_row],
  species_harmonised    = species_harmonised[long$source_row],
  species_match_level   = rs$match_level[long$source_row],
  taxonomy              = taxonomy,
  variable_as_published = long$variable_as_published,
  variable_group        = long$variable_group,
  value_as_published    = long$value_as_published,
  value                 = long$value,
  unit                  = long$unit,
  References            = refs_house[long$source_row],
  data_role             = ifelse(long$column_position <= 35, "secondary", "derived"),
  stringsAsFactors = FALSE)
rownames(final.dataframe) <- NULL

# ---- 4. Per-item reference lookup (ref_key exactly as printed in References) ----
bib <- utils::read.csv(file.path(reftab, "Jones_etal_2009_references.csv"), stringsAsFactors = FALSE,
                       colClasses = "character", encoding = "UTF-8")
fused <- utils::read.csv(file.path(reftab, "Jones_etal_2009_References_malformed_tokens.csv"),
                         stringsAsFactors = FALSE, colClasses = "character", encoding = "UTF-8")
fused <- unique(fused[fused$taxonomy == taxonomy, c("token_as_printed", "decoded_as")])
used  <- unique(unlist(strsplit(stats::na.omit(refs_house), "; ", fixed = TRUE)))
used  <- used[order(suppressWarnings(as.numeric(used)))]
cit   <- bib$citation[match(used, bib$ref_number)]
note  <- ifelse(used == "3018", "bibliography entry printed truncated ('Wiles, G. 1996.'), kept verbatim", "")
is_f  <- used %in% fused$token_as_printed
if (any(is_f)) {
  dec <- fused$decoded_as[match(used[is_f], fused$token_as_printed)]
  cit[is_f]  <- vapply(strsplit(dec, ";", fixed = TRUE),
                       function(p) paste(bib$citation[match(p, bib$ref_number)], collapse = " || "), "")
  note[is_f] <- paste0("fused token as printed (missing ';'): decodes to ", dec,
                       " (Jones_etal_2009_References_malformed_tokens.csv); both citations shown, ' || '-separated")
}
if (anyNA(cit) || any(!nzchar(cit)))
  stop("References keys without a citation: ", paste(used[is.na(cit) | !nzchar(cit)], collapse = ", "), call. = FALSE)
references <- data.frame(ref_key = used, cited_in_column = "References", citation = cit,
                         note = note, stringsAsFactors = FALSE)
write.csv(references, file.path(reftab, paste0(item_name, "_references.csv")), row.names = FALSE, fileEncoding = "UTF-8")

# ---- 5. Write the analysis CSV ----
csv_path <- file.path(item_dir, paste0(item_name, ".csv"))
write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 6. Public TSV: Item encoded from the live __ReadMe.xlsx by Item name ----
filecodes    <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- refusing to write NA.tsv", call. = FALSE)
tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")

# ---- 7. Validate ----
checks <- validate_dataset_item(
  csv_file = csv_path, tsv_file = tsv_path,
  readme_file = file.path(item_dir, paste0(item_name, ".ReadMe.md")),
  definitions_file = file.path(reftab, paste0(item_name, "_definitions.csv")),
  frozen_source_file = frozen, registry = filecodes, item_name = item_name, item_encoded = item_encoded)
print(checks)
message(item_name, ": ", nrow(final.dataframe), " long rows from ", nrow(dat), " species; ",
        sum(!is.na(species_harmonised)), " species harmonised; ", nrow(references), " ref keys -> ", tsv_path)
print(table(rs$match_level))
