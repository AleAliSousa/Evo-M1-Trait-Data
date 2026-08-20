## Kazu et al. 2015 — CORRIGENDUM, TABLE 1 (Artiodactyla cell counts)
## doi:10.3389/fnana.2015.00039   [corrigendum to doi:10.3389/fnana.2014.00128]
##
## PRINTED SOURCE -> the frozen copy is Kazu_etal_2015_TABLE1_snapshot.xlsx (sheet "TABLE1"),
## captured from the corrigendum PDF by Kazu_etal_2015_extract_snapshot.py. This script reads
## ONLY that snapshot (golden rule: all cleaning happens here, never in the frozen copy).
##
## THIS TABLE SUPERSEDES Kazu_etal_2014_Table1. The corrigendum states the reason in its own
## words: the cerebral-cortex totals were meant to include the hippocampus, but "values for the
## hippocampus had in four cases been included in the rest of brain, not cerebral cortex, ...
## and had failed to be included for Damaliscus", plus "a few other minor mistakes". The 2014
## build is kept as the historical printing and must NOT be merged; use this one.
##
## Deliberately a LINE-FOR-LINE PARALLEL of Kazu_etal_2014_Table1.R — same parser, same label
## map, same column schema, same consistency checks. That is what makes the two directly
## diffable, which is the job of
## private restricted_checks/Kazu_etal_2015/comparison/.
##
## Shape: ONE ROW PER SPECIES (5 artiodactyls, n = 1 specimen each, one hemisphere x 2).
## The printed table is transposed (structures as rows, species as columns); the reformat
## pivots it so the CSV/TSV is species-as-rows, as the cell-count merge expects.
##
## Units: masses printed in g are kept in g (the cell-count lineage's *_Mass.g); body mass
## printed in kg is converted to the project unit g (x1000, section 6 of the HOWTO).
## Densities are neurons/mg as printed; O/N is a dimensionless ratio.
##
## Source: Kazu, R. S., Maldonado, J., Mota, B., Manger, P. R., & Herculano-Houzel, S. (2015).
##   Corrigendum: Cellular scaling rules for the brain of Artiodactyla include a highly folded
##   cortex with few neurons. Front. Neuroanat. 9:39. DOI 10.3389/fnana.2015.00039.

## 0. PATHS — self-contained (Rscript or RStudio; full repo or lone folder) ----------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir   <- dirname(.sp)
table_name  <- "Kazu_etal_2015_TABLE1"                               # must match __ReadMe.xlsx Item name
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_xlsx  <- file.path(paper_dir, paste0(table_name, "_snapshot.xlsx"))
final_csv      <- file.path(paper_dir, paste0(table_name, ".csv"))
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA

## 1. PACKAGES -----------------------------------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) ------------------------
## Printed names are resolved ONLY through the species key, filtered to this paper's token.
## No hand-coded mapping lives in this script (HOWTO sec 5). The rows this table needs are
## proposed in Kazu_etal_2014/PROPOSED_species_key_rows.csv for merging into
## _keys/Stephan/species_key.csv.
TOKEN <- "Kazu2015"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
key_files <- if (!is.na(dataset_root))
  list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
             recursive = TRUE, full.names = TRUE) else character(0)
## Staging file, same three-column schema as the key. It exists only while this paper's
## rows are waiting to be merged into _keys/Stephan/species_key.csv; the key is read first,
## so once the rows land there this file changes nothing and can be deleted. It is read
## here so no species mapping is ever hand-coded into the script (HOWTO sec 5).
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

## 3. NUMBER PARSING (guarded — never guess) ------------------------------------------------
## Printed forms in this table:
##   "57.758"          plain decimal
##   "228,632"         thousands separators
##   "2.22 × 10^9"     mantissa x power of ten (the ^ marks the printed superscript;
##                     see Kazu_etal_2014_extract_snapshot.py for the transcription rule)
##   "n.a."            not available
##   "∼100"            approximate (body mass of the domestic pig)
## A thousands comma is accepted only when every group after the first is exactly three
## digits, so a printer's comma-for-decimal-point cannot silently multiply a value by 1000
## (the Jacobs_etal_2018_Table3.R guard). Anything else parses to NA and is named in
## parse_flags — never "corrected".
NA_TOKENS <- c("", "-", "–", "—", "NA", "n.a.", "__", "e")
well_formed <- function(tok) {
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
plain <- function(tok) {
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}
# returns c(value, approximate_flag); NA value = unparseable (caller flags it)
num1 <- function(cell) {
  tok <- trimws(as.character(cell))
  tok <- gsub(" ", " ", tok)
  if (is.na(tok) || tok %in% NA_TOKENS) return(c(NA_real_, 0))
  approx <- grepl("^[~∼≈]", tok)
  tok <- trimws(sub("^[~∼≈]", "", tok))
  if (grepl("×", tok)) {                                  # mantissa x 10^exp
    p <- strsplit(tok, "×", fixed = TRUE)[[1]]
    if (length(p) != 2) return(c(NA_real_, as.numeric(approx)))
    mant <- plain(trimws(p[1]))
    e <- trimws(p[2])
    if (!grepl("^10\\^-?[0-9]+$", e)) return(c(NA_real_, as.numeric(approx)))
    ex <- as.numeric(sub("^10\\^", "", e))
    return(c(mant * 10^ex, as.numeric(approx)))
  }
  c(plain(tok), as.numeric(approx))
}

## 4. READ THE FROZEN SNAPSHOT --------------------------------------------------------------
## Positional read (HOWTO sec 3): row 1 = caption, row 2 = the printed species header,
## rows 3-41 = the 39 printed data rows (label + 5 species), then a blank row + the legend.
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE1", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in seq_len(ncol(snap))) snap[[j]] <- chr(snap[[j]])

species_printed <- unlist(snap[2, -1], use.names = FALSE)
species_printed <- species_printed[nzchar(species_printed)]
stopifnot(length(species_printed) == 5)

body <- snap[3:41, , drop = FALSE]                              # the 39 printed data rows
rownames(body) <- NULL
stopifnot(nrow(body) == 39, body[1, 1] == "M_BD, kg", body[39, 1] == "O/N_OB")

## 5. MAP PRINTED ROW LABELS -> canonical <Structure>_<Measure> ------------------------------
## Structure names follow _keys/anatomy_reference.csv so the merge can pool across papers.
## Printed legend: BR whole brain (olfactory bulb excluded); CXT whole cerebral cortex
## (gray + white matter + hippocampus); GM cortical gray matter; HP hippocampus;
## CB cerebellum; RoB rest of brain (D+BG plus MES plus P+M); D+BG diencephalon + basal
## ganglia; MES mesencephalon; P+M pons + medulla; OB olfactory bulb.
STRUCT <- c(BD = "Body", BR = "WholeBrain", CXT = "CerebralCortex",
            GM = "CerebralCortexGrey", HP = "Hippocampus", CB = "Cerebellum",
            RoB = "RoB", "D+BG" = "DiencephalonStriatum", MES = "Mesencephalon",
            "P+M" = "PonsMedulla", OB = "OlfactoryBulb")
MEASURE <- c(M = "Mass.g", N = "N.n", DN = "N.p.mg", "O/N" = "O.p.N")

# The corrigendum is inconsistent with itself in the cortex subscript: it prints "M_CxT",
# "N_CxT" and "DN_CxT" with a lowercase x but "O/N_CXT" with an uppercase X, for the same
# structure. (The 2014 printing used CXT throughout.) The printed labels stay verbatim in the
# snapshot; the structure lookup is matched case-insensitively so both spellings resolve to
# CerebralCortex. This is a typographic normalisation, not a data change.
term_of <- function(label) {
  lab <- sub(",.*$", "", trimws(label))                          # drop the printed unit
  p <- strsplit(lab, "_", fixed = TRUE)[[1]]
  stopifnot(length(p) == 2, p[1] %in% names(MEASURE))
  hit <- match(tolower(p[2]), tolower(names(STRUCT)))
  stopifnot(!is.na(hit))
  paste0(STRUCT[[hit]], "_", MEASURE[[p[1]]])
}
terms <- vapply(body[[1]], term_of, character(1), USE.NAMES = FALSE)
stopifnot(!any(duplicated(terms)))

## 6. BUILD ONE ROW PER SPECIES + GUARDED PARSE ---------------------------------------------
out <- NULL
for (s in seq_along(species_printed)) {
  printed <- species_printed[s]
  row <- data.frame(
    Species          = resolve(printed),        # harmonised binomial (key-resolved)
    Species_Kazu2015 = printed,                 # printed name kept verbatim (invariant 3)
    n                = 1L,                      # Methods: one specimen per species
    stringsAsFactors = FALSE)
  flags <- character(0); approx_body <- FALSE
  for (i in seq_len(nrow(body))) {
    cell <- body[i, s + 1]
    v <- num1(cell)
    if (nzchar(cell) && !(cell %in% NA_TOKENS) && is.na(v[1]))
      flags <- c(flags, sprintf("%s printed '%s' — not parseable", body[i, 1], cell))
    if (v[2] == 1) {
      approx_body <- approx_body || terms[i] == "Body_Mass.g"
      flags <- c(flags, sprintf("%s printed '%s' — approximate", body[i, 1], cell))
    }
    row[[terms[i]]] <- v[1]
  }
  # project units: body mass printed in kg -> g (HOWTO sec 6)
  row$Body_Mass.g <- row$Body_Mass.g * 1000
  row$body_mass_approximate <- approx_body
  row$source_printing <- paste("Kazu et al. 2014 Table 1 as printed;",
                               "NOT the 2015 corrigendum (10.3389/fnana.2015.00039)")
  row$parse_flags <- if (length(flags)) paste(flags, collapse = "; ") else NA_character_
  out <- rbind(out, row)
}

## internal-consistency checks on the printed values (recorded, never silently repaired) ----
near <- function(a, b, tol) !is.na(a) && !is.na(b) && abs(a - b) <= tol * max(abs(b), 1)
cons <- character(nrow(out))
for (i in seq_len(nrow(out))) {
  f <- character(0)
  # mass additivity: whole brain = cortex + cerebellum + rest of brain
  ms <- out$CerebralCortex_Mass.g[i] + out$Cerebellum_Mass.g[i] + out$RoB_Mass.g[i]
  if (!is.na(ms) && !near(ms, out$WholeBrain_Mass.g[i], 1e-6))
    f <- c(f, sprintf("M_CXT+M_CB+M_RoB = %.3f != M_BR = %.3f", ms, out$WholeBrain_Mass.g[i]))
  # rest of brain = D+BG plus MES plus P+M (only where all three are printed)
  rs <- out$DiencephalonStriatum_Mass.g[i] + out$Mesencephalon_Mass.g[i] +
        out$PonsMedulla_Mass.g[i]
  if (!is.na(rs) && !near(rs, out$RoB_Mass.g[i], 1e-6))
    f <- c(f, sprintf("M_D+BG+M_MES+M_P+M = %.3f != M_RoB = %.3f", rs, out$RoB_Mass.g[i]))
  # neuron additivity: whole brain = cortex + cerebellum + rest of brain (0.5% tolerance,
  # because the printed N values are rounded to 3-5 significant figures)
  ns <- out$CerebralCortex_N.n[i] + out$Cerebellum_N.n[i] + out$RoB_N.n[i]
  if (!is.na(ns) && !is.na(out$WholeBrain_N.n[i]) && !near(ns, out$WholeBrain_N.n[i], 0.005))
    f <- c(f, sprintf("N_CXT+N_CB+N_RoB = %.4g != N_BR = %.4g (%.1f%%)",
                      ns, out$WholeBrain_N.n[i],
                      100 * (ns - out$WholeBrain_N.n[i]) / out$WholeBrain_N.n[i]))
  # density consistency: DN_x should equal N_x / (M_x in mg), 0.5% tolerance
  for (st in c("CerebralCortex", "Hippocampus", "Cerebellum", "RoB",
               "DiencephalonStriatum", "Mesencephalon", "PonsMedulla", "OlfactoryBulb")) {
    nn <- out[[paste0(st, "_N.n")]][i]; mm <- out[[paste0(st, "_Mass.g")]][i]
    dd <- out[[paste0(st, "_N.p.mg")]][i]
    if (!is.na(nn) && !is.na(mm) && !is.na(dd) && mm > 0 && !near(nn / (mm * 1000), dd, 0.005))
      f <- c(f, sprintf("DN_%s printed %.6g but N/M = %.6g (%.1f%%)", st, dd,
                        nn / (mm * 1000), 100 * (dd - nn / (mm * 1000)) / (nn / (mm * 1000))))
  }
  cons[i] <- if (length(f)) paste(f, collapse = "; ") else NA_character_
}
out$consistency_flags <- cons
out <- out[order(out$Species), ]
rownames(out) <- NULL

## 7. SAVE (LOCAL CSV + PUBLIC TSV) ---------------------------------------------------------
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
cat(sprintf("Kazu 2015 corrigendum TABLE 1: %d species x %d columns; %d rows with parse flags, %d with consistency flags\n",
            nrow(out), ncol(out), sum(!is.na(out$parse_flags)), sum(!is.na(out$consistency_flags))))
for (i in seq_len(nrow(out)))
  if (!is.na(out$consistency_flags[i]))
    cat("  ", out$Species_Kazu2015[i], ": ", out$consistency_flags[i], "\n", sep = "")
