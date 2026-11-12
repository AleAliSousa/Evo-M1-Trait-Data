# Melchionna et al. 2020: Supplementary Appendix S1, body mass, ECV and EQ of 317 primate species

Melchionna, M., Mondanaro, A., Serio, C., Castiglione, S., Di Febbraro, M., Rook, L., Diniz-Filho, J. A. F., Manzi, G., Profico, A., Sansalone, G., & Raia, P. (2020). Macroevolutionary trends of brain mass in Primates. *Biological Journal of the Linnean Society*, *129*(1), 14–25. https://doi.org/10.1093/biolinnean/blz161

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Supplementary Appendix** → Item name **`Melchionna_etal_2020_SupplementaryAppendix`**, Item encoded **`10.1093%2Fbiolinnean%2Fblz161_SupplementaryAppendix`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`blz161_suppl_supplementary_appendix.xlsx` is the untouched journal supplementary file (Supporting Information, Appendix S1), kept under its original name in `Melchionna_etal_2020/` (sha256 `980857464f6b453b0a02c762803012db5973fdea57e30714331e04e0c9491677`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Appendix 1` (the article calls it Supporting Information, Appendix S1: "We collected from the literature estimates of primate body mass and endocranial volume (ECV; see Supporting Information, Appendix S1)"). Row 1 is the header (8 columns A-H); rows 2-318 are the 317 species rows; no title, blank or footnote rows; no formulas. The SI text (`blz161_suppl_supplementary_information.docx`) holds only model-result tables and figures.


## What the data are
One row per species, 248 extant and 69 extinct (Palaeogene plesiadapiforms to hominins): body mass, ECV and EQ, with the full reference of the body mass and of the ECV. EQ = ECV / e^(0.60 ln(BM) − 1.402) (article eq. 1, after Grabowski et al. 2016).

**Units** are not printed: body mass in g and ECV in cm³ — the units of that equation, which reproduces every printed EQ (table checks). **Observation level:** species. **Data role: secondary**; three body masses are the authors' own estimates ("ours; calculated from the relationship between mandible size and body size", equation in Raia et al. 2018: *Dryopithecus brancoi*, *Homo naledi*, *Xenothrix mcgregory*), so those rows have `data_role` = both.

## Build
`Melchionna_etal_2020_SupplementaryAppendix.R` (run: `Rscript Melchionna_etal_2020/Melchionna_etal_2020_SupplementaryAppendix.R`) reads the frozen file and writes:
- `Melchionna_etal_2020_SupplementaryAppendix.csv`: 317 rows × 13 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.1093%2Fbiolinnean%2Fblz161_SupplementaryAppendix.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.1093__biolinnean__blz161_SupplementaryAppendix.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Melchionna_etal_2020_SupplementaryAppendix_definitions.csv` (13 columns + 5 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Melchionna_etal_2020_SupplementaryAppendix.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** The reference cells contain no-break spaces and line breaks: both become spaces and white space is collapsed; nothing else changes. `ecv_cm3` is kept and `ecv_mm3` (× 1000) added; body mass is already in g. Columns keep the printed order (references first).

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Melchionna_etal_2020`, matched on the lower-cased printed name). This item prints 317 distinct names; 313 accepted names result. The key rows are new: `out/_keys_General_new_rows_Melchionna_etal_2020.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 293, synonym:NCBI 13, our_judgment 5, subspecies_assign 3, spelling 2, unresolved 1. 96 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). 1 printed name is unresolved (blank `Species`, 1 row): `Aotus infulatus`. Fossil taxa keep their printed binomial as accepted name with `ncbi_taxid` blank (never a living species' taxid), as the General key treats fossils; `Xenothrix mcgregory` → *Xenothrix mcgregori* (spelling).

**References.** `reference_tables/Melchionna_etal_2020_SupplementaryAppendix_references.csv` lists the 39 distinct printed references; each cell is the full reference, so `ref_key` = `citation` = the printed text (white space normalised), with `cited_in_column` and row counts. Two printed forms of Gómez & Verdú 2012 are the same work; the NOW database citation is printed as an unfilled template.

## Table checks
Script section 4 runs 320 checks: 320 pass, 0 mismatch, 0 not evaluable. Results stay in `table_checks`.
- **EQ = ECV / e^(0.60 ln BM − 1.402) (317 checks: 317 pass)**, relative tolerance 1e-9: reproduced on every row (this is also the evidence for the units).
- **Totals in Material and methods: 317 species, 248 extant, 69 extinct (3 checks, all pass).**

## Printed-data observations (reported, not corrected)
- No units are printed; see above.
- `Presbytis rubiconda` and `Xenothrix mcgregory` are misspelt; kept as printed.


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Melchionna_etal_2020_SupplementaryAppendix.R to confirm.
