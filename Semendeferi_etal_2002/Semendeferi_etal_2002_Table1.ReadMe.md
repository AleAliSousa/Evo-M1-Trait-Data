# Semendeferi et al. 2002 — Table 1 (relative size of frontal cortex)

Semendeferi K, Lu A, Schenker N, Damasio H (2002). *Humans and great apes share a large frontal
cortex.* Nature Neuroscience 5(3):272-276.

Full table title (for `__ReadMe.xlsx`): **"Table 1. The relative size of the frontal cortex"**

## Source -> Snapshot
PDF p. 3 (text layer, clean). `Semendeferi_etal_2002_Table1_snapshot.csv` keeps all three columns as
printed: Brodmann 1909 & Blinkov & Glezer 1965 (frontal cortex as % of cortical **surface**) and the
Present study (frontal cortex as % of cortical **volume**), incl. "x (± sd)" and "x and y" cells, NA.

## Data readable
`Semendeferi_etal_2002_Table1.R` -> `Semendeferi_etal_2002_Table1.csv` (use this).
**IMPORTANT: `frontal_cortex_pct_of_cortex_volume` is a PERCENTAGE, not an absolute volume.** Absolute
frontal-lobe volumes are in Semendeferi et al. 1997 (J Hum Evol 32:375-388), which is not in this
folder. Two specimens for gorilla and Cebus (mean reported; see note). Macaque/Cebus binomials are
genus-level ("sp.").

## Provenance
Primary MRI (Semendeferi/Damasio). Covers Frontal lobe relatively; complements Smaers (frontal grey/
white) and the absolute frontal lobe of Semendeferi 1997. Does NOT fill parietal/temporal (that is
Semendeferi & Damasio 2000, not in folder).

## Species note
Reconcile to `_keys/Stephan/species_key.csv`; resolve Macaque/Cebus to species; orangutan pygmaeus vs abelii.

Pipeline: Source -> Snapshot OK -> Data readable OK -> Species note (in progress) -> Online database
