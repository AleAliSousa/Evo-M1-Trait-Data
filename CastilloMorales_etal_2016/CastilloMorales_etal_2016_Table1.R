# CastilloMorales_etal_2016_Table1.R
#
# Castillo-Morales A, Monzon-Sandoval J, de Sousa AA, Urrutia AO,
# Gutierrez H (2016). Neocortex expansion is linked to size variations in
# gene families with chemotaxis, cell-cell signalling and immune response
# functions in mammals. Open Biology 6: 160132. doi:10.1098/rsob.160132
#
# Item: Table 1 -- phenotypic traits for the 28 mammalian species analysed:
# brain volume (cm3), neocortex volume (cm3), the literature source of the
# volumes (refs 84-99), neocortex ratio Nr, encephalization index Ei and
# maximum lifespan MLSP.
#
# Frozen source: the publisher PDF of the paper in this folder
# (Castillo-Morales-2016-Neocortex_expansion.pdf, downloaded from
# rsob.royalsocietypublishing.org). Table 1 is a printed table in the paper,
# so the build is a verified transcription: the table below is the
# transcription, and the script checks it by recomputing Nr from the two
# volume columns for all 28 rows.
#
# Data role: SECONDARY compilation. The authors compiled each species'
# volumes from the single literature source named in Source; Ei derives
# from brain/body masses for 493 species provided by Gonzalez-Lagos et al.
# 2010 (paper ref 83). Nothing in this table is a primary measurement.
#
# Transcription notes:
#   * Ei signs: the PDF text layer renders the minus sign as a leading "2"
#     (e.g. -2.014 prints as "22.014"); the signed values below are as
#     intended by the paper's formula Ei = ln(brain mass / body mass^0.64).
#   * Volumes kept in cm3 exactly as printed (no unit conversion).
#
# Outputs:
#   CastilloMorales_etal_2016_Table1.csv          (this folder)
#   public_tsv/10.1098%2Frsob.160132_Table1.tsv   (for __Public/comparative-data/)
#
# Registry note: the public TSV name is the expected Item encoded
# (10.1098%2Frsob.160132_Table1). The registry row in __ReadMe.xlsx is an
# owner step.

tab <- data.frame(
  species_sci = c("Ailuropoda melanoleuca","Callithrix jacchus","Canis familiaris",
    "Cavia porcellus","Echinops telfairi","Erinaceus europaeus","Gorilla gorilla",
    "Homo sapiens","Loxodonta africana","Macaca mulatta","Macropus eugenii",
    "Microcebus murinus","Mus musculus","Mustela putorius furo",
    "Ornithorhynchus anatinus","Ovis aries","Pan troglodytes","Papio anubis",
    "Pongo abelii","Procavia capensis","Pteropus vampyrus","Rattus norvegicus",
    "Sarcophilus harrisii","Sorex araneus","Sus scrofa","Tarsius syrichta",
    "Tursiops truncatus","Vicugna pacos"),
  common_name = c("giant panda","marmoset","dog (poodle)","guinea pig",
    "lesser hedgehog tenrec","hedgehog","gorilla","human","elephant","macaque",
    "wallaby","mouse lemur","mouse (C57BL/6J)","European polecat","platypus",
    "sheep","chimpanzee","olive baboon","orangutan","hyrax","megabat","rat",
    "Tasmanian devil","shrew","pig","tarsier","dolphin","alpaca"),
  Brain_volume_cm3 = c(211.80935,7.241,458.273,4.671815,0.566,3.05,470.359,
    1251.847,3886.7,87.896,11.6637,1.68,0.48,8.8996,8.57145,100.332,382.103,
    190.957,304.2,12.68,8.89,1.69,15.1517,0.188,106.660,3.393,1376.976,181.467),
  Neocortex_volume_cm3 = c(136.43571,4.371,177.753,1.5798,0.0515,0.522,341.444,
    1006.525,2460.1,63.482,4.3987,0.74,0.12,4.147,4.09928,53.793,291.592,
    140.142,219.8,5.54,3.61,0.58,3.7334,0.0264,54.3913,1.768,1088.615,101.81),
  Source_ref_no = c(84,85,86,87,85,85,85,85,88,85,89,85,90,91,92,93,85,85,94,
    95,96,95,89,85,97,85,98,99),
  Source = c("Pirlot_Jiao_1985","Stephan_etal_1981","Schleifenbaum__1973",
    "Kruska__2014","Stephan_etal_1981","Stephan_etal_1981","Stephan_etal_1981",
    "Stephan_etal_1981","Hakeem_etal_2005","Stephan_etal_1981","Pirlot__1981",
    "Stephan_etal_1981","Beatty_Laughlin_2006","Roehrs__1986",
    "Pirlot_Nelson_1978","Ebinger__1974","Stephan_etal_1981",
    "Stephan_etal_1981","Zilles_Rehkaemper_1988","Bush_Allman_2004",
    "Baron_etal_1996","Bush_Allman_2004","Pirlot__1981","Stephan_etal_1981",
    "Kruska_Rohrs_1974","Stephan_etal_1981","Tschudin__1998","Kruska__1980"),
  Nr = c(1.81,1.52,0.63,0.51,0.10,0.21,2.65,4.10,1.72,2.60,0.61,0.79,0.32,0.87,
    0.92,1.16,3.22,2.76,2.60,0.78,0.68,0.52,0.33,0.16,1.04,1.09,3.78,1.28),
  Ei = c(-2.014,-1.627,-1.699,-2.948,-3.274,-2.863,-1.415,0.152,-1.082,-1.192,
    -2.207,-1.985,-2.832,-2.548,-2.219,-1.961,-0.948,-1.178,-0.892,-2.255,
    -2.204,-2.861,-2.792,-2.832,-2.468,-1.795,-0.321,-1.688),
  MLSP_years = c(36.8,16.5,24,12,19,11.7,55.4,122.5,65,40,15.1,18.2,4,11.1,
    22.6,22.8,59.4,37.5,59,14.8,20.9,5,13,3.2,27,16,51.6,25.8),
  stringsAsFactors = FALSE)

# Check: Nr recomputed from the volume columns must match the printed Nr.
nr_calc <- tab$Neocortex_volume_cm3 / (tab$Brain_volume_cm3 - tab$Neocortex_volume_cm3)
stopifnot(all(abs(round(nr_calc, 2) - tab$Nr) <= 0.011))
stopifnot(nrow(tab) == 28, !anyDuplicated(tab$species_sci))

write.csv(tab, "CastilloMorales_etal_2016_Table1.csv", row.names = FALSE)
write.table(tab, "public_tsv/10.1098%2Frsob.160132_Table1.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
