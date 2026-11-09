# Latimer_Sawin_1955_TABLE4.R --------------------------------------------------
#
# Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and
# the weight and length of the spinal cord in the rabbit (race X). Journal of
# Comparative Neurology, 103(3), 513-539. https://doi.org/10.1002/cne.901030307
# TABLE 4 "Weights of the brain and of its parts in 35 normal and in 15 dwarf male
# rabbits", p. 524 (PDF page 12).
#
# Reads the frozen snapshot (Latimer_Sawin_1955_TABLE4_snapshot.xlsx, written by
# Latimer_Sawin_1955_extract_snapshot.R) and does all the cleaning:
#   - one analysis row per printed numeric cell, in printed order, read along each
#     printed row: 14 printed rows x 7 cells = 98 rows (long format);
#   - three printed blocks: "Weights in grams", "Percentages of net body weight",
#     "Percentages of brain weight"; the sex and the n of each group (35 normal,
#     15 dwarf) from the caption; the group from the printed group headers
#     (NORMAL, DWARF). Dwarf = heterozygous for the dwarf gene, normal =
#     homozygous non-dwarf (MATERIAL AND METHODS, p. 516);
#   - project unit: brain and brain-part mass in mg = printed grams x 1000, in
#     mass.mg, for the Average and Stand. dev. of the grams block (build HOWTO
#     section 6); the printed grams stay in value / value_printed;
#   - "Medulla" includes the pons (MATERIAL AND METHODS, p. 515);
#   - the species comes from the species key (the collection key first, else this
#     paper's proposed rows in reference_tables/), never from an inline map;
#   - the table's own relations are re-run into `table_checks` (build HOWTO
#     section 7a): Coef. var. = 100 x Stand. dev. / Average; the "t" values
#     (normal vs dwarf) from the Averages, SDs and n; Brain = sum of its four parts
#     (grams, each group; the paper weighs the four parts and sums them, p. 515);
#     the percentages of brain weight add to 100 (each group). Across tables: the
#     NORMAL and DWARF Averages pooled (n-weighted) against TABLE 2 (all the
#     animals of the same sex), every row of the grams block, and the n. The
#     percentages of net body weight are a mean of per-animal ratios, so they are
#     compared with the ratio of the printed means (TABLE 1 net body weight of the
#     same group) only as an INFORMATIVE check (no pass criterion). Mismatches are
#     warned, noted on the row and kept as printed.
# No table value is typed in this script.
#
# Build order: Latimer_Sawin_1955_TABLE1.R and Latimer_Sawin_1955_TABLE2.R first
# (the cross-table checks read Latimer_Sawin_1955_TABLE1.csv and _TABLE2.csv;
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
stopifnot(identical(dim(snap), c(22L, 8L)), identical(snap[1, 1], "TABLE 4"))

one_line <- function(x) gsub("\n", " ", x, fixed = TRUE)
snake    <- function(x) gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(x)))
lab      <- ifelse(is.na(snap[, 1]), "", snap[, 1])
is_data  <- apply(snap[, 2:8, drop = FALSE], 1, function(x) all(!is.na(x)))
stat_hdr <- one_line(snap[4, 2:4])
t_hdr    <- one_line(snap[3, 8])
stopifnot(identical(stat_hdr, c("Average", "Stand. dev.", "Coef. var.")),
          identical(one_line(snap[4, 5:7]), stat_hdr), grepl("VALUES$", t_hdr))
stat_code <- c("mean", "sd", "cv")

## sex and n from the printed caption: "... in 35 normal and in 15 dwarf male rabbits";
## the group headers print only NORMAL and DWARF
cap <- snap[2, 1]
nn  <- regmatches(cap, regexec("in ([0-9]+) normal and in ([0-9]+) dwarf (male|female) rabbits$", cap))[[1]]
stopifnot(length(nn) == 4L, identical(tolower(c(snap[3, 2], snap[3, 5])), c("normal", "dwarf")))
sex  <- nn[4]
grpL <- list(label = snap[3, 2], group = tolower(snap[3, 2]), n = as.integer(nn[2]))
grpR <- list(label = snap[3, 5], group = tolower(snap[3, 5]), n = as.integer(nn[3]))

## ---- blocks: all three print a heading; the footnote is not a block -----------------
foot_rows    <- grep("^In tables ", lab)
heading_rows <- setdiff(which(!is_data & nzchar(lab) & seq_along(lab) > 4L), foot_rows)
stopifnot(length(foot_rows) == 1L, foot_rows == nrow(snap), length(heading_rows) == 3L,
          grepl("^Weights in grams$", lab[heading_rows[1]]),
          all(grepl("^Percentages of ", lab[heading_rows[-1]])))
block_code <- function(h) if (grepl("^Weights in grams$", h)) "weight" else
  snake(sub("^Percentages of ", "pct_", h))

cells <- NULL
for (rr in which(is_data)) {
  heading <- lab[max(heading_rows[heading_rows < rr])]
  block   <- block_code(heading)
  for (j in 2:8) {
    side <- if (j <= 4L) "L" else if (j <= 7L) "R" else "T"
    g    <- if (side == "R") grpR else grpL
    pos  <- (j - 2L) %% 3L + 1L
    cells <- rbind(cells, data.frame(
      printed_row = rr,
      snapshot_cell = paste0(LETTERS[j], rr),
      block = block,
      block_as_published = heading,
      group_label_as_published = if (side == "T") NA_character_ else g$label,
      sex = sex,
      group = if (side == "T") paste(grpL$group, "vs", grpR$group) else g$group,
      n = if (side == "T") NA_integer_ else g$n,
      n_compared = if (side == "T") paste(grpL$n, "vs", grpR$n) else NA_character_,
      structure_as_published = lab[rr],
      measure = paste0(snake(lab[rr]), "_", block),
      statistic = if (side == "T") "t" else stat_code[pos],
      statistic_as_published = if (side == "T") t_hdr else stat_hdr[pos],
      value_printed = snap[rr, j],
      side = side,
      stringsAsFactors = FALSE))
  }
}
cells$value <- suppressWarnings(as.numeric(gsub(",", "", cells$value_printed, fixed = TRUE)))
stopifnot(nrow(cells) == 98L, !anyNA(cells$value),
          identical(unique(cells$block), c("weight", "pct_net_body_weight", "pct_brain_weight")))

cells$unit <- ifelse(cells$statistic == "t", NA_character_,
              ifelse(cells$statistic == "cv" | cells$block != "weight", "%", "g"))
## project unit: grams x 1000 = mg (brain and brain-part mass; Average and Stand. dev.)
cells$mass.mg <- ifelse(cells$block == "weight" & cells$statistic %in% c("mean", "sd"),
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
              "group_label_as_published", "sex", "group", "n", "n_compared",
              "structure_as_published", "measure", "statistic", "statistic_as_published",
              "unit", "value_printed", "value", "mass.mg")
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
w <- grp[grp$statistic == "mean", c("printed_row", "side", "block", "structure_as_published",
                                    "measure", "group", "n")]
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

## 1. Coef. var. = 100 x Stand. dev. / Average, every printed group (28)
cv_obs <- 100 * w$sd / w$mean
cv_tol <- 100 * (w$sd + half_unit(w$sd_txt)) / (w$mean - half_unit(w$mean_txt)) - cv_obs +
          half_unit(w$cv_txt)
tc_cv <- chk(paste("cv", w$measure, w$group, sep = "_"),
             sprintf("Coef. var. = 100 x Stand. dev. / Average [%s, %s %s; row %d]",
                     w$measure, sex, w$group, w$printed_row),
             cv_obs, w$cv, cv_tol,
             "tolerance: worst case of 100 x (SD + half unit)/(Average - half unit), plus half a unit of the printed Coef. var.")
rows_cv <- lapply(seq_len(nrow(w)), function(i) row_of(w$printed_row[i], w$side[i], "cv"))

## 2. the "t" values (14): pooled-variance Student t, NORMAL vs DWARF, from the printed
##    Averages, SDs and n
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
tc_t <- chk(paste("t", tt$measure, sep = "_"),
            sprintf("t = |Average 1 - Average 2| / pooled-variance SE (Student; SDs as divisor n-1) [%s: %s %s n = %d vs %s %s n = %d]",
                    tt$measure, sex, L$group, L$n, sex, R$group, R$n),
            t_obs, tt$value, t_tol,
            sprintf("with divisor-n SDs t = %.3f; tolerance: rounding of the printed inputs (worst case) + half a unit of the printed t, and, below the recomputed t only, down to the divisor-n value (the paper does not state its formula)",
                    t_alt))
rows_t <- as.list(which(cells$statistic == "t"))

## 3. Brain = sum of its four parts, grams block, each group (2). MATERIAL AND METHODS,
##    p. 515: "The total brain weight is the sum of the weights of these 4 parts."
tc_sum <- NULL; rows_sum <- list()
for (g_ in unique(w$group)) {
  g  <- w[w$block == "weight" & w$group == g_, ]
  br <- g[g$structure_as_published == "Brain", ]
  pt <- g[g$structure_as_published != "Brain", ]
  stopifnot(nrow(br) == 1L, nrow(pt) == 4L)
  tc_sum <- rbind(tc_sum, chk(paste0("brain_sum_of_parts_", g_),
    sprintf("Brain Average = sum of the four part Averages, grams [%s %s; rows %d-%d vs row %d]",
            sex, g_, min(pt$printed_row), max(pt$printed_row), br$printed_row),
    sum(pt$mean), br$mean, sum(half_unit(pt$mean_txt)) + half_unit(br$mean_txt),
    paste0(paste(pt$mean_txt, collapse = " + "), "; tolerance half a unit per summed cell and of the printed total")))
  rows_sum[[length(rows_sum) + 1L]] <- row_of(br$printed_row, br$side, "mean")
}

## 4. Percentages of brain weight add to 100, each group (2). No total row is printed;
##    100 is the reference by definition.
tc_pct <- NULL; rows_pct <- list()
for (g_ in unique(w$group)) {
  g <- w[w$block == "pct_brain_weight" & w$group == g_, ]
  stopifnot(nrow(g) == 4L)
  tc_pct <- rbind(tc_pct, chk(paste0("pct_brain_weight_sum_", g_),
    sprintf("Percentages of brain weight: the four part Averages add to 100 [%s %s; rows %d-%d]",
            sex, g_, min(g$printed_row), max(g$printed_row)),
    sum(g$mean), 100, sum(half_unit(g$mean_txt)),
    paste0(paste(g$mean_txt, collapse = " + "), "; reference 100 by definition (no total is printed); tolerance half a unit per summed cell")))
  rows_pct[[length(rows_pct) + 1L]] <- vapply(g$printed_row, function(p) row_of(p, g$side[1], "mean"), integer(1))
}

## 5. Across tables (1 + 5): NORMAL n + DWARF n = TABLE 2 n, and the NORMAL and DWARF
##    Averages pooled (n-weighted) = the TABLE 2 Average of all the animals of this sex,
##    every row of the grams block. TABLE 2 is read from its analysis CSV as printed text.
t2_csv <- paste0(paper, "_TABLE2.csv")
gm   <- w[w$block == "weight", ]
strs <- unique(gm$structure_as_published)
t2 <- NULL; t2_n <- NA_integer_
if (file.exists(t2_csv)) {
  t2 <- read.csv(t2_csv, colClasses = "character", encoding = "UTF-8")   # keeps "9.156" as printed
  t2 <- t2[t2$block == "weight" & t2$statistic == "mean" & t2$sex == sex & t2$group == "all", ]
  stopifnot(nrow(t2) == length(strs), all(strs %in% t2$structure_as_published))
  t2_n <- as.integer(unique(t2$n)); stopifnot(length(t2_n) == 1L)
}
x_missing <- if (is.null(t2)) paste0(t2_csv, " not found; run Latimer_Sawin_1955_TABLE2.R first.") else NA_character_
tc_xn <- chk(paste0("n_vs_TABLE2_", sex),
             sprintf("NORMAL n + DWARF n (caption) = TABLE 2 n [%s]", sex),
             grpL$n + grpR$n, t2_n, 0, x_missing)
rows_xn <- list(integer(0))
tc_xm <- NULL; rows_xm <- list()
for (s_ in strs) {
  nd <- gm[gm$structure_as_published == s_, ]
  nd <- nd[match(c(grpL$group, grpR$group), nd$group), ]
  a_txt <- if (is.null(t2)) NA_character_ else t2$value_printed[match(s_, t2$structure_as_published)]
  a_val <- if (is.null(t2)) NA_real_ else as.numeric(t2$value[match(s_, t2$structure_as_published)])
  tc_xm <- rbind(tc_xm, chk(paste0("pooled_vs_TABLE2_", nd$measure[1], "_", sex),
    sprintf("NORMAL and DWARF Averages pooled (n-weighted) = TABLE 2 Average of all the %ss [%s]",
            sex, nd$measure[1]),
    sum(nd$n * nd$mean) / sum(nd$n), a_val,
    sum(nd$n * half_unit(nd$mean_txt)) / sum(nd$n) + half_unit(a_txt),
    if (is.null(t2)) x_missing else
      sprintf("(%d x %s + %d x %s) / %d vs TABLE 2 %s", nd$n[1], nd$mean_txt[1], nd$n[2],
              nd$mean_txt[2], sum(nd$n), a_txt)))
  rows_xm[[length(rows_xm) + 1L]] <- c(row_of(nd$printed_row[1], nd$side[1], "mean"),
                                       row_of(nd$printed_row[2], nd$side[2], "mean"))
}

## 6. INFORMATIVE ONLY (10): percentages of net body weight vs the ratio of the printed
##    means, 100 x Average grams (this table) / Average net body weight of the same sex
##    and group (TABLE 1, Panel B males or Panel C females). A mean of ratios need not
##    equal a ratio of means: no pass criterion, status not_evaluable.
t1_csv <- paste0(paper, "_TABLE1.csv")
pb  <- w[w$block == "pct_net_body_weight", ]
gmm <- gm[match(paste(pb$structure_as_published, pb$group), paste(gm$structure_as_published, gm$group)), ]
if (file.exists(t1_csv)) {
  t1 <- read.csv(t1_csv, colClasses = "character", encoding = "UTF-8")   # keeps "1650.0" as printed
  net <- t1[t1$measure == "body_weight_net" & t1$statistic == "mean" & t1$sex == sex &
              t1$group %in% c(grpL$group, grpR$group), ]
  stopifnot(nrow(net) == 2L)
  net_txt <- net$value_printed[match(pb$group, net$group)]
  net_val <- as.numeric(net$value[match(pb$group, net$group)])
  net_pan <- net$panel[match(pb$group, net$group)]
  rom <- 100 * gmm$mean / net_val
  info_note <- sprintf("INFORMATIVE ONLY, no pass criterion: the printed value is a mean of per-animal percentages; the ratio of the printed means, 100 x %s g / %s g (TABLE 1 Panel %s net body weight, %s %s), need not equal it. Ratio of means minus printed = %+.4f (%+.1f%% of the printed value).",
                       gmm$mean_txt, net_txt, net_pan, sex, pb$group, rom - pb$mean,
                       100 * (rom - pb$mean) / pb$mean)
} else {
  rom <- rep(NA_real_, nrow(pb))
  info_note <- paste0("INFORMATIVE ONLY: ", t1_csv, " not found; run Latimer_Sawin_1955_TABLE1.R first.")
}
tc_info <- data.frame(check_id = paste0("info_ratio_of_means_", pb$measure, "_", pb$group),
                      basis = sprintf("Percentage of net body weight (mean of ratios) vs 100 x Average grams / Average net body weight (ratio of means) [%s, %s %s]",
                                      pb$structure_as_published, sex, pb$group),
                      observed = rom, printed = pb$mean, difference = rom - pb$mean,
                      tolerance = NA_real_, status = "not_evaluable", note = info_note,
                      stringsAsFactors = FALSE)
rows_info <- rep(list(integer(0)), nrow(tc_info))

table_checks <- rbind(tc_cv, tc_t, tc_sum, tc_pct, tc_xn, tc_xm, tc_info)
check_rows   <- c(rows_cv, rows_t, rows_sum, rows_pct, rows_xn, rows_xm, rows_info)
rownames(table_checks) <- NULL

## ---- per-row notes for the checks that did not pass -----------------------------------
add_note <- function(df, rows, txt) {
  df$note[rows] <- ifelse(is.na(df$note[rows]), txt, paste(df$note[rows], txt, sep = " | "))
  df
}
errata_for <- c(brain_sum_of_parts_normal = "Latimer_Sawin_1955-E003",
                pooled_vs_TABLE2_prosencephalon_weight_male = "Latimer_Sawin_1955-E003",
                pooled_vs_TABLE2_brain_weight_male = "Latimer_Sawin_1955-E002")
for (i in which(table_checks$status == "mismatch")) {
  id <- table_checks$check_id[i]
  pr <- table_checks$printed[i]; ob <- table_checks$observed[i]; tl <- table_checks$tolerance[i]
  txt <- if (startsWith(id, "t_")) {
    sprintf("Table check %s: Student t recomputed from the printed Averages, SDs and n is %.3f (%.3f with divisor-n SDs); printed %s, outside the allowance (%.3f). Kept as printed.",
            id, ob, t_alt[match(id, tc_t$check_id)], cells$value_printed[check_rows[[i]][1]], tl)
  } else if (startsWith(id, "brain_sum_of_parts_")) {
    sprintf("Table check %s: the four printed part Averages add to %.3f g (%s); the Brain Average prints %s (printed minus sum = %+.3f g; rounding allows +/-%.4f g). Kept as printed.",
            id, ob, sub(";.*$", "", table_checks$note[i]), cells$value_printed[check_rows[[i]][1]], pr - ob, tl)
  } else if (startsWith(id, "pct_brain_weight_sum_")) {
    sprintf("Table check %s: the four percentages of brain weight add to %.2f, not 100 (allowance %.2f). Kept as printed.",
            id, ob, tl)
  } else if (startsWith(id, "pooled_vs_TABLE2_")) {
    sprintf("Table check %s: the NORMAL and DWARF Averages pooled (n-weighted), %s, give %.4f g; TABLE 2 prints %s g for all the %ss (pooled minus TABLE 2 = %+.4f g; rounding of the printed cells allows +/-%.4f g). Kept as printed.",
            id, sub(" vs TABLE 2 .*$", "", table_checks$note[i]), ob,
            sub("^.* vs TABLE 2 ", "", table_checks$note[i]), sex, ob - pr, tl)
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
