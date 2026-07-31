# Gabi, Neves, Masseron, Ribeiro, Ventura-Antunes, Torres, Mota, Kaas & Herculano-Houzel 2016 — prefrontal cortex neuron counts

Gabi M, Neves K, Masseron C, Ribeiro PFM, Ventura-Antunes L, Torres L, Mota B, Kaas JH,
Herculano-Houzel S (2016). *No relative expansion of the number of prefrontal neurons in
primate and human evolution.* PNAS 113(34):9617–9622. doi:**10.1073/pnas.1610178113**

## Why it's here (coverage gap — finer REGIONS)

Isotropic-fractionator counts that split the **cerebral cortex into a prefrontal (frontal)
portion vs. the rest of the cortex** (grey and white matter), for human + several
non-human primates. The species are already in the merge (from HH 2015), but their
**prefrontal-specific cell counts are not** — the merge currently has only whole-cortex
`CerebralCortex_N.n`. This paper is the strongest "more regions" addition.

⚠️ **Confirm the exact table** (main-text table vs. supplementary dataset) and species
roster / measured columns from the PDF before finalising `<N>` in the filenames — rename
`Table1` to the printed label if the data live in a supplementary table.

## Region scheme — NEW regional (needs the design decision)

See `__merging_cellcounts/HH_coverage_gaps_scaffold.md` → "Design note". Recommended
vocabulary (kept **separate** from whole-cortex, never pooled/averaged into it):

- `PrefrontalCortex_N.n`, `PrefrontalCortex_O.n` (± grey/white split:
  `PrefrontalCortexGrey_N.n`, `PrefrontalCortexWhite_N.n`)
- `RestOfCortex_N.n`, `RestOfCortex_O.n` (the non-prefrontal remainder, so prefrontal +
  rest reconciles to whole-cortex)
- `PrefrontalCortex_Mass.g` where reported

Do **not** map any Gabi column onto `CerebralCortex_N.n` — that whole-cortex value already
comes from HH 2015 and the newest-wins dedup would otherwise fight over it.

## Needs (blockers)

- [ ] PDF (+ supplementary dataset) into `Gabi_etal_2016/`.
- [ ] Region-scheme decision (recommended vocabulary above) — one decision covers Gabi 2016,
      Ribeiro 2013 and HH 2013 mouse.
- [ ] Register the table in `__ReadMe.xlsx` Sheet1 (`Data role = primary`).
- [ ] Fill extraction in `Gabi_etal_2016_Table1.R` + the standardized-terms stub.
- [ ] Uncomment `"Gabi_etal_2016_Table1"` in `cellcounts_compiled.R` `item_name`; re-run.

Status: **SCAFFOLD** — folder + README + stub `.R` + definitions stub only. Not merged.
