# Social-organization merge

Run `python3 Zhu_etal_2023/build_social_organization.py` before the supplementary
merge. This view is derived from the existing source CSVs; their snapshots and
printed species names are unchanged.

Supplementary Data 1 supplies 974 species. Data 3 supplies 34 additional species;
its other 60 rows agree on all three social-state flags and are recorded in
`Zhu_etal_2023_SocialOrganization_overlap_audit.csv`. Data 3 is therefore not
strictly a subset of Data 1. Commas and semicolons delimit the same states.

Four source-specific app variables expose the combined readable category and
three Yes/No state flags. Multiple states remain explicit; No means the source
did not classify that species in that state, not proof it never occurs.
These are nominal categories, not scores or numerical group sizes. They do not
supersede Lewitus's social/mating-system mixture; pair-living is not monogamy.
No cross-source pooling or canonical alias is appropriate without a semantic ruling.

All records are treated as secondary compilations except five Data 3 species
whose notes explicitly state that social organization was observed in this study:
Rhinolophus rex, Kerivoula hardwickii, Murina hilgendorfi, Myotis laniger, and
Pipistrellus javanicus. This is source-reported provenance, not independent
verification of the field observations. Notes about measured body mass or imputed
lifespan do not confer primary status on social organization.

Reference codes and the original table/row ID remain in the derived table and
coverage provenance audit. The supplied reference lists cover multiple traits
in each species row: they do not identify which reference supports each social
state. A matching bibliography entry alone cannot establish the primary social
source or justify replacing another dataset. Existing blanket "Primary" metadata
in the source-table documentation describes the compilation; it is not the
measurement role used by this merge.

Rebuild and check from the repository root:

```
python3 Zhu_etal_2023/build_social_organization.py
Rscript __merging_supplementary/supplementary_compiled.R
Rscript _keys/build_variable_definitions.R
Rscript _keys/build_trait_authority.R
Rscript _checks/check_trait_authority.R
Rscript _checks/social_variables/load_app.R /tmp/zhu_after.rds
# Capture BEFORE.rds with load_app.R before adding Zhu; then:
Rscript _checks/social_variables/check_zhu_coverage.R BEFORE.rds /tmp/zhu_after.rds
```

Coverage uses the actual local Shiny loader and its display aliases, plus the
25-member EvoM1 cohort. Legacy comparison includes Social_system and
Social_system_Zimmermann2017 (category); it measures availability only, not
semantic equivalence. Unresolved taxonomy remains flagged in the merge and
provenance audit; no wild-to-domestic substitutions are introduced.
