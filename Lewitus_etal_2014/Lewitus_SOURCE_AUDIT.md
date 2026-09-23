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
| `Lewitus_etal_2014/reference_tables/Lewitus_etal_2014_Neocortex_source_attribution.csv` | Per-species attribution of all 33 `Neocortex_mm^3` values against every neocortex table in the repo |
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

### Neocortex volume: the cited reference is NOT the source of the numbers

External Database S1 cites reference **(17)** — Bush & Allman (2003) — on **23 of the 25** neocortex
rows with a clean one-to-one mapping. **The published values do not come from it.** Matching
Lewitus's 33 printed values against every candidate table in this repo:

| Best-matching source | Species | Verdict |
|---|---|---|
| Frahm et al. 1982 Table 2 | 10 | **exact** |
| Stephan et al. 1981 Table V | 6 | **exact** |
| Stephan et al. 1981 Table VI | 6 | **exact** |
| Bush & Allman 2004a (nearest candidate) | 3 | **>5% — not the source** |
| no candidate in repo | 8 | — |

**22 of the 25 attributable values are exact matches to the Stephan/Frahm lineage**, and Bush &
Allman is never within 5%. `actual_source` for `Neocortex_mm^3` is recorded accordingly, on
value-level evidence rather than on the citation. An earlier version of this note credited Bush &
Allman on the strength of ref (17); that was wrong.

#### Full sweep: ref (17) is a mis-citation

Widening the search to **every** neocortex-volume column in the repo (31 candidate tables, testing
both the printed scale and a x1000 conversion), per-species results are in
`Lewitus_etal_2014_Neocortex_source_attribution.csv`:

| Outcome | Species |
|---|---|
| exact match in **two or more** Stephan-lineage tables | 21 |
| exact match in one table | 8 |
| no source found anywhere in the repo | 4 |

Tables that reproduce a Lewitus value exactly, by species count:

| Table | Species |
|---|---|
| **Stephan et al. 1981** | **20** |
| deSousa et al. 2010 Supp. Table 2 (x1000) | 18 |
| Sherwood et al. 2003 | 10 |
| Frahm et al. 1982 | 10 |
| Heldstab et al. 2016 (x1000) | 5 |
| Stephan et al. 1970 | 4 |
| **Bush & Allman (2003, 2004a)** | **0** — see the scope note below |

**Scope of the Bush & Allman test.** B&A publish neocortex only as separate grey and white columns,
with no combined total, so they were added to the pool as explicit sums (2003 `neo_white + neo_gray`;
2004a `neocortex_grey + neocortex_white`) plus each grey column on its own. Even then they can only
be tested where they report the species:

| | Species |
|---|---|
| B&A report the species — tested, **no match** | **13** |
| B&A do not report the species — **not testable** | 20 |

So the honest statement is *B&A fails on all 13 species where the comparison can be made*, with a
median relative difference of 0.165 and a best case of 0.003 (*Hylobates lar*, the single near-miss,
still not an exact match). It is **not** a clean 0-for-33: on 20 species B&A simply has nothing to
compare. An earlier version of this table reported "0 — not once in 33 species", which overstated
the evidence, and did so partly by construction, since the original column filter excluded
grey/white columns and B&A never entered the candidate pool at all.

The conclusion is unchanged but rests on the 13 testable species plus the positive evidence: 29 of
33 values match a Stephan-lineage table exactly, and adding B&A to the pool changes none of those
matches.

#### Formal check, per source and per compartment

The sweep above has since been redone as a re-runnable script in the restricted repo —
`restricted_checks/Lewitus_etal_2014/comparison/Lewitus_etal_2014_TableS1_compare_to_neocortex_sources.R`,
written up in `README_neocortex_source_check.md` there. It tests each source **per compartment**
(grey / white / grey+white), collapses deSousa Table 1's per-specimen rows to species means, and
asserts that Bush & Allman contributed testable rows before writing output.

The compartment result is decisive:

| Compartment class | Exact matches | Testable |
|---|---|---|
| total-like (grey+white, Stephan code 18) | **48** | 86 |
| split (grey only, white only, lamina 1, laminae 2-6) | **0** | 92 |

| Source | Compartment | Testable | Exact |
|---|---|---|---|
| deSousa 2010 Supp. Table 2 | as published | 28 | **18** |
| Stephan 1981 Table VI | code 18 (incl. cc) | 11 | **11 — all** |
| Frahm 1982 | grey+white total | 12 | **10** |
| Stephan 1981 Table V | code 18 (incl. cc) | 10 | **9** |
| Bush & Allman 2003 / 2004a | all three compartments | 9 / 13 | **0** |

So Lewitus took the **grey+white total**, never a compartment — which independently kills the
grey-only reading of "Neocortex - cc" — and Bush & Allman match none of the 66 testable
species x compartment rows.

All the matching tables are republications of the same Stephan-collection measurements, which is why
most values match several at once; the specific table Lewitus copied from cannot be isolated, but
the **lineage** is unambiguous. Stephan et al. 1981 is the single best fit at 20 of 33.

Two concrete illustrations:

- ***Aotus trivirgatus.*** Lewitus prints 9950. Bush & Allman 2003 Table 1 gives Neo White 1.49 and
  Neo Gray 4.32 cm3 = **5810 mm3** — not reachable by any conversion. 9950 is the exact value in
  Frahm 1982, Stephan 1981 and Sherwood 2003.
- ***Alouatta palliata.*** External Database S1 attributes "Neocortex volume (- corpus callosum)" to
  ref (17) for this species, but **Table S1 publishes no neocortex value for it at all** — the
  provenance entry points at data that was never printed. (Bush & Allman do report the species,
  11.6 + 17.4 cm3.)

The four values with no source anywhere in the repo are *Miopithecus talapoin* (26427),
*Piliocolobus badius* (50906), *Saguinus midas* (5883) and *Avahi occidentalis* (4443).

### The "- corpus callosum" label is not supported by the values

External Database S1 prints the data item as "Neocortex volume (- corpus callosum)" on all 28 species
rows carrying it, matching Table S2. But the numbers are Frahm's `total_neocortex_mm3`, defined in
this repo as "total neocortex volume in mm3 (grey + white matter)" — and per
`Stephan_primates_structure_keys.md` in the restricted repo, both Stephan code 18 and Frahm's
neocortex **include** the corpus callosum:

> `NeoWG` -> `Neocortex_Vol.mm3`: Stephan code 18 includes neocortical grey, underlying white matter,
> **corpus callosum**, and the insular, subgenual, cingular and retrosplenial transitional cortices.
> (Stephan et al. 1981 Tables IV-VI, footnote 18)

> Frahm's neocortex includes grey laminae 1-6 and white matter **with corpus callosum**, excludes
> internal capsule... (Frahm et al. 1982 Methods, p. 376)

So Lewitus's label says the corpus callosum was removed while the values are the cc-**inclusive**
Stephan/Frahm totals, unchanged to the digit. Either the subtraction was never applied or the label
is wrong; on the evidence in this repo the values are not cc-corrected.

**Consequence: `Neocortex_mm^3` is not a distinct structure.** It is a republication of volumes the
merge already carries as `Neocortex_Vol.mm3` from the same Stephan/Frahm tables. It is a
**supersede** candidate, not a `keep_separate` one — the opposite of what the label implies.

#### Was a corpus-callosum subtraction performed and we are seeing the result?

Tested directly against the Frahm columns, on the 11 species with both values:

| Candidate quantity | Exact matches to Lewitus | Median ratio |
|---|---|---|
| Frahm **total** neocortex (grey + white, incl. cc) | **10 / 11** | 1.0000 |
| Frahm **grey** only (laminae 1-6) | 0 / 11 | 1.2796 |
| Frahm **white** only | 0 / 11 | 4.5768 |

A subtraction of any magnitude is ruled out for these species: the published value equals the
cc-**inclusive** total to the digit (the one non-match is 740 vs 739.5, rounding). The same argument
covers the 12 species matching Stephan Tables V-VI, whose `Neocortex` term is defined by Stephan's
own definitions file as including the corpus callosum. Grey-only and white-only are not the source
either, so the split is not the explanation.

Nor is the subtraction reproducible here: **no corpus-callosum volume exists in this repo for any of
the Stephan/Frahm primates**, and there is no corpus-callosum variable in the app at all (cc data
appears only in `Gabi_etal_2016` and `BarbeitoAndrés_etal_2019`, different species).

#### And no subtraction is needed if you take grey matter only

The corpus callosum **is** white matter, so a grey-matter-only figure excludes it by construction —
"Neocortex - cc" could in principle mean a grey compartment rather than a subtraction. Tested on the
12 species Lewitus shares with Bush & Allman 2004a:

| Candidate | Exact matches | Median ratio (Lewitus / candidate) |
|---|---|---|
| B&A **grey** only — cc-free by construction | 0 / 12 | 1.506 |
| B&A **white** only | 0 / 12 | 5.661 |
| B&A grey + white total | 0 / 12 | 1.148 |

Lewitus is half again larger than B&A's grey matter, so a grey-only reading is ruled out — as is any
B&A compartment, consistent with the value-level attribution above. On the Frahm side the same test
already appears in the table above: Frahm grey alone is 0/11 at a ratio of 1.28. **Whatever Lewitus
published, it retains the white matter**, and in the Stephan/Frahm sources that white matter is
defined to include the corpus callosum.

**What cannot be ruled out from here:** that Lewitus performed the subtraction *in the analysis*,
using callosum volumes from a source not in this repo, and published the un-subtracted raw values in
Table S1. That would make the Table S2 definition a description of the analysis variable rather than
of the published column. Distinguishing the two needs the paper's own analysis inputs. What is
settled is the narrower, and for our purposes sufficient, point: **the numbers in Table S1 are
cc-inclusive**, so they must not be treated as a cc-corrected structure.

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

## 4. Impact assessment — what this touches

| Surface | Affected? | Detail |
|---|---|---|
| **`__merging_volumes`** | **No** | Zero Lewitus-sourced rows. It reads Frahm, Stephan, Bush & Allman, deSousa etc. directly. *Nycticebus coucang* is correctly 5831 mm3 there (Bush & Allman 2004a + Frahm 1982). |
| **Shiny app** | **Yes** | Serves `Neocortex_mm^3` for 33 species, **including the corrupt `6.192`**, alongside `Neocortex_Vol.mm3` — so a duplicated variable and one value ~1000x low are both live. |
| **Bush & Allman folders** | **No stated boundary** | Nothing about the corpus callosum in `Bush_Allman_2003/2004_a/2004_b` — not in the definitions files, and the PDFs mention the callosum only as a sectioning landmark (2004a) or in the axon-diameter literature (2003). Their methods never state whether it falls inside their white-matter compartment. And B&A turns out not to be the source of the Lewitus values anyway. |
| **`_keys/` (public)** | **Partly** | `variable_domain.csv` still has `Neocortex_mm^3` and `Neocortex_Vol.mm3` identical on Structure, canonical_structure, measure_class and Unit, with `poolable_group` blank — the distinction is not encoded where pooling happens. |
| **`-restricted`** | **Already documented** | `other_checks/stephan_primates_refs_check/metadata/qc_stephan/Stephan_primates_structure_keys.md` states the corpus-callosum status of both Stephan code 18 and Frahm, with footnote-level citations; the Zilles/Stephan crosswalk repeats it. |

### Where the corpus-callosum status was already recorded

It was **not** only in the restricted repo.
`Stephan_etal_1981/reference_tables/Stephan_etal_1981_definitions.csv` — public, and the source's own
definitions table, which is the evidence class a structure-key claim requires — already reads:

> `Neocortex`: neocortex including underlying white matter, **corpus callosum**, and
> insular/subgenual/cingular/retrosplenial transitional cortices.
> Stephan code 18 (NeoWG), Table IV-VI footnote 18.

So for Stephan the answer was in the public paper folder all along. Coverage by source:

| Source | cc status recorded? | Where |
|---|---|---|
| Stephan et al. 1981 | **yes — includes cc** | public, source's own definitions file |
| Frahm et al. 1982 | yes — includes cc | restricted crosswalk note only; the public `Frahm_etal_1982` definitions file is silent |
| Bush & Allman 2003 / 2004a / 2004b | **no** | nowhere — definitions silent, methods never state the boundary |

The gap is therefore narrower than it first looked. What is missing is (a) the cc status in Frahm's
own public definitions file, (b) any link from the `Neocortex_*` variables in `_keys/` to either
statement, and (c) Bush & Allman's boundary, which is genuinely unknown from the sources here.

### Does Bush & Allman exclude the corpus callosum? Probably not

B&A never state their white-matter boundary, but because the callosum is white matter the question is
testable: if B&A excluded it, their **white fraction** should sit below Frahm's, whose white matter is
defined to include it. On the 9 species measured by both:

| | Median | Direction |
|---|---|---|
| B&A white fraction minus Frahm white fraction | **+1.56 pp** | B&A **higher** in 6 of 9 |

That is the opposite of what exclusion predicts, so **B&A most likely includes the corpus callosum
too** — making the merge's pooling of B&A with Stephan/Frahm defensible on this axis. The per-species
scatter is wide (-6.0 to +5.7 pp), so treat this as suggestive rather than settled; it is inference
from compartment ratios, not a statement from the source.

Decomposing the overall shortfall shows the same thing from the other side — the discrepancy is in
grey matter, not white:

| Compartment | Median B&A / Frahm |
|---|---|
| total | 0.916 |
| **grey** | **0.901** |
| white | 0.997 |

B&A's white matter is effectively identical to Frahm's; their grey runs ~10% lower, which points at
shrinkage correction and grey-boundary criteria rather than at a callosum difference.

### The residual open question

The merge pools Bush & Allman with Stephan/Frahm into one `Neocortex_Vol.mm3` across 153 species, 55
of them B&A-derived. On the corpus-callosum axis that pooling now looks **defensible**: the white
compartments agree (ratio 0.997) and B&A's white fraction is if anything the larger.

What remains is a different question, and it is not about the callosum: B&A's **grey** matter runs
~10% below Frahm's, so the two sources are on slightly different scales whatever their boundaries.
Whether that warrants a source-level adjustment in the merge, or is within the tolerance the merge
already accepts across teams, has not been assessed here.

A caveat on all of this: it is inference from compartment ratios on 9 species, not a statement from
Bush & Allman, who never specify the boundary. A sentence in their methods would settle it outright.

## 5. Action taken: `Neocortex_mm^3` is vetoed from all downstream use

**2026-09-22.** The column no longer reaches the app or any merge. It is dropped at the melt by
`____EvoM1_TraitTable/traits_select_value_flags.csv` (`action = skip`), a new file mirroring the
schema and vocabulary of the volumes merge's existing
`__merging_volumes/volumes_select_value_flags.csv` — whose own rows veto the Smaers 2017 visual
columns for precisely the same reason (a republication of Frahm under a later date).

### Why supersede was not enough

`_keys/variable_canonical.csv` already superseded `Neocortex_mm^3` into `Neocortex_Vol.mm3`, and
that worked for the species the merge covers — *Nycticebus coucang* correctly resolved to 5831, so
the corrupt 6.192 was never served. But supersede **keeps uncovered species as a fallback**, and
five of them carry `species_sci` re-identifications in the trait table that are **absent from
`_keys/reidentifications.csv`**:

| Lewitus printed | trait-table `species_sci` | Served in app as |
|---|---|---|
| *Aotus trivirgatus* | *Aotus nancymaae* | a different species |
| *Otolemur crassicaudatus* | *Otolemur garnettii* | a different species |
| *Saimiri sciureus* | *Saimiri boliviensis boliviensis* | a different taxon |
| *Gorilla gorilla* | *Gorilla gorilla gorilla* | subspecies |
| *Galagoides demidoff* | *Galago demidoff* | genus synonym (harmless) |

Because the renamed labels do not collide with the merge's species, the supersede's coverage test
missed them and five Stephan/Frahm values entered the app **under the canonical
`Neocortex_Vol.mm3` label**, presented as merge-quality volumes for species Lewitus never measured.
That is the leak the veto closes.

### Verified after the change

| Check | Result |
|---|---|
| Lewitus-sourced neocortex rows in the app | **0** |
| rows tagged `EvoM1 traits` under a Neocortex label | **0** |
| any value `6.192` anywhere in the compiled table | **0** |
| `Neocortex_Vol.mm3` species still served | 152 (unchanged, from the merge) |

The mechanism fails loudly by design: a flag row matching no melted rows is fatal ("a veto that
matches nothing is a broken veto"), and any `action` other than `skip` is rejected. Both were tested
by deliberately breaking the file.

The `variable_canonical.csv` supersede row is now dead configuration. It has been kept, with its
note rewritten to record that the veto supersedes it, so nobody re-points it at live data.

## What was deliberately not done

- **The other 37 Lewitus columns have not been tested the same way.** Only `Neocortex_mm^3` has been
  audited to value level and vetoed. The trait table contributes 38 app variables sourced to
  Lewitus 2014; 15 already carry a `variable_canonical.csv` supersede, and the remaining 22 have
  never been checked against their putative sources. Given what this one column turned out to be,
  that is the obvious next audit — `Glia_neuron_ratio`, `Glial_cell_density` and `Neuronal_density`
  first, since the 2013 footnotes already attribute them to Lewitus et al. 2012 rather than to
  either paper.
- The undocumented `species_sci` re-identifications in `glia_gyrification.xlsx` are **still in the
  trait table**; the veto stops this column using them, but they affect every other column in that
  file and belong in `_keys/reidentifications.csv` with a basis and an authority.
- A link from the public `Neocortex_*` variables to the restricted structure-key note does not exist;
  nothing in `_keys/` records the corpus-callosum status that note establishes.
- The prose definition in `Lewitus_etal_2014_TableS1_definitions.csv` still sits in the `Structure`
  column rather than `Definition`, so the app shows "Neocortex volume" rather than the
  minus-corpus-callosum wording.
- `actual_source` is filled on 2014 Table S1 for `Neocortex_mm^3` only. The other 41 columns need the
  fuzzy join from `..._variable_sources.csv` adjudicated before they are asserted.
