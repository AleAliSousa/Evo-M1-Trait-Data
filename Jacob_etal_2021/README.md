# Jacob_etal_2021 — raccoon cytoarchitecture & problem-solving

Jacob, J., Kent, M., Benson-Amram, S., Herculano-Houzel, S., Raghanti, M. A., et al. (2021). Cytoarchitectural characteristics associated with cognitive flexibility in raccoons. *Journal of Comparative Neurology*, 529(14), 3375–3388. DOI: 10.1002/cne.25197. Single species (*Procyon lotor*, n = 18 zoo-sourced individuals); all items are **group means across three problem-solving performance groups** (intraspecific) — pool across groups before any species-level use.

## Items (all registered in `__ReadMe.xlsx`; item names use the printed uppercase loci)

| Item | Locus (PDF p.) | Content | Files |
|---|---|---|---|
| `Jacob_etal_2021_TABLE1` | TABLE 1 (p. 5) | hemisphere / hippocampus / somatosensory-cortex weights (one hemisphere), 3 groups | snapshot + R + csv + ReadMe + definitions |
| `Jacob_etal_2021_TABLE2` | TABLE 2 (p. 9) | frontoinsular layer-V cell-profile densities incl. VENs & fork neurons, 2 groups | snapshot + R + csv + ReadMe + definitions |
| `Jacob_etal_2021_TABLE3` | TABLE 3 (p. 11) | dentate-gyrus-hilus cell-profile densities incl. fusiform neurons, 3 groups | snapshot + R + csv + ReadMe + definitions |
| `Jacob_etal_2021_FIGURE4` | FIGURE 4 (p. 8) | isotropic-fractionation hippocampal nuclei counts (constructed snapshot from Results §3.1 text + caption) | snapshot + R + csv + ReadMe + definitions |

Snapshots are produced by `Jacob_etal_2021_extract_snapshot.R` (PDF text layer → frozen `_snapshot.csv`; extract-then-freeze, no values typed — it refuses to overwrite a differing frozen copy). The per-item `.R` scripts read the frozen snapshots and build CSV + TSV. Public TSVs: `__Public/comparative-data/10.1002%2Fcne.25197_<LOCUS>.tsv`. After (re)building, the owner reruns `_tools/file_list.R` so column L of `__ReadMe.xlsx` picks up the TSV matches.

## Where the numbers come from (honest provenance)

Every number in these files can be traced to characters inside the publisher's PDF in this folder. The PDF is not just a picture: Wiley embedded a **text layer** (the actual typeset characters), so "extraction" means reading those characters out of the file with `pdftools` — no OCR, no image recognition, no retyping. The chain is: **PDF text layer → `Jacob_etal_2021_extract_snapshot.R` (regex capture at run time) → frozen `_snapshot.csv` → per-item `.R` → analysis CSV → public TSV**. Anyone can rerun the extractor and get the frozen snapshots back byte-for-byte.

**History (2026-09-06):** the first versions of these scripts were drafted by an AI assistant that read the tables from the PDF and typed what it read directly into the R code ("hardcoding"). The values were correct — later verified cell-by-cell against the printed pages — but that reading step was invisible: nothing on disk recorded that a machine reader had transcribed them, and no independent frozen copy existed to audit the transcription against. The rebuild replaced that unrecorded route with the scripted extraction above.

**What is still judgment, not extraction** (recorded so nothing is mysterious):
- the extractor's regex patterns and anchors were designed by an AI assistant (Claude, 2026-09-06) and verified against the PDF;
- captions, printed headers, and table-note lines are literals in the extractor (transcribed from the printed page; each is anchor-asserted against the PDF before anything is written);
- two repairs where the text layer is defective relative to the printed page: floating footnote superscripts are reattached to their numbers, and the multiplication sign the text layer drops from "200 × 300 μm" is restored;
- FIGURE4's group Ns are partly **derived** (ANOVA df + the NeuN-exclusion sentence), flagged per row in `n_group_basis`;
- group labels are harmonised (text's "high solvers" → the tables' "Solver") in the build scripts.

Everything else is mechanical, and the extractor refuses to overwrite a frozen snapshot that differs from what it extracts (it writes `*_snapshot_NEW.csv` for review instead).

## Cross-item provenance notes
- **Text–table discrepancy (TABLE 3):** Results §3.3 prints nonsolver fusiform x̄c = 0.79; the table prints 0.71 ± 0.27. Table value used, recorded, not corrected.
- **Not built (candidate text item):** somatosensory-cortex total nuclei group means are printed **only in the Results §3.1 text** (x̄c = 242,337,500 / 214,821,875 / 270,594,097; no significant differences). If wanted, register a `Jacob_etal_2021_text` item and build it as a constructed snapshot — owner decision.
- Species key: `_keys/HerculanoHouzel/species_key.csv` (isotropic-fractionation lineage; Herculano-Houzel is a co-author) — the four items are listed on the *Procyon lotor* row.
