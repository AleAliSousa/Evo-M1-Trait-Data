# Heffner, Koay & Heffner (1999) — Results text

Heffner, R. S., Koay, G., & Heffner, H. E. (1999). Sound localization in an Old-World fruit bat (*Rousettus aegyptiacus*): Acuity, use of binaural cues, and relationship to vision. *Journal of Comparative Psychology*, 113(3), 297–306. https://doi.org/10.1037/0735-7036.113.3.297

**Item:** `Heffner_etal_1999_ResultsText` · **Item encoded:** `10.1037%2F0735-7036.113.3.297_ResultsText` · **Public TSV:** `__Public/comparative-data/10.1037%2F0735-7036.113.3.297_ResultsText.tsv`

## What the item is

The paper prints no table; its values are in running text and the Figure 1 legend. `Heffner_etal_1999_ResultsText_snapshot.csv` is a **constructed snapshot**: one row per printed quantitative statement (29 rows), with section, journal page, subject, quantity, value and unit **exactly as printed**, the in-text citation, and the verbatim phrase it was read from.

| role | statements | content |
|---|---|---|
| **primary** (this study, *Rousettus aegyptiacus*) | S01–S14, S29 (15) | MAA per bat A/B/C = 12°, 11°, 12° and mean 11.6° (n = 3); head diameter 3 cm; calculated phase-ambiguity frequency 7.6 kHz at ±30°; phase cue used at 4–5.6 kHz (upper limit 5.6 kHz); chance (≤ ~.30) at 8 kHz; .66–.89 at 10–50 kHz; retina ~11.5 mm, ~180° arc; peak ganglion-cell density 9,704 cells/mm²; acuity 3.15 cycles/degree; field of best vision 27° |
| **secondary** (cited / compiled) | S15–S28 (14) | 60-dB hearing range 2.25–64 kHz (Koay, Heffner & Heffner 1998); Norway rat 12.8°, least weasel 12.0°, ferret 11.8°; big brown bat MAA 14° and field of best vision 139° and acuity 0.75 c/deg; pallid bat ±1° (landing error — **exclude_flag**, not an MAA); megachiropteran acuity 3.0–5.5 c/deg; *Rhinolophus rouxi* 0.35 c/deg; Rousettus 2.7–3.03 c/deg (Marks 1980); obstacle avoidance 1 mm (Griffin et al. 1958); cows' phase-cue limit 500 Hz; surface-dwelling-mammal mean MAA 11.3° |

Note: the printed mean 11.6° is not the arithmetic mean of the printed per-bat thresholds (12, 11, 12 → 11.67); the per-bat values are presumably rounded. Both kept as printed.

## Secondary sources (traceability)

`reference_tables/Heffner_etal_1999_ResultsText_references.csv` maps every printed citation (split `citation_as_printed` on `"; "`, join on `ref_key`) to its verbatim bibliography entry, transcribed from the page-10 image (the text layer misreads "Heffner" as "Heffher" and "Kornfield" as "Komfield").
- S19–S21 share one printed citation group (*H. E. Heffner & Heffner, 1985; R. S. Heffner & Heffner, 1987; Kavanagh & Kelly, 1987*); by title they supply rat, weasel and ferret respectively — the paper does not state the per-value assignment, so the CSV keeps the whole group on each row.
- **S28** (cows, 500 Hz) has no in-text citation; **recovered** from the Figure 7 legend as *R. S. Heffner (1981), Sound localization and the superior olivary complex in horses and cattle* (recorded in the references `note`; the CSV citation cell stays blank as printed).
- **S18** (11.3°) is the authors' own mean over the Figure 5 compilation; Figure 5 cites no per-species sources, so its inputs cannot be traced from this paper.

## Pipeline (reader named)

1. **Source:** `heffner_etal_1999.pdf` (publisher PDF with OCR text layer).
2. **Snapshot:** constructed by an AI assistant on 2026-10-28 from the text layer and checked line by line against 140–150-dpi renders of pp. 298, 300–303, 305–306; dashes, ± signs and units follow the page image.
3. **Data readable:** `Heffner_etal_1999_ResultsText.R` parses numeric value / range (value_min, value_max) / qualifier (approximately, upper_bound), converts Hz → kHz (S28 only), sets `observation_level` (individual bats, one retina, species, group), `data_role`, and resolves subjects through `_keys/General/species_key.csv` (`source_publication = Heffner_etal_1999`; stops on zero rows or any unresolved name). It asserts every printed citation exists in the references table.
4. **Online database:** public TSV from the same script.

Run 2026-10-28: `Rscript --vanilla Heffner_etal_1999_ResultsText.R` (env `evom1-r`, R 4.5.3) — completed, 29 rows × 18 columns.

**Observation level:** S01–S03 are individual bats; S10–S14 come from one retina (a fourth bat). Pool or label before any species-level use.

## Overlap with other repo items

The 60-dB hearing range (S17) is Koay, Heffner & Heffner (1998), already built as `10.1037%2F0735-7036.112.4.371_Figure6`. The field-of-best-vision / threshold pair (27°, 11.6°) reappears as a digitised point in `Heffner_Heffner_2018_Figure3` (via Heffner & Heffner 2016): the text values here take precedence.

## Files

| file | what it is |
|---|---|
| `Heffner_etal_1999_ResultsText_snapshot.csv` | constructed snapshot (29 printed statements) |
| `Heffner_etal_1999_ResultsText.R` | snapshot → analysis CSV + public TSV |
| `Heffner_etal_1999_ResultsText.csv` | analysis data |
| `reference_tables/Heffner_etal_1999_ResultsText_definitions.csv` | data dictionary |
| `reference_tables/Heffner_etal_1999_ResultsText_references.csv` | 13 citation keys → verbatim bibliography entries |
| `Heffner_etal_1999_ResultsText_registry_row.xlsx` | paste-ready registry update |
