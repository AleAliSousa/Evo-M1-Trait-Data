# Stephan_etal_1982_Table1

## Source

PDF: `Stephan_temp_to_organize/pdfs/Stephan_etal_1982.pdf`. Paper: Stephan, H., Baron, G., & Frahm, H. D. (1982), *Comparison of brain structure volumes in Insectivora and Primates. II. Accessory olfactory bulb (AOB)*, J. Hirnforsch. 23(5), 575-591. PMID 7161483.

Table 1 — the accessory olfactory bulb (AOB) and its three measured layer components, in 61 species. All volumes (columns 2 and 7-9) are in mm3, both sides.

## Layout (organised like Baron_etal_1983/1987/1988)

Final outputs (csv, tsv) come only from the snapshot. Checking is self-contained in `comparison/`. Taxonomy/anatomy homogenisation across papers lives in the shared `../_keys/`.

The pipeline is: **raw → snapshot → R script → usable csv/tsv**. The *snapshot* is cleaned up only enough to be read like the journal table (for direct visual comparison with the PDF); the *R script* does the rest of the cleaning (R-friendly names, superscript translation, fill-down, typing).

| Path | Role |
|---|---|
| `Stephan_etal_1982.pdf` | The publication. |
| `Stephan_etal_1982_exportMSexcel.xlsx` | **Raw** Adobe-PDF-to-Excel export of the whole paper (all tables, uncleaned). Kept for provenance; not used by the scripts. |
| `Stephan_etal_1982_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): Table 1 reproduced to look like the journal page — see below. Visual-inspection copy. |
| `Stephan_etal_1982_Table1.R` | Preparation -> `Stephan_etal_1982_Table1.csv` (+ DOI/PMID-named TSV). Reads only the snapshot; does all the cleaning. |
| `reference_tables/Stephan_etal_1982_definitions.csv` | Data dictionary: every column -> structure, measure, stat, and the size-index method. |
| `comparison/Stephan_1982.csv` | Pre-existing formatted table (raw volumes), audited only. |
| `comparison/Stephan_etal_1982_Table1_compare_to_Stephan_1982_csv.R` | Checking (QA): snapshot vs `Stephan_1982.csv`. |

## Snapshot layout (made to look like the journal table)

The snapshot reads like the printed page so it can be eyeballed against the PDF. It deliberately keeps journal notation (no R-friendly column names, real superscripts) and leaves the cleaning to the R script.

- **Header**: row 1 caption; rows 2–4 the multi-tier journal header (`total AOB` over `volume | SEM in % | size index | in ‰ of net brain | in ‰ of MOB`; `components (layers) of AOB` over `volumes | in % of AOB | size indices`, each split `1+2 | 3–5 | 6`); row 5 the printed column numbers `(1)`–`(15)`. Data begin on **row 6**.
- **Indentation as columns**: the taxonomic hierarchy is spread over three leading columns — `group` (grade/section, col A), `family` (col B), `species` (col C) — so the indent you see in the journal is reproduced without fragile text-indentation. Group headers (Basal Insectivora, Progressive Insectivora, Macroscelidea, Scandentia, Prosimians, Simians) and the Mean rows sit in col A; family headers (Tenrecinae, Erinaceidae …) and the subtotal `n = …` rows sit in col B; species in col C.
- **Superscripts kept**: species names carry the journal's former-name superscripts (`Erinaceus algirus¹`, `Crocidura flavesc.²`, … `Saguinus midas¹¹`); the n marker `*` is kept too. These are *translated* in the R step, not here.
- **Subtotal + Mean rows** carry the index/percentage/per-mille values (volume/SEM/layer-volume cells are blank, as in the original). They are **arithmetic group means computed from the species rows** and reproduce the printed Mean rows to within a unit or two of rounding (basal 117, Insectivora 109, Simians 56, overall 185).
- **Footnotes** at the foot: the `*` (both sexes) note, the `§` note listing the 14 Old-World simians with no AOB, and the nomenclature legend (¹ Aethechinus algirus … ¹¹ Saguinus tamarin).

The R scripts select the **61 species rows** as the only rows with both a species name and a numeric volume, so group/family/subtotal/Mean/footnote rows are ignored automatically.

## The full table = raw data **and** the indices derived from it

The snapshot captures all 15 data columns of the printed table, in three tiers by how each was sourced:

- **Raw measurements (transcribed):** `n`, total `AOB_volume`, and the three layer volumes (`AOB_layer_1_2`, `_3_5`, `_6`). These come from the paper and match the existing `Stephan_1982.csv` exactly (see Checking).
- **Within-row derived (computed from the raw):** `pct_AOB_1_2/3_5/6` (= layer / total x 100) and `permille_net_brain` / `permille_MOB` (AOB relative to net brain and to the MOB, using the net-brain and MOB volumes from Stephan et al. 1981).
- **Allometric size indices (reconstructed + validated):** `size_index` (total AOB) and the three layer size indices `size_index_1_2/3_5/6`.

### How the size indices were obtained

The paper states the method explicitly (Methods, p.5): the volume is plotted against body weight on a double-logarithmic scale, and a **reference line of fixed slope 0.57** is drawn through the **mean log-volume and mean log-body-weight of the 'basal' Insectivora (n = 12)**. A species' size index is `100 x observed / expected`, where *expected* is read off that line; every point on the line has an index of 100.

Reconstructing the indices from the raw AOB volumes + Stephan's body weights with this exact formula reproduces the printed table to within rounding:

- every **legibly printed** index matches to **+/-1** (e.g. Tenrec 70, Echinops 88, Hemiechinus 262, Microcebus 757, Tupaia 585);
- the basal-Insectivora **geometric** mean is **100.1** (the reference, by construction);
- the printed **arithmetic** basal mean (**117**) and the printed **grand mean across all 61 species (185)** are reproduced **exactly**.

The size-index columns therefore hold these validated computed values (the faint 1982 scan is unreliable for OCR of these columns, but they are a deterministic function of the raw data via the paper's own method). `SEM_pct` is the one empirical column that is **not** computable; it was transcribed from the scan (page-image read), and is blank for the 19 single-individual (n = 1) species, which have no standard error.

## Preparation -> `Stephan_etal_1982_Table1.csv`

The R script reads past the multi-row header (data from row 6), names columns by position, and keeps the 61 species rows. It then does the cleaning the snapshot left for this stage:

- carries `group` (grade) and `family` down onto each species row (family resets at each grade, so Macroscelidea / Scandentia / Progressive / Simians species — which have no family header — get `family = NA`);
- splits each name's superscript into `former_name_ref` (the digit) and `former_name` (the translated synonym, e.g. ¹ → *Aethechinus algirus*), leaving a clean `Species_Stephan1982` binomial;
- splits the `n` marker into `n_note` and types `n` as integer;
- types every measurement column.

Output columns: `group, family, Species_Stephan1982, former_name_ref, former_name, n, n_note, AOB_volume_mm3, SEM_pct, size_index, permille_net_brain, permille_MOB, AOB_layer_1_2_mm3, AOB_layer_3_5_mm3, AOB_layer_6_mm3, pct_AOB_1_2, pct_AOB_3_5, pct_AOB_6, size_index_1_2, size_index_3_5, size_index_6`. Current accepted species names are **not** added here — they are applied at the compilation step via `../_keys/Stephan/species_key.csv`. Also writes a DOI/PMID-named TSV (`PMID%3A7161483_Table1.tsv`) to `../__Public/comparative-data/`.

## Checking -> `comparison/`

Matches the snapshot to `Stephan_1982.csv` by the faithful 1982 species name and compares the columns the two share — total AOB volume, the three layer volumes, and n. Verified: **61 matched, 0 value mismatches, no snapshot-only or csv-only rows.** The derived columns are not in the CSV and so are validated by recomputation (above) rather than by this audit.
