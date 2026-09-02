# Chaplin et al. 2013 — Results text (cortical surfaces: marmoset, capuchin, macaque)

Chaplin TA, Yu HH, Soares JGM, Gattass R, Rosa MGP (2013). *A conserved pattern of differential
expansion of cortical areas in simian primates.* J Neurosci 33(38):15120–15125.
doi:10.1523/JNEUROSCI.2909-13.2013 · Teams **Rosa** (Monash) + **Gattass** (UFRJ).

Registry (`__ReadMe.xlsx`): row already repointed to this DOI (2026-08-31, owner); **Item number
(col D) still blank** — set it to `ResultsText` so the key becomes `Chaplin_etal_2013_ResultsText`
/ encoded `10.1523%2FJNEUROSCI.2909-13.2013_ResultsText` (precedent:
`Kochiyama_etal_2018_FossilSpecimensText`). Products here and the public TSV already carry that name.
Identification note: this folder briefly pointed at the *other* Chaplin 2013 (marmoset V1
retinotopy, doi 10.1002/cne.23215) — wrong paper; owner swapped the PDF and citation 2026-08-31.

## What the data are
Total cortical surface areas of **one individual per species**, printed in the Results text (no
numbered table — made-a-table case): marmoset *Callithrix jacchus* (500 g female, Paxinos et al.
2012 atlas model) **963 mm²**; capuchin *Cebus apella* (3.3 kg male, unpublished Gattass-lab
histology) **6,796 mm²**; rhesus macaque *Macaca mulatta* (F99 atlas individual, body mass not
reported) **11,876 mm²**. 3 rows.

Measurement caveats (all recorded per-row): surfaces are **mid-thickness contour** models in CARET
(not pial — smaller than pial-surface areas); single hemisphere, L/R not stated; the capuchin is
corrected for post-fixation but **not** perfusion shrinkage; the **F99 macaque is a widely reused
atlas specimen** — run the specimen crosswalk before treating its value as independent of other
F99-derived sources (the human comparison in the paper reuses Orban 2004 / Hill 2010 registrations
and contributes no new human value).

## Source → Snapshot → Data readable
Verbatim Results/Methods quotes frozen to sheet `ResultsText_verbatim` of
`Chaplin_etal_2013_ResultsText_snapshot.xlsx`; curator's made-a-table on sheet `made_a_table`.
Transcription verified against the folder PDF (`pdftotext`: 963 / 6796 / 11,876 / 500 g / 3.3 kg
all confirmed). `Chaplin_etal_2013_ResultsText.R` → `Chaplin_etal_2013_ResultsText.csv`
(**use this**). Columns in `reference_tables/Chaplin_etal_2013_ResultsText_definitions.csv`.
Built offline 2026-08-31 (Python mirror; no R in sandbox) — **re-run the .R in RStudio after
setting the Item number** (expect byte-identical CSV/TSV).

## Merge note — NOT yet wired
Candidate for `__merging_cortical_areas` (whole-cortex surfaces, n=1 each). Mind the mid-thickness
vs pial methods difference when comparing against MRI pial surfaces (e.g. Demirci 2023) — flag as
a method term, don't average across conventions silently.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry Item number ⬜ → R rerun ⬜ → Merge ⬜
