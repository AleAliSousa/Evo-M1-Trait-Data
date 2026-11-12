# Buchsbaum_etal_1989_Text.R ----------------------------------------
#
# Buchsbaum et al. (1989), Life Sciences 45: 1349-1356. Values printed in the
# Summary (p. 1349) and RESULTS (p. 1353). Reads the constructed, frozen
# snapshot; checks every value against the frozen table snapshot. Rows 2-4
# restate the Lateral-cortex "Mean" row of the table (same means) but print
# different SDs for NREM and REM; rows 5-8 are differences/percentages computed
# from table means; row 1 is a whole-brain % reduction. No value typed.

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


tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 8L)
tb <- read_snapshot(paste0(paper, "_TableI_snapshot.csv"))
stopifnot(identical(dim(tb), c(27L, 7L)))
row_of <- function(label, after = NULL) { i <- which(tb[, 1] == label); if (!is.null(after)) i <- i[i > which(tb[, 1] == after)][1]; i[1] }
lat_mean <- row_of("Mean", "Lateral cortex")
final.dataframe <- data.frame(
  text_row = as.integer(tx$text_row), page = tx$page, location = tx$location,
  passage_as_printed = tx$passage_as_printed, subjects_as_printed = tx$subjects_as_printed,
  state_as_printed = tx$state_as_printed, region_as_printed = tx$region_as_printed,
  value_printed = tx$value_printed,
  dispersion_printed = ifelse(nzchar(tx$dispersion_printed), tx$dispersion_printed, NA_character_),
  units_printed = tx$units_printed, value_numeric = as.numeric(tx$value_printed),
  dispersion_numeric = suppressWarnings(as.numeric(tx$dispersion_printed)), stringsAsFactors = FALSE)
final.dataframe$measure <- ifelse(final.dataframe$units_printed == "micromoles/100g/min", "CMRglc",
                           ifelse(grepl("^%", final.dataframe$units_printed), "CMRglc_pct_change", "CMRglc_difference"))
final.dataframe$CMRglc.umol_100g_min <- ifelse(final.dataframe$measure == "CMRglc", final.dataframe$value_numeric, NA_real_)
final.dataframe$arm_id <- c("nrem_vs_awake", "nrem_sleep", "awake", "rem_sleep", rep("nrem_vs_awake", 4))[final.dataframe$text_row]
final.dataframe$value_status <- ifelse(final.dataframe$measure == "CMRglc", "restatement_of_table_mean_with_different_SD", "derived_from_table")
final.dataframe$value_status[final.dataframe$text_row == 3L] <- "restatement_of_table_mean"
final.dataframe$species_as_published <- "normal volunteers"
final.dataframe$note <- NA_character_


chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}


tv <- function(r, c) as.numeric(tb[r, c])
mf <- row_of("Medial frontal"); pu <- row_of("Putamen"); gm <- row_of("Grand Mean")
v <- function(r) final.dataframe$value_numeric[final.dataframe$text_row == r]
s <- function(r) final.dataframe$dispersion_numeric[final.dataframe$text_row == r]
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
