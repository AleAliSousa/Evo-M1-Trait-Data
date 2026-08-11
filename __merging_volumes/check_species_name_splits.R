# check_species_name_splits.R -- catch one printed species label resolving to TWO accepted names.
#
# Species resolution is SOURCE-AWARE: _keys/volumes_species_overrides.csv is keyed by
# (Reference, variant_name), so a curated decision applies only to the papers it is written for.
# That is deliberate (the same label can genuinely mean different things in different papers) but
# it fails open: add a source that prints an already-curated label and forget its override row, and
# the label falls through to NCBI instead. The species then SPLITS into two rows of the wide matrix
# -- e.g. "Callicebus moloch" staying itself in Stephan 1981 but becoming "Plecturocebus moloch" in
# Stephan 1984, so one animal carries LGN 53.2 under one name and 54.2 under the other, and its
# body/brain mass is duplicated across both rows.
#
# This script reads the resolution tables the merges write and lists every raw label with more than
# one accepted name, so the gap is visible before it reaches a comparison or an analysis. It only
# WARNS -- some splits are real curatorial decisions (a genus-level "Cebus sp." in one collection
# vs an identified species in another), so it is a review list, not a gate.
#
# Run standalone, or let run_all_scripts_v2.R pick it up. Reads only; writes one CSV.

folder <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(dirname(normalizePath(p)))
  }
  normalizePath(getwd())
})
setwd(folder)

files <- Sys.glob("volumes_source_species_ids*.csv")
if (!length(files)) {
  message("check_species_name_splits: no volumes_source_species_ids*.csv yet -> nothing to check.")
} else {
  all_splits <- NULL
  for (f in files) {
    d <- read.csv(f, stringsAsFactors = FALSE)
    if (!all(c("Source", "Species_raw", "Species_final") %in% names(d))) next
    n <- tapply(d$Species_final, d$Species_raw, function(x) length(unique(x)))
    raws <- names(n)[n > 1]
    if (!length(raws)) { message("OK ", f, ": no split labels."); next }
    for (raw in raws) {
      s <- d[d$Species_raw == raw, ]
      for (fin in sort(unique(s$Species_final))) {
        g <- s[s$Species_final == fin, ]
        all_splits <- rbind(all_splits, data.frame(
          file = sub("\\.csv$", "", f), Species_raw = raw, Species_final = fin,
          name_source = g$name_source[1], n_sources = nrow(g),
          sources = paste(sort(g$Source), collapse = "; "), stringsAsFactors = FALSE))
      }
    }
    message("SPLIT ", f, ": ", length(raws), " label(s) resolving to more than one accepted name -> ",
            paste(raws, collapse = "; "))
  }
  if (is.null(all_splits)) {
    message("check_species_name_splits: clean.")
  } else {
    write.csv(all_splits, "volumes_species_name_splits.csv", row.names = FALSE)
    # A split where one side is `unresolved_raw` or plain NCBI while another source has a curated
    # decision is almost always a MISSING OVERRIDE ROW rather than a real taxonomic judgement.
    likely <- unique(all_splits$Species_raw[all_splits$name_source == "curated"])
    likely <- intersect(likely, unique(all_splits$Species_raw[all_splits$name_source != "curated"]))
    warning("Species name splits: ", length(unique(all_splits$Species_raw)), " label(s); ",
            length(likely), " look like a missing row in _keys/volumes_species_overrides.csv ",
            "(curated in one source, not in another): ", paste(likely, collapse = "; "),
            ". See volumes_species_name_splits.csv.")
  }
}
