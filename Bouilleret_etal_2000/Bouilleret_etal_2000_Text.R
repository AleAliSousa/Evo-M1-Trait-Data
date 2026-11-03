# Bouilleret_etal_2000_Text.R ---------------------------------------
#
# Bouilleret, Boyet, Marescaux & Nehlig (2000), Brain Research 852: 255-262.
# Dentate-gyrus glucose utilization, printed only in RESULTS 3.3 (p. 259, left
# column); the dentate gyrus is not a row of Table 2.
#
# Reads the constructed, frozen snapshot Bouilleret_etal_2000_Text_snapshot.csv
# (written by Bouilleret_etal_2000_extract_snapshot.R from the PDF text layer):
#   58   control mice (group value; n = 4 per Table 2's control group)
#   27   lowest single value recorded in kainate-treated mice, any time point
#   179  highest single value recorded in kainate-treated mice, any time point
# 27 and 179 are single-animal extremes, not group means; neither the time
# point nor the side is stated. Units µmol/100 g/min (project unit).
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
stopifnot(nrow(tx) == 3L, identical(tx$text_row, as.character(1:3)),
          all(tx$units_printed == "µmol/100 g/min"))
final.dataframe <- data.frame(
  text_row            = as.integer(tx$text_row),
  page                = tx$page,
  location            = tx$location,
  passage_as_printed  = tx$passage_as_printed,
  context_as_printed  = tx$context_as_printed,
  subjects_as_printed = tx$subjects_as_printed,
  state_as_printed    = tx$state_as_printed,
  region_as_printed   = tx$region_as_printed,
  value_printed       = tx$value_printed,
  units_printed       = tx$units_printed,
  value_numeric       = num_of(tx$value_printed),
  measure             = "CMRglc",
  stringsAsFactors = FALSE)
final.dataframe$CMRglc.umol_100g_min <- final.dataframe$value_numeric
final.dataframe$observation_level <- ifelse(grepl("lowest|highest", tx$subjects_as_printed),
                                            "single animal (extreme)", "group")
final.dataframe$n <- ifelse(final.dataframe$observation_level == "group", 4L, 1L)
final.dataframe$arm_id <- ifelse(final.dataframe$observation_level == "group", "control_saline", "KA_any_day")
final.dataframe$species_as_published <- "adult male Swiss albino mice"
final.dataframe$note <- ifelse(final.dataframe$observation_level == "group",
  "Control-mouse dentate gyrus value; n taken from Table 2's control group (4); dispersion not printed; side not stated.",
  "Single-animal extreme among the 15 kainate mice (normo-/hypo-/hypermetabolic in 4/4/7 mice); time point and side not stated.")


chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

table_checks <- rbind(
  chk("order_low_control_high", "printed lowest (27) < control (58) < printed highest (179); observed = number of order violations",
      sum(!(final.dataframe$value_numeric[1] < final.dataframe$value_numeric[3]),
          !(final.dataframe$value_numeric[3] < final.dataframe$value_numeric[2])), 0, 0)
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
