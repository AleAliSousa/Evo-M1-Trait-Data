# Kochiyama et al. (2018) — Figure 3 family + supplementary extractions

Scientific Reports 8:6296, DOI 10.1038/s41598-018-24331-0. Source PDFs in this folder:
`Kochiyama-2018-Reconstructing the Neanderthal.pdf` (main) and
`41598_2018_24331_MOESM1_ESM.pdf` (supplementary). NT = Neanderthal (n=4),
EH = early *Homo sapiens* (n=4), MH = modern *Homo sapiens* (n=1185).

## The five items (as listed in `__ReadMe.xlsx`)

| Item | What it is | File(s) |
|---|---|---|
| `Figure3legend` | MH mean ± s.d. volume (cc) of the 13 parcels | `..._Figure3legend_snapshot.csv`, `.csv`, `.R` |
| `Figure3A` | Figure 3(a): NT/EH/MH **relative volumes** from the bar graphs for the 13 parcellated regions. MH = 1.0 by construction. | `..._Figure3A_snapshot.csv`, `.csv`, `.R` |
| `Figure3B` | Figure 3(b): digitized absolute left/right cerebellar volumes, in cc, for Ce A and Ce P by group. | `..._Figure3B_snapshot.csv`, `.csv`, `.R` |
| `ExtendedDataFigure4` | relative volumes from the individual-brain (4×1185) reconstruction (digitized) + Cohen's d | `..._ExtendedDataFigure4_snapshot.csv`, `.csv` |
| `ExtendedDataTable1` | AAL-atlas correspondence for the 13 parcels (faithful text) | `..._ExtendedDataTable1_snapshot.csv`, `.csv` |
| `ExtendedDataTable3` | ANOVA F(2,1190), p, post-hoc t(1190) for all 13 regions (faithful text) | `..._ExtendedDataTable3_snapshot.csv`, `.csv` |

Each item has a `reference_tables/*_definitions.csv`. Public TSVs are written to
`__Public/comparative-data/` under the DOI-encoded names from the registry.

> **Relabelling note.** In the earlier build, `Kochiyama_etal_2018_Figure3` held the
> *legend* data. The updated registry splits this into **`Figure3legend`** (the MH
> means) and **`Figure3`** (the figure = relative-volume bars). The files here follow
> the new registry: `Figure3` is now the digitized relative volumes; the old
> legend-era `Figure3.R`/`.ReadMe.md` were replaced.

## Reconciliation of the relative volumes (the analysis)

`Kochiyama_etal_2018_reconcile_relative_volumes.R` →
`Kochiyama_etal_2018_relative_volumes_reconciled.csv`.

Three independent derivations of NT/EH relative volume (MH = 1.0 by construction):

1. **Figure 3 bars** — digitized (±0.02).
## Figure 3A columns

- `Region_code`: Kochiyama parcel label from the figure.
- `Structure`: broader anatomical grouping.
- `Subregion`: textual expansion of the parcel.
- `NT_rel`: Neanderthal relative volume.
- `EH_rel`: early Homo sapiens relative volume.
- `MH_rel`: modern Homo sapiens relative volume, fixed to 1.0.
- `source`: source paper key.
- `note`: extraction note.

## Figure 3B columns

- `Region_code`: Kochiyama cerebellar parcel label from the figure.
- `Structure`: broader anatomical grouping.
- `Subregion`: textual expansion of the parcel.
- `Group_code`: NT, EH, or MH.
- `Group`: expanded group label.
- `Hemisphere`: Left or Right.
- `Volume_cc`: digitized volume in cubic centimeters.
- `source`: source paper key.
- `note`: extraction note.

## Notes

- Figure 3A and Figure 3B are no longer combined in a single snapshot, CSV, TSV, or R script.
- Values are figure-digitized estimates from the published figure.
- This shared ReadMe is intentionally the only shared file between the two items.

2. **Statistical recovery from Extended Data Table 3.** The post-hoc t's use the
   pooled ANOVA error (df 1190); MH supplies 1184/1190 of that df, so the pooled
   error variance ≈ MH's relative variance = CV² (CV = s.d./mean from the legend).
   Then `m_group = 1 + t(group vs MH) · CV · sqrt(1/4 + 1/1185)`, sign from Figure 3.
   The three pairwise t's are over-determined; their mutual consistency validates
   the table (recomputed `t_NTvsEH` matches the printed value to < 0.001).
3. **Extended Data Figure 4 bars** — digitized (individual-brain reconstruction).

**Result:** methods (1) and (2) agree to **< 0.01 relative-volume units** for every
ANOVA-significant region. MH is identical (=1.0) across legend / Figure 3 / Ext Fig 4,
as expected; Ext Fig 4 NT/EH means are close to Figure 3 but not identical (different
reconstruction) with much larger s.d. — exactly as the paper states.

Best estimates (MH = 1.0): Ce P NT 0.94 / EH 0.99; Ce V NT 0.97 / EH 1.01;
Pa SI NT 0.96 / EH 0.97; Oc SM NT 1.06 / EH 1.06; Oc I NT 1.03 / EH 1.05;
Sm NT 0.98 / EH 0.97. The other 7 regions are ANOVA-non-significant (NT/EH within
~1 CV of MH; digitized values only).

See **`REPORT_Kochiyama_relative_volumes_reconciliation.docx`**.

## Cross-paper comparability (Balzeau / Weaver / Kochiyama)

See **`REPORT_cross_paper_comparability.docx`**. Summary: the three cannot be pooled
into one numeric table (surface area vs volume vs mass; size-corrected vs MH-relative
vs absolute; different structures). The one genuinely poolable axis is **cerebellar
volume (Weaver × Kochiyama)** — Kochiyama's MH total cerebellum (Ce A+Ce P+Ce V) =
**140.65 cc** vs Weaver's recent-human MRI cerebellum = **140.5 cc** (0.1% apart),
an independent cross-validation. All three converge qualitatively: occipital
relatively larger in fossils, parietal larger in modern humans, cerebellum reduced
in Neanderthals.

## Fossil specimens table (compiled from the main-paper TEXT, not tabulated)

`Kochiyama_etal_2018_FossilSpecimensText.csv` (+ `_snapshot.csv`, `_groupmeans.csv`,
`_dateReferences.csv`, definitions) tabulates the 8 fossils used in the study:

- **Taxon** (p.5 / p.1): 4 NT (Neanderthal) — Amud 1, La Chapelle-aux-Saints 1,
  La Ferrassie 1, Forbes' Quarry 1; 4 EH (early *Homo sapiens*) — Qafzeh 9, Skhul 5,
  Mladeč 1, Cro-Magnon 1. (MH = 1185 *living* humans, no fossils.)
- **Specimen date range** (p.1, `date_min_yBP`/`date_max_yBP`) and the derived
  **midpoint** (`date_mean_yBP`); Forbes' Quarry 1 has no dating information.
- **Species-level date** = NT–*H. sapiens* divergence ~600,000–800,000 yBP (p.1,
  ref 19 = Meyer et al. 2016) — this is the only species-level date the paper gives;
  interpret accordingly.
- **Reconstructed cerebral & cerebellar volumes** (p.2, cc + mm³) per specimen; the
  per-specimen values reproduce the paper's reported group means exactly (NT 1161/149,
  EH 1135/153, MH 1097/149 cc) — a transcription check.
- **Date-citation references** (pp.7–8) resolved in `_dateReferences.csv` (refs 19–29,
  plus 18 for the Pan divergence).

Nomenclature matches the other Kochiyama files (NT/EH/MH codes; `Cerebrum_Vol.cc/.mm3`,
`Cerebellum_Vol.cc/.mm3`). Not a registry item; proposed encoded name
`10.1038%2Fs41598-018-24331-0_FossilSpecimensText`.
