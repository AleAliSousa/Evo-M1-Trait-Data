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
sources. These are kept as separate rows, **not averaged here** — averaging/selection is the
merge's job (`__merging_gyrification`).

## Species names
Table 1 is almost entirely non-primate mammals, which are outside the primate/insectivore-focused
`_keys/species_reference.csv`; those names therefore pass through as the cleaned printed binomial
in `species_sci` (documented, not an error). Several are historical spellings (e.g. *Felis
domestica* = *Felis catus*, *Phocaena phocaena* = *Phocoena phocoena*, *Hydrochaeris hydrochaeris*
= *Hydrochoerus hydrochaeris*, *Equus burchelii* = *Equus quagga*); spelling alignment to any
overlapping source (Lewitus 2014) is handled by the alias map in the merge script.

## Data role
`GI` is **primary** here. `Brain_size` is **secondary/context** (a mixed, unstandardised figure;
the harmonised brain volumes live in the volume merge). Registry: already in `__ReadMe.xlsx` as
`Zilles_etal_2013_Table1`.

## Provenance / independence
The GI values are compiled from four source references, one of which ([7]) is **Lewitus et al.
2014** — i.e. this table is **not fully independent** of `Lewitus_etal_2014_TableS1`. The merge
treats Zilles-2013 and Lewitus-2014 as a citation-dependent pair (see `__merging_gyrification`).

## Checks
Snapshot↔CSV diff = only the forward-fill of printed repeats + `species_sci` addition + `GI_method`
expansion. Row count: 54 GI values across 45 species.
