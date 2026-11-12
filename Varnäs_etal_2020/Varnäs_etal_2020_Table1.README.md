# Varnäs_etal_2020_Table1

**Item name** `Varnäs_etal_2020_Table1` · **Item number** `Table 1` ·
**Item encoded** (expected once registered) `10.1002%2Fsyn.22157_Table1`

Varnäs, K., Stepanov, V., & Halldin, C. (2020). Autoradiographic mapping of synaptic vesicle glycoprotein
2A in non-human primate and human brain. *Synapse* 74(10), e22157. <https://doi.org/10.1002/syn.22157>
(open access, CC BY).

**Item full original title:** TABLE 1 Binding of [¹¹C]UCB-J to synaptic vesicle glycoprotein 2A in
non-human primate and human brain (p. 4 of 6).

Folder name: diacritic kept (`Varnäs`, NFC), following the repo convention (`Sjölin_etal_2022`,
`Norlén_etal_2019`). The registry formula derives `Varnäs_etal_2020` from the citation's first author.
The PDF keeps its original download filename (`Varnas-2020-Autoradiographic mapping of synapt.pdf`),
copied from `_other_sources_metab_correlates_candidates/`.

Item number: Wiley sets the caption label in letter-spaced small caps (text layer `TA B LE 1`); the article
cites it as "Table 1", which is used for `Item number`. If the owner prefers the upper-case form
(`TABLE 1`), the Item name becomes `Varnäs_etal_2020_TABLE1` and the files must be renamed to match.

## What the data are

In vitro [11C]UCB-J **autoradiography** on whole-hemisphere cryosections (single radioligand
concentration 0.45–2.0 nM; non-displaceable binding defined with 10 µM UCB-J), as printed for **both
species groups in the same table**:

- **Non-human primate** — five cynomolgus monkeys, printed in Methods 2.2.1 as *Macaca Fascicularis*
  (20 µm coronal sections).
- **Human** — post-mortem whole hemispheres from **3 donors** (2 M, 1 F; 32, 34 and 62 y; post-mortem
  interval < 24 h), with no known neurological or psychiatric diagnosis (100 µm sections). No patient
  group exists; all tissue is healthy.

Fourteen printed regions. Per region and species group the table gives n, **specific binding (kBq/mm²,
mean (range))** and the **ratio region / white matter** (mean (range); ratios were calculated from
individual regional values). Printed blanks are kept: *Occipital cortex* has no NHP values, which is the
one region × group dropped as a row, and *White matter* has no ratio because it is the denominator.
**27 rows** = 14 human + 13 NHP.

Units are kept as printed. kBq/mm² is radioactivity per section area at one radioligand concentration,
so it is **not** Bmax and not convertible to fmol/mg: the molar activity per section is not given. It
is proportional to Bmax/KD only if KD is uniform across regions. The project units (mm³, g, mg) do not
apply and nothing is converted. Note that the NHP and human sections differ in thickness (20 vs 100 µm)
but print similar kBq/mm², so compare **within species, or via the WM ratio**, not absolute values across
species. n is very small (1–3 in human; dispersion is a range, not an SD).

Figure-only data are **not** in this item. Fig. 2 shows thalamic subnuclei and the text (p. 4) gives
only a qualitative order: highest in anterior and mediodorsal nuclei, lowest in reticular and lateral
geniculate nuclei.

## Pipeline

```
Source: Varnas-2020-Autoradiographic mapping of synapt.pdf (PDF p. 4)
  -> Varnäs_etal_2020_Table1_snapshot.R   writes the frozen snapshot
  -> Varnäs_etal_2020_Table1_snapshot.xlsx        FROZEN: 18 rows x 7 cols, sheet "Table1"
  -> Varnäs_etal_2020_Table1.R                    clean + reshape + table checks
  -> Varnäs_etal_2020_Table1.csv                  27 rows x 14 cols ("use this")
  -> __Public/comparative-data/<Item encoded>.tsv written only once the registry row exists
  -> reference_tables/Varnäs_etal_2020_Table1_definitions.csv
  -> reference_tables/Varnäs_etal_2020_species_key_proposed.csv
```

Run both scripts from a clean `Rscript` session in a UTF-8 locale (the folder name is non-ASCII; under
the C locale readxl cannot open the file path). RStudio on macOS is UTF-8 by default.

## Who read the values, when, and how it was checked

The source is a **printed PDF table**. The values were read on **2026-11-11 by an AI assistant (Claude)**
using `Varnäs_etal_2020_Table1_snapshot.R`. That script reads the PDF text layer at run time
(`pdftools::pdf_data`, word positions) and bins words into columns at the printed header words (`n`,
`Specific`, `Ratio`). It keeps only the table's Lato font, which drops the publisher's vertical
download watermark (Times-Roman, right margin); it first asserts that everything dropped lies at the
margin. **No table value is typed in any script**; the caption, header and note are anchored
literals. The extract refuses to overwrite a frozen copy that differs. During the first capture, a
superscript-placement bug in the Note line was found and fixed in the joiner, and the snapshot written
minutes earlier was regenerated once from the corrected script. No value cells changed.

Checks:

1. **Page image.** PDF p. 4 was rendered at 110 dpi and the table crops at 220 dpi, and read **row by
   row** against the snapshot: 14 rows × 6 value columns, including the blank NHP cells of Occipital
   cortex and the blank ratio cells of White matter. All agree.
2. **Table checks** (below): 44 pass, 0 mismatch.
3. **Independent cross-check.** The earlier-session staged extraction holds 27 human values
   (14 specific-binding, 13 ratios): **27/27 means and all 25 printed ranges agree.** The staged
   extraction did not include the NHP columns; those rest on checks 1–2.

Owner/RA visual check of the snapshot is still pending (registry column *Human visual check of snapshot*).

## Table checks

The table prints each mean beside its range. The reader checks the relation in units of the printed
decimals, where every printed number is ± half a unit of its last decimal:

- **n = 2** (two values): the mean must equal the midpoint of the range, within hu(mean) + (hu(min) +
  hu(max))/2. This covers 10 cells (the 5 human regions with n = 2). For example, Amygdala human
  `611 (520–703)` has midpoint 611.5, which passes at tolerance 1.0.
- **n ≥ 3**: min ≤ mean ≤ max — 34 cells.
- **n = 1**: a single value with no range is `not_evaluable` (8 cells: human Occipital cortex; NHP
  Cerebellum, Substantia nigra, Pons).

Result from an actual R run (2026-11-11): pass = 44, mismatch = 0, not_evaluable = 8.

The text's averages ("24 for NHP and 14 for human", p. 4) are not a relation printed in the table and
are not checked.

## Species

Both printed groups are kept. `species_group_as_published` holds the table header (`Non-human primate`,
`Human`) and `species_as_published` the Methods 2.2.1 name (`Macaca Fascicularis`, with the printed
capital epithet, and `Human`). The proposed key rows (collection *General*; *Macaca fascicularis* 9541,
*Homo sapiens* 9606) are in `reference_tables/Varnäs_etal_2020_species_key_proposed.csv`. They have not
been added to `_keys/General/species_key.csv`.

## Registration

The item is **not yet registered**. The build prints `not yet registered - TSV skipped` until the owner
pastes `Varnäs_etal_2020_Table1_registry_row.xlsx` into `__ReadMe.xlsx` and runs `_tools/file_list.R`.

## Errata

None recorded. There is no `reference_tables/Varnäs_etal_2020_errata.csv`.
