# Herculano-Houzel (2015) — Table 1

Herculano-Houzel, S. (2015). Decreasing sleep requirement with increasing
numbers of neurons as a driver for bigger brains and bodies in mammalian
evolution. *Proc Biol Sci, 282*(1816), 20151853.
https://doi.org/10.1098/rspb.2015.1853

## Source

Publication PDF is in this folder:
`Herculano-Houze-2015-Decreasing sleep requirem.pdf`

Open-access HTML version (PubMed Central): https://pmc.ncbi.nlm.nih.gov/articles/PMC4614783/

Table 1 is printed in **rotated landscape across two pages** and does **not**
extract cleanly from the PDF. (Table 2 in this folder *is* pulled from the PDF
with `tabulapdf` — see `Herculano-Houze-2015_Table2.R` — but Table 1 is wider
and broke up.)

## --> Snapshot

Because the PDF would not cooperate, Table 1 was captured a different way:
**scraped from the PMC HTML version** in R with `rvest`
(`read_html() |> html_elements("table") |> html_table()`, first table), then
**cross-checked cell-by-cell against the published PDF**. All data values match
the PDF.

The snapshot is faithful to the published table — it keeps:

- the per-cell **reference citations** in square brackets, e.g. `15.750 [19]`,
  `441.90 × 106 [20]` (the paper cites a source for nearly every value);
- the **footnote markers** `*`, `a`, `b`, `c` (see legend below);
- the original **units, scientific notation, `n.a.`, and clade header rows**
  (Primates, Eulipotyphla, Glires, Afrotheria, Artiodactyla, Scandentia).

Column labels were set to match the printed header (the scraped header row is
split by `html_table()`).

`Herculano-Houze-2015_Table1_snapshot.csv`

## --> Data readable

Cleaning happens in `Herculano-Houze-2015_Table1.R`, reading the snapshot and,
in order: remove `[reference]` citations → `n.a.` to `NA` → remove `*` →
remove trailing footnote letters (`218a` → `218`) → remove thousands spaces
(`47 960` → `47960`) → convert scientific notation in NCX (`441.90 × 106` →
`441.90e6`) → coerce to numeric → fold the clade rows into a new `category`
column.

`Herculano-Houze-2015_Table1.csv`  <-- USE THIS

## --> Online database

To add (not yet pushed): TSV copy named with the DOI-encoded item name to
https://github.com/r03ert0/comparative-data

`10.1098%2Frspb.2015.1853_Table1.tsv`  <-- ONLINE COPY

## Column key (from the table legend)

- **species** — binomial; **brain mass (g or cm3)**; **daily sleep (h)** (from ref [7])
- **D/A** — neuronal density ÷ cortical surface area (N mg⁻¹ mm⁻²)
- **NCX** — number of cortical neurons
- **DNCX** — neuronal density in cortical grey matter (N mg⁻¹); `*` = density
  includes white matter
- **ACX** — cortical surface area (mm²)
- **O/N** — ratio of other (non-neuronal) cells to neurons
- **T** — cortical grey-matter thickness (mm), = VCX/ACX
- **MCX** — cortical mass (g) or volume (cm³); `*` = mass includes white matter
- `[n]` = reference to the main text; `n.a.` = not available

## Notes / flags

- **Source type discrepancy:** the master `__ReadMe.xlsx` lists this item's
  Source Type as `pdf`. The actual capture was the **PMC HTML**, cross-checked
  against the PDF — worth updating the `Source Type` / `Source URL` fields.
- This is the **only** table in the dataset captured by web-scrape, so the
  method is documented fully here for traceability.
- `Oryctolagus cuniculus` has `n.a.` for T and MCX in the source (→ `NA`).
