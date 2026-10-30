# Barger et al. 2007 — Table 1 (amygdaloid complex + basolateral nuclei volumes)

Barger N, Stefanacci L, Semendeferi K (2007). *A comparative volumetric analysis of the amygdaloid
complex and basolateral division in the human and ape brain.* American Journal of Physical
Anthropology 134(3):392–403. doi:10.1002/ajpa.20684
(Semendeferi-lab paper — consistent with the Semendeferi/Zilles shared collection.)

Full table title (for `__ReadMe.xlsx`): **"Table 1. Volumetric estimates of the amygdaloid complex
and the basolateral division"**

## Source → Snapshot
PDF p. 4 (text layer; the grid extracts cleanly). `Barger_etal_2007_Table1_snapshot.csv` — 12
specimens, faithful to print: species group-header rows kept, left/right (L/R) sub-columns for each
ROI, footnote markers on the specimen IDs (d/e/f), en-dash `–` for not-collected, `cm3` units, order
preserved. *Recommend a visual diff against the PDF.*

Columns (ROIs, each L + R): Amygdaloid complex (AC), Basolateral division (BLD), Lateral (L),
Basal (B), Accessory basal (AB); plus Hemi = summed both cerebral hemispheres. Footnotes:
`d` axial sections (subnuclei not collected) · `e` basal & AB not discriminable · `f` left temporal
damage (left subnuclei not collected; right hemisphere doubled in Barger's analysis).

## Data readable
`Barger_etal_2007_Table1.R` → `Barger_etal_2007_Table1.csv` (**use this**). One row per specimen,
species forward-filled to binomial, `–` → NA, and an `_total` (= L + R) added for each ROI.
**`amygdaloid_complex_total`** (whole amygdaloid complex, both hemispheres) is the column that maps to the Stephan
**Amygdala**. Verified against the paper's prose (human AC 3.805, BLD 2.424, lateral 1.146 cm³).

## Provenance — important
The ape specimens (`YN82-140`, `YN86-137`, `YN89-278`, `YN85-38`, `YN81-146`, `Bathsheba`, `Zahlia`,
`Disco`, `Harry`, `Briggs`) are the **same Hirnforschung / Stephan-Collection brains** measured by
MacLeod et al. 2003 (their Table 2). So Barger's amygdala values can be merged **specimen-to-specimen**
with Stephan/MacLeod for these individuals — not just at the species mean. Primary stereology
(Cavalieri, NB hand-traced). n = 1 human, 3 chimpanzee, 2 bonobo, 1 gorilla, 3 orangutan, 2 gibbon.

## Specimen registration

All 12 rows are registered in
`_keys/specimen_crosswalk/specimen_crosswalk.csv`. Ten ape rows reuse the
canonical MacLeod/de Sousa specimen, while human `SN207/84` remains
`Barger-only`. Orangutans remain attached to the historical *Pongo pygmaeus*
sensu-lato concept except YN85-38, which public MacLeod evidence resolves as
*Pongo abelii*. Disco remains taxonomically flagged rather than silently
rewritten.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species/specimen note ✅ → Online database ☐

_Note: Table 2 (literature comparison of AC volume ranges across studies) is secondary and not
snapshotted here; can be added if wanted._
