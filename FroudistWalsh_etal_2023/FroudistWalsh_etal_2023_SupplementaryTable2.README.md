# Froudist-Walsh et al. 2023 — Supplementary Table 2 (macaque receptor density per neuron, SD)

Froudist-Walsh S, Xu T, Niu M, Rapan L, Zhao L, Margulies DS, Zilles K, Wang X-J, Palomero-Gallagher N (2023). *Gradients of neurotransmitter receptor expression in the macaque cortex.* Nat Neurosci 26:1281–1294. doi:10.1038/s41593-023-01351-2.

Registry (`__ReadMe.xlsx`): Item name **`FroudistWalsh_etal_2023_SupplementaryTable2`** (owner-registered row, Item number
"Supplementary Table 2"), encoded `10.1038%2Fs41593-023-01351-2_SupplementaryTable2`. The item name has no hyphen
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
**14 receptors × 109 cortical areas = 1526 rows** (long format). Per area and receptor: **standard deviation across
the three brains of the receptor density per neuron, fmol/neuron** (`value_fmol_per_neuron`, Stat = sd; printed cell
kept verbatim in `value_as_printed`). Same receptors, harmonised names and area order as
`FroudistWalsh_etal_2023_SupplementaryTable1` (the means); join the two on `area` × `receptor`.

**`N/A` as printed** → blank for areas **13l, 13m and V4dm** (3 areas × 14 receptors = 42 blank cells); footnote p. 20:
"due to artifacts of sectioning, receptor values were only available for one brain for areas V4dm, 13l and 13m, which
prevented estimates of standard deviation." Absent in print is not zero. Five cells print **`0.0000`** (F5d AMPA; 3al,
V6Avm and V6l GABAA/BZ; 23d M1) — kept as printed; the paper does not explain them. Printed SDs range 0 to 0.3322
(10d, GABAA/BZ).

## Source → Snapshot → Data readable  (printed PDF → generated snapshot)
Source: Springer ESM `supplementary_downloads/41593_2023_1351_MOESM1_ESM.pdf` (Supplementary Information, 24 pages,
text layer; URL, bytes and sha256 in `supplementary_downloads/download_manifest.csv`). The table is printed on
**pp. 17–20** (30 + 33 + 33 + 13 rows; footnote on p. 20).

- **Reader**: `FroudistWalsh_etal_2023_SupplementaryTable2_snapshot.py` (Python, pdfplumber; environment `neuro-atlas`),
  run 2026-11-16 by the AI assistant (Claude); same logic as the Table 1 reader (table located by its printed caption;
  anchored regular expression accepting numbers or `N/A`; header re-joined and asserted; 109 unique rows asserted;
  `--force` guard). The footnote is printed by the script and quoted above.
- **Snapshot**: `FroudistWalsh_etal_2023_SupplementaryTable2_snapshot.csv` — 109 rows, printed layout kept:
  `area, AMPA, kainate, NMDA, GABAA, GABAB, GABAA/BZ, M1, M2, M3, α1, α2, 5HT1A, 5HT2A, D1`;
  `N/A` kept as printed; four decimals as printed.
- **Build**: `FroudistWalsh_etal_2023_SupplementaryTable2.R` (reads the snapshot only) →
  **`FroudistWalsh_etal_2023_SupplementaryTable2.csv`** (use this) + public TSV
  `__Public/comparative-data/10.1038%2Fs41593-023-01351-2_SupplementaryTable2.tsv`. Cleaning: header guard; reshape
  to long; printed label → harmonised receptor name; `N/A` → blank, with a guard that exactly 13l, 13m, V4dm are
  blank. Column meanings: `reference_tables/FroudistWalsh_etal_2023_SupplementaryTable2_definitions.csv`. UTF-8
  locale switch as in the Table 1 script.

Units: **fmol/neuron** kept (source unit, no conversion).

## QA
- Snapshot vs analysis CSV vs public TSV (2026-11-16, Python): **1526 / 1526 cells identical**; 42 blanks exactly in
  13l, 13m, V4dm; TSV identical to CSV; area order identical to Supplementary Table 1.
- Visual spot-check of the page images: 12o NMDA 0.0225 (p. 17), A46vr α2 0.0045 and LIPd GABAB 0.1122 (p. 18),
  V4dm = `N/A` row (p. 19), MT 5HT2A 0.0121 and the footnote (p. 20) — all match.
- `validate_dataset_item()`: csv / tsv / definitions / frozen_source / registry_row / tsv_name_match /
  no_trailing_underscore PASS (readme PASS once this file exists).

## Related / Owner notes
- `FroudistWalsh_etal_2023_SupplementaryTable1` — the means. `github_macaque_receptor_gradients/` — GitHub README
  provenance (no data in the repo). EBRAINS doi:10.25493/5HK3-S8M and BALSA P2Nql not downloaded.
- Registry row exists; no `_registry_row.xlsx` written; `Item encoded` equals the TSV stem.
- `build_dataset_item()` runs only the first `.R` in the folder (Table 1); this item was built with `Rscript` and
  validated with `validate_dataset_item()` directly.

Pipeline: Source → Snapshot ✅ (generated, 2026-11-16) → Data readable ✅ → definitions ✅ → README ✅ →
public TSV ✅ (item was already registered) · single-species macaque reference (*M. fascicularis*, 3 brains).

## Snapshot layout audit (2026-11-27)

The printed table has area plus 14 receptor columns; `page` and `printed_order` were extraction metadata inserted as two leading snapshot columns. They have been removed from the frozen snapshot. The R reader now derives row order and the known four-page pagination, then produces the same long analysis table. `Rscript --vanilla FroudistWalsh_etal_2023/FroudistWalsh_etal_2023_SupplementaryTable2.R` rebuilt the 1,526-row CSV with unchanged SHA-256 `0f3b45b81062d8a12d689b060f9a9f2670cfe0467e23420ba0545f2d13a3f711`. The Python snapshot generator was updated to emit only printed columns; regeneration was not rerun because `pdfplumber` is unavailable in the current base environment. The retained 109 rows and 14 value columns were checked unchanged by the CSV transformation. Human visual signoff remains separate.
