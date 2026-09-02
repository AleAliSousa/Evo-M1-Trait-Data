# Halley & Krubitzer 2019 - Figure 1 source audit

## Source

Halley, A. C., & Krubitzer, L. (2019). Not all cortical expansions are the same:
the coevolution of the neocortex and the dorsal thalamus in mammals. *Current
Opinion in Neurobiology, 56*, 78-86.
https://doi.org/10.1016/j.conb.2018.12.003

## Disposition: DOCUMENTED SKIP

Figure 1 is a secondary log-log visualization, not a new measurement table. The
source audit reconstructs all 39 plotted thalamus/neocortex pairs from primary
tables already held in this repository:

- 37 species are the 37 complete thalamus + neocortex rows in Stephan et al. 1981.
- Capybara and guinea pig are Campos & Welker 1976 Table 1.

`Halley_Krubitzer_2019_Figure1_source_audit.R` regenerates the 39-row audit and
checks all seven ratios printed beneath Figure 1. Because every plotted value is
already represented by an upstream source, digitizing the plot would create a
rounded duplicate measurement team. No analysis dataset or public TSV is created.

Reference 22 (Bininda-Emonds et al. 2007) supplies the mammal phylogeny, not brain
measurements.

## Source and label problems found

1. The Figure 1 caption says the data are from references 15 and 22, but the two
   rodent points necessarily come from Campos & Welker 1976 (reference 31), as
   confirmed by the exact capybara ratio and the plotted component values.
2. The tree and numerical ratio identify the pygmy marmoset: figure label
   *Callithrix pygmaea*, upstream label *Cebuella pygmaea*, ratio `2535 / 190 =
   13.3`. The caption instead names *Callithrix jacchus* and says its thalamus was
   estimated. The upstream *C. pygmaea* thalamus is directly reported. The audit
   retains this contradiction and does not invent a corrected figure point.
3. Several figure labels modernize, shorten, or change the upstream taxon labels.
   `Halley_Krubitzer_2019_Figure1_source_map.csv` preserves both sides; it does not
   treat the relabeled rows as new specimens.

The PDF is retained as review evidence, and the source map/audit prevent this
figure from being rediscovered and digitized as a supposed data gap.
