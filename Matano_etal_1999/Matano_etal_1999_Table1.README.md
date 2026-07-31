# Matano_etal_1999_Table1  — SCAFFOLD (data not yet added)

> **Status: placeholder / awaiting ingest.** This folder is set up so the paper can be
> dropped straight into the existing Matano cerebellar pipeline. Nothing here is wired
> into `__merging_volumes` yet — see the "What to add" checklist below.

## Source

Paper: Matano, S., & Ohta, H. (1999). *Volumetric comparisons on some nuclei in the
cerebellar complex of prosimians.* **American Journal of Primatology** 48(1), 31–45.
DOI `10.1002/(SICI)1098-2345(1999)48:1<31::AID-AJP3>3.0.CO;2-Y`. PMID 10326769.

This is the **prosimian-focused extension of the Matano cerebellar series** already in the
repo (`Matano_etal_1985_a` = Part II cerebellar nuclei; `Matano_etal_1985_b` = Part I
ventral pons; `Matano__2001` = dentate proportions). Same Düsseldorf/Stephan collection,
same measurement conventions — so it slots into the same volumes merge.

**Table I (the target)** — seven volumetric measurements on the cerebellar complex of
~30 prosimian specimens (3 species each of Cheirogaleidae, Lemuridae, Indriidae, plus
Daubentonia, Lorisinae, Galaginae, and Tarsius):

1. medial cerebellar nucleus (MCN)
2. interposed cerebellar nucleus (ICN)
3. lateral cerebellar nucleus (LCN)
4. ventral pons (VPo)
5. inferior olive — principal nucleus (IOP)
6. inferior olive — accessory nuclei (IOA)
7. vestibular nuclear complex (VC)

All volumes in mm³. As with `Matano_etal_1985_a`, the printed table also carries **size
indices / ratios**, which are derived and recomputed downstream — snapshot only the raw
body-weight + volume columns.

## Layout (organised exactly like `Matano_etal_1985_a`)

Final outputs (csv, tsv) come only from the snapshot. Checking is self-contained in
`comparison/`. Taxonomy/anatomy homogenisation across papers lives in the shared
`../_keys/Stephan/`.

| Path | Role | Present? |
|---|---|---|
| `Matano-1999-Volumetric comparisons prosimians.pdf` | the publication | ⬜ add |
| `Matano_etal_1999_Table1_snapshot.xlsx` (sheet `Table1`) | snapshot: BoW + the 7 volume columns in code order | ⬜ add |
| `Matano_etal_1999_Table1.R` | prep → `Matano_etal_1999_Table1.csv` (+ DOI-named TSV) | ⬜ add |
| `Matano_etal_1999_Table1.csv` | usable long-per-species output | ⬜ generated |
| `reference_tables/Matano_etal_1999_Table1_definitions.csv` | data dictionary (template already stubbed here) | 🟡 stub → fill |
| `comparison/Matano_1999.csv` | formatted master table, audited only | ⬜ add |
| `comparison/Matano_etal_1999_Table1_compare_to_Matano_1999_csv.R` | QA: snapshot ↔ `Matano_1999.csv` | ⬜ add |

Expected output columns (one row per species):
`code, Species, n, body_weight_g, MCN_mm3, ICN_mm3, LCN_mm3, VPo_mm3, IOP_mm3, IOA_mm3, VC_mm3`

> **Laterality note to resolve on ingest:** the vestibular complex (VC) in
> `Stephan_etal_1981` / `Baron_etal_1988` was measured **one side only**
> (`../__merging_volumes/laterality_known.csv`). Confirm whether Matano & Ohta's VC (and
> the inferior-olive nuclei) are one-side or both-sides before merging, and register the
> laterality so a one-side value is never averaged against a both-sides value.

## What to add / do (checklist)

1. Drop the PDF in this folder.
2. Build `Matano_etal_1999_Table1_snapshot.xlsx` (sheet `Table1`) from the printed Table I —
   body weight + the 7 volume columns, in printed/code order, with the printed column numbers.
3. Copy `Matano_etal_1985_a_Table1.R` as the template, repoint it at this snapshot, and
   generate `Matano_etal_1999_Table1.csv` + the DOI-named TSV
   `10.1002%2F(SICI)1098-2345(1999)48%3A1%3C31%3A%3AAID-AJP3%3E3.0.CO%3B2-Y_Table1.tsv`
   into `../__Public/comparative-data/` (confirm the exact encoded TSV name against the
   `Item in directory FileList` lookup convention).
4. Fill `reference_tables/Matano_etal_1999_Table1_definitions.csv` (stub provided).
5. Add species/anatomy rows to `../_keys/Stephan/` (data token suggestion: **Matano1999**).
6. Add a registry row to `../__ReadMe.xlsx` (1st Author `Matano`, year `1999`, Collection
   `Stephan`, Item `Table1`, DOI as above).
7. Wire into `../__merging_volumes/` (standardized_term map + rebuild volumes_long/wide);
   check for cross-paper duplicate specimens vs `Matano_etal_1985_a` (overlapping prosimian
   codes should value-match, not double-count).
