# Orlin intake: four additional papers — 2026-10-26

Built Burkart et al. (2014), Strier, Lee & Ives (2014), Jacobs et al. (1990), and Pontzer & Kamilar (2009). This is source-database intake: eight registered items, eight public TSVs, and 24 new variable-catalog records. Aggregate merge pipelines are unchanged. Human RA verification remains pending; no human initials or sign-off have been inferred from automated checks.

| Paper | Registered items | Output rows | Contribution |
|---|---|---:|---|
| Burkart et al. 2014 | Table2; TableS7; Figure1 | 24 + 21 + 15 | Group rosters, group-service performance, and approximate species-level prosociality |
| Strier, Lee & Ives 2014 | TableS1; TableS2; TableS3 | 29 + 486 + 35 | Study summaries, annual/group demographic observations, and their published source bibliography |
| Jacobs et al. 1990 | Figure1 | 4 | Hippocampal volume and SE estimates for two vole species by sex; 10 animals per group |
| Pontzer & Kamilar 2009 | TableS1 | 161 | Mammalian daily travel, body mass, litter mass, lifespan, and lifetime reproductive output |

There are 775 output rows, including 35 bibliography rows. These are not 775 independent animals or species: observations, summaries, and bibliography have different units, and several items intentionally describe overlapping evidence.

## Files and registration

Each item includes a frozen source/snapshot, reproducible R reader, analysis CSV, item README, column definitions, and DOI-encoded public TSV. Paper folders include source PDFs, source manifests with SHA-256 hashes, and applicable reference lookups. Figure snapshots retain selected pixel coordinates, calibration, and source crops. Strier TableS2 has a study-membership crosswalk so repeated group/year labels remain distinguishable.

The worktree registry received eight entries at rows 803–810. The local project's current registry was reconciled separately and receives eight entries at rows 857–864; every pre-existing cell/formula is preserved. Local catalog records increase from 4,054 to 4,078, preserving the entire existing prefix. The compatibility catalog is regenerated from that reconciled catalog. Resolve all items by name, not by these audit-only row numbers.

Local destination: `/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data`.

## Validation and limitations

- All eight readers complete; all 72 repository validation invariants pass. Definitions cover every output column, CSV and public TSV contents agree, and the four folder audits pass.
- Independent PDF-text and source-to-output validation passes 9,903 assertions, including every tabular row, numeric field conversion, reference-key resolution, source hashes, and figure coordinate calculations. PDF line wraps and typographic ligatures are normalized for comparison. Pontzer's wrapped `Daubentonia madagascariensis` label was restored before final validation.
- Figure points were visually compared with the source crops. Jacobs absolute means and SEs are approximate, rounded to 0.1 mm³; Burkart prosociality is rounded to whole percentage points. Reading uncertainty is distinct from biological sampling error.
- Jacobs's relative-volume axis prints a ×100 label with 0.04–0.06 ticks. Values remain on the plotted scale, explicitly flagged; no percent conversion or inferred brain volume is supplied.
- Burkart TableS7 criterion percentages are not the overall prosociality outcome. Figure1 supplies that outcome separately and overlaps the group records. Its allocare score is literature-derived; human observations concern kindergarten children.
- Four Burkart roster counts differ from TableS7 counts excluding infants. All 21 comparisons ran (17 agree, four differ); eligibility differences may explain discrepancies. Both printed counts remain intact.
- Strier has 29 studies covering 22 species/subspecies. Its 486 ratio checks yield 445 agreements, 15 discrepancies, and 26 unevaluable rows. Population averages and rounded counts can differ from simple quotients; printed values are preserved, not corrected. Two baboon study blocks reuse group/year labels; their separate mean group sizes reproduce the two published study means.
- Strier cites reference [22], absent from the published bibliography. An explicit unresolved lookup entry accompanies S1 and S2; the S3 item retains exactly the 35 published entries.
- Pontzer is a secondary compilation. Methods identify Carbone et al. (2005) and Ernest (2003), without per-row primary-source assignment. Daily travel is not home-range area. Lifetime fertility/output are author-derived. Printed order labels, including the anomalous placement of `Halichoerus grypus`, are preserved.

The four paper-level errata files contain 23 proposed publication ambiguities: four Burkart count discrepancies, 15 Strier ratio discrepancies, two Strier missing-reference flags, one Jacobs axis ambiguity, and one Pontzer order-label ambiguity. These are review flags, not confirmed corrections.

QA scripts, logs, digitization overlays, and application evidence are archived outside the public repository at `Evo-M1-Traits-Data-restricted/restricted_checks/orlin_batch4_2026-10-26/`.

All additions are left uncommitted. Existing local changes are preserved; commit and merge remain with the owner.
