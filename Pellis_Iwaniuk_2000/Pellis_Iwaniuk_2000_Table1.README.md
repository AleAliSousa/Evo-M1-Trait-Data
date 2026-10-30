# Pellis_Iwaniuk_2000_Table1 — README

**Source.** Pellis, S. M., & Iwaniuk, A. N. (2000). Adult-adult play in primates: comparative
analyses of its origin, distribution and evolution. *Ethology, 106*(12), 1083-1104.
https://doi.org/10.1046/j.1439-0310.2000.00627.x

**Item.** `Table 1` (pp. 1087-1088), "Information on play and social organization for the species
used". Registry `Item name` = `Pellis_Iwaniuk_2000_Table1`, `Item encoded` =
`10.1046%2Fj.1439-0310.2000.00627.x_Table1`.

## What the data are

Species-level ratings of **adult-adult play fighting** in 71 primate species, scored separately for
the **sexual** and **non-sexual** context (0 = absent, 1 = present but rare, 2 = present and common,
with the ceiling raised to 3 for six strepsirrhines - printed as `2/3`), plus a binary **play
absent (0) / present (1)** column and, for the 20 strepsirrhine species only, a **social
organization** score (0-3). The ratings are compiled from the literature named in the table
footnote and were verified by the authors' own 20-50 h observations on ten species (p. 1088).

**This is the primary publication of these play scores** - see *Relationship to Iwaniuk et al.
(2001)* below, which matters for the merge.

## Files

| file | what it is |
|---|---|
| `Pellis-2000-Adult-Adult Play in Primates_ Comp.pdf` | the publication |
| `Pellis_Iwaniuk_2000_extract_snapshot.R` | PDF text layer -> frozen snapshot (no value typed in the script) |
| `Pellis_Iwaniuk_2000_Table1_snapshot.csv` | the frozen source: caption, two-tier header, 71 rows in printed order, both footnotes |
| `Pellis_Iwaniuk_2000_Table1.R` | build: snapshot -> analysis CSV + public TSV |
| `Pellis_Iwaniuk_2000_Table1.csv` | analysis CSV, 71 rows x 12 columns |
| `reference_tables/Pellis_Iwaniuk_2000_Table1_definitions.csv` | data dictionary (15 rows) |
| `__Public/comparative-data/10.1046%2Fj.1439-0310.2000.00627.x_Table1.tsv` | public TSV (repo-level) |

## Source -> snapshot

The source is a printed table, so a snapshot is required. `Pellis_Iwaniuk_2000_extract_snapshot.R`
pulls every score from the PDF's text layer at run time; only the caption, the two-tier column
headers and the two footnote lines are literals, each verified by an anchor assertion. The script
refuses to overwrite a differing frozen copy (writes `*_snapshot_NEW.csv` and stops).

**Glyph map** (both verified against a 200-dpi render of pp. 1087-1088, AI assistant, 2026-10-28):
the text layer renders the printed **en dash as the plus-minus sign** - it is a dash meaning *not
scored* - and drops the **ff ligature** (`Ateles geo\x80royi` prints as *Ateles geoffroyi*).

**Reader.** AI assistant (Claude), 2026-10-28: extraction script plus the page-render check of the
glyphs, the row count (48 rows on p. 1087 + 23 on p. 1088 = 71, the paper's stated sample) and the
irregular cells below. Pending human RA sign-off.

## Printed quirks, preserved

- **`Varecia variegata` has no presence value.** The printed row ends after the non-sexual column;
  the "Play absent (0) or present (1)" cell is blank on the page. It stays empty here - a blank is
  not a zero - and the build asserts that this is the only such row.
- **Dual values `2/3`** (six species: *Lepilemur edwardsii*, *L. mustelinus*, *Loris tardigradus*,
  *Nycticebus coucang*, *Otolemur crassicaudatus*, *Perodictus potto*). Footnote **: the first
  value was used to test the byproduct hypothesis, the second the social assessment hypothesis.
  The CSV keeps the printed cell plus both readings as their own columns.
- **Printed misspellings kept verbatim** and corrected only in the species key:
  `Perodictus potto` -> *Perodicticus potto* (the paper's own body text spells it correctly),
  `Saguinus fuscicolis` -> *Saguinus fuscicollis*, `Lepilemur edwardsii` -> *Lepilemur edwardsi*.
- En dash in the social-organization column = not scored (the score was assigned only where
  relative familiarity among group members could be judged), not a zero.

## Table checks

None: the table prints no totals, percentages or other internal relation that could check itself
(HOWTO section 7a - don't invent one).

## Relationship to Iwaniuk et al. (2001) - the merge-relevant finding

`Iwaniuk_etal_2001_Table4` (already in the repo, and the current source of the app's
`Play_total_score` / `Play_sex_score` / `Play_nonsex_score`) **republishes these scores**. Matching
the two tables species by species on the harmonised accepted name:

* **64 species shared (0 species are Iwaniuk-only), and every comparable cell is identical.**
  Where both tables print a value: 62 of 62 sexual scores agree and 63 of 63 non-sexual scores
  agree. The cells that are not comparable are missing on *both* sides (sexual: *Cacajao calvus*,
  *Phaner furcifer*; non-sexual: *Galagoides demidoff*, printed *Galagoides demidovii*), so no shared cell disagrees.
* **Five of the six species Pellis prints as `2/3` are shared with Iwaniuk, and for those five
  Iwaniuk prints the first (byproduct) value, 2.** The sixth, *Lepilemur edwardsi*, is not in
  Iwaniuk's Table 4 at all, so it is one of the additions below rather than a confirmation.
* Iwaniuk's `Total play` is `Sex play + Non-sex play` (holds for 61 of 64 species; the other three
  have a missing component);
* **this table adds 7 species** Iwaniuk's Table 4 does not carry - *Cebus olivaceus*,
  *Galago moholi*, *Lepilemur edwardsi*, *Macaca tonkeana*, *Mirza coquereli*, *Saguinus mystax*,
  *Tarsius bancanus* - and two variables Iwaniuk does not reprint at all: the binary play
  presence column and the strepsirrhine social-organization score.

The match was computed on harmonised accepted names (both tables through `resolve_species()`),
not on printed names: Iwaniuk prints several pre-revision binomials (e.g. *Cercocebus albigena*,
*Colobus badius*) that resolve to the same accepted species as this table's rows.

So Iwaniuk et al. (2001) Table 4 is the secondary, and this table the primary, for the play scores.
`__merging_supplementary/supplementary_sources.csv` was re-pointed accordingly (see that folder's
README): `Play_sex_score` and `Play_nonsex_score` now come from this item as `primary`, the two
Iwaniuk mapping rows for those labels were removed so the republication is not counted as a second
source, and `Play_total_score` stays with Iwaniuk, which is the publication that prints it.

## Data role

`primary`.
