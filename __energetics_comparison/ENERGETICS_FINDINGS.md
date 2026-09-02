# Brain energetics - cross-paper comparison (Part IV)

Common measures across the energetics papers: **CMRgl** (glucose), **CMRO2** (oxygen), **CBF** (blood flow).
Output: `energetics_long.csv` (schema: reference, species, region, measure, value, units, weighting).

## Coverage
- Heiss_etal_2004: Homo sapiens
- Kaufman__2004: Canis, Capra, Equus, Felis, Homo, Lepus, Macaca, Meriones, Mus, Ovis, Rattus, Sus
- Karbowski 2007: multi-species regional glucose utilization & oxygen consumption -- the source
  xlsx headers are badly OCR-garbled, so it is described here but not yet parsed into the table;
  it needs a dedicated extraction pass (like Stephan 1970).

## Human cortical CMRgl cross-check (independent sources)
- Heiss 2004 mean cortical CMRgl  ~ 33.0 umol/100g/min
- Kaufman 2004 (Homo) cortical CMRgl ~ 37.5 umol/100g/min
  -> same order of magnitude; good independent agreement for human cortex glucose metabolism.

## Proposed schema for an energetics merge (FOR CONFIRMATION - not built)
A long table mirroring `volumes_long.csv` but for metabolic rate:
  `Species, Region, Measure (CMRgl|CMRO2|CBF), Value, Units, Weighting, Source, Team, Year`
with:
- Units standardized to umol/100 g/min (CMRgl, CMRO2) and mL/100 g/min (CBF).
- A region crosswalk to the volume terms (e.g. Cortex<->Neocortex, Thalamus, Cerebellum, ...).
- Two-tier resolution like the volumes (Kaufman/Karbowski/Heiss are independent series -> Tier-2
  teams, averaged), keeping weighted vs unweighted Kaufman means distinct (recommend weighted).

Confirm this schema (units, region crosswalk, weighting choice, whether to include CBF) before an
energetics merge is implemented.
