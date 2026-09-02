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

---

## What a snapshot is

> **A snapshot is a frozen, faithful digital copy of a published table, saved
> exactly as it appears in the source — before any cleaning.**

Think of it as a photograph of the table. It looks like the paper: same layout,
same column headers, same values, same footnote marks, same reference numbers,
same units. It is *digitized* (so R can read it — CSV or Excel) but **not yet
tidied**.

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
   tesseract).  

4. **PDF → Excel (our default for printed tables).** Open the PDF in Adobe
   Acrobat Pro → *Export a PDF → Microsoft Excel Workbook*. Copy/paste the table
   and lightly reformat so it matches the printed layout. Save as
   `..._snapshot.xlsx`.

5. **Manual entry** (when the PDF is a scan or export is garbled). Type it in,
   keeping the original layout. Then double-check it — e.g. ask an AI assistant
   to read the table from the PDF and diff it against your file, and correct any
   mismatches by hand.

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

- Could someone open my snapshot next to the PDF and see they're the same table?
- Did I keep the footnotes and reference numbers?
- Is *every* change to the data written down in the `.R` script (and nothing
  baked silently into the snapshot)?
- Did I save a local snapshot file, even though the data is online?

If yes to all four, the snapshot is proper.
