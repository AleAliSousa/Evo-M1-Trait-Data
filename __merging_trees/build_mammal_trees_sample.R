#!/usr/bin/env Rscript
# =============================================================================
# build_mammal_trees_sample.R -- CANONICAL build of the multi-tree PGLS sample.
#
# Multi-tree companion to build_mammal_tree.R (which stays canonical for the
# single tree the Shiny app reads). This build turns the VertLife credible-set
# sample -- 100 complete trees of set MamPhy_BDvr_Completed_5911sp_topoCons_NDexp,
# drawn from Upham et al. 2019's 10k pseudoposterior -- into a pruned, relabelled
# multiPhylo sample for PGLS-across-trees sensitivity analyses.
#
#   INPUT
#     Upham_etal_2019/Completed100_topoCons_NDexp/output.nex
#         frozen source (config.yaml beside it records the download job and the
#         source tree IDs). Completed set = no-DNA species placed by the AUTHORS'
#         taxonomic imputation, with a different placement in each posterior tree.
#     __merging_trees/tree_tip_crosswalk.csv
#         the same crosswalk build_mammal_tree.R uses (auto_match gate).
#
#   OUTPUT
#     _keys/mammal_trees_sample100.nwk         100 Newick lines, tips = accepted
#                                              names; ape::read.tree() -> multiPhylo,
#                                              subset per analysis with keep.tip()
#     __merging_trees/mammal_trees_sample100_sourcelabels.nwk
#                                              same trees, PUBLISHED labels untouched
#     __merging_trees/tree_sample_ids.csv      line number -> source tree ID
#     __merging_trees/tree_coverage_report_completed100.csv
#                                              one row per project species
#
# NOTHING IS GRAFTED OR IMPUTED LOCALLY -- the completed set's imputed placements
# are Upham et al.'s own, published per tree. All trees share one tip set
# (verified), so species are resolved once and the pruning applied per tree.
#
# A Python mirror, build_mammal_trees_sample.py, reproduces these outputs where R
# is not available. Keep the two in step.
#
# Run from repo root:  Rscript __merging_trees/build_mammal_trees_sample.R
# Requires: ape
# =============================================================================

suppressWarnings(suppressMessages(library(ape)))

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
if (dir.exists(repo)) setwd(repo)

MERGE  <- "__merging_trees"
SOURCE <- file.path("Upham_etal_2019", "Completed100_topoCons_NDexp", "output.nex")
if (!file.exists(SOURCE))
  stop("Source sample not found: ", SOURCE,
       "\n  See Upham_etal_2019/Upham_etal_2019.README.md (Completed100 item).")

trees <- read.nexus(SOURCE)
if (!inherits(trees, "multiPhylo")) trees <- c(trees)
cat("source sample :", SOURCE, "\n  trees       :", length(trees),
    "\n  tips/tree   :", length(trees[[1]]$tip.label), "\n")

tipset1 <- sort(trees[[1]]$tip.label)
same <- vapply(trees, function(t) identical(sort(t$tip.label), tipset1), logical(1))
if (!all(same))
  stop("Tree ", which(!same)[1], " has a different tip set from tree 1 -- ",
       "the sample is not one consistent taxon set.")

# tip "Genus_species[_FAMILY_ORDER]" -> "Genus species"
tip_binom <- function(x) {
  p <- strsplit(gsub("[[:space:]]+", "_", trimws(x)), "_+")
  vapply(p, function(v) {
    v <- v[nzchar(v)]
    if (length(v) >= 2) paste(v[1], v[2]) else paste(v, collapse = " ")
  }, character(1))
}
lab_of <- setNames(trees[[1]]$tip.label, tolower(tip_binom(trees[[1]]$tip.label)))
lab_of <- lab_of[!duplicated(names(lab_of))]

# ---- crosswalk: resolve once, exactly as build_mammal_tree.R does -------------
xw <- read.csv(file.path(MERGE, "tree_tip_crosswalk.csv"),
               stringsAsFactors = FALSE, encoding = "UTF-8")
xw$candidate_rank <- suppressWarnings(as.integer(xw$candidate_rank))
species <- unique(xw$accepted_name)

resolve_one <- function(acc) {
  r <- xw[xw$accepted_name == acc, ]
  r <- r[order(ifelse(is.na(r$candidate_rank), 1e6, r$candidate_rank)), ]
  a <- r[r$auto_match == "TRUE" & nzchar(r$candidate_name), ]
  if (nrow(a)) for (i in seq_len(nrow(a))) {
    lab <- lab_of[tolower(a$candidate_name[i])]
    if (!is.na(lab)) return(list(row = a[i, ], tip = unname(lab)))
  }
  NULL
}
resolved <- setNames(lapply(species, resolve_one), species)

prio <- vapply(species, function(a) {
  h <- resolved[[a]]
  if (is.null(h)) 2L else if (h$row$candidate_source == "subspecies_parent") 1L else 0L
}, integer(1))
claim_order <- species[order(prio, species)]

rep_rows <- list()
keep_tip <- character(0); keep_acc <- character(0)
used <- character(0)

for (acc in claim_order) {
  r <- xw[xw$accepted_name == acc, ]
  r <- r[order(ifelse(is.na(r$candidate_rank), 1e6, r$candidate_rank)), ]
  fam <- r$family_expected[1]; ord <- r$order_expected[1]
  review <- r[r$auto_match == "FALSE" & nzchar(r$candidate_name), ]
  auto   <- r[r$auto_match == "TRUE"  & nzchar(r$candidate_name), ]
  placeholder <- any(r$candidate_source == "none_possible")
  h <- resolved[[acc]]

  matched_tip <- ""; via <- ""; csrc <- ""; note <- ""
  if (!is.null(h)) {
    csrc <- h$row$candidate_source
    status <- if (csrc == "accepted_name") "matched_direct"
              else if (csrc == "subspecies_parent") "matched_subspecies_parent"
              else "matched_synonym"
    if (h$tip %in% names(used)) {
      if (csrc == "subspecies_parent") {
        status <- "subspecies_of_matched_species"
        note <- paste0("parent species tip is held by ", used[[h$tip]],
                       "; a species-level tree cannot separate them, so this row is ",
                       "excluded from PGLS rather than duplicating the tip")
      } else {
        status <- "conflict_tip_already_used"
        note <- paste0("tip already assigned to ", used[[h$tip]],
                       "; resolve in tree_tip_crosswalk.csv before use")
      }
    } else {
      used[h$tip] <- acc
      keep_tip <- c(keep_tip, h$tip); keep_acc <- c(keep_acc, acc)
      matched_tip <- h$tip; via <- h$row$candidate_name
      if (status != "matched_direct") note <- h$row$note
    }
  } else if (placeholder) {
    status <- "unresolvable_placeholder"
    note <- "genus-level name: no single tip can represent it"
  } else if (nrow(review)) {
    status <- "absent_but_review_lead"
    note <- paste0("not on tree under any auto_match name, but these review-only ",
                   "candidates exist: ",
                   paste0(review$candidate_name,
                          ifelse(tolower(review$candidate_name) %in% names(lab_of),
                                 " [ON TREE]", " [not on tree either]"),
                          collapse = "; "))
  } else {
    status <- "absent_from_tree"
    note <- "no candidate spelling occurs in the source tree"
  }

  rep_rows[[acc]] <- data.frame(
    accepted_name = acc, status = status, matched_tip = matched_tip,
    matched_via = via, candidate_source = csrc,
    family_expected = fam, order_expected = ord,
    n_auto_candidates = nrow(auto), n_review_candidates = nrow(review),
    note = note, stringsAsFactors = FALSE)
}

if (length(keep_tip) < 4)
  stop("Only ", length(keep_tip), " species matched the trees; PGLS needs >= 4.")

# ---- prune every tree, write ---------------------------------------------------
relab <- setNames(gsub(" ", "_", keep_acc), keep_tip)

prune_one <- function(t) {
  p <- keep.tip(t, keep_tip)
  p$node.label <- NULL
  p
}
pruned_src <- lapply(unclass(trees), prune_one)
class(pruned_src) <- "multiPhylo"
pruned_app <- lapply(pruned_src, function(p) {
  p$tip.label <- unname(relab[p$tip.label]); p
})
class(pruned_app) <- "multiPhylo"

write.tree(pruned_src, file.path(MERGE, "mammal_trees_sample100_sourcelabels.nwk"))
write.tree(pruned_app, file.path("_keys", "mammal_trees_sample100.nwk"))

ids <- data.frame(line = seq_along(trees),
                  tree_id = if (is.null(names(trees))) paste0("tree_", seq_along(trees))
                            else names(trees))
write.csv(ids, file.path(MERGE, "tree_sample_ids.csv"),
          row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")

rep <- do.call(rbind, rep_rows[species])
write.csv(rep, file.path(MERGE, "tree_coverage_report_completed100.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

spreads <- vapply(pruned_app, function(p) {
  d <- node.depth.edgelength(p)[seq_len(Ntip(p))]
  max(d) - min(d)
}, numeric(1))
maxd <- vapply(pruned_app, function(p)
  max(node.depth.edgelength(p)[seq_len(Ntip(p))]), numeric(1))
w <- which.max(spreads)

cat("\nmatched", length(keep_tip), "/", length(species), "project species\n")
tb <- sort(table(rep$status), decreasing = TRUE)
for (i in seq_along(tb)) cat(sprintf("  %4d  %s\n", tb[i], names(tb)[i]))
cat(sprintf("\nworst root-to-tip spread across %d trees: %.6g  (%s)\n",
            length(trees), spreads[w],
            if (spreads[w] <= 1e-3 * maxd[w]) "ultrametric"
            else "NOT ultrametric -- check the source"))
cat("wrote _keys/mammal_trees_sample100.nwk\n")
cat("wrote", file.path(MERGE, "mammal_trees_sample100_sourcelabels.nwk"), "\n")
cat("wrote", file.path(MERGE, "tree_sample_ids.csv"), "\n")
cat("wrote", file.path(MERGE, "tree_coverage_report_completed100.csv"), "\n")
