# _keys/General — spoke for papers with no registered collection

`species_key.csv` (unified schema, `_keys/SPECIES_NAMING.md` §3b; `collection = General`) holds the
variant → `accepted_name` rows of every paper that belongs to none of the named collection spokes
(Stephan, Allman, HerculanoHouzel, Ashwell, Hof, Lyamin, Sato), including fossil-hominin label papers
(Balzeau 2012, Kochiyama 2018, Weaver 2001). Keyed by `(source_publication = paper folder, variant_name)`;
`resolve_species()` globs it like any other spoke. If a paper later gets its own collection, move its
rows to that spoke (one paper → one spoke).
