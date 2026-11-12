# Kennedy_etal_1978_Text_internal_check.R --------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for Kennedy, Sakurada, Shinohara, Jehle &
# Sokoloff (1978), Annals of Neurology 4: 293-301. The whole-brain estimate printed in the
# DISCUSSION (p. 298; item Kennedy_etal_1978_Text, text row 4: 29) is compared with the
# value recomputed from the sibling item Kennedy_etal_1978_Table (read from ITS frozen
# snapshot): (mean of the 31 gray-matter rows + mean of the 8 white-matter rows) / 2.
# Each printed cell is an integer (+/-0.5), so each group mean is uncertain by at most
# +/-0.5 and their average by +/-0.5; plus half a unit of the printed 29.
#
# The checks that use only the Text snapshot (3.7 cc O2 -> glucose equivalent, the two
# restatements) stay in Kennedy_etal_1978_Text.R (table_checks, build HOWTO 7a).
#
# Read-only: reads the Text snapshot and the Table snapshot in the paper folder, writes only
# Kennedy_etal_1978_Text_internal_check.csv next to this script. It never changes a value; a
# mismatch is warned and kept as printed.

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

## ---- cell helpers (as in Kennedy_etal_1978_Text.R) ---------------------------------
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*\u00b1.*$", "", s)) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 9.2" -> -9.2, "+ 7.4" -> 7.4

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 10L, identical(tx$text_row, as.character(1:10)))
tb <- read_snapshot(paste0(paper, "_Table_snapshot.csv"))
stopifnot(identical(dim(tb), c(52L, 2L)))

## the text value as the item script reads it (value_numeric)
text_row      <- as.integer(tx$text_row)
value_numeric <- num_of(tx$value_printed)

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

rows <- which(grepl("\u00b1", tb[, 2]))
sec  <- ifelse(tb[, 1] %in% c("Gray matter", "White matter"), tb[, 1], NA_character_)
for (i in 2:length(sec)) if (is.na(sec[i])) sec[i] <- sec[i - 1]
val  <- num_of(mean_lexeme(tb[rows, 2]))
gray <- val[sec[rows] == "Gray matter"]; white <- val[sec[rows] == "White matter"]
stopifnot(length(gray) == 31L, length(white) == 8L)
v <- function(r) value_numeric[text_row == r]
table_checks <- rbind(
  chk("equal_weight_gray_white_average",
      "DISCUSSION p. 298: (mean of 31 gray rows + mean of 8 white rows)/2 vs printed 29",
      (mean(gray) + mean(white)) / 2, v(4), 0.5 + 0.5,
      sprintf("gray mean %.3f, white mean %.3f", mean(gray), mean(white)))
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
