# Export gaps — rows still "notfound" after the catalog fixes

These 30 catalog rows have **no matching `.tsv` in `__Public/comparative-data/`**. Each needs its table extracted and exported under the target filename below (the encoded name the `Item in directory FileList` lookup expects). Generated 2026-07-20.

## Bucket 2 — sibling tables already exported, this one is missing

| Paper | Table | Target file to create | Note |
|---|---|---|---|
| Bauernfeind et al. 2013 | Table 3 | `10.1016%2Fj.jhevol.2012.12.003_Table3.tsv` | Table1 & Table2 already exported |
| Frahm & Zilles 1994 | Table 2 | `PMID%3A7983368_Table2.tsv` | Table1 already exported |
| Garwicz et al. 2009 | Table S2 | `10.1073%2Fpnas.0905777106_TableS2.tsv` | TableS1 already exported |
| Karbowski 2007 | Table 1 (main) | `10.1186%2F1741-7007-5-18_Table1.tsv` | S1–S23 exported; main Table 1 missing |

**Probably not data tables — confirm before exporting:**

| Paper | Item | Note |
|---|---|---|
| Isler et al. 2008 | `Tree.nex` | Nexus phylogeny file, not a tabular dataset |
| Iwaniuk et al. 1999 | `References` | Reference list, not data |

## Bucket 3 — paper has no export in comparative-data at all

| Paper | Table / item | Target file to create |
|---|---|---|
| Barbeito-Andres et al. 2019 | cell density | `10.1242%2Fjeb.204651_celldensity.tsv` |
| Barbeito-Andres et al. 2019 | cell number | `10.1242%2Fjeb.204651_cellnumber.tsv` |
| Barbeito-Andres et al. 2019 | volumes | `10.1242%2Fjeb.204651_volumes.tsv` |
| Brodmann 1913 | Tabelle 1 | `10.0000%2Fplaceholder_Tabelle1.tsv` — DOI is a placeholder; assign a real ID |
| Caves et al. 2018 | Table S1 | `10.1016%2Fj.tree.2018.03.001_TableS1.tsv` |
| DeCasien & Higham 2019 | Suppl. Data 1 – Activity Period | `10.1038%2Fs41559-019-0969-0_SupplementaryData1-ActivityPeriod.tsv` |
| DeCasien & Higham 2019 | Suppl. Data 1 – Brain Region | `10.1038%2Fs41559-019-0969-0_SupplementaryData1-BrainRegion.tsv` |
| DeCasien & Higham 2019 | Suppl. Data 1 – Diet | `10.1038%2Fs41559-019-0969-0_SupplementaryData1-Diet.tsv` |
| DeCasien & Higham 2019 | Suppl. Data 1 – Social System | `10.1038%2Fs41559-019-0969-0_SupplementaryData1-SocialSystem.tsv` |
| Fu et al. 2013 | Table 1 | `10.1007%2Fs00429-012-0462-x_Table1.tsv` |
| Genoud et al. 2018 | Table S2 | `10.1111%2Fbrv.12350_TableS2.tsv` |
| Haarlem et al. 2026 | CFF dataset | `10.1038%2Fs41559-026-02994-7_CFFdataset.tsv` |
| Heffner & Masterton 1983 | Table I | `10.1159%2F000121494_TableI.tsv` |
| Johansen et al. 2024 | Table 2 | `10.1523%2FJNEUROSCI.1750-23.2024_Table2.tsv` |
| Semendeferi & Damasio 2000 | (no item number set) | `10.1006%2Fjhev.1999.0381_.tsv` — assign an item number first |
| Semendeferi et al. 2002 | Table 1 | `10.1038%2Fnn814_Table1.tsv` |
| Sherwood et al. 2004 | Table 4 | `10.1159%2F000075672_Table4.tsv` |
| Sherwood et al. 2004 | Table 5 | `10.1159%2F000075672_Table5.tsv` |
| Smaers & Soligo 2013 | Supplement | `10.1098%2Frspb.2013.0269_Supplement.tsv` |
| Smaers et al. 2018 | Figure 2 – data 1 | `10.7554%2FeLife.35696_Figure2-data1.tsv` |
| Stephan et al. 1981 | Table VIII | `10.1159%2F000155964_TableVIII.tsv` |
| Stephan et al. 1981 | Table IX | `10.1159%2F000155965_TableIX.tsv` |
| Stephan et al. 1981 | Table X | `10.1159%2F000155966_TableX.tsv` |
| Turner et al. 2016 | Table 1 | `10.1159%2F000446762_Table1.tsv` |

**Note on DeCasien & Higham 2019:** these four may be intentionally absent from `comparative-data` because DeCasien data is absorbed via the volume-merge pipeline rather than exported as standalone `.tsv`. The catalog item-name column was also fixed (was showing "BrainRegion"/"SocialSystem" twice due to an off-by-one; now derives correctly from each row's item number).
