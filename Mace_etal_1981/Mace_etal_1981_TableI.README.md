# Mace et al. 1981 — Table I

Mace GM, Harvey PH, Clutton-Brock TH (1981). *Brain size and ecology in small mammals.* Journal of Zoology 193:333–354. DOI: 10.1111/j.1469-7998.1981.tb03449.x.

## Built item

`Mace_etal_1981_TableI_extract_snapshot.py` extracts PDF pp.5–11 (journal pp.337–343) using the text coordinates, applies the item-scoped, visually checked OCR overlay, and freezes `Mace_etal_1981_TableI_snapshot.csv`. The snapshot keeps all 278 printed species in order, with inherited order/family headings and the original units. Original dashes and meaningful blank cells are not zeros. The ecology columns are captured together, as printed under the combined heading 2345; positional missing codes are not inferred from collapsed OCR spacing.

`Mace_etal_1981_TableI.R` reads that snapshot and writes the analysis CSV and the public TSV named by the existing live registry entry. Brain weight estimates in printed grams are multiplied by 1,000 to mg. Body weights remain g; lengths remain mm. Original numeric lexemes remain alongside the numeric fields. Published species labels remain unchanged; accepted-name candidates come only from the shared resolver and the General publication-scoped key. Unresolved names remain labelled as such.

## Physical basis and data role

**Secondary provenance build, excluded from the measured-brain-mass merge.** This routing must not obscure a finer source distinction: the authors themselves measured the skull capacities. Methods (PDF p.4 / journal p.336) says that the reported brain weights were calculated from braincase volumes, using 2 mm glass beads or X-ray integration for small skulls. These are **endocranial-capacity-derived weight estimates, not weighed brain masses**. The per-species method and the numerical volume-to-weight conversion factor are not supplied; no inverse density conversion is invented here.

Body mass, length and ecology draw on earlier literature. The original paper does not give row-specific body/length citations. Mace 1979 is the named ecological-classification source; Jerison 1969/1973 are method sources, not extra observations. These distinctions are recorded in `reference_tables/*_references.csv` and `*_value_reference_links.csv`. Do not count this table and its later retellings as independent teams.

The later correction subtracting 0.59 g from Mace rodent values is **not applied to the faithful published table**. Boddy 2012 documents that correction via Isler & van Schaik 2006; a corrected-use decision needs a separately governed derivation rather than changing this snapshot.

## Coverage and checks

The printed table contains **278 species**. Seventeen lack body mass, leaving **261 complete brain/body pairs**, matching the analysis count in Methods. All 278 size estimates were retained. There is no additive printed total, so no synthetic table-total check was invented. The R reader checks those coverage counts and the first printed estimate (Aplodontia rufa, 7.63 g / 7,630 mg).

The PDF's OCR layer omits the whole body-length column on pp.10–11 and misreads several decimals/digits. `reference_tables/Mace_etal_1981_TableI_extraction_corrections.csv` records 186 checked cell corrections, including species typography, the missing length cells, and numeric sentinels such as Spermophilus parryi 744.6 g, S. undulatus 725.3 g, Eutamias quadrimaculatus 2.75 g, and Erinaceus europaeus 3.77 g. These are corrections of extraction against the print, not changes to published biology. The extraction helper refuses to overwrite a differing frozen snapshot.

## Build and review record

Built by Codex on 2026-10-29. Source table pages were rendered and visually inspected by the assistant; OCR corrections were checked against those images. R was run in a clean session and the CSV/public TSV were independently reconciled to the snapshot. No human reviewer initials are claimed. A metadata-update workbook is supplied for the existing registry row; the shared registry was not overwritten. No primary merge or app deployment was run.
