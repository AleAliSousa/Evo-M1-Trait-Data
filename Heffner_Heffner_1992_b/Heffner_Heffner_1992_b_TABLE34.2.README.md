# Heffner & Heffner (1992b) — Table 34.2

Heffner, R. S., & Heffner, H. E. (1992). Evolution of sound localization in mammals. In D. B. Webster, R. R. Fay, & A. N. Popper (Eds.), *The evolutionary biology of hearing* (pp. 691–715). Springer. https://doi.org/10.1007/978-1-4612-2784-7_43

**Item:** `Heffner_Heffner_1992_b_TABLE34.2` · **Item encoded:** `10.1007%2F978-1-4612-2784-7_43_TABLE34.2` · **Public TSV:** `__Public/comparative-data/10.1007%2F978-1-4612-2784-7_43_TABLE34.2.tsv`

**TABLE 34.2.** Species of mammals grouped by ability to use the main binaural locus cues (p. 696). Columns Ability / Species / Source; 20 species under four printed group headings: *Use both Δθ and ΔI* (12), *Ability to use Δθ reduced or absent* (2), *Ability to use ΔI reduced or absent* (5), *Unable to use Δt or Δfi* (1). The heading notation switches from Δθ/ΔI to Δt/Δfi in the last group — kept as printed.

## Data role

**secondary.** Every row is a categorical result taken from the study named in its Source cell. The analysis CSV keeps that key verbatim (`source_as_printed`); `reference_tables/Heffner_Heffner_1992_b_TABLE34.2_references.csv` binds each key to its verbatim bibliography entry (17 distinct keys; join `source_as_printed` = `ref_key`; no multi-citation cells). Use as a roadmap to the primary tone-localisation studies; do not ingest as new data.

**Traceability notes (verbatim, not corrected):**
- *"Mooney unpublished Master’s thesis"* (Spiny mouse) — **cited but absent**: the bibliography has no thesis entry; the only Mooney entry is the 1990 ARO abstract on hearing (Mooney, Heffner & Heffner 1990), cited in the text (p. 697) for the spiny-mouse audiogram. Not substituted.
- *"Heffner and Masterton 1980"* is printed without an initial; the bibliography entry is *Heffner H, Masterton B (1980)* (Henry Heffner).
- *"R. Heffner and Heffner 1986b"* (Cattle, Goat) is a conference abstract.
- *"Masterton et al. 1975"* is cited for three species (Tree shrew, Norway rat, Hedgehog).

## Pipeline (reader named)

1. **Source:** `heffner_heffner_1992_bookchapter.pdf` (scan; text layer renders the Greek group labels as "~e", "~J", "M", "~fi").
2. **Snapshot:** `Heffner_Heffner_1992_b_TABLE34.2_snapshot.csv` — transcribed by an AI assistant on 2026-10-28 from a 250-dpi render of PDF page 6; every cell checked against the image. Printed layout: group headings on their own rows in the Ability column, species rows below with Ability blank, printed row order.
3. **Data readable:** `Heffner_Heffner_1992_b_TABLE34.2.R` carries each heading down onto its species, recodes the four headings (`binaural_cue_use`: both / time_cue_reduced_or_absent / intensity_cue_reduced_or_absent / neither, plus per-cue columns), asserts every Source key exists in the references table, and resolves species via `_keys/General/species_key.csv` (`source_publication = Heffner_Heffner_1992_b`; stops on zero rows or any unresolved name).
4. **Online database:** public TSV from the same script.

Run 2026-10-28: `Rscript --vanilla Heffner_Heffner_1992_b_TABLE34.2.R` (env `evom1-r`, R 4.5.3) — completed, 20 rows × 9 columns. No table checks (no printed arithmetic).

## Species

Common names only. Most binomials are confirmed by the chapter's own Fig. 34.10 legend (p. 709) or the cited source's title (key `note`). Two need curator attention: **Hedgehog** → *Hemiechinus auritus* is a *hypothesis* (Masterton et al. 1975 is attributed *Hemiechinus auritus* in this repo's `Heffner_etal_2010` Table I; the chapter's Fig. 34.10 hedgehog is *Paraechinus hypomelas* from a different study, H. Heffner & Heffner 1984 — do not conflate); **Tree shrew** → *Tupaia glis* (medium confidence, the Heffner-lab tree shrew in the bibliography).

## Files

| file | what it is |
|---|---|
| `Heffner_Heffner_1992_b_TABLE34.2_snapshot.csv` | frozen snapshot (printed layout) |
| `Heffner_Heffner_1992_b_TABLE34.2.R` | snapshot → analysis CSV + public TSV |
| `Heffner_Heffner_1992_b_TABLE34.2.csv` | analysis data (20 rows) |
| `reference_tables/Heffner_Heffner_1992_b_TABLE34.2_definitions.csv` | data dictionary |
| `reference_tables/Heffner_Heffner_1992_b_TABLE34.2_references.csv` | 17 source keys → verbatim citations |
| `Heffner_Heffner_1992_b_TABLE34.2_registry_row.xlsx` | paste-ready registry row |

## Errata

<!-- errata:begin -->
<!-- errata:end -->
