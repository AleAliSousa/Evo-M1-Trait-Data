# Ketten (2012) — documented skip (no item built)

Ketten, D. R. (2012). Marine mammal auditory system noise impacts: Evidence and incidence. In A. N. Popper & A. Hawkins (Eds.), *The effects of noise on aquatic life* (Advances in Experimental Medicine and Biology, Vol. 730, pp. 207–212). Springer. https://doi.org/10.1007/978-1-4419-7311-5_46

Registry item: `Ketten__2012_Text(TTSvalues)` (Item number "Text (TTS values)", Data role secondary, recommendation "Low priority – related variable only"). **Not built** — decision 2026-10-28, under the project rule *"a review with only reproduced values gets a documented skip, not an item"*.

## Why no item

1. **Every quantitative value is reproduced from a single review.** Section 3 (p. 210) states: "Southall et al. (2007) provides a detailed discussion and original citations for the studies summarized below." The temporary-threshold-shift (TTS) onset exposures that follow (odontocetes p. 210; pinnipeds pp. 210–211) are Ketten's summary of that compilation. No value carries its own citation, so none can be traced to a primary study from this paper.
2. **Several values are already aggregated or ranged across studies/subjects** (e.g. "the mean shift onset was 195 dB SPL (SEL 192-201 dB)" for two species pooled; "TTS onsets near 170 dB (SEL 205 dB)" for two species together; growth "~2.5 dB TTS/dB noise"). Re-tabulating them would create pseudo-species values with no defined sample.
3. **No new data.** The chapter is a review; Figs. 1 and 2 are reproduced ("Updated from Yoshida and Liberman (2000)"; "Modified from Wartzok and Ketten (1999)"), and Fig. 2 audiograms have no axis-readable per-species sources in the legend.
4. **Measure class.** Noise-exposure TTS onset is an impact/criteria variable, not a sensory-ability trait of the kind the repo compiles.

## Where the values live (roadmap for primary ingestion)

Locators checked against a 130-dpi render of PDF p. 4 (journal p. 210) and the p. 211 text. Values as printed, for orientation only — **do not ingest from here**:

| locator | taxa as printed | statement (summary) |
|---|---|---|
| p. 210 ¶4 | *Tursiops truncatus* (bottlenose dolphin), *Delphinapterus leucus* [sic] (beluga whale) | ≥6-dB shift for single pulses at 160 kPa peak (SPL 226 dB peak-peak; SEL 186 dB); pure tones 3–80 kHz, ≤8 s: mean onset 195 dB SPL (SEL 192–201 dB); lowest onset 182 dB SPL, 1 subject, 75 kHz; 30-min OBN: 11-dB shifts at 179 dB SPL, 212–214 dB SEL; AEP, *Tursiops*, 50-min OBN: 4–8-dB onsets at 160 dB, 193–195 dB SEL |
| p. 210 ¶5 | *Phoca vitulina* (harbor seal) | TTS 6–8 dB at 152 dB SPL (SEL 183 dB), 30-min 2.5-kHz OBN; in air 99 dB re 20 µPa (SEL 131 dB) for 6 dB TTS |
| pp. 210–211 | *Zalophus californianus* (printed "califomianus"), *Mirounga angustirostris* | TTS onsets near 170 dB (SEL 205 dB) in water; in air 121–122 dB re 20 µPa (SEL 154–163 dB) |

Units as stated by the chapter: SPL dB re 1 µPa, SEL dB re 1 µPa²·s unless noted. The source to ingest is **Southall et al. (2007)** (its Tables and the original studies it cites); see `reference_tables/Ketten__2012_references.csv`.

## Files

- `ketten_2012_Marine_mammal_auditory_system_noise_impa.pdf` — source (kept)
- `Ketten__2012_NOTE.md` — this note
- `reference_tables/Ketten__2012_references.csv` — citation roadmap (verbatim bibliography entries for the review and figure sources)
- `Ketten__2012_Text(TTSvalues)_registry_row.xlsx` — proposed registry update marking the item a documented skip

No snapshot, analysis CSV, public TSV or species-key rows were created. `__ReadMe.xlsx` was not edited.
