# =============================================================================
# resolve_tips.R -- shared name -> tip resolution for every tree build.
#
# Sourced by build_mammal_tree.R, build_mammal_trees_sample.R and
# build_mammal_tree_augmented.R so the three builds cannot drift apart.
# resolve_tips.py is the Python mirror; keep the two in step.
#
#   resolve_tips(xw, tip_labels, universe)
#     xw          tree_tip_crosswalk.csv as a data.frame of character columns
#     tip_labels  tip labels of the SOURCE tree ("Genus_species_FAMILY_ORDER")
#     universe    species_universe.csv (accepted_name, in_species_reference,
#                 mdd_current, n_tables) or NULL
#     recognised  lower-case binomials the SOURCE taxonomy recognises as species
#                 (for the DNA-only tree: Upham et al.'s full 5,911-species list),
#                 or NULL
#   returns list(report = data.frame, keep_tip = chr, keep_acc = chr)
#
# RULES
#   * Only auto_match = TRUE candidates are matched, in candidate_rank order.
#   * A name the source taxonomy itself recognises as a species is matched ONLY
#     under that name. If it has no tip (no sequence data) it is absent; it is
#     never bridged to another tip by a synonymy newer than the tree. Without
#     this, Petaurista magnificus -- a separate, unsequenced species in Upham et
#     al. 2019 that MDD has since sunk into P. albiventer -- would be placed on
#     the P. albiventer tip, which the tree's own authors did not do.
#   * One tip carries one name. When several names resolve to the same tip the
#     tip goes to, in order:
#       1. a species-level match before a subspecies falling back to its parent
#       2. a name in _keys/species_reference.csv (the curated core) before a
#          label that only occurs in a merge table
#       3. the label that is the current Mammal Diversity Database name before
#          an older label -- the direction _keys/species_display_aliases.csv
#          unifies in ("unify to current name"), so a later alias keeps the tip
#       4. the name that IS the tip spelling before one reaching it by synonym
#       5. the name held in more app tables
#       6. byte order of the name (deterministic, locale-independent)
#   * The losers are reported, never dropped silently:
#       subspecies_of_matched_species   subspecies whose parent tip is taken
#       synonym_of_matched_name         another label for the taxon holds the tip.
#                                       The app treats the two labels as two
#                                       species; unify them in
#                                       _keys/species_display_aliases.csv if the
#                                       data under this label should enter PGLS.
#       conflict_tip_already_used       two names that both ARE the tip spelling
#                                       (case or whitespace variants of one
#                                       string) -- a real error.
# =============================================================================

tip_binom <- function(x) {
  p <- strsplit(gsub("[[:space:]]+", "_", trimws(x)), "_+")
  vapply(p, function(v) {
    v <- v[nzchar(v)]
    if (length(v) >= 2) paste(v[1], v[2]) else paste(v, collapse = " ")
  }, character(1))
}

resolve_tips <- function(xw, tip_labels, universe = NULL, recognised = NULL) {
  lab_of <- setNames(tip_labels, tolower(tip_binom(tip_labels)))
  lab_of <- lab_of[!duplicated(names(lab_of))]

  xw$candidate_rank <- suppressWarnings(as.integer(xw$candidate_rank))
  species <- unique(xw$accepted_name)
  sp_i <- match(xw$accepted_name, species)
  xw <- xw[order(sp_i, ifelse(is.na(xw$candidate_rank), 1e6, xw$candidate_rank)), ]
  sp_i <- match(xw$accepted_name, species)
  has  <- nzchar(xw$candidate_name)
  is_auto   <- xw$auto_match == "TRUE"  & has
  is_review <- xw$auto_match == "FALSE" & has
  on_tree <- unname(lab_of[tolower(xw$candidate_name)])

  first_row <- !duplicated(xw$accepted_name)
  fam <- setNames(xw$family_expected[first_row], xw$accepted_name[first_row])
  ord <- setNames(xw$order_expected[first_row],  xw$accepted_name[first_row])
  n_auto   <- tabulate(sp_i[is_auto],   nbins = length(species))
  n_review <- tabulate(sp_i[is_review], nbins = length(species))
  placeholder  <- species %in% xw$accepted_name[xw$candidate_source == "none_possible"]
  out_of_scope <- species %in% xw$accepted_name[xw$candidate_source == "out_of_scope"]
  oos_note <- setNames(xw$note[xw$candidate_source == "out_of_scope"],
                       xw$accepted_name[xw$candidate_source == "out_of_scope"])

  # names the source taxonomy recognises but this tree does not sample
  own <- tolower(vapply(strsplit(species, " +"), function(v)
    paste(v[seq_len(min(2L, length(v)))], collapse = " "), character(1)))
  blocked <- if (is.null(recognised)) rep(FALSE, length(species))
             else own %in% recognised & !(own %in% names(lab_of))

  # first auto candidate that is a tip, per species
  ok <- is_auto & !is.na(on_tree) & !blocked[sp_i]
  hit <- xw[ok, , drop = FALSE]
  hit$tip <- on_tree[ok]
  hit <- hit[!duplicated(hit$accepted_name), , drop = FALSE]
  h_i <- match(species, hit$accepted_name)          # NA = unresolved
  h_src <- hit$candidate_source[h_i]

  curated  <- rep(FALSE, length(species)); n_tables <- rep(0L, length(species))
  mdd_cur  <- rep(FALSE, length(species))
  if (!is.null(universe)) {
    u_i <- match(species, universe$accepted_name)
    curated  <- !is.na(u_i) & universe$in_species_reference[u_i] == "TRUE"
    mdd_cur  <- !is.na(u_i) & universe$mdd_current[u_i] == "TRUE"
    n_tables <- suppressWarnings(as.integer(universe$n_tables[u_i]))
    n_tables[is.na(n_tables)] <- 0L
  }

  resolved <- !is.na(h_i)
  claim <- order(!resolved,
                 ifelse(resolved & h_src == "subspecies_parent", 1L, 0L),
                 !curated,
                 !mdd_cur,
                 ifelse(resolved & h_src == "accepted_name", 0L, 1L),
                 -n_tables,
                 enc2utf8(species), method = "radix")

  status <- character(length(species)); matched_tip <- via <- csrc <- note <- status
  used <- new.env(hash = TRUE); used_src <- new.env(hash = TRUE)
  review_note <- function(i) {
    r <- xw[sp_i == i & is_review, , drop = FALSE]
    paste0("not on tree under any auto_match name, but these review-only ",
           "candidates exist: ",
           paste0(r$candidate_name,
                  ifelse(tolower(r$candidate_name) %in% names(lab_of),
                         " [ON TREE]", " [not on tree either]"),
                  collapse = "; "))
  }

  for (i in claim) {
    if (resolved[i]) {
      h <- hit[h_i[i], ]
      csrc[i] <- h$candidate_source
      status[i] <- if (csrc[i] == "accepted_name") "matched_direct"
                   else if (csrc[i] == "subspecies_parent") "matched_subspecies_parent"
                   else "matched_synonym"
      holder <- used[[h$tip]]
      if (!is.null(holder)) {
        if (csrc[i] == "subspecies_parent") {
          status[i] <- "subspecies_of_matched_species"
          note[i] <- paste0("parent species tip is held by ", holder,
                            "; a species-level tree cannot separate them, so this row is ",
                            "excluded from PGLS rather than duplicating the tip")
        } else if (csrc[i] == "accepted_name" && used_src[[h$tip]] == "accepted_name") {
          status[i] <- "conflict_tip_already_used"
          note[i] <- paste0("tip already assigned to ", holder,
                            "; resolve in tree_tip_crosswalk.csv before use")
        } else {
          status[i] <- "synonym_of_matched_name"
          note[i] <- paste0("same taxon as ", holder, ", which holds tip ", h$tip,
                            " (reached here via ", h$candidate_name, ", ", csrc[i], ")")
        }
      } else {
        assign(h$tip, species[i], envir = used)
        assign(h$tip, csrc[i], envir = used_src)
        matched_tip[i] <- h$tip; via[i] <- h$candidate_name
        if (status[i] != "matched_direct") note[i] <- h$note
      }
    } else if (out_of_scope[i]) {
      status[i] <- "out_of_scope"
      note[i] <- unname(oos_note[species[i]])
    } else if (placeholder[i]) {
      status[i] <- "unresolvable_placeholder"
      note[i] <- "genus-level name: no single tip can represent it"
    } else if (blocked[i]) {
      status[i] <- "absent_from_tree"
      note[i] <- paste0("recognised as a species by the source taxonomy but not sampled ",
                        "in this tree (no sequence data); not bridged to another tip")
    } else if (n_review[i] > 0) {
      status[i] <- "absent_but_review_lead"
      note[i] <- review_note(i)
    } else {
      status[i] <- "absent_from_tree"
      note[i] <- "no candidate spelling occurs in the source tree"
    }
  }

  report <- data.frame(
    accepted_name = species, status = status, matched_tip = matched_tip,
    matched_via = via, candidate_source = csrc,
    family_expected = unname(fam[species]), order_expected = unname(ord[species]),
    n_auto_candidates = n_auto, n_review_candidates = n_review,
    note = note, stringsAsFactors = FALSE)
  kept <- nzchar(matched_tip)
  list(report = report, keep_tip = matched_tip[kept], keep_acc = species[kept])
}

# Read root ($EVOM1_REPO, default: the repo this file sits in or the cwd) and
# write root ($EVOM1_OUT, default: the read root).
evom1_paths <- function() {
  repo <- Sys.getenv("EVOM1_REPO", unset = "")
  if (!nzchar(repo)) {
    home <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
    repo <- if (dir.exists("__merging_trees")) getwd() else if (dir.exists(home)) home else getwd()
  }
  out <- Sys.getenv("EVOM1_OUT", unset = "")
  if (!nzchar(out)) out <- repo
  for (d in c("_keys", "__merging_trees"))
    dir.create(file.path(out, d), recursive = TRUE, showWarnings = FALSE)
  list(repo = normalizePath(repo), out = normalizePath(out))
}

# Upham et al. 2019's full species list (5,911), as lower-case binomials, read
# from the VertLife job file beside the Completed sample. NULL if unavailable.
upham_completed_taxa <- function(repo) {
  f <- file.path(repo, "Upham_etal_2019", "Completed100_topoCons_NDexp", "config.yaml")
  if (!file.exists(f)) return(NULL)
  txt <- paste(readLines(f, warn = FALSE), collapse = " ")
  m <- regmatches(txt, regexpr("names:\\s*\\[[^]]*\\]", txt))
  if (!length(m)) return(NULL)
  nm <- strsplit(sub("^names:\\s*\\[", "", sub("\\]$", "", m)), ",")[[1]]
  nm <- gsub("[\"']", "", trimws(gsub("\\s+", " ", nm)))
  nm <- nm[nzchar(nm)]
  tolower(tip_binom(nm))
}

# A file the pipeline itself writes (crosswalk, universe): prefer the copy under
# the write root, fall back to the read root.
evom1_pipeline_file <- function(paths, name) {
  f <- file.path(paths$out, "__merging_trees", name)
  if (file.exists(f)) f else file.path(paths$repo, "__merging_trees", name)
}

# write.csv, but UTF-8 on disk whatever the session locale. Under a non-UTF-8
# locale (Rscript from cron, a container, some IDE terminals) write.csv turns
# "Vulpes r\u00fcppelli" into "Vulpes r<U+00FC>ppelli", and the report no longer
# joins back to the data. Same layout as write.csv(row.names = FALSE): strings
# quoted, numbers and logicals bare, NA as NA.
write_csv_utf8 <- function(df, path) {
  cell <- function(x) {
    if (is.character(x) || is.factor(x)) {
      x <- enc2utf8(as.character(x))
      ifelse(is.na(x), "NA", paste0('"', gsub('"', '""', x, fixed = TRUE), '"'))
    } else ifelse(is.na(x), "NA", as.character(x))
  }
  lines <- c(paste0('"', enc2utf8(names(df)), '"', collapse = ","),
             if (nrow(df)) do.call(paste, c(lapply(df, cell), sep = ",")))
  con <- file(path, open = "wb"); on.exit(close(con))
  writeLines(lines, con, sep = "\n", useBytes = TRUE)
}

read_chr_csv <- function(f)
  read.csv(f, stringsAsFactors = FALSE, encoding = "UTF-8",
           colClasses = "character", na.strings = character(0), check.names = FALSE)
