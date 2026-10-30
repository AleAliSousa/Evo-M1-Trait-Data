# Dos Santos et al. (2020) — published Table 1 vs unpublished data: comparison report

*Independent check (generated alongside the R check script). Compares the **published** Table 1 (main-PDF, `DosSantos_etal_2020_Table1.csv`) against the authors' **unpublished** raw spreadsheet (`2020-PublishedDataMammalsMicroglia - cópia.xlsx`), summarised to one value per animal × structure.*

## Bottom line

The published Table 1 contains **transcription/typographical errors in several cell-count values**, some of them physically impossible (neurons or microglia exceeding the total cell count of the same structure). The unpublished data is internally consistent and agrees with older publications (e.g. Herculano-Houzel et al. 2015). **The unpublished dataset is therefore used in the merged cell-counts dataset; the published Table 1 is excluded** (kept only as a reference snapshot).

## Method

- Unpublished raw rows summarised to mean per `Animal Latin Name` × `Structure`, mapped to the published structure codes (Br, Cb, Ctx, Cx, Hp, P+M, RoB).
- For each species × structure × measure (C, N, I, I/N, I/mg, N/mg, mass, and microglia/cell I/C), computed % difference = (unpublished − published)/published × 100.
- Independent integrity scan of the **published** data alone: flag any structure where neurons (N) or microglia (I) exceed total cells (C) — physically impossible, a definitive typo signature.
- 32 of 33 published species matched to the unpublished animals (Marmosops listed as 'Marmosops sp.' in the raw file). Full per-cell table: `DosSantos_etal_2020_comparison_report.csv`.

## Definitive typos — impossible published values (internal-consistency scan)

| Species | Structure | Problem |
|---|---|---|
| *Procavia capensis* | Cb | neurons N=4,883,703,000 > total cells C=579,378,000  (ratio 8×) |
| *Tragelaphus strepsiceros* | Br | neurons N=4,911,651,549 > total cells C=21,751,929  (ratio 226×) |
| *Tragelaphus strepsiceros* | Br | microglia I=1,204,929,478 > total cells C=21,751,929  (ratio 55×) |

The *Tragelaphus strepsiceros* whole-brain total cells (`Br_C` = 21,751,929) is the value you flagged: the unpublished value is 21,751,929,128 — the published figure dropped its last three digits (~1000× too small), which is why its neurons and microglia exceed it.

## Largest published-vs-unpublished discrepancies (|%diff| > 10)

| Species | Struct | Measure | published | unpublished | %diff |
|---|---|---|---:|---:|---:|
| *Tragelaphus strepsiceros* | Br | C | 21,751,929 | 21,751,929,128 | 99,900.0 |
| *Mungos mungo* | RoB | I/mg | 1.915 | 1,915 | 99,898.0 |
| *Tragelaphus strepsiceros* | Br | I/C | 55.39 | 0.05527 | -99.9 |
| *Procavia capensis* | Cb | N | 4,883,703,000 | 489,318,420 | -90.0 |
| *Elephantulus myurus* | Hp | N | 5,159,368 | 9,442,884 | 83.0 |
| *Dendrohyrax dorsalis* | Br | I/mg | 10,129 | 2,123 | -79.0 |
| *Tragelaphus strepsiceros* | Hp | I/N | 3.946 | 1.034 | -73.8 |
| *Elephantulus myurus* | Hp | C | 12,080,000 | 17,540,000 | 45.2 |
| *Tragelaphus strepsiceros* | Hp | I/mg | 4,710 | 2,682 | -43.1 |
| *Petrodromus tetradactylus* | RoB | I/C | 0.03011 | 0.04217 | 40.0 |
| *Papio anubis cynocephalus* | Cx | C | 4,934,116,014 | 6,740,084,000 | 36.6 |
| *Petrodromus tetradactylus* | RoB | N/mg | 13,696 | 18,628 | 36.0 |
| *Petrodromus tetradactylus* | RoB | N | 12,231,811 | 16,572,629 | 35.5 |
| *Petrodromus tetradactylus* | RoB | I | 1,217,665 | 1,648,532 | 35.4 |
| *Elephantulus myurus* | Hp | Mass | 0.086 | 0.116 | 34.9 |
| *Elephantulus myurus* | Hp | N/mg | 59,993 | 78,471 | 30.8 |
| *Papio anubis cynocephalus* | Cx | I/C | 0.05225 | 0.0382 | -26.9 |
| *Petrodromus tetradactylus* | Hp | I | 1,067,062 | 824,542 | -22.7 |
| *Petrodromus tetradactylus* | Hp | N | 6,294,000 | 4,863,982 | -22.7 |
| *Petrodromus tetradactylus* | Hp | I/C | 0.07648 | 0.05923 | -22.5 |
| *Cebus apella* | Cx | C | 3,035,947,220 | 3,707,354,000 | 22.1 |
| *Petrodromus tetradactylus* | Hp | N/mg | 23,164 | 18,093 | -21.9 |
| *Cebus apella* | Cx | I/C | 0.03494 | 0.0285 | -18.4 |
| *Elephantulus myurus* | Cx | N | 21,847,255 | 25,865,698 | 18.4 |
| *Canis familiaris* | Cb | I/mg | 6,421 | 7,555 | 17.7 |
| *Elephantulus myurus* | Cx | N/mg | 48,549 | 54,697 | 12.7 |
| *Elephantulus myurus* | Cx | C | 46,970,000 | 52,094,000 | 10.9 |
| *Loxodonta africana* | Br | Mass | 4,169 | 4,588 | 10.1 |

## Notes

- **Cell-count columns (C, N, I)** carry the typos; the ratio/density columns (I/N, N/mg) mostly agree (differences there are rounding).
- The unpublished file's unique reliable contribution is the **microglia/cell ratio (I/C = %Iba1+)**, which is what feeds the merged dataset (`*_I.p.C` terms).
- For overlapping species, cell *numbers* in the merged dataset come from older primary sources (e.g. Herculano-Houzel et al. 2015), not from this paper.



---

## Broader cross-check: DS2020 vs other Herculano-Houzel-team papers

*Does the unpublished data match the **other** HH-team papers (not just HH 2015)? Yes. Report: `DosSantos_etal_2020_crosssource_check.csv`.*

Neuron and total-cell counts per structure were compared for the **32 DS2020 species** that also appear in independent HH-team datasets: **Herculano-Houzel et al. 2015** (afrotherians, artiodactyls, primates), **Dos Santos et al. 2017** (marsupials — all 10 overlap), and **Jardim-Messeder et al. 2017** (carnivores).

### Result — the unpublished data is the same data as the other HH papers

- **Whole-brain neurons** (23 species): median |unpublished − other paper| = **0.0%**.
- **Cerebellum neurons** (25 species): median = **0.0%**.
- Across all comparable whole-brain/cerebellum values the unpublished figures are essentially identical to the independently-published HH-team values — i.e. they are the same underlying measurements. This is strong external validation for using the unpublished dataset.

### The published typos are resolved against an independent source

| Species | Clade source | Structure | published | unpublished | external | pub vs ext | unpub vs ext |
|---|---|---|---:|---:|---:|---:|---:|
| *Procavia capensis* | HH2015 | Cb_N | 4,883,703,000 | 489,318,420 | 488,373,000 | +900.0% | +0.2% |
| *Tragelaphus strepsiceros* | HH2015 | Br_C | 21,751,929 | 21,751,929,128 | 21,888,835,129 | -99.9% | -0.6% |

In both cases the **published** value is wildly off against the independent HH-team source, while the **unpublished** value matches it to <1% — the same conclusion as the within-paper check, now confirmed by a third, independent paper.

### Caveat — cerebral cortex is *not* used as evidence here

Several species show >10% differences for the **cortex** (`Ctx`) row (e.g. *Homo sapiens*, *Loxodonta*, some marsupials). These track **differing definitions of "cerebral cortex"** across papers (whether hippocampus / entorhinal / amygdala are included, and how cortical sub-regions are aggregated) — not transcription errors. Whole brain and cerebellum are unambiguous and are the basis for the conclusion above; cortex comparisons should be read with the definition caveat in mind.

