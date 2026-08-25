# App variable organisation & abbreviation support

How the Shiny app's variables are organised, and where the abbreviation
expansions come from. Written alongside the change that introduced
`_keys/glossary.csv`, `_keys/variable_domain.csv` and
`_keys/variable_definitions.csv`.

## The two problems

**1. The organising axis named provenance, not meaning.** The app grouped its
variables by `Dataset` — the seven compiled tables a value could come from
(`Brain-structure volumes`, `Cell counts`, `EvoM1 traits`, `Body & ecology`,
`Brain mass`, `Behaviour`, `Cerebellar folding`). That is useful provenance, but
it is a poor way to *find* a trait:

- Life-history measures sat in two datasets at once (`Gestation` in the body &
  ecology merge, `Neurogenic_period_days` in the trait table).
- `Brain mass` was a top-level bucket holding exactly **one** variable, sitting
  apart from body mass, which is the measure it is nearly always used against.
- `EvoM1 traits` was a grab bag of **87** labels drawn from 84 distinct source
  strings — gyrification, sleep, torpor, diet, life history, interlaminar
  astrocyte morphology, V1 synapse counts and corticospinal fibre measurements,
  all in one undifferentiated list.
- The anatomical and behavioural traits relating to body and ecology — the ones
  this change was prompted by — had no home of their own; they were distributed
  across `EvoM1 traits`, `Body & ecology` and `Behaviour` according to which
  merge happened to carry them.

**2. Variable names were unreadable without the source paper.** The labels are
compositional and full of paper-specific abbreviation. `ILA Subpial Ventral`
means nothing unless you know ILA is *interlaminar astrocytes*, which is
established only in Falcone et al. 2019 — and that folder had no definitions
file at all. Of the app's labels, **only 130 of 429 resolved to any definition**
anywhere in the repo. The single largest gap was the measure-code vocabulary:
`O.n`, `N.p.mg`, `I.p.C`, `p.C.CNS.neurons`, `Vol.mm3` and the rest carry **256**
labels between them and were defined *nowhere*.

## What was NOT wrong

The audit's first pass suggested ten concepts were double-listed (`Diet_Fruit`
and `Diet_Fruit (%)`, `Maximum_lifespan_yrs` and `Maximum_longevity (yr)`, ...).
**That was an artefact of reading the raw merge files rather than the app's
actual startup state.** `_keys/variable_canonical.csv` already carried 27
`action=supersede` rows, and `app.R` already applied them, so the app was
already collapsing every one of those pairs. Replaying the app's own supersede
loop gives **384** distinct labels, not 416; the 76 surviving raw rows are the
documented fallback for species a merge does not cover, which is the mechanism
working as designed. No de-duplication was needed and none was added.

Two candidates were examined and deliberately **rejected**, recorded in
`variable_canonical.csv` as `keep_separate`:

- `Neocortex_mm^3` (Lewitus) vs `Neocortex_Vol.mm3` (volume merge) — only 18 of
  28 overlapping species agree within 1%; *Macaca mulatta* differs by 15%,
  *Perodicticus potto* by 19%. Different measurements, not a duplicated label.
- `Ventricle_mm^3` vs `Ventricles_Vol.mm3` — all 27 overlapping species agree
  exactly, so these *are* the same measurement, but the app's supersede logic
  builds its coverage map from the four merge files only. `volumes_long` is a
  base dataset, so a supersede row would relabel without dropping and produce
  two conflicting rows per species.

## The organisation now

Two tiers, driven by `_keys/variable_domain.csv`, covering all 384 live labels
with **0 unclassified**:

| Domain | Labels |
|---|---|
| brain structure & size | 157 |
| cellular composition | 104 |
| diet & ecology | 22 |
| hand & limb morphology | 22 |
| behaviour & cognition | 20 |
| life history | 18 |
| sensorimotor & motor pathways | 18 |
| cortical & cerebellar folding | 8 |
| sleep & torpor | 7 |
| dataset metadata | 4 |
| body size | 2 |
| metabolism | 2 |

Each domain divides into a **measure class** (37 in total). Where the four merge
files already carried a `measure_class` column, those values are reused verbatim
(`hand_morphology`, `life_history`, `diet_ecology`, `motor_pathway`,
`cerebellar_folding`, ...) — nothing was renamed. The domain tier was added
above them, and the 87 trait-table labels plus 262 volume/cell-count labels were
assigned fresh.

`Dataset` is retained, demoted to a provenance filter under its own heading.
Nothing about the data changed: the baseline row count is identical at 109,248
values over 5,797 species.

Seven labels in `variable_domain.csv` are flagged `is_measurement = FALSE` —
three provenance strings (`Species_Kazu2015`, `Species_as_printed`,
`species_basis`) and four QC flags (`body_mass_approximate`,
`consistency_flags`, `parse_flags`, `source_printing`). Only **two** of those
(`Species_as_printed`, `species_basis`) reach the live app; the other five are
superseded or absent from the compiled tables. A "Measurements only" checkbox —
on by default — keeps them out of the variable pickers and plot axes while
leaving them in the table and download; it removes 130 rows from the 109,248.

Do not confuse this with the `dataset metadata` **domain**, which holds four
live labels: those same two provenance strings plus
`Journal_search_article_count` and `Zoological_record_article_count`. The latter
two are real measurements — Reader et al.'s research-effort denominators — and
stay available, because effort-correcting the innovation counts is a legitimate
analysis.

## Abbreviations

`_keys/glossary.csv` holds **109** terms: 38 structure abbreviations, 28 measure
codes, 23 acronyms, 20 units. Every expansion is traceable to a source in the
repo; none was invented. **13** are flagged `common = TRUE` (g, kg, mm, %, days)
and deliberately get **no** tooltip — the request was for the terms nobody would
know, not for every unit.

Hovering a variable name anywhere in the app shows its definition, the expansion
of each non-common abbreviation it contains, and its unit. A `Glossary` tab lists
both the term table and every variable with its definition and basis. Redundant
lines are suppressed: a definition that already reads "whole-animal body mass"
does not also append "Mass = mass".

Seven publication folders that feed the app had no definitions file; all now have
one in the house schema (`Code,Definition,Structure,Measure,Stat,role,taxon,
Reference,Note,Source Note`), read from each folder's own PDF:

- `Falcone_etal_2019` — TABLE1 (11 codes) + TABLE2 (7). Pial vs subpial ILA,
  the typical/rudimentary scoring rule, the Neurolucida complexity formula.
- `Karl_etal_2024` (17), `Ruf_Geiser_2015`, `Lyamin_etal_2008`,
  `Eagleman_Vaughn_2021`, `HerculanoHouzel__2015`, `Reader_Laland_2002`.

### Definition coverage

All **384** live labels now carry a definition, up from 130 of 429. Of those,
**148** are quoted from a source publication's definitions file and **236** are
composed from the structure and measure-code glossaries — because the label
itself is a composition. `definition_kind` records which, so a reader can always
tell a quoted definition from a derived one:

    Amygdala_O.n   ->  "Amygdala: number of other (non-neuronal) cells"   [composed]
    ILA total length -> "summed length of all processes of a pial ILA, in
                         micrometres, averaged over the cells reconstructed
                         per species"                            [source_definition]

## Files

Authored keys (reviewable in the repo, not buried in app code):

- `_keys/glossary.csv` — term, expansion, definition, kind, `common`, source.
- `_keys/variable_domain.csv` — label to domain / measure class / Structure /
  Measure / Unit / `is_measurement`.
- `_keys/variable_definitions.csv` — **generated**; do not hand-edit.

Scripts:

- `_keys/build_variable_definitions.R` — resolves every label in four passes
  (whole-label source definition; crosswalk where the app label differs from the
  source `Code`; compose structure + measure code; concatenate glossary terms),
  recording which pass won. Re-run after editing a definitions file, the
  glossary, or `variable_domain.csv`.
- `__ShinyApp/build_data.R` — bundles the three keys into `__ShinyApp/data/`.

Order of operations after changing a definition:

    Rscript _keys/build_variable_catalog.R          # if a definitions file changed
    Rscript _keys/build_variable_definitions.R
    Rscript __ShinyApp/build_data.R

### Two traps worth knowing

**The crosswalk is disambiguated by source folder, not by name.** Reader et al.
2011's `Tool_use` is a *report count*; Heldstab's `Tool_use` is *categorical*,
and both definitions files say never to pool them. An early attempt matched
labels to definitions by normalised name and silently attached the categorical
definition to the count variable. The crosswalk in
`build_variable_definitions.R` therefore carries `(label, code, folder)` triples.

**Rscript often runs in the C locale.** Definitions quote micro signs, en-dashes
and modifier circumflexes. In a C locale `write.csv` cannot represent these and
silently writes R's display escapes (`<U+00B5>`) into the file. The builder reads
with `encoding = "UTF-8"` and writes raw bytes via `writeBin` to bypass the
locale entirely. If you refactor the write step, check
`grep '<U+' _keys/variable_definitions.csv` comes back empty.
