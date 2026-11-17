# Source-row curation decisions

This directory holds reviewed interpretations of source-table rows that are
used before species-level merges. It contains metadata, not another copy of
the observations and not a registered dataset item.

brain_mass_row_basis.csv is the authoritative row-decision table for the
brain-mass stream. Each resolution_id matches a source TSV row and column
through source_records, species, value, and n_expected. It records the
original quantity, measurement basis, upstream reference, source role
override, age scope, pool eligibility, and evidence. The public source TSV
retains the reported value; this file records how that value is interpreted.

brain_mass_value_flags.csv is the authoritative row-veto table for the same
stream. Each entry identifies source rows by Source, Species, and optional
raw_value; n_expected guards the number matched. It records the review flag,
skip action, reason, and evidence. The source TSV keeps the reported value;
vetoed rows are omitted from species pooling and listed in the merge's
brain_mass_vetoed_rows.csv audit output.

Consumers:

- __measurements/build_measurements.py uses the row decision to annotate
  point basis and evidence during inventory.
- __measurements/pilot_metadata/build_pilot.R uses the same decision in the
  metadata qualification gate.
- __merging_brain_mass/build_brain_mass_merge.py and
  __merging_brain_mass/brain_mass_compiled.R apply both tables before pooling.

The merge directory contains derived outputs, not a second authoritative
copy of these decision tables. Edit a decision only when source evidence
supports it; then rebuild the outputs that depend on it.
