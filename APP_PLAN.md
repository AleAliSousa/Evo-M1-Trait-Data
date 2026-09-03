# APP_PLAN — apps for searching and using Evo-M1-Trait-Data

**Single source of truth for app development, merged 2026-09-02** from the former
`APP_DEVELOPMENT_PLAN.md` (portal vision) and `FINDER_APPROACH.md` (the worked-out finder
proposal, written 2026-08-14). Both originals are preserved in `_archive/`. Companion to
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md` (the database-building doc — why the repo exists and what
to build next) and `__ShinyApp/DEPLOY.md` (deploying the existing analysis app).

**Architecture ruling (owner, 2026-09-02): separate apps, shared plumbing.** The Finder ships as
its own `__Finder/` Shiny app with its own shinyapps.io URL; the GitHub-fetch-with-local-fallback
logic and the `pct()` encoder are factored out of `__ShinyApp/app.R` into `_tools/lib_gh.R`,
which both apps `source()`. A unified multi-tab portal remains the long-term option (Part C), but
nothing in the near-term build couples the two apps beyond `lib_gh.R`.

---

# PART A — The ecosystem: three complementary views

The repository contains both source-level data and curated species-level compilations. These are
different stages of the data lifecycle: source-level data preserve original measurements,
specimen identifiers, and provenance; compiled datasets from the `__merging_*` workflows are for
comparative analysis and visualization; and not every source-level observation reaches a
compilation. Every app must keep that distinction visible to the user.

| View | App | Status |
|---|---|---|
| **Data discovery** — "what data is here, and where?" | `__Finder/` (Part B) | proposed, spec below |
| **Comparative analysis** — trait-vs-trait plots on compiled data | `__ShinyApp/` | live; see `__ShinyApp/DEPLOY.md` |
| **Specimen provenance** — one specimen across studies | Specimen Tracker (Part C) | future |

**Trait Explorer = the existing `__ShinyApp`.** Its scope (already implemented or incremental):
select x/y traits, filter by taxonomy, highlight species, regression display, export plots and
filtered data. It must carry the standing disclaimer:

> Trait Explorer uses curated compiled datasets and may not contain every source-level
> measurement available in the repository.

---

# PART B — `__Finder/`: the discovery app (the near-term build)

## B.1 The problem, stated precisely

The repo holds ~2,800 files in ~175 study folders plus working folders. Everything needed to
answer "what data is here?" already exists, spread across sources only the builder knows how to
join: `__ReadMe.xlsx` Sheet1 (380 items), `_keys/variable_catalog.csv` (~1,144 variables),
`_keys/species_taxonomy.csv` + `genus_family.csv` (93% of species resolvable to Order/Family),
`_keys/anatomy_reference.csv`, the public TSVs in `__Public/comparative-data/` (300 tables), and
the folders themselves. "Which papers give me cerebellum volumes for carnivores?" is currently
answered by knowing the literature, not by querying the repo.

**The finder does exactly one thing: turn that into a search box.** It reads, never writes, never
moves a file. Explicitly out of scope: plotting, merging, download-a-selection, PGLS — those live
in `__ShinyApp`. The finder's output is always **a citation, a file, and a link**; the user's
next click leaves the app.

## B.2 Architecture

```
_tools/
  lib_gh.R                 NEW  shared: GH_BASE, pct(), read_*_gh() with local fallback
  build_finder_index.R     NEW  the whole build; read-only over the repo

__Finder/
  app.R                    NEW  the finder (single file, target <400 lines)
  README.md                NEW  what it is, how to run, how to update
  data/                    NEW  derived index, committed so GitHub serves it
    finder_items.csv         one row per data item
    finder_species.csv       one row per species
    finder_variables.csv     one row per variable
    finder_species_items.csv species <-> item edges
    finder_build_log.md      what the build found and could not resolve

Update_Finder.command / .bat   NEW  double-click launchers (mirror Update_ShinyApp.*)
```

`build_finder_index.R` is the only new moving part: it reads `__ReadMe.xlsx`, `_keys/*.csv`,
public-TSV headers, and a folder listing; it writes only into `__Finder/data/`. The app loads the
derived index (a few hundred KB), not the merged long tables — cold start well under a second.
Runtime data flow is identical to the existing app (fetch from `raw.githubusercontent.com`, local
fallback), so **updating the public finder is a `git push`**.

### The four index tables

**`finder_items.csv`** — the spine. One row per data item, all facets plus a pre-concatenated
`search_text` column so free-text search is one `grepl`. Field groups: identity (`item_name`,
`folder`, `first_author`, `year`, `doi`, `citation`…); what it measures (`main_trait`,
`measure_class`, `canonical_structure`, `domain`, `region_of_interest`); taxonomic scope;
provenance (`team`, `collection`, `data_role`, `method`); where the files are (`has_pdf`,
`has_extraction_R`, `has_snapshot`, `public_tsv`, `n_rows`, `columns`); links (`gh_folder_url`,
`gh_tsv_url`, `doi_url`, `local_path`); honesty (`export_status`, `facet_source`).

**`finder_species.csv`** — one row per species name appearing anywhere: accepted name, Order,
Family, common name (once it exists), `n_items`, `item_list`, collection flags,
`taxonomy_source`.

**`finder_variables.csv`** — flattened `variable_catalog.csv` joined to items, so "gyrification"
hits the variable and returns the items carrying it.

**`finder_species_items.csv`** — the long edge table powering "given a species, what data
exists". The species column name varies across TSVs (`species`, `species_printed`,
`species_sci`, paper-specific forms); the build resolves it with a pattern list and logs
failures.

## B.3 The app: four ways in

One `page_navbar` mirroring the existing app's `bslib` styling.

**Tab 1 — Find data.** Free-text box + faceted dropdowns (trait, structure, measure class, taxon
group, order, team/collection, data role, decade, has-PDF/script/export). Results in a `DT`
table with citation, trait, species count, links. Facet counts update against the current filter.

**Tab 2 — Find by species.** Alias- and common-name-aware species search → every item covering
it, plus a coverage strip of trait domains present/absent. Reverse: pick trait domains, get the
species having all of them.

**Tab 3 — Browse folders.** The folder organization as-is, made navigable, with GitHub and local
links.

**Tab 4 — Coverage & gaps.** Falls out of the index for free; arguably the highest-value tab for
the project: untagged items, unexported items, unresolved species, folders without extraction
scripts.

### Linking honestly

A browser will not open a `file://` folder from a web page. Each result row gets up to three
affordances: GitHub folder link (works everywhere; verified 200 on underscore- and
space-containing names), raw TSV / DOI links, and — local runs only — open-local-folder /
copy-local-path. The app detects local-vs-hosted by testing whether the repo root is on disk.
**Encoding is not optional:** public filenames are already percent-encoded, so URLs must encode
them a second time (`%252F` → 200, `%2F` → 404, verified live). That is why `pct()` moves to
`_tools/lib_gh.R` and is used for every emitted link.

## B.4 What will be imperfect, and what to do about it

Every facet value carries a `facet_source` of `registry` / `derived` / `missing`, and the UI
marks derived values.

- **The registry facet columns are about a third empty** (measured 2026-08-14 on 294 rows:
  `Main Trait(s)` 184 filled, `Taxon group` 201, `Team` 103, `Collection` 80; the registry has
  since grown to 380 rows — the build log must re-measure). Mitigate by deriving from
  `variable_catalog.csv` and TSV column names; show the rest under an explicit "untagged"
  bucket; list rows needing a human on the Coverage tab. Vocabularies are free text
  (105 distinct `Main Trait(s)` values) — normalize in the build now, promote a controlled
  vocabulary to `_keys/` once stable.
- **Species and taxonomy.** Key on `species_taxonomy.csv` with `genus_family.csv` genus
  fallback (93% Order/Family coverage); treat `species_reference.csv` as the core-M1-set flag it
  actually is. The unresolved names are ~43 birds (Ruf & Geiser 2015) plus
  `Ictidomys tridecemlineatus` — fix in `species_taxonomy.csv`, and add a `class` column so the
  ~7% non-mammal content is shown honestly. Known defect: `species_reference.csv` row with blank
  `accepted_name` (HH species, `needs_taxonomy_review`) — skip blank keys in the build, surface
  on Coverage. Fuzzy matching (`agrep`) at query time rather than growing the alias table.
  **No common names exist anywhere in the repo** — the single cheapest, highest-payoff addition
  (one column, ~214 rows).
- **Item counts do not reconcile** (registry rows vs public TSVs vs study folders — as of
  2026-09-02: 380 / 300 / ~175). The build assigns each item an `export_status`: `exported`,
  `not_exported` (shown, marked "in repo, not publicly exported"), `unregistered` (Coverage
  tab), `placeholder` (suppress dead placeholder-DOI links, e.g. Brodmann 1913).
- **`region_of_interest` is not yet a field.** The roadmap owns that tagging (in
  `variable_catalog.csv`); the index reads the column if present and omits the facet if not, so
  the app ships now and the facet lights up when tagging lands.
- **Specimen identity:** the finder does not resolve crosswalked specimens — it links to the
  specimen note whenever an item touches one.

## B.5 Build order

Each step ends somewhere usable.

1. **Reconciliation pass, no app** — `build_finder_index.R` far enough to emit
   `finder_items.csv` + build log; review before continuing.
2. **Species index** — species-column resolution across the public TSVs.
3. **Refactor shared helpers** into `_tools/lib_gh.R`; confirm `__ShinyApp` unchanged.
4. **App, tabs 1 and 3** (find-data + browse-folders); verify every link class locally.
5. **Tabs 2 and 4.**
6. **Deploy path** — `Update_Finder.*`, README, own shinyapps.io URL.
7. **Follow-ons, separately scoped:** `common_name` column; controlled trait vocabulary in
   `_keys/`; birds + `Ictidomys` into `species_taxonomy.csv` + `class` column; fix the
   blank-`accepted_name` row; `region_of_interest` tagging.

Maintenance: the index is derived — rebuild whenever `__ReadMe.xlsx`, `_keys/`, or
`__Public/comparative-data/` change; add the build to `run_all_scripts_v2.R` and
`update_shinyapp.R` so nobody remembers a second command. Idempotent, read-only over the repo.

### Open decisions (carried from the 2026-08-14 proposal)

1. ~~One app or two?~~ **Settled 2026-09-02: separate `__Finder/`.**
2. Surface `not_exported` items publicly? (Recommend yes, clearly labelled.)
3. Trait vocabulary: in-build normalization now, promote to `_keys/` later. (Recommended.)
4. Common names: part of this work or follow-on? (~214 rows, biggest public-usability win.)

---

# PART C — Longer term: Specimen Tracker and portal integration

**Specimen Tracker** — specimen-centric search and provenance. Search by specimen identifier
(valid only within a collection GROUP), collection, species, publication, or dataset; return
canonical specimen identity, species, collection, source datasets, publications, measured
traits, and reuse across studies. Builds directly on `_keys/specimen_crosswalk`,
`taxon_concept_registry`, and `____Collections and Specimen notes/`. Example uses: how many
studies include a particular chimpanzee specimen; which publications reused specimens from an
earlier study. Build only after the Finder ships — its species/item edge tables and `lib_gh.R`
are prerequisites, and the Finder's specimen-note links are the interim answer.

**Portal integration** — the original unified-portal vision (one Shiny app: Data Directory /
Trait Explorer / Specimen Tracker tabs with shared data-loading) is retained as the long-term
target, reachable by promoting the by-then-proven modules into one `page_navbar` app. Natural
navigation: Data Directory → trait → Trait Explorer → species → Specimen Tracker. Whether to
unify is a decision to revisit once both standalone apps exist; nothing before then should
assume it.
