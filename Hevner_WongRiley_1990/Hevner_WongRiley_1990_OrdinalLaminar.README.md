# Hevner_WongRiley_1990_OrdinalLaminar

**2026-11-26 public completion.** The item now has an exact row in the main `__ReadMe.xlsx` registry. Running `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 Rscript --vanilla Hevner_WongRiley_1990/Hevner_WongRiley_1990_OrdinalLaminar.R` wrote `__Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_OrdinalLaminar.tsv`. Earlier “not registered” or “public TSV pending” statements below describe the initial build date. Human source review remains as separately recorded.


**Item name** `Hevner_WongRiley_1990_OrdinalLaminar` · **Item number** `Ordinal Laminar` · **Item encoded** `10.1523%2FJNEUROSCI.10-04-01331.1990_OrdinalLaminar` (derived; the registry is the authority) — NOT yet registered in `__ReadMe.xlsx`; registry row to paste: `Hevner_WongRiley_1990_OrdinalLaminar_registry_row.xlsx`.

Hevner, R. F., & Wong-Riley, M. T. T. (1990). Regulation of cytochrome oxidase protein levels by functional activity in the macaque monkey visual system. *Journal of Neuroscience*, 10(4), 1331–1340. <https://doi.org/10.1523/JNEUROSCI.10-04-01331.1990>

**Item full original title:** Ordinal cytochrome-oxidase statements for macaque LGN laminae and striate-cortex layers, normal and after monocular TTX (Results pp. 1333–1335; Fig. 3, 5, 6 legends). Constructed statement table.

## Source

PDF in this folder: `Hevner-1990-Regulation of cytochrome oxidase p.pdf` (SfN scan with OCR layer, 10 pages = journal pp. 1331–1340). DOI as registered. Table 1 (densitometry) is the sibling item `Hevner_WongRiley_1990_Table1`.

## What this item is — and is not

**These are ordinal readings of the authors' own words, not measurements.** The paper gives no optical density for any cortical layer. Each row is one printed qualitative statement about cytochrome-oxidase (CO) reactivity of a layer, laminar compartment or area; `state` is our coding of the printed adjective (the verbatim clause is kept in `printed_wording`); `state_score` (1–7) and `ordinal_rank` (1 = darkest, dense rank within species × area × subfield × condition) are **derived from those adjectives** and imply no interval scale. Relative statements ("less reactive than the clusters") carry the comparison in `comparison_target` and are not ranked. Restatements of an already-rowed layer and groups with a single rankable statement get no rank (`rank_scope`). Schema: the `Preuss_etal_1999` statement-row convention (`row, row_type, taxon_as_printed, taxon_in_methods, species_as_published, Species, taxon_level, cortical_area, layer, marker, feature, trait, state, value_low, value_high, unit, n_individuals, state_basis, printed_wording, source_locator, observation_level, data_role, note`) plus `subfield, compartment, condition, comparison_target, state_score, ordinal_rank, rank_scope, source`.

Coding rules (fixed in the build script, never extended silently): darkest/highest = 7; dark, relatively dark, particularly high = 6; moderate-to-dark = 5; moderate = 4; light-to-moderate (printed "low-to-moderate", "lightly or moderately", "light-to-moderately") = 3; light, relatively low = 2; pale, relatively pale, least reactive, lightest = 1. Printed "high" / "CO-rich" / "specifically heightened" are coded dark; the printed word is always in `printed_wording`.

## What was rowed

19 statement rows: 8 normal (LGN 4, V1 4) and 11 TTX rows (`condition = "TTX (3-4 weeks, left eye)"`, feature `CO change after TTX` → trait `CO_change_TTX`, or Fig. 5/6-legend pattern rows). Retina statements (p. 1333) are outside the V1 / LGN scope and were not rowed. Layer labels as printed (Arabic 2, 3, 4A/4a, 4C, 5, 6; LGN laminae 1–6).

## Pipeline

```
Source (PDF)
  -> Hevner_WongRiley_1990_OrdinalLaminar_snapshot.R   writes the frozen CONSTRUCTED snapshot (hand-typed statement block)
  -> Hevner_WongRiley_1990_OrdinalLaminar_snapshot.csv   FROZEN: 20 rows x 20 cols (header + 19 statements)
  -> Hevner_WongRiley_1990_OrdinalLaminar.R   vocabulary check + species key + trait codes + state_score + ordinal_rank
  -> Hevner_WongRiley_1990_OrdinalLaminar.csv   19 rows x 31 cols  ("use this")
  -> __Public/comparative-data/10.1523%2FJNEUROSCI.10-04-01331.1990_OrdinalLaminar.tsv   (written by the build once registered)
  -> reference_tables/Hevner_WongRiley_1990_OrdinalLaminar_definitions.csv
```

## Who read the statements, when, and how it was checked

Hand transcription (HOWTO method 5) by an AI assistant (Claude) on 2026-11-18 from the PDF text layer, with laminar adjectives, layer labels and every number checked on page renders (pages listed in the snapshot script header). The build script was run with `Rscript` (conda env `evom1-r`, `LC_ALL=en_US.UTF-8`) from a clean session on 2026-11-18; it stops, as expected, at `Expected one registered item row for Hevner_WongRiley_1990_OrdinalLaminar` because the item is not yet registered (the analysis CSV is written before that point). Vocabulary check: every `state_as_read` is in the fixed vocabulary and every relative state has a comparison target (the build stops otherwise).

## Ordinal ranking (compact; derived from the adjectives)

**Normal macaque LGN (n = 7 *M. fascicularis*; Results p. 1333, Fig. 3 legend p. 1334):**

| condition | layer | compartment | state (as read) | rank (1 = darkest) | where |
|---|---|---|---|---|---|
| normal | lamina 6 | superior-medial portion | darkest | 1 | Fig. 3 legend, p. 1334 |
| normal | cellular laminae 1-6 | neuropil and many cell bodies | dark | 2 | Results, p. 1333 |
| normal | lamina 6 | superior and medial portions | relatively dark | 2 | Results, p. 1333 |
| normal | lamina 3 | whole lamina | relatively dark | 2 | Results, p. 1333 |

**Normal macaque V1 — NO complete laminar ranking is printed.** The Results (p. 1334) state only: puffs in layers 2 and 3 are zones of high CO activity relative to interpuffs (quantified in `Hevner_WongRiley_1990_Table1`: 1.32× histochemically, 1.19× immunohistochemically); layer 4A has a broken, beaded band in cross-section and a reticulated pattern tangentially; layers 1 and 6 were *sometimes* more intensely stained immunohistochemically than histochemically (not consistent; layer 1 possibly an edge effect). These are rowed as relative / presence statements; `ordinal_rank` is NA for all normal V1 rows.

**TTX (3–4 weeks, left eye; n = 3):** LGN laminae 2, 3, 5 (ipsilateral LGN) reduced / 'relatively pale'; V1 treated-eye columns reduced in layers 2, 3, 4A, 5, 6 and *most* in 4C (light columns 0.80× dark columns, Table 1); ocular-dominance stripes visible in 4C and 6 (Fig. 5 legend); layer 4a broken into columns and alternating rows of small pale / large dark puffs (Fig. 6 legend).

## Species names

Methods (p. 1331): 7 normal *Macaca fascicularis*; 3 TTX-treated (2 *M. radiata*, 1 *M. fascicularis*) — the TTX rows use the existing pooled key label `TTX-treated macaques (2 M. radiata, 1 M. fascicularis)` → `Macaca sp.`; key rows for this folder already exist (Table1 / Text items).

## Use

For a macaque V1 laminar CO ranking this paper is NOT the source: it gives puff > interpuff and the beaded 4A band only; the quantitative puff/interpuff and TTX column ratios are in `Hevner_WongRiley_1990_Table1`. The LGN rows give: cellular laminae dark; lamina 3 and the superior-medial part of lamina 6 relatively dark (the latter 'darkest'). TTX rows give the direction of change per layer (most in 4C).

## Data role

**primary** throughout (the authors' own observations on their own material).

## Unresolved / not captured

- The task expected a full macaque V1 layer ranking; the paper does not print one (see above). A macaque V1 laminar ranking would need another source (e.g. Horton 1984; Kennedy et al. 1985, not in this folder).
- LGN laminae 1, 4, 6 after TTX are only described as 'driven by the contralateral retina'; no state is printed for them in the ipsilateral LGN figure, so none is rowed.
- Retina (inner plexiform sublaminae a/b etc.) not rowed.

## Human visual check of snapshot

Pending human RA. A person still needs to lay the snapshot beside the cited pages, read a sample of rows against the sentences, confirm the adjective coding, and record `DDMMYYYY_initials` in the `Human visual check of snapshot` column.
