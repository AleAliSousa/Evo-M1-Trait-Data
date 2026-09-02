# `__Finder` — a discovery app for Evo-M1-Trait-Data

**Approach document, written 2026-08-14.** Proposal to be reviewed before any code is written.
Intended home: `__Finder/APPROACH.md` in the repo. Companion to
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` (why the repo exists) and `__ShinyApp/DEPLOY.md` (the existing
*analysis* app).

---

## 1. The problem, stated precisely

The repo holds **2,793 files in 144 study folders plus ~30 working folders**. Everything needed to
answer "what data is here?" already exists — but it is spread across four places that only a person
who built them knows how to join:

| Where | What it knows | Grain | Completeness |
|---|---|---|---|
| `__ReadMe.xlsx` Sheet1 | citation, DOI, trait, taxon group, measure type, team, collection | 294 items | uneven (see §5) |
| `_keys/variable_catalog.csv` | structure, domain, measure class, stat, role, taxon | 1,144 variables | good |
| `_keys/species_taxonomy.csv` + `genus_family.csv` | Order, Family per species | 583 species / 1,240 genera | good — 93% of species resolvable |
| `_keys/anatomy_reference.csv` | canonical structure → domain + measures seen | 193 structures | good |
| `__Public/comparative-data/*.tsv` | the actual columns and species, 29,167 data rows | 246 tables | 222/246 have a species column |
| the folders themselves | PDF, extraction `.R`, `README.md`, snapshot `.xlsx` | 144 folders | n/a |

So the question "which papers give me cerebellum volumes for carnivores, and where are the files?"
is currently answered by knowing the literature, not by querying the repo.

**This app does exactly one thing: turn that into a search box.** It reads, never writes, and never
moves a file. The folder organization is untouched — it becomes the *thing being indexed*.

### Explicitly out of scope

No plotting, no merging, no download-a-selection, no PGLS. Those exist in `__ShinyApp` and
duplicating them is how a finder turns into a second half-maintained analysis app. The finder's
output is always **a citation, a file, and a link** — the user's next click leaves the app.

---

## 2. Design decision: separate app, shared plumbing

Three options were considered:

| | Approach | Verdict |
|---|---|---|
| A | A new "Find" tab inside `__ShinyApp/app.R` | Rejected — `app.R` is already 641 lines; the finder needs its own facets and would roughly double it. Also couples a lightweight tool to a heavy one. |
| B | Standalone `__Finder/` app, own deploy URL | **Chosen** |
| C | Standalone, but duplicate the GitHub-fetch code | Rejected — two copies of `pct()` and the fallback logic will drift. |

**Chosen: B with shared helpers.** `__Finder/` is its own single-file app with its own shinyapps.io
URL, but the GitHub-fetch-with-local-fallback logic and the `pct()` encoder are factored out of
`__ShinyApp/app.R` into `_tools/lib_gh.R`, which both apps `source()`. That refactor is mechanical
and leaves `__ShinyApp` behaviour identical.

The finder is deliberately cheap to run: it loads **one derived index set (a few hundred KB)**, not
the merged long tables. Cold start should be well under a second, which matters for something people
open to ask a five-second question.

---

## 3. Architecture

```
_tools/
  lib_gh.R                 NEW  shared: GH_BASE, pct(), read_*_gh() with local fallback
  build_finder_index.R     NEW  the whole build; read-only over the repo

__Finder/
  app.R                    NEW  the finder (single file, target <400 lines)
  APPROACH.md              this document
  README.md                NEW  what it is, how to run, how to update
  data/                    NEW  derived index, committed so GitHub serves it
    finder_items.csv         one row per data item  (~294)
    finder_species.csv       one row per species     (~588)
    finder_variables.csv     one row per variable    (~1,144)
    finder_species_items.csv species <-> item edges
    finder_build_log.md      what the build found and what it could not resolve

Update_Finder.command      NEW  macOS double-click launcher (mirrors Update_ShinyApp.command)
Update_Finder.bat          NEW  Windows equivalent
```

`build_finder_index.R` is the only new moving part. It **reads** `__ReadMe.xlsx`, `_keys/*.csv`,
`__Public/comparative-data/*.tsv` headers, and a folder listing; it **writes** only into
`__Finder/data/`. Run time should be a few seconds — it parses TSV *headers* and counts rows, it does
not load 29k rows of data.

### The four index tables

**`finder_items.csv`** — the spine. One row per data item, carrying every facet plus a
pre-concatenated `search_text` column (citation + title + traits + structures + column names + folder
name) so the app's free-text search is a single `grepl` over one column.

| Field group | Fields |
|---|---|
| identity | `item_name`, `folder`, `paper`, `first_author`, `year`, `doi`, `citation`, `citation_short` |
| what it measures | `main_trait`, `measure_type`, `measure_class`, `canonical_structure`, `domain`, `region_of_interest` |
| taxonomic scope | `taxon_group`, `n_species`, `orders_present` |
| provenance | `team`, `collection`, `data_role`, `method`, `sample_type` |
| where the files are | `has_pdf`, `has_extraction_R`, `has_readme`, `has_snapshot`, `public_tsv`, `n_rows`, `n_cols`, `columns` |
| links | `gh_folder_url`, `gh_tsv_url`, `doi_url`, `local_path` |
| honesty | `export_status`, `facet_source` (see §5) |

**`finder_species.csv`** — one row per species name appearing anywhere: `species`, `accepted_name`,
`order`, `family`, `common_name` (see §5.2), `n_items`, `item_list`, `in_Stephan`,
`in_HerculanoHouzel`, `in_Allman`, `taxonomy_source`.

**`finder_variables.csv`** — flattened `variable_catalog.csv` joined to items, so a search for
"gyrification" hits the variable and returns the items that carry it.

**`finder_species_items.csv`** — the long edge table that powers "given a species, what data exists"
and "given these filters, which species survive". Built by reading the species column of each public
TSV. The column name varies — `species` (165 tables), `species_printed` (23), `species_sci` (20),
`taxon`, and paper-specific forms like `species_nudo1995` — so the build resolves it with a pattern
list and logs any table where it cannot.

### Data flow at runtime

Identical to the existing app, so there is one deployment story: the app fetches
`__Finder/data/*.csv` from `raw.githubusercontent.com/.../main/` at startup and falls back to the
local copies in `data/` if GitHub is unreachable. **Updating the public finder is therefore a
`git push`** — no redeploy needed unless `app.R` itself changes.

---

## 4. The app: four ways in

One `page_navbar`, mirroring the existing app's `bslib` styling so the two feel like siblings.

**Tab 1 — Find data.** The main view. A single free-text box (matches `search_text`) plus faceted
dropdowns: trait, structure, measure class, taxon group, order, team/collection, data role, decade,
and "has extraction script / has PDF / publicly exported". Results are a `DT` table, one row per
item, with citation, trait, species count, and a link column. Facet counts update against the
current filter so the user sees "cerebellum (14)" rather than guessing.

**Tab 2 — Find by species.** Type or pick a species (with alias and common-name matching); get every
item covering it, plus which collection the specimen came from, and — because this is the question
the repo cannot currently answer — a coverage strip showing which trait domains that species does
and does not have. Reverse direction too: pick trait domains, get the species list with data for all
of them.

**Tab 3 — Browse folders.** The organization as-is, made navigable: 144 study folders and the
working folders, each expandable to show what kind of files it holds, with GitHub and local links.
This is the "I know it's in a folder somewhere" path.

**Tab 4 — Coverage & gaps.** Falls out of the index for free (§5) and is arguably the highest-value
tab for the project rather than the public: which items have no trait tag, which have no public
export, which species are outside `species_reference.csv`, which folders hold no extraction script.

### Linking to folders — the honest version

This needs stating plainly because it constrains what "hyperlink to folders" can mean. **A browser
will not open a `file://` local folder from a web page** — it is a security restriction, not
something to work around. So each result row gets up to three link affordances, and which ones
appear depends on where the app is running:

| Affordance | Local run | On shinyapps.io | Verified against the live repo |
|---|---|---|---|
| **GitHub folder** — opens the folder's file listing | yes | yes | `200` on plain, underscore-prefixed, and space-containing folder names |
| **Raw TSV / DOI** — the data file, and the paper | yes | yes | `200`, with the encoding caveat below |
| **Open local folder** — `system2("open", …)` on macOS, `shell.exec` on Windows | yes | hidden | — |
| **Copy local path** — clipboard, for pasting into Finder/Explorer | yes | yes | — |

The app detects local-vs-hosted by testing whether the repo root is present on disk, so the same
`app.R` serves both your machine and the public without a config flag. Locally you get real
one-click folder opening; publicly you get GitHub, which is the right answer anyway since the public
has no local copy.

**Encoding is not optional.** The public filenames are *already* percent-encoded
(`10.1098%2Frspb.2015.1853_Table1.tsv`), so a URL must encode them a second time. Both forms were
tested against the live public repo:

- `…/10.1098%252Frspb.2015.1853_Table1.tsv` → **200**
- `…/10.1098%2Frspb.2015.1853_Table1.tsv` → **404**

The existing `pct()` in `app.R` already does byte-wise encoding correctly, which is exactly why it
should move to `_tools/lib_gh.R` and be used for every link the finder emits — including folder names
with spaces (`____Collections and Specimen notes` → `%20`, confirmed `200`).

---

## 5. What will be imperfect, and what to do about it

A finder built on this metadata will have visible holes. Hiding them produces a tool that silently
under-reports; surfacing them turns the same holes into a work queue. **Every facet value therefore
carries a `facet_source` of `registry` / `derived` / `missing`, and the UI marks derived values.**

### 5.1 The registry is about a third empty on the facet columns

Measured across the 294 rows of `__ReadMe.xlsx` Sheet1:

| Facet column | Filled | Consequence |
|---|---|---|
| `Main Trait(s)` | 184 / 294 | 110 items invisible to a trait filter |
| `Taxon group` | 201 / 294 | 93 invisible to a taxon filter |
| `Measure type` | 204 / 294 | |
| `Data role` | 204 / 294 | |
| `Method` | 111 / 294 | too sparse to facet on; show as a column only |
| `Team` | 103 / 294 | |
| `Collection` | 80 / 294 | |
| `Possible Traits` | 9 / 294 | unusable |

**Mitigation, in order of preference.** First, *derive* the missing facet from a second source:
`variable_catalog.csv` (1,144 rows, well populated) supplies `domain`, `canonical_structure` and
`measure_class` for most items, and the TSV column names themselves are a good trait signal. Second,
where nothing can be derived, show the item under an explicit **"untagged (110)"** bucket rather than
dropping it — a user filtering for volumes still sees that 110 items were not considered. Third, the
Coverage tab lists exactly which rows need a human, so filling `__ReadMe.xlsx` becomes a bounded task
instead of an open one.

Note the vocabularies are free text, not controlled: `Main Trait(s)` has **105 distinct values across
184 filled rows**, including near-duplicates (`cell numbers` vs `Cell numbers, region size`). The
build will normalize case and whitespace and apply a small synonym map, but a genuine controlled
vocabulary in `_keys/` is the durable fix and is worth doing as a follow-on.

### 5.2 Species names, taxonomy, and the missing common names

- **Taxonomy coverage is good — via the right key file.** 588 species appear across the merged long
  tables. `_keys/species_reference.csv` holds only **214 named species** (215 data rows, one of which
  has a blank `accepted_name` — see below; it is the curated M1 species list, not a taxonomy), but
  **`_keys/species_taxonomy.csv` holds 583 species across 27 orders and 114 families**
  and resolves **420/588 (71%)** directly. Adding genus-level fallback via `_keys/genus_family.csv`
  (1,240 genera) recovers **124 more**, for **544/588 = 93%** Order/Family coverage. So the Order
  facet is viable — the finder should key on `species_taxonomy.csv` with a `genus_family.csv` fallback,
  and treat `species_reference.csv` as the "is this in the core M1 set" flag it actually is.
- **The 44 unresolved names are 43 birds plus one genus rename**, all from
  Ruf & Geiser 2015 (torpor/hibernation): hummingbirds, nightjars, swifts, mousebirds. The mammal is
  `Ictidomys tridecemlineatus` (thirteen-lined ground squirrel, formerly *Spermophilus*) — a real gap
  worth fixing in `species_taxonomy.csv`. **This means ~7% of the species in the repo are not
  mammals**, which the finder should show honestly rather than implying a mammals-only scope; a
  `class` column (Mammalia / Aves) would let users filter it.
- **Data defect found while checking the above:** `species_reference.csv` row 133 has a **blank
  `accepted_name`** with `in_HerculanoHouzel = TRUE` and `needs_taxonomy_review = TRUE` — an orphan
  row flagging a Herculano-Houzel species whose name was never filled in. It is why the file's row
  count (215) and species count (214) differ. The build should skip blank keys rather than emit an
  empty facet value, and the row belongs on the Coverage tab for a human to resolve.
- **A counting convention for this document, since three row counts nearly tripped me up:** all
  counts here are **data rows excluding the header** unless stated. `wc -l` on these files returns
  one more (216 and 5 respectively). The build log should state which convention it uses.
- **`_keys/mammal_tree.nwk` has 198 tips, all of which are in the long tables** — a clean subset, so
  the finder can flag "has phylogeny" as a facet for the 198 without extra work.
- **`species_display_aliases.csv` has 4 alias rows** (5 lines including the header). Fine for the
  analysis app; too thin for a search box,
  where "Macaca mulata" (one *t*) and "M. mulatta" must both hit. The finder will do fuzzy matching
  (`agrep`) at query time rather than demanding the alias table grow first.
- **There are no common names anywhere in the repo.** A public user will search "dolphin", "macaque",
  "mouse lemur". This is the single cheapest, highest-payoff addition: one `common_name` column keyed
  to `species_reference.csv`. Recommend adding it, and until it exists, saying so in the app's search
  placeholder rather than letting the search silently fail.
- The specimen-identity work in `_keys/specimen_crosswalk` and `____Collections and Specimen notes`
  matters here: one animal under several species labels, and pre-2001 `Pongo pygmaeus` pooling what
  are now two species. The finder will not attempt to resolve these — it will **link to the specimen
  note** whenever an item touches a crosswalked specimen, so the caveat reaches the user at the point
  of use.

### 5.3 Three item counts that do not reconcile

294 registry rows, 246 public TSVs, 144 study folders. The build reconciles them and assigns each
item an `export_status`:

- `exported` — registry row with a matching TSV on disk (242 of them)
- `not_exported` — in the repo but no public TSV. `__ReadMe_export_gaps.md` documents **30 such
  items**, some genuinely non-tabular (Isler 2008 `Tree.nex`, Iwaniuk 1999 reference list). These must
  appear in the finder marked "in repo, not publicly exported" — a user searching for DeCasien diet
  data should learn it exists here, not get silence.
- `unregistered` — **4 TSVs on disk with no registry row** (Caves et al. 2018 is a known one, per the
  gaps doc). These surface on the Coverage tab.
- `placeholder` — e.g. Brodmann 1913 carries a placeholder DOI; its link must be suppressed rather
  than emitting a dead `10.0000/…` URL.

### 5.4 Region of interest is not yet a field

`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` calls for tagging items by region (M1 / V1 / entorhinal /
whole-brain), notes that V1 coverage is already substantial but unlabelled, and identifies entorhinal
as the real gap. The finder is the natural consumer of that tag, and the scope note is right that the
tag belongs in `_keys/variable_catalog.csv`, not invented here. **The index will read a
`region_of_interest` column if present and omit the facet if not** — so the app ships now and the
facet lights up when the tagging lands, with no app change.

---

## 6. Build order

Each step ends somewhere usable, so this can stop early if the direction turns out to be wrong.

1. **Reconciliation pass, no app.** Write `build_finder_index.R` far enough to join the four sources
   and emit `finder_items.csv` + `finder_build_log.md`. Deliverable: a written statement of exactly
   how many items are searchable on each facet, and the specific unresolved rows. *This is the step
   that tells us whether the metadata supports a useful finder — worth reviewing its output before
   step 2.*
2. **Species index.** Add the species-column resolution across 246 TSVs, emit `finder_species.csv` +
   `finder_species_items.csv`, keyed on `species_taxonomy.csv` with `genus_family.csv` genus fallback
   (93% coverage, §5.2). Deliverable: species coverage numbers and the list of tables whose species
   column could not be resolved.
3. **Refactor the shared helpers.** Move `pct()` and the GitHub-fetch/fallback into
   `_tools/lib_gh.R`; have `__ShinyApp/app.R` source it and confirm the existing app is unchanged.
4. **The app, tabs 1 and 3.** Find-data and browse-folders — the minimum that answers the original
   question. Run locally, verify every link class resolves.
5. **Tabs 2 and 4.** Species search and the coverage/gaps view.
6. **Deploy path.** `Update_Finder.command` / `.bat`, `README.md`, and a decision on whether the
   finder deploys as its own shinyapps.io app or the two updaters merge into one script.
7. **Follow-ons, separately scoped:** `common_name` column (biggest public-usability win); a
   controlled trait vocabulary in `_keys/`; add the 43 birds + `Ictidomys tridecemlineatus` to
   `species_taxonomy.csv` and a `class` column; fill or delete the blank-`accepted_name` row in
   `species_reference.csv`; `region_of_interest` tagging.

### Maintenance

Same contract as the existing app, which is the point of mirroring it: change data → run the updater
→ the public app reflects it. The index is derived, so it must be rebuilt when `__ReadMe.xlsx`,
`_keys/`, or `__Public/comparative-data/` change. Cheapest robust option is to add the finder build to
the existing `run_all_scripts_v2.R` and to `update_shinyapp.R`, so nobody has to remember a second
command. The build should be **idempotent and safe to run at any time** — it only reads the repo and
only writes `__Finder/data/`.

---

## 7. Decisions needed before step 1

1. **One app or two?** Separate `__Finder/` URL as proposed, or a fifth tab in the existing app?
   (Recommend separate — different job, different weight.)
2. **Public search scope.** Should the finder surface items with `export_status = not_exported` — i.e.
   tell the public that data exists in the repo but is not yet extracted? (Recommend yes, clearly
   labelled; it is accurate and it invites collaboration.)
3. **Where the trait vocabulary lives.** Normalize inside the build script for now, or create
   `_keys/trait_vocabulary.csv` as part of this work? (Recommend inside the build now, promote to
   `_keys/` once the mapping has stabilized.)
4. **Common names.** Add the column as part of this work, or as a follow-on? It is the biggest single
   improvement to public usability, and ~214 rows is an afternoon.
