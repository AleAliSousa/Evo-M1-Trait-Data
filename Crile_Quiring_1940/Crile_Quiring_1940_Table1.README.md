# Crile & Quiring 1940 — main table, all mammal sections (453 printed rows; 452 in the clean CSV)

Crile G, Quiring DP (1940). *A record of the body weight and certain organ and gland weights of 3690 animals.* Ohio J Sci 40(5):219-259.

## What the paper prints, and exactly what is covered
One long table (journal pp. 221-259; PDF pp. 3-41) of **per-lot records**: one row per species x sex x age/locality group, with number of animals, body weight (kg), and brain, thyroid, adrenal, heart, liver, eyes, kidney, lung, spleen and stomach+intestine weights. It is **not** a table of species means; the same species recurs on many rows.

**Built: every mammal section** — journal pp. 227-233 (Carnivores to Edentates), 238 (Insectivores, Marsupials), 239-243 (Primates, Anthropoids incl. the human groups), 245-259 (Rodents, Ungulates, Ungulates-Odd toed, Proboscidea and Hyracoidea). Data rows per printed section (snapshot): Carnivores 71, Pinnepedia 10, Cetacea 4, Chiroptera 1, Edentates 19, Insectivores 3, Marsupials 6, Primates 57, Anthropoids 49 (6 chimpanzee/gorilla + 43 human), Rodents 80, Ungulates 89, Ungulates—Odd toed 61, Proboscidea and Hyracoidea 3 = **453 data rows** (plus 2 printed caption rows kept in the snapshot, dropped from the CSV).
**Not built (non-mammals):** Invertebrates, Amphibia, Birds (pp. 221-227 top), Elasmobranch and Bony fishes (pp. 234-238 top), Reptiles (pp. 244-245 top): none are mammals.

## Source -> snapshot
`Crile_Quiring_1940.pdf` (EndNote 2198). The text layer holds names and headings but not the numbers, so `Crile_Quiring_1940_Table1_snapshot.csv` is a **constructed (transcribed) snapshot** from 2.0-2.2x renders: column and row order as printed, blanks (printed dot leaders) blank, dittos kept as curly quotes, brace-grouped catalogue numbers joined by commas. Layout conventions: the printed two-line name cell is one cell "Common name / Scientific name"; leading `Section` and trailing `Journal page` columns were added; the 2 caption rows ("Data from Journal of Agricultural Research ..." p. 251, "*Data furnished by the Bureau Animal Industry ..." p. 253) are kept as rows with only the text in the name cell.

## Fidelity checks (the paper prints no totals)
- No automated cross-check exists; checks are plausibility only: brain/body ratio, heart/body ratio and organ ordering were screened on all 452 rows. Nine rows outlie and the odd ones were re-read against the render; all match the print (flagged in `row_flag` where odd): Bear, American (adrenal 25.0 vs heart 6.0, body/brain blank), Cheetah (brain 2.449), cat. 153A genet (eyes 344), Brown lemming (kidney 44.04), Spotted hyena (lung 6809, stomach 6804).
- Column assignment of sparse rows was fixed by x-position against the header. **RA side-by-side check of all rows is still needed**; the highest-risk rows are the many with 3-6 blank cells.
- Total animals in the CSV = 2,842 mammals (of the paper's 3,690 animals incl. non-mammals).

## Duplicates and printed repeats (owner ruling applied)
- **Kept and flagged (identical in every value to an earlier row; owner ruling 2026-10-21: nothing is dropped, reduce downstream):** 1 row — snapshot row 148 (p. 240, *Spider, Black* 18 M&F, juvenile Panama) is identical to snapshot row 136 (p. 240, *Monkey, Night* 18 M&F). Recorded in `Crile_Quiring_1940_Table1_exact_duplicates.csv`; it stays in the snapshot.
- **Kept and flagged (repeat with small differences):** *Spider, Black* rows 149-150 repeat the *Monkey, Night* rows above (brain 108.8/118.4 vs 109/118); the cat. 93A row printed under *Vervet* (p. 241) repeats the *Cercopithecus mitis* 93A row (p. 239; body 1.225 vs 1.22, adrenal .220 vs .22). All three look like printer duplication of the same animals under a second name; the owner may wish to rule on which name is right.
- Near-coincidences that are NOT duplicates were left unflagged (e.g. woolly opossum / night monkey infants share several small integer values).

## Other caveats
- Units: only body weight is labelled (kg); organ weights assumed grams.
- Names as printed (*Aloutta*, *Macacus rhesus*, *Troglodytes niger*, *Silvilagus*, *Thomonys*, *Sabble-bred colts*, *Dear White-tailed*). `species` is blank where no scientific name is printed (human groups, breeds, several dog/cow/horse classes); those rows were **not** assigned a species here. Homo sapiens is implicit in the human groups (ANTHROPOIDS rows from cat. 1291).
- Domestic animals (cattle breeds, sheep, pigs, horses) are mixed in with wild species; rows from Lexington, Ky. and Bureau of Animal Industry are agricultural data (hog n carries an asterisk).
- Gorilla: AMNH partial dissection; thyroid "6 est." and adrenal "35 est."; Cape buffalo body "750 est." and brain "640 est." (`est_flag`).
- Humans: individual or small-group records with age/cause of death in Remarks; cat. 1318 occurs twice (two different men), as printed.
- Ages and `sex` "F-P" (undefined) as printed.

## Lewitus 2014 (ref 26)
Lewitus cites this paper for 3 values; the comparable quantities are **brain_g** and **body_weight_kg** (adult rows) in this item. Which lot Lewitus used is not stated.

## Build
`Crile_Quiring_1940_Table1.R` -> `..._Table1.csv` (453 rows) and `..._exact_duplicates.csv`. A "TSV skipped" warning is expected until the registry row is pasted into `__ReadMe.xlsx`. Registry row: `Crile_Quiring_1940_Table1_registry_row.xlsx`.

## Tables not built
- Non-mammal sections (invertebrates, amphibia, birds, fishes, reptiles): outside the owner's mammal scope.

## Source lead for the Panama primate rows (owner note 2026-10-21)
The *Spider, Black* (*Ateles dariensis* (Goldman)), *Howler, Black* (*Aloutta palliata inconsonans* (Goldman)) and *Monkey, Night* (*Aotus zonalis* (Goldman)) rows are all remarked "Panama". The paper's introduction credits Dr. Herbert Clark, Director of the Gorgas Memorial Laboratory, Panama, for part of the data, and the "(Goldman)" authorities are the Panama subspecies/species named by E. A. Goldman (his Panama mammal work, Smithsonian). So the repeated Spider/Night rows can be checked against the Gorgas Memorial Laboratory / Clark records or the Panama literature; the Crile table itself cannot say which of the two labels is right. Species names here are kept exactly as printed.

## Species assignment for rows with no printed scientific name (owner ruling 2026-10-21)
`species` is the printed name only (blank on 120 rows). New columns `species_assigned`, `species_assigned_basis`, `species_assigned_confidence`, `species_assigned_domestic` fill those blanks from `reference_tables/Crile_Quiring_1940_Table1_species_assignments.csv` (common name -> species): human groups -> *Homo sapiens*; dog breeds/types -> *Canis lupus familiaris*; cattle breeds/sex classes -> *Bos taurus*; "Calf" -> *Bos taurus* (medium confidence: Lexington, Ky. cattle-farm records); lambs -> *Ovis aries*; pigs -> *Sus scrofa domesticus*; horses, ponies and breeds -> *Equus caballus*; burros -> *Equus asinus*; "Dear White-tailed" (printed spelling) -> *Odocoileus virginianus*; "Leopard, Infant" -> *Panthera pardus*. **118 of 120 assigned; the 2 Mule rows are left unassigned (hybrid).** Domestic taxa carry `species_assigned_domestic = TRUE` so the domestication-pooling decision stays downstream. Rows that already print a scientific name are not touched. The paper states that its scientific names were checked by Arthur B. Fuller (Cleveland Museum of Natural History) but gives no source for the unnamed rows.
