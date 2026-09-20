## Barger et al. 2012 — Table 1 (specimens in sample)

Barger N, Stefanacci L, Schumann CM, Sherwood CC, Annese J, Allman JM, Buckwalter JA, Hof PR, Semendeferi K (2012). *Neuronal populations in the basolateral nuclei of the amygdala are differentially increased in humans compared with apes: A stereological study.* Journal of Comparative Neurology 520(13):3035–3054. doi:10.1002/cne.23118.

Registry (`__ReadMe.xlsx`): Item name **Barger_etal_2012_Table1**; Item number **Table 1**. The public TSV name must be resolved from `Item encoded` in the live registry.

### What the data are

Table 1 is an **individual-specimen inventory**, not a species-level summary. It contains 35 specimens and preserves the printed species, common name, sex, age, and sampled hemisphere. The sample comprises humans, chimpanzees, bonobos, gorillas, orangutans, gibbons, and long-tailed macaques.

Observation level: **one row per specimen**. Do not treat repeated species rows as duplicates or average them during the item build. Species-level sample sizes used by Table 3 can be derived by counting these rows.

### Collection and tissue-provenance notes

The superscript/table-note keys are retained in the frozen snapshot and expanded by the build script:

- `a`: new histological series processed by N.B.
- `b`: C.M.S. collection.
- `c`: K.S. collection.
- `d`: J.M.A. collection.
- `e`: J.A.B. collection.
- `f`: tissue provided by C.C.S. and P.R.H.; the two marked specimens were sectioned at 40 microns.

The two `f` specimens are the 22-year-old male western lowland gorilla and the 19-year-old male Müller's Bornean gibbon. Other ages are preserved exactly as printed, including `Adult` where no numeric age is given.

### Source → snapshot → data readable

Printed Table 1 in `Barger-2012-Neuronal populations.pdf` → **Barger_etal_2012_Table1_snapshot.xlsx** (sheet `Table1`) → `Barger_etal_2012_Table1.R` → **Barger_etal_2012_Table1.csv** plus the registry-encoded public TSV in `__Public/comparative-data/`.

The snapshot was transcribed from the PDF table by Microsoft Copilot on 2026-09-19 and should be visually checked side-by-side against page 3038 before merge use. It preserves the printed row order, column order, values, and note keys. The R script does not recreate or overwrite the frozen snapshot; it reads it and performs all cleaning downstream.

### Build transformations

- Splits trailing collection keys from the printed species field.
- Preserves the printed species field as `Species_Barger2012`.
- Writes a cleaned species field as `Species` without collection markers.
- Preserves age exactly as printed in `Age_Barger2012` and parses numeric ages into `Age_yr`; `Adult` remains missing in `Age_yr`.
- Expands the note keys to `collection_note` while retaining `collection_key`.
- Keeps hemisphere as printed because one hemisphere was quantified for each specimen.

### Taxonomy notes

Names are retained as printed in this item. `Hylobates concolor` is the paper's printed name for the white-cheeked gibbon specimen, and the three gibbon rows represent separate species. Any accepted-name harmonisation should use the appropriate collection-scoped species key rather than silently changing the frozen snapshot.

### Definitions

No `Table1_definitions.csv` exists for this item, and none is needed: Table 1 is a specimen
inventory (species, sex, age, hemisphere, collection provenance) with no anatomy or measure
variables to define. The paper's single data dictionary,
`reference_tables/Barger_etal_2012_definitions.csv`, covers the anatomical/measure terms
introduced by Table 3 and applies to the whole paper; it is deliberately not table-numbered.

### QA status

- Source: printed PDF table.
- Frozen snapshot: created.
- Expected analysis rows: 35.
- Observation level: individual specimen.
- Visual PDF-to-snapshot check: still required by the item owner.
- Data role: supporting specimen/provenance metadata for the Table 3 stereological means; confirm the registry setting before merge inclusion.
