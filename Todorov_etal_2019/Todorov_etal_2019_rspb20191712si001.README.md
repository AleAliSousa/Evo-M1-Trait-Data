# Todorov et al. 2019 — sexual-dimorphism supplement

Todorov OS, Weisbecker V, Gilissen E, Zilles K, de Sousa AA (2019),
“Primate hippocampus size and organization are predicted by sociality but not
diet,” *Proceedings of the Royal Society B* 286:20191712.
DOI: [10.1098/rspb.2019.1712](https://doi.org/10.1098/rspb.2019.1712).

## Source and build

`rspb20191712_si_001.zip` is the article's electronic supplementary archive.
`Todorov_etal_2019_rspb20191712si001.R` extracts and validates its `dimorphdata.csv`
member, producing `Todorov_etal_2019_rspb20191712si001.csv`. The output has 12 species
and 19 variables. Values are natural-log sexual-dimorphism ratios,
`ln(male arithmetic mean / female arithmetic mean)`; they are not absolute
volumes.

The field dictionary is
`reference_tables/Todorov_etal_2019_rspb20191712si001_definitions.csv`.

## Provenance and merge treatment

The paper says that unpublished male and female brain-component records were
used to calculate sex averages, credits Heiko Frahm for supplying the data,
and uses anatomical definitions from Stephan et al. (1981). These are therefore
derived summaries of the Frahm/Stephan material, not a new independent set of
brain measurements.

Do not add this table to `__merging_volumes`: its values are log ratios rather
than absolute volumes, and treating them as another measurement team would
double-count the underlying specimens. The restricted companion reconstructs
the 12 species × 19 variables from the private Frahm specimen records and keeps
all specimen-level values out of this repository.

Pipeline: Source archive → public data readable ✅ → restricted provenance
comparison ✅ → merge volumes **not applicable**.


## Rebuild 2026-10-30 (house-style; supersedes the build paragraph above)
- **Frozen source:** `Todorov_etal_2019_rspb20191712si001_snapshot.csv`, the zip member `dimorphdata.csv` copied byte-for-byte (SHA-256 `0e5feea1…27420cd`). The loose `rspb20191712_si_001/dimorphdata.csv` is not byte-identical: its CRLF line endings were stripped, but the values are the same. It is left in place and not used. The script asserts snapshot = zip member on every run.
- **Analysis CSV:** `Todorov_etal_2019_rspb20191712si001.csv` is now **long**: 228 rows = 12 species × 19 variables. Columns:
  - `Species_Todorov2019` (as printed) and `species_harmonised`, from the Stephan collection key (`_keys/Stephan/species_key.csv`, 12 rows for `Todorov_etal_2019`; `Plecturocebus_moloch` → *Callicebus moloch*, NCBI 9523);
  - `variable_code`, `variable_label`, `ln_male_over_female`, `ref_key`, `data_role` = secondary.
  The old wide 12 × 20 layout is replaced; no script in either repo read it.
- **Public TSV:** `__Public/comparative-data/10.1098%2Frspb.2019.1712_rspb20191712si001.tsv`, named from the live registry Item encoded.
- **Sources:** `reference_tables/Todorov_etal_2019_rspb20191712si001_references.csv` has three keys: `Frahm unpublished` (all values), `71` (Gautier-Hion & Gautier 1976, *Miopithecus talapoin* female body weight only) and `51` (Stephan et al. 1981, anatomical definitions only).
- **Definitions:** `reference_tables/Todorov_etal_2019_rspb20191712si001_definitions.csv` was rewritten to the house 10-column schema; the old 4-column dictionary is replaced.
- **Wording note:** the Methods (p.3) call the dimorphism "the ratio of male … divided by female". The supplement prints signed values (e.g. −0.62), i.e. the natural log of that ratio. Methods names the medulla `MED`; the supplement column is `OBL`.

## Not yet built: `data.html` in the same archive
`rspb20191712_si_001.zip/data.html` is a rendered HTML table of the main dataset: 43 species × brain volume, body weight, neocortex, hippocampus total and subfields (HP.HS.fibers, retrocommissural, subiculum, CA1–CA3, hilus, fascia dentata), and social/ecological variables. Its values are compiled from Frahm & Zilles 1994 [50] and Stephan et al. 1981 [51], so they are secondary. It has no Sheet1 row; it is proposed as a separate item (see the folder registry-row proposal).
