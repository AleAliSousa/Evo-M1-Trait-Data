# Primary census follow-up and population social data — 2026-10-23

## What was added

| EvoM1 species | Numerical evidence | Treatment |
|---|---|---|
| Oryctolagus cuniculus | 15 reported population means, 1.5–10; equal-weight mean 4.14 | Source-specific mean-of-population-means; all 15 site rows retained. Originating team's 2016 re-report explicitly links the 2015 field censuses. Not an independent replication. |
| Rattus norvegicus | Approximately 50 in one farm colony | Primary author estimate from camera traps and field signs. Population-colony label; not a precise census or a social-subgroup mean. |
| Mustela putorius furo | 39 single and two double occupied dens among 41 excavations; derived mean 43/41 | Separate den-occupancy label. Selected occupied dens, potentially repeated animals; not stable group size. |

These are different quantities, not three interchangeable species-wide group-size means. The rabbit values are from the original study team, but the 2015 full text remains to be obtained for direct checking of the underlying census/age scope. The rat count is approximate. The ferret passage was visually checked in the publisher PDF. Definitions expose these limits.

Numerical social/population-group coverage increases from 1,068 to 1,070 species and 19 to 21 of the 25 EvoM1 species. Social-group labels alone increase from 845 to 846 species and 18 to 19 EvoM1 species. Including the separately named den-occupancy metric gives 22/25 EvoM1 species with at least one of these distinct numerical quantities. This last count is broad availability, not completion of conventional social-group size.

Still no verified census extracted for **Tupaia belangeri, Mus musculus and Urocitellus parryii**. Conventional social/population-group size also remains missing for the ferret; den occupancy does not close that particular gap.

## Broader mammal data

- **Jaeggi et al. 2020:** full author workbook; 245 population records across 100 species. All original population locations, adult sex-composition indicators and citation strings retained. Adds social-category coverage for 18 species.
- **Qiu et al. 2022:** recovered author S5 archive; 141 records across 65 printed species, rather than the full reported 149 populations. Both model-included and missing-covariate-excluded rows are preserved. The merge includes 64 species and adds category coverage for 34 species.

Combined category availability increases from 1,024 to 1,076 species; all 25 EvoM1 species already had some category coverage. These population datasets provide **secondary classifications linked to primary field studies**, not new independent primary observations or numerical group sizes. Original papers have not all been re-read. The species summary is the set of recorded population states, never a first/modal state or a conversion of pair-living into the number 2. Species names come from data tables, not phylogenetic stand-in taxa.

## Explicit holds and limits

1. Qiu's excluded-sheet Macropus giganteus row 11 is coded SG, although the publication states SG did not occur. Retained in snapshot, held from merge.
2. Two Ailurops melanotis records lack a verified NCBI identity anchor. ITIS recognizes the species as valid (TSN 709403); do not merge it into A. ursinus. Retained in snapshot, held from merge.
3. Full Qiu Dryad workbook downloads returned HTTP 403; the API download returned 401. The public author S5 archive lacks exact population locations and has eight fewer records than the published total of 149; exact record correspondence remains unverified. Reconcile the full workbook against this subset before replacing it; never append both as independent observations.
4. The mouse follow-up found Jourjine et al. 2025's census/network archive (Dryad 10.5061/dryad.kprr4xhfk; about 11.8 GB) and analysis notebook. Its community-size field is `Mice_Count`, derived from seasonal network communities. Raw/processed records have not been acquired; no values were digitized or inferred from barn population totals, partner counts or plot axes. The published population is the Zurich free-ranging, provisioned barn population; retain domesticus taxon and tagged-animal scope when available.
5. Treeshrew pair-living statements located in reviews trace toward captive studies or other Tupaia species. No count assigned from these statements. For Arctic ground squirrel, primary female-kin/territory studies are identified; colony area in hectares and density cannot substitute for number of members.

## Files and reproduction

Source folders: `Jaeggi_etal_2020`, `Qiu_etal_2022`, `Ziege_etal_2016`, `Modlinska_Stryjek_2016`, `Norbury_etal_1998`. Each has original downloaded evidence, checksums, source snapshots, merge inputs, definitions and a README with source URLs and scope.

`build_population_censuses.py` rebuilds all tables from saved inputs. `population_primary_source_queue.csv` preserves reference strings and prioritizes primary-paper retrieval. `primary_census_six_species_audit.csv` records all six target outcomes. `population_census_coverage.csv` and `population_category_additions.csv` report app-level coverage. Taxonomy evidence is cached in `population_taxonomy_evidence/`, with review decisions in `population_taxonomy_resolution.csv` and source-specific mappings in the General spoke.

Five source-specific labels were wired into supplementary_sources, domain, definitions and authority. No canonical equivalence to generic group size was imposed. The full supplementary build was checked, then the saved output was scoped to the 167 new rows so existing unrelated rows remained unchanged. The local Shiny loader, numerical/category assertions, taxid consistency and authority checks were run. Existing remote-tree download warnings and unrelated missing-definition warnings remain outside this change. No commit or deployment was made.

## Next actions

First recover the full Qiu workbook and the mouse processed community-count table. For numerical breadth beyond EvoM1, use the retained Jaeggi/Qiu population citations as the retrieval queue; extract observed adult/all-age unit sizes separately and identify shared populations before pooling. For the remaining two difficult census searches, prioritize the original T. belangeri field records and McLean's 1982 Arctic-ground-squirrel female-kin paper, rather than repeating categorical claims from reviews.

Source-integrity check: downloaded Office copies gained local custom metadata, while worksheet and document contents stayed unchanged. Original byte streams are now preserved in ZIP archives; the rebuild uses those archived workbooks. Archive checksums and all 15 rabbit site values were independently checked.
