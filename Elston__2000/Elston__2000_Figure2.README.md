# Elston__2000_Figure2

Elston, G. N. (2000). Pyramidal cells of the frontal lobe: all the more spinous to think with. *The
Journal of Neuroscience*, 20:RC95 (1-4). doi:10.1523/JNEUROSCI.20-18-j0002.2000

**Data location.** The paper publishes no numbered data table. Figure 2 (panels A-C: basal dendritic
field area, branching complexity via Sholl analysis, and spine density, by cortical area) is a set of
plots and frequency-distribution histograms with no printed per-point values or axis data — so this is
a constructed snapshot, named for its locus (the Results section text that accompanies Figure 2), not a
digitization of the figure itself.

## Files in this folder
| file | what it is |
| --- | --- |
| `Elston__2000_Figure2_snapshot.csv` | summary statistics stated as explicit numbers in the Results text |
| `Elston__2000_Figure2.csv` | same data, written to the standard item-name file |
| `Elston__2000_Figure2.R` | script that writes the snapshot to the public TSV |
| `Elston__2000_Figure2.README.md` | this file |

## What we built
- **Source:** the article's own Results section (page 2 of the PDF), which states specific summary
  statistics in running prose for the basal dendritic fields of layer III pyramidal neurons.
- **Method.** Manual transcription of the stated sentences by an AI assistant on 2026-09-25 — no
  figure digitization was performed.
- **Sentences the values come from** (paraphrased locations, not verbatim quotation): area 10 (n=29)
  basal dendritic field mean ± SD; areas 11 (n=37) and 12 (n=21) likewise; the maximum branch count at
  75 μm from the soma, stated only for areas 10 and 11 as the range extremes ("ranged from 32.35 ± 4.41
  in area 10 to 33.51 ± 5.51 in area 11"); and the estimated total spine count for the "average" neuron
  in each of areas 10, 11, 12, V1, 7a, and TE.
- **Build:** `Elston__2000_Figure2.R` reads the snapshot and writes:
  - `Elston__2000_Figure2.csv` (6 rows x 7 columns)
  - `__Public/comparative-data/10.1523%2FJNEUROSCI.20-18-j0002.2000_Figure2.tsv` (public, DOI-encoded,
    added now — matches the registry's `Item encoded`)
- **Definitions:** `reference_tables/Elston__2000_Figure2_definitions.csv` (added now).

## What was NOT included in the snapshot
- The continuous Sholl branching curves, per-distance spine-density curves, and the bimodal/trimodal
  frequency-distribution histograms shown graphically in Figure 2 — these have no printed per-point
  values or axis scale in the text, and digitizing the plot image was not attempted (consistent with
  this repo's policy for `Fritsches_etal_2005_Fig2` and the `Halley_Krubitzer_2019_Figure1` documented
  skip: only values stated as numbers in the source are transcribed).
- Basal dendritic field area means/SDs for V1, 7a, and TE — the text reports these areas were
  significantly smaller than areas 10/11/12 (p < 0.01) but states no numeric mean for the comparison
  areas themselves, so those cells are left blank rather than inferred from the figure.
- Area 12's peak Sholl branch count — only the two range extremes (areas 10 and 11) are given a
  specific number in text ("ranged from ... to ...").

## Data role
**Primary (areas 10, 11, 12 — this paper's own intracellular-injection data) + secondary (V1, 7a, TE
— restated from Elston and Rosa 1997, 1998a and Elston et al. 1999a for direct comparison).**

## Checks
- 6 rows (one per cortical area), matching every explicit number stated in the Results section text;
  no value was read from the figure or inferred.

## Extraction / build record
Transcribed directly from the article PDF's Results section (page 2) by Microsoft Copilot (AI
assistant) on 2026-09-25. The CSV, R script, public TSV, README, and definitions file were all built
in this pass. No prior build existed for this item.
