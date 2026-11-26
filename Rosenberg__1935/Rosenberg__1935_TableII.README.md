# Rosenberg 1935 — Table II, winter and spring respiration

**Item:** `Rosenberg__1935_TableII` · **encoded:** `ArchIntPhysiol41_434-445_TableII`

Rosenberg, J. (1935). Métabolisme du tissu nerveux de la grenouille
(« Rana esculenta L. ») pendant le repos. *Archives Internationales de
Physiologie* **41**, 434–445.

Table II appears on printed p. 438 / held PDF p. 6. It prints six experiments
and one mean for each combination of winter/spring frogs and four isolated
tissues (brain, spinal cord, cerebrospinal axis, sciatic nerve). Oxygen is in
mm³ O₂ per g tissue per hour, normalized to 20 °C according to p. 437.
The experiment numbers are table rows, **not specimen IDs**, and no cross-tissue
individual matching is asserted.

`Rosenberg__1935_TableII_snapshot.csv` was transcribed from the 190-dpi page
image on 2026-11-25; the OCR text layer was not used for numeric extraction.
Human visual signoff is pending. `Rosenberg__1935_TableII.R` reads that frozen
snapshot, retains each of the 48 experiment cells and eight printed means as
separate rows, checks each mean against its six source values (within rounding
to a whole unit), and writes `Rosenberg__1935_TableII.csv` and
`__Public/comparative-data/ArchIntPhysiol41_434-445_TableII.tsv`. It converts
units by dividing by 600 and makes no inferential adjustment.

Run `Rscript Rosenberg__1935/Rosenberg__1935_TableII.R` from the repo root.
To reproduce the Mink comparison, run
`Rscript Rosenberg__1935/Rosenberg__1935_Mink1981_audit.R` after both table
builders. Table II's printed means give spinal/brain ratios of **187/211 =
0.886** for winter frogs and **188/204 = 0.922** for spring frogs. Both support
Mink's approximate 90% description; neither is a direct *Rana pipiens* rate.
