# Buchsbaum_etal_1989_Text_internal_check.R ------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Buchsbaum et al. (1989), Life Sciences
# 45: 1349-1356. The values printed in the Summary (p. 1349) and RESULTS (p. 1353) -- item
# Buchsbaum_etal_1989_Text -- are compared with the sibling item Buchsbaum_etal_1989_TableI
# (read from ITS frozen snapshot): rows 2-4 restate the Lateral-cortex "Mean" row of the table
# (same means, different SDs for NREM and REM); rows 5-8 are differences/percentages computed
# from table means; row 1 is a whole-brain % reduction.
#
# Read-only: reads the Text snapshot and the TableI snapshot in the paper folder, writes only
# Buchsbaum_etal_1989_Text_internal_check.csv next to this script. It never changes a value; a
# mismatch is warned and kept as printed. The item script Buchsbaum_etal_1989_Text.R reads
# only its own snapshot.

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
folder <- dirname(.sp); setwd(folder)                       # <Paper>/internal_checks
item_name <- sub("_internal_check\\.R$", "", basename(.sp))
base <- item_name
paper <- basename(dirname(folder))
paper_dir <- dirname(folder)                                # snapshots live in the paper folder

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file.path(paper_dir, file), header = header, colClasses = "character",
                na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 8L)
tb <- read_snapshot(paste0(paper, "_TableI_snapshot.csv"))
stopifnot(identical(dim(tb), c(27L, 7L)))
row_of <- function(label, after = NULL) { i <- which(tb[, 1] == label); if (!is.null(after)) i <- i[i > which(tb[, 1] == after)][1]; i[1] }
lat_mean <- row_of("Mean", "Lateral cortex")

## the text values as the item script reads them (value_numeric / dispersion_numeric)
text_row           <- as.integer(tx$text_row)
value_numeric      <- as.numeric(tx$value_printed)
dispersion_numeric <- suppressWarnings(as.numeric(tx$dispersion_printed))

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

tv <- function(r, c) as.numeric(tb[r, c])
mf <- row_of("Medial frontal"); pu <- row_of("Putamen"); gm <- row_of("Grand Mean")
v <- function(r) value_numeric[text_row == r]
s <- function(r) dispersion_numeric[text_row == r]
regs <- which(grepl("^[0-9]+\\.[0-9]$", tb[, 2]) & !(tb[, 1] %in% c("Mean", "Grand Mean")))
pct <- 100 * (as.numeric(tb[regs, 2]) - as.numeric(tb[regs, 4])) / as.numeric(tb[regs, 2])
table_checks <- rbind(
  chk("nrem_mean", "text 14.0 vs table Lateral cortex Mean NREM", v(2), tv(lat_mean, 4), 0),
  chk("nrem_sd",   "text SD 3.7 vs table Lateral cortex Mean NREM SD", s(2), tv(lat_mean, 5), 0),
  chk("awake_mean", "text 21.4 vs table Lateral cortex Mean Awake", v(3), tv(lat_mean, 2), 0),
  chk("awake_sd",   "text SD 6.3 vs table Lateral cortex Mean Awake SD", s(3), tv(lat_mean, 3), 0),
  chk("rem_mean", "text 19.2 vs table Lateral cortex Mean REM", v(4), tv(lat_mean, 6), 0),
  chk("rem_sd",   "text SD 4.3 vs table Lateral cortex Mean REM SD", s(4), tv(lat_mean, 7), 0),
  chk("medial_frontal_diff", "text 10.5 vs table Medial frontal Awake - NREM", tv(mf, 2) - tv(mf, 4), v(5), 0.1),
  chk("medial_frontal_pct", "text 38.2% vs 100 x (Awake - NREM)/Awake, Medial frontal", 100 * (tv(mf, 2) - tv(mf, 4)) / tv(mf, 2), v(6), 0.4),
  chk("putamen_diff", "text 7.5 vs table Putamen Awake - NREM", tv(pu, 2) - tv(pu, 4), v(7), 0.1),
  chk("putamen_pct", "text 28.4% vs 100 x (Awake - NREM)/Awake, Putamen", 100 * (tv(pu, 2) - tv(pu, 4)) / tv(pu, 2), v(8), 0.4),
  chk("largest_pct_is_medial_frontal", "largest % NREM decrease among the 12 regions = Medial frontal (observed = its rank)", rank(-pct)[tb[regs, 1] == "Medial frontal"], 1, 0),
  chk("smallest_pct_is_putamen", "smallest % NREM decrease among the 12 regions = Putamen (observed = its rank from the bottom)", rank(pct)[tb[regs, 1] == "Putamen"], 1, 0),
  chk("summary_23pct", "Summary 'about a 23% reduction ... across the entire brain' vs 100 x (Awake - NREM)/Awake of the Grand Mean",
      100 * (tv(gm, 2) - tv(gm, 4)) / tv(gm, 2), v(1), 1.5, "'about' allows a wide tolerance (1.5 points); the table gives 32.3")
)

## ---- output: this check's own CSV (never a snapshot, analysis CSV or TSV) ------
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": internal check  pass=", tally[[1]], "  mismatch=", tally[[2]],
        "  not_evaluable=", tally[[3]])
if (tally[[2]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$basis[i], bad$observed[i], bad$printed[i], bad$difference[i],
                    bad$tolerance[i]), call. = FALSE)
}
write.csv(table_checks, paste0(base, "_internal_check.csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(table_checks), " checks written to ", base, "_internal_check.csv")
