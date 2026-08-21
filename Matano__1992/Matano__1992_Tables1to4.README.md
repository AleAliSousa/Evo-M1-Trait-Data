# Matano__1992_Tables1to4

## Source

PDF: `Matano-1992-A Comparative Neurop.pdf` (in this folder; 14 pp.). Paper:
Matano, S. (1992). *A Comparative Neuroprimatological Study on the Inferior Olivary
Nuclei (from the Stephan Collection).* J. Anthropol. Soc. Nippon **100**(1), 69–82.
DOI [10.1537/ase1911.100.69](https://doi.org/10.1537/ase1911.100.69).

**Tables 1–4 — body weight and inferior-olivary-nucleus volumes** for **45 species**
(78 individuals): 2 Scandentia + 17 prosimians (Table 1), 12 New World monkeys
(Table 2), 10 Old World monkeys (Table 3), 4 apes + human (Table 4). Same schema in
all four; stacked here with a `group` column.

## Why this is not duplicate data

This is the **inferior olive** — a structure the rest of the dataset does not have.
The Baron/Frahm/Stephan "Comparison of brain structure volumes in Insectivora and
Primates" series covers the vestibular complex (VIII, Baron et al. 1988) and the
trigeminal complex (IX, Baron et al. 1990) but **never the olivary complex**, and no
olive structure appears in `_keys/Stephan/anatomy_key.csv`. Matano 1992 is the only
olivary source in the collection. (Sibling Matano papers already ingested measure
*different* structures: 1985a cerebellar nuclei, 1985b ventral pons, 2001 dentate.)

## Structures

| csv column | structure | printed column |
|---|---|---|
| `IOPr_mm3` | principal inferior olivary nucleus | Inf.Oliv. Principal |
| `IOAcMed_mm3` | medial accessory inferior olivary nucleus | Inf.Oliv. Acc.Med. |
| `IOAcDors_mm3` | dorsal accessory inferior olivary nucleus | Inf.Oliv. Acc.Dors. |
| `IOAc_mm3` | accessory inferior olivary nuclei (medial + dorsal) | Med.+Dorsal |

`IOPr` and `IOAc` are the two headline nuclei (Figs 1–2 and 3–4). **`IOAc = IOAcMed +
IOAcDors`** — verified on all 45 rows (max residual 0.02 mm³, rounding only). If
pooling, use `IOAc` **or** the two parts, not both. Volumes are as measured (both
sides, fresh-volume corrected per Stephan et al. 1981); allometry: log IOPr = 0.71·log W − 1.73.

## Snapshot provenance (important)

The four data tables are **scanned images with no text layer** — PDF text extraction
returns only the captions/footnotes, not the numbers. The snapshot was therefore read
directly from the rendered table images and transcribed by hand.
`Matano__1992_Tables1to4_snapshot.csv` is the frozen, journal-faithful copy (all
printed columns, four tables); all cleaning happens in the R script, never in the
snapshot. Integrity was checked by reproducing the printed **Med.+Dorsal** column as
`IOAcMed + IOAcDors` on every row (max residual ≤ 0.06).

## Eco-ethological columns

`activity_time`, `diet`, `locomotor_type` are printed alongside but are **external**
(after Napier & Napier 1967), not Matano measurements — kept for faithfulness, flagged
`info`/secondary in the definitions. Locomotor codes: SAQ semiarboreal quadruped,
AQP arboreal quadrupedal prosimian, VCL vertical clinging & leaping, SCQ slow-climbing
quadruped, NAQ New World arboreal quadruped, NSB New World semibrachiator, OTQ/OAQ Old
World terrestrial/arboreal quadruped, OSB Old World semibrachiator, OTB/OMB Old World
typical/modified brachiator, SBP specialised bipedal hominid.

## Pipeline

raw (scanned tables) → hand-read snapshot csv → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `Matano-1992-A Comparative Neurop.pdf` | source |
| `Matano__1992_Tables1to4_snapshot.csv` | frozen journal-faithful transcription |
| `Matano__1992_Tables1to4.R` | builder (snapshot → clean csv; verifies accessory sum) |
| `Matano__1992_Tables1to4.csv` | analysis-ready, 45 species |
| `reference_tables/Matano__1992_Tables1to4_definitions.csv` | column definitions |

## Registration (keys)

- `_keys/Stephan/anatomy_key.csv` — token **`Matano_1992`**: the four olive nuclei
  (`Nucleus_olivaris_inferior_principalis`, `_accessorius_medialis`, `_accessorius_dorsalis`,
  `_accessorius`), plus `Body_weight` and the specimen-count row.
- `_keys/anatomy_reference.csv` — the four olive canonical structures added
  (`brain_structure_volume`, `Volume_mm3`).
- `_keys/Stephan/species_key.csv` — token **`Matano1992`**: all 45 species mapped to
  accepted names (subset of the Matano1985a mapping; every species resolves).

### Still pending (need tools not in the cloud env)

- **`variable_catalog.csv`** regenerates from this folder's `definitions.csv` when
  `_keys/build_variable_catalog.R` is run (R). Not run here (no R in the container).
- **`__ReadMe.xlsx`** already carries the Matano 1992 bibliography row; its
  `Item in AUTO Public TSV FileList` lookup flips from `notfound` after
  `_tools/file_list.R` rebuilds the generated sheet and Excel recalculates the formula.
