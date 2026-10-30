## Schenker et al. 2005 — Appendix 1 (individual specimen volumes)

Schenker NM, Desgouttes A-M, Semendeferi K (2005). *Neural connectivity and cortical
substrates of cognition in hominoids.* Journal of Human Evolution 49(5):547–569.
doi:10.1016/j.jhevol.2005.06.004.

Registry (`__ReadMe.xlsx`): Item name **`Schenker_etal_2005_Appendix1`**, encoded
`10.1016%2Fj.jhevol.2005.06.004_Appendix1`.

### What the data are

Appendix 1 is an **individual-specimen inventory**: 27 living subjects, each scanned by
in-vivo MRI (`specimen_kind = in_vivo_subject`, not a postmortem histological specimen).
10 anonymized human subjects (`human1`–`human10`, no printed identity beyond an arbitrary
index) and 17 named nonhuman hominoids sourced from the Yerkes National Primate Research
Center (5 *Pan troglodytes*, 3 *Pan paniscus*, 2 *Gorilla gorilla*, 4 *Pongo pygmaeus*, 3
*Hylobates lar*), each with age, sex, rearing history (`HR`=human-reared, `MR`=mother-reared,
`N/A`=not available for humans), and the same 11 bilateral region volumes reported in
Table 1 at the individual level.

### Specimen registration

The 17 named nonhuman individuals are printed specimen identifiers and are registered in
the specimen-crosswalk system:

- `PUB_SCHENKER_2005_APPENDIX1` is registered in the public
  `_keys/specimen_crosswalk/specimen_source_registry.csv`.
- All 17 individuals are entered in the public `specimen_crosswalk.csv` as
  `Schenker-only` rows (canonical id `YERKES-<GENUS><SP>-<NAME>`).
- 13 of the 17 (all *Gorilla gorilla* and *Pongo pygmaeus* individuals, plus 4 of 5 *Pan
  troglodytes*, 2 of 3 *Pan paniscus*, and 1 of 3 *Hylobates lar*) have an exact
  name+species match against Carol MacLeod's private, unpublished Yerkes crosswalk
  (`PRIVATE_MACLEOD_NEOCORTEX_2002`, restricted repository) — see
  `Evo-M1-Trait-Data-restricted/specimen_registry/derived/specimen_crosswalk_restricted.csv`
  for the corresponding restricted rows (`match = "probable"`: identical name and species
  across two independent Yerkes-derived hominoid brain studies, but no accession or explicit
  institutional statement closes the link). `jcarter`, `bo`, `736_il`, and `gibbon4` have no
  match in that private crosswalk and remain public-only entries; absence there does not
  imply they are different animals, only that MacLeod's neocortex subsample did not include
  them (or that they were not de-anonymized in that particular workbook).
- Humans (`human1`–`human10`) are not registered as crosswalk rows: the paper prints no
  identifying information beyond an arbitrary per-paper index.

### Source → Snapshot → Data readable

Printed Appendix 1 → **`Schenker_etal_2005_Appendix1_snapshot.xlsx`** (sheet `Appendix1`) →
`Schenker_etal_2005_Appendix1.R` → **`Schenker_etal_2005_Appendix1.csv`** (use this) + the
public TSV `__Public/comparative-data/10.1016%2Fj.jhevol.2005.06.004_Appendix1.tsv`. Columns:
`reference_tables/Schenker_etal_2005_definitions.csv` — the paper-level dictionary shared
with `Table1`.

### Build transformations

- Keeps one row per individual; `Age_years` parsed as integer, `Rearing_history` kept as
  printed code (`HR`/`MR`/`N/A`).
- Frontal-lobe cortex components (`dorsal_cortex_cm3` + `mesial_cortex_cm3` +
  `orbital_cortex_cm3`) are checked against `frontal_cortex_cm3` to within the paper's
  stated rounding tolerance; a build-time warning (not a hard failure) flags any row where
  they diverge by more than that tolerance.

### QA status

- Source: printed PDF table (p. 3050 of the typeset PDF, "Appendix 1 Individual total
  volumes for each region").
- Frozen snapshot: created; not yet visually re-checked side-by-side against the PDF by a
  second reviewer.
- Expected analysis rows: 27 individuals.
- Observation level: individual specimen (in-vivo MRI subject).
- Cross-check: every row in the built CSV was checked against the printed PDF table and
  matches exactly.
