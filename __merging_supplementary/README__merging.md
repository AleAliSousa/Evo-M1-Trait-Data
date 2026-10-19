# __merging_supplementary -- built tables no other merge consumed

**Landed 2026-10-15.** The source scan (`__Cytosplore_export/scan_source_tables.py`) found 58 public
tables with rows for the Evo-M1 / V1 / EC / HMBA target species that no `__merging_*` folder reads.
This merge wires the ones that hold species-level trait data, through one mapping file, so each
inclusion is a reviewable row rather than code.

```
Rscript __merging_supplementary/supplementary_compiled.R      # -> supplementary_long.csv
Rscript _keys/build_variable_definitions.R                      # new labels -> definitions
Rscript _keys/build_trait_authority.R && Rscript _checks/check_trait_authority.R
```

`__ShinyApp/app.R` loads `supplementary_long.csv` with `std_merge()` as dataset **Supplementary
sources**; TraitExplorer discovers the folder automatically; `__Cytosplore_export` follows the app.

## Files
- `supplementary_sources.csv` -- the mapping (one row = one source column -> one label). Columns are
  documented at the top of `supplementary_compiled.R`.
- `supplementary_long.csv` -- std_merge schema + `n_specimens`, `items`, `label_policy`.
- `supplementary_unresolved_species.csv` -- printed names `resolve_species()` could not anchor; they
  are kept in the long table under the cleaned printed string with `species_basis = unresolved`.

## Decisions
- **Shared labels (5).** PanTHERIA gestation, weaning age, litter size, maximum longevity (months/12)
  and whole-animal BMR are the same quantities as the `__merging_body_ecology` measures and reuse
  their labels, so cohort coverage of those variables rises; the app pools the two datasets like any
  two sources and the export's cells table shows `n_values`/range. `_keys/trait_authority.csv` keeps
  `__merging_body_ecology` authoritative and lists this folder as the other producer.
- **Everything else is a new label**, suffixed with the source where an existing label measures a
  related but not identical quantity (`Diet_breadth_PanTHERIA` vs EltonTraits `Diet_breadth`;
  `Visual_acuity_*_compiled` vs the sensory merge's primary-split acuity labels, same
  `poolable_group`). Nothing is pooled across measurement bases.
- **Columns deliberately not taken**: whole-brain / cerebellum / hemisphere volumes in Smaers 2018
  and Semendeferi & Damasio 2000 (volumes merge is authoritative); ECV and body mass in Boyer &
  Harrington 2019; Pettigrew's ganglion-cell acuity (overlaps sensory merge); PanTHERIA body mass.
- **Roles** are the paper's role for that column (PanTHERIA, deSousa 2022, Navarrete 2016, Smaers
  2018, Iwaniuk 2001, Winkler & Bryant 2021, Changizi 2003, McDowell 2024, Pettigrew 1998 are
  compilations -> `secondary`; MRI / histology measurements -> `primary`).

## Tables from the scan that were NOT wired, and why
| table | reason |
|---|---|
| Fobbs_etal_2011 TableS1-S5 | brain-collection specimen inventory, not trait data |
| Chen_Wiens_2020 SupplementaryData3 | presence/absence of acoustic communication; uninformative within mammals |
| Owren_etal_1988 Table1+3 | raw audiogram thresholds per frequency; the sensory merge derives hearing limits elsewhere |
| Kirk_Kay_2004 Table1/2 | subsumed by the deSousa 2022 compilation (same measures, newer, with method) |
| MedinaGonzález 2026 SupplementaryFile1/2 | locomotor habit; belongs with the Medina items already in `__merging_behaviour` -- add there |
| Barger_etal_2012 Table1 | specimen sample description |
| Heffner / Kelly / Frost / Mooney / Dooley / Kastelein / Branstetter ResultsText items | single-species hearing/acuity extracts; belong in the sensory merge's method-basis reconciliation |
| Balzeau 2012, Kochiyama 2018 figure/text items, Matano 2001, Mackes 2020, BarbeitoAndrés 2019, Taniguchi 2022, VanEssen & Drury 1997, Johansen 2024, Dell 2016 | 1 target species each; left for the owning merge |

## Mapping (generated from supplementary_sources.csv)
| item | column | label | role | aggregate | note |
|---|---|---|---|---|---|
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 9-1_GestationLen_d | Gestation (days) [shared] | secondary | first | same quantity as body_ecology Gestation (days); pooled under the shared label |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 25-1_WeaningAge_d | Weaning_age (days) [shared] | secondary | first | shared label with body_ecology |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 15-1_LitterSize | Litter_size (count) [shared] | secondary | first | shared label with body_ecology |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 17-1_MaxLongevity_m | Maximum_longevity (yr) [shared] | secondary | first | PanTHERIA months / 12; shared label with body_ecology |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 18-1_BasalMetRate_mLO2hr | BMR_wholeanimal (mL O2/h) [shared] | secondary | first | shared label with body_ecology |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 23-1_SexualMaturityAge_d | Sexual_maturity_age (days) [distinct] | secondary | first | sexes pooled in PanTHERIA; existing Female_/Male_sexual_maturity labels are sex-specific, so kept distinct |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 3-1_AgeatFirstBirth_d | Age_at_first_birth (days) [distinct] | secondary | first |  |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 14-1_InterbirthInterval_d | Interbirth_interval (days) [distinct] | secondary | first | cf. Lewitus Inter-litter_interval_days (different compilation) |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 5-3_NeonateBodyMass_g | Neonate_body_mass (g) [distinct] | secondary | first | cf. Lewitus Weight_at_birth_g |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 16-1_LittersPerYear | Litters_per_year_PanTHERIA (count/yr) [distinct] | secondary | first |  |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 22-1_HomeRange_km2 | Home_range (km2) [distinct] | secondary | first | group home range; cf. Max_home_range_ha |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 21-1_PopulationDensity_n/km2 | Population_density (n/km2) [distinct] | secondary | first |  |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 10-2_SocialGrpSize | Social_group_size_PanTHERIA (count) [distinct] | secondary | first |  |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 1-1_ActivityCycle | Activity_cycle_PanTHERIA (category) [distinct] | secondary | first | PanTHERIA code 1 nocturnal, 2 crepuscular/cathemeral, 3 diurnal |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 6-1_DietBreadth | Diet_breadth_PanTHERIA (count) [distinct] | secondary | first | number of PanTHERIA diet categories (1-8); not the EltonTraits Diet_breadth |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 6-2_TrophicLevel | Trophic_level_PanTHERIA (category) [distinct] | secondary | first | code 1 herbivore, 2 omnivore, 3 carnivore |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 12-1_HabitatBreadth | Habitat_breadth_PanTHERIA (count) [distinct] | secondary | first |  |
| Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt | 12-2_Terrestriality | Terrestriality_PanTHERIA (category) [distinct] | secondary | first | code 1 fossorial/ground, 2 above ground |
| deSousa_etal_2022_acuityblind.csv | visual_acuity_cpd | Visual_acuity_anatomical_compiled (c/deg) [distinct] | secondary | mean | deSousa 2022 compilation; same basis as sensory merge Visual_acuity_anatomical |
| deSousa_etal_2022_acuityblind.csv | visual_acuity_cpd | Visual_acuity_behavioural_compiled (c/deg) [distinct] | secondary | mean | deSousa 2022 compilation; behavioural acuity has no primary label in the sensory merge yet |
| Boyer_Harrington_2019_SOMTableS6 | QTOT_ml_s | Brain_blood_flow_total (mL/s) [distinct] | secondary | mean | derived from foramen radii (ICA + VA) |
| Boyer_Harrington_2019_SOMTableS6 | QICA_ml_s | ICA_blood_flow (mL/s) [distinct] | secondary | mean |  |
| Boyer_Harrington_2019_SOMTableS6 | QVA_ml_s | VA_blood_flow (mL/s) [distinct] | secondary | mean |  |
| Boyer_Harrington_2019_SOMTableS6 | RICA_mm | ICA_lumen_radius (mm) [distinct] | primary | mean | measured carotid canal radius |
| Boyer_Harrington_2019_SOMTableS6 | RVA_mm | VA_lumen_radius (mm) [distinct] | primary | mean |  |
| Navarrete_etal_2016_Data | technical_innovation_count | Technical_innovation_count (count) [distinct] | secondary | first |  |
| Navarrete_etal_2016_Data | nontechnical_innovation_count | Nontechnical_innovation_count (count) [distinct] | secondary | first |  |
| Navarrete_etal_2016_Data | foraging_innovation_count | Foraging_innovation_count (count) [distinct] | secondary | first |  |
| Navarrete_etal_2016_Data | innovator | Innovator (category) [distinct] | secondary | first |  |
| Smaers_etal_2018_Figure2-data1 | LateralCerebellum_Vol.mm3 | LateralCerebellum_Vol (mm3) [distinct] | secondary | first | compiled by Smaers 2018 from named primaries (Source column); whole cerebellum/brain columns NOT taken (volumes merge is authoritative) |
| Smaers_etal_2018_Figure2-data1 | MedialCerebellum_Vol.mm3 | MedialCerebellum_Vol (mm3) [distinct] | secondary | first |  |
| Heesy__2004_Table1 | orbit_convergence_mean_deg | Orbit_convergence (deg) [distinct] | primary | first |  |
| Heesy__2004_Table1 | binocular_visual_field_midpoint_deg | Binocular_field_compiled_Heesy2004 (deg) [distinct] | secondary | first | literature values cited by Heesy (binocular_visual_field_reference) |
| Demirci_etal_2023_Fig.1 | total_surface_area_cm2 | CorticalSurface_Area_Demirci2023 (mm2) [distinct] | primary | mean | MRI total cortical surface; cm2 x100 |
| Demirci_etal_2023_Fig.1 | cerebral_volume_cm3 | Cerebral_Vol_Demirci2023 (mm3) [distinct] | primary | mean | cm3 x1000 |
| McDowell_etal_2024_Table1 | S_Cone_LambdaMax_nm | S_cone_lambda_max (nm) [distinct] | secondary | first |  |
| McDowell_etal_2024_Table1 | M_Cone_LambdaMax_nm | M_cone_lambda_max (nm) [distinct] | secondary | first |  |
| McDowell_etal_2024_Table1 | L_Cone_LambdaMax_nm | L_cone_lambda_max (nm) [distinct] | secondary | first |  |
| McDowell_etal_2024_Table1 | Rhodopsin_LambdaMax_nm | Rod_lambda_max (nm) [distinct] | secondary | first |  |
| McDowell_etal_2024_Table1 | Melanopsin_LambdaMax_nm | Melanopsin_lambda_max (nm) [distinct] | secondary | first |  |
| Changizi__2003_Table1 | n_ethobehavior_types | Behavioural_repertoire_size (count) [distinct] | secondary | first |  |
| Changizi__2003_Table1 | n_muscle_types | Muscle_type_count (count) [distinct] | secondary | first |  |
| Iwaniuk_etal_2001_Table4 | Total play | Play_total_score (score) [distinct] | secondary | first |  |
| Iwaniuk_etal_2001_Table4 | Sex play | Play_sex_score (score) [distinct] | secondary | first |  |
| Iwaniuk_etal_2001_Table4 | Non-sex play | Play_nonsex_score (score) [distinct] | secondary | first |  |
| Winkler_Bryant_2021_Figure1 | loud_play_vocalisation | Loud_play_vocalisation (category) [distinct] | secondary | any_Y | Y if any play vocalisation of the species is loud |
| Barger_etal_2012_Table3 | Amygdala_neurons | Amygdala_neuron_number (count) [distinct] | primary | first |  |
| Barger_etal_2012_Table3 | Lateral_neurons | Amygdala_lateral_neuron_number (count) [distinct] | primary | first |  |
| Barger_etal_2012_Table3 | Basal_neurons | Amygdala_basal_neuron_number (count) [distinct] | primary | first |  |
| Barger_etal_2012_Table3 | AccessoryBasal_neurons | Amygdala_accessory_basal_neuron_number (count) [distinct] | primary | first |  |
| Barger_etal_2012_Table3 | Central_neurons | Amygdala_central_neuron_number (count) [distinct] | primary | first |  |
| Semendeferi_etal_2002_Table1 | frontal_cortex_pct_of_cortex_volume | Frontal_cortex_pct_of_cortex_volume (%) [distinct] | primary | first |  |
| Semendeferi_Damasio_2000_Table2 | Frontal_Vol.mm3 | Frontal_lobe_Vol (mm3) [distinct] | primary | mean | MRI; whole-brain/cerebellum/hemisphere columns NOT taken (volumes merge authoritative) |
| Semendeferi_Damasio_2000_Table2 | Temporal_Vol.mm3 | Temporal_lobe_Vol (mm3) [distinct] | primary | mean | MRI; whole-brain/cerebellum/hemisphere columns NOT taken (volumes merge authoritative) |
| Semendeferi_Damasio_2000_Table2 | Insula_Vol.mm3 | Insula_Vol (mm3) [distinct] | primary | mean | MRI; whole-brain/cerebellum/hemisphere columns NOT taken (volumes merge authoritative) |
| Semendeferi_Damasio_2000_Table2 | ParietoOccipital_Vol.mm3 | ParietoOccipital_lobe_Vol (mm3) [distinct] | primary | mean | MRI; whole-brain/cerebellum/hemisphere columns NOT taken (volumes merge authoritative) |
| Schenker_etal_2005_Table1 | dorsal_cortex_mean_cm3 | Frontal_dorsal_cortex_Vol (mm3) [distinct] | primary | first |  |
| Schenker_etal_2005_Table1 | mesial_cortex_mean_cm3 | Frontal_mesial_cortex_Vol (mm3) [distinct] | primary | first |  |
| Schenker_etal_2005_Table1 | orbital_cortex_mean_cm3 | Frontal_orbital_cortex_Vol (mm3) [distinct] | primary | first |  |
| Seymour_etal_2019_rspb20192208si002 | Right_foramen_area_mm2 | Carotid_foramen_area_right (mm2) [distinct] | primary | mean |  |
| Seymour_etal_2019_rspb20192208si002 | Left_foramen_area_mm2 | Carotid_foramen_area_left (mm2) [distinct] | primary | mean |  |
| Pettigrew_etal_1998_Table2 | linear_magnification_mm_per_deg | Retinal_linear_magnification (mm/deg) [distinct] | secondary | first | ganglion-cell acuity column NOT taken (overlaps sensory merge Visual_acuity_anatomical) |
