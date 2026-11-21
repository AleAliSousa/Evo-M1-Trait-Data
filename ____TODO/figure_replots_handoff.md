# Handoff: simple replots for previously extracted figures

Requested by AAdS on 2026-11-20. Status: **open backfill; three-item pilot complete**;
Itoh Figure 2 is the worked example. The request is to leave a small, readable R script in each paper
folder so the extracted data can be plotted again and their shape checked easily.
The standing rule is in `AGENTS.md`, the constructed-snapshot HOWTO, and the
dataset-build done checklist.

## Completed example

- `Itoh_etal_2001/Itoh_etal_2001_Figure2_replot.R` reads the existing item CSV;
  the adjacent `_replot.png` shows all 19 regions and three genotypes with the
  extracted upper error endpoints. Its item README documents how to run it and
  which source annotations are omitted. Use its approach, not its bar-chart
  geometry, for other figure types.

## Next action: identify and work through past figure items

Start with the registry's source-format field and the item READMEs to distinguish
actual extracted figure data from author-supplied figure-data tables, figure
legends, crosschecks, derived summaries, or archived copies. A filename-only
scan on 2026-11-20 found **107 candidate CSVs in 58 paper folders**, including
Itoh and false positives; this is a discovery count, not a verified backlog.
Figures can also have names that do not contain `Fig`, so the registry/README
pass is required for completeness. Do not count `_snapshot.csv`, reference tables,
public duplicates, merges, backups, or archives as separate live items.

Reproduce the initial candidate list from the repo root:

```python
from pathlib import Path
import re
for p in sorted(Path('.').glob('*/*.csv')):
    if (not p.parts[0].startswith('_')
            and re.search(r'fig(?:ure)?s?\d', p.stem, re.I)
            and not p.stem.endswith('_snapshot')):
        print(p)
```

Initial candidates to inspect include Babushina_etal_1991 Figures 1–3,
BallesterosYáñez_etal_2006 Figure 3A–C, Barks_etal_2014 Figures 4A and 5A,
Bartlett__2003 Figures 4–5, Chang_etal_2015 Figures 2 and 4,
Heffner_etal_2013 Figure 2, and Hevner_etal_1995 Figures 31–32.
Re-check disk state before working: other sessions may be adding papers.

## Per-item work and completion criteria

1. Read the source figure/caption, item README, and extracted CSV. Identify
   original axes (including log axes), units, series, panels, category order,
   and whether uncertainty endpoints were actually extracted.
2. Add `<Item>_replot.R` beside `<Item>.csv`. Prefer base R and direct column
   selection plus only the reshaping/unit conversion needed to reproduce the
   source's shape. Read measurements from the extracted table; do not embed them
   in code, aggregate away observations, interpolate, refit, or smooth.
3. Preserve distinctions between panels, species, cohorts and series. Draw
   extracted uncertainty if available; do not invent uncertainty or call it
   SEM/SD without source evidence. Label missing panels/series/error bars and
   document deliberate presentation simplifications.
4. Save `<Item>_replot.png` in the paper folder. Run from a clean R session,
   inspect beside the source, and check shape, axes, ordering and labels.
   Keep scripts standalone and simple; no registry lookup, network access,
   digitization rerun, merge pipeline or new plotting framework is needed.
5. Add the run command, input/output filenames, omissions, and dated review
   result to the item README. Record a discrepancy as an open issue; do not
   adjust extracted values to make the plot look right. Do not mark human
   visual signoff on the strength of an assistant's inspection.
6. Track each verified item below, with script path, review result and any
   blocker/next action. Mark excluded candidates with the reason. The backfill
   is complete only after the registry/README sweep, every applicable live
   figure has a runnable script and inspected output, and gaps are explicit.

| Item | Status | Script / review / next action |
| --- | --- | --- |
| Itoh_etal_2001_Figure2 | Complete replot | `Itoh_etal_2001/Itoh_etal_2001_Figure2_replot.R`; human source signoff remains pending. |
| Babushina_etal_1991_Figure1 | Pilot replot complete | `Babushina_etal_1991/Babushina_etal_1991_Figure1_replot.R`; 12 extracted curve-1 points; source log10-kHz axis retained; source smooth curve and other species not extracted. No new shape discrepancy. |
| Bartlett__2003_Figure5 | Pilot replot complete | `Bartlett__2003/Bartlett__2003_Figure5_replot.R`; 12 monthly stacks, Groom below Play, February–January. No new shape discrepancy. |
| Barks_etal_2014_Fig4A | Pilot replot complete; source review open | `Barks_etal_2014/Barks_etal_2014_Fig4A_replot.R`; 52 bars, all subjects, raw cm³ only. Source +1 SD bars not extracted. Small frontal-GM species contrasts appear reversed; independently re-digitise the four frontal-GM bars and verify species/hemisphere assignments (see paper README). |
| Chang_etal_2015_Figure2 | Excluded from numeric shape pilot | README and CSV contain seven categorical pass/fail outcomes constructed from prose; bar heights were not extracted. Do not invent numeric heights to mimic the source. Any future numeric figure extraction is separate work. |
| Other past figures | Open | Complete inventory against registry and READMEs, then add and inspect replots item by item. |

## Pilot outcome (2026-11-20)

The three selected items were checked against the live registry, item READMEs,
extracted CSVs and local source PDFs. Each script uses base R only, reads its own
CSV, and writes only the adjacent `_replot.png`. Each was run with both
`Rscript --vanilla` and `source()` in a clean session; the PNGs were inspected
against the published figures. Review notes and omissions are recorded in the
paper READMEs (Barks uses its existing shared `FigVolumes_README.md`).

The pilot covers points on an already-logarithmic axis, stacked bars and grouped
bars. It shows why a completed replot and a passed extraction review must remain
separate statuses: Barks now has a usable visual check plus a specific open
source-review action. Measurements were not adjusted. The Chang exclusion also
confirms that a `Figure` filename need not contain numeric figure data. No full
backlog count or human visual signoff is claimed.

This handoff does not request a rebuild of the source datasets, registry,
public TSVs or merges. Retain existing extraction evidence and measurements.
