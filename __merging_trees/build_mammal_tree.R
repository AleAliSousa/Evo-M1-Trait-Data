#!/usr/bin/env Rscript
# =============================================================================
# build_mammal_tree.R -- CANONICAL build of the project phylogeny (tree A).
#
# Resolves the names in the species universe to real tips in a PUBLISHED source
# tree, prunes to the matched tips, and writes the tree the Shiny app fits PGLS
# against.
#
#   INPUT
#     Upham_etal_2019/*.tre                     the untouched published download
#                                               (frozen source; see that folder's
#                                               README for which file and why)
#     __merging_trees/tree_tip_crosswalk.csv    accepted_name -> candidate spellings
#                                               (make_tip_crosswalk_seed.py)
#     __merging_trees/species_universe.csv      the names to place
#                                               (build_species_universe.py)
#
#   OUTPUT
#     _keys/mammal_tree.nwk                     tips relabelled to accepted_name;
#                                               this is what __ShinyApp/app.R reads
#     __merging_trees/mammal_tree_sourcelabels.nwk
#                                               same topology, PUBLISHED tip labels
#     __merging_trees/tree_coverage_report.csv  one row per universe name
#
# NOTHING IS GRAFTED OR IMPUTED HERE. Every tip of this tree is a sequenced
# species in Upham et al.'s DNA-only tree. Species absent from it are reported
# as absent. The two wider products are separate, separately named builds:
#   build_mammal_trees_sample.R     Upham et al.'s own completed trees (tree B)
#   build_mammal_tree_augmented.R   this tree plus locally added branches (tree C)
#
# Only crosswalk rows with auto_match = TRUE are used. auto_match = FALSE rows
# are different or ambiguous taxon concepts; they are surfaced in the coverage
# report as leads and must be promoted by hand.
#
# Name -> tip resolution lives in resolve_tips.R (shared by all three builds).
# A Python mirror, build_mammal_tree.py, reproduces these outputs where R is not
# available. Keep the two in step.
#
# Run from repo root:  Rscript __merging_trees/build_mammal_tree.R
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

SOURCE_DIR <- file.path(P$repo, "Upham_etal_2019")
MERGE_OUT  <- file.path(P$out, "__merging_trees")

# ---- read the published source tree -----------------------------------------
find_tree <- function(dir) {
  f <- list.files(dir, pattern = "\\.(nwk|tre|newick|nex|tree)$",
                  full.names = TRUE, ignore.case = TRUE)
  if (!length(f))
    stop("No source tree in ", dir, "/.\n",
         "  See ", dir, "/Upham_etal_2019.README.md for the exact file to\n",
         "  download and where to put it, then re-run.")
  f[1]
}

read_tree_any <- function(f) {
  txt <- readLines(f, warn = FALSE)
  tr <- if (any(grepl("#NEXUS", txt, ignore.case = TRUE))) read.nexus(f) else read.tree(f)
  if (inherits(tr, "multiPhylo")) {
    message("NOTE: file holds ", length(tr), " trees; using the first. ",
            "A consensus/MCC tree is what this project stores (one tree per source).")
    tr <- tr[[1]]
  }
  tr
}

src  <- find_tree(SOURCE_DIR)
tree <- read_tree_any(src)
cat("source tree :", src, "\n  tips      :", length(tree$tip.label), "\n")

# ---- resolve -----------------------------------------------------------------
xw  <- read_chr_csv(evom1_pipeline_file(P, "tree_tip_crosswalk.csv"))
uni <- read_chr_csv(evom1_pipeline_file(P, "species_universe.csv"))
# Upham et al.'s full species list: a species they recognise but did not sequence
# is absent from this tree, never bridged to another tip (see resolve_tips.R).
recognised <- upham_completed_taxa(P$repo)
if (is.null(recognised)) {
  message("NOTE: Completed100 config.yaml not found; the source-taxonomy guard is off.")
} else cat("source taxonomy:", length(recognised), "species recognised by Upham et al. 2019\n")
res <- resolve_tips(xw, tree$tip.label, uni, recognised)
rep <- res$report; keep_tip <- res$keep_tip; keep_acc <- res$keep_acc

if (length(keep_tip) < 4)
  stop("Only ", length(keep_tip), " species matched the tree; PGLS needs >= 4.")

# ---- prune + write ----------------------------------------------------------
pruned <- keep.tip(tree, keep_tip)
pruned$node.label <- NULL
write.tree(pruned, file.path(MERGE_OUT, "mammal_tree_sourcelabels.nwk"))

relab <- setNames(gsub(" ", "_", keep_acc), keep_tip)
app <- pruned
app$tip.label <- unname(relab[app$tip.label])
write.tree(app, file.path(P$out, "_keys", "mammal_tree.nwk"))

write_csv_utf8(rep, file.path(MERGE_OUT, "tree_coverage_report.csv"))

d <- node.depth.edgelength(app)[seq_len(Ntip(app))]
spread <- max(d) - min(d)

in_scope <- sum(rep$status != "out_of_scope")
cat("\nmatched", length(keep_tip), "/", in_scope, "in-scope names (",
    nrow(rep), "universe names )\n")
tb <- sort(table(rep$status), decreasing = TRUE)
for (i in seq_along(tb)) cat(sprintf("  %5d  %s\n", tb[i], names(tb)[i]))
cat(sprintf("\nroot age: %.3f   root-to-tip spread: %.6g  (%s)\n", max(d), spread,
            if (spread <= 1e-3 * max(d)) "ultrametric"
            else "NOT ultrametric -- check the source tree"))
cat("wrote", file.path(P$out, "_keys", "mammal_tree.nwk"), "\n")
cat("wrote", file.path(MERGE_OUT, "mammal_tree_sourcelabels.nwk"), "\n")
cat("wrote", file.path(MERGE_OUT, "tree_coverage_report.csv"), "\n")
