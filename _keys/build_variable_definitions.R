#!/usr/bin/env Rscript
# =============================================================================
# build_variable_definitions.R
#
# Builds _keys/variable_definitions.csv: one row per app-facing variable label,
# carrying its concept domain, its measure class, and a DEFINITION that a reader
# outside the source paper can understand.
#
# Why this exists: the app's variable labels are compositional. Only ~1 in 3
# resolves to a whole-label definition in a per-paper *_definitions.csv; the rest
# are <structure>_<measure-code> constructions (Amygdala_O.n, SpinalCord_p.C.CNS.
# neurons) whose two halves ARE documented, separately. This script resolves each
# label in four passes, most authoritative first, and records which pass won in
# `definition_kind` so a reader can tell a quoted source definition from a
# composed one:
#
#   1. source_definition  - whole-label hit in a per-paper *_definitions.csv
#                           (or _keys/variable_catalog.csv)
#   2. crosswalk          - app label differs from the source Code
#                           (Innovation_report_count -> Reader's `Innovation`).
#                           Disambiguated by source folder, because the same Code
#                           means different things in different papers: Reader's
#                           Tool_use is a report COUNT, Heldstab's is categorical
#                           and the definitions files say never to pool them.
#   3. composed           - <structure expansion> + <measure-code expansion>,
#                           both from glossary.csv
#   4. glossary           - the label itself is a glossary term
#
# Inputs : _keys/glossary.csv, _keys/variable_domain.csv,
#          _keys/variable_catalog.csv, */*_definitions.csv,
#          */reference_tables/*_definitions.csv
# Output : _keys/variable_definitions.csv
#
# Run from anywhere:  Rscript _keys/build_variable_definitions.R
# Re-run whenever a definitions file, the glossary, or variable_domain changes;
# then re-run __ShinyApp/build_data.R to bundle the result into the app.
# =============================================================================

args     <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
keys_dir <- if (length(file_arg)) dirname(normalizePath(file_arg)) else getwd()
repo     <- normalizePath(file.path(keys_dir, ".."))
message("repo: ", repo)

trim <- function(x) trimws(as.character(x))
# encoding="UTF-8" is load-bearing: source definitions quote micro signs, degree
# symbols and en-dashes (e.g. "Largest fiber diameter <micro>m"). Without it those
# bytes are read in the session locale and written back out as \u-escapes.
rd   <- function(p) tryCatch(
  read.csv(p, stringsAsFactors = FALSE, check.names = FALSE,
           colClasses = "character", encoding = "UTF-8"),
  error = function(e) NULL)

# ---- 1. the two authored keys ------------------------------------------------
glos <- rd(file.path(keys_dir, "glossary.csv"))
dom  <- rd(file.path(keys_dir, "variable_domain.csv"))
if (is.null(glos) || is.null(dom))
  stop("glossary.csv and variable_domain.csv are required.")
dom <- dom[!duplicated(dom$label), ]
message("glossary terms: ", nrow(glos), " | labels: ", nrow(dom))

g_exp <- setNames(trim(glos$expansion),  trim(glos$term))
g_def <- setNames(trim(glos$definition), trim(glos$term))
g_com <- setNames(toupper(trim(glos$common)) == "TRUE", trim(glos$term))
# `[[` on a named character vector ERRORS on a missing name rather than
# returning NULL, so every glossary read goes through these instead.
gx  <- function(tbl, k) { if (!nzchar(k)) return("")
                          v <- tbl[match(k, names(tbl))]
                          if (is.na(v)) "" else unname(v) }
gis <- function(k) isTRUE(unname(g_com[match(k, names(g_com))]))

# ---- 2. pool every definition in the repo -----------------------------------
# Two schemas are in use: the house one (Code,Definition,...) and a shorter
# `column,definition,unit` form. Read both rather than silently missing papers.
def_files <- c(
  list.files(repo, pattern = "_definitions\\.csv$", recursive = FALSE, full.names = TRUE),
  Sys.glob(file.path(repo, "*", "*_definitions.csv")),
  Sys.glob(file.path(repo, "*", "reference_tables", "*_definitions.csv")))
def_files <- unique(def_files)

pool <- list()
add <- function(code, defn, folder, file, role = "") {
  code <- trim(code); defn <- trim(defn)
  if (!nzchar(code) || !nzchar(defn) || tolower(code) == "nan") return()
  key <- paste0(code, "\r", folder)
  # keep the longest definition per (code, folder), preferring role=primary
  rl    <- tolower(trim(role)); if (is.na(rl)) rl <- ""
  score <- identical(rl, "primary") * 1e6 + nchar(defn)
  if (!is.finite(score)) score <- 0
  if (is.null(pool[[key]]) || pool[[key]]$score < score)
    pool[[key]] <<- list(code = code, defn = defn, folder = folder,
                         file = file, score = score)
}
n_alt <- 0L
for (f in def_files) {
  d <- rd(f); if (is.null(d) || !nrow(d)) next
  folder <- strsplit(sub(paste0("^", repo, "/"), "", f), "/")[[1]][1]
  rel    <- sub(paste0("^", repo, "/"), "", f)
  cl     <- tolower(names(d))
  if ("code" %in% cl && "definition" %in% cl) {
    cc <- names(d)[match("code", cl)]; dc <- names(d)[match("definition", cl)]
    rc <- if ("role" %in% cl) names(d)[match("role", cl)] else NA
    for (i in seq_len(nrow(d)))
      add(d[[cc]][i], d[[dc]][i], folder, rel,
          if (!is.na(rc)) d[[rc]][i] else "")
  } else {
    cc <- names(d)[match(c("column", "variable", "term")[
      c("column", "variable", "term") %in% cl][1], cl)]
    dc <- names(d)[match(c("definition", "description")[
      c("definition", "description") %in% cl][1], cl)]
    if (is.na(cc) || is.na(dc)) next
    n_alt <- n_alt + 1L
    for (i in seq_len(nrow(d))) add(d[[cc]][i], d[[dc]][i], folder, rel)
  }
}
# the built catalog, as a lower-priority backstop
cat_ <- rd(file.path(keys_dir, "variable_catalog.csv"))
if (!is.null(cat_))
  for (i in seq_len(nrow(cat_)))
    add(cat_$Code[i], cat_$Definition[i], trim(cat_$paper[i]),
        "_keys/variable_catalog.csv", cat_$role[i])
message("definitions pooled: ", length(pool), " from ", length(def_files),
        " files (", n_alt, " in the short column/definition schema)")

by_code <- split(pool, vapply(pool, function(p) p$code, character(1)))
pick <- function(code, folder_pat = NULL) {
  cs <- by_code[[code]]; if (is.null(cs)) return(NULL)
  if (!is.null(folder_pat))
    cs <- cs[vapply(cs, function(p) grepl(folder_pat, p$folder, fixed = TRUE), logical(1))]
  if (!length(cs)) return(NULL)
  cs[[which.max(vapply(cs, function(p) p$score, numeric(1)))]]
}

# ---- 3. crosswalk: app label -> (source Code, source folder) ----------------
# Only where the app's label differs from the Code the source paper printed.
# The folder is load-bearing: it is what keeps Reader's count-based Tool_use
# apart from Heldstab's categorical Tool_use (the definitions files for both say
# never to pool them).
XW <- rbind(
  c("Innovation_report_count (reports)",                   "Innovation",                      "Reader"),
  c("Innovation_reduced_report_count (reports)",           "Innovation_reduced",              "Reader"),
  c("Tool_use_report_count (reports)",                     "Tool_use",                        "Reader"),
  c("Tool_use_reduced_report_count (reports)",             "Tool_use_reduced",                "Reader"),
  c("Extractive_foraging_report_count (reports)",          "Extractive_foraging",             "Reader"),
  c("Extractive_foraging_reduced_report_count (reports)",  "Extractive_foraging_reduced",     "Reader"),
  c("Social_learning_report_count (reports)",              "Social_learning",                 "Reader"),
  c("Journal_search_article_count (articles)",             "Journal_search_article_count",    "Reader"),
  c("Zoological_record_article_count (articles)",          "Zoological_record_article_count", "Reader"),
  c("Handedness_index_mean (HI)",                          "MeanHI",                          "Caspar"),
  c("Handedness_strength_mean (abs(HI))",                  "MeanAbsHI",                       "Caspar"),
  c("peak_workspace (index)",                              "peak_workspace",                  "Baker"),
  c("real_size (index)",                                   "real_size",                       "Baker"),
  c("relative_size (index)",                               "relative_size",                   "Baker"),
  c("Tool_Manufacture (category)",                         "Tool_Manufacture",                "Baker"),
  c("True_Tool_Use (category)",                            "True_Tool_Use",                   "Baker"),
  # life-history measures renamed by the body/ecology merge to a canonical name
  # (the merge pools several source columns onto each; see body_ecology_compiled.R
  # LIFE). The Lewitus column is the one that carries a printed definition.
  c("Gestation (days)",                                    "Gestation_days",                  "Lewitus"),
  c("Female_sexual_maturity (days)",                       "Female_sexual_maturity_days",     "Lewitus"),
  # locomotion measures the behaviour merge renamed off Medina-Gonzalez's column
  # names. The source's own definitions file carries the meaning of each (the AUI
  # ones give the formula), so the definition should come from there rather than
  # being composed from the label. The folder pattern stops before the accented
  # character on purpose: macOS stores the folder name decomposed (o + combining
  # acute) while an R source literal is composed, and the match is fixed = TRUE.
  c("Angular_utilization_index_FL (percent)", "FL_Angular_Excursion_Efficiency_pct", "MedinaGonz"),
  c("Angular_utilization_index_HL (percent)", "HL_Angular_Excursion_Efficiency_pct", "MedinaGonz"),
  c("Limb_posture (category)",                "Posture",                             "MedinaGonz"),
  c("Top_speed (category)",                   "Top_speed_class",                     "MedinaGonz"))
colnames(XW) <- c("label", "code", "folder")
XW <- as.data.frame(XW, stringsAsFactors = FALSE)

# ---- 4. resolve every label -------------------------------------------------
strip_unit <- function(lab) sub("\\s*\\([^()]*\\)$", "", lab)
unit_of    <- function(lab) {
  m <- regmatches(lab, regexpr("\\(([^()]*)\\)$", lab))
  if (length(m)) gsub("^\\(|\\)$", "", m) else ""
}
# non-common glossary terms occurring in a label, longest first (these are what
# the app turns into tooltips)
terms_in <- function(lab) {
  tt <- names(g_exp)[order(nchar(names(g_exp)), decreasing = TRUE)]
  # split on separators; the class is spelled out (no en-dash literal) so this
  # stays locale-safe for labels like "Hand-eye" that carry non-ASCII bytes
  flat  <- iconv(lab, "UTF-8", "ASCII", sub = " ")
  if (is.na(flat)) flat <- lab
  parts <- strsplit(gsub("[()]", " ", flat), "[^A-Za-z0-9]+")[[1]]
  out <- character(0)
  for (t in tt) {
    if (gis(t)) next
    # suffix match on the literal term (fixed=TRUE avoids escaping the dots and
    # parentheses that measure codes like O.p.N and p.C.CNS.mass contain)
    suffix_hit <- nchar(lab) > nchar(t) &&
      substring(lab, nchar(lab) - nchar(t) + 1) == t &&
      substring(lab, nchar(lab) - nchar(t), nchar(lab) - nchar(t)) %in% c("_", " ")
    if (suffix_hit || t %in% parts) {
      if (!any(grepl(t, out, fixed = TRUE) & out != t)) out <- c(out, t)
    }
  }
  out
}

res <- lapply(seq_len(nrow(dom)), function(i) {
  r    <- dom[i, ]
  lab  <- r$label
  base <- strip_unit(lab)
  unit <- unit_of(lab)
  defn <- ""; kind <- "unresolved"; src <- ""; code <- ""

  # pass 1: whole-label definition
  for (k in unique(c(lab, base, gsub(" ", "_", base)))) {
    h <- pick(k)
    if (!is.null(h)) { defn <- h$defn; kind <- "source_definition"
                       src <- h$file; code <- k; break }
  }
  # pass 2: crosswalk
  if (!nzchar(defn)) {
    j <- match(lab, XW$label)
    if (!is.na(j)) {
      h <- pick(XW$code[j], XW$folder[j])
      if (!is.null(h)) { defn <- h$defn; kind <- "source_definition_crosswalk"
                         src <- h$file; code <- XW$code[j] }
    }
  }
  # pass 3a: the label's own base name is a glossary term. This runs BEFORE
  # composition because a hand-written entry beats a mechanical join: composing
  # `Body_Mass (g)` from its parts yields "Body: mass in grams", where the
  # glossary says "whole-animal body mass in grams" and notes which merge is
  # authoritative for it.
  if (!nzchar(defn) && nzchar(gx(g_def, base))) {
    defn <- gx(g_def, base); kind <- "glossary_definition"
    src <- "_keys/glossary.csv"; code <- base
  }
  # pass 3b: compose <structure> + <measure code> from the glossary
  if (!nzchar(defn)) {
    st <- if (nzchar(trim(r$canonical_structure))) trim(r$canonical_structure) else trim(r$Structure)
    mc <- trim(r$Measure)
    s_exp <- if (nzchar(st)) { e <- gx(g_exp, st); if (!nzchar(e)) gsub("_", " ", st) else e } else ""
    m_exp <- gx(g_exp, mc)
    if (nzchar(s_exp) && nzchar(m_exp)) {
      defn <- paste0(s_exp, ": ", m_exp); kind <- "composed"
      src <- "_keys/glossary.csv + _keys/variable_domain.csv"
    } else if (nzchar(s_exp) || nzchar(m_exp)) {
      # A bare structure name is a weak definition (`log10_mc1_mm` -> "hand").
      # Only accept it if pass 4b cannot do better from the label's own terms.
      cand <- paste0(s_exp, m_exp)
      tms0 <- terms_in(lab)
      ex0  <- vapply(tms0, function(t) gx(g_exp, t), character(1))
      ex0  <- ex0[nzchar(ex0)]
      if (length(ex0) >= 2 && sum(nchar(ex0)) > nchar(cand)) {
        defn <- ""                      # leave it to pass 4b
      } else {
        defn <- cand; kind <- "composed_structure_only"
        src <- "_keys/glossary.csv + _keys/variable_domain.csv"
      }
    }
  }
  # pass 4: last resort - concatenate the glossary terms the label contains
  tms <- terms_in(lab)
  if (!nzchar(defn) && length(tms)) {
    ex <- vapply(tms, function(t) gx(g_exp, t), character(1)); ex <- ex[nzchar(ex)]
    if (length(ex)) {
      defn <- paste0(paste(ex, collapse = ", "), if (nzchar(unit)) paste0(" (", unit, ")") else "")
      kind <- "composed_from_glossary"; src <- "_keys/glossary.csv"
    }
  }

  # poolable_group is passed straight through from variable_domain.csv. The app reads
  # THIS file, not variable_domain.csv, so a column that stops here never reaches the
  # tooltips or the Plot tab's incompatible-basis warning.
  data.frame(label = lab, domain = r$domain, measure_class = r$measure_class,
             Structure = r$canonical_structure, Measure = r$Measure, Unit = r$Unit,
             is_measurement = r$is_measurement,
             poolable_group = if ("poolable_group" %in% names(r)) r$poolable_group else "",
             definition = defn, definition_kind = kind, definition_source = src,
             matched_code = code, glossary_terms = paste(tms, collapse = "|"),
             stringsAsFactors = FALSE)
})
outd <- do.call(rbind, res)
outd <- outd[order(outd$domain, outd$measure_class, outd$label), ]

# Definitions quote source text carrying non-ASCII characters (micro sign, en-dash,
# modifier circumflex). Rscript often runs in the C locale, where write.csv cannot
# represent those and silently emits R's "<U+00B5>" display escapes into the file.
# So build the CSV text ourselves and write raw UTF-8 bytes, bypassing the locale.
csv_field <- function(x) {
  x <- ifelse(is.na(x), "", as.character(x))
  needs <- grepl('[",\n\r]', x)
  x[needs] <- paste0('"', gsub('"', '""', x[needs]), '"')
  x
}
lines <- c(
  paste(csv_field(names(outd)), collapse = ","),
  do.call(paste, c(lapply(outd, csv_field), sep = ",")))
con <- file(file.path(keys_dir, "variable_definitions.csv"), open = "wb")
writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
close(con)
message("labels resolved: ", sum(nzchar(outd$definition)), " / ", nrow(outd))
print(table(outd$definition_kind))
unres <- outd$label[!nzchar(outd$definition)]
if (length(unres)) {
  message("UNRESOLVED (", length(unres), ") - add a definition or a glossary term:")
  message(paste(" -", unres, collapse = "\n"))
}
message("DONE -> _keys/variable_definitions.csv")
