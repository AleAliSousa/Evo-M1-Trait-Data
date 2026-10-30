#!/usr/bin/env Rscript
# =============================================================================
# build_mammal_tree.R -- CANONICAL build of the project phylogeny.
#
# Resolves the project's species to real tips in a PUBLISHED source tree, prunes
# to the matched tips, and writes the tree the Shiny app fits PGLS against.
#
#   INPUT
#     Upham_etal_2019/*.tre                     the untouched published download
#                                               (frozen source; see that folder's
#                                               README for which file and why)
#     __merging_trees/tree_tip_crosswalk.csv    accepted_name -> candidate spellings
#     _keys/species_reference.csv               the project species list
#
#   OUTPUT
#     _keys/mammal_tree.nwk                     tips relabelled to accepted_name;
#                                               this is what __ShinyApp/app.R reads
#     __merging_trees/mammal_tree_sourcelabels.nwk
#                                               same topology, PUBLISHED tip labels
#     __merging_trees/tree_coverage_report.csv  one row per project species
#
# NOTHING IS GRAFTED OR IMPUTED. Species absent from the source tree are reported
# as absent and dropped from the tree, per __ShinyApp/PHYLO_SETUP.md and the
# deprecation of _keys/extend_phylo.R. To widen coverage, use a source tree that
# already contains the taxa -- never fabricate a tip.
#
# Only crosswalk rows with auto_match = TRUE are used. auto_match = FALSE rows are
# different taxon concepts; they are surfaced in the coverage report as leads and
# must be promoted by hand (see the crosswalk header for the discipline).
#
# A Python mirror, build_mammal_tree.py, reproduces these outputs where R is not
# available. Keep the two in step.
#
# Run from repo root:  Rscript __merging_trees/build_mammal_tree.R
# Requires: ape
# =============================================================================

suppressWarnings(suppressMessages(library(ape)))

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
if (dir.exists(repo)) setwd(repo)

SOURCE_DIR <- "Upham_etal_2019"
MERGE      <- "__merging_trees"

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

# tip "Genus_species_FAMILY_ORDER" -> "Genus species"  (Upham/VertLife convention)
tip_binom <- function(x) {
  p <- strsplit(gsub("[[:space:]]+", "_", trimws(x)), "_+")
  vapply(p, function(v) {
    v <- v[nzchar(v)]
    if (length(v) >= 2) paste(v[1], v[2]) else paste(v, collapse = " ")
  }, character(1))
}
binom <- tip_binom(tree$tip.label)
lab_of <- setNames(tree$tip.label, tolower(binom))
lab_of <- lab_of[!duplicated(names(lab_of))]

# ---- crosswalk ---------------------------------------------------------------
xw <- read.csv(file.path(MERGE, "tree_tip_crosswalk.csv"),
               stringsAsFactors = FALSE, encoding = "UTF-8")
xw$candidate_rank <- suppressWarnings(as.integer(xw$candidate_rank))
species <- unique(xw$accepted_name)

# resolve every species first, WITHOUT claiming tips, so tip assignment below can
# follow a deterministic priority instead of CSV row order
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

# a species matching a tip in its own right always beats a SUBSPECIES falling back
# to that same tip (otherwise "Cryptomys hottentotus" vs its two subspecies would be
# decided by row order)
prio <- vapply(species, function(a) {
  h <- resolved[[a]]
  if (is.null(h)) 2L else if (h$row$candidate_source == "subspecies_parent") 1L else 0L
}, integer(1))
claim_order <- species[order(prio, species)]

# ---- match, with a one-species-per-tip guard --------------------------------
rep_rows <- list()
keep_tip <- character(0); keep_acc <- character(0)
used <- character(0)   # tip label -> accepted_name that claimed it

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
  stop("Only ", length(keep_tip), " species matched the tree; PGLS needs >= 4.")

# ---- prune + write ----------------------------------------------------------
pruned <- keep.tip(tree, keep_tip)
pruned$node.label <- NULL
write.tree(pruned, file.path(MERGE, "mammal_tree_sourcelabels.nwk"))

relab <- setNames(gsub(" ", "_", keep_acc), keep_tip)
app <- pruned
app$tip.label <- unname(relab[app$tip.label])
write.tree(app, "_keys/mammal_tree.nwk")

# report in species_reference.csv order
rep <- do.call(rbind, rep_rows[species])
write.csv(rep, file.path(MERGE, "tree_coverage_report.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

d <- node.depth.edgelength(app)[seq_len(Ntip(app))]
spread <- max(d) - min(d)

cat("\nmatched", length(keep_tip), "/", length(species), "project species\n")
tb <- sort(table(rep$status), decreasing = TRUE)
for (i in seq_along(tb)) cat(sprintf("  %4d  %s\n", tb[i], names(tb)[i]))
cat(sprintf("\nroot-to-tip spread: %.6g  (%s)\n", spread,
            if (spread <= 1e-3 * max(d)) "ultrametric"
            else "NOT ultrametric -- check the source tree"))
cat("wrote _keys/mammal_tree.nwk\n")
cat("wrote", file.path(MERGE, "mammal_tree_sourcelabels.nwk"), "\n")
cat("wrote", file.path(MERGE, "tree_coverage_report.csv"), "\n")
