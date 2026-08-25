# Campos & Welker 1976 - Table 1

## Source

Campos, G. B., & Welker, W. I. (1976). Comparisons between brains of a large and a
small hystricomorph rodent: capybara, *Hydrochoerus*, and guinea pig, *Cavia*;
neocortical projection regions and measurements of brain subdivisions. *Brain,
Behavior and Evolution, 13*(4), 243-266. https://doi.org/10.1159/000123814

Registry item: **Table 1**. Public file: `10.1159%2F000123814_Table1.tsv`.

## Dataset

Table 1 compares one capybara (`No. 59-490`) and one guinea pig (`No. 60-1`).
The source's names, *Hydrochoerus hydrochoerus* and *Cavia porcellus*, are retained.
The frozen snapshot preserves all 20 printed measures and all printed
multiplication factors. The builder writes:

- `Campos_Welker_1976_Table1_volume.csv`
- `Campos_Welker_1976_Table1_cortical_morphometry.csv`
- `Campos_Welker_1976_Table1_cell_count.csv`
- `Campos_Welker_1976_Table1.csv`, a 40-row long table used for the public TSV

The split prevents volumes, cortical surface/thickness, and cell measures from
being forced through one merge merely because they share a printed table.

## Methods and definitions

Volumes were estimated from planimetric measurements of enlarged section
drawings. The values in Table 1 are from the right hemisphere of both specimens;
they are not bilateral estimates and must not be doubled without an explicit
laterality decision. `thal` includes dorsal, epithalamic and ventral thalamic
regions and their fiber tracts but excludes pretectal nuclei. `cau` is the
caudate-putamen-accumbens complex. The source's basal-forebrain and hippocampal
composites are retained rather than silently mapped to narrower structures.

Neuronal counts used 162,000 um3 samples (90 x 90 x 20 um); all neurons with
visible nucleoli were counted. The source reports 6,173 such sample volumes per
mm3. Total neuron counts equal the printed structure volume multiplied by the
printed density (within the source's rounding).

## Source-level discrepancies retained

- The capybara cortico-thalamic ratio is reproduced by `3979 / 434.1 = 9.17`.
  The guinea-pig printed ratio is `5.15`, while `170.2 / 36.6 = 4.65`. The printed
  ratio is retained and flagged rather than corrected.
- The printed caudate mean-count and density factors are both `3.0`; the printed
  values imply approximately `3.20`. Both source factors are retained.

The R builder requires these three discrepancies and fails if any new arithmetic
discrepancy appears. All other multiplication factors reproduce to the precision
printed in the paper.
