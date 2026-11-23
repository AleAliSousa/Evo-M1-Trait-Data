# Caspar et al. 2022 — Table 1 (hand preference / laterality)

Caspar KR, Pallasdies F, Mader L, Sartorelli H, Begall S (2022). *The evolution and biological
correlates of hand preferences in anthropoid primates.* eLife 11:e77875. doi:10.7554/eLife.77875

Full table title: **"Table 1. Hand preference data for the 38 anthropoid primate species examined."**

## What this measures (and overlap)
This is a **handedness / laterality** table — hand *preference* (direction and strength), not manual
*dexterity* or manipulation skill. So it does **not** overlap the trait measured by Heffner &
Masterton / Iwaniuk 1999 (digital dexterity) or Heldstab 2016 (manipulation complexity), even
though it shares primate species with them (17 species in common with Heldstab 2016). Its
brain-size companion data are in Supplementary File 3.

## Source → Snapshot
Article PDF (open access); Table 1 (in two parts) exported to Excel via Acrobat and hand-formatted
into `Caspar_etal_2022_Table1_snapshot.xlsx` (frozen).

## Data readable
`Caspar_etal_2022_Table1.R` → `Caspar_etal_2022_Table1.csv` (**use this**). Removes the heading
rows, forward-fills the merged genus-level cells (`nGenus` and the two genus p-values — the `NA`
for *Pithecia pithecia* is genuine and preserved), and splits the three combined frequency(%)
columns into six. Columns defined in `reference_tables/Caspar_etal_2022_Table1_definitions.csv`.

## Species note
`Species` holds the binomials as printed; a `Species note` column carries common-name / subspecies
annotations added during compilation. Reconcile to `_keys/Stephan/species_key.csv`.

Pipeline: Source → Snapshot ✅ → Data readable ✅ → Species note ✅ → Online database ✅
(`10.7554%2FeLife.77875_Table1.tsv` in `__Public/comparative-data/`)
