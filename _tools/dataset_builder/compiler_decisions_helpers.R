## compiler_decisions_helpers.R -- shared functions for stage 11 of the *_refs_check
## pipelines (contract: COMPILER_DECISIONS_CONTRACT.md). Findings only; no value is changed.
## Depends on dplyr/tidyr/readr/stringr (tidyverse), already loaded by every pipeline config.

CD_MECHANISMS <- c("row_displacement", "digit_substitution", "unit_or_reference_slip",
                   "structure_definition_drift", "unrounded_working_value", "truncation",
                   "averaging_component_omitted", "wrong_citation", "format_artefact", "unexplained")
CD_PATTERNS <- c("taken_from_other_source", "comp_has_cell_unattributed", "whole_column", "whole_taxon",
                 "n_threshold", "isolated_probable_accident", "unassessed")

cd_norm_species <- function(x) {
  x <- tolower(trimws(as.character(x))); x <- gsub("_", " ", x); x <- gsub("\\s+", " ", x)
  ## trinomial -> binomial
  vapply(strsplit(x, " "), function(w) paste(head(w[nzchar(w)], 2), collapse = " "), "")
}

## ---- 1. coverage inverse ------------------------------------------------------------------
## index:  source_id, paper, species_norm, source_column, source_value, source_n (may be NA)
## comp:   species_norm, comp_column, comp_source (source_id the audit attributed the cell to; "" if none)
## colmap: source_id, source_column, comp_column  -- learned from verified matches
cd_coverage_inverse <- function(index, comp, colmap) {
  stopifnot(all(c("source_id", "species_norm", "source_column") %in% names(index)),
            all(c("species_norm", "comp_column") %in% names(comp)),
            all(c("source_id", "source_column", "comp_column") %in% names(colmap)))
  if (!"source_n" %in% names(index)) index$source_n <- NA_real_
  if (!"paper" %in% names(index)) index$paper <- sub("_(Table|TABLE|Fig|Figure|Supp|Results|text).*$", "", index$source_id)
  if (!"comp_source" %in% names(comp)) comp$comp_source <- ""
  colmap <- distinct(colmap, source_id, source_column, comp_column)
  comp <- distinct(comp, species_norm, comp_column, .keep_all = TRUE)
  comp_species <- unique(comp$species_norm)
  ix <- index %>% left_join(colmap, by = c("source_id", "source_column"), relationship = "many-to-many")
  ix <- ix %>% left_join(comp %>% rename(comp_source_for_cell = comp_source) %>% mutate(comp_has_cell = TRUE),
                         by = c("species_norm", "comp_column"))
  ix$comp_has_cell <- coalesce(ix$comp_has_cell, FALSE)
  ix$comp_source_for_cell <- coalesce(ix$comp_source_for_cell, "")
  ## per (source_id, comp_column): did the compilation ever take it from this source, and smallest N taken
  taken <- ix %>% filter(comp_has_cell, comp_source_for_cell == source_id) %>%
    group_by(source_id, comp_column) %>%
    summarise(n_taken = n(), min_n_taken = suppressWarnings(min(as.numeric(source_n), na.rm = TRUE)), .groups = "drop")
  ## per (source_id, species): did the compilation take any column from this row of this source
  row_taken <- ix %>% filter(comp_has_cell, comp_source_for_cell == source_id) %>%
    distinct(source_id, species_norm) %>% mutate(row_taken = TRUE)
  ix <- ix %>% left_join(taken, by = c("source_id", "comp_column")) %>%
    left_join(row_taken, by = c("source_id", "species_norm")) %>%
    mutate(row_taken = coalesce(row_taken, FALSE), n_taken = coalesce(n_taken, 0L),
           src_n = suppressWarnings(as.numeric(source_n)))
  out <- ix %>% filter(!(comp_has_cell & comp_source_for_cell == source_id)) %>%
    mutate(pattern = case_when(
      is.na(comp_column) ~ "unassessed",
      comp_has_cell & nzchar(comp_source_for_cell) ~ "taken_from_other_source",
      comp_has_cell ~ "comp_has_cell_unattributed",
      !(species_norm %in% comp_species) ~ "whole_taxon",
      n_taken == 0 ~ "whole_column",
      !is.na(src_n) & is.finite(min_n_taken) & src_n < min_n_taken ~ "n_threshold",
      row_taken ~ "isolated_probable_accident",
      TRUE ~ "unassessed"),
      evidence = case_when(
        pattern == "taken_from_other_source" ~ paste0("compilation cell attributed to ", comp_source_for_cell),
        pattern == "comp_has_cell_unattributed" ~ "compilation has the cell but the audit attributed it to no source; this source offers a value",
        pattern == "whole_taxon" ~ "species absent from the compilation",
        pattern == "whole_column" ~ paste0("compilation never takes ", comp_column, " from ", source_id),
        pattern == "n_threshold" ~ paste0("smallest N taken from ", source_id, " for ", comp_column, " = ", min_n_taken, "; this row N = ", src_n),
        pattern == "isolated_probable_accident" ~ paste0("compilation took other columns of this species' row from ", source_id, " (", n_taken, " cells of ", comp_column, " taken from it overall)"),
        TRUE ~ ifelse(is.na(comp_column), "source column never matched a compilation column", "species could not be placed"))) %>%
    select(source_id, paper, species_norm, source_column, comp_column, source_value, source_n,
           comp_has_cell, comp_source_for_cell, pattern, evidence) %>%
    arrange(factor(pattern, levels = CD_PATTERNS), source_id, species_norm, comp_column)
  out
}

## learn the source->compilation column map from verified matches:
## matches: source_id, source_column, comp_column (one row per matched cell)
cd_learn_colmap <- function(matches, min_cells = 1L) {
  matches %>% filter(!is.na(source_id), nzchar(source_id), !is.na(source_column), nzchar(source_column)) %>%
    count(source_id, source_column, comp_column, name = "cells") %>% filter(cells >= min_cells)
}

## ---- 2. error taxonomy --------------------------------------------------------------------
## final must carry: row_id, species, comp_column, comp_value, source_value, verification_status, correction_reason
## rules: named character vector  mechanism = regex  matched (case-insensitive) against
##        paste(verification_status, correction_reason, note); first hit wins in the given order.
cd_error_taxonomy <- function(final, rules, errata_ids = NULL) {
  stopifnot(all(names(rules) %in% CD_MECHANISMS))
  txt <- tolower(paste(final$verification_status, final$correction_reason, final$note, sep = " | "))
  mech <- rep(NA_character_, nrow(final))
  for (m in names(rules)) { hit <- is.na(mech) & grepl(rules[[m]], txt, perl = TRUE); mech[hit] <- m }
  e <- final %>% mutate(mechanism = mech) %>% filter(!is.na(mechanism))
  if (!"errata_id" %in% names(e)) e$errata_id <- ""
  if (!is.null(errata_ids)) e$errata_id <- coalesce(errata_ids[e$row_id], e$errata_id)
  e <- e %>% mutate(evidence = coalesce(na_if(correction_reason, "NA"), ""), evidence = ifelse(nzchar(evidence), evidence, note)) %>%
    select(row_id, species, comp_column, comp_value, source_value, mechanism, verification_status,
           correction_reason, errata_id, evidence)
  counts <- e %>% count(mechanism, name = "n") %>%
    transmute(row_id = "COUNT", species = "", comp_column = "", comp_value = as.character(n), source_value = "",
              mechanism, verification_status = "", correction_reason = "", errata_id = "", evidence = paste(n, "cells"))
  bind_rows(counts, e %>% mutate(across(everything(), as.character)))
}

## ---- 3. averaging tests -------------------------------------------------------------------
## cells: row_id, species, comp_column, comp_value (numeric), comp_n, decimals
## cands: row_id, source_id, value (numeric), n (numeric or NA)
cd_averaging_tests <- function(cells, cands) {
  eq <- function(a, b, d) !is.na(a) & !is.na(b) & abs(a - b) < 0.5 * 10^(-d) + 1e-9
  cands <- cands %>% filter(!is.na(value))
  agg <- cands %>% group_by(row_id) %>%
    summarise(candidate_sources = paste(source_id, collapse = "; "),
              candidate_values = paste(format(value, trim = TRUE), collapse = "; "),
              candidate_ns = paste(ifelse(is.na(n), "?", n), collapse = "; "),
              k = n(), mean_unweighted = mean(value),
              mean_n_weighted = if (all(!is.na(n)) && sum(n) > 0) sum(value * n) / sum(n) else NA_real_,
              .groups = "drop")
  single <- cands %>% select(row_id, value)
  cells %>% left_join(agg, by = "row_id") %>%
    rowwise() %>%
    mutate(d = ifelse(is.na(decimals), 0, decimals),
           matches_unweighted = !is.na(k) && k >= 2 && eq(comp_value, mean_unweighted, d),
           matches_n_weighted = !is.na(k) && k >= 2 && eq(comp_value, mean_n_weighted, d),
           matches_single_candidate = any(eq(comp_value, single$value[single$row_id == row_id], d)),
           verdict = case_when(
             is.na(k) | k < 2 ~ ifelse(matches_single_candidate, "single_source_relabelled_n", "not_tested_insufficient_candidates"),
             matches_n_weighted & !matches_unweighted ~ "pooled_n_weighted",
             matches_unweighted ~ "pooled_unweighted",
             matches_single_candidate ~ "single_source_relabelled_n",
             TRUE ~ "not_reproduced")) %>% ungroup() %>%
    mutate(mean_unweighted = round(mean_unweighted, 6), mean_n_weighted = round(mean_n_weighted, 6)) %>%
    select(row_id, species, comp_column, comp_value, comp_n, candidate_sources, candidate_values, candidate_ns,
           mean_unweighted, mean_n_weighted, matches_unweighted, matches_n_weighted, matches_single_candidate, verdict)
}

## ---- 4. source priority -------------------------------------------------------------------
## offers: cell_key, source_id, value, n, year, cited (logical: this source is the one the compilation cites)
## chosen: cell_key, chosen_source (source_id the audit attributed the value to; "" if none)
cd_source_priority <- function(offers, chosen) {
  offers <- offers %>% distinct(cell_key, source_id, .keep_all = TRUE) %>% left_join(chosen, by = "cell_key")
  multi <- offers %>% group_by(cell_key) %>% filter(n_distinct(source_id) >= 2) %>% ungroup()
  if (!nrow(multi)) return(list(pairs = tibble(), cells = tibble()))
  pairs <- multi %>% group_by(cell_key) %>%
    reframe({
      s <- pick(everything()); ids <- sort(unique(s$source_id)); cmb <- combn(ids, 2)
      tibble(source_a = cmb[1, ], source_b = cmb[2, ]) %>%
        rowwise() %>% mutate(
          chosen = first(s$chosen_source),
          year_a = first(s$year[s$source_id == source_a]), year_b = first(s$year[s$source_id == source_b]),
          n_a = first(s$n[s$source_id == source_a]), n_b = first(s$n[s$source_id == source_b]),
          value_a = first(s$value[s$source_id == source_a]), value_b = first(s$value[s$source_id == source_b]),
          cited_a = any(s$cited[s$source_id == source_a]), cited_b = any(s$cited[s$source_id == source_b])) %>% ungroup()
    })
  cells <- pairs %>% mutate(picked = case_when(chosen == source_a ~ "a", chosen == source_b ~ "b", TRUE ~ "neither"))
  summ <- cells %>% group_by(source_a, source_b) %>%
    summarise(cells_both_offer = n(), chosen_a = sum(picked == "a"), chosen_b = sum(picked == "b"),
              chosen_neither = sum(picked == "neither"),
              a_newer = first(!is.na(year_a) & !is.na(year_b) & year_a > year_b),
              years_known = first(!is.na(year_a) & !is.na(year_b) & year_a != year_b),
              ## N comparison only over cells where BOTH sources print an N
              n_comparable = mean(!is.na(n_a) & !is.na(n_b)),
              a_larger_n = { ok <- !is.na(n_a) & !is.na(n_b); if (any(ok)) mean(n_a[ok] > n_b[ok]) > 0.5 else NA },
              b_larger_n = { ok <- !is.na(n_a) & !is.na(n_b); if (any(ok)) mean(n_b[ok] > n_a[ok]) > 0.5 else NA },
              ## citation: which side is the one the compilation cites (a tie is not a rule)
              only_a_cited = mean(cited_a) > 0 & mean(cited_b) == 0,
              only_b_cited = mean(cited_b) > 0 & mean(cited_a) == 0,
              a_is_cited_more = mean(cited_a) > mean(cited_b),
              .groups = "drop") %>%
    mutate(winner = case_when(chosen_a + chosen_b == 0 ~ "none",
                              pmax(chosen_a, chosen_b) / (chosen_a + chosen_b) < 0.75 ~ "mixed",
                              chosen_a > chosen_b ~ "a", TRUE ~ "b"),
           dominant_rule = case_when(
             winner == "none" ~ "n/a",
             winner == "mixed" ~ "mixed",
             (winner == "a" & only_a_cited) | (winner == "b" & only_b_cited) ~ "cited_reference",
             n_comparable > 0.5 & ((winner == "a" & isTRUE(a_larger_n)) | (winner == "b" & isTRUE(b_larger_n))) ~ "larger_n",
             years_known & ((winner == "a" & a_newer) | (winner == "b" & !a_newer)) ~ "newer",
             years_known ~ "older",
             TRUE ~ "mixed")) %>%
    select(-winner, -years_known, -b_larger_n, -only_a_cited, -only_b_cited) %>%
    arrange(desc(cells_both_offer))
  list(pairs = summ, cells = cells %>% select(cell_key, source_a, source_b, chosen, picked, value_a, value_b, year_a, year_b, n_a, n_b, cited_a, cited_b))
}

## ---- 5. discoveries & markdown --------------------------------------------------------------
cd_discovery <- function(kind, subject, finding, evidence, made_by = "compiler", where_recorded = "") {
  stopifnot(kind %in% c("species_identity", "specimen_identity", "anatomical_correspondence", "recalculation", "exclusion_rule"),
            made_by %in% c("compiler", "audit"))
  tibble(kind = kind, subject = subject, finding = finding, evidence = evidence, made_by = made_by, where_recorded = where_recorded)
}

cd_md_table <- function(df, max_rows = 25) {
  if (!nrow(df)) return("_none_")
  df <- head(df, max_rows) %>% mutate(across(everything(), ~ gsub("\\|", "\\\\|", gsub("\n", " ", as.character(.x)))))
  c(paste0("| ", paste(names(df), collapse = " | "), " |"), paste0("|", paste(rep("---", ncol(df)), collapse = "|"), "|"),
    apply(df, 1, function(r) paste0("| ", paste(r, collapse = " | "), " |")))
}

cd_write_csv <- function(df, path) {
  readr::write_csv(df, path, na = "")
  invisible(path)
}

## ---- 6. declared relationships (_keys/source_relationships.csv) -------------------------
## Reads the key; returns one row per unordered PAPER pair with the relationship, the winner
## (paper id or "none"/"split") and the rule. Table-level source ids are collapsed to paper ids
## with cd_paper_of(). Scoped rows: the first row per pair whose scope is "all shared cells" is
## used for prediction; other scopes are kept in `scoped_rows` for the .md.
cd_paper_of <- function(sid) sub("_(Table|TABLE|Tables|Fig|Figure|Figures|Supp|SupTable|SupplementalTable|Results|ResultsText|text)\\S*$", "", sid)

cd_declared_relationship <- function(key_file = file.path(EVOM1_ROOT, "_keys", "source_relationships.csv")) {
  if (!file.exists(key_file)) return(NULL)
  k <- read.csv(text = readLines(key_file, encoding = "UTF-8", warn = FALSE), colClasses = "character",
                check.names = FALSE, na.strings = character(), encoding = "UTF-8")
  names(k) <- sub("^\ufeff", "", names(k))
  k <- k[nzchar(k$relationship) & k$status != "undeclared", , drop = FALSE]
  if (!nrow(k)) return(NULL)
  k$winner <- ifelse(grepl(" over ", k$direction), sub(" over .*$", "", k$direction),
                     ifelse(k$direction %in% c("none", "split"), k$direction, ""))
  k$pa <- pmin(k$paper_a, k$paper_b); k$pb <- pmax(k$paper_a, k$paper_b)
  k
}

## Attach declared relationship + conformity test to cd_source_priority() output.
## sp: list(pairs=, cells=) from cd_source_priority(); key: cd_declared_relationship().
cd_test_declared <- function(sp, key) {
  pairs <- sp$pairs; cells <- sp$cells
  if (is.null(key) || !nrow(pairs)) {
    pairs$declared_relationship <- ""; pairs$declared_winner <- ""; pairs$follows_declared_relationship <- "undeclared"
    cells$declared_winner <- ""; cells$follows_declared <- "undeclared"
    return(list(pairs = pairs, cells = cells, exceptions = cells[0, ]))
  }
  ## one prediction per paper pair: a single row, or several rows that agree on the winner; rows
  ## that disagree (different scopes point to different winners) yield "scoped_mixed" -- the
  ## test then needs column-level scope, which the cells table does not carry.
  gen <- key %>% group_by(pa, pb) %>%
    summarise(relationship = paste(sort(unique(relationship)), collapse = " / "),
              winner = if (n_distinct(winner) == 1) first(winner) else "scoped_mixed",
              rule = first(rule), n_rows = n(), .groups = "drop") %>% as.data.frame()
  lk <- function(a, b) {
    pa <- pmin(cd_paper_of(a), cd_paper_of(b)); pb <- pmax(cd_paper_of(a), cd_paper_of(b))
    i <- match(paste(pa, pb), paste(gen$pa, gen$pb)); gen[i, , drop = FALSE]
  }
  kp <- lk(pairs$source_a, pairs$source_b)
  pairs$declared_relationship <- coalesce(kp$relationship, "")
  pairs$declared_winner <- coalesce(kp$winner, "")
  pairs$declared_rule <- coalesce(kp$rule, "")
  pw <- ifelse(pairs$chosen_a + pairs$chosen_b == 0, "none",
               ifelse(pairs$chosen_a > pairs$chosen_b, cd_paper_of(pairs$source_a), cd_paper_of(pairs$source_b)))
  pairs$follows_declared_relationship <- case_when(
    !nzchar(pairs$declared_relationship) ~ "undeclared",
    pairs$declared_winner %in% c("none", "split") ~ "not_a_choice",
    pairs$declared_winner == "scoped_mixed" ~ "scoped_mixed",
    pw == "none" ~ "no_observation",
    pw == pairs$declared_winner ~ "yes",
    TRUE ~ "no")
  kc <- lk(cells$source_a, cells$source_b)
  cells$declared_relationship <- coalesce(kc$relationship, "")
  cells$declared_winner <- coalesce(kc$winner, "")
  cw <- ifelse(cells$picked == "a", cd_paper_of(cells$source_a), ifelse(cells$picked == "b", cd_paper_of(cells$source_b), ""))
  cells$follows_declared <- case_when(
    !nzchar(cells$declared_relationship) ~ "undeclared",
    cells$declared_winner %in% c("none", "split") ~ "not_a_choice",
    cells$declared_winner == "scoped_mixed" ~ "scoped_mixed",
    cells$picked == "neither" ~ "no_observation",
    cw == cells$declared_winner ~ "yes",
    TRUE ~ "no")
  ## kind of exception: the two sources print the same number (the compiler merely CITED the
  ## source the key says is not primary) or different numbers (the compiler TOOK the losing value)
  same <- if (all(c("value_a", "value_b") %in% names(cells))) {
    va <- suppressWarnings(as.numeric(cells$value_a)); vb <- suppressWarnings(as.numeric(cells$value_b))
    !is.na(va) & !is.na(vb) & abs(va - vb) <= 1e-9 * pmax(1, abs(va))
  } else rep(NA, nrow(cells))
  ## same measurement printed at two precisions (66.45 vs 66.5 cm3; 6450 vs 6500 mm3): equal once
  ## the finer print is rounded to the significant digits of the coarser print (half a unit of the
  ## coarser value's last significant digit is the tolerance)
  .nsig <- function(x) { s <- sub("^-", "", format(x, scientific = FALSE, trim = TRUE)); s <- gsub("\\.", "", s); s <- sub("^0+", "", s); s <- sub("0+$", "", s); nchar(s) }
  sig_equal <- if (all(c("value_a", "value_b") %in% names(cells))) {
    va <- suppressWarnings(as.numeric(cells$value_a)); vb <- suppressWarnings(as.numeric(cells$value_b))
    ok <- !is.na(va) & !is.na(vb) & va != 0 & vb != 0
    r <- rep(FALSE, length(va))
    if (any(ok)) {
      n <- pmin(.nsig(va[ok]), .nsig(vb[ok])); n[n < 1] <- 1
      coarse <- ifelse(.nsig(va[ok]) <= .nsig(vb[ok]), va[ok], vb[ok])
      unit <- 10^(floor(log10(abs(coarse))) - n + 1)      # value of the coarser print's last significant digit
      r[ok] <- abs(va[ok] - vb[ok]) <= 0.5 * unit + 1e-9
    }
    r
  } else rep(FALSE, nrow(cells))
  cells$exception_kind <- ifelse(cells$follows_declared != "no", "",
                                 ifelse(is.na(same), "values_not_compared",
                                        ifelse(same, "cited_non_primary_same_value",
                                               ifelse(sig_equal, "same_measurement_different_precision", "took_losing_value"))))
  ex <- cells[cells$follows_declared == "no", , drop = FALSE]
  kinds <- ex %>% count(source_a, source_b, exception_kind) %>% tidyr::pivot_wider(names_from = exception_kind, values_from = n, values_fill = 0)
  for (k in c("took_losing_value", "cited_non_primary_same_value", "same_measurement_different_precision", "values_not_compared")) if (!k %in% names(kinds)) kinds[[k]] <- 0L
  pairs <- pairs %>% left_join(kinds %>% select(source_a, source_b, took_losing_value, cited_non_primary_same_value, same_measurement_different_precision), by = c("source_a", "source_b")) %>%
    mutate(took_losing_value = coalesce(took_losing_value, 0L), cited_non_primary_same_value = coalesce(cited_non_primary_same_value, 0L),
           same_measurement_different_precision = coalesce(same_measurement_different_precision, 0L))
  list(pairs = pairs, cells = cells, exceptions = ex)
}
