# Hayssen_VanTienhoven_1993 — Asdell's Patterns of Mammalian Reproduction

Hayssen, V., van Tienhoven, A., & van Tienhoven, A. (1993). *Asdell's Patterns of Mammalian Reproduction:
A Compendium of Species-Specific Data.* Cornell University Press. (PDF used: the 2019 Cornell University Press
electronic reissue of the 1993 edition; 1,035 PDF pages; OCR text layer present.)

## Why this folder exists

Asdell's is the common root under the life-history compilations audited in
`Evo-M1-Trait-Data-restricted/other_checks/pantheria_refs_check`: PanTHERIA (Jones et al. 2009) cites it for
2,101 of 5,416 species (its second most-cited work, ref 1297), AnAge (de Magalhães et al. 2024) cites it on 1,035
species (BIBLIOID 00455), and of the 2,621 PanTHERIA cells that agree exactly with AnAge, 2,397 are on species
where both cite a common work — 969 species through this book. Unlike those compilations, **Asdell's cites per
value**: every data line in a species account ends with the number(s) of the reference(s) in its own Literature
Cited (printed pp. 705–990, ~12,000 numbered entries with letter suffixes). Transcribing it converts
compilation-level agreement into traceable provenance.

## Files

- `pdf_by_order/` — the book split into 23 PDF slices (front matter, one per order, Literature Cited,
  appendices + indexes), cut on the "Order …" heading page of each chapter. The whole-book PDF (56,083,653 bytes = 56.1 MB,
  SHA-256 `37a310449c8e6a48f317a9c6279baaa15a38eb156ab3732a905bad30bf6f594f`) is **not** stored in this repository; it stays in the
  OneDrive copy of this folder's owner. Every slice carries its own SHA-256 in the slice map.
- `Hayssen_VanTienhoven_1993_pdf_slices.csv` — slice map: file, section, TOC printed page, printed pages detected
  from page headers, PDF page range in the whole book, page count, size, SHA-256, first line of the slice.
- `Hayssen_VanTienhoven_1993_contents.csv` — the book's table of contents (order / family → printed page) with an
  estimated whole-book PDF page.

PDF page = printed page + 11 for most of the book; the offset is smaller in the first 60 pages because the scan
contains duplicate copies of several chapter-opening pages (PDF 16/17, 58/59, 64/65). Use the slice map, not a
constant offset, to locate a printed page.

## How the species accounts are organised (for the transcription)

Within each family the data are grouped under topic headings — NEONATAL MASS, LITTER SIZE, SEXUAL MATURITY,
CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY (and others) — and each line is
`<species or continuation> <value and qualifiers> <reference number(s)>`, e.g. printed p. 51
`Choloepus didactylus 423 d; r361-622; n14; yg dies 2940`, where `r` = range, `n` = sample size, `yg` = young,
and the trailing `2940` is the Literature Cited number. Abbreviations are defined on printed p. 5
(front-matter slice). Multi-value species continue on indented lines without repeating the name.

## Transcription plan (step 1 done — see "Reference table"; step 2 in progress per family — 27 families done (Suidae, Mustelidae, Canidae, Ursidae, Procyonidae, Viverridae, Herpestidae, Protelidae, Hyaenidae, Felidae, Otariidae, Odobenidae, Phocidae, Cheirogaleidae, Lemuridae, Indriidae, Daubentoniidae, Lorisidae, Galagidae, Tarsiidae, Callithricidae, Callimiconidae, Cebidae, Cercopithecidae, Hylobatidae, Pongidae, Hominidae), see "Species accounts (step 2)"; step 3 not yet started)

1. `Hayssen_VanTienhoven_1993_references.R` → `reference_tables/Hayssen_VanTienhoven_1993_references.csv`:
   one row per reference number from the Literature Cited slice (numbers with letter suffixes such as `3625a`
   are separate rows), parsed from the text layer with every unparsed line kept verbatim (convention C2).
2. Per-family long table `reference_tables/Hayssen_VanTienhoven_1993_accounts_<Family>.csv` (built by
   `Hayssen_VanTienhoven_1993_accounts.R`; families listed in its `FAMILIES` vector): species as printed, family, topic, value as
   printed, parsed numeric value/unit/range/n where the grammar allows, qualifiers verbatim, reference numbers,
   printed page, PDF slice + page. Start with the topics that map onto PanTHERIA's in-depth variables
   (neonatal mass, litter size, gestation, lactation/weaning, interlitter interval, sexual maturity) and the
   orders with Evo-M1 brain data (Primates, Chiroptera, Carnivora, Rodentia, Insectivora, Artiodactyla).
3. Register each per-order table in `__ReadMe.xlsx` as its own item (`build-dataset-item` conventions) and add
   the folder to the `pantheria_refs_check` source specs; the species-level `cited_by_pantheria_for_species`
   test then becomes a value-level test.

## Registry

Not yet in `__ReadMe.xlsx`; add a row for the paper when the first table is built.

## Reference table

Built by `Hayssen_VanTienhoven_1993_references.R` (Rscript, pdftools word boxes -> per-column lines -> sequence-constrained entry grammar) from `pdf_by_order/Hayssen_VanTienhoven_1993_21_LiteratureCited.pdf` (SHA-256 verified against the slice map; all 286 slice pages processed). Run date 2026-10-20.

### Counts (printed by the script)

- `reference_tables/Hayssen_VanTienhoven_1993_references.csv`: **12814 rows** = one per reference number; 12136 bare numbers (1..12139), 671 letter-suffixed inserts (e.g. 3625a), 7 subscript-suffixed inserts (printed 5424₁/5424₂/5405b₁, written `5424_1`/`5424_2`/`5405b_1`), 1 insert printed out of sequence and kept as printed (`1924a` between 1294 and 1295, printed p. 735; cited as 1924a in Insectivora).
- parse_status: parsed 11635, partial 1125, verbatim_only 54 (of which 15 are the book's own `not used` placeholders).
- Page check: headers parsed on 283 pages, declared on 3 (slice p. 1 title page; p. 73 printed page `777` OCR'd `Ill`; p. 279 header last `118*1` unreadable). Header-expected base numbers 12139; found 12136; **residual missing 3: 1744, 5418, 11166** — all three are absent from the printed book (page images of printed pp. 746, 832, 966 checked: 1743→1745, 5417→5419, 11165→11167). Zero entries outside their page's header range (asserted).
- OCR-damaged number tokens resolved: 18 (quoted verbatim in `number_note`): 10 by gap fill (e.g. `25%.`→2596, `115184.`→11984, `121 Albignac`→122), 7 subscript inserts, 1 damaged suffixed token(s) (`115>91a.`→11991a).
- `Hayssen_VanTienhoven_1993_references_unparsed.csv`: 0 rows (0 lines before the first entry; 0 numeric-start author-like lines folded into the preceding entry).
- `Hayssen_VanTienhoven_1993_core_journals.csv`: 169 Appendix 2 records (169 with an abbreviation); 6820 of 11635 parsed journal strings match a core abbreviation exactly.
- Coverage check (order slices 01–20, trailing right-aligned number runs + parenthesised lists in the familial prose): 48937 tokens, **10417 distinct numbers cited; 10388 have a row, 29 do not** (`Hayssen_VanTienhoven_1993_cited_numbers_not_in_bibliography.csv`; 3 of them cited ≥ 3 times). 10388 of 12814 reference rows are hit at least once. Appendix 1: 400 distinct numbers, 400 in the table, 0 not.

### Grammar

`<number><suffix>. <Authors>. <Year>. <Title>. <Journal>. <Volume>:<Pages>.` for articles; `<number>. <Authors>. <Year>. <Title>. <book, pages, editors, publisher, place>.` for books/chapters (→ `partial`); `<number>. not used` for reserved numbers (→ `verbatim_only`). Suffix = letter (inserted entry; can be printed before its base when alphabetical order requires: 781a precedes 781) or a printed subscript digit. Entry starts are accepted only when the number fits the sequence (bare: last bare + 1..40; letter: on the current base or opening a new base with `a`), so continuation lines beginning with a year (`1974. Observations …`) or a volume (`178.`) are never mistaken for entries; year-like tokens additionally need author-like text after them. A second pass fills single-number gaps with the one author-like line whose number token was OCR-damaged.

### OCR failure modes and handling

- Two-column pages: `pdf_text` interleaves the columns; the script uses `pdf_data` word boxes, finds the gutter per page (widest uncovered x-run in 200–450 pt) and reads each column separately.
- Running header: `<printed page> <first>.-<last>.`; dash dropped (`1236. 1276.`) or fused (`1598.1639b.`) handled by token extraction; three pages declared (see counts).
- Number tokens: digit→symbol (`25%.`, `50%.`), inserted characters (`587)8.`, `115184.`, `115>99.`), dropped period (`121 Albignac`), junk characters inside a suffixed number (`115>91a.`), a missing period (`11455a Ward`), subscript digits read as `,` or fused (`5424,.`, `54242.`, `5405b,.`, `3990,.` for 3900₁) — all resolved by sequence position and recorded in `number_note`. `1924a.` on printed p. 735 is NOT an OCR error: the book prints that number between 1294 and 1295 and cites it as 1924a; it is kept as printed and declared (`PRINTED_OUT_OF_SEQUENCE`).
- End-of-line hyphen rendered as `¬` (U+00AC): replaced by `-` and the next line joined without a space.
- Letter confusions inside citations (`.1 Mamm`, `Omithorhynchus`, `Fluszpferde`, `liber` for `über`, `Hire` for `Ihre`) are left verbatim in `citation`; `journal_or_publisher` is therefore as-OCR'd and the core-journal match rate above is a lower bound.
- Three printed gaps (1744, 5418, 11166) are the book's own; they are listed in the page-check file, not silenced.

### Coverage-check caveats

The 29 cited-but-absent tokens are of two kinds: (i) value tokens the trailing-number rule cannot distinguish from reference numbers (`10g`, `13d`, `5f` — a unit letter after a small number); (ii) suffixed numbers the species accounts cite but the bibliography never lists (4271b, 1127a, 11741a, 11957c). Kind (ii) is a finding about the book; it will be re-examined when the species accounts are transcribed. Columns beyond the specified set: `number_note`, `n_lines`, `column` (provenance of the number resolution and of the OCR block).


## Reference availability (`reference_tables/Hayssen_VanTienhoven_1993_references_availability.csv`)

The references table transcribes the book and never changes; whether we *have* a cited work is working
state and lives in this sidecar, one row per reference number checked, updated in place on re-check
(the same pattern as `REVIEW_QUEUE_resolutions.csv` in the refs_check pipelines and the per-paper errata
files). Columns are defined in `…_references_availability_definitions.csv`; the decision column is
`availability` (`available_endnote_pdf`, `available_evom1`, `available_online`, `in_endnote_review`,
`not_in_endnote`, `unavailable`, `not_needed`). First rows: the 57 works cited in the *Sus scrofa* and
*Mustela putorius* accounts, checked against the EndNote library — 1 present with a PDF (8220, Panepinto
et al. 1978), 56 absent; online routes not yet searched.

## Species accounts (step 2)

Built by `Hayssen_VanTienhoven_1993_accounts.R` (Rscript; `FAMILIES <- c("Suidae", "Mustelidae", "Canidae", "Ursidae", "Procyonidae", "Viverridae", "Herpestidae", "Protelidae", "Hyaenidae", "Felidae", "Otariidae", "Odobenidae", "Phocidae", "Cheirogaleidae", "Lemuridae", "Indriidae", "Daubentoniidae", "Lorisidae", "Galagidae", "Tarsiidae", "Callithricidae", "Callimiconidae", "Cebidae", "Cercopithecidae", "Hylobatidae", "Pongidae", "Hominidae")`), run date 2026-10-23. One row per printed data line (one value), each with its own Literature Cited number(s) joined to `reference_tables/Hayssen_VanTienhoven_1993_references.csv`, plus `family_overview` rows for the parenthesised reference lists in the family prose. Column definitions and the method rows (line grammar, family_overview, population_status rule, the book's own statements on domestic species) are in `reference_tables/Hayssen_VanTienhoven_1993_accounts_definitions.csv`; the book's abbreviation list (printed pp. 5–6) is `reference_tables/Hayssen_VanTienhoven_1993_abbreviations.csv` (144 rows).

### Families done

- **Suidae** (Artiodactyla; `Hayssen_VanTienhoven_1993_16_Artiodactyla.pdf`, slice pages 1–6, printed pp. 377–382): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Suidae.csv` **307 rows** = 297 data lines + 10 family_overview rows; parse_status parsed 295 / partial 2 / verbatim_only 0 (0.0%); 7 distinct printed species, 1 resolved through `_keys/resolve_species.R` (unresolved: Babyrousa babyrussa, Phacochoerus aethiopicus, Potamochoerus porcus, Hylochoerus meinertzhageni, Sus barbatus, Sus salvanius); population_status: captive_zoo 9, domestic_laboratory 37, feral 9, mixed:domestic_laboratory|wild 5, unspecified 92, wild 145. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY.
- **Mustelidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 32–56, printed pp. 260–284): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Mustelidae.csv` **1558 rows** = 1473 data lines + 85 family_overview rows; parse_status parsed 1404 / partial 61 / verbatim_only 8 (0.5%); 48 distinct printed species, 14 resolved through `_keys/resolve_species.R` (unresolved: Arctonyx collaris, Gulo gulo, Ictonyx striatus, Lutra canadensis, Martes americana, Martes zibellina, Mellivora capensis, Mustela eversmanni, Mustela frenata, Mustela lutreola, Poecilogale albinucha, Pteronura brasiliensis, Spilogale putorius, Spilogale pygmaea, Aonyx capensis, Conepatus leuconotus, Conepatus mesoleucus, Lutra felina, Lutra longicaudis, Lutra lutra, Lutra maculicollis, Lutra perspicillata, Martes flavigula, Melogale personata, Mephitis macroura, Mustela altaica, Mustela nudipes, Mustela sibirica, Poecilictis libyca, Vormela peregusna, Aonyx congica, Mustela mustela, Lutra provocax, Vormela spp); population_status: captive_zoo 107, domestic_laboratory 89, mixed:captive_zoo|wild 1, mixed:domestic_laboratory|wild 3, unspecified 781, wild 492. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY.
- **Canidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 1–19, printed pp. 229–247): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Canidae.csv` **1158 rows** = 1114 data lines + 44 family_overview rows; parse_status parsed 1072 / partial 34 / verbatim_only 8 (0.7%); 28 distinct printed species, 7 resolved through `_keys/resolve_species.R` (unresolved: Canis aureus, Canis mesomelas, Chrysocyon brachyurus, Cuon alpinus, Dusicyon thous, Nyctereutes procyonoides, Speothos venaticus, Urocyon cinereoargenteus, Vulpes bengalensis, Vulpes corsac, Vulpes velox, Canis spp "gray jackals", Canis adustus, Canis rufus, Dusicyon culpaeus, Dusicyon gymnocercus, Dusicyon vetulus, Vulpes chama, Vulpes ferrilata, Vulpes macrotis, Vulpes rueppelli); population_status: captive_zoo 54, domestic_laboratory 22, mixed:domestic_laboratory|wild 3, unspecified 565, wild 470. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Ursidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 19–27, printed pp. 247–255): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Ursidae.csv` **505 rows** = 491 data lines + 14 family_overview rows; parse_status parsed 461 / partial 28 / verbatim_only 2 (0.4%); 8 distinct printed species, 2 resolved through `_keys/resolve_species.R` (unresolved: Ailuropoda melanoleuca, Helarctos malayanus, Ursus americanus, Ursus thibetanus, Tremarctos ornatus, Melursus ursinus); population_status: captive_zoo 38, domestic_laboratory 9, mixed:captive_zoo|wild 1, unspecified 257, wild 186. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Procyonidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 27–32, printed pp. 255–260): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Procyonidae.csv` **290 rows** = 264 data lines + 26 family_overview rows; parse_status parsed 252 / partial 11 / verbatim_only 1 (0.4%); 9 distinct printed species, 6 resolved through `_keys/resolve_species.R` (unresolved: Bassaricyon spp, Bassariscus sumichrasti, Nasua spp); population_status: captive_zoo 14, domestic_laboratory 1, unspecified 153, wild 96. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, LITTERS/YEAR, SEASONALITY.
- **Viverridae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 57–60, printed pp. 285–288): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Viverridae.csv` **232 rows** = 221 data lines + 11 family_overview rows; parse_status parsed 211 / partial 10 / verbatim_only 0 (0.0%); 25 distinct printed species, 1 resolved through `_keys/resolve_species.R` (unresolved: Arctictis binturong, Civettictis civetta, Cryptoprocta ferox, Eupleres goudotii, Fossa fossa, Genetta spp, Genetta genetta, Hemigalus derbyanus, Paradoxurus hermaphroditus, Prionodon linsang, Arctogalidia trivirgata, Cynogale bennettii, Genetta felina, Genetta maculata, Genetta servalina, Nandinia binotata, Osbornictis piscivora, Paguma larvata, Paradoxurus zeylonensis, Poiana richardsoni, Prionodon pardicolor, Viverra tangalunga, Viverra zibetha, Viverricula indica); population_status: captive_zoo 14, unspecified 105, wild 102. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Herpestidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 61–65, printed pp. 289–293): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Herpestidae.csv` **274 rows** = 251 data lines + 23 family_overview rows; parse_status parsed 235 / partial 13 / verbatim_only 3 (1.2%); 22 distinct printed species, 5 resolved through `_keys/resolve_species.R` (unresolved: Atilax paludinosus, Galidia elegans, Herpestes auropunctatus, Mungotictis decemlineata, Crossarchus obscurus, Bdeogale crassicauda, Crossarchus alexandri, Galidictis fasciata, Herpestes edwardsi, Herpestes fuscus, Herpestes pulverulentus, Herpestes sanguineus, Herpestes vitticollis, Ichneumia albicauda, Paracynictis selousi, Rhynchogale melleri, Liberiictis kuhni); population_status: captive_zoo 16, feral 7, unspecified 138, wild 90. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY.
- **Protelidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 65–65, printed pp. 293–293): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Protelidae.csv` **24 rows** = 19 data lines + 5 family_overview rows; parse_status parsed 18 / partial 0 / verbatim_only 1 (5.3%); 1 distinct printed species, 0 resolved through `_keys/resolve_species.R` (unresolved: Proteles cristatus); population_status: unspecified 14, wild 5. Topics: LITTER SIZE, CYCLE LENGTH, GESTATION, LACTATION, SEASONALITY.
- **Hyaenidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 66–67, printed pp. 294–295): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Hyaenidae.csv` **113 rows** = 101 data lines + 12 family_overview rows; parse_status parsed 97 / partial 4 / verbatim_only 0 (0.0%); 3 distinct printed species, 2 resolved through `_keys/resolve_species.R` (unresolved: Hyaena brunnea); population_status: captive_zoo 5, unspecified 80, wild 16. Topics: NEONATAL MASS, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Felidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 68–84, printed pp. 296–312): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Felidae.csv` **1024 rows** = 1006 data lines + 18 family_overview rows; parse_status parsed 972 / partial 31 / verbatim_only 3 (0.3%); 30 distinct printed species, 9 resolved through `_keys/resolve_species.R` (unresolved: Acinonyx jubatus, Felis aurata, Felis bengalensis, Felis chaus, Felis geoffroyi, Felis manul, Felis margarita, Felis marmorata, Felis nigripes, Felis pardalis, Felis serval, Felis temmincki, Felis viverrina, Felis wiedii, Lynx caracal, Lynx rufus, Panthera uncia, Felis rubiginosa, Felis tigrina, Felis yagouaroundi, Lynx pardinus); population_status: captive_zoo 49, domestic_laboratory 16, feral 18, mixed:domestic_laboratory|wild 2, unspecified 562, wild 359. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY.
- **Otariidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 84–90, printed pp. 312–318): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Otariidae.csv` **357 rows** = 342 data lines + 15 family_overview rows; parse_status parsed 330 / partial 12 / verbatim_only 0 (0.0%); 14 distinct printed species, 5 resolved through `_keys/resolve_species.R` (unresolved: Arctocephalus australis, Arctocephalus forsteri, Arctocephalus galapagoensis, Arctocephalus gazella, Arctocephalus tropicalis, Neophoca cinerea, Phocarctos hookeri, Arctocephalus philippii, Arctocephalus townsendi); population_status: captive_zoo 4, domestic_laboratory 5, unspecified 284, wild 49. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Odobenidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 90–91, printed pp. 318–319): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Odobenidae.csv` **86 rows** = 80 data lines + 6 family_overview rows; parse_status parsed 77 / partial 3 / verbatim_only 0 (0.0%); 1 distinct printed species, 1 resolved through `_keys/resolve_species.R`; population_status: unspecified 63, wild 17. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Phocidae** (Carnivora; `Hayssen_VanTienhoven_1993_09_Carnivora.pdf`, slice pages 92–106, printed pp. 320–334): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Phocidae.csv` **923 rows** = 897 data lines + 26 family_overview rows; parse_status parsed 847 / partial 39 / verbatim_only 11 (1.2%); 20 distinct printed species, 5 resolved through `_keys/resolve_species.R` (unresolved: Cystophora cristata, Erignathus barbatus, Hydrurga leptonyx, Leptonychotes weddelli, Lobodon carcinophagus, Mirounga leonina, Monachus albiventer, Monachus monachus, Monachus schauinslandi, Ommatophoca rossi, Phoca fasciata, Phoca hispida, Phoca largha, Phoca sibirica, Monachus tropicalis); population_status: captive_zoo 4, domestic_laboratory 9, unspecified 740, wild 144. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Cheirogaleidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 1–3, printed pp. 174–176): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Cheirogaleidae.csv` **152 rows** = 142 data lines + 10 family_overview rows; parse_status parsed 140 / partial 2 / verbatim_only 0 (0.0%); 7 distinct printed species, 5 resolved through `_keys/resolve_species.R` (unresolved: Microcebus coquereli, Allocebus trichotis); population_status: captive_zoo 20, domestic_laboratory 9, unspecified 87, wild 26. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Lemuridae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 4–8, printed pp. 177–181): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Lemuridae.csv` **296 rows** = 284 data lines + 12 family_overview rows; parse_status parsed 274 / partial 10 / verbatim_only 0 (0.0%); 12 distinct printed species, 7 resolved through `_keys/resolve_species.R` (unresolved: Lemur coronatus, Lemur mongoz, Lemur macaco, Lemur rubriventer, Lemur rufipes); population_status: captive_zoo 35, domestic_laboratory 6, unspecified 192, wild 51. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, LITTERS/YEAR, SEASONALITY.
- **Indriidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 9–9, printed pp. 182–182): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Indriidae.csv` **52 rows** = 46 data lines + 6 family_overview rows; parse_status parsed 44 / partial 1 / verbatim_only 1 (2.2%); 5 distinct printed species, 3 resolved through `_keys/resolve_species.R` (unresolved: Lichanotus laniger, Propithecus spp); population_status: unspecified 36, wild 10. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, SEXUAL MATURITY, GESTATION, LACTATION, LITTERS/YEAR, SEASONALITY.
- **Daubentoniidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 10–10, printed pp. 183–183): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Daubentoniidae.csv` **12 rows** = 6 data lines + 6 family_overview rows; parse_status parsed 6 / partial 0 / verbatim_only 0 (0.0%); 1 distinct printed species, 1 resolved through `_keys/resolve_species.R`; population_status: unspecified 3, wild 3. Topics: LITTER SIZE, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Lorisidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 10–12, printed pp. 183–185): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Lorisidae.csv` **101 rows** = 90 data lines + 11 family_overview rows; parse_status parsed 85 / partial 5 / verbatim_only 0 (0.0%); 4 distinct printed species, 3 resolved through `_keys/resolve_species.R` (unresolved: Arctocebus calabarensis); population_status: captive_zoo 4, domestic_laboratory 4, unspecified 69, wild 13. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Galagidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 12–15, printed pp. 185–188): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Galagidae.csv` **217 rows** = 201 data lines + 16 family_overview rows; parse_status parsed 194 / partial 7 / verbatim_only 0 (0.0%); 7 distinct printed species, 4 resolved through `_keys/resolve_species.R` (unresolved: Galago zanzibaricus, Galago elegantulus, Galago inustus); population_status: captive_zoo 8, domestic_laboratory 4, unspecified 159, wild 30. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY.
- **Tarsiidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 15–16, printed pp. 188–189): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Tarsiidae.csv` **45 rows** = 37 data lines + 8 family_overview rows; parse_status parsed 34 / partial 3 / verbatim_only 0 (0.0%); 4 distinct printed species, 3 resolved through `_keys/resolve_species.R` (unresolved: Tarsius spp); population_status: captive_zoo 2, unspecified 28, wild 7. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Callithricidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 16–22, printed pp. 189–195): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Callithricidae.csv` **362 rows** = 345 data lines + 17 family_overview rows; parse_status parsed 338 / partial 6 / verbatim_only 1 (0.3%); 14 distinct printed species, 10 resolved through `_keys/resolve_species.R` (unresolved: Saguinus nigricollis, Callithrix spp, Saguinus spp, Callithrix humeralifer); population_status: captive_zoo 19, domestic_laboratory 50, mixed:domestic_laboratory|wild 2, unspecified 219, wild 55. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, SEASONALITY.
- **Callimiconidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 22–23, printed pp. 195–196): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Callimiconidae.csv` **46 rows** = 41 data lines + 5 family_overview rows; parse_status parsed 33 / partial 8 / verbatim_only 0 (0.0%); 1 distinct printed species, 1 resolved through `_keys/resolve_species.R`; population_status: captive_zoo 3, unspecified 25, wild 13. Topics: NEONATAL MASS, NEONATAL SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Cebidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 23–28, printed pp. 196–201): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Cebidae.csv` **306 rows** = 289 data lines + 17 family_overview rows; parse_status parsed 274 / partial 12 / verbatim_only 3 (1.0%); 31 distinct printed species, 20 resolved through `_keys/resolve_species.R` (unresolved: Cebus apella, C albifrons, Chiropotes albinasus, Chiropotes satanas, Lagothrix flavicauda, Cebus spp, Cebus griseus, Alouatta spp, Callicebus spp, Cacajao spp, Ateles belzebuth/A geoffroyi); population_status: captive_zoo 21, domestic_laboratory 40, unspecified 211, wild 17. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Cercopithecidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 29–48, printed pp. 202–221): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Cercopithecidae.csv` **1220 rows** = 1203 data lines + 17 family_overview rows; parse_status parsed 1144 / partial 42 / verbatim_only 17 (1.4%); 54 distinct printed species, 42 resolved through `_keys/resolve_species.R` (unresolved: Presbytis obscura, Presbytis senex, Cercopithecus cephus, Colobus abyssinicus, Papio sphinx, Presbytis aygula, Papio leucophaeus, Presbytis spp, Presbytis johnii/P senex, Papio spp, Cercopithecus spp, Nasalis concolor); population_status: captive_zoo 93, domestic_laboratory 163, unspecified 792, wild 155. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Hylobatidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 48–49, printed pp. 221–222): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Hylobatidae.csv` **58 rows** = 50 data lines + 8 family_overview rows; parse_status parsed 43 / partial 7 / verbatim_only 0 (0.0%); 6 distinct printed species, 4 resolved through `_keys/resolve_species.R` (unresolved: Hylobates hoolock, Hylobates spp); population_status: captive_zoo 2, domestic_laboratory 4, unspecified 38, wild 6. Topics: NEONATAL MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Pongidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 50–55, printed pp. 223–228): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Pongidae.csv` **320 rows** = 307 data lines + 13 family_overview rows; parse_status parsed 289 / partial 12 / verbatim_only 6 (2.0%); 4 distinct printed species, 4 resolved through `_keys/resolve_species.R`; population_status: captive_zoo 4, domestic_laboratory 14, unspecified 215, wild 74. Topics: NEONATAL MASS, NEONATAL SIZE, WEANING MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.
- **Hominidae** (Primates; `Hayssen_VanTienhoven_1993_08_Primates.pdf`, slice pages 55–55, printed pp. 228–228): `reference_tables/Hayssen_VanTienhoven_1993_accounts_Hominidae.csv` **23 rows** = 22 data lines + 1 family_overview rows; parse_status parsed 22 / partial 0 / verbatim_only 0 (0.0%); 1 distinct printed species, 1 resolved through `_keys/resolve_species.R`; population_status: domestic_laboratory 7, unspecified 15. Topics: NEONATAL MASS, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERBIRTH INTERVAL, SEASONALITY.

Per-family counts (27 families, 10061 rows, 9619 data lines):

| family | order | printed pp. | rows | data lines | overview rows | parsed | partial | verbatim_only | % verbatim | species | resolved | n topics | refs resolved | refs declared absent |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Suidae | Artiodactyla | 377–382 | 307 | 297 | 10 | 295 | 2 | 0 | 0.0 | 7 | 1 | 12 | 344 | 0 |
| Mustelidae | Carnivora | 260–284 | 1558 | 1473 | 85 | 1404 | 61 | 8 | 0.5 | 48 | 14 | 12 | 2032 | 0 |
| Canidae | Carnivora | 229–247 | 1158 | 1114 | 44 | 1072 | 34 | 8 | 0.7 | 28 | 7 | 11 | 1351 | 0 |
| Ursidae | Carnivora | 247–255 | 505 | 491 | 14 | 461 | 28 | 2 | 0.4 | 8 | 2 | 10 | 613 | 0 |
| Procyonidae | Carnivora | 255–260 | 290 | 264 | 26 | 252 | 11 | 1 | 0.4 | 9 | 6 | 11 | 342 | 6 |
| Viverridae | Carnivora | 285–288 | 232 | 221 | 11 | 211 | 10 | 0 | 0.0 | 25 | 1 | 10 | 303 | 0 |
| Herpestidae | Carnivora | 289–293 | 274 | 251 | 23 | 235 | 13 | 3 | 1.2 | 22 | 5 | 11 | 333 | 0 |
| Protelidae | Carnivora | 293–293 | 24 | 19 | 5 | 18 | 0 | 1 | 5.3 | 1 | 0 | 5 | 29 | 0 |
| Hyaenidae | Carnivora | 294–295 | 113 | 101 | 12 | 97 | 4 | 0 | 0.0 | 3 | 2 | 9 | 152 | 0 |
| Felidae | Carnivora | 296–312 | 1024 | 1006 | 18 | 972 | 31 | 3 | 0.3 | 30 | 9 | 11 | 1133 | 0 |
| Otariidae | Carnivora | 312–318 | 357 | 342 | 15 | 330 | 12 | 0 | 0.0 | 14 | 5 | 11 | 503 | 0 |
| Odobenidae | Carnivora | 318–319 | 86 | 80 | 6 | 77 | 3 | 0 | 0.0 | 1 | 1 | 9 | 104 | 0 |
| Phocidae | Carnivora | 320–334 | 923 | 897 | 26 | 847 | 39 | 11 | 1.2 | 20 | 5 | 11 | 1093 | 0 |
| Cheirogaleidae | Primates | 174–176 | 152 | 142 | 10 | 140 | 2 | 0 | 0.0 | 7 | 5 | 9 | 218 | 0 |
| Lemuridae | Primates | 177–181 | 296 | 284 | 12 | 274 | 10 | 0 | 0.0 | 12 | 7 | 9 | 357 | 0 |
| Indriidae | Primates | 182–182 | 52 | 46 | 6 | 44 | 1 | 1 | 2.2 | 5 | 3 | 8 | 73 | 0 |
| Daubentoniidae | Primates | 183–183 | 12 | 6 | 6 | 6 | 0 | 0 | 0.0 | 1 | 1 | 4 | 21 | 0 |
| Lorisidae | Primates | 183–185 | 101 | 90 | 11 | 85 | 5 | 0 | 0.0 | 4 | 3 | 9 | 145 | 0 |
| Galagidae | Primates | 185–188 | 217 | 201 | 16 | 194 | 7 | 0 | 0.0 | 7 | 4 | 11 | 300 | 0 |
| Tarsiidae | Primates | 188–189 | 45 | 37 | 8 | 34 | 3 | 0 | 0.0 | 4 | 3 | 8 | 63 | 0 |
| Callithricidae | Primates | 189–195 | 362 | 345 | 17 | 338 | 6 | 1 | 0.3 | 14 | 10 | 10 | 469 | 0 |
| Callimiconidae | Primates | 195–196 | 46 | 41 | 5 | 33 | 8 | 0 | 0.0 | 1 | 1 | 9 | 64 | 0 |
| Cebidae | Primates | 196–201 | 306 | 289 | 17 | 274 | 12 | 3 | 1.0 | 31 | 20 | 10 | 397 | 0 |
| Cercopithecidae | Primates | 202–221 | 1220 | 1203 | 17 | 1144 | 42 | 17 | 1.4 | 54 | 42 | 11 | 1387 | 3 |
| Hylobatidae | Primates | 221–222 | 58 | 50 | 8 | 43 | 7 | 0 | 0.0 | 6 | 4 | 8 | 74 | 0 |
| Pongidae | Primates | 223–228 | 320 | 307 | 13 | 289 | 12 | 6 | 2.0 | 4 | 4 | 10 | 418 | 0 |
| Hominidae | Primates | 228–228 | 23 | 22 | 1 | 22 | 0 | 0 | 0.0 | 1 | 1 | 8 | 24 | 0 |

Topic headings over all families (13): NEONATAL MASS, NEONATAL SIZE, WEANING MASS, WEANING SIZE, LITTER SIZE, SEXUAL MATURITY, CYCLE LENGTH, GESTATION, LACTATION, INTERLITTER INTERVAL, LITTERS/YEAR, SEASONALITY, INTERBIRTH INTERVAL. New since the Suidae/Mustelidae build: INTERBIRTH INTERVAL.

`reference_tables/Hayssen_VanTienhoven_1993_accounts_unparsed.csv`: 864 rows — outside_family_range:data 616, outside_family_range:heading 16, outside_family_range:prose 178, outside_family_range:topic 54.

### Grammar and page handling

Data line: `[species] <value>[; qualifier]* <ref>[, <ref>]*`; the species name is printed only on the first line of its run and inherited; a TOPIC heading in capitals resets the species. Pages are three columns (species / value / reference numbers) and the scan is slightly rotated, so one printed line's three columns differ by up to 6 pt (half a line) in the OCR y coordinate and `pdf_text` misplaces the numbers; the script rebuilds lines per column from `pdf_data` word boxes and aligns the columns with a per-page offset (reference column anchored on the first value/reference pair of the page; species column by the offset that maximises matches). Reference lists that wrap (`3571, 4643, 4645, 7979,` / `10499`) and values that wrap are joined. The family range is taken from the body headings `Order X, Family Y` (first page asserted to carry the family heading, every further page asserted to name the family in its running header); lines on shared pages that belong to the neighbouring family or to the order introduction are kept in the unparsed table as `outside_family_range`.

Value grammar: optional sex (`f:`, `m:`, `f/m:`) and measure label (`1st mate:`, `wean:`, `birth:`, `HB:`, ...), optional `~`/`est`/comparator, then `mode|max|min`, a number or range, a unit (g, kg, mg, d, wk, mo, yr, h, mm, cm, %) or count word (emb, yg, cl, lt, ps, ...); `;`-separated qualifiers parsed for `rA-B`, `n<k>`, `sd`, `se`, `±`, `mode`. OCR normalisation before parsing: `It`→`lt`, `nl`→`n1`, `rl`→`r1`, `l`→`1` after r/n/sd/se, `I`/`O`→`1`/`0` inside n-tokens; the verbatim OCR text is kept in `line_verbatim`/`value_text`.

### Population status rule

(1) Book qualifier on the line (`captive`/`zoo` → captive_zoo; `lab`/`domestic`/`farm`/`fur farm` → domestic_laboratory; `feral`; `wild`), basis `book_qualifier:<token>`. (2) Else the cited works' title/journal: `feral` → feral; wild keywords (wild, Wildschwein, Sanglier, jabalí, Schwarzwild, Iltis, polecat, Mammals of, J Mamm, J Wildl Manage, Mammalia, Z Saugetierk, Acta Theriol, field) → wild; domestic keywords (ferret, Frettchen, furo, UFAW, Lab Anim, miniature pig, domestic, Hausschwein, swine, sow/gilt/boar/pig, and the production journals J Anim Sci, Anim Prod, Anim Reprod Sci, Biol Reprod, J Reprod Fert, Theriogenology) → domestic_laboratory; a wild/feral modifier wins over an animal word (`wild boar`, `feral pigs`); several works disagreeing → `mixed:<a>|<b>`, basis `cited_work_title:<ref>=<keyword>`. Keyword matching is whole-word and case-insensitive, except that the stems wild, Wildschwein, Sanglier, jabal, Schwarzwild, Iltis, polecat are matched as word prefixes (Wildlebenden, Schwarzwildes, Iltissen, OCR `jabalf`). (3) Else `unspecified`. The book itself states (printed p. 1) that data for domesticated species such as the pig are generally not listed while their wild counterparts are, and that medical-journal ferret studies are assigned to *Mustela putorius*.

### Sus scrofa and Mustela putorius by population status

- *Sus scrofa*: 130 data lines — captive_zoo 3, domestic_laboratory 28, feral 9, mixed 5, unspecified 21, wild 64.

  | topic | captive_zoo | domestic_laboratory | feral | mixed | unspecified | wild |
  |---|---|---|---|---|---|---|
  | CYCLE LENGTH | 0 | 1 | 0 | 0 | 1 | 2 |
  | GESTATION | 0 | 5 | 0 | 0 | 4 | 10 |
  | INTERLITTER INTERVAL | 0 | 0 | 0 | 0 | 0 | 2 |
  | LACTATION | 0 | 0 | 0 | 0 | 3 | 1 |
  | LITTER SIZE | 0 | 4 | 3 | 1 | 3 | 14 |
  | LITTERS/YEAR | 0 | 0 | 0 | 0 | 0 | 4 |
  | NEONATAL MASS | 0 | 8 | 0 | 0 | 1 | 4 |
  | NEONATAL SIZE | 0 | 1 | 0 | 0 | 0 | 1 |
  | SEASONALITY | 3 | 1 | 3 | 4 | 5 | 16 |
  | SEXUAL MATURITY | 0 | 4 | 3 | 0 | 4 | 10 |
  | WEANING MASS | 0 | 3 | 0 | 0 | 0 | 0 |
  | WEANING SIZE | 0 | 1 | 0 | 0 | 0 | 0 |

- *Mustela putorius*: 81 data lines — captive_zoo 14, domestic_laboratory 30, unspecified 17, wild 20.

  | topic | captive_zoo | domestic_laboratory | unspecified | wild |
  |---|---|---|---|---|
  | CYCLE LENGTH | 0 | 1 | 1 | 1 |
  | GESTATION | 0 | 6 | 2 | 3 |
  | INTERLITTER INTERVAL | 0 | 1 | 0 | 0 |
  | LACTATION | 0 | 2 | 1 | 2 |
  | LITTER SIZE | 0 | 6 | 4 | 1 |
  | LITTERS/YEAR | 0 | 2 | 1 | 2 |
  | NEONATAL MASS | 0 | 1 | 1 | 2 |
  | NEONATAL SIZE | 0 | 0 | 1 | 1 |
  | SEASONALITY | 14 | 8 | 4 | 6 |
  | SEXUAL MATURITY | 0 | 3 | 2 | 2 |

### Species of interest by population status (wave 2: domestic/laboratory vs wild)

The population_status rule is the one above (book qualifier on the line, else keywords in the cited work's title/journal, else unspecified); for primates the production-journal cue (J Reprod Fert, Biol Reprod, Lab Anim) is what marks laboratory-colony studies domestic_laboratory, and `captive`/`zoo` on the line marks captive_zoo. Counts are data lines (family_overview rows excluded).

- *Felis silvestris*: 125 data lines — captive_zoo 5, domestic_laboratory 7, feral 18, mixed 2, unspecified 41, wild 52.

  | topic | captive_zoo | domestic_laboratory | feral | mixed | unspecified | wild |
  |---|---|---|---|---|---|---|
  | CYCLE LENGTH | 0 | 0 | 1 | 0 | 4 | 0 |
  | GESTATION | 0 | 2 | 0 | 0 | 4 | 3 |
  | INTERLITTER INTERVAL | 0 | 0 | 1 | 0 | 0 | 0 |
  | LACTATION | 0 | 0 | 0 | 0 | 2 | 8 |
  | LITTER SIZE | 0 | 2 | 4 | 2 | 6 | 7 |
  | LITTERS/YEAR | 0 | 0 | 2 | 0 | 1 | 3 |
  | NEONATAL MASS | 0 | 2 | 0 | 0 | 6 | 6 |
  | NEONATAL SIZE | 0 | 1 | 0 | 0 | 2 | 0 |
  | SEASONALITY | 5 | 0 | 5 | 0 | 6 | 17 |
  | SEXUAL MATURITY | 0 | 0 | 5 | 0 | 3 | 6 |
  | WEANING MASS | 0 | 0 | 0 | 0 | 7 | 2 |

- *Felis catus*: **0 data lines** — the book has no account for this species (domestic; see method:book_statements_on_domestic_species — domestic-dog data sit under Canis lupus).

- *Canis lupus*: 160 data lines — captive_zoo 10, domestic_laboratory 4, mixed 1, unspecified 73, wild 72.

  | topic | captive_zoo | domestic_laboratory | mixed | unspecified | wild |
  |---|---|---|---|---|---|
  | CYCLE LENGTH | 0 | 2 | 0 | 2 | 0 |
  | GESTATION | 0 | 0 | 1 | 8 | 9 |
  | INTERLITTER INTERVAL | 0 | 0 | 0 | 0 | 2 |
  | LACTATION | 0 | 0 | 0 | 10 | 7 |
  | LITTER SIZE | 0 | 1 | 0 | 20 | 26 |
  | NEONATAL MASS | 0 | 0 | 0 | 4 | 3 |
  | SEASONALITY | 10 | 0 | 0 | 16 | 17 |
  | SEXUAL MATURITY | 0 | 1 | 0 | 13 | 8 |

- *Canis familiaris*: **0 data lines** — the book has no account for this species (domestic; see method:book_statements_on_domestic_species — domestic-dog data sit under Canis lupus).

- *Vulpes vulpes*: 245 data lines — captive_zoo 14, domestic_laboratory 9, mixed 1, unspecified 141, wild 80.

  | topic | captive_zoo | domestic_laboratory | mixed | unspecified | wild |
  |---|---|---|---|---|---|
  | CYCLE LENGTH | 0 | 0 | 0 | 12 | 2 |
  | GESTATION | 0 | 0 | 1 | 14 | 0 |
  | INTERLITTER INTERVAL | 0 | 0 | 0 | 4 | 1 |
  | LACTATION | 0 | 0 | 0 | 13 | 6 |
  | LITTER SIZE | 0 | 0 | 0 | 35 | 32 |
  | NEONATAL MASS | 0 | 0 | 0 | 9 | 4 |
  | NEONATAL SIZE | 0 | 0 | 0 | 2 | 2 |
  | SEASONALITY | 14 | 9 | 0 | 40 | 24 |
  | SEXUAL MATURITY | 0 | 0 | 0 | 9 | 6 |
  | WEANING MASS | 0 | 0 | 0 | 3 | 2 |
  | WEANING SIZE | 0 | 0 | 0 | 0 | 1 |

- *Macaca mulatta*: 252 data lines — captive_zoo 29, domestic_laboratory 56, unspecified 148, wild 19.

  | topic | captive_zoo | domestic_laboratory | unspecified | wild |
  |---|---|---|---|---|
  | CYCLE LENGTH | 0 | 19 | 36 | 0 |
  | GESTATION | 0 | 4 | 25 | 4 |
  | INTERBIRTH INTERVAL | 0 | 0 | 6 | 1 |
  | LACTATION | 0 | 0 | 6 | 1 |
  | LITTER SIZE | 0 | 2 | 4 | 0 |
  | NEONATAL MASS | 0 | 7 | 22 | 2 |
  | NEONATAL SIZE | 0 | 1 | 2 | 0 |
  | SEASONALITY | 29 | 15 | 21 | 9 |
  | SEXUAL MATURITY | 0 | 8 | 26 | 2 |

- *Papio hamadryas*: 119 data lines — captive_zoo 5, domestic_laboratory 12, unspecified 94, wild 8.

  | topic | captive_zoo | domestic_laboratory | unspecified | wild |
  |---|---|---|---|---|
  | CYCLE LENGTH | 0 | 4 | 39 | 0 |
  | GESTATION | 0 | 3 | 8 | 1 |
  | INTERBIRTH INTERVAL | 0 | 0 | 8 | 1 |
  | LACTATION | 0 | 0 | 3 | 1 |
  | LITTER SIZE | 0 | 1 | 3 | 0 |
  | NEONATAL MASS | 0 | 2 | 5 | 0 |
  | NEONATAL SIZE | 0 | 0 | 3 | 0 |
  | SEASONALITY | 5 | 0 | 4 | 3 |
  | SEXUAL MATURITY | 0 | 2 | 17 | 2 |
  | WEANING MASS | 0 | 0 | 2 | 0 |
  | WEANING SIZE | 0 | 0 | 2 | 0 |

- *Papio leucophaeus*: 11 data lines — unspecified 4, wild 7.

  | topic | unspecified | wild |
  |---|---|---|
  | CYCLE LENGTH | 3 | 1 |
  | GESTATION | 1 | 1 |
  | INTERBIRTH INTERVAL | 0 | 1 |
  | LACTATION | 0 | 1 |
  | SEASONALITY | 0 | 2 |
  | SEXUAL MATURITY | 0 | 1 |

- *Papio sphinx*: 7 data lines — unspecified 7.

  | topic | unspecified |
  |---|---|
  | CYCLE LENGTH | 2 |
  | GESTATION | 3 |
  | LITTER SIZE | 1 |
  | SEASONALITY | 1 |

- *Papio spp*: 2 data lines — domestic_laboratory 1, wild 1.

  | topic | domestic_laboratory | wild |
  |---|---|---|
  | GESTATION | 1 | 0 |
  | LACTATION | 0 | 1 |

- *Pan troglodytes*: 122 data lines — captive_zoo 1, domestic_laboratory 8, unspecified 88, wild 25.

  | topic | captive_zoo | domestic_laboratory | unspecified | wild |
  |---|---|---|---|---|
  | CYCLE LENGTH | 0 | 2 | 31 | 5 |
  | GESTATION | 0 | 0 | 15 | 1 |
  | INTERBIRTH INTERVAL | 0 | 0 | 5 | 4 |
  | LACTATION | 0 | 0 | 6 | 5 |
  | LITTER SIZE | 0 | 0 | 7 | 3 |
  | NEONATAL MASS | 0 | 2 | 8 | 0 |
  | NEONATAL SIZE | 0 | 2 | 0 | 0 |
  | SEASONALITY | 1 | 1 | 0 | 1 |
  | SEXUAL MATURITY | 0 | 1 | 16 | 6 |

- *Homo sapiens*: 22 data lines — domestic_laboratory 7, unspecified 15.

  | topic | domestic_laboratory | unspecified |
  |---|---|---|
  | CYCLE LENGTH | 0 | 3 |
  | GESTATION | 1 | 3 |
  | INTERBIRTH INTERVAL | 2 | 0 |
  | LACTATION | 0 | 1 |
  | LITTER SIZE | 1 | 0 |
  | NEONATAL MASS | 1 | 6 |
  | SEASONALITY | 1 | 1 |
  | SEXUAL MATURITY | 1 | 1 |

- *Felis marmorata*: 3 data lines — unspecified 3.

  | topic | unspecified |
  |---|---|
  | LITTER SIZE | 1 |
  | NEONATAL MASS | 1 |
  | SEASONALITY | 1 |

- *Felis bieti*: **0 data lines** — the book has no account for this species.

*Papio*: the book prints Papio hamadryas, Papio leucophaeus, Papio sphinx and 'Papio spp' — 139 data lines in all (Papio hamadryas 119, Papio leucophaeus 11, Papio sphinx 7, Papio spp 2).

*Felis marmorata* (Pardofelis marmorata) — every line (3; the book has no longevity topic):

  | topic | value | refs | cited work | population_status | printed p. |
  |---|---|---|---|---|---|
  | NEONATAL MASS | `70-100 g` | 9564 | Schauenberg 1979 | unspecified | 296 |
  | LITTER SIZE | `2 yg` | 9564 | Schauenberg 1979 | unspecified | 299 |
  | SEASONALITY | `repro: not seasonal; Asia, Indonesia` | 9564 | Schauenberg 1979 | unspecified | 309 |

*Felis bieti*: no account in the book (0 lines; the Felidae species list has no bieti, and the slice text contains no 'bieti').

### Verification

Positive controls asserted by the script: 39 *Mustela putorius* lines (NEONATAL MASS `7 g 4643`, `9-10 g 3571`, `~10 g 9344`, `10 g ea; n2 4689`; SEXUAL MATURITY `f: vulvar edema: 30-50 wk 9394`, `f: 1st mate: 6-9 mo 9344`, `m: spermatogenesis: 8 mo 5167`, `f/m: 1 yr 7979`; INTERLITTER INTERVAL `20 wk 9344`; LITTERS/YEAR `1 7979, 10499`, `1; 2 if 1st lt removed 6156`, `2; r0-2 4299`); the *Sus scrofa* GESTATION (20) and LITTER SIZE (18) reference sets; and the *Sus scrofa* status mix (8220, 2973 domestic_laboratory; 473, 10600 feral; 2588, 6979 wild). Page images of every Suidae page and of Mustelidae printed pp. 260–267, 276–277, 285 were rendered and compared with the parsed rows by eye (see the session report for the lines checked).

### Wave 2 (2026-10-23): remaining Carnivora and all Primates

Grammar changes, each guarded so that the Suidae and Mustelidae tables stay byte-identical to the 2026-10-22 build (SHA-256 asserted in the session report): monotypic-family headings (`Order X, Family Y, Genus Z`) and an OCR-damaged heading name (`Proteiidae`) accepted; running headers matched within edit distance 2 (`Cercopitliecidae`); a single-page last family (Hominidae, p. 228) located by its own heading; three more printed page numbers declared from the page image (Carnivora pp. 319, 321; Primates p. 227); the page margin taken from the running header when a page has no species-column text (Phocidae p. 334); the reference-column anchor recomputed from line-final tokens when values end in numbers (Cercopithecidae pp. 208–210, 212, 216); a mutually-nearest second matching pass up to 8 pt for leftover lines (Primates pp. 177, 185); species-name OCR tolerance (`n/`→`rv`, `!`→`i`, split words, two-species lines, quoted vernacular) with a glyph-aware canonicalisation that keeps Canis rufus / Canis lupus and Panthera uncia / Panthera onca apart. See the method rows `method:family_headings_and_page_range`, `method:column_alignment_wave2`, `method:declared_repairs` in the definitions file.

Declared repairs (page images checked, each asserted to apply exactly once): 17 damaged reference strings (REF_OCR_FIX), 7 value lines absent from the OCR text layer (DECLARED_VALUE_LINES), 2 genuine wrapped reference lists whose comma the OCR lost (KNOWN_WRAPS), 11 species-name variants (SPECIES_OCR_FIX), 1 heading variant.

  | section | printed p. | OCR reference string | printed | reading |
  |---|---|---|---|---|
  | Carnivora | 242 | `7453, 7.` | `7453, 7462, 10086, 10087` | text layer holds only '7453, 7.'; the page prints four numbers |
  | Carnivora | 243 | `521°` | `5210` | final 0 read as a degree sign |
  | Carnivora | 246 | `831°` | `8310` | final 0 read as a degree sign |
  | Carnivora | 254 | `205’ 206` | `205, 206` | comma read as a quotation mark |
  | Carnivora | 256 | `1 1 A701 U/ ^ 1` | `10721` | number read as scattered junk |
  | Carnivora | 293 | `690/` | `5907` | digits mis-read |
  | Carnivora | 303 | `11991i` | `11991a` | suffix a read as i (the token 11991i in _cited_numbers_not_in_bibliography.csv is this OCR error, not a book gap) |
  | Carnivora | 303 | `11991;` | `11991a` | suffix a read as ; |
  | Carnivora | 303 | `11991!` | `11991a` | suffix a read as ! |
  | Primates | 175 | `115°. 8443, 8444` | `1150, 8443, 8444` | final 0 read as a degree sign |
  | Primates | 177 | `8435, 8438, ;` | `8435, 8438, 8439` | third number read as ; |
  | Primates | 178 | `4/22` | `4722` | 7 read as / |
  | Primates | 175 | `6432` | `8432` | 8 read as 6 (6432 Lidicker 1976 is a house-mouse paper; 8432 Petter-Rousseaux 1964, lemurs) |
  | Primates | 175 | `6435` | `8435` | 8 read as 6 (6435 Lidicker 1980, California vole; 8435 Petter et al. 1977, lemurs) |
  | Primates | 175 | `6451` | `8451` | 8 read as 6 (6451 Lincoln 1971, red deer; 8451 Petter-Rousseaux 1980, prosimians) |
  | Carnivora | 254 | `2812` | `2612` | 6 read as 8 (2812 Duplaix 1980, giant river otter; 2612 under Ursus arctos) |
  | Carnivora | 246 | `486` | `466` | 6 read as 8 (486 Baevskii, blastocyst cytometry; 466 Avaliani 1965) |

  | section | printed p. | species | value (from page image) | ref |
  |---|---|---|---|---|
  | Carnivora | 240 | (inherited) | `den emergence: 3-4 wk` | 747 |
  | Carnivora | 314 | Arctocephalus pusillus | `1` | 1605 |
  | Primates | 182 | Lichanotus laniger | `1` | 8444 |
  | Primates | 182 | (inherited) | `1` | 8432 |
  | Primates | 182 | Propithecus verreauxi | `1` | 8445 |
  | Primates | 224 | Gorilla gorilla | `1` | 9544 |
  | Primates | 227 | (inherited) | `min 3 yr` | 11176 |

Reference-number digit plausibility (`reference_tables/Hayssen_VanTienhoven_1993_accounts_ref_suspects.csv`): 187 numbers cited once in a family whose one-confusable-digit variant is cited >= 2 times in the same family (102 on data lines, 85 in family_overview prose lists). The 60 data-line suspects whose cited-once work has a different first author from the variant were triaged by title against the species on the line; 6 were rendered: 5 were OCR digit errors (both numbers valid in the bibliography: 6432/6435/6451 for 8432/8435/8451 on Cheirogaleidae p. 175 — a house-mouse, a California-vole and a red-deer paper standing in for the lemur monographs; 2812 for 2612 on Ursidae p. 254; 486 for 466 on Canidae p. 246) and are repaired in REF_OCR_FIX; 1 (Cebidae p. 198, 10809) is printed as cited. The remaining rows are a review list, not findings.

Positive controls for the wave-2 families: 26 lines in `CONTROL_LINES` (read from the page images), all asserted. Page images rendered and compared line by line with the parsed rows during the session (every data line of the page unless stated): Felidae pp. 296 (38 lines) and 303 (63; found 11991i = 11991a); Cercopithecidae pp. 209 (57) and 210 (64); Phocidae pp. 321 (64) and 334 (first 28 of 59); Cheirogaleidae p. 175 (58; found the 6432/6435/6451 digit errors). Species, value text and every reference number agreed on all other lines. Also rendered: the repair sites (Canidae pp. 240, 242, 243, 246; Ursidae p. 254; Procyonidae pp. 256, 258; Protelidae p. 293; Otariidae p. 314; Odobenidae p. 319; Lemuridae pp. 177, 178; Indriidae p. 182; Galagidae p. 185; Cebidae p. 201; Pongidae pp. 224, 227).

### Known failure modes

- Rotated pages: the reference column drifts ~15 pt in x down the page and sits up to 6 pt above/below its value line; handled by the per-column rebuild (a plain y grouping would pair a reference with the neighbouring line).
- OCR letter/digit confusions in qualifiers (`nl`, `It`, `rl`, `sdl.25`, `nIO`): normalised for parsing only.
- `~` is OCR'd as `-` (`-10 g`): read as approximately (`approx = TRUE`).
- A value whose text runs close to the reference column (`... nw Assam, India 8095`) is still split correctly because the split is by x anchor, not by gap.
- Lines whose value is prose-like (`half grown`, `solid food: grass almost at once`) parse as text (`partial`/`verbatim_only`) and are kept.
- Whole short value lines missing from the OCR text layer (a lone `1`, `min 3 yr`, `den emergence: 3-4 wk`) while species and reference survive: the orphaned reference is otherwise appended to the previous line's list. Detected by the suspect-continuation check (previous reference line without a trailing comma) and by in-range leftover lines; both now stop the run until declared. A dropped value whose reference follows a genuinely wrapped list cannot be detected this way.
- A reference number mis-read by one confusable digit into another valid number (8435 -> 6435) passes the reference guard silently; the digit-plausibility report lists candidates, and the step-1 note that 11991i is 'cited but not listed' turned out to be this kind of OCR error (11991a).
- Reference numbers damaged in the text layer (`°` for a final 0, `/` for 7, `;`/`!` for a suffix letter, a list truncated to `7453, 7.`): caught by the token guard and declared from the page image.
- A page whose only species name continues from the previous page has no species-column text; the margin then comes from the running header.
- Values that end in numbers close to the reference column (`n595 cycles, 28 f`) pull the reference anchor left unless it is taken from line-final tokens.
- Species names: `rv` read as `n/`, `i` as `!`, `rn` as `m`, `ri` as `h`, `l` as `t`/`i`, words split by spaces; and the inverse risk — two real species within two edits (Canis rufus/lupus, Panthera uncia/onca) must not be merged, hence the glyph-aware rule.
- The keyword rule for population status is a heuristic over titles and journals: Henry 1968 'European wild hogs' (J Wildl Manage) classifies as wild although those are introduced populations; the production-journal cue (J Reprod Fert, Biol Reprod) fires on physiological studies of wild-caught mustelids (stoat, badger, spotted skunk) and marks them domestic_laboratory; the animal word `pig` fires on 'Common bush-pig' (5771, *Potamochoerus*) and on 'Pigs' (9607a, *Babyrousa*). The basis column names the reference and keyword for every classification so these can be audited or re-weighted.

### How to add the next family

Append the family name to `FAMILIES` (the order and slice come from `_contents.csv` and the slice map), run `Rscript Hayssen_VanTienhoven_1993_accounts.R`, read the printed page table (every page in the range must yield rows; the running header of every page must name the family), the topic list, the unparsed table and the verbatim_only fraction; render the first and last page (`pdftools::pdf_convert`) and check ≥ 10 lines against the table; add positive-control lines for the new family to `CONTROL_LINES`.

