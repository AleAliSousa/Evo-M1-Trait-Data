# Stephan & Pirlot 1970 — Table 1 (bat brain-structure volumes, 18 species)

Stephan H, Pirlot P (1970). *Volumetric comparisons of brain structures in bats.* Z zool Syst
Evolutionsforsch 8(1):200–236. doi:10.1111/j.1439-0469.1970.tb00876.x · Team **Stephan** (MPI
Frankfurt) + Pirlot (Montréal).

Registry (`__ReadMe.xlsx`): Item **`Stephan_Pirlot_1970_Table1`**, encoded
`10.1111%2Fj.1439-0469.1970.tb00876.x_Table1`, stage VERIFIED → set to Data readable/FINISHED
after R rerun. ⚠ The row's note says "one brain each except Asellia tridens" — **Methods p. 206
names TWO n=2 species: Asellia tridens AND Glossophaga soricina**; update the note.

## What the data are
Absolute volumes (mm³) of 12 brain structures/complexes + total brain + body weight (g) for
**18 bat species from 8 families** (Rhinolophus → Eonycteris; incl. 3 megachiropterans). Stephan-school
parcellation: medulla, cerebellum, mesencephalon, diencephalon, bulbus olfactorius,
palaeocortex+amygdala ("Palaeocortex + NA"), septum, striatum, schizocortex, hippocampus,
neocortex, telencephalon (total). **Net volumes** (pure tissue — ventricles, meninges, nerves
excluded), corrected to fresh standard brain volume (Pirlot & Stephan 1970 standard weights ÷
specific brain weight 1.036). Schizocortex (Rose) = entorhinal + perirhinal + praesubicular.
Species names **as published** (Chaerophon leucostigma, Vampyrops helleri [=Platyrrhinus] are
historical names — paper-scoped key).

## Source → Snapshot → Data readable
Table 1 is a rotated full-page table (journal p. 205 = PDF page 6 of the folder scan). Rendered
at 300 dpi, both column halves read separately with the overlap column and truncated-digit edge
cross-checked; frozen in `Stephan_Pirlot_1970_Table1_snapshot.xlsx` (sheets `Table1` +
`footnote_verbatim`). **Additivity verified for all 18 species**: telencephalon = Σ(cols 5–11)
and total brain = Σ(cols 1–4, 12), max deviation 0.3 mm³ (printed rounding).
`Stephan_Pirlot_1970_Table1.R` → `Stephan_Pirlot_1970_Table1.csv` (**use this**; the .R re-runs
the additivity guards). Columns in `reference_tables/…_definitions.csv`.
Built offline 2026-08-31 (Python mirror) — re-run in RStudio to confirm.

## Merge note — NOT yet wired
Prime candidate for the volumes merge (Stephan-school structures crosswalk exists —
`_checks` Stephan↔merge crosswalk). Mind: these 18 bats predate the Baron et al. 1996 bat
compendium; check for specimen/series overlap with Baron before treating them as independent
(same Frankfurt collection lineage), and the seven Baron-block taxon decisions may touch the
same historical names.

Pipeline: Source ✅ → Snapshot ✅ → Data readable ✅ → Registry note fix + stage ⬜ → R rerun ⬜ → Merge ⬜
