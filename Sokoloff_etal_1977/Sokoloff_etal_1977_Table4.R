# Sokoloff_etal_1977_Table4.R ---------------------------------------------------
#
# Sokoloff, Reivich, Kennedy, Des Rosiers, Patlak, Pettigrew, Sakurada &
# Shinohara (1977), Journal of Neurochemistry 28: 897-916. TABLE 4 "Effects of
# thiopental anesthesia on local cerebral glucose consumption in the albino
# rat", p. 913.
#
# Reads the frozen snapshot (Sokoloff_etal_1977_Table4_snapshot.csv, written by
# Sokoloff_etal_1977_Table4_snapshot.R) and does all the cleaning:
#   - one analysis row per printed cell (25 structures x 3 columns = 75), in
#     printed order; section heading (Gray matter / White matter) carried down;
#   - arms: conscious_control (n = 6) and thiopental (n = 8), n read from the
#     printed column headers "Control (6)†" / "Anesthetized (8)†", mean ± S.E.M.,
#     30-min experimental period (footnote *); plus the printed "% Effect"
#     column as its own rows (arm_id percent_effect, measure percent_effect,
#     CMRglc.umol_100g_min NA) so the printed percentage is kept as printed;
#   - header footnote glyphs recorded in footnote_marks on every cell of the arm;
#   - species_as_published keeps the paper's wording; Species is the accepted
#     binomial from _keys/General/species_key.csv (rows for this folder).
#   Units µmol/100 g/min are the project unit; no conversion.
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

read_snapshot <- function(file, header = FALSE) {
  x <- read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## ---- cell helpers: a printed cell "54 ± 2†" / "111 ± 5" / "-42" is split into its ----
## printed mean lexeme, printed dispersion lexeme and footnote marks; the numbers are
## parsed from those lexemes. Nothing is repaired. Marks are the printed glyphs
## ("†", "*", or Kennedy-style "^a").
marks_of <- function(x) {
  m <- ifelse(grepl("[†*]+$", x), sub("^.*?([†*]+)$", "\\1", x),
       ifelse(grepl("\\^[a-z](,[a-z])*$", x), sub("^.*\\^([a-z](,[a-z])*)$", "\\1", x), NA_character_))
  gsub(",", "; ", m, fixed = TRUE)
}
strip_marks <- function(x) trimws(sub("([†*]+|\\^[a-z](,[a-z])*)$", "", x))
mean_lexeme <- function(x) { s <- strip_marks(x); trimws(sub("\\s*±.*$", "", s)) }
disp_lexeme <- function(x) { s <- strip_marks(x); ifelse(grepl("±", s), trimws(sub("^.*±\\s*", "", s)), NA_character_) }
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))   # "- 42" -> -42
n_in_header <- function(h) as.integer(sub("^.*\\((\\d+)\\).*$", "\\1", h))  # "30 min (10)*" -> 10

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

## ---- species: printed name kept, accepted binomial from the collection key ----------
## (HOWTO section 5, Bush_Allman pattern; the key is the single source of truth).
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(species_key$accepted_name, tolower(species_key$variant_name))

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
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
  invisible(tally)
}

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(36L, 4L)), snap[3, 1] == "Structure",
          grepl("^\\* Determined at 30 min", snap[35, 1]),
          grepl("^† The values are the means ± standard errors", snap[36, 1]))
section <- ifelse(snap[, 1] %in% c("Gray matter", "White matter"), snap[, 1], NA_character_)
for (i in 2:length(section)) if (is.na(section[i])) section[i] <- section[i - 1]
rows <- which(grepl("±", snap[, 2]))
stopifnot(length(rows) == 25L)

hdr <- snap[3, 2:4]
span <- gsub("\n", " ", snap[2, 2], fixed = TRUE)
arms <- data.frame(col = 2:4, group = c(span, span, NA_character_), column = hdr,
                   arm_id = c("conscious_control", "thiopental", "percent_effect"),
                   n = c(n_in_header(hdr[1]), n_in_header(hdr[2]), NA_integer_),
                   measure = c("CMRglc", "CMRglc", "percent_effect"),
                   unit = c("µmol/100 g/min", "µmol/100 g/min", "%"),
                   disp_type = c("SEM", "SEM", NA_character_), stringsAsFactors = FALSE)
stopifnot(identical(arms$n[1:2], c(6L, 8L)))

species_printed <- "albino rat"   # title and Table 4 caption
final.dataframe <- long_cells(snap, rows, arms, section = section, species = species_printed)
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
## header footnote marks (* on the title, † on both value-column headers) apply to the arm
hdr_marks <- marks_of(hdr)
for (k in 1:2) {
  sel <- final.dataframe$arm_id == arms$arm_id[k]
  final.dataframe$footnote_marks[sel] <- ifelse(is.na(final.dataframe$footnote_marks[sel]), hdr_marks[k],
                                                paste(final.dataframe$footnote_marks[sel], hdr_marks[k], sep = "; "))
  final.dataframe$note[sel] <- "Header footnote †: means ± S.E.M. in the number of animals in brackets; all control-vs-anesthetized differences significant at P < 0.05. Title footnote *: determined at 30 min after the pulse."
}
final.dataframe$note[final.dataframe$arm_id == "percent_effect"] <- "Printed % Effect of anesthesia relative to control; kept as printed, not recomputed."
stopifnot(!anyNA(final.dataframe$Species), !anyNA(final.dataframe$value_numeric),
          !anyNA(final.dataframe$dispersion_numeric[final.dataframe$measure == "CMRglc"]))

## ---- table checks (HOWTO section 7a) ------------------------------------------
## The % Effect column is derivable from the two printed means: 100 * (anesth - control) /
## control, rounded to the integer; checked row by row (tolerance 1 for rounding of
## means already rounded to integers). RESULTS p. 912-913: anesthesia "reduced the rates
## ... in all structures"; "percent effects in white matter were relatively small".
ctl <- final.dataframe[final.dataframe$arm_id == "conscious_control", ]
ane <- final.dataframe[final.dataframe$arm_id == "thiopental", ]
pct <- final.dataframe[final.dataframe$arm_id == "percent_effect", ]
stopifnot(identical(ctl$structure_as_published, ane$structure_as_published),
          identical(ctl$structure_as_published, pct$structure_as_published))
recomp <- 100 * (ane$value_numeric - ctl$value_numeric) / ctl$value_numeric
table_checks <- rbind(
  do.call(rbind, lapply(seq_len(nrow(pct)), function(i)
    chk(paste0("pct_effect_recomputed_", i), paste0("% Effect recomputed from printed means: ", pct$structure_as_published[i]),
        round(recomp[i]), pct$value_numeric[i], 1))),
  chk("all_reduced", "structures with anesthetized < control vs RESULTS 'all structures'", sum(ane$value_numeric < ctl$value_numeric), 25, 0),
  chk("white_effect_smaller", "mean % effect white rows minus mean % effect gray rows is positive (white less reduced); printed = 0 means boundary, observed should exceed it",
      mean(pct$value_numeric[pct$section_as_published == "White matter"]) - mean(pct$value_numeric[pct$section_as_published == "Gray matter"]), 0, 100,
      "sign check only: observed difference (white minus gray, %) must be > 0")
)
if (table_checks$observed[table_checks$check_id == "white_effect_smaller"] <= 0)
  table_checks$status[table_checks$check_id == "white_effect_smaller"] <- "mismatch"
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                               .name_repair = "minimal")
registry_row <- which(registry[["Item name"]] == item_name & !is.na(registry[["Item name"]]))
if (length(registry_row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][registry_row]
if (is.na(item_encoded) || !nzchar(item_encoded)) stop("Registered Item encoded is blank for ", item_name)
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV directory not found")
write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
message(item_name, ": public TSV ", item_encoded, ".tsv")
