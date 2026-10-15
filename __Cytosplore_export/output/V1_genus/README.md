# V1 species-trait tables for the Cytosplore M1 viewer (DRAFT) -- GENUS-LEVEL AVAILABILITY

**Genus mode.** Each cohort member adopts every label in the compiled data that shares its genus
(congeners, `Genus sp.`, hybrids, mixed/unknown taxa); `data_labels` in the species table lists them.
A variable's `species_with_data` therefore counts members for which *any* congener has a value, and
a wide cell is the pool (numeric mean) across those labels. Use these tables to compare availability
between cohorts, not as species trait values; the species-level folder holds those.


Built 2026-10-15 from Evo-M1-Trait-Data commit `731f7ac (from .git/HEAD; git command unavailable)` by `__Cytosplore_export/build_cytosplore_traits.R`.
Re-run that script to regenerate everything here; do not edit these CSVs by hand.

## What this is

Comparative species traits for the 17-species `V1` cohort (`_keys/species_cohorts.csv`), drawn from the harmonised Evo-M1-Trait-Data compilation exactly as the public Shiny app serves it. Only *measurement* variables are in the wide tables (QC flags and provenance strings are excluded). Species names are the cohort's own names, i.e. the names the RNA dataset uses -- join on `species_sci`.

## Files

| file | one row per | use |
|---|---|---|
| `V1_genus_species.csv` | species (17) | species list, taxonomy, which data labels were pooled (match level: genus), per-domain counts |
| `V1_genus_traits_wide.csv` | species x variable (597) | **recommended viewer input**: species x trait matrix, one value per cell |
| `V1_genus_traits_wide_core.csv` | species x variable (33) | same, only traits held for >= 14 of 17 species (`in_core`) |
| `V1_genus_variable_dictionary.csv` | variable (597) | column metadata for the wide tables: domain, structure, measure, unit, definition, coverage |
| `V1_genus_traits_cells.csv` | species x variable cell (3426) | how each wide cell was made: n values, aggregation, min/max, sources |
| `V1_genus_traits_long.csv` | value (8258) | full provenance: every source value behind every cell |
| `V1_genus_domain_coverage.csv` | species | n distinct variables per domain |
| `BUILD_INFO.txt` | - | build stamp and counts |

Source audit (run `python3 __Cytosplore_export/audit_cytosplore_variables.py V1 genus` after this script):

| file | one row per | use |
|---|---|---|
| `V1_genus_variable_audit.csv` | variable | contributing papers and roles, compilation-only cells, primary availability, poolability, `suggested_tier`, `source_class`, flags |
| `V1_genus_secondary_only_cells.csv` | species x variable | cells fed only by compilations, with whether a primary exists in the same group |
| `V1_genus_pooling_candidates.csv` | compatibility group | variables measuring the same quantity; gain if pooled; bases that must not be pooled |
| `AUDIT_SUMMARY.md` | - | the audit's headline numbers and flagged cases |

## How a wide cell is filled

- A cohort species may hold data under several labels (e.g. *Gorilla gorilla gorilla*, *Gorilla gorilla*,
  *Gorilla sp.*). Which labels are pooled is decided in `_keys/species_cohorts.csv` (`lookup_name`,
  with the reason in `lookup_basis`), not here. `data_labels` in the species table lists them.
- Numeric: arithmetic mean of all values across pooled labels and sources (the Shiny app's plotting
  rule). `n_values`, `value_min`, `value_max`, `spread_pct` and `sources` are in the cells table.
  Cells with `spread_pct` > 50 deserve a look before being shown as a point estimate.
- Categorical (diet, locomotion, ...): the single distinct value, or distinct values joined with
  ` | ` and `unresolved_categorical = TRUE` in the cells table.
- `m1_motor_related` in the dictionary is an advisory regex flag (M1, motor, corticospinal, dexterity,
  hand/limb, locomotion terms) to help pick the traits most relevant to a motor-cortex viewer.
- Domain(s) excluded from the wide tables as not being animal traits: dataset metadata (still in the long table).
- Brain-size variables are kept on separate measurement bases (weighed mass, mass excluding
  olfactory bulbs, endocranial volume, sum of parts, ...). `poolable_group` in the dictionary says
  which columns are the same quantity; do not average across groups.

## Species

| species_sci | common_name | Order | n_variables | data_labels |
|---|---|---|---|---|
| Aotus nancymaae | Owl monkey | Primates | 253 | Aotus azarae; Aotus azarai; Aotus brumbacki; Aotus hershkovitzi; Aotus infulatus; Aotus lemurinus; Aotus miconax; Aotus nancymaae; Aotus nigriceps; Aotus sp.; Aotus trivirgatus; Aotus vociferans |
| Callithrix jacchus | Common marmoset | Primates | 243 | Callithrix acariensis; Callithrix argentata; Callithrix aurita; Callithrix chrysoleuca; Callithrix emiliae; Callithrix flaviceps; Callithrix geoffroyi; Callithrix humeralifer; Callithrix humilis; Callithrix intermedia; Callithrix jacchus; Callithrix kuhli; Callithrix kuhlii; Callithrix leucippe; Callithrix manicorensis; Callithrix marcai; Callithrix mauesi; Callithrix melanura; Callithrix nigriceps; Callithrix penicillata; Callithrix saterei; Callithrix sp. |
| Dasypus novemcinctus | Armadillo | Cingulata | 89 | Dasypus hybridus; Dasypus kappleri; Dasypus novemcinctus; Dasypus pilosus; Dasypus sabanicola; Dasypus septemcinctus; Dasypus sp.; Dasypus yepesi |
| Felis catus | Cat | Carnivora | 179 | Felis bieti; Felis catus; Felis chaus; Felis manul; Felis margarita; Felis nigripes; Felis silvestris; Felis silvestris catus; Felis silvestris f.d. |
| Heterocephalus glaber | Naked mole rat | Rodentia | 100 | Heterocephalus glaber |
| Homo sapiens | Human | Primates | 442 | Homo erectus; Homo floresiensis; Homo georgicus; Homo habilis; Homo heidelbergensis; Homo naledi; Homo neanderthalensis; Homo rudolfensis; Homo sapiens |
| Macaca mulatta | Rhesus macaque | Primates | 354 | Macaca arctoides; Macaca assamensis; Macaca cyclopis; Macaca fascicularis; Macaca fascicularis group; Macaca fuscata; Macaca hecki; Macaca irus; Macaca leonina; Macaca maura; Macaca mulatta; Macaca mulatta group; Macaca nemestrina; Macaca nemestrina group; Macaca nigra; Macaca nigrescens; Macaca ochreata; Macaca pagensis; Macaca radiata; Macaca siberu; Macaca silenus; Macaca sinica; Macaca sinica group; Macaca sylvanus; Macaca sylvanus group; Macaca thibetana; Macaca tonkeana |
| Microcebus murinus | Mouse lemur | Primates | 217 | Microcebus berthae; Microcebus coquereli; Microcebus griseorufus; Microcebus murinus; Microcebus myoxinus; Microcebus ravelobensis; Microcebus rufus; Microcebus sambiranensis; Microcebus sp.; Microcebus tavaratra |
| Monodelphis domestica | Opossum | Didelphimorphia | 49 | Monodelphis adusta; Monodelphis americana; Monodelphis brevicaudata; Monodelphis dimidiata; Monodelphis domestica; Monodelphis emiliae; Monodelphis glirina; Monodelphis iheringi; Monodelphis kunsi; Monodelphis maraxina; Monodelphis osgoodi; Monodelphis palliolata; Monodelphis rubida; Monodelphis scalops; Monodelphis sorex; Monodelphis theresa; Monodelphis umbristriata; Monodelphis unistriata |
| Mus musculus | Mouse | Rodentia | 147 | Mus baoulei; Mus booduga; Mus bufo; Mus callewaerti; Mus caroli; Mus cervicolor; Mus cookii; Mus crociduroides; Mus famulus; Mus fernandoni; Mus fragilicauda; Mus goundae; Mus haussa; Mus indutus; Mus macedonicus; Mus mahomet; Mus mattheyi; Mus mayori; Mus minutoides; Mus musculoides; Mus musculus; Mus neavei; Mus orangiae; Mus oubanguii; Mus pahari; Mus phillipsi; Mus platythrix; Mus saxicola; Mus setulosus; Mus setzeri; Mus shortridgei; Mus sorella; Mus sp.; Mus spicilegus; Mus spretus; Mus tenellus; Mus terricolor; Mus triton; Mus vulcani |
| Mustela putorius furo | Ferret | Carnivora | 163 | Mustela africana; Mustela altaica; Mustela erminea; Mustela eversmanii; Mustela felipei; Mustela frenata; Mustela itatsi; Mustela kathiah; Mustela lutreola; Mustela lutreolina; Mustela nigripes; Mustela nivalis; Mustela nudipes; Mustela putorius; Mustela putorius furo; Mustela sibirica; Mustela strigidorsa; Mustela subpalmata; Mustela vison |
| Otolemur garnettii | Galago | Primates | 226 | Otolemur crassicaudatus; Otolemur garnetti; Otolemur garnettii; Otolemur monteiri |
| Pan troglodytes | Chimpanzee | Primates | 329 | Pan paniscus; Pan troglodytes |
| Phocoena phocoena | Harbour porpoise | Artiodactyla | 56 | Phocoena dioptrica; Phocoena phocoena; Phocoena sinus; Phocoena spinipinnis |
| Rattus norvegicus | Rat | Rodentia | 203 | Rattus adustus; Rattus andamanensis; Rattus annandalei; Rattus arfakiensis; Rattus argentiventer; Rattus arrogans; Rattus baluensis; Rattus blangorum; Rattus bontanus; Rattus burrus; Rattus colletti; Rattus elaphinus; Rattus enganus; Rattus everetti; Rattus exulans; Rattus feliceus; Rattus fuscipes; Rattus giluwensis; Rattus hainaldi; Rattus hoffmanni; Rattus hoogerwerfi; Rattus jobiensis; Rattus koopmani; Rattus korinchi; Rattus leucopus; Rattus losea; Rattus lugens; Rattus lutreolus; Rattus macleari; Rattus marmosurus; Rattus mindorensis; Rattus mollicomulus; Rattus montanus; Rattus mordax; Rattus morotaiensis; Rattus nativitatis; Rattus niobe; Rattus nitidus; Rattus norvegicus; Rattus norvegicus f.d.; Rattus norvegicus var.alba; Rattus novaeguineae; Rattus omichlodes; Rattus osgoodi; Rattus palmarum; Rattus pelurus; Rattus pococki; Rattus praetor; Rattus pyctoris; Rattus ranjiniae; Rattus richardsoni; Rattus salocco; Rattus sanila; Rattus satarae; Rattus simalurensis; Rattus sordidus; Rattus sp.; Rattus steini; Rattus stoicus; Rattus tanezumi; Rattus tawitawiensis; Rattus timorensis; Rattus tiomanicus; Rattus tunneyi; Rattus vandeuseni; Rattus verecundus; Rattus villosissimus; Rattus xanthurus |
| Sus scrofa | Pig | Artiodactyla | 159 | Sus ahoenobarbus; Sus barbatus; Sus bucculentus; Sus cebifrons; Sus celebensis; Sus oliveri; Sus philippensis; Sus salvanius; Sus scrofa; Sus scrofa domesticus; Sus verrucosus |
| Tupaia belangeri | Treeshrew | Scandentia | 229 | Tupaia belangeri; Tupaia chrysogaster; Tupaia dorsalis; Tupaia glis; Tupaia gracilis; Tupaia javanica; Tupaia longipes; Tupaia minor; Tupaia moellendorffi; Tupaia montana; Tupaia nicobarica; Tupaia palawanensis; Tupaia picta; Tupaia sp.; Tupaia splendidula; Tupaia tana |

## Variables per domain (all / core / M1-motor flagged)

| domain | variables | core | m1_motor |
|---|---|---|---|
| brain structure & size | 175 | 5 | 5 |
| cellular composition | 119 | 0 | 3 |
| cortical & cerebellar folding | 9 | 1 | 0 |
| body size | 2 | 1 | 0 |
| metabolism | 64 | 2 | 2 |
| life history | 18 | 8 | 0 |
| diet & ecology | 22 | 15 | 0 |
| behaviour & cognition | 20 | 0 | 9 |
| sensorimotor & motor pathways | 21 | 0 | 21 |
| hand & limb morphology | 22 | 0 | 22 |
| sleep & torpor | 7 | 0 | 0 |
| cellular morphology | 107 | 0 | 32 |
| sensory performance | 11 | 1 | 0 |

## Known caveats carried over from the compilation

- `_keys/README_species_cohorts.md` records open name-fragmentation rulings (e.g. ferret
  *Mustela putorius furo* vs polecat *M. putorius*; *Sus scrofa* re-pointed to the domestic form).
  The `uncounted_name_variants` column in the species table lists, per species, labels that hold
  data but are **not** counted because no ruling has adopted them.
- Coverage is availability, not agreement: a cell is filled if any source gives a value.
- Values are as compiled; see the source TSVs under `__Public/comparative-data/` and the per-merge
  READMEs under `__merging_*/` for method and provenance detail.

## Regenerating

```
Rscript __ShinyApp/build_data.R                       # only if ____EvoM1_TraitTable/*.xlsx changed
Rscript __Cytosplore_export/build_cytosplore_traits.R V1 genus 0.80
python3 __Cytosplore_export/audit_cytosplore_variables.py V1 genus
```
