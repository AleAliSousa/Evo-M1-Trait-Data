# Bahney_vonBartheld_2018_TABLE3

## Source
Bahney, J., & von Bartheld, C. S. (2018). The cellular composition and glia–neuron ratio in the spinal cord of a human and a nonhuman primate: Comparison with other species and brain regions. *Anatomical Record*, 301(4), 697–710. https://doi.org/10.1002/ar.23728

TABLE 3 (printed p. 704): "Glia–neuron ratios (GNRs) for cerebral cortex, cerebellum, and spinal cord in different vertebrate species".

## Pipeline
| file | role |
|---|---|
| `Bahney_vonBartheld_2018_TABLE3_snapshot.csv` | frozen source: printed header, section rows (Cerebral cortex / Cerebellum / Spinal Cord), rows in printed order, parentheses, `∼`, en-dash ranges, footnote row(s) |
| `Bahney_vonBartheld_2018_TABLE3.R` | reads the snapshot positionally, harmonises species, writes CSV + public TSV |
| `Bahney_vonBartheld_2018_TABLE3.csv` | 43 rows (one per printed row) |
| `reference_tables/Bahney_vonBartheld_2018_TABLE3_references.csv` | 22 cited works: `ref_key` exactly as printed → verbatim bibliography entry |
| `reference_tables/Bahney_vonBartheld_2018_TABLE3_definitions.csv` | data dictionary |
| `Bahney_vonBartheld_2018_TABLE3_registry_row.xlsx` | registry row for the owner |
| public TSV | `__Public/comparative-data/10.1002%2Far.23728_TABLE3.tsv` |

## Reader / provenance
Built 2026-10-28 by an AI assistant from the PDF text layer using word coordinates (column
binning, wrapped cells re-joined to their row), then verified row-by-row against a 3× render of
p. 704. `Chvátal` restored from the page image (text-layer accent glyph).

## Data role — secondary compilation (with two primary rows)
Every row except the paper's own spinal-cord rows ("This Study") is compiled from earlier
publications; `data_role` marks rows `primary`/`secondary`; registry **Data role = both**.
Do **not** merge the secondary rows as new data — use
`reference_tables/Bahney_vonBartheld_2018_TABLE3_references.csv` (join `references` == `ref_key`) as the roadmap to the
primary sources (many are already items in this repo, e.g. Herculano-Houzel et al. 2006/2007,
Sarko et al. 2009, Gabi et al. 2010, Burish et al. 2010, Neves et al. 2014, Haug 1987, Stolzenburg et al. 1989).

## Reference notes (kept verbatim, not corrected)
- All printed keys resolve to exactly one bibliography entry (LITERATURE CITED, pp. 708–710).
- Friede 1954 title prints "Der quantitative Anteil der Glia and der Cortexentwicklung" (kept verbatim).
- Hawkins & Olszewski 1957 row: common name "Minke whale" but binomial "Balaenoptera physales L." (= fin whale *B. physalus*); harmonised to the binomial and flagged in the species key.

## Units
Brain weight g → mg (× 1000). Ranges (e.g. `0.29–0.42`) keep min/max and a midpoint;
parentheses → `*_estimated` flags (footnote: "estimated numerical values or most likely species names").

## Species
Printed Latin names kept in `species_as_published` (parentheses included); harmonised via
`_keys/General/species_key.csv` (source_publication `Bahney_vonBartheld_2018`). Rows with a blank Latin cell (Mouse, Chicken) are matched on the common name. Non-mammals (frogs, chicken, turtle) are retained.

## Table checks
Not assessed: the table has no printed totals or additive relation (ratios are not additive).

## Registry note (action for owner)
`__ReadMe.xlsx` Sheet1 col A for **TABLE 2, TABLE 3 and TABLE 4** ends in an auto-incremented
DOI (`…/ar.23729`, `…/ar.23730`, `…/ar.23731`); the article DOI is **10.1002/ar.23728**
(PDF p. 697; TABLE 1 row). The formula columns therefore resolve `Item encoded` to
`10.1002%2Far.2372{9,30,31}_TABLE{2,3,4}`. The build scripts detect this and write the TSV
under the house-formula code `10.1002%2Far.23728_TABLE<N>` with a warning. The
`<Item>_registry_row.xlsx` files carry the corrected citation; once col A is fixed and
`_tools/file_list.R` re-run, the lookup and the TSV name agree and the guard is inert.
