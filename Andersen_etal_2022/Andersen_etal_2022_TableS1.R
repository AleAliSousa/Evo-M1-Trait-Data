# Andersen_etal_2022_TableS1.R -----------------------------------------------------
#
# Andersen, K. B., Hansen, A. K., Knudsen, K., Schacht, A. C., Damholdt, M. F.,
# Brooks, D. J., & Borghammer, P. (2022). Healthy brain aging assessed with
# [18F]FDG and [11C]UCB-J PET. Nuclear Medicine and Biology 112-113: 52-58.
# https://doi.org/10.1016/j.nucmedbio.2022.06.007
# Table S1 "Relative [18F]FDG uptake vs. [11C]UCB-J uptake differences (%)" of
# the journal-supplied supplement 1-s2.0-S0969805122020662-mmc1.docx.
#
# Frozen source: Andersen_etal_2022_TableS1_snapshot.docx, a copy-rename of the
# journal download (digital-native; never opened or re-saved). This script reads
# its word/document.xml directly (xml2) -- no table value is typed here.
#
# Table S1 is printed as three Word tables under one caption: "HC old" (docx
# table 1), "HC young" (docx table 2) -- per region the grey-matter-normalised
# [18F]FDG and [11C]UCB-J values, the relative difference (%) and its
# uncorrected P -- and a third table (cited in the main text as "Table S1 C")
# that repeats the Young and Old relative differences with an uncorrected
# young-vs-old P. Output: one row per region x group (HC old, HC young), with the
# part-C P carried on both rows. table_checks: the part-C Young/Old columns must
# equal the part-A/B relative differences (they are the same printed numbers).
#
# Units: GM-normalised uptake ratios (unitless) and percent, as printed. Project
# units (mm3, g, mg) do not apply; no conversion is made.

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

## ---- read the frozen docx: body-level paragraphs and tables in order ---------------
tmp <- tempfile(); dir.create(tmp)
unzip(paste0(base, "_snapshot.docx"), files = "word/document.xml", exdir = tmp)
doc <- read_xml(file.path(tmp, "word", "document.xml")); unlink(tmp, recursive = TRUE)
ns <- xml_ns(doc)
clean <- function(s) trimws(gsub("[[:space:]\u00a0]+", " ", s))
node_text <- function(n) clean(paste0(xml_text(xml_find_all(n, ".//w:t", ns)), collapse = ""))
kids <- xml_children(xml_find_first(doc, "//w:body", ns))
kind <- xml_name(kids)
txt  <- vapply(kids, node_text, character(1))
read_tbl <- function(node) {
  rows <- xml_find_all(node, "./w:tr", ns)
  do.call(rbind, lapply(rows, function(r)
    vapply(xml_find_all(r, "./w:tc", ns), node_text, character(1))))
}
tbl_idx <- which(kind == "tbl")
prev_par <- function(i) { j <- max(which(kind[seq_len(i - 1)] == "p" & nzchar(txt[seq_len(i - 1)]))); txt[j] }

## Table S1 = the three tables after the caption "Table S1. Relative ..."
cap_i <- which(kind == "p" & startsWith(txt, "Table S1. Relative [18F]FDG uptake vs. [11C]UCB-J uptake differences"))
stopifnot(length(cap_i) == 1L)
s1 <- tbl_idx[tbl_idx > cap_i][1:3]
stopifnot(identical(prev_par(s1[1]), "HC old"), identical(prev_par(s1[2]), "HC young"))
tA <- read_tbl(kids[[s1[1]]]); tB <- read_tbl(kids[[s1[2]]]); tC <- read_tbl(kids[[s1[3]]])
hdrAB <- c("Region (GM norm)", "[18F]FDG", "[11C]UCB-J", "Relative difference (%)", "P-value (uncorrected)")
stopifnot(identical(tA[1, ], hdrAB), identical(tB[1, ], hdrAB),
          identical(tC[1, ], c("Region (GM norm)", "Relative difference (%) Young",
                               "Relative difference (%) Old", "P-value (uncorrected)")),
          nrow(tA) == 14L, nrow(tB) == 14L, nrow(tC) == 14L,
          identical(tA[-1, 1], tB[-1, 1]), identical(tA[-1, 1], tC[-1, 1]))
foot_i <- which(kind == "p" & startsWith(txt, "Table S1. Percentage difference of [18F]FDG over [11C]UCB-J"))
stopifnot(length(foot_i) == 1L, foot_i > s1[3])

## ---- reshape ---------------------------------------------------------------------
num  <- function(s) suppressWarnings(as.numeric(gsub("\\s+", "", s)))  # " - 8.38" -> -8.38
pnum <- function(s) suppressWarnings(as.numeric(sub("^<", "", gsub("\\s+", "", s))))
pcen <- function(s) ifelse(grepl("^<", gsub("\\s+", "", s)), "<", "=")
## group sizes printed in the main text, Table 1 ("Sample size, n": HC young 11, HC old 15),
## and in the supplement's own Fig. S1 panel labels ("Young HC=11", "Old HC=15")
n_fig <- function(lbl) as.integer(sub(paste0("^.*", lbl, " HC=([0-9]+).*$"), "\\1",
                                      txt[kind == "p" & grepl(paste0(lbl, " HC="), txt)][1]))
n_old <- n_fig("Old"); n_young <- n_fig("Young")
stopifnot(identical(c(n_old, n_young), c(15L, 11L)))

one <- function(t, group, n) data.frame(
  docx_table           = match(group, c("HC old", "HC young")),
  printed_row          = seq_len(nrow(t) - 1L),
  region_as_published  = t[-1, 1],
  group_as_published   = group,
  is_healthy_control   = 1L,
  n                    = n,
  species_as_published = "Homo sapiens",
  FDG_GMnorm           = num(t[-1, 2]),
  UCBJ_GMnorm          = num(t[-1, 3]),
  rel_diff_FDG_over_UCBJ.pct = num(t[-1, 4]),
  p_FDG_vs_UCBJ_uncorrected_printed = t[-1, 5],
  p_FDG_vs_UCBJ_uncorrected  = pnum(t[-1, 5]),
  p_FDG_vs_UCBJ_relation     = pcen(t[-1, 5]),
  stringsAsFactors = FALSE)
final.dataframe <- rbind(one(tA, "HC old", n_old), one(tB, "HC young", n_young))
final.dataframe$p_young_vs_old_rel_diff_uncorrected_printed <- tC[-1, 4][final.dataframe$printed_row]
final.dataframe$p_young_vs_old_rel_diff_uncorrected <- pnum(final.dataframe$p_young_vs_old_rel_diff_uncorrected_printed)
final.dataframe <- final.dataframe[order(final.dataframe$printed_row, final.dataframe$docx_table), ]
rownames(final.dataframe) <- NULL
stopifnot(!anyNA(final.dataframe$FDG_GMnorm), !anyNA(final.dataframe$UCBJ_GMnorm),
          !anyNA(final.dataframe$rel_diff_FDG_over_UCBJ.pct), !anyNA(final.dataframe$p_FDG_vs_UCBJ_uncorrected))

## ---- table checks: part C repeats the part A/B relative differences -----------------
tc <- list()
for (g in list(list(col = 2L, t = tB, lbl = "young"), list(col = 3L, t = tA, lbl = "old"))) {
  for (i in 2:nrow(tC)) {
    obs <- num(tC[i, g$col]); pr <- num(g$t[i, 4])
    tc[[length(tc) + 1L]] <- data.frame(
      check_id = paste0("partC_", g$lbl, "_", tC[i, 1]),
      basis = paste0("Table S1 part C 'Relative difference (%) ", tools::toTitleCase(g$lbl),
                     "' = HC ", g$lbl, " table 'Relative difference (%)', row ", tC[i, 1]),
      observed = obs, printed = pr, difference = obs - pr, tolerance = 0,
      status = if (isTRUE(round(obs * 100) == round(pr * 100))) "pass" else "mismatch",
      note = "same printed number in two places; compared in units of 0.01", stringsAsFactors = FALSE)
  }
}
table_checks <- do.call(rbind, tc)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) warning(paste(table_checks$check_id[table_checks$status == "mismatch"],
                                            collapse = ", "), call. = FALSE)

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
