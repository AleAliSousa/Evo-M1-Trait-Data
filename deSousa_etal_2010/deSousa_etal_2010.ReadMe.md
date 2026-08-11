# de Sousa et al. 2010 — V1 (area striata) + LGN volumes  [primary anchor]

Working **primary anchor** for the V1 / LGN data that Smaers 2017 used (its supplement ref **S6**).
Two candidate 2010 de Sousa papers — add the relevant PDF(s) to snapshot the original tables:
- de Sousa AA et al. (2010) *Comparative cytoarchitectural analyses of striate and extrastriate areas
  in hominoids.* Cerebral Cortex 20:966-981.  (= Smaers 2017 [S6])
- de Sousa AA et al. (2010) *Hominoid visual brain structure volumes and the position of the lunate
  sulcus.* J Hum Evol 58:281-292.  (= DeCasien ref [60]) — **snapshotted, see below**

## Supplementary Table 2 (J Hum Evol 2010) — faithful snapshot + corrected dataset
Source supplement added: `1-s2.0-S0047248410000023-mmc2.doc` = *"Supplementary Table 2. Primate
species mean volumes"* (Brain, Neocortex, V1/area striata, LGN; mean ± N for ~44 primates). Per the
snapshot pipeline:

| file | role |
|---|---|
| `1-s2.0-S0047248410000023-mmc2.doc` | original published supplement (raw source) |
| `deSousa_etal_2010_SupTable2_snapshot.xlsx` | **snapshot** — frozen, faithful copy of the published table (original layout, spellings, units label "(g)", footnote). **The published error is KEPT here.** |
| `deSousa_etal_2010_SupTable2.R` | snapshot → clean script (applies the corrections below) |
| `deSousa_etal_2010_SupTable2.csv` | **cleaned, "use this"** — corrected neocortex + corrected binomials, with a `correction` column |
| `deSousa_etal_2010_SupTable2_definitions.csv` | column metadata |
| `Sup Table 2 Species Means_corrected.xlsx` | earlier hand-corrected working copy (basis for the corrected values) |

**Source footnote (verbatim):** *"Non-hominoid mean values (except M. fascicularis) are from Stephan
et al (1981, 1988). Hominoid and M. fascicularis mean values were obtained for this study (see Table 1
and text for further details)."*

### Supp. Table 2's V1 and LGN are 2 × the LEFT hemisphere (not an error — an author-side estimate)

Everything in this paper was measured on the left side; the hominoid V1 and LGN means in Supp. Table 2
are the **doubled** figures. Methods, verbatim:

> "In all statistical analyses, left V1 and left LGN volumes were doubled to estimate the total (left
> plus right hemisphere) volumes of V1 and LGN for each specimen because the volumes of V1 (Amunts et
> al., 2007a) and LGN (H. Frahm, unpublished observation) apparently do not exhibit major asymmetries."

Checked: Supp. Table 2 V1 = 2 × mean(Table 1 left V1) exactly — Homo 15.2 = 2×7.63, *Pan paniscus*
11.6 = 2×5.8, *Gorilla* 9.1 = 2×4.55, *Hylobates lar* 4.1 = 2×2.05. The same doubled LGN values are
carried into **de Sousa et al. 2013 Table 1**, which does not restate the convention.

This is **provenance, kept separate from the error flags above.** The published errors in this table
(the prosimian neocortex values, the misspelt binomials) are mistakes and are corrected in the dataset;
the doubling is a deliberate, argued estimator and the values are used exactly as published. It is
registered in `../__merging_volumes/laterality_known.csv` as `doubling = by_source` and surfaces as
`published_bilateral_estimate` in `volumes_flags.csv` — never as an `action = skip` veto.

### Error in the published table (flagged in `__ReadMe.xlsx`)
- **Value error (neocortex).** The **Neocortex ("Neo. vol.") values for the 17 strepsirrhine + tarsier
  (prosimian) species** were mis-copied from Stephan et al. (1981, 1988). **13 of the 17 exceed the
  whole-brain volume of the same species — impossible** (e.g. *Tarsius syrichta* Neo 23.1 vs brain 3.5;
  *Galagoides demidoff* 27.4 vs 3.3). Brain, V1 and LGN are unaffected. → **kept in the snapshot,
  corrected to the Stephan values in the dataset** (see `correction` column).
- **Species-name errors (flagged separately).** 7 binomials are misspelt in the published table
  (`Syndactylus symphalangus`→`Symphalangus syndactylus`, `Cercopithecus mitus`→`mitis`,
  `Sanguinus`→`Saguinus` ×2, `Pithecus monachus`→`Pithecia monachus`, `Lagathricha`→`lagothricha`,
  `tardigradius`→`tardigradus`) → kept in snapshot, corrected in the dataset.

## Current contents (earlier stopgap)
`deSousa_etal_2010_V1LGN.csv` — V1 (area striata grey, = your `ASG_Sousa`), LGN (= `LGN_Sousa`), brain
(= `Brainvol`) for 45 primates, taken from your `Stephan_primates.csv` compilation citing de Sousa 2010.
This was the pre-snapshot compilation (mm³, full precision); the faithful snapshot of Supp. Table 2 now
lives in the files above (cm³, as published). Kept for the Smaers check below; values already match Stephan.

## Why this anchor exists
It lets us verify "the Smaers dataset" (Smaers 2017 Table S1) against the primary V1 values. See
`../Smaers_etal_2017/primary_source_checks/check_primaryvisual_vs_deSousa2010.csv`.

### Check #1 result (Smaers-2017 primary-visual-grey vs this V1)
- **Monkeys: exact match** (9 species, 0.0 diff) — Smaers used your de Sousa V1 directly (cm3 = mm3/1000).
- **Great apes + gibbon: diverge** (Gorilla +32%, Pan +28%, Pongo -15%, Hylobates +12%, Homo -3%) —
  the ape V1 in the Smaers dataset comes from a *different* measurement than your `ASG_Sousa`
  (likely the de Sousa Cereb Cortex 2010 hominoid striate values). Worth pinning which ape source each used.
