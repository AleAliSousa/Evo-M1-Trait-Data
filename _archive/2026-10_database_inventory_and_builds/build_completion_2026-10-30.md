# Existing dataset builds completed — 2026-10-30

The live `__ReadMe.xlsx` supplied each public TSV stem. Eleven prepared items were rebuilt from their saved R scripts and frozen snapshots: Crile–Quiring Table 1; Dunbar–Bever Tables 1–3; Herculano-Houzel et al. Table 1; Hofman Table I; Haug Table 2; Manger et al. Table 1; and Reep–O'Shea Tables 1, 3, and 4. Jacobs et al. Tables 1–2 were also rebuilt to correct the capitalization of their DOI-encoded TSV filenames to the current registry values. The older Jacobs files were identical in bytes to the rebuilt files; this was a filename correction.

Across these 13 items, 701 analysis rows match the public TSVs cell for cell. `validate_dataset_item()` returned eight passes and one optional errata skip per item, with no failures. The 11 previously prepared snapshots were byte-identical to their prebuild hashes. Hofman's script had a `_Table1` suffix typo that changed its `source` field on rerun; the suffix is now `_TableI`, so its CSV retains the established `Hofman__1985` source. Crile's TSV writer now doubles embedded quotation marks so a standard TSV parser matches the analysis CSV.

## Review still needed

- Human side-by-side source checks were not performed or marked complete. The registry's progress labels were not edited.
- Haug Table 2 still uses staged species-key rows and reports five unresolved names. One staged vervet mapping is explicitly a taxonomic hypothesis; the staged rows were not merged into the shared key.
- Reep–O'Shea Table 4 retains the printed mean 4.23. The script reports a simple mean of 4.023 and an n-weighted mean of 4.021, so this discrepancy remains documented rather than corrected silently.
- Bjugn Table III has an analysis-only build script and an explicit owner publication gate. Elston 2005a Tables 4–6 refuse public export until the source placement decision is recorded; Elston 2005b Table 4 contains an explicit analysis-only hold. Nudo–Masterton Figure 2A remains a candidate. Their public TSVs were not created.

The companion `database_inventory_2026-10-30.md` and `.json` compare the current registry with folders and public files. The workbook was changing during this work, so the inventory is a point-in-time snapshot. It currently has 880 registry item rows, 796 with a matching public TSV and 84 without one. These counts describe file presence, not scientific or human-review completion.
