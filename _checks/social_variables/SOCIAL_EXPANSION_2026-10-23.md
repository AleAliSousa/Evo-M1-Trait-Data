# Zhu reconciliation and numerical social coverage — 2026-10-23

## Taxonomy
All 563 previously unmatched Zhu names now resolve: 555 by unique exact NCBI species name/synonym and eight by documented Mammal Diversity Database crosswalks to NCBI identities. The audit retains printed names, accepted identities, taxids, evidence URLs and decisions. Cached query/response evidence is in `taxonomy_evidence/`; `apply_zhu_taxonomy.py` applies the evidence to the hub and Zhu spoke. There are 551 new hub anchors, not 563 new species observations. No Zhu rows were dropped or collapsed: 1,008 species and four categorical variables remain. Resolution of a name does not validate population scope or the underlying biological classification.

The eight crosswalks concern Acrocodia indicus, Ammelaphus imberbis, Nyala angasii, Scarturus elator, Scarturus euphratica, Strepsiceros strepsiceros, Tapirella bairdii and Urva vitticolla. Historical names remain available in the source snapshots and alias audit. Broad Zhu coverage is no longer provisional because of those 563 unmatched names; source classification and historical taxon-scope caveats remain.

## Zhu → Lukas & Clutton-Brock → supporting references
Of 814 Zhu rows explicitly citing Lukas, 801 link to a unique Lukas row (727 exact printed names; 74 identity matches). Thirteen remain unresolved or ambiguous and are flagged rather than fuzzy-matched. Of the linked rows, 780 have matching three-state flags and 21 differ. Pair-living and social monogamy are not equivalent even when flags agree. Zhu's reference list covers multiple traits, so a citation does not identify which reference supports each social state.

`Zhu_Lukas_provenance_trace.csv` preserves every Zhu row, Lukas flags, reference code, bibliography-match notes, and comparison status. Bibliography matches inherited from the Lukas reference table can themselves be approximate; these are not verified primary classifications. `Zhu_Lukas_supporting_source_queue.csv` prioritizes papers by linked rows. Nowak (269 rows) and Dalerum (119) are large secondary-source routes. Twenty-four rows cite Murariu & Benedek and require particular attention: a shrew account must not be assumed to provide direct evidence for all linked species. No conflicting classification has been silently overwritten.

Priority: resolve the 13 name links, review the 21 state differences and the 24 Murariu-linked rows, then follow the large secondary-source routes to their actual observations. These sets can overlap.

## Numerical additions and coverage
Wiafe 2019 contributes four primary reported observations/means, including Chlorocebus sabaeus = 10 individuals per group. Its reported overall summaries do not exactly reconstruct from the rounded sector table and counts; that discrepancy remains explicit. Devillard et al. 2003 contributes Felis catus = 70 in one provisioned feral colony, not a species-wide mean. Both use source-specific labels with population, statistic and age-scope limitations in definitions. The numerical coverage count means an observation is available, not that all quantities are interchangeable.

| Coverage | All species before → after | EvoM1 before → after |
|---|---:|---:|
| Social-group numerical labels | 843 → 845 | 16 → 18 / 25 |
| Population-group numerical labels | 390 → 390 | 6 → 6 / 25 |
| Either type | 1,066 → 1,068 | 17 → 19 / 25 |

The original nine-species gap list missed existing PanTHERIA population-group size 180 for Heterocephalus glaber. That is secondary population-group evidence, not a newly verified social-colony mean. Six EvoM1 species still lack either numerical type: Tupaia belangeri, Mus musculus, Rattus norvegicus, Urocitellus parryii, Oryctolagus cuniculus and Mustela putorius furo. The nine-row `group_size_gap_audit.csv` records each search outcome and the next source-level action.

For broader mammals, prioritize population-level artiodactyl and marsupial datasets and the primary papers behind the vigilance meta-analysis. Audit Kamilar's 253-species compilation for overlap before importing: it already uses PanTHERIA. See `broader_mammal_source_audit.csv`. None of these candidate datasets has been ingested in this pass.

## Verification and limits
The supplementary merge and local Shiny data loader completed. Checks confirm five new numerical rows, 4,032 categorical Zhu rows, no unresolved Zhu rows, all app labels having decided authority, and a consistent 1,515-anchor taxid hub. Both new labels have definitions and domains. Existing unrelated definition gaps (19 labels) and unavailable remote phylogeny warnings remain outside this work. Coverage is computed by `check_social_expansion.R` using local app outputs before and after this pass; the CSV contains the results.

Only Zhu and the two new sources were replaced/appended in the saved supplementary output; unrelated supplementary rows were preserved from the turn-start snapshot. The repo contains concurrent unrelated edits; those were not reverted or committed. No deployment was performed.
