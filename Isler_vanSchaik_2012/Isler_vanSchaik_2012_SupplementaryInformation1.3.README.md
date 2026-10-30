# Isler & van Schaik 2012 — Supplementary Information 1.3

**Source:** `1-s2.0-S0047248412000577-mmc1.pdf`, pp.3–4, “Sources of social behaviour, breeding system, ecology and life history.” **Role:** bibliographic/scope information, not original measurements.

`Isler_vanSchaik_2012_extract_snapshot.py` reads group blocks and the left then right columns of the single-species list. It freezes 64 blocks: 13 broad taxonomic scopes and 51 explicitly numbered species statements. A citation that wraps onto the next line is retained as one block. The snapshot preserves the text and species-number strings; the matching `.R` writes an analysis CSV and the existing registry-coded public TSV. One source cell can contain multiple works. The supplementary data build resolves these into relational source links, preserving candidate-scope versus explicit-species assignment.

Species numbers refer to the 445-row supplementary workbook, not bibliography numbers. Section 1.3 does **not** identify the source of brain values. Subgroup scope expansion uses the project's family metadata or documented genus membership and never promotes a scope candidate into a proven per-trait primary.

Extracted by Codex on 2026-10-29. The two-column source list was rendered and inspected, including the wrapped Calegaro-Marques citation and the compound Owens years. The R build completed; no human visual-check initials were entered. No primary merge is fed.
