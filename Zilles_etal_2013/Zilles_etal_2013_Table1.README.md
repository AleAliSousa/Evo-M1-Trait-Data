# Zilles et al. 2013 — Table 1 (brain size & gyrification index across mammals)

Zilles K, Palomero-Gallagher N, Amunts K (2013). *Development of cortical folding during
evolution and ontogeny.* Trends in Neurosciences 36(5):275–284. doi:10.1016/j.tins.2013.01.006

Table 1 = **"Brain size and gyrification index (GI) in various mammalian orders, families, and
species"** — a comparative compilation of whole-cortex GI for 45 non-primate mammal species
across 10 orders (Monotremata, marsupials, Proboscidea, Rodentia, Lagomorpha, Carnivora,
Perissodactyla, Artiodactyla, Cetacea). **No primates appear in this table** — the paper's
primate GI scaling is presented in Figure 2, not Table 1.

## Why this was built
The paper was present in the repo as **PDF only** and registered in `__ReadMe.xlsx` as
`Zilles_etal_2013_Table1`, but had no snapshot, no reformat script, and no CSV/TSV — so its GI
values were not usable in the merge. This build adds the full house pipeline.

## Source → snapshot → CSV
- **Source:** `Zilles-2013-Development of cortical folding du.pdf` (Table 1), in this folder.
- **Snapshot:** `Zilles_etal_2013_Table1_snapshot.xlsx` (sheet `Table1`) — a **faithful** copy of
  the printed table: row 1 = caption, row 2 = header, then data verbatim. The print **leaves
  Order/Family blank on continuation rows** and lists **multiple GI values per species** (each a
  different source reference) as rows with blank Order/Family/Species/Common name; the snapshot
  preserves that layout. Footnote `a` (GI methods per reference code) is kept as a trailing row.
- **Reformat:** `Zilles_etal_2013_Table1.R` reads the snapshot, forward-fills the repeated
  Order/Family/Species/Common-name cells, keeps **one row per GI value** (a species with 3 GI
  values → 3 rows), adds `GI_method` from the footnote, harmonises species (accepted binomial in
  `species_sci`, printed name in `Species`), and writes:
  - `Zilles_etal_2013_Table1.csv` (54 GI rows, 45 species)
  - `__Public/comparative-data/10.1016%2Fj.tins.2013.01.006_Table1.tsv`

## Columns
`species_sci` (resolved binomial), `Species` (printed), `Common_name`, `Order`, `Family`,
`Brain_size` (the table's mixed volume/weight figure — **not** a standardised volume),
`GI`, `Ref` (source-reference code), `GI_method` (expansion of the footnote).

## Multiple GI values per species
Vulpes vulpes (2), Felis domestica (3), Panthera leo (2), Equus caballus (2), Sus scrofa
domestica (3), Bos taurus (2), Ovis aries (2) each carry more than one GI value from different
sources. These are kept as separate rows, **not averaged here**. Since step 17 (25 November 2026)
each row is a data point of the one route (`__compiled/item_columns.csv`, `__compiled/datapoints.R`),
with its cited work taken from `Ref`.

## Species names
Table 1 is almost entirely non-primate mammals, which are outside the primate/insectivore-focused
`_keys/species_reference.csv`; those names therefore pass through as the cleaned printed binomial
in `species_sci` (documented, not an error). Several are historical spellings (e.g. *Felis
domestica* = *Felis catus*, *Phocaena phocaena* = *Phocoena phocoena*, *Hydrochaeris hydrochaeris*
= *Hydrochoerus hydrochaeris*, *Equus burchelii* = *Equus quagga*); they are resolved by the
species key (`_keys/Stephan/species_key.csv`, rows for `Zilles_etal_2013`).

## Data role
`GI` is **secondary**: every value is taken from another work, named per row in `Ref` (corrected
25 November 2026; this README earlier called it primary). `Brain_size` is **secondary/context** (a
mixed, unstandardised figure; the harmonised brain volumes are served elsewhere). Registry: in
`__ReadMe.xlsx` as `Zilles_etal_2013_Table1` (its data role there is blank).

## Provenance / independence
The GI values come from four works, per the paper's reference list (corrected 25 November 2026;
this README earlier said [7] was Lewitus et al. 2014, which is wrong: Lewitus 2014 is neither a
primary source nor the source of these values):

| `Ref` | Work | Values |
|---|---|---|
| [4] | Pillay P & Manger PR (2007) Eur J Neurosci 25:2705–2712 | 16 |
| [5] | Elias H & Schwartz D (1969) Science 166:111–113 | 14 |
| [7] | Brodmann K (1913) Verhandlungen der Gesellschaft Deutscher Naturforscher und Ärzte, 200–240 | 16 |
| [87] | Schlenska G (1974) | 8 |

The [7] values are total ÷ (total − sulcal) cortical surface from Brodmann's Table 1
(`Brodmann__1913/Brodmann__1913_Table1.csv`): 10 of the 11 species in that table match within 0.02.
The horse does not (Zilles 1.99; Brodmann's surfaces give 2.91); that value is not served (owner,
25 November 2026). Values that also appear in Manger et al. 2012 (from Pillay & Manger 2007) or in
Lewitus et al. 2014 are counted once (`__compiled/datapoints.csv.gz`, status `same_data`).

## Checks
Snapshot↔CSV diff = only the forward-fill of printed repeats + `species_sci` addition + `GI_method`
expansion. Row count: 54 GI values across 45 species.
