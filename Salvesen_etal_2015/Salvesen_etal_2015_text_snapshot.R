# Salvesen_etal_2015_text_snapshot.R: split from Salvesen_etal_2015_extract_snapshot.R (one script per output); writes only Salvesen_etal_2015_text_snapshot.*
## Salvesen_etal_2015_text_snapshot.R -- PDF text layer -> the three frozen snapshots
##
## Salvesen L, Ullerup BH, Sunay FB, Brudek T, Lokkegaard A, Agander TK, Winge K,
## Pakkenberg B (2015). Changes in total cell numbers of the basal ganglia in patients
## with multiple system atrophy - a stereological study. Neurobiol Dis 74:104-113.
## doi:10.1016/j.nbd.2014.11.008
##
## Source -> snapshot step (snapshot HOWTO method 3, the Jacob_etal_2021 pattern):
## every DATA value is EXTRACTED from the born-digital PDF's text layer at run time.
## No value is typed in this script; only structural literals (captions, printed
## headers, footnote lines) live here, and each is anchored against the text layer.
##
## Writes (frozen; the build scripts READ these and never regenerate them):
##   Salvesen_etal_2015_Table4_snapshot.xlsx  (sheet "Table4", 50 rows x 8 cols)
##   Salvesen_etal_2015_Table1_snapshot.xlsx  (sheet "Table1", 13 rows x 7 cols)
##   Salvesen_etal_2015_text_snapshot.csv     (constructed: Results-text volumes)
##
## Frozen-file guard: if a snapshot exists and the extraction differs, the new
## capture is written to *_snapshot_NEW.<ext> and the run stops.
##
## Text-layer quirks repaired (each verified on the 300-dpi page image, PDF p. 5):
##   - the superscript exponent is flattened ("0.9 x 106"): restored as 10^6 / 10^3
##     using Unicode superscripts (10\u2076, 10\u00b3);
##   - the printed "<" before p-values renders as "b" ("b0.001*"): restored to "<";
##   - "Density/mm3": superscript restored ("Density/mm\u00b3");
##   - ligatures (fi, fl, ffi) expanded; superscript footnote letters written "^a".

## 0. PATHS --------------------------------------------------------------------
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
paper  <- "Salvesen_etal_2015"
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))  # = item name (this script is <Item>_snapshot.R)
pdf_file <- "Salvesen-2015-Changes in total cell numbers of.pdf"
if (!file.exists(pdf_file)) stop("Source PDF not found: ", pdf_file, call. = FALSE)
for (p in c("pdftools", "openxlsx", "readxl"))
  if (!requireNamespace(p, quietly = TRUE)) stop("Install ", p, call. = FALSE)

## 1. TEXT LAYER ---------------------------------------------------------------
pages <- pdftools::pdf_text(pdf_file)
stopifnot(length(pages) == 10L)
unlig  <- function(x) { x <- gsub("\ufb01", "fi", x); x <- gsub("\ufb02", "fl", x); gsub("\ufb03", "ffi", x) }
pages  <- unlig(pages)
squish <- function(x) trimws(gsub("[[:space:]]+", " ", paste(x, collapse = " ")))
lines_of <- function(pg) strsplit(pages[pg], "\n", fixed = TRUE)[[1]]
anchor <- function(x, where) if (!any(grepl(x, where, fixed = TRUE)))
  stop("PDF anchor not found: ", x, call. = FALSE)
X <- "\u00d7"; SUP <- c("3" = "\u00b3", "6" = "\u2076")
times10 <- function(mant, ex) paste0(mant, " ", X, " 10", SUP[ex])

## frozen-file guard ------------------------------------------------------------
freeze_xlsx <- function(m, file, sheet) {
  m[is.na(m)] <- ""
  if (file.exists(file)) {
    old <- as.matrix(readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                                        col_types = "text", .name_repair = "minimal"))
    old[is.na(old)] <- ""; dimnames(old) <- NULL
    new <- m; dimnames(new) <- NULL
    # readxl drops trailing all-blank rows/cols; compare on the stored extent
    same <- nrow(old) <= nrow(new) && ncol(old) <= ncol(new) &&
      identical(old, new[seq_len(nrow(old)), seq_len(ncol(old)), drop = FALSE]) &&
      all(new[-seq_len(nrow(old)), , drop = FALSE] == "")
    if (same) { message(basename(file), ": frozen copy matches the extraction (unchanged)"); return(invisible(FALSE)) }
    alt <- sub("\\.xlsx$", "_NEW.xlsx", file)
    wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, as.data.frame(m, stringsAsFactors = FALSE), colNames = FALSE)
    openxlsx::saveWorkbook(wb, alt, overwrite = TRUE)
    stop(basename(file), " differs from the new extraction; wrote ", basename(alt),
         ". Compare by hand; the frozen copy was NOT changed.", call. = FALSE)
  }
  wb <- openxlsx::createWorkbook(); openxlsx::addWorksheet(wb, sheet)
  openxlsx::writeData(wb, sheet, as.data.frame(m, stringsAsFactors = FALSE), colNames = FALSE)
  openxlsx::setColWidths(wb, sheet, cols = seq_len(ncol(m)), widths = "auto")
  openxlsx::saveWorkbook(wb, file, overwrite = FALSE)
  message(basename(file), ": frozen snapshot written (", nrow(m), " x ", ncol(m), ")")
  invisible(TRUE)
}
freeze_csv <- function(df, file) {
  tmp <- tempfile(fileext = ".csv")
  write.csv(df, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  if (file.exists(file)) {
    if (identical(readLines(file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
      message(basename(file), ": frozen copy matches the extraction (unchanged)"); return(invisible(FALSE)) }
    alt <- sub("\\.csv$", "_NEW.csv", file); file.copy(tmp, alt, overwrite = TRUE)
    stop(basename(file), " differs from the new extraction; wrote ", basename(alt),
         ". Compare by hand; the frozen copy was NOT changed.", call. = FALSE)
  }
  file.copy(tmp, file); message(basename(file), ": frozen snapshot written (", nrow(df), " rows)")
  invisible(TRUE)
}

## 4. RESULTS-TEXT VOLUMES (constructed snapshot; PDF pp. 6-7 = journal pp. 109-110)
split_columns <- function(page) {               # two-column reading order (Jacob pattern)
  lines <- strsplit(page, "\n", fixed = TRUE)[[1]]
  best_pos <- NA_integer_; best_frac <- 0
  for (pos in 50:110) {
    cand <- lines[nchar(lines) > pos + 5]
    if (length(cand) < 10) next
    frac <- mean(substr(cand, pos + 1, pos + 1) == " ")
    if (frac > best_frac) { best_pos <- pos; best_frac <- frac }
  }
  if (is.na(best_pos) || best_frac < 0.85) return(paste(lines, collapse = " "))
  paste(paste(substr(lines, 1, best_pos), collapse = " "),
        paste(substring(lines, best_pos + 1), collapse = " "))
}
PG <- vapply(pages, function(p) squish(split_columns(p)), character(1))
VOL <- paste0("The overall mean volumes? of the (putamen|caudate nucleus|globus pallidus|",
              "subthalamic nucleus|red nucleus) (?:was|were) (=? ?)([0-9.]+) ?(cm|mm) ?3 ",
              "\\(range = ([0-9.]+)\u2013([0-9.]+) ?(cm|mm) ?3 ?\\) in (?:the )?",
              "(control subjects|control brains) and ([0-9.]+) ?(cm|mm) ?3 ",
              "\\(range = ([0-9.]+)\u2013([0-9.]+) ?(cm|mm) ?3 ?\\) in the (MSA brains) ",
              "\\((paraffin-embedded tis(?:- )?sue)\\)\\.")
heading <- c(putamen = "Putamen", "caudate nucleus" = "Caudate nucleus",
             "globus pallidus" = "Globus pallidus", "subthalamic nucleus" = "Subthalamic nucleus",
             "red nucleus" = "Red nucleus")
rows_t <- list(); k <- 0L
for (pg in seq_along(PG)) {
  mm <- gregexpr(VOL, PG[pg], perl = TRUE)[[1]]
  if (mm[1] < 0) next
  for (st in as.integer(mm)) {
    tail_txt <- substr(PG[pg], st, st + 900)
    m <- regmatches(tail_txt, regexec(VOL, tail_txt, perl = TRUE))[[1]]
    sentence <- m[1]
    after <- substr(tail_txt, nchar(sentence) + 2, nchar(tail_txt))
    # the comparison sentence(s) up to and including the first "(p = x)."
    cmp <- regmatches(after, regexec("^(.*?\\(p = ([0-9.]+)\\)\\.)", after, perl = TRUE))[[1]]
    stopifnot(length(cmp) == 3L)
    for (g in 1:2) {
      k <- k + 1L
      ## m[2] region, m[3] "=", m[4:8] control mean/unit/lo/hi/unit, m[9] control phrase,
      ## m[10:14] MSA mean/unit/lo/hi/unit, m[15] "MSA brains", m[16] tissue qualifier
      idx <- if (g == 1) 4:8 else 10:14
      rows_t[[k]] <- data.frame(
        text_row = k, pdf_page = pg, journal_page = 103 + pg,
        results_subsection = heading[[m[2]]],
        region_as_printed = m[2],
        group_as_printed = if (g == 1) m[9] else m[15],
        mean_as_printed = paste0(if (g == 1) gsub(" ", "", m[3]) else "", m[idx[1]]),
        mean_unit_as_printed = paste0(m[idx[2]], "\u00b3"),
        range_as_printed = paste0(m[idx[3]], "\u2013", m[idx[4]], " ", m[idx[5]], "\u00b3"),
        qualifier_as_printed = gsub("tis- sue", "tissue", m[16], fixed = TRUE),
        p_value_as_printed = cmp[3],
        comparison_text_as_printed = trimws(cmp[2]),
        volume_sentence_as_printed = sentence,
        stringsAsFactors = FALSE)
    }
  }
}
snapT <- do.call(rbind, rows_t)
stopifnot(nrow(snapT) == 10L, setequal(snapT$region_as_printed, names(heading)))
freeze_csv(snapT, paste0(item_name, "_snapshot.csv"))
