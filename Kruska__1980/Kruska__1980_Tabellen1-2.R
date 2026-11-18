# Kruska__1980_Tabellen1-2.R
#
# Kruska D (1980). Domestikationsbedingte Hirngroessenanderungen bei
# Saeugetieren. Zeitschrift fuer Zoologische Systematik und
# Evolutionsforschung 18(3): 161-195. doi:10.1111/j.1439-0469.1980.tb00738.x
#
# Items: Tabelle 1 -- fresh brain weights and fixation shrinkage (%) for
# 40 specimens (7 camelids, 17 pigs, 16 rats, wild/domestic/feral forms);
# Tabelle 2 -- per-specimen brain-part volumes (mm3, fresh,
# shrinkage-corrected) for the 7 camelid brains (3 guanaco, 2 alpaca,
# 2 llama) from complete serial sections.
#
# Frozen source: the publisher PDF scan in this folder
# (Kruska-1980-Domestikationsbeding.pdf), supplied by Michael Proulx.
# Both tables were transcribed from the printed pages and verified cell
# by cell against rendered page images; the full extraction archive
# (all 14 tables, verbatim) is in extracted_tables/ with its REPORT.md.
#
# Methods that matter: volumes were measured on complete serial sections
# by the planimetric paper-weighing method (Stephan 1960) and corrected
# back to fresh volumes per brain (factor = fresh volume / section
# volume), with fresh volume = fresh weight / 1.035 (specific gravity of
# brain substance). Shrinkage through fixation/processing was 32-59%
# (Tabelle 1).
#
# Outputs:
#   Kruska__1980_Tabelle1.csv / Kruska__1980_Tabelle2.csv  (this folder)
#   public_tsv/10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle1.tsv
#   public_tsv/10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle2.tsv
#
# Registry note: the public TSV names are the expected Items encoded.
# The registry rows in __ReadMe.xlsx are an owner step.

t1 <- read.csv(text = "
specimen_code,species_sci,species_as_printed,Fresh_brain_weight_g,Fixation_shrinkage_pct
G 10,Lama guanicoe,Lama guanacoe,252,53
G 14,Lama guanicoe,Lama guanacoe,250,45
G 24,Lama guanicoe,Lama guanacoe,262,40
A 7,Vicugna pacos,Lama guanacoe f. pakos,189,49
A 9,Vicugna pacos,Lama guanacoe f. pakos,187,47
L 6,Lama glama,Lama guanacoe f. glama,197,47
L 7,Lama glama,Lama guanacoe f. glama,233,42
Ss 3,Sus scrofa,Sus scrofa,172,48
Ss 8,Sus scrofa,Sus scrofa,194,55
Ss 14,Sus scrofa,Sus scrofa,115,57
Ss 18,Sus scrofa,Sus scrofa,204,52
Ss 19,Sus scrofa,Sus scrofa,135,59
Ss 20,Sus scrofa,Sus scrofa,182,57
Sd 1,Sus scrofa domesticus,Sus scrofa f. dom.,78,50
Sd 5,Sus scrofa domesticus,Sus scrofa f. dom.,92,50
Sd 9,Sus scrofa domesticus,Sus scrofa f. dom.,105,49
Sd 12,Sus scrofa domesticus,Sus scrofa f. dom.,125,52
Sd 17,Sus scrofa domesticus,Sus scrofa f. dom.,119,49
Sd 19,Sus scrofa domesticus,Sus scrofa f. dom.,112,50
Sd 31,Sus scrofa domesticus,Sus scrofa f. dom.,110,44
A 21,Sus scrofa,Sus scrofa f. dom. verwildert,100,45
A 22,Sus scrofa,Sus scrofa f. dom. verwildert,111,42
A 23,Sus scrofa,Sus scrofa f. dom. verwildert,99,45
A 26,Sus scrofa,Sus scrofa f. dom. verwildert,106,47
W 47,Rattus norvegicus,Rattus norvegicus,2.14,41
W 34,Rattus norvegicus,Rattus norvegicus,2.25,48
W 42,Rattus norvegicus,Rattus norvegicus,2.55,38
W 39,Rattus norvegicus,Rattus norvegicus,2.53,49
W 14,Rattus norvegicus,Rattus norvegicus,2.53,36
W 18,Rattus norvegicus,Rattus norvegicus,2.2,46
W 41,Rattus norvegicus,Rattus norvegicus,2.1,38
W 77,Rattus norvegicus,Rattus norvegicus,2.42,37
E 22,Rattus norvegicus,Rattus norvegicus f. dom.,2.3,39
E 51,Rattus norvegicus,Rattus norvegicus f. dom.,1.98,41
E 54,Rattus norvegicus,Rattus norvegicus f. dom.,2.22,33
E 55,Rattus norvegicus,Rattus norvegicus f. dom.,2.22,32
E 16,Rattus norvegicus,Rattus norvegicus f. dom.,2.16,40
E 52,Rattus norvegicus,Rattus norvegicus f. dom.,2.01,37
E 53,Rattus norvegicus,Rattus norvegicus f. dom.,2.04,33
E 68,Rattus norvegicus,Rattus norvegicus f. dom.,2.13,36
", stringsAsFactors = FALSE)

t2 <- read.csv(text = "
specimen_code,species_sci,species_as_printed,Brain_mass_g_fresh,Brain_volume_mm3_fresh,Pure_brain_substance_mm3,Telencephalon_mm3,Diencephalon_mm3,Mesencephalon_mm3,Cerebellum_mm3,Medulla_oblongata_mm3,Neocortex_mm3,Neocortex_grey_mm3,Neocortex_white_mm3,Corpus_striatum_mm3,Allocortex_mm3,note
G 14,Lama guanicoe,Lama guanacoe,250,241313,233485,166324,14259,9843,29952,13106,143593,83116,60476,6206,16525,
G 10,Lama guanicoe,Lama guanacoe,252,243243,236987,173070,13684,9907,28783,11543,147954,91623,56331,7787,17329,
G 24,Lama guanicoe,Lama guanacoe,262,252896,244257,178571,13044,8887,31804,11951,155048,95715,59332,7762,15761,
A 9,Vicugna pacos,Lama guanacoe f. pakos,187,180502,174661,120531,13062,8011,23722,9335,99985,55276,44709,5640,14906,
A 7,Vicugna pacos,Lama guanacoe f. pakos,189,182432,174751,124276,10793,7527,24095,8060,103635,62047,41589,6273,14386,Allocortex as printed in Tabelle 2; Tabellen 6 and 11 print 14368 and Tabelle 3's share (8.22%) confirms 14368 -- misprint in Tabelle 2
L 6,Lama glama,Lama guanacoe f. glama,197,190154,182299,123956,11491,8647,26851,11354,104062,64499,39563,5960,13934,
L 7,Lama glama,Lama guanacoe f. glama,233,224903,212219,151860,12283,9329,26548,12199,127889,74098,53791,7304,16667,
", stringsAsFactors = FALSE)

stopifnot(nrow(t1) == 40, nrow(t2) == 7)
alp <- t2[t2$species_sci == "Vicugna pacos", ]
stopifnot(mean(alp$Brain_volume_mm3_fresh) == 181467,
          mean(alp$Neocortex_mm3) == 101810)

write.csv(t1, "Kruska__1980_Tabelle1.csv", row.names = FALSE)
write.csv(t2, "Kruska__1980_Tabelle2.csv", row.names = FALSE)
write.table(t1, "public_tsv/10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle1.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
write.table(t2, "public_tsv/10.1111%2Fj.1439-0469.1980.tb00738.x_Tabelle2.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
