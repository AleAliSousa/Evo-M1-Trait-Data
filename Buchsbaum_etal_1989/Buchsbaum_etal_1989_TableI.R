# Buchsbaum_etal_1989_TableI.R ------------------------------------------------
#
# Buchsbaum et al. (1989), Life Sciences 45: 1349-1356. The table on p. 1354
# "MEAN GLUCOSE METABOLIC RATE IN HUMAN SLEEP (micromoles/100g/min)" (no number
# printed; the text calls it Table I). Normal male volunteers, FDG-PET, night-
# time; FDG given while Awake (n = 10; saccadic eye-movement task, lights off),
# in NREM sleep (n = 12; mainly stages 2-3) or in REM sleep (n = 12).
#
# Reads the frozen snapshot and writes one analysis row per printed mean/SD pair
# (12 regions + 3 section means + grand mean = 16 rows x 3 arms = 48 rows).
# row_type separates measured regions from the printed means (do not pool the
# means with the regions). Units µmol/100 g/min (project unit). No value typed.

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

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## ---- cell helpers: a printed cell "57 ± 5^b,c" / "- 9.2 ± 9.84" / "34.1**" ---------
## is split into its printed mean lexeme, printed dispersion lexeme and footnote
## marks; the numbers are parsed from those lexemes. Nothing is repaired.
marks_of <- function(x) {
  m <- ifelse(grepl("\\^[a-z](,[a-z])*$", x), sub("^.*\\^([a-z](,[a-z])*)$", "\\1", x),
       ifelse(grepl("\\*+$", x), sub("^.*?(\\*+)$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("(\\^[a-z](,[a-z])*|\\*+)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*±.*$", "", s)) }
disp_lexeme <- function(x) { s <- strip_marks(x); ifelse(grepl("±", s), trimws(sub("^.*±\\s*", "", s)), NA_character_) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 9.2" -> -9.2, "+ 7.4" -> 7.4

long_cells <- function(snap, rows, arms, section, species, structure = snap[rows, 1]) {
  out <- do.call(rbind, lapply(seq_len(nrow(arms)), function(k) {
    cell <- snap[rows, arms$col[k]]
    data.frame(printed_row = rows, structure_order = seq_along(rows),
               section_as_published = section[rows],
               structure_as_published = gsub("\n", " ", structure, fixed = TRUE),
               group_as_published = arms$group[k], column_as_published = arms$column[k],
               arm_id = arms$arm_id[k], n = arms$n[k],
               cell_as_printed = cell, mean_printed = mean_lexeme(cell),
               dispersion_printed = disp_lexeme(cell), dispersion_type = arms$disp_type[k],
               footnote_marks = marks_of(cell), measure = arms$measure[k],
               unit_as_printed = arms$unit[k], stringsAsFactors = FALSE)
  }))
  out$value_numeric        <- num_of(out$mean_printed)
  out$dispersion_numeric   <- num_of(out$dispersion_printed)
  out$CMRglc.umol_100g_min <- ifelse(out$measure == "CMRglc", out$value_numeric, NA_real_)
  out$species_as_published <- species
  out$note <- NA_character_
  out <- out[order(out$structure_order, match(out$arm_id, arms$arm_id)), ]
  rownames(out) <- NULL
  out
}


snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(27L, 7L)), snap[1, 1] == "MEAN GLUCOSE METABOLIC RATE IN HUMAN SLEEP",
          identical(snap[4, c(2, 4, 6)], c("Awake (n=10)", "NREM (n=12)", "REM (n=12)")),
          identical(snap[5, 2:7], rep(c("mean", "SD"), 3)))
sections <- c("Lateral cortex", "Subcortical gray", "Medial cortex")
section <- ifelse(snap[, 1] %in% sections, snap[, 1], NA_character_)
for (i in 2:nrow(snap)) if (is.na(section[i])) section[i] <- section[i - 1]   # carried down; Grand Mean set to NA below
rows <- which(grepl("^[0-9]+\\.[0-9]$", snap[, 2]))
stopifnot(length(rows) == 16L)
arms <- data.frame(col = c(2L, 4L, 6L), column = snap[4, c(2, 4, 6)], arm_id = c("awake", "nrem_sleep", "rem_sleep"),
                   n = c(10L, 12L, 12L), stringsAsFactors = FALSE)
final.dataframe <- do.call(rbind, lapply(seq_along(rows), function(j) {
  r <- rows[j]
  do.call(rbind, lapply(seq_len(nrow(arms)), function(k) data.frame(
    printed_row = r, structure_order = j,
    section_as_published = ifelse(snap[r, 1] == "Grand Mean", NA_character_, section[r]),
    structure_as_published = snap[r, 1],
    row_type = ifelse(snap[r, 1] == "Grand Mean", "grand_mean", ifelse(snap[r, 1] == "Mean", "section_mean", "region")),
    column_as_published = arms$column[k], arm_id = arms$arm_id[k], n = arms$n[k],
    mean_printed = snap[r, arms$col[k]], dispersion_printed = snap[r, arms$col[k] + 1L],
    dispersion_type = "SD", measure = "CMRglc", unit_as_printed = "micromoles/100g/min",
    stringsAsFactors = FALSE)))
}))
final.dataframe$value_numeric        <- as.numeric(final.dataframe$mean_printed)
final.dataframe$dispersion_numeric   <- as.numeric(final.dataframe$dispersion_printed)
final.dataframe$CMRglc.umol_100g_min <- final.dataframe$value_numeric
final.dataframe$species_as_published <- "normal volunteers (male subjects)"
final.dataframe$note <- ifelse(final.dataframe$row_type == "region", NA_character_,
  "Printed mean row (not a measured region); its SD is the printed SD of that mean.")
final.dataframe$note[final.dataframe$arm_id == "awake" & is.na(final.dataframe$note)] <-
  "Awake n = 10: IV lines failed for blood drawing in 2 of the 12 awake subjects (footnote under the table)."
stopifnot(!anyNA(final.dataframe$value_numeric), all(final.dataframe$section_as_published[final.dataframe$row_type != "grand_mean"] %in% sections))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## Each printed section "Mean" vs the mean of its 4 printed regions, and the
## "Grand Mean" vs the mean of the 12 regions; tolerance 0.05 (rounding of the
## four inputs averages to at most 0.05) + 0.05 (printed result).

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}


tc <- list()
for (a in arms$arm_id) {
  d <- final.dataframe[final.dataframe$arm_id == a, ]
  for (s in sections) {
    reg <- d$value_numeric[d$section_as_published == s & d$row_type == "region"]
    pm  <- d$value_numeric[d$section_as_published == s & d$row_type == "section_mean"]
    tc[[length(tc) + 1L]] <- chk(paste0("mean_", gsub(" ", "_", s), "_", a), paste0(s, " Mean vs mean of its 4 regions, ", a), mean(reg), pm, 0.1)
  }
  tc[[length(tc) + 1L]] <- chk(paste0("grand_mean_", a), paste0("Grand Mean vs mean of the 12 regions, ", a),
                               mean(d$value_numeric[d$row_type == "region"]), d$value_numeric[d$row_type == "grand_mean"], 0.1)
}
table_checks <- do.call(rbind, tc)

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


## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived exactly as the registry formula would
## build it (DOI with "/" percent-encoded, "_", item locus) and the README says
## the item awaits registration; the registry stays the authority.
doi <- "10.1016/0024-3205(89)90021-0"
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(gsub("/", "%2F", doi, fixed = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
