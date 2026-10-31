# Jung et al. 2022 — Supplementary Table S2

## Source
Jung, Y. J., Almasi, A., Sun, S. H., Yunzab, M., Cloherty, S. L., Bauquier, S. H., Renfree, M.,
Meffin, H., & Ibbotson, M. R. (2022). Orientation pinwheels in primary visual cortex of a highly
visual marsupial. *Science Advances*, 8(39), eabn0954. https://doi.org/10.1126/sciadv.abn0954

Item: supplementary **table S2**, "Pinwheel density (ρ) and column spacing (Λ) across various
species", in `sciadv.abn0954_sm.pdf`.

## What this item is
Nine mammals (Mouse, Mouse lemur, Galago, Tree shrew, Ferret, Squirrel monkey, Cat, Wallaby,
Macaque) with body mass, average orientation pinwheel density (ρ) and orientation column spacing
(Λ). Row order is as printed, ascending by body mass.

## Data role — `both`, and which rows are which
This item genuinely earns the registry's `Data role = both`:

- **primary** — the **Wallaby** row. All three of its cells print `(own data)`, i.e. measurements
  first published by Jung et al. (2022) itself: 4800 g, ρ = 2.62, Λ = 1.43.
- **secondary** — every other row, each cell carrying a numbered citation to another study.

The Mouse row prints `0` for both ρ and Λ with no citation (salt-and-pepper organisation, no
orientation map); those two cells are left uncited in the publication and so have blank `*_ref`
values here.

## Reference join — how to trace any value to its primary study
Each measured column is paired with a `*_ref` column carrying the reference number(s) **exactly as
printed**, multi-citations separated by `", "`. To resolve:

1. split the `*_ref` cell on `", "`;
2. join each token on `ref_key` in `reference_tables/Jung_etal_2022_TableS2_references.csv`;
3. read `citation` — transcribed verbatim from the supplement's own REFERENCES AND NOTES list,
   which uses the same numbering as the main article's.

Ten distinct keys are cited: nine numbers (9, 12, 18, 36, 52, 70, 71, 85, 86), all of which
resolve, plus the literal token `own data`, which is carried as its own `ref_key` row pointing at
Jung et al. (2022) and flagged in `note` as the primary-data marker. Three of the numbered keys are
the same works listed in the paper-level, author-year-keyed
`reference_tables/Jung_etal_2022_secondary_references.csv` — 9 = Kaschube et al. (2010),
18 = Ho et al. (2021), 52 = Schottdorf et al. (2015) — and the `note` column states that crosswalk,
so the two reference tables bind.

## Units
`body_mass_g` is printed with a trailing `g` in the publication ("25g"); the build keeps the number
only. Λ is in mm; ρ is pinwheels per hypercolumn area (dimensionless count).

## Files
- `Jung_etal_2022_TableS2_snapshot.xlsx` — frozen source (sheet `TableS2`)
- `Jung_etal_2022_TableS2.R` — build script (snapshot → analysis CSV → public TSV)
- `Jung_etal_2022_TableS2.csv` — analysis CSV, 9 rows × 8 columns
- `reference_tables/Jung_etal_2022_TableS2_definitions.csv` — column definitions
- `reference_tables/Jung_etal_2022_TableS2_references.csv` — printed key → full citation
- `__Public/comparative-data/10.1126%2Fsciadv.abn0954_TableS2.tsv` — public TSV
