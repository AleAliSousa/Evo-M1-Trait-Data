# Matano (1992) — per-table data

Matano, S. (1992). *A Comparative Neuroprimatological Study on the Inferior Olivary Nuclei
(from the Stephan Collection).* J. Anthropol. Soc. Nippon **100**(1), 69–82.
DOI [10.1537/ase1911.100.69](https://doi.org/10.1537/ase1911.100.69).
PDF: `Matano-1992-A Comparative Neurop.pdf` (in this folder, 14 pp.).

## Layout — one item per printed table (project convention)

The volume data span **four printed tables**, one per taxonomic grade, all sharing the same
schema. Each is its own registry item with its own snapshot, builder, CSV and public TSV —
the same split already applied to `Stephan_etal_1970` and `Stephan_etal_1981`.

| Item | Printed caption (taxon block) | species | `group` values |
|---|---|---|---|
| `Matano__1992_Table1` | Scandentia and prosimians | 19 | `Scandentia` (2), `Prosimian` (17) |
| `Matano__1992_Table2` | New World monkeys | 12 | `New World monkey` |
| `Matano__1992_Table3` | Old World monkeys | 10 | `Old World monkey` |
| `Matano__1992_Table4` | Apes and Man | 4 | `Ape/Human` |

45 species, 78 individuals in total. Table 1 is the only table that mixes two blocks; the
taxon block each row was printed under is carried in the `group` column of every CSV/TSV.

> **History (2026-08-21).** Replaced the single bundled `Matano__1992_Tables1to4` item after
> `__ReadMe.xlsx` was re-registered as four rows (`Table 1`–`Table 4`). The split is
> **merge-invariant**: the four CSVs concatenate to the retired bundled CSV byte-for-byte, the
> four TSVs to the retired bundled TSV, and `volumes_long.csv` / `volumes_wide.csv` are
> unchanged — only provenance labels (`Source`/`item`) refine to the per-table item names.
> The bundled builder also carried a **path bug**: it read its snapshot by a bare relative
> name and referenced `base` / `item_name` before defining them, so running it from anywhere
> but the folder itself failed with
> `Matano__1992_Tables1to4_snapshot.csv does not exist in current working directory: /Users/crossmodal/Desktop`.
> All four new scripts derive their own location (`--file=` / `rstudioapi`) and are safe to
> Source from any working directory.

## Why this is not duplicate data

This is the **inferior olive** — a structure the rest of the dataset does not have. The
Baron/Frahm/Stephan "Comparison of brain structure volumes in Insectivora and Primates" series
covers the vestibular complex (VIII, Baron et al. 1988) and the trigeminal complex (IX, Baron
et al. 1990) but **never the olivary complex**, and no olive structure appeared in
`_keys/Stephan/anatomy_key.csv` before this paper. Matano 1992 is the only olivary source in
the collection. (Sibling Matano papers already ingested measure *different* structures: 1985a
cerebellar nuclei, 1985b ventral pons, 1986 vestibular nuclei, 2001 dentate.)

## Structures

| csv column | structure | printed column |
|---|---|---|
| `IOPr_mm3` | principal inferior olivary nucleus | Inf.Oliv. Principal |
| `IOAcMed_mm3` | medial accessory inferior olivary nucleus | Inf.Oliv. Acc.Med. |
| `IOAcDors_mm3` | dorsal accessory inferior olivary nucleus | Inf.Oliv. Acc.Dors. |
| `IOAc_mm3` | accessory inferior olivary nuclei (medial + dorsal) | Med.+Dorsal |

`IOPr` and `IOAc` are the two headline nuclei (Figs 1–2 and 3–4). **`IOAc = IOAcMed +
IOAcDors`** — re-derived and checked in every builder (max residual 0.05 mm³ in Tables 1 and 3,
0.02 mm³ in Tables 2 and 4; rounding only). If pooling, use `IOAc` **or** the two parts, not
both. Volumes are as measured (both sides, fresh-volume corrected per Stephan et al. 1981);
allometry: log IOPr = 0.71·log W − 1.73.

## Snapshot provenance (important)

The four data tables are **scanned images with no text layer** — PDF text extraction returns
only the captions/footnotes, not the numbers. The snapshots were therefore read directly from
the rendered table images and transcribed by hand. Each
`Matano__1992_Table<N>_snapshot.csv` is the frozen, journal-faithful copy of one printed table
(all printed columns, printed row order); all cleaning happens in the `.R`, never in the
snapshot.

Each builder reads its snapshot **as character throughout** (`col_types = cols(.default =
col_character())`). Matano prints 3 significant figures and the trailing zeros are meaningful
(`0.380`, `8.50`, `0.8000`); parsing to double would silently drop them and rewrite the
published CSV/TSV. Numeric coercion happens only for the `IOAc = IOAcMed + IOAcDors` check.

## Eco-ethological columns

`activity_time`, `diet`, `locomotor_type` are printed alongside but are **external** (after
Napier & Napier 1967), not Matano measurements — kept for faithfulness, flagged `info`/secondary
in the definitions. The only cleaning is the trailing full stop dropped from `diet`
(`Ins.` → `Ins`). Locomotor codes: SAQ semiarboreal quadruped, AQP arboreal quadrupedal
prosimian, VCL vertical clinging & leaping, SCQ slow-climbing quadruped, NAQ New World arboreal
quadruped, NSB New World semibrachiator, OTQ/OAQ Old World terrestrial/arboreal quadruped,
OSB Old World semibrachiator, OTB/OMB Old World typical/modified brachiator, SBP specialised
bipedal hominid.

## Pipeline

raw (scanned tables) → hand-read snapshot csv → R script → usable csv/tsv, **× 4**.

| Path | Role |
|---|---|
| `Matano-1992-A Comparative Neurop.pdf` | source |
| `Matano__1992_Table<N>_snapshot.csv` | frozen journal-faithful transcription of table *N* |
| `Matano__1992_Table<N>.R` | builder (snapshot → clean csv + TSV; verifies the accessory sum) |
| `Matano__1992_Table<N>.csv` | analysis-ready |
| `__Public/comparative-data/10.1537%2Fase1911.100.69_Table<N>.tsv` | public TSV |
| `reference_tables/Matano__1992_Table<N>_definitions.csv` | column definitions |

Each script is self-contained: run `Rscript Matano__1992_Table1.R` from anywhere, or open it in
RStudio and click **Source** (save first). It finds the repo root by walking up to
`__ReadMe.xlsx`; with no repo root it still writes the local CSV and warns that the TSV was
skipped.

## Registration (keys)

Tokens are **paper-scoped**, shared by all four tables — the split did not change them:

- `_keys/Stephan/anatomy_key.csv` — token **`Matano__1992`**: the four olive nuclei
  (`Nucleus_olivaris_inferior_principalis`, `_accessorius_medialis`, `_accessorius_dorsalis`,
  `_accessorius`), plus `Body_weight` and the specimen-count row.
- `_keys/anatomy_reference.csv` — the four olive canonical structures
  (`brain_structure_volume`, `Volume_mm3`).
- `_keys/Stephan/species_key.csv` — token **`Matano1992`**: all 45 species mapped to accepted
  names (subset of the Matano1985a mapping; every species resolves).
- `_keys/volumes_species_overrides.csv` — the 15 curated override rows are keyed by
  **item name**, so they were re-keyed to the table each species is printed in
  (8 × Table1, 3 × Table2, 2 × Table3, 2 × Table4).

## Merge

Primary data, Tier-1 **`Stephan_collection`**, year 1992 — all four items are listed separately
in `__merging_volumes/volumes_compiled.R` and have their own
`standardized_term_by_reference/Matano__1992_Table<N>_standardized_terms.csv` (identical term
mappings, one `Reference` each). The bundled term file is kept as
`Matano__1992_Tables1to4_standardized_terms.csv.RETIRED`; `standardized_term.R` globs `*.csv`,
so it is no longer picked up. `volumes_compiled.R` also carries all four in its `enc_override`
map, so a lost `__ReadMe.xlsx` row degrades instead of halting the merge.

The olive is measured by no other source, so these values pass through Tier-1 resolution
unopposed and are never averaged.

### Still pending (needs R)

- `_keys/build_variable_catalog.R` — `variable_catalog.csv` and
  `variable_catalog_compatibility.csv` were updated offline to match what a re-run produces
  (20 catalog rows for this paper, taxon set per table); re-run to confirm.
- `_tools/file_list.R` — regenerates `AUTO_Public_TSV_FileList`, after which the four
  registry rows' `Public TSV match` lookup flips from `notfound` to the new filenames.
