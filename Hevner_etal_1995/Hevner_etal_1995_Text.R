# Hevner_etal_1995_Text.R ---------------------------------------------------------
#
# Hevner R. F., Liu S. & Wong-Riley M. T. T. (1995) Neuroscience 65(2): 313-342.
# Numeric values printed in the running text (Abstract p. 313, EXPERIMENTAL
# PROCEDURES p. 314, RESULTS pp. 335-338, DISCUSSION pp. 339-341); the paper has
# no table.
#
# Reads the constructed, frozen snapshot Hevner_etal_1995_Text_snapshot.csv (one
# row per printed value, written by Hevner_etal_1995_Text_snapshot.R), parses the
# printed lexemes (single values, ranges, dispersions) and classifies each row:
#   value_status  result            this paper's own measured/derived quantity
#                 ratio_statement   a verbal ratio of this paper's data ("eight- to 12-fold")
#                 sample_descriptor n, body weights, counts of regions/cell types
#                 cited             a value the paper cites from other work (cited_ref)
#                 restatement       repeats an earlier row (restates_text_row)
#   data_role     primary for this paper's own values; secondary for cited values and
#                 their restatements
# Units: enzyme activities as printed (mU/mg tissue, mU/mg protein); brain weight also
# in the project unit mg (g x 1000). No value is typed in this script.

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

root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository registry not found")
species_key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                        colClasses = "character", check.names = FALSE, encoding = "UTF-8")
species_key <- species_key[species_key$source_publication == basename(folder), ]
if (nrow(species_key) == 0L) stop("species_key.csv has no rows for source_publication = ", basename(folder))
lk <- setNames(species_key$accepted_name, tolower(species_key$variant_name))

read_snapshot <- function(file) read.csv(file, header = TRUE, colClasses = "character",
                                         na.strings = character(0), check.names = FALSE, encoding = "UTF-8")
num_of <- function(x) suppressWarnings(as.numeric(gsub("\\s+", "", x)))

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
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

tx <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(nrow(tx) == 48L, identical(tx$text_row, as.character(1:48)))

words <- c(one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10)
## a printed lexeme -> numeric; words, "~", "about", "n = ", "-fold", "times" stripped; ranges -> low/high
parse_lex <- function(s) {
  t <- tolower(s); t <- gsub("~|about|approximately|nearly a|almost a|n =|-fold|times|fold", "", t)
  t <- trimws(gsub("\\s+", " ", t))
  for (w in names(words)) t <- gsub(paste0("\\b", w, "\\b"), words[[w]], t)
  t <- gsub("\\s*(-|to)\\s*", "-", t)                     # "8- -12" / "4 to 5" -> "8-12" / "4-5"
  t <- gsub("-+", "-", t)
  parts <- strsplit(t, "-", fixed = TRUE)[[1]]
  parts <- parts[nzchar(parts)]
  nums <- suppressWarnings(as.numeric(parts))
  if (length(nums) == 2L && !anyNA(nums)) c(NA, nums[1], nums[2]) else c(nums[1], NA, NA)
}
pm <- t(vapply(tx$value_printed, parse_lex, numeric(3)))
stopifnot(!any(is.na(pm[, 1]) & is.na(pm[, 2])))

final.dataframe <- data.frame(
  text_row            = as.integer(tx$text_row),
  page                = tx$page,
  location            = tx$location,
  passage_as_printed  = tx$passage_as_printed,
  quantity            = tx$quantity,
  structure_or_subjects_as_printed = tx$structure_or_subjects_as_printed,
  value_printed       = tx$value_printed,
  dispersion_printed  = ifelse(nzchar(tx$dispersion_printed), tx$dispersion_printed, NA_character_),
  dispersion_type_as_printed = ifelse(nzchar(tx$dispersion_type_as_printed), tx$dispersion_type_as_printed, NA_character_),
  units_printed       = tx$units_printed,
  value_numeric       = pm[, 1],
  value_low           = pm[, 2],
  value_high          = pm[, 3],
  dispersion_numeric  = num_of(tx$dispersion_printed),
  n                   = suppressWarnings(as.integer(tx$n_as_printed)),
  cited_ref           = ifelse(nzchar(tx$cited_ref), tx$cited_ref, NA_character_),
  stringsAsFactors = FALSE)
final.dataframe$approximate <- grepl("about|approximately|~|nearly|almost|generally", tx$value_printed) |
                               grepl("about|approximately|generally", tx$passage_as_printed) & grepl("fold|times|%", tx$units_printed)
final.dataframe$dispersion_type <- ifelse(is.na(final.dataframe$dispersion_numeric), NA_character_,
                                    ifelse(grepl("S\\.E\\.M\\.", tx$dispersion_type_as_printed), "S.E.M.", "S.D."))
## project-unit column for the one mass value (brain weight g -> mg)
final.dataframe$Brain_Mass.mg <- ifelse(tx$quantity == "brain weight", final.dataframe$value_numeric * 1000, NA_real_)
final.dataframe$Brain_Mass_SD.mg <- ifelse(tx$quantity == "brain weight", final.dataframe$dispersion_numeric * 1000, NA_real_)

status <- rep("result", nrow(tx))
status[grepl("^number of|^body weight", tx$quantity)] <- "sample_descriptor"
status[grepl("^ratio|^range|^share", tx$quantity)] <- "ratio_statement"
status[nzchar(tx$cited_ref) & !grepl("^linear regression", tx$quantity)] <- "cited"
restates <- c(`4` = 1L, `15` = 13L, `29` = 1L, `33` = 2L, `43` = 1L, `45` = 3L, `46` = 1L)
status[as.integer(names(restates))] <- "restatement"
final.dataframe$value_status <- status
final.dataframe$restates_text_row <- unname(restates[as.character(final.dataframe$text_row)])
final.dataframe$data_role <- ifelse(status == "cited" | (status == "restatement" & final.dataframe$text_row %in% c(45L)), "secondary", "primary")
final.dataframe$species_as_published <- ifelse(final.dataframe$text_row == 42L, NA_character_, "albino rat")   # row 42 (ATP share, cited) names no species
final.dataframe$Species <- unname(lk[tolower(final.dataframe$species_as_published)])
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$text_row %in% c(19L, 20L)] <-
  "Dispersion type not restated; the preceding sentence gives mean ± S.D. The Fig. 31 legend states S.E.M. for the plotted bars; the digitised whole-brain error bars (5.1 and 31) are consistent with S.D./sqrt(6) = 4.9 and 41, not with 12 and 100 (internal_checks)."
final.dataframe$note[final.dataframe$text_row == 21L] <- "Calculated by the authors from the whole-brain activity content and the cited cytochrome aa3 content (table_checks: turnover)."
final.dataframe$note[final.dataframe$text_row == 22L] <- "Cited from ref 3 (Brown, Crompton & Wray 1991, Biochim. biophys. Acta 1057: 273-275); not this paper's measurement."
final.dataframe$note[final.dataframe$text_row %in% c(3L, 45L)] <- "Gray/white ratio of 2-DG uptake cited from ref 30 (Sokoloff et al. 1977); not this paper's data. See Sokoloff_etal_1977_Table3."
final.dataframe$note[final.dataframe$text_row %in% c(41L, 47L)] <- "Range of the Sokoloff et al. (1977, ref 30) gray-matter 2-DG values as characterised by these authors; not this paper's measurement."
final.dataframe$note[final.dataframe$text_row %in% c(38L, 39L, 40L)] <- "This paper's regression of the cited Sokoloff et al. (1977) rates on its own CO values (7 regions); the r2 is this paper's result, the glucose data are ref 30."
final.dataframe$note[final.dataframe$text_row == 42L] <- "General statement cited from ref 10 (Erecinska & Silver 1989); not a measurement of this paper and not species-specific."
final.dataframe$note[final.dataframe$text_row == 44L] <- "Cited from ref 7 (Darriet, Der & Collins 1986, J. cerebr. Blood Flow Metab. 6: 8-14)."
final.dataframe$note[final.dataframe$text_row %in% c(26L, 27L, 35L, 36L)] <- "Also plotted as a bar in Fig. 31 / Fig. 32 (sibling item); the printed value here takes precedence over the digitised bar."
final.dataframe$note[final.dataframe$text_row == 48L] <- "Authors' approximation: (625/200)^2 = 9.77."

## ---- table checks (own snapshot only) -----------------------------------------------------
v <- function(r, col = "value_numeric") final.dataframe[[col]][final.dataframe$text_row == r]
same_range <- function(r, ref) chk(paste0("restatement_range_", r), sprintf("text row %d restates row %d (low and high of the printed range)", r, ref),
                                  v(r, "value_low") * 100 + v(r, "value_high"), v(ref, "value_low") * 100 + v(ref, "value_high"), 0)
table_checks <- rbind(
  chk("protein_percent", "p. 335: 89.9 mg protein/g tissue = 8.99 % vs printed 'about 9%'", v(18) / 10, v(17), 0.5),
  chk("specific_activity_from_content", "p. 335: 158 mU/mg tissue / 89.9 mg protein/g tissue x 1000 vs printed 1760 mU/mg protein", v(19) / v(18) * 1000, v(20), 15, "tolerance: 1760 printed to 3 s.f. (±5) plus rounding of 158 and 89.9"),
  chk("turnover_number", "p. 335: 158 mU/mg tissue = 158 µmol/min/g; / 5.5 nmol aa3/g / 60 vs printed 479 s-1", v(19) * 1000 / v(22) / 60, v(21), 6, "rounding of 158 (±0.5) and 5.5 (±0.05) allows about ±6"),
  chk("n_sum", "p. 314: 7 histochemistry + 14 biochemistry vs printed total 21", v(6) + v(8), v(5), 0),
  chk("n_biochem_split", "p. 314: 6 whole brains + 8 regionally dissected vs 14 biochemistry rats", v(13) + v(14), v(8), 0),
  same_range(4, 1), same_range(29, 1), same_range(43, 1), same_range(46, 1),
  chk("restatement_three_fold", "text row 45 vs text row 3", v(45), v(3), 0),
  chk("restatement_two_fold", "text row 33 vs text row 2", v(33), v(2), 0),
  chk("restatement_n6", "text row 15 vs text row 13", v(15), v(13), 0)
)
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## The live registry is required before writing the public item TSV.
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
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
