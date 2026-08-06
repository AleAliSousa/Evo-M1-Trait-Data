# Nudo et al. 1995 - TABLE 5: nine further morphological characteristics of corticospinal (CS)
# somata, per species.
#
# PRINTED SOURCE -> the frozen copy is Nudo_etal_1995_TABLE5_snapshot.xlsx (sheet "TABLE5"),
# captured by Nudo_etal_1995_extract_snapshot.py from a 300-dpi render of p. 188. This script
# reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES (24), printed row order kept (identical to TABLES 2 and 4).
#
# UNITS - printed vs corrected. Eight of the nine columns are dimensionless or already in the
# printed unit. One column's PRINTED UNIT IS WRONG:
#     printed header   "Thickness (um)"
#     printed values   0.10 - 0.71
#     the paper's own text (p. 187) calls the same numbers millimetres: "The highest value was
#     found in slow loris (0.71 mm) and the lowest ... short-tailed opossum (0.10 mm)".
#     0.71 um would be a hundredth of one soma; 0.71 mm is a plausible layer-V thickness.
#   -> the value is carried UNCHANGED and the unit is corrected in the column name:
#      CS_layer_thickness.mm. The printed unit is preserved in the snapshot header and named
#      in the definitions ("Source Note") - nothing is rescaled.
# Densities: cells/mm2 (surface) and cells/mm3 (volume), as printed. No conversion (sec 6 -
# these are areal/volumetric cell densities, not the mm3 structure-volume lineage).
#
# "n/a" is the paper's own missing-data token (hyrax concentration; armadillo / hyrax / least
# shrew concentration-of-large-cells) and becomes NA. It is NOT a zero - unlike the printed 0s
# in TABLES 2 and 4, which mean "this region does not exist in this species".
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
item_name <- "Nudo_etal_1995_TABLE5"
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
# "n/a" is in NA_TOKENS, so a printed n/a becomes NA and is NOT flagged as unparseable.
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
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE5", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$V1) & nzchar(snap$V2), , drop = FALSE]

## 5. BUILD --------------------------------------------------------
ORDER_FIX <- c(Camivora = "Carnivora", Lagamorpha = "Lagomorpha")
PCT_COLS <- c(6, 7, 9, 10)     # concentration, concentration (large cells), condensation,
                               # % medial-lateral distribution - all percentages
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  flags <- character(0)
  parts  <- strsplit(r[1], "/", fixed = TRUE)[[1]]
  common <- trimws(parts[1]); gs <- trimws(parts[2]); ord <- trimws(parts[3])
  ord_ok <- if (!is.na(ORDER_FIX[ord])) unname(ORDER_FIX[ord]) else ord
  if (ord_ok != ord) flags <- c(flags, sprintf("order printed '%s' - typographic error for '%s'",
                                               ord, ord_ok))
  for (k in 2:10) if (nzchar(r[k]) && !(trimws(r[k]) %in% NA_TOKENS) && is.na(num1(r[k])))
    flags <- c(flags, sprintf("column %d printed '%s' - not parseable as a number", k, r[k]))
  for (k in PCT_COLS) {
    v <- num1(r[k])
    if (!is.na(v) && (v < 0 || v > 100))
      flags <- c(flags, sprintf("column %d printed '%s' - outside 0-100 for a percentage",
                                k, r[k]))
  }
  out <- rbind(out, data.frame(
    Animal_Nudo1995                     = r[1],
    animal_common_Nudo1995              = common,
    gs_initials_Nudo1995                = gs,
    Order_Nudo1995                      = ord,
    Order_resolved                      = ord_ok,
    species_sci                         = resolve(gs),
    avg_surface_density.cells_per_mm2   = num1(r[2]),
    CS_layer_thickness.mm               = num1(r[3]),   # printed header says (um): WRONG,
                                                        # the paper's text calls these mm.
                                                        # Value unchanged, unit corrected.
    max_volume_density.cells_per_mm3    = num1(r[4]),
    column_height.cells                 = num1(r[5]),
    concentration_pct                   = num1(r[6]),
    concentration_large_cells_pct       = num1(r[7]),
    rostral_caudal_density_ratio        = num1(r[8]),
    condensation_pct                    = num1(r[9]),
    medial_lateral_position_pct         = num1(r[10]),
    parse_flags = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL

## 5b. CHECKS ------------------------------------------------------
stopifnot(nrow(out) == 24)
# The printed n/a cells are the only missing values, and they must be exactly these four.
na_cells <- with(out, paste(animal_common_Nudo1995[is.na(concentration_pct)], collapse = ", "))
cat(sprintf("  concentration n/a: %s (expected: Hyrax)\n", na_cells))
cat(sprintf("  concentration (large cells) n/a: %s (expected: Armadillo, Hyrax, Least shrew)\n",
            paste(out$animal_common_Nudo1995[is.na(out$concentration_large_cells_pct)],
                  collapse = ", ")))
# Statistics the paper states in its text (p. 187-188). NOTE: the avg-surface-density figures
# in the text do NOT agree with this table - see the README. The others do.
cat(sprintf("  mean column height       = %.2f cells   (paper text: 3.85)\n",
            mean(out$column_height.cells)))
cat(sprintf("  mean max volume density  = %.0f cells/mm3 (paper text: 5,606)\n",
            mean(out$max_volume_density.cells_per_mm3)))
cat(sprintf("  mean concentration       = %.1f %%       (paper text: 22.9)\n",
            mean(out$concentration_pct, na.rm = TRUE)))
cat(sprintf("  mean avg surface density = %.0f cells/mm2 (paper text: 260 -- DISAGREES, see README)\n",
            mean(out$avg_surface_density.cells_per_mm2)))

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
cat(sprintf("Nudo TABLE 5: %d rows, %d flagged\n", nrow(out), sum(!is.na(out$parse_flags))))
