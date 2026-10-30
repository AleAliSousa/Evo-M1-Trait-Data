# Deaner et al. 2006 — Table 1 (primate cognition meta-analysis ranks)

Deaner RO, van Schaik CP, Johnson VE (2006). *Do some taxa have better domain-general cognition
than others? A meta-analysis of nonhuman primate studies.* Evol Psychol 4:149–196.
doi:10.1177/147470490600400114.

Registry: **`Deaner_etal_2006_Table1`**, encoded `10.1177%2F147470490600400114_Table1`; stage
candidate → set after R rerun.

## What the data are
Performance **ranks** (lower = better; fractional = ties) for **24 primate genera × 30
experimental procedures** — 113 filled cells — across 9 cognitive paradigms. Paradigm→procedure
mapping taken from the paper's sections **and the printed grid borders** (image-verified):
DP 1–3, PS 4, ID 5–7, TU 8–9, DL 10–17, RL 18–23, **OD 24–26, SO 27** (procedure 26 is described
inside the Oddity section — the caption's paradigm order alone would mislead), DR 28–30.
**SECONDARY** (meta-analysis; per-procedure primary studies cited in the paper's text). Long
format: one row per genus × procedure.

## Overlap warning
Same meta-analytic lineage as **`Johnson_etal_2002_Table1`** (registry note: "largely overlaps").
Johnson 2002 is deferred (its PDF corrupts fractional ranks — see
`Johnson_etal_2002/Johnson_etal_2002_NOTE.md`); if it is ever built, cross-validate against this
item and never treat the two as independent.

## Source → Snapshot → Data readable
Extracted with `pdftotext -bbox` **word coordinates** (each value assigned to its nearest
procedure-column center — no whitespace guessing), then verified against the rendered page image
(journal p. 154 = PDF p. 7). Wide matrix frozen in `Deaner_etal_2006_Table1_snapshot.xlsx`
(sheets `Table1`, `notes`); `.R` reshapes to the long `.csv` (**use this**) + public TSV.
Built offline 2026-08-31 (Python mirror) — re-run the .R in RStudio.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry stage ⬜ → R rerun ⬜ → Merge ⬜
