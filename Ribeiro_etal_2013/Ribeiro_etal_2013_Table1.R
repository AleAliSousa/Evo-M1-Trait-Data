## Ribeiro et al. 2013 — Table 1 (human cortical cell densities by region)
## doi:10.3389/fnana.2013.00028
##
## PRINTED SOURCE -> the frozen copy is Ribeiro_etal_2013_Table1_snapshot.xlsx (sheet
## "Table1"), captured from the article PDF by Ribeiro_etal_2013_extract_snapshot.py. This
## script reads ONLY that snapshot (golden rule: all cleaning happens here).
##
## Shape: ONE ROW PER PRINTED CORTICAL REGION (7), all from ONE individual — the right
## cerebral cortex of a 65-year-old human female, cut into 101 coronal sections of 2 mm
## (Methods, "Subject" and "Morphometry"). Each printed value is a MEAN ACROSS THE SECTIONS
## of that region, not a whole-region total.
##
## *** REGIONAL, NEVER POOLED ***
## These are WITHIN-CORTEX regional densities. They must never be averaged into, or
## compared as equals with, the whole-cortex CerebralCortex_* terms that Homo sapiens
## already has in __merging_cellcounts (from Herculano-Houzel et al. 2015) — exactly the
## rule Jacobs_etal_2018/README.md states for M1. The seven region means are also not
## weighted by region mass, so they cannot be recombined into a cortex-wide mean.
##
## Units (NOT printed in the table header; taken from the Results text, "Distribution of
## neuronal and other cell densities": "neuronal density varies 5x (between approximately
## 10,000 and 50,000 N/mg), and other cell density varies 3x (approximately 30,000-90,000
## O/mg)"). So: neurons per mg and other cells per mg of cortical GRAY matter
## (Methods: DN and DO are defined as densities "in the gray matter"). O/N is
## dimensionless. Nothing is unit-converted.
##
## Source: Ribeiro, P. F. M., Ventura-Antunes, L., Gabi, M., Mota, B., Grinberg, L. T.,
##   Farfel, J. M., Ferretti-Rebustini, R. E. L., Leite, R. E. P., Jacob Filho, W., &
##   Herculano-Houzel, S. (2013). The human cerebral cortex is neither one nor many...
##   Front. Neuroanat. 7:28. DOI 10.3389/fnana.2013.00028.

## 0. PATHS — self-contained ----------------------------------------------------------------
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
paper_dir    <- dirname(.sp)
table_name   <- "Ribeiro_etal_2013_Table1"
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_xlsx  <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA

## 1. PACKAGES -------------------------------------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) --------------------------
## The table prints no species: this is a single-species human study and the paper names its
## subject only as "human" (title, abstract, Methods "Subject"). That printed word is kept as
## Species_Ribeiro2013 and resolved through the species key — never by an inline map.
TOKEN <- "Ribeiro2013"
SPECIES_PRINTED <- "human"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
key_files <- if (!is.na(dataset_root))
  list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
             recursive = TRUE, full.names = TRUE) else character(0)
## Staging file with the key's own three-column schema; read only until these rows are
## merged into _keys/Stephan/species_key.csv (the key is consulted first).
proposed <- file.path(paper_dir, "PROPOSED_species_key_rows.csv")
if (file.exists(proposed)) key_files <- c(key_files, proposed)
km <- list(); km_src <- list()
for (kf in key_files) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
  k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && !(v %in% names(km))) { km[[v]] <- k$accepted_name[i]; km_src[[v]] <- kf }
  }
}
pending <- names(km_src)[vapply(km_src, function(f) identical(f, proposed), logical(1))]
if (length(pending))
  warning("species_key.csv still lacks ", TOKEN, " rows for: ",
          paste(pending, collapse = "; "),
          " — resolved from PROPOSED_species_key_rows.csv until they are merged.",
          call. = FALSE)
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  if (tolower(cx) %in% names(km)) return(km[[tolower(cx)]])
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. CELL PARSING (guarded — never guess) ----------------------------------------------------
## Printed cell forms:  "17,742 ± 4,240"  "25,394 ± 4,595***"  "2.291 ± 0.366"
## A thousands comma is accepted only when every group after the first is exactly three
## digits, so a printer's comma-for-decimal-point cannot silently multiply a value by 1000
## (the Jacobs_etal_2018_Table3.R guard). Trailing *, ** or *** are the ANOVA significance
## markers defined in the printed legend and are split off into their own columns.
NA_TOKENS <- c("", "-", "–", "—", "NA", "n.a.", "__", "e")
well_formed <- function(tok) {
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
num1 <- function(tok) {
  tok <- trimws(tok)
  if (tok %in% NA_TOKENS) return(NA_real_)
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}
# "25,394 ± 4,595***" -> list(mean = 25394, se = 4595, sig = "***")
split_cell <- function(cell) {
  s <- trimws(gsub(" ", " ", as.character(cell)))
  sig <- regmatches(s, regexpr("\\*+$", s))
  sig <- if (length(sig)) sig else ""
  s <- sub("\\*+$", "", s)
  p <- strsplit(s, "±", fixed = TRUE)[[1]]
  list(mean = num1(p[1]),
       se   = if (length(p) > 1) num1(p[2]) else NA_real_,
       sig  = sig,
       raw  = trimws(as.character(cell)))
}

## 4. READ THE FROZEN SNAPSHOT ----------------------------------------------------------------
## Positional read: row 1 = caption, row 2 = the printed header, rows 3-9 = the seven printed
## region rows in printed order, then a blank row + the legend.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "Table1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in seq_len(ncol(snap))) snap[[j]] <- chr(snap[[j]])
stopifnot(snap[2, 1] == "Cortical region")
body <- snap[3:9, , drop = FALSE]
rownames(body) <- NULL
stopifnot(nrow(body) == 7, body[1, 1] == "Prefrontal", body[7, 1] == "V1")

## 5. BUILD ONE ROW PER PRINTED REGION ---------------------------------------------------------
## `region_term` is a MECHANICAL derivation of the printed label, offered as the
## never-pooled regional vocabulary discussed in __merging_cellcounts/
## HH_coverage_gaps_scaffold.md ("Design note"). That naming decision is still open, so the
## term is derived here rather than hand-listed, and the printed label is kept beside it.
out <- NULL
for (i in seq_len(nrow(body))) {
  nd <- split_cell(body[i, 2]); od <- split_cell(body[i, 3]); on <- split_cell(body[i, 4])
  flags <- character(0)
  for (nm in c("Neuronal density", "Other cell density", "O/N ratio")) {
    x <- switch(nm, "Neuronal density" = nd, "Other cell density" = od, on)
    if (nzchar(x$raw) && (is.na(x$mean) || is.na(x$se)))
      flags <- c(flags, sprintf("%s printed '%s' — not parseable", nm, x$raw))
  }
  out <- rbind(out, data.frame(
    Species             = resolve(SPECIES_PRINTED),
    Species_Ribeiro2013 = SPECIES_PRINTED,
    n                   = 1L,                       # one hemisphere of one individual
    Region              = body[i, 1],               # printed label, verbatim
    region_term         = paste0(gsub("[^A-Za-z0-9]", "", body[i, 1]), "CortexGrey"),
    CorticalGrey_N.p.mg      = nd$mean,
    CorticalGrey_N.p.mg_SE   = nd$se,
    CorticalGrey_O.p.mg      = od$mean,
    CorticalGrey_O.p.mg_SE   = od$se,
    CorticalGrey_O.p.N       = on$mean,
    CorticalGrey_O.p.N_SE    = on$se,
    sig_N.p.mg          = if (nzchar(nd$sig)) nd$sig else NA_character_,
    sig_O.p.mg          = if (nzchar(od$sig)) od$sig else NA_character_,
    sig_O.p.N           = if (nzchar(on$sig)) on$sig else NA_character_,
    parse_flags         = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}

## 6. CHECK: printed O/N ratio vs other-cell density / neuronal density -------------------------
## These are NOT expected to match exactly. Each printed value is a mean over the sections of
## the region, and mean(O_i/N_i) != mean(O_i)/mean(N_i) (Jensen). The check is kept as two
## explicit columns so the size of the gap is auditable rather than assumed.
out$ONratio_check_from_densities <- out$CorticalGrey_O.p.mg / out$CorticalGrey_N.p.mg
out$ONratio_check_pct_diff <- 100 * (out$CorticalGrey_O.p.N - out$ONratio_check_from_densities) /
  out$ONratio_check_from_densities
cat("O/N check (printed vs other-cell density / neuronal density):\n")
print(data.frame(Region = out$Region,
                 printed = out$CorticalGrey_O.p.N,
                 from_densities = round(out$ONratio_check_from_densities, 4),
                 pct_diff = round(out$ONratio_check_pct_diff, 2)), row.names = FALSE)
if (any(abs(out$ONratio_check_pct_diff) > 5, na.rm = TRUE))
  warning("a printed O/N ratio differs from O-density/N-density by more than 5% — inspect")

## 7. SAVE (LOCAL CSV + PUBLIC TSV) --------------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(table_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", table_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}
cat(sprintf("Ribeiro Table 1: %d cortical regions x %d columns; %d rows flagged\n",
            nrow(out), ncol(out), sum(!is.na(out$parse_flags))))
