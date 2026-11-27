# Registry file balance — 2026-11-26

The 55 naming mismatches identified earlier have been corrected in the registry
formulas and paper files. No alias/path-exception columns remain in
`__ReadMe.xlsx` Sheet1.

| Exact registry path status | Rows |
|---|---:|
| Both CSV and TSV | 1,295 |
| CSV only | 0 |
| TSV only | 0 |
| Non-tabular tree asset | 2 |
| Neither (active source/build task) | 1 |

The 22 Schenker, Sun, and Walton item names now retain meaningful underscores
in the registry. The other 33 mismatches were corrected in paper folder/item
names: 29 source-year, same-year suffix, accent, or folder spellings and four
item descriptor names. The `registry_name_renames_2026-11-26.csv` log records
all 157 path changes. Paper citations and distinct same-year identities were
preserved. All 55 corrected rows now have an exact-name R reader and matching
CSV/TSV cells. Existing readers were run after renaming; five that still
consulted staged/old registry entries were repaired. Five regenerated tables
changed only their `source` label to include the correct `_a` paper suffix;
measurement fields were unchanged.

Run `python3 _tools/audit_registry_file_balance.py` to regenerate
`registry_file_balance_2026-11-26.csv`. The original 36 rows have now been
reviewed individually; see `neither_36_resolution_2026-11-26.md` for all
decisions and named next actions. Three more older duplicate registry pairs
outside that set were merged into their completed rows. The two tree rows
have existing NEXUS files, so the audit reports them separately from missing
CSV/TSV items. `__ReadMe.xlsx` opened successfully after the update, its
formula and public-file cache rebuilt, and no orphan public TSVs remain.

The next pass built González-Lagos Appendix I as a bibliography, Stensaas Tables 1–4 as human V1 area summaries, and Terborgh Chapter 7 Tables 7.1–7.5 from the institutional book reader. The underlying González-Lagos 493-species trait table remains unavailable. Nunn 2001 and Krubitzer et al. 1995 moved to source disposition after citation and text-area review; they have no separate Evo-M1 trait item. Hawrylycz 2012 is the one remaining first-sheet row without a CSV/TSV: it is upstream AHBA provenance for Castrillon 2023, while a separate Julich-derived trait item has not been specified. See [`three_unbuilt_sources_2026-11-26.md`](three_unbuilt_sources_2026-11-26.md). Substitute QC, recording-site, or swelling-case tables were deliberately not registered. This count is file presence, not merge approval or human visual signoff. `python3 _tools/check_readme_integrity.py` passed with 1,295 public TSVs listed.
