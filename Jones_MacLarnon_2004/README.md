# Jones & MacLarnon 2004 — bat trait data and source map

Jones KE, MacLarnon AM (2004). *Affording larger brains: testing hypotheses of mammalian brain evolution on bats.* American Naturalist 164:E20–E31. DOI: 10.1086/421334.

## Source files and builds

The two publisher enhancements are now held locally: **datafile1.txt**, the 313-species trait table, and **datafile2.txt**, its 148-entry source list. They arrived on 2026-10-29 after the publisher download links initially failed. Each has a byte-identical item-named `_snapshot.txt`; these are tab-delimited text, not HTML or reconstructed plot points. Data file 1 is ASCII; file 2 has one non-ASCII acute-accent byte and is read as Windows-1252. The original bytes and published spelling remain unchanged.

Official source: https://www.journals.uchicago.edu/doi/10.1086/421334, with enhancements:
- https://www.journals.uchicago.edu/doi/suppl/10.1086/421334/suppl_file/datafile1.txt
- https://www.journals.uchicago.edu/doi/suppl/10.1086/421334/suppl_file/datafile2.txt

The existing registry items `Jones_MacLarnon_2004_datafile1` and `Jones_MacLarnon_2004_datafile2` each have a reader, analysis CSV, public DOI-coded TSV, definitions and metadata-update workbook. Run datafile2.R and datafile1.R from clean R sessions. The data reader invokes the standard-library Python reference builder; only the reference builder and the two frozen source files are required for its provenance output. Main registry rows are looked up by item name, never row position. No shared registry overwrite was made.

## What the supplement contains

| Variable | Published unit | Nonmissing species |
|---|---|---:|
| Adult body mass | g | 313 |
| Adult brain mass | mg | 313 |
| Basal metabolic rate | mL O2/hour | 69 |
| Total intestinal length | mm | 51 |
| Gestation length | days | 90 |
| Diet | fruit = 0; nonfruit = 1 | 312 |

**The Jones brain column is explicitly a mass column, not an unidentified g/cc measure.** This identifies the quantity reported by Jones, not the original preparation or weighing method for every cited work. All values remain secondary species means. Methods says data were averaged across subspecies/localities and that size measurements combine males and nonpregnant females. Do not infer a sex field or separate samples from these pooled means.

The supplement has **90** gestation values, although Methods reports **96**. It also has **no weaning-age or maternal-energy-investment column**, although these quantities are described in the paper. These discrepancies are retained; no absent measurements are created. The data reader checks actual supplement coverage and keeps numeric lexemes beside numeric values. Diet has 208 ones, 104 zeros and one missing value; missing remains missing.

## References and original-source limits

The published source columns separately identify joint **body and brain mass**, **BMR**, **intestine length**, **gestation** and **diet** sources. Their item-scoped lookup has **136 distinct cited keys**, including one explicitly unresolved key, **1,084 variable/source links**, and **34 as-cited-in chains**. The full 148-entry list is independently built as datafile2; the measurement lookup includes only keys actually used by datafile1. A cell containing several references is one compiled datum with several source links, not several observations or an equal-weight contribution claim. The body/brain column cannot establish which part of each reference contributed to which mass.

Brain/body source keys are 1 (Pirlot & Stephan 1970), 12 (Stephan, Nelson & Frahm 1981), 77 (Bhatnagar et al. 1990), 1471 (Bernard et al. 1988), 2274 (Jurgens & Prothero 1987), 2603 (Baron, Stephan & Frahm 1996), and the abbreviated keys 9, 10, 11, 16 and 24. Key 2603 occurs on **275 of 313 rows**; those observations must not be counted again as independent of the Baron lineage. The five abbreviated brain/body keys identify earlier works *as cited in* Pirlot & Stephan or Stephan et al.; they retain the intermediary. Key 9 itself combines Dubois 1897 and 1914 and remains compound, with no invented sample partition.

**One published citation is missing:** *Cynopterus sphinx* gestation (120 days) cites `43; 118; 123`, but key **123** is absent from datafile2. Key 124 exists but is not silently substituted. The value and all three printed keys remain. The issue table records the gap. This affects gestation, not its brain mass, which cites 2603.

`reference_tables/*_value_reference_links.csv` is authoritative for field-scoped links. `*_reference_chain_links.csv` keeps the abbreviated work and its cited intermediary separate. Bibliographic matches do not establish experimental primary status; the empty primary-reference catalog is intentional. No row is eligible for primary-only pooling, and datafile1 is explicitly excluded by both brain-mass merge readers until upstream overlap and measurement methods are resolved. No merge outputs or app deployment were rebuilt.

## Why Burger can cite Jones for both brain size and BMR

The paper and its supplement supply both quantities. The two earlier works named in Methods are Jones & MacLarnon 2001 (*Bat life-histories: testing models of mammalian life-history evolution*, Evolutionary Ecology Research 3:465–476) and Cruz-Neto & Jones, then in press (*Exploring the evolution of the basal rate of metabolism in bats*, in *Functional and evolutionary ecology of bats*). The latter is explicitly about BMR. They are context for the compilation, not the complete per-brain source list. The separate numbered source columns resolve this apparent contradiction. An American Naturalist research article can supply online data without being a dedicated dataset paper.

The locally held PanTHERIA WR05/WR93 datasets each have 55 columns, including `18-1_BasalMetRate_mLO2hr` and `5-2_BasalMetRateMass_g`, but no brain mass, brain volume or endocranial-capacity column. PanTHERIA cannot replace this brain table. Shared BMR ancestry would require its own source/sample check.

## Review record

Built by Codex on 2026-10-29. Born-digital sources require no PDF transcription review. Both text snapshots were checked byte-for-byte against the supplied files; original cells, row order and numeric outputs were reconciled, reference foreign keys were checked, and the R readers were run in clean sessions. Missing key 123 is the only unbound printed key; all as-cited-in parent keys exist. Published labels are preserved, with shared-resolver identity candidates recorded separately and uncertain names left unresolved. Registry metadata rows are supplied for owner updates, including `Not applicable: tabulated and digital already` for snapshot review.
