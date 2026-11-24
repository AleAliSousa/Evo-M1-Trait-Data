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
| `same_sources_value_differs` | as above, but the values differ by more than 0.5 % | yes, as before; listed for the owner (a correction, or an error?) |
| `cited_source_has_no_value_here` | a source is an item of the database but holds no value for this species and measure in this merge | yes (the source is not available here) |
| `partly_from_sources_not_in_database` | some sources are items of the database, others are not | yes |
| `cites_sources_not_in_database` | no source is an item of the database | yes |

Each merge lists every Amniote value with its status: `__merging_life_history/life_history_same_data.csv`,
`__merging_supplementary/supplementary_same_data.csv`.

## First use (step 13, 24 November 2026)

| merge | same_data | value differs | source has no value here | partly not in database | not in database |
|---|---:|---:|---:|---:|---:|
| Life history | 10,823 | 814 | 7,388 | 2,052 | 3,682 |
| Additional published datasets (`__merging_supplementary`) | 5,122 | 319 | 10,254 | 3,145 | 4,691 |
