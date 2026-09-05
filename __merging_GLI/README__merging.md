# Grey-level index (GLI) merge

This merge compiles cytoarchitectonic **grey-level index (GLI)** — the percent area of a cortical
section occupied by cell-body somata versus neuropil (Schleicher & Zilles, 1989) — across the
built dataset items that measure it directly. It is modelled on `__merging_cortical_layers`: a
small set of primary tables, long-format output, explicit documentation of scope and limits.

## Founder source

`PalomeroGallagher_Zilles_2018/PalomeroGallagher_Zilles_2018_TableS3.csv` — per-specimen GLI
(mean over all layers, and by stratum: supragranular/granular/infragranular) for areas **44 and
45** (Broca-region homologs) in 7 species (human, bonobo, chimpanzee, gorilla, orangutan, gibbon,
macaque). `data_role = primary`. See that item's own README for full provenance.

## Gap check re-verified this pass

The founder item's README already flagged that Palomero-Gallagher & Zilles (2018) Fig. 15 compares
its area 44/45 GLI against GLI reported for other areas in four other papers: area 10
(Semendeferi et al. 2001), area 13 (Semendeferi et al. 1998), V1/V2 (de Sousa et al. 2010), and area
4/M1 (Sherwood et al. 2004). This pass re-checked, rather than assumed, that claim:

1. **Grepped every built CSV in the repo** (excluding `__Public/` and `_checks/`) for
   `GLI|grey.level|gray.level|neuropil`. None of `Sherwood_etal_2004`, `deSousa_etal_2010`,
   `Semendeferi_etal_1998`, `Semendeferi_etal_2001`'s existing built CSVs carried a GLI or
   grey-level column — confirmed directly by inspecting their headers:
   - `Sherwood_etal_2004_TABLEI.csv`: whole-brain/neocortex/hippocampus/striatum/thalamus/
     cerebellum volumes only.
   - `Sherwood_etal_2004_unpublishedviaDeCasien.csv`: brain/thalamus volume only.
   - `deSousa_etal_2010_Table1.csv` / `_SupTable2.csv`: brain, neocortex, V1, LGN volumes only.
   - `Semendeferi_etal_1998_TABLE2.csv`: brain and area-13 volumes only.
   - `Semendeferi_etal_2001_TABLE2.csv`: brain and area-10 volumes only.
2. **Checked each paper's source PDF for an un-extracted GLI table**, since a built CSV lacking
   GLI does not prove the *paper* lacks one:
   - `Sherwood_etal_2004` (`Sherwood-2004-Brain structure variation in gre....pdf`, 16 pages):
     **no GLI table.** Zero hits for `GLI` or `grey/gray-level` anywhere in the PDF text. This
     paper measures gross volumetric brain-structure variation, not cytoarchitectonic stain
     density — it is not a GLI source despite being cited in Palomero-Gallagher & Zilles' Fig. 15
     comparison.
   - `deSousa_etal_2010` (`deSousa_etal_2010.pdf`, 12 pages): **no GLI table** — a single incidental
     `GLI` string hit, not a data table. This paper reports V1/LGN/neocortex volumetry, not GLI.
   - `Semendeferi_etal_1998` (`semendeferi_etal_1998.pdf`, 27 pages): **has a GLI table** — Table 4,
     "Grey-Level Index in area 13" (29 GLI mentions in the text). Not previously built in this
     repo (the existing `Semendeferi_etal_1998_TABLE2` item covers only Table 2 volumes; its
     README flagged Tables 4-5 as unbuilt beyond a cell-count pointer, and `__merging_cellcounts`
     was checked and confirmed to carry no GLI column). **Extracted and built this pass** as
     `Semendeferi_etal_1998_TABLE4_GLI` (see below).
   - `Semendeferi_etal_2001` (`semendeferi_etal_2001.pdf`, 18 pages): **has a GLI table** — Table 3,
     "Grey-level index in area 10" (25 GLI mentions). Same situation as the 1998 paper: not
     previously built. **Extracted and built this pass** as `Semendeferi_etal_2001_TABLE3_GLI`.

So the original claim ("Sherwood/de Sousa/Semendeferi are cited for GLI comparison but not built
here") was **half right**: it holds for Sherwood 2004 and de Sousa 2010 (genuinely no GLI table in
the source), but not for the two Semendeferi papers, which do report per-area GLI tables that had
simply not been extracted into this repo yet. Both have now been built as new primary items.

## Sources in this merge

| Source | Area(s) | Species | Granularity | data_role |
|---|---|---|---|---|
| `PalomeroGallagher_Zilles_2018_TableS3` | 44, 45 | human, bonobo, chimpanzee, gorilla, orangutan, gibbon, macaque (*Macaca fascicularis*) | per-specimen (2-4 named individuals per species) | primary |
| `Semendeferi_etal_1998_TABLE4` (renamed from `..._TABLE4_GLI` to match the registry row already added to `__ReadMe.xlsx`) | 13 | human, chimpanzee, bonobo, gorilla, orangutan, gibbon, macaque (*Macaca mulatta*, "rhesus monkey") | species-level (one right hemisphere/species; SD = across measurement locations, not specimens) | primary |
| `Semendeferi_etal_2001_TABLE3` (renamed, same reason) | 10 | same 7 species as the 1998 companion paper | species-level (one right hemisphere/species) | primary |
| `Sherwood_etal_2004_I_Table4` (**pre-existing item, already FINISHED before this session** -- folded in this pass; note this is the `Sherwood_etal_2004_I` folder, a *different* item from the plain `Sherwood_etal_2004` volumetric item checked in the gap-check above) | 4 / M1 | macaque (*Macaca fascicularis*), *Papio anubis*, orangutan, gorilla, chimpanzee, human | species-level, agranular cortex (layers II/III/V/VI only -- **no granular/layer-IV stratum**, `GLI_pct_mean_granular = NA` for every row) | primary |

## Update: Sherwood and de Sousa, added on request

A later pass, prompted by new `__ReadMe.xlsx` rows the project owner added for Semendeferi,
Sherwood, and de Sousa, re-checked both:

- **Sherwood**: the gap-check above correctly found no GLI in the plain `Sherwood_etal_2004`
  item (whole-brain/neocortex/etc. volumes only) -- but missed that a *separate* folder,
  `Sherwood_etal_2004_I` (same 2004 DOI-adjacent paper series, Table 4 "GLI values for each
  cortical layer"), already existed in the repo, fully built and `FINISHED`, with M1 (area 4)
  per-layer GLI for 6 species. That item is now folded into `GLI_long.csv` /
  `GLI_species_area_stratum_comparison_qa_*.csv` as a 4th source (`area4_M1`). M1 is agranular
  cortex, so it contributes `all_layers`/`supragranular`/`infragranular` rows only, no `granular`
  row.
- **de Sousa**: the owner added a registry row for `deSousa_etal_2009_Table2` ("RMA regressions
  of V1, V2, and VP GLI values on brain and visual system variables") -- now built as its own
  item (`deSousa_etal_2009/deSousa_etal_2009_Table2.csv`, primary, TSV written). This table is
  **regression statistics** (slope/intercept/R2/p of GLI vs. brain/visual-system size), not raw
  per-species GLI values, so it is **not** folded into `GLI_long.csv` (nothing to reshape into a
  species x area x stratum row). The raw values behind it are plotted in de Sousa et al. 2009
  Fig. 6/7, not printed in any table found in this PDF -- V1/V2/VP raw GLI therefore remains
  unavailable in tabular form; see that item's own README.

## Outputs

- `GLI_long.csv` — **166 rows** (148 from the three founder/Semendeferi sources + 18 from
  Sherwood_etal_2004_I): one row per (species, specimen, area, stratum), reshaped from the
  three sources' wide `GLI_pct_mean_*` columns into long `stratum` values
  (`all_layers`/`supragranular`/`granular`/`infragranular`). Carries `Species`,
  `species_as_published`, `specimen_as_published`, `area_as_published`, `n_specimens`, `stratum`,
  `GLI_pct`, `source`, `source_role` (`founder` vs `added_this_pass`), `source_location`,
  `data_role`.
- `GLI_species_area_stratum_comparison_qa_long.csv` — species x area x stratum means (averaging
  the founder's multiple specimens per species down to one value per species, for comparability
  with the two species-level Semendeferi sources), with `n_specimens_contributing`.
- `GLI_species_area_stratum_comparison_qa_wide.csv` — the same, pivoted wide (one row per
  species/source, one column per area x stratum) for a side-by-side look across areas 10/13/44/45.

## Known limitations

1. **Five of the seven human-brain-evolution comparison areas from Fig. 15 are now covered:**
   44/45 (founder), 13 and 10 (Semendeferi, added this pass), and 4/M1 (Sherwood_etal_2004_I,
   folded in this pass — a pre-existing item that the first gap-check pass missed because it
   checked the wrong Sherwood folder). **V1/V2 (de Sousa) GLI remains unavailable as a table**:
   de Sousa et al. 2010 (volumetric only, confirmed no GLI in CSV or PDF) is not a GLI source at
   all; de Sousa et al. 2009 does measure V1/V2/VP GLI, and its regression table (Table 2) is now
   built as `deSousa_etal_2009_Table2`, but the raw per-species GLI values behind that regression
   are only in Fig. 6/7 (not a table) and are not extracted here — see that item's README.
2. **No true cross-source reconciliation is possible.** The founder is per-specimen (2-4 named
   individuals per species); the two Semendeferi sources are species-level single-hemisphere means.
   `GLI_long.csv` stacks them; it does not average across sources or areas. Comparisons in the QA
   tables are species x area x stratum, not a single cross-area composite.
3. **Macaque species differ across sources** and are not the same taxon: the founder's macaque is
   *Macaca fascicularis*; both Semendeferi papers used *Macaca mulatta* ("the rhesus monkey",
   confirmed in each paper's Materials and Methods). Rows are kept as their own published species
   binomials — do not collapse "macaque" to one row across sources.
4. **Different measurement methods/scales are nominally the same metric but not necessarily
   directly comparable.** All four papers use the Schleicher & Zilles (1989) GLI method, but
   Palomero-Gallagher & Zilles (2018) values are markedly lower in an absolute sense than the
   Semendeferi values for the same species (e.g., human area 44 GLI ~13-15 vs. human area 13 GLI
   ~14 vs. area 10 GLI ~15 — areas differ, but cross-paper methodological details such as staining
   protocol and measurement-field size are not verified identical here). Treat cross-paper,
   cross-area comparisons as illustrative, not as a controlled comparison.
5. **The two new Semendeferi items are not yet in `__ReadMe.xlsx`.** Per repo convention, registry
   rows are staged (not written directly to the workbook, which may be open concurrently) in
   `Semendeferi_etal_1998/__ReadMe_row_to_add_TABLE4_GLI.csv` and
   `Semendeferi_etal_2001/__ReadMe_row_to_add_TABLE3_GLI.csv`. The owner should paste each as
   values into the first empty `Sheet1` row and run `_tools/file_list.R`.
6. **No public TSV has been written yet** for the two new items — that step requires the workbook's
   `Item encoded` lookup, which in turn requires the registry rows above to be inserted first.

## Rebuild

Run from the repository root:

```sh
python __merging_GLI/GLI_compiled.py
```

This reads the three source CSVs directly (all already built; no upstream `Rscript` step is needed
for the founder or the two new items — their build scripts, if the source PDFs change, are
`Semendeferi_etal_1998/Semendeferi_etal_1998_TABLE4_GLI_snapshot.csv` /
`Semendeferi_etal_2001/Semendeferi_etal_2001_TABLE3_GLI_snapshot.csv`, manually transcribed from
each paper's Table 4 / Table 3 respectively — there is no digital-native source file for either).

## New items built this pass

- `Semendeferi_etal_1998/Semendeferi_etal_1998_TABLE4_GLI.csv` (+ `_snapshot.csv`, `.README.md`,
  `reference_tables/..._definitions.csv`, `__ReadMe_row_to_add_TABLE4_GLI.csv`)
- `Semendeferi_etal_2001/Semendeferi_etal_2001_TABLE3_GLI.csv` (+ same set of companion files)

Both are `data_role = primary`, species-level (n_specimens = 1 per row, one right hemisphere per
species), for cytoarchitectonic areas 13 and 10 respectively, extracted from the PDF text layer of
each paper's own Table 4 / Table 3 (no digital supplementary spreadsheet exists for either paper).
