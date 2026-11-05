# Specimen note: Munger et al. 2022 Table 1 (area 9 astrocytes)

## Purpose

Register the 25 individuals of Munger et al. (2022), *J Comp Neurol*, doi:10.1002/cne.25387,
Table 1, and record which of them are probably the same animals as individuals printed in other
publications held in this repository. Table 1 prints species, age (years), sex and brain weight (g)
for each individual. It prints **no accession, house name or studbook number**, so every
cross-paper link below rests on public attributes only.

## Sources of the brains (Materials and methods 2.1)

| species | individuals | source collection |
|---|---:|---|
| *Macaca nemestrina* | 6 (3 M, 3 F; 3-16 y) | Washington National Primate Research Center |
| *Papio anubis* | 6 (4 M, 2 F; 5-10 y) | Southwest National Primate Research Center |
| *Pan troglodytes* | 7 (3 M, 4 F; 24-51 y) | National Chimpanzee Brain Resource |
| *Homo sapiens* | 6 (3 M, 3 F; 37-44 y) | NIH NeuroBioBank Brain and Tissue Repository |

The four collection strings are new in `_keys/collection_registry.csv` (groups `WANPRC`, `SNPRC`,
`NCBR`, `NIH_NEUROBIOBANK`). Whether `NCBR` should share a group with `GAAP` or `YERKES` is left to
the owner (see the YN01-92 link below).

## Method

Every public table in the repository with individual rows for these four species was scanned on
2026-11-04 (16 tables, including Bauernfeind 2013, Stimpson 2015, Hrvoj-Mihic 2026, Karl 2024,
Sherwood 2020, Barger 2007/2012, Bianchi 2012, Schenker 2005, Young 2013, Turner 2016). A pair was
considered when species and sex agree and age differs by at most one year. It is called
**probable** only when the brain weight also agrees to the printed precision (0.1 g). Brain weight
at necropsy is a strong fingerprint within one species and collection network, but it is not an
accession, so no link here is `matched`.

## Results

Six of the seven chimpanzees carry an informative brain weight; five of those six have a probable
counterpart elsewhere. No macaque, baboon or human has one.

| Munger row | individual | probable same animal | evidence |
|---:|---|---|---|
| 13 | *Pan*, M, 24 y, 375.5 g | Stimpson et al. 2015 Table S1, subject 5 | M, 24 y, 375.5 g |
| 14 | *Pan*, F, 35 y, 302.2 g | Hrvoj-Mihic et al. 2026 Dataset S1, PTF93 | F, 35.38 y, 302.15 g |
| 15 | *Pan*, F, 40 y, 371.5 g | Hrvoj-Mihic et al. 2026 Dataset S1, PTF125 | F, 40.49 y, 371.50 g |
| 16 | *Pan*, M, 40 y, 341.2 g | Bauernfeind et al. 2013 Table 1, **YN01-92a** (GAAP); Stimpson et al. 2015 Table S1, subject 1 | M, 40 y, 341.2 g in all three |
| 19 | *Pan*, F, 51 y, 387.7 g | Hrvoj-Mihic et al. 2026 Dataset S1, PTF173 | F, 50.50 y, 387.70 g |

- Row 16 joins the existing crosswalk identity `BAUERNFEIND-PANTRO-YN01-92`. It is the only Munger
  individual with a printed accession anywhere in the repository (YN01-92, a GAAP/Yerkes-style
  necropsy number; the trailing `a` is a Bauernfeind footnote letter).
- The other four links get source-local identities (`MUNGER2022-T1-13`, `-14`, `-15`, `-19`), shared
  by a crosswalk row for the partner paper.
- Ages in Hrvoj-Mihic are decimal years; Munger's whole years are consistent with rounding to the
  nearest year (50.50 -> 51, 40.49 -> 40).

## Not linked, and why

- **Row 18** (*Pan*, F, 43 y, 356.8 g): two Hrvoj-Mihic codes print F and 356.80 g, PTF141 (43.0 y)
  and PTF143 (43.31 y). Either could be this animal, or the source holds one animal twice. Left as
  `Munger2022-only`, with both candidates in the audit file.
- **Row 17** (*Pan*, M, 41 y, `384**`): the caption says the value is the species average from
  Robson & Wood (2008), so it is not this animal's weight and cannot fingerprint it.
- **Row 9** (*Papio*, M, 7 y): Karl et al. 2024 prints a male olive baboon of 7 y, but its brain mass
  (174.3 g) is the Sherwood 2020 species mean, so weight cannot decide.
- **Humans, macaques, other baboons**: no public table matches on species, sex, age and brain weight.

## Consumer rules

1. These links are identity candidates. Never count the paired rows as independent biological
   replicates, and never average a Munger value with a partner-paper value as if two animals.
2. The five linked chimpanzees all come from one author network (Sherwood, Hof, Raghanti, Hopkins).
   That makes reuse likely, but it does not replace an accession; a shared NCBR or Yerkes number
   would upgrade a link to `matched`.
3. Different measurements on one animal (insula volume, amygdala serotonergic axons, brain weight
   series, area 9 astrocytes) can be combined at the specimen level through `canonical_specimen`.

## Files

- `munger_2022_provenance_audit.csv`: one row per Munger individual and evidence row (27 rows).
- `specimen_crosswalk.csv`: 25 Munger rows plus 5 partner rows (Stimpson x2, Hrvoj-Mihic x3).
- `specimen_source_registry.csv`: `PUB_MUNGER_ETAL_2022_TABLE1`, `PUB_STIMPSON_ETAL_2015_TABLES1`,
  `PUB_HRVOJMIHIC_ETAL_2026_SD1`.
- The comparison with the Allen Institute M1 cross-species transcriptomic study uses unpublished
  specimen metadata, so it lives in the restricted repository:
  `restricted_checks/_cross_table/Munger_etal_2022_vs_M1_cross_species_study/`.
