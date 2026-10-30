# Evo-M1 database inventory

Registry and filesystem snapshot: 2026-10-29. File presence is checked on disk; progress labels are copied from the live registry.

## Counts

| Measure | Count |
|---|---:|
| registry rows | 806 |
| unique item names | 785 |
| citation only rows | 0 |
| public tsv files | 788 |
| registered with public tsv | 728 |
| registered without public tsv | 78 |
| new since head | 19 |
| paper folders | 469 |
| paper folders with registry rows | 406 |
| registry rows without paper folder | 0 |
| merge domains | 19 |
| compiled output csvs | 60 |

Data-role labels in the registry: 274 `primary`, 183 `secondary`, 82 `both`, and 249 blank; 18 rows use other descriptive labels. These are registry labels, not a review of the underlying measurements.

## Items added since the latest commit

| Item | Public TSV | CSV | R | Snapshot | Definitions | Registry progress |
|---|:---:|:---:|:---:|:---:|:---:|---|
| Dlugosz_etal_2013_TableS1 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Franco_etal_2000_Table1 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Franco_etal_2000_Text | Yes | Yes | Yes | Yes | Yes | (blank) |
| Garcia_Ravignani_2020_sp1 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Graham__2011_TABLEI | Yes | Yes | Yes | Yes | Yes | BUILT; WIRED LOCALLY (extract script, snapshot, R, CSV, TSV, definitions, references, R... |
| Heffner_Heffner_2016_Figure5 | Yes | Yes | Yes | Yes | Yes | BUILT (constructed snapshot, R, CSV, TSV, definitions, README; validated 8/8 2026-10-29... |
| Heffner_etal_2001_a_ResultsText | Yes | Yes | Yes | Yes | Yes | PREPARED (snapshot, R, CSV, definitions, README built and table check passed 2026-10-29... |
| Heffner_etal_2001_a_Figure6 | Yes | Yes | Yes | Yes | Yes | PREPARED (snapshot, R, CSV, definitions, README built and table check passed 2026-10-29... |
| Isler_vanSchaik_2012_1-s2.0-S0047248412000577-mmc2.xls | Yes | Yes | Yes | Yes | Yes | (blank) |
| Isler_vanSchaik_2012_SupplementaryInformation1.3 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Isler_vanSchaik_2012_SupplementaryInformation4.References | Yes | Yes | Yes | Yes | Yes | (blank) |
| Jones_MacLarnon_2004_datafile1 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Jones_MacLarnon_2004_datafile2 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Mace_etal_1981_TableI | Yes | Yes | Yes | Yes | Yes | (blank) |
| Martin_etal_2017_SupportingInformationS1 | Yes | Yes | Yes | Yes | Yes | (blank) |
| Martin_etal_2017_MammalianVocalisationDataMartinetal.xlsx | Yes | Yes | Yes | Yes | Yes | (blank) |
| Pellis_Iwaniuk_2000_Table1 | Yes | Yes | Yes | Yes | Yes | BUILT; WIRED LOCALLY (extract script, snapshot, R, CSV, TSV, definitions, README; 5 lab... |
| Ross_Kirk_2007_Appendix1 | Yes | Yes | Yes | Yes | Yes | BUILT (extract script, snapshot, R, CSV, TSV, definitions, README); validation 8/8 2026... |
| Sjölin_etal_2022_SupplementaryData | Yes | Yes | Yes | Yes | Yes | BUILT; WIRED LOCALLY (snapshot, R, CSV, TSV, definitions, README, __merging_supplementa... |

Eight of these items were built or completed in this pass: Dlugosz Table S1; Franco Table 1 and Text; Garcia–Ravignani sp1; Heffner ResultsText and Figure 6; Martin Supporting Information S1 and Mammalian Vocalisation Data.
The other 11 recent items already had public TSVs. All 19 now have a public TSV, analysis CSV, R script, frozen source, definitions, and README on disk.


## Registry health

- Repeated item names: 19; these include the registry’s intentional `#n` multi-row convention and need row-level review before any deduplication.
- Repeated encoded names: 19.
- Public TSV files with no registry encoded name: 81.
- Encoded names containing whitespace: 2.
- Paper folders without any matching registry item: 63.
- Several recent rows still have blank or PREPARED progress text despite files now existing. The live workbook was not edited during this inventory.
- A missing local file can reflect a source-only/candidate row or a legacy naming convention. Use the JSON item records for review.

## Full inventory

The companion JSON lists every registered item, its registry status and role, six local file checks, and compiled output metadata.

### Compiled outputs

Files ending in `_long.csv`, `_wide.csv`, `_unfiltered.csv`, or `_compiled.csv` within the merge directories:

| Domain | Output | Rows | Columns |
|---|---|---:|---:|
| __merging_GLI | `GLI_long.csv` | 336 | 15 |
| __merging_GLI | `GLI_species_area_stratum_comparison_qa_long.csv` | 300 | 10 |
| __merging_GLI | `GLI_species_area_stratum_comparison_qa_wide.csv` | 44 | 31 |
| __merging_behaviour | `behaviour_long.csv` | 5355 | 18 |
| __merging_behaviour | `behaviour_observations_long.csv` | 5422 | 10 |
| __merging_behaviour | `behaviour_wide.csv` | 523 | 59 |
| __merging_behaviour | `social_mirror_play_long.csv` | 519 | 19 |
| __merging_behaviour | `social_mirror_play_observations_long.csv` | 553 | 17 |
| __merging_behaviour | `social_mirror_play_wide.csv` | 83 | 105 |
| __merging_body_ecology | `body_ecology_long.csv` | 90621 | 18 |
| __merging_body_ecology | `body_ecology_unfiltered.csv` | 108584 | 17 |
| __merging_body_ecology | `body_ecology_wide.csv` | 7487 | 24 |
| __merging_brain_mass | `brain_mass_long.csv` | 2685 | 18 |
| __merging_brain_mass | `brain_mass_unfiltered.csv` | 4655 | 20 |
| __merging_brain_mass | `brain_mass_wide.csv` | 1294 | 8 |
| __merging_cell_morphology | `cell_morphology_long.csv` | 3155 | 35 |
| __merging_cellcounts | `cellcounts_long.csv` | 3259 | 8 |
| __merging_cellcounts | `cellcounts_unfiltered.csv` | 5912 | 4 |
| __merging_cellcounts | `cellcounts_wide.csv` | 86 | 166 |
| __merging_cerebellar_folding | `cerebellar_folding_long.csv` | 383 | 18 |
| __merging_cerebellar_folding | `cerebellar_folding_wide.csv` | 56 | 8 |
| __merging_cerebral_metabolic_rate | `cerebral_metabolic_rate_long.csv` | 235 | 14 |
| __merging_cerebral_metabolic_rate | `cerebral_metabolic_rate_unfiltered.csv` | 2161 | 44 |
| __merging_cerebral_metabolic_rate | `cerebral_metabolic_rate_wide.csv` | 14 | 61 |
| __merging_cortical_areas | `cortical_areas_long.csv` | 717 | 23 |
| __merging_cortical_areas | `cortical_areas_wide.csv` | 91 | 31 |
| __merging_cortical_layers | `cortical_layers_all_regions_long.csv` | 175 | 35 |
| __merging_cortical_layers | `cortical_layers_m1_long.csv` | 125 | 35 |
| __merging_cortical_layers | `cortical_layers_m1_observations_wide.csv` | 12 | 44 |
| __merging_cortical_layers | `cortical_layers_m1_species_long.csv` | 119 | 35 |
| __merging_cortical_layers | `cortical_layers_m1_species_summary_wide.csv` | 6 | 44 |
| __merging_endocranial_volume | `endocranial_volume_long.csv` | 389 | 18 |
| __merging_endocranial_volume | `endocranial_volume_unfiltered.csv` | 658 | 16 |
| __merging_endocranial_volume | `endocranial_volume_wide.csv` | 304 | 3 |
| __merging_fossil_brain_glucose | `fossil_brain_glucose_long.csv` | 68 | 22 |
| __merging_fossil_brain_glucose | `fossil_brain_glucose_unfiltered.csv` | 98 | 23 |
| __merging_fossil_brain_glucose | `fossil_brain_glucose_wide.csv` | 35 | 22 |
| __merging_gyrification | `gyrification_long.csv` | 181 | 11 |
| __merging_gyrification | `gyrification_wide.csv` | 123 | 11 |
| __merging_life_history | `life_history_long.csv` | 27801 | 20 |
| __merging_life_history | `life_history_unfiltered.csv` | 83923 | 28 |
| __merging_life_history | `life_history_wide.csv` | 5140 | 16 |
| __merging_sensory | `comparison_vs_SensoryData_compiled.csv` | 208 | 8 |
| __merging_sensory | `sensory_long.csv` | 373 | 19 |
| __merging_sensory | `sensory_unfiltered.csv` | 438 | 15 |
| __merging_sensory | `sensory_wide.csv` | 140 | 13 |
| __merging_sensory | `taste_long.csv` | 172 | 19 |
| __merging_sensory | `taste_observations_long.csv` | 245 | 17 |
| __merging_sensory | `taste_wide.csv` | 46 | 37 |
| __merging_sleep | `sleep_long.csv` | 625 | 14 |
| __merging_sleep | `sleep_wide.csv` | 257 | 9 |
| __merging_supplementary | `supplementary_long.csv` | 64067 | 21 |
| __merging_volumes | `claustrum_cerebellar_long.csv` | 190 | 19 |
| __merging_volumes | `claustrum_cerebellar_observations_long.csv` | 208 | 17 |
| __merging_volumes | `claustrum_cerebellar_wide.csv` | 28 | 18 |
| __merging_volumes | `volumes_long.csv` | 12159 | 13 |
| __merging_volumes | `volumes_unfiltered.csv` | 14382 | 10 |
| __merging_volumes | `volumes_wide.csv` | 550 | 150 |
| __merging_weights | `weights_long.csv` | 349 | 20 |
| __merging_weights | `weights_wide.csv` | 57 | 19 |

### Registered items without a matching public TSV

| Item | Registry progress |
|---|---|
| Babushina_etal_1991_Figure1 | Snapshot only (digitised 2026-10-26); R, CSV, TSV and definitions not built |
| Babushina_etal_1991_Figure2 | Snapshot only (digitised 2026-10-26); R, CSV, TSV and definitions not built |
| Babushina_etal_1991_Figure3 | Snapshot only (digitised 2026-10-26); R, CSV, TSV and definitions not built |
| Babushina_etal_1991_Text | (blank) |
| Bahney_vonBartheld_2018_TABLE2 | (blank) |
| Bahney_vonBartheld_2018_TABLE3 | (blank) |
| Bahney_vonBartheld_2018_TABLE4 | (blank) |
| Bjugn__1993_TABLEIII | (blank) |
| Boddy_etal_2012_brainbodydatabasev2.txt | FINISHED |
| Branstetter_etal_2017_TableI | candidate |
| Brodmann__1913_Tabelle1 | FINISHED |
| Crile_Quiring_1940_Table1 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| deMagalhães_Costa_2009_AnAgebuild2009 | NOT NEEDED (citation only; AnAge = deMagalhães_etal_2024 Build 15) |
| Dunbar_Bever_1998_Table1 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Dunbar_Bever_1998_Table2 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Dunbar_Bever_1998_Table3 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Elston_etal_2005_a_Table4 | (blank) |
| Elston_etal_2005_a_Table5 | (blank) |
| Elston_etal_2005_a_Table6 | (blank) |
| Elston_etal_2005_b_TABLE4 | (blank) |
| Frost_Masterton_1994_Figure3 | candidate |
| Halley_Krubitzer_2019_Figure1 | FINISHED |
| Haug__1987_TABLE2 | Built; owner registry insertion pending |
| Heffner_Heffner_1985_Figure3 | candidate |
| Heffner_Heffner_1985_Figure6 | candidate |
| Heffner_etal_1994_c_Figure7 | candidate |
| Heffner_etal_2003_Figure4 | candidate |
| Heffner_etal_2003_Figure5 | candidate |
| Heffner_etal_2007_Figure4 | candidate |
| Heffner_etal_2008_ResultsText | (blank) |
| Heffner_etal_2013_Figure2 | candidate |
| Heffner_etal_2013_Table1 | candidate |
| Heffner_etal_2014_Figure3 | candidate |
| Heffner_etal_2014_Figure9 | candidate |
| Heffner_etal_2014_Figures10-11 | candidate |
| Heffner_etal_2015_TABLEI | (blank) |
| HerculanoHouzel_etal_2007_Table1 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Hofman__1985_TableI | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Isler_etal_2008_Tree.nex | FINISHED |
| Jacobs_etal_1997_Table1 | FINISHED |
| Jacobs_etal_1997_Table2 | FINISHED |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | (blank) |
| Jones_etal_2009_PanTHERIA1-0WR93Aug2008.txt | (blank) |
| Jorstad_etal_2023_TableS1 | FINISHED |
| Jorstad_etal_2023_TableS2 | FINISHED |
| Jorstad_etal_2023_TableS3 | FINISHED |
| Jorstad_etal_2023_TableS4 | FINISHED |
| Jung_etal_2022_TableS1 | (blank) |
| Jung_etal_2022_TableS2 | (blank) |
| Karbowski__2007_Table1 | (blank) |
| Kaskan_etal_2005_Figure2 | (blank) |
| Kaskan_etal_2005_Figure3 | (blank) |
| Kaskan_etal_2005_References | (blank) |
| Kaskan_etal_2005_TableS2 | (blank) |
| Ketten__2012_Text(TTSvalues) | (blank) |
| Koay_etal_2002_Figure3 | candidate |
| Koay_etal_1998_Figure7 | (blank) |
| Koay_etal_1998_b_Figure8 | candidate |
| Koay_etal_1998_b_Figure9 | candidate |
| Manger_etal_2012_Table1 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Mayer_etal_2019_Fig6 | BUILT from PDF Results text; public TSV pending |
| McGuire_Ratcliffe_2011_ElectronicSupplementaryMaterial1,Table1 | (blank) |
| Myhrvold_etal_2015_AmnioteDatabaseReferencesAug2015.csv | (blank) |
| Myhrvold_etal_2015_AmnioteRangeCountAug2015.csv | (blank) |
| Myhrvold_etal_2015_AmnioteSparseTableAug2015.csv | (blank) |
| Nudo_Masterton_1990_IV_Figure2A | candidate |
| Reep_OShea_1990_Table1 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Reep_OShea_1990_Table3 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Reep_OShea_1990_Table4 | PREPARED (CSV built; owner registry paste / public TSV pending; RA side-by-side check p... |
| Rivara_etal_2003_Betzcells | candidate |
| Shultz_Dunbar_2010_TableS1 | (blank) |
| Smaers_Soligo_2013_Supplement | (blank) |
| Stephan_etal_1991_Table71 | (blank) |
| Todorov_etal_2019_rspb20191712si001 | (blank) |
| Upham_etal_2019_Completed100 | (blank) |
| VanEssen_Drury_1997_ResultsTextCitedV1Ranges | BUILT as secondary citation; primary source extraction pending |
| Wenstrup__1984_Figure8 | candidate |
| Young_etal_2013_ResultsTextSurface | BUILT; case-level overlap review required before merge |

### Duplicate item names

- `Hanson_etal_2018_Table2`: 2 registry rows
- `Hanson_etal_2018_Table3`: 2 registry rows
- `Hayssen_etal_1993_Primates`: 2 registry rows
- `Heffner__1998_Table1`: 2 registry rows
- `Jacobs_etal_2016_Table1`: 2 registry rows
- `Johnson_etal_2016_Table1`: 3 registry rows
- `Karlsen_Pakkenberg_2011_authordata(groupmeans)`: 2 registry rows
- `Karlsen_Pakkenberg_2011_reportedvalues`: 2 registry rows
- `Karlsen_Pakkenberg_2011_Table2`: 2 registry rows
- `Mackes_etal_2020_ERABIS(cortical)`: 2 registry rows
- `Mooney_etal_2012_Table4.1`: 2 registry rows
- `Morgan_etal_2014_DataS1`: 2 registry rows
- `Peruffo_etal_2019_Table2`: 3 registry rows
- `Pettigrew_etal_1998_Table2`: 2 registry rows
- `Walhovd_etal_2011_normativevolumes`: 2 registry rows
- `Winkler_Bryant_2021_Figure1`: 2 registry rows
- `Young_etal_2013_Table1`: 2 registry rows
- `Young_etal_2013_b_Table1`: 2 registry rows
- `Zilles_etal_2013_Table1`: 2 registry rows

### Paper folders with no matching registry item

- `Glendenning_Masterton_1998`
- `MorroghBernard_etal_2008`
- `Modlinska_Stryjek_2016`
- `Pasquaretta_etal_2014`
- `Isler_vanSchaik_2009`
- `Jacobs_Williams_2001`
- `Isler_vanSchaik_2006`
- `Campbell_Tobler_1984`
- `Heffner_Heffner_2010`
- `Anderson_Gallup_2015`
- `GalánAcedo_etal_2019`
- `Panepinto_etal_1978`
- `Devillard_etal_2003`
- `Hiwatashi_etal_2011`
- `Krubitzer_etal_1995`
- `Kamilar_Cooper_2013`
- `Feinberg_etal_1990`
- `Stensaas_etal_1974`
- `Smith_Jungers_1997`
- `Deegan_Jacobs_2001`
- `Jacobs_Deegan_2001`
- `McComb_Semple_2005`
- `Elston_Fujita_2014`
- `Reader_Laland_2002`
- `Shultz_Dunbar_2007`
- `Jacobs_Deegan_1993`
- `Sherwood_etal_2020`
- `Jacobs_Deegan_2003`
- `Bowmaker_etal_1991`
- `Ferrell_etal_2026`
- `Luethke_etal_1988`
- `Jacobs_Neitz_1987`
- `Luethke_etal_1989`
- `Grueter_etal_2013`
- `MacLean_etal_2014`
- `Norbury_etal_1998`
- `Zimmermann__2017`
- `Deaner_etal_2007`
- `Baizer_etal_2014`
- `Changizi_He_2005`
- `Jacobs_etal_2019`
- `Dunn_Smaers_2018`
- `Jaeggi_etal_2020`
- `Hardus_etal_2009`
- `Nunn_Samson_2018`
- `Jacobs_etal_2002`
- `Henry_etal_2006`
- `Ziege_etal_2016`
- `Filiminoff_1932`
- `Gamba_etal_2015`
- `Krubitzer_1995`
- `Nunn_etal_2001`
- `Terborgh__1983`
- `Krubitzer_1998`
- `Lyon_etal_1998`
- `Qiu_etal_2022`
- `Hohmann__1991`
- `Jacobs__2009`
- `Jacobs__2008`
- `Weaver__2005`
- `Gallup__1977`
- `Tan_Li_1999`
- `Wiafe_2019`

### Encoded names containing whitespace

- `10.1111%2Fevo.13128 _MammalianVocalisationDataMartinetal.xlsx`
- `10.1111%2Fevo.13128 _SupportingInformationS1`

### Unlisted public TSV files

- `10.1002%2F(sici)1096-9861(19971006)386%3A4%3C661%3A%3AAid-cne11%3E3.0.Co;2-n_Table1.tsv`
- `10.1002%2F(sici)1096-9861(19971006)386%3A4%3C661%3A%3AAid-cne11%3E3.0.Co;2-n_Table2.tsv`
- `10.1002%2Fajp.1350300307_TextResults.tsv`
- `10.1002%2Fajpa.1330380234_ResultsText.tsv`
- `10.1002%2Fajpa.23427_SupplementaryTable1.tsv`
- `10.1002%2Fajpa.23427_Table1.tsv`
- `10.1002%2Far.20829 _Table1.tsv`
- `10.1002%2Far.23728_TABLE2.tsv`
- `10.1002%2Far.23728_TABLE3.tsv`
- `10.1002%2Far.23728_TABLE4.tsv`
- `10.1007%2F978-3-319-59478-1_5_Table5.1.tsv`
- `10.1007%2Fs00265-018-2629-9_TableS1.tsv`
- `10.1007%2Fs00265-018-2629-9_TableS2.tsv`
- `10.1007%2Fs00429-014-0792-y _Table1.tsv`
- `10.1007%2Fs10764-015-9861-1_TableI.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSII.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSIII.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSIV.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSV.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSVI.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSVII.tsv`
- `10.1007%2Fs10764-015-9861-1_TableSVIII.tsv`
- `10.1016%2F0042-6989(87)90202-1_Table1.tsv`
- `10.1016%2F0149-7634(84)90054-X_Table1.tsv`
- `10.1016%2FS0042-6989(01)00264-4_Table1.tsv`
- `10.1016%2FS0042-6989(02)00565-5_Table1.tsv`
- `10.1016%2Fj.evolhumbehav.2012.09.004_Table1.tsv`
- `10.1016%2Fj.evolhumbehav.2012.09.004_TableS1.tsv`
- `10.1017%2FS0952523808080760_Table1.tsv`
- `10.1017%2FS0952523808080760_Table2.tsv`
- `10.1037%2F0735-7036.102.2.99_Table1.tsv`
- `10.1038%2F46947_Table1.tsv`
- `10.1038%2Fs41597-019-0059-9_BodyMass.tsv`
- `10.1038%2Fs41597-019-0059-9_DielActivity.tsv`
- `10.1038%2Fs41597-019-0059-9_Habitat.tsv`
- `10.1038%2Fs41597-019-0059-9_HomeRange.tsv`
- `10.1038%2Fs41597-019-0059-9_IUCN_Poptrend_Realm.tsv`
- `10.1038%2Fs41597-019-0059-9_Locomotion.tsv`
- `10.1038%2Fs41597-019-0059-9_TrophicGuild.tsv`
- `10.1038%2Fsrep07600_Extendeddatatable5.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0004_Table4.1.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0004_Table4.2.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0004_Table4.3.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0004_Table4.4.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Figure8.1.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Figure8.2.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Table8.2.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Table8.3.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Table8.5.tsv`
- `10.1093%2Facprof:oso%2F9780199213276.003.0008_Table8.6.tsv`
- `10.1098%2Frsbl.2005.0366_Table1.tsv`
- `10.1098%2Frspb.2000.1421_TextResults.tsv`
- `10.1098%2Frstb.2009.0039_Table1.tsv`
- `10.1098%2Frstb.2012.0341_S2.tsv`
- `10.1121%2F1.1903415_Table1.tsv`
- `10.1159%2F000006530_Table1.tsv`
- `10.1159%2F000006530_Table2.tsv`
- `10.1159%2F000006530_Table3.tsv`
- `10.1159%2F000006530_Table4.tsv`
- `10.1159%2F000006530_Table5.tsv`
- `10.1159%2F000006530_Table6.tsv`
- `10.1159%2F000006530_Table7.tsv`
- `10.1159%2F000049915_TextResults.tsv`
- `10.1159%2F000156538_Table10.tsv`
- `10.1159%2F000156538_Table11.tsv`
- `10.1159%2F000156538_Table12.tsv`
- `10.1159%2F000156538_Table3.tsv`
- `10.1159%2F000156538_Table4.tsv`
- `10.1159%2F000156538_Table5.tsv`
- `10.1159%2F000156538_Table6.tsv`
- `10.1159%2F000156538_Table7.tsv`
- `10.1159%2F000156538_Table8.tsv`
- `10.1159%2F000156538_Table9.tsv`
- `10.1186%2F1471-2148-11-312_TextResults.tsv`
- `10.1242%2Fjeb.156.1.1_Table1.tsv`
- `10.1242%2Fjeb.156.1.1_Table2.tsv`
- `10.3389%2Ffnins.2018.00534_TableS1.tsv`
- `JPsycholNeurol%3A44%3A1-96_Tablep70.tsv`
- `NA.tsv`
- `PMID%3A682579_Table1.tsv`
- `PMID%3A682579_Table3.tsv`
