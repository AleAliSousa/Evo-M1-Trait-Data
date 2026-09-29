## render_errata.R — validate a paper's errata file and regenerate its three
## renderings (README block, definitions notes; merges read the file directly).
## See ERRATA_CONVENTION.md. Base R only; sourced by load_dataset_builder.R.
##
##   check_errata_file(errata_file)            -> character(0) if valid, else the problems
##   read_errata(errata_file)                  -> data.frame (validated) or NULL when absent
##   render_errata(paper_dir, dry_run = FALSE) -> invisible(list(readme = ..., definitions = ...))
##   find_errata_files(root)                   -> all <Paper>/reference_tables/<Paper>_errata.csv

ERRATA_COLUMNS <- c("errata_id", "item", "variable", "locator", "printed_value", "repo_value_before",
                    "issue_type", "proposed_value", "evidence", "status", "status_reason",
                    "raised_by", "date_raised", "date_resolved", "note")
ERRATA_REQUIRED <- c("errata_id", "item", "variable", "locator", "printed_value", "issue_type",
                     "evidence", "status", "raised_by", "date_raised")
ERRATA_ISSUE_TYPES <- c("repo_transcription_error", "publication_error", "publication_ambiguity",
                        "cross_source_disagreement", "unresolved_discrepancy")
ERRATA_STATUSES <- c("proposed", "confirmed", "withdrawn")
ERRATA_BEGIN <- "<!-- errata:begin -->"
ERRATA_END   <- "<!-- errata:end -->"

errata_file_for <- function(paper_dir) {
  paper <- basename(normalizePath(paper_dir, mustWork = FALSE))
  file.path(paper_dir, "reference_tables", paste0(paper, "_errata.csv"))
}

errata_template <- function(paper) {
  df <- as.data.frame(setNames(replicate(length(ERRATA_COLUMNS), character(0), simplify = FALSE), ERRATA_COLUMNS),
                      stringsAsFactors = FALSE)
  attr(df, "paper") <- paper
  df
}

## locale-independent UTF-8 read (Rscript under a C locale rejects non-ASCII via fileEncoding)
.read_errata_csv <- function(errata_file) {
  raw <- readLines(errata_file, encoding = "UTF-8", warn = FALSE)
  raw[1] <- sub("^\ufeff", "", raw[1])
  read.csv(text = raw, stringsAsFactors = FALSE, check.names = FALSE, na.strings = character(),
           colClasses = "character", encoding = "UTF-8")
}

## --- CSV record helpers (base R only) -----------------------------------------
## Group physical lines into logical records (a quoted field may span lines).
.csv_records <- function(lines) {
  recs <- list(); buf <- character(); open <- FALSE
  for (ln in lines) {
    buf <- c(buf, ln)
    nq <- lengths(regmatches(ln, gregexpr('"', ln, fixed = TRUE)))
    if (nq %% 2 == 1) open <- !open
    if (!open) { recs[[length(recs) + 1]] <- buf; buf <- character() }
  }
  if (length(buf)) recs[[length(recs) + 1]] <- buf
  recs
}
## Fields of one record (character), no NA coercion, no row-name inference.
.csv_fields <- function(rec) {
  as.character(unlist(read.csv(text = paste(rec, collapse = "\n"), header = FALSE, stringsAsFactors = FALSE,
                               colClasses = "character", na.strings = character(), encoding = "UTF-8")[1, ]))
}
## readr/pandas-style minimal quoting: only fields holding a comma, a quote,
## a newline or an outer space are quoted.
.min_quote_csv_record <- function(x) {
  x <- ifelse(is.na(x), "", x); need <- grepl('[",\n\r]|^ | $', x)
  x[need] <- paste0('"', gsub('"', '""', x[need], fixed = TRUE), '"')
  paste(x, collapse = ",")
}

## Filesystem names arrive as bytes of unknown encoding under a C locale; declare
## them UTF-8 (macOS/Linux paths are UTF-8) so they compare equal to CSV text.
.utf8 <- function(x) { Encoding(x) <- "UTF-8"; x }

## Unicode-normalisation-insensitive name comparison (macOS stores folder names
## in NFD; CSV text is usually NFC): compare everything in NFD.
.nfd <- function(x) { y <- iconv(x, "UTF-8", "UTF-8-MAC"); ifelse(is.na(y), x, y) }

check_errata_file <- function(errata_file) {
  problems <- character()
  if (!file.exists(errata_file)) return(paste0("errata file not found: ", errata_file))
  paper <- .utf8(sub("_errata\\.csv$", "", basename(errata_file)))
  e <- tryCatch(.read_errata_csv(errata_file), error = function(err) NULL)
  if (is.null(e)) return(paste0("errata file unreadable: ", errata_file))
  names(e) <- sub("^\ufeff", "", names(e))
  miss <- setdiff(ERRATA_COLUMNS, names(e))
  if (length(miss)) problems <- c(problems, paste0("missing column(s): ", paste(miss, collapse = ", ")))
  extra <- setdiff(names(e), ERRATA_COLUMNS)
  if (length(extra)) problems <- c(problems, paste0("unexpected column(s): ", paste(extra, collapse = ", ")))
  if (length(problems)) return(problems)
  if (!nrow(e)) return(character(0))
  for (col in ERRATA_REQUIRED) {
    bad <- which(!nzchar(trimws(e[[col]])))
    if (length(bad)) problems <- c(problems, sprintf("blank %s in row(s) %s", col, paste(bad, collapse = ",")))
  }
  ## prefix test by startsWith (a regex built from an accented paper name fails under a C locale)
  pre <- paste0(paper, "-E")
  id_ok <- startsWith(e$errata_id, pre) & grepl("^[0-9]{3,}$", substring(e$errata_id, nchar(pre) + 1))
  if (any(!id_ok)) problems <- c(problems, paste0("errata_id not of the form ", paper, "-E001: ", paste(e$errata_id[!id_ok], collapse = ", ")))
  if (anyDuplicated(e$errata_id)) problems <- c(problems, paste0("duplicated errata_id: ", paste(unique(e$errata_id[duplicated(e$errata_id)]), collapse = ", ")))
  bad <- !e$issue_type %in% ERRATA_ISSUE_TYPES
  if (any(bad)) problems <- c(problems, paste0("unknown issue_type: ", paste(unique(e$issue_type[bad]), collapse = ", ")))
  bad <- !e$status %in% ERRATA_STATUSES
  if (any(bad)) problems <- c(problems, paste0("unknown status: ", paste(unique(e$status[bad]), collapse = ", ")))
  wd <- e$status == "withdrawn" & !nzchar(trimws(e$status_reason))
  if (any(wd)) problems <- c(problems, paste0("withdrawn without status_reason: ", paste(e$errata_id[wd], collapse = ", ")))
  rs <- e$status != "proposed" & !nzchar(trimws(e$date_resolved))
  if (any(rs)) problems <- c(problems, paste0("status left 'proposed' but date_resolved blank: ", paste(e$errata_id[rs], collapse = ", ")))
  for (col in c("date_raised", "date_resolved")) {
    v <- e[[col]]; bad <- nzchar(v) & !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", v)
    if (any(bad)) problems <- c(problems, sprintf("%s not ISO (YYYY-MM-DD): %s", col, paste(v[bad], collapse = ", ")))
  }
  bad <- !startsWith(e$item, paper)
  if (any(bad)) problems <- c(problems, paste0("item does not start with the paper id: ", paste(unique(e$item[bad]), collapse = ", ")))
  problems
}

read_errata <- function(errata_file) {
  if (!file.exists(errata_file)) return(NULL)
  problems <- check_errata_file(errata_file)
  if (length(problems)) stop("invalid errata file ", errata_file, ":\n  ", paste(problems, collapse = "\n  "), call. = FALSE)
  e <- .read_errata_csv(errata_file)
  names(e) <- sub("^\ufeff", "", names(e))
  e
}

find_errata_files <- function(root) {
  f <- list.files(root, pattern = "_errata\\.csv$", recursive = TRUE, full.names = TRUE)
  f[basename(dirname(f)) == "reference_tables" &
      sub("_errata\\.csv$", "", basename(f)) == basename(dirname(dirname(f)))]
}

.md_escape <- function(x) gsub("\\|", "\\\\|", gsub("\n", " ", x))
.strike <- function(x) ifelse(nzchar(x), paste0("~~", x, "~~"), x)

## ---- rendering 1: README block ---------------------------------------------
.errata_block <- function(e, paper) {
  hdr <- c(ERRATA_BEGIN,
           "## Errata",
           "",
           sprintf("Generated from `reference_tables/%s_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.", paper),
           "")
  if (!nrow(e)) return(c(hdr, "_No errata recorded for this item._", ERRATA_END))
  e <- e[order(e$errata_id), ]
  rows <- vapply(seq_len(nrow(e)), function(i) {
    r <- e[i, ]
    cells <- c(r$errata_id, r$variable, r$locator, r$printed_value, r$repo_value_before, r$issue_type,
               r$proposed_value, r$status, r$evidence,
               if (r$status == "withdrawn") paste0("WITHDRAWN: ", r$status_reason) else r$note)
    cells <- .md_escape(cells)
    if (r$status == "withdrawn") cells[c(2:7, 9)] <- .strike(cells[c(2:7, 9)])
    paste0("| ", paste(cells, collapse = " | "), " |")
  }, "")
  c(hdr,
    "| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |",
    "|---|---|---|---|---|---|---|---|---|---|",
    rows,
    "",
    sprintf("%d recorded, %d open (proposed), %d confirmed, %d withdrawn.", nrow(e),
            sum(e$status == "proposed"), sum(e$status == "confirmed"), sum(e$status == "withdrawn")),
    ERRATA_END)
}

.replace_block <- function(lines, block) {
  b <- which(lines == ERRATA_BEGIN); en <- which(lines == ERRATA_END)
  if (length(b) == 1L && length(en) == 1L && en > b) {
    c(lines[seq_len(b - 1L)], block, if (en < length(lines)) lines[(en + 1L):length(lines)])
  } else if (!length(b) && !length(en)) {
    c(lines, "", block)
  } else stop("README has unbalanced errata markers", call. = FALSE)
}

## ---- rendering 2: definitions note prefix -----------------------------------
.errata_prefix <- function(rows) {
  rows <- rows[rows$status != "withdrawn", , drop = FALSE]
  if (!nrow(rows)) return("")
  paste0(vapply(seq_len(nrow(rows)), function(i) {
    r <- rows[i, ]
    sprintf("ERRATA %s (%s, %s): printed %s, repo had %s%s | ", r$errata_id, r$status, r$issue_type,
            r$printed_value, if (nzchar(r$repo_value_before)) r$repo_value_before else "blank",
            if (nzchar(r$proposed_value)) paste0(", proposed ", r$proposed_value) else "")
  }, ""), collapse = "")
}
.strip_prefix <- function(x) gsub("ERRATA [^ ]+ \\([^)]*\\): [^|]*\\| ", "", x)

render_errata <- function(paper_dir, dry_run = FALSE, quiet = FALSE) {
  paper_dir <- normalizePath(paper_dir, mustWork = TRUE)
  paper <- .utf8(basename(paper_dir))
  ef <- errata_file_for(paper_dir)
  e <- read_errata(ef)
  if (is.null(e)) { if (!quiet) message("render_errata: no errata file for ", paper, " -- nothing to render"); return(invisible(NULL)) }
  touched <- list(readme = character(), definitions = character())
  items <- unique(e$item)
  ## README per item (<Paper>_<Item>.README.md; some folders use the older
  ## <Paper>_<Item>.md form), falling back to <Paper>.README.md
  readmes <- list.files(paper_dir, pattern = "\\.md$", full.names = TRUE)
  for (it in items) {
    bn <- .nfd(basename(readmes))
    cand <- readmes[bn == .nfd(paste0(it, ".README.md"))]
    if (!length(cand)) cand <- readmes[bn == .nfd(paste0(it, ".md"))]
    if (!length(cand)) cand <- readmes[bn == .nfd(paste0(paper, ".README.md"))]
    if (!length(cand)) { warning("no README found for item ", it, " in ", paper); next }
    lines <- readLines(cand[1], encoding = "UTF-8", warn = FALSE)
    new <- .replace_block(lines, .errata_block(e[e$item == it, , drop = FALSE], paper))
    if (!identical(new, lines)) {
      if (!dry_run) writeLines(enc2utf8(new), cand[1], useBytes = TRUE)
      touched$readme <- c(touched$readme, cand[1])
    }
  }
  ## definitions per item: prefix the note column of each affected variable.
  ## Record-level edit: only the CSV records whose variable carries an erratum
  ## (or whose note already carries a stale ERRATA prefix) are re-serialised;
  ## every other line is left byte-identical. A whole-file read.csv/write.csv
  ## round-trip is NOT safe here -- some hand-written definitions files carry
  ## ragged rows (unquoted commas), and read.csv silently promoted the first
  ## column to row names on such a file (DeCasien_Higham_2019, 2026-09-29,
  ## restored from git).
  for (it in items) {
    df <- file.path(paper_dir, "reference_tables", paste0(it, "_definitions.csv"))
    if (!file.exists(df)) { warning("no definitions file for item ", it); next }
    raw <- readLines(df, encoding = "UTF-8", warn = FALSE)
    bom <- startsWith(raw[1], "\ufeff"); raw[1] <- sub("^\ufeff", "", raw[1])
    recs <- .csv_records(raw)                      # list of character vectors of physical lines
    hdr <- .csv_fields(recs[[1]])
    vidx <- match(c("variable", "Code", "field", "column"), hdr); vidx <- vidx[!is.na(vidx)][1]
    nidx <- match(c("notes", "Note", "note", "provenance"), hdr); nidx <- nidx[!is.na(nidx)][1]
    if (is.na(vidx) || is.na(nidx)) { warning("definitions file ", basename(df), " has no variable/note columns"); next }
    rows_it <- e[e$item == it, , drop = FALSE]
    wanted <- unique(rows_it$variable); seen <- character()
    out <- recs
    for (i in seq_along(recs)[-1]) {
      fld <- .csv_fields(recs[[i]])
      if (length(fld) < max(vidx, nidx)) next
      v <- fld[vidx]; note <- fld[nidx]
      stale <- grepl("^ERRATA ", note)
      applies <- v %in% wanted | "*" %in% wanted
      if (!stale && !applies) next
      if (length(fld) != length(hdr)) stop("definitions file ", basename(df), ": record for '", v, "' has ", length(fld), " fields but header has ", length(hdr), " -- fix the CSV before rendering errata", call. = FALSE)
      note <- .strip_prefix(note)
      if (applies) {
        sel <- if ("*" %in% wanted) rows_it else rows_it[rows_it$variable == v, , drop = FALSE]
        note <- paste0(.errata_prefix(sel), note); seen <- c(seen, v)
      }
      fld[nidx] <- note
      out[[i]] <- .min_quote_csv_record(fld)
    }
    missing <- setdiff(wanted[wanted != "*"], seen)
    for (v in missing) warning("errata variable '", v, "' not in ", basename(df))
    out <- unlist(out)
    if (bom) out[1] <- paste0("\ufeff", out[1])
    if (!identical(out, raw)) {
      if (!dry_run) writeLines(enc2utf8(out), df, useBytes = TRUE)
      touched$definitions <- c(touched$definitions, df)
    }
  }
  if (!quiet) message("render_errata(", paper, "): ", nrow(e), " errata; README files touched: ", length(touched$readme),
                      "; definitions files touched: ", length(touched$definitions), if (dry_run) " [dry run]" else "")
  invisible(touched)
}
