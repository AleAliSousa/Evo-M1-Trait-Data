# Combined brain size for quick plots

The Shiny dataset **Combined brain size** supplies two paired predictors:

- **Brain mass (all usable sources) (g)**
- **Brain volume (all usable sources) (mL)** (mL = cm³)

Both use the same contributing reports and weights. They are alternative
representations of one broad brain-size predictor, not independent traits.
The existing basis-specific measurements and the older, measured-first mass
selection remain available for method-specific analyses.

## Conversion convention

[AnimalTraits' methods](https://doi.org/10.1038/s41597-022-01364-9) standardize
brain volumes to mass using **1.036 g/mL**. We use `M[g] = 1.036 * V[mL]`
and its inverse, converting each report before aggregation. mm³ is divided by
1,000 to obtain mL. Small values are not rounded to four decimal places.

A reported volume stays unchanged in the volume representation. A reported
mass stays unchanged in the mass representation, including a source's already
calculated gram-valued estimate. The other representation is a new estimate.
For an existing calculated mass, division by 1.036 is a **density-equivalent
volume**, not an assertion that we recovered the original volume. Historical
compiler conventions (e.g. Burger's 1 g/cm³ or Weaver's fossil corrections)
are not silently inverted or applied a second time. Original conversion
evidence remains attached in the contribution table and upstream basis keys.
Thus this is an AnimalTraits-style common-scale predictor, not a reconstruction
of every source's original measurement. No original source value is rewritten.

Endocranial capacity is retained as a labelled **proxy**: multiplying by density
does not subtract meninges or CSF, and the volume output is not wholly measured
brain tissue. Fresh/fixed preparation, source-specific boundaries and proxy
methods remain in provenance; this broad predictor does not correct shrinkage
or remove method bias. The density was established for fresh vertebrate brain
tissue; its extension to other taxa follows AnimalTraits' convention.

## Inputs and qualification

1. Eligible whole-brain mass rows in `brain_mass_unfiltered.csv`, including
   explicitly estimated masses. Existing row exclusions, unresolved-basis
   review records and olfactory-bulb-excluded masses stay out.
2. `Total_brain_net_volume_Vol.mm3` reports from the volumes merge, restricted
   to the source contributions selected in its current long table. Regional
   volumes and superseded Stephan tables are not introduced as whole brains.
3. The ECV merge's source rows, applying its explicit upstream-team reprint
   exclusions and retaining sex scope. Sexes
   are combined for this view, as in AnimalTraits' default aggregation.
4. The registered AnimalTraits observations TSV, including all animal classes.
   Exactly one representation is read per observation: its original volume
   when available, otherwise its standardized mass. Original and standardized
   columns never count as separate observations. AnimalTraits remains secondary
   provenance here; an original source is not promoted merely by being cited.

Species use the existing source-aware resolver. Unspecified `sp.`/`spp.` and
explicitly pooled species labels remain in the audit but not in species plots.
The app's existing display aliases are applied before pooling so each displayed
species has one paired result; `Species_input` preserves the incoming label.
This builder makes no species reidentifications or taxonomic-order assignments.
Known non-taxon text and ambiguous placeholders in
`_keys/navigation_taxonomy_review.csv` are excluded with their existing repair
actions. For Soria's legacy `Not recognised` rows only, an exact unique match
within its original source table recovers the explicit `species` field instead
of the PHYLACINE placeholder; this field repair is recorded in source evidence.
Unmatched or ambiguous cases remain excluded for repair. Missing taxonomic
Order alone never excludes a genuine animal.
"All usable sources" refers to these qualified input streams, not every
unreviewed brain-like column anywhere in the repository.

## Aggregation and repeated sources

[AnimalTraits' supplied aggregation function](https://github.com/animaltraits/animaltraits.github.io/blob/main/R/AT-functions.R)
defaults to a sample-size-weighted arithmetic mean, combining sexes and excluding
unspecified species. We follow conversion-before-averaging and that arithmetic
mean. Two adaptations are necessary for this repository's mixed compilations:

- **Repeated sources:** the established source-team labels are retained.
  AnimalTraits references with an exact DOI pointing to one registered team
  inherit that team. Within a species/team we select one source/representation:
  primary first, then fully documented sample sizes, native mass, newest year,
  most reports, and source name as a deterministic tie-break. All observations
  within that selected source are retained. If a species has primary reports,
  secondary reports remain fallback/audit data. The selected reports are then
  pooled across teams; there is no measured-mass priority across teams.
- **Incomplete sample sizes:** AnimalTraits' `sampleSizeValue`, Burger's
  `Sample_size.brain`, DeCasien's `N`, and documented brain/individual counts
  from Frahm 1998, Röhrs 1986, Meyer 1981, Weaver 2001 and Jacobs & Spencer 1994
  are read explicitly (`N_SPECS` in the builder; evidence is in each item's
  `reference_tables/*_definitions.csv`). Adapters
  match source species and original value; ambiguous matches or nonnumeric
  sample-size ranges stay unknown. Other inputs currently lack a documented
  sample-size adapter. Unknown n receives weight 1 per report, which is an
  equal-report fallback, **not an assertion of one animal**. A count of reports
  is not a count of independent animals. Source means can therefore be
  underweighted relative to individual records until their n is recovered.

The source-team rule is conservative and does not prove specimen independence.
Different studies within a team may be lost through this selection; unlinked
relays across teams may remain. Each exclusion and the final normalized weights
are exported for inspection. The results are intended for exploratory plots;
the older separate-method traits support checking dependence on these choices.

## Build and outputs

Run `python3 __merging_brain_size/build_brain_size.py` from the repository root
(Python 3 and pandas, used by the shared species resolver). Shiny's
`build_data.R` also runs it after refreshing the source manifest. Rebuild the
upstream mass/volume/ECV merges first when their inputs change.

- `brain_size_long.csv`: two rows per species, read by Shiny; full methods,
  citation item tokens, contributor IDs and unknown-n counts are retained.
- `brain_size_wide.csv`: the same two values side by side.
- `brain_size_contributions.csv`: candidate reports, original quantity/value,
  equations, source evidence, sample-size status, selection decisions and
  final weights. Only `included = True` contributes to the published predictors.
- `brain_size_inputs.csv`: input hashes for build provenance.
- `brain_size_definitions.csv`: authored definitions, also consumed by
  `_keys/build_variable_definitions.R`.

Checks: `python3 -m unittest discover -s __merging_brain_size -p 'test_*.py'`
and `Rscript _checks/shiny_brain_size.R`.

Verified local build, 2026-11-19: 3,328 displayed taxa, 12,562 candidate
reports and 7,911 contributing reports. Sample sizes are documented for 2,164
contributions; 5,747 use the explicit equal-report fallback. Of the species
results, 2,384 include at least one unknown-n contribution. The nine builder
tests, both Shiny integration tests (including actual regression plots), and
the existing species/regression suite passed. The hosted app has not been
updated by this build.
