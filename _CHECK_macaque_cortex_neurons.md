# Collins et al. 2010, case 08-59 (Macaca mulatta): is 1.36 billion neurons one hemisphere or the whole cortex?

Checked 2026-11-24 after the question came up in chat: the IF merge carries
Neocortex_right_N.n = 1,361,451,374 for this case and a whole-Neocortex figure of
2,722,902,748, which is exactly twice the right side. If the paper's 1.36 billion
were a whole-cortex figure, the doubled value would be a 2x error. It is not.

## Verdict: 1.36 billion is ONE hemisphere. The doubling is a symmetry assumption, not an error.

## Evidence

1. **The paper's design is single-hemisphere throughout.** Collins, Airey, Young,
   Leitch & Kaas (2010), "Neuron densities vary across and within cortical areas in
   primates", PNAS 107(36):15927–15932 (PMC2936588), abstract: "The numbers and
   proportion of neurons in areas and regions of cortex were determined for **a
   single cortical hemisphere** from two prosimian galagos, one New World owl
   monkey, one Old World macaque monkey, and one baboon."

2. **The paper's cortex-wide phrasing refers to that hemisphere.** Results:
   "Of the nearly 3.5 billion cells in the macaque cortex, 40% (1.4 billion) were
   neurons"; Discussion: "our results using the isotropic fractionator estimated
   1.36 billion neurons in the macaque cortex". Read against the design, "the
   macaque cortex" in both places is the one hemisphere studied.

3. **The dataset's own internal check already benchmarks it that way.**
   Collins_etal_2010/internal_checks/Collins_etal_2010_DatasetS1_internal_check.csv
   compares the 42-sample sums against the text figures explicitly labelled
   "whole-hemisphere figure of the text":
   - neurons: sum 1,361,451,374 vs Discussion 1.36 billion → +0.11%, PASS.
   - neurons: sum vs Results' rounded 1.4 billion → −2.75% (text rounding).
   - cells: sum 3,412,640,628 vs Results' "nearly 3.5 billion" → −2.50% (text rounding).
   - neuron share: 39.89% computed vs 40% printed → PASS.

4. **The merge's wiring is explicit about sides.** The Collins standardized terms
   map this case's sums to Neocortex_right_* ("Neocortex sum of pieces
   total_neurons (right hemisphere)"), with Neocortex_left_* terms for cases
   measured on the left and Neocortex_unilateral_* for one-hemisphere cases
   generally. The whole-Neocortex value (2 × right) is the merge's symmetry
   doubling, and the measured right-hemisphere value is carried alongside it.

## What remains true

- No left-hemisphere measurement exists for this animal; the whole-neocortex
  figure is an estimate under a symmetry assumption, and anyone citing it should
  cite the right-hemisphere sum as the measurement.
- HH2015's 1.71 billion (whole cerebral cortex incl. hippocampus, both
  hemispheres, compiled) is a different quantity from a different source; the
  two are not in conflict once Collins' figure is read as unilateral
  (2 × 1.36 = 2.72 billion neocortex-only vs 1.71 billion cortex+hippocampus
  remains a real difference between the sources, but it is a
  source/method difference, not a doubling artefact).

## Planned: a big macaque cortex check (Michael, 2026-11-24 — for later, not started)

Michael's suspicion (2026-11-24): the HH2015 mulatta value may not hold up,
because the HH team's unpublished workbook (below) does not list the species.
Per-hemisphere neocortex/cortex neuron numbers for *Macaca mulatta* as they
stand: Christensen 1.35B, Charvet 1.31B, Collins 1.36B — against
Herculano-Houzel 0.855B (1.71B whole cerebral cortex ÷ 2). Three independent
groups converge at ~1.3–1.4B; the HH figure stands alone. A single big check,
deferred to later, should put every source on the table at once:

**Papers to check (the two independent arbitrators are NOT in the dataset):**

1. **Christensen et al. 2007**, "Neocortical and hippocampal neuron and glial
   cell numbers in the rhesus monkey", Anat Rec 290:330–340
   (doi:10.1002/ar.20504). Pakkenberg group; optical fractionator; n=8 right
   hemispheres; mean unilateral neocortical neurons 1.35 × 10^9 (CV ±0.10),
   glia 0.78 × 10^9, neuron/glia ratio 1.77; hippocampal subregion counts
   (CA1, CA2-3) also reported. Not registered, no folder.
2. **Charvet et al. 2017**, "Combining diffusion MR tractography with
   stereology highlights increased cross-cortical integration in primates",
   J Comp Neurol 525:1075–1093 (doi:10.1002/cne.24115). Finlay/Charvet lab;
   optical fractionator; unilateral isocortical neurons split upper/lower
   layers: *M. mulatta* 910.86M + 394.95M = 1.31B (n=1, F, brain 103.08 g);
   *M. maura* 964.69M + 508.13M = 1.47B; *Papio hamadryas* 2.51B,
   *P. papio* 2.71B. The paper itself notes its rhesus value matches
   Christensen's. Not registered, no folder. (It also re-uses Charvet et al.
   2015/2016 data for six other species.)

**The unpublished file to check:**

3. **"2020-PublishedDataMammalsMicroglia - cópia.xlsx"** — the HH team's
   unpublished dataset in the restricted repo
   (Evo-M1-Trait-Data-restricted), the source spreadsheet behind Dos Santos
   et al. 2020's `_I.*` values in the IF merge. Check its macaque cortex rows
   directly: it carries cortex rows for *M. fascicularis* (1,404,683,000
   neurons, 40 g) and *M. nemestrina* (2,194,785,386, 76.964 g) but, per the
   2026-11-24 discussion, **no *M. mulatta* cortex rows at all** — verify
   that absence and inventory exactly which Macaca species/structures it does
   hold.

**Anchors already in the dataset, to be read alongside:**

- HH2015 Table 1 mulatta cortex rows (cite HH2007). UPDATE 2026-11-24:
  HH2007's SI Table 2 has since been fetched, and HH2015's mulatta structure
  cells match it cell-for-cell (cortex 69.832 g, neurons 1.71 × 10^9, other
  cells 5.27 × 10^9; the SI confirms n = 2, so HH2015 Table 5's n = 1 is the
  deviant figure). The provenance question is closed — the value is HH2007's
  own measurement; the cross-method disagreement above stands. Transcription
  and cell-by-cell check: project working files `evom1-hh2007-si/`.
- Gabi et al. 2010 (fascicularis 800,960,000 / 36.226 g; radiata 1.66B /
  48.274 g; printed counts are themselves 2× single-hemisphere).
- Dos Santos et al. 2020 published Table 1 vs the unpublished workbook.
- Collins et al. 2010 (this note) and Collins et al. 2016 cortical-sheet
  distributions (4 macaque hemispheres: nemestrina, 2× radiata, mulatta;
  hemispheric neuron totals 1.3–1.7B).
- Young et al. 2013 and Rockel et al. 1980 are densities, not totals —
  context only. O'Kusky & Colonnier 1982 (area 17 only) and the vervet
  frontal-cortex stereology are partials, not arbitrators.

**Scope of the check when it runs:** reconcile per species and per structure
(neocortex vs cerebral cortex incl. hippocampus), per hemisphere vs doubled,
neurons separately from non-neuronal cells (the glia counts diverge across
all sources even where neuron counts converge), and settle what the dataset
should carry for *M. mulatta* cortex neurons and on what provenance.
