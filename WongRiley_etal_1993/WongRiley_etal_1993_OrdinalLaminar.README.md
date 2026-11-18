# WongRiley_etal_1993_OrdinalLaminar

**Item name** `WongRiley_etal_1993_OrdinalLaminar` · **Item number** `Ordinal Laminar` · **Item encoded** `10.1017%2Fs0952523800003217_OrdinalLaminar` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `WongRiley_etal_1993_OrdinalLaminar_registry_row.xlsx`.

Wong-Riley, M. T. T., Hevner, R. F., Cutlan, R., Earnest, M., Egan, R., Frost, J., & Nguyen, T. (1993). Cytochrome oxidase in the human visual cortex: Distribution in the developing and the adult brain. *Visual Neuroscience*, 10(1), 41–58. <https://doi.org/10.1017/S0952523800003217>

**Item full original title:** Ordinal laminar cytochrome-oxidase statements for human V1 (fetal zones, birth, day 24, 4 months, adult), V2 and extrastriate occipital cortex (Results pp. 42–49; Fig. 1 and Fig. 4 legends). Constructed statement table.

## Source

PDF in this folder: `Wong-Riley-1993-Cytochrome oxidase in the huma.pdf` (Cambridge UP scan with OCR layer, 18 pages = journal pp. 41–58). DOI verified for the sibling Text item on 2026-11-18. No table, no densitometric plot; the only CO numbers are percent differences (Text item).

## What this item is — and is not

**These are ordinal readings of the authors' own words, not measurements.** The paper gives no optical density for any cortical layer. Each row is one printed qualitative statement about cytochrome-oxidase (CO) reactivity of a layer, laminar compartment or area; `state` is our coding of the printed adjective (the verbatim clause is kept in `printed_wording`); `state_score` (1–7) and `ordinal_rank` (1 = darkest, dense rank within species × area × subfield × condition) are **derived from those adjectives** and imply no interval scale. Relative statements ("less reactive than the clusters") carry the comparison in `comparison_target` and are not ranked. Restatements of an already-rowed layer and groups with a single rankable statement get no rank (`rank_scope`). Schema: the `Preuss_etal_1999` statement-row convention (`row, row_type, taxon_as_printed, taxon_in_methods, species_as_published, Species, taxon_level, cortical_area, layer, marker, feature, trait, state, value_low, value_high, unit, n_individuals, state_basis, printed_wording, source_locator, observation_level, data_role, note`) plus `subfield, compartment, condition, comparison_target, state_score, ordinal_rank, rank_scope, source`.

Coding rules (fixed in the build script, never extended silently): darkest/highest = 7; dark, relatively dark, particularly high = 6; moderate-to-dark = 5; moderate = 4; light-to-moderate (printed "low-to-moderate", "lightly or moderately", "light-to-moderately") = 3; light, relatively low = 2; pale, relatively pale, least reactive, lightest = 1. Printed "high" / "CO-rich" / "specifically heightened" are coded dark; the printed word is always in `printed_wording`.

## What was rowed

55 statement rows, all human: fetal occipital zones at 26 weeks (Fig. 1 legend p. 42 and Results p. 44 — the legend calls the cortical plate 'dark', the text 'moderately reactive'; both rows kept), V1 at birth (2 cases), postnatal day 24, 4 months and adult (24 cases), V2 at birth and adult, and the extrastriate occipital cortex of pp. 49 (areas anterior to V2: layers III and IV high but continuous; VI moderate; V less reactive; anteriormost cortex lightest). Trait mix: 39 absolute laminar states, 10 relative (puff/interpuff, IVcα/IVcβ, V/VI), 6 presence/absence (IVa band, puffs). Greek sublayer subscripts were read from the page image (the OCR layer drops them). The percent OD differences IVcα vs IVcβ are NOT repeated here; they are the quantified rows of `WongRiley_etal_1993_Text` (rows 27, 36, 61), cross-referenced in `note`.

## Pipeline

```
Source (PDF)
  -> WongRiley_etal_1993_OrdinalLaminar_snapshot.R   writes the frozen CONSTRUCTED snapshot (hand-typed statement block)
  -> WongRiley_etal_1993_OrdinalLaminar_snapshot.csv   FROZEN: 56 rows x 20 cols (header + 55 statements)
  -> WongRiley_etal_1993_OrdinalLaminar.R   vocabulary check + species key + trait codes + state_score + ordinal_rank
  -> WongRiley_etal_1993_OrdinalLaminar.csv   55 rows x 31 cols  ("use this")
  -> __Public/comparative-data/10.1017%2Fs0952523800003217_OrdinalLaminar.tsv   (written by the build once registered)
  -> reference_tables/WongRiley_etal_1993_OrdinalLaminar_definitions.csv
```

## Who read the statements, when, and how it was checked

Hand transcription (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from the PDF text layer, with laminar adjectives, layer labels and every number checked on page renders (pages listed in the snapshot script header). The build script was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stops, as expected, at `Expected one registered item row for WongRiley_etal_1993_OrdinalLaminar` because the item is not yet registered (the analysis CSV is written before that point). Vocabulary check: every `state_as_read` is in the fixed vocabulary and every relative state has a comparison target (the build stops otherwise).

## Ordinal ranking (compact; derived from the adjectives)

**Adult V1 (n = 24; Results pp. 44–45). Relative rows not in the table: puffs darker than interpuffs (II/III); IVcα less reactive than IVcβ (5–14 % lower OD, quantified in `WongRiley_etal_1993_Text` row 61); IVb blends with interpuff areas; IVa not demonstrable by CO:**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | IVc | whole layer | darkest | 1 | Results, p. 45 |
| adult | IVcβ | lower half to three-fourths | darkest | 1 | Results, p. 45 |
| adult | VI | whole layer | moderate-to-dark | 2 | Results, p. 45 |
| adult | V | whole layer | light-to-moderate | 3 | Results, p. 45 |
| adult | I | whole layer | light | 4 | Results, p. 44 |

**V1 at birth (n = 2; p. 44):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| at birth (2 and 3 days) | IVc | whole layer (dense band) | dark | 1 | Results, p. 44 |
| at birth (2 and 3 days) | VI | whole layer (especially upper half) | moderate | 2 | Results, p. 44 |
| at birth (2 and 3 days) | V | whole layer | light-to-moderate | 3 | Results, p. 44 |
| at birth (2 and 3 days) | III | whole layer | light-to-moderate | 3 | Results, p. 44 |
| at birth (2 and 3 days) | II | whole layer | light-to-moderate | 3 | Results, p. 44 |
| at birth (2 and 3 days) | I | whole layer | light-to-moderate | 3 | Results, p. 44 |
| at birth (2 and 3 days) | IVb | whole layer | light | 4 | Results, p. 44 |
| at birth (2 and 3 days) | I | inner third | least reactive | 5 | Results, p. 44 |

**V1 at 4 months (n = 1; p. 44):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| fourth postnatal month | VI | whole layer | moderate-to-dark | 1 | Results, p. 44 |
| fourth postnatal month | I | whole layer | light | 2 | Results, p. 44 |
| fourth postnatal month | IVb | whole layer | light | 2 | Results, p. 44 |
| fourth postnatal month | V | whole layer | light | 2 | Results, p. 44 |

**Adult V2 (pp. 47, 49):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| adult | lower II to mid IV | globular zones (islands within stripes) | dark | 1 | Results, p. 47 |
| adult | III and IV | globular zones | dark | 1 | Results, p. 49 |
| adult | III | band (background to globular zones) | moderate | 2 | Results, p. 47 |

Postnatal-day-24, fetal-zone (26 weeks), neonatal-V2 and extrastriate rows are in the CSV; most of those groups have one or two rankable statements.

## Species names

All rows are the authors' own human material ('human' → *Homo sapiens*, key rows for this folder added with the Text item). `n_individuals` per stage from Methods p. 42: 24 adults, 2 newborns, 1 fetus, 1 day-24 infant, 1 four-month infant.

## Use

Adult V1 laminar frame for pairing with BigBrain / receptor strata (ordinal only): IVc darkest (lower half to three-fourths of IVcβ the darkest; IVcα less than IVcβ) > VI moderate-to-dark > V light-to-moderate > I light; II/III = puffs darker than interpuffs; IVb blends with interpuffs; IVa not CO-distinct in human (contrast macaque). Use `WongRiley_etal_1993_Text` for the only numbers (IVcα/IVcβ 0.86–0.95) and the laminar thicknesses.

## Data role

**primary** throughout (the authors' own observations on their own material).

## Unresolved / not captured

- V2 stripes: the paper says they 'were not always clearly demarcated into alternating thin and thick stripes'; no thin/thick-stripe CO states are printed, so none are rowed.
- Adult IVb has no absolute adjective (it 'blends in with interpuff areas'); rowed as relative only.
- Fig. 7 and Fig. 10 schematics (stippled, no scale) were not digitised; they would only duplicate the text statements.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside the cited pages, read a sample of rows against the sentences, confirm the adjective coding, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
