# Andersen_etal_2022_TableS2.R -----------------------------------------------------
#
# Andersen, K. B., Hansen, A. K., Knudsen, K., Schacht, A. C., Damholdt, M. F.,
# Brooks, D. J., & Borghammer, P. (2022). Healthy brain aging assessed with
# [18F]FDG and [11C]UCB-J PET. Nuclear Medicine and Biology 112-113: 52-58.
# https://doi.org/10.1016/j.nucmedbio.2022.06.007
# "Table (S)2. Region of interest analysis of [11C]UCB-J SUVR-1 and [18F]FDG SUVR
# values for young versus old HC" (printed caption) of the journal-supplied
# supplement 1-s2.0-S0969805122020662-mmc1.docx.
#
# Frozen source: Andersen_etal_2022_TableS2_snapshot.docx, a copy-rename of the
# journal download (digital-native; never opened or re-saved). This script reads
# its word/document.xml directly (xml2) -- no table value is typed here.
#
# The table prints only P-values (old versus young HC, two-sample t test with
# equal variances), in two parts: A) uncorrected, B) Bonferroni corrected, each
# for four measures: [11C]UCB-J and [18F]FDG, CSO-normalised, without and with
# PVC. Output: one row per region x measure, with the part-A and part-B P side
# by side. table_checks: part B = min(1, k x part A) with k = number of VOI rows
# (14), within the rounding of the printed 3-decimal values.
#
# Units: P-values (unitless), as printed. No conversion applies.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base <- item_name

suppressPackageStartupMessages({ library(xml2); library(readxl); library(readr) })

## ---- read the frozen docx ----------------------------------------------------------
tmp <- tempfile(); dir.create(tmp)
unzip(paste0(base, "_snapshot.docx"), files = "word/document.xml", exdir = tmp)
doc <- read_xml(file.path(tmp, "word", "document.xml")); unlink(tmp, recursive = TRUE)
ns <- xml_ns(doc)
clean <- function(s) trimws(gsub("[[:space:]\u00a0]+", " ", s))
node_text <- function(n) clean(paste0(xml_text(xml_find_all(n, ".//w:t", ns)), collapse = ""))
## header cells hold two paragraphs ("Old versus young" / "[11C]UCB-J CSO norm"): keep the break
cell_text <- function(tc) paste(vapply(xml_find_all(tc, "./w:p", ns), node_text, character(1)), collapse = " | ")
kids <- xml_children(xml_find_first(doc, "//w:body", ns))
kind <- xml_name(kids)
txt  <- vapply(kids, node_text, character(1))
read_tbl <- function(node) {
  rows <- xml_find_all(node, "./w:tr", ns)
  do.call(rbind, lapply(rows, function(r) vapply(xml_find_all(r, "./w:tc", ns), cell_text, character(1))))
}
tbl_idx <- which(kind == "tbl")
cap_i <- which(kind == "p" & startsWith(txt, "Table (S)2. Region of interest analysis"))
stopifnot(length(cap_i) == 1L)
s2 <- tbl_idx[tbl_idx > cap_i][1:2]
tA <- read_tbl(kids[[s2[1]]]); tB <- read_tbl(kids[[s2[2]]])
meas <- c("[11C]UCB-J CSO norm", "[11C]UCB-J CSO norm PVC", "[18F]FDG CSO norm", "[18F]FDG CSO norm PVC")
stopifnot(identical(tA[1, ], c("A) VOI region", paste("Old versus young |", meas))),
          identical(tB[1, ], c("B) VOI region", paste("Old versus young |", meas))),
          nrow(tA) == 15L, nrow(tB) == 15L, identical(tA[-1, 1], tB[-1, 1]))
## the footnote paragraph after each part names its correction
fA <- txt[which(kind == "p" & seq_along(kind) > s2[1] & nzchar(txt))[1]]
fB <- txt[which(kind == "p" & seq_along(kind) > s2[2] & nzchar(txt))[1]]
stopifnot(startsWith(fA, "P designates the group test P-value (two-sample t test with equal variances)"),
          startsWith(fB, "P designates the group test P-value (Bonferroni corrected, two-sample t test"))

## ---- reshape: one row per region x measure ------------------------------------------
pv <- function(s) suppressWarnings(as.numeric(s))
k_vois <- nrow(tA) - 1L
final.dataframe <- do.call(rbind, lapply(seq_along(meas), function(j) data.frame(
  printed_row              = seq_len(k_vois),
  region_as_published      = tA[-1, 1],
  comparison               = "old versus young HC",
  measure_as_published     = meas[j],
  tracer                   = ifelse(grepl("UCB-J", meas[j]), "[11C]UCB-J", "[18F]FDG"),
  outcome                  = ifelse(grepl("UCB-J", meas[j]), "SUVR-1", "SUVR"),
  reference_region         = "centrum semiovale (CSO)",
  pvc                      = as.integer(grepl("PVC$", meas[j])),
  species_as_published     = "Homo sapiens",
  n_old                    = NA_integer_,
  n_young                  = NA_integer_,
  p_uncorrected_printed    = tA[-1, j + 1L],
  p_uncorrected            = pv(tA[-1, j + 1L]),
  p_bonferroni_printed     = tB[-1, j + 1L],
  p_bonferroni             = pv(tB[-1, j + 1L]),
  stringsAsFactors = FALSE)))
## group sizes from the supplement's own Fig. S1 panel labels (= main-text Table 1)
n_fig <- function(lbl) as.integer(sub(paste0("^.*", lbl, " HC=([0-9]+).*$"), "\\1",
                                      txt[kind == "p" & grepl(paste0(lbl, " HC="), txt)][1]))
final.dataframe$n_old <- n_fig("Old"); final.dataframe$n_young <- n_fig("Young")
stopifnot(identical(unique(final.dataframe$n_old), 15L), identical(unique(final.dataframe$n_young), 11L),
          !anyNA(final.dataframe$p_uncorrected), !anyNA(final.dataframe$p_bonferroni))
final.dataframe <- final.dataframe[order(final.dataframe$printed_row, match(final.dataframe$measure_as_published, meas)), ]
rownames(final.dataframe) <- NULL

## ---- table checks: B = min(1, k * A) --------------------------------------------------
## A prints 3 decimals: true A in [A - 0.0005, A + 0.0005] (>= 0). Expected B range
## = min(1, k * that interval); the printed B (+/- half a unit of its own last
## decimal; "1.0" -> 0.05) must overlap it. k = 14 VOI rows (Bonferroni over VOIs).
hu <- function(s) { d <- nchar(sub("^[^.]*\\.?", "", s)); 0.5 * 10^(-d) }
tc <- lapply(seq_len(nrow(final.dataframe)), function(i) {
  r <- final.dataframe[i, ]
  a_lo <- max(0, r$p_uncorrected - hu(r$p_uncorrected_printed)); a_hi <- r$p_uncorrected + hu(r$p_uncorrected_printed)
  e_lo <- min(1, k_vois * a_lo); e_hi <- min(1, k_vois * a_hi)
  b_lo <- r$p_bonferroni - hu(r$p_bonferroni_printed); b_hi <- r$p_bonferroni + hu(r$p_bonferroni_printed)
  ok <- b_hi >= e_lo - 1e-12 && b_lo <= e_hi + 1e-12
  data.frame(check_id = paste0("bonferroni_", r$region_as_published, "_", gsub("[^A-Za-z0-9]+", "", r$measure_as_published)),
             basis = sprintf("part B = min(1, %d x part A); row %s, %s", k_vois, r$region_as_published, r$measure_as_published),
             observed = min(1, k_vois * r$p_uncorrected), printed = r$p_bonferroni,
             difference = min(1, k_vois * r$p_uncorrected) - r$p_bonferroni,
             tolerance = (e_hi - e_lo) / 2 + hu(r$p_bonferroni_printed),
             status = if (ok) "pass" else "mismatch",
             note = sprintf("A printed %s -> expected B in [%.4f, %.4f]; B printed %s",
                            r$p_uncorrected_printed, e_lo, e_hi, r$p_bonferroni_printed),
             stringsAsFactors = FALSE)
})
table_checks <- do.call(rbind, tc)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad))) warning(bad$check_id[i], ": ", bad$note[i], call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write_csv(final.dataframe, paste0(base, ".csv"), na = "")    # readr: UTF-8 in any locale
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once registered) -----------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
