# Terhune_Ronald_1975 — Table 1 (underwater audiogram of two ringed seals)

## Source
Terhune, J. M., & Ronald, K. (1975). Underwater hearing sensitivity of two
ringed seals (*Pusa hispida*). *Canadian Journal of Zoology*, 53(3),
227-231. doi:10.1139/z75-028

Registry Item **Table 1**, "Underwater hearing sensitivity of two ringed
seals in dB re 1 µbar", printed p. 229. Public copy:
`Terhune_Ronald_1975/Terhune-1975-Underwater hearing sensitivity of.pdf`.

## Species flag (important — read before merging with the 1972 folder)
This folder's name (`Terhune_Ronald_1975`) is a companion/adjacent folder to
`Terhune_Ronald_1972`, and the two papers share a first author, methodology,
and journal, so it would be easy to assume they cover the same species. **They
do not.** `Terhune_Ronald_1972` reports the underwater audiogram of the harp
seal (*Pagophilus groenlandicus*). This paper reports the underwater
audiogram of a different species entirely: the **ringed seal, *Pusa
hispida*** (two subjects: one adult female, one adult male). This is
confirmed by the title, abstract, and body text, which explicitly compare
the new ringed-seal thresholds against the harp-seal thresholds from
Terhune and Ronald (1972) as a *different* species. Do not merge or conflate
the two items' data.

## Why this item exists
Minimum-audible-field underwater audiograms (1–90 kHz) were obtained for two
ringed seals using the same yes-no psychophysical tracking method as the
companion harp-seal study. The audiograms show uniform sensitivity (±7 dB)
from 1–45 kHz, a lowest threshold of -32 dB re 1 µbar (68 dB re 1 µPa) at 16
kHz, and a steep high-frequency roll-off (60 dB/octave) above 45 kHz. The
paper explicitly tests whether ringed-seal hearing resembles that of other
phocid subfamily members (harp, harbor, grey seals) studied to date.

## Source quality and verification
The source PDF is a scanned photocopy (NRC Research Press reprint) with an
OCR text layer; the automatically extracted Table 1 text was garbled into
unusable placeholder characters (multi-column table lost in extraction).
**Table 1 (15 frequencies x 2 subjects, printed p. 229) was therefore
transcribed by hand from a 200 dpi render of PDF page 3 and cross-checked
digit-by-digit against the rendered image** before finalizing the snapshot.

## Pipeline
Printed table -> snapshot -> analysis csv -> public TSV.

| file | role |
|---|---|
| `Terhune_Ronald_1975_Table1_snapshot.csv` | frozen source, printed wide layout (female/male columns side by side, as in the source) |
| `Terhune_Ronald_1975_Table1.R` | reshapes wide -> long, writes CSV + public TSV |
| `Terhune_Ronald_1975_Table1.csv` | tidy analysis rows, one per sex x frequency (30 rows) |
| `reference_tables/Terhune_Ronald_1975_Table1_definitions.csv` | data dictionary |

## Data role
All 30 rows are this paper's own new measurements ("primary"), from the two
tested ringed seals.

## Observation level
One row per subject (female or male) per tested frequency (15 frequencies,
1.0–90.0 kHz; 2 subjects each = 30 rows).

## Units
Threshold and SD columns are in dB re 1 µbar (add 100 to convert to dB re 1
µPa, per the paper's own stated convention). The 90-kHz female threshold and
SD are printed in parentheses in the source table — `(+18)` and `(5.1)` —
which the paper's text explains was near the edge of the testing apparatus's
range; this is preserved and flagged via
`value_is_parenthetical_estimate = TRUE` rather than being treated as an
equally-certain raw reading. Female minimum sensitivity: -32 dB at both 11.3
and 16.0 kHz (tied). Male minimum sensitivity: -31 dB at 44.9 kHz. The
paper's own summary statement ("lowest threshold was -32 dB... at 16 kHz")
matches the female subject's value.
