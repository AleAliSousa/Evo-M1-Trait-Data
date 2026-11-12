# Grabowski et al. 2023: Data File S1, diet (358 species rows)

Grabowski, M., Kopperud, B. T., Tsuboi, M., & Hansen, T. F. (2023). Both diet and sociality affect primate brain-size evolution. *Systematic Biology*, *72*(2), 404–418. https://doi.org/10.1093/sysbio/syac075

Data: Dryad, https://doi.org/10.5061/dryad.2547d7wpg (Data File S1).

**Registry:** no row yet in `__ReadMe.xlsx`. Item number (col D) **Data File S1 Diet** → Item name **`Grabowski_etal_2023_DataFileS1Diet`**, Item encoded **`10.5061%2Fdryad.2547d7wpg_DataFileS1Diet`**. The row to paste is in `out/registry_rows_digital.json`; the script looks both names up live.

## Frozen source (born-digital, no derived snapshot)
`Grabowski_SB_Data_File_S1.xlsx` is the untouched Dryad Data File S1 (https://doi.org/10.5061/dryad.2547d7wpg), kept under its original name in `Grabowski_etal_2023/` (sha256 `3f407068a9fc6fb5ace78fd8c468ed440108cd9eeef579cd71de4fa4b0b2df08`). Under build HOWTO §0a there is no copy-renamed `_snapshot`; the R script reads this file directly with `readxl` (`col_types = "list"`, positional), so `audit_dataset_item()` reporting the snapshot as missing is expected.
Sheet read: `Diet Data`. Row 1 holds notes (A1 description; Y1, Z1, AF1, AJ1, AK1, AL1 column notes), row 2 the header (38 columns A-AL), rows 3-360 the 358 species rows; no blank or footnote rows.

**Formulas — cached values.** 2,751 cells of this sheet are Excel formulas (M on two rows, X, Z-AK). `readxl` returns the values Excel last cached, not the formulas. At build every formula cell had a cached value (0 missing); 12 are cached as `#VALUE!` (M80, AA80, AC80, AD80, AG80, AJ80, AK80, M227, AA227, AC227, AD227, AG227: a summed cell holds text) and are blank in the CSV. The script audits this when `tidyxl` is installed.


## What the data are
One row is one species as printed: percentage of feeding time on 15 food categories (Leaves ... Other), their Sum and the gap to 100, the four categories of Nunn and van Schaik (2002) (Fauna, Reproductive.Parts, Vegetative.Parts, Exudates) and other derived sums, and three classifications used in the main analysis (`*`): Frug/Non.Frug and Fol/Non.Fol from the percentages, and Fol/Non.Fol by physiological adaptation (typed). 201 species have percentage data (`to_use` Yes, green in column A); 157 do not (red). Sources: `diet_reference`, and `compilation_sources` (Powell et al. 2017; Campbell et al. 2011).

**Observation level:** species (one source, an average of sources — sheet 'Diet Data - Multiple Sources' — or a compilation). **Data role: secondary.**

## Build
`Grabowski_etal_2023_DataFileS1Diet.R` (run: `Rscript Grabowski_etal_2023/Grabowski_etal_2023_DataFileS1Diet.R`) reads the frozen file and writes:
- `Grabowski_etal_2023_DataFileS1Diet.csv`: 358 rows × 42 columns (UTF-8 with BOM, house C6).
- the public TSV `__Public/comparative-data/10.5061%2Fdryad.2547d7wpg_DataFileS1Diet.tsv`, after looking up *Item encoded* by *Item name* in `__ReadMe.xlsx` (it warns and writes no TSV while the registry row is missing). The mirror wrote it locally as `out/__Public_local/10.5061__dryad.2547d7wpg_DataFileS1Diet.tsv` (`%2F` → `__`; see `out/tsv_manifest_digital.json`).

Definitions: `reference_tables/Grabowski_etal_2023_DataFileS1Diet_definitions.csv` (42 columns + 6 `Method:` rows; printed header and column letter in *Source Note*).

**R NOT RUN (Python mirror).** There is no R in this sandbox. The CSV and TSV of 2026-11-10 were written by `mirror/Grabowski_etal_2023_DataFileS1Diet.py`, a Python mirror of the script (same reads, cleaning, species lookup, table checks and `write.csv` / `write.table` formatting). Run the script once to confirm byte-identical output and to run `validate_dataset_item()`.

**Cleaning.** Text trimmed, white space collapsed, `n/a` and the white-space-only cell E116 → blank; everything else verbatim, including the Mac Roman mojibake printed in some cells (`Corr√™a` = Corrêa, `K√∂nig`, `¬†` in Synonyms = a no-break space). Percentages and derived columns are numbers as stored (e.g. 100.00000000000001 is written 100, 15 significant digits). No unit conversion (percentages).

**Species.** `species_as_published` keeps every printed name verbatim; `Species` is the accepted name looked up in `_keys/General/species_key.csv` (rows with `source_publication = Grabowski_etal_2023`, matched on the lower-cased printed name). This item prints 358 distinct names; 326 accepted names result. The key rows are new: `out/_keys_General_new_rows_Grabowski_etal_2023.csv` (one row per distinct printed name of the paper, union over its items) must be appended to the key before the R script runs, or it stops with 'Unkeyed printed name'. Basis of the rows this item uses: verbatim 304, our_judgment 16, synonym:NCBI 15, unresolved 8, subspecies_assign 8, author_judgment 4, lump 2, spelling 1. 102 accepted names are not yet in the hub (`_keys/species_reference.csv`; hub rows needed). 8 printed names are unresolved (blank `Species`, 8 rows): `Alouatta_arctoidea`, `Aotus_miconax`, `Cebus_nigritusXlibidinosus`, `Cheirogaleus_adipicaudatus`, `Euoticus_pallidus`, `Leontopithecus_caissara`, `Piliocolobus_tholloni_and_foai`, `Presbytis_natunae`. Printed names keep their underscore.

**References.** `reference_tables/Grabowski_etal_2023_DataFileS1Diet_references.csv` lists 200 cited works (`ref_key` exactly as printed, one row per printed form; `cited_in_column` = the CSV column, or `caption` for works named in a header or note row). 88 have their entry verbatim from `Grabowski_SB_Data_File_References.docx` or the article's reference list; the others have none printed (citation left empty, never invented; the note says why). Cells keep their printed text; multi-citation cells are not split in the CSV (bind with `build_source_match()`, dictionary match on `ref_key`).

## Table checks
Script section 4 runs 3772 checks: 3467 pass, 258 mismatch, 47 not evaluable. Results stay in `table_checks`; values are kept as printed.
- **Sum = SUM(Leaves, Flowers, Fruit, Seeds, Total.Animal, Gum ... Other) (205 checks: 205 pass).** Cached formula, reproduced exactly.
- **Sum within 1 point of 100 (205 checks: 146 pass, 59 mismatch).** The mismatches are sources whose categories as printed add up to less (or more) than 100 (from 0 to 103.3; most 89-99).
- **Vs.100 = 100 − Sum (202 checks: 182 pass, 20 mismatch).** Vs.100 is typed; the mismatches look not updated after categories changed.
- **Fruit+Seeds = Fruit + Seeds (202 checks: 186 pass, 16 not evaluable)** and **Total.Animal = Invertebrates + Vertebrates (126 checks: 91 pass, 4 mismatch, 31 not evaluable)**, tolerance 0.1; not evaluable when both parts are `n/a` (the source's combined value). Total.Animal mismatches (Invertebrates + Vertebrates vs printed): row 47 *Cercocebus_torquatus_atys* 40.9 vs 5.4; row 126 *Macaca_radiata* 16.3 vs 14.5; row 180 *Saguinus_niger* 12.37 vs 15.46; row 227 *Callithrix_aurita* 34 vs 38.5.
- **Derived columns (Total.Leaves, Total.Fruit, Animal, High.Cal.Non.Animal, Reproductive, Structural, Fauna, Reproductive.Parts, Vegetative.Parts, Exudates): 1674 checks, all pass.** All reproduce their cached formulas.
- **Frug.Non.Frug.Per* from the Excel rule on the row's own cells (200 checks: 180 pass, 20 mismatch).** **The formulas in AJ90:AJ203 reference the row above** (e.g. AJ109 = `IF(AND(AG108>AF108, ...))`): 114 rows carry the classification computed for the previous species, and it differs from the species' own in 20 rows (e.g. *Lepilemur_edwardsi*, row 109, Frug with 12.3% reproductive vs 87.7% vegetative parts). Fol.Non.Fol.Per* (200 checks: 200 pass) has no such shift.
- **The Methods rule** (reproductive / vegetative parts larger than the three other categories): Frug 200 checks: 87 pass, 113 mismatch; Fol 200 checks: 160 pass, 40 mismatch. Besides the shifted rows, Excel compares text above any number, so a category printed `n/a` (text) makes `AG > AF` FALSE: e.g. *Alouatta_belzebul* (61.3% reproductive, 37.4% vegetative, Fauna and Exudates `n/a`) is Non.Frug. These two columns were used in the main analysis.
- **To.Use = Percent Feeding Data (358 checks: 356 pass, 2 mismatch):** rows 196 (*Trachypithecus_cristatus*: Yes / No) and 314 (*Presbytis_frontata*: No / Yes). The column-A fill agrees with To.Use on all 358 rows.

## Printed-data observations (reported, not corrected)
- 26 rows refer to the Multiple Sources sheet ("see Multiple Sources Sheet" / "see 2nd Sheet"), but only 8 of those species have a block there; 18 do not (`Aotus_azarai`, `Callicebus_lugens`, `Cercopithecus_ascanius`, `Cercopithecus_cephus`, `Cercopithecus_nictitans`, `Chiropotes_israelita`, `Chlorocebus_aethiops`, `Lagothrix_poeppigii`, `Macaca_fascicularis`, `Nycticebus_coucang`, `Perodicticus_potto`, `Piliocolobus_badius`, `Piliocolobus_kirkii`, `Pongo_pygmaeus`, `Presbytis_rubicunda`, `Procolobus_verus`, `Pygathrix_nemaeus`, `Semnopithecus_dussumieri`). For the 13 species that sheet does hold, Diet Data prints the UNWEIGHTED means of the sources, not the sheet's N-weighted average rows (Multiple Sources item, table checks 4d); *Propithecus_verreauxi* cites Norscia et al. 2006 and Richard 1978 instead.
- Citation cells mix sources, compilations and comments ("adds up to 121%, thus insect minus 21%", "not found anymore 2012?"); typos are kept (`O'Brien and Kinnaird, 1867` for 1997, `Numes` for Nunes).


Reader: AI assistant (Copilot), Python mirror of the R script, 2026-11-10; R NOT RUN - run Rscript Grabowski_etal_2023_DataFileS1Diet.R to confirm.
