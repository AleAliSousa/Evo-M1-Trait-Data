# Specimen note: Gibbon "Disco" / GPZ-5542

## Purpose

This note tracks the specimen identity and taxonomic history of the gibbon named **Disco**, also recorded as **Disco 3/97** and **GPZ-5542**. The specimen appears in several brain-volume and regional-volume datasets under conflicting species labels. The goal is to prevent silent cross-species duplication in the database and to keep the specimen identity separate from published taxonomic labels.

## Current working conclusion

**Disco should be treated as one biological individual with multiple identifiers and conflicting published taxonomic assignments.**

The most important points are:

- **Specimen / house name:** Disco
- **Brain-collection identifier:** Disco 3/97
- **MacLeod/Yerkes identifier:** GPZ-5542
- **Sex:** Female
- **Age in MacLeod records:** 22 years
- **Published Hirnforschung/Zilles taxon:** *Hylobates lar*
- **Published Barger 2014 taxon:** *Nomascus concolor*
- **Studbook lead:** *Nomascus leucogenys*, white-cheeked gibbon, Studbook ID 0050, BROWNSVIL local ID 5542
- **Database handling:** keep `specimen_name`, `identifier`, `published_taxon`, and `current/resolved_taxon` separate.

Do **not** let generic `GIBBON` rows be automatically converted to *Hylobates lar* without a specimen-level check. For Disco specifically, that rule hides a real taxonomic conflict.

## Evidence chain

### 1. MacLeod dissertation / Appendix I links Disco to GPZ-5542

The MacLeod dissertation Appendix I row records Disco as a gibbon specimen with a multiline identifier field:

| Field | Value |
|---|---|
| Specimen | `GIBBON / ZILLES(SEMEND.)` |
| Identifier | `DISCO (3/97) / GPZ-5542` |
| Sex | `F` |
| Body weight | `6.8 K.` |
| Brain weight | `120 g` |
| Age | `22 YRS.` |
| Source | `YERKES` |
| Cause of death | `HEMORRHAGIC ENTERITIS` |
| Cut | `FRONTAL` |
| Stain | `AG` |

The important detail is that `GPZ-5542` appears on the second line of the same identifier cell as `DISCO (3/97)`. This is why it can be missed when the table is displayed as a single-line spreadsheet cell.

This establishes the specimen identity used in the brain dataset:

```text
Disco 3/97 = GPZ-5542
```

### 2. MacLeod dissertation sample description classifies the Hirnforschung gibbons as *Hylobates lar*

The MacLeod dissertation methodology says the Hirnforschung sample contains **5 *Hylobates lar*** among the anthropoid specimens. The user-provided dissertation text gives the Hirnforschung sample as including:

```text
5 Hylobates lar
```

and states that these specimens were drawn mainly from Karl Zilles' collection, with three chimpanzees, one gorilla, and one gibbon from the Stephan collection housed at the same institute.

This matters because it shows that, in MacLeod's framework, Disco was part of a five-specimen *Hylobates lar* Hirnforschung group rather than merely a generic gibbon later inferred to be *Hylobates lar*.

### 3. MacLeod et al. 2003 explicitly lists Disco as *Hylobates lar*

MacLeod et al. 2003 Table 2, "Volumetric data from the Hirnforschung sample," explicitly lists the five hylobatid rows as *Hylobates lar*, including Disco:

| Published taxon | Specimen | Sex | Brain volume cm3 | Cerebellum cm3 | Vermis cm3 | Hemisphere cm3 |
|---|---|---:|---:|---:|---:|---:|
| *Hylobates lar* | `YN81-146` | F | 88.8 | 10.6 | 2.0 | 8.6 |
| *Hylobates lar* | `2436 (LH)` | NA | 107.9 | 14.5 | 2.3 | 12.2 |
| *Hylobates lar* | `1547` | M | 79.3 | 12.3 | 2.4 | 9.9 |
| ** *Hylobates lar* ** | **`Disco 3/97`** | **F** | **115.8** | **13.8** | **2.3** | **11.5** |
| *Hylobates lar* | `1203` | M | 98.4 | 12.0 | 2.6 | 9.4 |

This is now direct published evidence that MacLeod et al. 2003 treated **Disco 3/97** as *Hylobates lar*.

### 4. de Sousa et al. 2010 also publishes Disco as *Hylobates lar*

de Sousa et al. 2010 follows the same identification stream. Its Table 1 lists:

```text
Hylobates lar | Disco 3/97 | Zilles | brain mass 120 g | brain volume 115.8 cm3
```

The values match MacLeod et al. 2003 and the MacLeod dissertation record:

```text
115.8 cm3 = 115800 mm3
120 g brain weight
Disco 3/97
```

Therefore, the MacLeod/de Sousa/Zilles path consistently publishes Disco as *Hylobates lar*.

### 5. The INM-1 / Zilles collection context supports why de Sousa inherited *Hylobates lar*

The INM-1/Zilles collection material lists a *Hylobates lar* specimen identified as `3/97 whole brain`, near another *Hylobates lar* entry for `YN 81/146`. This is consistent with the de Sousa 2010 and MacLeod 2003 treatment of Disco 3/97 as *Hylobates lar*.

This does not independently prove the animal was biologically *Hylobates lar*, but it explains why the Zilles/Hirnforschung-derived papers used that label.

### 6. Barger 2007 includes Disco only under generic `Gibbon`

Barger et al. 2007 Table 1 has a generic **Gibbon** section with two specimens:

| Published group | Specimen ID | Age | Sex | Hemi cm3 | Amygdaloid complex L | Amygdaloid complex R | Lateral L | Basal L | Accessory basal L |
|---|---:|---:|---|---:|---:|---:|---:|---:|---:|
| Gibbon | Disco | 22 | F | 93.2 | 0.270 | 0.367 | 0.060 | 0.086 | 0.0223 |
| Gibbon | YN81-146 | Adult | F | 68.3 | 0.203 | 0.204 | 0.046 | 0.063 | 0.0206 |

The Barger 2007 table does **not** assign a binomial name to either `Disco` or `YN81-146`; it only groups them under `Gibbon`. The paper text says the sample included both *Hylobates lar* and *Hylobates concolor*, but Table 1 does not state which specimen is which.

### 7. Barger 2014 maps Disco's Barger 2007 values to *Nomascus concolor*

Barger et al. 2014 Table 1 marks cases included in Barger et al. 2007 with an asterisk. Its two gibbon rows are:

| Published taxon in Barger 2014 | Lateral | Basal | Accessory basal | Central | Total amygdala | Hippocampus | Striatum |
|---|---:|---:|---:|---:|---:|---:|---:|
| *Hylobates lar* *,a | 0.046* | 0.063* | 0.021* | 0.009 | 0.203* | 0.805 | 1.510 |
| *Nomascus concolor* *,a | 0.060* | 0.086* | 0.022* | 0.012 | 0.270* | 0.950 | 1.994 |

The *Nomascus concolor* row matches the **left hemisphere** values for Barger 2007's Disco row:

| Measure | Barger 2007 Disco L | Barger 2014 *Nomascus concolor* |
|---|---:|---:|
| Amygdala total | 0.270 | 0.270* |
| Lateral nucleus | 0.060 | 0.060* |
| Basal nucleus | 0.086 | 0.086* |
| Accessory basal nucleus | 0.0223 | 0.022* |

The *Hylobates lar* row instead matches Barger 2007's YN81-146 left hemisphere values:

| Measure | Barger 2007 YN81-146 L | Barger 2014 *Hylobates lar* |
|---|---:|---:|
| Amygdala total | 0.203 | 0.203* |
| Lateral nucleus | 0.046 | 0.046* |
| Basal nucleus | 0.063 | 0.063* |
| Accessory basal nucleus | 0.0206 | 0.021* |

Therefore, within the Barger 2007/2014 chain:

```text
Disco -> Nomascus concolor
YN81-146 -> Hylobates lar
```

This directly conflicts with the MacLeod/de Sousa/Zilles chain, where Disco is *Hylobates lar*.

### 8. White-cheeked gibbon studbook lead points to *Nomascus leucogenys*

A white-cheeked gibbon studbook (*Nomascus leucogenys*) contains a female **DISCO**, Studbook ID **0050**, with this record:

| Field | Value |
|---|---|
| Studbook ID | `0050` |
| Birth date | `1/1/1972`, estimated to year |
| Sex | Female |
| House name | `DISCO` |
| Transfer | `BALTIMORE`, local ID `72225`, date `7/11/1972` |
| Transfer | `BROWNSVIL`, local ID `5542`, date `9/21/1993` |
| Death | `BROWNSVIL`, local ID `NHXX`, date `2/17/1994` |

The same studbook defines **BROWNSVIL** as **Gladys Porter Zoo, Brownsville, TX, USA**.

The link is not that the studbook prints `GPZ-5542`. Instead, the link is:

```text
MacLeod:     GIBBON DISCO = GPZ-5542
Studbook:   DISCO = BROWNSVIL local ID 5542
BROWNSVIL:  Gladys Porter Zoo, Brownsville, TX
Therefore:  GPZ-5542 is probably Gladys Porter Zoo local ID 5542 for Disco
```

The age agreement strengthens this match: MacLeod lists Disco as 22 years old, while the studbook gives an estimated 1972 birth and a 1994 death, approximately 22 years.

This studbook lead suggests that the animal may actually have been *Nomascus leucogenys*, not *Hylobates lar* or *Nomascus concolor*. Because it is an animal-record/studbook source rather than a secondary brain-table label, it may be the strongest taxonomic evidence, but it should still be marked as a resolution by external provenance unless original Yerkes/Gladys Porter Zoo accession records are obtained.

## Why the taxonomic confusion matters in DeCasien / merge comparisons

### DeCasien 2019 duplicated Disco across genus labels

DeCasien MOESM3 / Brain Region Data includes both of these values:

```text
Hylobates_lar       BV 115800    ref 60 = de Sousa et al. 2010
Nomascus_concolor   BV 115800    refs 56;57 = Barger 2007, 2014
```

These are not two different animals. They are the same **Disco 3/97 / GPZ-5542** brain volume entered under two taxonomic labels.

The value is:

```text
115.8 cm3 = 115800 mm3
```

This is the MacLeod/de Sousa Disco brain volume.

### DeCasien `Nomascus_concolor` amygdala 637 is also Disco

DeCasien's `Nomascus_concolor` amygdala value is:

```text
637 mm3
```

That equals Barger 2007 Disco bilateral amygdaloid complex:

```text
0.270 cc + 0.367 cc = 0.637 cc = 637 mm3
```

The parallel *Hylobates lar* amygdala value in DeCasien is:

```text
407 mm3 = 0.203 + 0.204 cc
```

which corresponds to Barger 2007 YN81-146, not Disco.

So DeCasien's two gibbon amygdala values reflect Barger 2014's relabeling of the two Barger 2007 generic `Gibbon` rows:

```text
Disco      -> Nomascus_concolor -> Amygdala 637
YN81-146   -> Hylobates_lar     -> Amygdala 407
```

### Why the prior 18% mismatch was spurious

A previous comparison matched DeCasien `Nomascus_concolor` amygdala 637 against a Barger 2014-derived *Nomascus concolor* value of 540 mm3, producing an apparent mismatch of 17.96% (recorded as `mismatch_pct = 17.963` in `DeCasien_vs_merge_comparison.csv`).

But 540 is the same Disco animal estimated from only the left hemisphere:

```text
Barger 2014 left total = 0.270 cc
Left doubled estimate = 0.270 x 2000 = 540 mm3
```

Barger 2007 has both hemispheres and shows that Disco is asymmetric:

```text
Left  = 0.270 cc
Right = 0.367 cc
True bilateral = 0.637 cc = 637 mm3
```

Therefore, the 18% gap is not a species difference. It is a comparison between a left-doubled estimate and a true bilateral measurement from the same specimen.

## Secure conclusions

The following are secure enough for database annotation:

1. **Disco 3/97 and GPZ-5542 are the same brain specimen identity in MacLeod's records.**
2. **MacLeod dissertation / MacLeod et al. 2003 / de Sousa et al. 2010 publish Disco as *Hylobates lar*.**
3. **Barger 2007 lists Disco only as generic `Gibbon`.**
4. **Barger 2014 maps the Barger 2007 Disco values to *Nomascus concolor*.**
5. **Barger 2014 maps YN81-146, not Disco, to *Hylobates lar*.**
6. **The white-cheeked gibbon studbook lead links a female DISCO with BROWNSVIL local ID 5542, pointing to *Nomascus leucogenys*.**
7. **DeCasien's `Nomascus_concolor` BV 115800 and Amygdala 637 are duplicate entries of the Disco specimen, not independent *Nomascus* records.**

## What remains unresolved

The unresolved question is the animal's true biological species.

Published brain datasets conflict:

| Source path | Taxon label for Disco |
|---|---|
| MacLeod dissertation Appendix I | generic `GIBBON`, identifier `DISCO (3/97) / GPZ-5542` |
| MacLeod dissertation sample description | Disco included among 5 *Hylobates lar* Hirnforschung specimens |
| MacLeod et al. 2003 Table 2 | *Hylobates lar* `(Disco 3/97)` |
| de Sousa et al. 2010 | *Hylobates lar* `Disco 3/97` |
| Barger 2007 | generic `Gibbon`, specimen `Disco` |
| Barger 2014 | *Nomascus concolor* values matching Disco |
| White-cheeked gibbon studbook lead | *Nomascus leucogenys*, `DISCO`, BROWNSVIL local ID `5542` |

The best way to settle the true taxon would be original accession/pedigree documentation from Yerkes and/or Gladys Porter Zoo for `GPZ-5542`, `BROWNSVIL 5542`, or house name `Disco`.

## Recommended database treatment

### Specimen-level fields

```text
specimen_name = DISCO
record_note = 3/97
primary_identifier = GPZ-5542
alternate_identifiers = DISCO (3/97); GPZ-5542; BROWNSVIL 5542; Baltimore 72225; Studbook ID 0050
sex = F
source = YERKES / Zilles-Semendeferi / Hirnforschung
probable_prior_institution = Gladys Porter Zoo / BROWNSVIL
birth_date_estimated = 1972-01-01
birth_date_estimate_precision = year
death_date = 1994-02-17
age_at_death_years = 22
```

### Published taxon aliases

```text
published_as_generic = GIBBON
published_as_hylobates_lar = MacLeod dissertation; MacLeod et al. 2003; de Sousa et al. 2010; INM/Zilles-derived records
published_as_nomascus_concolor = Barger et al. 2014; DeCasien refs 56;57 for Disco-derived cells
studbook_taxon_lead = Nomascus leucogenys
```

### Recommended current taxon handling

Most conservative option:

```text
taxon_current = NA
taxon_common_printed = gibbon
taxon_conflict = TRUE
taxon_note = Disco / GPZ-5542 has conflicting published labels: Hylobates lar in MacLeod/de Sousa/Zilles-derived sources, Nomascus concolor in Barger 2014, and a studbook lead pointing to Nomascus leucogenys. Resolve only with original accession or studbook/pedigree evidence.
```

If accepting the studbook as authoritative:

```text
taxon_current = Nomascus leucogenys
taxon_basis = White-cheeked Gibbon Studbook, Studbook ID 0050, house name DISCO, BROWNSVIL local ID 5542; linked to MacLeod GPZ-5542 by name, sex, age, and Gladys Porter Zoo local ID.
taxon_conflict = TRUE
```

Either way, retain the publication-specific labels rather than overwriting them.

## Recommended action for DeCasien/merge comparison

Reclassify the DeCasien `Nomascus_concolor` Disco cells rather than adding independent *Nomascus* records:

```text
status = decasien_duplicate_of_Hylobates_lar_Disco
flag = decasien_duplicate_specimen_cross_genus
specimen = Disco / GPZ-5542
```

For BV:

```text
DeCasien taxon = Nomascus_concolor
DeCasien value = 115800
matched_source = deSousa_etal_2010_Table1 / MacLeod_etal_2003_Table2
matched_value = 115800
pct_diff = 0
note = Same Disco specimen; DeCasien cross-genus duplicate.
```

For amygdala:

```text
DeCasien taxon = Nomascus_concolor
DeCasien value = 637
matched_source = Barger2007_specimen
matched_value = 637
pct_diff = 0
mismatch_audit_source = Barger2014 left-doubled estimate
mismatch_audit_value = 540
mismatch_audit_pct = ~18
note = 637 is true bilateral L+R for Disco; 540 is left-doubled from Barger 2014 and underestimates because Disco is asymmetric.
```

## Script/data-cleaning implications

Keep these concepts separate in cleaned outputs:

```text
taxon_printed
published_taxon
species_current
specimen_name
record_note
primary_identifier
alternate_identifiers
taxon_common_printed
taxonomic_issue
taxonomic_note
```

For MacLeod Appendix I, the multiline `IDENT. NUMBER` field should parse Disco as:

```text
specimen_name = DISCO
record_note = 3/97
primary_identifier = GPZ-5542
alternate_identifiers = DISCO (3/97); GPZ-5542
```

Avoid blanket rules like:

```text
GIBBON -> Hylobates lar
```

Instead, use specimen-level mapping:

```text
Disco / GPZ-5542 = taxonomic conflict; published as H. lar, N. concolor, studbook lead N. leucogenys
YN81-146 = Hylobates lar in Barger 2014 and multiple related datasets
1203 = Hylobates lar in Stephan/Smaers-related datasets; separate from Disco
```

## Suggested database note

> The specimen `Disco` is a female gibbon brain specimen also recorded as `Disco 3/97` and `GPZ-5542`. MacLeod's dissertation Appendix I records it as `GIBBON`, identifier `DISCO (3/97) / GPZ-5542`, sex F, age 22 years, source Yerkes. The MacLeod dissertation sample description treats the Hirnforschung gibbons as five *Hylobates lar*, and MacLeod et al. 2003 Table 2 explicitly lists `Hylobates lar (Disco 3/97)`, brain volume 115.8 cm3. de Sousa et al. 2010 also publishes `Hylobates lar Disco 3/97`, brain volume 115.8 cm3. Barger 2007 lists the same specimen only as `Gibbon / Disco`, but Barger 2014 maps its left-hemisphere amygdala values to *Nomascus concolor*; Barger 2014's *Hylobates lar* row corresponds instead to `YN81-146`. A white-cheeked gibbon studbook lead links a female `DISCO`, Studbook ID 0050, to BROWNSVIL local ID 5542 at Gladys Porter Zoo, pointing to *Nomascus leucogenys*. Therefore Disco should be tracked as a single specimen with conflicting taxonomic labels. DeCasien `Nomascus_concolor` BV 115800 and Amygdala 637 should be treated as cross-genus duplicates of Disco, not independent *Nomascus* records.

## Sources checked / cited in this note

- MacLeod dissertation Appendix I / `MacLeod__2000_APPENDIXI.csv`, row `GIBBON / ZILLES(SEMEND.)`, identifier `DISCO (3/97) / GPZ-5542`.
- User-provided MacLeod dissertation methodology text, Chapter Three, Hirnforschung sample description.
- MacLeod et al. 2003, Table 2, `Hylobates lar (Disco 3/97)`, brain volume 115.8 cm3, cerebellum 13.8 cm3, vermis 2.3 cm3, hemisphere 11.5 cm3.
- de Sousa et al. 2010, Table 1, `Hylobates lar Disco 3/97`, brain mass 120 g, brain volume 115.8 cm3.
- INM-1 / Zilles collection specimen list, `Hylobates lar ... 3/97 whole brain` near `Hylobates lar f YN 81/146`.
- Barger et al. 2007, Table 1, generic `Gibbon` rows for `Disco` and `YN81-146`.
- Barger et al. 2014, Table 1, starred rows mapping Barger 2007 values to *Nomascus concolor* and *Hylobates lar*.
- DeCasien & Higham 2019 MOESM3, Brain Region Data, duplicate `Hylobates_lar` and `Nomascus_concolor` Disco-derived cells.
- White-Cheeked Gibbon Studbook, *Nomascus leucogenys*, North American Region Studbook, Studbook ID 0050, house name `DISCO`, BROWNSVIL local ID `5542`.

## Addendum, 2026-08-29 — the MRI question, and whether Stephan/Frahm brains reach Semendeferi

*Public account. Restricted evidence — curator-code and catalog linkage, the Bauernfeind
accession join, and the studbook draft — is in
`Evo-M1-Trait-Data-restricted/specimen_registry/cases/hylobates/`.
Companion table: `Disco_study_list_public.csv`.*

---

## 1. Your claim about Semendeferi is supported — and it cannot be falsified from the published tables

**No Stephan/Frahm brain can be traced into any Semendeferi study.** Four checks, all negative:

- **No Semendeferi publication is registered in the specimen crosswalk at all** — zero of the
  26 `source_publication` values.
- **`Semendeferi_etal_1998`, `_2001`, `_2002` report species-level values with n = 1 and no
  specimen identifiers.** Their brain volumes (1,158,300 / 393,000 / 378,400 mm³) match no
  Frahm individual within 0.5%.
- **`Semendeferi_Damasio_2000` does have a `Specimen` column with 29 individuals — but the
  labels are anonymous sequential tags** (`Human 1`, `Gibbon 3`, `Orang-utan 2`). No
  accession number, no house name. Identifier matching is impossible by construction.
- **`_keys/team_grouping_crosswalk.csv` files Semendeferi 1998 and 2001 under
  `registry_Team = Zilles`** — Zilles collection material, not Stephan.

The important qualification: this is **absence of any linkable identifier, not demonstrated
absence of the brains**. Semendeferi & Damasio 2000 anonymised its sample, so no amount of
work on the repo side can confirm or refute overlap. Only the authors' own records could.

### Where the "Semendeferi" attribution actually comes from

11 specimens carry a collection string naming Semendeferi (`Zilles/Semendeferi`,
`Zilles/Semendeferi (ex Yerkes)`). **Every one of those attributions comes from
`MacLeod_2000` or `Barger_etal_2007`** — other authors describing the shared collection.
None comes from a Semendeferi-authored table. MacLeod's Appendix I prints the collection as
`ZILLES(SEMEND.)`, which is the documentary trace of exactly the situation you described:
Zilles and Semendeferi divided sections from the same brains, so the same animal exists in
both collections in different physical form.

Those 11 are the Pongo trio (Harry, Briggs, YN85-38), five *Pan*, one *Gorilla*, and the two
gibbons Disco and YN81-146. They are the shared-brain set.

### The one Stephan gibbon

`MacLeod_etal_2003_Table2` carries a `stephan_collection` boolean, and among its five
Hirnforschung gibbons **only `1203` is TRUE**. That specimen is `STEPHAN-FRAHM-0200`, also
published by `Smaers_etal_2010`. It is the single Stephan-collection gibbon in the
Hirnforschung sample — consistent with the dissertation's description of three chimpanzees,
one gorilla and one gibbon coming from Stephan.

---

## 2. Disco: 8 studies, 4 registered and 4 not

You remembered the code correctly. **`deSousa_etal_2009_Table1` lists Disco as `hld`**, with
`archive_number = Disco`, F, 22 yr, brain 120,000 mg, left V1 2,292 mm³, left LGN 90 mm³.
That study is **not registered in the crosswalk**.

| study | handle used | modality | status |
|---|---|---|---|
| `MacLeod_2000` | `DISCO (3/97) / GPZ-5542` | histology | registered |
| `MacLeod_etal_2003` | `Disco 3/97` | histology | **not registered** |
| `deSousa_dissertation_2008` | `hld` | histology | registered |
| `deSousa_etal_2009` | `hld` (archive `Disco`) | histology / cytoarchitecture | **not registered** |
| `deSousa_etal_2010` | `Disco 3/97` | histology | registered |
| `Barger_etal_2007` | `Disco` / `GPZ-5542` | histology | registered |
| `Barger_etal_2014` | **none printed** | histology | **not registered**, value-level only |
| `DeCasien_Higham_2019` | Disco named only in repo reconciliation | secondary compilation | **not registered** |

Rejected as false positives: `Baron_etal_1996` and `Burger_etal_2019`, where the grep hit is
*discolor* (a species epithet), not Disco.

`Barger_etal_2014` is the hardest case: it prints no specimen handle at all, and Disco is
identifiable there only because its *Nomascus concolor* row reproduces the left-hemisphere
amygdala values of Barger 2007's Disco row. A handle-based search will never find it.

---

## 3. The MRI question: not excluded, and not confirmable by values

Three MRI-or-MRI-adjacent samples could in principle contain Disco.

| sample | modality | gibbons | identifiers printed | verdict |
|---|---|---|---|---|
| `MacLeod_etal_2003` Table 1 | histology, Yerkes sample, 47 rows all coronal | Sunny, Cherokee, Cleo, Buddy | house names | **Disco excluded** — named gibbons, none is Disco |
| `Semendeferi_Damasio_2000` | MRI | `Gibbon 1`–`Gibbon 4`, 79.5 / 92.6 / 78.5 / 78.5 cm³ | none | **cannot confirm or exclude** |
| `Rilling_Insel_1998` / `_1999` | MRI | n = 4 (2M 2F), mean 83.0 cc | none — species means only | **cannot confirm or exclude** |

Disco is female, and Rilling's gibbon sample contains two females, so she is not excluded on
sex or count.

**I tested whether the two MRI samples are actually one dataset.** Sample sizes match for
*Gorilla* (2), *Pan troglodytes* (6) and *Pongo* (4), and the gibbon means agree to 0.87%
(82.275 vs 83.0 cc) — but the remaining species means differ by 4.9% to 10.9%
(*Gorilla* +10.9%, *Pongo* +8.9%, *Pan paniscus* +8.1%, *Homo* +7.0%, *Pan troglodytes*
−4.9%). **They are not the same scans.** The gibbon agreement is an isolated coincidence,
not evidence of a shared sample.

That negative result matters for method: **cross-modality value matching cannot establish
specimen identity here.** In vivo or whole-brain MRI volumes and fixed, sectioned,
shrinkage-corrected histological volumes differ systematically — Disco's histological brain
volume is 115.8 cm³ against an MRI gibbon maximum of 92.6 cm³. Only identifiers can link a
brain across modalities, and neither MRI study published any.

### Four named gibbons nobody has registered

`Sunny`, `Cherokee`, `Cleo` and `Buddy` (MacLeod 2003 Table 1, Yerkes sample) appear in
**neither the catalog nor the crosswalk nor the alias index**. They are named Yerkes animals,
which makes them the most studbook-tractable specimens in the gibbon set — the same route
that resolved Kanting. Registering them is a prerequisite for asking whether any of them is
also an MRI subject.

---

