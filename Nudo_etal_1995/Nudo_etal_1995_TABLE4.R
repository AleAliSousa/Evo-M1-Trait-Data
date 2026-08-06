# Nudo et al. 1995 - TABLE 4: MAXIMUM surface density of corticospinal (CS) somata, by region.
#
# PRINTED SOURCE -> the frozen copy is Nudo_etal_1995_TABLE4_snapshot.xlsx (sheet "TABLE4"),
# captured by Nudo_etal_1995_extract_snapshot.py from a 300-dpi render of p. 187. This script
# reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES (24), printed row order kept (identical to TABLES 2 and 5).
#
# UNITS - printed vs corrected. The caption prints "(cells/mm2)" with a true superscript two;
# the PDF's OCR text layer mangles it to "cells/mm'", which is an ARTEFACT OF THE TEXT LAYER,
# not a print error (verified on a 900-dpi render of p. 187). Both forms are recorded:
#     printed caption          "TABLE 4. Maximum Surface Density of Corticospinal Somata
#                               (cells/mm2)"   [superscript 2, kept verbatim in the snapshot]
#     text-layer rendering     "(cells/mm')"   [OCR artefact - do not propagate]
#     unit used here           cells per mm2   -> column suffix ".cells_per_mm2"
# No numeric conversion (an areal density is not one of the mass/volume classes of sec 6).
#
# Definition (Methods, p. 184): "the maximum number of labeled somata under each unit surface
# area of neocortex", estimated by counting labelled somata subjacent to each
# 250 um x 50 um patch of neocortical surface. A printed 0 in C / C' means the region does not
# exist in that species (region C = primates only, C' = rodents + rabbit only) - a true zero,
# not a missing value.
#
# Source: Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol
#   358(2):181-205. DOI 10.1002/cne.903580203.

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
paper_dir <- dirname(.sp)
item_name <- "Nudo_etal_1995_TABLE4"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
TOKEN <- "Nudo1995"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
read_key_rows <- function() {
  out <- list()
  if (!is.na(dataset_root))
    for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                          recursive = TRUE, full.names = TRUE)) {
      k <- read.csv(kf, stringsAsFactors = FALSE)
      if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
      k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
      if (nrow(k)) out[[length(out) + 1L]] <- k[, c("variant_name", "accepted_name")]
    }
  if (length(out)) return(do.call(rbind, out))
  staged <- file.path(paper_dir, "PROPOSED_species_key_rows.csv")
  if (file.exists(staged)) {
    warning("No '", TOKEN, "' rows in _keys/*/species_key.csv - falling back to the staged ",
            "PROPOSED_species_key_rows.csv. Merge it into the key, then delete the staged file.")
    k <- read.csv(staged, stringsAsFactors = FALSE)
    return(k[trimws(k$source_publication) == TOKEN, c("variant_name", "accepted_name")])
  }
  data.frame(variant_name = character(0), accepted_name = character(0))
}
km <- local({
  k <- read_key_rows(); m <- list()
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(m[[v]])) m[[v]] <- k$accepted_name[i]
  }
  m
})
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. NUMBER PARSING -----------------------------------------------
NA_TOKENS <- c("", "-", "–", "—", "NA", "n.a.", "n/a", "__", "e")
well_formed <- function(tok) {
  tok <- trimws(tok)
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
num1 <- function(tok) {
  tok <- trimws(as.character(tok))
  if (tok %in% NA_TOKENS) return(NA_real_)
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}

## 4. READ SNAPSHOT ------------------------------------------------
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE4", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$V1) & nzchar(snap$V2), , drop = FALSE]

## 5. BUILD --------------------------------------------------------
# "Lagamorpha" is printed in the rabbit row (TABLE 3 prints "Lagomorpha"); the printed string
# is kept and the correction is made visible in Order_resolved + parse_flags.
ORDER_FIX <- c(Camivora = "Carnivora", Lagamorpha = "Lagomorpha")
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  flags <- character(0)
  parts  <- strsplit(r[1], "/", fixed = TRUE)[[1]]
  common <- trimws(parts[1]); gs <- trimws(parts[2]); ord <- trimws(parts[3])
  ord_ok <- if (!is.na(ORDER_FIX[ord])) unname(ORDER_FIX[ord]) else ord
  if (ord_ok != ord) flags <- c(flags, sprintf("order printed '%s' - typographic error for '%s'",
                                               ord, ord_ok))
  for (k in 2:5) if (nzchar(r[k]) && is.na(num1(r[k])))
    flags <- c(flags, sprintf("column %d printed '%s' - not parseable as a number", k, r[k]))
  A <- num1(r[2]); B <- num1(r[3]); C <- num1(r[4]); Cp <- num1(r[5])
  # region A is by definition the zone of highest density; B/C/C' should not exceed it
  for (p in list(list("B", B), list("C", C), list("C'", Cp)))
    if (!is.na(A) && !is.na(p[[2]]) && p[[2]] > A)
      flags <- c(flags, sprintf("max density in region %s (%g) exceeds region A (%g)",
                                p[[1]], p[[2]], A))
  out <- rbind(out, data.frame(
    Animal_Nudo1995                = r[1],
    animal_common_Nudo1995         = common,
    gs_initials_Nudo1995           = gs,
    Order_Nudo1995                 = ord,
    Order_resolved                 = ord_ok,
    species_sci                    = resolve(gs),
    max_surface_density_A.cells_per_mm2      = A,
    max_surface_density_B.cells_per_mm2      = B,
    max_surface_density_C.cells_per_mm2      = C,
    max_surface_density_Cprime.cells_per_mm2 = Cp,
    method = "max labelled somata subjacent to a 250 um x 50 um patch of neocortical surface",
    parse_flags = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL

## 5b. CHECKS (against figures the paper states in its text, p. 187) --
stopifnot(nrow(out) == 24)
cat(sprintf("  mean max density region A = %.0f cells/mm2 (paper: 1,367)\n",
            mean(out$max_surface_density_A.cells_per_mm2)))
cat(sprintf("  mean max density region B = %.0f cells/mm2 (paper: 421; = %.0f%% of A, paper: ~31%%)\n",
            mean(out$max_surface_density_B.cells_per_mm2),
            100 * mean(out$max_surface_density_B.cells_per_mm2) /
                  mean(out$max_surface_density_A.cells_per_mm2)))
pr <- out[out$Order_resolved == "Primates", ]
cat(sprintf("  primates: mean region C = %.0f (paper: 522; = %.0f%% of primate A, paper: ~43%%)\n",
            mean(pr$max_surface_density_C.cells_per_mm2),
            100 * mean(pr$max_surface_density_C.cells_per_mm2) /
                  mean(pr$max_surface_density_A.cells_per_mm2)))
cp <- out[out$max_surface_density_Cprime.cells_per_mm2 > 0, ]
cat(sprintf("  C'-bearing species (n=%d): mean C' = %.0f (paper: 994; = %.0f%% of their A, paper: ~49%%)\n",
            nrow(cp), mean(cp$max_surface_density_Cprime.cells_per_mm2),
            100 * mean(cp$max_surface_density_Cprime.cells_per_mm2) /
                  mean(cp$max_surface_density_A.cells_per_mm2)))

## 6. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}
cat(sprintf("Nudo TABLE 4: %d rows, %d flagged\n", nrow(out), sum(!is.na(out$parse_flags))))
