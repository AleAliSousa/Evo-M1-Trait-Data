# Latimer_Sawin_1955_TABLE7.R --------------------------------------------------
#
# Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and
# the weight and length of the spinal cord in the rabbit (race X). Journal of
# Comparative Neurology, 103(3), 513-539. https://doi.org/10.1002/cne.901030307
# TABLE 7 "Weights, lengths and percentage weights and lengths of the spinal cord in
# the normal and dwarf rabbits", p. 527 (PDF page 15).
#
# Reads the frozen snapshot (Latimer_Sawin_1955_TABLE7_snapshot.xlsx, written by
# Latimer_Sawin_1955_extract_snapshot.R) and does all the cleaning:
#   - one analysis row per printed numeric cell, in printed order, read along each
#     printed row: 8 printed rows x 7 cells = 56 rows (long format);
#   - two printed blocks, "35 normal and 15 dwarf males" and "30 normal and 20 dwarf
#     females": the sex and the n of each group come from the block heading, the
#     group from the printed group headers (NORMAL, DWARF), which are printed once
#     above the first block. Dwarf = heterozygous for the dwarf gene, normal =
#     homozygous non-dwarf (MATERIAL AND METHODS, p. 516);
#   - the four printed row labels are abbreviations, two of them printed on two
#     lines (the female block breaks one of them differently); each is joined into
#     one line and coded (see measure_of below). "gm" and "mm" are the printed
#     units; B.W. is the net body weight and B.L. the nose-anus body length (text,
#     p. 526);
#   - project unit: cord mass in mg = printed grams x 1000, in mass.mg, for the
#     Average and Stand. dev. of "Cord, gm" (as for brain mass, build HOWTO
#     section 6); the printed grams stay in value / value_printed; the cord length
#     is printed in mm and is not converted;
#   - the species comes from the species key (the collection key first, else this
#     paper's proposed rows in reference_tables/), never from an inline map;
#   - the table's own relations are re-run into `table_checks` (build HOWTO
#     section 7a): Coef. var. = 100 x Stand. dev. / Average; the "t" values (normal
#     vs dwarf, each sex) from the Averages, SDs and n. Across tables: NORMAL n +
#     DWARF n = TABLE 6 n, and the NORMAL and DWARF Averages pooled (n-weighted)
#     against TABLE 6 (all the animals of the sex) for the cord weight and length.
#     The two percentage rows are means of per-animal ratios, so they are compared
#     with the ratio of the printed means (TABLE 1 net body weight and nose-anus
#     length of the same group, Panels B and C) only as an INFORMATIVE check (no
#     pass criterion). Mismatches are warned, noted on the row and kept as printed.
# No table value is typed in this script.
#
# Build order: Latimer_Sawin_1955_TABLE1.R and Latimer_Sawin_1955_TABLE6.R first
# (the cross-table checks read Latimer_Sawin_1955_TABLE1.csv and _TABLE6.csv;
# without them those checks are not evaluated).
#
# R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.
# Written 2026-11-07 by an AI assistant. The analysis CSV, the public TSV and the
# table-check results quoted in the README come from a Python mirror of this script.

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
base  <- item_name
paper <- basename(folder)
locus <- sub(paste0("^", paper, "_"), "", item_name)
doi   <- "10.1002/cne.901030307"
species_as_published <- "rabbit (race X)"   # the paper's title: "... in the rabbit (race X)"

suppressPackageStartupMessages(library(readxl))

root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)

## ---- read the frozen snapshot by position -------------------------------------
snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = locus,
                             col_names = FALSE, .name_repair = "minimal"))
dimnames(snap) <- NULL
stopifnot(identical(dim(snap), c(14L, 8L)), identical(snap[1, 1], "TABLE 7"))

one_line <- function(x) gsub("\n", " ", x, fixed = TRUE)
lab      <- ifelse(is.na(snap[, 1]), "", snap[, 1])
is_data  <- apply(snap[, 2:8, drop = FALSE], 1, function(x) all(!is.na(x)))
stat_hdr <- one_line(snap[4, 2:4])
t_hdr    <- one_line(snap[3, 8])
stopifnot(identical(stat_hdr, c("Average", "Stand. dev.", "Coef. var.")),
          identical(one_line(snap[4, 5:7]), stat_hdr), grepl("VALUES$", t_hdr))
stat_code <- c("mean", "sd", "cv")

## ---- groups (NORMAL | DWARF) and blocks ("35 normal and 15 dwarf males") -------------
stopifnot(identical(tolower(c(snap[3, 2], snap[3, 5])), c("normal", "dwarf")))
grpL <- list(label = snap[3, 2], group = tolower(snap[3, 2]))
grpR <- list(label = snap[3, 5], group = tolower(snap[3, 5]))
sex_word   <- c(males = "male", females = "female")
block_re   <- "^([0-9]+) normal and ([0-9]+) dwarf (males|females)$"
block_rows <- grep(block_re, lab)
stopifnot(length(block_rows) == 2L)
blocks <- lapply(lab[block_rows], function(h) {
  m <- regmatches(h, regexec(block_re, h))[[1]]
  list(heading = h, block = m[4], sex = sex_word[[m[4]]],
       n = c(as.integer(m[2]), as.integer(m[3])))            # NORMAL, DWARF
})
stopifnot(identical(vapply(blocks, `[[`, "", "sex"), c("male", "female")))

## ---- row labels -> measure codes ----------------------------------------------------
## The printed labels are abbreviations ("Cord, gm"; "Cord, % of" over "net B.W."),
## joined into one line here. The codes name the printed labels and carry no table
## value; every printed label must be listed, or the run stops.
measure_of <- c("Cord, gm"            = "cord_weight",
                "Cord, mm"            = "cord_length",
                "Cord, % of net B.W." = "cord_weight_pct_net_body_weight",
                "Cord L., % of B.L."  = "cord_length_pct_body_length")
unit_of    <- c(cord_weight = "g", cord_length = "mm",
                cord_weight_pct_net_body_weight = "%", cord_length_pct_body_length = "%")
data_rows <- which(is_data)
stopifnot(length(data_rows) == 8L, all(one_line(lab[data_rows]) %in% names(measure_of)),
          all(data_rows > block_rows[1]))

cells <- NULL
for (rr in data_rows) {
  b <- blocks[[max(which(block_rows < rr))]]
  for (j in 2:8) {
    side <- if (j <= 4L) "L" else if (j <= 7L) "R" else "T"
    g    <- if (side == "R") grpR else grpL
    gn   <- if (side == "R") b$n[2] else b$n[1]
    pos  <- (j - 2L) %% 3L + 1L
    cells <- rbind(cells, data.frame(
      printed_row = rr,
      snapshot_cell = paste0(LETTERS[j], rr),
      block = b$block,
      block_as_published = b$heading,
      group_label_as_published = if (side == "T") NA_character_ else g$label,
      sex = b$sex,
      group = if (side == "T") paste(grpL$group, "vs", grpR$group) else g$group,
      n = if (side == "T") NA_integer_ else gn,
      n_compared = if (side == "T") paste(b$n[1], "vs", b$n[2]) else NA_character_,
      measure = measure_of[[one_line(lab[rr])]],
      measure_as_published = one_line(lab[rr]),
      statistic = if (side == "T") "t" else stat_code[pos],
      statistic_as_published = if (side == "T") t_hdr else stat_hdr[pos],
      value_printed = snap[rr, j],
      side = side,
      stringsAsFactors = FALSE))
  }
}
cells$value <- suppressWarnings(as.numeric(gsub(",", "", cells$value_printed, fixed = TRUE)))
stopifnot(nrow(cells) == 56L, !anyNA(cells$value))

cells$unit <- ifelse(cells$statistic == "t", NA_character_,
              ifelse(cells$statistic == "cv", "%", unname(unit_of[cells$measure])))
## project unit: grams x 1000 = mg (cord mass; Average and Stand. dev.)
cells$mass.mg <- ifelse(cells$measure == "cord_weight" & cells$statistic %in% c("mean", "sd"),
                        cells$value * 1000, NA_real_)

## ---- species from the key, never an inline map ------------------------------------
key_files <- c(file.path(root, "_keys", "General", "species_key.csv"),
               file.path(folder, "reference_tables", paste0(paper, "_species_key_proposed.csv")))
species <- NA_character_
for (kf in key_files[file.exists(key_files)]) {
  key <- read.csv(kf, stringsAsFactors = FALSE, encoding = "UTF-8")
  hit <- key$accepted_name[key$source_publication == paper &
                             tolower(key$variant_name) == tolower(species_as_published)]
  if (length(hit)) {
    species <- hit[1]
    message(item_name, ": species '", species_as_published, "' -> ", species, " (", kf, ")")
    break
  }
}
if (is.na(species))
  stop(item_name, ": '", species_as_published, "' is in no species key for ", paper,
       ". Add the row to the key file, not to this script.", call. = FALSE)

out_cols <- c("printed_row", "snapshot_cell", "block", "block_as_published",
              "group_label_as_published", "sex", "group", "n", "n_compared", "measure",
              "measure_as_published", "statistic", "statistic_as_published", "unit",
              "value_printed", "value", "mass.mg")
final.dataframe <- cells[, out_cols]
final.dataframe$species <- species
final.dataframe$species_as_published <- species_as_published
final.dataframe$data_role <- "primary"
final.dataframe$note <- NA_character_
rownames(final.dataframe) <- NULL

## ---- table checks (build HOWTO section 7a) ------------------------------------------
## Compared in the printed units. A tolerance is only what rounding of the printed
## cells can explain (half a unit of the last printed decimal of each input, worst
## case), plus, for the "t" values, the stated allowance for the unstated formula.
half_unit <- function(txt) {
  dec <- ifelse(grepl(".", txt, fixed = TRUE), nchar(sub("^[^.]*\\.", "", txt)), 0L)
  0.5 * 10^(-dec)
}
chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable",
                      ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
## Student t, pooled variance. divisor_n = TRUE treats the printed SDs as divisor-n
## SDs (the paper says only "the usual statistical constants", p. 516).
t_pooled <- function(d, s1, n1, s2, n2, divisor_n = FALSE) {
  v1 <- if (divisor_n) n1 * s1^2 else (n1 - 1) * s1^2
  v2 <- if (divisor_n) n2 * s2^2 else (n2 - 1) * s2^2
  d / sqrt((v1 + v2) / (n1 + n2 - 2) * (1 / n1 + 1 / n2))
}

## one row per printed group: Average, Stand. dev., Coef. var. side by side
grp <- cells[cells$statistic != "t", ]
w <- grp[grp$statistic == "mean", c("printed_row", "side", "measure", "measure_as_published",
                                    "sex", "group", "n")]
pick <- function(stat, col) {
  s <- grp[grp$statistic == stat, ]
  s[[col]][match(paste(w$printed_row, w$side), paste(s$printed_row, s$side))]
}
w$mean <- pick("mean", "value"); w$mean_txt <- pick("mean", "value_printed")
w$sd   <- pick("sd", "value");   w$sd_txt   <- pick("sd", "value_printed")
w$cv   <- pick("cv", "value");   w$cv_txt   <- pick("cv", "value_printed")
rownames(w) <- NULL
row_of <- function(printed_row, side, stat)
  which(cells$printed_row == printed_row & cells$side == side & cells$statistic == stat)

## 1. Coef. var. = 100 x Stand. dev. / Average, every printed group (16)
cv_obs <- 100 * w$sd / w$mean
cv_tol <- 100 * (w$sd + half_unit(w$sd_txt)) / (w$mean - half_unit(w$mean_txt)) - cv_obs +
          half_unit(w$cv_txt)
tc_cv <- chk(paste("cv", w$measure, w$sex, w$group, sep = "_"),
             sprintf("Coef. var. = 100 x Stand. dev. / Average [%s, %s %s; row %d]",
                     w$measure, w$sex, w$group, w$printed_row),
             cv_obs, w$cv, cv_tol,
             "tolerance: worst case of 100 x (SD + half unit)/(Average - half unit), plus half a unit of the printed Coef. var.")
rows_cv <- lapply(seq_len(nrow(w)), function(i) row_of(w$printed_row[i], w$side[i], "cv"))

## 2. the "t" values (8): pooled-variance Student t, NORMAL vs DWARF within each sex,
##    from the printed Averages, SDs and n
tt <- cells[cells$statistic == "t", ]
L  <- w[match(paste(tt$printed_row, "L"), paste(w$printed_row, w$side)), ]
R  <- w[match(paste(tt$printed_row, "R"), paste(w$printed_row, w$side)), ]
d     <- abs(L$mean - R$mean)
hm    <- half_unit(L$mean_txt) + half_unit(R$mean_txt)
t_obs <- t_pooled(d, L$sd, L$n, R$sd, R$n)
t_alt <- t_pooled(d, L$sd, L$n, R$sd, R$n, divisor_n = TRUE)
t_hi  <- t_pooled(d + hm, L$sd - half_unit(L$sd_txt), L$n, R$sd - half_unit(R$sd_txt), R$n)
t_lo  <- t_pooled(pmax(d - hm, 0), L$sd + half_unit(L$sd_txt), L$n,
                  R$sd + half_unit(R$sd_txt), R$n, divisor_n = TRUE)
t_tol <- ifelse(tt$value >= t_obs, t_hi - t_obs, t_obs - t_lo) + half_unit(tt$value_printed)
tc_t <- chk(paste("t", tt$measure, tt$sex, sep = "_"),
            sprintf("t = |Average 1 - Average 2| / pooled-variance SE (Student; SDs as divisor n-1) [%s: %s %s n = %d vs %s %s n = %d]",
                    tt$measure, L$sex, L$group, L$n, R$sex, R$group, R$n),
            t_obs, tt$value, t_tol,
            sprintf("with divisor-n SDs t = %.3f; tolerance: rounding of the printed inputs (worst case) + half a unit of the printed t, and, below the recomputed t only, down to the divisor-n value (the paper does not state its formula)",
                    t_alt))
rows_t <- as.list(which(cells$statistic == "t"))

## 3. Across tables (2 + 4): NORMAL n + DWARF n = TABLE 6 n, and the NORMAL and DWARF
##    Averages pooled (n-weighted) = the TABLE 6 Average of all the animals of the sex,
##    for "Cord, gm" and "Cord, mm". TABLE 6 is read from its analysis CSV as printed text.
pooled_measures <- c("cord_weight", "cord_length")
t6_csv <- paste0(paper, "_TABLE6.csv")
t6 <- NULL
if (file.exists(t6_csv)) {
  t6 <- read.csv(t6_csv, colClasses = "character", encoding = "UTF-8")   # keeps "3.925" as printed
  t6 <- t6[t6$statistic == "mean" & t6$group == "all", ]
}
x_missing <- if (is.null(t6)) paste0(t6_csv, " not found; run Latimer_Sawin_1955_TABLE6.R first.") else NA_character_
tc_xn <- NULL; rows_xn <- list(); tc_xm <- NULL; rows_xm <- list()
for (b in blocks) {
  t6s  <- if (is.null(t6)) NULL else t6[t6$sex == b$sex, ]
  t6_n <- if (is.null(t6)) NA_integer_ else as.integer(unique(t6s$n))
  stopifnot(length(t6_n) == 1L)
  tc_xn <- rbind(tc_xn, chk(paste0("n_vs_TABLE6_", b$sex),
    sprintf("NORMAL n + DWARF n (block heading '%s') = TABLE 6 n [%s]", b$heading, b$sex),
    sum(b$n), t6_n, 0, x_missing))
  rows_xn[[length(rows_xn) + 1L]] <- integer(0)
  for (m_ in pooled_measures) {
    nd <- w[w$sex == b$sex & w$measure == m_, ]
    nd <- nd[match(c(grpL$group, grpR$group), nd$group), ]
    a_txt <- if (is.null(t6)) NA_character_ else t6s$value_printed[match(m_, t6s$measure)]
    a_val <- if (is.null(t6)) NA_real_ else as.numeric(t6s$value[match(m_, t6s$measure)])
    tc_xm <- rbind(tc_xm, chk(paste0("pooled_vs_TABLE6_", m_, "_", b$sex),
      sprintf("NORMAL and DWARF Averages pooled (n-weighted) = TABLE 6 Average of all the %ss [%s]",
              b$sex, m_),
      sum(nd$n * nd$mean) / sum(nd$n), a_val,
      sum(nd$n * half_unit(nd$mean_txt)) / sum(nd$n) + half_unit(a_txt),
      if (is.null(t6)) x_missing else
        sprintf("(%d x %s + %d x %s) / %d vs TABLE 6 %s", nd$n[1], nd$mean_txt[1], nd$n[2],
                nd$mean_txt[2], sum(nd$n), a_txt)))
    rows_xm[[length(rows_xm) + 1L]] <- c(row_of(nd$printed_row[1], nd$side[1], "mean"),
                                         row_of(nd$printed_row[2], nd$side[2], "mean"))
  }
}

## 4. INFORMATIVE ONLY (8): the two percentage rows vs the ratio of the printed means,
##    100 x Average cord weight (g) / Average net body weight (g) and 100 x Average cord
##    length (mm) / Average nose-anus body length (mm) of the same sex and group (TABLE 1,
##    Panel B males or Panel C females). A mean of ratios need not equal a ratio of
##    means: no pass criterion, status not_evaluable.
ratio_of <- c(cord_weight_pct_net_body_weight = "cord_weight",
              cord_length_pct_body_length     = "cord_length")
t1_measure <- c(cord_weight_pct_net_body_weight = "body_weight_net",
                cord_length_pct_body_length     = "body_length_nose_anus")
t1_csv <- paste0(paper, "_TABLE1.csv")
pb  <- w[w$measure %in% names(ratio_of), ]
num <- w[match(paste(ratio_of[pb$measure], pb$sex, pb$group), paste(w$measure, w$sex, w$group)), ]
if (file.exists(t1_csv)) {
  t1 <- read.csv(t1_csv, colClasses = "character", encoding = "UTF-8")   # keeps "1650.0" as printed
  den <- t1[t1$statistic == "mean" & t1$group %in% c(grpL$group, grpR$group), ]
  den <- den[match(paste(t1_measure[pb$measure], pb$sex, pb$group),
                   paste(den$measure, den$sex, den$group)), ]
  stopifnot(!anyNA(den$value))
  rom <- 100 * num$mean / as.numeric(den$value)
  info_note <- sprintf("INFORMATIVE ONLY, no pass criterion: the printed value is a mean of per-animal percentages; the ratio of the printed means, 100 x %s %s / %s %s (TABLE 1 Panel %s %s, %s %s), need not equal it. Ratio of means minus printed = %+.4f (%+.1f%% of the printed value).",
                       num$mean_txt, unit_of[num$measure], den$value_printed, unit_of[num$measure],
                       den$panel, den$measure_as_published, pb$sex, pb$group, rom - pb$mean,
                       100 * (rom - pb$mean) / pb$mean)
} else {
  rom <- rep(NA_real_, nrow(pb))
  info_note <- paste0("INFORMATIVE ONLY: ", t1_csv, " not found; run Latimer_Sawin_1955_TABLE1.R first.")
}
tc_info <- data.frame(check_id = paste0("info_ratio_of_means_", pb$measure, "_", pb$sex, "_", pb$group),
                      basis = sprintf("%s (mean of ratios) vs 100 x Average %s / TABLE 1 Average %s (ratio of means) [%s %s]",
                                      pb$measure_as_published, ratio_of[pb$measure],
                                      t1_measure[pb$measure], pb$sex, pb$group),
                      observed = rom, printed = pb$mean, difference = rom - pb$mean,
                      tolerance = NA_real_, status = "not_evaluable", note = info_note,
                      stringsAsFactors = FALSE)
rows_info <- rep(list(integer(0)), nrow(tc_info))

table_checks <- rbind(tc_cv, tc_t, tc_xn, tc_xm, tc_info)
check_rows   <- c(rows_cv, rows_t, rows_xn, rows_xm, rows_info)
rownames(table_checks) <- NULL

## ---- per-row notes for the checks that did not pass -----------------------------------
add_note <- function(df, rows, txt) {
  df$note[rows] <- ifelse(is.na(df$note[rows]), txt, paste(df$note[rows], txt, sep = " | "))
  df
}
errata_for <- c(pooled_vs_TABLE6_cord_weight_male = "Latimer_Sawin_1955-E006")
for (i in which(table_checks$status == "mismatch")) {
  id <- table_checks$check_id[i]
  pr <- table_checks$printed[i]; ob <- table_checks$observed[i]; tl <- table_checks$tolerance[i]
  txt <- if (startsWith(id, "t_")) {
    sprintf("Table check %s: Student t recomputed from the printed Averages, SDs and n is %.3f (%.3f with divisor-n SDs); printed %s, outside the allowance (%.3f). Kept as printed.",
            id, ob, t_alt[match(id, tc_t$check_id)], cells$value_printed[check_rows[[i]][1]], tl)
  } else if (startsWith(id, "pooled_vs_TABLE6_")) {
    sprintf("Table check %s: the NORMAL and DWARF Averages pooled (n-weighted), %s, give %.4f %s; TABLE 6 prints %s %s for all the %ss (pooled minus TABLE 6 = %+.4f %s; rounding of the printed cells allows +/-%.4f %s). Kept as printed.",
            id, sub(" vs TABLE 6 .*$", "", table_checks$note[i]), ob,
            cells$unit[check_rows[[i]][1]], sub("^.* vs TABLE 6 ", "", table_checks$note[i]),
            cells$unit[check_rows[[i]][1]], cells$sex[check_rows[[i]][1]], ob - pr,
            cells$unit[check_rows[[i]][1]], tl, cells$unit[check_rows[[i]][1]])
  } else {
    sprintf("Table check %s: recomputed %.4f, printed %s (allowance %.4f). Kept as printed.",
            id, ob, format(pr), tl)
  }
  if (!is.na(errata_for[id])) txt <- paste0(txt, " See errata ", errata_for[[id]], ".")
  final.dataframe <- add_note(final.dataframe, check_rows[[i]], txt)
}

tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]], " (the not_evaluable rows include the ",
        nrow(tc_info), " informative ratio-of-means comparisons)")
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV --------------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name (never by row number).
## The run STOPS, rather than write a misnamed TSV, if the registry value contains
## whitespace or "https" (the Munger_etal_2022 guard): that happens when column A
## (citation) ends with anything but a single "https://doi.org/<DOI>".
expected_encoded <- paste0(gsub("/", "%2F", doi, fixed = TRUE), "_", locus)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                         .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning(item_name, ": no 'Item encoded' for this Item name in __ReadMe.xlsx; public TSV ",
          "not written (expected ", expected_encoded, ").", call. = FALSE)
} else if (grepl("\\s", item_encoded) || grepl("https", item_encoded, ignore.case = TRUE)) {
  stop(item_name, ": 'Item encoded' in __ReadMe.xlsx is '", item_encoded, "'. It contains ",
       "whitespace and/or 'https', so the public TSV would be misnamed. Column A (citation) of ",
       "this registry row must end with a single 'https://doi.org/", doi, "' and nothing after ",
       "it (no repeated 'https://doi.org/', no trailing space). Fix column A, let the workbook ",
       "recalculate and save it, then re-run. Expected Item encoded: ", expected_encoded,
       ". The analysis CSV has been written; the public TSV has not.", call. = FALSE)
} else if (grepl("_$", item_encoded)) {
  stop(item_name, ": 'Item encoded' ends with '_' (blank Item number?): '", item_encoded,
       "'. Public TSV not written.", call. = FALSE)
} else {
  if (!identical(item_encoded, expected_encoded))
    warning(item_name, ": the registry resolves '", item_encoded, "', not the expected '",
            expected_encoded, "'; the registry is the authority and is used.", call. = FALSE)
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  if (dir.exists(tsv_dir)) {
    write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
    message(item_name, ": public TSV ", item_encoded, ".tsv")
  } else warning(item_name, ": __Public/comparative-data not found; public TSV not written.",
                 call. = FALSE)
}
