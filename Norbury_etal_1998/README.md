# Norbury, Norbury & Heyward 1998: ferret den occupancy

Space use and denning behaviour of wild ferrets (Mustela furo) and cats (Felis catus). New Zealand Journal of Ecology22(2):149–159.
Publisher PDF: https://newzealandecology.org/nzje/2045/pdf (downloaded 2026-10-23).

Page154 (PDF page6) was visually verified. Of 41 excavated dens known to contain radio-collared ferrets, two contained another ferret; both pairs were adult males. The count-frequency snapshot retains 39 single-occupied dens (derived by subtraction) and two double-occupied dens. It does not invent identifiers for the individual dens.

Derived mean occupancy = (39×1 + 2×2)/41 = 1.0487804878. This is daytime occupancy of selected occupied dens, not a random sample of independent social groups or an all-season social-group mean. The sample can include repeated animals. A further pair observed by telemetry in November is retained in this note but excluded from the excavation denominator. Ferrets were feral in South Island New Zealand pastoral habitat. Source Mustela furo is an NCBI synonym of the project's Mustela putorius furo anchor (taxid9669).

A separate Den_occupancy_mean_Norbury1998 label prevents inflating conventional group-size coverage. Rebuild with `_checks/social_variables/build_population_censuses.py`.

## Snapshot provenance — repaired 2026-10-31

Until 2026-10-31 `Norbury_etal_1998_DenCensus_snapshot.csv` carried **39** single-occupant dens — a
number the paper never prints. It is derived by subtracting the two shared dens from the 41
excavated, and a snapshot holding a derived value cannot be checked against the page.

The snapshot is now a **constructed snapshot** carrying only printed quantities (`41`, `Two`,
`adult males`, `May and August`) plus the two verbatim sentences from p. 154, subsection "Den
sharing by ferrets". `build_population_censuses.py` opens `source/Norbury_etal_1998.pdf` and
asserts both passages appear verbatim, and warns if pymupdf is unavailable to re-check.

The derived 39 now lives in the analysis layer, `Norbury_etal_1998_DenCensus.csv`, written as
`41-2` with the derivation spelled out per row. `Norbury_etal_1998_DenSummary.csv` is unchanged
(mean 1.048780487804878).
