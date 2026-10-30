# Clancy, Darlington & Finlay 2001 — Table 1 (predicted and empirical timing of 95 neural events in 9 species)

Clancy B, Darlington RB, Finlay BL (2001). *Translating developmental time across mammalian species.* Neuroscience 105(1):7-17. doi:10.1016/s0306-4522(01)00171-3

## Source -> snapshot
`Clancy_etal_2001.pdf` (EndNote record 7053). Table 1 is rotated on PDF pp.4-5 (journal pp.10-11); the text layer does not carry the table, so `Clancy_etal_2001_Table1_snapshot.csv` is a **constructed (transcribed) snapshot** read from 2.5x renders in strips: 95 events x 9 species, wide, in printed order. Per species three columns: `model` (bold, predicted PC day), `empir.` (empirical PC day, blank when none) and `empir. ref` (the superscript source letter(s), kept as a separate column). The first data row is the **species score** printed under each species name (0.663 hamster ... 2.500 human); the second numeric column `score` is the **event score** (the model's event parameter). These two sets are the model's rate/offset-type parameters (species and event positions) and are carried into the clean CSV as `species_score` / `event_score`. The primate limbic/cortex/other adjustment is **not** tabulated in Table 1 (it is visible only through Table 2's three columns per primate).

## Build
`Clancy_etal_2001_Table1.R` -> `..._Table1.csv`, LONG: 855 rows = 95 events x 9 species (predicted_PC_days, observed_PC_days, observed_source_refs, species_score, event_score, parsed event_structure / event_type). TSV is written once the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks (all done on the transcription)
- **Row/cell counts vs paper:** 95 events (46 on p.10 + 49 on p.11); 95 x 9 = 855 predictions; **362 empirical cells** (paper: "found observations ... for 362"); 855 - 362 = **493** unobserved (paper: "493 neural occurrences"). All match.
- **Events observed in one species only:** 3 (red nucleus-peak and vestibular nuclei-peak, rat; isles of Calleja-peak, mouse) — paper: "three of the 95 events ... observed in only one species each". Match.
- **Model vs empirical correlation:** paper states R = 0.9900 for the 362 pairs. Transcribed values give r = 0.9905 on ln(PC days) and 0.9814 on raw days; the paper's value is consistent with the log scale (difference 0.0005 = within the rounding of printed dates; no single mistranscription could be isolated by this check).
- **Internal consistency of predictions:** the 95 x 7 non-primate predicted columns follow a smooth quadratic in ln(PC day) vs event score x species score with max residual 3% (no outlier cell); macaque and human fall into three tight clusters (limbic / other / cortex adjustments), human/macaque ratio constant (ln ratio 0.21-0.24 for all 95 rows).
- **Cross-table check with Table 2:** hamster, mouse and rabbit predicted values agree with Table 2 translated rat day within <= 0.2 PC days; ferret, cat and spiny mouse differ by up to ~0.9, 1.1 and 0.6 PC days when the Table 1 rat value is used as the Table 2 key (linear interpolation on the 0.5-day grid). Looks systematic (a publication-level difference between the two tables, not a transcription slip), kept as printed. See Table 2 README.

## Caveats
- **Predicted vs observed:** the bold model value exists for every cell and is a regression output, not data. Only `observed_PC_days` is empirical. Observed dates are literature-derived (letters a-m, `reference_tables/Clancy_etal_2001_Table1_references.csv`), so this table is **secondary** for observations; for the primary reports use the cited studies. Source `a` (Ashwell et al. 1996) is a tammar wallaby paper that compiles timing in other mammals.
- Superscript letters at 2.5x scale: `l` (Robinson & Dreher) and `i` (Kostovic & Rakic) are visually close; read as `l` throughout (no `i` appears). RA to confirm.
- Species columns are common names: "sp. mouse" = spiny mouse (Table 2 heading); macaque and human have no binomial in the table.
- Lewitus et al. 2014 cites this paper for the **neurogenic period of 4 species**. The comparable quantities are the empirical *start* and *end* neurogenesis events (event_type start / end): retinal ganglion cell generation start+end (hamster 9.5/14, mouse 10.5/18.5, rat 11.5/18.5, cat 19.5/35.5, macaque 30/57 PC days) and dLGN start+end (hamster, mouse, rat, cat, macaque), plus cortical layer II/III, IV, V, VI start/end. Which structure/duration Lewitus used for his 4 values is not stated; the owner should check it against Lewitus's S1 before deciding which events define "neurogenic period".

## RA check still to do
Side-by-side read of the render against the snapshot (95 rows x 27 value columns), especially the superscript letters and multi-letter refs (`a,g,l`, `a,g`, `g,l`).
