# Rosenberg 1935 — Table I, monthly nerve-tissue respiration

**Item:** `Rosenberg__1935_TableI` · **encoded:** `ArchIntPhysiol41_434-445_TableI`

Rosenberg, J. (1935). Métabolisme du tissu nerveux de la grenouille
(« Rana esculenta L. ») pendant le repos. *Archives Internationales de
Physiologie* **41**, 434–445. Held PDF:
`Rosenberg-1935-Metabolism of nerve tissue of t.pdf`.

## Source and build

Table I is on printed p. 436 / held PDF p. 4. Its 11 month rows report oxygen
absorbed by isolated brain, spinal cord, cerebrospinal axis, and sciatic nerve,
as mm³ O₂ per g tissue per hour. The table gives the number of experiments,
extremes, and (for some rows) **probable error of the mean in percent**. Rosenberg
says on p. 437 that respiratory values were normalized to **20 °C** with a
coefficient of 2.2 per 10 °C. These are tissue measurements at rest, not whole
animal or in vivo cerebral metabolic rates. No individual frog identifiers are
provided.

The PDF has an OCR text layer, but its rotated table headings and digits are
unreliable. `Rosenberg__1935_TableI_snapshot.csv` is a hand transcription from
the page image inspected at 160 dpi on 2026-11-25. A human visual signoff is
still pending. Empty printed cells remain empty. The R script reads the frozen
snapshot without embedded values, makes one row per reported tissue-month cell,
parses the printed ranges, and adds only the unit conversion **mm³/g/h ÷ 600 =
cm³/100 g/min**. The source's probable error is retained under its own name;
it is not reclassified as a standard error.

Run from anywhere:

```sh
Rscript Rosenberg__1935/Rosenberg__1935_TableI.R
Rscript Rosenberg__1935/Rosenberg__1935_TableII.R
Rscript Rosenberg__1935/Rosenberg__1935_Mink1981_audit.R
```

Outputs: `Rosenberg__1935_TableI.csv` (28 reported tissue-month means),
`__Public/comparative-data/ArchIntPhysiol41_434-445_TableI.tsv`, the
item definitions, and the separate Mink comparison audit. The raw source
species label is kept as *Rana esculenta L.*

## Mink et al. 1981 citation check

Mink et al. (1981) Table 1, printed p. R208, reports *Rana pipiens* spinal
metabolic rate **2.60 cm³ O₂/100 g/min**, with reference 82 = Rosenberg 1935.
Mink's prose on p. R204 says Rosenberg found a spinal rate approximately
**90%** of brain rate in a **European frog**. Rosenberg did **not** measure
*Rana pipiens* or report a rate of 2.60 in Mink's units. In Rosenberg Table I,
the unweighted ratio of the spinal and brain means for the seven months that
report both is **0.92044**. Multiplying Mink's own modeled frog brain rate
2.83 by this ratio gives **2.60485**, very close to its printed 2.60. This
numerical match does not establish Mink's exact calculation; its text rounds
the source relation to 90%.

`Rosenberg__1935_Mink1981_audit.csv` computes those values directly from the
built Rosenberg and Mink tables. The supported source claim is the approximate
**within-species tissue ratio** for *R. esculenta*. Mink's *R. pipiens* spinal
rate is a **cross-species extrapolation from a model brain rate**, not a direct
Rosenberg observation. Do not substitute Rosenberg's raw tissue values for
Mink's modeled rate or count them as independent *R. pipiens* data.

Table II provides a second check; see `Rosenberg__1935_TableII.README.md`.
