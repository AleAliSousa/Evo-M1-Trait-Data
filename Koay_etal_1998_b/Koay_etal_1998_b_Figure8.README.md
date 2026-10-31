# Koay, Kearns, Heffner & Heffner (1998) — Figure 8

**Source paper.** Koay, G., Kearns, D., Heffner, H. E., & Heffner, R. S. (1998). Passive sound-localization ability of the big brown bat (*Eptesicus fuscus*). *Hearing Research*, 119, 37–48. https://doi.org/10.1016/s0378-5955(98)00037-9

**The item is a figure, not a table.** Figure 8 (journal p. 45) is a single logarithmic scale bar running from 1° to 180° — "Azimuthal sound-localization acuity for 29 species of mammals" — with each species named beside the bar and joined to it by a tick or a leader. The paper tabulates none of these values.

## ⚠️ Digitised data, and a loosely calibrated axis

The figure **prints no axis ticks**: the only fiducials are the eight scale labels (1°, 2°, 5°, 10°, 20°, 50°, 100°, 180°) set inside the bar. Calibrating on their glyph centres leaves an rms of 20 px and a maximum of 45 px (0.022 decade), so **values carry roughly ±5 %** — noticeably weaker than a figure with a ruled axis. Treat these as positions on a schematic scale, not as measurements.

**All 28 printed leaders were individually resolved.** No leader had to be inferred. Three species (spiny mouse, wood rat, grasshopper mouse) are joined to **one** tick by a printed brace, and two labels each name two species ("pig, opossum"; "kangaroo rat, gerbil"), so the **30 species rows occupy 26 distinct positions**.

## Independent check

Ten of the eleven species this figure shares with **Heffner et al. (1994) Table 1** — the reference the caption itself points to for sources, built in this repo as `Heffner_etal_1994_c_Table1` — agree within 10 %:

| species | Figure 8 (digitised) | Heffner et al. 1994 Table 1 |
| --- | --- | --- |
| albino rat | 10.9° | 11.1° |
| wild Norway rat | 12.1° | 12.8° |
| chinchilla | 15.5° | 15.6° |
| spiny mouse / wood rat | 19.0° | 19.0° |
| grasshopper mouse | 19.0° | 19.3° |
| kangaroo rat / gerbil | 26.4° | 27.0° |
| groundhog | 27.0° | 27.8° |
| naked mole rat | **56.0°** | **63.0°** |
| blind mole rat | 181.7° | 180.0° |

The naked mole rat is the one outlier (−11 %). The paper's own big brown bat value is **14°** (Results text, mean of 16/12/13° for three bats); the arrow in Figure 8 digitises to **13.8°**.

## "29 species", 30 labels

The caption says 29 species; the figure carries **30 species names**. The reconciliation is almost certainly that **"albino rat" and "wild Norway rat" are two forms of one species** — Heffner et al. (1994) Table 1 lists exactly those two as separate rows both under *Rattus norvegicus*. This is recorded as an inference, not a correction; the item keeps all 30 rows.

## Files in this folder

| file | what it is |
| --- | --- |
| `Koay_etal_1998_b.pdf` | the publication |
| `Koay_etal_1998_b_Figure8_extract_snapshot.py` | the digitiser; measures every coordinate at run time |
| `Koay_etal_1998_b_Figure8_snapshot.csv` | **frozen digitisation**: one row per printed label (28), value as read, leader type, shared-tick flag |
| `Koay_etal_1998_b_Figure8.R` | snapshot + species key → CSV + public TSV |
| `Koay_etal_1998_b_Figure8.csv` | analysis-ready, one row per species (30 rows) |
| `reference_tables/…_species_key.csv` | label → species, with the binomial **only where this paper prints it** (Figure 9 caption key); 10 species have no binomial anywhere in the paper and are left blank |
| `reference_tables/…_references.csv` | the two sources the figure cites |
| `reference_tables/…_definitions.csv` | data dictionary (10-col schema) |

Public TSV: `__Public/comparative-data/10.1016%2Fs0378-5955(98)00037-9_Figure8.tsv`.

## Data role

Registered as **secondary**, and that is right for 29 of the 30 rows: the caption sources them all to Heffner et al. (1994). The **big brown bat** point (bold, arrowed) is this paper's own measurement, so the item is strictly **both**; the proposed registry row says so, and `data_role` carries it per row.

## Note for the database

For the 12 species shared with `Heffner_etal_1994_c_Table1`, prefer that item: it prints the values and their per-species sources. This figure's value is a fallback and the only source here for the other 18.
