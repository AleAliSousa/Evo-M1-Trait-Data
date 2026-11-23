# Finlay et al. 2006 — Table 6.1

Finlay BL, Cheung DT, Darlington RB (2006). *Developmental constraints on or developmental structure
in brain evolution.* In: Munakata Y, Johnson MH (eds), *Attention and Performance XXI*, Oxford Univ.
Press. doi:10.1093/oso/9780198568742.003.0006

Table 6.1: per-species body/brain weight, number of visual / somatomotor / total cortical areas, and
total cortical sheet area. Values drawn primarily from the Kaas & Krubitzer mapping studies.

## Source → Snapshot
Publication PDF → Adobe "Export PDF → Excel" → Table 6.1 laid out by hand as
`Finlay_etal_2006_Table6.1_snapshot.xlsx` (`Common Name`, `Species Name`, then the six numeric
columns). Frozen/archival — all cleaning happens in the `.R`.

## Data readable
`Finlay_etal_2006_Table6.1.R` → `Finlay_etal_2006_Table6.1.csv` (**use this**). Numbers typed; the
journal's printed name kept verbatim in `species_as_published`; common name in `common_name`; a
canonical binomial in `Species`. Columns defined in
`reference_tables/Finlay_etal_2006_Table6.1_definitions.csv`.

## Species note (DONE)
The printed `Species Name` column mostly carries real binomials, but a few rows are genus-level
`sp.` or contain typos. Following the repo policy for these tables
(`__merging_volumes/SPECIES_STANDARDIZATION_PLAN.md` §3), a canonical **`Species`** column was added
and every decision recorded, with its basis, in the reviewable **`common_name_to_species.csv`**:

- **spelling fixes**: *Felis cattus*→*Felis catus*, *Tupia belangeri*→*Tupaia belangeri*.
- **CORRECTION**: the previous build renamed *Echinops telfairi*→"*Echinops telfari*" (a typo). That
  rename is removed — *telfairi* is correct and matches the rest of the repo.
- **re-identification of sp.-level labels**: "Rhesus Macaque" *Macaca sp.*→*Macaca mulatta*;
  "Squirrel" *Squirrel sp.*→*Sciurus carolinensis* (Krubitzer 1995; consistent with Changizi 2001).
- **kept at genus level** (clean single genus, species not pinned down): *Galago sp.*, *Mus sp.*
  (printed "Mouse sp."), *Rattus sp.* — with notes on the likely research-model species for review.

The printed names are never overwritten — they remain in `species_as_published`.

**Quality note (from the source):** this is a book chapter / conference volume; references are not
per-row, so the sp.-level assignments above are proposals for sign-off, not journal-stated facts.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅

## Source attribution of the surface-area column (2026-08-25)

Table 6.1 has no per-row citations; the methods name a 30-work Kaas/Krubitzer corpus and describe
the measurement: *"we traced the perimeters of flattened cortices [from the published maps] into
NIMH Image v.4 … and used their accompanying scale bars"*. A per-species attribution against that
citation list is in **`Finlay_etal_2006_Table6.1_source_attribution.csv`** (attributed source,
confidence, evidence, cross-source value check). Headlines:

- **Well-attributed**: the five shrews (Catania et al. 1999), tenrec (Krubitzer et al. 1997), tree
  shrew (Lyon et al. 1998), three Huffman-1999 marsupials, *Didelphis* (Beck et al. 1996 — which
  mapped *D. virginiana*, so the printed *D. marsupialis* is a conflation, matching the chapter's
  own "North American Opossum"), marmoset, squirrel monkey, macaque (Felleman & Van Essen 1991 —
  the 32-visual-area count and the ~10,600 mm² surface both match), flying fox, galago.
- **No cited source exists** for *Trichosurus vulpecula*, *Sminthopsis crassicaudata*, *Erinaceus
  europaeus*, and the mouse/rat surfaces ("Gosh 1997" is a CAT paper, not the possum). Candidates
  are the not-to-scale summary schematics in the cited reviews (Krubitzer 1995 TiNS; Krubitzer &
  Huffman 2000).
- **⚠️ Systematic low bias in the traced surfaces.** Where independent whole-hemisphere values
  exist, Finlay's tracings of small-mammal/marsupial maps run far LOW: galago 383 vs Collins
  2010's directly flattened hemispheres 1,849–2,261; possum 208 vs Brodmann 1,547; hedgehog 107 vs
  575; opossum 270 vs 804; mouse 51 vs Mota 148 / Brodmann 205. This is what tracing a
  mapped-region-only mount or a schematic figure would produce. Marmoset (910 vs Chaplin MRI 963)
  and macaque (vs F&VE) look sound; owl monkey is the lone HIGH outlier (5,486 vs Collins 2,036 /
  Mota 2,214). **The Trichosurus conflict flagged in `__merging_cortical_areas` is therefore not a
  one-off typo but one instance of this method-level bias — an owner decision is pending on
  whether Finlay's surface column should be demoted/excluded for non-primates in the merge.**
