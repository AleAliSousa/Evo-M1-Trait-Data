# Jacobs et al. 2018 — Table 5 (Golgi somatodendritic morphology, 3 neuron types)

**Snapshot built 2026-08-04. Reformat `.R`, analysis CSV and public TSV built 2026-08-05.**

| File | |
|---|---|
| `Jacobs_etal_2018_Table5_snapshot.xlsx` | frozen source (printed table) |
| `Jacobs_etal_2018_Table5.R` | reformat: snapshot → CSV + TSV |
| `Jacobs_etal_2018_Table5.csv` | analysis table — **53 rows = 19 species × their neuron types** |
| `__Public/comparative-data/10.1002%2Fcne.24349_Table5.tsv` | public TSV |

**Shape.** One row per species × `neuron_type`, each of the eight measures as `<measure>` +
`<measure>_sd`. Units are left exactly as printed (µm³, µm, µm², spines/µm) — Golgi 2-D tracing,
never mixed with Table 3's stereology; `method` is stamped on every row.

**Species names** are resolved from the printed common name through `Jacobs2018` rows in
`_keys/Stephan/species_key.csv` (paper-scoped, `_keys/SPECIES_NAMING.md` §3) — binomials taken from
Table 3 of the same paper where the species appears there, otherwise the standard binomial. Plains
zebra uses the house name `Equus burchelli`; Bennett's wallaby uses `Notamacropus rufogriseus`.

**`gigantopyramidal_absent`** is `TRUE` on the rows of the four species where the paper's text
states gigantopyramidal neurons were not distinguishable (banded mongoose, Flemish giant rabbit,
rat, Bennett's wallaby). Those species have Superficial + Deep rows only — the absence is recorded
as a flag rather than as an invented zero-valued row.

### Verification of the built CSV (recomputed 2026-08-05)

| Check | From the built CSV | Paper |
|---|---|---|
| Traced neurons, total | **617** | 617 |
| — superficial / deep / gigantopyramidal | **233 / 203 / 181** | 233 / 203 / 181 |
| Feliform gigantopyramidal mean soma size | **2,847 µm²** | 2,847 µm² |
| Primate gigantopyramidal mean soma size | **987 µm²** | 987 µm² |

The two n = 1 rows (clouded leopard Deep, ring-tailed lemur Deep) carry `NA` in every `_sd` column,
not `0`. **Re-run `Jacobs_etal_2018_Table5.R` in RStudio** to confirm it reproduces the committed
files — they were written by an offline mirror of the script (no R in the authoring environment).

## Source

Same paper as `Jacobs_etal_2018_Table3.README.md` — J Comp Neurol 526(3):496–536,
DOI **10.1002/cne.24349**, PMID **29088505**, EndNote `[4950]`. Table 5 is printed on pp. 508–509.

**Printed source → snapshot required** (invariant 1). Captured from the PDF text layer, verified
against the rendered pages and against the paper's own totals (see *Verification*).

## What Table 5 gives

Golgi somatodendritic morphology for **three neuron types in M1** across **19 species / 7 orders**
(**53 species × neuron-type rows**, 617 traced neurons):

- `Superficial` — primarily layer III pyramidal (233 cells)
- `Deep` — primarily layer V pyramidal (203 cells)
- `Gigantopyramidal` — Betz cells in primates (181 cells)

| Column | Meaning (paper's footnotes) | Unit |
|---|---|---|
| `na` | number of cells traced | count |
| `Volb` | dendritic volume | µm³ |
| `TDLc` | total dendritic length | µm |
| `MSLd` | average length of dendritic segments | µm |
| `DSCe` | number of segments per neuron | count |
| `DSNf` | number of spines per neuron | count |
| `DSDg` | number of spines per µm of dendritic length | spines/µm |
| `SoSizeh` | soma size | µm² |
| `SoDepthi` | soma depth from the pial surface | µm |

All as `Mean ± SD`, except the two **n = 1** rows (clouded leopard Deep, ring-tailed lemur Deep),
which are printed as bare values with no SD — correct, not missing data.

**Presence/absence datum (from the text, not the table):** gigantopyramidal neurons "were not
distinguishable in the mongoose, rabbit, rat, or wallaby" — hence those four species have Superficial
and Deep rows only. This is a real biological zero, **not** a gap; record it as such.

## Fidelity notes

- Values carried **exactly as printed**; printed taxonomic-group rows and species sub-heading rows
  kept, printed row order kept.
- **Print oddity, carried verbatim:** ring-tailed lemur Gigantopyramidal `MSLd` is printed
  `69 ± 0.04`. Every other MSL SD is an integer 1–14, so this is very likely `69 ± 4`. **Unresolved —
  flag on ingest; do not silently change.**
- Species names here are printed as **common names only** (no binomials in Table 5). Take binomials
  from Table 1 / Table 3 of the same paper when resolving via `_keys`; keep the printed common name
  (invariant 3). Note Table 5 prints `Kudu` where Table 1 prints `Greater kudu` / *Tragelaphus
  strepsiceros*, and `Rat` where Table 1 prints `Long-Evans rat` / *Rattus norvegicus*.

## Verification done (2026-08-04)

Recomputed from the snapshot against figures the paper states independently in its text/abstract:

| Check | From snapshot | Paper |
|---|---|---|
| Traced neurons, total | **617** | 617 |
| — superficial / deep / gigantopyramidal | **233 / 203 / 181** | 233 / 203 / 181 |
| Feliform gigantopyramidal mean soma size | **2,847 µm²** | 2,847 µm² |
| Primate gigantopyramidal mean soma size | **987 µm²** | 987 µm² |
| Deep pyramidal mean soma depth (n-weighted) | **1,331 µm** | 1,331 ± 24 µm |
| Gigantopyramidal mean soma depth (n-weighted) | **1,450 µm** | 1,452 ± 23 µm |

The neuron totals reproducing exactly validates the whole `na` column; the two soma-size group means
reproducing exactly validates `SoSizeh`; the soma-depth means validate `SoDepthi`.

> ⚠️ **Nolan et al. 2024 misquotes this table.** The review gives the feliform mean as **2874 µm²**;
> the paper says **2,847 µm²** (and the snapshot reproduces 2,847 exactly from the four feliform
> values). A digit transposition. Concrete instance of why a review's quoted figures are never
> ingested — see `README.md` (this folder).

## Still to do (locally, with R)

1. `Jacobs_etal_2018_Table5.R`: snapshot → analysis CSV. Split `Mean ± SD` into `mean` / `sd`;
   carry `neuron_type` as an explicit column; leave `sd` empty (not 0) for the two n = 1 rows.
2. Strip the footnote letters from the headers (`na` → `n`, `Volb` → `Vol`, …) **in the script**, not
   in the snapshot.
3. Resolve `species_sci` via `_keys`, taking binomials from Table 1/Table 3.
4. Register in `__ReadMe.xlsx` (`Data role = primary`), write the DOI-coded public TSV (invariant 2).
5. Wire into `__merging_cellcounts` as a **regional (M1) sub-trait** with its own standardized terms.
   `method = Golgi (2-D somatodendritic tracing)` — **not** interchangeable with the unbiased
   stereology in Table 3, even where both report a soma measure for the same species.

## Species overlap with Table 3 (same paper, different method)

**Seven** species appear in both tables — African lion, African wild dog, Banded mongoose, Caracal,
Siberian tiger, Chacma baboon, Golden lion tamarin. Both give a soma measure, by **different
methods**, so the merge must **resolve, not average**. Table 3 (stereology) is the better soma
estimate; Table 5 is the only source of the dendritic and spine measures.

## Overlap with `Young_etal_2013` (the other regional-M1 source)

Checked 2026-08-04 — **no species collision, and no measure collision.** Young Table 1 holds
*Otolemur garnettii, Aotus nancymaae, Saimiri sciureus, Macaca nemestrina, Papio cynocephalus anubis,
Papio hamadryas anubis, Pan troglodytes*; Jacobs shares neither species exactly. Genus-level overlap
only: *Saimiri* (Jacobs *boliviensis* vs Young *sciureus*) and *Papio* (Jacobs *ursinus* and
*hamadryas* vs Young *cynocephalus anubis* / *hamadryas anubis* — different subspecies). Measures are
disjoint anyway: Young gives M1 cell count / surface area / mass, Jacobs gives per-neuron morphology.
The two sit side by side as regional-M1 sub-traits with nothing to reconcile.
