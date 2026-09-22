# Frahm–Stephan individual specimens: a restricted primary source with a narrow public route

## Purpose

Register H. Frahm's unpublished individual-specimen volumetric data (the
material underlying Stephan et al. 1981) in the specimen-crosswalk system, and
draw the line between what that unpublished source can support in the
**public** `specimen_crosswalk.csv` and what must stay in the restricted
companion repository.

## The core problem

Frahm supplied individual-specimen fresh-volume data for 91 animals directly
to this project as an unpublished scan (`frahm_volumes copy.pdf`, 91 pages,
one specimen per page) with a companion transcription workbook. No part of
that scan or workbook is public. A subset of the same underlying measurements
did reach print — through three routes that are *citations of the same
Frahm/Stephan material*, not independent replications:

1. **Smaers et al. (2010), Table 1** prints 16 specimens' neopallium,
   total-brain, and (for 11 of them) basal-ganglia volumes, with the table
   caption crediting the previously-unpublished Stephan/Frahm individual data
   and printing each specimen's **catalogue number**.
2. **de Sousa (2008 dissertation) / de Sousa et al. (2010) Table 1** print V1,
   LGN, and archive labels for a large comparative series; two of those
   archive labels (`1548` for a Pan troglodytes and `A375` for a Gorilla
   gorilla) turn out, on the restricted Frahm scan, to be the same physical
   animals as two of Frahm's numbered specimens.
3. **Todorov et al. (2019)** publishes only species-level log male/female
   volume ratios derived from the unpublished individual records; no
   individual labels are printed at all.

Because (1) and (2) put real, printed values into the public domain while the
identity thread connecting those printed labels back to *which* Frahm
specimen they are runs through the private scan, the same printed label can be
"public" for its measurement and "restricted" for its specimen-level identity
bridge at the same time. `SPECIMEN_INFORMATION_BOUNDARY.md` requires this to
be classified row by row rather than assumed either way.

## Evidence chain

1. `specimen_registry/build_frahm_via_specimen_registry.R` (restricted repo)
   builds **109** rows in the identical
   `specimen_crosswalk.csv` schema: **91** base rows for
   the private Frahm/Stephan specimens themselves, **16**
   rows re-using the matched Frahm canonical specimens under the
   `Smaers_etal_2010` source label, and **2** rows for
   the two direct de Sousa/Frahm identifier overlaps. Every one of these
   109 rows carries `access_class = restricted`, because
   every one cites `PRIVATE_FRAHM_SCAN` and/or `PRIVATE_FRAHM_PIVOTS` in
   `evidence_source_ids` — including the Smaers- and de Sousa-sourced rows,
   whose *measurement* is public but whose *link to a specific Frahm
   individual* is not. Of the 91 base specimens,
   **74** have no public trace anywhere (`match = Frahm-only`)
   and **35** were matched to a public source row.
2. `via_data_source_registry.csv` (public repo) already carried the
   `PUB_SMAERS_2010`, `PUB_DESOUSA_DISSERTATION_2008`, `PUB_DESOUSA_2010`, and
   `PUB_TODOROV_2019` entries recording this exact split, instructing "do not
   add the 16 Frahm-supplied records as an independent team" and "do not
   merge [Todorov] as absolute volumes."
3. The public repo already holds
   `Smaers_etal_2010/Smaers_etal_2010_Table1_Stephan_specimen_data_via_Frahm.csv`
   — **16** rows extracted straight from the printed Table 1,
   each with a `catalogue_number` the paper itself prints ("Printed specimen
   numbers are retained as `catalogue_number`" — its own README). This file
   requires no private evidence to use.
4. Checking those 16 printed catalogue numbers against the
   live public crosswalk (word-bounded match on `primary_identifier` /
   `alternate_identifiers`, scoped to the Hirnforschung/Stephan-Zilles
   collection group) found:
   - **catalogue `280`** (Pan troglodytes) exactly matches the existing public
     `HIRN-PANTRO-SCHIMPANSE-280` (from `MacLeod_etal_2003`, itself registered
     "no private evidence used").
   - **catalogue `1203`** (Hylobates lar) exactly matches the existing public
     `HIRN-HYLOBATES-1203` (same MacLeod 2003 source).
   - **catalogue `375`** (Gorilla gorilla) is plausibly the same animal as the
     existing public `STEPHAN-GORILLA-A375`, but only the `A`-prefixed form is
     printed publicly (by MacLeod 2000/2003 and de Sousa); the `375`/`A375`
     equivalence is confirmed only by the restricted Frahm scan (Frahm code
     203). This is the same unresolved prefix ambiguity already visible,
     un-merged, in the public crosswalk for `HIRN-PANTRO-A280` vs
     `HIRN-PANTRO-SCHIMPANSE-280` — the repository's own prior practice is not
     to close that class of gap on print alone.
   - The remaining **13** catalogue numbers have no existing public row at
     all.
5. The two de Sousa/Frahm direct overlaps (`1548`, `A375`) add nothing new
   publicly: both physical specimens are already public rows sourced from de
   Sousa/MacLeod; only the *fact* that they are also Frahm specimens 202/203
   is restricted, and it stays restricted.

## Recommended treatment (and what was done)

- **2** Smaers-sourced rows (catalogue `280`,
  `1203`) were appended to the public crosswalk under their existing public
  canonical IDs, `access_class = public`, `evidence_source_ids =
  PUB_SMAERS_2010` only, `match = matched`.
- **13** Smaers-sourced rows with no existing public
  match were appended as new public specimens (new `canonical_specimen` IDs
  of the form `HIRN-<GENUS ABBREV>-<catalogue>`), `access_class = public`,
  `evidence_source_ids = PUB_SMAERS_2010` only, `match = Smaers-only`. No
  private source is cited by any of these 15 new public rows.
- **1** Smaers-sourced row (catalogue `375`, Gorilla) was
  **not** merged into `STEPHAN-GORILLA-A375** publicly; the identity bridge is
  restricted-only and already present in the restricted crosswalk.
- The **91** private Frahm/Stephan base specimens and the
  **2** de Sousa/Frahm identity-overlap rows were
  **not** merged into the public crosswalk. They already exist, correctly
  classified `access_class = restricted`, in
  `specimen_registry/derived/frahm_via_specimen_rows.csv` and in the merged
  `specimen_crosswalk_restricted.csv` — no restricted-side work was needed.
- Todorov et al. (2019) remains a source-registry entry with no specimen rows
  in either repository, matching the existing `PUB_TODOROV_2019` instruction.

Public `specimen_crosswalk.csv` went from **390** to
**405** rows (+15).

## The hard rule that governed this

A printed measurement and its specimen-identity bridge can have different
access classes. A catalogue number printed in a public table is public; the
assertion that it is *the same individual* as a code recorded only in a
private scan is not, unless the public evidence alone (matching numbers,
species, and collection, with no ambiguity requiring the private source) can
carry it. Where an ambiguity exists that the repository has already left
unresolved elsewhere on public evidence (the `A`-prefix cases), this note
follows that precedent rather than closing the gap unilaterally.

## What remains unresolved

- Whether Smaers catalogue `375` is the same animal as public
  `STEPHAN-GORILLA-A375` is settled in the restricted repository (Frahm code
  203) but deliberately not asserted in the public crosswalk.
- The `HIRN-PANTRO-A280` / `HIRN-PANTRO-SCHIMPANSE-280` prefix ambiguity
  predates this note and is unrelated to Frahm; it is flagged here only
  because it shaped the `375`/`A375` decision by precedent.
- The 13 newly minted `HIRN-<GENUS>-<catalogue>` canonical IDs have not been
  cross-checked against any other public source in this repository beyond the
  identifier-matching pass run here; if a future source prints one of these
  same catalogue numbers under a different label, that should be resolved as
  a normal specimen match, not assumed.

## Sources cited

- `specimen_registry/build_frahm_via_specimen_registry.R`,
  `specimen_registry/derived/frahm_via_specimen_rows.csv` (restricted repo)
- `unpublished_data/____Unpublished__Frahm_Stephan_individuals/` — scan,
  workbook, README, validation issues (restricted repo)
- `Smaers_etal_2010/Smaers_etal_2010_Table1_Stephan_specimen_data_via_Frahm.csv`
  and its README (public repo)
- `deSousa_etal_2010/deSousa_etal_2010_Table1.csv`,
  `deSousa_dissertation_2008` (public repo)
- `_keys/specimen_crosswalk/via_data_source_registry.csv`,
  `specimen_source_registry.csv`, `SPECIMEN_INFORMATION_BOUNDARY.md`,
  `SCHEMA.md`, `IDENTIFIER_MATCHING_RULES.md` (public repo)
- `_keys/specimen_crosswalk/frahm_provenance_audit.csv` (this pass)
