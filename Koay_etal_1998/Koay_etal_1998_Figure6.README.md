# Koay, Heffner & Heffner (1998) — Figure 6

**Source paper.** Koay, G., Heffner, R. S., & Heffner, H. E. (1998). Hearing in a megachiropteran fruit bat (*Rousettus aegyptiacus*). *Journal of Comparative Psychology*, 112(4), 371–382. https://doi.org/10.1037/0735-7036.112.4.371

**The item is a figure, not a table.** The paper prints no comparative table. Figure 6 (journal p. 378) plots **high-frequency hearing limit** (highest frequency audible at 60 dB SPL, kHz, log axis) against **functional interaural distance** (µs, log axis) for 68 labeled points; the **key to species — with the audiogram reference for every point — is the Figure 6 caption printed on the facing page** (p. 379). Registry row added by the owner (Item number "Figure 6"). This is the single most-cited source in the Bath sensory compilation (128 value uses).

## Files in this folder

| file | what it is |
| --- | --- |
| `koay_etal_1998.pdf` | the publication (scan; copy of the archive PDF) |
| `Koay_etal_1998_Figure6_snapshot.csv` | **frozen digitisation** of the figure's 67 recoverable points, full precision, verbatim from the Bath extraction |
| `Koay_etal_1998_Figure6.R` | canonical reformat: snapshot + caption key → CSV + public TSV |
| `Koay_etal_1998_Figure6_mirror.py` | offline Python mirror that generated the committed outputs — delete after verifying the `.R` |
| `Koay_etal_1998_Figure6.csv` | analysis-ready data, one row per caption entry (69 rows) |
| `reference_tables/…_caption_key.csv` | the caption's species key, verbatim (69 entries: Ef/Ml/Nl/Ra/Rf + 1–64), with medium and printed marker |
| `reference_tables/…_species_crosswalk.csv` | printed misprints/older names → corrected binomials (verified against page images) |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |
| `comparison/…_vs_SensoryData_compiled.csv` | audit vs the compiled sensory check fixture |

Public TSV: `__Public/comparative-data/10.1037%2F0735-7036.112.4.371_Figure6.tsv`.

## Provenance of the values — read before using

**Every value is digitised from the figure** (`value_origin = digitised_from_figure`): the underlying numbers appear nowhere in print. The digitisation is the Bath team's 2021 pass (`hearing data.xlsx`, sheet "Koay 1998 extract", Fig-6 block), frozen verbatim as the snapshot — per the house rule that a figure-derived value must be reproducible from a saved extraction, not hand-typed. Spot-checks against the rendered figure (pig ~500 µs/40 kHz; cattle ~1300/35; Ra ~139/64; Tursiops ~76/143) confirm the axes were read correctly.

- **Point 13 (*Macaca irus*)** sits in the dense mid-cluster and was not recoverable by the Bath digitisation — its row carries NA with the audiogram reference (Stebbins et al., 1966) preserved for a Route-A rebuild from the primary.
- **Point 61 (beluga)** appears in **Figure 7 only** (caption states this); no Figure 6 value.
- An **older digitisation pass** survives in `Meeting 23 July/hearing data.xlsx` — see comparisons below.
- The Rousettus point (Ra) is the paper's **own audiogram** (primary); every other point compiles the caption's cited audiogram (secondary) — hence Data role **both**.

## Caption key & species names

The caption was transcribed verbatim (the PDF is a scan; ambiguous binomials verified against 350 dpi page images). The paper prints several misprints/older names — kept as printed and mapped in the crosswalk: *Cercopithecus aithiops* (→ *Chlorocebus aethiops*), *Sylvilagus floridana* (→ *floridanus*), *Sciureus niger* (→ *Sciurus*), *Mesocricetus auritus* (→ *auratus*), *Chinchilla laniger* (→ *lanigera*), *Orcina orca* (→ *Orcinus*), *Macaca irus* (→ *M. fascicularis*), *Lemur fulvus* (→ *Eulemur*), plus genus-era notes (*Marmosa/Thylamys elegans*, *Spalax/Nannospalax ehrenbergi*). Note the caption's hedgehog (#4) is ***Hemiechinus auritus*** (Ravizza et al. 1969b **audiogram**) — distinct from HH1992a's *Paraechinus hypomelas* (Chambers '71 **localization**); the two Heffner-corpus hedgehogs are different species measured for different traits, which explains the compilation's hedgehog confusion flagged in the HH1992a build.

## Comparison vs the compiled check fixture

Check rows citing "Koay et al 1998" for the two figure traits, 94 rows:

- **7 agree exactly** with the frozen digitisation (the check's own `digitised_from_figure` values).
- **4 digitised-origin check values do not match this snapshot**: beluga high-freq is a **Figure 7** value (correctly so); Inia high-freq + interaural and Orcinus interaural trace to the **older Meeting-23-July digitisation pass** (verified present there). Provenance documented, nothing lost.
- **80 differ by design**: published-origin check values follow compilation Rule 3 (values taken from Koay's cited primaries where stated) — the digitisation is not their source.
- **7 rows cite this paper for species not in the figure**: *Delphinus delphis* (the same dolphin-duplication defect found in the HH1992a build) and *Carollia perspicillata*, *Phyllostomus hastatus*, *Rhinolophus rouxii* (those audiograms are Koay et al. **2002/2003** — mis-citation in the compilation).

## Notes for the database

- Figure 7 (low-frequency vs high-frequency limits, incl. the beluga) was also digitised by the Bath team (same extract sheet, separate block) — a natural second item (`Figure 7` registry row) when wanted.
- The compilation's *published* audiogram-limit values route to the individual Heffner-lab papers in the caption key (Route-A candidates), not to this item.
- `species_key.csv` token: `Koay1998`.
