# HerculanoHouzel_etal_2011_Table1

Herculano-Houzel, S., Ribeiro, P. F. M., Campos, L., da Silva, A. V.,
Torres, L. B., Catania, K. C., & Kaas, J. H. (2011). Updated neuronal
scaling rules for the brains of Glires (rodents/lagomorphs). *Brain,
Behavior and Evolution*, 78(4), 302–314.
https://doi.org/10.1159/000330825 — PMCID PMC3237106 (open access).

Table 1, "Average data for the 11 species of Glires": species means
(± SD) of body mass, brain mass and the numbers of neuronal and
non-neuronal (other) cells in the whole brain (olfactory bulb
excluded), cerebral cortex, cerebellum, rest of brain (RoB) and
olfactory bulb, all measured with the isotropic fractionator. The
printed table has species as columns (vernacular names) and measures
as rows; the averages for mouse, hamster, rat, guinea pig, agouti and
capybara were recalculated by the authors from Herculano-Houzel et al.
(2006) — the 2011 paper is the earliest publication of these values in
this form, and no 2006 dataset exists in Evo-M1.

## Build

1. `HerculanoHouzel_etal_2011_Table1_snapshot.R` captures Table 1 from
   the frozen PMC full text (`fulltext.html` in this folder) into
   `HerculanoHouzel_etal_2011_Table1_snapshot.csv` — printed row
   labels, printed species order and verbatim cell strings
   ("23.3 ± 5.9", "26.88 ± 3.34 × 106", "ca. 500", "n.a."). It refuses
   to overwrite a differing frozen snapshot.
2. `HerculanoHouzel_etal_2011_Table1.R` reads only the snapshot,
   transposes it to one row per species, splits means from SDs,
   converts counts (printed × 10^6) to absolute counts, and writes
   `HerculanoHouzel_etal_2011_Table1.csv` plus the DOI-coded public
   TSV in `__Public/comparative-data/`.

Species mapping (printed header → binomial used in the paper's text):

| Printed | Binomial | Order |
|---|---|---|
| Naked mole-rat | *Heterocephalus glaber* | Rodentia |
| Mouse | *Mus musculus* | Rodentia |
| Hamster | *Mesocricetus auratus* | Rodentia |
| Rat | *Rattus norvegicus* | Rodentia |
| Spiny rat | *Proechimys cayennensis* | Rodentia |
| Guinea pig | *Cavia porcellus* | Rodentia |
| Prairie dog | *Cynomys* sp. | Rodentia |
| Grey squirrel | *Sciurus carolinensis* | Rodentia |
| Rabbit | *Oryctolagus cuniculus* | Lagomorpha |
| Agouti | *Dasyprocta prymnolopha* | Rodentia |
| Capybara | *Hydrochoerus hydrochaeris* | Rodentia |

The paper's text prints the agouti as "Dasyprocta primnolopha" [sic];
the built table uses *Dasyprocta prymnolopha*, the spelling used by
Herculano-Houzel et al. (2015) and the species hub. Measure columns
are named exactly as in the sibling HerculanoHouzel_etal_2015 tables
("Cerebral cortex N, n", "Whole brain Neurons", …) so the item slots
into the isotropic-fractionator merge on the same standardized terms.

## Fidelity checks (run by the build script; see `table_checks`)

31 of 34 checks pass. The printed whole-brain values equal the sum of
the cortical + cerebellar + RoB values within print rounding for all
species except:

- **Prairie dog brain neurons.** The 2011 table prints
  473.94 ± 78.74 × 10^6, but its own parts sum to 437.94 × 10^6 and
  Herculano-Houzel et al. (2015, Table 5) print 437,943,767 with the
  same SD (78,742,230): the 2011 mean is a digit transposition
  (473.94 for 437.94). The built table stays verbatim; the merge
  corrects this one cell in its guarded §3.4d block.
- **Agouti whole-brain counts.** Printed brain neurons
  (795.11 × 10^6) and other cells (951.68 × 10^6) differ from the sum
  of the printed parts by −32.22 and +22.64 × 10^6 respectively —
  identically in the 2015 compilation, so these are the authors'
  reported whole-brain values, not a misprint, and they stand.

**Rabbit cerebellum (the check this item exists to land):** printed
counts 396.67 × 10^6 neurons and 124.58 × 10^6 other cells give
O/N = 0.314 — confirming that the 1.222 printed for this cell in
Herculano-Houzel et al. (2015, Table 2) is that paper's error (it
duplicates its own olfactory-bulb ratio). The 2011 table prints no
ratios, so the merge derives 0.314 from these counts once this item
takes precedence.

## Role in the dataset

This paper is the **primary source** for the Glires rows that
Herculano-Houzel et al. (2015) re-reported in its Tables 1–5: the
2015 tables' own Source columns cite this paper for the naked
mole-rat, spiny rat, prairie dog, grey squirrel and rabbit, and the
2006 paper (recalculated here) for the other six species. In
`__merging_cell_counts_isotropic_fractionator/compiled.R` this item
is therefore pinned above the 2015 tables in the within-team source
precedence (§8.2.H), with the 2015 tables remaining the fallback
wherever this table lacks a cell. Consequences, all verified in the
merge re-run that accompanied this build:

- every shared cell's value becomes the 2011 printed value (the 2015
  tables carry the same data unrounded, so count/mass cells move only
  at print-rounding level);
- densities and O/N ratios, which 2015 prints but 2011 does not, are
  then derived by the merge from the 2011 counts — this is what
  corrects the rabbit cerebellum O/N from 1.222 to 0.314;
- SDs come from this table where it prints them (the rabbit, n = 1,
  and the agouti whole-brain values have none, in either paper).

## Caveats

- Grey squirrel body mass is printed "ca. 500": body weights were not
  recorded for the wild-caught squirrel and prairie dog; the authors
  assumed an average of 500 g for the squirrel. The built table
  carries 500; the snapshot keeps the verbatim string.
- Prairie dog olfactory bulb is printed "n.a." (not analysed) and is
  NA here; the 2015 compilation also has no prairie-dog bulb data.
- Whole brain excludes the olfactory bulb throughout (the paper's
  "remaining areas"/RoB likewise excludes it).
- The paper prints no densities and no ratios; any N/mg, O/mg, O/N or
  % neurons value downstream of this item is a merge derivation from
  these counts, never a reported value.
