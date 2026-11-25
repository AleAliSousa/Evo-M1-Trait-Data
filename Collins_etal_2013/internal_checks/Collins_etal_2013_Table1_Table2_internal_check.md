# Collins et al. 2013: Table 1 versus Table 2 internal check

Checked 2026-11-24 from the source PDF (printed pages 807 and 810, PDF pages 3 and 6) and the registered `Collins_etal_2013_Table1.csv`. All values are per hemisphere. This note is a **within-paper** check and belongs with the Collins 2013 item.

Table 2 calls its last columns the percent of cortical gray-matter mass and neurons represented by V1. Dividing the displayed Table 1 V1 species means by its displayed `GM` species means gives:

| Species | V1/GM mass from Table 1 | Table 2 mass % | V1/GM neurons from Table 1 | Table 2 neuron % |
|---|---:|---:|---:|---:|
| *Callithrix jacchus* | 0.297/2.042 = 14.54% | 14.5% | 38.86/120.33 = 32.29% | 35.6% |
| *Otolemur garnettii* | 0.310/2.556 = 12.13% | 12.1% | 36.56/88.50 = 41.31% | 45.1% |
| *Aotus trivirgatus* | 0.520/3.698 = 14.06% | 14.1% | 62.08/200.32 = 30.99% | 35.1% |
| *Macaca mulatta* | 1.880/21.430 = 8.77% | 8.8% | 213.76/687.96 = 31.07% | 31.1% |
| *Papio cynocephalus* | 5.632/36.334 = 15.50% | 11.3% | 394.19/1420.34 = 27.76% | 32.8% |

Thus displayed Table 1 reconstructs all V1/GM mass percentages except *Papio*, and only the *M. mulatta* V1/GM neuron percentage. These deviations exceed printed rounding. Table 2's other ratios (for example macaque and baboon V1/brain mass and V1/brain neurons) reconstruct from Table 1 to printed precision, localizing the issue to the GM reference columns.

## Possible gray-neuron denominator, not confirmed

[Herculano-Houzel et al. 2008](https://pmc.ncbi.nlm.nih.gov/articles/PMC2527956/) supplied most of Table 1's `GM` references. It states that its cortical neuron number combined gray- and white-matter neurons (7–18% in white matter), even while describing the mass as gray matter. If the printed Table 2 V1/GM neuron percentages used *gray-only* neuron denominators, the implied denominators are:

| Species | V1 neurons / printed Table 2 fraction | Percent lower than Table 1 GM neuron reference |
|---|---:|---:|
| *Callithrix* | 38.86/0.356 = 109.16M | 9.3% |
| *Otolemur* | 36.56/0.451 = 81.06M | 8.4% |
| *Aotus* | 62.08/0.351 = 176.87M | 11.7% |
| *Papio* | 394.19/0.328 = 1201.80M | 15.4% |

Those differences fall within the previously reported 7–18% white-matter-neuron share. This is a **plausible inference**, not a demonstrated reconstruction: the paper does not publish the individual gray-only denominators for these species in Tables 1–2. It also does not explain the *Papio* V1/GM **mass** difference (11.3% printed versus 15.5% from Table 1). Its macaque GM pair (21.430 g, 687.96M) is not in HH2008 Table 1, which has no *M. mulatta* row; its exact earlier source remains to be traced in the between-paper check.

Do not silently replace Table 1's imported GM references or Table 2's published percentages. Preserve each as printed, mark Table 2 percentages as not all reconstructible from displayed Table 1 means, and use direct Table 1 arithmetic when a fraction from those displayed values is required.
