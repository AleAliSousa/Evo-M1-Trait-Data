# Matano 1986 — Table I (vestibular nuclei)

**Matano, S. (1986). A volumetric comparison of the vestibular nuclei in primates.**
*Folia Primatologica* 47(4), 189–203. DOI [10.1159/000156277](https://doi.org/10.1159/000156277)

Item name `Matano__1986_TableI` · Item encoded `10.1159%2F000156277_TableI` ·
Team **Stephan_collection** · **Data role: both** (see “Primary vs secondary” below)

Table I. *Volumes (mm³) of the vestibular nuclei in primates* — **46 species, 80 individuals**
(2 Scandentia, 18 prosimians, 26 anthropoids including *Homo*), four nuclei plus the whole complex.

---

## Files

| file | what it is |
|---|---|
| `Matano-1986-A volumetric compari.pdf` | the publication (scan, **no text layer**) |
| `Matano__1986_TableI_snapshot.xlsx` | frozen source, sheet `TableI` — printed layout, printed units, printed row order and grade headers |
| `Matano__1986_TableI.R` | reformat: snapshot → CSV (+ public TSV) |
| `Matano__1986_TableI.csv` | analysis-ready, one row per species (46) |
| `reference_tables/Matano__1986_TableI_definitions.csv` | data dictionary |
| `comparison/` | the Table III QA anchor, the audit script, and its reports |
| `__Public/comparative-data/10.1159%2F000156277_TableI.tsv` | the public TSV |

## Source → snapshot

The PDF is a **scan with no text layer** (`pdftotext` returns only the library watermark), and no
Adobe export or curated project CSV of this table exists. Table I was therefore OCR'd
(tesseract, page 3 rendered at 300 dpi) in **two independent passes** — `--psm 6` and `--psm 4` —
which agree **exactly**, digit for digit, on all 46 × 6 printed cells. The snapshot reproduces the
printed table: caption row, the two header rows, the `Scandentia` / `Primates, prosimians` /
`Primates, simians` grade rows, printed row order, printed genus abbreviations, and original units.

## QA — 0 mismatches (`comparison/`)

With no second copy of the table to audit against, the paper's **own derived table supplies the
check**. Table III prints each nucleus as a **percentage of the complex**, computed by the author
from the same unrounded volumes. Recomputing those percentages from the Table I volumes audits the
transcription — a single mis-read digit moves a percentage far outside rounding noise.

`Matano__1986_TableI_compare_to_TableIII_csv.R` runs 230 checks over the 46 species:

- **184 percentage checks** — `nucleus / complex × 100` vs printed Table III (tolerance 0.35 pp,
  which absorbs Table I's 3-significant-figure printing): **0 mismatches**
- **46 sum checks** — `superior + lateral + medial + descending` vs the printed `complex`
  (tolerance 1.2 %): **0 mismatches**

Tables II–V are **not transcribed** — size indices, percentages, ratios and correlations are derived
and are recomputed downstream (HOWTO §7). Table III is held in `comparison/` **only** as the audit
anchor.

## Laterality — these are ONE-SIDE volumes

Registered in `__merging_volumes/laterality_known.csv` as `side = unilateral`, `doubling = none`,
`required_suffix = _unilateral`, so every volume column and every merge term carries `_unilateral`.
The paper never states a side; three lines of evidence fix it:

1. **The Methods say so indirectly** — *“The data of Stephan et al. [1981] have been incorporated in
   the present study.”* For the **27 species shared** with `Stephan_etal_1981_TableXIII`, all four
   nuclei are identical **to the printed digit** (0/27 mismatches on each nucleus); only the
   re-summed `complex` column differs, on 6 species, by one unit in the last place. Stephan 1981's
   vestibular columns are already registered `unilateral`.
2. **Baron et al. (1988) state it outright** about those earlier data: *“the volumes of the vestibular
   nuclei were measured in 33 species … but from one side only. Since the present data are from new
   measurements that included new individuals and are from both sides, the volumes are not merely a
   simple duplication of the former data.”*
3. **The new material behaves the same way.** Baron 1988 ÷ Matano 1986 on the complex is
   **2.02 (sd 0.18)** for the 27 species known to be one-side and **1.92 (sd 0.17)** for the 19
   species new here — indistinguishable, so Matano's own measurements are one-side too.

Note that Baron 1988 is **not** a doubling of this table: the ratio ranges 1.67–2.68 across species,
exactly as Baron's text claims (new measurements, new individuals, both sides).

## Primary vs secondary — `Data role = both`

- **Secondary (27 species)** — re-printed from Stephan et al. 1981 Table XIII, identical to the digit.
- **Primary (19 species)** — Matano's own new measurements, absent from Stephan 1981 Table XIII:
  *Alouatta seniculus, Aotus trivirgatus, Avahi laniger laniger, Callicebus moloch, Callithrix
  jacchus, Cercopithecus mitis, Cheirogaleus medius, Daubentonia madagascariensis, Erythrocebus
  patas, Galago senegalensis, Indri indri, Macaca mulatta, Miopithecus talapoin, Nycticebus coucang,
  Pithecia monachus, Pygathrix nemaeus, Saguinus midas, Urogale everetti, Varecia variegata.*

`body_weight_g` is likewise **secondary** — re-used weights, largely Stephan et al. 1981.

**No suppression is coded anywhere.** The build enters the merge as Tier-1 `Stephan_collection`,
where the most recent publication supersedes: Stephan 1981 → superseded by this table (1986) →
superseded in turn by **Baron et al. 1988**, which measured **all 46** of these species bilaterally.
The Tier-1 rule handles both the 27 duplicates and the 19 new species without special-casing. See
`__merging_volumes/README__merging.md`.

## Effect on the merge

Measured against the current `volumes_long.csv` before re-running the compile:

- **+95 new rows** — the 19 new species × the 5 `*_unilateral` terms, which previously had no
  unilateral coverage at all (each term went from 37 to 56 species).
- **135 rows re-sourced** to this table (27 species × 5 terms) under the Tier-1 most-recent rule,
  **129 of them with the value unchanged** — the four nuclei are identical to Stephan 1981 to the digit.
- **6 values change**, all on `Complexus_vestibularis_unilateral_Vol.mm3` only, by one unit in the
  last place: *Propithecus verreauxi* 43.2 → 43.3, *Loris tardigradus* 8.45 → 8.46,
  *Lagothrix lagothricha* 53.0 → 53.1, *Lophocebus albigena* 87.1 → 87.0,
  *Cercopithecus ascanius* 52.0 → 52.1, *Hylobates lar* 59.3 → 59.4. These are not disagreements:
  Matano re-summed the complex from the **unrounded** nuclei, so his printed total differs in the
  last digit from Stephan's. All are ≤ 0.2 %, and the Matano figure is the better-rounded one.
- **No bilateral value changes.** Every doubled both-sides estimate this build would generate in
  step 7 is dropped by the existing `anti_join`, because Baron 1988 supplies a real bilateral
  measurement for **all 46** of these species on all five terms (verified).

So the merge gains coverage and provenance; the only numeric movement is six last-digit corrections
on one unilateral variable.

## Species names

Printed names are kept verbatim in `Species_Matano1986`, including the printed genus abbreviations
(`C. medius`, `A. l. occidentalis`, `S. oedipus`, `C. mitis`). Harmonisation is central, via
`_keys/Stephan/species_key.csv` under the token **`Matano1986`** (46 rows; all resolve against the
names already used by the `Baron1988` / `Matano1985a` / `Matano1985b` tokens — e.g.
`Lemur albifrons` → *Eulemur fulvus*).

## Nuclear delineation (matters when pooling)

The complex is divided into four main nuclei. Small cell groups were ignored (nucleus parasolitarius,
group y) or absorbed into one of the four — the interstitial nucleus of the vestibular nerve and
group l into the **lateral**; groups f, x and z into the **descending**; nucleus supravestibularis
into the **medial** — following Baron (1977).

Brains were fixed in Bouin's fluid (a few in 10 % formalin), paraffin-embedded, cut as frontal serial
sections and stained with cresyl-violet and by Heidenhain-Woelcke. Five to eight sections per nucleus
at equal intervals were projected on photographic paper, delineated, cut out and weighed
(`V = AP × WS × D/M²`); section volumes were converted to estimated fresh volumes following
Stephan et al. (1981).
