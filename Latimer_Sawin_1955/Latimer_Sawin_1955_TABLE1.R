# Latimer_Sawin_1955_TABLE1.R --------------------------------------------------
#
# Latimer, H. B., & Sawin, P. B. (1955). The weight of the brain, of its parts and
# the weight and length of the spinal cord in the rabbit (race X). Journal of
# Comparative Neurology, 103(3), 513-539. https://doi.org/10.1002/cne.901030307
# TABLE 1 "Weight and length of the body for the entire group of 50 males and 50
# females in panel A. Panels B and C show similar data for the normal and dwarf
# males and females", p. 517 (PDF page 5).
#
# Reads the frozen snapshot (Latimer_Sawin_1955_TABLE1_snapshot.xlsx, written by
# Latimer_Sawin_1955_extract_snapshot.R) and does all the cleaning:
#   - one analysis row per printed numeric cell, in printed order, read along each
#     printed row: 9 printed rows x 7 cells = 63 rows (long format);
#   - panel, sex, group and n come from the printed panel titles and group headers
#     ("50 MALES", "35 NORMAL", ...). Panels B and C reprint only the group labels,
#     so their columns take the Panel A column header (Average, Stand. dev., Coef.
#     var., "t" VALUES);
#   - units: the table prints none. Body weight is in grams and nose-anus length in
#     millimetres (MATERIAL AND METHODS, p. 516: values "grouped in 200 gm or 20 mm
#     intervals"). Grams are the project unit for body mass; nothing is converted;
#   - the species comes from the species key (the collection key first, else this
#     paper's proposed rows in reference_tables/), never from an inline map;
#   - the table's own relations are re-run into `table_checks` (build HOWTO
#     section 7a): Coef. var. = 100 x Stand. dev. / Average for every group; the
#     "t" values from the Averages, SDs and n; Panel A against the n-weighted means
#     of Panels B and C. Mismatches are warned, noted on the row and kept as printed.
# No table value is typed in this script.
#
# R NOT RUN — outputs written by a Python mirror; Alexandra to run the R.
# Written 2026-11-06 by an AI assistant. The analysis CSV, the public TSV and the
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
stopifnot(identical(dim(snap), c(21L, 8L)), identical(snap[1, 1], "TABLE 1"))

one_line <- function(x) gsub("\n", " ", x, fixed = TRUE)
snake    <- function(x) gsub("^_+|_+$", "", gsub("[^a-z0-9]+", "_", tolower(x)))
lab      <- ifelse(is.na(snap[, 1]), "", snap[, 1])
is_data  <- apply(snap[, 2:8, drop = FALSE], 1, function(x) all(!is.na(x)))
stat_hdr <- one_line(snap[5, 2:4])
t_hdr    <- one_line(snap[4, 8])
stopifnot(identical(stat_hdr, c("Average", "Stand. dev.", "Coef. var.")),
          identical(one_line(snap[5, 5:7]), stat_hdr), grepl("VALUES$", t_hdr))
stat_code <- c("mean", "sd", "cv")

## ---- panels: title row, optional subtitle row, group-header row, 3 data rows ---
title_rows <- grep("^Panel [A-Z] ", lab)
stopifnot(length(title_rows) == 3L)
panel_last <- c(title_rows[-1] - 1L, nrow(snap))
group_of <- function(txt) {                      # "50 MALES" -> n = 50, word = "males"
  stopifnot(grepl("^[0-9]+ [A-Z]+$", txt))
  list(n = as.integer(sub(" .*$", "", txt)), word = tolower(sub("^[0-9]+ ", "", txt)))
}
sex_word   <- c(males = "male", females = "female")
group_word <- c(normal = "normal", dwarf = "dwarf")

cells <- NULL
for (k in seq_along(title_rows)) {
  rows  <- title_rows[k]:panel_last[k]
  title <- lab[title_rows[k]]
  panel <- sub("^Panel ([A-Z]) .*$", "\\1", title)
  r <- title_rows[k] + 1L
  subtitle <- NA_character_
  if (nzchar(lab[r]) && all(is.na(snap[r, 2:8]))) { subtitle <- lab[r]; r <- r + 1L }
  hdr <- r
  stopifnot(!nzchar(lab[hdr]), !is.na(snap[hdr, 2]), !is.na(snap[hdr, 5]))
  gL <- group_of(snap[hdr, 2]); gR <- group_of(snap[hdr, 5])
  if (all(c(gL$word, gR$word) %in% names(sex_word))) {
    sexL <- sex_word[[gL$word]]; sexR <- sex_word[[gR$word]]; grpL <- grpR <- "all"
  } else {
    stopifnot(all(c(gL$word, gR$word) %in% names(group_word)))
    s <- tolower(sub("^Panel [A-Z] ", "", title))
    stopifnot(s %in% names(sex_word))
    sexL <- sexR <- sex_word[[s]]
    grpL <- group_word[[gL$word]]; grpR <- group_word[[gR$word]]
  }
  data_rows <- rows[is_data[rows]]
  stopifnot(length(data_rows) == 3L)
  for (rr in data_rows) for (j in 2:8) {
    side <- if (j <= 4L) "L" else if (j <= 7L) "R" else "T"
    pos  <- (j - 2L) %% 3L + 1L
    cells <- rbind(cells, data.frame(
      printed_row = rr,
      snapshot_cell = paste0(LETTERS[j], rr),
      panel = panel,
      panel_as_published = if (is.na(subtitle)) title else paste0(title, "; ", subtitle),
      group_label_as_published = switch(side, L = snap[hdr, 2], R = snap[hdr, 5], T = NA_character_),
      sex = switch(side, L = sexL, R = sexR,
                   T = if (sexL == sexR) sexL else paste(sexL, "vs", sexR)),
      group = switch(side, L = grpL, R = grpR,
                     T = if (grpL == grpR) grpL else paste(grpL, "vs", grpR)),
      n = switch(side, L = gL$n, R = gR$n, T = NA_integer_),
      n_compared = if (side == "T") paste(gL$n, "vs", gR$n) else NA_character_,
      measure = snake(lab[rr]),
      measure_as_published = lab[rr],
      statistic = if (side == "T") "t" else stat_code[pos],
      statistic_as_published = if (side == "T") t_hdr else stat_hdr[pos],
      value_printed = snap[rr, j],
      side = side,
      stringsAsFactors = FALSE))
  }
}
cells$value <- suppressWarnings(as.numeric(gsub(",", "", cells$value_printed, fixed = TRUE)))
stopifnot(nrow(cells) == 63L, !anyNA(cells$value))

## Units are not printed; grams and millimetres per MATERIAL AND METHODS (p. 516).
cells$unit <- ifelse(cells$statistic == "t", NA_character_,
              ifelse(cells$statistic == "cv", "%",
              ifelse(grepl("^body_weight", cells$measure), "g",
              ifelse(grepl("^body_length", cells$measure), "mm", NA_character_))))
stopifnot(!anyNA(cells$unit[cells$statistic != "t"]))

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

out_cols <- c("printed_row", "snapshot_cell", "panel", "panel_as_published",
              "group_label_as_published", "sex", "group", "n", "n_compared", "measure",
              "measure_as_published", "statistic", "statistic_as_published", "unit",
              "value_printed", "value")
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
w <- grp[grp$statistic == "mean", c("printed_row", "side", "panel", "measure", "sex", "group", "n")]
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

## 1. Coef. var. = 100 x Stand. dev. / Average, every printed group (18)
cv_obs <- 100 * w$sd / w$mean
cv_tol <- 100 * (w$sd + half_unit(w$sd_txt)) / (w$mean - half_unit(w$mean_txt)) - cv_obs +
          half_unit(w$cv_txt)
tc_cv <- chk(paste("cv", w$panel, w$measure, w$sex, w$group, sep = "_"),
             sprintf("Coef. var. = 100 x Stand. dev. / Average [Panel %s, %s, %s, %s; row %d]",
                     w$panel, w$measure, w$sex, w$group, w$printed_row),
             cv_obs, w$cv, cv_tol,
             "tolerance: worst case of 100 x (SD + half unit)/(Average - half unit), plus half a unit of the printed Coef. var.")
rows_cv <- lapply(seq_len(nrow(w)), function(i) row_of(w$printed_row[i], w$side[i], "cv"))

## 2. the "t" values (9): pooled-variance Student t from the printed Averages, SDs, n
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
tc_t <- chk(paste("t", tt$panel, tt$measure, sep = "_"),
            sprintf("t = |Average 1 - Average 2| / pooled-variance SE (Student; SDs as divisor n-1) [Panel %s, %s: %s %s n = %d vs %s %s n = %d]",
                    tt$panel, tt$measure, L$sex, L$group, L$n, R$sex, R$group, R$n),
            t_obs, tt$value, t_tol,
            sprintf("with divisor-n SDs t = %.3f; tolerance: rounding of the printed inputs (worst case) + half a unit of the printed t, and, below the recomputed t only, down to the divisor-n value (the paper does not state its formula)",
                    t_alt))
rows_t <- as.list(which(cells$statistic == "t"))

## 3. Panel A against Panels B and C: n (2) and n-weighted Averages (6)
allw <- w[w$group == "all", ]
subw <- w[w$group != "all", ]
nd_of <- function(a) {
  nd <- subw[subw$sex == a$sex & subw$measure == a$measure, ]
  stopifnot(nrow(nd) == 2L, identical(sort(nd$group), c("dwarf", "normal")))
  nd
}
tc_n <- do.call(rbind, lapply(unique(allw$sex), function(s) {
  a <- allw[allw$sex == s, ][1, ]; nd <- nd_of(a)
  chk(paste0("n_A_vs_", nd$panel[1], "_", s),
      sprintf("Panel A n (%s) = normal n + dwarf n of Panel %s", s, nd$panel[1]),
      sum(nd$n), a$n, 0)
}))
rows_n <- rep(list(integer(0)), nrow(tc_n))
tc_pm <- do.call(rbind, lapply(seq_len(nrow(allw)), function(i) {
  a <- allw[i, ]; nd <- nd_of(a)
  chk(paste0("pooled_mean_A_vs_", nd$panel[1], "_", a$measure, "_", a$sex),
      sprintf("Panel A Average = n-weighted mean of the Panel %s normal and dwarf Averages [%s, %s]",
              nd$panel[1], a$measure, a$sex),
      sum(nd$n * nd$mean) / sum(nd$n), a$mean,
      sum(nd$n * half_unit(nd$mean_txt)) / sum(nd$n) + half_unit(a$mean_txt),
      sprintf("(%d x %s + %d x %s) / %d", nd$n[1], nd$mean_txt[1], nd$n[2], nd$mean_txt[2], sum(nd$n)))
}))
rows_pm <- lapply(seq_len(nrow(allw)), function(i) row_of(allw$printed_row[i], allw$side[i], "mean"))

table_checks <- rbind(tc_cv, tc_t, tc_n, tc_pm)
check_rows   <- c(rows_cv, rows_t, rows_n, rows_pm)
rownames(table_checks) <- NULL

## ---- per-row notes for the checks that did not pass -----------------------------------
add_note <- function(df, rows, txt) {
  df$note[rows] <- ifelse(is.na(df$note[rows]), txt, paste(df$note[rows], txt, sep = " | "))
  df
}
errata_for <- c(pooled_mean_A_vs_C_body_length_nose_anus_female = "Latimer_Sawin_1955-E001")
for (i in which(table_checks$status == "mismatch")) {
  id <- table_checks$check_id[i]
  pr <- table_checks$printed[i]; ob <- table_checks$observed[i]; tl <- table_checks$tolerance[i]
  txt <- if (startsWith(id, "t_")) {
    sprintf("Table check %s: Student t recomputed from the printed Averages, SDs and n is %.3f (%.3f with divisor-n SDs); printed %s, outside the allowance (%.3f). Kept as printed.",
            id, ob, t_alt[match(id, tc_t$check_id)], cells$value_printed[check_rows[[i]][1]], tl)
  } else if (startsWith(id, "pooled_mean_")) {
    sprintf("Table check %s: the n-weighted mean of the normal and dwarf groups, %s, is %.2f; Panel A prints %s (printed minus pooled = %+.2f; rounding of the printed cells allows +/-%.2f). Kept as printed.",
            id, table_checks$note[i], ob, cells$value_printed[check_rows[[i]][1]], pr - ob, tl)
  } else {
    sprintf("Table check %s: recomputed %.4f, printed %s (allowance %.4f). Kept as printed.",
            id, ob, cells$value_printed[check_rows[[i]][1]], tl)
  }
  if (!is.na(errata_for[id])) txt <- paste0(txt, " See errata ", errata_for[[id]], ".")
  final.dataframe <- add_note(final.dataframe, check_rows[[i]], txt)
}

tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
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
