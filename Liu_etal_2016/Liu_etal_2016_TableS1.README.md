# Liu et al. 2016 — Table S1 (hand proportions → manipulative potential)

**⚠️ This folder was scaffolded as `Bardo_etal_2016/` on a fabricated author list. Corrected
2026-08-04.** "Bardo et al. 2016" does not exist. The paper carrying this title is by **Liu, Xiong &
Hu** — Ameline Bardo is a real hand-evolution researcher (several records in the EndNote library) but
is **not** an author on it. Same failure mode as the "Heuer 2018" case: real title, real journal, real
DOI, invented byline. Verified against EndNote `[9631]` and the SI PDF's own title page.

## Source

Liu, M.-J., Xiong, C.-H., & Hu, D. (2016). *Assessing the manipulative potentials of monkeys, apes and
humans from hand proportions: implications for hand evolution.* **Proceedings of the Royal Society B
283(1843):20161923.** DOI **10.1098/rspb.2016.1923** · PMID **27903877** · EndNote `[9631]`.

Institute of Rehabilitation and Medical Robotics, Huazhong University of Science and Technology,
Wuhan — a biomechanics/robotics group. Worth noting because the fabricated byline named a French
primatology team, which made the wrong attribution look plausible.

**Frozen source in this folder:** `rspb20161923_si_001.pdf` (25 pp. Electronic Supplementary
Information). The SI is a **PDF of the tables, not a data file** → **printed source, so a snapshot is
required** (invariant 1).

## What Table S1 gives

> *"Hand proportions of the anthropoid samples and their predicted results of manipulative potentials."*

Confirmed column headers, read off the SI:

| Column | Meaning |
|---|---|
| `Species` | anthropoid species (abbreviated binomial, e.g. `Ho. sapiens`) |
| `Key` | **museum accession number** — one row per specimen |
| `MC1` / `PP1` / `DP1` | metacarpal / proximal phalanx / distal phalanx of the **thumb** |
| `MC2` / `PP2` / `IP2` / `DP2` | metacarpal / proximal / intermediate / distal phalanx of the **forefinger** |
| `WS` | **workspace** |
| `GMI` | **global manipulation index** — the headline manipulative-potential measure |

Segment lengths are **proportions** relative to the combined thumb + forefinger length, so they are
dimensionless — there is no unit conversion to do (invariant 4 does not bite here).

**13 anthropoid species** (from Figures S1–S2): *Homo sapiens, Pan troglodytes, Pan paniscus, Gorilla
gorilla, Pongo pygmaeus, Hylobates lar, Macaca mulatta, Macaca fascicularis, Papio hamadryas,
Presbytis cristata, Sapajus/Cebus apella, Cebus albifrons, Alouatta seniculus*.

**Specimen count — RESOLVED 2026-08-05: 137 is correct.** The earlier regex sweep found only 133
because it missed the four `UNI-FI` (Florence) rows at the top of SI p. 8. The built snapshot has
**137 specimen rows across 13 species**, and the paper's own Methods say *"a dataset that includes
a total of 137 hand samples from 13 anthropoid species"* — an independent confirmation. Museum
breakdown: HMNH 32, AMNH 30, WITS 29, NMW 15, UV 10, UM-APC 9, MRAC 5, UNI-FI 4, YPM 2, ZMB 1.
`NME` appears in the printed museum key but **no row carries it** — an unused legend entry.

Per-species specimen counts: *Homo sapiens* 45, *Macaca fascicularis* 17, *Pongo pygmaeus* 10,
*Presbytis cristata* 9, *Cebus albifrons* 9, *Pan troglodytes* 7, *Macaca mulatta* 7,
*Papio hamadryas* 7, *Sapajus apella* 6, *Alouatta seniculus* 6, *Pan paniscus* 5,
*Hylobates lar* 5, *Gorilla gorilla* 4.

Museum keys: AMNH (American Museum of Natural History), HMNH (Harvard), YPM (Yale Peabody), UM-APC
(U. Massachusetts Amherst), ZMB (Museum für Naturkunde Berlin), NMW (Naturhistorisches Museum Wien),
UV (U. Vienna), UNI-Fl (U. Florence), MRAC (Musée royal de l'Afrique centrale), NME (National Museum
of Ethiopia), WITS (U. Witwatersrand).

### ⚠️ `UNI-Fl` vs `UNI-FI` — the paper is internally inconsistent. Do not harmonise. (checked 2026-08-05)

The Florence code is spelled **two different ways in the same supplement**, and this is the paper's
own inconsistency, not an extraction artefact. The PDF's embedded text encodes genuinely different
characters:

| Where | As printed | Codepoints |
|---|---|---|
| Museum-key legend, SI p. 7 | `UNI-Fl` | `F` = U+0046, **`l` = U+006C** (lowercase L) |
| The four data rows, SI p. 8 | `UNI-FI` | `F` = U+0046, **`I` = U+0049** (uppercase i) |

Both readings are defensible, which is why it is easy to get wrong: `Fl` matches the legend's own
gloss "University of **Fl**orence", while `FI` is the official Italian province code for Firenze. In
the printed font the two glyphs are near-identical, so this looks like a typo in *our* files. It is
not.

**Rule:** each stays as printed in the cell it came from — the snapshot and analysis CSV carry
**`UNI-FI`** in `specimen_key` / `museum` because that is what those cells print (fidelity checklist),
and the legend quoted above keeps `UNI-Fl`. Verified: the snapshot's four Florence rows read `UNI-FI`,
and the caption row preserves the legend verbatim. **Do not "fix" either one.**

All nine other museum codes are unambiguous all-caps and agree between legend and data (checked
codepoint-by-codepoint). Only Florence differs.

**If a canonical museum code is ever needed** — e.g. to match specimens across sources, or against the
`specimen_crosswalk` — add it as a *separate derived* column in the build script (`museum_canonical`),
mapping both spellings to one code. Do not achieve it by editing `museum`, which must keep the printed
string.

## ⚠️ Hard citation-dependency with Feix et al. 2015 — stronger than the scaffold claimed

The SI states the raw morphometrics of these samples "are taken from the literature [1]", and
reference [1] is **Feix, Kivell, Pouydebat & Dollar (2015),** *Estimating thumb–index finger precision
grip and manipulation potential in extant and fossil primates*, J R Soc Interface.

So Liu 2016 is **not an independent measurement** — it is a new functional model applied to **Feix
2015's hand morphometrics**. That matters for the merge:

- `Baker_etal_2025` already carries `peak_workspace`, which descends from the **same Feix 2015 data**.
- Liu's `WS` / `GMI` and Baker's `peak_workspace` therefore share their **raw input**, not merely a
  construct family. **Citation-dependent → never average.** Resolve to one source.
- `Data role = secondary` (derived re-analysis), and Feix 2015 should be recorded as the upstream
  primary in the source note. Feix 2015 is **not currently in the repo** — worth adding, since it is
  the actual primary for both Liu and Baker.

## Fossil hands (Figure S6) — do not pool into extant means

Figure S6 infers manipulative potential for **fossil** hands: *Homo neanderthalensis*, Ohalo II H2,
and *Homo naledi* (the last from reference [2], not Feix). Per house rule, fossil *Homo* is a temporal
grade, **not** a sensu-lato split — keep fossil rows decomposable and never fold them into an extant
*Homo sapiens* mean.

## Built 2026-08-05

| File | |
|---|---|
| `rspb20161923_si_001.pdf` | the printed source (SI, 25 pp.; Table S1 on pp. 7–10) |
| `Liu_etal_2016_TableS1_extract_snapshot.py` | capture script (no R in the authoring environment) |
| `Liu_etal_2016_TableS1_snapshot.xlsx` | **frozen source** — 137 specimen rows, caption + header kept |
| `Liu_etal_2016_TableS1.R` | reformat: snapshot → CSV + TSV |
| `Liu_etal_2016_TableS1.csv` | analysis table, **one row per specimen** |
| `__Public/comparative-data/10.1098%2Frspb.2016.1923_TableS1.tsv` | public TSV |

**Granularity: specimen rows kept, not species means.** Table S2 of the paper works from species
means, but aggregating here would discard the museum accession, so averaging is left to the merge.

**How the species blocks were recovered.** The `Species` cell is a *merged* cell — the binomial is
printed once, vertically centred in its block of specimen rows. Centring turned out to be too
imprecise to segment on (it mis-assigned rows by up to nine). The extractor instead uses the
table's **own drawn cell borders**: the sub-1-pt rules spanning the Species column are exactly the
block boundaries, and a block that runs off the foot of a page continues in the first segment of
the next. The snapshot then expands the merged cell — the species is written on every row of its
block, which is that cell's actual value.

**Species names.** One remap, via a `Liu2016` row in `_keys/Stephan/species_key.csv`:
`Presbytis cristata` → `Trachypithecus cristatus`, so the row joins `Reader_etal_2011`, which
prints the current name. The other 12 printed binomials stand.

### Verification

- **137 specimens / 13 species** — matches the paper's own Methods sentence exactly.
- **Column-shift check:** the seven segment proportions are shares of one length, so each row must
  sum to 1. Observed range across all 137 rows is **0.998–1.002** (printed rounding). Carried in
  the analysis CSV as `segment_sum_check`.
- Museum counts sum to 137.
- **Re-run `Liu_etal_2016_TableS1.R` in RStudio** to confirm it reproduces the committed CSV/TSV.

### Still to do (curator)

- `____EvoM1_TraitTable/EvoM1_read_hand_liu.R` — the `TODO(curator)` column marker is **resolved**:
  the headline index is `GMI`, with `WS` as a second exposed measure.
- Merge wiring into `__merging_behaviour` is **not** done (out of scope for this build).

## Wire into `__merging_behaviour/behaviour_compiled.R` (only after `hand_liu.xlsx` exists)

- Add `Liu = "Liu"` to `TEAM`.
- Add `grab("hand_liu.xlsx","GMI","Manipulability_index","liu")` (and optionally a second `grab` for
  `WS`).
- `META` row: `mclass = "hand_morphology"`, **citation-dependent with Baker `peak_workspace`** via
  Feix 2015 → resolve, never average.

## Other tables in the SI (not the ingest target)

- **Table S2** — PCA of hand proportions on **species means**.
- **Table S3** — Bonferroni post-hoc comparisons of **workspace size** between species (p-values).
- **Table S4** — Bonferroni post-hoc comparisons of **GMI** between species (p-values).

S3/S4 are inferential statistics, not trait values — do not ingest.
