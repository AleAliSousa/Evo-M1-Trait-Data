# Specimen note: FSU green monkey ("Cercopithecus aethiops", 1,370 g / 36.54 g)

## Purpose

Tracks one anonymous single animal that appears under three source tables and one relay chain: Glendenning & Masterton 1998 Table 1, Nudo et al. 1995 Table 1, and, through Boddy 2012 and DeCasien 2017, the comparative brain-mass compilations. It records what can and cannot be said about the animal so the value is not pooled as an independent species mean. Canonical id: `FSU-GREENMONKEY-1370G` (4 crosswalk rows).

## Current working conclusion

**One animal, one measurement, reported repeatedly.** Body 1,370 g and brain 36.54 g (printed 36,540 mg in Nudo). The animal is a single non-adult-sized specimen whose brain mass is far below every comparable vervet or green monkey record. It should not enter a species mean for *Chlorocebus aethiops* or *C. sabaeus*.

- **Specimen name / accession / sex / age:** none printed.
- **Identity link:** `probable`, not `matched`. Values are identical across papers and all trace to the Masterton lab at Florida State University (FSU), but no accession, house name or specimen code closes the link.
- **Taxon:** unresolved. Both papers print *Cercopithecus aethiops*; Nudo prints the common name "Green monkey", which is *C. sabaeus* in modern usage; 1990s *C. aethiops* was sensu lato (grivet + vervet + green monkey). `resolved_taxon` is left blank and no taxon-concept row has been added.

## Evidence chain

1. **Glendenning & Masterton 1998, Table 1 (animal 30).** Source `FSU`, body 1,370 g, brain 36.54 g. The Results text describing Table 1 says the body and brain weight columns give values recorded at time of sacrifice and dissection; the table footnote says only that body weights were weighed at time of dissection (estimates are in parentheses). Neither says whether brain weight is fresh or post-fixation. One animal per species; the paper names this as a measurement-error source. Sex, age and histology of this animal are not given. The paper's shrinkage discussion concerns the in-vitro nuclear volumes; whether it also affects the weight columns is neither shown nor excluded.
2. **Nudo, Sutherland & Masterton 1995, Table 1.** Same body and brain values, plus neocortical area 3,616 mm2. The paper says these measurements were described in Nudo & Masterton 1989/1990b and retabulated for reference (secondary report). Brain was weighed after perfusion and 30% sucrose immersion until the tissue sank.
3. **Boddy et al. 2012 database v2.** Relays the Glendenning row with Age class "Adult", a database label that conflicts with the 1,370 g body mass. Table S1 species means exclude Glendenning entirely (0 of 630 reference strings cite it), giving 64.1333 g from Bronson 1981 and Warncke 1908.
4. **DeCasien et al. 2017.** Relays the Boddy row (source Glendenning 1998, N=1, Adult). It is carried unfiltered into the brain-mass merge.

## Overlap of the two FSU tables

Of 15 species in both Nudo Table 1 and Glendenning Table 1, 10 have identical body and brain values and 5 differ (galago, squirrel, hedgehog body, raccoon, tree shrew). The tables therefore share part of the same FSU material; Nudo may have used different animals for the rest. See `Green_monkey_FSU_glendenning_vs_nudo.csv` in this folder.

## How the value compares

36.54 g is 0.57 of the *C. sabaeus* median in DeCasien 2017 (13 specimens, range 50.0-81.5 g, median 64.0 g). The smallest juveniles in that set still have 50 g brains. Body mass alone makes a juvenile plausible. It does not explain the brain mass. The cause (age, partial brain, preparation or recording) is **unresolved**. The same FSU lineage gives primate brain masses 27-43% below literature medians in Nudo Table 1, and neocortical areas below other sources, so absolute values from this lineage are not validated.

## Recommended treatment

- Keep the row out of species-mean pooling for brain mass, body mass and surface area; keep within-paper comparisons (same animals, same method).
- **Enforced in the merges (2026-10-26)** by value-veto files: `__merging_brain_mass/brain_mass_value_flags.csv` (Nudo 24 rows; DeCasien/Glendenning 5 rows) and `__merging_body_ecology/body_ecology_value_flags.csv` (Nudo 24 rows). The reason is owner policy (unvalidated, treated as non-shrinkage-corrected), not demonstrated shrinkage.
- Record it once. Boddy, DeCasien and Nudo rows are relays or retabulations of the Glendenning/FSU measurement, not independent sources.
- Do not rewrite the printed taxon to *C. sabaeus* or *C. aethiops* on the strength of either label.

## Hard rule

This is a specimen measurement, so it may be reassigned if a taxon is later established, always with `taxon_conflict` surfaced. It must never be averaged into a pooled concept as if it were an adult species mean.

## Unresolved

- Age, sex, accession and histological treatment of the animal (check Nudo & Masterton 1989/1990b, not in the repo).
- Which paper first reported the weights: Glendenning (1998) is the earliest printed table found here, but Nudo & Masterton 1989/1990b predate it and are not checked.
- Taxon concept for the sensu lato "green monkey" label.

## Sources cited

Glendenning & Masterton 1998 (Brain Behav Evol 51:59-89); Nudo, Sutherland & Masterton 1995 (J Comp Neurol 358:181-205); Boddy et al. 2012; DeCasien et al. 2017; Bronson 1981; Warncke 1908.
