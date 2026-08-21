#!/usr/bin/env Rscript
# check_laterality_doubling.R
# -----------------------------------------------------------------------------
# Is every doubled brain-volume value marked, and marked as provenance rather
# than as a veto?
#
# Two different things can make a "both-hemisphere" volume out of one measured
# side, and the merge has to keep them apart:
#
#   doubling = none       the source printed one side AS MEASURED; the x2 (if
#                         any) is done by THIS project in step 7 of the merge
#                                        -> flag estimated_bilateral_from_unilateral
#   doubling = by_source  the source PUBLISHED 2x one side, with the authors'
#                         own symmetry argument (de Sousa 2010 V1/LGN; de Sousa
#                         2013 LGN)      -> flag published_bilateral_estimate
#
# Both are PROVENANCE: they record how a both-sides number came to exist and
# never remove a value. Only an `action = skip` row in
# volumes_select_value_flags.csv drops anything. This script exists because that
# distinction is easy to lose.
#
# What it checks
#   1. laterality_known.csv parses, and every `doubling` is one of {none, by_source}.
#   2. Every registered column resolves to a standardized term.
#   3. doubling = none      -> the term CARRIES its required laterality suffix
#      doubling = by_source -> the term carries NO laterality suffix (it stands
#                              for both sides).
#   4. No author-doubled stem is in the merge's bilateral-doubling set, i.e.
#      nothing gets doubled twice.
#   5. Predicts the exact `published_bilateral_estimate` rows the R merge should
#      emit (from the last written volumes_unfiltered.csv /
#      volumes_resolution_audit_select.csv) and, once the R scripts have been
#      re-run, diffs that prediction against the actual volumes_flags*.csv.
#   6. No author-doubled term appears as a `skip` in
#      volumes_select_value_flags.csv -- doubling must never be treated as
#      grounds for omission.
#
# Run:  Rscript _checks/check_laterality_doubling.R
# Exit: 0 = all checks pass (pending checks are not failures), 1 = at least one FAIL.
#
# Ported from check_laterality_doubling.py (retired). The port is deliberately
# literal -- same checks, same wording, same exit status -- so the two could be
# diffed against each other by _checks/parity_R_vs_py.R before the .py went away.
# Two details exist only to keep that diff clean: sort(method = "radix") gives
# C-locale ordering, which is what Python's sorted() does and what R's
# locale-aware sort() does not; and py_list() reproduces Python's list repr in
# the one FAIL message that prints a list.
# -----------------------------------------------------------------------------

HERE <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(dirname(normalizePath(f)))
  sf <- tryCatch(dirname(normalizePath(sys.frames()[[1]]$ofile)), error = function(e) NULL)
  if (!is.null(sf)) return(sf)
  normalizePath(getwd())
})
REPO   <- dirname(HERE)
MV     <- file.path(REPO, "__merging_volumes")
SUFFIX <- "_(unilateral|left|right)_Vol\\.mm3$"
VALID  <- c("none", "by_source")
## Python compares (Reference, Term) tuples; R has no tuple, so pairs are joined on a
## control character that cannot occur in a CSV field. It also sorts below every
## printable character, so sorting the joined keys orders them exactly as Python
## orders the tuples. Written as an escape, never as a raw byte in the source.
SEP    <- "\u0001"

fails <- character()
pending <- character()

## Read a CSV the way Python's csv.DictReader does: every field a string, empty
## stays "", the literal text NA stays "NA", and a UTF-8 BOM is stripped.
rd <- function(path) {
  if (!file.exists(path)) return(NULL)
  read.csv(path, colClasses = "character", check.names = FALSE,
           na.strings = character(0), fileEncoding = "UTF-8-BOM")
}
## Python's r.get("x") yields None for an absent column; a data.frame would abort.
col <- function(df, name) {
  if (is.null(df) || !nrow(df)) return(character())
  if (name %in% names(df)) as.character(df[[name]]) else rep("", nrow(df))
}
srt <- function(x) sort(unique(x), method = "radix")       # C-locale, as Python sorts
py_list <- function(x) sprintf("[%s]", paste(sprintf("'%s'", x), collapse = ", "))

report <- function(ok, label, detail = "") {
  cat(sprintf("  [%s] %s%s\n", if (ok) "PASS" else "FAIL", label,
              if (nzchar(detail)) paste0(" -- ", detail) else ""))
  if (!ok) fails <<- c(fails, label)
}

cat("Is every doubled brain-volume value marked, and marked as provenance rather than as a veto?\n")
cat("\n")

# ---------------------------------------------------------------- 1-3 registry vs term map
lat   <- rd(file.path(MV, "laterality_known.csv"))
terms <- rd(file.path(MV, "standardized_term_volumes.csv"))
if (is.null(lat) || is.null(terms)) {
  message("laterality_known.csv or standardized_term_volumes.csv not found -- run from the repo.")
  quit(status = 1L)
}

doubling <- trimws(col(lat, "doubling"))
doubling[!nzchar(doubling)] <- "none"
lat_ref  <- col(lat, "Reference")
lat_orig <- col(lat, "Original_Term")
lat_req  <- col(lat, "required_suffix")

tmap <- setNames(col(terms, "Standardized_Term"),
                 paste(col(terms, "Reference"), col(terms, "Original_Term"), sep = SEP))
lat_key <- paste(lat_ref, lat_orig, sep = SEP)

cat("Registry\n")
bad_vals <- srt(setdiff(doubling, VALID))
report(!length(bad_vals), "every `doubling` is none|by_source", paste(bad_vals, collapse = ", "))

unmapped <- which(!(lat_key %in% names(tmap)))
report(!length(unmapped), "every registered column has a standardized term",
       paste(sprintf("%s:%s", lat_ref[unmapped], lat_orig[unmapped]), collapse = "; "))

st_of  <- unname(tmap[lat_key])
mapped <- which(!is.na(st_of))
one_side  <- mapped[doubling[mapped] == "none"]
by_source <- mapped[doubling[mapped] != "none"]

## Anchored, matching the R guard: the suffix must sit immediately before _Vol.mm3.
miss <- one_side[!(nzchar(lat_req[one_side]) &
                     endsWith(st_of[one_side], paste0(lat_req[one_side], "_Vol.mm3")))]
report(!length(miss),
       sprintf("doubling=none (%d) carry their laterality suffix (anchored)", length(one_side)),
       paste(sprintf("%s -> %s", lat_orig[miss], st_of[miss]), collapse = "; "))

wrong <- by_source[grepl(SUFFIX, st_of[by_source])]
report(!length(wrong),
       sprintf("doubling=by_source (%d) carry NO laterality suffix", length(by_source)),
       paste(sprintf("%s -> %s", lat_orig[wrong], st_of[wrong]), collapse = "; "))

doubled_ref  <- lat_ref[by_source]
doubled_term <- st_of[by_source]
doubled_key  <- unique(paste(doubled_ref, doubled_term, sep = SEP))
doubled_terms <- srt(doubled_term)
cat(paste0("    author-doubled terms: ", paste(doubled_terms, collapse = ", "), "\n"))

# ---------------------------------------------------------------- 4 never doubled twice
# Each merge script decides which stems get a both-sides partner built. An author-doubled stem must
# not be in that set, or the merge would double an already-doubled figure. The three scripts express
# this differently, so check each on its own terms.
cat("\nNo value is doubled twice\n")
stems <- unique(sub("_Vol\\.mm3$", "", sub(SUFFIX, "", doubled_terms)))

## Drop `#` comments, but not a `#` inside a string literal.
strip_r_comments <- function(text) {
  ch <- strsplit(text, "", fixed = TRUE)[[1]]
  n <- length(ch); out <- character(n); k <- 0L
  i <- 1L; in_str <- FALSE; quote <- ""; esc <- FALSE
  while (i <= n) {
    c1 <- ch[i]
    if (in_str) {
      k <- k + 1L; out[k] <- c1
      if (esc) esc <- FALSE
      else if (c1 == "\\") esc <- TRUE
      else if (c1 == quote) in_str <- FALSE
    } else if (c1 == "\"" || c1 == "'") {
      in_str <- TRUE; quote <- c1
      k <- k + 1L; out[k] <- c1
    } else if (c1 == "#") {
      while (i <= n && ch[i] != "\n") i <- i + 1L      # swallow to end of line
      k <- k + 1L; out[k] <- "\n"
    } else {
      k <- k + 1L; out[k] <- c1
    }
    i <- i + 1L
  }
  paste(out[seq_len(k)], collapse = "")
}

## String literals from a `name <- c( ... )` assignment.
##
## Scans to the BALANCED closing paren rather than the first `)` -- a `)` inside a trailing
## comment (`# cranial motor nuclei (Sherwood 2005):`) truncated an earlier regex version and made
## this check silently pass on a partial list.
rlist <- function(text, name) {
  m <- regexpr(paste0(name, "\\s*<-\\s*c\\("), text, perl = TRUE)
  if (m[1] < 0L) return(NULL)
  first <- m[1] + attr(m, "match.length")              # first char after the "("
  ch <- strsplit(text, "", fixed = TRUE)[[1]]
  i <- first; depth <- 1L; n <- length(ch)
  while (i <= n && depth > 0L) {
    if (ch[i] == "(") depth <- depth + 1L
    else if (ch[i] == ")") depth <- depth - 1L
    i <- i + 1L
  }
  if (depth > 0L) return(NULL)                         # unbalanced -- treat as unreadable
  inner <- substr(text, first, i - 2L)                 # i-1 is the ")"
  hits <- regmatches(inner, gregexpr('"[^"]+"', inner))[[1]]
  unique(substr(hits, 2L, nchar(hits) - 1L))
}

targets <- list(
  list(script = "volumes_compiled_select.R",   listname = "bilateral_stems_exclude", mode = "exclude"),
  list(script = "volumes_compiled.R",          listname = "insula_stems",            mode = "allowlist"),
  list(script = "volumes_compiled_DeCasien.R", listname = "bilateral_stems",         mode = "allowlist")
)
for (t in targets) {
  path <- file.path(MV, t$script)
  if (!file.exists(path)) {
    cat(sprintf("  [PEND] %s not found\n", t$script))
    pending <- c(pending, sprintf("%s not found", t$script))
    next
  }
  text <- strip_r_comments(paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n"))
  got  <- rlist(text, t$listname)
  if (is.null(got)) {
    ## `"auto"` (or any non-literal) means the stem set is discovered at run time, so an
    ## exclusion list is the only thing standing between us and a double-doubling.
    auto <- regexpr(paste0(t$listname, '\\s*<-\\s*"auto"'), text, perl = TRUE)[1] > 0L
    report(FALSE, sprintf("%s: could not read `%s`", t$script, t$listname),
           if (auto) "set to \"auto\" -- verify by hand" else "assignment not found or not a c(...)")
    next
  }
  if (t$mode == "exclude") {
    bad_stems <- srt(setdiff(stems, got))
    report(!length(bad_stems),
           sprintf("%s: every author-doubled stem is in `%s`", t$script, t$listname),
           paste(bad_stems, collapse = ", "))
  } else {
    bad_stems <- srt(intersect(stems, got))
    report(!length(bad_stems),
           sprintf("%s: no author-doubled stem is in `%s`", t$script, t$listname),
           paste(bad_stems, collapse = ", "))
  }
}

# ---------------------------------------------------------------- 6 provenance != veto
cat("\nDoubling is provenance, never a veto\n")

## Port of `.pat_match` in volumes_compiled_select.R: `*` = any, trailing `*` = prefix.
pat_match <- function(pattern, value) {
  p <- trimws(if (is.na(pattern)) "" else pattern)
  if (p == "" || p == "*") return(TRUE)
  if (endsWith(p, "*")) return(startsWith(if (is.na(value)) "" else value, substr(p, 1L, nchar(p) - 1L)))
  identical(p, value)
}

vf <- rd(file.path(MV, "volumes_select_value_flags.csv"))
skips <- character()
if (!is.null(vf) && nrow(vf)) {
  vf_action <- trimws(col(vf, "action"))
  vf_source <- col(vf, "Source")
  vf_var    <- col(vf, "Variable")
  parts <- strsplit(doubled_key, SEP, fixed = TRUE)
  for (i in which(vf_action == "skip"))
    for (p in parts)
      if (pat_match(vf_source[i], p[1]) && pat_match(vf_var[i], p[2]))
        skips <- c(skips, sprintf("%s/%s hits %s:%s", vf_source[i], vf_var[i], p[1], p[2]))
}
report(!length(skips),
       "no author-doubled column is skipped in the value-flag registry (wildcards expanded)",
       paste(skips, collapse = "; "))

# ---------------------------------------------------------------- 5 predicted vs actual flags
cat("\nPredicted `published_bilateral_estimate` rows\n")

predicted <- function(rows, source_key, keep = NULL) {
  if (is.null(rows) || !nrow(rows)) return(character())
  src <- col(rows, source_key); var <- col(rows, "Variable"); sp <- col(rows, "Species")
  idx <- seq_len(nrow(rows))
  if (!is.null(keep)) idx <- idx[keep(rows)[idx]]
  idx <- idx[paste(src[idx], var[idx], sep = SEP) %in% doubled_key]
  unique(paste(sp[idx], var[idx], sep = SEP))
}
actual <- function(path) {
  rows <- rd(path)
  if (is.null(rows)) return(NULL)
  if (!nrow(rows)) return(character())
  keep <- col(rows, "flag") == "published_bilateral_estimate"
  unique(paste(col(rows, "Species")[keep], col(rows, "Variable")[keep], sep = SEP))
}

jobs <- list(
  list(label = "volumes_compiled.R", src = "volumes_unfiltered.csv",
       keep = NULL, flags = "volumes_flags.csv"),
  list(label = "volumes_compiled_select.R", src = "volumes_resolution_audit_select.csv",
       keep = function(r) startsWith(col(r, "status"), "USED"), flags = "volumes_flags_select.csv"),
  list(label = "volumes_compiled_DeCasien.R", src = "volumes_unfiltered_DeCasien.csv",
       keep = NULL, flags = "volumes_flags_DeCasien.csv")
)
for (j in jobs) {
  exp <- predicted(rd(file.path(MV, j$src)), "Source", j$keep)
  got <- actual(file.path(MV, j$flags))
  cat(sprintf("  %s: expect %d row(s) from %s\n", j$label, length(exp), j$src))
  if (is.null(got)) {
    pending <- c(pending, sprintf("%s not found", j$flags))
    cat(sprintf("    [PEND] %s not found\n", j$flags))
  } else if (!length(got) && length(exp)) {
    pending <- c(pending, sprintf(
      "%s has no published_bilateral_estimate rows yet -- re-run %s in R, then re-run this check",
      j$flags, j$label))
    cat(sprintf("    [PEND] %s carries none yet -- re-run %s in R\n", j$flags, j$label))
  } else {
    missing <- srt(setdiff(exp, got)); extra <- srt(setdiff(got, exp))
    report(!length(missing) && !length(extra),
           sprintf("%s matches the prediction", j$flags),
           sprintf("missing %s extra %s", py_list(head(missing, 4L)), py_list(head(extra, 4L))))
  }
  for (k in head(srt(exp), 3L)) {
    p <- strsplit(k, SEP, fixed = TRUE)[[1]]
    cat(sprintf("      e.g. %s | %s\n", p[1], p[2]))
  }
  if (length(exp) > 3L) cat(sprintf("      ... and %d more\n", length(exp) - 3L))
}

# ---------------------------------------------------------------- summary
cat("\n")
if (length(fails)) {
  cat(sprintf("FAILED %d check(s): %s\n", length(fails), paste(fails, collapse = "; ")))
} else if (length(pending)) {
  cat("All checks pass. Pending (re-run the R merge, then re-run this script):\n")
  for (p in pending) cat(paste0("  - ", p, "\n"))
} else {
  cat("All checks pass.\n")
}
if (!interactive()) quit(status = if (length(fails)) 1L else 0L)
