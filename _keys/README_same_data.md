# Same data reached through two compilations (`same_data.R`, `compilation_cited_sources.csv`)

Owner's rule of 24 November 2026: a compilation's copy of another compilation, or of a primary,
is registered as **the same data, per data point**, and the source it copies is served in its
place. Exceptions are decided in writing, per case: the copy corrected an error of the source, or
the source is not available.

## The key

`compilation_cited_sources.csv` has one row per citation key of a compilation that is an item of
this database: `compilation_paper, ref_key` (as the compilation prints it), `cited_paper` (the
paper folder), `match_basis`, `status`, `note`. Only rows whose status starts with `confirmed` are
used. First filled for the Amniote database (Myhrvold et al. 2015): PanTHERIA (Jones et al. 2009),
AnAge (de Magalhães & Costa 2009 -> `deMagalhães_etal_2024`), Ernest 2003 and Hayssen et al. 1993.
Hayssen's later *Mammalian Species* accounts (2008-2011) are other keys and are not Hayssen 1993.

## The test, per data point

`same_data.R` reads the Amniote database's own per-cell derivations
(`Myhrvold_etal_2015/reference_tables/..._cell_references_part*.csv`): for each Mammalia cell, the
sources that produced its value (the single source, the two sources of a mean, or the record(s)
selected from a median pool). A merge then gives each Amniote value one status:

| status | when | served? |
|---|---|---|
| `same_data` | every source of the value is an item that holds a value for the same species and measure in this merge, and the values agree within 0.5 % | no: counted once, from the source |
| `differs_from_cited_sources` | as above, but the values differ by more than 0.5 % | no (owner, 24 November 2026): a correction must be stated and cite a primary; the Amniote database does neither, so the copy is not a correction and the sources it cites are served |
| `cited_source_has_no_value_here` | a source is an item of the database but holds no value for this species and measure in this merge | yes (the source is not available here) |
| `partly_from_sources_not_in_database` | some sources are items of the database, others are not | yes |
| `cites_sources_not_in_database` | no source is an item of the database | yes |

Each merge lists every Amniote value with its status: `__merging_life_history/life_history_same_data.csv`,
`__merging_supplementary/supplementary_same_data.csv`.

## Copies that differ from their sources (step 14, 24 November 2026)

The owner checked one case (*Marmosa murina* birth weight: Amniote 0.31 g; PanTHERIA, AnAge 2009 and
AnAge 2024 all 0.09 g) and decided: a copy that differs from every source it cites is not a correction
unless the compilation says so and cites a primary. The Amniote database prints no corrections, so
these copies are not served; the sources are. A between-source check of all 1,133 copies (restricted
repository, `restricted_checks/_cross_table/Amniote_copies_vs_cited_sources/`) found that in 509 the
Amniote median or mean holds a record of another species (the *Marmosa murina* median holds two
*Potorous tridactylus* records), 44 match the source version Amniote cites (AnAge 2009, PanTHERIA's
1993-taxonomy edition) and not the one served here, and 531 have no identified cause.

## Counts (steps 13 and 14, 24 November 2026)

| merge | same_data | differs from cited sources | source has no value here | partly not in database | not in database |
|---|---:|---:|---:|---:|---:|
| Life history | 10,823 | 814 | 7,388 | 2,052 | 3,682 |
| Additional published datasets (`__merging_supplementary`) | 5,122 | 319 | 10,254 | 3,145 | 4,691 |
