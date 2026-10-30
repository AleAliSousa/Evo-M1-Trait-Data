## Frahm_Zilles_1994_Table2

### Source

PDF: `frahm_zilles_1994.pdf` (in this folder). Paper: Frahm, H. D., & Zilles, K. (1994), *Volumetric comparison of hippocampal regions in 44 primate species*, *J. Hirnforsch.*, 35(3), 343–354. PMID 7983368. Registry Item number **Table 2**.

Printed Table 2 (p. 348) reports retrohippocampal-region volumes for **48 species (4 Insectivora + 44 primates)**. It contains six measurements: subiculum, CA1, CA2, CA3, hilus, and fascia dentata. All volumes are in mm³.

### Pipeline

raw → snapshot → R script → usable csv/tsv.

| Path | Role |
|---|---|
| `frahm_zilles_1994.pdf` | The publication; printed Table 2 is on p. 348. |
| `frahm_zilles_1994.xlsx` | **Raw** Adobe-PDF-to-Excel export. Kept for provenance; not read by the preparation script. |
| `Frahm_Zilles_1994_Table2_snapshot.xlsx` | **Journal-faithful snapshot** with one sheet, `Table2`. It preserves the printed species order and blank rows separating Insectivora / Prosimians / Simians. No grade headers or n column were added. |
| `Frahm_Zilles_1994_Table2.R` | Preparation → `Frahm_Zilles_1994_Table2.csv` plus the registry-encoded TSV. Reads only the snapshot. |

### Preparation → Frahm_Zilles_1994_Table2.csv

One row per species (48): `Species`, `subiculum_mm3`, `CA1_mm3`, `CA2_mm3`, `CA3_mm3`, `hilus_mm3`, and `fascia_dentata_mm3`.

The R script:

1. reads past the caption and column-header rows;
2. retains rows with a species name and numeric CA1 volume;
3. drops the blank taxonomic separators;
4. parses all six measurements as numeric values;
5. checks for duplicate species and warns if the row count is not 48; and
6. writes the local CSV and, when the repository registry is available, the `Item encoded` TSV under `__Public/comparative-data/`.

No unit conversion or species-name modernization is performed.

### Relationship to Table 1

The paper states that the retrocommissural hippocampus volume shown in printed Table 1 is calculated as the sum of the six Table-2 regions. The separate Table-2 item therefore retains only the six directly tabulated subfield volumes and does not repeat body weight, total hippocampus, HP + HS fibres, or the calculated retrocommissural total.

### Data note

The printed journal names are preserved in both the snapshot and analysis CSV, including abbreviated or historical forms such as *Tarsius spec.* and *Avahi l. occidentalis*. Accepted names and taxonomy should be applied later through the repository’s existing taxonomy keys rather than altering this journal-faithful item.
