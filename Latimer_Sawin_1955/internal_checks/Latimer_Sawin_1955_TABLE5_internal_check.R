# Latimer_Sawin_1955_TABLE5_internal_check.R -- cross-item internal check (build HOWTO 7b)
#
# Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and
# the weight and length of the spinal cord in the rabbit (race X). Journal of
# Comparative Neurology, 103(3), 513-539. https://doi.org/10.1002/cne.901030307
#
# Cross-item check of Latimer_Sawin_1955_TABLE5: NORMAL n + DWARF n = TABLE 2 n; the NORMAL and DWARF Averages pooled (n-weighted) against the TABLE 2 Average of all the females, every row of the grams block; and, informative only (no pass criterion), the percentages of net body weight against the ratio of the printed means (TABLE 1 net body weight of the same group).
# It needs the sibling analysis CSV Latimer_Sawin_1955_TABLE2.csv (all females) and Latimer_Sawin_1955_TABLE1.csv (Panel C, net body weight), so it
# lives here and not in Latimer_Sawin_1955_TABLE5.R (which reads only its own snapshot).
# The own snapshot is read and parsed exactly as in Latimer_Sawin_1955_TABLE5.R (same code).
# READ-ONLY: writes only internal_checks/Latimer_Sawin_1955_TABLE5_internal_check.csv. No value is
# changed; a mismatch is warned and kept as printed. Nothing from the sibling enters the
# item's CSV/TSV. Run the sibling item script(s) first so the sibling CSV is current.

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
check_dir <- dirname(.sp)                      # <Paper>/internal_checks
folder <- dirname(check_dir); setwd(folder)   # <Paper>
item_name <- sub("_internal_check$", "", sub("\\.R$", "", basename(.sp)))
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
stopifnot(identical(dim(snap), c(21L, 8L)), identical(snap[1, 1], "TABLE 5"))

one_line <- function(x) gsub("\n", " ", x, fixed = TRUE)
snake    <- function(x) gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(x)))
lab      <- ifelse(is.na(snap[, 1]), "", snap[, 1])
is_data  <- apply(snap[, 2:8, drop = FALSE], 1, function(x) all(!is.na(x)))
stat_hdr <- one_line(snap[4, 2:4])
t_hdr    <- one_line(snap[3, 8])
stopifnot(identical(stat_hdr, c("Average", "Stand. dev.", "Coef. var.")),
          identical(one_line(snap[4, 5:7]), stat_hdr), grepl("VALUES$", t_hdr))
stat_code <- c("mean", "sd", "cv")

## sex and n from the printed caption: "... in 30 normal and in 20 dwarf female rabbits";
## the group headers print only NORMAL and DWARF
cap <- snap[2, 1]
nn  <- regmatches(cap, regexec("in ([0-9]+) normal and in ([0-9]+) dwarf (male|female) rabbits$", cap))[[1]]
stopifnot(length(nn) == 4L, identical(tolower(c(snap[3, 2], snap[3, 5])), c("normal", "dwarf")))
sex  <- nn[4]
grpL <- list(label = snap[3, 2], group = tolower(snap[3, 2]), n = as.integer(nn[2]))
grpR <- list(label = snap[3, 5], group = tolower(snap[3, 5]), n = as.integer(nn[3]))

## ---- blocks: all three print a heading; TABLE 5 prints no footnote -----------------
foot_rows    <- grep("^In tables ", lab)
heading_rows <- setdiff(which(!is_data & nzchar(lab) & seq_along(lab) > 4L), foot_rows)
stopifnot(length(foot_rows) == 0L, length(heading_rows) == 3L,
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

## 5. Across tables (1 + 5): NORMAL n + DWARF n = TABLE 2 n, and the NORMAL and DWARF
##    Averages pooled (n-weighted) = the TABLE 2 Average of all the animals of this sex,
##    every row of the grams block. TABLE 2 is read from its analysis CSV as printed text.
t2_csv <- paste0(paper, "_TABLE2.csv")
gm   <- w[w$block == "weight", ]
strs <- unique(gm$structure_as_published)
t2 <- NULL; t2_n <- NA_integer_
if (file.exists(t2_csv)) {
  t2 <- read.csv(t2_csv, colClasses = "character", encoding = "UTF-8")   # keeps "9.349" as printed
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
  t1 <- read.csv(t1_csv, colClasses = "character", encoding = "UTF-8")   # keeps "1959.3" as printed
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

table_checks <- rbind(tc_xn, tc_xm, tc_info)
rownames(table_checks) <- NULL
table_checks <- table_checks[, c("check_id", "basis", "observed", "printed", "difference", "tolerance", "status", "note")]

tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": cross-item checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- the only file written ----------------------------------------------------------
check_csv <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(table_checks), " cross-item checks written to ", basename(check_csv))
