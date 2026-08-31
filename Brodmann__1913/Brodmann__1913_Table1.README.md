# Brodmann 1913 (Verhandlungen) — Table 1 (total cortical surface & brain weight, mammals)

Brodmann K (1913). *Neue Ergebnisse über die vergleichende histologische Lokalisation der
Grosshirnrinde…* Verhandlungen der Anatomischen Gesellschaft (Ergänzungsheft zum Anatomischen
Anzeiger 41), 157–216. (No DOI; catalogued under alt id `OCLC:8777719`.)

Registry (`__ReadMe.xlsx`): Item name **`Brodmann__1913_Table1`**, encoded `OCLC%3A8777719_Table1`.

## Why this was built (relation to Smaers 2017)
Smaers et al. 2017 used Brodmann only for a **4-region cortical *surface-area* subset across 10
primates** (`Smaers_etal_2017/comparison/Brodmann_surface_1909.csv`: primary visual, prefrontal,
other association, frontal motor). Brodmann's original Table 1 is much broader — it is the source's
**total cortical surface, sulcal cortex, and brain weight for ~38 taxa spanning every mammal order**
(humans through monotremes). None of those totals, the sulcal-cortex column, the brain weights, or
the non-primate species are in Smaers's subset, so this is genuinely additive data.

## What the data are
One row per taxon (**38 rows**): `CorticalSurface_1hemisphere.mm2` (Rindenfläche of one hemisphere),
`SulcalCortex.mm2` + `SulcalCortex_pct` (Furchenrinde), and `BrainWeight.g` (+ parenthetical
`HemisphereWeight.g`). Surface spans 76 mm² (shrew) to 301,843 mm² (elephant). Sulcal cortex is blank
for the small-brained species where Brodmann reported none (rodents, most insectivores, etc.).

## ⚠️ Reading method & fidelity (scanned 1913 Fraktur)
The `pdftotext` OCR of this 1913 German paper is unreliable (mis-aligned columns, `=`/`:`/`-`
confusion, split rows). Table 1 was therefore **transcribed from a 200-dpi render of the page**
(p.206), read cell-by-cell — the house approach for scanned sources (cf. Weaver 2001). Two notes:
- The human rows carry historical terms verbatim (`Naturmenschen`, `Idioten`); preserved as printed,
  not endorsed.
- Human brain weights (1590/1327) align to the max/min surface rows respectively; the average-surface
  and Naturmenschen/Idioten rows have no weight given.

## Taxonomy (printed names preserved)
`Species_Brodmann1913` and `Genus_printed` keep Brodmann's German + (often obsolete) Latin names
(`Hapale`, `Anthropopithecus`, `Cynocephalus`, `Putorius`, `Centetes`, `Phalangista`, `Proechidna`…).
`Species` gives a best-effort modern binomial, left at **genus + sp.** where the species isn't
determinable (e.g. *Cercopithecus* sp., *Phoca* sp., *Elephas* sp.). A `_keys` harmonisation pass
(token `Brodmann1913`) should be added before any merge.

## Source → Snapshot → Data readable  (scanned PDF → snapshot required)
`Brodmann_1913_Verhandlungen.pdf` p.206 → **`Brodmann__1913_Table1_snapshot.xlsx`** (faithful, German
names, qmm values) → `Brodmann__1913_Table1.R` (to be run in R) → **`Brodmann__1913_Table1.csv`** (use
this) + the public TSV `__Public/comparative-data/OCLC%3A8777719_Table1.tsv`. Columns:
`reference_tables/…_definitions.csv`.

## Remaining Brodmann tables (not yet built)
This paper has five more tables worth mining for additional species/regions:
- **Tabelle 2** (p.~24) — individual European + brain-weight values.
- **Tabelle 3** (p.25) — regional surface measurements (the block Smaers's 4 regions come from).
- **Tabelle 4 & 5** (pp.29–36) — visual cortex (Sehfläche) surface, absolute & relative.
- **Tabelle 6** (p.42) — olfactory cortex (Riechfläche) surface.
Building these would capture the extra species/regions beyond Smaers's primate subset.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → definitions ✅ → README ✅ → catalog row (added) · comparison vs Smaers subset ⬜.
