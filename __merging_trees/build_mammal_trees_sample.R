#!/usr/bin/env Rscript
# =============================================================================
# build_mammal_trees_sample.R -- CANONICAL build of the multi-tree PGLS sample
# (tree B: Upham et al.'s own completed trees).
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
#     Upham_etal_2019/*.tre
#         the DNA-only MCC tree, read for its TIP SET only: a species in the
#         completed set but not in the DNA-only tree has no sequence data and its
#         placement is imputed.
#     __merging_trees/tree_tip_crosswalk.csv, species_universe.csv
#         the same crosswalk and universe build_mammal_tree.R uses.
#
#   OUTPUT
#     _keys/mammal_trees_sample100.nwk         100 Newick lines, tips = accepted
#                                              names; ape::read.tree() -> multiPhylo,
#                                              subset per analysis with keep.tip()
#     __merging_trees/mammal_trees_sample100_sourcelabels.nwk
#                                              same trees, PUBLISHED labels untouched
#     __merging_trees/tree_sample_ids.csv      line number -> source tree ID
#     __merging_trees/tree_coverage_report_completed100.csv
#                                              one row per universe name
#     __merging_trees/tree_tip_provenance_completed100.csv
#                                              one row per tip: sequenced or
#                                              imputed_by_Upham_etal_2019
#
# NOTHING IS GRAFTED OR IMPUTED LOCALLY -- the completed set's imputed placements
# are Upham et al.'s own, published per tree. All trees share one tip set
# (verified), so species are resolved once and the pruning applied per tree.
#
# ANY ANALYSIS ON THESE TREES MUST BE ABLE TO DROP THE IMPUTED TIPS: read
# tree_tip_provenance_completed100.csv and repeat the fit on
# provenance == "sequenced" only. An imputed tip sits where taxonomy and a
# birth-death model put it, with no information from the trait being analysed.
#
# Name -> tip resolution lives in resolve_tips.R (shared by all three builds).
# A Python mirror, build_mammal_trees_sample.py, reproduces these outputs where R
# is not available. Keep the two in step.
#
# Run from repo root:  Rscript __merging_trees/build_mammal_trees_sample.R
# Paths: reads $EVOM1_REPO (default: this repo), writes $EVOM1_OUT (default: same).
# Requires: ape
# =============================================================================

suppressWarnings(suppressMessages(library(ape)))

.here <- local({
  a <- commandArgs(FALSE); f <- sub("^--file=", "", a[grep("^--file=", a)])
  if (length(f)) dirname(normalizePath(f)) else "__merging_trees"
})
source(file.path(.here, "resolve_tips.R"))
P <- evom1_paths()

MERGE_OUT <- file.path(P$out, "__merging_trees")
SOURCE <- file.path(P$repo, "Upham_etal_2019", "Completed100_topoCons_NDexp", "output.nex")
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

# ---- tip set of the DNA-only tree: which species have sequence data -----------
dna_file <- list.files(file.path(P$repo, "Upham_etal_2019"),
                       pattern = "\\.(nwk|tre|newick|nex|tree)$",
                       full.names = TRUE, ignore.case = TRUE)[1]
if (is.na(dna_file)) stop("DNA-only source tree not found in Upham_etal_2019/")
dna_txt <- readLines(dna_file, warn = FALSE)
dna_tree <- if (any(grepl("#NEXUS", dna_txt, ignore.case = TRUE))) read.nexus(dna_file) else read.tree(dna_file)
if (inherits(dna_tree, "multiPhylo")) dna_tree <- dna_tree[[1]]
sequenced <- tolower(tip_binom(dna_tree$tip.label))

# ---- resolve once, exactly as build_mammal_tree.R does ------------------------
xw  <- read_chr_csv(evom1_pipeline_file(P, "tree_tip_crosswalk.csv"))
uni <- read_chr_csv(evom1_pipeline_file(P, "species_universe.csv"))
res <- resolve_tips(xw, trees[[1]]$tip.label, uni)
rep <- res$report; keep_tip <- res$keep_tip; keep_acc <- res$keep_acc

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

write.tree(pruned_src, file.path(MERGE_OUT, "mammal_trees_sample100_sourcelabels.nwk"))
write.tree(pruned_app, file.path(P$out, "_keys", "mammal_trees_sample100.nwk"))

ids <- data.frame(line = seq_along(trees),
                  tree_id = if (is.null(names(trees))) paste0("tree_", seq_along(trees))
                            else names(trees))
write.csv(ids, file.path(MERGE_OUT, "tree_sample_ids.csv"),
          row.names = FALSE, quote = FALSE, fileEncoding = "UTF-8")

write_csv_utf8(rep, file.path(MERGE_OUT, "tree_coverage_report_completed100.csv"))

prov <- data.frame(
  accepted_name = keep_acc,
  tip_label = gsub(" ", "_", keep_acc),
  source_tip = keep_tip,
  provenance = ifelse(tolower(tip_binom(keep_tip)) %in% sequenced,
                      "sequenced", "imputed_by_Upham_etal_2019"),
  stringsAsFactors = FALSE)
prov <- prov[order(enc2utf8(prov$accepted_name), method = "radix"), ]
write_csv_utf8(prov, file.path(MERGE_OUT, "tree_tip_provenance_completed100.csv"))

spreads <- vapply(pruned_app, function(p) {
  d <- node.depth.edgelength(p)[seq_len(Ntip(p))]
  max(d) - min(d)
}, numeric(1))
maxd <- vapply(pruned_app, function(p)
  max(node.depth.edgelength(p)[seq_len(Ntip(p))]), numeric(1))
w <- which.max(spreads)

in_scope <- sum(rep$status != "out_of_scope")
cat("\nmatched", length(keep_tip), "/", in_scope, "in-scope names (",
    nrow(rep), "universe names )\n")
tb <- sort(table(rep$status), decreasing = TRUE)
for (i in seq_along(tb)) cat(sprintf("  %5d  %s\n", tb[i], names(tb)[i]))
pt <- table(prov$provenance)
for (i in seq_along(pt)) cat(sprintf("  tips %-28s %5d\n", names(pt)[i], pt[i]))
cat(sprintf("\nroot age range: %.2f - %.2f   worst root-to-tip spread across %d trees: %.6g  (%s)\n",
            min(maxd), max(maxd), length(trees), spreads[w],
            if (spreads[w] <= 1e-3 * maxd[w]) "ultrametric"
            else "NOT ultrametric -- check the source"))
cat("wrote", file.path(P$out, "_keys", "mammal_trees_sample100.nwk"), "\n")
cat("wrote", file.path(MERGE_OUT, "mammal_trees_sample100_sourcelabels.nwk"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_sample_ids.csv"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_coverage_report_completed100.csv"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_tip_provenance_completed100.csv"), "\n")
