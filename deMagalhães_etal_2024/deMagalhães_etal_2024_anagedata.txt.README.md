# de Magalhães et al. 2024 — AnAge database export (`anage_data.txt`)

de Magalhães, J. P., Abidi, Z., Dos Santos, G. A., Avelar, R. A., Barardo, D., Chatsirisupachai, K.,
Clark, P., De-Souza, E. A., Johnson, E. J., Lopes, I., Novoa, G., Senez, L., Talay, A., Thornton, D.,
& To, P. K. P. (2024). Human Ageing Genomic Resources: updates on key databases in ageing research.
*Nucleic Acids Research*, 52(D1), D900-D908. doi:10.1093/nar/gkad927

Full-database export of **AnAge** (Human Ageing Genomic Resources), **Build 15** (release date
2023-07-03 per `release.html`, downloaded 2025-08-25): life-history and longevity data across
**4,645 species, all taxa** (not mammal-restricted) — Kingdom/Phylum/Class/Order/Family/Genus/Species,
maturity, gestation/incubation, weaning, litter size, birth/weaning/adult weight, growth rate,
maximum longevity, and (for a sparse subset) initial mortality rate, mortality-rate-doubling-time,
metabolic rate, body mass, and body temperature. `release.html` reports 4,671 entries for Build 15;
this downloaded copy holds 4,645 rows (minor drift between the release notes and the live export, per
AnAge's own release-notes caveat — not a build error on our side).

## What we built
The folder had only the raw download (`anage_data.txt`), the source PDF, and `release.html`. Now
built to convention:

- **Frozen source (digital-native, no snapshot):** `anage_data.txt` (tab-delimited, UTF-8, 31
  columns) is machine-readable, so it **is** the frozen source — kept verbatim, never edited (see
  `__HOWTO_build_a_dataset_file.md` §0a invariant 1).
- **Reformat:** `deMagalhães_etal_2024_anagedata.txt.R` reads the source file directly, cleans column
  names to R-friendly form (units kept in the name, e.g. `Maximum_longevity_yrs`, `Inter_litter_Interbirth_interval_days`), strips
  thousands-separator commas, and coerces the 17 numeric columns; no species harmonisation was
  applied (the source already provides its own canonical Genus/Species split — there is no printed
  common-name-only column that would need a project `species_key.csv` lookup). No rows were dropped;
  all 4,645 taxa (not just Mammalia) are kept, since this is a general cross-taxon life-history
  reference table rather than a single-collection species table. Writes:
  - `deMagalhães_etal_2024_anagedata.txt.csv` (analysis-ready, 4,645 rows × 31 columns)
  - `__Public/comparative-data/10.1093%2Fnar%2Fgkad927_anagedata.txt.tsv` (public, DOI-encoded per
    the registry's pre-existing `Item encoded` value — see Registry below)
- **Definitions:** `reference_tables/deMagalhães_etal_2024_anagedata.txt_definitions.csv`.
- **Bibliography:** `deMagalhães_etal_2024_anagedata.txt_references.R` reads the frozen
  `Search the AnAge Database.pdf` directly and writes:
  - `reference_tables/deMagalhães_etal_2024_anagedata.txt_references.csv` — all 1,467 BIBLIOIDs;
  - `reference_tables/deMagalhães_etal_2024_anagedata.txt_reference_alignment.csv` — one row per
    dataset row × reference occurrence, preserving whether the key came from `Source_ref` or
    `References` and its honest scope;
  - `reference_tables/deMagalhães_etal_2024_anagedata.txt_reference_alignment_issues.csv` — the
    unresolved numeric key and non-bibliographic source labels summarized for review.
  - `reference_tables/deMagalhães_etal_2024_anagedata.txt_reference_columns.csv` — declares the
    two source-key scopes for the repository-wide `source_match.R` convention; `References =
    row_overall` preserves the source's granularity without manufacturing variable-level support.

## Data role
**Secondary (compilation).** AnAge is itself a curated compilation: every life-history value is
drawn from primary literature keyed by `Source_ref` (the longevity record) / `References` (the row
overall). The separately saved full-bibliography PDF now resolves the numeric codes. It does not,
however, identify which individual variables each row-level `References` entry supports, so the
alignment records that scope as `row_overall` rather than inventing per-variable attribution.

The PDF contains all BIBLIOIDs 1–1467. Of the 1,422 distinct numeric keys used in this downloaded
dataset, 1,421 resolve. Key `0` is not a bibliography entry and is retained as unresolved on 20
crocodilian rows. `Source_ref` also contains 32 prose-source occurrences (18 unique personal-
communication or website-feedback labels); these remain explicit `non_bibliographic_source_text`
records rather than being assigned invented BIBLIOIDs.

The PDF was printed from the live Build-15 bibliography, which reports 4,671 AnAge entries, while
this downloaded data copy has 4,645 rows. Consequently, 1,381 reference citation counts agree
exactly and 86 show small count differences or are unused in the downloaded copy. The key joins are
still valid; the count differences are carried as release/export-drift flags.

## Quality caveats (from the source)
- `Data_quality` (low/questionable/acceptable/high) and `Sample_size` (tiny/small/medium/large/huge)
  are AnAge's own curator-assigned qualitative bins, not raw counts or CIs.
- `IMR_per_yr` / `MRDT_yrs` (43 of 4,645 rows), `Metabolic_rate_W` / `Temperature_K` (627 / 494 rows)
  are sparse, model-fit or paired-measurement columns — most rows are blank by design, not by error.
- `Body_mass_g` (paired with the metabolic-rate measurement) is a **separate** column from
  `Adult_weight_g` and may come from a different individual/study — kept distinct per the source's
  own layout, not merged.
- `HAGRID` is AnAge's internal ID and is **reshuffled at every build** (per `release.html`): do not
  join across AnAge builds/downloads by `HAGRID`.

## Species names
Genus/Species/Common_name are AnAge's own printed, curated taxonomy — kept exactly as exported. No
project `species_key.csv` rows were added, since this is not a printed-table transcription needing
name harmonisation against a project collection.

## Registry
A stub row already existed in `__ReadMe.xlsx` Sheet1 (Item number `anage_data.txt`, Publication
`deMagalhães_etal_2024`, DOI `10.1093%2Fnar%2Fgkad927`) with the formula-derived Item name
(`deMagalhães_etal_2024_anagedata.txt`) and Item encoded
(`10.1093%2Fnar%2Fgkad927_anagedata.txt`) already resolved, but every descriptive column (N→AN) was
blank and `Public TSV match` read `notfound`. Per house rule, we did not script-edit the workbook;
suggested values for the descriptive columns are supplied separately in
`deMagalhães_etal_2024_anagedata.txt_registry_row.xlsx` (HOW_TO_PASTE sheet) for the owner to paste
into the existing row, then run `_tools/file_list.R` and re-verify `Public TSV match`.

## Downstream use
General-purpose life-history/longevity covariate table (all taxa); the Mammalia subset (1,349 rows)
is the most directly relevant slice for this project's comparative mammalian work. Consumed by
`__merging_supplementary` (life-history columns, mapped in `supplementary_sources.csv`; added 2026-10-20) and by
`__merging_body_ecology` (`Body_mass_g` only).

## Extraction / build record
Read, cleaned, and built by Microsoft Copilot (AI assistant) on 2026-09-25, working from the
already-downloaded `anage_data.txt` and the existing `__ReadMe.xlsx` registry stub row. No manual
transcription was needed (digital-native source). The R script above documents the transformation;
running it end-to-end (including the `__ReadMe.xlsx` lookup and `validate_dataset_item()` call) still
needs to happen in an R session against the live repo, since this build environment has no R runtime
— the analysis CSV and public TSV delivered alongside it were generated with an equivalent Python
transform for delivery now, and should be spot-checked by re-running the R script.

## Checks
- Analysis CSV = 4,645 rows (matches source row count exactly; no accidental empty columns).
- Verified UTF-8 (no encoding fallback needed); no thousands-separator commas or stray missing-value
  tokens remained in numeric columns after cleaning.
- No independent curated copy exists to audit against (first-party compilation, digital-native
  source) — no `comparison/` step applies (§7).
- Bibliography extraction: 1,467 unique rows, exactly BIBLIOID 1–1467; no blank titles, duplicate
  IDs, or nonnumeric citation counts. The normalized bridge contains 20,425 row-reference links.
- Numeric alignment: 1,421 of 1,422 distinct used keys matched; the sole unmatched key is `0`.

## Changelog
- **2026-10-20 — `Inter_litter_Interbirth_interval_yrs` renamed to `Inter_litter_Interbirth_interval_days`.**
  AnAge's header (`Inter-litter/Interbirth interval`) carries no unit, but the field is documented in
  days and the values are days (Homo sapiens 639, Mus musculus 30, Sus scrofa 230). The `_yrs` suffix
  was a naming slip in the 2026-09-25 build. Fixed in the build script only (frozen `anage_data.txt`
  untouched); the rebuilt CSV and public TSV are byte-identical to the previous ones apart from that
  header cell. Definitions row updated (`Time.days`, unit `days`). Not recorded as an erratum: no value
  differed from the source, only our column label (the errata convention covers value discrepancies).
  Downstream: the `__merging_supplementary/supplementary_sources.csv` row for this column now names
  `_days`; it was already reading the values as days, so the regenerated `supplementary_long.csv` is
  byte-identical. `__merging_body_ecology` reads only `Body_mass_g` and is unaffected. The downstream
  variable catalog, compatibility groups and Shiny source manifest were regenerated with
  `_keys/build_variable_catalog.R` and `__ShinyApp/build_data.R`; the supplementary merge README
  now documents the corrected column name.
- **2026-10-20 — build script re-run end-to-end with `Rscript`** (including the `__ReadMe.xlsx` lookup
  and `validate_dataset_item()`): every check PASS (`errata_file_valid` SKIP, no errata file);
  4,645 rows → CSV + public TSV.
