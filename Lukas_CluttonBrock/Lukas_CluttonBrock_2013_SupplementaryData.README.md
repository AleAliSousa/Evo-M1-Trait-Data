# Lukas_CluttonBrock_2013_SupplementaryData — Social organization of 2,545 mammalian species

Lukas, D., & Clutton-Brock, T. H. (2013). The evolution of social monogamy in mammals. *Science*,
341(6145), 526–530. https://doi.org/10.1126/science.1238677

## What this item is
2,545 mammalian species classified as solitary, socially monogamous, or group-living, with
paternal-care status and a per-species source reference. This is the species-level dataset
underlying the paper's phylogenetic comparative analyses (summarized by order in the PDF's
Table S1: 229/2,545 = 9% socially monogamous overall).

## Source — digital-native, not transcribed from the PDF
The paper's own supplementary PDF (`lukas.sm.pdf`) prints this exact table as plain text spread
across 66 pages (pp. 18–83), but its embedded text layer extracts in column-stream order (all
species names together, then all Yes/No answers together, then all references together) rather
than row order — reconstructing 2,545 rows × 5 columns reliably from that would mean slow,
error-prone visual transcription.

Instead, the authors separately deposited this identical dataset as a structured, digital-native
file on KNB (the Knowledge Network for Biocomplexity): "Social systems of mammalian species",
https://knb.ecoinformatics.org/#view/doi:10.5063/F1NC5Z4D, entity
`SupplementaryData_Lukas&CluttonBrock_EvolMonogamyMammals_data_Science2013.csv` (object id
`dieter_lukas.14.1`), fetched directly from
`https://knb.ecoinformatics.org/knb/d1/mn/v2/object/dieter_lukas.14.1`. Its row count (2,545) and
first several rows match the PDF table exactly. Per house convention for a digital-native source,
the untouched download is frozen byte-identical as the snapshot (confirmed by md5) rather than
re-transcribed.

## Determining the reference for any datapoint
Each row carries a `Reference_code` column — a shorthand key (author surname(s) + year + optional
journal/source abbreviation, e.g. `"Nowak_1999_Mammal_Book"`) exactly as exported. These keys are
**not numbered** and are matched against the paper's separately-registered
`Lukas_CluttonBrock_2013_ReferencesforSupplementaryTable` item (the alphabetically-ordered
bibliography transcribed from `lukas.sm.pdf`, pages 85–107 of 107 — PDF page index, "References
for Supplementary Table" heading) by author-surname + year, with journal-abbreviation hints used
to break ties between same-author-same-year entries.

`reference_tables/Lukas_CluttonBrock_2013_SupplementaryData_references.csv` is the resulting
lookup (`ref_key` → `ref_id`/`citation`, one row per unique shorthand code, 517 keys). **435 of
517 unique keys (2,013 of 2,545 rows, 79%) resolve** to a specific bibliography entry. The
remaining 82 keys (532 rows, 21%) do not resolve with confidence, for two distinct reasons kept
separate in that file's `note` column:
- **Cited-but-absent**: the single highest-frequency case is `Murariu_&_Benedek_2005_Grig_Antip`
  (366 rows, 14% of the whole table) — this exact author surname does not appear anywhere in
  `lukas.sm.pdf`'s printed reference list, in any page, confirmed by a full-text search. This is
  a genuine gap in the paper's own supplementary materials, not a transcription error on this
  side — and matches an independent, published critique of this dataset noting that its
  per-order "default" reference for Soricomorpha specifically describes a single shrew species
  in Romania and does not support the social-organization calls made for the other 366 species
  of that order (Schradin, 2017, *Royal Society Open Science*,
  https://doi.org/10.1098/rsos.170346).
- **Unresolved shorthand**: the rest are keys whose author-surname/year could not be matched to
  any printed entry with confidence (exact match, then a conservative fuzzy match allowing ±1
  year and close surname spelling) — kept as `NOT FOUND`/unresolved rather than guessed.

## Data role
**Secondary** — this is the paper's own compiled, literature-sourced classification (per-species
provenance tracked via `Reference_code`), not primary data measured by this paper's authors.

## Files
- `Lukas_CluttonBrock_2013_SupplementaryData_snapshot.tsv` — the untouched KNB download, frozen
  byte-identical (md5-verified).
- `Lukas_CluttonBrock_2013_SupplementaryData.csv` / public TSV — same content, column names
  cleaned for analysis use, published.
- `reference_tables/Lukas_CluttonBrock_2013_SupplementaryData_references.csv` — the reference-key
  lookup described above.
