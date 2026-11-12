# Hand-verified transcription of Nguyen et al. (2019) Table 2, PDF pages 9-10.
# Mean and SEM are split into adjacent snapshot columns without changing values.

.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
paper_dir <- dirname(.sp)

txt <- "species_printed|region_printed|neuron_type_printed|n|Vol_mean|Vol_SEM|TDL_mean|TDL_SEM|MSL_mean|MSL_SEM|DSC_mean|DSC_SEM|DSN_mean|DSN_SEM|DSD_mean|DSD_SEM|Soma_size_mean|Soma_size_SEM|Soma_depth_mean|Soma_depth_SEM
African lion|Frontal|Aspiny|2|7621|2953|2866|386|79|33|47|25|||||456|8|755|373
African lion|Frontal|Extraverted|3|8877|486|3055|346|54|7|59|13|465|1|0.16|0.02|313|22|582|97
African lion|Frontal|Multiapical|1|15387||3531||86||41||982||0.28||484||830|
African lion|Frontal|Pyramidal|14|11019|966|3037|223|70|4|46|4|711|85|0.23|0.02|385|24|738|63
African lion|Motor|Aspiny|5|6224|817|2492|192|70|7|36|3|||||401|51|989|190
African lion|Motor|Extraverted|11|10324|1089|3487|414|59|3|59|6|645|183|0.16|0.03|337|28|512|25
African lion|Motor|Gigantopyramidal|16|49253|4580|1872|215|53|3|35|3|210|36|0.10|0.01|1771|176|1885|34
African lion|Motor|Multiapical|2|13812|3086|3292|278|69|4|48|2|664|75|0.20|0.01|419|15|1106|387
African lion|Motor|Pyramidal|32|15199|1035|4135|187|68|2|61|3|722|64|0.17|0.01|399|15|984|87
African lion|Visual|Aspiny|9|3544|688|2163|359|60|6|36|4|||||329|41|984|107
African lion|Visual|Inverted|3|8906|1101|3302|302|74|7|46|9|533|250|0.17|0.09|374|46|1747|428
African lion|Visual|Meynert|6|33878|4984|3813|808|74|10|48|6|332|156|0.07|0.02|1655|125|1736|91
African lion|Visual|Pyramidal|58|12493|1283|3672|162|61|2|61|2|777|58|0.20|0.01|372|47|1087|69
African leopard|Frontal|Aspiny|6|3736|504|2261|360|63|9|37|5|||||225|18|1211|118
African leopard|Frontal|Extraverted|3|7185|755|3349|645|68|12|50|6|1388|521|0.39|0.08|267|45|874|131
African leopard|Frontal|Inverted|4|6843|2029|2161|369|60|4|36|6|568|179|0.24|0.06|321|58|1484|305
African leopard|Frontal|Multiapical|1|30469||2955||70||42||2421||0.82||584||1473|
African leopard|Frontal|Neurogliaform|1|1125||1204||23||52||||||151||1087|
African leopard|Frontal|Pyramidal|20|8809|716|3337|172|64|4|53|3|1703|169|0.50|0.04|284|14|1134|106
African leopard|Motor|Aspiny|33|8512|565|2899|136|77|3|39|2|||||444|25|957|44
African leopard|Motor|Extraverted|9|8317|1559|2759|272|66|6|42|2|782|109|0.28|0.03|235|20|614|62
African leopard|Motor|Gigantopyramidal|17|67235|5026|3001|389|130|8|25|3|595|95|0.20|0.01|2548|158|1467|40
African leopard|Motor|Horizontal|2|6537|2640|2744|785|57|8|48|8|524|221|0.18|0.03|337|121|1429|168
African leopard|Motor|Inverted|3|8085|556|2550|308|81|11|33|5|504|235|0.20|0.10|344|82|1407|228
African leopard|Motor|Pyramidal|87|10482|482|3379|89|65|1|53|1|846|36|0.25|0.01|271|10|829|33
African leopard|Visual|Aspiny|13|6239|1588|3074|299|67|4|47|5|||||305|54|910|81
African leopard|Visual|Extraverted|5|4675|791|2633|440|52|3|50|7|1105|339|0.40|0.10|202|33|463|15
African leopard|Visual|Horizontal|2|4567|299|3282|179|67|8|49|3|1020|116|0.31|0.05|220|14|1152|188
African leopard|Visual|Inverted|1|5672||3451||65||53||1389||0.40||132||913|
African leopard|Visual|Meynert|4|22944|1565|2898|180|97|10|31|5|314|87|0.11|0.03|1037|85|1373|20
African leopard|Visual|Neurogliaform|4|5051|1795|3475|512|53|7|66|3|||||216|61|725|167
African leopard|Visual|Pyramidal|42|9076|1001|3430|172|64|2|54|2|1104|73|0.33|0.02|277|25|921|59
Cheetah|Frontal|Aspiny|9|4735|879|2884|423|89|6|35|7|||||250|14|882|152
Cheetah|Frontal|Horizontal|3|13131|1348|5106|308|80|4|65|7|2315|398|0.45|0.06|418|53|1140|426
Cheetah|Frontal|Inverted|1|26434||8596||85||101||2380||0.28||542||1804|
Cheetah|Frontal|Multiapical|3|10915|4134|4230|1199|78|11|53|10|1535|571|0.35|0.05|462|110|1246|349
Cheetah|Frontal|Neurogliaform|6|4019|1224|5514|1217|58|2|94|18|||||182|22|896|37
Cheetah|Frontal|Pyramidal|29|14750|1774|5708|268|90|3|64|2|2561|179|0.44|0.02|394|22|1093|76
Cheetah|Motor|Aspiny|9|8392|1675|3240|265|111|10|30|3|||||465|63|925|43
Cheetah|Motor|Extraverted|6|6616|1067|4215|292|72|4|59|4|1579|224|0.37|0.03|225|21|530|72
Cheetah|Motor|Gigantopyramidal|29|51059|3965|4827|365|90|3|55|4|411|73|0.08|0.01|2210|163|1637|29
Cheetah|Motor|Horizontal|1|5764||5077||72||71||1972||0.39||228||227|
Cheetah|Motor|Inverted|2|9379|4356|5289|523|97|19|58|17|1720|192|0.33|0.07|365|14|1342|246
Cheetah|Motor|Multiapical|9|27719|4952|5912|431|81|4|73|4|1782|118|0.31|0.02|592|67|1473|106
Cheetah|Motor|Pyramidal|54|12069|1413|4350|154|77|2|57|2|1172|62|0.28|0.02|365|36|843|54
Cheetah|Visual|Aspiny|15|6891|1087|3170|239|78|4|42|3|||||432|50|1106|80
Cheetah|Visual|Extraverted|2|10856|4181|4826|490|62|2|78|11|1010|315|0.22|0.09|336|116|484|105
Cheetah|Visual|Meynert|11|27099|2456|5963|478|94|8|66|8|742|113|0.14|0.03|940|105|1388|86
Cheetah|Visual|Pyramidal|44|12471|877|4820|144|67|1|73|2|1267|92|0.26|0.01|411|52|784|39"

snapshot <- read.delim(text = txt, sep = "|", na.strings = c("", "NA"),
                       check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(snapshot) == 49L, ncol(snapshot) == 20L)
if (any(is.na(snapshot[c("species_printed", "region_printed", "neuron_type_printed", "n")]))) {
  stop("Missing row identity in Nguyen Table 2 transcription")
}
if (any(xor(is.na(snapshot$DSN_mean), is.na(snapshot$DSD_mean)))) {
  stop("DSN and DSD must be jointly present or absent")
}
write.csv(snapshot, file.path(paper_dir, "Nguyen_etal_2019_Table2_snapshot.csv"),
          row.names = FALSE, na = "")
message("Wrote Nguyen_etal_2019_Table2_snapshot.csv (49 species-region-neuron rows)")
