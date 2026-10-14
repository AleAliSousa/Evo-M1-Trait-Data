# Elston_etal_2005_b_TABLE3 — prepared scientific item, not a certified repository build

## Source identity and scope
Elston et al. (2005), *Specialization in Pyramidal Cell Structure in the Sensory-Motor Cortex of the Chacma Baboon (Papio ursinus) With Comparative Notes on Macaque and Vervet Monkeys*. The Anatomical Record Part A **286A:854–865**, printed DOI **10.1002/ar.a.20217** ([article](https://doi.org/10.1002/ar.a.20217)). Source locus: **TABLE 3, printed p.862**.

Naming follows the actual baboon article and existing registry publication token **Elston_etal_2005_b**, not the physical source folder. The repository's a/b PDF placement is inconsistent: the baboon original is physically under a and the original under b is a different vervet publication. **Both originals remain unchanged and in place. Owner source-placement resolution is required.** Neither PDF nor page renders are part of this payload.

Exactly the four baboon Tables 1–4 are prepared. Figure 6 spine-total estimates, cross-species comparisons and additional tables/figures are excluded. No macaque or vervet values are silently added.

## Frozen evidence and reader
AI assistant transcribed the identity-verified baboon PDF on **2026-10-10**, using its text layer plus newly rendered actual baboon pages (p.861 table rotated for reading). Caption, headers, source order, footnotes, printed scaled strings, ± combinations and meaningful missingness are preserved in `Elston_etal_2005_b_TABLE3_snapshot.csv`. Unicode μm²/10⁴/ᵃ/±/– represents printed glyphs without changing value. This is a published-view CSV, **not** a cleaned dataframe copied twice.

Numerical means in the verified baboon PDF use the Roman font (captions use bold); **no numeric bold annotations were fabricated** from maxima. Table 2 source superscript a is preserved; it must not be confused with the numeric bold styling in the separate vervet article. This is AI source review, **not human by-eye visual curation**.

`Elston_etal_2005_b_TABLE3.R` reads the frozen file and the item-scoped `reference_tables/Elston_etal_2005_b_TABLE3_context.csv`; all cleaning, long reshaping, numeric typing, context joins and conversions are implemented in R. It locates its own saved reader using source-frame `ofile` **and** `file` before a wrapper's `--file`, derives `folder`, `base`, `item_name` and uses `utils::`-qualified I/O for a base-environment parent. `Elston_etal_2005_b_TABLE3.csv` is an actual **Python-generated analysis preview**, not output from executed R.

## Transformations and scientific limits
All 150 printed area × bin positions are retained in three source panels, including actual bare zeros, 46 en-dashes and area 6 at 281–290 μm bare 1. ± splits only when printed; missing SEM remains unknown for every bare value. Dashes are unavailable, not zero. The printed bins remain 0–10,11–20,...291–300, not shifted/interpolated. Ten randomly selected dendrites of different neurons per area (50 total) is established, but the contributor n at endpoints is unknown. Area 5 at 11–20 prints 0.20 ± 1.33 and at 51–60 prints 11.20 ± 0.01: both retained without correction. Prose p.858 says proximal spine density zero, while area 6 first bin prints 0.10 ± 0.10: contradiction retained and flagged. Bare distal 1 is not converted to an inferred pair or filled into surrounding dashes.

All areas come from **one wild-caught adult male Papio ursinus, B2, 23 kg (23000 g), exact age unknown, LEFT hemisphere**. Only basal dendrites/cells at the **base of layer III** are included; 2D tangential camera-lucida drawings, 250 μm sections, apical collaterals excluded. 258 cells were injected and 141 analysed across the five areas; these global workflow counts are not independent biological n. Technical cells/dendrites are **not animals**, and B2 does not mean n=2. The five areas and repeated bins/tables are dependent observations. Methods link B2 to visual/cingulate papers; the specimen crosswalk remains unresolved. No historical name is replaced by an inline accepted-taxon mapping, and no canonical anatomy or merge compatibility is assumed.

Context is join-ready by **Reference + cortical_area** and identifies its printed passage/table dependency. Every analysis column is documented by exact ten-column definitions (`Code,Definition,Structure,Measure,Stat,role,taxon,Reference,Note,Source Note`), with blank Measure for metadata and method/observation notes. `merge_eligible=FALSE` keeps scientific and owner holds visible.

## Registry and publication gates
Tables 1–3 have exact current registered names; Table 4 is absent. The current Table 1 registry Data role is **both**; an item-scoped **primary** proposal is justified because these four tables contain wholly original baboon-only measurements and exclude the secondary cross-species comparison material. **No registry role is automatically changed.** Table 2/3 descriptive completion and Table 4 registration are owner-only proposals. Generated B/E:L, DOI override C, existing Progress stage and human visual curation are not overwritten; blank proposals mean no change, not clearing.

The reader re-reads the real current registry by exact Item name at invocation; publication requires matching baboon DOI/citation/publication identity and safe existing Item encoded, plus explicit `evom1.publish` and `evom1.elston_owner_release` options. Defaults are closed; unresolved registration never creates a guessed filename. Table 4 stays analysis-only in this supplied reader even if an owner later registers it.

## Verification and status
**R: NOT RUN.** No R parse, clean-session run, audit/dry-run/build/validation or package availability is claimed. Source/Python/static checks only. Python checks cover all source numeric strings, source-to-preview shape, missing-value semantics, scaled conversion, context/sample scope, dictionary coverage and file readback. Future R validation must run each exact item reader separately on an R-enabled local repository (a folder wrapper is not proof of all four readers).

**No public TSV, shared upload, original registry/source/key/merge edit or FINISHED certification.** Source placement, exact taxon/anatomy and specimen overlap, scientific comparability and R execution remain unresolved. Older handoffs and the portable workflow were not changed.
