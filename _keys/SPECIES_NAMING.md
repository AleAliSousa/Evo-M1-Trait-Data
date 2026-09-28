# Species naming — one way for the whole dataset

**Status:** v1 implemented 2026-09-28 — `_keys/resolve_species.R` (identity resolver, §3c), all
spokes on the unified schema (§3b) incl. the new `_keys/General/species_key.csv` for papers with no
registered collection, and every `__merging_*` build script (13 R + 4 Python, via
`resolve_species.py`) sourcing the resolver (the resolving merges set `Species` from it; every long
table carries `species_printed`, `accepted_name`, `species_basis`, `reidentified`). This spec defines a single, shared way to
resolve species names so the *same per-paper table* can feed any sub-dataset (volumes, cell counts,
metabolic, …) and get **the same accepted name every time**.

It refines the hub-and-spoke design already described in `_keys/README.md` — that design stays;
this fixes the part that drifted (two resolution mechanisms and two key schemas).

---

## 0. Versioning — ship v1 lean, add the crosswalk later

To avoid building machinery before it's needed, this lands in two stages:

**v1 (now) — NCBI-only, no crosswalk table.**
- One authority for *identity*: `species_reference.csv` (`accepted_name` + `ncbi_taxid`), with NCBI as
  the single taxonomy view (the Order/Family columns it already has).
- One resolver `resolve_species(printed, source_publication)` doing the **identity** step only
  (variant → `accepted_name`), reading all spokes. No `taxonomy=` argument yet.
- Spokes unified to one schema; `source_publication` = paper folder name.
- **Specific-case handling still works in v1** — it lives in the spoke `basis`/`note` columns (§7c),
  which need no crosswalk.

**v2 (when a second taxonomy actually arrives) — the multi-authority crosswalk.**
- Add `species_taxonomy.csv` (one row per `accepted_name × authority`) and the `taxonomy=` argument
  so records can be relabelled into NCBI / MDD / ITIS / GBIF / `paper:<folder>` views (§3a-bis, §3c).
- Nothing in v1 has to change to adopt it — the identity anchor and spokes are unchanged; the
  crosswalk only *adds* selectable taxonomy views.

Sections below marked **(v2)** describe the later stage; everything else is v1.

---

## 1. The problem we're fixing

Today a species name is resolved in **two different ways**, so the same species can come out
differently depending on which sub-dataset it lands in:

- **Volumes** (`__merging_volumes/volumes_compiled.R`, step 4) — pre-migration it no longer used the
  Stephan key at all: it resolved names through an NCBI backbone cache
  (`volumes_species_ids_cache.csv`) plus `_keys/volumes_species_overrides.csv` keyed by item name
  (both migrated into the spokes on 2026-09-28 and no longer read for resolution).
- **Cell counts** (`__merging_cellcounts/cellcounts_compiled.R`, step 4) ignores the spoke keys and
  resolves names with a **live NCBI `name2taxid()` lookup** to an NCBI "preferred name".
- A few per-paper build scripts (the `Bush_Allman_*` ones) *also* harmonise in-script, against
  whichever key directory they happen to point at (`Stephan` in one, `Allman` in others).

Three schemas/paths for one job. The two merges can disagree; the per-paper scripts add a third path.

---

## 2. Principles (the "one way")

1. **One join anchor, many taxonomy views.** `_keys/species_reference.csv` holds the single
   internal **identity** for each animal — `accepted_name` (the join anchor) backed where possible by
   a `ncbi_taxid`. This anchor is *not* a taxonomy claim; it is just the stable key everything joins
   on. **Taxonomy** (Order/Family/rank, and the "accepted" binomial under a given authority) is a
   *separate, multi-valued* attribute kept in `species_taxonomy.csv` — one row per
   `(accepted_name × authority)`, so the same animal can carry NCBI, ITIS, GBIF, MDD, and even
   paper-specific names at once (see §3 and §6/R1). Nothing downstream invents its own mapping or
   does a live taxonomy lookup at compile time; it picks an existing authority view.
2. **Resolve once, at the merge/compile step — never in the per-paper build.** Per-paper tables keep
   only the **printed** name. Each sub-dataset calls the *same* resolver. (This is the choice we
   made: it is what lets one per-paper TSV be reused across sub-datasets unchanged.)
3. **Key the variant map by paper, not by lab or by table.** Each variant row is identified by
   `(source_publication, variant_name)`, where **`source_publication` is the paper = its folder
   name** (`Stephan_etal_1981`), not the per-table Item name. A paper belongs to one collection, so
   its variant rows live in that collection's spoke file **once**, and every table of that paper and
   every sub-dataset that uses it resolves through those same rows. **One paper → one taxonomy** by
   default (see §6/R3); a paper that genuinely mixes taxonomies must say so explicitly (a per-table
   override row), never silently.
4. **One resolver function, called identically everywhere.** Both merges (and any future one)
   `source()` the same `_keys/resolve_species.R` and call one function. No bespoke per-merge logic.
5. **Keep the per-collection spoke files** (the README's reasons hold: collections are distinct
   specimen sets, files stay a manageable size, a new collection is just a new subfolder) — but give
   them **one identical schema** so they can be stacked into a single variant table.

---

## 3. The pieces

```
_keys/
  species_reference.csv        HUB / IDENTITY — one row per accepted_name (+ default ncbi_taxid)
  species_taxonomy.csv         TAXONOMY CROSSWALK (NEW) — one row per (accepted_name x authority)
  resolve_species.R            the single resolver (NEW) — sourced by every merge
  <Collection>/
    species_key.csv            SPOKE — variant spellings -> accepted_name (unified schema)
```

### 3a. Hub / identity — `species_reference.csv`

One row per canonical animal = the **join anchor**. Keep it lean and identity-focused:
`accepted_name` (anchor) and a single default `ncbi_taxid`. It may retain the convenience taxonomy
columns it has today (`Order_resolved`, `Family_resolved`, the historical `*_Stephan1981`, the
`*_MDD`), but those are now understood as a *default view*; the full, multi-authority taxonomy lives
in `species_taxonomy.csv`. Adding a new species = one new row here (plus its variant row in the
relevant spoke, and its authority rows in the crosswalk).

### 3a-bis. Taxonomy crosswalk — `species_taxonomy.csv` **(v2)**

The multiple-taxonomy table. **One row per `(accepted_name × authority)`:**

```
accepted_name, authority, authority_name, authority_id, rank, order, family, note
```

- `authority` — `NCBI`, `ITIS`, `GBIF`, `MDD`, or `paper:<folder>` for a paper-specific taxonomy
  (e.g. `paper:DeCasien_Higham_2019`).
- `authority_name` — the accepted binomial **under that authority** (may differ from our anchor).
- `authority_id` — that authority's stable ID (NCBI taxid, ITIS TSN, GBIF key, MDD id, …).
- `rank` — `species` / `genus` / `subspecies` (lets a genus-level `sp.` carry a genus id honestly).
- `order`, `family`, `note` — taxonomy under that authority + provenance.

This is what lets you "convert to multiple taxonomies": a record keyed on `accepted_name` can be
relabelled into *any* authority's name/rank/order by joining this table on the chosen `authority`.
`resolve_taxonomy.R` populates the `NCBI`/`ITIS`/`GBIF` rows; MDD and `paper:*` rows are added by
hand or from a paper's own table. For one-off cases you can look an authority up live **once** and
cache the result here, so the pipeline stays offline thereafter.

### 3b. Spokes — `<Collection>/species_key.csv` (UNIFIED schema)

**Target schema — identical in every spoke:**

```
variant_name, accepted_name, source_publication, collection, ncbi_taxid, basis, note
```

- `variant_name` — the name exactly as printed in that paper (the thing we match on).
- `accepted_name` — the canonical name; must exist in `species_reference.csv`.
- `source_publication` — the **paper = folder name** (`Stephan_etal_1981`), shared by all tables of
  that paper (decided in §6/R3). Not the per-table Item name.
- `collection` — the spoke group (`Stephan`, `Allman`, `HerculanoHouzel`, …). Redundant with the
  folder, but explicit so stacked rows stay self-describing.
- `ncbi_taxid` — optional convenience copy; the authoritative taxid lives in the hub.
- `basis` — **how this mapping was decided** (the v1 specific-case handler, §7c): e.g.
  `verbatim` (name printed = accepted), `synonym:<authority>` (nomenclatural update),
  `reident:<authority|paper>` (an ambiguous/`sp.` record assigned to a species),
  `author_judgment` (the source author's own call, no external authority),
  `our_judgment` (our curatorial decision), `value_match:<source>` (equivalence found by value, §7c).
- `note` — free text rationale / citation (e.g. "10kTrees v3 tip", "typo in print", "combined species").

**Current vs target:**

| spoke | current columns | change needed |
|---|---|---|
| `Stephan/species_key.csv` (1038) | `accepted_name, source_publication, variant_name` | add `collection`, `ncbi_taxid`, `note`; reorder |
| `Allman/species_key.csv` (121) | `accepted_name, source_publication, variant_name` | same as Stephan |
| `HerculanoHouzel/species_key.csv` (87) | `accepted_name, ncbi_taxid, variant_name, source_datasets` | split `source_datasets` (comma list) into one row per `source_publication`; add `collection`, `note` |

### 3c. Resolver — `_keys/resolve_species.R` (NEW)

A small file that loads once and exposes one function; `_keys/resolve_species.py` is its
stdlib+pandas mirror with the identical contract (same normalisation, match order and return
columns; `python _keys/resolve_species.py --selftest` asserts agreement with the R resolver), used by
the Python-built merges (GLI, weights, endocranial_volume, cerebral_metabolic_rate). **Contract:**

```r
# resolve_species(printed, source_publication = NULL,
#                  taxonomy = "NCBI",
#                  return = c("accepted_name","authority_name","authority_id","rank","order","family"))
#
#   printed             character vector of names as printed in the source table
#   source_publication  the paper = folder name (so the same spelling in two papers can map
#                        differently if ever needed); if NULL, match on variant_name alone
#   taxonomy            which authority view to attach: "NCBI" (default) | "ITIS" | "GBIF" |
#                        "MDD" | "paper:<folder>" | "anchor" (= our accepted_name only, no relabel)
#   return              which field(s) to attach
#
# Behaviour:
#   1. bind ALL _keys/*/species_key.csv into one variant table (cached)
#   2. match (source_publication, variant_name) -> accepted_name        [IDENTITY: always single]
#      (fall back to variant_name-only match; then to the printed string itself)
#   3. join species_taxonomy.csv on (accepted_name, authority = taxonomy) [TAXONOMY: selectable]
#      to attach that authority's name / id / rank / order / family
#   4. return a data.frame aligned to `printed`, with `unresolved` (no accepted_name) and
#      `taxonomy_missing` (accepted_name found but no row for that authority) flags
```

Step 2 is the **identity** step — always one `accepted_name`, so every sub-dataset joins
consistently. **In v1 the function does steps 1–2 only** (no `taxonomy=` argument); NCBI is the lone
view, taken from the hub. Step 3 — the **taxonomy** step, where you swap `taxonomy=` to relabel the
same records into NCBI, MDD, a paper's taxonomy, etc. without changing the join — is **(v2)**, added
with the crosswalk. This generalises the volumes merge's
existing `accepted(token, name)` helper (which already does steps 1–2 against a single spoke) to read
**all** spokes and attach a chosen authority. The cell-counts merge's live `name2taxid()` block
becomes `resolve_species(..., taxonomy = "NCBI")` (the NCBI names/ids come from the crosswalk, looked
up once and cached — not re-fetched every run).

---

## 4. The resolution flow

```
per-paper build (e.g. Bush_Allman_2003_Table1.R)
    -> writes TSV with the PRINTED name only (species_as_published / Species_<Paper>)
       (NO harmonisation in the per-paper script)

merge / sub-dataset (volumes, cell counts, metabolic, …)
    -> source("_keys/resolve_species.R")
    -> Species_accepted <- resolve_species(printed, source_publication = <token>)
    -> join, dedupe, average, etc. on accepted_name
```

Because every sub-dataset runs the same call on the same printed name, a table reused in two
sub-datasets resolves identically by construction.

---

## 5. How to … (once migrated)

- **Add a paper.** Build it (printed name only in the TSV). Add its variant rows to the relevant
  `<Collection>/species_key.csv` (one row per printed spelling → accepted name). If it introduces a
  species not yet in the hub, add one row to `species_reference.csv` (with `ncbi_taxid` if known) and
  re-run `resolve_taxonomy.R`. Add the paper to the sub-dataset's `item_name`/`papers` list. Done —
  it now resolves the same way in every sub-dataset.
- **Add a new sub-dataset.** `source()` the resolver and call `resolve_species()`. No new naming code.
- **Add a new collection.** New `_keys/<Collection>/species_key.csv` with the unified schema; the
  resolver picks it up automatically (it globs `_keys/*/species_key.csv`).
- **Fix a misidentified/typo'd name.** Edit the spoke row (and `note`), never the per-paper TSV.

---

## 6. Migration checklist (when we proceed)

1. **Clean the hub.** Fix the 3 bad rows (blank `NA` name; the duplicated mojibake
   *Scutisorex somereni*). Then **fill taxids**: extend `resolve_taxonomy.R` to write back the NCBI
   taxid it resolves; run it to fill ~126/131 (the 5 genus-level `sp.` get the genus taxid +
   `rank = genus`).
2. **(v2 — skip for v1) Build `species_taxonomy.csv`.** Seed `NCBI` rows from `resolve_taxonomy.R`
   output (name, taxid, rank, order, family). Carry the existing MDD columns over as `authority = MDD`
   rows. Add `paper:<folder>` rows only where a paper's own taxonomy is needed (e.g. DeCasien). In v1
   the NCBI view stays in the hub's existing columns; no separate table.
3. **Unify the spoke schema.** Add the missing columns to Stephan/Allman; expand HerculanoHouzel's
   `source_datasets` list into one row per `source_publication` (= folder name). Verify no
   `accepted_name` is absent from `species_reference.csv`.
4. **Write `_keys/resolve_species.R`** implementing §3c (identity step + selectable taxonomy step);
   unit-check it against known (paper, printed)→accepted pairs from each collection, and against each
   `taxonomy=` view.
5. **Repoint `volumes_compiled.R`** to `source()` the resolver and replace the local `accepted()` +
   single-key read. Re-run; **diff `volumes_long.csv` against the pre-migration copy — expect zero
   changes** (volumes already uses the Stephan key, so this should be behaviour-preserving).
6. **Repoint `cellcounts_compiled.R`** to `resolve_species()` (v1: NCBI view from the hub) instead of
   the live `name2taxid()`. Because anchors are seeded from NCBI (R1), diff `cellcounts_long.csv` and
   expect **near-zero** name changes; review any that do change. (In v2 this becomes
   `resolve_species(..., taxonomy = "NCBI")`, behaviour-identical.)
7. **Remove in-script harmonisation** from `Bush_Allman_2003/2004_a/2004_b` (and don't add it to new
   scripts): keep `species_as_published` only. Move their mappings into `Allman/species_key.csv`,
   keyed by folder name.
8. **Update the HOWTO §5** to state the single rule: per-paper scripts keep the printed name; the
   merge resolves via `resolve_species()`.

### Resolved decisions

- **R1 — multiple taxonomies (decided: support them).** Identity and taxonomy are split (§2, §3a-bis):
  one stable `accepted_name` anchor, plus a `species_taxonomy.csv` crosswalk carrying NCBI, ITIS,
  GBIF, MDD and `paper:<folder>` views, selectable via `resolve_species(..., taxonomy = ...)`. This
  also dissolves the original R1 worry: the cell-counts merge keeps an **NCBI view** (so its current
  names are preserved as `taxonomy = "NCBI"`), while the join runs on the stable anchor. At cutover,
  **seed each cell-count species' `accepted_name` from the name NCBI currently returns**, so the
  identity diff is ~zero; differences then surface only where you *choose* a non-NCBI anchor.
  "Use a specific paper's taxonomy" = add `authority = paper:<folder>` rows and ask for it explicitly.
- **R2 — taxid coverage (answered).** Of 215 rows, 84 have a taxid and 131 don't — but only **5 are
  truly unobtainable**: the genus-level `sp.` entries (`Ateles sp.`, `Callicebus sp.`, `Gorilla sp.`,
  `Pongo sp.`, `Tarsius sp.`), which have no species-level taxid (give them the **genus** taxid with
  `rank = genus`). The other **126 are ordinary mammals NCBI has** — 89 already carry an NCBI-by-name
  Order/Family, so the taxid just needs writing back. **Plan:** extend `resolve_taxonomy.R` to persist
  the taxid it finds (into the hub and the crosswalk's NCBI rows); expect to fill ~126/131. Also fix
  3 dirty rows first: a blank `NA` accepted_name and a mojibake-duplicated *Scutisorex somereni*
  (`scutisorexãsomereni` / `ScutisorexÊsomereni` → one clean row).
- **R3 — the join key (decided: paper = folder name).** `source_publication` is the **paper folder
  name** (`Stephan_etal_1981`), shared by all of that paper's tables, with **one taxonomy per paper**;
  a paper that mixes taxonomies states it explicitly via a per-table override row. Per-table keying is
  still allowed where it makes a script shorter, but the default and the spoke key is the folder name.
  (The TSV/registry stay per-table by Item name; only species resolution keys on the paper.)

### Remaining risk

- **R4 — variant-name collisions.** If the same `variant_name` maps to different accepted names in
  two papers, the `(source_publication, variant_name)` key handles it — but flag any such case so
  it's a deliberate decision, not a silent overwrite.

---

## 7. Comparison datasets & taxonomy reconciliation

Some datasets are not *primary sources* we merge — they are external **benchmarks** we compare the
merge against (e.g. **DeCasien & Higham 2019**). The naming design covers them, but they play a
different role, and they expose the one thing the resolver deliberately does **not** do
automatically: taxonomic **lumping/splitting**.

### 7a. Two roles a source can play

| | **Primary source** | **Comparison dataset** |
|---|---|---|
| examples | Stephan, Bush, Herculano-Houzel | DeCasien & Higham 2019 |
| public TSV in `__Public/comparative-data/` | yes | no |
| listed in a merge's `item_name` / `papers` | yes | no |
| has a spoke `species_key.csv` | yes | **yes** |
| resolved via `resolve_species()` | yes | **yes** |

Both roles use the **same resolver and the same spoke schema**. The only difference is that a
comparison dataset is resolved *for the comparison* and never written to a TSV or merged. So a
comparison join is always **accepted_name ↔ accepted_name**: resolve the benchmark's names to
`accepted_name`, resolve the merge's names to `accepted_name`, then compare — apples to apples.

**Give each comparison dataset its own spoke**, e.g. `_keys/DeCasien/species_key.csv`
(`collection = DeCasien`). Its variant rows live there, keyed by its own `source_publication`
(`DeCasien_Higham_2019`) — **not** dumped into another collection's key. (Today the proposed DeCasien
edits target `_keys/Stephan/species_key.csv`; under this design they move to the DeCasien spoke so
DeCasien names never leak into the Stephan collection's key.)

### 7b. Where the resolver stops: lumping vs spelling

The resolver maps a *name* to an `accepted_name`. It handles spelling variants and renames. It does
**not** decide that two *different* canonical names refer to the same animal — that is a taxonomic
judgement. The DeCasien comparison is full of exactly this: the benchmark carries full binomials
where our merge (mostly Stephan) carries genus-level `sp.`, and vice versa:

```
DeCasien "Ateles geoffroyi"  vs merge "Ateles sp"        value 72410 == 72410  (0% diff)
DeCasien "Tarsius sp"        vs merge "Tarsius syrichta"  value   133 ==   133
DeCasien "Avahi occidentalis" -> merge accepted "Avahi laniger"
```

These are **lumping/splitting** decisions, not spellings. The resolver will leave them as
non-matches until the equivalence is recorded in a key — and that is correct: lumping needs a human.

### 7c. Specific cases — what *kind* of name difference is it, and on what basis

A name difference between a benchmark (or any source) and our anchor is **not one thing**. Before
adopting a mapping, classify it and record *why* — that is what the spoke `basis` column is for
(it works in v1, no crosswalk needed). The DeCasien comparison shows all three kinds at once:

| kind | what it is | example (DeCasien ↔ merge) | `basis` to record | adopt? |
|---|---|---|---|---|
| **synonym / rename** | same animal, nomenclature changed | `Avahi laniger` ↔ `Avahi occidentalis` (value 9256.8, 0%) | `synonym:<authority>` | yes |
| **re-identification** | source said `sp.` / was ambiguous; a species was *assigned* | `Ateles geoffroyi` ↔ `Ateles sp` (value identical) | `reident:<authority\|paper>` | yes, but flag the assigner |
| **disagreement / error** | genuinely different species, or a misattribution | `Cebus apella` ↔ `Cebus albifrons` (77300 vs 77027); `Callithrix pygmaea` taking a `jacchus` value | `our_judgment` (reject) | **no** — flag, don't map |

**On DeCasien specifically (what is established vs inferred — important for comparisons).**
The re-identification is an **inference, not a sourced fact**, and the spoke must say so:

- Her phylogeny tips follow the *published* **10kTrees v3** consensus tree + Perelman phylogeny
  (Methods, refs 26–27) — so her binomials are standard nomenclature, not invented.
- Her supplementary **"Brain Region Data Notes"** tab documents only *measurement* substitutions
  (labels A–F, e.g. "Removed cerebellum, replaced with measurement from [61]") — **nothing about
  species-name assignment.**
- Her `Taxon` column carries a full binomial/subspecies for **every** row; there is **no `sp.`** in
  her table.
- Empirically, her `Ateles geoffroyi` value equals Bush & Allman's `Ateles sp` value (0% diff,
  `DeCasien_vs_merge_comparison.csv`).

So the chain `Ateles sp` (Bush) → `Ateles geoffroyi` (DeCasien) is established **by value-match plus
her use of a binomial where the source had only `sp.`** — not by any statement, and possibly made by
an intermediate compilation rather than DeCasien herself. Label it accordingly (next subsection):
`basis = reident`, `evidence = value_match_exact`, `authority = 10kTrees_v3`, `adopted_from =
DeCasien_Higham_2019` — **never** as a fact DeCasien asserted. Value-coincidence conflicts
(e.g. *Cebus apella* vs *albifrons*, ~0.35%) → **do not adopt**; flag for review.

### 7c-label. How to label a re-identification (and the `basis` vocabulary)

`basis` is a controlled vocabulary (works in v1 — spoke columns only, no crosswalk):

| `basis` | meaning |
|---|---|
| `verbatim` | printed name = accepted; no change |
| `spelling` | orthographic/typo fix |
| `synonym` | nomenclatural update, same taxon (e.g. *Cebus* → *Sapajus*) |
| `reident` | **a source's specimen given a finer/different identity than the source stated** (genus `sp.` → species, or a relabel) — the case here |
| `subspecies_assign` | a subspecies assigned/rolled to species |
| `lump` / `split` | taxonomic lumping/splitting decision |

A `reident` row carries extra provenance so the inference is fully traceable — as spoke columns
(or, if you'd rather not widen the spoke, packed into `note` with these keys):

```
variant_name      = "Ateles sp"                 # exactly as the source printed it
accepted_name     = "Ateles geoffroyi"          # the assigned identity we adopt
source_publication= "Bush_Allman_2004_b"        # the source whose specimen is re-identified
basis             = "reident"
authority         = "10kTrees_v3"               # the nomenclatural standard the name conforms to
evidence          = "value_match_exact:Bush_Allman_2004_b"   # HOW we know they're the same datum
adopted_from      = "DeCasien_Higham_2019"      # where we took the assignment
corroborated_by   = "Smaers_etal_2017"          # others using the same call (optional)
status            = "adopted"                    # adopted | proposed | rejected
decided_by, date  = "<you>, 2026-06-25"
```

Key point: the re-identification is recorded **against the source being re-identified** (Bush), with
DeCasien/Smaers as the *authority/provenance* for the call — not as a Bush statement and not as a
DeCasien fact. `species_as_published` in the per-paper TSV always preserves the original `Ateles sp`,
so the change is non-destructive and reversible.

### 7c-track. Applying DeCasien's calls while tracking them (the ledger)

You want to adopt these (they reflect reality and match Smaers) **and** track them. Do it through a
single reviewed ledger — a generalisation of the file you already have
(`DeCasien_Higham_2019/DeCasien_taxonomy_proposed_changes.csv`):

- **`_keys/reidentifications.csv`** — one row per re-identification, columns = the provenance block
  above (`source_publication, variant_name, accepted_name, basis, authority, evidence, adopted_from,
  corroborated_by, status, decided_by, date`). `status = proposed` until you approve; `adopted` once
  in. This is the audit trail.
- The spoke `reident` rows are **generated from / kept consistent with** the `adopted` ledger rows,
  so resolution and provenance never drift apart.
- The merge carries a boolean **`reidentified`** column (TRUE where the accepted_name came from a
  `reident` rather than the source's own label) so any analysis can include or exclude these with one
  filter, and reviewers can see at a glance which species IDs are curatorial.

> **Note your current proposed file is incomplete.** It was built with a `ref_is_stephan` filter, so
> it lists only Stephan-sourced cases (e.g. *Avahi laniger* ↔ *occidentalis*, *Tarsius*). The
> Bush-sourced ones (*Ateles sp* → *geoffroyi*, *Callicebus sp* → *moloch*, etc.) are **not** in it
> yet — regenerate without that filter before adopting, so every `match_taxonomy_variant` gets a
> reviewed decision.

### 7c-loop. The propose → review → key loop (keep it)

The existing DeCasien workflow is the right pattern and survives unchanged:

1. **Discover by value, name-agnostically.** Match benchmark cells to the merge by *value* within a
   genus and a tolerance (the process behind `DeCasien_vs_merge_comparison.csv`, status
   `match_taxonomy_variant`). This finds equivalences the keys don't know yet — keep it even after
   the resolver is in place, because the resolver makes joins *consistent* while value-match makes
   them *complete*.
2. **Propose, don't apply.** Candidate `variant → accepted` additions go to a review file
   (`DeCasien_taxonomy_proposed_changes.csv`) — never applied automatically.
3. **Human reviews and approves.**
4. **Record the decision in the spoke.** Approved equivalences become rows in the **DeCasien spoke**
   with the rationale in `note` (e.g. `note = "DeCasien splits; lumped to Stephan 'Ateles sp' on
   identical value 72410"`). From then on `resolve_species()` applies them automatically and
   identically in every comparison.

### 7d. Adjudication aids from the hub

Use the hub + crosswalk to settle hard cases: `ncbi_taxid` collapses synonyms/subspecies to one ID,
and the `order`/`family` columns catch cross-rank mismatches. If you want to view or compare in
**DeCasien's own taxonomy**, add its names as `authority = paper:DeCasien_Higham_2019` rows in
`species_taxonomy.csv` and call `resolve_species(..., taxonomy = "paper:DeCasien_Higham_2019")` — the
join still runs on the stable anchor, but records are relabelled into DeCasien's scheme. Optional
future column worth considering: a `lumped_with` / `senior_synonym` field to make a lumping decision
first-class (rather than only implicit in spoke `note`s), so genuine splits-vs-lumps are queryable.

### 7e. Caveat — join granularity

`accepted_name ↔ accepted_name` joins cleanly **only when both datasets agree on the canonical
unit**. Where a benchmark genuinely *splits* a species we *lump* (or vice versa) and you choose not
to reconcile, compare at **genus level** or flag the row rather than forcing a 1:1 match. The
value-match safety net in 7c is what keeps those visible.

---

## 8. What does NOT change

- The hub-and-spoke structure and the rationale for per-collection files (`_keys/README.md`).
- `species_reference.csv` / `anatomy_reference.csv` shapes and `resolve_taxonomy.R`.
- The per-paper snapshot → CSV → public-TSV build (it just stops doing any species harmonisation).
- Anatomy/structure naming — this spec is species only; structures follow the parallel
  `anatomy_key.csv` → `anatomy_reference.csv` path and could get the same treatment later.
