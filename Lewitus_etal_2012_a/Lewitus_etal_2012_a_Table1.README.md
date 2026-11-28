# Lewitus et al. 2012 - Table 1 (species list by taxonomic classification, with n individuals)

Lewitus, Sherwood & Hof (2012). Cellular signatures in the primary visual cortex of phylogeny and placentation. Brain Struct Funct 217(2):531-547. doi:10.1007/s00429-011-0338-5

## Source -> snapshot
PDF p.5 (journal p.535). Transcribed from a render; the table is printed as two side-by-side panels (Primates left, Carnivora + Shrew-to-Whale right). The snapshot now keeps those two three-column panels adjacent, including group/subgroup blanks, caption and two footnotes. Footnote letter is kept as `^a`; sample size as `(n)`. The R reader stacks the left panel before the right for analysis.

## Fidelity checks
- 71 rows = the "71 mammalian species" of the Abstract (Primates 37, Carnivora 22, SW 12).
- Every Table 1 species also appears in Table 2 (set comparison); Table 2 has one extra (Manis gigantea).
- 31 species carry footnote a (Eutheria group): matches Results ("31 species"); the Methods text says 32 - a discrepancy inside the paper, kept as printed.

## Caveats
- This is a species list with sample sizes, not measurements. Per-species cell densities and glia:neuron ratios are NOT printed in the paper (see main README).
- Stereology study: do not pool derived densities with isotropic-fractionator counts.

## Build
Run `Rscript Lewitus_etal_2012_a/Lewitus_etal_2012_a_Table1.R` from the
repository root. The 71-row analysis CSV matched the prior version cell for
cell after the 2026-11-27 layout correction. TSV skipped until the registry
row is pasted into `__ReadMe.xlsx`. Independent human source comparison is
separate.
