# ecology_compiled.R  --  ecology merge: diet, foraging strata and activity pattern.
#
# Split 2026-11-21 from body_ecology_compiled.R (the old __merging_body_ecology merge).
# This merge keeps the old script's diet_ecology class, unchanged:
#
#   diet_ecology      Wilman 2014 EltonTraits: 10 diet %s + Diet_breadth (numeric);
#                     Diet_dominant / Trophic_guild / ForStrat_stratum / Activity_pattern
#                     (categorical -> pooled by MODE, not mean), plus the Galan-Acedo
#                     et al. 2019 diel-activity gap-fill for Activity_pattern (section 4b,
#                     carried over verbatim from the combined script, where it was added
#                     2026-11-20): Wilman wins wherever it has a species-level value.
#   Imputed values are not served (owner decision of 24 November 2026): diet and activity
#   values that EltonTraits took from the genus or family average (certainty D1 / D2) are
#   left out and listed in ecology_not_served.csv (section 4).
#
# The old merge's other classes moved in the same split: mass + metabolic (body) to
# __merging_body/body_compiled.R, life_history to __merging_life_history (Option A).
# Pooling and species-resolution code is the old script's, verbatim; only the harvest
# blocks for the departed classes, the output folder and the output file names changed.
# Two consequences to know about:
#   * the long table's species_printed / species_basis columns summarise the
#     unfiltered rows OF THIS MERGE (they used to summarise all four classes), so
#     they are narrower than in the old combined merge;
#   * the old merge's single value veto (a body-mass flag) moved with the mass
#     harvest to __merging_body/body_value_flags.csv; no veto applies to the
#     measures here, so this merge has no vetoed-rows output.
#
# Pipeline:
#   1. harvest Wilman (+ Galan gap-fill) -> resolve species   -> ecology_unfiltered.csv
#   2. team-dedupe, then pool across teams, primary preferred -> ecology_long.csv / _wide.csv
#   3. dedupe / disagreement report                           -> ecology_dedupe_report.csv
#   (values not served, with the reason for each               -> ecology_not_served.csv)
#   (the fixed source-column crosswalk is written to ecology_source_columns.csv)

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
out <- file.path(repo, "__merging_ecology")

norm    <- function(h) tolower(trimws(gsub('"', "", h)))
body_rx <- "(body.?mass|body.?weight|bodyweight|bo[wm]ass|bow_g|body_?wt)"
EXCLUDE <- c("source","ref","note","_sd"," sd","sem","dimorph","log","raw",
             "spinal","brain","assoc",": data","original")
SKIP    <- c("10.1016%2Fj.jhevol.2008.08.004_Table7.tsv", # body-mass dimorphism (a ratio)
             "10.1159%2F000021575_Table1.tsv", # Simmen1998 secondary body covariates
             "10.1186%2F1741-7007-5-20_AdditionalFile1.tsv", # Lindenfors2007 reused body masses
             "10.1098%2Frspb.2026.2257_TableS2.tsv") # Dupont2026 TableS2: fossil specimens, literature body-mass estimates; fossils stay out of this extant pool
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
  # a blank/NA role in the catalog must not be recorded: %||% below only defaults NULL, and an NA role
  # makes any(d_role == "primary") NA in pool_one() (Pirlot_Kamiya_1982, Ridgway__1990 as of 2026-10-19)
  if (length(m) == 3 && !is.na(vc$role[i]) && nzchar(vc$role[i])) { k <- paste(tolower(m[2]), m[3]); if (is.null(role_ay[[k]])) role_ay[[k]] <- vc$role[i] }
}
## Species identity: the shared resolver (_keys/resolve_species.R; SPECIES_NAMING.md v1). Replaces the
## former inline hub-then-first-key lookup (2026-09-28): rows are keyed by (paper folder, printed
## variant) and carry a basis; unresolved names fall back to the cleaned printed string as before.
source(file.path(repo, "_keys", "resolve_species.R"))
# public TSV file -> paper folder, via the registry (Item encoded -> Item name), read from __ReadMe.xlsx
reg_folder <- tryCatch({
  r <- as.data.frame(readxl::read_excel(file.path(repo, "__ReadMe.xlsx"), sheet = "Sheet1",
                                        col_types = "text", .name_repair = "minimal"),
                     stringsAsFactors = FALSE, check.names = FALSE)
  r <- r[!is.na(r[["Item encoded"]]) & nzchar(r[["Item encoded"]]), , drop = FALSE]
  setNames(paper_folder_of_item(r[["Item name"]], repo), paste0(r[["Item encoded"]], ".tsv"))
}, error = function(e) { message("ecology: registry not readable (", conditionMessage(e),
                                 ") -> species resolved without paper scope"); character() })
folder_of_file <- function(fn) { f <- unname(reg_folder[fn]); if (is.null(f) || !length(f)) NA_character_ else f }
clean_sp <- species_normalise
# Vectorised: the Wilman table alone is 5,403 rows; resolve_species() is vectorised over x.
resolve <- function(x, fn = NA_character_) resolve_species(x, source_publication = folder_of_file(fn))

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

# Tables that carry no per-row species column because every row is the same
# species (documented in the source itself, not inferrable from headers).
# 10.1111%2Fj.1749-6632.2011.05978.x_TableS3.tsv (Zilles et al. 2011, "Three
# brain collections") is titled "Zilles-Amunts collection Homo sapiens" in
# its own supplementary-table caption -- a developmental series of
# prenatal/perinatal human specimens (catalogue numbers "H <n>/<year>"), not
# a multi-species table. Before this override existed, species_col()'s
# fallback to column 1 (source_row, 1..152) silently mislabeled every row's
# species as a row-index number.
SPECIES_OVERRIDE <- c(
  "10.1111%2Fj.1749-6632.2011.05978.x_TableS3.tsv" = "Homo sapiens"
)

binom <- "^[A-Z][a-z]+ [a-z][a-z-]+"
check_species_names <- function(species) {
  duplicate <- !is.na(species) & grepl("^([A-Z][a-z]+) \\1 ", species, perl = TRUE)
  if (any(duplicate)) stop("Repeated genus in harvested species names: ",
    paste(head(unique(species[duplicate]), 6), collapse = "; "),
    ". Check source-column assembly before pooling.", call. = FALSE)
  invisible(TRUE)
}
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
    # Species can be a full underscore-separated name, not just an epithet.
    # Inspect each row, but return its original text for the shared resolver.
    # Do not strip repeated words from accepted names or change other sources'
    # column-selection rules here.
    return(function(rows) {
      genus <- cell(rows, gi); species <- cell(rows, si)
      normalised <- trimws(gsub("[[:space:]]+", " ", gsub("_", " ", species, fixed = TRUE)))
      full <- !is.na(species) & grepl(binom, normalised)
      absent <- is.na(species) | !nzchar(species) | tolower(species) %in% c("na", "none")
      answer <- trimws(paste(genus, species))
      answer[full] <- species[full]
      answer[absent] <- NA_character_
      answer
    }) }
  h <- which(norm(headers) %in% c("species","scientific","scientific name","taxon","binomial",
                                  "genus species","species name","species_name","animal"))
  if (length(h)) { i <- h[1]; return(function(rows) cell(rows, i)) }
  # No species-identifying column found. Column 1 is whatever the source
  # happens to start with (often a row index or catalogue number, not a
  # taxon) -- returning it as "species" fabricates a label rather than
  # reporting one. Blank so keep_rows() drops these rows instead of
  # mislabeling them; add a SPECIES_OVERRIDE entry for a genuinely
  # single-species table with no per-row column.
  function(rows) rep(NA_character_, length(rows))
}

# Wraps species_col() with SPECIES_OVERRIDE: some source files are known to be
# single-species with no per-row species column at all (see SPECIES_OVERRIDE
# above), so check the override before falling back to header-sniffing.
get_species <- function(fn, headers, sample, rows) {
  if (fn %in% names(SPECIES_OVERRIDE)) return(rep(unname(SPECIES_OVERRIDE[[fn]]), length(rows)))
  species_col(headers, sample)(rows)
}

# One harvested block. `value` is already in the canonical unit.
blk <- function(species_raw, value, raw_value, raw_unit, mclass, measure, units,
                fn, author, year, team, role) {
  rs <- resolve(species_raw, fn)
  data.frame(Species = rs$accepted_name, Species_raw = species_raw,
             measure_class = mclass, Measure = measure, Units = units,
             Value_canonical = as.character(value), raw_value = raw_value, raw_unit = raw_unit,
             Source = fn, first_author = author, Year = year, Team = team, role = role,
             species_printed = species_raw, accepted_name = rs$accepted_name,
             species_basis = rs$species_basis, reidentified = rs$reidentified,
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

uf <- list(); colmap <- list(); not_served <- list()

# ---- 4. diet & ecology (Wilman 2014 EltonTraits, 5,403 mammals) ------------
WILMAN <- "10.1890%2F13-1917.1_MamFuncDat.tsv"
DIET_PCT <- c("Diet_Inv","Diet_Vend","Diet_Vect","Diet_Vfish","Diet_Vunk",
              "Diet_Scav","Diet_Fruit","Diet_Nect","Diet_Seed","Diet_PlantO")
DIET_NUM <- c(DIET_PCT, "Diet_breadth")
DIET_CAT <- c("Diet_dominant","Trophic_guild","ForStrat_stratum","Activity_pattern")
wp <- file.path(pub, WILMAN)
if (file.exists(wp)) {
  fn <- WILMAN  # get_species() checks SPECIES_OVERRIDE by filename; without
                # this, fn would still hold whatever file the LIFE loop above
                # last visited.
  rows <- read_tsv_rows(wp); headers <- gsub('"', "", rows[[1]]); drows <- rows[-1]
  sp <- get_species(fn, headers, drows[seq_len(min(length(drows), 59))], drows)
  m <- src_meta(WILMAN); team <- team_ay[[m$ay]] %||% (if (nzchar(m$author)) m$author else "Wilman")
  # Imputed values are not served (owner decision, 24 November 2026: "we should be able to
  # re-calculate those data from the species data, if we ever need them"). EltonTraits names,
  # per species, the source of its diet values and of its activity values; where no species
  # data were found it gives the genus average (Ref_2, certainty code D1) or the family
  # average (Ref_3, D2). Those values are left out: the 10 diet percentages and what Wilman
  # derives from them (Diet_breadth, Diet_dominant, Trophic_guild) by Diet_Certainty, and
  # Activity_pattern by Activity_Certainty. Each value left out is written, per species and
  # measure, to ecology_not_served.csv with status "imputed". Foraging stratum has no such
  # code (its A / B code is the reliability of the source) and is served as before.
  IMPUTED <- c(D1 = "genus average (EltonTraits Ref_2, certainty D1)",
               D2 = "family average (EltonTraits Ref_3, certainty D2)")
  cert_col <- function(nm) {
    ci <- match(nm, headers)
    if (is.na(ci)) stop("ecology: column ", nm, " not found in ", WILMAN, call. = FALSE)
    cell(drows, ci)
  }
  cert <- list(diet = cert_col("Diet_Certainty"), activity = cert_col("Activity_Certainty"))
  cert_group <- function(col) if (col == "Activity_pattern") "activity" else
                              if (col == "ForStrat_stratum") NA_character_ else "diet"
  for (col in c(DIET_NUM, DIET_CAT)) {
    ci <- match(col, headers); if (is.na(ci)) next
    raw <- cell(drows, ci)
    ok <- !is.na(raw) & nzchar(raw) & !(tolower(raw) %in% c("na", "none", "nan"))
    grp <- cert_group(col)
    if (!is.na(grp)) {
      imp <- ok & cert[[grp]] %in% names(IMPUTED)
      if (any(imp)) {
        rs <- resolve(sp[imp], WILMAN)
        not_served[[length(not_served) + 1L]] <- data.frame(
          Reference = "Wilman_etal_2014_MamFuncDat", Species_printed = sp[imp],
          Species = rs$accepted_name, Measure = col, Value_as_published = raw[imp],
          status = "imputed", code = cert[[grp]][imp], reason = unname(IMPUTED[cert[[grp]][imp]]),
          stringsAsFactors = FALSE)
      }
      ok <- ok & !imp
    }
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

# ---- 4b. Galán-Acedo et al. 2019 diel activity: gap-fill for Activity_pattern ----
# Added 2026-11-20 (audit enactment). The Wilman/EltonTraits Activity_pattern above
# is the authoritative label. Galán-Acedo et al. 2019 report the same quantity for
# primates as codes (D / N / CA) in GalánAcedo_etal_2019_DielActivity.csv -- the item
# __merging_supplementary maps, unchanged, as Activity_pattern_Galan2019. Mapped onto
# Wilman's words (D -> Diurnal, N -> Nocturnal, CA -> Cathemeral) the two agree on
# 95.7% of the 323 species both report, so Galán is used ONLY where Wilman lacks the
# species. Since 24 November 2026 that includes the species whose Wilman value is a genus or
# family average (left out in section 4): a species-level Galán value then fills the gap.
# Rows are filtered to those species before pooling, which keeps every
# Wilman row byte-identical and makes the precedence structural rather than a
# pooling artefact. Species are resolved with the paper scope, exactly as the
# supplementary merge resolves this same table, and each species' value is the
# mode of its codes with that merge's tie-break, so the fill agrees
# species-for-species with the Activity_pattern_Galan2019 label.
GALAN_DIEL <- file.path(repo, "GalánAcedo_etal_2019", "GalánAcedo_etal_2019_DielActivity.csv")
if (file.exists(GALAN_DIEL)) {
  g <- read.csv(GALAN_DIEL, stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
  code <- trimws(as.character(g$DielActivity))
  words <- c(D = "Diurnal", N = "Nocturnal", CA = "Cathemeral")
  ok <- !is.na(code) & code %in% names(words)
  rs <- resolve_species(as.character(g$Species[ok]), source_publication = "GalánAcedo_etal_2019")
  gd <- data.frame(Species = rs$accepted_name, Species_raw = as.character(g$Species[ok]),
                   measure_class = "diet_ecology", Measure = "Activity_pattern", Units = "category",
                   Value_canonical = unname(words[code[ok]]), raw_value = code[ok], raw_unit = "category",
                   Source = "GalánAcedo_etal_2019_DielActivity.csv", first_author = "GalánAcedo",
                   Year = "2019", Team = "GalánAcedo_etal_2019", role = "secondary",
                   species_printed = as.character(g$Species[ok]), accepted_name = rs$accepted_name,
                   species_basis = rs$species_basis, reidentified = rs$reidentified,
                   stringsAsFactors = FALSE)
  ap_so_far <- do.call(rbind, uf[vapply(uf, function(d) any(d$Measure == "Activity_pattern"), logical(1))])
  gd <- gd[!gd$Species %in% unique(ap_so_far$Species), , drop = FALSE]
  if (nrow(gd)) {
    # one row per species: modal code (alphabetical tie-break, as in
    # __merging_supplementary's agg_fun "mode"), so the pooled value below is
    # the species' single Galán value, not a second arbitration.
    gd <- do.call(rbind, lapply(split(gd, gd$Species), function(d) {
      d$Value_canonical <- names(sort(table(d$Value_canonical), decreasing = TRUE))[1]
      d$raw_value <- paste(sort(unique(d$raw_value)), collapse = "; ")
      d[1, , drop = FALSE]
    }))
    uf[[length(uf) + 1L]] <- keep_rows(gd)
  }
}

uf <- do.call(rbind, uf)
check_species_names(uf$Species)

## ---- value vetoes: none apply to this merge --------------------------------
## The old combined merge's only flag vetoes body-mass rows of one source table;
## it moved with the mass harvest to __merging_body/body_value_flags.csv.

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
       Teams = paste(sort(enc2utf8(teams), method = "radix"), collapse = "; "),
       roles = paste(sort(enc2utf8(unique(d_role)), method = "radix"), collapse = "; "),
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
## Species naming columns (SPECIES_NAMING.md v1): long is pooled per species x measure, so
## species_printed / species_basis list the distinct printed names / bases of the unfiltered rows that
## resolved to this Species; accepted_name == Species; reidentified = any such row was a reident.
sp_cols <- as.data.frame(species_columns_summary(uf, "Species"))
ix <- match(long$Species, sp_cols$Species)
long$species_printed <- sp_cols$species_printed[ix]; long$accepted_name <- long$Species
long$species_basis   <- sp_cols$species_basis[ix];   long$reidentified  <- sp_cols$reidentified[ix]

multi <- long$n_sources > 1
dedupe <- data.frame(Species = long$Species[multi], Measure = long$Measure[multi],
                     Units = long$Units[multi], n_sources = long$n_sources[multi],
                     n_teams = long$n_teams[multi], pooled = long$Value[multi],
                     spread_max_over_min = g("spread")[multi], flag = g("flag")[multi],
                     per_source = g("per_source")[multi],
                     stringsAsFactors = FALSE, row.names = NULL)
dedupe <- dedupe[order(-dedupe$n_sources), ]

# ---- write -----------------------------------------------------------------
## source-column crosswalk for this merge: the Wilman columns are fixed in section 4
## (not auto-detected), and the Galan table enters only through the section 4b gap-fill.
srcmap <- rbind(
  data.frame(file = WILMAN, source_column = DIET_PCT, Measure = DIET_PCT, unit = "%",
             note = "Wilman 2014 EltonTraits, as published", stringsAsFactors = FALSE),
  data.frame(file = WILMAN, source_column = "Diet_breadth", Measure = "Diet_breadth",
             unit = "count", note = "Wilman 2014 EltonTraits, as published", stringsAsFactors = FALSE),
  data.frame(file = WILMAN, source_column = DIET_CAT, Measure = DIET_CAT, unit = "category",
             note = "Wilman 2014 EltonTraits, as published; pooled by mode", stringsAsFactors = FALSE),
  data.frame(file = "GalanAcedo_etal_2019_DielActivity.csv", source_column = "DielActivity",
             Measure = "Activity_pattern", unit = "category",
             note = "gap-fill only (section 4b): D/N/CA mapped to Diurnal/Nocturnal/Cathemeral; species for which Wilman has no species-level value only",
             stringsAsFactors = FALSE))
write.csv(srcmap, file.path(out, "ecology_source_columns.csv"), row.names = FALSE)
write.csv(uf,     file.path(out, "ecology_unfiltered.csv"),     row.names = FALSE, na = "")
write.csv(long,   file.path(out, "ecology_long.csv"),           row.names = FALSE, na = "")
write.csv(dedupe, file.path(out, "ecology_dedupe_report.csv"),  row.names = FALSE, na = "")
ns <- if (length(not_served)) do.call(rbind, not_served) else
  data.frame(Reference = character(), Species_printed = character(), Species = character(),
             Measure = character(), Value_as_published = character(), status = character(),
             code = character(), reason = character(), stringsAsFactors = FALSE)
write.csv(ns,     file.path(out, "ecology_not_served.csv"),     row.names = FALSE, na = "")

# wide: one column per Measure, canonical unit in the name
WCOL <- c()   # no measure is renamed in the wide table of this merge
wide_cols <- c(DIET_PCT, "Diet_breadth", DIET_CAT)
wname <- unname(ifelse(long$Measure %in% names(WCOL), WCOL[long$Measure], long$Measure))
spp <- unique(long$Species)
wide <- data.frame(Species = spp, stringsAsFactors = FALSE)
ri <- match(long$Species, spp)
for (cn in wide_cols) {
  v <- rep(NA_character_, length(spp)); sel <- wname == cn
  v[ri[sel]] <- long$Value[sel]; wide[[cn]] <- v
}
write.csv(wide, file.path(out, "ecology_wide.csv"), row.names = FALSE, na = "")

cat(sprintf("unfiltered rows: %d  |  long rows: %d  |  species: %d\n",
            nrow(uf), nrow(long), nrow(wide)))
tb <- table(paste0(long$measure_class, " / ", long$Measure, " (", long$Units, ")"))
for (nm in sort(names(tb))) cat(sprintf("   %5d  %s\n", tb[[nm]], nm))
cat(sprintf("disagreement>2x flags: %d\n", sum(dedupe$flag == "DISAGREEMENT>2x")))
cat(sprintf("not served (imputed, genus or family average): %d values of %d species (diet: %d species, activity: %d species)\n",
            nrow(ns), length(unique(ns$Species_printed)),
            length(unique(ns$Species_printed[ns$Measure != "Activity_pattern"])),
            length(unique(ns$Species_printed[ns$Measure == "Activity_pattern"]))))
