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

**Specimen count — confirm on the PDF.** The scaffold asserted "137 hand samples"; that number was
part of the fabricated block and is **not verified**. A regex sweep of the extracted Table S1 finds
**133** specimen rows (HMNH 32, AMNH 30, WITS 29, NMW 15, UV 10, UM-APC 9, MRAC 5, YPM 2, ZMB 1),
and the museum key also lists UNI-Fl and NME with no rows detected — so the extraction is probably
missing a few. Count by hand when building the snapshot; do not carry 137 forward unchecked.

Museum keys: AMNH (American Museum of Natural History), HMNH (Harvard), YPM (Yale Peabody), UM-APC
(U. Massachusetts Amherst), ZMB (Museum für Naturkunde Berlin), NMW (Naturhistorisches Museum Wien),
UV (U. Vienna), UNI-Fl (U. Florence), MRAC (Musée royal de l'Afrique centrale), NME (National Museum
of Ethiopia), WITS (U. Witwatersrand).

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

## Still to do (locally, with R)

1. Hand-build `Liu_etal_2016_TableS1_snapshot.xlsx` from the SI PDF — printed source, faithful capture,
   **one row per specimen** with `Species` and `Key` preserved verbatim (invariant 3).
2. `Liu_etal_2016_TableS1.R`: snapshot → analysis CSV. Decide and document whether the merge takes
   **specimen rows** or **species means** — Table S2 works from species means, so the paper itself uses
   both. Aggregating loses the museum-accession provenance, so keep the specimen rows in the analysis
   CSV and aggregate only at the merge.
3. Register in `__ReadMe.xlsx` Sheet1: `Item name = Liu_etal_2016_TableS1`,
   `Item encoded = 10.1098%2Frspb.2016.1923_TableS1`, `Data role = secondary`,
   `Main Trait(s) = hand manipulability (workspace, global manipulation index)`,
   `Taxon group = Primates`, `Team = Liu`.
4. Write the DOI-coded public TSV (invariant 2).
5. Reader `____EvoM1_TraitTable/EvoM1_read_hand_liu.R` (renamed from the Bardo version) — the
   `TODO(curator)` column marker is now **resolved**: the headline index is `GMI`, with `WS` available
   as a second exposed measure.

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
