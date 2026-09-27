# Which macaque is Elston (2000) J Neurosci 20:RC95?

**Resolved: *Macaca fascicularis*** (2026-09-27). The paper itself never names the species — every
mention is "macaque monkey" (checked across the full PDF text layer; the only *Macaca* string is in a
cited title). The resolution rests on the same cells being re-tabulated, with the species named, in
two later papers from the same lab (G. N. Elston, Vision, Touch and Hearing Research Centre,
University of Queensland).

## 1. Elston 2000 — what the paper gives
- Methods: prefrontal areas 10, 11, 12 "of the left hemisphere of a 12-year-old female macaque monkey";
  perfusion / injection protocol "detailed in previous studies (Elston et al., 1996; Elston and Rosa,
  1997, 1998a)". Comparator V1, 7a, TE values "published previously (Elston and Rosa, 1997, 1998a;
  Elston et al., 1999a)".
- Results, area 10: n = 29 cells; basal dendritic field area "mean ± SD, 133.2 × 10³ ± 3.70 × 10³ µm²";
  maximum branches at 75 µm "32.35 ± 4.41"; estimated total spines for the average neuron 8766.

## 2. Elston, Benavides-Piccione & DeFelipe 2001 (J Neurosci 21:RC163) — names the species
- Methods: "the Old World macaque monkey (*Macaca fascicularis*)"; "Macaque prefrontal cortex was
  derived from the left hemisphere of a 10-year-old male".
- Table 1, Macaque / Prefrontal: peak branching complexity **32.36 ± 4.41**, basal dendritic field
  area **13.3 ± 1.99 × 10⁴ µm²**.
- Introduction attributes the macaque PFC phenotype to "(Elston, 2000)".

## 3. Elston et al. 2006 (Anat Rec A 288:26-35) — names the species and cites 2000
- Methods: "Macaque (*Macaca fascicularis*) gPFC was taken from a 10-year-old male ... (Elston, 2000;
  Elston et al., 2005a)".
- Table 1, gPFC / *Macaca*: BDFA **133000** (footnote t), TNS **8766** (footnote t); footnote
  t = Elston et al. (2001).

## 4. Why this is the same material
| quantity | Elston 2000 (area 10) | Elston 2001 (Prefrontal) | Elston 2006 (gPFC, via 2001) |
|---|---|---|---|
| basal dendritic field area (µm²) | 133,200 | 133,000 (13.3 × 10⁴) | 133,000 |
| Sholl peak / branches at 75 µm | 32.35 ± 4.41 | 32.36 ± 4.41 | — |
| total spines, average neuron | 8,766 | — | 8,766 |
| n cells | 29 | — | — |

Three independent statistics agree to rounding; the spine total is identical to four digits. These
are one data set, and the two papers that name the species both say *Macaca fascicularis*.

## 5. Two discrepancies the resolution exposes (carry as notes, do not fix)
1. **Age/sex of the animal.** 2000: 12-year-old female. 2001 and 2006: 10-year-old male. Same cells,
   two descriptions; which is right is not determinable from the papers. `Elston__2000_Figure2`
   keeps the 2000 wording; the long table's `curation_note` records the conflict.
2. **"SD" in Elston 2000 is numerically the SEM.** 2000 prints 133.2 ± 3.70 × 10³ µm² labelled
   "mean ± SD"; 2001 prints 13.3 ± 1.99 × 10⁴ µm² for the same cells. 19,900 / √29 = 3,695 ≈ 3,700.
   So the 2000 "±" is the standard error and the 2001 "±" the standard deviation (or the 2000 label
   is a misprint). The snapshot carries the printed value under the printed label (`_SD`); the term
   map's `note` and the long table's `curation_note` flag it. Areas 11 and 12 (± 4.64 × 10³ and
   5.58 × 10³ with n = 37 and 21) are presumably SEMs too, but no independent SD exists to check.

## 6. What changes in the merge
- `species_aliases_draft.csv`: `Elston__2000_Figure2` → *Macaca fascicularis*, `taxon_level = species`.
- Because the 2001 Prefrontal macaque row and the 2006 gPFC *Macaca* row ARE the 2000 area-10 cells,
  the three rows are citation-dependent: 2000 is the primary tabulation of area 10 specifically
  (areas 11 and 12 exist only in 2000); 2001 pools "prefrontal" (area 10) and is the primary for its
  new occipital/temporal rows; 2006 is already `merge_default = FALSE` (footnote t). The compile now
  marks the 2001 Macaque/Prefrontal BDFA and complexity rows as `dependency = Elston__2000_Figure2`
  (kept, `merge_default = TRUE`, since 2001 prints the SD the 2000 text lacks) — owner may prefer
  the reverse.
- Suggested copy of this note into `Elston__2000/Elston__2000_Figure2.README.md` (not done here;
  that is a paper folder, and this merge folder is the draft's only write target).
