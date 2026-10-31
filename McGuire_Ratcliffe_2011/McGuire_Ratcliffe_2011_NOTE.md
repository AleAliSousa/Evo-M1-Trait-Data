# McGuire & Ratcliffe 2011 — ESM received; the item is built

Registry item `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1`
(doi:10.1098/rsbl.2010.0744, Biol Lett 7:233-236, "Light enough to travel: migratory bats have
smaller brains, not larger hippocampi").

**Resolved 2026-10-31.** The ESM download that blocked this folder is present:
`rsbl20100744supp1.pdf` (obtained by hand — the Royal Society and PMC copies sit behind a
reCAPTCHA to automated fetch), alongside the paper PDF `McGuire_Ratcliffe_2011.pdf`. The earlier
"one click needed" note is superseded.

ESM 1 Table 1 is built to the house convention and `validate_dataset_item()` passes all nine
checks. See `McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1.README.md` for the
file list, provenance and table checks. The public TSV is
`__Public/comparative-data/10.1098%2Frsbl.2010.0744_ElectronicSupplementaryMaterial1,Table1.tsv`.

The registry row already exists; seven blank or stale cells (Progress stage, Snapshot name,
N.B., Material type, Method, Source (if secondary), Human visual check) are proposed in
`McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1_registry_row.xlsx` and queued in
`_checks/registry_pending.csv` for the owner to apply with `_tools/registry_apply.R`.

**Still open for this folder:** ESM 2 holds only the phylogeny description and its own reference
list — no table, so no second item is registered. The item is secondary throughout; the primary
measurements live in Baron, Stephan & Frahm (1996) (`Baron_etal_1996`), and the two must be
deduplicated before any merge.
