# Species-name marker audit

**Date:** 2026-08-19
**Scope:** every `.csv`, `.tsv`, `.xlsx`, `.xlsm`, `.xls`, `.R`, `.py`, `.md` and `.pdf`
in the repo (2,022 files + 201 PDFs; 26,255 distinct binomial-like strings).
**Scanner:** `_checks/scan_species_name_markers.py` (re-runnable; six passes).
**Register:** `_checks/species_name_marker_audit.csv`.
**Status:** findings independently re-verified against builder scripts, snapshots and
source PDFs; three first-pass conclusions were wrong and have been corrected here.

## Why this audit exists

`Homo sapiensb` is not a misspelling. It is `Homo sapiens` + a superscript footnote
marker `b` that lost its typography when the printed table was flattened into a
snapshot. The same happens with trailing digits and with `† ‡ § *`. In every case
the trailing character **carries information**: it must be decoded into its own
column, never silently deleted and never left glued to the name.

Two distinct conventions are both correct, and they should not be confused:

- **Footnote markers** (`deSousa_etal_2009/2010`, `MacLeod_etal_2003`):
  `species_as_published` holds the name *without* the marker, the marker goes in
  `footnote_ref` or a decoded column, and it is never stored in both places.
- **Specimen labels** (`Ashwell__2020`, `MacLeod_etal_2003` `specimen`): the printed
  label genuinely *is* `Ornithorhynchus anatinus 1`, so it stays intact in the
  as-published field, with `specimen_number` as the parsed companion. The number is
  reproduced twice on purpose — that is not a violation of the rule above.

## Summary

| Class | Instances | Sources | Handled | Gaps |
|---|---|---|---|---|
| 1. Glued footnote **letters** (a/b/c/d) | 16 cells | 4 | 4 | 0 |
| 2. Glued footnote **numbers** (former-name synonymy) | 30 cells | 4 | 2 | **2** |
| 3. **Symbol** markers (`† ‡ § *`) | 40 cells | 4 | 2 | **2** |
| 4. Trailing numbers = **specimen codes** | ~90 cells | 5 | 5 | 0 |
| 5. Trailing numbers = **composite key** (not a marker) | 417 cells | 1 | n/a | 0 |
| 6. Look-alikes = genuine **spelling variants** | ~30 pairs | many | n/a | 0 |
| 7. Genuine **OCR corruption** (opposite problem) | 7 | 5 | raw layer only | 0 |

**Four live gaps**, in `Frahm_etal_1984`, `Baron_etal_1988`, `Lewitus_etal_2014` and
`Baron_etal_1996`. One further defect surfaced en route: `Lewitus_etal_2014_TableS1.csv`
carries two footnote lines as if they were species rows.

Only one built CSV still has a marker glued to a name (`Lewitus`, §3.3); everywhere
else the markers were either decoded or lost at the snapshot step.

---

## 1. Glued footnote letters — all handled

| Source | Printed value(s) | Marker means | Where it lives now |
|---|---|---|---|
| `deSousa_etal_2010` Table 1 | `Homo sapiensb` (10 rows) | footnote b: values differ from Amunts 2007 by shrinkage-correction convention | `footnote_ref` |
| `deSousa_etal_2009` Table 1 | `Pan paniscusc`, `Pan troglodytesd` | table footnotes c, d | `footnote_ref` |
| `Barger_etal_2014` Table 1 | `Homo sapiens∗,a`, `Pan troglodytes∗,a`, `Pan troglodytesb`, `Pan paniscus∗,a`, `Gorilla gorilla∗,a`, `Gorilla gorillab`, `Pongo pygmaeus∗,a`, `Pongo pygmaeusa`, `Pongo pygmaeusb`, `Hylobates lar ∗,a`, `Nomascus concolor ∗,a`, `Hylobates muellerib` | `∗` = case also in Barger 2007; `a` = paraffin, `b` = cryosectioned | `in_barger2007` + `processing` (20 rows) |
| `Bauernfeind_etal_2013` | `Total insula (right)a`, `(left)a` (column headers, not species) | footnote a | transcribed in the ReadMe |

Barger is the instructive case: two markers ride in one cell, and the same letter
`a` means "paraffin" here and something else in every other paper. Decoding needs
the legend, never a regex guess.

---

## 2. Glued footnote numbers — the Frankfurt synonymy series

In the Stephan / Frahm / Baron tables a digit after the binomial points into a
legend of **names used in former papers**. The numbering is **paper-scoped** — the
same digit means different taxa in different papers, so each legend must be
transcribed per source and never reused.

| Source | Printed values | Status |
|---|---|---|
| `Baron_etal_1983` Table 1 | 12 species, digits 1–12 (`Erinaceus algirus1` … `Rhynchocyon cirnei12`) | ✅ `Species_former_synonym`, 12/12 populated; legend transcribed in the R script |
| `Stephan_etal_1982` Table 1 | `Erinaceus algirus¹` … `Saguinus midas¹¹` — **different numbering from Baron 1983** (here 6 = *Rhynchocyon cirnei*; there 6 = *Lemur fulvus*) | ✅ `former_name_ref` + `former_name`, 11 pairs |
| `Frahm_etal_1984` Table 1 | `Lemur albifrons 1)`, `Varecia variegata 2)`, `Otolemur crassicaudatus 3)`, `Galagoides demidoff 4)`, `Saguinus midas 5)`, `Miopithecus talapoin 6)` | ❌ **GAP 2.1** |
| `Frahm_etal_1982` Table 1 | `Erinaceus algirus¹` … `Miopithecus talapoin¹¹`, superscript runs still live in `frahm_stephan_1982.xlsx` | not a gap — **Table 1 is not transcribed**; the repo builds Table 2, which prints no per-species marker |

### Gap 2.1 — `Frahm_etal_1984` Table 1 drops the synonymy footnote

`frahm_etal_1984.pdf` prints the marker (e.g. p. text line 168,
`Lemur albifrons 1) … 2 … 1,519`) and the legend at line 209:

> "Classification and species names are adapted to the list given by Corbet and Hill
> (1980). Different names used in former papers and in Stephan et al. (1981) are:
> 1) *Lemur fulvus*; 2) *Lemur variegatus*; 3) *Galago crassicaudatus*;
> 4) *Galago demidovii*; 5) *Saguinus tamarin*; 6) *Cercopithecus talapoin*
> (for Tables 1–3) and 7) *Aethechinus algirus*; and 8) *Crocidura occidentalis*
> (for Table 4)."

`Frahm_etal_1984_Table1_snapshot.xlsx` already has the digits gone;
`Frahm_etal_1984_Table1.csv` is `Species, n, Area_striata_*, source` with no
former-name column, and the README never mentions the footnote.

**Fix:** re-snapshot the six rows with their `n)` markers, transcribe the 8-entry
legend (noting the 1–6 / 7–8 table split), and add `Species_former_synonym` exactly
as `Baron_etal_1983_Table1.R` does. These former names are the join keys against
Stephan et al. 1981a.

---

## 3. Symbol markers

| Source | Marker | Meaning (from the legend) | Status |
|---|---|---|---|
| `MacLeod_etal_2003` Table 2 | `†` `‡` `*` `§` | † from the Stephan Collection · ‡ brain weight not known · * horizontal sections · § sagittal sections (default coronal) | ✅ decoded into `stephan_collection`, `brainweight_known`, `section_plane` (26 marked rows). Table 1's all-FALSE/coronal values are correct — its snapshot carries no markers |
| `Baron_etal_1988` Table 1 | `*)` | **semiaquatic species** | ❌ **GAP 3.1** |
| `Lewitus_etal_2014` Table S1 | `*` on 12 species | GI calculated by the authors from Nissl sections (brainmuseum.org), not taken from the literature | ❌ **GAP 3.2** |
| `Baron_etal_1996` Tables 10 / 32 | `§)` | "see addendum at end of Volume 3, pp. 1592–1595" | ⚠️ **GAP 3.3** (minor) |
| `Caspar_etal_2022` | `†` on *Macaca tonkeana* | "Ages unknown, sex derived from given names" | not a gap — the dagger is in the paper's **Table 4**, which the repo does not ingest; Table 1 prints no dagger |

### Gap 3.1 — `Baron_etal_1988` loses the semiaquatic flag

Caption of `baron_etal_1988_scan.pdf` (text line 212): *"… in Insectivora and
Scandentia; \*) = semiaquatic species."* Five rows are marked in print —
*Potamogale velox, Micropotamogale ruwenzorii, Neomys fodiens, Desmana moschata,
Galemys pyrenaicus* — and all five are in `Baron_etal_1988_Table1.csv` (lines 23,
30, 43, 47, 56) with columns `Species, VC, VI, VL, VM, VS` only. The snapshot was
reconstructed from `comparison/Baron_1988.csv`, so it never carried the marker.

This is the most substantive loss in the audit: **semiaquatic vs terrestrial is the
paper's headline contrast**, and the flag is now invisible to anyone using the
built table.

**Fix:** add a logical `semiaquatic` column, populated from the five printed names.

### Gap 3.2 — `Lewitus_etal_2014` leaves the asterisk glued to the name

The legend is sharedString 146 of `pbio.1002000.s013.xlsx`: *"\*Calculated from
images of Nissl-stained coronal sections from www.brainmuseum.org (see Methods)"* —
a **primary-vs-secondary provenance flag** on the GI value, exactly the distinction
this repo tracks elsewhere.

`Lewitus_etal_2014_TableS1.R:51` does strip `*`, but only inside the `resolve`
closure that feeds `species_sci`. The original `Species` column is bound
separately, so the marker **survives into the built CSV and the public TSV**:

```
species_sci             Species
Oryctolagus cuniculus   Oryctolagus_cuniculus*
Mandrillus sphinx       Mandrillus_sphinx*
```

12 species carry it: *Oryctolagus cuniculus, Mandrillus sphinx, Alouatta palliata,
Callicebus moloch, Cynocephalus volans, Tupaia glis, Capra hircus domestica,
Pteropus giganteus, Choloepus didactylus, Dasypus novemcinctus, Trichechus manatus,
Procavia capensis*.

**Fix:** add `GI_measured_by_authors` (logical), and clean `Species` so no built
column keeps a marker glued to a name.

#### Gap 3.2b — two footnote lines are ingested as species rows

Source rows 105–106 land in `Lewitus_etal_2014_TableS1.csv` as data rows with all
39 trait fields `NA`:

```
"¶ See Table S2 for column definitions", …
"Calculated from images of Nissl-stained coronal sections from www.brainmuseum.org (see Methods)", …
```

The CSV, the public TSV (105 lines), the script comment and the README all state
**104 species**; the real count is **102** — which is what
`__merging_gyrification/gyrification_compiled.R:9` already assumes. The founder-TSV
QA ("104/104 matched") passes only because the founder carries the same two phantom
rows. They do not reach `gyrification_long/wide.csv`, so nothing downstream is
numerically wrong, but the row-count claim and the QA anchor are both off by two.

### Gap 3.3 — `Baron_etal_1996` `§)` meaning is recoverable

The `§)` is preserved verbatim in `Species_Baron1996` and named in the README as an
"addendum marker", but its meaning is not recorded. The book spells it out on
pp. 56/63/138/145: *"§) see addendum at end of Volume 3, pp. 1592–1595."*

Note the marker also survives in `Baron_etal_1996_taxonomy_crosswalk.csv` and in
both public TSVs (`ISBN%3A9783764353704_Table10.tsv`, `…_Table32.tsv`).

**Fix:** transcribe the legend text into the README and decode into a boolean.
(Other markers in that book — `*)` = "Median values between males and females…",
`**)` = "Doubtful determination; probably *Myotis myotis*" — sit on tables the repo
does not build, so Tables 10/32 need only `§)`.)

---

## 4. Trailing numbers that ARE specimen codes — all handled

| Source | Values | Where it lives |
|---|---|---|
| `Ashwell__2020` | `Ornithorhynchus anatinus 1/2/3`, `Tachyglossus aculeatus 1/2/3` | `species_as_published` + `specimen_number` + `row_type` |
| `MacLeod_etal_2003` | `Homo sapiens 1`…`6`, `Cebus sp. 5` | `specimen` |
| `Smaers_etal_2011` | `Gorilla gorilla 375`, `Homo sapiens 1696/2431/5694/6895`, `Hylobates lar 1203`, `Alouatta seniculus1184`, `Pithecia monachus1180`, + 12 more | `catalogue_number` (Stephan-collection accession numbers) |
| `Baker_etal_2025` | `Oreopithecus_bambolii_1` | specimen ID column |
| `Stephan_etal_1981` | `Stephan code 1`…`44` | code column |

Cross-check worth keeping: `Smaers_etal_2011`'s `Gorilla gorilla 375` and
`MacLeod_etal_2003`'s `Gorilla gorilla (A375) †` are the **same Stephan-collection
brain**; likewise `Hylobates lar 1203` / `Hylobates lar (1203) †`. Two sources, two
encodings of one accession number.

## 5. Trailing numbers that are NOT markers

`DeCasien_Higham_2019`, sheet **"Group Size Data (from 38)"**, 417 values such as
`Alouatta_palliata12.2`, `Allenopithecus_nigroviridis40`. The column header reads
`KEY (species name & group size)`: the number is the **group-size value concatenated
into a dedup key**, and the sheet's own `First or Duplicate Entry?` column uses it to
mark `ok` / `dup`. Do not parse these as specimen codes or footnotes.

## 6. Look-alikes that are genuine spelling variants

~30 pairs differ by a trailing letter that **is** part of the name — mostly the
`-i` / `-ii` patronymic genitive and Latin gender agreement. Do not "fix" these;
they belong in the taxonomy crosswalk, not the footnote layer.

`Callimico goeldii/goeldi` · `Otolemur garnettii/garnetti` ·
`Miniopterus schreibersii/schreibersi` · `Myotis daubentonii/daubentoni` ·
`Myotis bechsteinii/bechsteini` · `Equus burchellii/burchelli` ·
`Scotophilus kuhlii/kuhli`, `heathii/heathi`, `dinganii/dingani` ·
`Pteronotus parnellii/parnelli` · `Pteropus temminckii/temmincki` ·
`Spermophilus richardsonii/richardsoni`, `townsendii/townsendi` ·
`Chalinolobus gouldii/gouldi` · `Cynopterus horsfieldii/horsfieldi` ·
`Elephantulus edwardii/edwardi` · `Enchisthenes hartii/harti` ·
`Hylobates klossii/klossi` · `Vulpes rueppellii/rueppelli` ·
`Zaglossus bruijnii/bruijni` · `Citellus parryii/parryi` ·
`Fukomys mechowii/mechowi` · `Herpestes edwardsii/edwardsi` ·
`Lasiopodomys / Microtus brandtii/brandti` · `Neophascogale lorentzii/lorentzi` ·
`Rhinolophus pearsonii/pearsoni` · `Callithrix kuhlii/kuhli`, `humeralifera/humeralifer` ·
`Anoura caudifera/caudifer` · `Chinchilla lanigera/laniger` ·
`Crocidura hildegardeae/hildegardea`

## 7. Genuine OCR corruption found en route

The mirror-image problem: these really are broken, and all sit in the **raw /
extract layer only** — none reaches a built `.csv`.

| Corrupted | Correct | File |
|---|---|---|
| `Aclhcchinus algirus` | *Aethechinus algirus* | `Stephan_etal_1970/stephan_etal_1970.xlsx` |
| `Aotes trivirgarus` | *Aotus trivirgatus* | `Stephan_etal_1970/stephan_etal_1970.xlsx` |
| `Aorus trivirgatus` | *Aotus trivirgatus* | `Matano_etal_1985_a/Matano-1985-Volume comparisons i 2.xlsx` |
| `Apodemus jlavicollis` | *Apodemus flavicollis* (fl-ligature → `jl`) | `Iwaniuk_etal_2001/Iwaniuk_etal_2001.xlsx` |
| `Cercocebus alb1gena` | *Cercocebus albigena* (`i` → `1`) | raw extract |
| `Nycriceb11s coi1ca11g` | *Nycticebus coucang* (`u` → `11`, `t` → `r`) | raw extract |
| `Callimico goeldii` + 42 spaces + `0` | merged-cell bleed, Table 7 | `Iwaniuk_etal_2001/Iwaniuk_etal_2001.xlsx` |

---

## Confirmed clean

No species-name markers in raw, snapshot, PDF or built layers:
`Stephan_etal_1984 / 1987 / 1988 / 1991`, `Baron_etal_1987 / 1990`,
`Frahm_etal_1997 / 1998`, `Frahm_Zilles_1994`, `Zilles__Rehkamper_1988`,
all `Matano`, `Bush_Allman` and `Sherwood` folders.

`Stephan_etal_1988` has `EIᵃ` and `Ecoethological characteristicsᵇ` on *column
headers*; both legends are transcribed in the snapshot and decoded into
`activity` / `diet_category` / `locomotion` / `ecoethology_refs`.

## Two detection lessons

**1. Read the raw `.xlsx` XML before snapshotting.** `.xlsx` files keep superscript
*formatting* in `xl/sharedStrings.xml` (`<vertAlign val="superscript"/>`) even when
every downstream reader flattens it. Reading that XML recovers the marker *and*
tells you which characters were superscript. Pass D of the scanner does this.

**2. The snapshot step is where markers die, so the PDF is the only witness.**
Both `Frahm_etal_1984` and `Baron_etal_1988` lost their markers before the snapshot
was written; nothing in any spreadsheet or script records them, and the first pass
of this audit missed both because it did not read PDFs. The scanner now runs
`pdftotext` over every PDF. **Whenever a snapshot is built from a scanned table,
check the printed page for footnote markers before trusting the snapshot.**

Pass F is recall-limited, not precision-limited: it only sees a marker when OCR
keeps the binomial and the marker on one line, so it recovers 5 of the 6 Frahm 1984
rows and 1 of the 5 Baron 1988 rows. Treat a single F hit in a folder as a signal to
read that table's caption by hand — the full row lists in the register came from
doing exactly that.

One scanner note: the audit's own outputs are excluded from the scan
(`SKIP_NAMES`). They quote every marker they document, and leaving them in scope
inflates the "how many files is this string in?" counts that pass A depends on —
enough to stop it flagging `Homo sapiensb` at all.
