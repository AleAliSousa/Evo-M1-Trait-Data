# Weibel et al. 2004 — Tables 1 + A.1 (mammalian VO2max and body mass)

Weibel ER, Bacigalupe LD, Schmitt B, Hoppeler H (2004). *Allometric scaling of maximal metabolic
rate in mammals: muscle aerobic capacity as determinant factor.* Respir Physiol Neurobiol
140:115–132. doi:10.1016/j.resp.2004.01.006.

Registry: **`Weibel_etal_2004_Table1`** (`10.1016%2Fj.resp.2004.01.006_Table1`) and
**`Weibel_etal_2004_TableA.1`** (`…_TableA.1`); stage cells blank → set after R rerun.

## What the data are
- **Table 1** (p. 119): species-level pooled VO2max (ml/min) + body mass (kg), **34 species**.
- **Table A.1** (pp. 128–129): the underlying **58 study-level estimates** (species × primary
  study; strain/sex in the printed common name), with per-kg and absolute VO2max.

## ⚠ Published discrepancy — Table 1 misalignment (verified against page image)
Table 1's VO2max column is shifted by one species for the chipmunk→guinea-pig block: T1 chipmunk
14.58 = A.1 mole rat's value; T1 rat 54.44 = A.1 mongoose; T1 mongoose 32.59 = A.1 guinea pig;
rat's own A.1 values are 14.5–28.9 ml/min. All values kept **as printed**; the 5 affected rows
carry the discrepancy in their `note` column. **Prefer Table A.1** (its 58 rows verify internally:
body mass × per-kg = absolute for every row).

Names as published: "Equus caballlus" (sic, horse rows), "Helogale pervula" (sic, =parvula),
"Agouti paca" (=Cuniculus paca) — paper-scoped species key resolves.

## Source → Snapshot → Data readable
Both tables transcribed from the folder PDF (`pdftotext -layout`; Table 1 verified against the
rendered page image) into `Weibel_etal_2004_Tables_snapshot.xlsx` (sheets `Table1`, `TableA1`,
`notes`). Per-item `.R` → `.csv` (**use these**) + public TSVs. Definitions in
`reference_tables/`. Built offline 2026-08-31 (Python mirror) — re-run both .R in RStudio.

## Merge note — NOT yet wired
VO2max is a body/physiology trait (body_ecology side, not brain volumes). Study-level A.1 is the
mergeable layer; Table 1 only as a cross-check.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry stages ⬜ → R rerun ⬜ → Merge ⬜
