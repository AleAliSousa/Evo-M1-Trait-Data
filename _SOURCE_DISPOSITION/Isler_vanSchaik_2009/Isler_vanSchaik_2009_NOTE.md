# Isler_vanSchaik_2009 — documented skip (no dataset item)

Isler K, van Schaik CP (2009). The Expensive Brain: a framework for explaining evolutionary changes in brain size. *J Hum Evol* 57:392–400. doi:10.1016/j.jhevol.2009.04.009. SOM: `1-s2.0-S0047248409001286-mmc1.doc`.

## Decision (2026-10-30): DOCUMENTED SKIP — no registry item
- The SOM holds section 1 (compilation methods and two source paragraphs), Tables A1–A3 (multiple-regression and independent-contrast statistics: n, r², estimates, SE, p) and a 78-entry reference list. It holds **no species-level values** and no species-by-source map.
- Tables A1–A3 are model summaries, not taxon data. The registry treats this kind of table as citation evidence, not data (cf. SOURCE_DISPOSITION Deaner_etal_2007_Table1). They are not built. The owner can register them as statistical-summary items if wanted.
- The species-level compilation descends to Isler_vanSchaik_2012 `mmc2.xls` (registered, built 2026-10-29).

## Source roadmap (secondary sources)
`reference_tables/Isler_vanSchaik_2009_SOM_references.csv` has 83 rows:
- 54 brain/body-mass source keys;
- 23 life-history source keys;
- 6 bibliography entries not named in the section 1 source lists.

Every one of the 78 bibliography entries appears exactly once as a `citation`. Keys printed with several years (`Oboussier, 1955, 1964, 1966, 1970, 1972, 1974a, b`) are split into one row per work, with the printed form kept in `note`. Kept verbatim and flagged, never corrected:
- `Milelr et al, 2002` (typo; bibliography `Miller, R.A., ... 2002`);
- `Wasser and Jones, 1991` vs bibliography `Waser, P.M., Jones, W.T., 1991`;
- `Bauchot Ebinger, 1974` — ambiguous, citation left blank, candidates (Bauchot 1985; Bauchot & Stephan 1966; Ebinger 1974) listed;
- `Gittleman, 1986b` cited for brain/body although the bibliography's 1986b is the life-history paper (and 1986a vice versa);
- `the Mammalian Species accounts` and `G. Mace, pers. comm.` have no bibliography entry.

Text read with macOS `textutil -convert txt` (source DOC bytes unchanged). Rows were matched by an assistant script on author list + year. See `README.md` for compilation policies (adult-only, female preference, medians across populations; ~2/3 endocranial volume vs 1/3 fresh mass by order). These are policies, not per-cell types.
