# Kruska (1980) — table extraction report

Source file: `~/workspace/user/files/Kruska-1980-Domestikationsbeding.pdf`
Extraction date: 2026-11-18. Local files only; nothing committed.

## 1. Paper identity — VERIFIED

The PDF is the publisher's scan (Acrobat 5.0 Paper Capture) of:

> Kruska, D. (1980). Domestikationsbedingte Hirngrößenänderungen bei Säugetieren.
> *Zeitschrift für Zoologische Systematik und Evolutionsforschung* **18** (3): 161–195.
> DOI 10.1111/j.1439-0469.1980.tb00738.x

Evidence from the PDF itself:

- 35 PDF pages = journal pp. 161–195 exactly; running heads alternate
  "D. Kruska" / the article title, with printed page numbers 161–195.
- p. 161: "Aus dem Institut für Zoologie der Tierärztlichen Hochschule Hannover —
  Direktor: Prof. Dr. M. Röhrs", title as above, "Von D. Kruska",
  "Eingegangen am 15. Mai 1980"; footnote: the paper is Kruska's
  Habilitationsschrift, Tierärztliche Hochschule Hannover, 1979.
- p. 161 imprint line: "U.S. Copyright Clearance Center Code Statement:
  0044-3805/80/1803-0161/$2.50/0 — Z. Zool. Syst. Evolut.-forsch. 18 (1980)
  161–195 — © 1980 Verlag Paul Parey, Hamburg und Berlin" (ISSN 0044-3805).
- English summary on p. 190 under the title "Changes of brain size in mammals
  caused by domestication".
- Kruska's taxonomy for the camelids is as expected: guanaco = *Lama guanacoe*,
  alpaca = *Lama guanacoe* f. *pakos*, llama = *Lama guanacoe* f. *glama*
  (his argument, pp. 162–163: the guanaco is the sole stem species of llama and
  alpaca; the vicuña forms no breeding community with them).

## 2. How the camelid volumes were obtained (methods, pp. 172–176)

- Complete serial sections ("totale Schnittserien") of each brain; structures
  delimited on enlarged photographs of the sections (Abb. 8–10; section
  thickness 20 µm, cresyl-violet stain), cut out and weighed (planimetric
  paper-weighing method of Stephan 1960; Stephan et al. 1970; Kruska 1970b;
  Kruska & Stephan 1973).
- Formalin fixation + histological processing shrinks brains by 32–59%
  (Tabelle 1), so all section volumes are back-corrected to **fresh** volumes:
  for each brain a correction factor = fresh brain volume ÷ total section
  volume, where fresh brain volume = fresh brain weight ÷ specific gravity of
  brain substance **1.035**. Every part volume is multiplied by that brain's
  factor; equal shrinkage of all parts within a brain is assumed.
- The camelid sample for the serial-section work is 7 brains: 3 guanacos
  (G 14, G 10, G 24), 2 alpacas (A 9, A 7) and 2 llamas (L 6, L 7). Specimen
  codes are used as column heads throughout.
- "Reine Hirnsubstanz" (pure brain substance) is the reference volume for the
  relative-share tables (Tab. 3, 7, 12); the geometric-mean tables (Tab. 4, 8,
  13) express shares against total brain volume (Hirnvolumen).
- Summary statistics in Tab. 4/8/13 pool llama + alpaca (n = 4) against
  guanaco (n = 3); **no per-form (alpaca-only or llama-only) means are printed
  anywhere in the paper**.

## 3. Tables extracted (all 14 numbered tables + the in-text index lists)

All values were transcribed from the OCR text layer and then **verified cell
by cell against rendered page images** (150 dpi). Values in the CSVs are
verbatim as printed: German decimal commas and space thousands separators are
preserved (e.g. `241 313`, `250,0`, `-17,6`); no values were converted or
rounded. Signs in the "% difference" tables are as printed (+ = increase,
− = decrease). Dashes reproduced as `-` mean "not measured" in the original.

| File | Table | Journal p. | Content |
|---|---|---|---|
| `table01_fresh_brain_weights_shrinkage.csv` | Tab. 1 | 172 | Fresh brain weights (g) and % shrinkage from formalin fixation + histological processing, **per specimen**: 7 camelids, 17 pigs (wild, domestic, feral), 16 rats (wild, laboratory). 40 rows. |
| `table02_camelid_brain_part_volumes_per_specimen.csv` | Tab. 2 | 176 | **The primary camelid data.** Brain weight (g), total brain volume, pure brain substance, and absolute volumes (mm³) of medulla oblongata, cerebellum, mesencephalon, diencephalon, telencephalon, neocortex, corpus striatum, allocortex, neocortex grey and white — per specimen (G 14, G 10, G 24, A 9, A 7, L 6, L 7). Per-specimen values, not means. |
| `table03_camelid_large_parts_relative_shares_pct.csv` | Tab. 3 | 176 | Same structures as % of pure brain substance, per specimen. |
| `table04_camelid_large_parts_geometric_means.csv` | Tab. 4 | 177 | Geometric means, geometric variability coefficients, % shares of total brain volume, and % change wild→domestic; guanaco (n = 3) vs llama + alpaca pooled (n = 4). |
| `table05_percent_reductions_large_parts_by_species.csv` | Tab. 5 | 177 | % reductions of total brain size and large parts, wild→domestic, for Ratte, Schwein, Schaf, Lama/Alpaka, Frettchen, Pudel (compiled from Kruska's and others' earlier studies; wild form = 100%). |
| `table06_camelid_olfactory_absolute_volumes_mm3.csv` | Tab. 6 | 182 | Absolute volumes (mm³) of olfactory allocortex structures (bulbus olfactorius, regio retrobulbaris, regio praepiriformis, amygdala + centromedial/basolateral groups, tuberculum olfactorium, Basalkern), per specimen. |
| `table07_camelid_olfactory_relative_shares_pct.csv` | Tab. 7 | 182 | Same, as % of pure brain substance, per specimen. |
| `table08_camelid_olfactory_geometric_means.csv` | Tab. 8 | 182 | Geometric means etc., guanaco vs llama + alpaca. |
| `table09_olfactory_percent_differences_by_species.csv` | Tab. 9 | 183 | % size differences of olfactory structures, wild→domestic, for Ratte, Schwein, Schaf, Lama/Alpaka, Pudel. |
| `table10_optic_percent_differences_by_species.csv` | Tab. 10 | 184 | % size differences of optic structures (tractus opticus, corpus geniculatum laterale, area striata, colliculi superiores), wild→domestic, for Ratte, Schwein, Schaf only (no camelid optic measurements). |
| `table11_camelid_limbic_absolute_volumes_mm3.csv` | Tab. 11 | 186 | Absolute volumes (mm³) of limbic structures (septum, hippocampus, schizocortex), per specimen. |
| `table12_camelid_limbic_relative_shares_pct.csv` | Tab. 12 | 186 | Same, as % of pure brain substance, per specimen. |
| `table13_camelid_limbic_geometric_means.csv` | Tab. 13 | 186 | Geometric means etc., guanaco vs llama + alpaca. |
| `table14_limbic_percent_differences_by_species.csv` | Tab. 14 | 187 | % size differences of limbic structures, wild→domestic, for Ratte, Schwein, Schaf, Lama/Alpaka, Pudel (incl. rat-only substructures). |
| `intext_cerebralisation_indices_p171.csv` | in-text lists | 171 | Cerebralisationsindices (CI) of the wild ancestors and Abnahmewerte (AW, % brain-size decrease wild→domestic) printed as small lists in the running text: Rodentia (Rattus norvegicus 62 / −8%; Mus musculus 66 / ±0%; Cavia aperea 90 / −5 bis 7%), Artiodactyla (Sus scrofa 97 / −33,6%; Ovis ammon 117 / −23,9%; Lama guanacoe 127 / −17,6%), Carnivora (Mustela putorius 55 / −32,4%; Felis silvestris 104 / −23,9%; Canis lupus 119 / −34,0%). |

### The interspecific compiled dataset

There is **no printed interspecific data table** of brain and body weights.
The compiled cross-species material (brain weight vs body weight for the wild
ancestors and domestic forms across Rodentia, Lagomorpha, Perissodactyla,
Artiodactyla, Carnivora) is presented only as (i) allometric scatter figures
(e.g. Abb. 7 for the camelids: 24 guanaco and 17 llama/alpaca individuals),
(ii) the in-text CI/AW lists transcribed above, and (iii) narrative values in
the text (e.g. horses/zebras ≈ −16%; mink ≈ −5.0% or nil; cats −23.9%;
wolves→dogs −29% in Röhrs & Ebinger 1978, −34.0% after Schleifenbaum 1973,
the value Kruska adopts for his part-volume comparisons). The underlying
brain/body weight pairs are **not** in this paper; Kruska states (p. 189,
acknowledgements) that he was given brain and body weights from the Stephan
collection and other museum collections. The camelid allometry itself rests on
Herre & Thiede (1965), with Kruska's recalculation on slightly enlarged
material (common exponent a = 0.2507; brain-size decrease guanaco→domestic
tylopods = 17.6%).

## 4. The alpaca check (Castillo-Morales et al. 2016, their ref. [99])

Castillo-Morales et al. (2016), Table 1, print for *Vicugna pacos*:
brain volume **181.467 cm³**, neocortex volume **101.81 cm³**, citing
Kruska (1980).

**Result: both numbers are exactly reproducible from Kruska's Tabelle 2 —
they are the plain arithmetic means of the two alpaca specimens (A 9 and A 7),
converted from mm³ to cm³.** Kruska prints no alpaca mean himself (his summary
tables pool llama + alpaca), so the averaging was done by Castillo-Morales
et al. (or an intermediate source), but every digit checks out:

| Quantity | A 9 (Tab. 2) | A 7 (Tab. 2) | Mean | = cm³ | Castillo-Morales 2016 |
|---|---|---|---|---|---|
| Hirnvolumen (whole-brain volume) | 180 502 mm³ | 182 432 mm³ | 181 467 mm³ | **181.467 cm³** | 181.467 cm³ ✓ |
| Neocortex | 99 985 mm³ | 103 635 mm³ | 101 810 mm³ | **101.81 cm³** | 101.81 cm³ ✓ |

Supporting detail: the alpacas' fresh brain weights (Tab. 1/2) are 187 g (A 9)
and 189 g (A 7); the Tab. 2 volumes are the shrinkage-corrected fresh volumes
described in §2, not weight ÷ 1.035 (187/1.035 = 180.68 cm³ ≠ 180.502 cm³),
so the Castillo-Morales values rest specifically on the Tab. 2 corrected
volumes. Their derived Nr also follows: 101.81 / (181.467 − 101.81) = 1.278 ≈
the printed 1.28.

## 5. Transcription uncertainties and internal inconsistencies

After image verification, **no cell in any table remained unreadable** — the
scan is clean and every digit could be confirmed. Three things to note:

1. **Original misprint (digit transposition) in Tabelle 2:** specimen A 7,
   Allocortex is printed as **14 386** mm³ in Tab. 2, but as **14 368** mm³ in
   both Tab. 6 and Tab. 11. Tab. 3 settles it: A 7's printed allocortex share
   is 8,22%, and 14 368 / 174 751 = 8.22% whereas 14 386 would give 8.23%.
   The CSVs reproduce each table as printed (Tab. 2 = 14 386; Tabs. 6/11 =
   14 368); the consistent value is 14 368.
2. **Joint (braced) cells:** Tab. 5, Frettchen column — a single value 30,9
   covers Corpus striatum and Allocortex together. Tab. 9, Pudel column — a
   single value −19,3 covers Regio retrobulbaris through Basalkern. Both are
   flagged in a `note` column in the CSVs; the joint value is entered on the
   first row of the brace only.
3. **Rounding-level internal sums:** Tab. 2 part volumes sum to the printed
   "Reine Hirnsubstanz" within 1 mm³ (e.g. G 14: parts sum 233 484 vs printed
   233 485; neocortex grey + white = 143 592 vs printed neocortex 143 593) —
   ordinary rounding in the original, values transcribed as printed.

Also note for the folder build: Tab. 4/8/13 col. 7 changes and Tab. 5/9/10/14
are **compiled/derived comparative values** (several rest on other authors'
data — Schumacher 1963 for polecat/ferret, Schleifenbaum 1973 for wolf/poodle,
Ebinger 1974/1975 for sheep), whereas Tabs. 1, 2, 3, 6, 7, 11, 12 are Kruska's
own per-specimen primary data for the camelids (Tabs. 1 also pigs and rats).
