# Bouilleret_etal_2000_Table2.R -----------------------------------------------
#
# Bouilleret, Boyet, Marescaux & Nehlig (2000), Brain Research 852: 255-262.
# Table 2 "Effects of intrahippocampal kainate on LCMRglcs of adult mice",
# pp. 258-259; µmol/100 g/min, means ± S.D.
# Adult male Swiss albino mice, freely moving and conscious during the 2DG
# experiment (catheters under light halothane at least 3-4 h before). Control
# = saline injected into the right dorsal hippocampus (n = 4: one saline mouse
# randomly selected at each of the four times); KA = kainate (50 nl, 0.2 µg)
# into the right dorsal hippocampus, studied at day 0 (10-12 h, late status
# epilepticus, n = 3), day 15, 30 and 120 (n = 4 each).
#
# Reads the frozen snapshot (Bouilleret_etal_2000_Table2_snapshot.csv, written by
# Bouilleret_etal_2000_extract_snapshot.R):
#   - one analysis row per printed cell (48 structure-side rows x 5 arms), in
#     printed order;
#   - the printed section heading carried down; the printed side (", right" /
#     ", left") split into its own column; right = ipsilateral to the injection
#     (METHODS: injection into the right hippocampus, Fig 1 legend);
#   - "destroyed" kept as printed, value NA;
#   - units µmol/100 g/min are the project unit; no conversion.
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
stopifnot(identical(dim(snap), c(67L, 6L)), snap[1, 1] == "Table 2",
          snap[3, 2] == "Control (n = 4)", snap[3, 3] == "KA", snap[60, 1] == "Table 2 (continued)")
sections <- c("Cerebral cortex", "Forebrain", "Hypothalamus", "Thalamus", "Midbrain\u2013brainstem", "White matter")
section <- ifelse(snap[, 1] %in% sections, snap[, 1], NA_character_)
for (i in 2:length(section)) if (is.na(section[i])) section[i] <- section[i - 1]
rows <- which(grepl("±|destroyed", snap[, 2]))
stopifnot(length(rows) == 48L)

spanner <- snap[3, ]; for (j in 4:6) if (!nzchar(spanner[j])) spanner[j] <- spanner[j - 1]
hdr <- ifelse(nzchar(snap[4, ]), snap[4, ], snap[3, ])
arms <- data.frame(
  col       = 2:6,
  group     = c(NA, rep("KA", 4)),
  column    = gsub("\n", " ", hdr[2:6], fixed = TRUE),
  arm_id    = c("control_saline", "KA_day0", "KA_day15", "KA_day30", "KA_day120"),
  n         = as.integer(sub("^.*\\(n = ([0-9]+)\\).*$", "\\1", hdr[2:6])),
  measure   = "CMRglc",
  unit      = "µmol/100 g/min",
  disp_type = "SD",
  stringsAsFactors = FALSE)
stopifnot(identical(arms$n, c(4L, 3L, 4L, 4L, 4L)))
final.dataframe <- long_cells(snap, rows, arms, section = section, species = "adult male Swiss albino mice")
final.dataframe$side_as_published <- sub("^.*, (right|left)$", "\\1", final.dataframe$structure_as_published)
final.dataframe$structure_base_as_published <- sub(", (right|left)$", "", final.dataframe$structure_as_published)
final.dataframe$side_vs_injection <- ifelse(final.dataframe$side_as_published == "right", "ipsilateral", "contralateral")
dest <- final.dataframe$cell_as_printed == "destroyed"
final.dataframe$note[dest] <- "Printed 'destroyed': from day 30 no reading was made in CA1/CA3 because of cell loss (RESULTS 3.3)."
final.dataframe$note[!is.na(final.dataframe$footnote_marks)] <-
  ifelse(is.na(final.dataframe$note[!is.na(final.dataframe$footnote_marks)]),
         "Stars: * p < 0.05, ** p < 0.01 vs control group.", final.dataframe$note[!is.na(final.dataframe$footnote_marks)])
stopifnot(all(final.dataframe$side_as_published %in% c("right", "left")),
          sum(dest) == 4L, !anyNA(final.dataframe$value_numeric[!dest]))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## No totals or percentages are printed. The text allows count checks only:
## "LCMRglcs were determined in 24 structures both ipsi- and contralaterally"
## (2.4) and the n of each group (2.2: 23 mice = 8 saline + 15 kainate, one
## saline mouse per time point retained -> control n = 4; KA 3 + 4 + 4 + 4 = 15).

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

## Hypothalamus and Thalamus share sub-labels (Anterior, Ventromedian,
## Posterior), so a structure is counted as section + label.
n_struct <- length(unique(paste(final.dataframe$section_as_published,
                                final.dataframe$structure_base_as_published)))
table_checks <- rbind(
  chk("n_structures", "distinct structures (section + label, sides pooled) vs 2.4 '24 structures'",
      n_struct, 24, 0),
  chk("n_kainate_mice", "sum of KA group n vs 2.2 '15 receiving kainate'", sum(arms$n[-1]), 15, 0),
  chk("n_destroyed", "'destroyed' cells = CA1 and CA3 right at day 30 and 120 (RESULTS 3.3)", sum(dest), 4, 0)
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
doi <- "10.1016/S0006-8993(99)02092-2"
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
