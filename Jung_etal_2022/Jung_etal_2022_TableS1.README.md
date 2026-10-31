# Jung et al. 2022 — Supplementary Table S1

## Source
Jung, Y. J., Almasi, A., Sun, S. H., Yunzab, M., Cloherty, S. L., Bauquier, S. H., Renfree, M.,
Meffin, H., & Ibbotson, M. R. (2022). Orientation pinwheels in primary visual cortex of a highly
visual marsupial. *Science Advances*, 8(39), eabn0954. https://doi.org/10.1126/sciadv.abn0954

Item: supplementary **table S1**, "Experimental Data on retinal and V1 cell density", in
`sciadv.abn0954_sm.pdf`.

## What this item is
Eleven mammals (Mouse, Rat, Rabbit, Squirrel, Ferret, Tree shrew, Cat, Wallaby, Macaque, Agouti,
Mouse lemur) with V1 surface area, retina surface area, their ratio, 2D V1 neuron number, retinal
ganglion-cell number, the V1/RGC ratio, and the centro-peripheral retinal ganglion-cell density
ratio (CP ratio).

## Data role — a compilation, not new measurement
The registry records `Data role = both` for this item. On inspection of the printed table, **every
measured cell in table S1 carries a numbered citation to another study** — including the Wallaby
column (V1 size cites 25, retina size and RGC number cite 75, V1 neurons cites 51, CP ratio cites
75 and 7). The only cells Jung et al. contribute are the two **derived ratio rows**
(`V1_retina_surface_ratio`, `V1_neuron_RGC_ratio`), which print no citation and are computed from
the cited values in the same column; the table's own footnote further attributes the 2D V1 neuron
counts to Jang et al. (51).

So for table S1 the honest reading is *secondary throughout, with two derived rows*. Jung et al.'s
own wallaby measurements appear in **table S2** and in `Jung_etal_2022_Reportedresults`, not here.
This is reported, not corrected: the registry `Data role` field has been left as the owner set it.

## Reference join — how to trace any value to its primary study
Each measured column is paired with a `*_ref` column carrying the reference number(s) **exactly as
printed**, multi-citations separated by `", "`. To resolve:

1. split the `*_ref` cell on `", "`;
2. join each token on `ref_key` in `reference_tables/Jung_etal_2022_TableS1_references.csv`;
3. read `citation` — transcribed verbatim from the supplement's own REFERENCES AND NOTES list,
   which uses the same numbering as the main article's.

33 distinct keys are cited by this table and all 33 resolve. **Five** of them are works that the
paper-level, author-year-keyed `reference_tables/Jung_etal_2022_secondary_references.csv` also
lists; the `note` column of the item references file states that crosswalk row by row
(17 = Ibbotson and Jung (2020), 18 = Ho et al. (2021), 25 = Vidyasagar et al. (1992),
51 = Jang et al. (2020), 75 = Wimborne et al. (1999)), so the two reference tables bind. The other
two entries in `secondary_references.csv` — Kaschube et al. (2010) = ref 9 and Schottdorf et al.
(2015) = ref 52 — are **not** cited anywhere in table S1; they are cited by table S2.

## Snapshot caveat
`Jung_etal_2022_TableS1_snapshot.xlsx` is **transposed** relative to the publication: table S1
prints species across the columns and traits down the rows, while the snapshot carries one row per
species. A reviewer laying the snapshot beside the PDF must transpose mentally. The snapshot was
not re-saved or re-cut in this pass (owner instruction); recorded here as a known departure from
the "same spatial format as printed" snapshot rule.

## Missing values
`-` is printed for Agouti and Mouse lemur in the 2D V1 neuron, V1/RGC ratio and (Mouse lemur only)
RGC-number rows; these arrive as blank cells in the CSV and TSV.

## Files
- `Jung_etal_2022_TableS1_snapshot.xlsx` — frozen source (sheet `TableS1`)
- `Jung_etal_2022_TableS1.R` — build script (snapshot → analysis CSV → public TSV)
- `Jung_etal_2022_TableS1.csv` — analysis CSV, 11 rows × 14 columns
- `reference_tables/Jung_etal_2022_TableS1_definitions.csv` — column definitions
- `reference_tables/Jung_etal_2022_TableS1_references.csv` — printed key → full citation
- `__Public/comparative-data/10.1126%2Fsciadv.abn0954_TableS1.tsv` — public TSV
