#!/usr/bin/env Rscript
## snapshot_freeze.R -- freeze the snapshots of items that a person has already checked.
##
## RULE
##   A snapshot is frozen evidence once a person has visually checked it against the paper.
##   The check is recorded in __ReadMe.xlsx, Sheet1, column "Human visual check of snapshot", as
##       DDMMYYYY_initials          e.g.  14102026_AAdS      (YYYY-MM-DD_initials is accepted too)
##   Any item with such a value is FROZEN: no sweep or build script may rewrite its snapshot files
##   (`<Item name>_snapshot.*`, and `<Item name>_<word>_snapshot.*` such as reference_tables context
##   snapshots). Everything downstream of the snapshot (analysis CSV, public TSV) is still rebuilt.
##
##   Not frozen: blank cells; "Not applicable: tabulated and digital already" (no person checked a
##   transcription -- set EVOM1_FREEZE_NA=1 to freeze those untouched downloads too); a value that
##   starts with REOPEN (e.g. "REOPEN 14102026_AAdS" -- keeps the old stamp visible while the
##   snapshot is being redone); and an unparseable value (reported as a warning, so a typo is
##   visible and not silently unprotected).
##
## HOW IT PROTECTS (three layers)
##   1. lock    Frozen files are hashed (md5, base R) into _checks/snapshot_freeze/manifest.csv and a
##              byte copy is kept in _checks/snapshot_freeze/store/.
##   2. prevent run_all_scripts_v2.R skips any script that, by static scan, writes a frozen item's
##              snapshot (the skip reason says which item and how to override).
##   3. enforce After every script the frozen files are re-hashed; if one changed (a writer the scan
##              did not catch) it is restored from the store and the script is logged FAILED.
##
## FLEXIBILITY (re-running a frozen snapshot on purpose)
##   * One run:   EVOM1_UNFREEZE="Item_name_1,Item_name_2"   (or ALL)   Rscript run_all_scripts_v2.R
##                The item is RELEASED in the manifest, so the new bytes are not reverted next time.
##   * Permanent: change the check cell (blank it, or prefix REOPEN). The item is released.
##   * Re-freeze: record a NEW check stamp (new date). A released item whose check stamp is unchanged
##                re-locks only if its bytes still equal the checked bytes; if they changed, it stays
##                released until the stamp changes -- altered bytes never keep an old stamp.
##
## CLI (from the repo root)
##   Rscript _tools/snapshot_freeze.R status            # table: what is frozen / drifted / released
##   Rscript _tools/snapshot_freeze.R lock              # sync manifest + store with the registry
##   Rscript _tools/snapshot_freeze.R verify            # exit 1 if any frozen snapshot differs
##   Rscript _tools/snapshot_freeze.R restore           # put drifted frozen snapshots back
##   add --unfreeze=Item_a,Item_b to release items for that command
##
## FROM A SCRIPT (before writing a snapshot):
##   source(file.path(root, "_tools", "snapshot_freeze.R")); freeze_assert_writable(path, root)

options(stringsAsFactors = FALSE)

## Repo paths contain non-ASCII characters; under a C locale basename()/grepl() on them fail.
## (Same fix as run_all_scripts_v2.R; harmless when a UTF-8 locale is already active.)
for (.loc in c("en_US.UTF-8", "en_GB.UTF-8", "C.UTF-8", "UTF-8")) {
  if (isTRUE(tryCatch(Sys.setlocale("LC_CTYPE", .loc), error = function(e) FALSE) == .loc)) {
    Sys.setenv(LANG = .loc, LC_ALL = .loc); break
  }
}

FREEZE_COL_PATTERN <- "visual check of snapshot"
FREEZE_DIR  <- file.path("_checks", "snapshot_freeze")
FREEZE_NA   <- "^\\s*Not applicable"
FREEZE_SKIP_EXT <- "\\.(R|Rmd|py|md|ipynb|sh)$"
FREEZE_SKIP_DIR <- "(^|/)(\\.git|_archive|__Public|_checks|_skills|renv)(/|$)"

.nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x

freeze_root <- function(start = getwd()) {
  d <- normalizePath(start, mustWork = FALSE)
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("snapshot_freeze: no __ReadMe.xlsx above ", start)
  d
}

## ---- 1. registry: who is checked? -------------------------------------------------------------
freeze_classify_check <- function(x) {
  x <- if (length(x) == 0L || is.na(x)) "" else trimws(as.character(x))
  if (!nzchar(x)) return(list(state = "blank", date = NA_character_, who = NA_character_))
  if (grepl("^REOPEN", x, ignore.case = TRUE)) return(list(state = "reopened", date = NA_character_, who = NA_character_))
  if (grepl(FREEZE_NA, x, ignore.case = TRUE)) return(list(state = "not_applicable", date = NA_character_, who = NA_character_))
  m <- regmatches(x, regexec("^([0-3][0-9])([01][0-9])((?:19|20)[0-9]{2})[_ -]+([A-Za-z][A-Za-z.]*)", x, perl = TRUE))[[1]]
  d <- NA
  if (length(m) == 5L) {
    d <- suppressWarnings(as.Date(sprintf("%s-%s-%s", m[4], m[3], m[2]), format = "%Y-%m-%d")); who <- m[5]
  } else {
    m <- regmatches(x, regexec("^((?:19|20)[0-9]{2})-([01][0-9])-([0-3][0-9])[_ -]+([A-Za-z][A-Za-z.]*)", x, perl = TRUE))[[1]]
    if (length(m) == 5L) { d <- suppressWarnings(as.Date(sprintf("%s-%s-%s", m[2], m[3], m[4]))); who <- m[5] }
  }
  if (length(d) == 1L && !is.na(d)) return(list(state = "checked", date = format(d), who = who))
  list(state = "unparsed", date = NA_character_, who = NA_character_)
}

freeze_registry <- function(root = freeze_root()) {
  rg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text", .name_repair = "minimal")
  col <- grep(FREEZE_COL_PATTERN, names(rg), ignore.case = TRUE)
  if (length(col) != 1L) stop("snapshot_freeze: expected exactly one column matching '", FREEZE_COL_PATTERN,
                              "' in __ReadMe.xlsx Sheet1; found ", length(col))
  items <- .nfc(rg[["Item name"]]); val <- rg[[col]]
  keep <- !is.na(items) & nzchar(items)
  cls <- lapply(val[keep], freeze_classify_check)
  data.frame(item = items[keep], check_value = ifelse(is.na(val[keep]), "", trimws(val[keep])),
             state = vapply(cls, `[[`, "", "state"), check_date = vapply(cls, `[[`, "", "date"),
             who = vapply(cls, `[[`, "", "who"), stringsAsFactors = FALSE)
}

## ---- 2. snapshot files of an item -------------------------------------------------------------
freeze_index <- function(root = freeze_root()) {
  f <- list.files(root, recursive = TRUE, all.files = FALSE, include.dirs = FALSE)
  f <- f[!grepl(FREEZE_SKIP_DIR, f) & !grepl(FREEZE_SKIP_EXT, f) & grepl("snapshot", basename(f), ignore.case = TRUE)]
  data.frame(rel = f, rel_nfc = .nfc(f), stringsAsFactors = FALSE)
}

freeze_files_for <- function(item, index) {
  esc <- gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", tolower(item))
  rx <- paste0("^", esc, "(_[a-z0-9-]+)*_snapshot(\\.|_)")
  hit <- grepl(rx, tolower(basename(index$rel_nfc)))
  index$rel[hit]
}

.md5 <- function(paths) unname(as.character(tools::md5sum(paths)))

## ---- 3. manifest + store ----------------------------------------------------------------------
.manifest_cols <- c("item", "file", "md5", "bytes", "check_value", "status", "locked_on", "note")
.manifest_path <- function(root) file.path(root, FREEZE_DIR, "manifest.csv")
.store_path    <- function(root, md5) file.path(root, FREEZE_DIR, "store", md5)

freeze_read_manifest <- function(root) {
  p <- .manifest_path(root)
  if (!file.exists(p)) return(setNames(data.frame(matrix(character(), 0, length(.manifest_cols))), .manifest_cols))
  m <- utils::read.csv(p, colClasses = "character", na.strings = character(), fileEncoding = "UTF-8")
  m[, .manifest_cols, drop = FALSE]
}
freeze_write_manifest <- function(m, root) {
  dir.create(file.path(root, FREEZE_DIR, "store"), recursive = TRUE, showWarnings = FALSE)
  m <- m[order(m$item, m$file), , drop = FALSE]
  utils::write.csv(m, .manifest_path(root), row.names = FALSE, fileEncoding = "UTF-8")
}

.unfreeze_set <- function(x = Sys.getenv("EVOM1_UNFREEZE", "")) {
  v <- trimws(strsplit(x, ",", fixed = TRUE)[[1]]); .nfc(v[nzchar(v)])
}

## Sync manifest with registry + disk. Never modifies a snapshot. Returns the manifest with a
## `state` column added: ok | new | relocked | DRIFT | MISSING | released | released-changed.
freeze_sync <- function(root = freeze_root(), unfreeze = .unfreeze_set(), write = TRUE, quiet = FALSE) {
  reg <- freeze_registry(root); idx <- freeze_index(root); man <- freeze_read_manifest(root)
  freeze_na <- identical(Sys.getenv("EVOM1_FREEZE_NA", ""), "1")
  should <- reg$state == "checked" | (freeze_na & reg$state == "not_applicable")
  if (!quiet && any(reg$state == "unparsed"))
    for (i in which(reg$state == "unparsed"))
      message("snapshot_freeze WARNING: unparseable check value for ", reg$item[i], ": '", reg$check_value[i],
              "' -> not newly frozen; an already-locked item stays locked (expected DDMMYYYY_initials)")
  out <- list(); now <- format(Sys.time(), "%Y-%m-%d %H:%M")
  unfrozen_all <- "ALL" %in% unfreeze
  seen <- character()
  for (i in which(should)) {
    item <- reg$item[i]; cv <- reg$check_value[i]
    files <- freeze_files_for(item, idx)
    for (f in files) {
      key <- paste(item, .nfc(f), sep = "\r"); seen <- c(seen, key)
      h <- .md5(file.path(root, f)); b <- as.character(file.size(file.path(root, f)))
      old <- man[man$item == item & .nfc(man$file) == .nfc(f), , drop = FALSE]
      rel <- unfrozen_all || item %in% unfreeze
      if (nrow(old) == 0L) {
        st <- if (rel) "released" else "new"
        out[[length(out) + 1]] <- data.frame(item, file = f, md5 = h, bytes = b, check_value = cv,
          status = if (rel) "released" else "locked", locked_on = now, note = if (rel) "released at first sight (EVOM1_UNFREEZE)" else "", state = st)
      } else {
        o <- old[1, ]
        if (o$check_value != cv) {            # a new human check -> (re)lock the current bytes
          out[[length(out) + 1]] <- data.frame(item, file = f, md5 = h, bytes = b, check_value = cv,
            status = "locked", locked_on = now, note = paste0("re-locked after new check (was '", o$check_value, "')"), state = "relocked")
        } else if (o$status == "released") {   # unchanged stamp: relock only if bytes still the checked bytes
          if (rel) { o$state <- "released"; out[[length(out) + 1]] <- o }
          else if (h == o$md5) { o$status <- "locked"; o$note <- "re-locked: bytes still equal the checked bytes"; o$state <- "relocked"; out[[length(out) + 1]] <- o }
          else { o$state <- "released-changed"; o$note <- "snapshot changed after release; record a new check stamp to freeze it again"; out[[length(out) + 1]] <- o }
        } else if (rel) {                      # lock -> release (authorised rerun)
          o$status <- "released"; o$note <- paste0("released ", now, " via EVOM1_UNFREEZE"); o$state <- "released"
          out[[length(out) + 1]] <- o
        } else {
          o$state <- if (!file.exists(file.path(root, f))) "MISSING" else if (h == o$md5) "ok" else "DRIFT"
          out[[length(out) + 1]] <- o
        }
      }
    }
  }
  ## manifest rows not matched above: the snapshot file is gone, or the item is no longer checked.
  for (j in seq_len(nrow(man))) {
    key <- paste(man$item[j], .nfc(man$file[j]), sep = "\r")
    if (key %in% seen) next
    o <- man[j, ]; st <- reg$state[match(o$item, reg$item)]; st <- if (is.na(st)) "blank" else st
    fp <- file.path(root, o$file); rel <- unfrozen_all || o$item %in% unfreeze
    if (o$status == "locked" && !rel && (st == "unparsed" || should[match(o$item, reg$item)] %in% TRUE)) {
      ## still protected: either the file vanished (checked item) or the cell holds a typo (unparsed)
      o$state <- if (!file.exists(fp)) "MISSING" else if (.md5(fp) == o$md5) "ok" else "DRIFT"
      if (st == "unparsed") o$note <- "check cell unparseable -> kept locked until corrected"
    } else {
      if (o$status == "locked") { o$status <- "released"; o$note <- paste0("check cleared/reopened in registry; released ", now) }
      o$state <- "released"
    }
    out[[length(out) + 1]] <- o
  }
  res <- if (length(out)) do.call(rbind, out) else cbind(freeze_read_manifest(root), state = character())
  if (write) {
    ## byte copies of everything currently locked (never overwrite a stored copy that has the same name)
    for (k in which(res$status == "locked" & res$state %in% c("new", "relocked", "ok", "DRIFT", "MISSING"))) {
      sp <- .store_path(root, res$md5[k]); fp <- file.path(root, res$file[k])
      if (!file.exists(sp) && file.exists(fp) && res$state[k] %in% c("new", "relocked", "ok")) {
        dir.create(dirname(sp), recursive = TRUE, showWarnings = FALSE); file.copy(fp, sp)
      }
    }
    freeze_write_manifest(res[, .manifest_cols, drop = FALSE], root)
  }
  rownames(res) <- NULL
  res
}

## Locked rows only (what scripts must not touch).
freeze_locked <- function(sync) sync[sync$status == "locked" & sync$state %in% c("new", "relocked", "ok", "DRIFT", "MISSING"), , drop = FALSE]

## Cheap per-script check: re-hash only the locked files. Returns the rows that differ / vanished.
freeze_check_locked <- function(locked, root = freeze_root()) {
  if (!nrow(locked)) return(locked)
  fp <- file.path(root, locked$file)
  now <- ifelse(file.exists(fp), .md5(fp), NA_character_)
  locked[is.na(now) | now != locked$md5, , drop = FALSE]
}

## Put back frozen snapshots from the byte store. `bad` = rows from freeze_check_locked(); with
## NULL, a fresh sync decides. Returns the files restored.
freeze_restore <- function(root = freeze_root(), bad = NULL) {
  if (is.null(bad)) bad <- freeze_check_locked(freeze_locked(freeze_sync(root, write = FALSE, quiet = TRUE)), root)
  done <- character()
  for (k in seq_len(nrow(bad))) {
    sp <- .store_path(root, bad$md5[k])
    if (!file.exists(sp)) { warning("snapshot_freeze: no stored copy for ", bad$file[k], " (restore it from git)"); next }
    file.copy(sp, file.path(root, bad$file[k]), overwrite = TRUE); done <- c(done, bad$file[k])
  }
  done
}

## ---- 4. enforcement helpers used by the sweep / by individual scripts -------------------------
## Static scan: does this script WRITE a snapshot file? (quoted "snapshot" in a writer call's
## arguments, or a variable that holds a snapshot path.) Deliberately conservative about readers.
.writer_rx <- "(write\\.csv2?|write_csv2?|write\\.table|write_tsv|write_delim|write\\.xlsx|write_xlsx|saveWorkbook|file\\.copy|file\\.rename|file\\.create|writeLines|download\\.file|fwrite|write_csv_tsv|saveRDS|unlink|file\\.remove)\\s*\\("
.reader_rx <- "^\\s*[A-Za-z_.][A-Za-z0-9_.]*\\s*(<-|=)\\s*(utils::|readr::|readxl::|openxlsx::|data\\.table::)?(read\\.csv2?|read_csv2?|read\\.table|read\\.delim|read_tsv|read_delim|read_excel|read\\.xlsx|loadWorkbook|readLines|fread|readRDS|scan)\\s*\\("
## a quoted string that looks like a snapshot FILE name ("..._snapshot.csv", "snapshot.xlsx"), not a
## column label such as "Snapshot_record"
.snap_str_rx <- "[\"'][^\"']*(_snapshot|snapshot\\.(csv|tsv|xlsx|xls|txt|nex))[^\"']*[\"']"
freeze_script_writes_snapshot <- function(path) {
  txt <- tryCatch(readLines(path, warn = FALSE, encoding = "UTF-8"), error = function(e) character())
  if (!length(txt)) return(FALSE)
  txt <- sub("(^|\\s)#.*$", "", txt)                          # drop comments (rough)
  asg <- grep("^\\s*[A-Za-z_.][A-Za-z0-9_.]*\\s*(<-|=)\\s*", txt)
  pv <- character()
  for (i in asg) {
    ln <- txt[i]
    if (grepl(.reader_rx, ln, perl = TRUE)) next
    if (grepl(.snap_str_rx, ln, ignore.case = TRUE, perl = TRUE))
      pv <- c(pv, sub("^\\s*([A-Za-z_.][A-Za-z0-9_.]*)\\s*(<-|=).*$", "\\1", ln))
  }
  pv <- unique(pv)
  ## The exact text of each writer call, by balanced parentheses (a fixed line window would bleed
  ## into following lines, e.g. a stopifnot(md5sum(snapshot)) after file.copy(snapshot, local_csv)).
  joined <- paste(txt, collapse = "\n")
  starts <- gregexpr(.writer_rx, joined, perl = TRUE)[[1]]
  if (starts[1] == -1L) return(FALSE)
  for (st in starts) {
    ch <- strsplit(substr(joined, st, st + 1500L), "")[[1]]
    depth <- 0L; open <- FALSE; end <- length(ch); q <- ""
    for (k in seq_along(ch)) {                                # skip parens inside quoted strings
      c1 <- ch[k]
      if (nzchar(q)) { if (c1 == q) q <- ""; next }
      if (c1 == "\"" || c1 == "'") { q <- c1; next }
      if (c1 == "(") { depth <- depth + 1L; open <- TRUE }
      else if (c1 == ")") { depth <- depth - 1L; if (open && depth == 0L) { end <- k; break } }
    }
    call <- paste(ch[seq_len(end)], collapse = "")
    ## file.copy(from, to) / file.rename(from, to): only the DESTINATION is at risk
    ## (Isler: file.copy(snapshot, local_csv) READS the snapshot).
    if (grepl("^file\\.(copy|rename)\\s*\\(", call, perl = TRUE)) {
      args <- sub("^file\\.(copy|rename)\\s*\\(", "", call, perl = TRUE)
      ca <- strsplit(args, "")[[1]]; depth <- 0L; cut <- NA_integer_; q <- ""
      for (k in seq_along(ca)) {
        c1 <- ca[k]
        if (nzchar(q)) { if (c1 == q) q <- ""; next }
        if (c1 == "\"" || c1 == "'") { q <- c1; next }
        if (c1 == "(") depth <- depth + 1L else if (c1 == ")") depth <- depth - 1L
        else if (c1 == "," && depth == 0L) { cut <- k; break }
      }
      call <- if (is.na(cut)) "" else substr(args, cut + 1L, nchar(args))
    }
    call <- gsub("\n", " ", call, fixed = TRUE)
    if (grepl(.snap_str_rx, call, ignore.case = TRUE, perl = TRUE)) return(TRUE)
    if (length(pv) && any(vapply(pv, function(v) grepl(paste0("(^|[^A-Za-z0-9_.])", gsub("\\.", "\\\\.", v), "([^A-Za-z0-9_.]|$)"), call, perl = TRUE), logical(1)))) return(TRUE)
  }
  FALSE
}

## For a script: the locked items it could rewrite (same folder as the snapshot, and the script is
## that item's reader or names it / its snapshot file). NULL if none.
freeze_blocking_items <- function(script, locked, root) {
  if (!nrow(locked)) return(character())
  rel <- .nfc(sub(paste0("^", gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", root), "/?"), "", normalizePath(script, mustWork = FALSE)))
  sdir <- dirname(rel)
  cand <- locked[.nfc(dirname(locked$file)) == sdir | .nfc(dirname(locked$file)) == file.path(sdir, "reference_tables"), , drop = FALSE]
  if (!nrow(cand)) return(character())
  if (!freeze_script_writes_snapshot(script)) return(character())
  txt <- .nfc(paste(readLines(script, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  stem <- .nfc(tools::file_path_sans_ext(basename(script)))
  hit <- vapply(seq_len(nrow(cand)), function(k)
    tolower(stem) == tolower(cand$item[k]) || grepl(cand$item[k], txt, fixed = TRUE) ||
      grepl(.nfc(basename(cand$file[k])), txt, fixed = TRUE), logical(1))
  unique(cand$item[hit])
}

## Call this in a script right before writing a snapshot file; stops if the item is frozen.
freeze_assert_writable <- function(path, root = freeze_root(dirname(normalizePath(path, mustWork = FALSE)))) {
  sync <- freeze_sync(root, write = FALSE, quiet = TRUE)
  lk <- freeze_locked(sync)
  rel <- .nfc(sub(paste0("^", gsub("([][{}()+*^$|\\\\?.])", "\\\\\\1", root), "/?"), "", normalizePath(path, mustWork = FALSE)))
  hit <- lk[.nfc(lk$file) == rel, , drop = FALSE]
  if (nrow(hit))
    stop("Refusing to rewrite frozen snapshot ", rel, " (item ", hit$item[1], ", checked ", hit$check_value[1],
         "). To redo it on purpose: EVOM1_UNFREEZE=", hit$item[1], ", then record a new check stamp.", call. = FALSE)
  invisible(TRUE)
}

## ---- 5. CLI -----------------------------------------------------------------------------------
freeze_cli <- function(args) {
  cmd <- if (length(args) && !grepl("^--", args[1])) args[1] else "status"
  uf <- sub("^--unfreeze=", "", args[grepl("^--unfreeze=", args)])
  unfreeze <- if (length(uf)) .nfc(trimws(strsplit(uf[1], ",", fixed = TRUE)[[1]])) else .unfreeze_set()
  root <- freeze_root()
  reg <- freeze_registry(root)
  cat(sprintf("registry: %d items | checked (dated) %d | not applicable %d | reopened %d | unparsed %d | blank %d\n",
              nrow(reg), sum(reg$state == "checked"), sum(reg$state == "not_applicable"),
              sum(reg$state == "reopened"), sum(reg$state == "unparsed"), sum(reg$state == "blank")))
  if (cmd == "status") {
    s <- freeze_sync(root, unfreeze, write = FALSE)
  } else if (cmd %in% c("lock", "verify", "restore")) {
    s <- freeze_sync(root, unfreeze, write = (cmd == "lock"))
    if (cmd == "restore") { r <- freeze_restore(root, s[s$status == "locked" & s$state %in% c("DRIFT", "MISSING"), , drop = FALSE]); cat("restored", length(r), "file(s)\n"); for (x in r) cat("  ", x, "\n") }
  } else stop("unknown command '", cmd, "'; use status | lock | verify | restore")
  if (nrow(s)) print(s[, c("item", "file", "check_value", "status", "state")], row.names = FALSE) else cat("no frozen snapshots\n")
  chk <- reg$item[reg$state == "checked"]; nofile <- setdiff(chk, s$item)
  if (length(nofile)) cat("checked items with no snapshot file found: ", paste(nofile, collapse = ", "), "\n")
  bad <- sum(s$status == "locked" & s$state %in% c("DRIFT", "MISSING"))
  if (bad) cat(bad, "frozen snapshot(s) differ from the checked bytes -> run `restore`, or release the item deliberately\n")
  if (cmd == "verify" && bad) quit(status = 1)
  invisible(s)
}

if (!interactive() && sys.nframe() == 0L) freeze_cli(commandArgs(trailingOnly = TRUE))
