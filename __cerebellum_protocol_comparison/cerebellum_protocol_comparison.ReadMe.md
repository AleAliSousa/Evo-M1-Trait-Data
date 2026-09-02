# `__cerebellum_protocol_comparison`

Cross-publication check: which cerebellum **protocol** does each downstream
compilation's cerebellum column actually carry, and do any of them pool
incompatible protocols in a single column?

Every input is a public table in this repository, so per
[`REPO_BOUNDARY.md`](../REPO_BOUNDARY.md) §3 ("check whose every input is
already public → public, beside what it audits") the check lives here rather
than in the private repo's `restricted_checks/_cross_table/`.

## Why this check exists

Three mutually incompatible cerebellum compositions circulate in the sources
this repo indexes, and **all three currently map to the standardized term
`Cerebellum`**:

| composition | source | stated where |
|---|---|---|
| cerebellum **+ peduncles + basal pons** | Stephan et al. 1981 (code 7), Stephan et al. 1970 | `Stephan_etal_1981_TablesI-VI_definitions.csv`: "cerebellum including brachium and nuclei pontis" |
| cerebellum **+ peduncles**, pons a separate row | Zilles & Rehkämper 1988 Table 12-2 | prints `Cerebellum (without pons)` and `Pons` separately |
| cerebellum **only** — no peduncles, no brain stem | MacLeod et al. 2003; MacLeod 2000 | MacLeod et al. 2003 methods; MacLeod 2000 p. 57 |

No `definitions.csv` in this repository mentions "peduncle" anywhere, so the
middle distinction is invisible to a reader working from the definitions alone.

## Inputs (all public, all in this repo)

| file | role |
|---|---|
| `Stephan_etal_1981/Stephan_etal_1981_TablesI-VI.csv` | pons-inclusive reference protocol |
| `Matano_etal_1985_b/Matano_etal_1985_b_Table1.csv` | ventral pons — the subtrahend for converting between protocols |
| `MacLeod_etal_2003/MacLeod_etal_2003_Table1.csv` | *sensu stricto* reference protocol |
| `DeCasien_Higham_2019/41559_2019_969_MOESM3_ESM.xlsx` | downstream compilation under test |
| `Smaers_etal_2018/Smaers_etal_2018_Figure2-data1.csv` | downstream compilation under test |

## Outputs

| file | contents |
|---|---|
| `cerebellum_protocol_pooling_detail.csv` | one row per (dataset, species): the dataset's value, the cited source, the protocol that citation implies, and the value's distance from Stephan raw / Stephan-minus-pons / MacLeod |
| `cerebellum_protocol_pooling_summary.csv` | the same rolled up by dataset × cited source × implied protocol |

`species_key` is a normalized binomial for joining only; it is not a taxonomic
assertion. `in_macleod_table` records whether the species appears in MacLeod
et al. 2003 Table 1 at all — useful because some rows are attributed to MacLeod
for species that table does not contain.

## Reproducing

```
cd __cerebellum_protocol_comparison
Rscript cerebellum_protocol_comparison.R
```

Reads only from this repository (paths resolved relative to the script), writes
only the two CSVs beside itself. Requires `readxl`, `dplyr`, `tidyr`, `readr`,
`stringr`.

## What it found

See [`CEREBELLUM_PROTOCOL_FINDINGS.md`](CEREBELLUM_PROTOCOL_FINDINGS.md).
Headline: both compilations pool protocols inside one column, the offset between
protocols is ~9% in hominoids rather than negligible, and the published
justification for pooling has the size gradient backwards.
