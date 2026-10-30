# Bahney_vonBartheld_2018_TABLE4

## Source
Bahney, J., & von Bartheld, C. S. (2018). The cellular composition and glia–neuron ratio in the spinal cord of a human and a nonhuman primate: Comparison with other species and brain regions. *Anatomical Record*, 301(4), 697–710. https://doi.org/10.1002/ar.23728

TABLE 4 (printed p. 706): "Non-neuron to neuron ratios (nNNRs) of different CNS parts among vertebrate species".

## Pipeline
| file | role |
|---|---|
| `Bahney_vonBartheld_2018_TABLE4_snapshot.csv` | frozen source: printed header, rows in printed order, parentheses, `∼`, en-dash ranges, footnote row(s) |
| `Bahney_vonBartheld_2018_TABLE4.R` | reads the snapshot positionally, harmonises species, writes CSV + public TSV |
| `Bahney_vonBartheld_2018_TABLE4.csv` | 112 rows (long: printed row × CNS part with a value) |
| `reference_tables/Bahney_vonBartheld_2018_TABLE4_references.csv` | 16 cited works: `ref_key` exactly as printed → verbatim bibliography entry |
| `reference_tables/Bahney_vonBartheld_2018_TABLE4_definitions.csv` | data dictionary |
| `Bahney_vonBartheld_2018_TABLE4_registry_row.xlsx` | registry row for the owner |
| public TSV | `__Public/comparative-data/10.1002%2Far.23728_TABLE4.tsv` |

## Reader / provenance
Built 2026-10-28 by an AI assistant from the PDF text layer using word coordinates (column
binning, wrapped cells re-joined to their row), then verified row-by-row against a 3× render of
p. 706. The text layer drops the `∼` glyph on the Bandeira et al. (2009) row; it was restored from the page image.

## Data role — secondary compilation (with two primary rows)
Every row except the paper's own spinal-cord rows ("This study" / "Current study") is compiled from earlier
publications; `data_role` marks rows `primary`/`secondary`; registry **Data role = both**.
Do **not** merge the secondary rows as new data — use
`reference_tables/Bahney_vonBartheld_2018_TABLE4_references.csv` (join `references` == `ref_key`) as the roadmap to the
primary sources (many are already items in this repo, e.g. Herculano-Houzel et al. 2006/2007,
Sarko et al. 2009, Gabi et al. 2010, Burish et al. 2010, Neves et al. 2014).

## Reference notes (kept verbatim, not corrected)
- All printed keys resolve to exactly one bibliography entry (LITERATURE CITED, pp. 708–710).
- `Gabi et al. 2010` is printed once without the comma; kept as a separate key (same work as `Gabi et al., 2010`).
- Brain-mass unit is not printed in the Table 4 header; g assumed (Table 3 header; identical values for shared species) and converted to mg.

## Units
Brain mass g → mg (× 1000). Ranges (e.g. `0.29–0.42`) keep min/max and a midpoint;
parentheses → `*_estimated` flags (footnote: "estimated numerical values or most likely species names").

## Species
Printed Latin names kept in `species_as_published` (parentheses included); harmonised via
`_keys/General/species_key.csv` (source_publication `Bahney_vonBartheld_2018`). 

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
