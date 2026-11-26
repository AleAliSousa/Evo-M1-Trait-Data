#!/usr/bin/env Rscript
# =============================================================================
# build_compiled.R  --  build the ONE table both apps read
#
#   Rscript __compiled/build_compiled.R [repo] [output folder]
#
# Writes compiled_long.csv.gz: the table the Evo-M1 app used to assemble at
# every start-up (`compiled`), one row per species x variable x dataset value.
# Both apps (Evo-M1 __ShinyApp/app.R and TraitExplorer) now read this one file
# instead of the per-folder merge outputs.
#
# INPUT   the merge outputs listed in _keys/app_feeds.csv (rows with
#         evo_m1_app = TRUE), __merging_brain_mass/brain_mass_unfiltered.csv,
#         and the keys the loader uses: _keys/variable_canonical.csv,
#         species_display_aliases.csv, species_pooling.csv,
#         population_status.csv, variable_definitions.csv.
#         Sources mapped in __compiled/item_columns.csv are read as data points by
#         __compiled/datapoints.R (the one route; no merge folder) and served from them.
# OUTPUT  __compiled/compiled_long.csv.gz  (gzip: the plain CSV is over 45 MB)
#         __compiled/datapoints.csv.gz  (every data point of the one route, as printed)
#         14 columns as the app has them, in the app's order:
#           Species, Dataset, Variable, Value, Value_num, Source, Items,
#           Source_details, Teams, N_sources, Variable_raw, Unit, Unit_raw,
#           population_verdict
#         then  domain, measure_class  (from _keys/variable_definitions.csv,
#         the key behind the app's two-tier variable picker; a label with no
#         row there gets "Unclassified", a blank class gets "other", as in the
#         picker).
#
# The loader below was MOVED here from __ShinyApp/app.R, not rewritten: every
# block marked "moved from app.R" or "copy of app.R" is that file's code,
# line for line. Change a loader here; if you change a block marked "copy",
# change app.R's copy too.
#
# The output does not depend on the session: the script sets a UTF-8 character
# type and byte-order (C) sorting itself, writes UTF-8 with LF line ends, and
# orders rows by Species, then Variable, in byte order (ties stay in feed
# order). Two runs on the same inputs give the same bytes.
#
# A feed that app_feeds.csv does not list, or whose file is missing or
# unreadable, stops the build and names the feed.
# =============================================================================

.self_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else getwd()
})
.args   <- commandArgs(trailingOnly = TRUE)
repo    <- normalizePath(if (length(.args) >= 1) .args[1] else file.path(.self_dir, ".."))
out_dir <- if (length(.args) >= 2) .args[2] else file.path(repo, "__compiled")
OUT_NAME <- "compiled_long.csv.gz"
if (!file.exists(file.path(repo, "_keys", "app_feeds.csv")))
  stop("Not an Evo-M1-Trait-Data checkout (no _keys/app_feeds.csv): ", repo, call. = FALSE)

# ---- session-independent settings -------------------------------------------
for (.loc in c("en_US.UTF-8", "C.UTF-8", "UTF-8"))
  if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", .loc)))) break
if (!isTRUE(l10n_info()[["UTF-8"]]))
  stop("No UTF-8 locale is available on this machine; the loader needs one.", call. = FALSE)
invisible(Sys.setlocale("LC_COLLATE", "C"))
options(stringsAsFactors = FALSE, scipen = 0, digits = 7, OutDec = ".", warn = 1)

# ---- reading ----------------------------------------------------------------
# app.R read every file through read_csv_gh(gh_rel, local): GitHub, or the
# checkout with ./data as a fallback. The builder reads the checkout only, with
# the same read.csv() call; `local` is ignored and data_dir exists only so the
# moved calls evaluate. A missing or unreadable file stops the build.
data_dir <- "data"
read_csv_gh <- function(gh_rel, local = NULL) {
  feed <- if (exists("app_feeds")) app_feeds$feed[app_feeds$path %in% gh_rel] else character(0)
  what <- if (length(feed)) paste0("Feed '", feed[1], "' (", gh_rel, ", from _keys/app_feeds.csv)") else gh_rel
  f <- file.path(repo, gh_rel)
  if (!file.exists(f)) stop(what, " does not exist in ", repo, ".", call. = FALSE)
  tryCatch(read.csv(f, stringsAsFactors = FALSE, check.names = FALSE),
           error = function(e) stop(what, " cannot be read: ", conditionMessage(e), call. = FALSE))
}
# brain_mass_items(), used by the Brain mass loader, stays in __ShinyApp/explorer.R
# (a check calls it there); it is sourced, not copied.
source(file.path(repo, "__ShinyApp", "explorer.R"), local = TRUE)

# ---- the one route (__compiled/datapoints.R) --------------------------------
# Traits whose sources are mapped in __compiled/item_columns.csv are built from data points under
# the owner's rules, not from a merge folder. Their rows join the merge rows below and get the same
# treatment (species display aliases, Hemispheres, subspecies rule, population verdict, keys).
source(file.path(repo, "_keys", "resolve_species.R"), local = TRUE)
source(file.path(repo, "__compiled", "datapoints.R"), local = TRUE)
dp_all <- dp_points(repo)

# ---- the feed list (moved from app.R) ---------------------------------------
# One row per feed in _keys/app_feeds.csv; feed_path("x") is the path of feed x.
# If x has no row there with evo_m1_app = TRUE, the build stops and names it.
app_feeds <- read_csv_gh("_keys/app_feeds.csv", file.path(data_dir, "app_feeds.csv"))
if (!all(c("feed", "path", "evo_m1_app") %in% names(app_feeds)))
  stop("_keys/app_feeds.csv must have columns: feed, path, evo_m1_app. Found: ",
       paste(names(app_feeds), collapse = ", "))
for (cl in c("feed", "path", "evo_m1_app")) app_feeds[[cl]] <- trimws(as.character(app_feeds[[cl]]))
feed_path <- function(feed) {
  p <- app_feeds$path[app_feeds$feed == feed & toupper(app_feeds$evo_m1_app) == "TRUE"]
  p <- p[!is.na(p) & nzchar(p)]
  if (length(p) != 1L)
    stop("Feed '", feed, "' is loaded by build_compiled.R, but _keys/app_feeds.csv has ", length(p),
         " row(s) with feed = '", feed, "', evo_m1_app = TRUE and a path; exactly one ",
         "is needed.", call. = FALSE)
  p
}
GH <- list(
  taste = feed_path("taste"),
  social_mirror_play = feed_path("social_mirror_play"),
  volumes    = feed_path("volumes"),
  cellcounts = feed_path("cellcounts"),
  traits     = feed_path("traits"),
  body       = feed_path("body"),
  ecology    = feed_path("ecology"),
  # 2026-11-22: the five life-history measures that used to ride in
  # body_ecology were folded into the life-history merge (PR #97, Option A);
  # std_life_history() below surfaces them under their existing labels.
  life_history = feed_path("life_history"),
  brain_mass = feed_path("brain_mass"),
  brain_size = feed_path("brain_size"),
  behaviour  = feed_path("behaviour"),
  # 2026-11-19: postcranial anatomy, hand use and limb function. Only the numeric, extant,
  # species-level table is served; specimen, fossil, record-level and categorical tables stay in the
  # merge folder. Same long schema as std_merge(); methods are separate Measure names, never pooled.
  postcranial = feed_path("postcranial"),
  cmr        = feed_path("cmr"),
  ecv        = feed_path("ecv"),
  cortical_areas  = feed_path("cortical_areas"),
  cell_morphology = feed_path("cell_morphology"),
  fossil_bgu = feed_path("fossil_bgu"),
  sensory    = feed_path("sensory"),
  # 2026-10-15: mapping-driven merge of built public tables no other merge
  # consumed (PanTHERIA life history/ecology, deSousa 2022 acuity compilation,
  # Boyer & Harrington 2019 blood flow, Navarrete 2016 innovation, ...). Same
  # schema as the std_merge() merges; see __merging_supplementary/README__merging.md.
  supplementary = feed_path("supplementary"),
  # 2026-11-23: two merges the apps did not load as datasets before.
  sleep = feed_path("sleep"),
  # read-time wild/domestic pooling keys (no merge reads them; see _keys/README_species_pooling.md)
  pooling    = "_keys/species_pooling.csv",
  population = "_keys/population_status.csv"
)

# ---- keys the loader uses (copy of app.R) -----------------------------------
canon <- tryCatch(
  read_csv_gh("_keys/variable_canonical.csv",
              file.path(data_dir, "variable_canonical.csv")),
  error = function(e) NULL)

# Species display aliases: unify synonym labels (e.g. Callithrix pygmaea ->
# Cebuella pygmaea) across ALL datasets so a species lines up regardless of the
# taxonomy a source used. See _keys/species_display_aliases.csv.
aliases <- tryCatch(
  read_csv_gh("_keys/species_display_aliases.csv",
              file.path(data_dir, "species_display_aliases.csv")),
  error = function(e) NULL)
unalias <- function(sp) {
  if (is.null(aliases) || !nrow(aliases)) return(sp)
  m <- setNames(aliases$canonical, aliases$variant)
  hit <- m[sp]; ifelse(is.na(hit), sp, unname(hit))
}
if (is.null(canon) || is.null(aliases))
  stop("_keys/variable_canonical.csv and _keys/species_display_aliases.csv are both needed.", call. = FALSE)

# Which dataset is served where two datasets carry the same label for the same
# species: one row per label and pair of datasets, decided by the owner.
precedence <- read_csv_gh("_keys/label_precedence.csv", file.path(data_dir, "label_precedence.csv"))
if (!all(c("variable", "winning_dataset", "yielding_dataset") %in% names(precedence)))
  stop("_keys/label_precedence.csv must have columns: variable, winning_dataset, yielding_dataset.", call. = FALSE)
for (cl in c("variable", "winning_dataset", "yielding_dataset")) precedence[[cl]] <- trimws(as.character(precedence[[cl]]))

# Subspecies (_keys/species_pooling.csv, axis = subspecies; owner rule of
# 2026-11-23): compiled data are filed under the species. Each pool has one
# species_rank row (the species) and one row per subspecies name.
subspecies_key <- local({
  k <- read_csv_gh("_keys/species_pooling.csv", file.path(data_dir, "species_pooling.csv"))
  k <- k[trimws(as.character(k$axis)) == "subspecies", , drop = FALSE]
  for (cl in c("pool_id", "member", "relation")) k[[cl]] <- trimws(as.character(k[[cl]]))
  top <- k[k$relation == "species_rank", , drop = FALSE]
  if (anyDuplicated(top$pool_id) || any(!k$pool_id %in% top$pool_id))
    stop("_keys/species_pooling.csv: every subspecies pool needs exactly one species_rank row.", call. = FALSE)
  low <- k[k$relation != "species_rank", , drop = FALSE]
  if (anyDuplicated(low$member))
    stop("_keys/species_pooling.csv: a subspecies name is filed twice: ",
         paste(unique(low$member[duplicated(low$member)]), collapse = "; "), call. = FALSE)
  data.frame(member = low$member, species = top$member[match(low$pool_id, top$pool_id)],
             stringsAsFactors = FALSE)
})

# Hemispheres (_keys/hemisphere_basis.csv; owner rule of 2026-11-23): where one
# hemisphere was measured, the plain label serves the both-hemisphere value
# (2 x the measured one) and says so in the Hemispheres column; the measured
# value is served under the label with a one-side suffix. Each dataset named in
# the key has a flags file written by its merge (Species, Variable, flag,
# detail); the two flags below are the ones that mark a doubled value.
hemi_key <- read_csv_gh("_keys/hemisphere_basis.csv", file.path(data_dir, "hemisphere_basis.csv"))
if (!all(c("dataset", "flags_file", "one_side_suffixes") %in% names(hemi_key)))
  stop("_keys/hemisphere_basis.csv must have columns: dataset, flags_file, one_side_suffixes.", call. = FALSE)
for (cl in c("dataset", "flags_file", "one_side_suffixes")) hemi_key[[cl]] <- trimws(as.character(hemi_key[[cl]]))
if (anyDuplicated(hemi_key$dataset)) stop("_keys/hemisphere_basis.csv names a dataset twice.", call. = FALSE)
HEMI_ONE  <- "one hemisphere (as measured)"
HEMI_MEAN <- "mean of sources, one of them 2 x one hemisphere (doubled by that source)"
HEMI_FLAG <- c(estimated_bilateral_from_unilateral = "2 x one hemisphere (doubled by this project)",
               published_bilateral_estimate        = "2 x one hemisphere (doubled by the source)")
hemisphere_basis <- function(out) {
  res <- rep("", nrow(out))
  for (i in seq_len(nrow(hemi_key))) {
    ds <- hemi_key$dataset[i]; rows <- out$Dataset == ds
    if (!any(rows)) stop("_keys/hemisphere_basis.csv row ", i, ": no dataset is labelled '", ds, "'.", call. = FALSE)
    suf <- trimws(strsplit(hemi_key$one_side_suffixes[i], ";", fixed = TRUE)[[1]]); suf <- suf[nzchar(suf)]
    one <- if (length(suf)) rows & grepl(paste0("_(", paste(suf, collapse = "|"), ")_[^_]+$"), out$Variable_raw) else rep(FALSE, nrow(out))
    res[one] <- HEMI_ONE
    fl <- read_csv_gh(hemi_key$flags_file[i])
    if (!all(c("Species", "Variable", "flag", "detail") %in% names(fl)))
      stop(hemi_key$flags_file[i], " must have columns: Species, Variable, flag, detail.", call. = FALSE)
    fl <- fl[fl$flag %in% names(HEMI_FLAG), , drop = FALSE]
    # The feed's species names have been through the display aliases by now
    # (_keys/species_display_aliases.csv); the flags file has the merge's own names.
    fl$Species <- unalias(fl$Species)
    fl <- fl[!duplicated(fl[c("Species", "Variable", "flag")]), , drop = FALSE]
    fk <- paste(fl$Species, fl$Variable, sep = "\r")
    if (anyDuplicated(fk)) stop(hemi_key$flags_file[i], ": a value is flagged twice for its hemispheres.", call. = FALSE)
    k <- match(paste(out$Species, out$Variable_raw, sep = "\r"), fk); hit <- rows & !is.na(k)
    if (any(hit & one))
      stop(hemi_key$flags_file[i], ": a one-side label is also flagged as doubled: ",
           paste(unique(out$Variable_raw[hit & one]), collapse = "; "), call. = FALSE)
    txt <- unname(HEMI_FLAG[fl$flag[k[hit]]])
    txt[fl$flag[k[hit]] == "published_bilateral_estimate" & grepl("^a contributing source", fl$detail[k[hit]])] <- HEMI_MEAN
    res[hit] <- txt
    message("hemispheres, ", ds, ": ", sum(hit), " doubled value(s) marked (", nrow(fl) - length(unique(k[hit])),
            " flagged value(s) not served), ", sum(one), " one-side value(s)")
  }
  res
}

# ---- Load & harmonize compiled data (moved from app.R) -----------------------

load_compiled <- function() {
  # Some merges retain richer provenance than others. Never discard those
  # columns merely to make their schemas line up.
  bind_compiled <- function(...) {
    frames <- list(...)
    cols <- unique(unlist(lapply(frames, names)))
    do.call(rbind, lapply(frames, function(d) {
      for (cl in setdiff(cols, names(d))) d[[cl]] <- rep("", nrow(d))
      d[cols]
    }))
  }
  field <- function(d, name) if (name %in% names(d)) as.character(d[[name]]) else rep("", nrow(d))
  # Value is kept as text (so categorical traits like Diet are shown as-is);
  # Value_num is the numeric parse used for plotting.
  std <- function(gh_rel, local, dataset, source_col, n_col = NULL) {
    d <- read_csv_gh(gh_rel, local)
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = d$Variable,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = d[[source_col]],
      Items = if ("Sources" %in% names(d)) field(d, "Sources") else field(d, source_col),
      Source_details = field(d, "Source_detail"),
      Teams = as.character(d[[source_col]]),
      N_sources = if (!is.null(n_col)) suppressWarnings(as.integer(d[[n_col]])) else NA_integer_,
      Variable_raw = d$Variable, Unit = NA_character_, Unit_raw = NA_character_,
      stringsAsFactors = FALSE)
  }
  # A merge long file has Measure/Units/Value/n_sources/Teams (no Variable/Source).
  std_merge <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    # Unresolved mixed-basis records belong in the review table, including when
    # an older merge is loaded. No species has an approved ambiguous fallback.
    if (dataset == "Brain mass") {
      d <- d[d$Measure != "Brain_Mass_mass_or_volume", , drop = FALSE]
      d$Measure[d$Measure == "Brain_Mass_from_volume_or_ecv"] <- "Brain_Mass_estimated_from_volume"
      reports <- read_csv_gh("__merging_brain_mass/brain_mass_unfiltered.csv",
                             file.path(data_dir, "brain_mass_unfiltered.csv"))
      d$items <- brain_mass_items(d, reports)
    }
    lab <- paste0(d$Measure, " (", d$Units, ")")
    provenance <- paste0("EvoM1 ", tolower(d$Measure), " merge (", d$n_sources, " sources)")
    if (dataset == "Combined brain size") {
      provenance <- paste0("Pooled brain size; ", d$n_sources, " contributing reports; ",
                           d$n_teams, " source teams; ", d$reports_with_unknown_n,
                           " reports with unknown sample size")
      d$measurement_method <- paste(d$measurement_method, d$weighting, d$conversion, sep = "; ")
    }
    if (dataset == "Brain mass" && all(c("selected_measure", "measurement_method") %in% names(d))) {
      selected <- d$Measure == "Brain mass (measured or estimated from volume)"
      provenance[selected] <- paste0("Selected ", d$measurement_method[selected],
                                    "; ", d$selected_measure[selected],
                                    " (", d$n_sources[selected], " source reports)")
    }
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = provenance,
      Items = field(d, "items"),
      Source_details = if ("measurement_method" %in% names(d)) field(d, "measurement_method") else field(d, "roles"),
      Teams = as.character(d$Teams),
      N_sources = suppressWarnings(as.integer(d$n_sources)),
      Variable_raw = lab, Unit = d$Units, Unit_raw = d$Units,
      stringsAsFactors = FALSE)
  }

  # Life-history merge (Hayssen-based, plus the paper tables folded in by
  # PR #97). Its Measure/Units strings are terse (gestation_d / d), so a plain
  # std_merge() would mint new labels and strand the canonical supersede rows
  # and domain keys written against the long-standing labels. Surface ONLY the
  # five measures the old body_ecology merge carried, relabelled onto those
  # labels and units; the merge's other measures stay out of the app, as they
  # always have. Values are already in days / counts / years.
  std_life_history <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    lab_map <- c(gestation_d = "Gestation (days)",
                 weaning_age_d = "Weaning_age (days)",
                 litter_size_n = "Litter_size (count)",
                 maximum_longevity_y = "Maximum_longevity (yr)",
                 female_maturity_age_d = "Female_sexual_maturity (days)")
    unit_map <- c("Gestation (days)" = "days", "Weaning_age (days)" = "days",
                  "Litter_size (count)" = "count",
                  "Maximum_longevity (yr)" = "yr",
                  "Female_sexual_maturity (days)" = "days")
    d <- d[d$Measure %in% names(lab_map), , drop = FALSE]
    lab <- unname(lab_map[d$Measure])
    unit <- unname(unit_map[lab])
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = paste0("EvoM1 life history merge (", d$n_sources, " sources)"),
      Items = field(d, "items"),
      Source_details = field(d, "roles"),
      Teams = as.character(d$Teams),
      N_sources = suppressWarnings(as.integer(d$n_sources)),
      Variable_raw = lab, Unit = unit, Unit_raw = unit,
      stringsAsFactors = FALSE)
  }

  # The cerebral-metabolic-rate merge is keyed Species x REGION x Measure, so its
  # label has to carry the region: "Neocortex_CMRgl", "Whole_brain_CMRO2". It also
  # names its provenance columns differently from the other merges (n_studies /
  # Compilations, because its sources are compilations resolved down to
  # primary-study level), hence its own loader rather than std_merge().
  std_cmr <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    lab <- paste0(d$Region, "_", d$Measure, " (", d$Units, ")")
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = paste0("EvoM1 cerebral metabolic rate merge (", d$n_studies,
                      " primary studies; ", d$Compilations, ")"),
      Items = field(d, "Compilations_used"),
      Source_details = field(d, "Primary_references"),
      Teams = as.character(d$Compilations),
      N_sources = suppressWarnings(as.integer(d$n_studies)),
      Variable_raw = lab, Unit = d$Units, Unit_raw = d$Units,
      stringsAsFactors = FALSE)
  }

  # ---- 2026-09-22: seven merges built but never wired into the app ----------
  # Each has a schema that does not match std()/std_merge()/std_cmr(), so each
  # gets its own small loader, following the same output-shape contract
  # (Species, Dataset, Variable, Value, Value_num, Source, Teams, N_sources,
  # Variable_raw, Unit, Unit_raw). `Teams` is the merge row's provenance tokens
  # (its Teams / Sources / source column, ";"-separated), kept verbatim so the
  # read-time pooling layer below can look each token up in population_status.csv.

  # Cortical-area count / surface / thickness / folding-index merge. `status`
  # marks rows superseded by a later source or held pending an unresolved
  # check (e.g. Finlay 2006 vs Project Kaskan) -- only "active" rows are shown.
  std_cortical_areas <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    d <- d[!is.na(d$status) & d$status == "active", ]
    lab <- d$Standardized_Term
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$value), Value_num = suppressWarnings(as.numeric(d$value)),
      Source = d$source,
      Teams = as.character(d$source),
      N_sources = NA_integer_,
      Variable_raw = lab, Unit = NA_character_, Unit_raw = NA_character_,
      stringsAsFactors = FALSE)
  }

  # Cell type x soma size x dendritic / spine morphology (soma volume, dendritic
  # length, spine density, VEN counts, interlaminar astrocytes, ...). The merge is
  # long over species x region x layer x cell_type x measure x statistic and is
  # never pooled across methods (a Golgi soma AREA and a nucleator soma AREA are
  # different quantities), so the merge itself supplies `variable_label` =
  # region_cellType_measure[_variant] [method_class]; the app only appends the
  # unit. Rows kept: merge_default (drops values already merged from their own
  # table, e.g. Elston 2006 footnote-t re-reports), central statistics only
  # (mean / estimate / value / category -- never sd, sem, min, max, cv, ce),
  # species-level taxa (Hylobates sp. stays out). Individual-level rows
  # (Armstrong 1979 specimens, Hakeem 2009 hemispheres) are kept because no
  # species summary exists for them; the plot's per-species mean averages them.
  # Categorical values (Falcone ILA presence) keep Value as text, Value_num NA.
  # See __merging_cell_morphology/README__merging.md.
  std_cell_morphology <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    d <- d[!is.na(d$merge_default) & d$merge_default &
             d$statistic %in% c("mean", "estimate", "value", "category") &
             !is.na(d$taxon_level) & d$taxon_level == "species", ]
    val <- ifelse(!is.na(d$value), as.character(d$value), as.character(d$value_text))
    d <- d[!is.na(val) & nzchar(val), ]; val <- val[!is.na(val) & nzchar(val)]
    lab <- paste0(d$variable_label, " (", d$unit, ")")
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = val, Value_num = suppressWarnings(as.numeric(d$value)),
      Source = d$source,
      Teams = as.character(d$source),
      N_sources = NA_integer_,
      Variable_raw = lab, Unit = d$unit, Unit_raw = d$unit,
      stringsAsFactors = FALSE)
  }

  # Fossil-hominin whole-brain glucose utilization (BGU): per specimen, per
  # estimator team -- rows are NOT averaged across teams, so each team's
  # estimate (and its modern-human-relative ratio) shows as its own point.
  std_fossil_bgu <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    lab_bgu   <- paste0("Fossil_", d$Measure, " (", d$Units, ") - ", d$Team)
    lab_ratio <- paste0("Fossil_", d$Measure, "_Ratio_MH - ", d$Team)
    rbind(
      data.frame(
        Species = d$Species, Dataset = dataset, Variable = lab_bgu,
        Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
        Source = d$Source, Teams = as.character(d$Source), N_sources = NA_integer_,
        Variable_raw = lab_bgu, Unit = d$Units, Unit_raw = d$Units,
        stringsAsFactors = FALSE),
      data.frame(
        Species = d$Species, Dataset = dataset, Variable = lab_ratio,
        Value = as.character(d$Ratio_MH), Value_num = suppressWarnings(as.numeric(d$Ratio_MH)),
        Source = d$Source, Teams = as.character(d$Source), N_sources = NA_integer_,
        Variable_raw = lab_ratio, Unit = "ratio to modern human", Unit_raw = "ratio",
        stringsAsFactors = FALSE)
    )
  }

  # Sleep & torpor merge. Its terms are the labels the trait table has always
  # used (REM_sleep_pct, Torpor_type ...), so the labels, their definitions and
  # their domain rows carry over unchanged; _keys/variable_canonical.csv
  # supersedes the trait-table columns that held the same values.
  std_sleep <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = d$Standardized_Term,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = d$source,
      Items = field(d, "source"),
      Source_details = field(d, "ref"),
      Teams = as.character(d$team),
      N_sources = 1L,
      Variable_raw = d$Standardized_Term,
      Unit = ifelse(grepl("|", d$Units, fixed = TRUE), "category", d$Units), Unit_raw = d$Units,
      stringsAsFactors = FALSE)
  }

  # Sensory psychophysics (percepts only -- see README__merging.md for what is
  # deliberately excluded). Shape matches std_merge() except for its
  # provenance columns (n_studies / Sources instead of n_sources / Teams).
  std_sensory <- function(gh_rel, local, dataset) {
    d <- read_csv_gh(gh_rel, local)
    # Measure names here already carry the unit as a dot suffix (Visual_acuity.cdeg,
    # Audible_freq_high_60dB.kHz, ...) -- unlike other merges' bare Measure names, so
    # do NOT also append " (Units)" or the unit shows twice.
    lab <- d$Measure
    data.frame(
      Species = d$Species, Dataset = dataset, Variable = lab,
      Value = as.character(d$Value), Value_num = suppressWarnings(as.numeric(d$Value)),
      Source = ifelse(!is.na(d$Sources) & nzchar(d$Sources), d$Sources,
                      paste0("EvoM1 sensory merge (", d$n_studies, " studies)")),
      Teams = as.character(d$Sources),
      N_sources = suppressWarnings(as.integer(d$n_studies)),
      Variable_raw = lab, Unit = d$Units, Unit_raw = d$Units,
      stringsAsFactors = FALSE)
  }

  base <- bind_compiled(
    std(GH$volumes,    file.path(data_dir, "volumes_long.csv"),
        "Brain-structure volumes", "Teams", "n_teams"),
    std(GH$cellcounts, file.path(data_dir, "cell_counts_isotropic_fractionator_long.csv"),
        "Cell counts", "Source"),
    std(GH$traits,     file.path(data_dir, "evom1_traits_long.csv"),
        "EvoM1 traits", "Source")
  )
  merges <- bind_compiled(
    std_merge(GH$taste, file.path(data_dir, "taste_long.csv"), "Taste performance"),
    std_merge(GH$social_mirror_play, file.path(data_dir, "social_mirror_play_long.csv"), "Social composition, mirror tests & play"),
    std_merge(GH$body,       file.path(data_dir, "body_long.csv"), "Body"),
    std_merge(GH$ecology,    file.path(data_dir, "ecology_long.csv"), "Ecology"),
    std_life_history(GH$life_history, file.path(data_dir, "life_history_long.csv"), "Life history"),
    # Brain mass is emitted as PARALLEL variables, one per measurement basis
    # (measured, excluding olfactory bulbs, or explicitly derived estimates);
    # unresolved mixed-basis records are held for review. Endocranial volume
    # retains its own native-volume merge. The explicit combined view below
    # additionally uses ECV as a proxy under the AnimalTraits density convention.
    std_merge(GH$brain_mass, file.path(data_dir, "brain_mass_long.csv"),   "Brain mass"),
    std_merge(GH$brain_size, file.path(data_dir, "brain_size_long.csv"), "Combined brain size"),
    std_merge(GH$ecv, file.path(data_dir, "endocranial_volume_long.csv"),
              "Endocranial volume"),
    std_merge(GH$behaviour,  file.path(data_dir, "behaviour_long.csv"),    "Behaviour"),
    std_merge(GH$postcranial, file.path(data_dir, "postcranial_species_long.csv"),
              "Postcranial & limb function"),
    std_cmr(GH$cmr, file.path(data_dir, "cerebral_metabolic_rate_long.csv"),
            "Cerebral metabolic rate"),
    std_cortical_areas(GH$cortical_areas, file.path(data_dir, "cortical_areas_long.csv"),
            "Cortical areas & surfaces"),
    std_cell_morphology(GH$cell_morphology, file.path(data_dir, "cell_morphology_long.csv"),
            "Cell type, size & morphology"),
    std_fossil_bgu(GH$fossil_bgu, file.path(data_dir, "fossil_brain_glucose_long.csv"),
            "Fossil brain glucose"),
    std_sensory(GH$sensory, file.path(data_dir, "sensory_long.csv"),
            "Sensory performance"),
    std_sleep(GH$sleep, file.path(data_dir, "sleep_long.csv"), "Sleep & torpor"),
    # Five PanTHERIA measures reuse the shared labels on purpose (Gestation,
    # Weaning_age, Litter_size, Maximum_longevity, BMR_wholeanimal: identical
    # quantities, label_policy = shared in supplementary_sources.csv); the app
    # pools them like any second source. Everything else is a new label.
    std_merge(GH$supplementary, file.path(data_dir, "supplementary_long.csv"),
              "Additional published datasets"),
    # the one route: species values from the data points (__compiled/datapoints.R)
    dp_species_values(dp_all)
  )

  # unify species labels everywhere so synonyms line up
  base$Species   <- unalias(base$Species)
  merges$Species <- unalias(merges$Species)

  # Supersede raw columns with authoritative compiled labels (compiled-first +
  # fallback). Coverage is checked across the compiled output already loaded
  # above, not just the later merge files: brain-structure volumes are loaded as
  # a base table but are still the canonical source for raw trait-table volumes.
  if (!is.null(canon) && nrow(canon)) {
    sup <- canon[!is.na(canon$action) & canon$action == "supersede", ]
    coverage <- rbind(base, merges)
    cov <- split(coverage$Species, coverage$Variable)   # species each compiled label covers
    label_for <- function(v, u) {
      if (v %in% names(cov)) return(v)
      lab_unit <- paste0(v, " (", u, ")")
      if (lab_unit %in% names(cov)) return(lab_unit)
      lab_unit
    }
    keep <- rep(TRUE, nrow(base))
    for (i in seq_len(nrow(sup))) {
      lab <- label_for(sup$canonical_variable[i], sup$canonical_unit[i])
      f   <- suppressWarnings(as.numeric(sup$to_canonical_factor[i])); if (is.na(f)) f <- 1
      sel <- base$Variable_raw == sup$raw_variable[i]
      ds  <- trimws(as.character(sup$match_dataset[i]))
      if (!is.na(ds) && nzchar(ds)) sel <- sel & base$Dataset == ds
      if (!any(sel)) next
      conv <- base$Value_num[sel] * f
      base$Variable[sel]  <- lab
      base$Unit[sel]      <- sup$canonical_unit[i]; base$Unit_raw[sel] <- sup$raw_unit[i]
      base$Value_num[sel] <- conv
      base$Value[sel]     <- ifelse(is.na(conv), base$Value[sel],
                                    formatC(conv, format = "g", digits = 8))
      keep[sel] <- !(base$Species[sel] %in% cov[[lab]])   # drop where merge covers it
    }
    base <- base[keep, ]
  }

  out <- bind_compiled(base, merges)
  for (cl in c("Items", "Source_details")) out[[cl]][is.na(out[[cl]])] <- ""
  # Lewitus Table S2 defines nominal social-system codes, not quantitative scores.
  # Preserve source data; decode only this source variable at the app boundary.
  social_labels <- c(`1` = "Solitary", `2` = "Monogamous",
                     `3` = "Multi-male", `4` = "Harem")
  social_rows <- out$Variable == "Social_system" & out$Dataset == "EvoM1 traits"
  social_values <- trimws(out$Value[social_rows])
  valid <- is.na(social_values) | social_values %in% c(names(social_labels), unname(social_labels))
  if (any(!valid)) stop("Unknown Lewitus Social_system code: ",
                       paste(unique(social_values[!valid]), collapse = ", "))
  decoded <- unname(social_labels[social_values])
  out$Value[social_rows] <- ifelse(is.na(decoded), social_values, decoded)
  out$Value_num[social_rows] <- NA_real_
  out <- out[!is.na(out$Value) & nzchar(out$Value), ]
  # Hemispheres: marked on the merge's own species name and label, so before
  # the subspecies rule renames anything.
  out$Hemispheres <- hemisphere_basis(out)
  # Subspecies: the value is served under the species; the name it was filed
  # under stays in the Subspecies column. Done before label precedence, so
  # precedence is decided at species rank.
  hit <- match(out$Species, subspecies_key$member)
  out$Subspecies <- ifelse(is.na(hit), "", out$Species)
  out$Species[!is.na(hit)] <- subspecies_key$species[hit[!is.na(hit)]]
  message("subspecies: ", sum(!is.na(hit)), " row(s) filed under their species")
  # Label precedence (_keys/label_precedence.csv): where the winning dataset has
  # a species for the label, the yielding dataset's row for it is not served.
  # A species only the yielding dataset has keeps its row. Applied after empty
  # values are removed, so an empty cell never wins.
  yield <- rep(FALSE, nrow(out))
  for (i in seq_len(nrow(precedence))) {
    v <- precedence$variable[i]
    win <- out$Variable == v & out$Dataset == precedence$winning_dataset[i]
    los <- out$Variable == v & out$Dataset == precedence$yielding_dataset[i]
    if (!any(win) || !any(los))
      stop("_keys/label_precedence.csv row ", i, " (", v, "): ",
           if (!any(win)) precedence$winning_dataset[i] else precedence$yielding_dataset[i],
           " serves no such label. Correct or remove the row.", call. = FALSE)
    yield <- yield | (los & out$Species %in% out$Species[win])
  }
  message("label precedence: ", sum(yield), " row(s) not served because another dataset wins")
  out <- out[!yield, ]
  out[order(out$Species, out$Variable), ]
}

compiled <- load_compiled()

# ---- Wild/domestic population verdict (pk: copy of app.R; the rest moved) ----
# Row-level verdict for compiled rows under a wild-form label; see
# _keys/README_species_pooling.md. The app reads the result as
# compiled$population_verdict.
pooling_key <- tryCatch(read_csv_gh(GH$pooling, file.path(data_dir, "species_pooling.csv")),
                        error = function(e) NULL)
population_key <- tryCatch(read_csv_gh(GH$population, file.path(data_dir, "population_status.csv")),
                           error = function(e) NULL)
pk <- if (!is.null(pooling_key) && nrow(pooling_key)) {
  p <- pooling_key[trimws(as.character(pooling_key$axis)) == "domestication", , drop = FALSE]
  for (cl in c("pool_id", "member", "relation")) p[[cl]] <- trimws(as.character(p[[cl]]))
  p$label <- unalias(p$member)                       # the compiled spelling of the member
  gone <- p$label[!p$label %in% compiled$Species]
  if (length(gone))
    message("species_pooling.csv names label(s) with no compiled data: ", paste(gone, collapse = "; "))
  n_dom <- tapply(p$relation == "domestic_form", p$pool_id, sum)
  if (any(n_dom != 1L))
    message("species_pooling.csv: each pool needs exactly one domestic_form row; offending: ",
            paste(names(n_dom)[n_dom != 1L], collapse = ", "))
  p
} else NULL
wild_labels <- if (is.null(pk)) character(0) else unique(pk$label[pk$relation == "wild_form"])
# Row-level population verdict for compiled rows under a wild-form label. A row is
# one merge cell and may pool several source tokens (compiled$Teams, ";"-separated).
# Each token is looked up by (label, token). The verdict is domestic if every token
# is domestic, wild if every token is wild, mixed if any token is domestic or mixed,
# otherwise unknown -- a token missing from the key counts as unknown.
row_population <- function(species, teams) {
  if (is.null(population_key) || !nrow(population_key)) return(rep("unknown", length(species)))
  pop <- setNames(trimws(as.character(population_key$population)),
                  paste(unalias(trimws(as.character(population_key$accepted_name))),
                        trimws(as.character(population_key$source_table)), sep = "\r"))
  vapply(seq_along(species), function(i) {
    tk <- if (is.na(teams[i])) character(0) else trimws(strsplit(teams[i], ";", fixed = TRUE)[[1]])
    tk <- tk[nzchar(tk)]
    if (!length(tk)) return("unknown")
    p <- unname(pop[paste(species[i], tk, sep = "\r")]); p[is.na(p)] <- "unknown"
    if (all(p == "domestic")) "domestic" else if (all(p == "wild")) "wild"
    else if (any(p %in% c("domestic", "mixed"))) "mixed" else "unknown"
  }, character(1))
}
compiled$population_verdict <- NA_character_
is_wild_row <- compiled$Species %in% wild_labels
if (any(is_wild_row))
  compiled$population_verdict[is_wild_row] <-
    row_population(compiled$Species[is_wild_row], compiled$Teams[is_wild_row])
if (is.null(pooling_key) || is.null(population_key))
  stop("_keys/species_pooling.csv and _keys/population_status.csv are both needed.", call. = FALSE)

# ---- domain and measure_class (copy of app.R) -------------------------------
# The key behind the app's two-tier variable picker (Domain > Measure class).
vardef <- tryCatch(
  read_csv_gh("_keys/variable_definitions.csv",
              file.path(data_dir, "variable_definitions.csv")),
  error = function(e) NULL)
have_org <- !is.null(vardef) && nrow(vardef) && all(c("label", "domain") %in% names(vardef))
vd_get <- function(col) {
  if (!have_org || !col %in% names(vardef)) return(setNames(character(0), character(0)))
  setNames(trimws(as.character(vardef[[col]])), vardef$label)
}
lab_domain <- vd_get("domain");        lab_class  <- vd_get("measure_class")
look <- function(map, k) {
  if (!length(map)) return(rep("", length(k)))
  v <- unname(map[k]); v[is.na(v)] <- ""; v
}
if (!have_org || !"measure_class" %in% names(vardef))
  stop("_keys/variable_definitions.csv with columns label, domain, measure_class is needed.", call. = FALSE)
compiled$domain <- look(lab_domain, compiled$Variable)
compiled$domain[!nzchar(compiled$domain)] <- "Unclassified"
compiled$measure_class <- look(lab_class, compiled$Variable)
compiled$measure_class[!nzchar(compiled$measure_class)] <- "other"

# Not a measurement (owner rule of 2026-11-24): a label the key marks
# is_measurement = False is a note about the data, such as how a species name
# was determined. It is not a variable and is not served; it stays on record in
# the file it came from.
not_meas <- tolower(look(vd_get("is_measurement"), compiled$Variable)) == "false"
message("not a measurement: ", sum(not_meas), " row(s) of ", length(unique(compiled$Variable[not_meas])),
        " label(s) not served")
compiled <- compiled[!not_meas, , drop = FALSE]

# ---- write ------------------------------------------------------------------
COLS <- c(Species = "character", Dataset = "character", Variable = "character",
          Value = "character", Value_num = "numeric", Source = "character",
          Items = "character", Source_details = "character", Teams = "character",
          N_sources = "integer", Variable_raw = "character", Unit = "character",
          Unit_raw = "character", population_verdict = "character",
          domain = "character", measure_class = "character", Subspecies = "character",
          Hemispheres = "character")
compiled <- compiled[c(setdiff(names(compiled), c("Subspecies", "Hemispheres")), "Subspecies", "Hemispheres")]
if (!identical(names(compiled), names(COLS)))
  stop("The loader produced columns [", paste(names(compiled), collapse = ", "),
       "]; expected [", paste(names(COLS), collapse = ", "), "].", call. = FALSE)
if (!identical(unname(vapply(compiled, function(x) class(x)[1], "")), unname(COLS)))
  stop("A column of the compiled table changed type; expected ",
       paste(names(COLS), COLS, sep = ":", collapse = ", "), ".", call. = FALSE)
if (!nrow(compiled)) stop("The loader produced an empty table.", call. = FALSE)

# byte order on Species, then Variable; ties keep the order the feeds were bound in
compiled <- compiled[order(compiled$Species, compiled$Variable, method = "radix"), ]
rownames(compiled) <- NULL

# Text for each cell. Missing is NA (unquoted); text is always quoted, so an
# empty string stays distinct from missing. A number is written with the fewest
# digits that read back as the same double (15, else 16, else 17).
fmt_chr <- function(x) {
  x <- enc2utf8(x)
  if (any(!validUTF8(x[!is.na(x)]))) stop("A text value is not valid UTF-8.", call. = FALSE)
  if (any(x %in% "NA")) stop("A text value is the literal string NA, which a CSV cannot tell from missing.", call. = FALSE)
  if (any(grepl("[\r\n]", x))) stop("A text value contains a line break.", call. = FALSE)
  ifelse(is.na(x), "NA", paste0("\"", gsub("\"", "\"\"", x, fixed = TRUE), "\""))
}
fmt_num <- function(x) {
  s <- sprintf("%.15g", x)
  for (d in 16:17) {
    bad <- is.finite(x) & suppressWarnings(as.numeric(s)) != x
    if (!any(bad)) break
    s[bad] <- sprintf(paste0("%.", d, "g"), x[bad])
  }
  s[is.na(x) & !is.nan(x)] <- "NA"
  s
}
fmt_int <- function(x) ifelse(is.na(x), "NA", sprintf("%d", x))
cells <- lapply(names(COLS), function(nm) switch(COLS[[nm]],
  character = fmt_chr(compiled[[nm]]), numeric = fmt_num(compiled[[nm]]), integer = fmt_int(compiled[[nm]])))
lines <- c(paste0("\"", names(COLS), "\"", collapse = ","), do.call(paste, c(cells, sep = ",")))

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
out_file <- file.path(out_dir, OUT_NAME)
tmp_file <- paste0(out_file, ".tmp")
con <- gzfile(tmp_file, open = "wb", compression = 9)
writeLines(lines, con, sep = "\n", useBytes = TRUE)
close(con)

# Read the file back the way the apps do and insist it is the table just built.
back <- read.csv(tmp_file, colClasses = COLS, check.names = FALSE, stringsAsFactors = FALSE)
if (!identical(back, compiled)) {
  unlink(tmp_file)
  stop("The written file does not read back as the table that was built; nothing was replaced.", call. = FALSE)
}
if (!file.rename(tmp_file, out_file)) stop("Could not move the new file into place: ", out_file, call. = FALSE)

# ---- data points of the one route --------------------------------------------
dp_write_points(dp_all, out_dir)
cat(sprintf("data points: %d (%d items, %d traits) -> %s\n", nrow(dp_all), length(unique(dp_all$item)),
            length(unique(dp_all$trait)), file.path(out_dir, "datapoints.csv.gz")))

# ---- subspecies register ----------------------------------------------------
# What the table holds below species rank: every filed subspecies, and every
# three-word label under a species of the table that is not filed (domestic
# forms, species groups, names awaiting a decision). Written beside the table.
all_cells <- table(paste(compiled$Species, compiled$Dataset, compiled$Variable, sep = "\r"))
reg_rows <- function(d, name, species, status) {
  cell <- paste(d$Species, d$Dataset, d$Variable, sep = "\r")
  sib <- compiled[nzchar(compiled$Subspecies) & compiled$Species == species & compiled$Subspecies != name, , drop = FALSE]
  data.frame(name = name, species = species, status = status, n_values = nrow(d),
             n_variables = length(unique(d$Variable)),
             n_cells_shared_with_other_rows_of_the_species = if (status == "filed") sum(all_cells[unique(cell)] > 1L) else NA_integer_,
             n_variables_also_measured_in_another_subspecies = if (status == "filed") length(intersect(unique(d$Variable), unique(sib$Variable))) else NA_integer_,
             datasets = paste(sort(unique(d$Dataset)), collapse = "; "),
             sources = paste(sort(unique(trimws(unlist(strsplit(d$Teams[!is.na(d$Teams)], ";", fixed = TRUE))))), collapse = "; "),
             stringsAsFactors = FALSE)
}
filed <- split(compiled[nzchar(compiled$Subspecies), , drop = FALSE], compiled$Subspecies[nzchar(compiled$Subspecies)])
reg <- lapply(names(filed), function(nm) reg_rows(filed[[nm]], nm, filed[[nm]]$Species[1], "filed"))
three <- unique(compiled$Species[grepl("^[A-Z][a-z]+ [a-z][a-z-]+ [a-z][a-z-]+$", compiled$Species)])
three <- three[sub(" [^ ]+$", "", three) %in% compiled$Species]
dom_forms <- if (is.null(pk)) character(0) else pk$label[pk$relation == "domestic_form"]
for (nm in sort(three, method = "radix")) {
  ep <- sub("^.* ", "", nm)
  st <- if (nm %in% dom_forms) "not filed: domestic form (domestication axis)"
        else if (ep == "group") "not filed: species group, not a subspecies"
        else if (ep %in% c("familiaris", "domesticus", "domestica", "furo", "hircus", "caballus", "indicus", "taurus", "catus", "aries", "asinus", "dingo", "hallstromi"))
          "not filed: domestic or feral form, awaiting a decision"
        else "not filed: awaiting a decision"
  reg[[length(reg) + 1L]] <- reg_rows(compiled[compiled$Species == nm, , drop = FALSE], nm, sub(" [^ ]+$", "", nm), st)
}
reg <- if (length(reg)) do.call(rbind, reg) else reg_rows(compiled[0, ], character(0), character(0), character(0))[0, ]
reg <- reg[order(reg$status != "filed", reg$species, reg$name, method = "radix"), ]
reg_cells <- lapply(names(reg), function(nm) if (is.character(reg[[nm]])) fmt_chr(reg[[nm]]) else fmt_int(as.integer(reg[[nm]])))
reg_lines <- c(paste0("\"", names(reg), "\"", collapse = ","), do.call(paste, c(reg_cells, sep = ",")))
reg_con <- file(file.path(out_dir, "subspecies_register.csv"), open = "wb")
writeLines(reg_lines, reg_con, sep = "\n", useBytes = TRUE)
close(reg_con)
cat(sprintf("subspecies register: %d filed, %d not filed\n", sum(reg$status == "filed"), sum(reg$status != "filed")))

csv_bytes <- sum(nchar(lines, type = "bytes")) + length(lines)
cat(sprintf("compiled: %d rows, %d species, %d variables, %d datasets, %d columns\n", nrow(compiled),
            length(unique(compiled$Species)), length(unique(compiled$Variable)),
            length(unique(compiled$Dataset)), ncol(compiled)))
cat(sprintf("wrote %s: %.1f MB gzip (%.1f MB as plain CSV)\n", out_file,
            file.size(out_file) / 1e6, csv_bytes / 1e6))
