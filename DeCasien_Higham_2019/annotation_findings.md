# DeCasien & Higham (2019) MOESM3 — annotation findings

Follow-up to the user's annotations in `DeCasien_vs_merge_comparison_DeCasien_changethis4.csv`
(last column, "DO THIS"). 66 rows were annotated. They fall into four classes: **A** (values
Barks/Sherwood never published, recovered via DeCasien), **B** (DeCasien reported a value that
disagrees with its cited source), **C** (value exists in a cited table but needed a
conversion/crosswalk to match), and **D** (a taxonomy/attribution problem).

This document covers the **B** and **D** findings and the re-sourcing outcome for the two rows
flagged during review (Propithecus, Loris). The **A** recoveries are delivered as two new datasets
(`Barks_etal_2014_viaDeCasien2019`, `Sherwood_etal_2004_viaDeCasien2019` — renamed 2026-08-19 from `*_unpublishedviaDeCasien`; see CHANGES.md); the **C**
conversions are wired into `DeCasien_Higham_2019_SupplementaryData1-BrainRegion.R`. Both are
described in `CHANGES.md`.

All 65 of the 66 annotated rows now resolve off `decasien_only` in the regenerated comparison. The
Nomascus concolor BV cell (a class-D misattribution, see below) is now also resolved: it and its
companion Nomascus concolor Amygdala cell were reclassified as
`decasien_duplicate_of_Hylobates_lar_Disco` (the Disco / GPZ-5542 specimen; see
`Disco_gibbon_specimen_note.md` and `Disco_gibbon_DeCasien_resolution.md`).

Two `decasien_only` cells remain, both **unrelated to the annotated set and unrelated to Disco**, and
both are **merge-side ingestion gaps rather than DeCasien errors** (all values reproduce Bush & Allman
exactly):

- *Cheirogaleus medius* Neocortex (GM) = 890 = Bush & Allman 2004a Table 2 `neo_grey` 0.89 cm3.
  The merge ingested Bush & Allman 2003 (no *Cheirogaleus*) and 2004b (V1/LGN) but **not** 2004a
  Table 2, so there is no Bush neocortex cell for *Cheirogaleus* to match. Fix: ingest 2004a Table 2.
- *Mandrillus sphinx* Neocortex (GM+WM) = 99260 = Bush & Allman 2004a `neo_grey`+`neo_white`
  (71.33+27.93) cm3. The merge holds the grey (71300) and white (27900) as separate rows but never
  summed them into a `Neocortex_Vol.mm3` total, so the GM+WM crosswalk has no target. Fix: add a
  summed GM+WM neocortex for Bush sources (99260 vs 2004a exact; 99200 / 0.06% vs the 2003 components).

---

## Class B — DeCasien value disagrees with its cited source

These are cells where the *structure* is present for the *same taxon* in a source DeCasien cites,
but DeCasien's number does not reproduce it. In the regenerated comparison these now carry status
`description_match_value_mismatch` (flag `description_match_value_differs`): a comparison **was**
possible, and the CSV records the nearest same-structure source value in the `mismatch_source /
mismatch_value / mismatch_pct` columns rather than leaving the cell blank. These are flagged for
human review, **not** asserted as matches.

| Taxon | Region | DeCasien | Cited source's value | Diff | Interpretation |
|---|---|---|---|---|---|
| *Avahi laniger* | BV | 10060.9 | Stephan 1981 `Total_brain_net_volume` = 9798 (*A. l. laniger*); 9124 (*A. l. occidentalis*) | +2.7% / +10.3% | DeCasien's value sits between the two Stephan 1981 subspecies rows and above both. Likely a subspecies-averaging or transcription variant of the Stephan 1981 net brain volume — it is close to, but not equal to, the *laniger* row. |
| *Tarsius syrichta* | MOB | 79.2 | Stephan 1981 `Bulbus_olfactorius` (*Tarsius sp.*) = 18.8 | +321% | **Not** a small transcription slip — DeCasien's 79.2 is ~4× the only olfactory-bulb value available for *Tarsius* in the Stephan tables. This looks like a wrong cell was pulled (a different structure or a different taxon's MOB), and it should not be treated as a *Tarsius* MOB value without checking DeCasien's original source cell. |

Two further **C**-annotated rows also ended in this tier because their cited value differs beyond
the 2% match tolerance (see Class C in `CHANGES.md`):

| Taxon | Region | DeCasien | Nearest same-structure source | Diff |
|---|---|---|---|---|
| *Loris tardigradus* | BV | 6771.2 | Stephan 1981 / 1970 `Total_brain_net_volume` = 6269; Bauernfeind 2013 = 6612 | +8.0% / +2.4% |
| *Saimiri sciureus* | Amygdala | 277.0 | Stephan 1981 = 227; Stephan 1987 = 242.4 | +22% / +14% |

For *Loris* and *Saimiri* the merge **does** hold the structure for the taxon, so the disagreement
is DeCasien-side; the recovered nearest values are now visible in the CSV for adjudication.

---

## Class D — taxonomy / attribution problem: *Nomascus concolor*

The user asked, of DeCasien's two *Nomascus concolor* cells: *"Barger et al 2014 say the data in
Table 1 for Nomascus concolor was published in Barger et al [2007], but that species is not found
there. Did they call it Gibbon?"*

**Answer: yes.** Both *Nomascus concolor* values reproduce a ***Hylobates lar*** (gibbon) source
value exactly:

| DeCasien cell | Value | Exact match |
|---|---|---|
| *Nomascus concolor* BV | 115800 | *Hylobates lar* BV = 115800 (de Sousa et al. 2010 Table 1) |
| *Nomascus concolor* Amygdala | 637 | *Hylobates lar* `amygdaloid_complex_total` = 0.637 cc → 637 (Barger et al. 2007 Table 1) |

Barger et al. 2007 Table 1 contains only *Homo sapiens, Pan troglodytes, Pan paniscus, Gorilla
gorilla, Pongo pygmaeus,* and ***Hylobates lar*** — no *Nomascus*. DeCasien's amygdala value of 637
is precisely the first *Hylobates lar* individual's total amygdaloid complex (0.270 + 0.367 = 0.637
cc). The BV of 115800 is precisely the *Hylobates lar* brain volume de Sousa et al. 2010 report.

**Conclusion:** DeCasien assigned *Hylobates lar* source values to *Nomascus concolor*. This is a
**species misattribution in DeCasien**, not a missing source. The underlying numbers are real
gibbon measurements; they are simply filed under the wrong genus. In the comparison the BV cell
stays `decasien_only` because the merge carries that 115800 value under *Hylobates lar*, not
*Nomascus* (a genus-restricted search cannot cross to it); the amygdala cell lands in
`description_match_value_mismatch` against the *Nomascus*-genus Barger2014 rows. Neither should be
"fixed" by adding a *Nomascus* record — the correct action is to note the misattribution.

---

## Re-sourcing outcome for the two review-flagged rows (Propithecus, Loris)

During review it was noted that two class-C rows appeared not to reproduce from the source DeCasien
cites. Both were chased down:

- ***Propithecus verreauxi* LGN 70** — DeCasien's annotation implied the value comes from Bush &
  Allman (2004b), but that table contains **no** *Propithecus*. The value is instead recoverable
  from Stephan: `Corpus_geniculatum_laterale` = 68.6 (Stephan 1981) and 64.5 (Stephan 1984/1970).
  In the regenerated comparison it now matches **Frahm & Zilles 1994** LGN = 70.93 at 1.3% (same
  genus, same structure). So it is a genuine **class-C in-pool match**, not a re-sourcing failure;
  the cited source (Bush & Allman) was simply imprecise.

- ***Loris tardigradus* BV** — an earlier automated check reported "Loris absent from Stephan 1981."
  That was a **false negative**: the search read the wrong column (the specimen `code` column, not
  `Species`). *Loris tardigradus* **is** in Stephan 1981 with `Total_brain_net_volume` = 6269. It is
  therefore a **class-C value-difference** (DeCasien 6771 is +8% vs Stephan, +2.4% vs Bauernfeind
  2013's 6612), now surfaced in the `description_match_value_mismatch` tier — not a missing source.

Net: neither row required re-sourcing to an outside dataset. Both are in-pool; one matches within
tolerance (Propithecus), the other is a flagged value-difference (Loris). The correction to the
earlier undercount (only Propithecus named as a miss) is recorded here for the audit trail.
