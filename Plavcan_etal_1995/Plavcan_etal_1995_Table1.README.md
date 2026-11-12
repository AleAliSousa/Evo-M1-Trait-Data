# Plavcan et al. 1995: Table 1, behavioural classifications and residual maxillary canine crown height (94 primate species × 2 sexes)

Plavcan, J. M., van Schaik, C. P., & Kappeler, P. M. (1995). Competition, coalitions and canine size in primates. *Journal of Human Evolution*, 28(3), 245–276. https://doi.org/10.1006/jhev.1995.1019

**Registry:** no row yet. The local copy of the live registry (2026-11-10) has only the two Plavcan & van Schaik 1997 rows (746–747). The row to paste is `out/registry_rows_plavcan1995.json`:
- Item name **`Plavcan_etal_1995_Table1`**, Item number **`Table 1`**.
- Item encoded **`10.1006%2Fjhev.1995.1019_Table1`**, from the registry's I/K formulas.

The R script looks up the Item encoded in `__ReadMe.xlsx` by Item name. Paste the row first. Without it, the script warns and does not write the public TSV.

## What the item is
Table 1 is captioned "Behavioral classifications and residual maxillary canine crown height". It runs over four printed pages, all printed sideways: Table 1 on p. 252, then three pages headed "Table 1 Continued" on pp. 253–255 (PDF pages 8–11). It lists 94 non-human primate species under three printed group headings: 49 catarrhines, 17 platyrrhines and 28 prosimians. "Dental metric data were gathered for 94 species" (p. 249).

Each species row prints:
- **Males** and **Females** blocks. Each block has C = coalitions (Yes/No), I = intensity (High/Low) and F = frequency (High/Low). A dash means the sex was not classified. This applies to the females of 18 species and to the males of *Simias concolor*.
- **Residuals** for Males and Females. Footnote a describes them as "from an isometric line passed through a data set treating male and female values as separate points".
- **References**: the author–year keys of the classification sources.

The table has four footnotes:
- a: the residual method.
- b: "C is coalitions, I is intensity, and F is frequency".
- c: on *Colobus badius*. Its male coalitions are "tentative".
- d: on *Pan troglodytes*, *Ateles geoffroyi*, *A. paniscus* and *Brachyteles arachnoides*. Their male coalitions are "for between-group behavior. Within-group behavior is low-intensity, high-frequency".

**No competition "level" or class column is printed.** The paper's Table 2 (p. 259) and Figure 3 (p. 264) group each sex into five classes: C HI HF, LI LF, LI HF, HI LF and HI HF. The build derives this grouping as `figure3_class`.

Definitions of the categories, from the Methods:
- **Intensity (p. 247).** "High-intensity contest competition is recognized when adults are either intolerant of one another, or when stable dominance hierarchies are maintained through agonistic interactions". Low intensity means "relatively tolerant … normally peaceful relations, or … escalated aggression is rare and dominance hierarchies, if present at all, are reported as difficult to detect".
- **Frequency (p. 248).** High means "two or more adults of the same sex regularly occur together in breeding groups". Low means solitary, or "only one adult of a single sex typically occurs in a breeding group". Species with reported multimale influxes are tentatively classed Low.
- **Coalitions (pp. 248–249).** Each sex of each species was classed "coalitionary or non-coalitionary … depending on whether competition typically occurs between alliances of related individuals or not". Coalitions count only "when escalated competition is primarily coalitionary". Among males, only the "male-bonded" *Pan troglodytes*, *Ateles* and *Brachyteles* are coalitionary, plus *Colobus badius* tentatively. These are classed as high-intensity, high-frequency.
- **Classification procedure (pp. 250–251).** The classes come from literature reports on wild populations. J.M.P. and C.P.vS. classified the anthropoids "without prior knowledge of the canine data", and P.M.K. classified the prosimians. Both within- and between-group behaviour were considered, and the classes were made "as conservative as possible".
- **Residuals (pp. 249–250, Figure 1).** The measure is maxillary canine crown height, from the cementum–enamel junction to the apex. The authors measured it on museum specimens (Plavcan 1990; Kappeler 1992). The residual is taken from an isometric line (slope 0·333) of ln canine height on ln body weight, passed through both sexes as separate points. Body weights come from Plavcan & van Schaik (1992) for anthropoids and Kappeler (1992) for prosimians. Raw crown heights and body weights are not printed.

## Frozen source and reader
- **Source:** `Plavcan_1995_article.pdf`, kept in the owner's source folder and not copied here.
  - 32 pages: a 200-dpi CCITT scan with no text layer.
  - Encrypted, with print and copy allowed.
  - sha256 `0620f2fb052b85ddb81fa31aaab4fb680cc117f055d1a8f97f7a6d50c1625707`.
- **Constructed snapshot:** `Plavcan_etal_1995_Table1_snapshot.csv`, a hand transcription frozen on 2026-11-10.
  - sha256 `c6d30d5c26ec30c0b62bb54b04c2c85d82961301432a5b52b445eb78e5437332`.
  - `Plavcan_etal_1995_Table1_snapshot.R` writes it from the verbatim printed-layout block inside the script.
  - The script refuses to overwrite a frozen copy that differs.
- **Snapshot layout:** one row per printed line, in printed order. 116 lines × 10 columns, UTF-8 with a BOM, no header line. Per page: lines 1–30 are p. 252, 31–54 are p. 253, 55–83 are p. 254 and 84–116 are p. 255.
  - Every page keeps its caption, the spanning header (Males / Females / Residualsᵃ) and the column header (Species, Cᵇ, I, F, C, I, F, Males, Females, References).
  - It holds the 6 group headings, the 94 species rows and the 4 footnotes.
  - Printed spellings and printed typos are kept.
  - The raised decimal point '·' and the minus '−' are kept, and dashes are written '—'.
  - Superscripts are written as Unicode modifier letters (ᵃ ᵇ ᶜ ᵈ).
  - Italics are dropped. A reference cell that wraps over two printed lines is joined with a space.
- **Reader:** AI assistant (Copilot) transcribed by eye from 300-dpi renders of PDF pages 8–11 on 2026-11-10; owner OCR export used as a second reading (797 cells agree, 153 disagreements resolved by re-reading the image).
  - **Second reading.** The second reading is `Plavcan_1995_user_ocr_export.xlsx` (sha256 `309059d7…a8896ea6`), sheets 'Table 2'–'Table 5'. It is an OCR export, not a journal file, and the build never reads it.
  - **Cells compared.** 950 cells were compared: the 940 cells of the 94 species rows, the 6 group headings and the 4 footnotes. Captions and column headers were checked by eye only.
  - **Disagreements.** 153 cells disagree. In 126 the OCR reads differently, e.g. 'Alacaca mulatta', 'Ga/ago', 'l,ow', 'Stammbach (l 987)'. In the other 27 the cell is missing from the export, mostly female dashes. Each one was re-read on the 300-dpi render, cropped within its printed row. In all 153 the printed value equals the snapshot value: **0 transcription changes**.
  - **Agreement by column:** species names 42/94, references 64/94, C/I/F 506/564, residuals 178/188, group headings 6/6, footnotes 1/4. Details are in `Plavcan_etal_1995_Table1_ocr_crosscheck.csv`.
  - **Checks during transcription.**
    - Species per page: 26 + 20 + 23 + 25 = 94.
    - All 187 printed residuals were re-read at 1.6–2× zoom.
    - The key "Wolfheim (1977)" was compared glyph by glyph (f vs t) at 6–8×.
    - All 122 cited works were found in the reference list on pp. 271–276, rendered at 300 dpi.
- **Human visual check requested.** The registry says 'Pending human RA'. Please compare the snapshot with the PDF row by row. Check the residual signs and decimals and the C/I/F cells of mid-table rows in particular, and these rows:
  - the dashes on the *Simias concolor* row (line 60)
  - the 18 female-dash rows
  - the italic *Macaca nigra* row (line 37)
  - *Miopithecus talapoin* / Wolfheim (1977) (line 40)
  - the footnote marks c and d

## Observation level
**species × sex: 188 rows = 94 species × 2.** The authors "classified each sex of each species" (p. 248), and each sex has its own residual, so the sexes stay on separate rows. Never average the two sexes.

Both sexes' residuals are taken from one isometric line, so the male and female rows of a species are directly comparable. Male minus female residual is the dimorphism used in Figure 3.

## Build
`Plavcan_etal_1995_Table1.R` is self-locating: run it as `Rscript Plavcan_etal_1995/Plavcan_etal_1995_Table1.R`, or Source it in RStudio. The steps:
1. **Read and verify the snapshot.** Read the frozen snapshot by position, all as character. Check its 116 × 10 shape and the four printed column headers.
2. **Type each line** as caption, header, group heading, footnote or species row (4 / 8 / 6 / 4 / 94). Carry the page (252 + one per caption) and the group heading down.
3. **Split the footnote mark (c, d)** from the species name. `species_as_published` keeps the printed name.
4. **Parse the cells.**
   - C must be Yes/No and I/F must be High/Low, or '—', which becomes NA. Any other entry stops the script.
   - Residuals: '·' becomes '.', '−' becomes '-', and '—' becomes NA. An unparsed residual stops the script.
   - `residual_as_printed` keeps the printed string.
5. **Accepted names.** `Species` comes from `_keys/General/species_key.csv` rows with `source_publication = Plavcan_etal_1995`. The script stops if a printed name has no key row.
6. **Reshape to species × sex**, with the male row before the female row. The derived columns:
   - `classified`: C, I and F all printed.
   - `figure3_class`: C HI HF when C = Yes, otherwise HI/LI + HF/LF.
   - `classification_note`: the text of footnote c or d, on the male row.
   - The constants `observation_level`, `source_locator` and `data_role`.
7. **`table_checks`** (section 4) are kept in the R object and never written to the CSV or TSV.
8. **Write the outputs.**
   - `Plavcan_etal_1995_Table1.csv`: 188 rows × 20 columns, UTF-8 with a BOM.
   - The public TSV `__Public/comparative-data/<Item encoded>.tsv`, with the Item encoded looked up in `__ReadMe.xlsx`.
   - It then runs `validate_dataset_item()` if the loader exists.

Columns: `table_order, printed_page, snapshot_row, group, species_as_published, Species, species_footnote, sex, coalitions, intensity, frequency, classified, figure3_class, residual_canine_crown_height, residual_as_printed, classification_note, references, observation_level, source_locator, data_role`.

Reference tables:
- `reference_tables/Plavcan_etal_1995_Table1_definitions.csv`: the 20 columns plus 6 `Method:` rows.
- `reference_tables/Plavcan_etal_1995_Table1_references.csv`: 124 rows, one per printed key × cited work. It covers 116 distinct printed keys and 122 works. Compound keys such as "Chalmers (1968a,b)" and "Cords (1987, 1988)" get one row per work.
  - `citation` is the verbatim reference-list entry. Italics are dropped, page-range dashes are typed as en dashes, and apostrophes and quotes are typographic.
  - To join: split `references` on "; " and join on `ref_key`. All 116 keys resolve.

**R NOT RUN - run Rscript Plavcan_etal_1995_Table1_snapshot.R then Plavcan_etal_1995_Table1.R.** This sandbox has no R. Python mirrors wrote the snapshot, the CSV and the TSV with the same logic and R's `write.csv`/`write.table` formatting:
- `mirror/Plavcan_etal_1995_Table1_extract_snapshot_mirror.py`, which parses the R script's own block.
- `mirror/Plavcan_etal_1995_Table1_mirror.py`.

The extract script should find the frozen copy identical and leave it alone, and the build should reproduce the CSV byte for byte. The mirror wrote the TSV locally as `out/__Public_local/10.1006__jhev.1995.1019_Table1.tsv`; its upload name is `10.1006%2Fjhev.1995.1019_Table1.tsv`.

## Table checks
Script section 4 runs 36 checks: 31 pass and 5 do not. Values are kept as printed.
- **Species count (1):** 94 species rows, matching "94 species" (p. 249). Pass.
- **Table 2 sample sizes (4; p. 259):** counts of species with a residual for each effect.
  - Pass: females coalitions 23, females intensity 64, males coalitions 33.
  - **Mismatch:** males intensity gives 88; Table 2 prints 87. The paper does not say which species was left out.
- **"68 species" (1; p. 259, also the Figure 3 total):** 75 species have both sexes classified and both residuals. **Mismatch** (+7), located in the Figure 3 cells below.
- **Figure 3 (26; p. 264):** 25 cells, female class × male class, against the printed N, plus "Eleven of these cells are empty" (p. 263, pass). 22 cells match. Three do not:
  - **Cell E** (females C HI HF × males HI HF): Table 1 gives 11 species; Figure 3 prints N = 4. The mean dimorphism (male − female) of the 11 is 0.637, against the printed .639 (s about .20 vs .208). The printed N is therefore probably a misprint.
  - **Cell M** (females LI HF × males LI HF): 2 species (*Pan paniscus*, *Propithecus diadema*); Figure 3 prints 3. The printed N, mean (.071) and s (.187) are reproduced exactly if *Propithecus verreauxi* males count as LI HF. Table 1 prints them High/High.
  - **Cell Y** (females HI HF × males HI HF): 6 species; Figure 3 prints 5. The printed N, mean (.161) and s (.113) are reproduced exactly without *Papio hamadryas*.
  - Other differences, observations only: cell O's mean (.533) comes closest (.530) with *P. hamadryas* in place of *P. verreauxi*. The G and S means differ by .003 and .006 even though N agrees. Figure 3 may use a different residual set: the authors ran their analyses on both empirical-regression and isometric residuals (p. 250).
- **Male coalitions (2; p. 249):** male C = Yes for exactly the species named in the text (*Pan troglodytes*, *Ateles geoffroyi*, *A. paniscus*, *Brachyteles arachnoides*, and tentatively *Colobus badius*). These are exactly the rows marked c or d. Pass.
- **Coalitionary = High/High (2):** males 5/5 (stated, p. 249) and females 12/12 (implied, p. 248). Pass.

## Data role: both
- **Secondary:** the C/I/F classifications. The authors compiled them from the field literature named in `references`.
- **Primary:** the residuals. They derive from the authors' own museum measurements (Plavcan 1990; Kappeler 1992), expressed as a relative size index (ln units) against an isometric line. They are not raw canine heights, and the body weights behind them are secondary.

Merge only the residual columns as primary, and never pool them with raw crown heights.

## Species names
`species_as_published` keeps the printed name, and `Species` is the accepted name. There are 94 new key rows in `out/_keys_General_new_rows_Plavcan_etal_1995.csv` (collection General):
- **72 verbatim.**
- **14 synonym:NCBI**, e.g.:
  - *Cercocebus albigena* → *Lophocebus albigena*
  - *Cercopithecus aethiops* → *Chlorocebus aethiops*
  - *Colobus badius* → *Piliocolobus badius*
  - *Colobus verus* → *Procolobus verus*
  - *Hylobates syndactylus* → *Symphalangus syndactylus*
  - *Hylobates hoolock* → *Hoolock hoolock*
  - *Presbytis cristata* / *obscura* / *entellus* → *Trachypithecus* / *Semnopithecus*
  - *Cebus apella* → *Sapajus apella*
  - *Galagoides alleni* → *Galago alleni*
  - *Galagoides demidovii* → *G. demidoff*
  - *Galagoides zanzibaricus* → *Paragalago zanzibaricus*
- **3 synonym:literature:**
  - *Presbytis pileata* → *Trachypithecus pileatus* (Catalogue of Life via GBIF)
  - *Presbytis vetulus* → *Trachypithecus vetulus* (medium confidence)
  - *Galago elegantulus* → *Euoticus elegantulus*
- **5 spelling:** *Cercopithecus nicitans*, *Colobus satanus* and *Alouatta paliatta* (printed typos), and *Hylobates klossi* and *Saimiri oerstedi* (period spellings).
- **Needs a hub row:** *Simias concolor* (NCBI 170207) is not in the species reference hub. Add a hub row before merging.
- **Sensu lato in 1995:** nine taxa had a broader meaning then; the key notes record each one:
  - *Hylobates concolor* (now several *Nomascus*)
  - *Macaca nemestrina* (incl. *M. leonina*)
  - *Pongo pygmaeus* (incl. *P. abelii*)
  - *Cebus apella*, *Presbytis entellus*, *Aotus trivirgatus*, *Cercopithecus aethiops*, *Cercocebus torquatus* (incl. *C. atys*), *Colobus badius* (Kibale red colobus)
- 16 NCBI/taxonomy web lookups were made on 2026-11-10.

## Relation to Püschel et al. 2026 S1 Data `cl`
Püschel et al. 2026 cite this paper for `cl` (intra-sexual competition level, 1–4) for 40 of their 41 species; *Homo* cites Plavcan & van Schaik 1997. **Table 1 prints no 1–4 level.** It prints C/I/F per sex, so `cl` is derived, not transcribed.

16 of the 40 species match a Table 1 species by accepted name. For these, `cl` follows the male classification:
- **cl 4 = male HI HF** (8 of 8): *Cercocebus torquatus*, *Macaca fascicularis*, *M. mulatta*, *M. nemestrina*, *Papio hamadryas*, *Sapajus apella*, *Semnopithecus entellus*, *Theropithecus gelada*.
- **cl 3 = male HI LF:** *Cercopithecus neglectus*, *Gorilla gorilla*, *Saimiri sciureus*.
- **cl 2 = male LI HF** (*Pan paniscus*) **or male coalitionary** (*Ateles geoffroyi*, *Pan troglodytes*; their within-group male competition is LI HF, footnote d).
- **cl 1** = *Hylobates lar* and *Symphalangus syndactylus*. Table 1 classes their males HI LF, like the cl 3 species. So cl 1 encodes something Table 1 does not print, probably pair-living.
  - This fits the four competition levels of Plavcan & van Schaik (1992, 1997), but that is an inference. Check it against Plavcan_vanSchaik_1997 (registry rows 746–747).

The other 24 species have no Table 1 row, so Table 1 cannot confirm their `cl`:
- They are *Hylobates moloch*, *Nomascus gabriellae*/*leucogenys*/*siki*, *Pithecia pithecia*, *Ateles fusciceps*/*hybridus*, three *Leontopithecus*, *Cercopithecus diana*, *Pongo* sp., *Pygathrix cinerea*, *Rhinopithecus roxellana*, *Trachypithecus auratus*/*hatinhensis*, *Macaca leonina*/*silenus*/*sylvanus*/*tonkeana*, *Mandrillus sphinx*, *Papio anubis* and *Sapajus flavius*/*xanthosternos*.
- Pitheciines were explicitly excluded from this study (p. 256), yet *Pithecia pithecia* has `cl` 1.

A cell-by-cell comparison belongs in `Evo-M1-Trait-Data-restricted/restricted_checks/Püschel_etal_2026/comparison` (SKILL.md: no comparison folder in the public repo). It was not done here.

## Printed-data observations (reported, not corrected)
- **Four printed pages,** not the "three sheets" in the owner's Build proposal. In the owner's OCR export, Table 1 is in sheets 'Table 2'–'Table 5'. Sheet 'Table 1' is the first page of the article, and 'Table 6' is the paper's Table 2, where "5·668" appears.
- **The *Macaca nigra* row** is printed entirely in italics; other rows italicise only the species name. Italics are not recorded.
- **Printed typos kept:**
  - Species: *Cercopithecus nicitans*, *Colobus satanus*, *Alouatta paliatta*.
  - Reference keys: Crocket, Peges-Feuillade, Wheatly.
- **Seven keys are spelled differently from their reference-list entries:** Bennet/Bennett, Blaffer Hrdy/Blaffer-Hrdy, Hernandez-Camacho/Hernandez-Comacho, Hladik/Hladick, Crocket/Crockett, McFarland Symington/Symmington, and Wolfe/Wolf. Each is noted in the references table.
- **Residuals:** 187 printed values, 91 of them negative, and 58 dash cells. Their sum is 1.355 (mean 0.007). This is not a check: residuals from an isometric line need not sum to zero.

## Not built
- The paper's Table 2 and later tables are analysis statistics.
- Figure 3 is a matrix of means. It was used here only for the table checks.
- The raw canine crown heights and body weights are not printed in this paper.
