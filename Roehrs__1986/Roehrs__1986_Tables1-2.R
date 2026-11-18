# Roehrs__1986_Tables1-2.R
#
# Roehrs M (1986). Cephalisation, Telencephalisation und
# Neocorticalisation bei Mustelidae. Zeitschrift fuer Zoologische
# Systematik und Evolutionsforschung 24: 157-166.
# doi:10.1111/j.1439-0469.1986.tb00624.x
#
# Items: Table 1 -- gross body weights and brain weights (species means,
# n) and cephalisation index for 20 mustelid species; Table 2 --
# species-typical net volumes (mm3) of whole brain, telencephalon,
# neocortex and allocortex + corpus striatum for 10 species.
#
# Frozen source: the publisher PDF scan in this folder
# (Ro_hrs-1986-Cephalisation__Telen.pdf), supplied by Michael Proulx.
# Both tables were transcribed from the printed pages and verified
# against page images (journal pp. 161 and 163); German decimal commas
# converted to points.
#
# Provenance: Table 1 values are the Hannover group's species means
# (three species after Drescher 1977, flagged in the CSV). Table 2
# volumes rest on the volume determinations of Schumacher (1963) and
# Thiede (1973), converted by Roehrs to species-typical values using
# Table 1's means (subadults removed).
#
# Outputs:
#   Roehrs__1986_Table1.csv / Roehrs__1986_Table2.csv   (this folder)
#   public_tsv/10.1111%2Fj.1439-0469.1986.tb00624.x_Table1.tsv
#   public_tsv/10.1111%2Fj.1439-0469.1986.tb00624.x_Table2.tsv
#
# Registry note: the public TSV names are the expected Items encoded.
# The registry rows in __ReadMe.xlsx are an owner step.

t1 <- read.csv(text = "
species_sci,Body_mass_g_gross,Brain_mass_g,Cephalisation,n,note
Mustela nivalis,68,1.90,99,13,
Mustela erminea,185,4.67,128,15,
Mustela putorius,977,9.23,102,32,
Mustela vison,1038,9.59,100,33,
Mustela nigripes,449,7.80,128,1,
Martes martes,1005,17.55,184,3,
Martes foina,1469,21.78,184,19,
Martes pennanti,2760,34.29,202,15,Values determined after Drescher (1977) (Table 1 footnote 1)
Galictis cuja,1190,18.80,178,1,
Galictis vittatus,1418,18.20,160,2,
Eira barbara,3878,47.90,233,4,
Mephitis mephitis,3150,11.54,65,6,
Conepatus chinga,1669,18.72,150,5,
Conepatus humboldti,1485,12.25,103,13,
Helictis personata,1250,15.00,138,1,
Meles meles,13675,59.56,144,4,
Taxidea taxus,6734,62.81,223,6,Values determined after Drescher (1977) (Table 1 footnote 1)
Lutra lutra,4932,47.17,205,6,
Lutra canadensis,6690,59.58,212,13,Values determined after Drescher (1977) (Table 1 footnote 1)
Pteronura brasiliensis,16500,121.75,260,2,
", stringsAsFactors = FALSE)

t2 <- read.csv(text = "
species_sci,Brain_volume_mm3_net,Telencephalon_volume_mm3,Neocortex_volume_mm3,Allocortex_plus_striatum_volume_mm3
Mustela nivalis,1795,1151.13,762.16,388.97
Mustela erminea,4443,3033.7,2101.1,932.6
Mustela putorius,8899.6,6063.3,4147,1916.3
Martes foina,20857,15393,11594,3799
Galictis cuja,17944,13518,10726,2792
Eira barbara,45688,35148,29077,6071
Conepatus chinga,17822,13153,9228,3925
Conepatus humboldti,11682,8446.1,5735.9,2713.79
Meles meles,56771,42839.4,32604,10235.4
Pteronura brasiliensis,115203.1,91955.1,83257.3,8697.8
", stringsAsFactors = FALSE)

stopifnot(nrow(t1) == 20, nrow(t2) == 10)
# checks: TEL V = NEOC V + ALLO+CSTR V; Castillo-Morales ferret values
# TEL V = NEOC V + ALLO+CSTR V holds exactly for 9 of 10 rows; the printed
# Conepatus humboldti row is internally inconsistent by 3.59 mm3
# (8446.1 vs 5735.9 + 2713.79 = 8449.69) -- transcribed as printed.
stopifnot(all(abs(t2$Telencephalon_volume_mm3 -
  (t2$Neocortex_volume_mm3 + t2$Allocortex_plus_striatum_volume_mm3)) < 4))
mp <- t2[t2$species_sci == "Mustela putorius", ]
stopifnot(mp$Brain_volume_mm3_net == 8899.6, mp$Neocortex_volume_mm3 == 4147)

write.csv(t1, "Roehrs__1986_Table1.csv", row.names = FALSE)
write.csv(t2, "Roehrs__1986_Table2.csv", row.names = FALSE)
write.table(t1, "public_tsv/10.1111%2Fj.1439-0469.1986.tb00624.x_Table1.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
write.table(t2, "public_tsv/10.1111%2Fj.1439-0469.1986.tb00624.x_Table2.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
