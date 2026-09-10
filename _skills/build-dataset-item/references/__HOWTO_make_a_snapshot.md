# How to make a snapshot — a guide for RAs

This dataset compiles published trait tables from many papers into one
comparable format. For every table we keep four files in the paper's folder:

| file | what it is |
|---|---|
| `..._snapshot.csv` *(or `.xlsx`, or a born-digital file's original extension)* | **the snapshot** — a frozen, faithful copy of the table *as published* |
| `....csv` | the cleaned, analysis-ready data ("use this") |
| `....R` | the script that turns the snapshot into the clean CSV |
| `....ReadMe.md` | a short note on where the table came from and what was done |

This guide is about the first one.

## The memorable distinction

**The snapshot is for a person checking the paper; the cleaned CSV/TSV is for a
computer analysing the data.**

Use this side-by-side test: open the snapshot beside the published table. Can you
find and compare corresponding values easily because the headings, row order, and
column order remain in the same places? If not, the snapshot has probably been
cleaned or rearranged too far.

The snapshot does **not** need to reproduce every visual detail exactly. Fonts,
borders, spacing, merged cells, and difficult symbols may differ when necessary.
Preserve the published organisation and meaning closely enough for a reliable
cell-by-cell comparison.

---

## What a snapshot is

> **A snapshot is a frozen, faithful digital copy of a published table, saved
> before any cleaning.**

Think of it as the spreadsheet an author might have prepared for the publisher,
or that a publisher might have formatted further for the page. It retains the
published table's organisation: headings and subheadings, row order, column order,
values, footnote marks, reference numbers, units, and meaningful blank cells. It
is digitised as text (CSV or Excel) but **not yet tidied for analysis**.

Published tables often contain features that help a reader but are inconvenient
for statistical software, such as grouped rows, multi-level headings, notes, and
footnotes. Those features belong in the snapshot when they preserve meaning or
make comparison with the paper easier.

## Why we bother (the point of it)

The snapshot is the **audit anchor** between the paper and our analysis.

- **Traceability.** Anyone can lay the snapshot next to the PDF and confirm,
  cell by cell, that we copied the paper correctly.
- **Separation of "what the paper said" from "what we changed."** Every edit —
  renaming a column, dropping a unit, fixing a typo — happens *after* the
  snapshot, inside the `.R` script. So the changes are visible and reversible.
- **Durability.** Papers, links and supplementary files disappear. The snapshot
  is our own permanent copy. *(We keep a hardcopy snapshot file even when the
  data is also available at a URL.)*

If the clean data ever looks wrong, the snapshot is how we find out whether the
mistake came from the paper or from our cleaning.

## The one golden rule

**Freeze the snapshot before you clean anything. Do all cleaning in the `.R`
script.**

The most common mistake is saving the snapshot *after* already renaming headers
or stripping symbols — then it no longer matches the paper, and the whole point
(comparison to source) is lost. Capture first, clean second.

**The other way to fake a snapshot: hardcoding.** A `data.frame` typed into the
build script — with cleaned column names, split mean/SEM columns, markers
already converted to flags — written out as `..._snapshot.csv` on every run is
**not a snapshot**; it is the product wearing the snapshot's name, and it leaves
nothing to audit the cleaning against. The tell: the "snapshot" and the clean
CSV are the same file. A hand transcription is fine (that's method 5 below),
but it must be typed **as printed, into the frozen file**, and the `.R` must
**read** that file — never regenerate it. An `*_extract.R` that *builds* a
snapshot from the PDF/HTML source is different and fine: it saves the captured
hardcopy first, then cleaning starts from that file.

## Choosing the format (evidence, not product)

**The snapshot is evidence, not product.** Choose the capture that minimizes
transformation between the publication and the file on disk; all
standardization happens later, in the scripted build. Fidelity is measured
against the published page — never against an extraction tool's output.

A format conversion is an edit, and the snapshot exists to precede all edits.
Converting an Excel capture to a "standard" CSV flattens merged headers,
coerces types, and drops footnote marks and formatting that carry meaning —
the file stops being evidence and becomes a derived product pretending to be
one. So there is no standard snapshot *format*, only a standard *rule*, by
source type:

1. **Born digital** — the journal or repository supplies the data as
   `.csv` / `.xlsx` / `.tsv`: the untouched download **is** the snapshot.
   Copy-rename it to `<Paper>_<locus>_snapshot.<original ext>`, bytes
   untouched — never open-and-resave, never convert. Record the original
   filename, URL and download date in the ReadMe.
2. **Printed table** (PDF or scan) — transcribe it:
   - flat layout → **`_snapshot.csv`** (the default: plain text, diffable);
   - layout that CSV cannot hold losslessly (multi-row or merged headers,
     superscript footnote marks, formatting that carries meaning) →
     **`_snapshot.xlsx`**. Excel here is not a compromise; it is the more
     faithful medium.
3. **No published table** — the values live in a figure or in prose: build a
   *constructed snapshot* (see *When there is no table*, below).

Never add a conversion step to make snapshots uniform: it duplicates the
file — and worse, it leaves two frozen copies, and two frozen sources is one
too many.

## What the snapshot must keep (fidelity checklist)

Keep everything that is in the printed table, even if it looks messy:

- [ ] **Original column headers** (even long, multi-line, or symbol-heavy ones)
- [ ] **All values exactly as printed** — including units, `×10⁶`-style notation,
      and spaces inside numbers (`47 960`)
- [ ] **Footnote markers** — `*`, superscript letters (`218a`), daggers, etc.
- [ ] **Reference citations** printed in the cells — `[19]`, `(20)`
- [ ] **`n.a.` / `—` / blank** cells, as printed (don't "fix" them yet)
- [ ] **Grouping / header rows** (e.g. clade names that span the table)
- [ ] **Row order** as published

Cleaning (numbers → numeric, splitting columns, NCBI species names, etc.) comes
later, in the script. Not here.

## What belongs outside the snapshot

Do not force contextual information into the snapshot if it was not part of the
published table. Keep it accessible elsewhere in the paper folder or collection:

- `reference_tables/<Item>_definitions.csv` defines variables, including acronyms
  or terms that would otherwise be ambiguous.
- `reference_tables/<Item>_references.csv` maps secondary-source keys printed in
  the data to the relevant bibliography entries. Include only references used by
  the item, not the paper's entire bibliography.
- Collection-specific `_keys/` files disambiguate species names and anatomical
  terms. Preserve the name printed by the paper in the analysis data as well.
- If useful information appears only in prose, create a clearly labelled file such
  as `<Paper>_data_from_text_snapshot.csv` and record the section or passage and
  extraction method in the README.

These resources should be join-ready where practical so species binomials, source
references, definitions, or anatomical mappings can be bound to the analysis data
without changing the faithful snapshot.

## How to make one — methods, best first

1. **Direct download.** If the journal offers the table/supplement as `.xlsx`
   or `.csv`, download it and use that file as the snapshot. Easiest and most
   faithful. Copy-rename it to `..._snapshot.<original ext>` with the bytes
   untouched — never open-and-resave or convert (see *Choosing the format*).

2. **Web-scrape the publisher's HTML.** Pull the table from the open-access
   HTML version (PMC, journal site) in R with `rvest` — handy when the PDF won't
   extract (e.g. a wide, rotated table). **The scraping script must also save
   the snapshot**: write it to `..._snapshot.csv` *before* any cleaning, so the
   scrape is captured as a hardcopy on every run (don't rely on the live URL
   alone). Cross-check against the PDF and note the HTML source in the ReadMe.
   *(Worked example in the repo: `HerculanoHouzel__2015/` Table 1.)*

3. **Extract from a PDF of the paper.** If the table is published in a PDF, write
   a script to use a tool like tabulapdf (R) to extract it programmatically. This 
   works best for text-based PDFs; scanned documents may require OCR (e.g., 
   tesseract). Plain `pdftools::pdf_text` + regex also works well for small
   tables and for values printed in running text — worked example:
   `Jacob_etal_2021/Jacob_etal_2021_extract_snapshot.R` (no values typed in the
   script; anchored printed literals for headers/notes; two-column reading-order
   reconstruction; refuses to overwrite a differing frozen copy). Prefer this
   over manual entry whenever the PDF has a usable text layer.

4. **PDF → Excel (our default for printed tables).** Open the PDF in Adobe
   Acrobat Pro → *Export a PDF → Microsoft Excel Workbook*. Copy/paste the table
   and lightly reformat so it matches the printed layout. Save as
   `..._snapshot.xlsx`.

5. **Manual entry** (when the PDF is a scan or export is garbled). Type it in,
   keeping the original layout. Then double-check it — e.g. ask an AI assistant
   to read the table from the PDF and diff it against your file, and correct any
   mismatches by hand. Record in the ReadMe **who typed it and when** — this
   applies to an AI assistant exactly as to a person: "transcribed by <RA / AI
   assistant> on <date>, verified against the PDF by <how>". A reading step
   that leaves no record is how "hardcoded" numbers happen; the values always
   come from somewhere, and the ReadMe must say where and through whom.

Whatever the method, the result is the same kind of file: a faithful, frozen
copy you can compare to the paper.

## When there is no table (constructed snapshots)

Sometimes the values are published only in a figure or in running text. The
snapshot is then a table **we** construct — name it by its locus:
`<Paper>_Figure2_snapshot.csv`, `<Paper>_text_snapshot.csv`. Because the
tabular form itself is our work, the extraction method is part of the
provenance and the ReadMe **must** record it:

- **from a figure** — the tool (e.g. WebPlotDigitizer), the calibration
  points, and the axis assumptions;
- **from text** — which section and sentences the values come from, quoted or
  cited precisely.

The fidelity checklist still applies to the values themselves (units,
footnote marks, `n.a.` as printed). Everything downstream is unchanged.

## File naming

Inside the paper's folder (e.g. `JardimMesseder_etal_2017/`):

```
<Paper>_<Table>_snapshot.csv     # or .xlsx — the snapshot
<Paper>_<Table>.csv              # cleaned data, "use this"
<Paper>_<Table>.R                # snapshot -> clean
<Paper>_<Table>.ReadMe.md        # source + steps
```

`<Table>` is the **locus**: `Table1`, `TableS2`, `Figure2`, `text`, or the
original dataset name for a born-digital download.

The ReadMe follows the team pipeline:
`Source → Snapshot → Data readable → (Transpose / Variables / Species notes) →
Online database`. The full, authoritative sequence — and what happens to the
snapshot after this guide — is in **`__HOWTO_build_a_dataset_file.md`** (the old
`Pipeline` sheet in `__ReadMe.xlsx` has been retired in favour of that file).
Copy the format of any existing `*.README.md`.

## Quick self-check before you move on

- Could someone open my snapshot next to the PDF and compare values easily in the
  same row and column positions?
- Did I keep the headings, subheadings, row order, column order, units, footnotes,
  and reference numbers that matter for interpretation?
- Did I avoid reproducing decorative formatting that does not help comparison or
  preserve meaning?
- Is *every* change to the data written down in the `.R` script (and nothing
  baked silently into the snapshot)?
- Did I save a local snapshot file, even though the data is online?
- Does the `.R` **read** the snapshot (rather than write it from hardcoded
  values), and does the snapshot actually differ from the clean CSV?

If yes to all four, the snapshot is proper.
