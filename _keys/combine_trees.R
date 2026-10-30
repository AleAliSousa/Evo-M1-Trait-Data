#!/usr/bin/env Rscript
# =============================================================================
# combine_trees.R -- join published, time-calibrated trees into ONE tree for the
# app's PGLS. This is source-to-source joining (grafting whole PUBLISHED clades
# at a literature divergence age) — NOT taxonomic imputation of individual
# species. No tips are invented; each subtree keeps its own branch lengths.
#
#   INPUTS (dated / ultrametric, same time unit e.g. Ma):
#     _keys/phylo_placental.nwk    required  (e.g. team's Zoonomia tree)
#     _keys/phylo_marsupial.nwk    required  (a published marsupial time-tree)
#     _keys/phylo_monotreme.nwk    optional  (a monotreme tree; else skipped)
#   OUTPUT:
#     _keys/mammal_tree.nwk        the app's tree
#
# Divergence ages (Ma) used for the joins — set from the literature you cite:
THERIA_AGE  <- 160   # marsupial <-> placental split (Theria crown)
MAMMALIA_AGE <- 180  # monotreme <-> Theria split (Mammalia crown), if monotremes used
#
# Run from repo root:  Rscript _keys/combine_trees.R
# Requires: ape, phytools
# =============================================================================

suppressWarnings(suppressMessages({library(ape); library(phytools)}))
setwd(normalizePath(file.path(dirname(sub("^--file=", "",
      commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])), "..")))

read_one <- function(stem) {
  for (e in c("nwk","tre","newick","nex","tree")) {
    f <- file.path("_keys", paste0(stem, ".", e))
    if (file.exists(f)) {
      txt <- readLines(f, warn = FALSE)
      tr <- if (any(grepl("#NEXUS", txt, ignore.case = TRUE))) read.nexus(f) else read.tree(f)
      if (inherits(tr, "multiPhylo")) tr <- tr[[1]]
      return(tr)
    }
  }
  NULL
}
root_age <- function(tr) max(node.depth.edgelength(tr))   # = crown age if ultrametric

plac <- read_one("phylo_placental")
mars <- read_one("phylo_marsupial")
mono <- read_one("phylo_monotreme")
if (is.null(plac) || is.null(mars))
  stop("Need _keys/phylo_placental.* and _keys/phylo_marsupial.* (see PHYLO_SETUP.md).")

for (nm in c("plac","mars")) {
  tr <- get(nm)
  if (!is.ultrametric(tr, tol = 1e-3))
    message("WARNING: ", nm, " is not ultrametric; joins assume dated trees. ",
            "Consider force.ultrametric() or a dated source tree.")
}

Rp <- root_age(plac); Rm <- root_age(mars)
if (THERIA_AGE <= max(Rp, Rm))
  stop(sprintf("THERIA_AGE (%.1f) must exceed both crown ages (placental %.1f, marsupial %.1f).",
               THERIA_AGE, Rp, Rm))

# join placental + marsupial under a Theria root, keeping each crown at its age
backbone <- read.tree(text = sprintf("(PLAC:%f,MARS:%f);",
                                     THERIA_AGE - Rp, THERIA_AGE - Rm))
combined <- bind.tree(backbone, plac, where = which(backbone$tip.label == "PLAC"))
combined <- bind.tree(combined, mars, where = which(combined$tip.label == "MARS"))

# optionally add monotremes at the Mammalia root
if (!is.null(mono)) {
  Rmo <- root_age(mono); Rt <- root_age(combined)   # Rt should ~ THERIA_AGE
  if (MAMMALIA_AGE <= max(Rt, Rmo))
    stop(sprintf("MAMMALIA_AGE (%.1f) must exceed Theria (%.1f) and monotreme crown (%.1f).",
                 MAMMALIA_AGE, Rt, Rmo))
  bb2 <- read.tree(text = sprintf("(THERIA:%f,MONO:%f);",
                                  MAMMALIA_AGE - Rt, MAMMALIA_AGE - Rmo))
  combined <- bind.tree(bb2, combined, where = which(bb2$tip.label == "THERIA"))
  combined <- bind.tree(combined, mono, where = which(combined$tip.label == "MONO"))
}

combined <- tryCatch(force.ultrametric(combined, method = "extend"),
                     error = function(e) combined)
combined$node.label <- NULL
combined$tip.label <- gsub(" ", "_", combined$tip.label)
write.tree(combined, "_keys/mammal_tree.nwk")

# ---- coverage report vs the dataset -----------------------------------------
tax <- read.csv("_keys/species_taxonomy.csv", stringsAsFactors = FALSE)
bin <- gsub("_", " ", combined$tip.label)
matched <- sum(tolower(tax$Species) %in% tolower(bin))
message(sprintf("combined tree: %d tips (placental %d + marsupial %d%s)",
                length(combined$tip.label), length(plac$tip.label),
                length(mars$tip.label),
                if (!is.null(mono)) paste0(" + monotreme ", length(mono$tip.label)) else ""))
message(sprintf("dataset species on tree: %d / %d", matched, nrow(tax)))
message("wrote _keys/mammal_tree.nwk")
