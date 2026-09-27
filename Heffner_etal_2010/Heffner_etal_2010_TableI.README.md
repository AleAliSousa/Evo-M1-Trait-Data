# Heffner_etal_2010_TableI

## Source
Heffner, R. S., Koay, G., & Heffner, H. E. (2010). Use of binaural cues for
sound localization in large and small non-echolocating bats: *Eidolon
helvum* and *Cynopterus brachyotis*. *Journal of the Acoustical Society of
America*, 127(6), 3837-3845. doi:10.1121/1.3372717

Registry Item **Table I**, printed p. 3841. Public copy:
`Heffner_etal_2010/Heffner-2010-Use of binaural cues for sound lo.pdf`.

**Folder-identity note:** this folder (`Heffner_etal_2010`) actually
contains this 3-author (Heffner, Koay, Heffner) 2010 JASA paper on binaural
localization cues -- NOT a 2010 audiogram paper. The other, superficially
similar-looking folder `Heffner_Heffner_2010` (2-author) contains a
different 2010 paper, the whitetail-deer audiogram (JASA Express Letters).
This was re-verified directly against each folder's own `GetDriveChildren`
listing before building either item; see the cross-check note at the end
of this README.

## Why this item exists
The paper determined whether two non-echolocating Old World fruit bats
(*Eidolon helvum*, large; *Cynopterus brachyotis*, small) can use
interaural time/phase-difference cues for sound localization. Table I is
the paper's own comparative summary: for each of 10 mammal species
(including the two tested here), it lists the frequency range over which
the binaural phase cue is physically available (from the species'
low-frequency hearing limit to the frequency of phase ambiguity) and
whether that species is known to actually use the cue. The table's point is
that physical availability of the cue does not predict its use -- only 2 of
10 species use it despite all 10 having it available over a substantial
frequency range.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Heffner_etal_2010_TableI_snapshot.csv` | frozen source, printed layout incl. footnote citations |
| `Heffner_etal_2010_TableI.R` | reads the snapshot, writes CSV + public TSV |
| `Heffner_etal_2010_TableI.csv` | one row per species (10) |
| `reference_tables/Heffner_etal_2010_TableI_definitions.csv` | data dictionary |

## Data role — mixed, by row
Only the *Cynopterus brachyotis* and *Eidolon helvum* rows are this paper's
own new data (`data_role = "primary"`); the other 8 rows are secondary,
reproduced by the paper's own Table I from Masterton et al. (1975), Koay et
al. (1998a, 1998b), Heffner et al. (2001a, 2001c), Heffner et al. (2010 --
a companion paper on echolocating bats, distinct from this paper), and
Wesolek et al. (2010). Table I's per-species footnote letters were matched
to their citations exactly as printed and carried into the `source` column.

## Observation level
Species-level summary values (not per-individual); each row condenses a
species' own previously-published or newly-measured low-frequency hearing
limit and phase-ambiguity frequency into a single physically-available
octave range for the binaural phase cue, plus a binary yes/no for whether
that species is known to behaviorally use the cue.

## Units
Frequency in kHz; the "available range" column is in octaves
(log2 of the ratio between the phase-ambiguity frequency and the
lowest-audible-at-60-dB frequency, calculated by the paper's authors at a
30 degree angle from midline per Table I footnote "a").

## Cross-check: folder-identity verification (important)
Per the task's explicit warning about a known mix-up between
`Heffner_etal_2010` and `Heffner_Heffner_2010`, both folders were
freshly listed via `GetDriveChildren` immediately before any PDF was
opened:
- `Heffner_etal_2010/` -> `Heffner-2010-Use of binaural cues for sound
  lo....pdf` (this item; 3-author paper, JASA 127:3837-3845).
- `Heffner_Heffner_2010/` -> `Heffner-2010-The behavioral audiogram of
  white....pdf` (a different item; 2-author paper on whitetail deer, JASA
  Express Letters 127:EL111-EL114; built separately as
  `Heffner_Heffner_2010_ResultsText`).

These are confirmed distinct papers with distinct DOIs
(10.1121/1.3372717 vs. 10.1121/1.3284546); no cross-contamination occurred.
