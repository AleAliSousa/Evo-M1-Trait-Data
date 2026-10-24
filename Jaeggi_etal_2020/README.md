# Jaeggi et al. 2020: population social organization

Variable social organization is ubiquitous in Artiodactyla and probably evolved from pair-living ancestors. DOI: https://doi.org/10.1098/rspb.2020.0035

Author workbook downloaded 2026-10-23 from https://github.com/adrianjaeggi/artiodactyl.socialorg (Artiodactyla_Dataset_corrected_11Mar.xlsx). The original workbook and GitHub file metadata are preserved in source/ and SHA256 hashes in source_manifest.csv.

All 245 population records across 100 printed species are transcribed from the population sheet, including locations, adult sex-composition codes and reference strings. These are SECONDARY classifications drawn from primary field studies, not 245 new primary observations. Primary-paper verification remains pending; references are retained per row. Numerical codes indicate categories/presence, not group sizes. The author species-level summary and phylogenetic proxy substitutions are not used as extra observations.

The merge table contains the set of states observed across populations, never a first or modal species state. No counts are inferred from solitary or pair labels. The original population rows remain available. The historical guanaco name Lama glama guanicoe maps to Lama guanicoe using MDD taxon 1006386; it must not map to the domestic llama.

Rebuild: `python3 _checks/social_variables/build_population_censuses.py` from the repository root. Source input is unchanged. Definitions and the supplementary source mapping specify the app label and secondary role.

Source integrity: local Office copies acquired added custom metadata without changes to worksheet/document content. Authoritative original bytes are preserved inside ZIP archives; the rebuild reads the archived workbook. source_manifest.csv hashes the archives and other non-Office evidence, not mutable display copies.
