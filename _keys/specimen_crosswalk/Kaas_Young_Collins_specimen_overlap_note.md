# Specimen note: Young 2013, Collins 2010/2016, and Turner 2016

## Purpose

This note records which brains in Young et al. 2013 (*Cell and neuron densities in the primary motor
cortex of primates*) recur in the Kaas laboratory's Collins and Turner papers. It prevents regional M1
measurements and whole-cortex measurements from being interpreted as independent animals.

## Current conclusions

- The Young 2013 and Collins 2016 chimpanzees are a **high-confidence probable match** to
  `KAAS-PAN-11_38`. They must not be counted as independent by default. Young omits the age, sex,
  accession and case number required to promote its row from `probable` to `matched`.
- Young's *Papio cynocephalus anubis* is probable case `09-27`, the same normal baboon as Collins
  2010 and Young 2013b. Young's *P. hamadryas anubis* is probable case `11-31`, the normal Texas
  baboon in Young 2013b and Turner 2016.
- Young's owl monkey is probable Collins case `07-78`.
- Young's three-galago mean **partially overlaps** Collins: case `08-07` is one of the three, but the
  other two are unresolved. The published mean cannot be decomposed into specimen values.
- Young's squirrel monkey and two *Macaca nemestrina* have no known Collins 2010 overlap.

## Evidence chain

### 1. Young 2013 Methods fixes the source institutions

Young states that the galagos, owl monkey and squirrel monkey came from Vanderbilt; the two
*Macaca nemestrina* and one *Papio cynocephalus anubis* came from Washington NPRC; and the
additional *P. hamadryas anubis* and single chimpanzee came from Texas Biomedical. These Methods
assignments supersede an older curator-added `Specimen` column in the frozen Table 1 snapshot.

### 2. Numerical fingerprints identify reused animals

| Young row | Young evidence | Matching source | Identity treatment |
|---|---|---|---|
| *Otolemur garnettii*, n=3 | one animal 1,850 mm2, 2.87 g | Collins 08-07: 1,849.493 mm2, 2.8721 g | partial overlap; probable member |
| *Aotus nancymaae*, n=1 | about 2,000 mm2, 5.21 g | Collins 07-78: 2,036.45 mm2, 5.2155 g | probable |
| *P. cynocephalus anubis* | total cortex 18,577 mm2 | Collins/Young 2013b case 09-27 | probable in Young; matched where case is printed |
| *P. hamadryas anubis* | total cortex 23,400 mm2 | Young 2013b/Turner case 11-31 | probable in Young; matched where case is printed |

### 3. Chimpanzee evidence

Young reports one Kaas/Vanderbilt chimpanzee from Texas Biomedical, with M1 area 2,700 mm2 and 27%
neurons. Collins 2016 reports one 53-year-old female Texas Biomedical chimpanzee in the same research
program, with M1 area 2,497 mm2 and 27% neurons. The area difference is compatible with different M1
dissection boundaries. Turner 2016 describes the program's chimpanzee in the singular while explicitly
enumerating multiple baboons. Turner and Miller dissertation evidence independently anchors the
Collins animal as case `11_38` across right and left hemispheres.

This is strong evidence for one chimpanzee, but Young does not print an accession, case number, age or
sex. Under the specimen-crosswalk schema, its link therefore remains `probable`, not `matched`.

## Data treatment

1. Keep Young's M1 traits regional. Do not pool them with whole-cortex surface or cell counts.
2. Do not use Young and Collins chimpanzee rows as independent biological replicates.
3. Exclude case 09-27 when Collins 2010 already contributes that animal.
4. Keep case 11-31 as the distinct normal baboon where a nonduplicate normal case is needed.
5. Treat the Young galago row as a partially overlapping three-animal mean. Do not subtract or
   reconstruct an individual contribution from the published mean.

## Remaining uncertainty

An explicit Young-era case number, accession, or specimen log would be needed to promote the Young
chimpanzee, owl monkey, and case-less baboon links from `probable` to `matched`, and to identify the
other two galagos in Young's three-animal mean.

## Sources

- Collins et al. 2010, Dataset S1 and article.
- Young, Collins & Kaas 2013, M1 article.
- Young et al. 2013b, epileptic-baboon article and Supporting Information.
- Collins et al. 2016, chimpanzee article.
- Turner et al. 2016, macaque article and comparative baboon/chimpanzee discussion.
- Turner and Miller 2017 dissertations, as registered in `specimen_source_registry.csv`.
