# Reep et al. 2007 - Table 1

## Source

Reep, R. L., Finlay, B. L., & Darlington, R. B. (2007). The limbic system in
mammalian brain evolution. *Brain, Behavior and Evolution, 70*(1), 57-70.
https://doi.org/10.1159/000101491

Registry item: **Table 1**. Public file:
`10.1159%2F000101491_Table1.tsv`.

## Dataset

Table 1 reports shrinkage-corrected volumes (mm3) of 11 brain components for
29 University of Wisconsin Comparative Mammalian Brain Collection specimens:
18 Carnivora, 5 Artiodactyla, 1 Perissodactyla, 4 Xenarthra, and 1 Sirenia.
The source specimen number, common name, scientific name, order, and family are
retained. The source scientific name is never silently modernized.

The 11 measures are medulla, cerebellum, mesencephalon, diencephalon, striatum,
septum, amygdala, paleocortex, hippocampus, schizocortex, and isocortex.

## Measurement and laterality

Brains were perfusion-fixed, celloidin-embedded, sectioned coronally at 25-40
micrometres, and sampled using 8-10 sections per region. Areas from one side were
integrated through the rostrocaudal extent, corrected for histological shrinkage,
then multiplied by two to publish whole-brain regional volumes. The left side was
measured for the Steller sea lion (*Eumetopias jubatus*); the right side was used
for the other 28 specimens. These are therefore published bilateral estimates,
not two independently measured hemispheres.

## Definition cautions

- Reep includes globus pallidus in striatum, while Stephan et al. 1981 included
  it in diencephalon. Merge mappings must keep those two Reep measures
  definition-specific rather than treating them as identical to the Stephan
  diencephalon and striatum variables.
- Amygdala is reported separately but is also included in paleocortex. Those two
  columns overlap and must not be summed as independent components.
- Isocortex includes gray and white matter plus claustrum; lateral ventricles are
  excluded. It is mapped to the project's neocortex volume term.

## Pipeline and QA

`Reep_etal_2007_Table1_snapshot.xlsx` is the frozen transcription of printed
Table 1. `Reep_etal_2007_Table1.R` reads that snapshot and writes the analysis
CSV plus the DOI-coded public TSV. The folder copy of the PDF is preserved as
`Reep_etal_2007.pdf`.

Automated checks require 29 unique species, 29 unique specimen numbers, no
missing values, and positive values in all 319 volume cells. The transcription
was independently compared against text extracted from both printed table pages;
all 319 cells matched. Two source comma-placement anomalies were normalized as
thousands separators: Olingo isocortex `90,30.72` -> 9,030.72 and Florida manatee
diencephalon `1,2847.68` -> 12,847.68.

