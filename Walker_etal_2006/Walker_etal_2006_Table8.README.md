# Walker, Burger, Wagner & Von Rueden 2006 — Table 8 (observed vs regression-predicted brain ratios: humans; chimpanzee for comparison)

Walker R, Burger O, Wagner J, Von Rueden CR (2006). *Evolution of brain size and juvenile periods in primates.* J Hum Evol 51(5):480-489. doi:10.1016/j.jhevol.2006.06.002

## Source -> snapshot
`Walker_etal_2006.pdf` (EndNote record 2701), PDF p.7 (journal p.486). The text layer is usable but loses minus signs and en-dashes, so `Walker_etal_2006_Table8_snapshot.csv` is transcribed from the render: 5 brain ratios x (Pan troglodytes; Homo sapiens Predicted; Homo sapiens Observed), ranges kept as printed with an en dash.

## Build
`Walker_etal_2006_Table8.R` -> `..._Table8.csv`, LONG, 15 rows (5 ratios x 3 columns); ranges split into value_min / value_max (equal for point values).

## Fidelity checks
Text layer vs render agree on all 15 cells (2.4-3.2, 4.5-6.2, 3.1, 5.9, 31.8; 2.2, 3.5, 1.4, 2.3, 13.7; 3.1-4.1, 5.3-9.3, 4.0, 9.1, 58.5). Text: "the human nonvisual neocortex ratios and the executive-to-brainstem ratio are three to four times larger than expected": 4.0/1.4 = 2.9, 9.1/2.3 = 4.0, 58.5/13.7 = 4.3 — consistent.

## Caveats
- Only 2 species and 5 derived ratios; the **human Predicted** column is a regression output (tables 3-7 at 65 kg, 120 yr, group size 150), not data. Observed ratios come from Reader & MacDonald 2003, who used Stephan et al. 1970/1981/1988 volumes (secondary; prefer the Stephan-based primary sources already in the merge).
- Chimpanzee cells carry no Predicted/Observed label; treated as observed. Whether the ranges are alternative volume estimates is not stated.

## Lewitus 2014 cross-reference (juvenile periods)
Lewitus et al. 2014 cites Walker 2006 as the dataset-wide source for primate **juvenile periods** (age at first reproduction). **No table in this paper prints those species values.** The paper's analysis used a 67-species database (age at first reproduction in months, brain weight, max life span, body size, home range, % fruit, group size) compiled from Barton 1999, Harvey et al. 1987, Smith & Jungers 1997, Kappeler & Pereira 2003 and Kaplan et al. 2003 (data at http://www.unm.edu/~hkaplan/pnas/primatedatabase.xls — not in the PDF, not retrievable from this folder). Age at first reproduction appears in the paper only as the dependent variable of Table 1 (regression statistics). So the comparable quantity (juvenile period per species) must be taken from that external Kaplan et al. 2003 database or the secondary sources above, not from this paper.

## RA check still to do
Side-by-side read of the render against the snapshot (5 rows x 3 value columns).
