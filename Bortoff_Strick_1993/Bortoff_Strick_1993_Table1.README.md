# Bortoff & Strick 1993 — Table 1, curated (corticospinal termination extent + CM inference)

**Built 2026-08-15. Re-keyed to the article DOI and renamed to the house pattern 2026-08-15.**

| File | |
|---|---|
| `Bortoff_Strick_1993.pdf` | the publication (open-access, Europe PMC) |
| `Bortoff_Strick_1993_extract_snapshot.R` | builds the frozen snapshot from the curated rows |
| `Bortoff_Strick_1993_Table1_snapshot.xlsx` | frozen source (sheet `Table1`) |
| `Bortoff_Strick_1993_Table1.R` | reformat: snapshot → CSV (+ public TSV + trait table) |
| `Bortoff_Strick_1993_Table1.csv` | analysis table — **2 rows = 2 species**, 12 columns |
| `reference_tables/Bortoff_Strick_1993_Table1_definitions.csv` | data dictionary (13 codes) |
| `PROPOSED_species_key_rows.csv` | the `Bortoff1993` rows staged for `_keys/Stephan/species_key.csv` (already merged in) |

Registry: `Item name = Bortoff_Strick_1993_Table1`,
`Item encoded = 10.1523%2FJNEUROSCI.13-12-05105.1993_Table1`.

## Source

Bortoff, G. A., & Strick, P. L. (1993). *Corticospinal terminations in two New-World primates:
further evidence that corticomotoneuronal connections provide part of the neural substrate for
manual dexterity.* J Neurosci 13(12):5105–5118. DOI 10.1523/JNEUROSCI.13-12-05105.1993.

`Bortoff_Strick_1993.pdf` is the open-access 14-page article retrieved from Europe PMC on
2026-08-15 (SHA-256 `bbb7baad6b0777f600e973dbd0911a5540ec7868528b5446fe1ae654e6f81e0c`).

## Why the snapshot is a curatorial capture, not a printed table

The paper prints **no species × trait table**. The comparative result lives in the Results prose
and in Figures 3–11: for each species the authors describe where the WGA-HRP corticospinal terminal
field sits in the spinal grey. So there is no printed table to reproduce, and the frozen copy
(invariant 1) is instead a hand-verified curatorial capture — one row per species, every cell
carrying the page or figure it came from. `Bortoff_Strick_1993_extract_snapshot.R` rebuilds it;
nothing is cleaned, resolved or converted in the snapshot itself.

*(This replaces the earlier `create_snapshot.mjs`, which required the `@oai/artifact-tool` runtime
and could not be re-run inside this repo.)*

## The trait and its coding rubric

`CST_termination_grade` is a deliberately conservative three-level ordinal:

| grade | meaning |
|---|---|
| `0` | absent or virtually absent from ventral horn / lamina IX |
| `1` | sparse or highly restricted ventral-horn / lamina IX termination |
| `2` | dense and extensive ventral-horn / lamina IX termination |

| species (printed) | accepted | grade | CM inference | evidence |
|---|---|---|---|---|
| *Cebus apella* | *Sapajus apella* | 2 | `likely` | three termination zones; dense, extensive lamina IX overlap at C8–T1 (Results pp. 5108–5111; Figs 3, 5–11) |
| *Saimiri sciureus* | *Saimiri sciureus* | 1 | `against` | two intermediate-zone fields; lamina IX label absent or sparse and highly restricted (Results pp. 5109–5111; Figs 4, 6, 10–11) |

`CM_monosynaptic` is **blank for both rows on purpose.** The paper states outright (Discussion
pp. 5110–5111) that light-microscopic terminal fields prove neither the presence nor the absence of
a direct monosynaptic contact. The authors' softer reading is kept separately in
`CM_connection_inference`, so an inference is never promoted to a fact. The `.R` warns if the column
ever stops being all-NA without a new source (spike-triggered averaging, intracellular recording).

## Species names

The printed name survives verbatim in `Species_printed` (invariant 3). `species_sci` is resolved in
the `.R` from `_keys/Stephan/species_key.csv` under the **`Bortoff1993`** token —
`Cebus apella → Sapajus apella` (Silva 2001). The mapping is **not** hand-coded in the script or the
snapshot (§5).

## Data role — primary

`Data role = primary`. The WGA-HRP tract-tracing observation is Bortoff & Strick's own; only the
0–2 grading is curatorial (that layer is documented in the definitions as `Method:coding`). The row
is merged in `__merging_behaviour` under team **Bortoff_Strick**, measure class `motor_pathway`.

## What is *not* here

- **Nudo & Masterton (1990)** concerns comparative corticospinal **origins**, not termination extent
  — it was not used to manufacture grades. (`Nudo_etal_1995` is built separately.)
- **Lemon (2008)** is a useful comparative review, but §"reviews are roadmaps" applies: broad
  clade-level statements are never assigned to a species without a species-specific primary
  observation.
- **Heffner & Masterton's dexterity scale** stays a separate behaviour variable; it is never used as
  a substitute for the anatomical grade.

## Adding a species

Requires a species-specific tract-tracing or electrophysiology result with the exact page/figure
recorded in `Source_location`. Add the row in `Bortoff_Strick_1993_extract_snapshot.R` **only if it
is still Bortoff & Strick data** — a different paper gets its **own folder** and its own registry
row, and the two are pooled in `__merging_behaviour`, not inside this table.

## Rebuild

```
Rscript Bortoff_Strick_1993/Bortoff_Strick_1993_extract_snapshot.R   # only if the rows change
Rscript Bortoff_Strick_1993/Bortoff_Strick_1993_Table1.R
Rscript ____EvoM1_TraitTable/EvoM1_read_corticospinal_terminations.R
Rscript __merging_behaviour/behaviour_compiled.R
Rscript __ShinyApp/build_data.R
```

Outputs: the snapshot, `Bortoff_Strick_1993_Table1.csv`, and
`__Public/comparative-data/10.1523%2FJNEUROSCI.13-12-05105.1993_Table1.tsv` (filename looked up from
`__ReadMe.xlsx`, invariant 2). The trait-table feed
`____EvoM1_TraitTable/corticospinal_terminations.xlsx` is **not** written by this script — like
every other trait table it has its own reader, which reads the public TSV.

## Checks in the build

- 2 rows; every grade in `{0, 1, 2}`
- every `species_sci` resolved (hard error if the `Bortoff1993` key rows are missing)
- warning if `CM_monosynaptic` stops being all-NA
- warning if a resolved name is absent from `_keys/species_reference.csv`

No `comparison/` step: there is no second curated copy of these values to audit against (§7 — its
absence is not a defect when nothing exists to compare to).
