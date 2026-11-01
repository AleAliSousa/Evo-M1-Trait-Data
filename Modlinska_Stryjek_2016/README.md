# Modlinska & Stryjek 2016: wild rat colony estimate

Food Neophobia in Wild Rats (Rattus norvegicus) Inhabiting a Changeable Environment—A Field Study. https://doi.org/10.1371/journal.pone.0156741

The authors' Materials and Methods / Animals report approximately 50 rats in one free-living farm colony outside Warsaw. The estimate uses six months of camera-trap observation, burrows, paths, droppings and bait consumption, also citing earlier same-team data. Preserved primary PMC XML: https://www.ebi.ac.uk/europepmc/webservices/rest/PMC4890768/fullTextXML (retrieved 2026-10-23). Not found in local EndNote metadata search.

This is a primary approximate whole-colony population estimate, NOT an exact census, a typical social-subgroup size or a mean of colonies. Age scope is unspecified. The approximate flag and commensal farm context remain in the table and definition. It enters a population-group label, not the generic social-group-size pool.

Rebuild (changed 2026-10-31): `_checks/social_variables/build_population_censuses.py` writes the
constructed snapshot from the PMC XML; `Modlinska_Stryjek_2016_Colony.R` then builds the analysis row
from it, parsing the printed `approx. 50 individuals` and stopping if that wording changes. Output is
unchanged apart from R's `TRUE` spelling in `approximate`. The item is unregistered, so the public TSV
is skipped with a message.

## Snapshot provenance — repaired 2026-10-31

Until 2026-10-31 `Modlinska_Stryjek_2016_Colony_snapshot.csv` was written as a byte-identical copy
of `Modlinska_Stryjek_2016_Colony.csv` — a cleaned analysis row, not the source.

It is now a **constructed snapshot**: the value is stated in prose, so the snapshot carries the
printed wording (`approx. 50 individuals`, `brown rats (Rattus norvegicus)`) with the verbatim
Methods sentence and the method sentence beside it, located at Materials and Methods, subsection
"Animals". `build_population_censuses.py` extracts both sentences from `source/PMC4890768.xml` and
asserts the printed phrase is present, so the snapshot tracks the source rather than the product.
