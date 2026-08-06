# Nudo et al. 1995 — TABLE 1 (body weight, brain weight, neocortical surface area)

**Built 2026-08-06.**

| File | |
|---|---|
| `Nudo_etal_1995_TABLE1_snapshot.xlsx` | frozen source (sheet `TABLE1`) |
| `Nudo_etal_1995_TABLE1.R` | reformat: snapshot → CSV (+ TSV) |
| `Nudo_etal_1995_TABLE1.csv` | analysis table — **24 rows = 24 species** |
| `reference_tables/Nudo_etal_1995_TABLE1_definitions.csv` | data dictionary (7 codes) |

Registry: `Item name = Nudo_etal_1995_TABLE1`, `Item encoded = 10.1002%2Fcne.903580203_TABLE1`.

## Source

Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). *Variation and evolution of mammalian
corticospinal somata with special reference to primates.* **J Comp Neurol 358(2):181–205.**
DOI **10.1002/cne.903580203**. PDF in this folder.

TABLE 1 is printed on **journal p. 183 = PDF p. 3**, left column.

**Printed/scanned source → a snapshot is required** (invariant 1). The PDF has an OCR text layer
and it is **not trustworthy** — it renders `Rattus norvegicus` as "Raltus noruegicus",
`Macaca fascicularis` as "Maraca fascicularis", `Callithrix jacchus` as "Callilhrirjacchus",
`(g)`/`(mg)` as `(e)`/`(me)`. **Every cell was read off 300-dpi renders of the page**, then
re-checked against the text layer by coordinate-matched word extraction: **all 24 rows × 3 numeric
columns agree** (the text layer's *numbers* on this page happen to be clean; its *words* are not).

## What TABLE 1 gives

Per species: printed common name, printed scientific name, **body weight (g)**, **brain weight
(mg)**, **cortical surface area (mm²)**. The paper says (p. 184) these are *retabulated* from
Nudo & Masterton (1989, 1990b) "for easy reference" — see **Data role** below.

Printed row order is kept, and it is the **same order** the animal rows take in TABLES 2, 4 and 5
(alphabetical by the short animal name: rat, armadillo, bushbaby, cat, … vole).

## Units

The journal already prints the project units, so both mass conversions are ×1 — written out
explicitly in the `.R` rather than omitted:

| printed | project | factor |
|---|---|---|
| body weight `(g)` | `Body_Mass.g` | ×1 |
| brain weight `(mg)` | `Brain_Mass.mg` | ×1 |
| cortical surface area `(mm2)` | `Neocortex_SurfaceArea.mm2` | ×1 (area kept as mm², per §6 it is
not one of the mass/volume classes) |

Sanity check that the brain column really is milligrams: rat 268 g / 1,500 mg; least shrew 8 g /
80 mg; rhesus 3,300 g / 53,700 mg.

## Species names

The printed scientific name survives verbatim in `Species_Nudo1995`, **including the two rows the
journal prints with an abbreviated genus** (`E. europaeus`, `M. mulatta`); the printed common name
survives in `Common_name_Nudo1995`. `species_sci` is resolved **only** through the species key
(`source_publication = Nudo1995`). Six of 24 printed names resolve to a different accepted name:

| printed | accepted | why |
|---|---|---|
| `Citellus tridecemlineatus` | `Spermophilus tridecemlineatus` | *Citellus* = junior synonym; repo precedent (Karbowski2007). **MDD now uses *Ictidomys tridecemlineatus* — curator call.** |
| `Erinaceus albiventris` | `Atelerix albiventris` | genus split; repo already maps `Erinaceus algirus → Atelerix algirus` in six papers |
| `E. europaeus` | `Erinaceus europaeus` | printed genus abbreviation expanded |
| `Cercopithecus aethiops` | `Chlorocebus aethiops` | genus split; repo precedent (Granatosky2018, Seymour2015). **Ambiguous — see below.** |
| `M. mulatta` | `Macaca mulatta` | printed genus abbreviation expanded |
| `Monodelphis domesticus` | `Monodelphis domestica` | gender agreement; *domestica* is the valid form |
| `Pitymys pinetorum` | `Microtus pinetorum` | *Pitymys* sunk to a subgenus of *Microtus* |

> **Ambiguous — `Cercopithecus aethiops` / "Green monkey".** The printed *binomial* maps to
> `Chlorocebus aethiops` (grivet), but the printed *common name* "Green monkey" is
> `Chlorocebus sabaeus` in modern usage, and `Heuer2019` in this repo maps "Green monkey" →
> `Chlorocebus sabaeus`. **I followed the printed binomial.** 1995-era *C. aethiops* was a
> sensu-lato species covering grivet + vervet + green monkey, so the animal cannot be resolved
> below that with the information printed. Flagged for the owner.

**Nothing is merged into `_keys/`.** All 48 rows this paper needs (24 binomials for TABLE 1 + 24
genus/species initials for TABLES 2/4/5) are staged in `Nudo_etal_1995/PROPOSED_species_key_rows.csv`.
Until they are merged, the `.R` reads that staged file *and warns*; after merging, delete the
staged file and the output is byte-identical.

## Verification

| check | result |
|---|---|
| rows | **24** (paper: "24 species in 21 genera … 16 families, 9 orders, 2 subclasses") |
| distinct `species_sci` | 24 |
| every numeric cell parses | 24/24 × 3 columns, **0 rows flagged** |
| snapshot vs PDF text layer (coordinate-matched) | 24/24 rows identical |
| row order vs TABLES 2/4/5 | identical by species |
| cross-table plausibility: TABLE 2 `#CSN` ÷ TABLE 5 avg surface density = the CS-labelled cortical area, which must be ≤ this table's neocortical area | passes for 24/24; the labelled zone is **4.3 %–27.6 %** of neocortex |

## Fidelity notes

- Values carried **exactly as printed**, thousands separators included, in the snapshot.
- **Documented deviations** (only two, both in the snapshot):
  1. the 3-line stacked printed header is flattened to two header rows (label / unit), no word
     dropped;
  2. common names that wrap over 2–3 printed lines are joined with one space and a line-break
     hyphen closed up (`Common mar-` + `moset` → `Common marmoset`). Scientific names never wrap
     and are verbatim.
- **No grouping rows.** (A caption scan can pick up "grade 2, eutherians (nonprimates) …" next to
  the caption — that text belongs to the *adjacent body-text column*, not to TABLE 1. The caption
  is exactly "Body Weight, Brain Weight, and Neocortical Surface Area for Species and Genera
  Represented", and the table is a flat 24-row list.)
- No footnotes are printed under TABLE 1.

## Data role — read before merging

Set **`Data role = secondary`** unless the owner decides otherwise. The paper states outright
(p. 184) that these body/brain/surface measurements "have been described elsewhere (Nudo and
Masterton, 1989, 1990b). They are **retabulated here** in Table 1 for easy reference." They are
therefore a **re-report**, not new measurement, and must not be double-counted against those
sources (§9). If Nudo & Masterton 1989/1990b are ever built, run
`__merging_volumes/crosspub_value_match.R` to confirm the values are identical.

## Still to do (locally, with R)

1. **Re-run `Nudo_etal_1995_TABLE1.R` in RStudio** to confirm it reproduces the committed CSV — it
   was written by an offline Python mirror of the script (no R in the authoring environment).
   The `.R` is canonical.
2. Merge `PROPOSED_species_key_rows.csv` into `_keys/Stephan/species_key.csv`, then delete it.
3. The `.R` writes the public TSV once `Item encoded` is present (it is); the TSV was **not**
   written in this session.
