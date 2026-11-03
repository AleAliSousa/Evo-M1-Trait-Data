# Nakanishi_etal_1997_TABLEII

**Item name** `Nakanishi_etal_1997_TABLEII` · **Item number** `TABLE II` · **Item encoded (derived, awaiting registration)** `10.1007%2FBF03011974_TABLEII`

Nakanishi, O., Ishikawa, T., Imamura, Y., & Hirakawa, T. (1997). Inhibition of cerebral metabolic and circulatory responses to nitrous oxide by 6-hydroxydopamine in dogs. Canadian Journal of Anaesthesia, 44(9), 1008-1013. https://doi.org/10.1007/BF03011974

**Item full original title:** TABLE II Modification of cerebral circulatory and metabolic Response to N2O by pretreatment with 6-Hydroxydopamine in dogs (p. 1011)

> **Not yet registered.** No `__ReadMe.xlsx` row exists; the public TSV is named by the code the registry formula would build (DOI with `/` percent-encoded, `_`, item locus), the Mink_etal_1981 convention. Paste `Nakanishi_etal_1997_TABLEII_registry_row.xlsx` to register.

## Source

PDF `Nakanishi-1997-Inhibition of cerebral metaboli.pdf` (moved from `cereb metabol refs/`), journal pp. 1008-1013. Typeset PDF with a usable text layer, used only to locate passages; values read from 300/500-dpi renders. TABLE I (MAP, PaO2, PaCO2, pH by period and group) carries no cerebral metabolic or flow values and is not built; the Figure (cortical catecholamines) is not built.

## Pipeline

```
Source PDF
  -> Nakanishi_etal_1997_extract_snapshot.R   verbatim printed block; refuses to overwrite a differing frozen copy
  -> Nakanishi_etal_1997_TABLEII_snapshot.csv   FROZEN: 19 printed rows
  -> Nakanishi_etal_1997_TABLEII.R              parse + table checks (no values typed)
  -> Nakanishi_etal_1997_TABLEII.csv            28 rows ("use this")
  -> __Public/comparative-data/10.1007%2FBF03011974_TABLEII.tsv
  -> reference_tables/Nakanishi_etal_1997_TABLEII_definitions.csv
```


## Who read the values, when, and how it was checked

Transcribed **blind** by an AI assistant (Claude) on 2026-11-02 from page renders (TABLE II re-read row by row on a 500-dpi crop), frozen before any compilation value was opened. The page sets each Periods and Time label once per pair of group lines (vertically centred); the snapshot keeps them on the line where they are printed, and the build script assigns them (Control = rows 3-4; each Time label covers its own 6-OHDA line and the sham-op line above).

## Table checks

Result of an actual R run (2026-11-02): pass 0, mismatch 0, not evaluable 0 (no arithmetic relation printed; the daggers are statistical marks).

## Data role

**Proposed: `primary`**.

## Arms, anesthesia and preparation

* **Groups:** sham-operated (intracisternal saline 1 ml, 7 days earlier) and 6-OHDA (intracisternal 6-hydroxydopamine 100 ug/kg, 7 days earlier); 7 dogs each; pretreatment under pentobarbital 50 mg/kg i.p.
* **Periods:** Control (mean of 5-8 determinations over 30 min) = halothane 0.2% end-tidal in 60% N2 / 40% O2; N2O addition = 60% N2O substituted for N2 (10/30/60 min); N2O withdrawal = N2 again (10/30/60 min). Induction halothane 2-3%, surgery 1-1.5%; succinylcholine; ventilated; lidocaine local.
* **Preparation:** in vivo; CBF by electromagnetic flow-meter on the cannulated sagittal-sinus outflow, converted to ml/100 g brain/min with individual brain weights (Michenfelder et al. 1968); CMRO2 = CBF x arterial-sagittal sinus O2 content difference.

## Species

Mongrel dogs, male and female, 8-16 kg. Proposed key row: `reference_tables/Nakanishi_etal_1997_species_key_proposed.csv` (Canis lupus familiaris, 9615); not adopted into `_keys/`.

## Compilation check (done after the snapshot was frozen)

Kaufman 2004 A14 row 93 (CBF 63 ± 5; CMRO2 272.77 ± 9.38 umol/100g/min, n = 7, 'Halothane') = TABLE II Control sham-op 63 ± 5 and 6.11 ± 0.21 ml/100 g/min (x 44.643), exact. Kaufman row 94 (CBF 173 ± 26; CMRO2 317.00 ± 17.40, 'Halothane, N 20') = TABLE II N2O addition 10 min sham-op 173 ± 26† and 7.10 ± 0.39† (x 44.65), i.e. the 10-min peak during 60% N2O, not a steady state (30 min 6.92, 60 min 7.34). Of the two Kaufman candidates, 272.77 is the control (0.2% halothane in N2/O2) and 317.00 the N2O arm; Kaufman's 'N 20' tag marks the N2O arm. Both are the sham-operated group (intracisternal saline 7 d earlier, which the authors suspect itself enhanced the N2O response); neither compilation carries the 6-OHDA arm. Karbowski 2007 S1 row 5 CMRO2 0.061 ± 0.002 ml/g/min = the same Control sham-op 6.11 ± 0.21 (/100), labelled whole brain; its total O2 4.392 ml/min is not printed (the paper gives no brain weights; implies ~72 g). Caveats both compilations drop: CBF is sagittal-sinus outflow normalised to brain weight (Michenfelder method); dispersions printed as SD but called SEM in the text (E001).

Restricted comparison extract: `Evo-M1-Trait-Data-restricted/__energetics_comparison/primary_items_extract/nakanishi_1997.csv`.

## Human visual check of snapshot

Not yet recorded.

<!-- errata:begin -->
## Errata

Generated from `reference_tables/Nakanishi_etal_1997_errata.csv` by `_tools/dataset_builder/render_errata.R` -- edit the CSV, not this block. See `_tools/dataset_builder/ERRATA_CONVENTION.md`.

| id | variable | where printed | printed | repo value before | issue | proposed | status | evidence | note |
|---|---|---|---|---|---|---|---|---|---|
| Nakanishi_etal_1997-E001 | * | TABLE II footnote, p. 1011: 'Mean ± SD of seven dogs.' (same footnote under TABLE I, p. 1010) | Mean ± SD of seven dogs. |  | publication_ambiguity |  | proposed | RESULTS p. 1010 quote TABLE I's MAP 107 ± 7 and 127 ± 7 mmHg as '(Mean ± SEM)', and METHODS give PaCO2 '36 ± 2 mmHg (mean SEM)', while the TABLE I and II footnotes say SD. Several TABLE II dispersions are very small for an SD across seven dogs (CMRO2 5.98 ± 0.07, 6.32 ± 0.07; CV ~1%), which fits SEM better. The paper does not settle which. | dispersion_type kept as SD (as the table footnote prints); merges should treat it as SD-or-SEM. Kaufman 2004 carries the dispersion as SD. |

1 recorded, 1 open (proposed), 0 confirmed, 0 withdrawn.
<!-- errata:end -->
