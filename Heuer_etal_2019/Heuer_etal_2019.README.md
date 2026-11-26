# Heuer et al. 2019 — Evolution of neocortical folding (34 primate MRI)

Source folder for a **neocortical folding** source (candidate #5 in
`PROJECT_SCOPE_AND_DATASET_ROADMAP.md`; **reinstated** 2026-07-31 — owner reports no known issue
with Heuer). This is **neocortical** folding — a separate question from cerebellar folding, which is
out of scope.

## Source (freeze before cleaning)

Heuer, K., Gulban, O. F., Bazin, P.-L., Osoianu, A., Valabregue, R., Santin, M., Herbin, M., &
Toro, R. (2019). *Evolution of neocortical folding: a phylogenetic comparative analysis of MRI from
34 primate species.* Cortex 118:275–291. DOI **10.1016/j.cortex.2019.04.011**.

- **What it contributes (verified 2026-07-31 against the paper's methods):** 3-D MRI
  surface-reconstruction folding metrics across **34 primate species / 65 individuals** — an
  **absolute gyrification index**, **total folding length**, **average fold wavelength** (~stable
  12 mm ± 20 % despite ~20× cerebral-volume range), and **average fold depth**, plus cerebral surface
  area and convex-hull surface.
- **Author data:** the authors' archived dataset is on **Zenodo doi:10.5281/zenodo.2538751**
  and at `github.com/neuroanatomy/34primates`. The 65 measured cases in
  `Heuer_etal_2019_Data.csv` were checked against author GitHub
  `data/derived/stats/stats.csv` at commit
  `55ae95e5dbf1c3e114c1b6949e036c9aa2798e78` on 2026-11-25.
  Source SHA-256: `b9453ac9555209d514ef0df5ffdd392247b70430b85ce7b9b44ab7e0f685a597`.
  All case IDs and seven numeric fields agree to within 1e-6.

## DECISION: house separately — do NOT pool into `__merging_gyrification` (method differs, confirmed)

Owner decision (2026-07-31), confirmed against the paper's methods. The gyrification merge pools
**only the Zilles-method GI** — a **2-D** ratio on coronal sections (inner+buried pial contour ÷ outer
contour) — and deliberately excludes other folding constructs (e.g. Mota & Herculano-Houzel FI).
**Heuer 2019 uses a different method:** a **3-D** absolute gyrification index (the ratio between the cerebral
surface area and the surface area of a sphere of the same volume) plus folding length / wavelength / depth —
metrics the Zilles coronal method does not produce. The paper itself presents these as an
*alternative* to the classical Zilles GI. So:

- **Do not reconcile to, or pool with, the Zilles GI merge.** Even Heuer's "gyrification index" is the
  3-D surface-to-sphere ratio, not the Zilles coronal-contour GI — not interchangeable.
- **House it here** as its own MRI folding source (exactly as Mota FI lives in its own folder).
- Its **cerebral / convex-hull surface-area** columns belong with cortical-surface data
  (`__merging_cortical_areas`) if ever merged — same rule the GI README applies to Mota — **not** the
  GI merge.

## Built items and specimen registration (updated 2026-11-25)

The folding measurements and sample documentation are built:

| Registry item | Source | Frozen copy | Rows |
|---|---|---|---|
| `Heuer_etal_2019_Table1` | printed Table 1, article p. 3 | `Heuer_etal_2019_Table1_snapshot.xlsx` (hand-verified) | **34 species / 65 individuals** |
| `Heuer_etal_2019_S1` | journal supplement `1-s2.0-S0010945219301704-mmc1.zip` | `S1_QCtable_mmc1.tsv` (digital-native, unpacked verbatim) | **66 scanned specimens** |
| `Heuer_etal_2019_Data` | authors' `data/derived/stats/stats.csv` | author GitHub commit and SHA-256 above | **65 measured cases** |

Public TSVs: `10.1016%2Fj.cortex.2019.04.011_Table1.tsv` and `..._S1.tsv`.

Table 1 and S1 are sample metadata; `Data` contains the measured MRI folding values.
The 65 measured cases are registered individually in
`_keys/specimen_crosswalk/specimen_crosswalk.csv`; the one S1-only case is registered
as an excluded scan, without inventing a measurement. See
`Heuer_etal_2019_specimen_registration_audit.csv` for each S1 ID, author-stats ID,
source, taxon, provenance, inclusion flag, canonical key, and match status.
Three same-name links to existing Yerkes registrations (Brian the bonobo, Buddy
the gibbon, Kinyani the gorilla) are **probable**, not confirmed by a shared accession.
The ten ABIDE human S1 IDs use `Human_` prefixes, whereas the author stats use
numeric IDs; both forms are retained in the crosswalk. Table 1 provenance resolves
the two S1 rows labelled only "Gorilla" to different species.

### Table 1 — why it was hand-transcribed

The PDF's text layer has lost every intra-cell space (`Daubentoniamadagascariensis`), so an
automatic parse would have to re-insert word breaks by guesswork. `Heuer_etal_2019_Table1_make_snapshot.py`
therefore holds a hand transcription, guarded by two assertions that fail loudly on a typo:
**34 species rows** and **N summing to 65 individuals** — both figures the paper states itself.

### Finding: S1 has one specimen the paper did not analyse

S1 lists **66** scanned specimens; the paper analysed **65** from 34 species. The extra row is a
**red howler monkey** (`HurleurRouxAloua_47da`, MNHN; species-level ID not confirmed by S1) — present in the QC
table, absent from Table 1. It was scanned and quality-checked but left out of the analysed sample.
Recorded in `species_note` and the specimen crosswalk, not dropped. It has no
row in `Heuer_etal_2019_Data.csv`.

### Finding: "Gorilla" is two species

Table 1 prints the common name **Gorilla twice** — *Gorilla beringei* (provenance BC) and
*Gorilla gorilla* (provenance NCBR) — and S1 prints only the common name. A name-keyed lookup
cannot express that, so those two S1 rows keep `species_sci = NA` with the disambiguation recorded
in `species_note`. The SpecimenIDs agree with Table 1 (`GorillaBeringeiG_0854` vs
`Gorilla_kinyani`). **For the curator:** this is a `_keys/specimen_crosswalk` case, not a
species-key one.

### Sample composition matters for this source

Folding metrics are method-sensitive and this sample is heterogeneous: **33 of 66 scans in vivo**,
**19 of 66 extracted from the skull**, voxel sizes from **0.175 mm** (ex-cranio museum specimens)
to **1.0 mm** (in vivo human), and SNR from **2.6 to 350.4** — a 135-fold spread. Those columns are
carried on every row so a future analysis can filter on them rather than pooling blind.

## Build steps completed

1. `Heuer_etal_2019_Table1.R` and `Heuer_etal_2019_S1.R` — snapshot/frozen source → CSV + TSV.
2. `reference_tables/Heuer_etal_2019_Table1_definitions.csv` and `..._S1_definitions.csv`
   (the earlier speculative `Heuer_etal_2019_definitions.csv`, whose column names were guesses at
   the unseen Zenodo file, has been **removed** — it described data this repo does not hold).
3. 33 `Heuer2019` rows added to `_keys/Stephan/species_key.csv` (common name → binomial, read off
   Table 1; `Gorilla` deliberately excluded as ambiguous).
4. Registered in `__ReadMe.xlsx` Sheet1.
5. `Heuer_etal_2019_Data.csv` is built and listed in the compiled item columns;
   the 3-D folding measure remains distinct from the Zilles 2-D GI merge.
6. On 2026-11-25, registered all 66 S1 cases and the 65 measured-case links
   in the specimen crosswalk, with three probable cross-paper name matches.

## Dissertation lead

The German National Library [catalogs](https://d-nb.info/1282312243) Katja
Heuer's *Mechanical morphogenesis and the development and evolution of primate
cortical folding* as a Leipzig University dissertation (2022), published as a
bound 231-page volume in 2023. The title is English, but the text language has
not been checked. No dissertation PDF was located in this repository, the
EndNote PDF store, or the online repositories searched on 2026-11-25. If obtained,
check for unpublished specimen identifiers and methods; prefer the journal
article for measurements already published there.
