# Herculano-Houzel et al. 2007 - Table 1 (cellular composition of the brain: tree shrew + 6 primates)

Herculano-Houzel S, Collins CE, Wong P, Kaas JH (2007). *Cellular scaling rules for primate brains.* PNAS 104(9):3562-3567. Table 1 (journal p.3563; PDF p.2). Isotropic fractionator.

## Source -> snapshot -> CSV
`HerculanoHouzel_etal_2007.pdf` (EndNote 5901); text layer scrambled, so the **constructed snapshot** `..._Table1_snapshot.csv` was read by eye from a 2.2x render. Kept as printed: "mean ± SD" strings, thousands commas, `n.a.`, the footer 'Variation' row. `..._Table1.R` splits mean/SD, converts x10^6 to counts (neurons -> `N.n`, non-neurons -> `O.n`, WholeBrain; brain/body `Mass.g`), drops the Variation row (7 species). TSV skipped until the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks (all pass)
- Variation row reproduced from the data: body 3900/361 = 10.8; brain 87.346/7.780 = 11.2; neurons 6376.16/635.80 = 10.0; non-neurons 7162.90/590.74 = 12.1.
- Text cross-checks: Callithrix 636 M neurons, Macaque 6.4 billion; body 10.8-fold, brain 11.2-fold, NN 10.0-fold, NNN 12.1-fold.

## Tables not built
- SI Table 2 and other supporting-information tables (cortex/cerebellum/rest-of-brain fractions): not in the PDF (online supplement only); not inspected.
- No other numbered tables; the paper's other numerical content is in figures and regression equations (statistics, skipped).

## Lewitus 2014 (ref 85) comparability
Table 1 holds the comparable quantities: brain mass, body mass, total neurons (`N.n`) and non-neuronal cells (`O.n`). Lewitus's copy is secondary; prefer this table.

## Overlap with repo (checked against `__merging_cellcounts/cellcounts_long.csv`)
The same species are already held from `HerculanoHouzel_etal_2015_Table5` (WholeBrain_N.n, _O.n, _Mass.g, Body_Mass.g):
- Identical: Tupaia glis, Callithrix jacchus, Otolemur garnettii, Aotus trivirgatus, Cebus (as Sapajus apella), all four columns; Saimiri brain mass and neurons.
- DIFFERENT: *Saimiri sciureus* non-neurons 2,075.03 M here vs 2,073,030,000 in 2015 Table5 (one digit; verify against the 2015 PDF; the printed 2007 value is kept); Saimiri body mass n.a. here vs 859 g in 2015.
- DIFFERENT: *Macaca* brain 87.346 g / body 3900 g / neurons 6376 M / non-neurons 7163 M here (labelled "Macaque monkey", Fig. 1 'Macaca fascicularis') vs 2015 Table5 *M. fascicularis* 46.162 g / 5700 g / 3439 M / 3154 M. Different specimens or a species relabel; needs the owner's ruling before wiring (do not pool).
- No existing HerculanoHouzel_etal_2007 rows in the merge, so this item adds no new species except confirming the above; treat as a secondary-duplicate source for 5 species.

## Caveats
Species printed as vernacular names; binomials come from the Fig. 1 caption only. Brain mass "whole brain" olfactory-bulb convention not stated in the table.

## Macaca / Saimiri overlap with HerculanoHouzel_etal_2015_Table5 — resolved 2026-10-21
- The "Macaque monkey" row here is **rhesus, *Macaca mulatta*** per the Methods (rhesus monkeys, n = 2, Vanderbilt Department of Psychology colony, young adults); the Fig. 1 label reads *M. fascicularis*, which conflicts with the Methods. The 2015 Table 5 row for *Macaca mulatta* (brain 87.346 g, body 3900 g, neurons 6,376,160,000, other cells 7,162,900,000) is **identical** to this row, so the two items agree on this animal.
- The 46.162 g row in the 2015 table is a different record: *M. fascicularis*, body 5700 g, source Gabi et al. 2010. It is not this paper's macaque, so it is not a disagreement and not a half-brain artefact.
- Hemisphere check: the Methods state that for ALL animals only one hemisphere was processed and the result multiplied by 2, so the printed brain masses and totals are whole-brain. The 87 g vs 46 g gap is therefore not a one-hemisphere issue; neurons differ by 0.54x and other cells by 0.44x, not a constant half.
- *Saimiri sciureus*: non-neuronal total prints 2,075.03 M here and 2,073.03 M in the 2015 table; neurons (3,246.43 M) and brain mass (30.216 g) agree. Neither value can be confirmed from the text (the paper's percent-neuron figure, 61%, fits both). Kept as printed; candidate erratum. Body mass is n.a. here (859 g in the 2015 table).
- Specimens: n per species from the Methods (galago 3, marmoset 3, owl monkey 2, squirrel monkey 2, rhesus 2, tree shrew 2, capuchin 1 adult from the Federal University of Rio de Janeiro colony). Individual-animal values are in SI Table 2 (online only); obtaining that SI would let each animal be registered as a specimen.
