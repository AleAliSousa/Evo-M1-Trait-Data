# New papers in the Orlin folder: contribution to Evo-M1-Trait-Data

Reviewed 2026-10-25. This is a recommendation report, not an inclusion decision or data import.

## Scope and screening

The project covers mammalian M1, V1, and entorhinal cortex, together with regional anatomy, cellular measures, sensory function, motor behavior, cognition, ecology, and energetic context. Entorhinal and hippocampal coverage are particularly relevant gaps. Hippocampal measures complement the entorhinal arm; they must not be relabelled as entorhinal measurements.

I inventoried the full Orlin tree (243 PDFs, including drafts and figures; 232 distinct PDF byte hashes; 40 XLSX, 17 XLS, and 25 CSV files), extracted available PDF text, and examined the most relevant papers and supplements. Selected scanned pages were inspected visually. This is a source scout, not a complete transcription or a cell-by-cell novelty audit. The counts describe files, not independent papers. Not every old XLS or Word attachment was numerically parsed.

Novelty was checked against the current `__ReadMe.xlsx` citation/item registry, the SOURCE_DISPOSITION and PROPOSED_CHANGES worksheets, source folders, `PROJECT_SCOPE_AND_DATASET_ROADMAP.md`, and `SOURCE_DISPOSITION_REGISTER.md`. For the main recommendations I checked publication identity using titles and DOI, rather than first-author/year alone. All papers recommended below are absent as registered sources in this checkout. A citation in another paper's bibliography does not constitute inclusion. Absence here does not establish absence from every other user repository or literature library.

The previous shortlist of Stephan, Frahm & Zilles, Reep, and DeCasien compilations did not meet the user's request for new papers. Those are not recommendations here. New-paper status also does not imply that every measurement is independent of existing sources.

## Strongest additions

### 1. Lewitus, Hof & Sherwood (2012), Evolution: comparative V1 and hippocampal cell densities

**Highest priority for the cellular dataset.** *Phylogenetic comparison of neuron and glia densities in the primary visual cortex and hippocampus of carnivores and primates*, Evolution 66:2551–2563, DOI **10.1111/j.1558-5646.2012.01601.x**. The study covers 37 primate and 21 carnivore species. Main **Table 2** reports neuronal density, glial density, and glia:neuron ratio for V1 and hippocampus. This is an unusually direct match to comparative regional cellular organization.

The project already registers a DIFFERENT Lewitus 2012 paper, *Cellular signatures in the primary visual cortex of phylogeny and placentation*, DOI 10.1007/s00429-011-0338-5. Its README explicitly notes missing primate density data in the local supplement. The Evolution paper therefore deserves a separate source identity and an overlap audit, prioritizing hippocampal values and potentially missing primate V1 values. Preserve stereology, sampling region, and density units; a sampled density is not a whole-region neuron total.

The local XLS was identified from embedded labels and its exact match to the publisher's supplement name; numeric cells were not parsed. Its S1–S3 labels include species and non-primate cellular/volumetric data, so do not assume it contains the complete hippocampal table. Acquire/use the main article's Table 2 as the first target. [Publisher and supplement listing](https://academic.oup.com/evolut/article-abstract/66/8/2551/6851653); [indexed article PDF with Table 2](https://legacy.lib.westfield.ma.edu/mongoose/sites/default/files/Lewitus_2012_Evolution.pdf).

Local sources: [lewitus_2012 EVO_1601_sm_suppmatS1.xls](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project home range hippocampus/add to mastercopy/added/lewitus_2012 EVO_1601_sm_suppmatS1.xls>).

### 2. Benson-Amram et al. (2016): carnivore problem solving and dexterity

**Highest priority for behavior/M1 context.** *Brain size predicts problem-solving ability in mammalian carnivores*, DOI **10.1073/pnas.1505913113**. The local **Dataset S1** is immediately usable: I counted **495 trial rows, 140 individual IDs, and 39 species**. It contains success opening a puzzle box, latency, working time, behavioral diversity, dexterity scores, sex, trial number, and apparatus size, alongside secondary brain/body measures.

Keep trial, individual, and species levels explicit when producing summaries. Repeated species brain volumes across trials are not independent brain specimens. The paper also describes regional endocranial measurements for 17 species; audit their source and endocast definitions separately. The behavioral observations are the strongest contribution, and the paper's main Tables 1–3 are model results rather than the intake target. [Published article](https://pmc.ncbi.nlm.nih.gov/articles/PMC4780594/).

Local sources: [Benson-Amram-2016-Brain size predicts.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Benson-Amram-2016-Brain size predicts.pdf>), [pnas.1505913113.sd01.xlsx](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/pnas.1505913113.sd01.xlsx>).

### 3. Amunts et al. (2005): human entorhinal and hippocampal volumes

**Highest priority for the entorhinal gap.** *Cytoarchitectonic mapping of the human amygdala, hippocampal region and entorhinal cortex: intersubject variability and probability maps*, DOI **10.1007/s00429-005-0025-5**. **Table 1**, printed p. 346/PDF p. 4, gives left/right means and SDs in mm³ for **10 human brains**, including entorhinal cortex, dentate gyrus, CA1–3, subiculum, HATA, and amygdala groups.

I visually checked the table and volume methods. The entorhinal means are 1745 ± 370 mm³ left and 1678 ± 309 mm³ right. Values are histological estimates corrected for individual tissue shrinkage. Keep laterality and pooled CA1–3 explicit. There are discrepancies between the table and later prose for right hippocampal/amygdala totals; preserve a source discrepancy note and verify against any correction before using those totals. This is one human cohort, not comparative species replication. [Publication record](https://pubmed.ncbi.nlm.nih.gov/16208455/).

Local sources: [Amunts-2005-Cytoarchitectonic ma.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/hippocampus subregions and subfunctions/Amunts-2005-Cytoarchitectonic ma.pdf>).

### 4. Slomianka et al. (2013): sengi hippocampal principal cell numbers

**High priority for cell counts and taxonomic breadth.** *The hippocampus of the eastern rock sengi: cytoarchitecture, markers of neuronal function, principal cell numbers, and adult neurogenesis*, DOI **10.3389/fnana.2013.00034**. **Table 2** supplies unilateral principal cell counts in dentate gyrus, hilus/CA4, CA3, CA1, and subiculum for *Elephantulus myurus*: four males and four females, with pooled and sex-specific means and SDs. **Table 4** adds PCNA+, DCX+, and apoptotic cell counts for 12 animals.

The 14 animals described in methods are not the sample size for every measurement. Preserve unilateral status and distinguish principal cells, proliferation markers, and young-neuron markers. Table 3 contains derived cross-species ratios, not a second set of independent primary counts. [Author manuscript](https://repository.up.ac.za/bitstream/handle/2263/33196/Slomianka_Hippocampus_2013.pdf).

Local sources: [Slomianka-2013-The hippocampus of t.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/hippocampus subregions and subfunctions/Slomianka-2013-The hippocampus of t.pdf>).

### 5. Meyer (1981): brain component masses, including two marsupials

**High priority for regional anatomy and broader mammal coverage.** *A quantitative comparison of the parts of the brains of two Australian marsupials and some eutherian mammals*, Brain Behav Evol 18:60–71. Primary dissection data compare quokka, brush-tailed possum, rat, rabbit, cat, sheep, and human.

**Table II** (printed p. 62 onward) gives brain component weights in grams, with mean ± SE. I visually checked its first page and methods: 10 quokkas, 10 rats, and five each of the other five taxa (45 brains). It includes cerebellum, medulla, pons, midbrain, olfactory bulbs, and olfactory tubercles; read the full continuation before defining the complete item. This is regional MASS, not volume. Preserve fixation/dissection differences and do not convert g to mm³ without an explicit justified density assumption. Two copies are present, with poor text extraction; use the clearer scan in `zz more data brain` for transcription.

Local sources: [meyer_1981.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/zz more data brain/meyer_1981.pdf>).

### 6. Stevens (2014): primate intertemporal choice

**High priority for a distinct behavioral trait.** *Evolutionary pressures on primate intertemporal choice*, DOI **10.1098/rspb.2014.0499**. The local CSV (**Data S1**) has **941 records across measures**, of which **96 are indifference-point records across 13 primate species**. The file retains subject, value, sample size, SD, reference, and notes. It is not 941 independent behavioral subjects.

Delay-choice/indifference points complement the already-held MacLean inhibitory-control tasks, but should remain a separate task measure. Reward amounts, liquids versus solids, adjusting procedures, and repeated use of primary experiments matter. Brain volume and much ecological information are secondary; intake should prioritize the behavioral values and keep primary references. [Article and methods](https://pmc.ncbi.nlm.nih.gov/articles/PMC4046412/).

Local sources: [Stevens-2014-Evolutionary pressur.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project self-control and brain size/self-control papers/Stevens-2014-Evolutionary pressur.pdf>), [rspb20140499supp2.csv](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project self-control and brain size/self-control papers/Stevens 2014 suppl/rspb20140499supp2.csv>).

### 7. Nummela et al. (2013): comparative peripheral sensory anatomy

**High priority for the V1/sensory context, with a separate anatomy destination.** *Exploring the mammalian sensory space: co-operations and trade-offs among senses*, DOI **10.1007/s00359-013-0846-2**. **Supplementary Table S2** contains body mass, axial eye diameter, cribriform plate area, tympanic membrane area, habitat, diet, and references for **119 mammal species**. S1 adds retinal, olfactory epithelium, basilar membrane, and cochlear dimensions; S3 includes infraorbital foramen area.

These are anatomical traits, not audiogram thresholds or visual acuity. The current sensory merge is percepts-only, so this needs an anatomy-aware route. S1 and S3 contain transformed quantities; retain transformation/units and prefer raw S2 values when available. This is a compilation, so deduplicate shared eye dimensions and other values against their primary studies. [Publication record](https://pubmed.ncbi.nlm.nih.gov/24043357/).

Local sources: [Nummela-2013-Exploring the mammal.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Nummela-2013-Exploring the mammal.pdf>), [Nummela_supp.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Nummela_supp.pdf>).

## Further worthwhile additions

### 8. West & Gundersen (1990): human hippocampal neuron counts

*Unbiased stereological estimation of the number of neurons in the human hippocampus*, J Comp Neurol 296:1–22. **Table 2** gives individual and summary volumes, numerical densities, and neuron totals for five hippocampi and five subdivisions: dentate granule cell layer, hilus, CA3–2, CA1, and subiculum. **Table 1** supplies cohort information; ages are 47–85 years. Valuable human cellular reference. Preserve age, laterality, and cellular-layer boundaries; layer volume must not be mapped to whole-subfield volume. The West 1990 thesis in the same folder is a potential duplicate route, not another independent cohort.

Local sources: [west_gundersen_1990.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/hippocampus subregions and subfunctions/west_gundersen_1990.pdf>).

### 9. Slomianka & West (1989): layered hippocampal volumes in wild mice

*Comparative quantitative study of the hippocampal region of two closely related species of wild mice*, DOI **10.1002/cne.902800405**. **Table 1** gives means and SDs for 17 listed structures/combinations in *Apodemus flavicollis* and *A. sylvaticus*, with two geographical samples of the latter, six animals per group. Adds telencephalic and fine hippocampal component volumes. Keep population and anatomical layer definitions; derived ratios and overlapping parts/totals are not extra independent measurements.

Local sources: [Slomianka-1989-Comparative quantita.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/hippocampus subregions and subfunctions/Slomianka-1989-Comparative quantita.pdf>).

### 10. West & Schwerdtfeger (1985): hippocampal components in three mammals

*An allometric study of hippocampal components*, DOI **10.1159/000118723**. The visually inspected first page confirms primary volume measurements in European hedgehog (*Erinaceus europaeus*), tree shrew (*Tupaia glis*), and marmoset (*Callithrix jacchus*), using Timm-stained perfused brains. Particularly relevant for laminar hippocampal anatomy. Exact table/sample audit remains to be done because the local PDF is image-only. Check specimen provenance and definitions against Stephan/Frahm before treating overlapping species totals as independent.

Local sources: [West 1985 Allometric Pinsvin Tupia Marmo.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/hippocampus subregions and subfunctions/West 1985 Allometric Pinsvin Tupia Marmo.pdf>).

### 11. Jacobs & Spencer (1994): kangaroo rat hippocampal volumes

*Natural space-use patterns and hippocampal size in kangaroo rats*. **Table 1** includes body/brain weights, hippocampal volume, sample size, and mean ± SE for *Dipodomys merriami*, *D. spectabilis*, and *D. ordii*, with sex groups where available. Useful rodent anatomy and sex context. Preserve the one-animal *D. ordii* row and sex-specific uncertainty instead of presenting all species as equally sampled. The companion Jacobs et al. (1990) vole paper is also absent and worth checking for its primary sex-specific hippocampal observations.

Local sources: [jacobs_spencer_1994.PDF](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/home range hippocampus/jacobs_spencer_1994.PDF>).

### 12. Patzke et al. (2015; online 2013): selected new hippocampal records

*In contrast to many other mammals, cetaceans have relatively small hippocampi that appear to lack adult neurogenesis*, DOI **10.1007/s00429-013-0660-1**. The filename uses the online year; the journal publication is 2015.

**Table 1** is mainly a secondary compilation from Stephan, Baron, Reep, Pirlot/Nelson, and Montie. Prioritize the rows labelled **source 5, current study**: two hippos, two harbour porpoises, one bottlenose dolphin, two minke whales, one black rhinoceros, and three African elephants. These are candidate additions, subject to checking reuse in other Manger-group reports. Brain volumes are calculated from mass, as the table footnote states, and should retain that derivation. **Table 2** supplies method-specific neurogenesis evidence, including the study's observations. Treat DCX non-detection as a result under the reported assay, not definitive biological absence. Do not import the 375-species compilation as 375 new observations. [Publication date and abstract](https://pubmed.ncbi.nlm.nih.gov/24178679/).

Local sources: [Patzke-2013-In contrast to many.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/hippocampus misc/Patzke-2013-In contrast to many.pdf>).

### 13. Weisbecker, Ashwell & Fisher (2013): improved marsupial body masses

*An improved body mass dataset for the study of marsupial brain size evolution*, DOI **10.1159/000348647**. The local workbook has **191 named rows with brain volume values**, plus male/female/average body masses and mandible-based mass estimates. The published supplement's principal contribution is revised body mass for interpreting Ashwell's endocranial volumes. It is not independent new measurement of all those brains. Useful for the body/ecology backbone after reconciling with existing body-mass sources. [Publisher paper describing the supplement](https://karger.com/bbe/article-pdf/82/2/81/2263638/000348647.pdf).

Local sources: [Weisbecker_2013_marsupial_brain wtvol_body mass-MF.xlsx](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project home range hippocampus/add to mastercopy/Weisbecker_2013_marsupial_brain wtvol_body mass-MF.xlsx>).

## Other new papers worth selective follow-up

These are lower priority than the anatomical/cellular and standardized behavioral additions above. They are not confirmed ready-to-merge datasets.

- **Gómez et al. (2016), The phylogenetic roots of human lethal violence.** Supplement section IX.A has species, number of deaths, percentage caused by conspecifics, and reference codes. A potentially valuable new aggression dimension. Preserve sampling denominator and distinguish observed non-detection from absence; do not map lethal aggression to general aggression. Source: [Gomez, 2016 - supp.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/_aggression/Gomez, 2016 - supp.pdf>).

- **Opie et al. (2013), primate monogamy supplement.** Published-source candidate with mating system, paternal care, female ranging, infanticide, and source fields. Useful socioecological traits if absent from the existing DeCasien/PanTHERIA-derived products. Source-specific overlap audit required. Source: [opie2013 sd01.xlsx](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project home range hippocampus/add to mastercopy/added/opie2013 sd01.xlsx>).

- **Pontzer & Kamilar (2009), Great ranging associated with greater reproductive investment in mammals.** Table S1 supplies daily movement distance and life-history/body-size measures. Daily distance is potentially useful locomotor/energetic context; it is not home-range area. Many covariates are secondary. Source: [Pontzer-2009-suppl.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/home range reproductive investment/Pontzer-2009-suppl.pdf>).

- **Burkart et al. (2014), The evolutionary origin of human hyper-cooperation.** Standardized prosociality tests in 24 groups of 15 primate species. Main Table 2 is a subject/group roster, not performance values; obtain the actual performance supplement before building. Useful behavioral extension. Source: [burkart_etal_2014.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers temp/burkart_etal_2014.pdf>).

- **Coleman (2009), What Do Primates Hear?.** Reviews behavioral audiograms for 29 nonhuman primate species. Valuable for missing primary studies and measurement comparability. Much may duplicate existing hearing sources, so use a primary-paper gap audit rather than a second pooled audiogram dataset. Source: [Coleman-2009-What Do Primates Hea.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Coleman-2009-What Do Primates Hea.pdf>).

- **Strier (2014) supplement.** Contains group size variability, sex ratios, dispersal, grouping, and duration of observations. Potentially complementary social variability traits; resolve exact citation before intake. Source: [Strier2014_Table_S1.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project home range hippocampus/add to mastercopy/social structure data/Strier2014_Table_S1.pdf>).

- **Fisher & Owens (2000), Female home range size and the evolution of social organization in macropod marsupials.** Potential sex-specific ranging and ecological context for marsupials. Check existing PanTHERIA records and original-source ancestry. Source: [Fisher-2000-Female home range si.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/home range social/Fisher-2000-Female home range si.pdf>).

- **Davis et al. (1967) and Davis & Leary (1968).** Oddity/detour performance across eight primate species. Primary-task candidates, but compare with the primary experiments underlying Deaner and Shultz before claiming independent new behavior. Source: [davis_leary_1968.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/Project hippocampus subregions/davis_leary_1968.pdf>).

- **Edler (2007), hippocampus thesis.** A thesis rather than a new journal paper. Potential primary hippocampal material, with local spreadsheets, but provenance and overlap with Sherwood/DeCasien unpublished material must be resolved. Source: [Edler_Melissa_dissertation.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/home range hippocampus primates/Edler_Melissa_dissertation.pdf>).

- **Harman (1997), quokka hippocampal development.** Potential developmental context and age-specific hippocampal measures. Lower priority for a primarily adult comparative dataset; retain stage-specific measures if pursued. Source: [Harman-1997-Development and cell.pdf](</Users/crossmodal/Library/CloudStorage/Dropbox/COLLABORATIVE/Orlin/papers hippocampus home range etc/home range brain other taxa/Harman-1997-Development and cell.pdf>).

## New citations with limited incremental value, and files not to mistake for new papers

- **Barton & Venditti (2014)** has cerebellum/neocortex compilation tables, but its supplement explicitly cites upstream MacLeod, Bush/Allman, Rilling/Insel, Stephan, and other studies. Use it to identify missing primaries (including the Evolution Lewitus paper), not as an independent measurement team.
- **Safi & Dechmann (2005), Hutcheon et al. (2002), and Pitnick et al. (2006)** have comparative bat ecological or mating-system data. These may add ecological traits, but the brain measurements need checking against the extensive Baron coverage already included.
- **Healy's flicker-fusion CSV** may identify older primary studies, but the project already registers Haarlem et al. (2026)'s CFF dataset. The Orlin CSV visibly has numbers with apparently concatenated citation markers in some mass/metabolic fields; do not ingest it as clean numeric data.
- **Long et al. (2015)** concerns stem-primate endocast/neocortical surface ratios. It is a new paper, but lower priority for extant mammals and not a direct cortical tissue-volume measure.
- **Bozek et al. (2014)** adds metabolomic concentrations, not cerebral energy-use rates. It would require a distinct molecular dataset scope and should not be substituted for glucose/oxygen consumption.
- **Kruska-2013** is the already-registered Kruska 2014 wild-cavy/guinea-pig paper, under its early-online year.
- **Stephan, Frahm & Zilles, Reep, DeCasien, MacLean 2014, McGuire & Ratcliffe 2011, Olkowicz 2016, and the Todorov hippocampus compilation** are already represented. Their local working copies are not new papers.
- Experimental lesion/transgenic mechanism papers, human height papers, general reviews, drafts, and model-output tables are lower-value sources of normal comparative mammalian traits for this request.

## Recommended sequence

Start with **Lewitus (Evolution 2012)** for cellular coverage, **Benson-Amram 2016** for behavior/dexterity, and **Amunts 2005** for direct entorhinal anatomy. Next add **Slomianka 2013**, **Meyer 1981**, and **Stevens 2014**. Nummela merits inclusion once sensory anatomy has an appropriate destination. Then pursue the additional hippocampal sources and selected Patzke primary rows.

Only this review report was added. The recommendations identify source items for future intake; their final merge eligibility depends on specimen/source overlap, units, laterality, anatomical definitions, and primary-versus-secondary roles.
