# Heuer et al. 2023 — cerebellar folding in mammals

Built from the authors' open release for **56 mammal species**. The author repository was frozen on
2026-08-15 at commit `8b603fb0bf711ece57ddb658d39d3fd5e01ff20e` (the same revision archived by
Software Heritage in the article):

> Heuer K, Traut N, de Sousa AA, Valk SL, Clavel J, Toro R. (2023). Diversity and
> evolution of cerebellar folding in mammals. *eLife* 12:e85907.
> https://doi.org/10.7554/eLife.85907

## Frozen evidence

- `Heuer_etal_2023_eLife85907.pdf`: version-of-record article (CC BY).
- `elife-85907-supp1-v2.xlsx`: journal species list.
- `source_data/data.csv`: untouched final phenotype table from the authors' repository.
- `source_data/01_...` through `05_...`: component measurements.
- `source_data/01_cb_data.csv`, `02_scale.csv`, `rosetta.csv`, and `load_data.R`: raw lookup and
  assembly files needed to audit the final columns.
- `LICENSE.author-repository.txt`: Apache-2.0 license for the author repository.

The frozen final phenotype `source_data/data.csv` has SHA-256
`55f462a7374dec84eed3e745b42292df9ccc6435dc7c4ef29b554df768fa4ece`.

`Heuer_etal_2023_Data.R` is the canonical build. It retains the released log fields and also
back-transforms the seven directly measured neuroanatomical variables to the millimetre units
defined in article Table 1. The two weight fields are *not* back-transformed: the upstream
`rosetta.csv` calls them `LogBodyWeight`/`LogBrainWeight`, while `load_data.R` renames them with a
`Log10` prefix without applying `log10()`. Keeping the values verbatim avoids guessing the base.

Outputs:

- `Heuer_etal_2023_Data.csv`
- `../__Public/comparative-data/10.7554%2FeLife.85907_Data.tsv`
- `../__merging_cerebellar_folding/{cerebellar_folding_long,cerebellar_folding_wide}.csv`

The merge treats the seven direct measurements as one primary team. It never pools them with
Ashwell 2020's PSA/ESA foliation index or with neocortical gyrification: those are different
measurement procedures. The Shiny app loads this as its own **Cerebellar folding** dataset.

## Registry status

`Heuer_etal_2023_Data` is registered in `__ReadMe.xlsx` with the stable DOI-coded public filename,
and the Shiny source manifest includes the 56-species table.

# Chimpanzee specimen provenance (2026-11-25)

The chimpanzee `chimp_cor_cell` section series in `source_data/01_cb_data.csv` corresponds to Brain Museum slides visibly labeled **63-397**. The [Brain Museum gallery](https://brainmuseum.org/specimens/primates/chimp/sections/coronal-cell/thumbnail.html) instead heads the page `#63-307`; its slide images and the [Heuer author-repository chimp image](https://github.com/neuroanatomy/comp-cb-folding/blob/main/data/raw/img/cb/chimp_cor_cell.json.cb-50%25.png) show `63-397`. One gallery file is named `0285chimp63-395.jpg`, but its slide also prints `63-397`. Fobbs & Johnson 2011 Table S2 independently lists Welker chimp `63-397`. See [specimen note](../_keys/specimen_crosswalk/Brainmuseum_chimp_63-397_specimen_note.md). The article does not itself print the accession; the image provenance supplies it. These sources represent one imaged specimen, not independent Heuer and Brain Museum animals.

## Specimen registration (2026-11-25)

All 56 species rows in `Heuer_etal_2023_Data.csv` now have one Heuer source-label row in `_keys/specimen_crosswalk/specimen_crosswalk.csv`. The companion `Heuer_etal_2023_specimen_image_audit.csv` records the selected image, accession read from the image where visible, SHA-256, canonical specimen, match basis, and exceptions. The image URLs are pinned to author-repository commit `8b603fb0bf711ece57ddb658d39d3fd5e01ff20e`, the same revision used for this folder's phenotype source data.

- 54 rows use Brain Museum source images. Accession ink is visible on 52 selected images. Fifty of those 52 match a Fobbs & Johnson 2011 Table S2 Welker accession without a taxon conflict and reuse that canonical specimen. The pig `61-361` is labeled on its image and Brain Museum page but absent from Fobbs S2. The gray-kangaroo image/page says `62-127`, while Fobbs S2 assigns `62-127` to a little brown bat and `62-167` to a kangaroo; the Heuer kangaroo is registered separately with the conflict flagged. See `Brainmuseum_kangaroo_62-127_specimen_note.md` in the crosswalk folder.
- The selected manatee and sheep images have no visible accession. Their Brain Museum pages and Fobbs S2 catalog entries indicate `85-32` and `61-693` respectively. These links are **probable**, and the audit records that the identifiers were not read on the selected images.
- The remaining two rows are a single BigBrain human donor and BrainMaps rhesus macaque `rm316-nissl`; their dataset identities are registered without inventing museum accessions.

These rows identify the image underlying each Heuer measurement. They do not make Heuer, Fobbs, and Brain Museum independent animals. The image labels were transcribed by the agent and cross-checked against the cited source records; they await human visual signoff.
