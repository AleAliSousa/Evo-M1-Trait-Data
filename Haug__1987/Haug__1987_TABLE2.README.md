# Haug 1987 — TABLE 2 (brain volume and register number, 42 species)

**Built 2026-10-26.**

| File | |
|---|---|
| `Haug-1987-Brain sizes, surface.pdf` | the paper (from the EndNote library, record 6894) |
| `Haug__1987_TABLE2_snapshot.xlsx` | frozen source (sheet `TABLE2`): printed caption, two header tiers, 42 rows, printed footnote |
| `Haug__1987_extract_snapshot.py` | builds the snapshot from the PDF text layer (no table values typed into the script) |
| `Haug__1987_TABLE2.R` | reformat: snapshot → CSV (+ TSV once registered) |
| `Haug__1987_TABLE2.csv` | analysis table — **42 rows** |
| `reference_tables/Haug__1987_TABLE2_definitions.csv` | data dictionary |
| `PROPOSED_species_key_rows.csv` | 37 staged species-key rows (nothing merged into `_keys/`) |
| `Haug__1987_TABLE2_registry_row.xlsx` | registry row for the owner to paste into `__ReadMe.xlsx` |

Registry: `Item name = Haug__1987_TABLE2`, expected `Item encoded = 10.1002%2Faja.1001800203_TABLE2`. **Not yet
registered, so the public TSV has not been written** — the `.R` writes it once the row is pasted and
`_tools/file_list.R` has run.

## Source

Haug, H. (1987). *Brain sizes, surfaces, and neuronal sizes of the cortex cerebri: a stereological
investigation of man and his variability and a comparison with some mammals (primates, whale,
marsupials, insectivores, and one elephant).* **Am J Anat 180(2):126–142.** DOI
10.1002/aja.1001800203. TABLE 2 is printed on **journal p. 128 = PDF p. 3**. (Printed caption: "The
various species of this investigation including the brain volume (Br-vo) in cm³ and our register
number".)

## What TABLE 2 gives

Per row: abbreviation, Latin name, common name, brain volume (Br-vo, cm³) and register number. Rows
whose common name ends ", mean" are means over several specimens (15 of 42); the rest are single
brains. Haug's TABLE 3 (not built) gives the number of brains for only 9 species. **No brain mass is
printed.** Other compilations (Boddy 2012, DeCasien 2017) convert these volumes to mass at ×1.036.

## Units

Br-vo is printed in cm³; the project unit is mm³, so `Brain_Vol.mm3 = printed × 1000` (human 1,300 → 1,300,000;
mouse 0.3 → 300). Thousands separators ("1,345") are stripped only when well-formed.

## Frozen source and fidelity

The PDF is a scan with an OCR text layer that is **not trustworthy** for characters. The extract script
assembles rows from word coordinates and repairs 9 cells where the layer disagrees with the page
(`OCR_FIXES` in the script): abbreviations of rows 8, 10, 11, 16, 20 (`us`, `cc`, `cc`, `0s`, `oc` →
US, CC, CC, OS, OC), Latin names of rows 9 and 13 (`Eeo`, `lator` → *leo*, *lotor*), the common name of
row 41 (`ouossum` → opossum) and the register number of row 33 ("22"+"1" → 221). **All 42 rows × 6 columns
were then compared with an independent reading of a render of the page: 0 mismatches.** The numbers
in the text layer were otherwise clean.

Printed spellings are kept verbatim, including *Globicephala macrorryncha*, *Papio duguera*,
*Cercopithecus aetiops*, *Saimiri sciurius*, *Aotes trivirigatus*, *Talpa europaeus*, and the genus-only
rows *Sorex*, *Wallabia*, *Tachyglossus* and *Lemur div.* The abbreviation `CC` is printed for both dog and coyote.

## Species names

37 of 42 printed names are staged in `PROPOSED_species_key_rows.csv` (token `Haug__1987`, collection `General`);
**nothing is merged into `_keys/`**. Until it is, the `.R` reads the staged file and warns. Grounds are in each row's `note`:
24 are already-accepted binomials (`verbatim`); 5 reuse mappings already in `_keys/` (*Phocaena phocaena*, *Canis familiaris*,
*Felis domestica*, *Cercopithecus talapoin*, *Lagothrix lagotricha*); the others follow how Boddy 2012 / DeCasien 2017 mapped the same
Haug row (e.g. *Papio duguera* → *Papio anubis*, *Ateles ater* → *Ateles paniscus*, *Lemur ruficaudatus* → *Lepilemur ruficaudatus*) or are obvious
spelling fixes.

**Not resolved (printed name passes through):** *Delphinus delphinus* (not in `species_reference.csv`), *Lemur div.* (a mixed-species row),
*Sorex*, *Wallabia* and *Tachyglossus* (genus only). Curator decision needed.

> **Ambiguous — *Cercopithecus aetiops* / "Vervet monkey".** Boddy 2012 and DeCasien 2017 map this row to *Chlorocebus aethiops*
> and I staged the same (`basis = hypothesis`). In modern usage "vervet" is *C. pygerythrus*, and 1987-era *C. aethiops* was sensu lato, so the species cannot
> be resolved below that from what is printed. Brain volume 64 cm³. This is the Haug 1987 row that Boddy 2012 / DeCasien 2017 carry as a **0 g brain mass**
> (volume blank): an extraction error in those compilations, not Haug's value.

## Measurement basis — read before pooling

Haug does not state a single basis for every row of Br-vo. The Methods say the specimens were "fixed at different places in the world" so the
"shrinkage of the single specimen is not reliably determined", and that the cortex measurements are "corrected for embedding shrinkage" and "represent values
for fresh material" (these refer to histological measurements, not explicitly to Br-vo). Treat Br-vo as a volume of unstated fixation state;
it is not a validated fresh-brain volume. Do not convert to mass inside this item.

## Table checks

The table carries no sums or percentages, so there is no arithmetic relation to test (§7a). Structural checks in the `.R`: 42 rows, row numbers 1–42, every Br-vo parses (0 flagged).
Run result: **42 rows, 0 flagged, 5 species names unresolved** (R run 2026-10-26).

## Data role

**`primary`**: the volumes are Haug's own measurements (he and Elias collected the material). They have not been merged. A merge into
`__merging_volumes` needs the source-admission gate and a decision on basis and the species-level `mean` rows.

## Fidelity notes

- Row order and the printed footnote marker are kept in the snapshot. The caption's register-number footnote is the footnote under the table.
- The only OCR repairs are the 9 listed above, all in the extract script.
- Row 22 (*Ateles ater*) prints the abbreviation **`NA`**. It is text, not a missing value; the reformat keeps it, but default CSV readers (pandas, `read.csv`) turn it into NA, so read `Abbr_Haug1987` with missing-value parsing off. (An earlier build blanked it; fixed 2026-10-26 and re-checked: all 42 CSV rows match the page reading.)
- Registry: the existing `Nudo_etal_1995_TABLE1` registry row carries `primary` while its README recommends `secondary`; flagged here as a pointer, not changed.
