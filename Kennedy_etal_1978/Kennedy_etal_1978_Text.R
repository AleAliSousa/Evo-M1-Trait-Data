# Kennedy_etal_1978_Text.R ------------------------------------------
#
# Kennedy, Sakurada, Shinohara, Jehle & Sokoloff (1978), Annals of Neurology
# 4: 293-301. Values printed in the DISCUSSION (p. 298) and in the legends of
# Fig 2 (p. 299) and Fig 3 (p. 300), not in the table.
#
# Reads the constructed, frozen snapshot Kennedy_etal_1978_Text_snapshot.csv
# (one row per printed value, written by Kennedy_etal_1978_extract_snapshot.R)
# and classifies each value by provenance, because the passage mixes this
# paper's own results with values it CITES:
#   new_estimate      29   whole-brain estimate the authors compute from their
#                          own table (equal gray/white weighting)
#   new_single_animal 121, 47, 67 (Fig 2 legend), 107 (Fig 3 legend)
#   cited             3.7 cc O2/100 g/min, Schmidt, Kety & Pennes 1945 [20],
#                     barbiturate-anesthetized monkey (a CMRO2)
#                     31, conscious young men [22] (Sokoloff 1976)
#   derived_from_cited 28, the authors' glucose equivalent of the cited 3.7
#   restatement       the second "28 and 31"
# Units: µmol/100 g/min (project unit). The cited CMRO2 in cc O2/100 g/min is
# also given in µmol O2/100 g/min using the merge's factor 44.64 µmol per mL O2.
# No value is typed in this script.

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

tx <- read_snapshot(paste0(base, "_snapshot.csv"), header = TRUE)
stopifnot(nrow(tx) == 10L, identical(tx$text_row, as.character(1:10)))
tb <- read_snapshot(paste0(paper, "_Table_snapshot.csv"))
stopifnot(identical(dim(tb), c(52L, 2L)))

ML_O2_TO_UMOL <- 44.64      # µmol O2 per mL O2 (STP), the factor used by __merging_cerebral_metabolic_rate

final.dataframe <- data.frame(
  text_row            = as.integer(tx$text_row),
  page                = tx$page,
  location            = tx$location,
  passage_as_printed  = tx$passage_as_printed,
  subjects_as_printed = tx$subjects_as_printed,
  state_as_printed    = tx$state_as_printed,
  region_as_printed   = tx$region_as_printed,
  cited_ref           = ifelse(nzchar(tx$cited_ref), tx$cited_ref, NA_character_),
  value_printed       = tx$value_printed,
  units_printed       = tx$units_printed,
  value_numeric       = num_of(tx$value_printed),
  stringsAsFactors = FALSE)
final.dataframe$measure <- ifelse(grepl("^cc per", tx$units_printed), "CMRO2", "CMRglc")
final.dataframe$CMRglc.umol_100g_min <- ifelse(final.dataframe$measure == "CMRglc",
                                               final.dataframe$value_numeric, NA_real_)
final.dataframe$CMRO2.umol_100g_min  <- ifelse(final.dataframe$measure == "CMRO2",
                                               final.dataframe$value_numeric * ML_O2_TO_UMOL, NA_real_)
status <- c(`1` = "cited", `2` = "derived_from_cited", `3` = "cited", `4` = "new_estimate",
            `5` = "restatement", `6` = "restatement", `7` = "new_single_animal",
            `8` = "new_single_animal", `9` = "new_single_animal", `10` = "new_single_animal")
final.dataframe$value_status <- unname(status[tx$text_row])
final.dataframe$restates_text_row <- c(NA, NA, NA, NA, 2L, 3L, NA, NA, NA, NA)[final.dataframe$text_row]
final.dataframe$n <- ifelse(final.dataframe$value_status == "new_single_animal", 1L,
                     ifelse(final.dataframe$value_status == "new_estimate", 7L, NA_integer_))
final.dataframe$species_as_published <- ifelse(grepl("men|man$", tx$subjects_as_printed),
                                               tx$subjects_as_printed, "monkey")
final.dataframe$data_role <- ifelse(final.dataframe$value_status %in% c("cited", "derived_from_cited") |
                                      (final.dataframe$value_status == "restatement"),
                                    "secondary", "primary")
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$text_row == 1L] <-
  "Cited from ref 20 (Schmidt, Kety & Pennes 1945, Am J Physiol 143:33-52); barbiturate anesthesia kept 'very low'. CMRO2 converted x44.64 to µmol O2/100 g/min."
final.dataframe$note[final.dataframe$text_row %in% c(2L, 5L)] <-
  "Glucose equivalent of the cited 3.7 cc O2 'assuming the usual stoichiometry'; not a measurement in this paper."
final.dataframe$note[final.dataframe$text_row %in% c(3L, 6L)] <-
  "Human value cited from ref 22 (Sokoloff 1976, Basic Neurochemistry); not this paper's data."
final.dataframe$note[final.dataframe$text_row == 4L] <-
  "Authors' estimate for the brain as a whole from the table: equal gray/white fractions, arithmetic means of gray and of white structures averaged. See table_checks: the table gives 30.0."
final.dataframe$note[final.dataframe$text_row %in% 7:10] <-
  "Single animal / single autoradiographic section shown in the figure; not a group mean."

## ---- table checks ---------------------------------------------------------------

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

rows <- which(grepl("±", tb[, 2]))
sec  <- ifelse(tb[, 1] %in% c("Gray matter", "White matter"), tb[, 1], NA_character_)
for (i in 2:length(sec)) if (is.na(sec[i])) sec[i] <- sec[i - 1]
val  <- num_of(mean_lexeme(tb[rows, 2]))
gray <- val[sec[rows] == "Gray matter"]; white <- val[sec[rows] == "White matter"]
stopifnot(length(gray) == 31L, length(white) == 8L)
v <- function(r) final.dataframe$value_numeric[final.dataframe$text_row == r]
table_checks <- rbind(
  ## each printed cell is an integer (±0.5), so each group mean is uncertain by
  ## at most ±0.5 and their average by ±0.5; plus half a unit of the printed 29.
  chk("equal_weight_gray_white_average",
      "DISCUSSION p. 298: (mean of 31 gray rows + mean of 8 white rows)/2 vs printed 29",
      (mean(gray) + mean(white)) / 2, v(4), 0.5 + 0.5,
      sprintf("gray mean %.3f, white mean %.3f", mean(gray), mean(white))),
  ## 3.7 mL O2 -> µmol O2 (/22.4 mL per mmol) -> glucose (6 O2 : 1 glucose)
  chk("o2_to_glucose_equivalent",
      "DISCUSSION p. 298: 3.7 cc O2/100 g/min / 22.4 mL/mmol x 1000 / 6 vs printed 'approximately 28'",
      v(1) / 22.4 * 1000 / 6, v(2), 0.05 / 22.4 * 1000 / 6 + 0.5,
      "assumes the 6:1 O2:glucose stoichiometry the text invokes"),
  chk("restatement_28", "text row 5 vs text row 2", v(5), v(2), 0),
  chk("restatement_31", "text row 6 vs text row 3", v(6), v(3), 0)
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
