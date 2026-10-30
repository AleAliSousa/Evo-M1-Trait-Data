# Turner et al. 2016 — Table 1 (experimental cases: brain weight + cortical surface area)

Turner EC, Young NA, Reed JL, Collins CE, Flaherty DK, Gabi M, Kaas JH (2016). *Distributions of cells
and neurons across the cortical sheet in Old World macaques.* Brain Behav Evol 88(1):1–13.
doi:10.1159/000446762 · Team **Kaas** (Vanderbilt) · flattened neocortex + flow fractionator.

Registry (`__ReadMe.xlsx`): Item **`Turner_etal_2016_Table1`**, encoded
`10.1159%2F000446762_Table1`. Data role **primary**; main trait *brain surface total area*.

## What the data are
Table 1 ("Summary of experimental cases") is the **specimen table**: case, species, age, sex,
hemisphere, brain weight (g) and **brain surface area (cm²)** for **6 measured hemispheres** — 4
macaque hemispheres (2 *Macaca radiata* hemispheres of one animal, 1 *M. nemestrina*, 1 *M. mulatta*)
and 2 baboons. The surface area is the trait this paper contributes to `__merging_cortical_areas`
as `CorticalSurface_Area.mm2`: the **total unfolded neocortical sheet per hemisphere** (buried/sulcal
cortex included), neocortex separated from white matter, manually flattened, piece surfaces measured
in ImageJ. It is **not** an exposed/pial surface and is not interchangeable with Mota &
Herculano-Houzel's `AG`. The paper's per-piece cell and neuron counts are **not** in this table.

## Source → Snapshot → Data readable
The source is the **printed table in the PDF** (`Turner-2016-Distributions of cells and neurons.pdf`,
p. 2), so a snapshot is required (`__HOWTO_build_a_dataset_file.md` §0a invariant 1). Frozen as
`Turner_etal_2016_Table1_snapshot.xlsx` (sheet **`Table1`**): row 1 caption, row 2 the printed header
with its units, rows 3–8 the six cases in published order with values **as printed** (`25.0`, `186.0`
kept with their trailing zeros, cell values stored as text), row 10 the printed footnote verbatim —
including the paper's own spelling **"cyncephalus"** (a typo for *cynocephalus*, left uncorrected in
the snapshot and explained in the data instead). Entered by hand and then checked cell-by-cell against
the PDF (snapshot guide method 5).

`Turner_etal_2016_Table1.R` reads that snapshot **positionally** → `Turner_etal_2016_Table1.csv`
(**use this**, 6 rows) and the public TSV `__Public/comparative-data/10.1159%2F000446762_Table1.tsv`,
with the encoded name looked up from `__ReadMe.xlsx`. Cleaning done there, not in the snapshot:
project units (**cm² × 100 → mm²**, **g × 1000 → mg**) added alongside the printed values, the printed
footnotes split into their own `taxon_note` / `case_note` columns, and the hemisphere suffix split off
the case id (`12-58 LH` → `case_number` `12-58`). Columns are documented in
`reference_tables/Turner_etal_2016_Table1_definitions.csv`.

> Note: the registry's `Item in AUTO Public TSV FileList` cell is a **formula** and still reads `notfound`
> until `__ReadMe.xlsx` is next opened and recalculated in Excel — the TSV it looks for now exists.

## Species names
Printed names are abbreviated (`M. radiata`) and the baboons appear only as the codes **PHX** and
**PHA**, expanded in the table footnote: `PHA = P. hamadryas anubis`, `PHX = P. hamadryas
anubis/cyncephalus hybrid`. The printed form is preserved in `Species_Turner2016`; accepted binomials
come from `_keys/Stephan/species_key.csv` (token **`Turner2016`**, 5 rows added — no inline fixes).
**Both baboons resolve to `Papio cynocephalus anubis`**, which is the accepted name Collins et al.
2010 and Young et al. 2013 already use for the same animals in this merge; the hybrid status of PHX is
not lost — it is carried in `taxon_note`.

## Specimen flags — this is a shared-specimen paper (`specimen_overlap`, `dedupe_status`)
- **Case 9-27 (PHX)** is the **same baboon** as `Collins_etal_2010_DatasetS1` case **09-27** (Collins'
  cortical surface 18,577 mm² vs 18,600 mm² here — same animal, slightly different summation).
  Flagged `exclude_duplicate_Collins2010`: Collins already contributes that specimen's surface, so
  this row must **not** enter a merge.
- **Case 11-31 (PHA)** also appears in `Young_etal_2013_b`, which is excluded from the merges — so
  Turner is the **merged surface source** for this baboon (`include`).
- **Case 10-50 (*M. mulatta*)** is a **different individual** from Finlay et al. 2006's macaque
  (15,230 vs 10,598 mm², ~44% apart). Both are kept and the disagreement is flagged downstream, not
  averaged away silently.
- **Case 12-58** is **one animal measured in both hemispheres** → two rows here. Aggregation to a
  single per-hemisphere value (10,200 mm²) happens in the merge, not in this build.

## Checks
`comparison/Turner_etal_2016_Table1_compare_to_turner_2016_surface_csv.R` audits the snapshot against
`turner_2016_surface.csv` — the curated per-case extract `__merging_cortical_areas` has been reading
while this folder was unbuilt — joined on case + hemisphere (the curated file zero-pads `09-27`; the
paper prints `9-27`, so both sides are normalised). Result: **6/6 cases matched, 0 value mismatches**,
no snapshot-only or csv-only rows, and `dedupe_status` agrees. So the merge can be re-pointed at this
build's TSV without any merged value changing — a deliberate follow-up, not done here.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Comparison ✅ (0 mismatches) → Species note ✅ →
Online database ✅
