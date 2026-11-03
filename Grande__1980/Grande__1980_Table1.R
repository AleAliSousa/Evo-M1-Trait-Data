# Grande__1980_Table1.R ------------------------------------------------------------
#
# Grande (1980), pp. 88-92 in Assessment of energy metabolism in health and disease (First
# Ross Conference on Medical Research). Table 1 p. 88: "Various estimates of BMR partition in
# man, as percent of total BMR" - liver, brain, heart, kidney, subtotal 1, muscle, subtotal 2,
# in five columns that each cite an earlier publication (Ref 15, 19, 16*, 17, 18; list on pp.
# 91-92). SECONDARY: a compilation of five earlier estimates, one of them Grande's own (1950).
#
# Reads the frozen snapshot (Grande__1980_Table1_snapshot.csv) and:
#   - writes one analysis row per printed cell: 7 rows x 5 estimates = 35 rows (long format);
#     the two cells printed blank (Ref 18, Muscle and Subtotal 2) stay in as NA;
#   - keeps the printed reference key ("Ref 16*") in ref_key; reference_tables/
#     Grande__1980_Table1_references.csv binds it to the bibliography entry (ref_number
#     is the numeral);
#   - table checks (HOWTO 7a): Subtotal 1 = liver + brain + heart + kidney; Subtotal 2 =
#     Subtotal 1 + muscle, per estimate, within half a unit of the last printed decimal per
#     summed cell. Blank cells are left out and say so.
# Values are % of total BMR; no unit conversion.
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
  x <- utils::read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## English print: "," = thousands separator, "." = decimal mark.
num_en <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x), fixed = TRUE)))
dec_en <- function(x) ifelse(grepl(".", x, fixed = TRUE), nchar(sub("^.*\\.", "", x)), 0L)   # printed decimals

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(10L, 6L)), snap[2, 1] == "Organ", identical(snap[2, 2:6], c("Ref 15", "Ref 19", "Ref 16*", "Ref 17", "Ref 18")),
          identical(snap[3:9, 1], c("Liver", "Brain", "Heart", "Kidney", "Subtotal 1", "Muscle", "Subtotal 2")))
rows <- 3:9
refs <- snap[2, 2:6]
final.dataframe <- do.call(rbind, lapply(seq_along(rows), function(i)
  do.call(rbind, lapply(1:5, function(k) {
    cell <- snap[rows[i], 1 + k]
    data.frame(printed_row = rows[i], row_order = i, organ_as_published = snap[rows[i], 1],
               is_subtotal = grepl("^Subtotal", snap[rows[i], 1]),
               ref_key = refs[k], ref_number = as.integer(sub("^Ref ([0-9]+).*$", "\\1", refs[k])),
               footnote_marks = ifelse(grepl("\\*$", refs[k]), "*", NA_character_),
               cell_as_printed = cell, species_as_published = "man",
               stringsAsFactors = FALSE)
  }))))
final.dataframe$pct_of_BMR <- num_en(final.dataframe$cell_as_printed)
final.dataframe$unit_as_printed <- "% of total BMR"
final.dataframe$note <- NA_character_
final.dataframe$note[final.dataframe$cell_as_printed == ""] <- "cell printed blank (no value for this estimate)"
final.dataframe$note[final.dataframe$ref_key == "Ref 16*" & is.na(final.dataframe$note)] <- "printed footnote *: recalculated from original data of Ref 16"
stopifnot(nrow(final.dataframe) == 35L, sum(is.na(final.dataframe$pct_of_BMR)) == 2L)

## ---- table checks (HOWTO section 7a) ------------------------------------------

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

get <- function(k, i) snap[rows[i], 1 + k]
table_checks <- do.call(rbind, lapply(1:5, function(k) {
  d1 <- max(dec_en(get(k, 1:5)))
  s1 <- num_en(get(k, 1:4)); tot1 <- num_en(get(k, 5)); mus <- num_en(get(k, 6)); tot2 <- num_en(get(k, 7))
  chk_rows <- list(
    chk(paste0("subtotal1_", gsub(" ", "", refs[k])), paste0(refs[k], ": liver + brain + heart + kidney vs printed Subtotal 1"),
        sum(s1), tot1, 4 * 0.5 * 10^(-d1), "four summed cells, half unit of the last printed decimal each"),
    chk(paste0("subtotal2_", gsub(" ", "", refs[k])), paste0(refs[k], ": printed Subtotal 1 + muscle vs printed Subtotal 2"),
        if (is.na(mus)) NA_real_ else tot1 + mus, tot2, 2 * 0.5 * 10^(-d1),
        if (is.na(mus)) "muscle and Subtotal 2 printed blank: not evaluable" else "two summed cells, half unit each"))
  do.call(rbind, chk_rows)
}))
report_checks(table_checks)

## ---- outputs ----------------------------------------------------------------
utils::write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived the way the registry formula builds it from
## column C (no DOI exists for this publication: chapter in a Ross Laboratories conference report, pp. 88-92): alt code with ":" and
## "/" percent-encoded, "_", item locus. The registry stays the authority.
alt_code <- "AssessEnergyMetab:1980:88-92"
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(utils::URLencode(alt_code, reserved = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  utils::write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
