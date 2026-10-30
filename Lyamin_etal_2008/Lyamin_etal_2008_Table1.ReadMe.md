# Lyamin et al. (2008) — Table 1

**Source paper.** Lyamin, O. I., Manger, P. R., Ridgway, S. H., Mukhametov, L. M., & Siegel, J. M.
(2008). Cetacean sleep: an unusual form of mammalian sleep. *Neuroscience & Biobehavioral Reviews*,
32(8), 1451–1484.

**Table.** Table 1: *"Number of muscle jerks in cetaceans"*. Seven rows, six species — killer whale
appears twice, as a calf and as an adult female.

## Files in this folder

| file | what it is |
| --- | --- |
| `Lyamin_etal_2008_Table1_snapshot.csv` | Table 1 as printed |
| `Lyamin_etal_2008_Table1.csv` | cleaned, analysis-ready data ("use this") |
| `Lyamin_etal_2008_Table1.R` | script that turns the snapshot into the clean CSV |
| `species_resolution_Lyamin_Table1.csv` | common name → binomial, with confidence flags |
| `Lyamin_etal_2008_Table1.ReadMe.md` | this file |

## Pipeline

`Source → Snapshot → Data readable → (Species notes) → Online database`

## Snapshot

**Method.** Manual entry, transcribed by an AI assistant on 10 September 2026 from a page image of
the printed table supplied by M. Windley, and checked against it.

**Columns kept, exactly as in the paper.**

- `Cetacean species` — common names, as printed
- `Age`
- `Number of jerks`
- `Reference`

**Row order.** As published.

**Number of jerks is kept as printed text.** The seven rows use six different reporting conventions:
a total over a period (`45 over 6 days`), a daily rate (`15–98 per day`), a mean with dispersion
(`144 ± 24, average over 6 nights`), upper bounds (`<29 single and <10 serial per night`), values
split by individual (`13, 31 and 35/3 days`), and one qualitative entry (`a few/night in male`).
En-dashes, `±` and `<` are preserved.

**What was NOT included in the snapshot.**

- Binomials. The printed table gives common names only; the resolution lives in
  `species_resolution_Lyamin_Table1.csv`.

## Cleaning applied (in `.R`)

- Column names → snake_case; common names lowercased.
- `number_of_jerks` kept as character.
- `n_animals` and `age_class` parsed from the printed `Age` string where unambiguous; the printed
  string is retained in `age_printed`.
- `reference_unpublished` and `reference_in_press` flags set from the printed reference.
- Binomials joined from the resolution file.

## Notes for the database

- Two rows are Lyamin and Siegel unpublished data; one reference is Shpak et al. (in press). All
  three are flagged in the cleaned CSV and should not be treated as citable primaries. The published
  form of Shpak et al. should be traced before that row is used.
- The killer whale rows are separate measurements at different ages, not a species mean.
- Only the beluga row carries a dispersion estimate.
- Muscle jerks are a behavioural count, not a scored sleep stage; if promoted to a term they need a
  `dependency_group` of their own, kept apart from the sleep-architecture traits, as `Torpor_*` is.
- Sleep values for this paper come from Table 2 (`Lyamin_etal_2008_Table2`).

## Public export

Add the row to `__ReadMe.xlsx` (`Item name = Lyamin_etal_2008_Table1` plus the derived `Item
encoded`) and run the `.R`, which writes `__Public/comparative-data/<Item encoded>.tsv`.
