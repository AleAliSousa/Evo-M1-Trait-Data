# body_ecology_compiled.R  --  whole-organism (body & ecology) merge.
#
# Four measure classes, harvested from __Public/comparative-data and pooled team/role-aware so the
# same specimens / compilations are never double-counted:
#
#   mass              Body_Mass (g)            -- every source table carrying a species body-mass
#                                                 column, auto-detected (see pick_column)
#   metabolic (body)  BMR_wholeanimal (mL O2/h), BMR_massspecific (mL O2/h/g, derived per row)
#   life_history      Maximum_longevity (yr), Gestation (d), Weaning_age (d), Litter_size,
#                     Female_sexual_maturity (d)
#   diet_ecology      Wilman 2014 EltonTraits: 10 diet %s + Diet_breadth (numeric);
#                     Diet_dominant / Trophic_guild / ForStrat_stratum / Activity_pattern
#                     (categorical -> pooled by MODE, not mean)
#
# Pipeline (mirrors __merging_cerebral_metabolic_rate):
#   1. pick the species-level column + unit per source     -> body_ecology_source_columns.csv (audit)
#   2. harvest -> resolve species -> canonical unit        -> body_ecology_unfiltered.csv
#   3. team-dedupe (same collection = one value), then pool across teams, primary preferred
#                                                          -> body_ecology_long.csv / _wide.csv
#   4. dedupe / disagreement report                        -> body_ecology_dedupe_report.csv
#
# HISTORY. This was previously a body-mass-only twin of build_body_ecology_merge.py, which carried
# the other three classes. That Python builder has been retired (2026-08-07) and its full scope
# folded in here, so this script is now the single implementation. `_checks/` holds a frozen copy of
# the Python's last output plus `check_body_ecology_against_fixture.py`, which diffs this script's
# CSVs against it — run that after any change to this file.

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

## ---- repo root: self-locating (Rscript, source(), or RStudio) --------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (!is.null(of) && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  NA_character_
})
repo <- local({
  d <- if (!is.na(.sp)) dirname(.sp) else normalizePath(getwd())
  while (dirname(d) != d && !dir.exists(file.path(d, "__Public"))) d <- dirname(d)
  if (dir.exists(file.path(d, "__Public"))) d
  else if (dir.exists("__Public")) "." else ".."   # legacy cwd fallback
})
pub <- file.path(repo, "__Public", "comparative-data")
out <- file.path(repo, "__merging_body_ecology")

norm    <- function(h) tolower(trimws(gsub('"', "", h)))
body_rx <- "(body.?mass|body.?weight|bodyweight|bo[wm]ass|bow_g|body_?wt)"
EXCLUDE <- c("source","ref","note","_sd"," sd","sem","dimorph","log","raw",
             "spinal","brain","assoc",": data","original")
SKIP    <- c("10.1016%2Fj.jhevol.2008.08.004_Table7.tsv")   # body-mass dimorphism (a ratio)
FACTOR  <- c(g = 1, kg = 1000, mg = 0.001)
# 1 mL O2 = 20.1 J; 1 kcal = 4184 J  =>  kcal/day -> mL O2/h
KCAL_DAY_TO_MLO2H <- 4184 / 20.1 / 24

# ---- lookups ---------------------------------------------------------------
manifest <- read.csv(file.path(repo, "__ShinyApp", "data", "source_manifest.csv"),
                     stringsAsFactors = FALSE, check.names = FALSE)
xwalk <- read.csv(file.path(repo, "_keys", "team_grouping_crosswalk.csv"),
                  stringsAsFactors = FALSE, check.names = FALSE)
team_ay <- list()                                   # (first_author, year) -> team
for (i in seq_len(nrow(xwalk))) {
  it <- xwalk[[1]][i]; tm <- xwalk[[2]][i]
  m <- regmatches(it, regexec("([A-Za-z]+).*?_((?:19|20)[0-9]{2})", it))[[1]]
  if (length(m) == 3 && nzchar(tm)) team_ay[[paste(tolower(m[2]), m[3])]] <- tm
}
vc <- read.csv(file.path(repo, "_keys", "variable_catalog.csv"),
               stringsAsFactors = FALSE, check.names = FALSE)
role_ay <- list()                                   # (first_author, year) -> role, body-mass rows
for (i in seq_len(nrow(vc))) {
  if (vc$measure_class[i] != "mass") next
  t <- tolower(paste(vc$Code[i], vc$Definition[i]))
  if (!grepl("body", t) || grepl("brain", t)) next
  m <- regmatches(vc$paper[i], regexec("([A-Za-z]+).*?((?:19|20)[0-9]{2})", vc$paper[i]))[[1]]
  if (length(m) == 3) { k <- paste(tolower(m[2]), m[3]); if (is.null(role_ay[[k]])) role_ay[[k]] <- vc$role[i] }
}
ref   <- read.csv(file.path(repo, "_keys", "species_reference.csv"), stringsAsFactors = FALSE)$accepted_name
ref_l <- setNames(ref, tolower(ref))
variant_l <- c()                                    # named character: lower variant -> accepted
for (kf in list.files(file.path(repo, "_keys"), pattern = "species_key.csv",
                      recursive = TRUE, full.names = TRUE)) {
  k <- read.csv(kf, stringsAsFactors = FALSE)
  if (all(c("variant_name", "accepted_name") %in% names(k))) {
    v <- tolower(trimws(k$variant_name)); a <- k$accepted_name
    ok <- nzchar(v) & nzchar(a) & !duplicated(v) & !(v %in% names(variant_l))
    variant_l <- c(variant_l, setNames(a[ok], v[ok]))       # first key wins, as in the Python
  }
}
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
# Vectorised: the Wilman table alone is 5,403 rows, so a scalar resolver is far too slow.
resolve <- function(x) {
  c0 <- clean_sp(x); lc <- tolower(c0)
  o <- unname(ref_l[lc])
  o2 <- unname(variant_l[lc])
  ifelse(!is.na(o), o, ifelse(!is.na(o2), o2, c0))
}

# ---- readers ---------------------------------------------------------------
read_tsv_rows <- function(path) {                   # -> list of character vectors, header first
  lines <- readLines(path, warn = FALSE)
  if (!length(lines)) return(NULL)
  strsplit(lines, "\t", fixed = TRUE)
}
cell <- function(rows, i) {                         # column i of the data rows, unquoted+trimmed
  vapply(rows, function(r) if (length(r) >= i) trimws(gsub('"', "", r[i])) else NA_character_,
         character(1))
}

pick_column <- function(headers) {
  cand <- headers[grepl(body_rx, norm(headers), perl = TRUE)]
  cand <- cand[!vapply(cand, function(h) any(vapply(EXCLUDE, function(e) grepl(e, norm(h), fixed = TRUE), logical(1))), logical(1))]
  cand <- cand[!grepl("^n[ _]", norm(cand)) & !grepl("sample_size", norm(cand))]
  if (!length(cand)) return(list(col = NA_character_, unit = NA_character_))
  if (any(grepl("(g)", norm(cand), fixed = TRUE))) cand <- cand[!grepl("(mg)", norm(cand), fixed = TRUE)]
  sp <- cand[grepl("species", norm(cand))]
  pick <- if (length(sp)) sp[1] else { c2 <- cand[!grepl("male|female", norm(cand))]; if (length(c2)) c2[1] else cand[1] }
  n <- norm(pick)
  list(col = pick,
       unit = if (grepl("kg", n)) "kg" else if (grepl("\\bmg\\b|\\(mg\\)|_mg", n)) "mg" else "g")
}

binom <- "^[A-Z][a-z]+ [a-z][a-z-]+"
species_col <- function(headers, sample) {
  # Which column holds the binomial? Score every column on the sample rows by how often its value
  # looks like "Genus species"; >= 0.5 wins. Otherwise Genus + Species epithet, otherwise a named
  # column, otherwise column 1. Returns a function(rows) -> character vector.
  score <- function(i) {
    v <- vapply(sample, function(r) if (length(r) >= i) trimws(gsub('"', "", r[i])) else "", character(1))
    v <- v[nzchar(v)]; if (!length(v)) 0 else mean(grepl(binom, v))
  }
  sc <- vapply(seq_along(headers), score, numeric(1)); best <- which.max(sc)
  if (length(best) && sc[best] >= 0.5) { i <- best; return(function(rows) cell(rows, i)) }
  g <- which(norm(headers) == "genus"); s <- which(norm(headers) %in% c("species", "species epithet"))
  if (length(g) && length(s)) { gi <- g[1]; si <- s[1]
    return(function(rows) trimws(paste(cell(rows, gi), cell(rows, si)))) }
  h <- which(norm(headers) %in% c("species","scientific","scientific name","taxon","binomial",
                                  "genus species","species name","species_name","animal"))
  i <- if (length(h)) h[1] else 1
  function(rows) cell(rows, i)
}

# One harvested block. `value` is already in the canonical unit.
blk <- function(species_raw, value, raw_value, raw_unit, mclass, measure, units,
                fn, author, year, team, role) {
  data.frame(Species = resolve(species_raw), Species_raw = species_raw,
             measure_class = mclass, Measure = measure, Units = units,
             Value_canonical = as.character(value), raw_value = raw_value, raw_unit = raw_unit,
             Source = fn, first_author = author, Year = year, Team = team, role = role,
             stringsAsFactors = FALSE)
}
keep_rows <- function(d) {                          # drop unusable species labels
  # NB is.na first: nzchar(NA_character_) is TRUE, so an NA species would otherwise survive.
  d[!is.na(d$Species) & nzchar(d$Species) & !(tolower(d$Species) %in% c("na", "none")), , drop = FALSE]
}
src_meta <- function(fn) {
  mi <- match(fn, manifest$file)
  author <- if (!is.na(mi)) manifest$first_author[mi] else ""
  year   <- if (!is.na(mi)) as.character(manifest$year[mi]) else ""
  list(author = author, year = year, ay = paste(tolower(author), year))
}

uf <- list(); colmap <- list()

# ---- 1. body mass, every table that has a body column ----------------------
for (path in sort(list.files(pub, pattern = "\\.tsv$", full.names = TRUE))) {
  fn <- basename(path)
  rows <- read_tsv_rows(path); if (is.null(rows)) next
  headers <- gsub('"', "", rows[[1]])
  if (!any(grepl(body_rx, norm(headers), perl = TRUE))) next
  pc <- if (fn %in% SKIP) list(col = NA_character_, unit = NA_character_) else pick_column(headers)
  m <- src_meta(fn)
  colmap[[length(colmap) + 1L]] <- data.frame(
    file = fn, first_author = m$author, year = m$year,
    chosen_column = if (is.na(pc$col)) "(none/skipped)" else pc$col,
    unit = if (is.na(pc$unit)) "" else pc$unit,
    all_body_columns = paste(headers[grepl(body_rx, norm(headers), perl = TRUE)], collapse = "; "),
    stringsAsFactors = FALSE)
  if (is.na(pc$col)) next
  ci <- match(pc$col, headers); drows <- rows[-1]; if (!length(drows)) next
  raw <- cell(drows, ci); val <- suppressWarnings(as.numeric(raw))
  ok <- !is.na(val); if (!any(ok)) next
  sp <- species_col(headers, drows[seq_len(min(length(drows), 59))])(drows)
  team <- team_ay[[m$ay]] %||% (if (nzchar(m$author)) m$author else fn)
  role <- role_ay[[m$ay]] %||% "secondary"
  uf[[length(uf) + 1L]] <- keep_rows(blk(sp[ok], val[ok] * FACTOR[[pc$unit]], raw[ok], pc$unit,
                                         "mass", "Body_Mass", "g", fn, m$author, m$year, team, role))
}

# ---- 2. BMR (whole-animal, plus mass-specific derived per row) -------------
# All four sources are compilations -> role "secondary".
BMR <- list(
  c("10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv", "BMR (ml O2/h)",        "mlO2h",    "Body mass (g)", "g"),
  c("10.1016%2Fj.jhevol.2017.09.003_Table1.tsv",  "BMR_kcal_day",         "kcal_day", "BM_g",          "g"),
  c("10.1111%2Fbrv.12350_TableS2.tsv",            "BMR.mlO2_h",           "mlO2h",    "Body_mass.g",   "g"),
  c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv", "Basal_metabolic_rate", "mlO2h",    "Body_weight",   "g"))
for (s in BMR) {
  fn <- s[1]; bcol <- s[2]; bunit <- s[3]; bmcol <- s[4]; bmunit <- s[5]
  path <- file.path(pub, fn); if (!file.exists(path)) next
  rows <- read_tsv_rows(path); if (is.null(rows)) next
  headers <- gsub('"', "", rows[[1]]); if (!(bcol %in% headers)) next
  bi <- match(bcol, headers); mi <- match(bmcol, headers)
  drows <- rows[-1]; if (!length(drows)) next
  raw <- cell(drows, bi); bval <- suppressWarnings(as.numeric(raw))
  ok <- !is.na(bval); if (!any(ok)) next
  wa <- if (bunit == "kcal_day") bval * KCAL_DAY_TO_MLO2H else bval
  sp <- species_col(headers, drows[seq_len(min(length(drows), 59))])(drows)
  m <- src_meta(fn); team <- team_ay[[m$ay]] %||% (if (nzchar(m$author)) m$author else fn)
  uf[[length(uf) + 1L]] <- keep_rows(blk(sp[ok], wa[ok], raw[ok], bunit, "metabolic (body)",
                                         "BMR_wholeanimal", "mL O2/h", fn, m$author, m$year, team, "secondary"))
  if (!is.na(mi)) {                                  # mass-specific = whole-animal / body mass
    bm <- suppressWarnings(as.numeric(cell(drows, mi)))
    ok2 <- ok & !is.na(bm) & bm > 0
    if (any(ok2))
      uf[[length(uf) + 1L]] <- keep_rows(blk(sp[ok2], wa[ok2] / bm[ok2], raw[ok2],
                                             paste0(bunit, "/", bmunit), "metabolic (body)",
                                             "BMR_massspecific", "mL O2/h/g", fn, m$author, m$year,
                                             team, "secondary"))
  }
}

# ---- 3. life history -------------------------------------------------------
# One canonical unit per measure; no cross-unit conversion. Weaning: lactation length is used as a
# weaning-age proxy (lactation ends at weaning), so it pools with weaning-period / time-to-weaning.
LIFE <- list(
  list("Maximum_longevity", "yr", c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv" = "Maximum_lifespan_yrs")),
  list("Gestation", "days", c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv" = "Gestation_days",
                              "10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv" = "Gestation length (d)",
                              "10.1073%2Fpnas.0905777106_TableS1.tsv"      = "Gestation (days)")),
  list("Weaning_age", "days", c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv" = "Weaning_period_days",
                                "10.1016%2Fj.jhevol.2008.08.004_TableS3.tsv" = "Lactation length (d)",
                                "10.3389%2Ffnins.2021.632853_TABLE1.tsv"     = "Time_to_weaning_days")),
  list("Litter_size", "count", c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv" = "Litter_size")),
  list("Female_sexual_maturity", "days", c("10.1371%2Fjournal.pbio.1002000_TableS1.tsv" = "Female_sexual_maturity_days")))
for (L in LIFE) {
  measure <- L[[1]]; units <- L[[2]]; srcmap <- L[[3]]
  for (fn in names(srcmap)) {
    col <- srcmap[[fn]]
    path <- file.path(pub, fn); if (!file.exists(path)) next
    rows <- read_tsv_rows(path); if (is.null(rows)) next
    headers <- gsub('"', "", rows[[1]]); if (!(col %in% headers)) next
    ci <- match(col, headers); drows <- rows[-1]; if (!length(drows)) next
    raw <- cell(drows, ci); v <- suppressWarnings(as.numeric(raw))
    ok <- !is.na(v) & v > 0; if (!any(ok)) next        # non-positive life-history values dropped
    sp <- species_col(headers, drows[seq_len(min(length(drows), 59))])(drows)
    m <- src_meta(fn); team <- team_ay[[m$ay]] %||% (if (nzchar(m$author)) m$author else fn)
    uf[[length(uf) + 1L]] <- keep_rows(blk(sp[ok], v[ok], raw[ok], units, "life_history",
                                           measure, units, fn, m$author, m$year, team, "secondary"))
  }
}

# ---- 4. diet & ecology (Wilman 2014 EltonTraits, 5,403 mammals) ------------
WILMAN <- "10.1890%2F13-1917.1_MamFuncDat.tsv"
DIET_PCT <- c("Diet_Inv","Diet_Vend","Diet_Vect","Diet_Vfish","Diet_Vunk",
              "Diet_Scav","Diet_Fruit","Diet_Nect","Diet_Seed","Diet_PlantO")
DIET_NUM <- c(DIET_PCT, "Diet_breadth")
DIET_CAT <- c("Diet_dominant","Trophic_guild","ForStrat_stratum","Activity_pattern")
wp <- file.path(pub, WILMAN)
if (file.exists(wp)) {
  rows <- read_tsv_rows(wp); headers <- gsub('"', "", rows[[1]]); drows <- rows[-1]
  sp <- species_col(headers, drows[seq_len(min(length(drows), 59))])(drows)
  m <- src_meta(WILMAN); team <- team_ay[[m$ay]] %||% (if (nzchar(m$author)) m$author else "Wilman")
  for (col in c(DIET_NUM, DIET_CAT)) {
    ci <- match(col, headers); if (is.na(ci)) next
    raw <- cell(drows, ci)
    ok <- !is.na(raw) & nzchar(raw) & !(tolower(raw) %in% c("na", "none", "nan"))
    units <- if (col %in% DIET_PCT) "%" else if (col == "Diet_breadth") "count" else "category"
    if (col %in% DIET_NUM) {
      v <- suppressWarnings(as.numeric(raw)); ok <- ok & !is.na(v)
      if (!any(ok)) next
      val <- v[ok]
    } else {
      if (!any(ok)) next
      val <- raw[ok]
    }
    uf[[length(uf) + 1L]] <- keep_rows(blk(sp[ok], val, raw[ok], units, "diet_ecology",
                                           col, units, WILMAN, m$author, m$year, team, "secondary"))
  }
}

uf <- do.call(rbind, uf)
colmap <- do.call(rbind, colmap)

# ---- pool: team-dedupe, then across teams (primary preferred) --------------
# Group on (Species, measure_class, Measure, Units). Numeric groups pool by mean (median also
# reported); categorical groups pool by MODE. Within a group, each Team contributes one value
# (its own mean), so a collection measured in several papers is not counted more than once; if any
# team is `primary`, only the primary teams are pooled.
gkey <- paste(uf$Species, uf$measure_class, uf$Measure, uf$Units, sep = "\r")
tkey <- paste(gkey, uf$Team, sep = "\r")
val  <- suppressWarnings(as.numeric(uf$Value_canonical))
is_num_row <- !is.na(val)
gi <- split(seq_len(nrow(uf)), gkey)                 # index vectors per group
gi <- gi[order(names(gi), method = "radix")]         # byte order, so runs are reproducible

# per_source is a diagnostic string, so its numbers are rendered the way Python's str(float) does
# ("2500.0", not "2500") — that keeps the column byte-comparable against the frozen fixture in
# _checks/, which is the only reason the formatting matters.
py_num <- function(x) { s <- as.character(x); ifelse(grepl("[.eE]", s), s, paste0(s, ".0")) }

pool_one <- function(ix) {
  d_team <- uf$Team[ix]; d_role <- uf$role[ix]
  if (length(ix) == 1L) {                # fast path: most groups are a single Wilman/Lewitus row
    one <- if (is_num_row[ix]) as.character(round(val[ix], 4)) else uf$Value_canonical[ix]
    return(list(Value = one, Value_median = one, n_sources = 1L, n_teams = 1L,
                n_teams_primary = as.integer(d_role == "primary"),
                Teams = d_team, roles = d_role,
                value_min = if (is_num_row[ix]) one else "",
                value_max = if (is_num_row[ix]) one else "",
                spread = "", flag = "",
                per_source = sprintf("%s%s(%s,%s)=%s", uf$first_author[ix], uf$Year[ix], d_team,
                                     d_role, if (is_num_row[ix]) py_num(round(val[ix], 3))
                                             else uf$Value_canonical[ix])))
  }
  teams <- unique(d_team)
  team_primary <- vapply(teams, function(t) any(d_role[d_team == t] == "primary"), logical(1))
  numeric_grp <- all(is_num_row[ix])
  if (numeric_grp) {
    v <- val[ix]
    team_val <- vapply(teams, function(t) mean(v[d_team == t]), numeric(1))
    used <- if (any(team_primary)) team_val[team_primary] else team_val
    pooled <- round(mean(used), 4); pooled_med <- round(median(used), 4)
    vmin <- as.character(round(min(v), 4)); vmax <- as.character(round(max(v), 4))
    spread <- if (min(v) > 0) max(v) / min(v) else NA_real_
    flag <- if (!is.na(spread) && spread > 2) "DISAGREEMENT>2x" else ""
    spread_out <- if (!is.na(spread)) as.character(round(spread, 2)) else ""
    per <- py_num(round(v, 3))
    pooled <- as.character(pooled); pooled_med <- as.character(pooled_med)
  } else {
    s <- uf$Value_canonical[ix]
    keep <- if (any(team_primary)) d_team %in% teams[team_primary] else rep(TRUE, length(ix))
    # levels in first-appearance order so a tie goes to the value seen first, as Counter does
    tb <- table(factor(s[keep], levels = unique(s[keep])))
    pooled <- names(tb)[which.max(tb)]
    pooled_med <- pooled; vmin <- ""; vmax <- ""
    flag <- if (length(unique(s)) > 1) "MULTIPLE" else ""
    spread_out <- ""; per <- s
  }
  list(Value = pooled, Value_median = pooled_med,
       n_sources = length(ix), n_teams = length(teams), n_teams_primary = sum(team_primary),
       # radix = C byte order, so team/role lists don't reorder with the machine's locale
       Teams = paste(sort(teams, method = "radix"), collapse = "; "),
       roles = paste(sort(unique(d_role), method = "radix"), collapse = "; "),
       value_min = vmin, value_max = vmax, spread = spread_out, flag = flag,
       per_source = paste(sprintf("%s%s(%s,%s)=%s", uf$first_author[ix], uf$Year[ix],
                                  d_team, d_role, per), collapse = " | "))
}
P <- lapply(gi, pool_one)
k <- do.call(rbind, strsplit(names(gi), "\r", fixed = TRUE))
g <- function(f) vapply(P, function(p) as.character(p[[f]]), character(1))
gn <- function(f) vapply(P, function(p) as.integer(p[[f]]), integer(1))

long <- data.frame(Species = k[, 1], measure_class = k[, 2], Measure = k[, 3], Units = k[, 4],
                   Value = g("Value"), Value_median = g("Value_median"),
                   n_sources = gn("n_sources"), n_teams = gn("n_teams"),
                   n_teams_primary = gn("n_teams_primary"),
                   primary_used = gn("n_teams_primary") > 0,
                   Teams = g("Teams"), roles = g("roles"),
                   value_min = g("value_min"), value_max = g("value_max"),
                   stringsAsFactors = FALSE, row.names = NULL)

multi <- long$n_sources > 1
dedupe <- data.frame(Species = long$Species[multi], Measure = long$Measure[multi],
                     Units = long$Units[multi], n_sources = long$n_sources[multi],
                     n_teams = long$n_teams[multi], pooled = long$Value[multi],
                     spread_max_over_min = g("spread")[multi], flag = g("flag")[multi],
                     per_source = g("per_source")[multi],
                     stringsAsFactors = FALSE, row.names = NULL)
dedupe <- dedupe[order(-dedupe$n_sources), ]

# ---- write -----------------------------------------------------------------
write.csv(colmap, file.path(out, "body_ecology_source_columns.csv"), row.names = FALSE)
write.csv(uf,     file.path(out, "body_ecology_unfiltered.csv"),     row.names = FALSE, na = "")
write.csv(long,   file.path(out, "body_ecology_long.csv"),           row.names = FALSE, na = "")
write.csv(dedupe, file.path(out, "body_ecology_dedupe_report.csv"),  row.names = FALSE, na = "")

# wide: one column per Measure, canonical unit in the name
WCOL <- c(Body_Mass = "Body_Mass.g", BMR_wholeanimal = "BMR_wholeanimal.mLO2h",
          BMR_massspecific = "BMR_massspecific.mLO2hg", Maximum_longevity = "Maximum_longevity.yr",
          Gestation = "Gestation.days", Weaning_age = "Weaning_age.days",
          Litter_size = "Litter_size", Female_sexual_maturity = "Female_sexual_maturity.days")
wide_cols <- c("Body_Mass.g","BMR_wholeanimal.mLO2h","BMR_massspecific.mLO2hg",
               "Maximum_longevity.yr","Gestation.days","Weaning_age.days","Litter_size",
               "Female_sexual_maturity.days", DIET_PCT, "Diet_breadth", DIET_CAT)
wname <- unname(ifelse(long$Measure %in% names(WCOL), WCOL[long$Measure], long$Measure))
spp <- unique(long$Species)
wide <- data.frame(Species = spp, stringsAsFactors = FALSE)
ri <- match(long$Species, spp)
for (cn in wide_cols) {
  v <- rep(NA_character_, length(spp)); sel <- wname == cn
  v[ri[sel]] <- long$Value[sel]; wide[[cn]] <- v
}
write.csv(wide, file.path(out, "body_ecology_wide.csv"), row.names = FALSE, na = "")

cat(sprintf("body-mass sources: %d\nunfiltered rows: %d  |  long rows: %d  |  species: %d\n",
            sum(colmap$chosen_column != "(none/skipped)"), nrow(uf), nrow(long), nrow(wide)))
tb <- table(paste0(long$measure_class, " / ", long$Measure, " (", long$Units, ")"))
for (nm in sort(names(tb))) cat(sprintf("   %5d  %s\n", tb[[nm]], nm))
cat(sprintf("disagreement>2x flags: %d\n", sum(dedupe$flag == "DISAGREEMENT>2x")))
