# Wiafe 2019: observed primate group sizes

Wiafe, E.D. (2019). Encounter rates and group sizes of diurnal primate species of
Mole National Park, Ghana. Journal of Threatened Taxa 11(5):13523–13530.
https://doi.org/10.11609/jott.4026.11.5.13523-13530

Original PDF downloaded 2026-10-23 from the publisher:
https://threatenedtaxa.org/index.php/JoTT/article/download/4026/6224
CC BY 4.0. Not found in the local EndNote metadata search.

## Build chain (R owns the analysis layer, added 2026-10-31)

| file | written by | reads |
|---|---|---|
| `Wiafe__2019_Table3_snapshot.csv`, `Wiafe__2019_GroupSizes_snapshot.csv` | `build_group_sizes.py` (transcription only) | the PDF, by hand |
| `Wiafe__2019_Table3.csv` | `Wiafe__2019_Table3.R` | the Table 3 snapshot |
| `Wiafe__2019_GroupSizes.csv` | `Wiafe__2019_GroupSizes.R` | the abstract snapshot |

`build_group_sizes.py` no longer writes the CSVs (one writer per file). Both R scripts resolve the
printed names through `_keys/General/species_key.csv` (four `source_publication = Wiafe__2019`
rows, basis `common_name`, added 2026-10-31) and stop if those rows disappear. Neither item is in
`__ReadMe.xlsx` yet, so each writes its CSV and reports that the public TSV is skipped until a
registry row exists. The R rebuild reproduces `Wiafe__2019_Table3.csv` cell for cell; in
`Wiafe__2019_GroupSizes.csv` the Green Monkey mean is now the number `10` rather than the string
`10.0` — the printed `10.0` is preserved in the snapshot.

`build_group_sizes.py` reproduces the transcription. Table 3 (PDF page 8,
printed p.13528) was visually checked. All 16 sector rows, names, zeros and range
strings remain in the snapshot. The source's overall abstract summary is a
separate four-row snapshot and merge table. No zero-sized colobus groups are
invented from unobserved sectors, and no values are pooled across the two views.

Method: 40 five-kilometre transects, observers staying on the transect and
observing encountered groups for ten minutes. Age restriction is not specified;
these are not documented adult-only group sizes. Observational means are
population-specific, not universal species attributes.

Caution: Table 1 counts groups encountered in each sector, not individuals per
group. Its means (14.5/9.8/6.8) must not be mistaken for social group size. The
separately reported abstract means cannot be exactly reconstructed by weighting
Table 3's rounded sector means by Table 1 group counts. Retain the author's
reported values with this flag; do not silently replace them with derived means.
The colobus observation is one group of six. This source uses unambiguous
Chlorocebus sabaeus, not pooled Cercopithecus aethiops sensu lato.

## Snapshot provenance — repaired 2026-10-31

`Wiafe__2019_Table3_snapshot.csv` is now Table 3 **in its printed grid**: the sector band
(`Eastern` / `Southern` / `Western` / `Northern`) over the `Mean` / `SE` / `Range` sub-header, one
row per species in printed order, 12 value columns left to right. A reviewer can lay it beside
printed p. 13528 and match cell for cell. The long form it replaced is now
`Wiafe__2019_Table3.csv`, the analysis layer.

`Wiafe__2019_GroupSizes_snapshot.csv` is now a **constructed snapshot** of the Abstract sentences
(printed p. 13523), keeping the colobus value as the printed word `six`. `Wiafe__2019_GroupSizes.csv`
remains the analysis layer, where `six` becomes 6.

Both replace a duplicate pair that had been written under a `Wiafe__2019_` (double-underscore)
prefix with different content. Those two files were verified against the PDF, reproduced under the
folder-consistent names by `build_group_sizes.py`, and moved to Trash.

**Open for the owner:** the house convention gives single-author papers a double underscore
(`Gallup__1977`, `Karbowski__2007`, `Wirz__1950`). Wiafe 2019 is single-author, so this folder
arguably should be `Wiafe__2019`. It is unregistered and has no public TSV, so renaming is cheapest
now — but the rename also touches `source_publication` in the species key, so it is left to you.
