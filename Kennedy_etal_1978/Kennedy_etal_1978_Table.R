# Kennedy_etal_1978_Table.R ---------------------------------------------------
#
# Kennedy, Sakurada, Shinohara, Jehle & Sokoloff (1978), Annals of Neurology
# 4: 293-301. The single, unnumbered table "Values for Local Cerebral Glucose
# Utilization in Normal, Conscious Monkeys", p. 298.
#
# Reads the frozen snapshot (Kennedy_etal_1978_Table_snapshot.csv, written by
# Kennedy_etal_1978_extract_snapshot.R) and does all the cleaning:
#   - one analysis row per printed structure (39), in printed order;
#   - the printed section heading (Gray matter / White matter) carried down;
#   - the footnote mark "^a" on a structure name moved to footnote_marks and
#     turned into n (7 animals; 6 for the rows marked a, per the footnote);
#   - mean and S.E.M. lexemes split and parsed. Units µmol/100 g/min are the
#     project unit; no conversion.
# No table value is typed in this script.

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
stopifnot(identical(dim(snap), c(52L, 2L)), snap[2, 1] == "Structure",
          grepl("^The values are means ± standard errors from measurements in 7 animals", snap[52, 1]))
section <- ifelse(snap[, 1] %in% c("Gray matter", "White matter"), snap[, 1], NA_character_)
for (i in 2:length(section)) if (is.na(section[i])) section[i] <- section[i - 1]
rows <- which(grepl("±", snap[, 2]))
stopifnot(length(rows) == 39L)

arms <- data.frame(col = 2L, group = NA_character_,
                   column = gsub("\n", " ", snap[2, 2], fixed = TRUE),
                   arm_id = "conscious_normal", n = 7L, measure = "CMRglc",
                   unit = "µmoles/100 gm/min", disp_type = "SEM", stringsAsFactors = FALSE)
name_printed <- snap[rows, 1]
final.dataframe <- long_cells(snap, rows, arms, section = section,
                              species = "rhesus monkey",
                              structure = sub("\\^a$", "", name_printed))
marked <- grepl("\\^a$", name_printed)
final.dataframe$footnote_marks[marked] <- "a"
final.dataframe$n[marked] <- 6L
final.dataframe$note[marked] <- "Footnote a: value from 6 animals (all other rows 7)."
stopifnot(sum(marked) == 3L, !anyNA(final.dataframe$value_numeric))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## The table prints no totals. The RESULTS text (p. 297) states the row counts:
## "31 gray and 8 white structures". The DISCUSSION's equal-weight gray/white
## average (29 µmol/100 g/min) is checked in Kennedy_etal_1978_Text.R.

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

table_checks <- rbind(
  chk("n_gray_rows",  "structure rows under 'Gray matter' vs RESULTS p. 297 '31 gray ... structures'",
      sum(final.dataframe$section_as_published == "Gray matter"), 31, 0),
  chk("n_white_rows", "structure rows under 'White matter' vs RESULTS p. 297 '8 white structures'",
      sum(final.dataframe$section_as_published == "White matter"), 8, 0),
  chk("highest_is_inferior_colliculus",
      "highest printed value is the Inferior colliculus row (RESULTS p. 297: 'The highest value was in the inferior colliculus')",
      max(final.dataframe$value_numeric),
      final.dataframe$value_numeric[final.dataframe$structure_as_published == "Inferior colliculus"], 0)
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
doi <- "10.1002/ana.410040402"
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
