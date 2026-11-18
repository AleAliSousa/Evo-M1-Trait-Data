# Missing Orders: continue after NCBI

**NCBI is preferred for lookup speed and genome links, not an exclusive
taxonomic authority. A missing NCBI record is a handoff to the next database,
never a reason to leave a recognizable animal's Order unidentified.**

## Lookup ladder

1. Check the source label, existing project keys, and NCBI exact names and
   documented synonyms. An API error, missing taxid, or incomplete NCBI lineage
   does not mean that the animal lacks a classification.
2. **Mammal Diversity Database (MDD)** for living and recently extinct mammals.
   Search the accepted species table and the accompanying synonym table. Match
   a species first; an unambiguous genus or family is sufficient to assign an
   Order even when species identity is not resolved. MDD's scope does not cover
   most older fossil mammals, so immediately continue those to GBIF/PBDB.
3. **GBIF** for broader coverage, historical names, synonyms and fossil taxa.
   Use the species match service with the animal kingdom constraint. Exact
   species/synonym matches take precedence over genus/family matches. Fuzzy
   candidates require checking their spellings and source context; a high
   confidence score alone is not evidence of identity.
4. **ITIS**: search the scientific name, then retrieve its full hierarchy by
   TSN. Read the Order from the hierarchy, not from a search-result snippet.
5. **Paleobiology Database (PBDB)** for fossil mammals, including fossil
   primates and historically grouped stem taxa. Preserve the actual named
   Order and cited classification; do not assume every fossil in a primate
   paper belongs to crown Primates.
6. If these do not resolve it, examine the original paper/key and specialist
   taxonomic literature (or the appropriate specialist register). Expand an
   abbreviation or correct a printed/OCR spelling with recorded evidence.
   Record the source location, query/matched names, chosen authority and URL.
   Continue the curation task until there is a supported classification or an
   explicitly documented genuine ambiguity. **"Not in NCBI" is not a terminal
   status.**

Database errors continue to the next provider and remain marked `service_error`
for retry. Conflicting homonyms should first be disambiguated with the full
species name and source context; do not stop after a genus-only collision.

## Run and rebuild

From the repository root:

```sh
python3 _keys/build_species_taxonomy.py
python3 _tools/update_navigation_taxonomy.py
python3 -B _checks/test_navigation_taxonomy.py
Rscript _checks/shiny_usability.R
```

The updater runs NCBI, rebuilds the local key, continues unresolved labels
through MDD → GBIF → ITIS → PBDB, and rebuilds again. To continue a previously
completed NCBI pass directly, run `python3 _tools/update_order_fallbacks.py`,
then rebuild the taxonomy key. `--ncbi-only` is for provider maintenance, not a
completed missing-Order curation pass. The normal key rebuild and app never
perform live taxonomy requests.

## Records and handoff

- `genus_navigation_taxonomy.csv`: dated NCBI genus/family classifications.
- `order_navigation_fallbacks.csv`: accepted classifications for original
  compiled labels, with authority, matched name, match basis, URL and date.
- `navigation_taxonomy_search_log.csv`: each downstream provider query and
  outcome. Review candidates and retry errors rather than treating them as
  absent taxa.
- `navigation_taxonomy_review.csv`: unfinished source/literature work, with a
  distinct status and next action. This is a work queue, not a list of taxa
  declared unclassifiable.
- `navigation_label_queries.csv`: source-reviewed spellings, abbreviations and
  higher-taxon queries. Querying a family/genus assigns Order without asserting
  a species identity. Re-check the source context before adding a query.
- `navigation_order_evidence.csv`: explicit source-table or specialist/literature
  classifications used after database lookup, with the same provenance fields.
  Includes context-resolved group labels and specialist protist synonyms.
- `navigation_label_issues.csv`: verified missing/mixed-placeholder problems and
  the exact upstream fields to repair. In particular, `not specified` combines
  squirrel, tree shrew and macaque in Jung's table, while `Not recognised` is a
  PHYLACINE-name placeholder across hundreds of species in Soria's table. These
  are not taxa that lack an Order; their mixed rows must be separated upstream.
- `_checks/shiny_taxonomy_unresolved.csv`: current app labels still lacking an
  Order, with originating datasets, for tracing the source.

Distinguish a scientific animal name, a higher/unspecified animal label, and
non-taxon text. An anatomical region, cause of death, measurement method or
footnote in a Species field is an upstream extraction problem; do not invent an
Order for it or count it as an animal that taxonomy databases failed to cover.

Keep the original label and all trait values. A navigation classification does
not change species identity, prove two samples can be pooled, or create an NCBI
taxid. Non-NCBI evidence stays explicitly non-NCBI in `Order_basis`. Existing
resolved classifications are not silently replaced merely because a later
database uses a different order circumscription.

## Provider references

- [MDD scope and current release](https://www.mammaldiversity.org/),
  [release downloads and synonym tables](https://www.mammaldiversity.org/releases/).
- [GBIF species API](https://techdocs.gbif.org/en/openapi/v1/species).
- [ITIS web services](https://www.itis.gov/web_service.html) and
  [full-hierarchy API](https://itis.gov/ws_hierApiDescription.html).
- [PBDB taxon service](https://paleobiodb.org/data1.2/taxa/list_doc.html).
