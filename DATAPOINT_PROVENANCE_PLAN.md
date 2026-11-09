# Data-point provenance: plan and hand-off

*Written 8 Nov 2026 to start a new thread. Status: **plan only**. Nothing in this file has been built yet.*

## 1. The problem

Evo-M1-Trait-Data records whether data are primary, secondary, derived or predicted in several places and at different levels:

- the registry describes a whole table;
- the definitions files describe a whole column;
- some item CSVs describe individual cells.

The same fact can therefore be stated in one place, contradicted in another, or not recorded at all.

**Example: Mink et al. 1981, Table 1.** The registry calls the whole table `secondary` (AG). In the brain O2 column (F), however:

| Cells | What they are |
|---|---|
| Rat (68), cat (30), macaque (84), dog (32), human (50) | Measured values copied from cited studies |
| 28 warm-blooded rows | Mink's own Eq. 1 predictions |
| 6 cold-blooded rows | Eq. 3 predictions |
| Goldfish, alligator, crow | Other derivations |

Columns H to K and the ratio are arithmetic on these cells. Some spinal-cord weights borrow another species' brain:cord ratio (footnotes j–x). None of this is visible at registry level.

**What we need.** Every value should answer five questions:

1. What kind of value is it (measured, copied, converted, derived, predicted, extrapolated, averaged, digitised…)?
2. What are its inputs (upstream values or cited references)?
3. What rule produced it (equation, footnote, text)?
4. Has it been checked against its source, and with what result?
5. Is there an erratum or flag on it?

These answers should live in **one consistent place**. Lineage across papers must allow forks: one value can have several parents (an average) and many children (cited by several papers).

## 2. What already exists (reuse it; do not replace it)

| Mechanism | Level | Where |
|---|---|---|
| Registry `Data role` (AG) and `Source (if secondary)` (AH) | item (whole table) | `__ReadMe.xlsx` Sheet1 |
| `role` column | variable (column) | `reference_tables/<Item>_definitions.csv`, aggregated in `variable_catalog.csv` |
| `data_role`, `value_role`, `ref_keys_*`, `printed_footnote_marks` | row/cell (only in some items) | item CSVs, e.g. `Mink_etal_1981_TABLE1.csv` |
| Errata (one CSV per paper, three renderings) | cell | `reference_tables/<Pub>_errata.csv`; `_tools/dataset_builder/ERRATA_CONVENTION.md`; `render_errata.R` |
| Value-to-reference links: `derivation_role`, `compilation_role`, `source_reference_ids`, `primary_reference_ids` | merged value | `__merging_cerebral_metabolic_rate/…value_reference_links.csv` |
| Paper-level citation graph | paper | `_tools/dataset_builder/resolve_reference_chains.py` |
| Source matching and compiler decisions | value / decision | `source_match.R`, `SOURCE_MATCH_CONVENTION.md`, `COMPILER_DECISIONS_CONTRACT.md` |
| Cross-table check of Mink 1981, MacLarnon 1996 and Karbowski 2007 against their primaries | value | Restricted repo: `restricted_checks/_cross_table/Mink_1981_MacLarnon_1996_Karbowski_2007_vs_primaries/`. Contains `crosswalk.csv` (434 rows), `proposed_errata.csv` (15) and `output/comparison_long.csv`. The first run made 484 comparisons: 112 match, 14 within rounding, 4 mismatch, 2 pairing mismatch, 116 derived, 133 primary not held, 103 not comparable |
| Human check of a snapshot | item | Registry AJ |

## 3. Proposed design

### 3.1 One authoritative level, with summaries above it

- **Value level (new, authoritative):** `reference_tables/<Item>_value_provenance.csv`, one row per value. The item's R script writes it.
- **Column level (default):** definitions `role`. This applies to every cell in the column unless the value level overrides it.
- **Item level (summary only):** registry AG/AH. These would be computed from the value level (e.g. `mixed: 5 reported_from_source, 28 predicted_model, …`), not typed by hand. *Decision needed (§6).*

The finest level present wins. A validator flags any coarser level that contradicts it.

### 3.2 Value identifier

`value_id = <Item name>:<row key>:<variable>`

- Example: `Mink_etal_1981_TABLE1:r38:spinal_cord_weight.g` is the camel's cord weight.
- **Row key:** use the printed or source row number where the item has one (`printed_row`, `source_snapshot_row`). Otherwise use the frozen snapshot order. Snapshots are frozen, so the keys stay stable.
- **Variable:** the item CSV's column name.

### 3.3 `<Item>_value_provenance.csv` columns (draft)

`value_id, item, row_key, taxon_as_printed, variable, value_printed, unit, origin, method, inputs, ref_keys, primary_item, check_status, erratum_id, note`

**`origin` vocabulary (draft):**

| `origin` | Meaning | Example |
|---|---|---|
| `measured_here` | Measured in this paper | Latimer & Sawin 1955 rabbit weights |
| `reported_from_source` | Copied from a cited source (secondary) | Mink rat brain O2 7.6 (ref 68) |
| `transformed` | One input converted, rounded or rescaled | Mink Eq. 5 body-rate rescaling |
| `derived` | Arithmetic on several inputs | Mink I = F × B / 100 |
| `predicted_model` | Value from a fitted equation | Mink Eq. 1 brain O2 for 28 warm-blooded rows |
| `extrapolated_proxy` | Borrowed from another species or specimen through a ratio | Mink camel cord = brain ÷ 2.5 (horse ratio) |
| `averaged` | Mean of values from several studies | Coto 2026 rat brain O2 = mean(Mink, Karbowski) |
| `digitised` | Read from a figure | Figure items |
| `estimated_unspecified` | Source says "estimated" or "approximately" without a method | |
| `unknown` | Not yet determined | |

**Other columns:**

- `method`: equation id, footnote mark, or a text pointer (e.g. `Eq. 1`, `footnote x`, `Methods p. R205`).
- `inputs`: value_ids, `ref:<n>` citation keys, or both, separated by `;`.
- `check_status`: `match / within_rounding / mismatch / pairing_mismatch / derived_reproduced / derived_mismatch / not_held / not_checked`. This is filled from restricted check outputs.
- `erratum_id`: links to the paper's errata CSV. **Errata stay where they are.**

### 3.4 Cross-paper lineage (forks allowed)

A repo-level edge table, `_lineage/lineage_edges.csv`, with columns:

`from_value_id, to_value_id, relation, evidence, confidence, checked_by, checked_date`

- **`relation` values:** `copied`, `rounded`, `unit_converted`, `derived_input`, `averaged_input`, `predicted_from`, `extrapolated_from`, `mispaired`, `cited_not_found`.
- **Graph shape:** a value can have several parents and several children, so the graph is a directed acyclic graph rather than a chain.
- **Forks** (two compilations taking the same primary by different routes) are simply two paths to one node.
- **Values we don't hold:** an upstream value outside the dataset is a stub node, `ref:<item>:<n>`, until the primary is built.

### 3.5 Where each kind of flag goes (the consistent place)

| Question | Recorded in |
|---|---|
| Measured or predicted / derived / extrapolated? | `value_provenance.origin` |
| Secondary? From where? | `origin = reported_from_source` and `inputs` (upstream value_id or `ref:` key) |
| Is it wrong in print? | Errata CSV (unchanged), linked by `erratum_id` |
| Does it agree with the primary? | `check_status` (from restricted checks) |
| Was the snapshot human-checked? | Registry AJ (item); optional value-level `human_check` later |
| Table-wide role | Registry AG/AH, as a summary of the above |

### 3.6 Validator

`_tools/dataset_builder/validate_value_provenance.R` checks that:

- every value in an item CSV has a provenance row or a column default;
- the vocabulary is valid;
- `inputs` resolve;
- the lineage graph has no cycles;
- registry AG agrees with the value-level summary.

### 3.7 Merges and the app

- **Merges:** merged tables carry `value_id` and `origin` from source cells. `derivation_role` and `compilation_role` in the cerebral metabolic rate merge map onto `origin` and `relation`.
- **App "Trace" view:** pick a value to see its upstream graph back to primaries and its downstream uses.
  - Colour nodes by `origin`. Mark errata and check results on edges.
  - Provide a "measured only" filter for analyses.

## 4. Pilot: everything connected to Mink et al. 1981

**Items:**

- Mink_etal_1981_TABLE1 and _REFERENCES
- MacLarnon__1996_Table1
- Karbowski__2007_TableS1 (and Table1)
- Latimer_Sawin_1955 TABLE1–7
- Krompecher_Lipak_1966_Table2
- Crile_Quiring_1940_Table1
- Latimer 1924/1938/1942/1956 items
- Primaries of the brain O2 values: Geiger_Magnes_1947, Gilboe_Betz_1973, Nilsson_Siesjö_1976, Schmidt_etal_1945, Nemoto_etal_1994, Nakanishi_etal_1997, Sahlin_etal_1987
- Downstream: **Coto_etal_2026_Fig7** (registry row 1001, fields still blank)

Seed the pilot with the restricted `crosswalk.csv` and `comparison_long.csv`.

### 4.1 Worked example A: the camel row (Mink row 38)

| Column | Printed | Origin | Evidence |
|---|---|---|---|
| A body weight | 453,590 g (20) | `reported_from_source`, flag `cited_not_found` | Ref 20 = Crile & Quiring 1940. Their table has no camel. 453,590 g is 1,000 lb (453,592 g) rounded. |
| B brain weight | 569.5 g (20) | `reported_from_source`, flag `cited_not_found` | Not in Crile & Quiring 1940. The next place to look is ref 76 (Quiring 1950), the horse row's source, which we do not hold. |
| C spinal cord weight | 227.8 g, footnote x | `extrapolated_proxy` | Footnote x: "Extrapolated from brain-to-spinal cord weight ratio of *Equus caballus* (52)". 569.5 ÷ 2.5 = 227.8. Ref 52 (Krompecher & Lipák 1966) prints horse brain 532 g, cord 215 g, quotient 2.5. |
| F brain O2 rate | 3.175 | `predicted_model` (Eq. 1) | Eq. 1 from brain 569.5 g gives 3.1753 |
| G spinal O2 rate | 0.762 | `predicted_model` (Eq. 4) | Eq. 4 gives 0.749 (about 2% off; Eq. 4's printed coefficients are rounded) |
| H–K and ratio | — | `derived` | Arithmetic per footnotes e–i |

**Conclusion:** the camel row contains no measured value. Ref 52 supplies only the ratio, i.e. the rationale.

**Related rows:**

- **Cattle** (row 39): body and brain match Crile & Quiring's "Miscellaneous cows" (n = 71): 506 kg and 420 g. The cord, 168 g, equals 420 ÷ 2.5 (footnote x).
- **Horse** (row 40): the cord is printed as "260 (52)", but 260 = 650 ÷ 2.5. Krompecher & Lipák measured 215 g (with a 532 g brain). The horse cord is therefore also an extrapolation, printed as if it were a cited value.

### 4.2 Worked example B: Coto et al. 2026, Fig. 7 (downstream)

**Source of the plotted values.** Coto et al. 2026 (*PNAS*, doi 10.1073/pnas.2605431123) plot 7 mammals. The values are in Dataset S1, sheet `mammal_scaling_data_figure_7`, which is a digital-native file. The legend says:

> Brain OCRs for mammals were calculated as averages of minimally two studies with the exception of *Papio cynocephalus* (one study). … data are from Karbowski (24), Mink et al. (23), and references therein.

**Reconstruction against Mink Table 1 and Karbowski 2007 Table S1** (rates in ml O2/100 g/min):

| Species (Coto label) | Coto brain g | Coto OCR ml/min | Implied rate | Mink rate (origin) | Karbowski rate | Reconstruction |
|---|---|---|---|---|---|---|
| *Rattus norvegicus* | 1.8 | 0.144 | 8.00 | 7.6 (measured, ref 68) | 8.4 | mean(7.6, 8.4) × 1.8 g. Exact. Brain mass from neither source. |
| *Felis domestica* | 27.56 | 1.42 | 5.15 | 4.5 (measured, ref 30) | 5.8 | mean(4.5, 5.8) × Mink's 27.56 g = 1.419 |
| *Canis familiaris* | 85 | 4.038 | 4.75 | 3.4 (measured, ref 32) | 6.1 | mean(3.4, 6.1) × 85 g = 4.0375. Brain mass from neither source. |
| *Ovis aries* | 114 | 5.586 | 4.90 | 3.94 (**Eq. 1 prediction**) | 4.9 | **Karbowski only.** 5.586 is Karbowski's printed total; 114 g = 5.586 / 0.049. Mink's prediction is not used. |
| *Papio cynocephalus* | 147 | 4.9539 | 3.37 | 3.79 (**Eq. 1 prediction**; Mink's species is *P. papio*) | 3.4 (0.034) | Sahlin et al. 1987 Table IV, "Before SAH", CMRO2 corrected to paCO2 40 mm Hg: 3.37. Multiplied by Mink's *P. papio* brain weight, 147 g (Riese & Riese 1952). Mink's prediction is not used. Cross-species pairing. |
| *Macaca mulatta* | 92.36 | 4.5672 | 4.945 | 3.7 (measured, ref 84) | 6.0 | Not reproduced from Mink + Karbowski (their mean would be 4.85). Check against Schmidt 1945 and Nemoto 1994 (both held). |
| *Homo sapiens* | 1339 | 48 | 3.585 | 3.3 (measured, ref 50) | 3.5 | Not reproduced (mean 3.4). Needs Kety 1957, Clarke 1994, Madsen 1991. |

**Findings:**

1. **Why Mink was used.** Karbowski 2007 S1 gives one study per species. To meet their "at least two studies" rule, Coto used Mink's measured values as the second study. They also took brain masses from Mink (cat, baboon) because Karbowski S1 prints only rates and totals.
2. **Predicted values were not used.** Neither of Mink's two Eq. 1 predictions in this species set (sheep, baboon) was used.
3. **The legend's one-study exception is incomplete.** Sheep is also single-study, not just the baboon.
4. **Citation mismatch.** Coto's ref 24 is Karbowski 2011 (*PLoS ONE* 6:e26709). That paper reports blood flow and capillary scaling and relies on Karbowski 2007 for metabolic rates. The plotted numbers match Karbowski 2007 Table S1. Record this as `cited_not_found` on the Karbowski 2011 edge, with the values attached to 2007.
5. **Methods differ between the averaged pairs.** Mink's measured partners come from older preparations: Geiger & Magnes 1947 used a perfused cat brain, and Gilboe & Betz 1973 an isolated dog brain. All are lower than Karbowski's values (4.5 vs 5.8, 3.4 vs 6.1, 7.6 vs 8.4, 3.7 vs 6.0).
6. **Species-label conflict.** *P. cynocephalus* is the species printed by Sahlin 1987. Our Karbowski/merge mapping uses *Papio anubis* (already noted in the Sahlin README).

### 4.3 Worked example C: the rabbit spinal cord (Mink row 24)

Mink pairs a female body and brain weight with a male cord weight; the sources are Latimer & Sawin 1955 Tables 1 and 2. This is erratum `Mink_etal_1981-E005`. In the lineage it becomes an edge with `relation = mispaired`. MacLarnon 1996 took the same-sex means correctly.

### 4.4 Pilot deliverables

1. `Mink_etal_1981/reference_tables/Mink_etal_1981_TABLE1_footnotes.csv`. Columns:
   - `mark`, `text_verbatim`, `applies_to_columns`, `printed_rows`;
   - `origin_implied`, `donor_taxon`, `donor_ref_key`, `rule` (e.g. `C = B / 2.5`).

   Sources: snapshot rows 47–72 (the parentheses note plus footnotes a–y) and the CSV's `printed_footnote_marks`. At present the footnotes exist only inside the snapshot and as marks in the CSV.
2. `Mink_etal_1981_TABLE1_derivations.R`. Recomputes every non-measured cell (Eqs. 1, 3, 4, 5; H–K; ratio; footnote j–x cords) and writes `Mink_etal_1981_TABLE1_value_provenance.csv`.
   - This extends the restricted module C2, which reproduced 113 of 114 derived cells. The one exception is the whale's Eq. 5 body rate: printed 0.071, computed 0.088.
3. Value-provenance files for MacLarnon 1996 Table 1, Karbowski 2007 S1, Latimer & Sawin 1955 T1–T7 and Krompecher & Lipák 1966 Table 2.
4. `_lineage/lineage_edges.csv` for the cluster, seeded from `crosswalk.csv` plus the Coto reconstruction above.
5. Validator run and a short report: values by origin, edges by relation, unresolved stubs.

## 5. Phases

| Phase | Work | Output |
|---|---|---|
| 0 | Decide the vocabulary, `value_id` format and file locations (§6) | Short `_tools/dataset_builder/VALUE_PROVENANCE_CONVENTION.md` next to `ERRATA_CONVENTION.md` |
| 1 | Pilot on Mink Table 1 | Footnotes table, derivations script, value-provenance CSV |
| 2 | Rest of the Mink cluster, plus lineage edges | Per-item provenance CSVs, `lineage_edges.csv` |
| 3 | Validator; registry AG/AH summary generator | `validate_value_provenance.R`, summary paste file |
| 4 | Roll into the build guide (`_skills/build-dataset-item/SKILL.md`, HOWTO §9 data role) | New items write provenance at build time |
| 5 | App "Trace" view | Lineage graph per value |

## 6. Decisions needed from Alexandra

1. **Vocabulary:** keep or rename the `origin` and `relation` terms above.
2. **`value_id`:** use printed row numbers (human-readable, needs care when a table has sub-rows) or a frozen sequence?
3. **Public vs restricted:** should lineage edges and `check_status` live in the public repo? The checks compare against primaries we hold; some primaries are restricted.
4. **Registry AG/AH:** should they become computed summaries, or stay manual with a validator warning?
5. **Cited source lacks the value** (the camel in Crile & Quiring 1940; the Karbowski 2011 citation in Coto): is `cited_not_found` an edge relation, a value flag, or both?
6. **Downstream papers that are not dataset material** (e.g. Coto 2026, ants): give them a full item (row 1001 exists) or only lineage nodes?

## 7. Start here (new thread)

1. Read, in this order:
   - this file;
   - `_tools/dataset_builder/ERRATA_CONVENTION.md`;
   - `_tools/dataset_builder/SOURCE_MATCH_CONVENTION.md` and `COMPILER_DECISIONS_CONTRACT.md`;
   - `Mink_etal_1981/Mink_etal_1981_TABLE1.README.md` and its `reference_tables/`;
   - the restricted comparison README (path in §2).
2. Get the decisions in §6, or proceed with the defaults above, marked as provisional.
3. Build Phase 1. Constraints:
   - **Scripts:** R scripts are the deliverable. Where R cannot run, use a Python mirror labelled **R NOT RUN**.
   - **Values:** keep printed values. Resolve, never average. Flag discrepancies, never balance.
   - **Registry:** column M is manual; only E–L are formulas. Rows past 200 are changed by paste file, not live edits.
   - **Messages:** never email or post on Alexandra's behalf.
