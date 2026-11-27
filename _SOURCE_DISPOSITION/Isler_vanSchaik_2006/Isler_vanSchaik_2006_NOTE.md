# Isler_vanSchaik_2006 — documented skip (no dataset item)

Isler K, van Schaik CP (2006). Metabolic costs of brain size evolution. *Biology Letters* 2:557–560. doi:10.1098/rsbl.2006.0538. Supplement: `rsbl20060538supp1.pdf` (12 pp.).

## Decision (2026-10-30): DOCUMENTED SKIP — no registry item
- The main paper and the supplement print **no per-species brain, body or BMR values**. Appendix A (supp. p.1) names the brain/body sources of the 313-species compilation as a single list. It gives no species-to-source map, so no `_references.csv` keyed to data rows can be built.
- Appendix C (supp. pp.5–11) prints a Nexus `TRANSLATE` list of 313 numbered taxa and a `TREE Nee` with branch lengths. The tree is an analysis structure, not trait data. It is **not** built here. Isler_etal_2008_Tree.nex is a precedent for a tree item, so the owner could register this tree later as `Isler_vanSchaik_2006_AppendixC`. A Nexus transcribed from the PDF text layer would need a tip-count/parse check before release.
- The species-level values behind the paper live in later releases by the same group: Isler_etal_2008 (registered), Isler_vanSchaik_2012 (registered, 2026-10-29). Use those.

## Source roadmap (secondary sources)
`reference_tables/Isler_vanSchaik_2006_AppendixA_references.csv` has 17 rows. They cover the 14 published sources named in Appendix A, each with its verbatim Appendix A bibliography entry, plus the two unpublished databases (R.D. Martin, G.M. Mace) and the authors' own millet-seed cranial capacities (3 species, n=1 each, values not printed). Columns: `ref_key` (as printed, e.g. `Crile & Quiring (1940)`), `cited_in_column`, `citation`, `note`, `source_location`. Line-wrap breaks in the PDF text layer were joined (`23-\n36` → `23-36`). Nothing else was altered; misspellings (`artiodacytles`) are kept.

Notes recorded verbatim, not corrected:
- the 0.59 g correction of Mace et al. (1981) rodent data (G. Mace, pers. com.);
- `Gittleman (1986)` has no year letter. Its title differs from the 2009 SOM's 1986a;
- `Iwaniuk (2001)` here is the single-author ground-squirrel paper, not Iwaniuk et al. 2001.

Data role of every listed source: secondary relative to this paper (values compiled from them). Appendix B phylogeny references (supp. pp.2–5) are tree sources and are not listed.

Built by an assistant one-off text extraction (PyMuPDF text layer of `rsbl20060538supp1.pdf`, p.1). Every row was asserted to match exactly one Appendix A bibliography entry. Source PDFs unchanged. See also `README.md` (2026-10-29).
