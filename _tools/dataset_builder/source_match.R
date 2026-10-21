# source_match.R -- preliminary source -> variable (-> species) match for secondary-data items
#
# Convention: _tools/dataset_builder/SOURCE_MATCH_CONVENTION.md
#
# Inputs  (all relative to one paper folder, <Item> = the item CSV name without .csv)
#   <Item>.csv                                        the analysis CSV (built item)
#   reference_tables/<Item>_references.csv            ref_key | cited_in_column | citation | note
#                                                     (legacy aliases accepted: ref, ref_number,
#                                                      source_number -> ref_key; full_reference,
#                                                      full_citation -> citation)
#   reference_tables/<Item>_reference_columns.csv     OPTIONAL declaration, curated by hand:
#                                                     key_column | applies_to | separator | note
#                                                     applies_to = "*" (every data column of the
#                                                     row) or a "; "-separated list of data columns
# Outputs (reference_tables/)
#   <Item>_source_match.csv            one row per (data row, variable, individual ref_key)
#   <Item>_source_match_summary.csv    one row per (ref_key, variable): n_species, species list
#   <Item>_source_match_issues.csv     everything the join could not settle (may be empty)
#   <Item>_reference_columns_proposed.csv   written only when no declaration exists: the
#                                           auto-detected key columns and their guessed scope,
#                                           to be reviewed, renamed to _reference_columns.csv
#                                           and edited. Never read back by this tool.
#
# Base R only (no packages) so every item build .R can source it.
#
# Usage
#   source(file.path(EVOM1_ROOT, "_tools/dataset_builder/source_match.R"))
#   build_source_match("<paper folder>", "<Item>")                 # one item
#   source_match_all(EVOM1_ROOT)                                   # every *_references.csv
#   source_match_all(EVOM1_ROOT, out_dir = "/tmp/sm", write_repo = FALSE)   # dry run

## ---------------------------------------------------------------- constants ----
SM_EMPTY_VALUES <- c("", "NA", "N/A", "n/a", "na", "-", "--", "\u2014", "\u2013", ".", "?")
SM_KEY_ALIASES  <- c("ref_key", "ref", "ref_number", "source_number", "Ref_number",
                     "short_reference", "ref_letter", "key")
SM_CIT_ALIASES  <- c("citation", "full_reference", "full_citation", "Citation", "reference",
                     "full")
# column names that are never data columns, whatever the definitions file says
SM_META_PATTERN <- paste0("(?i)^(species|species_.*|.*_species|taxon|order|family|subfamily|",
                          "genus|clade|suborder|class|common_name|common.name|row_id|source|",
                          "item|note|notes|data_role|snapshot_record|label_as_published|",
                          "species_as_published|full_reference|table_heading_citation|",
                          ".*_ref_short|source_note|provenance_class|observation_level|",
                          "source_printed_page|source_pdf_page|source_as_published|",
                          "footnote_markers|hold_reason|human_visual_curation|row_type|",
                          "source_.*|.*_data_role|extraction_note|value_origin|",
                          "unit_or_interpretation|result_as_printed)$")
SM_GENERIC_STEMS <- c("source", "sources", "ref", "refs", "reference", "references", "key", "keys",
                      "src", "cit", "citation", "citations", "data")
# candidate key columns, by name, when nothing is declared
SM_KEYCOL_PATTERN <- paste0("(?i)(^ref$|^refs$|^reference$|^references$|^reference_keys?$|",
                            "^source_ref_key$|ref_key$|_ref$|_refs$|^src_|^ref_|",
                            "_reference$|_references$|source_as_printed|^source_number$|^source$)")
SM_KEYCOL_EXCLUDE <- "(?i)full_reference|heading_citation|_ref_short$"

## ---------------------------------------------------------------- helpers ------
sm_read_csv <- function(path) {
  if (!file.exists(path)) stop("source_match: file not found: ", path, call. = FALSE)
  # read bytes as UTF-8 ourselves: independent of the session locale, tolerant of BOM and CRLF
  txt <- readLines(path, encoding = "UTF-8", warn = FALSE)
  txt <- sub("^\ufeff", "", txt); txt <- sub("\r$", "", txt)
  txt <- txt[seq_len(max(which(nzchar(txt)), 0L))]
  if (!length(txt)) stop("source_match: empty file: ", path, call. = FALSE)
  df <- read.csv(text = txt, check.names = FALSE, stringsAsFactors = FALSE, encoding = "UTF-8",
                 na.strings = character(0), colClasses = "character")
  names(df) <- enc2utf8(names(df))
  df
}

# UTF-8 with BOM so Excel on macOS renders diacritics (convention C6); verified on read-back
sm_write_csv <- function(df, path) {
  # serialise to text, then write BOM + UTF-8 bytes directly: independent of the session locale
  txt <- utils::capture.output(utils::write.csv(df, stdout(), row.names = FALSE, na = ""))
  txt <- enc2utf8(paste0(paste(txt, collapse = "\n"), "\n"))
  con <- file(path, open = "wb"); on.exit(close(con))
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeBin(charToRaw(txt), con)
  close(con); on.exit(NULL)
  b <- readBin(path, "raw", 3L)
  if (!identical(b, as.raw(c(0xEF, 0xBB, 0xBF))))
    stop("source_match: BOM missing after write: ", path, call. = FALSE)
  invisible(path)
}

sm_is_empty <- function(x) is.na(x) | trimws(x) %in% SM_EMPTY_VALUES

sm_norm <- function(x) tolower(gsub("[^a-z0-9]", "", tolower(enc2utf8(x))))

# which style are the printed keys?  numeric (24, 10a), letter (a, e), or author-year
sm_key_style <- function(keys) {
  k <- trimws(keys)
  if (all(grepl("^[0-9]+[a-z]?$", k)))  return("numeric")
  if (all(grepl("^[a-z]{1,2}$",  k)))   return("letter")
  "author_year"
}

# split one key cell into individual keys.  Returns list(keys=, residual=)
sm_parse_cell <- function(cell, style, known_keys, separator = NULL, known_citations = NULL) {
  if (sm_is_empty(cell)) return(list(keys = character(0), residual = ""))
  x <- gsub("[\\[\\]\\(\\)\\{\\}]", " ", cell, perl = TRUE)        # drop brackets
  x <- gsub("[\u2013\u2014]", "-", x)                                 # en/em dash -> hyphen
  if (!is.null(separator) && nzchar(separator)) {
    toks <- trimws(strsplit(x, separator, fixed = TRUE)[[1]])
    toks <- toks[nzchar(toks)]
    return(list(keys = toks, residual = ""))
  }
  # a cell may hold the citation text itself (Lyamin: "Mukhametov et al. (1988)" keyed as "a");
  # try the citations first, longest first, on a punctuation-free normalisation
  if (!is.null(known_citations) && style != "author_year") {
    nx <- sm_norm(x); hit <- character(0)
    ok <- which(!is.na(known_citations) & nchar(known_citations) >= 8)
    for (j in ok[order(-nchar(known_citations[ok]))]) {
      nc <- sm_norm(known_citations[j])
      if (nzchar(nc) && grepl(nc, nx, fixed = TRUE)) { hit <- c(hit, known_keys[j]); nx <- sub(nc, " ", nx, fixed = TRUE) }
    }
    if (length(hit)) return(list(keys = unique(hit), residual = trimws(gsub("(and|ref|refs|[0-9]{4})", " ", nx))))
  }
  if (style == "numeric") {
    m <- gregexpr("[0-9]+[a-z]?(\\s*-\\s*[0-9]+[a-z]?)?", x, perl = TRUE)
    toks <- regmatches(x, m)[[1]]
    keys <- character(0)
    for (t in toks) {
      if (grepl("-", t, fixed = TRUE)) {                              # expand a printed range (C2)
        ends <- trimws(strsplit(t, "-", fixed = TRUE)[[1]])
        if (all(grepl("^[0-9]+$", ends))) {
          a <- as.integer(ends[1]); b <- as.integer(ends[2])
          if (b >= a && (b - a) <= 100L) { keys <- c(keys, as.character(seq(a, b))); next }
        }
        keys <- c(keys, t)                                            # unexpandable: keep verbatim
      } else keys <- c(keys, t)
    }
    # Numeric keys may be zero-padded in data cells but unpadded in the reference
    # lookup (AnAge Source_ref 0450 vs BIBLIOID/ref_key 450). Preserve the printed
    # cell separately, but canonicalize an otherwise exact integer match here.
    if (length(keys)) {
      known_int <- suppressWarnings(as.integer(known_keys))
      keys <- vapply(keys, function(k) {
        if (!grepl("^[0-9]+$", k)) return(k)
        hit <- which(!is.na(known_int) & known_int == suppressWarnings(as.integer(k)))
        if (length(hit) == 1L) known_keys[hit] else k
      }, character(1))
    }
    resid <- regmatches(x, m, invert = TRUE)[[1]]
  } else if (style == "letter") {
    m <- gregexpr("[a-z]{1,2}", x, perl = TRUE)
    keys  <- regmatches(x, m)[[1]]
    resid <- regmatches(x, m, invert = TRUE)[[1]]
  } else {                                                            # author-year: dictionary match
    # match each known key as a punctuation-tolerant regex on the raw cell, longest key first
    keys <- character(0)
    for (k in known_keys[order(-nchar(known_keys))]) {
      rx <- sm_key_regex(k)
      if (nzchar(rx) && grepl(rx, x, perl = TRUE, ignore.case = TRUE)) {
        keys <- c(keys, k); x <- gsub(rx, " ", x, perl = TRUE, ignore.case = TRUE)
      }
    }
    # bare numbers left behind "refs. 43 and 44" -> "ref. 44" when such a key exists
    nums <- regmatches(x, gregexpr("(?<![A-Za-z0-9])[0-9]{1,3}(?![0-9])", x, perl = TRUE))[[1]]
    for (n in nums) {
      cand <- known_keys[sm_norm(known_keys) == paste0("ref", n) | sm_norm(known_keys) == paste0("refs", n)]
      if (length(cand)) { keys <- c(keys, cand[1]); x <- sub(paste0("(?<![A-Za-z0-9])", n, "(?![0-9])"), " ", x, perl = TRUE) }
    }
    # what is left: pieces (split on ";" and " and " only, never on "," or "&") that still look like a
    # citation -- a year, "unpublished", "pers. comm.", "in press", "this issue" -- are unknown keys;
    # anything else is residual text (a locator such as "Figure 3 caption")
    pieces <- trimws(strsplit(x, "\\s*(;|\\band\\b)\\s*", perl = TRUE)[[1]])
    pieces <- gsub("^[\\s,&]+|[\\s,&]+$", "", pieces, perl = TRUE)
    pieces <- pieces[nzchar(pieces)]
    looks_cit <- grepl("(?i)(\\b1[6-9][0-9]{2}\\b|\\b20[0-9]{2}\\b|unpubl|pers\\.? ?comm|in press|this issue|submitted)", pieces, perl = TRUE)
    keys  <- c(keys, pieces[looks_cit])
    resid <- pieces[!looks_cit]
  }
  resid <- paste(resid, collapse = " ")
  resid <- gsub("(?i)\\b(and|ref\\.?|refs\\.?|this study:?|see|text)\\b", " ", resid, perl = TRUE)
  resid <- trimws(gsub("[,;/&:\\s]+", " ", resid, perl = TRUE))
  list(keys = unique(keys), residual = resid)
}

# "Dunlop et al. (1998)" -> regex matching "Dunlop et al., 1998" / "Dunlop et al. 1998" too
sm_key_regex <- function(k) {
  parts <- regmatches(k, gregexpr("[A-Za-z0-9\u00C0-\u024F]+", k, perl = TRUE))[[1]]
  if (!length(parts)) return("")
  parts <- ifelse(tolower(parts) == "and", "(?:and)?", parts)   # "Illing and Wassle" == "Illing & Wassle"
  paste0("(?<![A-Za-z0-9])", paste(parts, collapse = "[^A-Za-z0-9]{0,12}"), "(?![A-Za-z0-9])")
}

# stem of a variable-specific key column: Depth_Ref -> depth, src_VA -> va
sm_key_stem <- function(col) {
  s <- sub("(?i)(_ref_key|_ref|_refs|_reference|_references|_source|_src|_citation)$", "", col, perl = TRUE)
  s <- sub("(?i)^(src_|ref_|source_|refs_)", "", s, perl = TRUE)
  if (identical(tolower(s), tolower(col)) || !nzchar(s)) return(NA_character_)
  if (tolower(s) %in% SM_GENERIC_STEMS || nchar(s) < 3L) return(NA_character_)
  tolower(s)
}

sm_species_column <- function(cols) {
  pref <- c("species", "Species", "species_sci", "Species_Name", "species_as_published",
            "Species_as_published", "taxon", "Taxon")
  hit <- pref[pref %in% cols]
  if (length(hit)) return(hit[1])
  hit <- grep("(?i)^species|^taxon_as_published$|^Species_", cols, value = TRUE, perl = TRUE)
  if (length(hit)) return(hit[1])
  NA_character_                                   # a results table without species rows
}

## ------------------------------------------------------ main: one item ----------
build_source_match <- function(paper_dir, item, refs_file = NULL, out_dir = NULL,
                               strict = FALSE, quiet = FALSE) {
  paper_dir <- normalizePath(paper_dir, mustWork = TRUE)
  paper     <- basename(paper_dir)
  ref_dir   <- file.path(paper_dir, "reference_tables")
  if (is.null(out_dir)) out_dir <- ref_dir
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
  say <- function(...) if (!quiet) message("[source_match] ", item, ": ", ...)

  ## -- inputs --------------------------------------------------------------
  item_csv <- file.path(paper_dir, paste0(item, ".csv"))
  dat <- sm_read_csv(item_csv)
  if (is.null(refs_file)) refs_file <- file.path(ref_dir, paste0(item, "_references.csv"))
  refs <- sm_read_csv(refs_file)

  kcol <- intersect(SM_KEY_ALIASES, names(refs))[1]
  ccol <- intersect(SM_CIT_ALIASES, names(refs))[1]
  if (is.na(kcol) || is.na(ccol))
    stop("source_match: ", basename(refs_file), " needs a key column (", paste(SM_KEY_ALIASES, collapse = "/"),
         ") and a citation column (", paste(SM_CIT_ALIASES, collapse = "/"), "); has: ",
         paste(names(refs), collapse = ", "), call. = FALSE)
  legacy_schema <- !(kcol == "ref_key" && ccol == "citation")
  refs$ref_key  <- trimws(refs[[kcol]]); refs$citation <- trimws(refs[[ccol]])
  refs <- refs[!sm_is_empty(refs$ref_key), , drop = FALSE]
  refs$citation[sm_is_empty(refs$citation)] <- NA_character_          # kept as keys, flagged below
  no_cit <- refs$ref_key[is.na(refs$citation)]
  dup <- unique(refs$ref_key[duplicated(refs$ref_key)])
  if (length(dup)) {                                                   # one row per key (C2)
    if (length(unique(refs$citation[refs$ref_key %in% dup])) > length(dup) || strict)
      stop("source_match: duplicated ref_key with differing citations in ", basename(refs_file),
           ": ", paste(dup, collapse = ", "), call. = FALSE)
    refs <- refs[!duplicated(refs$ref_key), , drop = FALSE]
  }
  if (any(grepl("^[0-9]+\\s*[-\u2013]\\s*[0-9]+$", refs$ref_key)))
    stop("source_match: unexpanded range in ref_key of ", basename(refs_file),
         " -- one row per individual reference number (C2)", call. = FALSE)
  style <- sm_key_style(refs$ref_key)
  if (!"cited_in_column" %in% names(refs)) refs$cited_in_column <- NA_character_

  ## -- data / meta columns --------------------------------------------------
  sp_col   <- sm_species_column(names(dat))
  if (is.na(sp_col)) { dat[[".species"]] <- NA_character_; sp_col <- ".species"; say("no species column; species = NA") }
  row_id   <- if ("Row_ID" %in% names(dat)) dat$Row_ID else sprintf("r%03d", seq_len(nrow(dat)))

  ## -- key columns: declared, else detected ----------------------------------
  decl_file <- file.path(ref_dir, paste0(item, "_reference_columns.csv"))
  declared  <- file.exists(decl_file)
  if (declared) {
    decl <- sm_read_csv(decl_file)
    need <- c("key_column", "applies_to")
    if (!all(need %in% names(decl)))
      stop("source_match: ", basename(decl_file), " needs columns ", paste(need, collapse = ", "), call. = FALSE)
    if (!"separator" %in% names(decl)) decl$separator <- ""
    if (!"note" %in% names(decl))      decl$note <- ""
    bad <- setdiff(decl$key_column, names(dat))
    if (length(bad)) stop("source_match: declared key_column not in ", basename(item_csv), ": ",
                          paste(bad, collapse = ", "), call. = FALSE)
    decl$basis <- "declared"
  } else {
    # 1) columns the references file names in cited_in_column (case-insensitive exact)
    cic <- unique(na.omit(trimws(unlist(strsplit(refs$cited_in_column, ";", fixed = TRUE)))))
    from_refs <- names(dat)[tolower(names(dat)) %in% tolower(cic)]
    # 2) columns whose name looks like a key
    from_name <- grep(SM_KEYCOL_PATTERN, names(dat), value = TRUE, perl = TRUE)
    keycols   <- unique(c(from_refs, from_name))
    keycols   <- keycols[!grepl(SM_KEYCOL_EXCLUDE, keycols, perl = TRUE)]
    # a column whose values are the item / paper name is provenance, not a key (Kaskan/Manger `source`)
    is_item_name <- vapply(keycols, function(k) {
      v <- unique(dat[[k]][!sm_is_empty(dat[[k]])])
      length(v) > 0 && all(startsWith(v, paper) | startsWith(v, item))
    }, logical(1))
    self_cited <- keycols[is_item_name]
    keycols <- keycols[!is_item_name]
    # a declared data column (cited_in_column naming a variable, Lyamin footnote e) is not a key column
    keycols <- keycols[!(keycols %in% from_refs & !grepl(SM_KEYCOL_PATTERN, keycols, perl = TRUE) &
                         vapply(keycols, function(k) all(grepl("^[-0-9.]+$", dat[[k]][!sm_is_empty(dat[[k]])])), logical(1)))]
    if (!length(keycols)) {
      sm_write_csv(data.frame(key_column = "", applies_to = "", separator = "",
                              note = "EDIT: no key column detected; name the column that holds the printed key, or delete this file if the keys live only in a caption",
                              basis = "none_detected", stringsAsFactors = FALSE),
                   file.path(out_dir, paste0(item, "_reference_columns_proposed.csv")))
      stop("DECLARE: no key column found in ", basename(item_csv),
           if (length(self_cited)) paste0(" (", paste(self_cited, collapse = ", "), " holds the item name: primary data citing itself)") else
           " (cited_in_column names none of its columns and no column name matches the key pattern)", ";",
           " edit reference_tables/", item, "_reference_columns_proposed.csv and rename it _reference_columns.csv",
           call. = FALSE)
    }
    decl <- data.frame(key_column = keycols, applies_to = NA_character_, separator = "",
                       note = "", basis = NA_character_, stringsAsFactors = FALSE)
  }
  meta_cols <- unique(c(sp_col, decl$key_column,
                        grep(SM_META_PATTERN, names(dat), value = TRUE, perl = TRUE)))
  data_cols <- setdiff(names(dat), meta_cols)
  if (!length(data_cols)) stop("source_match: no data columns left after removing key/meta columns in ",
                               basename(item_csv), call. = FALSE)

  # guess the scope of undeclared key columns
  if (!declared) {
    for (i in seq_len(nrow(decl))) {
      stem <- sm_key_stem(decl$key_column[i])
      hit  <- if (is.na(stem)) character(0) else
        data_cols[startsWith(tolower(data_cols), stem)]
      if (length(hit)) {
        decl$applies_to[i] <- paste(hit, collapse = "; "); decl$basis[i] <- "stem_match"
      } else if (nrow(decl) == 1L) {
        decl$applies_to[i] <- "*"; decl$basis[i] <- "row_level_default"
      } else {
        decl$applies_to[i] <- "unresolved"; decl$basis[i] <- "unresolved_key_scope"
      }
    }
    prop <- decl[, c("key_column", "applies_to", "separator", "note", "basis")]
    prop$note <- ifelse(prop$basis == "unresolved_key_scope",
                        "EDIT: list the data columns this key column attributes, or *", "")
    sm_write_csv(prop, file.path(out_dir, paste0(item, "_reference_columns_proposed.csv")))
  }

  ## -- the join -------------------------------------------------------------------
  cells  <- list(); issues <- list()
  add_issue <- function(type, key_column = "", ref_key = "", row = "", species = "", variable = "", detail = "") {
    one <- function(x) if (length(x)) as.character(x[1]) else ""
    issues[[length(issues) + 1L]] <<- data.frame(
      item = item, issue = one(type), key_column = one(key_column), ref_key = one(ref_key),
      row_id = one(row), species = one(species), variable = one(variable), detail = one(detail),
      stringsAsFactors = FALSE
    )
  }
  cited_keys <- character(0)
  for (i in seq_len(nrow(decl))) {
    kc    <- decl$key_column[i]; scope <- trimws(decl$applies_to[i]); basis <- decl$basis[i]
    sep   <- if (is.na(decl$separator[i])) "" else decl$separator[i]
    row_scope <- identical(scope, "row_overall")
    vars  <- if (identical(scope, "*")) data_cols else
             if (row_scope) "row_overall" else
             if (identical(scope, "unresolved")) character(0) else
             trimws(strsplit(scope, ";", fixed = TRUE)[[1]])
    badv  <- setdiff(vars, c(names(dat), "row_overall"))
    if (length(badv)) stop("source_match: applies_to names unknown columns for ", kc, ": ",
                           paste(badv, collapse = ", "), call. = FALSE)
    if (!length(vars)) { add_issue("unresolved_key_scope", kc, detail = "declare applies_to in _reference_columns.csv"); next }
    for (r in seq_len(nrow(dat))) {
      parsed <- sm_parse_cell(dat[[kc]][r], style, refs$ref_key, sep, refs$citation)
      keys   <- parsed$keys
      if (nzchar(parsed$residual))
        add_issue("residual_text_in_key_cell", kc, "", row_id[r], dat[[sp_col]][r], detail = parsed$residual)
      vals   <- if (row_scope) setNames(data.frame(row_id[r], stringsAsFactors = FALSE), "row_overall") else
                dat[r, vars, drop = FALSE]
      filled <- vars[!sm_is_empty(unlist(vals))]
      if (!length(keys)) {
        for (v in filled) add_issue("value_without_key", kc, "", row_id[r], dat[[sp_col]][r], v, dat[[v]][r])
        next
      }
      cited_keys <- c(cited_keys, keys)
      if (!length(filled)) {
        add_issue("key_without_values", kc, paste(keys, collapse = "|"), row_id[r], dat[[sp_col]][r])
        next
      }
      for (k in keys) {
        known <- k %in% refs$ref_key
        if (!known) add_issue("key_not_in_references", kc, k, row_id[r], dat[[sp_col]][r], detail = dat[[kc]][r])
        cells[[length(cells) + 1L]] <- data.frame(
          item = item, row_id = row_id[r], species = dat[[sp_col]][r], key_column = kc,
          key_cell_as_printed = dat[[kc]][r], n_keys_in_cell = length(keys), ref_key = k,
          citation = if (known) refs$citation[match(k, refs$ref_key)] else NA_character_,
          variable = filled, value = if (row_scope) rep("row_overall", length(filled)) else unlist(dat[r, filled]),
          match_basis = basis,
          status = if (!known) "key_not_in_references" else if (is.na(refs$citation[match(k, refs$ref_key)])) "matched_citation_missing" else
                   if (length(keys) > 1L) "matched_shared_key" else "matched",
          stringsAsFactors = FALSE, row.names = NULL)
      }
    }
  }
  long <- if (length(cells)) do.call(rbind, cells) else
    data.frame(item = character(), row_id = character(), species = character(), key_column = character(),
               key_cell_as_printed = character(), n_keys_in_cell = integer(), ref_key = character(),
               citation = character(), variable = character(), value = character(),
               match_basis = character(), status = character(), stringsAsFactors = FALSE)
  for (k in no_cit) add_issue("reference_without_citation", "", k, detail = if ("note" %in% names(refs)) refs$note[match(k, refs$ref_key)] else "")
  uncited <- setdiff(refs$ref_key, unique(cited_keys))
  for (k in uncited) add_issue("reference_never_cited", "", k, detail = refs$citation[match(k, refs$ref_key)])
  iss <- if (length(issues)) do.call(rbind, issues) else
    data.frame(item = character(), issue = character(), key_column = character(), ref_key = character(),
               row_id = character(), species = character(), variable = character(), detail = character(),
               stringsAsFactors = FALSE)

  ## -- summary: ref_key x variable --------------------------------------------------
  if (nrow(long)) {
    key <- paste(long$ref_key, long$variable, sep = "\r")
    sp  <- split(long$species, key)
    first <- !duplicated(key)
    summ <- data.frame(item = item, ref_key = long$ref_key[first], citation = long$citation[first],
                       variable = long$variable[first], key_column = long$key_column[first],
                       n_rows = as.integer(table(key)[key[first]]),
                       n_species = vapply(sp[key[first]], function(s) length(unique(s)), integer(1)),
                       species = vapply(sp[key[first]], function(s) paste(sort(unique(s)), collapse = "; "), character(1)),
                       n_rows_shared_key = vapply(split(long$n_keys_in_cell > 1L, key)[key[first]], sum, integer(1)),
                       match_basis = long$match_basis[first],
                       status = ifelse(long$status[first] == "key_not_in_references", "key_not_in_references",
                                       ifelse(is.na(long$citation[first]), "matched_citation_missing", "matched")),
                       stringsAsFactors = FALSE, row.names = NULL)
    # order: as the references file lists the keys, then by data column order
    summ <- summ[order(match(summ$ref_key, refs$ref_key), match(summ$variable, names(dat))), ]
  } else summ <- data.frame()

  ## -- write ---------------------------------------------------------------------
  f_long <- file.path(out_dir, paste0(item, "_source_match.csv"))
  f_summ <- file.path(out_dir, paste0(item, "_source_match_summary.csv"))
  f_iss  <- file.path(out_dir, paste0(item, "_source_match_issues.csv"))
  sm_write_csv(long, f_long); sm_write_csv(summ, f_summ); sm_write_csv(iss, f_iss)

  ## -- report / assert ------------------------------------------------------------
  n_unknown <- sum(iss$issue == "key_not_in_references")
  n_unres   <- sum(iss$issue == "unresolved_key_scope")
  counts    <- table(iss$issue)
  say(nrow(dat), " rows x ", length(data_cols), " data columns; ", nrow(refs), " references (", style,
      " keys", if (legacy_schema) paste0(", legacy columns ", kcol, "/", ccol) else "", "); key columns: ",
      paste0(decl$key_column, " -> ", decl$applies_to, " [", decl$basis, "]", collapse = "; "))
  say(nrow(long), " cell attributions, ", nrow(summ), " ref x variable pairs, ", nrow(iss), " issues",
      if (nrow(iss)) paste0(" (", paste(names(counts), counts, sep = "=", collapse = ", "), ")") else "")
  if (strict && (n_unknown || n_unres))
    stop("source_match: ", item, " has ", n_unknown, " keys not in references and ", n_unres,
         " unresolved key columns (strict = TRUE)", call. = FALSE)
  invisible(list(item = item, paper = paper, long = long, summary = summ, issues = iss,
                 key_columns = decl[, c("key_column", "applies_to", "basis")], key_style = style,
                 legacy_schema = legacy_schema, declared = declared, n_refs = nrow(refs),
                 n_data_cols = length(data_cols), species_column = sp_col,
                 files = c(long = f_long, summary = f_summ, issues = f_iss)))
}

## ------------------------------------------------------ driver: whole repo -------
# Legacy reference files that are not named <Item>_references.csv: item they belong to.
SM_LEGACY_REFS <- data.frame(stringsAsFactors = FALSE, rbind(
  c("Kaskan_etal_2005",     "Kaskan_etal_2005_References.csv",                       "Kaskan_etal_2005_TableS1"),
  c("Iwaniuk_etal_1999",    "Iwaniuk_etal_1999_References.csv",                      "Iwaniuk_etal_1999_Table1"),
  c("DeCasien_Higham_2019", "DeCasien_Higham_2019_referencesbraindata.csv",          "DeCasien_Higham_2019_BrainRegionDatamm3"),
  c("Boyer_Harrington_2018","Boyer_Harrington_2018_Table1_references.csv",           "Boyer_Harrington_2018_Table1"),
  c("Seymour_etal_2015",    "Seymour_etal_2015_TableS1_references.csv",              "Seymour_etal_2015_TableS1"),
  c("Veilleux_Kirk_2014",   "reference_tables/Veilleux_Kirk_2014_SupplementalTable1_data_sources.csv",
                                                                                     "Veilleux_Kirk_2014_SupplementalTable1")))
names(SM_LEGACY_REFS) <- c("paper", "refs_file", "item")

source_match_all <- function(root, out_dir = NULL, write_repo = TRUE, papers = NULL, quiet = TRUE) {
  root <- normalizePath(root, mustWork = TRUE)
  todo <- list()
  for (f in Sys.glob(file.path(root, "*", "reference_tables", "*_references.csv"))) {
    paper <- basename(dirname(dirname(f)))
    item  <- sub("_references\\.csv$", "", basename(f))
    todo[[length(todo) + 1L]] <- list(paper = paper, item = item, refs = f)
  }
  for (i in seq_len(nrow(SM_LEGACY_REFS)))
    todo[[length(todo) + 1L]] <- list(paper = SM_LEGACY_REFS$paper[i], item = SM_LEGACY_REFS$item[i],
                                      refs = file.path(root, SM_LEGACY_REFS$paper[i], SM_LEGACY_REFS$refs_file[i]))
  if (!is.null(papers)) todo <- Filter(function(t) t$paper %in% papers, todo)
  rows <- list()
  for (t in todo) {
    pdir <- file.path(root, t$paper)
    od   <- if (write_repo) NULL else file.path(out_dir, t$paper, "reference_tables")
    res  <- tryCatch(build_source_match(pdir, t$item, refs_file = t$refs, out_dir = od, quiet = quiet),
                     error = function(e) e)
    if (inherits(res, "error")) {
      msg <- conditionMessage(res)
      st  <- if (!file.exists(file.path(pdir, paste0(t$item, ".csv")))) "NOT_ITEM_SCOPED" else
             if (startsWith(msg, "DECLARE:")) "DECLARE" else "ERROR"
      rows[[length(rows) + 1L]] <- data.frame(paper = t$paper, item = t$item, status = st,
        key_style = "", declared = NA, legacy_schema = NA, n_refs = NA, n_data_cols = NA, key_columns = "",
        n_attributions = NA, n_ref_x_variable = NA, n_key_not_in_references = NA, n_reference_never_cited = NA,
        n_value_without_key = NA, n_unresolved_key_scope = NA, n_residual_text = NA,
        message = msg, stringsAsFactors = FALSE)
      next
    }
    nI <- function(x) sum(res$issues$issue == x)
    rows[[length(rows) + 1L]] <- data.frame(paper = t$paper, item = t$item,
      status = if (nI("key_not_in_references") + nI("unresolved_key_scope") > 0) "REVIEW" else "OK",
      key_style = res$key_style, declared = res$declared, legacy_schema = res$legacy_schema,
      n_refs = res$n_refs, n_data_cols = res$n_data_cols,
      key_columns = paste0(res$key_columns$key_column, "->", res$key_columns$applies_to,
                           " [", res$key_columns$basis, "]", collapse = "; "),
      n_attributions = nrow(res$long), n_ref_x_variable = nrow(res$summary),
      n_key_not_in_references = nI("key_not_in_references"), n_reference_never_cited = nI("reference_never_cited"),
      n_value_without_key = nI("value_without_key"), n_unresolved_key_scope = nI("unresolved_key_scope"),
      n_residual_text = nI("residual_text_in_key_cell"), message = "", stringsAsFactors = FALSE)
  }
  idx <- do.call(rbind, rows)
  idx_path <- if (write_repo) file.path(root, "_checks", "source_match_index.csv") else
              file.path(out_dir, "source_match_index.csv")
  dir.create(dirname(idx_path), showWarnings = FALSE, recursive = TRUE)
  sm_write_csv(idx, idx_path)
  message("[source_match] ", nrow(idx), " items: ", paste(names(table(idx$status)), table(idx$status),
          sep = "=", collapse = ", "), " -> ", idx_path)
  invisible(idx)
}
