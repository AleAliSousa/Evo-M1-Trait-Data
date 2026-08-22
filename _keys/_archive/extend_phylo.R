#!/usr/bin/env Rscript
# DEPRECATED — do not use.
#
# This script grafted missing species onto the tree by taxonomy (imputation).
# Per project policy, phylogenies must come from a PUBLISHED SOURCE and species
# not present in that source tree are excluded from PGLS (not imputed).
#
# See __ShinyApp/PHYLO_SETUP.md for choosing a source tree. Remove this file:
#   git rm _keys/extend_phylo.R
# (_keys/genus_family.csv was only needed for grafting and can also be removed.)

stop("extend_phylo.R is deprecated: use a published source tree (see PHYLO_SETUP.md), not imputation.")
