# Andelin et al. (2019), Table 4

Source: `Andelin-2019-The Effect of Onset Age of Visual.pdf`, PDF p. 6,
“Human surface area means by hemisphere.”

The snapshot CSV sketches the printed nine-column table: caption, two-tier
headers, four group rows in source order, and the area-unit footnote. The
thousands spaces in cortex areas are retained. The former snapshot flattened
the header tiers and omitted the caption and footnote; those source-layout
details were restored in the snapshot and extraction script on 2026-11-27.

`Andelin_etal_2019_Table4.R` reads the data rows from that layout, assigns
analysis names, and converts cortex areas and event times. Rebuild check:

```sh
Rscript --vanilla Andelin_etal_2019/Andelin_etal_2019_Table4.R
```

The resulting four-row analysis CSV was byte-identical to the pre-correction
CSV. No human visual signoff is claimed.
