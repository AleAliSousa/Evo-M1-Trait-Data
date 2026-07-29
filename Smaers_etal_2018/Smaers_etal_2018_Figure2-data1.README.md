# Smaers et al. 2018 — Figure 2, Source data 1 (brain & cerebellum volumes)

Smaers JB, Turner AH, Gómez-Robles A, Sherwood CC (2018). *A cerebellar substrate for high-level
cognition.* eLife 7:e35696. doi:10.7554/eLife.35696.

Registry (`__ReadMe.xlsx`): Item name **`Smaers_etal_2018_Figure2-data1`**, encoded
`10.7554%2FeLife.35696_Figure2-data1`.

## What the data are
The brain data behind the paper's phylogenetic analyses: **50 species** (primates + a few
outgroups, e.g. *Loxodonta africana*) with whole-**brain**, **medial cerebellum**, and total
**cerebellum** volumes, plus a per-row **Source**. The paper's focal variable, the **lateral
cerebellum**, is derived as `total cerebellum − medial cerebellum` and carried as
`LateralCerebellum_Vol.mm3`. One row per species.

## ⚠️ Compilation (Data role = both) — don't double-count
Every value is drawn from the source named in `Source`: **Maseko et al. 2012** (25 rows),
**MacLeod et al. 2003** (17), **Smaers et al. 2011** (8). MacLeod 2003 and Smaers 2011 are already
folders in this repo, so most of this table re-labels data already present. It is built for
provenance; **only genuinely new rows should ever enter a merge**, and even then via the volumes
merge's cross-publication value-match check (`__merging_volumes/crosspub_value_match.R`) to avoid
double-counting. Treat as secondary unless a row is confirmed original to Smaers 2018.

## Source → Data readable (digital-native: no snapshot)
The source is a machine-readable Word table, so it **is** the frozen source (kept verbatim; no
derived snapshot — see `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
`elife-35696-fig2-data1-v2.docx` → `Smaers_etal_2018_Figure2-data1.R` (reads the docx via
`docxtractr`) → **`Smaers_etal_2018_Figure2-data1.csv`** (use this) + the public TSV
`__Public/comparative-data/10.7554%2FeLife.35696_Figure2-data1.tsv`. Column meanings:
`reference_tables/…_definitions.csv`.

Units: volumes converted **cm³ → mm³** (×1000); the cm³ originals remain in the frozen source docx.

## Species names
The printed binomial is preserved as **`Species_Smaers2018`** and carried in `Species`; because this
table is a compilation not slated for direct merge, harmonisation to `_keys/Stephan/species_key.csv`
is deferred to the merge step (add rows there under token `Smaers2018` if it is ever merged).

## Build note
Generated in an environment without R; outputs were produced by the equivalent step and
`Smaers_etal_2018_Figure2-data1.R` reproduces them from the frozen source docx (docxtractr → CSV +
TSV with the `Item encoded` lookup). Re-run in R to regenerate.

Pipeline: Source (frozen, digital-native docx) → Data readable ✅ → definitions ✅ → README ✅ · compilation, handle via crosspub value-match before any merge.
