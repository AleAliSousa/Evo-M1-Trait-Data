# Hansen et al. 2022 — PET-parcellated-scale033 (human regional receptor/transporter densities, 41 PET maps)

Hansen JY, Shafiei G, Markello RD, Smart K, Cox SML, Nørgaard M, Beliveau V, Wu Y, Gallezot J-D, Aumont É,
Servaes S, Scala SG, DuBois JM, Wainstein G, Bezgin G, Funck T, Schmitz TW, Spreng RN, Galovic M, Koepp MJ,
Duncan JS, Coles JP, Fryer TD, Aigbirhio FI, McGinnity CJ, Hammers A, Soucy J-P, Baillet S, Guimond S,
Hietala J, Bedard M-A, Leyton M, Kobayashi E, Rosa-Neto P, Ganz M, Knudsen GM, Palomero-Gallagher N,
Shine JM, Carson RE, Tuominen L, Dagher A, Misic B (2022). *Mapping neurotransmitter systems to the
structural and functional organization of the human neocortex.* Nat Neurosci 25:1569–1581.
doi:10.1038/s41593-022-01186-3.

Registry (`__ReadMe.xlsx`): Item name **`Hansen_etal_2022_PET-parcellated-scale033`**; expected Item encoded
`10.1038%2Fs41593-022-01186-3_PET-parcellated-scale033` (now present in the main registry).
Naming note: the registry formula strips spaces and underscores from `Item number`, so the item is
hyphenated (`PET-parcellated-scale033`) rather than `PET_parcellated_scale033`; hyphens survive the formula.

## ⚠️ Single-species (human) in vivo reference atlas — not comparative across species
Group-average PET (one map is SPECT) tracer-binding maps from 1,238 healthy adults across many studies, one
species only. It contributes human regional receptor/transporter data points — including **primary motor
cortex** (`is_M1 = 1`, Desikan-Killiany *precentral*, left and right) — to be related to regional metabolic
and compositional data, not a cross-species row set.

## Why the frozen source is a *constructed* snapshot (voxel maps → parcellated table)
The paper publishes **no region table**: its data are voxelwise group-average PET images (NIfTI, MNI152),
distributed via neuromaps and the authors' repository. A voxel image cannot be a snapshot in this dataset's
sense (nothing to lay beside a printed table). The authors' repository, however, contains their own
**digital-native tabulation**: `data/PET_parcellated/scale033/<tracer_file>.csv`, one vector of 83 regional
means per map, produced by `code/parcellate.py` (voxel mean within each Lausanne scale033 parcel), and
`data/lausanne/region_info_scale033.xlsx` giving the 83 region labels in that order. Those 41 vectors + the
region file are the frozen source. Because 42 separate files cannot be "copy-renamed untouched" into one
snapshot, **`Hansen_etal_2022_PET-parcellated-scale033_snapshot.R` assembles them** into
`Hansen_etal_2022_PET-parcellated-scale033_snapshot.csv` (83 region rows × 7 metadata columns + 41 tracer-file
columns). Values are carried as the **verbatim text tokens** of the source files (18 significant digits, no
numeric parsing, no re-ordering); the metadata columns are the authors' `region_info_scale033.xlsx` columns as
read (`scale`, constant `scale033`, dropped; the unnamed 0-based index column kept as `row_index`). The script
verifies the sha256 of all 41 tracer CSVs against `github_hansen_receptors/download_manifest.csv` and refuses
to overwrite a snapshot that differs from a fresh assembly. The side-by-side check for this snapshot is
file-by-file: column `<tracer_file>` of the snapshot = the token sequence of `<tracer_file>.csv`
(verified programmatically on 2026-11-15, all 41 identical; region metadata identical to the xlsx).

**Parcellation caveat.** The *published* analyses use the Schaefer 100/200/400 cortical parcellations
(Methods); the Lausanne scale033 (Desikan-Killiany + subcortex) tabulation is the preprint atlas kept in the
repository (README: "the atlas I used for the preprint"). It is used here because it joins region-for-region
with Johansen et al. 2024 Table 2 (SV2A synaptic density) and with FreeSurfer-based regional metabolic data.

## Frozen source (provenance)
`github_hansen_receptors/` = frozen download of **netneurolab/hansen_receptors**, commit
`f8b41da92a733f99368c1f39d4959731aa1316c1`, downloaded 2026-11-15 (`download_manifest.csv`: path, URL, bytes,
sha256 per file; 59 files, of which this item reads the 41 scale033 CSVs and `region_info_scale033.xlsx`).
Licence of the repository: **CC BY-NC-SA 4.0** (`LICENSE.md`) — non-commercial use, attribution to Hansen et al.
2022 *and* to the original PET studies (`reference_tables/Hansen_etal_2022_PET-parcellated-scale033_references.csv`),
share-alike for derivatives. The paper itself is CC BY 4.0. Downstream public TSVs inherit the NC-SA terms.
Integrity note: on 2026-11-15 `region_info_scale033.xlsx` on disk (19,495 bytes) no longer matched the manifest
sha256 (12,263 bytes): OneDrive/SharePoint re-saved the workbook in place, adding `customXml/` metadata parts.
The cell content was compared with the commit-pinned raw file from GitHub and is identical (83 × 8 cells); the
snapshot script therefore warns rather than stops on that one file. The 41 tracer CSVs match their sha256.

## What the data are
**3,403 rows** = 83 regions (68 Desikan-Killiany cortical, 34 per hemisphere; 15 subcortical: thalamus,
caudate, putamen, pallidum, accumbens, hippocampus, amygdala ×L/R, brainstem labelled L) × 41 tracer maps.
Each row: the regional mean of one group-average map (`value`), the map's binding measure (`value_unit`), the
receptor/transporter, tracer, n and source study parsed from the authors' filename convention
`<receptor>_<tracer>_hc<n>_<source>[_suffix]`, and `in_hansen_main_matrix` (1 = one of the 26 maps that
make up the paper's 19-receptor matrix; 0 = the 15 alternative/comparison maps). **Values are
hemisphere-specific** (left and right rows; no L+R mean is formed — the maps are densities, not volumes).

**Units differ by map and are NOT interconvertible.** BPND and SUVR are unitless ratios, VT is mL/cm³,
Bmax is pmol/mL (Beliveau/Nørgaard atlases: converted from BP or VT with autoradiography densities). Hansen et
al. treat all as "proportional to receptor density" and z-score each map across regions before any
comparison; do the same (or use ranks) before pooling across maps. Measure per map comes from the paper's
**Table 1** (26 maps) or Methods; for 14 maps the paper does not state the measure → `value_unit = see_source`
(consult `reference_tables/Hansen_etal_2022_PET-parcellated-scale033_references.csv` for the source study).

### Tracer → unit table (from `reference_tables/Hansen_etal_2022_PET-parcellated-scale033_tracer_units.csv`)
| tracer_file | receptor (harmonised) | n | source | main matrix | value_unit | unit source |
|---|---|---|---|---|---|---|
| 5HT1a_cumi_hc8_beliveau | 5HT1a | 8 | beliveau | 0 | see_source | not stated |
| 5HT1a_way_hc36_savli | 5HT1a | 36 | savli | 1 | BPND | Table 1 |
| 5HT1b_az_hc36_beliveau | 5HT1b | 36 | beliveau | 0 | see_source | not stated |
| 5HT1b_p943_hc22_savli | 5HT1b | 22 | savli | 1 | BPND | Table 1 |
| 5HT1b_p943_hc65_gallezot | 5HT1b | 65 | gallezot | 1 | BPND | Table 1 |
| 5HT2a_alt_hc19_savli | 5HT2a | 19 | savli | 0 | see_source | not stated |
| 5HT2a_cimbi_hc29_beliveau | 5HT2a | 29 | beliveau | 1 | Bmax_pmol_mL | Table 1 |
| 5HT2a_mdl_hc3_talbot | 5HT2a | 3 | talbot | 0 | see_source | not stated |
| 5HT4_sb20_hc59_beliveau | 5HT4 | 59 | beliveau | 1 | Bmax_pmol_mL | Table 1 |
| 5HT6_gsk_hc30_radhakrishnan | 5HT6 | 30 | radhakrishnan | 1 | BPND | Table 1 |
| 5HTT_dasb_hc100_beliveau | 5HTT | 100 | beliveau | 1 | Bmax_pmol_mL | Table 1 |
| 5HTT_dasb_hc30_savli | 5HTT | 30 | savli | 0 | BPND | Methods (inferred) |
| A4B2_flubatine_hc30_hillmer | A4B2 | 30 | hillmer | 1 | VT | Table 1 |
| CB1_FMPEPd2_hc22_laurikainen | CB1 | 22 | laurikainen | 0 | see_source | not stated |
| CB1_omar_hc77_normandin | CB1 | 77 | normandin | 1 | VT | Table 1 |
| D1_SCH23390_hc13_kaller | D1 | 13 | kaller | 1 | BPND | Table 1 |
| D2_fallypride_hc49_jaworska | D2 | 49 | jaworska | 0 | see_source | not stated |
| D2_flb457_hc37_smith | D2 | 37 | smith | 1 | BPND | Table 1 |
| D2_flb457_hc55_sandiego | D2 | 55 | sandiego | 1 | BPND | Table 1 |
| D2_raclopride_hc7_alakurtti | D2 | 7 | alakurtti | 0 | see_source | not stated |
| DAT_fepe2i_hc6_sasaki | DAT | 6 | sasaki | 0 | see_source | not stated |
| DAT_fpcit_hc174_dukart_spect | DAT | 174 | dukart | 1 | SUVR | Table 1 |
| GABAa-bz_flumazenil_hc16_norgaard | GABAa | 16 | norgaard | 1 | Bmax_pmol_mL | Table 1 |
| GABAa_FLUMAZENIL_c11 | GABAa |  |  | 0 | see_source | not stated |
| GABAa_flumazenil_hc6_dukart | GABAa | 6 | dukart | 0 | see_source | not stated |
| H3_cban_hc8_gallezot | H3 | 8 | gallezot | 1 | VT | Table 1 |
| M1_lsn_hc24_naganawa | M1 | 24 | naganawa | 1 | BPND | Table 1 |
| MU_carfentanil_hc204_kantonen | MOR | 204 | kantonen | 1 | BPND | Table 1 |
| MU_carfentanil_hc39_turtonen | MOR | 39 | turtonen | 0 | see_source | not stated |
| NAT_MRB_hc10_hesse | NET | 10 | hesse | 0 | see_source | not stated |
| NAT_MRB_hc77_ding | NET | 77 | ding | 1 | BPND | Table 1 |
| NMDA_ge179_hc29_galovic | NMDA | 29 | galovic | 1 | VT | Table 1 |
| SERT_DASB_HC30 | 5HTT | 30 |  | 0 | see_source | not stated |
| SERT_MADAM_c11 | 5HTT |  |  | 0 | see_source | not stated |
| VAChT_feobv_hc18_aghourian_sum | VAChT | 18 | aghourian | 1 | SUVR | Table 1 |
| VAChT_feobv_hc3_spreng | VAChT | 3 | spreng | 1 | SUVR | Table 1 |
| VAChT_feobv_hc4_tuominen | VAChT | 4 | tuominen | 1 | SUVR | Table 1 |
| VAChT_feobv_hc5_bedard_sum | VAChT | 5 | bedard | 1 | SUVR | Table 1 |
| mGluR5_abp_hc22_rosaneto | mGluR5 | 22 | rosaneto | 1 | BPND | Table 1 |
| mGluR5_abp_hc28_dubois | mGluR5 | 28 | dubois | 1 | BPND | Table 1 |
| mGluR5_abp_hc73_smart | mGluR5 | 73 | smart | 1 | BPND | Table 1 |

Filename n vs Table 1: `5HT1a_way_hc36_savli` (Table 1: n = 35) and `5HT1b_p943_hc22_savli` (Table 1: n = 23)
disagree by one; the filename values are kept in `n_subjects`, the printed ones in the tracer_units table.
Three files (`GABAa_FLUMAZENIL_c11`, `SERT_DASB_HC30`, `SERT_MADAM_c11`) are not cited anywhere in the paper;
their names match JuSpace (Dukart et al. 2021, ref 7) map names; `c11` is the radionuclide, not an n.
`SERT_DASB_HC30` is not a duplicate of `5HTT_dasb_hc30_savli` (r = 0.98, values differ).

## Aggregation deferred (what Hansen do that this item does NOT)
`code/make_receptor_matrix.py` builds the paper's region × 19 receptor matrix by (i) selecting the 26 maps
flagged `in_hansen_main_matrix = 1`, (ii) z-scoring each map across regions, (iii) for receptors with several
maps (5HT1b: 2, D2: 2, mGluR5: 3, VAChT: 4) taking the **n-weighted average of the z-scored maps**. None of
that is done here: every map is kept as a separate row set so that the consumer chooses the weighting (and can
include or exclude the alternative maps). Note that in the authors' VAChT line the z-scored Bedard (n = 5) and Aghourian (n = 18) maps carry no
multiplier in the numerator while the denominator is 3+4+5+18 = 30 — a quirk of the published code, reported
here as observed, not corrected.

## Join to Johansen et al. 2024 Table 2 (Desikan-Killiany spelling)
`dk_region_johansen` carries the region spelled as in `Johansen_etal_2024/Johansen_etal_2024_Table2.csv`
(`Region`), via `reference_tables/Hansen_etal_2022_PET-parcellated-scale033_dk_region_key.csv`: 38 of the 42 distinct labels
match by a case- and space-insensitive string rule (`lateralorbitofrontal` → `Lateral orbitofrontal`), 3 are
manual (`bankssts` → *Banks of the superior temporal sulcus*, `thalamusproper` → *Thalamus*, `accumbensarea` →
*Accumbens*), and `brainstem` has no counterpart (Johansen prints *Pons*, which is not the whole brainstem) →
NA. **82 of 83 regions** (41 of 42 labels) join; Johansen's lobe totals, cerebellum, ventral DC, pons and
white matter have no Hansen counterpart. Johansen's hemisphere columns (`SV2A_L`, `SV2A_R`) join on
`hemisphere` as well.

## Source → Snapshot → Data readable
Authors' repository (digital-native parcellated CSVs) → **`Hansen_etal_2022_PET-parcellated-scale033_snapshot.R`** → frozen
`Hansen_etal_2022_PET-parcellated-scale033_snapshot.csv` → **`Hansen_etal_2022_PET-parcellated-scale033.R`** →
**`Hansen_etal_2022_PET-parcellated-scale033.csv`** (use this; 3,403 rows × 21 columns) + public TSV
`__Public/comparative-data/<Item encoded>.tsv` (written once the item is registered). Column meanings:
`reference_tables/Hansen_etal_2022_PET-parcellated-scale033_definitions.csv`. Item-scoped lookups: `..._tracer_units.csv` (map → measure, Table 1
row, Hansen reference numbers), `..._references.csv` (`ref_key` = `tracer_file`; one row per cited work, 62 rows;
verbatim bibliography entries from the PDF text layer — subscripts such as 5-HT~1B~ / GABA~A~ are flattened by
extraction), `..._dk_region_key.csv` (label → Johansen spelling).

**Reader.** Values were carried from the authors' files into the snapshot by `Hansen_etal_2022_PET-parcellated-scale033_snapshot.R`
(no human transcription); Table 1 measures, n, references and the Methods tracer-comparison notes were read
from the PDF text layer (pages 4, 12–14, 16) by an AI assistant (Claude) on 2026-11-15 and typed into
`reference_tables/Hansen_etal_2022_PET-parcellated-scale033_tracer_units.csv`; the DK key was generated by the string rule plus three manual rows.
Fidelity checks run 2026-11-15: snapshot tokens == source tokens for all 41 files; analysis-CSV `value` ==
source value to ≤ 5 × 10⁻¹⁵ relative (R `write.csv` prints 15 significant digits; the snapshot keeps all 18).
Human visual check of the snapshot: not applicable (tabulated and digital already); the Table 1 transcription
in `tracer_units.csv` is pending a human RA check.

## Table checks
None — the source tables print no totals or percentages (no `table_checks` reported by the build script).

## Build status
Snapshot ✅ · Data readable ✅ (CSV written by `Rscript Hansen_etal_2022_PET-parcellated-scale033.R` 2026-11-15) ·
definitions ✅ · README ✅ · registry row `Hansen_etal_2022_PET-parcellated-scale033_registry_row.xlsx` ✅ (to be pasted by the owner) ·
**public TSV complete 2026-11-26**: `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hansen_etal_2022/Hansen_etal_2022_PET-parcellated-scale033.R` wrote 3,403 rows to `__Public/comparative-data/10.1038%2Fs41593-022-01186-3_PET-parcellated-scale033.tsv`. This derived file follows the source repository's CC BY-NC-SA 4.0 terms, with Hansen et al. and the original PET-study citations in the item references file. The unresolved tracer-unit annotations noted above remain flagged; no units were inferred in this completion. Data role: primary (single-species human reference).
