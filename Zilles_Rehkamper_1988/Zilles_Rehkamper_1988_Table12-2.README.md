# Zilles_Rehkamper_1988_Table12-2

## Source

PDF: `zilles_rehkamper_1988.pdf` (in this folder). Chapter: Zilles, K., & Rehkämper, G. (1988), *The brain, with special reference to the telencephalon*, in J. H. Schwartz (Ed.), **Orang-Utan Biology** (pp. 157–176), Oxford University Press. ISBN 9780195043716. Registry Item number **Table 12-2**.

**Table 12-2 — "Volumes of Brain Components and Their Percentages of Total Brain Volume."** This is the chapter's primary volumetric contribution: the fresh volumes of the brain components of the **orang-utan (Pongo)**, with each as a percentage of total brain volume. (The companion **Table 12-3** gives the derived size/encephalization indices for Pongo and the other hominoids — not snapshotted here, by design; indices are derived and recomputed downstream.)

## Layout — this table is structure-as-rows, single species

Unlike the species-as-rows tables in the Stephan/Frahm/Baron series, Table 12-2 lists the brain **structures down the rows** for one specimen (Pongo), with two value columns. The snapshot reproduces that printed orientation rather than imposing the species-row template.

| Path | Role |
|---|---|
| `zilles_rehkamper_1988.pdf` | The publication. |
| `zilles_rehkamper_1988.xlsx` | **Raw** Adobe-PDF-to-Excel export of the whole chapter (all tables across generically-named sheets). Table 12-2 is on the export's sheet `Table 13`. Kept for provenance; not read by the scripts. |
| `Zilles_Rehkamper_1988_Table12-2_snapshot.xlsx` | **Snapshot** (sheet `Table12-2`): Table 12-2 reproduced to read like the printed page — caption, the two-line header (`Fresh Volume (cc³)` / `Percentage of Total Brain Volume¹`), the 18 structure rows with the printed indentation of sub-components, and the footnote. |
| `Zilles_Rehkamper_1988_Table12-2.R` | Preparation → `Zilles_Rehkamper_1988_Table12-2.csv` (+ ISBN-named TSV). Reads only the snapshot. |
| `reference_tables/Zilles_Rehkamper_1988_Table12-2_definitions.csv` | Data dictionary: each structure → canonical structure + measure (Vol.mm3). |
| `comparison/Zilles_1988.csv` | Pre-existing formatted master table (Pongo row carries this paper's values), audited only. |
| `comparison/Zilles_Rehkamper_1988_Table12-2_compare_to_Zilles_1988_csv.R` | Checking (QA): snapshot ↔ `Zilles_1988.csv`. |

## Snapshot layout (made to look like the printed table)

Row 1 caption (`TABLE 12-2. Volumes of Brain Components and Their Percentages of Total Brain Volume`); row 2 header (`Structure` | `Fresh Volume (cc³)` | `Percentage of Total Brain Volume¹`); rows 3–20 the 18 structures in printed order; row 21 the footnote (`¹Excluding ventricles and nerves.`). Sub-components are indented in the `Structure` cell exactly as printed: **Gray area striata** and **White matter** under Neocortex; **Regio praepiriformis** and **Corpus amygdaloideum** under Paleocortex; **Globus pallidus** under Corpus striatum. Volumes are kept in the printed unit **cc³ (= cm³)**; the R step converts to mm³.

The table is internally consistent: the six top-level components (Medulla 5.5, Cerebellum-without-pons 42.9, Pons 4.3, Mesencephalon 4.0, Diencephalon 13.5, Telencephalon 238.3) sum to the total brain and their percentages to 100; the telencephalic parts (Neocortex 219.8 + Hippocampus 2.7 + Regio entorhinalis 1.3 + Paleocortex 2.4 + Septum 0.6 + Corpus striatum 11.5) sum to 238.3.

### Structure-key implications

`Pons` here is the top-level **whole pons** row and maps to `Pons_Vol.mm3`.
It must not be treated as Matano 1985b's ventral-pons (`VPo`) term, even though
the Pongo value in `Stephan_primates` happens to sit in a column whose other
species were populated from Matano. Likewise, `Cerebellum_without_pons` keeps
the paper's explicit exclusion in its definition, and `Gray area striata` is a
grey-only subcomponent distinct from Stephan 1981's area-striata total (which
includes underlying white matter).

## Preparation → `Zilles_Rehkamper_1988_Table12-2.csv`

One row per structure (18) for Pongo: `Species_Zilles1988, structure, fresh_volume_cc3, volume_mm3, pct_total_brain`. The R script reads past the caption+header (data from row 3), drops the footnote row (no numeric volume), squishes the structure label (removing the snapshot's indentation), and converts cc³ → mm³ (×1000). There are no species-name superscripts to translate. Also writes an ISBN-named TSV (`ISBN%3A9780195043716_Table12-2.tsv`) to `../__Public/comparative-data/` (Item encoded looked up in `__ReadMe.xlsx` by the registry Item name `Zilles_Rehkämper_1988_Table12-2`; the on-disk files use the ASCII folder spelling).

## Checking → `comparison/`

Because the table is structure-as-rows for one species, the audit is **per-structure for Pongo**: each snapshot volume (cc³ → mm³) is matched to the corresponding column of the Pongo row in `Zilles_1988.csv`. Verified: **12 shared structures matched, 0 value mismatches** (Telencephalon 238 300, Neocortex 219 800, Cerebellum 42 900, Medulla 5 500, Mesencephalon 4 000, Diencephalon 13 500, Hippocampus 2 700, Septum 600, Striatum 11 500, Pallidum 1 800, Amygdala 1 400, Palaeocortex 2 400). Reported but expected, not errors:

- **snapshot-only (6):** Pons, Gray (without area striata), Gray area striata, White matter, Regio entorhinalis, Regio praepiriformis — printed in Table 12-2 but not carried as their own canonical column in this CSV.
- **csv-only (3):** Body_weight (54 000 g) and Brain_weight (333 000 mg) — given in the chapter text (Table 12-1), not in Table 12-2 — and the canonical `Lobus_piriformis` recode.

## Provenance note (why only Pongo)

Zilles & Rehkämper (1988) is the original source of the **orang-utan** brain-structure volumes;
indices for Gorilla, Pan, Hylobates and Homo in the chapter's Table 12-3 were computed from Stephan
et al. (1981). Pongo data added to several **pre-1988** dataset CSVs without recording this source
therefore show up as `csv_only` anachronisms in those papers' comparisons. A `Pongo` value in a
pre-1988 formatted CSV that the paper itself never measured almost certainly traces back to this
chapter — Matano et al. 1985b is the clearest case (see that folder's README). Treat the
anachronism as evidence of the borrowing, not as a mismatch to reconcile.

*(A cross-table audit of this in the private companion repo was retired on 2026-08-20; the finding
above is what it established.)*
