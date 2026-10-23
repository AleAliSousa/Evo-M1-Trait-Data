# Ernest 2003 — Life history characteristics of placental non-volant mammals (`Mammal_lifehistories_v2.txt`)

Ernest, S. K. M. (2003). Life history characteristics of placental nonvolant mammals. *Ecology*, 84(12), 3402.
Ecological Archives E084-093-D1. https://doi.org/10.1890/02-9002

Species-level compiled averages of nine life-history variables for **1,440 placental, non-volant mammals**
(17 orders; no bats, no marsupials or monotremes): adult (female) mass, gestation, newborn mass, weaning age,
weaning mass, age of first reproduction, maximum lifespan, litter size and litters per year.

## Why this item exists
`Ernest et al., 2003` is the second-largest feeder of the Amniote life-history database
(`Myhrvold_etal_2015`): ~14,500 cited records, almost all mammalian. AnAge (de Magalhães & Costa 2009) also
names Ernest (2003) as one of its standard sources. Building it lets Amniote/AnAge values be compared
with the compilation they drew from. (The Amniote reference table calls the citation "Ernest et al., 2003" and
gives the full reference as the Ecology Letters paper, Ernest et al. 2003, 6:990-995. But the life-history values are the
Ecology data paper. The Ecology Letters paper is a short analysis paper and publishes no species table.)

## Files
- `Ernest-2003-Life history characteristics of pl.pdf`: the one-page data-paper abstract (from the owner's EndNote library).
- `Ernest__2003_Mammallifehistoriesv2.txt_snapshot.tsv`: **frozen source**. It is `Mammal_lifehistories_v2.txt`
  downloaded 2026-10-23 from https://esapubs.org/archive/ecol/E084/093/ and copy-renamed with bytes untouched
  (SHA-256 `9b7a4ef7082c7b37ab76b922cfd5c86fd3e49444fa2db180439cfbe051fef6b9`; tab-delimited ASCII, CRLF;
  header + 1,440 records + 4 tab-only trailing rows).
- `metadata.htm`: the archive's metadata page, downloaded the same day, untouched
  (SHA-256 `e746b54a9cbabd2b23022fc0e8ef4000383ec3b9d13923e607ca7990965a8758`). It holds the variable
  definitions, missing code, authentication sums and the numbered reference list.
- `Ernest__2003_Mammallifehistoriesv2.txt.R`: the build. It reads both frozen files and writes:
  - `Ernest__2003_Mammallifehistoriesv2.txt.csv`: analysis CSV, 1,440 rows;
  - `__Public/comparative-data/10.1890%2F02-9002_Mammallifehistoriesv2.txt.tsv`: public TSV;
  - `reference_tables/Ernest__2003_Mammallifehistoriesv2.txt_references.csv`: the 29 numbered sources
    (`ref_key`, `cited_in_column = refs`, `citation` verbatim from metadata.htm, `note`).
- `reference_tables/Ernest__2003_Mammallifehistoriesv2.txt_definitions.csv`: data dictionary.

## Reader / provenance
No transcription was needed: the source is the author's machine-readable file. The values were carried into the CSV
by the R build script, run by an AI assistant on 2026-10-23. The cleaning steps are listed below.
- Trailing tab-only rows dropped.
- Headers renamed with the unit kept in the name (`AFR_mo`, `Max_lifespan_mo` …).
- `-999` set to NA.
- `refs` "1,2,6" rewritten as "1; 2; 6".
- `Species_Ernest2003` = Genus + species added.

Months are kept as printed (not converted to days). Body masses are already in g, the project unit.

## Table checks
The metadata (Class IV A, "Authentication procedures") prints the column sums of the nine numeric columns,
**including the -999 codes**. The build recomputes them from the frozen file before NA conversion and stops on any mismatch.
All nine agree exactly (difference 0.00):

| column | published sum |
|---|---|
| mass(g) | 552350473.58 |
| gestation(mo) | -413634.01 |
| newborn(g) | 9652529.75 |
| weaning(mo) | -615124.25 |
| wean mass(g) | 23110460.38 |
| AFR(mo) | -587698.17 |
| max. life(mo) | -705968.00 |
| litter size | -80112.72 |
| litters/year | -687082.61 |

## Data role
**Secondary (compilation).** Every value is the unweighted mean over the numbered literature sources entered for
that species (most are themselves compilations: ref 1 = Hayssen & Van Tienhoven 1993 *Asdell's*, ref 2 =
Nowak 1999 *Walker's*, …). `refs` is **row-level**: it lists every source used for the species, not which
source supplied which variable. Do not merge as primary data.

## Caveats (from the metadata)
- `Adult_mass_g` is **female** mass where dimorphism is strong. AnAge 2009 traces most of its two-fold
  disagreements with Ernest to this choice.
- `AFR_mo` is age at first **conception** (gestation subtracted from age at first birth). Add `Gestation_mo` before
  comparing with "female maturity" in AnAge or Amniote.
- `Max_lifespan_mo` is a single maximum record, not an average.
- After reference 26, a variable stopped accruing sources once it had 10 entries.
- The metadata abstract labels litter size "(months)". This is a typo: Class IV B gives no unit.
- metadata.htm carries 12 U+FFFD replacement characters (lost apostrophes, e.g. "Asdell�s"). They are kept verbatim
  in the references table and noted there.

## Species names
The printed Genus/species (MSW2 taxonomy, Wilson & Reeder 1993) are kept verbatim. No `species_key.csv` rows were
added, following the same treatment as the other life-history compilations (`Jones_etal_2009`, `deMagalhães_etal_2024`).
