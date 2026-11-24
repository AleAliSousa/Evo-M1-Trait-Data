#!/usr/bin/env Rscript
# brain_mass_hemisphere_flags.R - which served brain masses are 2 x one hemisphere.
#
# The hemisphere rule (_keys/README_hemisphere_basis.md) holds for every dataset: a value
# that is twice one measured hemisphere is served as the both-hemisphere value AND marked.
# This merge doubles nothing itself; some of its sources publish doubled values. They are
# listed, by source table and column, in laterality_known.csv (species measured on both
# sides: laterality_known_exceptions.csv). This script finds the served values those
# sources contribute to and writes brain_mass_flags.csv (Species, Variable, flag, detail),
# which the one-table builder reads through _keys/hemisphere_basis.csv to fill the
# Hemispheres column. No value is changed.
#
# Run from the repository root, after the merge itself has been rebuilt:
#   Rscript __merging_brain_mass/brain_mass_hemisphere_flags.R
dir <- "__merging_brain_mass"
if (!file.exists(file.path(dir, "brain_mass_long.csv"))) stop("run from the repository root", call. = FALSE)
rd <- function(f) read.csv(file.path(dir, f), check.names = FALSE, colClasses = "character",
                           encoding = "UTF-8", na.strings = character(0))
reg <- rd("laterality_known.csv"); exc <- rd("laterality_known_exceptions.csv")
u <- rd("brain_mass_unfiltered.csv"); long <- rd("brain_mass_long.csv")
bad <- reg[!(reg$side == "unilateral" & reg$doubling == "by_source"), , drop = FALSE]
if (nrow(bad)) stop("laterality_known.csv: this merge only knows doubling = by_source; a value this project ",
                    "would have to double needs the merge itself to do it (see the volumes merge).", call. = FALSE)
k <- paste(u$Source, u$column, sep = "\r")
if (!all(paste(reg$Reference, reg$Original_Term, sep = "\r") %in% k))
  stop("laterality_known.csv names a source table or column the merge does not read.", call. = FALSE)
u$doubled <- k %in% paste(reg$Reference, reg$Original_Term, sep = "\r") &
  !paste(u$Source, u$Species, sep = "\r") %in% paste(exc$Reference, exc$Species, sep = "\r")
u <- u[tolower(u$pool_eligible) == "true", , drop = FALSE]
# the sources behind a served value: same species, same emitted measure (for the combined
# label, the measure it selected)
long$from <- ifelse(long$Measure %in% u$measure_emitted, long$Measure, long$selected_measure)
out <- list()
for (i in seq_len(nrow(long))) {
  s <- u[u$Species == long$Species[i] & u$measure_emitted == long$from[i], , drop = FALSE]
  if (!any(s$doubled)) next
  what <- paste(unique(sprintf("%s, column '%s'", s$paper[s$doubled], s$column[s$doubled])), collapse = "; ")
  detail <- if (all(s$doubled))
    sprintf("published value is 2x one hemisphere, doubled by the source (not by this merge): %s -- see laterality_known.csv", what)
  else
    sprintf("a contributing source publishes 2x one hemisphere (doubled by that source, not by this merge): %s; %d of %d sources -- see laterality_known.csv",
            what, sum(s$doubled), nrow(s))
  out[[length(out) + 1L]] <- data.frame(Species = long$Species[i], Variable = sprintf("%s (%s)", long$Measure[i], long$Units[i]),
                                        flag = "published_bilateral_estimate", detail = detail, stringsAsFactors = FALSE)
}
out <- if (length(out)) do.call(rbind, out) else data.frame(Species = character(0), Variable = character(0), flag = character(0), detail = character(0))
out <- out[order(out$Variable, out$Species), , drop = FALSE]
con <- file(file.path(dir, "brain_mass_flags.csv"), open = "wb")
write.csv(out, con, row.names = FALSE, fileEncoding = "UTF-8"); close(con)
cat(sprintf("brain_mass_flags.csv: %d served value(s) of %d species marked as 2 x one hemisphere (%d wholly from a doubling source, %d a mean that includes one)\n",
            nrow(out), length(unique(out$Species)), sum(grepl("^published", out$detail)), sum(grepl("^a contributing", out$detail))))
