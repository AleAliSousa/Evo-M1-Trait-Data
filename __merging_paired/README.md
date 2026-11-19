# Paired neocortex + brain-size extract

Built 2026-11-18 from the post-wiring merge outputs (`__merging_volumes/volumes_long.csv`,
`__merging_brain_mass/brain_mass_long.csv` and their unfiltered files), by
`build_paired_extract.py` in this folder. To regenerate after a merge re-run, run
`python3 build_paired_extract.py` from inside this folder in a repo checkout.

Purpose: for a neocortex-vs-brain-size regression, take both traits for a species from the
SAME source wherever the database allows, instead of the merged (mixed-source) values.

## Pairing rules (in preference order)

1. `same_item_mass` — one dataset item gives the neocortex volume (volumes merge) and a
   measured brain mass (brain-mass merge, pooled-eligible Brain_Mass_measured rows only).
2. `same_item_volume` — one dataset item gives neocortex and total brain volume.
3. `same_team_mass` — one team (e.g. Stephan_collection) gives both, mass side.
4. `same_team_volume` — one team gives both, volume side.
5. `none` — no pairing exists; the merged values are carried, flagged `merged_combined`.

Ties within a class: the candidate whose neocortex value is closest to the merged value.
Item values are that item's species means; team values are means of the team's item means
(mirroring the merges' own team logic).

Brain volume from a mass uses Stephan's density, volume = mass / 1.036 (and mass from a
volume, mass = volume x 1.036 / 1000). `Nr_paired` = neocortex / (brain volume - neocortex),
after Dunbar, as in Castillo-Morales et al. 2016. `Nr_merged` is the same ratio from the
merged volumes values, for comparison.

## Coverage

- 425 species with a merged neocortex volume: 406 paired (89 at item level, 317 at team
  level), 19 unpaired.
- compiled_genome_data cohort: 61 of 72 paired.
- The 64 species of the 2026-11-18 OLS regression download: 54 of 64 paired.

## Known gap

Mus musculus is unpaired: Beatty & Laughlin 2006 gives the C57BL/6J cortical volume
(115.59 mm3) but the volumes merge carries no Beatty total (the paper's noncortical column
is not a mapped term). The paper's own in-vivo total is cortical + noncortical = 477.60 mm3,
so a hand pairing exists if wanted; the extract does not invent merge data.
