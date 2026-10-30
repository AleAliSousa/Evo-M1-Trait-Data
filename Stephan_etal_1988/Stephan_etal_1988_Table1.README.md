# Stephan_etal_1988_Table1

## Source

PDF: `stephan_etal_1988.pdf`; Adobe PDF→Excel export: `stephan_etal_1988.xlsx`. Chapter:
Stephan, H., Baron, G., & Frahm, H. D. (1988). *Comparative size of brains and brain
components.* In H. D. Steklis & J. Erwin (Eds.), **Comparative Primate Biology, Vol. 4:
Neurosciences** (pp. 1–38). New York: Alan R. Liss. (`__ReadMe.xlsx` row: `Stephan_etal_1988`,
Item number "TABLE 1", identifier `ISBN:0845140000`.)

Table 1 — Body Weights (BoW, g), Brain Weights (BrW, mg) and Encephalization Indexes (EI) of
Tenrecinae, Scandentia, and the 45 primate species whose brain structures were measured, with
ecoethological codes for the primates. **52 species** (4 Tenrecinae + 3 Scandentia + 45
primates). The chapter has many other tables (Table 3 = per-structure size indexes; Tables 5–6
= group averages); only Table 1 is built here.

## Files

| Path | Role |
|---|---|
| `stephan_etal_1988.pdf` | The publication (38-page chapter). |
| `stephan_etal_1988.xlsx` | Raw Adobe PDF→Excel export of the whole chapter (all 20 sheets, uncleaned). Provenance; not read by the scripts. |
| `Stephan_etal_1988_Table1_snapshot.xlsx` | **Snapshot** (sheet `Table1`): Table 1 reproduced journal-style — caption; tier-1 header (BoW \| BrW \| EI \| Ecoethological characteristics); tier-2 ((g)\|(mg)\|(1)–(4)); grade rows (Tenrecinae/Scandentia/Prosimians/Simians) and species (`<code> <binomial>`); two footnote rows. Values transcribed from the **printed PDF page** (thousands commas kept). |
| `Stephan_etal_1988_Table1.R` | Reformat → `Stephan_etal_1988_Table1.csv` (+ identifier-named TSV). Reads only the snapshot. |
| `reference_tables/Stephan_etal_1988_Table1_definitions.csv` | Data dictionary (10-column schema). |
| `__Public/comparative-data/ISBN%3A0845140000_TABLE1.tsv` | Shared public copy (named from `__ReadMe.xlsx` Item encoded). |

## Snapshot fidelity notes

The snapshot reproduces the printed page. OCR garbling in the export was corrected against the
PDF to the **printed** form: `Ateles geoffroyi` (export "riteles"), `Hylobates lar` (export
"tar"), `Daubentonia madagascariensis` (printed split across two lines), grade `Prosimians`
(printed "Pro simians"), locomotor code `OMB` (export/OCR "0MB"). Body and brain weights keep
their printed thousands commas (e.g. `1,330,000`); the R `parse_number()` strips them. EI keeps
printed decimals (e.g. `0.90`).

## Reformat → CSV

Reads past the 3 header rows, names the 8 columns by position, keeps the **52 species rows**
(the only rows with a numeric BoW — grade-header and footnote rows are dropped automatically),
splits the leading 4-digit `Stephan_code` from `Species`, types BoW/BrW/EI, and
keeps the four ecoethological codes as character (blank for Tenrecinae/Scandentia, and for
Homo's diet/refs, as printed). Adds `source = "Stephan_etal_1988"`. Current accepted names are
applied later via `../_keys/Stephan/`. (R is not in the build sandbox; the committed CSV/TSV
were produced by a Python mirror of this logic and will be regenerated when you run the R.)

Output columns: `Stephan_code, Species, BoW_g, BrW_mg, EI, activity, diet_category,
locomotion, ecoethology_refs, source`.

**EI method (footnote a):** EI = observed BrW / expected BrW from the Tenrecinae reference line
(log–log; slope 0.63, y-intercept 1.6128); points on the line have EI = 1.

## Verification

No `comparison/` folder is kept — that convention is reserved for tables that already had a
pre-existing formatted sheet, and this one was built from the raw PDF + export. Verification was
done at build time by cross-checking the snapshot (transcribed from the printed PDF page) against
the **independent Adobe PDF→Excel export**, matched by Stephan code: **52 species, BoW/BrW/EI all
agree, 0 value mismatches** — i.e. the two independent digitisations are identical.
