# MacLean_etal_2014_TableS1_internal_check.R ---------------------------------------------------
#
# Cross-item internal check (build HOWTO 7b) for MacLean et al. (2014), PNAS 111:E2140-E2148,
# supplementary Table S1. R port of the part of compare_sources.py that reads the sibling
# resources of this item (the SI reference list, SIText_extracted.txt, and the analysis CSV
# of Table S1 itself, MacLean_etal_2014_TableS1.csv, as the Python script did).
#
# What it does
#   1. Parses the SI reference list (numbered 1..31, up to the line "Fig. S1.") from
#      MacLean_etal_2014_SIText_extracted.txt.
#   2. Resolves every source number cited in the column `source_numbers_as_published` of MacLean_etal_2014_TableS1.csv
#      to that list (one link per cited number).
#   3. Writes the check table MacLean_etal_2014_TableS1_internal_check.csv (columns as table_checks, 7a):
#      the SI list is complete (31 entries numbered consecutively) and every cited
#      number resolves. A cited number that does not resolve is a mismatch: warned and
#      kept as printed (blank citation in the links file), never repaired.
#   4. Also writes the three provenance files the Python script produced for this table:
#      MacLean_etal_2014_SIReferences.csv, MacLean_etal_2014_TableS1_source_links.csv and
#      MacLean_etal_2014_S1_vs_ECV_merge.csv (S1 ECV against the repository ECV merge,
#      __merging_endocranial_volume/endocranial_volume_long.csv, exact printed binomial).
#      The comparison with the ECV merge is a comparison with another dataset, not a check
#      of the paper against itself; it is kept here because compare_sources.py did it.
#
# Read-only for the item: it never writes a snapshot, an analysis CSV or a TSV, and never
# changes a value. Everything it writes goes to this folder (<Paper>/internal_checks/).
# The item script MacLean_etal_2014_TableS1.R reads only its own snapshot.
#
# Python parity: the outputs are byte-identical to the files the Python script
# compare_sources.py left in the paper folder (UTF-8, CRLF, minimal quoting as
# Python's csv.DictWriter). The extraction of the main-paper reference list from the
# PDF (MacLean_etal_2014_MainPaperReferences.csv) is NOT ported: pypdf's text layout
# (e.g. "Sex . (D.") cannot be reproduced by an R PDF reader byte for byte, so that step
# stays in compare_sources.py and is flagged for the owner.

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
folder    <- dirname(.sp); setwd(folder)                       # <Paper>/internal_checks
item_name <- sub("_internal_check\\.R$", "", basename(.sp))
paper_dir <- dirname(folder)                                    # resources live in the paper folder
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Repository root (__ReadMe.xlsx) not found above ", folder, call. = FALSE)
paper <- basename(paper_dir)

## ---- helpers --------------------------------------------------------------------
py_strip <- function(x) gsub("^[[:space:]]+|[[:space:]]+$", "", x)          # str.strip()
## csv.DictWriter: UTF-8, CRLF, a field is quoted only if it holds a comma, quote or line break
csv_field <- function(x) {
  x <- as.character(x); x[is.na(x)] <- ""
  q <- grepl("[,\"\r\n]", x)
  x[q] <- paste0("\"", gsub("\"", "\"\"", x[q], fixed = TRUE), "\"")
  x
}
write_py_csv <- function(df, file) {
  m <- rbind(names(df), do.call(cbind, lapply(df, as.character)))
  txt <- paste0(apply(m, 1, function(r) paste(csv_field(r), collapse = ",")), "\r\n", collapse = "")
  writeBin(charToRaw(enc2utf8(txt)), file)
}
read_py_csv <- function(file) read.csv(file, colClasses = "character", na.strings = NULL,
                                       check.names = FALSE, encoding = "UTF-8", fileEncoding = "UTF-8")
tc_row <- function(check_id, basis, observed, printed, tolerance, note = "") {
  d <- observed - printed
  data.frame(check_id = check_id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = tolerance,
             status = ifelse(is.na(d), "not_evaluable", ifelse(abs(d) <= tolerance, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

## ---- 1. the SI reference list (from the extracted SI text) -----------------------
si_lines <- readLines(file.path(paper_dir, "MacLean_etal_2014_SIText_extracted.txt"),
                      encoding = "UTF-8", warn = FALSE)
si_n <- integer(0); si_cit <- character(0)
for (line in si_lines) {
  if (startsWith(line, "Fig. S1.")) break
  m <- regmatches(line, regexec("^([0-9]{1,2})\\.[[:space:]]+(.+)", line))[[1]]
  if (length(m) && as.integer(m[2]) == length(si_n) + 1L) {
    si_n <- c(si_n, as.integer(m[2])); si_cit <- c(si_cit, m[3])
  } else if (length(si_n) && nzchar(py_strip(line)) && !startsWith(line, "MacLean et al. www.pnas.org")) {
    si_cit[length(si_cit)] <- paste0(si_cit[length(si_cit)], " ", py_strip(line))
  }
}
si_refs <- data.frame(reference_number = si_n, citation_as_extracted = si_cit,
                      stringsAsFactors = FALSE)
si_lookup <- setNames(si_cit, as.character(si_n))

## ---- 2. cited source numbers of this item -> SI citations ------------------------
rows <- read_py_csv(file.path(paper_dir, paste0(item_name, ".csv")))
links <- list()
for (i in seq_len(nrow(rows))) {
  for (number in py_strip(strsplit(rows[["source_numbers_as_published"]][i], ",", fixed = TRUE)[[1]])) {
    if (!nzchar(number)) next
    cit <- unname(si_lookup[number])
    links[[length(links) + 1L]] <- data.frame(
      table = "S1", source_row = rows$source_row[i],
      species_as_published = rows$species_as_published[i],
      si_reference_number = number, si_citation_as_extracted = if (is.na(cit)) "" else cit,
      stringsAsFactors = FALSE)
  }
}
links <- do.call(rbind, links)
n_cited <- length(unique(links$si_reference_number))
n_unresolved <- length(unique(links$si_reference_number[!links$si_reference_number %in% names(si_lookup)]))


## ---- 3. S1 ECV against the repository ECV merge (comparison, not a check) -----------
merge <- read_py_csv(file.path(base, "__merging_endocranial_volume", "endocranial_volume_long.csv"))
merge <- merge[merge$measure_class == "endocranial_volume", ]
merge <- merge[!duplicated(merge$Species, fromLast = TRUE), ]       # dict comprehension: last row wins
by_species <- merge[match(rows$species_as_published, merge$Species), ]
hit <- !is.na(by_species$Species)
maclean <- as.numeric(rows$ecv_cc)
merged  <- ifelse(hit, as.numeric(by_species$Value), NA_real_)
## Python float repr: shortest string that round-trips, ".0" kept for whole numbers
py_repr <- function(x) vapply(x, function(v) {
  if (is.na(v)) return("")
  for (d in 1:17) { s <- sprintf(paste0("%.", d, "g"), v); if (as.numeric(s) == v) break }
  if (!grepl("[.e]", s)) s <- paste0(s, ".0")
  s
}, character(1))
comparison <- data.frame(
  species_as_published = rows$species_as_published,
  maclean_ecv_cc = rows$ecv_cc,
  merge_species_exact_match = ifelse(hit, "True", "False"),
  merge_ecv_ml = ifelse(hit, by_species$Value, ""),
  merge_teams = ifelse(hit, by_species$Teams, ""),
  difference_maclean_minus_merge_ml = py_repr(round(maclean - merged, 6)),
  maclean_source_numbers_unresolved = rows$source_numbers_as_published,
  stringsAsFactors = FALSE)

## ---- check table (same columns as table_checks, 7a) --------------------------------
table_checks <- rbind(
  tc_row("si_reference_list_complete",
         "SI reference list parsed from MacLean_etal_2014_SIText_extracted.txt: entries parsed vs the 31 numbered entries printed",
         length(si_n), 31, 0,
         "numbers must run consecutively from 1 up to the line 'Fig. S1.'; cross-resource: reads the SI text"),
  tc_row("source_numbers_resolve",
         paste0("distinct source numbers cited in column source_numbers_as_published of ", item_name,
                ".csv that resolve to an SI reference vs distinct numbers cited"),
         n_cited - n_unresolved, n_cited, 0,
         paste0("cross-item: reads ", item_name, ".csv (sibling analysis CSV) and the SI text; ",
                nrow(links), " links written")))

## ---- output: this check's own CSV and the provenance files it derives ---------------
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
write.csv(table_checks, paste0(item_name, "_internal_check.csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
write_py_csv(si_refs, "MacLean_etal_2014_SIReferences.csv")
write_py_csv(links, paste0(item_name, "_source_links.csv"))
write_py_csv(comparison, "MacLean_etal_2014_S1_vs_ECV_merge.csv")
message(item_name, ": ", nrow(table_checks), " checks written to ", item_name, "_internal_check.csv")
