# Hodel_etal_2015_InlineSupplementaryTable4.R ------------------------------------
#
# Hodel, Hunt, Cowell, Van Den Heuvel, Gunnar & Thomas (2015) NeuroImage 105:
# 112-119. doi:10.1016/j.neuroimage.2014.10.020
# Inline Supplementary Table 4: "Comparison of age and sex adjusted cortical lobar volumes (mm^3) in non-adopted, PI-EA, and PI-LA children (corrected for total intracranial volume)."
#
# FROZEN SOURCE: Hodel_etal_2015_InlineSupplementaryTable4_snapshot.docx = the
# journal-supplied supplementary file 1-s2.0-S1053811914008441-mmc4.docx
# (ScienceDirect download, kept in ScienceDirect_files_09Nov2026_23-01-31.887/),
# copy-renamed with bytes untouched (born-digital; HOWTO "Choosing the format").
# This script reads the Word table XML directly; nothing is retyped.
#
# What the table holds -- NOT group means. Each printed row is one region x
# hemisphere with the GLM group effect (F, p, partial eta^2), the parameter
# estimates B (SE) for the contrast of PI-EA and of PI-LA against the
# non-adopted control group, and the EA-vs-LA contrast p (footnote a). Models
# adjust for age, sex and total intracranial volume (ICV). Units: mm^3 as printed in the title.
# No control-group or PI-group mean volume is printed anywhere in the paper or
# its supplements (README).
#
# Cleaning:
#   - one analysis row per printed region x hemisphere row, printed order;
#   - region label forward-filled from its heading row (the first region,
#     "Frontal Lobe^b", sits in the column-header row); its footnote mark split
#     into region_footnote_marks;
#   - "B (se)*" cells split into B, SE and the significance mark; p cells split
#     into the printed lexeme, a number and the mark;
#   - one DERIVED row per region with hemisphere "left+right (computed)" and
#     B = B_left + B_right (exact for OLS with identical design matrices; no SE
#     is computable because the L/R covariance is not reported) - HOWTO section 6;
#   - table checks (HOWTO section 7a): the "*" mark on a printed p is checked
#     against the footnote's threshold p < .02, and each row's F is checked
#     against its printed p and partial eta^2 (F distribution, df (2, df2)).
# Units: mm3 printed = project unit; no conversion.

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

suppressPackageStartupMessages(library(readxl))

suppressPackageStartupMessages(library(xml2))

docx <- paste0(base, "_snapshot.docx")
stopifnot(file.exists(docx))
doc <- read_xml(unz(docx, "word/document.xml"))
ns  <- xml_ns(doc)

run_text <- function(node) {
  rs <- xml_find_all(node, ".//w:r", ns)
  paste0(vapply(rs, function(r) {
    t <- paste0(xml_text(xml_find_all(r, ".//w:t", ns)), collapse = "")
    va <- xml_attr(xml_find_first(r, "./w:rPr/w:vertAlign", ns), "val")
    if (nzchar(t) && !is.na(va) && va == "superscript") paste0("^", t) else t
  }, character(1)), collapse = "")
}

body_paras <- xml_find_all(doc, "/w:document/w:body/w:p", ns)
para_txt   <- trimws(vapply(body_paras, run_text, character(1)))
para_txt   <- para_txt[nzchar(para_txt)]
caption    <- para_txt[1]
footnotes  <- para_txt[-1]
stopifnot(startsWith(caption, "Inline Supplementary Table 4."))

tbl  <- xml_find_all(doc, "//w:tbl", ns)
stopifnot(length(tbl) == 1L)
trs  <- xml_find_all(tbl[[1]], "./w:tr", ns)
cells <- lapply(trs, function(tr) vapply(xml_find_all(tr, "./w:tc", ns), function(tc)
  paste(vapply(xml_find_all(tc, "./w:p", ns), run_text, character(1)), collapse = " "), character(1)))
stopifnot(all(lengths(cells) == 7L), length(cells) == 13L)
grid <- do.call(rbind, cells)
stopifnot(identical(trimws(grid[2, 2:7]),
                    c("F", "p", "\u03b7partial^2", "PI-EA B (se)", "PI-LA B (se)", "EA vs. LA p")))

## ---- parse ------------------------------------------------------------------
num_p <- function(x) as.numeric(sub("\\*$", "", trimws(x)))
mark  <- function(x) ifelse(grepl("\\*\\s*$", x), "*", NA_character_)
split_B <- function(x) {
  m <- regmatches(x, regexec("^\\s*(-?[0-9.]+)\\s*\\(([0-9.]+)\\)\\s*(\\*?)\\s*$", x))
  stopifnot(all(lengths(m) == 4L))
  data.frame(B = as.numeric(vapply(m, `[`, "", 2)), SE = as.numeric(vapply(m, `[`, "", 3)),
             mark = ifelse(vapply(m, `[`, "", 4) == "*", "*", NA_character_))
}

region <- NA_character_; region_mark <- NA_character_; out <- list()
for (i in 2:nrow(grid)) {
  lab <- trimws(grid[i, 1])
  if (i == 2L || all(!nzchar(trimws(grid[i, 2:7])))) {          # region heading row
    region_mark <- ifelse(grepl("\\^[a-z]$", lab), sub(".*\\^([a-z])$", "\\1", lab), NA_character_)
    region <- sub("\\^[a-z]$", "", lab)
    next
  }
  ea <- split_B(grid[i, 5]); la <- split_B(grid[i, 6])
  out[[length(out) + 1L]] <- data.frame(
    printed_row = i, region_as_published = region, region_footnote_marks = region_mark,
    hemisphere_as_published = lab,
    F = as.numeric(trimws(grid[i, 2])),
    p_printed = trimws(grid[i, 3]), p = num_p(grid[i, 3]), p_sig_mark = mark(grid[i, 3]),
    eta_partial_sq = as.numeric(trimws(grid[i, 4])),
    PI_EA_B_printed = trimws(grid[i, 5]), PI_EA_B.mm3 = ea$B, PI_EA_SE.mm3 = ea$SE, PI_EA_sig_mark = ea$mark,
    PI_LA_B_printed = trimws(grid[i, 6]), PI_LA_B.mm3 = la$B, PI_LA_SE.mm3 = la$SE, PI_LA_sig_mark = la$mark,
    EA_vs_LA_p_printed = trimws(grid[i, 7]), EA_vs_LA_p = num_p(grid[i, 7]), EA_vs_LA_sig_mark = mark(grid[i, 7]),
    value_status = "printed", stringsAsFactors = FALSE)
}
printed_df <- do.call(rbind, out)
stopifnot(nrow(printed_df) == 8L, all(printed_df$hemisphere_as_published %in% c("left", "right")))

## ---- derived left+right contrast (HOWTO section 6) --------------------------
sums <- do.call(rbind, lapply(split(printed_df, factor(printed_df$region_as_published,
                                                       unique(printed_df$region_as_published))), function(d) {
  stopifnot(nrow(d) == 2L)
  o <- d[1, ]; o[, setdiff(names(o), c("region_as_published", "region_footnote_marks"))] <- NA
  o$hemisphere_as_published <- "left+right (computed)"
  o$PI_EA_B.mm3 <- round(sum(d$PI_EA_B.mm3), 2); o$PI_LA_B.mm3 <- round(sum(d$PI_LA_B.mm3), 2)
  o$value_status <- "derived_sum"
  o
}))
final.dataframe <- rbind(printed_df, sums)
final.dataframe <- final.dataframe[order(match(final.dataframe$region_as_published,
                                               unique(printed_df$region_as_published)),
                                         is.na(final.dataframe$printed_row)), ]

## ---- sample sizes (main text, Methods: Participants) ------------------------
## 110 PI (EA N = 56, LA N = 54) + 62 non-adopted controls; 15 subjects
## (2 non-adopted, 13 PI) excluded from hippocampal and amygdala analyses only;
## the EA/LA split of those 13 is not reported.
subc <- final.dataframe$region_as_published %in% c("Hippocampus", "Amygdala")
final.dataframe$n_control  <- ifelse(subc, 60L, 62L)
final.dataframe$n_PI_EA    <- ifelse(subc, NA_integer_, 56L)
final.dataframe$n_PI_LA    <- ifelse(subc, NA_integer_, 54L)
final.dataframe$n_PI_total <- ifelse(subc, 97L, 110L)
final.dataframe$contrast_reference_group <- "non-adopted controls"
final.dataframe$model_adjustment <- "age, sex and total intracranial volume (ICV)"
final.dataframe$unit_as_printed <- "mm^3"
final.dataframe$species_as_published <- "children"   # title: "non-adopted, PI-EA, and PI-LA children"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$value_status == "derived_sum"] <-
  "Computed: B_left + B_right (exact for the bilateral-sum contrast under OLS with the same covariates and subjects); SE not computable; not printed."

## Row notes: two printed inconsistencies, kept as printed (errata E002, E003).
r_or <- which(final.dataframe$region_as_published == "Occipital Lobe" & final.dataframe$hemisphere_as_published == "right")
final.dataframe$note[r_or] <- "p printed '.027*': the '*' contradicts the footnote threshold p < .02 (F(2,166) = 3.709 gives p = .027). Kept as printed. See errata Hodel_etal_2015-E002."
r_tl <- which(final.dataframe$region_as_published == "Temporal Lobe" & final.dataframe$hemisphere_as_published == "left")
final.dataframe$note[r_tl] <- "F printed 6.368 is inconsistent with the printed p .006 and eta_p^2 .061 (F(2,166) = 6.368 gives p = .0022, eta_p^2 = .071; p .006 / eta .061 imply F ~ 5.4). Kept as printed. See errata Hodel_etal_2015-E003."
rownames(final.dataframe) <- NULL

## ---- table checks (HOWTO section 7a) ----------------------------------------
## Footnote: "*Group effect or parameter estimate ... significant at the p<.02
## level". Where a p is printed, the mark must appear iff p < .02. A printed
## ".000" is < .0005 and so < .02. B (se) marks rest on a t test whose df is not
## printed and are not checked.
pc <- rbind(
  data.frame(col = "p", printed = printed_df$p_printed, v = printed_df$p, m = printed_df$p_sig_mark,
             lab = paste(printed_df$region_as_published, printed_df$hemisphere_as_published)),
  data.frame(col = "EA_vs_LA_p", printed = printed_df$EA_vs_LA_p_printed, v = printed_df$EA_vs_LA_p,
             m = printed_df$EA_vs_LA_sig_mark,
             lab = paste(printed_df$region_as_published, printed_df$hemisphere_as_published)))
table_checks <- data.frame(
  check_id   = paste0("sigmark_", pc$col, "_", gsub(" ", "_", pc$lab)),
  basis      = paste0("footnote '*' = p < .02; column ", pc$col, ", row ", pc$lab, " (printed '", pc$printed, "')"),
  observed   = as.numeric(pc$v < 0.02),
  printed    = as.numeric(!is.na(pc$m)),
  difference = as.numeric(pc$v < 0.02) - as.numeric(!is.na(pc$m)),
  tolerance  = 0,
  status     = ifelse((pc$v < 0.02) == !is.na(pc$m), "pass", "mismatch"),
  note       = "observed = 1 if printed p < .02; printed = 1 if the cell carries '*'",
  stringsAsFactors = FALSE)
## F, p and partial eta^2 of one row are tied by the F distribution with
## df = (2, df2): p = P(F(2, df2) > F) and eta_p^2 = 2F / (2F + df2).
## df2 = 166, as printed in the main text for the ICV-adjusted models (e.g. 'F(2, 166) = 3.439'): N = 172 minus intercept, 2 group terms, age, sex, ICV.
## Tolerance: p compared at the printed 3 decimals (|round(p_calc, 3) - p| <= .001);
## eta_p^2 within .0015 (half a unit of the printed 3rd decimal plus F rounding).
df2 <- ifelse(printed_df$region_as_published %in% c("Hippocampus", "Amygdala"), 166, 166)
p_calc   <- pf(printed_df$F, 2, df2, lower.tail = FALSE)
eta_calc <- 2 * printed_df$F / (2 * printed_df$F + df2)
lab <- paste(printed_df$region_as_published, printed_df$hemisphere_as_published)
tc_p <- data.frame(check_id = paste0("F_to_p_", gsub(" ", "_", lab)),
  basis = paste0("p = P(F(2, ", df2, ") > F); row ", lab, " (F ", printed_df$F, ", p '", printed_df$p_printed, "')"),
  observed = round(p_calc, 4), printed = printed_df$p, difference = round(round(p_calc, 3) - printed_df$p, 4),
  tolerance = 0.001, status = ifelse(abs(round(p_calc, 3) - printed_df$p) <= 0.001 + 1e-9, "pass", "mismatch"),
  note = "df2 per the comment above", stringsAsFactors = FALSE)
tc_e <- data.frame(check_id = paste0("F_to_eta_", gsub(" ", "_", lab)),
  basis = paste0("eta_p^2 = 2F/(2F + ", df2, "); row ", lab),
  observed = round(eta_calc, 4), printed = printed_df$eta_partial_sq,
  difference = round(eta_calc - printed_df$eta_partial_sq, 4), tolerance = 0.0015,
  status = ifelse(abs(eta_calc - printed_df$eta_partial_sq) <= 0.0015, "pass", "mismatch"),
  note = "df2 per the comment above", stringsAsFactors = FALSE)
table_checks <- rbind(table_checks, tc_p, tc_e)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) warning(item_name, ": table check mismatch (see table_checks and README)", call. = FALSE)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name (never by row). The
## TSV is written ONLY when the item is registered; until the owner pastes the
## registry row, no TSV is written anywhere.
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
