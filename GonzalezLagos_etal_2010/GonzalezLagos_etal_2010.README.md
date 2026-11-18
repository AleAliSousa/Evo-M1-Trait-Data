# González-Lagos, Sol & Reader 2010 — the 493-species brain/body dataset behind Castillo-Morales 2016's Ei

González-Lagos C, Sol D, Reader SM (2010). *Large-brained mammals live
longer.* Journal of Evolutionary Biology 23: 1064–1074.
doi:10.1111/j.1420-9101.2010.01976.x. PMID 20345813.

The paper assembles a global database of **493 mammal species** (brain
mass, body mass, lifespan and other life-history, ecological and dietary
variables) and shows that relative brain size predicts lifespan. Its
**residual brain mass** — log[brain mass / body mass^0.64], slope
estimated from the dataset itself — is the quantity Castillo-Morales et
al. (2016) adopted as their encephalization index **Ei** (their ref 83),
so this paper is the methodological source of the Ei column in
`CastilloMorales_etal_2016_Table1`.

## Status

- **Article:** in hand (publisher PDF in this folder, supplied by
  Michael Proulx 2026-11-18).
- **Dataset:** the 493-species file was never deposited in any
  repository (checked 2026-11-18: no Dryad, figshare or DataCite
  record; the Wiley article page carries no supporting-information
  file; the first author's 2012 PhD thesis, whose Chapter 1 is this
  paper, contains no data appendix for it). It appears to have
  circulated only by author contact -- consistent with
  Castillo-Morales et al. 2016's "kindly provided by" wording. The
  openly released descendant of the same database is Gonzalez-Voyer
  et al. (2016, Evolution 70:1364-1375; Dryad doi:10.5061/dryad.m2tj3),
  expanded to 596 species with brain and body mass complete on all
  rows; it is built as the Evo-M1 item `GonzalezVoyer_etal_2016`.
  There is no analysis CSV or public TSV for the 2010 item itself.

## What the dataset will carry when obtained

Species, brain mass (g), body mass (g) — the two columns Evo-M1 needs —
plus the paper's life-history variables. Per the Methods: masses are
species means compiled from the sources in the paper's Appendix I;
endocranial-volume-derived masses were corrected following Isler & van
Schaik (2006); the per-row basis (measured vs ECV-derived) is not
flagged, so the dataset is a **secondary compilation** for Evo-M1
purposes, like Baker et al. 2025.
