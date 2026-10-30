# Armstrong 1979 — why the volume rows are not wired yet

Disposition: **HOLD** (`SOURCE_DISPOSITION_REGISTER.md`). Written 2026-09-28, answers added the same
day from the paper's Materials and Methods (`Armstrong__1979.pdf`) and the item's own specimen
crosswalk.

## The seven questions, answered

**1. Was it corrected for shrinkage using brain mass? — No. It was not corrected at all.**

> "The thalami in this study came from different laboratories. Different preparative techniques can
> produce variable amounts of tissue shrinkage (Frontera '58; Stephan et al. '70). **An assumption of
> this study is that shrinkage within the thalamus is approximately the same for all regions**
> (Stephan et al. '70). Comparisons that rely on ratios of the …"

Armstrong cites Stephan et al. 1970 for the assumption and then deliberately does *not* adopt their
fresh-volume correction. There is no brain-mass-based correction, no fresh-volume scaling, and no
per-specimen shrinkage factor. Her defence is **relative**: she assumes shrinkage is uniform *within*
the thalamus and therefore analyses **ratios to total thalamic volume**. The absolute mm³ are
preparation-sensitive by the author's own account, and the item README says so too ("raw volumes
remain preparation-sensitive"). The merge's Stephan/Frahm/Baron values are shrinkage-corrected to
fresh volume. **These are not the same quantity.**

**2. How was it measured?** Boundaries determined at 15–21.6×; each section projected through a
flat-field planar optical system onto paper and the nuclei traced; area by **compensating polar
planimeter**, with **two tracings at two arm positions** as a reliability check against irregular
nuclear outlines; volume from area × section spacing (Bauchot 1963). Celloidin (and some paraffin)
embedding, 30–40 µm sections depending on specimen, cresyl violet, with a parallel myelin series.
Cell-count sampling interval varied by specimen (every 15th to every 36th section). Neuronal density
was **not** corrected for neuronal nuclear size, and the perikaryal-volume summaries are described by
the author as tentative.

**3. Was it duplicated for both sides? — No, and it must not be.**

> "The volume of a nucleus from each specimen was calculated from the measurement of **only one
> hemisphere**."

Nothing was doubled. So an unsuffixed standardized term would be wrong: these are `_unilateral`
values in the sense of `laterality_known.csv`, `doubling = none`, and any both-sides partner would be
this project's ×2 estimate (`estimated_bilateral_from_unilateral`), not the author's.

**4. Are sample sizes given? — Yes, and the paper's own count is misleading for volumes.**

> "The thalami of hominoids were studied quantitatively in specimens from **one gorilla, one
> chimpanzee, two gibbons, and three humans**."

But for *volumes* specifically: the third human brain (`Homo s.-c`) "could not [be used to] measure
nuclear volumes" — it supplied cell sizes and counts only. And the two `Hylobates` sp. rows are
**two hemispheres of one animal**, not two animals:

> "Thalami from the two hemispheres of one brain, from a gibbon (*Hylobates*) of unknown species and
> weight, were from the department of anatomy at Thomas Jefferson Medical College."

So the volume N per taxon is: *Gorilla gorilla* 1, *Pan troglodytes* 1, *Hylobates lar* 1,
*Hylobates* sp. 1 (two hemisphere measurements), **Homo sapiens 2**. Note that the `n` column in the
public TSV is the **neuron-counting sample size**, not the number of animals — do not read it as N.

**5. Is the structure truly the same as the other LGN data? — No, on two counts.**

- **Dorsal only.** The item README records "LGB means **dorsal** LGB". The Stephan school separates
  the two: `Baron_etal_1996_Table30` prints `corpus_geniculatum_laterale_mm3`,
  `cgl_dorsal_part_mm3` *and* `cgl_ventral_part_mm3`, so the merge's
  `Corpus_geniculatum_laterale_Vol.mm3` is the dorsal **+** ventral total.
- **Includes the fibrous laminae.** "The measurements for LGB included the fibrous laminae between
  the cellular regions" — i.e. interlaminar white matter is inside Armstrong's boundary.

`VB` additionally "excludes the lightly stained small-celled VPI region", and has no counterpart in
the merge at all.

Together with (1) and (3) this fully accounts for the 5–6× gap in the table below: roughly ×2 for one
hemisphere, ×1.2–1.4 for dorsal-only versus the dorsal+ventral total, and ×2–2.5 for uncorrected
histological shrinkage. **The gap is explained, not mysterious — which is exactly why the values
cannot be mapped to the canonical LGN term.**

**6. Are there any cases where it is probably the same specimens? — Yes. One near-certain, one
possible.**

| Armstrong specimen | collection | body | brain | merge comparison | verdict |
|---|---|---|---|---|---|
| `H. lar-t` *Hylobates lar* | **Max Planck Institute Frankfurt** | 5.93 kg | **101.9 g** | Stephan et al. 1981 Table III *Hylobates lar*: body 5,700 g, brain **102,000 mg = 102.0 g** | **almost certainly the same brain** — 0.1% apart, and Frankfurt *is* the Stephan/Vogt collection |
| `Pan t.` *Pan troglodytes* | University of Wisconsin | 63.5 kg | **405.5 g** | Stephan 1981 Table III *Pan troglodytes*: brain **405,000 mg = 405.0 g** (body 46.0 kg) | **possible but unproven** — brain 0.1% apart, but a different collection and body mass 38% apart; chimp brains cluster near 400 g, so this may be coincidence |
| `Homo s.-s` / `-t` | Yakovlev Collection | — | 1,890 g (fixed) / 1,200 g (fresh) | Stephan 1981: 1,330 g | no match |
| `Gorilla g.` | Columbia University / Bronx Zoo | 203 kg | 540 g | no *Gorilla* mass in the merge | no overlap known |
| `Hylo.-s` / `-h` | Thomas Jefferson Medical College | unknown | unknown | — | no overlap known |

The *Hylobates lar* case is the important one: it means Armstrong is **partly a re-measurement of a
Tier-1 brain**, not an independent Tier-2 series, and averaging her *H. lar* value against Stephan's
would be counting one animal twice. The Wisconsin *Pan* needs a check against the Bush specimen
workbook (restricted; `Bush_Allman_N_FINDINGS.md`) — Bush's Wisconsin *Pan troglodytes* is
`chimp_63_397`, whole brain 364.14 cm³.

**7. Which collection and location?** Five, all in
`Armstrong__1979/Armstrong__1979_specimen_crosswalk.csv`: Max Planck Institute Frankfurt (*H. lar*,
transverse); University of Wisconsin comparative brain collection (*Pan*, coronal, saline+formalin
perfused); Columbia University / Bronx Zoo (*Gorilla*, coronal, described as a mountain gorilla but
printed *Gorilla gorilla*); Yakovlev Collection (both human volume brains, sagittal and transverse);
Thomas Jefferson Medical College (the *Hylobates* sp. hemispheres, sagittal and horizontal). The
cell-count-only human (`Homo s.-c`) has no stated collection.

## Revised disposition

The HOLD stands, but the reasons are now specific rather than suspicious, and two of the three gates
are **resolved**:

- Gate 1 (definition/basis) — **resolved, and it rules out the canonical term.** Armstrong's LGB is
  one hemisphere, dorsal only, laminae included, and uncorrected for shrinkage. It needs its own
  definition-specific terms, e.g. `Corpus_geniculatum_laterale_dorsal_unilateral_uncorrected_Vol.mm3`,
  and must never pool with `Corpus_geniculatum_laterale_Vol.mm3`.
- Gate 2 (specimen overlap) — **resolved for *H. lar*** (same brain as Stephan 1981 → a
  `shares_specimens_with` edge to `Stephan_collection`, so recency, not averaging), **open for
  *Pan***, clear for the rest.
- Gate 3 (part/whole and repeated rows) — unchanged: `LGB` = `LGBp` + `LGBm`; the two *Hylobates* sp.
  rows are one animal.

What this source is actually worth, once those terms exist: five hominoid taxa with dorsal LGB, LGBp,
LGBm, MGBp and VB — and **VB (ventrobasal complex) is a structure the merge does not have at all**.
That, not the LGN, is the reason to wire it.

Armstrong, E. (1979). *A quantitative comparison of the hominoid thalamus: I. Specific sensory relay
nuclei.* Am J Phys Anthropol 51(3):365–382. Item `Armstrong__1979_Tables1-9`, public TSV
`10.1002%2Fajpa.1330510308_Tables1-9.tsv`, 106 long rows.

The 2026-09-28 registry audit named this item one of two "cheapest real wins" for
`__merging_volumes`, on the grounds that it is already per-specimen and needs no de-averaging. That
is true of its *shape*. It is not true of its *content*. Three gates, and none of them is the
historical-taxonomy problem that holds up Baron 1996.

## What the item contains

Of 106 rows, **46 are `measure == "volume"` with `unit == "mm3"`**; of those, **35 are
`role == "primary"`**. The remaining 11 are literature-comparison values and are excluded outright:

| `source_group` | rows | note |
|---|---|---|
| `Hopf_1965` | 4 | `role = secondary` |
| `Blinkov_Zvorykin_1950` | 4 | `role = secondary`, and MGBp + MGBm rather than MGBp |
| `Solnitzky_1945` | 2 | `role = secondary` |
| `Chacko_1948` | 1 | `role = secondary` |

Primary structures: `LGB`, `LGBp`, `LGBm`, `MGBp`, `VB`. Primary taxa: *Homo sapiens*,
*Pan troglodytes*, *Gorilla gorilla*, *Hylobates lar*, *Hylobates* sp. The other 60 rows are
neuronal density, estimated neuron number and perikaryal volume — those belong to
`__merging_cellcounts`, not here.

## Gate 1 — Armstrong's LGB is 5–6× below the LGN already in the merge

| species | Armstrong LGB (mm³) | `Corpus_geniculatum_laterale_Vol.mm3` in `volumes_long.csv` | ratio | merge sources |
|---|---|---|---|---|
| *Homo sapiens* | 69.1, 78.0 | 373.67 | **5.1–5.4×** | Bush 2004b; de Sousa 2013; Stephan 1984 |
| *Hylobates lar* | 27.1 | 163.73 | **6.0×** | Bush 2004b; de Sousa 2013; Stephan 1984 |
| *Pan troglodytes* | 56.3 | 330.00 | **5.9×** | Bush 2004b; de Sousa 2013; Frahm 1998 |

The gap is far too large for a laterality artefact (that would be 2×) and far too consistent across
three species and three independent merge teams to be specimen variation. Something structural
differs — the delineation (Armstrong's "LGB" may be the laminated principal body only), the
shrinkage correction, or a section-sampling basis. **Until that is established from the paper, the
rows must not be mapped to `Corpus_geniculatum_laterale_Vol.mm3`.** Mapping them there would drag
three well-populated, three-team cells down by a factor of five.

This is the `definition_compatibility` decision of
`__merging_volumes/PLAN__hierarchical_curation.md` §5.3 in its sharpest form, and the merge has no
mechanism that would catch it: the >50% deviation flag fires **only within Tier 1** and only against
the next-most-recent value, so a new Tier-2 team disagreeing by 500% would be averaged in silently.

The same question applies to `MGBp` against `Corpus_geniculatum_mediale_Vol.mm3`, and `VB` has no
counterpart in the merge at all (it would be a genuinely new structure).

## Gate 2 — the specimens may already be in the merge, through two different teams

`collection` on the primary volume rows:

| collection | taxon | overlap risk |
|---|---|---|
| **Max Planck Institute Frankfurt** | *Hylobates lar* (`Hylobates_lar_1`) | **the Stephan / Zilles collection** — the same brains underlie Tier 1 and the `Zilles` team |
| **University of Wisconsin comparative brain collection** | *Pan troglodytes* (`Pan_1`) | **the Bush & Allman collection** — 59 specimens / 55 species, see `Bush_Allman_N_FINDINGS.md` in the restricted repo |
| Yakovlev Collection | *Homo sapiens* (`Homo_volume_1`, `Homo_volume_2`) | Bauernfeind 2013 also draws on Yakovlev-Haleem |
| Columbia University / Bronx Zoo | *Gorilla gorilla* (`Gorilla_1`) | no known overlap |
| Thomas Jefferson Medical College | *Hylobates* sp. (`Hylobates_unknown_1`) | no known overlap |

So Armstrong is **not** an independent Tier-2 series in the way Reep or Kverkova are. Two of its five
specimen sources are collections the merge already draws on, which is the condition that makes
cross-team averaging illegitimate. `_keys/specimen_crosswalk/` is the place to settle it, and it
already holds the Frankfurt and Wisconsin material — but nothing reads it yet, so this has to be done
by hand for now.

## Gate 3 — part/whole and repeated rows

- `LGB` = `LGBp` + `LGBm`. Check: *Homo* `Homo_volume_1` LGBp 57.7 + LGBm 11.5 = 69.2 against a
  printed LGB of 69.1, and the item's own note records exactly this ("printed components sum to
  99.9% and 69.2 mm3 versus the 69.1 mm3 Table 1 total"). Ingesting all three terms is fine as long
  as they are distinct standardized terms and no downstream sum treats them as independent.
- `Hylobates` sp. carries **two rows per structure under one `individual_id`**
  (`Hylobates_unknown_1`): LGB 17.8 and 21.0, MGBp 7.1 and 8.3, VB 41.2 and 37.5. Two hemispheres or
  two measurements of one animal — either way, n = 1 brain, not 2. A blind `mean()` gives the right
  number for the wrong reason; the specimen-aware pooling of
  `PLAN__weighted_averages_rollout.md` gives it for the right one.
- *Homo* has a third `individual_id`, `Homo_combined`, whose note says it "combines mean nuclear
  volume from Homo s.-s and Homo s.-t with density from Homo s.-c" — a derived row, not an
  observation. It is `measure = estimated_neuron_number`, so it does not reach the volume path, but
  do not let it in later.

## What would clear this

1. Read the paper's methods for the LGB delineation and the shrinkage/sampling basis, and compare
   against Stephan 1984 / de Sousa 2013 / Bush 2004b. Either establish that Armstrong measures a
   narrower structure — in which case it gets its own definition-specific term and the 5× gap
   becomes expected rather than alarming — or establish a basis correction.
2. Check the Frankfurt *Hylobates lar* and Wisconsin *Pan troglodytes* specimens against
   `_keys/specimen_crosswalk/` and against the Bush Wisconsin workbook (restricted). If they are
   animals the merge already has, Armstrong is a `shares_specimens_with` edge, not a new team.
3. Decide the team assignment that follows from (2): own Tier-2 team, or folded into
   `Stephan_collection` / `Zilles` / `Bush` as a specimen-sharing group resolved by recency.

Until 1 and 2 are answered, wiring this source would be the Bush-triple-counting mistake with a 5×
scale error on top.
