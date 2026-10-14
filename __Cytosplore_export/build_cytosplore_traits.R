# =============================================================================
# build_cytosplore_traits.R -- species-trait tables for the Cytosplore M1 viewer
#
# Re-runnable. Produces, for one named species cohort (default: EvoM1, the 25
# M1 RNA species in _keys/species_cohorts.csv), a set of flat CSV tables that a
# standalone viewer can ingest, plus a README describing them.
#
#   Rscript __Cytosplore_export/build_cytosplore_traits.R            # EvoM1
#   Rscript __Cytosplore_export/build_cytosplore_traits.R V1 0.8     # cohort, core threshold
#
# HOW IT GETS ITS DATA. It does not re-implement the harmonisation of the 17
# __merging_* domain tables. It evaluates the data-layer part of
# __ShinyApp/app.R (everything above `ui <- ...`) in a private environment and
# takes `compiled`, `cohorts`, `cohort_species()`, the variable-definition
# lookups and the taxonomy from there. So whatever the public Shiny app shows
# for a cohort is exactly what these tables hold -- same aliases
# (_keys/species_display_aliases.csv), same supersession
# (_keys/variable_canonical.csv), same label pooling (species_cohorts.csv
# `lookup_name`), same measurement-only filter (variable_definitions.csv
# `is_measurement`). If the app changes, re-run this and the export follows.
#
# EVOM1_SOURCE is forced to "local": the export is built from the checkout
# this script lives in, never from GitHub, so the numbers match the files you
# are looking at. Run __ShinyApp/build_data.R first if the ____EvoM1_TraitTable
# workbooks changed (that regenerates __ShinyApp/data/evom1_traits_long.csv).
#
# OUTPUT  (__Cytosplore_export/output/<cohort>/)
#   <cohort>_species.csv            one row per cohort species: names, taxonomy,
#                                   data labels pooled, per-domain variable counts
#   <cohort>_traits_long.csv        every value behind the cohort, one row per
#                                   species x variable x source value (provenance)
#   <cohort>_traits_cells.csv       one row per species x variable: the value
#                                   the wide table uses, how it was aggregated,
#                                   n values, min/max, sources
#   <cohort>_traits_wide.csv        species x variable matrix (all measurement
#                                   variables with >= 1 cohort species)
#   <cohort>_traits_wide_core.csv   same, restricted to variables covering
#                                   >= CORE_FRACTION of the cohort (default 0.8)
#   <cohort>_variable_dictionary.csv  one row per variable: domain, class,
#                                   structure, measure, unit, definition,
#                                   cohort coverage, in_core flag
#   <cohort>_domain_coverage.csv    species x domain: n distinct variables held
#   README.md                       what the tables are and how to read them
#   BUILD_INFO.txt                  timestamp, repo commit, row counts
#
# AGGREGATION RULE for the wide table (one cell per species x variable).
#   numeric  : arithmetic mean of all values the cohort species holds for that
#              variable across its pooled labels and sources (identical to the
#              Shiny app's plotting rule). n, min, max and sources are in
#              <cohort>_traits_cells.csv so the mean is never the only record.
#   categorical: the single distinct value if there is one; otherwise the
#              distinct values joined with " | " (the viewer should treat such
#              cells as unresolved, and the cells table flags them).
# =============================================================================

suppressPackageStartupMessages({ library(stats); library(utils) })

# The compiled labels and definitions contain non-ASCII characters (µ, en
# dashes, accented author names). In a C/POSIX locale write.csv() silently
# TRUNCATES such strings at the first high byte ("invalid char string in output
# conversion"). Insist on a UTF-8 locale, and mark every string UTF-8 before
# writing so the output is byte-exact regardless of how R was launched.
if (!isTRUE(l10n_info()[["UTF-8"]])) {
  ok <- FALSE
  for (loc in c("en_US.UTF-8", "C.UTF-8", "en_GB.UTF-8"))
    if (!inherits(try(Sys.setlocale("LC_CTYPE", loc), silent = TRUE), "try-error") &&
        isTRUE(l10n_info()[["UTF-8"]])) { ok <- TRUE; break }
  if (!ok) warning("Could not switch to a UTF-8 locale; non-ASCII characters may be mangled.")
}
mark_utf8 <- function(d) {
  names(d) <- { n <- names(d); Encoding(n) <- "UTF-8"; n }
  for (j in seq_along(d)) if (is.character(d[[j]])) Encoding(d[[j]]) <- "UTF-8"
  d
}

args <- commandArgs(trailingOnly = TRUE)
COHORT        <- if (length(args) >= 1 && nzchar(args[1])) args[1] else "EvoM1"
CORE_FRACTION <- if (length(args) >= 2) as.numeric(args[2]) else 0.8
if (is.na(CORE_FRACTION) || CORE_FRACTION <= 0 || CORE_FRACTION > 1)
  stop("CORE_FRACTION must be in (0, 1]; got ", args[2])

# Domains that variable_definitions.csv marks as measurements but that are not
# properties of the animal (literature article counts per species). Kept in
# the long table, excluded from the wide/cells/dictionary tables.
EXCLUDE_DOMAINS <- c("dataset metadata")

# Advisory flag for the viewer: variables about M1 / the motor system / manual
# dexterity. A regex on label + structure + definition, so review the flagged
# set (dictionary column m1_motor_related) rather than trusting it blindly.
M1_PATTERN <- paste0("\\bM1\\b|[Mm]otor|[Cc]orticospin|[Pp]yramidal tract|\\bCST\\b|",
                     "[Dd]exterity|Area_?4\\b|Brodmann_?4\\b|[Pp]recentral|",
                     "[Hh]and|[Dd]igit|[Mm]anipulat|[Gg]rasp|[Pp]recision grip|",
                     "[Ff]orelimb|[Hh]indlimb|[Ll]ocomot|[Gg]ait|[Ll]imb")

# ---- locate the repo ---------------------------------------------------------
script_path <- {
  f <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(f)) normalizePath(sub("^--file=", "", f[1])) else NA_character_
}
find_repo <- function(start) {
  d <- normalizePath(start)
  for (i in 1:6) {
    if (dir.exists(file.path(d, "_keys")) && dir.exists(file.path(d, "__ShinyApp")))
      return(d)
    d <- dirname(d)
  }
  NA_character_
}
repo_root <- if (!is.na(script_path)) find_repo(dirname(script_path)) else find_repo(getwd())
if (is.na(repo_root))
  stop("Cannot find the Evo-M1-Trait-Data repo root (a folder containing _keys/ and __ShinyApp/). ",
       "Run from inside the repo or via its path.")
app_dir <- file.path(repo_root, "__ShinyApp")
out_dir <- file.path(repo_root, "__Cytosplore_export", "output", COHORT)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
message("repo:   ", repo_root)
message("cohort: ", COHORT, "   core threshold: ", CORE_FRACTION)

# ---- evaluate the Shiny app's data layer ------------------------------------
# Everything in app.R above `ui <- page_navbar(...)` is data loading and keys.
# Evaluate exactly that prefix in a private environment. If the app is ever
# restructured so `ui <-` is not a top-level assignment, fail loudly.
Sys.setenv(EVOM1_SOURCE = "local")
old_wd <- setwd(app_dir); on.exit(setwd(old_wd), add = TRUE)
exprs <- parse(file.path(app_dir, "app.R"), keep.source = FALSE)
is_assign_to <- function(e, nm) {
  is.call(e) && (identical(e[[1]], as.name("<-")) || identical(e[[1]], as.name("="))) &&
    is.name(e[[2]]) && identical(as.character(e[[2]]), nm)
}
ui_at <- which(vapply(exprs, is_assign_to, logical(1), nm = "ui"))
if (length(ui_at) != 1L)
  stop("Expected exactly one top-level `ui <- ...` in __ShinyApp/app.R; found ", length(ui_at))
app <- new.env(parent = globalenv())
# suppress the Shiny/bslib attach messages; keep everything else
suppressPackageStartupMessages(
  for (i in seq_len(ui_at - 1L)) eval(exprs[[i]], envir = app)
)
setwd(old_wd)

need <- c("compiled", "cohorts", "cohort_species", "cohort_cov", "cohort_domain_matrix",
          "cohort_trait_table", "meas_labels", "var_dom", "lab_class", "lab_struct",
          "lab_meas", "lab_unit", "lab_def", "lab_defsrc", "lab_pool", "lab_family",
          "lab_ismeas", "look", "taxonomy", "domain_levels")
missing <- need[!vapply(need, exists, logical(1), envir = app, inherits = FALSE)]
if (length(missing))
  stop("app.R data layer did not define: ", paste(missing, collapse = ", "),
       ". The app has changed; update this script to match.")
if (is.null(app$cohorts) || !COHORT %in% app$cohorts$cohort)
  stop("Cohort '", COHORT, "' is not defined in _keys/species_cohorts.csv. Available: ",
       paste(unique(app$cohorts$cohort), collapse = ", "))

compiled <- app$compiled
key      <- app$cohort_species(COHORT)        # one row per cohort species, with $labels
n_sp     <- nrow(key)
message("species in cohort: ", n_sp)

# ---- species table ------------------------------------------------------------
# label -> cohort species map (a species may pool several data labels)
lab_map <- data.frame(
  data_label  = unlist(key$labels, use.names = FALSE),
  species_sci = rep(key$species_sci, lengths(key$labels)),
  stringsAsFactors = FALSE)

tax <- app$taxonomy
tax_of <- function(sci, col) {
  if (is.null(tax)) return(rep(NA_character_, length(sci)))
  # try the cohort name, then each pooled data label, then the binomial prefix
  vapply(seq_along(sci), function(i) {
    cands <- c(sci[i], key$labels[[i]], paste(strsplit(sci[i], "\\s+")[[1]][1:2], collapse = " "))
    hit <- tax[[col]][match(cands, tax$Species)]
    hit <- hit[!is.na(hit) & nzchar(hit)]
    if (length(hit)) hit[1] else NA_character_
  }, character(1))
}

dm   <- app$cohort_domain_matrix(COHORT)
dmat <- dm$mat                                  # species x domain, n distinct variables
colnames(dmat) <- paste0("n_vars__", gsub("[^A-Za-z0-9]+", "_", colnames(dmat)))

p_cov <- app$cohort_cov(key)                    # species_sci x Variable (measurement only)
p_cov <- p_cov[p_cov$Variable %in% app$meas_labels, , drop = FALSE]
n_vars_total <- as.integer(table(factor(p_cov$Species, levels = key$species_sci)))

species_tbl <- data.frame(
  species_sci       = key$species_sci,
  common_name       = key$common_name,
  Order             = tax_of(key$species_sci, "Order"),
  Family            = tax_of(key$species_sci, "Family"),
  data_labels       = key$label_str,
  n_data_labels     = lengths(key$labels),
  in_data           = key$in_data,
  n_variables       = n_vars_total,
  pct_of_variables  = round(100 * n_vars_total / length(app$meas_labels), 1),
  lookup_basis      = if ("lookup_basis" %in% names(key)) key$lookup_basis else "",
  uncounted_name_variants = key$variants,
  note              = if ("note" %in% names(key)) key$note else "",
  stringsAsFactors  = FALSE)
species_tbl <- cbind(species_tbl, as.data.frame(dmat, stringsAsFactors = FALSE))
rownames(species_tbl) <- NULL

# ---- long table (all values, with provenance) --------------------------------
long <- compiled[compiled$Species %in% lab_map$data_label, , drop = FALSE]
long$species_sci <- lab_map$species_sci[match(long$Species, lab_map$data_label)]
lk <- function(map, k) app$look(map, k)
long_out <- data.frame(
  species_sci    = long$species_sci,
  common_name    = key$common_name[match(long$species_sci, key$species_sci)],
  data_label     = long$Species,
  variable       = long$Variable,
  domain         = unname(app$var_dom[long$Variable]),
  measure_class  = lk(app$lab_class,  long$Variable),
  structure      = lk(app$lab_struct, long$Variable),
  measure        = lk(app$lab_meas,   long$Variable),
  unit           = ifelse(!is.na(long$Unit) & nzchar(long$Unit), long$Unit,
                          lk(app$lab_unit, long$Variable)),
  value          = long$Value,
  value_num      = long$Value_num,
  is_measurement = long$Variable %in% app$meas_labels,
  dataset        = long$Dataset,
  source         = long$Source,
  n_sources      = long$N_sources,
  poolable_group = lk(app$lab_pool, long$Variable),
  stringsAsFactors = FALSE)
long_out <- long_out[order(long_out$species_sci, long_out$domain, long_out$variable), ]
rownames(long_out) <- NULL

# ---- per-cell summary + wide matrix (measurement variables only) -------------
meas <- long_out[long_out$is_measurement & !long_out$domain %in% EXCLUDE_DOMAINS, , drop = FALSE]
cell_key <- paste(meas$species_sci, meas$variable, sep = "\r")
summ <- function(idx) {
  v  <- meas$value[idx]; vn <- meas$value_num[idx]
  numeric_ok <- all(!is.na(vn))
  if (numeric_ok) {
    used <- if (length(vn) == 1L) formatC(vn, format = "g", digits = 10) else
      formatC(mean(vn), format = "g", digits = 10)
    agg  <- if (length(vn) == 1L) "single" else sprintf("mean of %d", length(vn))
    vmin <- min(vn); vmax <- max(vn); unresolved <- FALSE
  } else {
    dv <- unique(trimws(v)); dv <- dv[nzchar(dv)]
    used <- paste(dv, collapse = " | ")
    agg  <- if (length(dv) == 1L) "categorical: single" else "categorical: multiple"
    vmin <- NA_real_; vmax <- NA_real_; unresolved <- length(dv) > 1L
  }
  data.frame(
    species_sci = meas$species_sci[idx[1]],
    variable    = meas$variable[idx[1]],
    value_used  = used,
    value_used_num = if (numeric_ok) as.numeric(used) else NA_real_,
    aggregation = agg,
    n_values    = length(idx),
    n_data_labels = length(unique(meas$data_label[idx])),
    value_min   = vmin, value_max = vmax,
    spread_pct  = if (numeric_ok && length(vn) > 1L && mean(vn) != 0)
                    round(100 * (vmax - vmin) / abs(mean(vn)), 1) else NA_real_,
    unresolved_categorical = unresolved,
    datasets    = paste(sort(unique(meas$dataset[idx])), collapse = " | "),
    sources     = paste(sort(unique(meas$source[idx])),  collapse = " | "),
    stringsAsFactors = FALSE)
}
cells <- do.call(rbind, lapply(split(seq_len(nrow(meas)), cell_key), summ))
cells$domain        <- unname(app$var_dom[cells$variable])
cells$unit          <- lk(app$lab_unit, cells$variable)
cells <- cells[order(cells$species_sci, cells$domain, cells$variable), ]
rownames(cells) <- NULL

# variable order: domain (in the app's domain order), then label
dom_rank <- setNames(seq_along(app$domain_levels), app$domain_levels)
vars_present <- unique(cells$variable)
vars_present <- vars_present[order(dom_rank[unname(app$var_dom[vars_present])], vars_present)]

wide <- data.frame(species_sci = key$species_sci,
                   common_name = key$common_name,
                   stringsAsFactors = FALSE, check.names = FALSE)
for (v in vars_present) {
  m <- cells[cells$variable == v, , drop = FALSE]
  col <- m$value_used[match(wide$species_sci, m$species_sci)]
  # numeric column if every filled cell is numeric, else character
  if (all(!is.na(m$value_used_num))) col <- as.numeric(col)
  wide[[v]] <- col
}

# ---- variable dictionary --------------------------------------------------------
tt <- app$cohort_trait_table(COHORT)            # Variable, Domain, Species_with_data, Pct, Missing
tt <- tt[tt$Variable %in% vars_present, , drop = FALSE]
ds_of <- vapply(split(meas$dataset, meas$variable), function(x)
  paste(sort(unique(x)), collapse = " | "), character(1))
# Unit resolution, in order of authority: the authored key
# (_keys/variable_domain.csv -> variable_definitions.csv), then the Units
# column the merge itself carries (long rows), then the unit the label spells
# out (".mm3", "(um)", ".deg"). unit_source records which one was used so a key
# gap is visible rather than silently papered over.
unit_from_rows <- vapply(split(meas$unit, meas$variable), function(u) {
  u <- unique(u[!is.na(u) & nzchar(u)]); if (length(u) == 1L) u else "" }, character(1))
unit_from_label <- function(v) {
  m <- regmatches(v, regexec("\\(([^()]+)\\)\\s*$", v))[[1]]
  if (length(m) == 2L) return(m[2])
  m <- regmatches(v, regexec("[._]([A-Za-z0-9/]+)$", v))[[1]]
  if (length(m) == 2L && m[2] %in% c("mm3","mm2","mm","cm3","mL","ml","g","mg","kg","um","nm",
                                     "ms","us","Hz","kHz","deg","cdeg","octaves","days","mnths",
                                     "yr","ha","percent")) return(m[2])
  ""
}
u_key  <- lk(app$lab_unit, tt$Variable)
u_rows <- unname(unit_from_rows[tt$Variable]); u_rows[is.na(u_rows)] <- ""
u_lab  <- vapply(tt$Variable, unit_from_label, character(1))
unit_res <- ifelse(nzchar(u_key), u_key, ifelse(nzchar(u_rows), u_rows, u_lab))
unit_src <- ifelse(nzchar(u_key), "variable_definitions.csv",
            ifelse(nzchar(u_rows), "merge Units column",
            ifelse(nzchar(u_lab), "parsed from label", "none")))
dict <- data.frame(
  variable          = tt$Variable,
  domain            = tt$Domain,
  measure_class     = lk(app$lab_class,  tt$Variable),
  structure         = lk(app$lab_struct, tt$Variable),
  measure           = lk(app$lab_meas,   tt$Variable),
  unit              = unit_res,
  unit_source       = unit_src,
  poolable_group    = lk(app$lab_pool,   tt$Variable),
  poolable_family   = lk(app$lab_family, tt$Variable),
  definition        = lk(app$lab_def,    tt$Variable),
  definition_source = lk(app$lab_defsrc, tt$Variable),
  datasets          = unname(ds_of[tt$Variable]),
  species_with_data = tt$Species_with_data,
  pct_cohort        = tt$Pct,
  in_core           = tt$Species_with_data >= ceiling(CORE_FRACTION * n_sp),
  missing_species   = tt$Missing_species,
  stringsAsFactors  = FALSE)
dict$m1_motor_related <- grepl(M1_PATTERN,
  paste(dict$variable, dict$structure, dict$measure_class, dict$definition))
dict <- dict[order(dom_rank[dict$domain], dict$variable), ]
rownames(dict) <- NULL

core_vars <- dict$variable[dict$in_core]
wide_core <- wide[, c("species_sci", "common_name", core_vars), drop = FALSE]

# ---- domain coverage ------------------------------------------------------------
dom_cov <- as.data.frame(dm$mat, stringsAsFactors = FALSE)
dom_cov <- cbind(species_sci = rownames(dm$mat), dom_cov, stringsAsFactors = FALSE)
rownames(dom_cov) <- NULL

# ---- write ----------------------------------------------------------------------
wcsv <- function(d, name) {
  f <- file.path(out_dir, paste0(COHORT, "_", name, ".csv"))
  d <- mark_utf8(d)
  write.csv(d, f, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  # guard: a C-locale write truncates strings silently; make sure the header
  # round-trips with the right number of columns
  hdr <- strsplit(readLines(f, n = 1L, encoding = "UTF-8"), "\",\"", fixed = TRUE)[[1]]
  if (length(hdr) != ncol(d))
    stop("Header of ", basename(f), " has ", length(hdr), " fields, expected ", ncol(d),
         " -- a string was truncated on write (locale/encoding problem).")
  message(sprintf("  wrote %-38s %6d rows x %4d cols", basename(f), nrow(d), ncol(d)))
  f
}
f_species <- wcsv(species_tbl, "species")
f_long    <- wcsv(long_out,    "traits_long")
f_cells   <- wcsv(cells,       "traits_cells")
f_wide    <- wcsv(wide,        "traits_wide")
f_core    <- wcsv(wide_core,   "traits_wide_core")
f_dict    <- wcsv(dict,        "variable_dictionary")
f_dom     <- wcsv(dom_cov,     "domain_coverage")

# ---- build info --------------------------------------------------------------------
git_rev <- tryCatch(
  system2("git", c("-C", shQuote(repo_root), "log", "-1", "--format=%h %ci"),
          stdout = TRUE, stderr = FALSE), error = function(e) character(0))
if (!length(git_rev) || !nzchar(git_rev[1])) {
  # git may be unavailable; read the checked-out HEAD directly
  head_f <- file.path(repo_root, ".git", "HEAD")
  git_rev <- "unknown (not a git checkout)"
  if (file.exists(head_f)) {
    h <- readLines(head_f, warn = FALSE)[1]
    if (startsWith(h, "ref: ")) {
      ref_f <- file.path(repo_root, ".git", sub("^ref: ", "", h))
      if (file.exists(ref_f)) h <- readLines(ref_f, warn = FALSE)[1]
    }
    git_rev <- paste0(substr(h, 1, 7), " (from .git/HEAD; git command unavailable)")
  }
}
git_rev <- git_rev[1]
fill_pct <- round(100 * nrow(cells) / (n_sp * length(vars_present)), 1)
fill_pct_core <- if (length(core_vars))
  round(100 * sum(cells$variable %in% core_vars) / (n_sp * length(core_vars)), 1) else NA
no_data <- key$species_sci[!key$in_data]
by_dom <- aggregate(variable ~ domain, dict, length)
by_dom$core <- as.integer(tapply(dict$in_core, dict$domain, sum)[by_dom$domain])
by_dom$m1   <- as.integer(tapply(dict$m1_motor_related, dict$domain, sum)[by_dom$domain])
by_dom <- by_dom[order(dom_rank[by_dom$domain]), ]

info <- c(
  sprintf("built:           %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("repo commit:     %s", git_rev),
  sprintf("cohort:          %s (%d species)", COHORT, n_sp),
  sprintf("core threshold:  >= %.0f%% of cohort (>= %d species)", 100 * CORE_FRACTION,
          ceiling(CORE_FRACTION * n_sp)),
  sprintf("species without any data: %s",
          if (length(no_data)) paste(no_data, collapse = "; ") else "none"),
  sprintf("long rows (all values):   %d", nrow(long_out)),
  sprintf("  of which measurement:   %d", nrow(meas)),
  sprintf("species x variable cells: %d", nrow(cells)),
  sprintf("variables in wide:        %d   (matrix fill %.1f%%)", length(vars_present), fill_pct),
  sprintf("variables in wide_core:   %d   (matrix fill %.1f%%)", length(core_vars), fill_pct_core),
  sprintf("cells unresolved categorical: %d", sum(cells$unresolved_categorical)),
  sprintf("cells with numeric spread > 50%%: %d",
          sum(!is.na(cells$spread_pct) & cells$spread_pct > 50)),
  sprintf("units: %d from key, %d from merge rows, %d parsed from label, %d none",
          sum(dict$unit_source == "variable_definitions.csv"), sum(dict$unit_source == "merge Units column"),
          sum(dict$unit_source == "parsed from label"), sum(dict$unit_source == "none")),
  sprintf("variables flagged m1_motor_related: %d (of which core: %d)",
          sum(dict$m1_motor_related), sum(dict$m1_motor_related & dict$in_core)),
  sprintf("domains excluded from wide/cells/dictionary: %s", paste(EXCLUDE_DOMAINS, collapse = "; ")),
  "", "variables per domain (all / core / m1_motor_related):",
  sprintf("  %-32s %4d / %4d / %4d", by_dom$domain, by_dom$variable, by_dom$core, by_dom$m1))
writeLines(enc2utf8(info), file.path(out_dir, "BUILD_INFO.txt"), useBytes = TRUE)
cat(paste(info, collapse = "\n"), "\n")

# ---- README --------------------------------------------------------------------------
md_tbl <- function(d) {
  d[] <- lapply(d, function(x) gsub("|", "\\|", as.character(x), fixed = TRUE))
  c(paste0("| ", paste(names(d), collapse = " | "), " |"),
    paste0("|", paste(rep("---", ncol(d)), collapse = "|"), "|"),
    apply(d, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
}
sp_show <- species_tbl[, c("species_sci", "common_name", "Order", "n_variables", "data_labels")]
readme <- c(
  sprintf("# %s species-trait tables for the Cytosplore M1 viewer (DRAFT)", COHORT),
  "",
  sprintf("Built %s from Evo-M1-Trait-Data commit `%s` by `__Cytosplore_export/build_cytosplore_traits.R`.",
          format(Sys.time(), "%Y-%m-%d"), git_rev),
  "Re-run that script to regenerate everything here; do not edit these CSVs by hand.",
  "",
  "## What this is",
  "",
  sprintf(paste(
    "Comparative species traits for the %d-species `%s` cohort (`_keys/species_cohorts.csv`),",
    "drawn from the harmonised Evo-M1-Trait-Data compilation exactly as the public Shiny app",
    "serves it. Only *measurement* variables are in the wide tables (QC flags and provenance",
    "strings are excluded). Species names are the cohort's own names, i.e. the names the",
    "RNA dataset uses -- join on `species_sci`."), n_sp, COHORT),
  "",
  "## Files",
  "",
  "| file | one row per | use |",
  "|---|---|---|",
  sprintf("| `%s` | species (%d) | species list, taxonomy, which data labels were pooled, per-domain counts |", basename(f_species), n_sp),
  sprintf("| `%s` | species x variable (%d) | **recommended viewer input**: species x trait matrix, one value per cell |", basename(f_wide), length(vars_present)),
  sprintf("| `%s` | species x variable (%d) | same, only traits held for >= %d of %d species (`in_core`) |", basename(f_core), length(core_vars), ceiling(CORE_FRACTION * n_sp), n_sp),
  sprintf("| `%s` | variable (%d) | column metadata for the wide tables: domain, structure, measure, unit, definition, coverage |", basename(f_dict), nrow(dict)),
  sprintf("| `%s` | species x variable cell (%d) | how each wide cell was made: n values, aggregation, min/max, sources |", basename(f_cells), nrow(cells)),
  sprintf("| `%s` | value (%d) | full provenance: every source value behind every cell |", basename(f_long), nrow(long_out)),
  sprintf("| `%s` | species | n distinct variables per domain |", basename(f_dom)),
  "| `BUILD_INFO.txt` | - | build stamp and counts |",
  "",
  "Source audit (run `python3 __Cytosplore_export/audit_cytosplore_variables.py` after this script):",
  "",
  "| file | one row per | use |",
  "|---|---|---|",
  sprintf("| `%s_variable_audit.csv` | variable | contributing papers and roles, compilation-only cells, primary availability, poolability, `suggested_tier`, `source_class`, flags |", COHORT),
  sprintf("| `%s_secondary_only_cells.csv` | species x variable | cells fed only by compilations, with whether a primary exists in the same group |", COHORT),
  sprintf("| `%s_pooling_candidates.csv` | compatibility group | variables measuring the same quantity; gain if pooled; bases that must not be pooled |", COHORT),
  "| `AUDIT_SUMMARY.md` | - | the audit's headline numbers and flagged cases |",
  "",
  "## How a wide cell is filled",
  "",
  "- A cohort species may hold data under several labels (e.g. *Gorilla gorilla gorilla*, *Gorilla gorilla*,",
  "  *Gorilla sp.*). Which labels are pooled is decided in `_keys/species_cohorts.csv` (`lookup_name`,",
  "  with the reason in `lookup_basis`), not here. `data_labels` in the species table lists them.",
  "- Numeric: arithmetic mean of all values across pooled labels and sources (the Shiny app's plotting",
  "  rule). `n_values`, `value_min`, `value_max`, `spread_pct` and `sources` are in the cells table.",
  "  Cells with `spread_pct` > 50 deserve a look before being shown as a point estimate.",
  "- Categorical (diet, locomotion, ...): the single distinct value, or distinct values joined with",
  "  ` | ` and `unresolved_categorical = TRUE` in the cells table.",
  "- `m1_motor_related` in the dictionary is an advisory regex flag (M1, motor, corticospinal, dexterity,",
  "  hand/limb, locomotion terms) to help pick the traits most relevant to a motor-cortex viewer.",
  sprintf("- Domain(s) excluded from the wide tables as not being animal traits: %s (still in the long table).",
          paste(EXCLUDE_DOMAINS, collapse = "; ")),
  "- Brain-size variables are kept on separate measurement bases (weighed mass, mass excluding",
  "  olfactory bulbs, endocranial volume, sum of parts, ...). `poolable_group` in the dictionary says",
  "  which columns are the same quantity; do not average across groups.",
  "",
  "## Species",
  "",
  md_tbl(sp_show),
  "",
  if (length(no_data)) c(sprintf("Species with no data under their cohort name: %s.", paste(no_data, collapse = "; ")), "") else character(0),
  "## Variables per domain (all / core / M1-motor flagged)",
  "",
  md_tbl(setNames(by_dom, c("domain", "variables", "core", "m1_motor"))),
  "",
  "## Known caveats carried over from the compilation",
  "",
  "- `_keys/README_species_cohorts.md` records open name-fragmentation rulings (e.g. ferret",
  "  *Mustela putorius furo* vs polecat *M. putorius*; *Sus scrofa* re-pointed to the domestic form).",
  "  The `uncounted_name_variants` column in the species table lists, per species, labels that hold",
  "  data but are **not** counted because no ruling has adopted them.",
  "- Coverage is availability, not agreement: a cell is filled if any source gives a value.",
  "- Values are as compiled; see the source TSVs under `__Public/comparative-data/` and the per-merge",
  "  READMEs under `__merging_*/` for method and provenance detail.",
  "",
  "## Regenerating",
  "",
  "```",
  "Rscript __ShinyApp/build_data.R                       # only if ____EvoM1_TraitTable/*.xlsx changed",
  sprintf("Rscript __Cytosplore_export/build_cytosplore_traits.R %s %.2f", COHORT, CORE_FRACTION),
  "```")
writeLines(enc2utf8(readme), file.path(out_dir, "README.md"), useBytes = TRUE)
message("done -> ", out_dir)
