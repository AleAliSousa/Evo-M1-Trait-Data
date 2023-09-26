This readme file was generated on 2022-07-15 by Kai R. Caspar



GENERAL INFORMATION

Title of Dataset: The evolution and biological correlates of hand preferences in anthropoid primates


Contact for this dataset
Name: Kai R. Caspar
ORCID: 0000-0002-2112-1050
Institution: University of Duisburg-Essen
Email: kai.caspar@uni-due.de

Date of data collection: September 2017 to May 2020 

Geographic location of data collection: Allwetterzoo Münster, Apenheul (Apeldoorn), Artis Amsterdam, Bali Wildlife Rescue Center, Bioparc de Doué-la-Fontaine, Burger’s Zoo (Arnhem), Erlebnis-Zoo Hannover, Howletts Wild Animal Park (Bekesbourne), Naturzoo Rheine, Parc Zoologique et Botanique de Mulhouse, Port Lympne Wild Animal Park (Lympne), Serengeti-Park Hodenhagen, Tierpark Aachen, Tierpark Berlin, Tierpark Hamm, Tierpark Hellabrunn (Munich), Tierpark Mönchengladbach, Tierpark Ulm, Wilhelma Stuttgart, Zoo Basel, Zoo Berlin, Zoo Dortmund, Zoo Dresden, Zoo Duisburg, Zoo Frankfurt, Zoo Heidelberg, Zoo Köln (Cologne), Zoo Krefeld, Zoo Landau in der Pfalz, Zoo Liberec, Zoo Magdeburg, Zoo Neuwied, Zoo Osnabrück, Zoo Wuppertal, Zoológico de São Paulo, Zoologischer Stadtgarten Karlsruhe, ZOOM Erlebniswelt Gelsenkirchen, ZooParc Overloon, and Zoopark Erfurt
Information about funding sources that supported the collection of the data: German Society for Mammalian Biology

DATA & FILE OVERVIEW

Individual-level_data.csv
	Tube task hand preference data for all subjects considered in the study, itemized at the individual level. Includes literature data.

Miscellaneous_individual-level_data.csv
	Tube task hand preference data from additional subjects that were not considered for the analyses in the study

Insertion-level_data.csv
	Tube task hand preference data for subjects newly tested for the study, itemized at the insertion level. Does not include literature data.

DATA FILE-SPECIFIC INFORMATION FOR: Individual-level_data.csv

1. Number of variables: 16

2. Number of individuals/rows: 1786

3. Variable List: 
	Genus: Genus classification for subject
	Species: Species classification for subject
	Location: Locality were the respective subject was sampled
	Subject: ID / house name of subject
	Sex: Sex of the subject (m = male / f = female)
	Age:Age cohort of subject (adult (sexually mature), juvenile (weaned, sexually immature), infant (not weaned, sexually immature)
	# insertions: Total # of insertions in the tube task (minimum: 30)
	Notes on insertions: Comments on the # or sampling of insertions in a given subject
	# bouts: Total # of bouts in the tube task, referring to uninterrupted sequences of insertions (minimum: 6)
	HI: Handedness index (continuous variable, range: -1 — 1), indicates direction of manual lateralization. -1 indicates that all tube task insertions were performed with the left hand, 1 that all were performed with the right hand. 0 indicates an equal number of left vs right insertions and thus ambipreference
	AbsHI: Absolute handedness index (continuous variable, range 0 — 1), indicates strength of manual lateralization. 1 indicates that all tube task insertions were performed with one preferred hand (regardless of it being the left or right one). 0 indicates an equal number of left vs right insertions and thus ambipreference
	z-score: Results of a binomial z-test on left vs right insertions. Values < -1.96 indicate significant left handedness, values > 1.96 indicate significant right handedness. Values inbetween -1.96 and 1.96 indicate a lack of significant individual hand preferences and thus ambipreference.
	Category: Hand preference category assignment of the respective individual (left / right / ambipreferent)	
	References: Literature reference for data that were derived from published papers (all references are also cited below). Non-referenced data were originally collected for this study (as indicated by references ="this study")
	General notes: Notes on sampling procedures for literature data
	Clade: Superordinate taxonomic affiliation of the respective individual (Cercopithecoidea / Hominoidea / Platyrrhini)

4. Missing data codes: 
	None

5. Abbreviations used: 
	NA; not applicable
	HI; Handedness index
	AbsHI; Absolute Handedness index

DATA FILE-SPECIFIC INFORMATION FOR: Miscellaneous_individual-level_data.csv

1. Number of variables: 14

2. Number of individuals/rows: 9

3. Variable List: 
	Genus: Genus classification for subject
	Species: Species classification for subject
	Location: Locality were the respective subject was sampled
	Subject: ID / house name of subject
	Sex: Sex of the subject (m = male / f = female)
	Age:Age cohort of subject (adult (sexually mature), juvenile (weaned, sexually immature), infant (not weaned, sexually immature)
	# insertions: Total # of insertions in the tube task (minimum: 30)
	# bouts: Total # of bouts in the tube task, referring to uninterrupted sequences of insertions (minimum: 6)
	HI: Handedness index (continuous variable, range: -1 — 1), indicates direction of manual lateralization. -1 indicates that all tube task insertions were performed with the left hand, 1 that all were performed with the right hand. 0 indicates an equal number of left vs right insertions and thus ambipreference
	AbsHI: Absolute handedness index (continuous variable, range 0 — 1), indicates strength of manual lateralization. 1 indicates that all tube task insertions were performed with one preferred hand (regardless of it being the left or right one). 0 indicates an equal number of left vs right insertions and thus ambipreference
	z-score: Results of a binomial z-test on left vs right insertions. Values < -1.96 indicate significant left handedness, values > 1.96 indicate significant right handedness. Values inbetween -1.96 and 1.96 indicate a lack of significant individual hand preferences and thus ambipreference.
	Category: Hand preference category assignment of the respective individual (left / right / ambipreferent)	
	References: Literature reference for data that were derived from published papers (all references are also cited below). Non-referenced data were originally collected for this study (as indicated by references ="this study")
	General notes: Notes on sampling procedures for literature data
	Clade: Superordinate taxonomic affiliation of the respective individual (Cercopithecoidea / Lemuriformes / Platyrrhini)

4. Missing data codes: 
	None

5. Abbreviations used: 
	HI; Handedness index
	AbsHI; Absolute Handedness index

DATA FILE-SPECIFIC INFORMATION FOR: Insertion-level_data.csv

1. Number of variables: 14

2. Number of individuals/rows: 25382

3. Variable List: 
	Genus: Genus classification for subject
	Species: Species classification for subject
	Subject: ID / house name of subject
	Sex: Sex of the subject (m = male / f = female)
	Age:Age cohort of subject (adult (sexually mature), juvenile (weaned, sexually immature), infant (not weaned, sexually immature)
	Date: Date of sampling for the respective insertion event
	Bout: Bouts in the tube task to which the respective insertion is assigned to. A bout is an uninterrupted sequence of insertions (minimum per individual: 6). Counted separately for each individual.
	Insertion event: # of insertions in the respective bout (minimum: 1)
	Notes on insertions: Comments on the # or sampling of insertions in a given subject
	Hand used to insert: Identity of hand (left vs right) used in the respective insertion event.
	Handed in with: Hand that the experimenter used to pass the tube on to the subject for the bout in question. NA if the tube was not handed over tp the subject directly but was instead placed into the enclosure.
	Posture: Body posture of the individual while performing an insertion event (sitting, suspended, crouched bipedal stance, erect bipedal stance).
	Fingers used: Fingers of the hand used to perform a respective insertion event. Fingers and thumb may be listed individually (Thumb, Index (= index finger), Middle (= middle finger), Ring (= ring finger), Pinkie (= pinkie finger). If all fingers but not the thumb was used to insert, we noted "fingers". If all fingers and thumb were inserted simultaneously, we noted "hand".
	Location: Locality were the respective subject was sampled
	Clade: Superordinate taxonomic affiliation of the respective individual (Cercopithecoidea / Hominoidea / Platyrrhini)

4. Missing data codes: 
	None

5. Abbreviations used: 
	NA; not applicable

SHARING/ACCESS INFORMATION

Licenses/restrictions placed on the data: 
This work is licensed under a CC0 1.0 Universal (CC0 1.0) Public Domain Dedication license.

REFERENCES

Literature data referenced in the files derive from the following studies:

Canteloup, C., Vauclair, J., & Meunier, H. (2013). Hand preferences on unimanual and bimanual tasks in Tonkean macaques (Macaca tonkeana). American Journal of Physical Anthropology, 152(3), 315-321. doi:https://doi.org/10.1002/ajpa.22342

Caspar, K. R., Mader, L., Pallasdies, F., Lindenmeier, M., & Begall, S. (2018). Captive gibbons (Hylobatidae) use different referential cues in an object-choice task: insights into lesser ape cognition and manual laterality. PeerJ, 6, e5348. doi:10.7717/peerj.5348

Chatagny, P., Badoud, S., Kaeser, M., Gindrat, A.-D., Savidan, J., Fregosi, M., . . . Rouiller, E. M. (2013). Distinction between hand dominance and hand preference in primates: a behavioral investigation of manual dexterity in nonhuman primates (macaques) and human subjects. Brain and Behavior, 3(5), 575-595. doi:https://doi.org/10.1002/brb3.160

Cochet, H., & Vauclair, J. (2012). Hand preferences in human adults: non-communicative actions versus communicative gestures. Cortex, 48(8), 1017-1026. doi:https://doi.org/10.1016/j.cortex.2011.03.016

Cubí, M., & Llorente, M. (2021). Hand preference for a bimanual coordinated task in captive hatinh langurs (Trachypithecus hatinhensis) and grey-shanked douc langurs (Pygathrix cinerea). Behavioural Processes, 187, 104393. doi:https://doi.org/10.1016/j.beproc.2021.104393

de Andrade, A. C., & de Sousa, A. B. (2018). Hand preferences and differences in extractive foraging in seven capuchin monkey species. American Journal of Primatology, 80(8), e22901. doi:https://doi.org/10.1002/ajp.22901

Fan, P., Liu, C., Chen, H., Liu, X., Zhao, D., Zhang, J., & Liu, D. (2017). Preliminary study on hand preference in captive northern white-cheeked gibbons (Nomascus leucogenys). Primates, 58(1), 75-82. doi:10.1007/s10329-016-0573-8

Hopkins, W. D., Phillips, K. A., Bania, A., Calcutt, S. E., Gardner, M., Russell, J., . . . Schapiro, S. J. (2011). Hand preferences for coordinated bimanual actions in 777 great apes: implications for the evolution of handedness in hominins. Journal of Human Evolution, 60(5), 605-611. doi:10.1016/j.jhevol.2010.12.008

Maille, A., Belbeoc'h, C., Rossard, A., Bec, P., & Blois-Heulin, C. (2013). Which are the features of the TUBE task that make it so efficient in detecting manual asymmetries? An investigation in two Cercopithecine species (Cercopithecus neglectus and Cercocebus torquatus). Journal of Comparative Psychology, 127(4), 436-444. doi:10.1037/a0032227

Meguerditchian, A., Donnot, J., Molesti, S., Francioly, R., & Vauclair, J. (2012). Sex difference in squirrel monkeys’ handedness for unimanual and bimanual coordinated tasks. Animal Behaviour, 83(3), 635-643. doi:https://doi.org/10.1016/j.anbehav.2011.12.005

Morino, L., Uchikoshi, M., Bercovitch, F., Hopkins, W. D., & Matsuzawa, T. (2017). Tube task hand preference in captive hylobatids. Primates, 58(3), 403-412. doi:10.1007/s10329-017-0605-z

Motes Rodrigo, A., Ramirez Torres, C. E., Hernandez Salazar, L. T., & Laska, M. (2018). Hand preferences in two unimanual and two bimanual coordinated tasks in the black-handed spider monkey (Ateles geoffroyi). Journal of Comparative Psychology, 132(2), 220-229. doi:10.1037/com0000110

Nelson, E. L., & Boeving, E. R. (2015). Precise digit use increases the expression of handedness in Colombian spider monkeys (Ateles fusciceps rufiventris). American Journal of Primatology, 77(12), 1253-1262. doi:https://doi.org/10.1002/ajp.22478

Phillips, K. A., Sherwood, C. C., & Lilak, A. L. (2007). Corpus callosum morphology in capuchin monkeys is influenced by sex and handedness. PLOS ONE, 2(8), e792. doi:10.1371/journal.pone.0000792

Regaiolli, B., Spiezio, C., & Hopkins, W. D. (2018). Hand preference on unimanual and bimanual tasks in Barbary macaques (Macaca sylvanus). American Journal of Primatology, 80(3), e22745. doi:https://doi.org/10.1002/ajp.22745

Schmitt, V., Melchisedech, S., Hammerschmidt, K., & Fischer, J. (2008). Hand preferences in Barbary macaques (Macaca sylvanus). Laterality, 13(2), 143-157. doi:10.1080/13576500701757532

Schweitzer, C., Bec, P., & Blois-Heulin, C. (2007). Does the complexity of the task influence manual laterality in de Brazza’s monkeys (Cercopithecus neglectus)? Ethology, 113(10), 983-994. doi:https://doi.org/10.1111/j.1439-0310.2007.01405.x

Spoelstra, K. (2021). Lateralized behavior in white-handed gibbons (Hylobates lar). Master Thesis. Linköping University, Linköping.

Vauclair, J., Meguerditchian, A., & Hopkins, W. D. (2005). Hand preferences for unimanual and coordinated bimanual tasks in baboons (Papio anubis). Cognitive Brain Research, 25(1), 210-216. doi:https://doi.org/10.1016/j.cogbrainres.2005.05.012

Zhao, D., Hopkins, W. D., & Li, B. (2012). Handedness in nature: first evidence on manual laterality on bimanual coordinated tube task in wild primates. American Journal of Physical Anthropology, 148(1), 36-44. doi:https://doi.org/10.1002/ajpa.22038

