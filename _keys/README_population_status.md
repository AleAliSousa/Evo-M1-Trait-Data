# `population_status.csv` — was the animal measured wild, domestic, or a mixture?

A read-time key. **No merge reads it.** It records, for every source that
contributes a value under one of the wild/domestic label pairs in
`species_pooling.csv`, which population the source measured. The Shiny app's
Cohort coverage tab and `__Cytosplore_export/build_cytosplore_traits.R` consult
it when their pooling switch is set to `domestic_evidence`
(see `README_species_pooling.md`); nothing else does, and the default (`off`)
never looks at it.

It exists because the identity resolver cannot carry this information. The
resolver maps a *printed name* to an anchor, and `Sus scrofa` printed by Koay
et al. 1998 for a pig in a hearing study is, as a name, the species *Sus
scrofa*. Which population was in the apparatus is a separate fact, with its
own evidence, and this is where it lives.

## Vocabulary

| `population` | meaning | adopted in `domestic_evidence` mode? |
|---|---|---|
| `wild` | the source measured, or compiles by design, wild / free-living animals | no |
| `domestic` | the source measured domestic animals (laboratory ferrets, farm pigs), stated or shown by the row | yes |
| `mixed` | a compilation whose entry draws on both, not separable per field | yes |
| `unknown` | the row gives no basis to decide | no |

`mixed` and `domestic` both count as evidence that the wild-form label holds
domestic animals' data for that source, which is the owner's stated reason for
the switch ("most such data are from domestic animals"). `unknown` is never
adopted: a key row with no evidence cannot be audited.

## Columns

| column | meaning |
|---|---|
| `source_table` | the provenance token as the long file spells it: the `Teams` entry of a `std_merge` table (`Genoud`, `Jones_etal_2009`), the item name in `Sources`/`source` columns (`Koay_etal_1998_Figure6`), the `Source` string of the trait-table melt. This is the token the app carries in its `Teams` column, so a lookup is exact |
| `printed_name` | how that source wrote the animal — binomial, trinomial, common name, flag — i.e. the evidence a reader can check in the TSV |
| `accepted_name` | the label the merge filed the row under (one of the `species_pooling.csv` members) |
| `population` | the vocabulary above |
| `evidence` | what in the source row supports the call; inferences say so |
| `decided_by`, `decided_date` | who ruled; rows seeded without a ruling say `auto-seeded ... (no decision)` |
| `note` | caveats; `inferred from study type` marks the two rows (Kaufman 2004, Veilleux & Kirk 2014's pig) that rest on the kind of study rather than on a printed statement |
| `merges_observed`, `n_rows_observed` | where the token was seen when the key was built (informational; regenerated) |

Key is `(source_table, accepted_name)`. The same token can be wild for one
label and domestic for another (Genoud 2018: `Domestic = 0` for the polecat,
`Domestic = 1` for every pig row).

## How it was seeded (2026-10-20)

`build_population_status.py` scans every `__merging_*/*_long.csv` and the app's
`evom1_traits_long.csv` for rows under the four labels, splits the provenance
column into tokens, and applies the decisions written in the script, each with
its evidence. Re-running the script keeps any row whose `decided_by` is not the
auto placeholder, so the CSV can be edited by hand and the script only appends
new tokens (as `unknown`).

Evidence used, by kind:

- **Printed domestic form** — trinomial, `Sus scrofa domestica`, `Pig`,
  `Domestic pig`, `Ferret`, `Putorius furo`: every row under the two domestic
  labels, plus Zilles 2013's "Ferret" for *Mustela putorius*.
- **Common names on the row** — `pig` / `ferret` in Heffner & Heffner 1992a and
  Koay et al. 1998; `Hog (domestic)` in Heffner & Masterton 1975; `Pigs` with
  strain in Weibel 2004; the breed `Landrace-Large white cross piglets` in
  van Haarlem 2026.
- **A source's own flag** — Genoud et al. 2018 `Domestic` column.
- **German names** — Brodmann 1913 `Schwein` (domestic pig) vs `Iltis` (wild
  polecat).
- **Value identity with a labelled row** — Herculano-Houzel 2015 sleep table
  brain mass 64.18 g = Kazu 2015's domestic pig; Lewitus 2013's 137.65 g =
  Lewitus 2014's *S. s. domesticus*; Bush & Allman 2003's 2,140 mm³ =
  Bush & Allman 2004a's *M. p. furo* (already in `taxon_clarity.csv`);
  de Sousa 2022's acuities = Veilleux & Kirk 2014's pig and ferret.
- **The source distinguishes forms itself** — Ashwell 2020 and Winkler &
  Bryant 2021 list the polecat and the domestic form as separate rows, so
  their `Mustela putorius` is wild; Boddy 2012 prints the polecat's old name
  *Putorius putorius*.
- **Compilations, per their design** — EltonTraits: wild. PanTHERIA, Amniote
  DB, AnAge, Lewitus 2013/2014, Boddy/Burger for the pig: mixed (one status per
  source; PanTHERIA's ecology fields are wild by design but its life-history
  fields admit captive records, and the entry is not annotated per field).
- **Unknown** — Jacobs 2018 (`European polecat` at a ferret-sized 8.3 g
  brain), Falcone 2019, Smaers 2018 (Maseko 2012 specimens), Wimberly 2021
  gait recordings.

One row is a label error rather than a population question: the app's melt
of `glia_gyrification.xlsx` files Lewitus 2014's `Sus_scrofa_domesticus` row
under `Sus scrofa`. It is marked domestic here so the switch treats it
correctly; the fix belongs in `____EvoM1_TraitTable`.

## Changing a row

Edit the CSV: set `population`, write the `evidence`, put your name in
`decided_by` and the date in `decided_date`. Then re-run
`python3 _keys/build_population_status.py` (keeps your row) and rebuild the
exports in `domestic_evidence` mode. Do not add a `species_basis` value for
this — the resolver's basis vocabulary is about names, and this key is about
animals.
