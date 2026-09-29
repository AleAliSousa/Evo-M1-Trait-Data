# Lewitus et al. 2014 — External Database S1, sources per data item

Lewitus E, Kelava I, Kalinka AT, Tomancak P, Huttner WB (2014). *An adaptive threshold in
mammalian neocortical evolution.* PLoS Biology 12(11):e1002000. doi:10.1371/journal.pbio.1002000

A rollup of the per-species table in **External Database S1** (`pbio.1002000.s021.doc`): for each
data item printed for two or more species, how many species list it, how many distinct references
they cite, and which reference dominates. It is the variable-level view used to trace where Table S1
columns come from — e.g. `neocortex volume`: 27 species, 25 of them citing ref 17 (Bush & Allman
2003), although the published Table S1 values are Stephan et al. 1981's (see the restricted audit).

## Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `pbio.1002000.s021.doc` | **Raw** journal supplement (Word 97–2003). Kept for provenance; not read by the script. |
| `Lewitus_etal_2014_ExternalDatabaseS1sources_snapshot.xlsx` | **Snapshot** (sheet `Table`): the per-species table as printed. |
| `Lewitus_etal_2014_ExternalDatabaseS1references.csv` | Citations, built by `Lewitus_etal_2014_ExternalDatabaseS1references.R` — **run that script first**. |
| `Lewitus_etal_2014_ExternalDatabaseS1sources.R` | Preparation → `Lewitus_etal_2014_ExternalDatabaseS1sources.csv` (+ DOI-named TSV). Reads only the snapshot and the references CSV. |
| `../__Public/comparative-data/10.1371%2Fjournal.pbio.1002000_ExternalDatabaseS1sources.tsv` | Public TSV, named from `__ReadMe.xlsx` (Item name → Item encoded). |

A Word document is not digital-native in the sense of Tables S1/S8 (see the references README), so
this item is built from a snapshot.

## Snapshot layout

Row 1 the document title; row 2 the printed intro paragraph; row 3 the printed header `Species` /
`Data` / `Reference(s)`; then the 93 printed rows — 91 species, as *Propithecus verreauxi* and
*Pteropus giganteus* are printed twice. Each Word paragraph is one line of the cell; blank paragraphs
are kept and trailing ones dropped. Names, values and typos are as printed (`Alouatta paliatta`,
`Choloeps didactylus`, `Carpus callosum`, an unclosed bracket in the *Ovis aries* entry).

## Pairing items with references

In print the reference numbers are lined up with the data items by eye, with blank paragraphs padding
for wrapped text, so line positions cannot be trusted. The script pairs them by **order**:

- **Data cell → items.** A blank line ends an item; a line starting with a lower-case letter
  continues the item above (the six `…neonate body` / `and brain weight` breaks).
- **Reference(s) cell → sources.** One per non-blank line; its numbers are the parenthesised integers
  on that line (`(63), (64)` for *Mus musculus* is two). Text such as `Wikipedia`, `See text.` or
  `(Kelava, personal observation)` is a source with no number.
- **Equal counts** → item *k* gets source *k* (91 of 93 rows).
- **Unequal counts** → not attributable item by item; left out of the rollup (*Monodelphis virgiana*:
  two items, `(60), (61)` on one line).
- **No references printed** → left out (*Tachyglossus aculeatus*).

## Rollup → `Lewitus_etal_2014_ExternalDatabaseS1sources.csv`

Item text is normalised for grouping: lower case, every parenthesised value removed (units, values,
and the `(- corpus callosum)` qualifier — so `Neocortex volume (- corpus callosum)` groups with
*Procyon lotor*'s plain `Neocortex volume`), spaces squeezed, no space before a comma. One row per
item printed for **2 or more** species (19), sorted by `n_species`, then item:

| Column | Meaning |
|---|---|
| `data_item_normalised` | normalised item text |
| `n_species` | distinct species listing the item |
| `n_distinct_refs` | distinct reference numbers cited for it |
| `dominant_ref_number` | the number cited by the most species (ties → lowest number) |
| `n_species_with_dominant` | species citing that number |
| `dominant_ref_pct` | 100 × `n_species_with_dominant` / `n_species`, one decimal; species whose source has no number count in `n_species` |
| `dominant_ref_citation` | from the references CSV |

## Changes from the previous version (2026-09-28)

The earlier `Lewitus_etal_2014_ExternalDatabaseS1_variable_sources.csv` was rolled up from a
`textutil` text-layer parse that split the table wrongly and left 13 blocks it could not pair out of
the count:

- two species were merged into their neighbours (*Choloepus didactylus* into *Cheirogaleus medius*,
  *Hydrochaeris hydrochaeris* into *Homo sapiens*);
- the wrapped `…neonate body` / `and brain weight` item made six blocks look unpaired;
- bracketed values at the end of an item were read as reference numbers (*Cynictis penicillata*
  `Litters per year (2)`, *Erinaceus europaeus* `group size (1)`), and the un-numbered `Wikipedia`
  source for *Tupaia glis* was not counted;
- `(60), (61)` and `(63), (64)` lost a number, and *Callithrix jacchus* / *Oryctolagus cuniculus*
  were read as having no reference;
- spellings with a space before a comma (`brain weight , body weight`) were counted as separate items.

Counts therefore rise — neocortex volume 25 → 27 species (ref 17: 23 → 25), cortical thickness
18 → 25, adult body/brain and neonate weights 18 + 3 → 31 — and percentages now carry a decimal
(92.0 → 92.6). The restricted provenance file still reflects the old parse (see below).

## Related checks (restricted repo)

`Evo-M1-Trait-Data-restricted/restricted_checks/Lewitus_etal_2014/comparison/` holds the source
audit (`Lewitus_SOURCE_AUDIT.md` / `.html`), the per-species × item provenance
(`Lewitus_etal_2014_ExternalDatabaseS1_provenance.csv`, still the earlier `textutil` parse; its
errors are listed in the `provenance_csv_check` column of
`Lewitus_etal_2014_Neocortex_source_attribution.csv`) and that attribution file.

## Names and role

Registered in `__ReadMe.xlsx` as Item number `External Database S1 _variable_sources` → Item name
`Lewitus_etal_2014_ExternalDatabaseS1sources` (renamed 2026-09-28 from
`Lewitus_etal_2014_ExternalDatabaseS1_variable_sources.*`). Source metadata, not trait values;
`secondary` in the registry.
