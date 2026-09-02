# Weaver__2001_NotesforTableA-15

## Source

PDF: `weaver_2001.pdf` (dissertation p. 245)

Paper: Weaver, A. G. H. (2001). *The cerebellum and cognitive evolution in Pliocene and Pleistocene hominids* [PhD dissertation, The University of New Mexico].

Item: **Notes for Table A-15** — the provenance notes printed immediately after Table A-15, stating where each variable / taxon group's values came from.

## What this is

This is **metadata / provenance**, not measured data. It records, for each of the seven notes, which variable(s) and taxon group it covers and the cited data source. It is not merged into any trait table; it documents the sourcing behind `Weaver__2001_TableA-15`.

## Files

| Path | Role |
|---|---|
| `Weaver__2001_NotesforTableA-15_snapshot.csv` | Verbatim transcription of the notes (title + 7 note lines). Source of truth. |
| `Weaver__2001_NotesforTableA-15.R` | Turns the verbatim notes into a structured source-attribution table (+ TSV). |
| `Weaver__2001_NotesforTableA-15.csv` | Structured notes: `note_id, variable, taxon_group, data_source, note_text`. |
| `reference_tables/Weaver__2001_NotesforTableA-15_definitions.csv` | Data dictionary. |

## Summary of the provenance

- Extant monkeys & pongids: brain and cerebellar volumes from **MRI**.
- Recent *Homo sapiens*: brain volume & body mass from **Beals et al. 1984**; cerebellar volume = mean of **Riedel et al. 1989; Rilling & Insel 1998; Semendeferi & Damasio 2000; Snyder et al. 1995**.
- Fossil hominids: cerebellar & endocranial volumes from **3-D virtual scanned models** (Weaver's own); cranial-capacity→brain-volume→brain-mass conversion via **Ruff et al. 1997**.
- Body mass: *H. erectus* / archaic / early-modern *H. sapiens* from **Ruff et al. 1997**; australopithecines & *H. habilis* from **McHenry 1992b**.

## Data role

`info` / `note` — provenance metadata; not merged.
