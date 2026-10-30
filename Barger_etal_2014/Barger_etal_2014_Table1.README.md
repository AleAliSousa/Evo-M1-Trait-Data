# Barger_etal_2014_Table1

## Source

PDF: `Barger-2014-Evidence for evoluti.pdf`; Adobe PDF→Excel export: `Barger-2014-Evidence for
evoluti.xlsx`. Paper: Barger, N., Hanson, K. L., Teffer, K., Schenker-Ahmed, N. M., & Semendeferi,
K. (2014). *Evidence for evolutionary specialization in human limbic structures.* Front Hum
Neurosci, 8, 277. https://doi.org/10.3389/fnhum.2014.00277 (open access). `__ReadMe.xlsx` row:
`Barger_etal_2014`, Item number "Table 1", encoded `10.3389%2Ffnhum.2014.00277_Table1`.

Table 1 — stereological volumes (cubic centimetres, cc) of the amygdala (lateral, basal,
accessory basal, central nuclei, and whole-amygdala total), hippocampus, and striatum in **20
individual hominoid specimens** (Homo, Pan troglodytes, Pan paniscus, Gorilla, Pongo, Hylobates
lar, Nomascus concolor, Hylobates muelleri). The paper has other tables (Table 2 = frontal/insular
cortex; Table 3 = Stephan anthropoid data; etc.); only Table 1 is built here.

## Files

| Path | Role |
|---|---|
| `Barger-2014-Evidence for evoluti.pdf` | The publication. |
| `Barger-2014-Evidence for evoluti.xlsx` | Raw Adobe PDF→Excel export (all tables, uncleaned). Provenance; not read by the scripts. |
| `Barger_etal_2014_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): journal-style — caption; tier-1 header (Species \| Amygdala \| Hippocampus \| Striatum); tier-2 (Lateral \| Basal \| Accessory basal \| Central \| Total); 20 specimen rows with footnote markers (∗ / a / b) and dashes kept; footnote row. |
| `Barger_etal_2014_Table1.R` | Reformat → `Barger_etal_2014_Table1.csv` (+ DOI-named TSV). Reads only the snapshot. |
| `reference_tables/Barger_etal_2014_Table1_definitions.csv` | Data dictionary (10-column schema). |
| `__Public/comparative-data/10.3389%2Ffnhum.2014.00277_Table1.tsv` | Shared public copy. |

## Key fidelity / interpretation notes

- **One hemisphere.** Per the table footnote, every volume is **one hemisphere** of the
  individual specimen (cc) — *not* a both-hemisphere sum. This matters when pooling with
  Barger 2007 (which reports L/R and both-hemisphere totals) or Stephan (both-hemisphere). The
  definitions flag this on every volume.
- **Footnote markers (kept in snapshot, translated in R):** `*` = case also included in Barger
  et al. 2007 → column `in_barger2007` (Y/N); trailing `a` = paraffin-embedded
  (Semendeferi 1998 / Barger 2007), `b` = cryosectioned (Barger 2012) → column `processing`. A
  dash `–` = the structure was not measured/included for that case → `NA` in the CSV.
- **Multiple individuals per species** with no printed specimen ID, so the reformat assigns a
  sequential `case_index` (1–20) used both in the CSV and for the comparison match.

## Reformat → CSV

Reads past the 3 header rows, names the 8 columns by position, keeps the 20 specimen rows (≥1
numeric value; the footnote row is dropped), parses the species binomial and its `*`/`a`/`b`
markers into `species` + `in_barger2007` + `processing`, types the seven volume columns (∗
stripped, `–` → NA), and adds `source = "Barger_etal_2014"`. (R is not in the build sandbox; the
committed CSV/TSV were produced by a Python mirror of this logic and will be regenerated when you
run the R.)

Output columns: `case_index, species, processing, in_barger2007, amygdala_lateral_cc,
amygdala_basal_cc, amygdala_accessory_basal_cc, amygdala_central_cc, amygdala_total_cc,
hippocampus_cc, striatum_cc, source`. Structure names (`LateralNucleus`, `BasalNucleus`,
`AccessoryBasalNucleus`, `CentralNucleus`, `AmygdaloidComplex`, `Hippocampus`, `Striatum`) match
`Barger_etal_2007` so the catalog pools them.

## Verification

No `comparison/` folder is kept — that convention is reserved for tables that already had a
pre-existing formatted sheet, and this one was built from the raw PDF + export. Verification was
done at build time by cross-checking the snapshot (from the Adobe export) against an independent
extraction from the **PDF text**, matched by specimen order (`case_index`): **20 specimens, all
seven volume columns agree, 0 value mismatches**, including the dash/`NA` pattern.
