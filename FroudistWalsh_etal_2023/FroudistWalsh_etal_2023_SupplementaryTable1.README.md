# Froudist-Walsh et al. 2023 — Supplementary Table 1 (macaque receptor density per neuron, mean)

Froudist-Walsh S, Xu T, Niu M, Rapan L, Zhao L, Margulies DS, Zilles K, Wang X-J, Palomero-Gallagher N (2023). *Gradients of neurotransmitter receptor expression in the macaque cortex.* Nat Neurosci 26:1281–1294. doi:10.1038/s41593-023-01351-2.

Registry (`__ReadMe.xlsx`): Item name **`FroudistWalsh_etal_2023_SupplementaryTable1`** (owner-registered row, Item number
"Supplementary Table 1"), encoded `10.1038%2Fs41593-023-01351-2_SupplementaryTable1`. The item name has no hyphen
although the folder (`Froudist-Walsh_etal_2023`) does; the registry is the authority, so every file here uses the
unhyphenated item name.

## ⚠️ Single-species (macaque) reference — not comparative across species
Quantitative in vitro receptor autoradiography in **three adult male *Macaca fascicularis*** (Methods, "In vitro
receptor autoradiography", article PDF p. 15: "three male Macaca fascicularis brains (7.3 ± 0.6 years old; body weight
6 ± 0.8 kg) obtained from Covance Preclinical Services"; Reporting Summary: ages 8, 7 and 7 years). **The species is
*M. fascicularis*, not *M. mulatta*** — the build brief assumed rhesus; the paper and Reporting Summary say cynomolgus.
The human (n = 5) and rat (n = 6) data mentioned in the Methods are not in these tables. One species only; the item
contributes macaque regional data points (notably **primary motor cortex, areas 4a/4m/4p**) to the comparative dataset.

## How the per-neuron values were obtained (Methods, article PDF p. 15)
These are **receptor densities per neuron (fmol/neuron)**, not the autoradiographic densities per mg protein:
- Autoradiographs were calibrated against tritium standards to binding-site concentrations in **fmol/mg protein**
  (14 receptors; ligands and incubation protocols in Supplementary Table 4 of the same PDF, pp. 23–24).
- Neuron density per area was taken from **Collins et al. (2010) PNAS 107:15927–15932 (ref. 8)** — isotropic
  fractionator counts on the brain of **one 4-month-old macaque**, published as a flat map of "Vanderbilt sections"
  in **neurons per gram**. The authors located each Vanderbilt section on the Yerkes19 surface using sulcal and areal
  landmarks and estimated the neuron density of each of the **109 Julich Brain Macaque Maps areas** by the degree of
  overlap with the sections ("Surface representation of neural density data").
- Division used the figure that **8% of brain tissue is protein** (ref. 89, McIlwain & Bachelard 1971): fmol/mg protein
  × 0.08 mg protein per mg tissue ÷ neurons per mg tissue → fmol/neuron. The authors note this "amounts to multiplying
  by a constant". The per-mg-protein source values are **not printed** anywhere in the article or supplement.

**Parcellation**: 109 cortical areas of the *Julich Brain Macaque Maps* (cyto- and receptor-architectonic; EBRAINS KG
instance e39a0407-a98a-480e-9c63-4a2225ddfbe4; surfaces on BALSA study W336). Area labels as printed (e.g. `10d`,
`45A`, `F5v`, `PEipe`, `V4dm`, `29/30`, `a24'ab`, `MT`). Supplementary Table 3 (pp. 21–22, not built) gives their
overlap with the seven Yeo networks.

## What the data are
**14 receptors × 109 cortical areas = 1526 rows** (long format). Per area and receptor: **mean receptor density per
neuron over the three brains, fmol/neuron** (`value_fmol_per_neuron`; printed cell kept verbatim in
`value_as_printed`). Receptors (printed order; harmonised name → printed label): AMPA, kainate, NMDA, GABAA, GABAB,
GABAA/BZ, M1, M2, M3, alpha1 (α1), alpha2 (α2), 5-HT1A (5HT1A), **5-HT2 (printed 5HT2A)**, D1. The harmonised names
are those of `Zilles_PalomeroGallagher_2017_SupplementaryTable2.csv` so the two receptor items join on `receptor`;
the paper labels the ketanserin site 5HT2A where Zilles 2017 labels it 5-HT2 (same ligand). Zilles 2017's
alpha4beta2 is not measured here.

Every cell is printed (no blanks). Note from Supplementary Table 2's footnote (p. 20): for areas **V4dm, 13l and
13m** "receptor values were only available for one brain", so their means rest on n = 1. Range of the printed means
(from the built CSV): 0.006 (V1, D1) to 0.8208 (F5v, GABAB) fmol/neuron.

## Source → Snapshot → Data readable  (printed PDF → generated snapshot)
Source: Springer ESM `supplementary_downloads/41593_2023_1351_MOESM1_ESM.pdf` (Supplementary Information, 24 pages,
text layer; URL, bytes and sha256 in `supplementary_downloads/download_manifest.csv`). The table is printed on
**pp. 13–16** (30 + 33 + 33 + 13 rows).

- **Reader**: `FroudistWalsh_etal_2023_SupplementaryTable1_snapshot.py` (Python, pdfplumber; environment `neuro-atlas`),
  run 2026-11-16 by the AI assistant (Claude). It finds the table pages by the printed caption, pulls every printed
  row from the text layer with an anchored regular expression (area label + exactly 14 numeric/`N/A` tokens), re-joins
  the column header that the text layer splits at the subscripts and asserts it against the expected 14 labels; no
  table value is typed in the script. It asserts 109 unique area rows and refuses to overwrite a differing frozen
  copy unless run with `--force`. A first regex pass elsewhere had found 106 rows; the three missing rows were the
  `N/A` rows of Table 2 (13l, 13m, V4dm) — the pattern here accepts `N/A` and recovers all 109 in both tables, with
  identical area order.
- **Snapshot**: `FroudistWalsh_etal_2023_SupplementaryTable1_snapshot.csv` — 109 rows, printed layout kept:
  `area, AMPA, kainate, NMDA, GABAA, GABAB, GABAA/BZ, M1, M2, M3, α1, α2, 5HT1A, 5HT2A, D1`
  (subscripts flattened, Greek α kept; values as printed — the text layer drops trailing zeros, e.g. `0.295`).
- **Build**: `FroudistWalsh_etal_2023_SupplementaryTable1.R` (reads the snapshot only) →
  **`FroudistWalsh_etal_2023_SupplementaryTable1.csv`** (use this) + public TSV
  `__Public/comparative-data/10.1038%2Fs41593-023-01351-2_SupplementaryTable1.tsv`. Cleaning done there: header
  guard against the 14 printed labels; reshape to long (one row per area × receptor, printed order then printed
  column order); printed label → harmonised receptor name; `N/A` → blank (none in this table). Column meanings:
  `reference_tables/FroudistWalsh_etal_2023_SupplementaryTable1_definitions.csv`. The script switches the character
  locale to UTF-8 when run in a C-locale session so `α` is written as UTF-8 and not `<U+03B1>`.

Units: **fmol/neuron** kept (source unit; a per-neuron receptor-density measure class, no conversion). It is NOT
comparable with the fmol/mg protein values of Zilles 2017 without the neuron densities.

## QA
- Snapshot vs analysis CSV vs public TSV (2026-11-16, Python): **1526 / 1526 cells identical** (`value_as_printed`
  equals the snapshot cell; `value_fmol_per_neuron` equals its numeric value); TSV identical to CSV; 109 areas, 14
  receptors, no empty column; area order identical to Supplementary Table 2.
- Visual spot-check of the page images (`read_file` on the PDF): 10d AMPA 0.1424 and 14r GABAA/BZ 0.4703 (p. 13), F5v M2
  0.0563 (p. 14), PEipe 5HT1A 0.0911 (p. 15), MT D1 0.0124 (p. 16) — all match; header order confirmed on p. 13.
- `build_dataset_item()` validation: csv / tsv / definitions / frozen_source / registry_row / tsv_name_match /
  no_trailing_underscore PASS (readme PASS once this file exists).
- No independent transcription of these per-neuron values exists in the repo (the GitHub repository named in the
  Code availability statement contains no data — see `github_macaque_receptor_gradients/GITHUB_DATA_README.md`).

## Related
- `FroudistWalsh_etal_2023_SupplementaryTable2` — the matching **SD** table (same areas, same order).
- `github_macaque_receptor_gradients/` — provenance copy of the GitHub repository README (no data files in the repo).
- Data repositories named in the paper (not downloaded): EBRAINS doi:10.25493/5HK3-S8M; BALSA study P2Nql.
- `_keys/General/species_key.csv` — row added for `Froudist-Walsh_etal_2023` (Macaca fascicularis, 9541).

## Owner notes
- Registry rows for both Supplementary Tables already exist; no `_registry_row.xlsx` was written. `Item encoded`
  verified equal to the public TSV stem.
- `build_dataset_item()` always runs the first `.R` file in the folder, so it builds Table 1 only; Table 2 was built
  with `Rscript FroudistWalsh_etal_2023_SupplementaryTable2.R` and validated with `validate_dataset_item()`.
- Supplementary Table 3 (Yeo-network overlap) and 4 (incubation protocols) are not built (derived / methods tables).

Pipeline: Source → Snapshot ✅ (generated, 2026-11-16) → Data readable ✅ → definitions ✅ → README ✅ →
public TSV ✅ (item was already registered) · single-species macaque reference (*M. fascicularis*, 3 brains).

## Snapshot layout audit (2026-11-27)

The printed table has area plus 14 receptor columns; `page` and `printed_order` were extraction metadata inserted as two leading snapshot columns. They have been removed from the frozen snapshot. The R reader now derives row order and the known four-page pagination, then produces the same long analysis table. `Rscript --vanilla FroudistWalsh_etal_2023/FroudistWalsh_etal_2023_SupplementaryTable1.R` rebuilt the 1,526-row CSV with unchanged SHA-256 `0417d41524eb6048bf355d94e7af643af1e70a320638afdb366e4d816c23186f`. The Python snapshot generator was updated to emit only printed columns; regeneration was not rerun because `pdfplumber` is unavailable in the current base environment. The retained 109 rows and 14 value columns were checked unchanged by the CSV transformation. Human visual signoff remains separate.
