# Heffner, Koay & Heffner (2020) — Figure 3

**Source paper.** Heffner, R. S., Koay, G., & Heffner, H. E. (2020). Hearing and sound localization in Cottontail rabbits, *Sylvilagus floridanus*. *Journal of Comparative Physiology A*, 206(4), 543–552. https://doi.org/10.1007/s00359-020-01424-8

**The item is a figure.** Figure 3 (journal p. 548) plots **high-frequency hearing limit at 60 dB SPL** (kHz) against **functional interaural distance** (µs), both log axes, for *n* = 74 species in the regression plus 3 subterranean species excluded from it. The paper prints no comparative table. Fourth Route-A sensory source folder; same variable pair as `Koay_etal_1998/` Figure 6, twenty-two years later.

## Two very different kinds of value in this paper

| | what it is | use it? |
| --- | --- | --- |
| **Cottontail rabbit values** (`reference_tables/…_cottontail_values_from_text.csv`) | the paper's **own measurements**, stated numerically in the running text | **yes — this is the mergeable primary data** |
| **Figure 3 comparative points** (`Heffner_etal_2020_Figure3.csv`) | ~79 markers compiled from earlier literature, **with no per-point references anywhere in the paper** | provenance only — **never merge** |

**Fig. 3 carries no reference key.** Unlike `Koay_etal_1998` Fig. 6, whose caption names an audiogram source for every point, this caption gives only the symbol scheme. Its comparative points are therefore unattributed compiled values: recorded here for completeness and comparison, but they fail the repo's "no value without a traceable source" rule and are excluded from any merge.

## ⚠️ The paper contradicts itself on the Cottontail's high-frequency limit

- **Abstract:** "their hearing ranged from 300 Hz to **32 kHz**, a span of 7.5 octaves"
- **Results and Discussion (twice):** "their hearing range extends from 300 Hz to **56 kHz**"

**56 kHz is correct**, on three independent grounds: it is the value stated in the Results; R. Heffner confirmed it by email to the Bath curators (recorded in the compilation's comment field); and the paper's own "7.5 octaves" is arithmetic proof — log₂(56000/300) = **7.54**, whereas log₂(32000/300) = 6.74. The abstract's 32 kHz is a typo. Documented in the values table with the quoted text and the location of each statement.

## Files in this folder

| file | what it is |
| --- | --- |
| `Heffner-2020-Hearing and sound localization in.pdf` | the publication (born-digital) |
| `Heffner_etal_2020_Figure3_extract.py` | reproducible **vector** extraction: marker paths + axis ticks → calibrated values |
| `Heffner_etal_2020_Figure3_snapshot.csv` | frozen snapshot: 79 markers, calibrated values + raw geometry audit columns |
| `Heffner_etal_2020_Figure3_assign.py` | label→marker assignment + independent validation against Koay 1998 |
| `Heffner_etal_2020_Figure3.R` | canonical reformat: snapshot + assignment → CSV + public TSV |
| `Heffner_etal_2020_Figure3_mirror.py` | offline Python mirror that generated the committed outputs — delete after verifying the `.R` |
| `Heffner_etal_2020_Figure3.csv` | analysis-ready data (79 rows) |
| `reference_tables/…_cottontail_values_from_text.csv` | **the paper's own primary values**, quoted verbatim with locations |
| `reference_tables/…_label_assignment.csv` | per-label assignment, method, confidence, and the Koay cross-check |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |
| `comparison/…_vs_SensoryData_compiled.csv` | audit vs the compiled sensory check fixture |

Public TSV: `__Public/comparative-data/10.1007%2Fs00359-020-01424-8_Figure3.tsv`.

## How the values were extracted (and how precise they are)

The PDF is born-digital, so Figure 3 is **vector art**: each marker is a drawn path with exact page coordinates and each axis tick is a line. The extractor reads both, least-squares fits log₁₀(value) against page coordinate for each axis, and converts marker centres to data units. **Max relative residual: 0.57 % (x), 0.54 % (y)** — random, not systematic, so that is the figure's own tick-placement precision and the floor on achievable accuracy. This is reproducible and far better than pixel digitisation, but the values remain figure-derived (`value_origin = digitised_from_figure` on every row).

79 markers were recovered (the caption's 74 regression species + 3 subterranean + a small number of overlapping/duplicated draws in the dense cluster). Each marker is drawn twice in the PDF (fill path + outline path); those pairs are merged.

## Species identity — deliberately incomplete

Only **42 of the ~79 points carry a printed label**, and most sit in a dense cluster with crossing leader lines. Assignment is therefore kept as a separate, auditable step with an explicit confidence column, and **34 markers** end up carrying a label:

- **17 `validated_vs_Koay1998`** — assignment independently confirmed: the same species' point in `Koay_etal_1998_Figure6.csv` (independent digitisation, same two variables) agrees within 12 %.
- **5 `CHECK_value_differs_from_Koay1998`** — assignment looks right but the value moved between 1998 and 2020. Some are real revisions: **killer whale** is ~34 kHz in Koay 1998 (Hall & Johnson 1972) but ~101 kHz here, and **chimpanzee** 23 → 28 kHz. Treat as "the 2020 figure used newer data", not as extraction error.
- **15 `AMBIGUOUS_marker_claimed_by_2_labels`** and **5 unvalidated** — the geometry cannot decide. Flagged, never guessed.

**The confidence flags earned their keep on the two rabbits.** Leader-line geometry put *Cottontail* on a marker reading 51.7 kHz and *Domestic rabbit* on 57.6 kHz; both tripped the Koay cross-check. The caption states rabbits are drawn as **stars**, and the figure contains exactly two star paths, which pins both — and both then confirm independently: the Cottontail star reads **56.17 kHz against the paper's own text value of 56 kHz**, and the other reads 247.7 µs / 49.5 kHz against Koay's *Oryctolagus* 252.9 / 49.2. Those two assignments are marked `star_symbol_caption` in the assignment table. The Cottontail agreement is also an end-to-end check on the whole extraction chain: an independent route to a value the text states in print, correct to 0.3 %.

Two printed blocks are not species: "Prairie dogs" is a group heading over the two prairie-dog labels, and "Pig"/"Reindeer" are adjacent labels the character clustering merges.

## Comparison vs the compiled check fixture

The compilation cites this paper exactly once — Cottontail high-frequency limit, 56 kHz — and it **agrees exactly** with the paper's text value, including the curator's note about the internal conflict. Nothing else in the compilation depends on this paper.

## Notes for the database

- Figures 4 (histogram of low-frequency limits) and 5 (distribution of localization thresholds) are distributions, not per-species scatter; Fig. 5 could yield localization thresholds if wanted, but with the same no-reference problem.
- For *Sylvilagus floridanus* a merge should take the **text** values (300 Hz, 56 kHz, 7.5 octaves, MAA 27.6°), not the Fig. 3 marker.
- `species_key.csv` token: `HeffnerEtAl2020`.
