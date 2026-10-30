# Heffner_etal_2001_a_Figure6 - README

**Source.** Heffner, R. S., Koay, G., & Heffner, H. E. (2001). Sound localization in a new-world frugivorous bat, *Artibeus jamaicensis*: Acuity, use of binaural cues, and relationship to vision. *Journal of the Acoustical Society of America, 109*(1), 412-421. https://doi.org/10.1121/1.1329620

**Item.** `FIG. 6` (p. 419). Registry `Item name` will be `Heffner_etal_2001_a_Figure6` once the row
is pasted (**`sequence` = "a"** required).

## What this item is

FIG. 6 is the **primary version** of the relationship that `Heffner_Heffner_2016_Figure5`
reproduces: width of the field of best vision against sound-localization threshold, here for
**24 species** (the 2016 figure shows 22), with `r = 0.916`, `P < 0.0001` printed in the caption
and `r = .916` printed inside the panel - both kept as printed.

Like the 2016 item, this is a **roster, not coordinates** (owner decision): the figure plots points,
prints no values, and its caption points elsewhere for them - *"for citations, see Heffner et al.,
1994"*. What this item adds over the 2016 roster is **authoritative identity**: the legend prints a
letter code, a common name *and a binomial* for every point.

That resolves two identities the 2016 item could only flag:

- `marmot` -> ***Marmota monax*** (the 2016 item had to settle for *Marmota* sp.);
- `hamster` -> ***Mesocricetus auritus*** as printed here, a misprint for *M. auratus*, which the
  species key already carries as a spelling variant - so the 2016 item's `hypothesis` basis is now
  corroborated by a printed binomial.

**Roster differences.** The 2001 figure has five species the 2016 figure drops - chipmunk
(*Tamias striatus*), prairie dog (*Cynomys ludovicianus*), domestic rabbit (*Oryctolagus
cuniculus*), spiny mouse (*Acomys cahirinus*), wood rat (*Neotoma floridana*) - and lacks the three
bats 2016 adds (short-tailed, straw-colored and greater spear-nosed fruit bats): 24 - 5 + 3 = 22.

## Files

| file | what it is |
|---|---|
| `Heffner_etal_2001_a_Figure6_snapshot.csv` | the frozen **constructed** snapshot: caption, both printed axis titles, both tick-label sets, the caption and panel statistics, the caption's citation pointer, and the 24 legend entries |
| `Heffner_etal_2001_a_Figure6.R` | build: snapshot -> analysis CSV (+ public TSV once registered) |
| `Heffner_etal_2001_a_Figure6.csv` | analysis CSV, 24 rows x 18 columns |
| `reference_tables/Heffner_etal_2001_a_Figure6_definitions.csv` | data dictionary (20 rows) |

## Source -> snapshot (constructed)

Unlike the 2016 figure, **this caption is in the PDF text layer**, so the legend was extracted
rather than transcribed; the layer's punctuation mis-mapping (`~`/`!` for parentheses, `5` for `=`,
`,` for `<`) was corrected and the result **verified against a 200-dpi render of printed p. 419**,
as were the axis titles and tick labels, which are only on the plot.

**Reader.** AI assistant (Claude), 2026-10-29. Pending human RA sign-off.

## Printed quirks, preserved

`Felis domesticus` (-> *Felis catus*), `Canis familiaris` (-> *Canis lupus familiaris*),
`Mesocricetus auritus` (-> *M. auratus*), lowercase `virginia opossum`, and the caption/panel
disagreement over `0.916` vs `.916`. All 24 printed binomials resolve through existing key spokes,
so this paper adds **no new rows** to `_keys/General/species_key.csv`.

## Table checks

The 24 letter-coded legend entries are checked against the caption's "24 species of mammals" -
**passes exactly**.

## Data role and merge

`secondary`, and not wired into any merge: with no coordinates there is nothing to merge. The one
value this paper measures itself is in `Heffner_etal_2001_a_ResultsText`.
