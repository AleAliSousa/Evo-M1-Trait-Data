# Hand-verified transcription of Schleifenbaum (1973) Tables 1-2.
# Table 1 is stored one individual per row; Table 2 retains its printed
# structure-as-rows orientation.  German decimal commas and parentheses survive
# in the frozen snapshots and are parsed only by the build script.

.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
paper_dir <- dirname(.sp)

table1_txt <- "Nr_printed|species_group_printed|sex_printed|age_printed|NKG_g_printed|HG_g_printed
1*|Großpudel|♂|neonat|170,00|11,03
2*|Großpudel|♂|1 Woche|380,47|17,25
3*|Großpudel|♀|2 Wochen|545,00|27,23
4*|Großpudel|♂|3 Wochen|774,00|37,10
5*|Großpudel|♂|1 Monat|698,00|39,17
6*|Großpudel|♀|2 Monate|4545,00|58,00
7*|Großpudel|♂|3 Monate|6885,00|73,12
8*|Großpudel|♀|4 Monate|8525,00|75,98
9*|Großpudel|♀|7 Monate|12110,00|85,41
14|Großpudel|♀|neonat|150,00|8,46
15|Großpudel|♂|neonat|225,07|9,31
16|Großpudel|♀|neonat|142,58|7,97
17|Großpudel|♀|1 Woche|251,60|15,28
18|Großpudel|♀|3 Wochen|1046,00|35,10
19|Großpudel|♀|1 Monat|995,00|37,33
20|Großpudel|♀|2 Monate|3995,00|59,65
21|Großpudel|♀|3 Monate|7140,00|74,69
22|Großpudel|♂|8 Monate|11445,00|90,25
10*|Wölfe|?|neonat|(224,00)|(13,00)
11*|Wölfe|♂|1 Monat|1735,00|75,20
12*|Wölfe|♂|3 Monate|7732,00|121,20
13*|Wölfe|♂|6 Monate|13150,00|135,00
23|Wölfe|♀|3 Wochen|448,00|49,20
24|Wölfe|♀|3 Monate|5825,00|102,00
25|Wölfe|♂|4 Monate|8975,00|152,40
26|Wölfe|♂|4 Monate|8500,00|115,70
27|Wölfe|♂|5 Monate|6345,00|119,00
28|Wölfe|♂|5 Monate|10810,00|125,00
29|Wölfe|♂|7 Monate|14055,00|117,40
30|Wölfe|♀|7 Monate|18100,00|121,00
31|Wölfe|♂|7 Monate|12250,00|132,60
32|Wölfe|♀|9 Monate|17570,00|131,80
33|Wölfe|♂|10 Monate|19257,00|162,40"

table2_txt <- "measure_printed|unit|1|2|3|4|5|6|7|8|9|10|11|12|13
Oblongata|mm3|323|583|793|914|1131|2196|2353|2975|3230|—|1744|4336|4303
Kleinhirn|mm3|412|819|1896|2703|3038|5547|7017|8473|8330|—|6292|11721|13589
Mittelhirn|mm3|627|607|926|947|1037|1794|2221|2404|2550|—|1830|2751|3097
Zwischenhirn|mm3|649|1159|1431|2037|1971|3088|3148|3569|4360|—|3346|6106|5951
Endhirn|mm3|7664|13477|21190|29293|30599|48181|55279|55749|63890|—|59356|91907|103470
Neocortex|mm3|6220|11329|18397|26100|26977|41740|48098|48718|56190|—|52655|81125|92616
Striatum|mm3|342|510|663|769|861|1582|1736|1876|2090|—|1599|2733|2893
Allocortex|mm3|1102|1647|2130|2424|2761|4859|5444|5156|5620|—|5101|8049|7961
(Periv. Matrix)|mm3|351|399|360|310|216|20|—|—|—|—|—|—|—
Bulbus olfact.|mm3|150|319|351|516|850|914|1332|1381|1600|—|1242|2774|3440
Riechhirn + NA|mm3|677|969|1175|1280|1535|2921|2976|2902|2980|—|2852|3935|3987
Nichtolf. Alloc.|mm3|425|678|955|1144|1226|1939|2468|2254|2640|—|2249|4114|3974
Septum|mm3|96|126|163|183|161|209|273|295|300|—|336|413|237
Ammonshorn|mm3|247|351|511|628|855|1429|1866|1491|1770|—|1372|3211|3137
Schizocortex|mm3|82|201|281|334|211|300|330|468|560|—|542|490|600
Gesamthirnvolumen|mm3|9600|16650|26240|35890|37800|60800|70000|73100|82360|—|72570|117000|125400"

table1 <- read.delim(text = table1_txt, sep = "|", check.names = FALSE,
                     colClasses = "character", stringsAsFactors = FALSE)
table2 <- read.delim(text = table2_txt, sep = "|", check.names = FALSE,
                     colClasses = "character", stringsAsFactors = FALSE)
stopifnot(nrow(table1) == 33L, nrow(table2) == 16L)

write.csv(table1, file.path(paper_dir, "Schleifenbaum__1973_Table1_snapshot.csv"),
          row.names = FALSE, na = "")
write.csv(table2, file.path(paper_dir, "Schleifenbaum__1973_Table2_snapshot.csv"),
          row.names = FALSE, na = "")
message("Wrote Schleifenbaum Table 1 (33 rows) and Table 2 (16 measures x 13 individuals) snapshots")
