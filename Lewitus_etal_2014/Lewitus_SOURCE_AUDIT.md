# Lewitus 2013 / 2014 — where the data actually comes from

**Written 2026-09-22.** Lewitus 2013 Table A1 and Lewitus 2014 Table S1 are almost entirely
**secondary compilations**. This note records the per-variable sources, transcribed from the papers'
own footnotes and from External Database S1, and reports two findings about the published tables.

Following house convention, a disagreement with a published table is a **finding about that table**,
not a defect here: `actual_source` and notes are filled, printed values are left as printed.

---

## Files added

| File | Contents |
|---|---|
| `Lewitus_etal_2014/reference_tables/Lewitus_etal_2014_ExternalDatabaseS1_references.csv` | 88 rows, one per reference number, from External Database S1's numbered list |
| `Lewitus_etal_2014/reference_tables/Lewitus_etal_2014_ExternalDatabaseS1_provenance.csv` | 233 rows: species x data item -> reference number(s) + citation, with an `alignment` column |
| `Lewitus_etal_2014/reference_tables/Lewitus_etal_2014_ExternalDatabaseS1_variable_sources.csv` | Variable-level rollup: which reference dominates each data item |
| `Lewitus_etal_2013/reference_tables/Lewitus_etal_2013_TableA1_definitions.csv` | **updated** — gains `footnote`, `actual_source`, `actual_source_citation`, `actual_source_repo_folder`; `role` corrected |
| `Lewitus_etal_2014/reference_tables/Lewitus_etal_2014_TableS1_definitions.csv` | **updated** — same four columns; filled for `Neocortex_mm^3` only |

Source of the S1 tables: `pbio.1002000.s021.doc` (External Database S1, 24 pp.), extracted with
`textutil`. The document embeds EndNote field codes; the numbered reference list at its end is the
authoritative mapping and is what was transcribed.

---

## 1. Lewitus 2013 Table A1 — footnote legend

From `Lewitus_etal_2013_TableA1_Note.csv`. Every column except gray-matter thickness is secondary:

| Column | Footnote | Actual source | In repo |
|---|---|---|---|
| `brain_weight_g` | a | Stephan et al. 1981 | `Stephan_etal_1981` |
| `ventricle_1_2_volume_mm3` | a | Stephan et al. 1981 | `Stephan_etal_1981` |
| `neuron_density_per_mm3` | b | Lewitus et al. 2012, Evolution 66:2551 | **not in repo** |
| `astrocyte_density_per_mm3` | b | Lewitus et al. 2012, Evolution 66:2551 | **not in repo** |
| `gray_matter_thickness_mm` | c | This paper, Figure 5 — **the only primary column** | `Lewitus_etal_2013` |
| `GI` | d | Lewitus et al. 2013 arXiv 1304.5412 | `Lewitus_etal_2014` |

`role` was `primary` on all eight rows before this update; it is now `secondary` on five.

### The self-citation is a preprint of the 2014 paper

Footnote **d** in the 2013 paper cites "Lewitus et al., 2013" = **arXiv 1304.5412**, which the Note
file records as later published as:

> Lewitus E, Kelava I, Kalinka AT, Tomancak P, Huttner WB (2014) An Adaptive Threshold in Mammalian
> Neocortical Evolution. *PLoS Biol* 12(11): e1002000.

So Table A1's `GI` column comes from **`Lewitus_etal_2014`**, not from the 2013 paper it is printed
in. Anyone joining the two folders on GI is joining a table to its own source. The
`actual_source_repo_folder` column now says so explicitly.

**Gap:** Lewitus et al. 2012 supplies two columns but has no folder in this repo.

---

## 2. Lewitus 2014 — External Database S1 gives per-species provenance

External Database S1 is a three-column table (Species / Data / Reference(s)) covering **89 species**,
listing sources *additional* to the dataset-wide ones. Its header names refs 1-15, AnAge, and
PANTHERIA (16) as the bulk sources.

Being named in the header does **not** mean a reference is absent from the per-species table — four
of those 16 are also cited per-species, and one of them is the most-cited reference in the whole
document:

| Header ref | One-to-one rows | Source |
|---|---|---|
| **11** | **20** | Sacher & Staffeld 1974 — the dominant source for adult/neonate body and brain weight |
| **12** | 8 | Stephan, Frahm & Baron 1981 |
| 1 | 0 (block-level only) | Zilles et al. 1989 |
| 2 | 0 (block-level only) | Walker et al. 2006 |

The 12 header refs never cited per-species are 3-10, 13-15 and 16 (PANTHERIA) — those are the ones
applied dataset-wide only. A further five non-header refs (60, 62, 63, 65, 66) are also never cited
per-species; they are unexplained and worth a look.

**Alignment is recorded, not assumed.** Within a species block the data items and the trailing
reference numbers usually correspond one-to-one, but not always:

| `alignment` | Rows | Meaning |
|---|---|---|
| `one_to_one` | 170 | item count == reference count; each item carries its own reference |
| `block_level` | 55 | counts differ; all the block's references are listed against every item |
| `no_reference_printed` | 8 | the block prints no reference |

Do not read a `block_level` row as an attribution of that item to that reference.

### Parsing guard worth keeping

Reference markers and data values are both bare parenthesised integers. `group size (900)` parsed as
reference 900. The extractor therefore accepts a trailing `(n)` **only if `n` resolves in the
88-entry reference list**, scanning right-to-left and stopping at the first that does not. Every
emitted reference number is asserted to resolve.

### Neocortex volume comes from Bush & Allman 2003

Reference **(17)** is cited on **23 of the 25** neocortex rows that have a clean one-to-one mapping:

> Bush EC & Allman JM (2003) The scaling of white matter to gray matter in cerebellum and neocortex.
> *Brain Behav. Evol.* 61(1):1-5.

This is now recorded as `actual_source` for `Neocortex_mm^3`, pointing at the existing
`Bush_Allman_2003` folder. It also explains an earlier observation: Lewitus's neocortex values agree
exactly with the repo's volumes merge for 18 of 27 shared species, because that merge already carries
the Bush & Allman lineage.

External Database S1 also **confirms the structure definition** independently of Table S2: the data
item is printed as "Neocortex volume (- corpus callosum)" on every one of the 28 species rows that
carry it.

---

## 3. Finding: `Nycticebus coucang` neocortex is a missed unit conversion

**This is an error in the published table**, reproduced faithfully here; the repo value is correct as
a transcription.

Lewitus 2014 Table S1 prints `Neocortex_mm^3 = 6.192` for *Nycticebus coucang*. The rest of that
column runs 740 - 341,444.

Bush & Allman 2003 reports neocortex in **cm³**, so Lewitus's column requires a x1000 conversion.
Comparing the nine species present in both tables:

| | Lewitus / (B&A total neocortex, cm³) |
|---|---|
| 8 other species | **982 - 1713** (median 1320) — i.e. a cm³ -> mm³ conversion |
| *Nycticebus coucang* | **1.13** — no conversion applied |

Corroboration: B&A 2003 gives 5.47 cm³ (= 5470 mm³) for this species, and the repo's volumes merge
carries 5831 mm³ from Bush & Allman 2004a + Frahm et al. 1982. On the column's own scale the printed
value implies **~6192 mm³**.

The residual spread in the ratio (982-1713) is expected: Lewitus's figure is neocortex minus corpus
callosum and is not exactly B&A's white+gray total.

**Recommended handling.** Leave `6.192` as printed — it is what the source says. Flag the species so
it cannot enter a merge: the value is ~1000x low and would distort any allometric fit. This has not
been done yet; it needs a decision on where the exclusion is recorded.

---

## What was deliberately not done

- `Neocortex_mm^3` and `Neocortex_Vol.mm3` remain **indistinguishable** in `_keys/variable_domain.csv`
  (same Structure, canonical_structure, measure_class, Unit; blank `poolable_group`) even though the
  first excludes the corpus callosum. Encoding that needs a decision.
- The prose definition in `Lewitus_etal_2014_TableS1_definitions.csv` still sits in the `Structure`
  column rather than `Definition`, so the app shows "Neocortex volume" rather than the
  minus-corpus-callosum wording.
- `actual_source` is filled on 2014 Table S1 for `Neocortex_mm^3` only. The other 41 columns need the
  fuzzy join from `..._variable_sources.csv` adjudicated before they are asserted.
