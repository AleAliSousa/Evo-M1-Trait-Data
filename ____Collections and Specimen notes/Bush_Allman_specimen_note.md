# Public specimen note: Bush & Allman comparative brain-volume series

## Purpose and evidence boundary

This public note registers what the specimen crosswalk can establish about the
individual animals behind Bush & Allman's three comparative brain-volume papers
(`Bush_Allman_2003`, `Bush_Allman_2004_a`, `Bush_Allman_2004_b`) using only
published evidence. The full evidence chain — accession-level identities, an
author-supplied workbook, and cross-checks against Wisconsin/AFIP, de Sousa,
and Frahm records — is restricted and held in
`Evo-M1-Trait-Data-restricted/specimen_registry/cases/bush_allman/`
(`Bush_Allman_AFIP_specimen_note.md`, `bush_allman_afip_provenance_audit.csv`).

The public and restricted claims must not be conflated. In particular, a
species-level value printed in a Bush & Allman table is public, but the
accession that produced it is not, and the link between the two depends on
private evidence.

## The core problem

Bush & Allman's three papers each print one row per species (45 rows in the
2003 cerebellum table, 55 in the 2004a frontal-cortex table, 22 in the 2004b
V1/LGN table), and none of the three tables prints a specimen accession,
catalog number, or any other individual-level identifier — the `source`
column names the paper, not an animal. This is the inverse of the Pongo case:
there the printed record over-resolves (a broad taxon label hides a pooled
sample); here the printed record under-resolves (a species value hides which
physical animal, or animals, produced it). Neither problem can be closed from
the paper text alone.

Two facts are recoverable from the papers themselves:

1. All three papers draw on the same underlying collection. Their species
   lists overlap heavily, and several species (e.g. multiple galago and owl
   monkey rows) recur across the 2003 and 2004 tables at slightly different
   printed precision, consistent with shared specimens rather than
   independent samples — though the paper text alone cannot say whether a
   given repeated species row is the same individual or a different one from
   the same species.
2. The animals came from a comparative teaching/research collection
   identified elsewhere (Welker / University of Wisconsin comparative
   collection, later transferred toward the National Museum of Health and
   Medicine at AFIP) rather than being wild-caught for these studies.

Resolving *which* accession backs *which* printed row requires the author's
own specimen workbook and correspondence, which are private and therefore
restricted-only (see below).

## Public evidence chain

### 1. The printed tables carry no specimen identifiers

`Bush_Allman_2003_Table1.csv`, `Bush_Allman_2004_a_Table2.csv`, and
`Bush_Allman_2004_b_TABLE1/2/3.csv` were checked column-by-column: every
column is either a species name or a measurement/covariate (group, activity
pattern, diet, group size, ratios). No column carries an accession, catalog,
or specimen code. A public crosswalk row for any of these papers can
therefore identify a **species value**, not an individual animal.

### 2. Brainmuseum.org independently documents a Welker/Wisconsin chimpanzee

The existing public crosswalk row `UW-WELKER-63-307` comes from Brainmuseum's
public chimpanzee atlas page, which prints accession `63-307` from the same
Welker/University of Wisconsin collection lineage that supplied Bush &
Allman's material. This is public, collection-level evidence that the two
sources draw on the same lineage of specimens. It is **not** specimen-level
evidence that `63-307` is one of the animals Bush & Allman measured: no
public source connects that accession number to any Bush & Allman table row,
and the only source that prints a possibly related number (`63-397`) is the
author's private workbook, not a public record. The two are kept as separate,
provisional canonical specimens; see that row's note for the full
cross-reference.

### 3. de Sousa et al. (2010) documents a separate, confirmed Welker/AFIP chimpanzee

The public crosswalk already carries `WELKER-PAN-56-49`, a Welker/AFIP
chimpanzee (archive label `56_49`, dissertation code `ptw1`) established from
de Sousa's public dissertation and 2010 paper. This is a different, exactly
identified animal from the collection lineage Bush & Allman also drew on. It
was not created by this review and needed no change, but it is the clearest
public illustration that the Welker/Wisconsin-AFIP lineage contains multiple,
individually distinguishable animals across different papers.

## Why no new individual-level rows were added here

Every accession-level identity behind a Bush & Allman table row depends on at
least one private source (the author's workbook, a privately supplied 2006
specimen sheet, or private correspondence) — confirmed by checking all 123
rows of the restricted provenance audit, each of which cites one of these
private sources alongside the public paper. Per the repository's public/
restricted boundary rule, an accession-level identity link is restricted
whenever it depends on such a source, even though the species value it
supports is itself printed in a public paper. That is the case here for all
59 individual accessions the author workbook resolves (plus the two separate
Brainmuseum/de Sousa cross-check specimens discussed above, neither of which
the audit treats as an established Bush accession). The restricted companion
repository already carries the full crosswalk-schema rows for those animals
(`specimen_registry/derived/specimen_crosswalk_restricted.csv`);
nothing further belongs in the public file until a public, specimen-level
bridge (an institutional accession record, for example) becomes available.

## Database treatment

At the specimen level:

- The public crosswalk carries no new Bush & Allman accession-level rows; the
  three source-publication registry entries
  (`PUB_BUSH_ALLMAN_2003`, `PUB_BUSH_ALLMAN_2004_A`, `PUB_BUSH_ALLMAN_2004_B`)
  already record that a printed-row-to-accession link stays restricted.
- `UW-WELKER-63-307` (public, Brainmuseum) and `WELKER-PAN-56-49` (public, de
  Sousa) remain distinct, unmerged canonical specimens; both now cross-
  reference the Bush-Allman restricted case in their notes.
- `WELKER_AFIP` is an existing `collection_registry.csv` group; no new
  collection entry was required.

At the concept level:

- No new taxon-concept row is required. This is a specimen/provenance
  problem (which animal produced which value), not a pooled *sensu lato*
  taxon-concept problem — species names in the Bush & Allman tables are used
  in their modern sense throughout.

## Hard rule

```text
species value printed in a Bush & Allman table
    -> public; usable as a species-level measurement

accession/animal that produced that value
    -> restricted; requires the author workbook or private correspondence
       to identify, and must not be inferred from collection co-location
       (Welker/Wisconsin-AFIP) alone
```

## What remains unresolved

- Whether Brainmuseum's public `63-307` is a distinct specimen from the
  Bush-workbook/Reader-sheet `63-397`, or a transcription variant of the same
  accession — unresolved in both the public and restricted layers pending
  institutional (NMHM/UW) documentation.
- Exact custody (Wisconsin vs. AFIP) of the Bush & Allman specimens at the
  time of measurement — a restricted-evidence question; the public record
  only supports collection lineage, not custody dates.
- Any public, specimen-level bridge (accession list, supplementary table)
  that would let individual Bush & Allman animals be registered publicly.

## Public sources

- Bush, E. C. & Allman, J. M. (2003) — cerebellum table (`Bush_Allman_2003_Table1.csv`).
- Bush, E. C. & Allman, J. M. (2004a) — frontal-cortex table (`Bush_Allman_2004_a_Table2.csv`).
- Bush, E. C. & Allman, J. M. (2004b) — V1/LGN/RGC tables (`Bush_Allman_2004_b_TABLE1/2/3.csv`).
- de Sousa, A. et al. (2010) — Table 1 (Welker/AFIP chimpanzee `56_49`).
- Brainmuseum.org — chimpanzee specimen page (accession `63-307`).

## Restricted complement

`Evo-M1-Trait-Data-restricted/specimen_registry/cases/bush_allman/` holds the
full accession-level crosswalk: `Bush_Allman_AFIP_specimen_note.md` (evidence
chain and recommended treatment for all 59 workbook individuals, plus the two
separate Brainmuseum/de Sousa cross-check specimens discussed above) and
`bush_allman_afip_provenance_audit.csv` (123 rows, one per paper-item ×
printed label, each classified `specimen` with its supporting evidence and
hazard). Those details may inform an authorized restricted build but are not
evidence that may be copied into this public note or the public crosswalk.
