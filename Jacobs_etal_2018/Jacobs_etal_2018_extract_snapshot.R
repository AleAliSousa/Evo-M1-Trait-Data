# Jacobs_etal_2018_extract_snapshot.R ----------------------------------------------------
# R port of Jacobs_etal_2018_extract_snapshot.py (openpyxl -> openxlsx).
#
# The transcribed values, the printed header tiers, the printed row order, the
# printed footnotes and the cosmetic layout (bold header rows, wrapped header
# cells, column widths) are all carried over unchanged. Verified cell-by-cell
# against the committed snapshots: every cell value identical.
#
# ---------------------------------------------------------------------------
# Original header, carried over verbatim from the Python script:
#
# Build the Jacobs et al. 2018 snapshots (Table 3 + Table 5).
#
# Faithful capture per __HOWTO_make_a_snapshot.md: printed headers, values exactly
# as printed (mean +/- SD in one cell, ranges as one cell with the en dash),
# printed grouping rows kept, printed row order kept. Print typos are NOT fixed
# here -- they are carried verbatim and flagged in the README.
#
# The only documented deviation: the printed Species cell holds the common name on
# line 1 and the italic binomial on line 2; that single cell is split into two
# columns (Species / Species_binomial) so the file is machine-readable. Both
# printed strings survive verbatim (invariant 3).
# ---------------------------------------------------------------------------

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)

suppressPackageStartupMessages(library(openxlsx))

## Each block below is the printed sheet exactly as it is written out: one line
## per worksheet row, cells separated by "|", an empty field where the page (or
## the printed header tier) is blank. No value is parsed, converted or cleaned
## here - that happens downstream in the per-table .R.
write_sheet <- function(txt, sheet, filename, dims, bold_rows, wrap_rows, widths) {
  g <- do.call(rbind, lapply(strsplit(strsplit(txt, "\n", fixed = TRUE)[[1]], "|", fixed = TRUE),
                             function(x) { length(x) <- dims[2]; x }))
  g[!is.na(g) & g == ""] <- NA_character_
  stopifnot(nrow(g) == dims[1], ncol(g) == dims[2])
  wb <- createWorkbook()
  addWorksheet(wb, sheet)
  writeData(wb, sheet, as.data.frame(g, stringsAsFactors = FALSE),
            colNames = FALSE, keepNA = FALSE)
  if (length(bold_rows))
    addStyle(wb, sheet, createStyle(textDecoration = "bold"),
             rows = bold_rows, cols = seq_len(dims[2]), gridExpand = TRUE)
  if (length(wrap_rows))
    addStyle(wb, sheet, createStyle(textDecoration = "bold", wrapText = TRUE),
             rows = wrap_rows, cols = seq_len(dims[2]), gridExpand = TRUE)
  ## openxlsx adds 0.71 padding to a stored width; subtract it so the file matches
  ## the widths the openpyxl version wrote.
  if (length(widths)) setColWidths(wb, sheet, cols = seq_along(widths), widths = widths - 0.71)
  saveWorkbook(wb, file.path(paper_dir, filename), overwrite = TRUE)
  message(sprintf("%s [%s]: %d rows x %d cols", filename, sheet, dims[1], dims[2]))
}


## ---- Table3 ------------------------------------------------------
txt_Table3 <- "TABLE 3  Estimated average lengths, areas, and volumes of layer V pyramidal and gigantopyramidal neuron somata in carnivore and primate species (in alphabetical order by species)a|||||||||||||||||||||
||Body mass|Brain mass|Pyramidal neuron lengths (µm)|||Gigantopyramidal neuron lengths (µm)|||Pyramidal neuron areas (µm2)|||Gigantopyramidal neuron areas (µm2)|||Pyramidal neuron volumes (µm3)|||Gigantopyramidal neuron volumes (µm3)||
Species|Species_binomial|(kg)|(g)|n|Mean|Range|n|Mean|Range|n|Mean|Range|n|Mean|Range|n|Mean|Range|n|Mean|Range
Carnivores|||||||||||||||||||||
African lion|Panthera leo|155.8|223.5|137|8.9±1.5|5.7–14.8|15|20.5±4.6|15.0–29.8|134|268.9±86.1|113.3–596.0|16|1,416.2±644.4|728.6–2,858.5|132|3,793.6±1,872.5|1,014.5–13,002.4|16|46,173.6±30,550.2|15,350.5–119,782.3
African wild dog|Lycaon pictus|26.3|141.5|178|9.1±1.0|6.3–10.8|83|12.9±2.0|10.8–21.7|167|286.4±51.8|20.11–389.4|76|586.4±206.7|391.0–1,622.1|207|4,391.3±1,700.0|2,025.6–8,996.72|41|16,074.3±8,689.9|9,109.7–55,734,1
Amur leopard|Panthera pardus orientalis|52.4|125.5|292|8.3±1.1|6.2–11.7|29|19.2±6.1|12.3–29.4|295|225.9±64.1|122.4–458.2|29|1,316±818.2|479.5–2,765.8|298|2,775.7±1,291.9|1,051.0–8,841.8|27|45,239.7±38,077.4|9,888.8–117,188.8
Asian small-clawed otter|Amblonyx cinereus|3.5|38.1|216|8.6±1.6|6.2–12.8|31|16.0±2.5|13.1–23.0|217|252.1±102.2|124.5–552.5|29|872.8±274.0|566.7–1,667.0|218|3,266.5±2,056.3|1,006.1–9,897.8|30|20,560.2±10,114.9|10,167.7–51,610.2
Banded mongoose|Mungos mungo|1.3|10.5|503|7.5±0.8|6.0–9.0|60|9.8±0.8|9.0–12.0|509|187.5±38.1|120.0–278.3|46|330.3±51.4|281.3–495.8|509|2,099.2±691.7|1,003.2–3,590.5|31|5,297.7±1,167.3|40,16.1–8,954.5
Caracal|Caracal caracal|11.6|55.3|282|8.8±1.2|7.6–12.3|41|15.2±2.5|12.7–27.7|285|258.3±74.8|186.0–520.0|41|775.0±317.0|520.9–2,509.1|284|3,415.1±1,663.6|2,001.3–9,691.3|40|18,421.7±14,309.5|10,129.5–100,697.6
European polecat|Mustela putorius|1.1|8.3|177|8.2±1.5|6.0–11.0|44|12.4±1.0|11.1–14.8|183|241.1±89.3|119.3–433.3|32|533.6±68.6|443.5–725.2|190|3,214.3±1,819.4|1,004.3–7,649.7|27|10,231.0±1,777.3|8,187.3–15,925.5
Harp seal|Pagophilus groenlandicus|132.3|276.0|240|9.1±1.2|6.3–11.0|49|11.7±0.7|11.0–13.9|237|271.7±65.2|127.9–387.9|52|438.5±54.3|390.5–614.6|237|3,585.2±1233.7|1,104.6–5,983.4|52|7,296.3±1,491.9|6,012.3–11,984.2
Northern fur seal|Callorhinus ursinus|135.9|328.6|433|9.6±1.6|6.1–12.5|43|13.4±1.0|12.5–17.5|447|319.1±105.6|122.3–549.2|27|642.8±106.1|556.4–1,053.3|443|4,667.7±2,249.8|1,013.7–9,971.2|34|12,955.6±3,638.7|10,033.7–28,902.2
Raccoon|Procyon lotor|6.4|40.0|541|8.8±1.2|6.3–13.0|39|15.4±2.3|13.0–21.5|551|254.1±74.8|120.7–548.4|37|794.6±253.8|562.4–1,488.5|550|3,232.9±1,440.6|1,000.8–9,666.8|40|17,746.9±9,299.3|10,075.0–44,546.1
Siberian tiger|Panthera tigris altaica|161.0|279.3|126|8.6±1.2|6.4–11.8|12|17.0±4.6|12.1–27.8|128|245.9±72.7|126.3–452.0|12|1,040.0±569.8|460.9–2,517.8|131|3,158.4±14,71.9|1,045.7–7,560.3|11|32,289.6±25,103.6|9,909.7–99,838.6
Primates|||||||||||||||||||||
Black-capped squirrel monkey|Saimiri boliviensis|0.9|25.5|146|6.5±0.5|5.8–7.5|24|8.2±0.8|7.7–11|126|140.7±20.2|114.2–189.5|22|224.4±46.4|191.8–392.0|109|1,360.5±266.4|1,001.7–1,949.0|24|2,646.0±935.7|2,004.6–6,030.8
Chacma baboon|Papio ursinus|31.0|214.4|27|6.5±0.2|6.0–6.9|27|8.0±0.8|7.2–9.8|35|143.8±16.3|121.0–178.3|19|223.7±35.8|182.0–305.8|38|1,364.1±252.0|1,016.7–1,909.4|18|2,662.7±593.6|2,014.3–4,069.2
Cotton-top tamarin|Saguinus oedipus|0.4|8.9|137|6.5±0.5|5.8–7.5|35|8.9±1.2|7.6–12.0|108|145.5±18.3|118.3–187.9|37|260.9±73.5|191.9–473.5|111|1,368.7±239.2|1,000.1–1,955.0|41|3,349.5±1,506.8|2,008.8–8,339.8
Golden lion tamarin|Leontopithecus rosalia|0.6|12.8|134|5.7±0.5|4.8–6.7|27|7.5±0.7|6.7–9.5|130|107.7±19.8|77.0–148.1|32|183.1±38.5|149.5–299.5|140|909.3±272.5|511.5–1,498.9|29|2,171.0±713.3|1,530.6–4,147.9
Hamadryas baboon|Papio hamadryas|26.0|159.1|104|6.5±0.3|6.0–7.0|64|7.9±1.3|7.0–15.7|130|143.1±16.0|118.3–175.0|41|235.0±101.1|176.1–784.4|143|1,385.2±267.5|1,002.6–1,980.9|35|3,327.7±2,644.4|2,001.8–16,828.2
Lar gibbon|Hylobates lar|5.5|134.8|97|7.8±0.1|6.1–8.6|96|9.3±0.04|8.6–9.9|123|205.8±30.6|122.7–247.9|46|273.8±13.6|251.8–295.1|159|2,558.9±637.9|1,061.1–3,640.8|71|5,603.9±3,121.4|3,657.9–12,964.4
Pygmy marmoset|Cebuella pygmaea|0.1|4.1|108|6.6±0.3|6.2–7.4|42|8.3±0.6|7.5–9.6|127|141.3±16.4|120.0–183.7|40|229.4±35.0|187.4–295.0|134|1,304.5±229.8|1,002.2–1,943.7|42|2,757.2±666.1|2,007.3–4,313.6
Red-tailed monkey|Cercopithecus ascanius|4.2|58.4|193|6.7±0.3|6.2–7.4|111|8.1±0.6|7.4–10.5|241|150.2±20.2|120.7–189.2|76|224.5±27.7|190.1–347.6|239|1,421.9±287.1|1,000.6–1,992.0|83|2,567.1±490.8|2,002.7–4901.5
Vervet monkey|Chlorocebus pygerythrus|5.6|71.8|57|7.2±0.6|6.2–8.4|26|10.3±1.9|8.4–14.9|62|167.1±30.4|122.0–228.9|27|352.6±139.9|237.6–715.6|71|1,698.7±536.0|1,005.8–2929.2|26|5,636.5±3,458.1|3,033.8–15,219.6
|||||||||||||||||||||
a Each species is represented by one animal. The standard deviation and the range observed as well as the number of cells measured are provided. Estimates of area were calculated using the “nucleator” probe of the StereoInvestigator software (see text for details).|||||||||||||||||||||"
write_sheet(txt_Table3, "Table3", "Jacobs_etal_2018_Table3_snapshot.xlsx", c(27L, 22L),
            bold_rows = c(2, 3), wrap_rows = integer(0), widths = c(30.0, 26.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0, 17.0))

## ---- Table5 ------------------------------------------------------
txt_Table5 <- "TABLE 5  Summary statistics for each neuron type across sampled species in morphological analysis (in alphabetical order by taxonomic group)|||||||||
Neuron type|na|Volb|TDLc|MSLd|DSCe|DSNf|DSDg|SoSizeh|SoDepthi
Artiodactyls|||||||||
|Blue wildebeest||||||||
Superficial|19|13,411±1,527|5,640±414|77±3|75±6|2,224±220|0.30±0.02|425±30|759±68
Deep|13|22,158±2,526|6,086±306|86±4|73±5|2,236±232|0.30±0.03|479±38|1,387±105
Gigantopyramidal|26|51,400±3,386|5,666±266|101±4|57±3|3,244±219|0.50±0.02|882±45|1,361±47
|Giraffe||||||||
Superficial|11|16,059±2,157|5,177±319|81±3|64±3|4,955±383|0.84±0.06|301±27|658±31
Deep|10|16,222±1,927|5,980±659|85±6|70±5|4,370±579|0.58±0.03|408±31|1,218±37
Gigantopyramidal|5|73,427±15,718|8,397±903|100±4|84±8|7,794±902|0.75±0.04|1,143±112|1,513±92
|Kudu||||||||
Superficial|16|7,445±633|3,655±269|71±3|51±3|2,068±238|0.40±0.04|323±13|948±18
Deep|13|10,316±1,309|3,771±244|72±5|54±4|1,726±199|0.30±0.03|357±30|1,468±91
Gigantopyramidal|7|25,210±2,779|5,191±592|87±4|61±9|2,135±173|0.30±0.04|745±71|1,724±102
Caniforms|||||||||
|African wild dog||||||||
Superficial|41|10,853±677|4,681±222|79±2|60±3|2,343±147|0.40±0.02|376±18|759±26
Deep|31|11,050±639|4,707±259|83±3|57±3|1,892±193|0.30±0.02|428±18|1,385±62
Gigantopyramidal|9|27,317±3,821|5,794±499|79±4|72±5|3,038±399|0.42±0.04|2,662±261|1,554±45
|Domestic dog||||||||
Superficial|12|9,446±1,147|3,112±165|58±3|55±4|929±95|0.30±0.02|430±44|718±41
Deep|8|12,572±1,700|3,429±366|68±5|51±5|929±122|0.20±0.03|629±67|1,230±75
Gigantopyramidal|17|37,564±3,807|3,524±238|73±4|49±3|1,225±149|0.30±0.03|1,876±187|1,402±66
Diprotodont|||||||||
|Bennett’s wallaby||||||||
Superficial|10|4,951±636|4,739±381|90±5|53±4|2,697±298|0.48±0.04|258±13|540±37
Deep|13|14,151±2,023|4,705±619|85±6|52±4|2,753±467|0.38±0.03|437±31|1,052±33
Feliforms|||||||||
|Banded mongoose||||||||
Superficial|10|6,400±1,010|5,092±539|72±5|71±6|3,011±442|0.48±0.04|279±21|622±29
Deep|14|11,551±1,404|4,931±327|81±5|61±3|3,120±251|0.51±0.03|484±74|992±34
|Caracal||||||||
Superficial|10|7,962±1,117|6,008±464|82±4|75±6|3,395±470|0.46±0.05|370±29|670±54
Deep|9|15,765±3,052|5,353±329|88±5|61±3|3,661±306|0.53±0.02|448±45|1,267±64
Gigantopyramidal|10|67,799±15,311|7,222±712|88±4|81±6|1,187±214|0.15±0.05|2,000±182|1,199±47
|Clouded leopard||||||||
Superficial|5|8,452±1,563|3,521±255|62±7|59±6|1,353±37|0.35±0.02|306±27|571±50
Deep|1|4,203|4,436|78|57|1,170|0.22|294|1,435
Gigantopyramidal|6|61,253±11,929|1,179±205|63±7|18±2|240±38|0.20±0.03|3,720±352|1,363±53
|Siberian tiger||||||||
Superficial|6|20,182±5,677|6,215±247|83±8|77±5|2,257±308|0.28±0.04|439±85|752±71
Deep|3|16,066±1,812|5,589±352|97±14|60±10|1,496±98|0.19±0.02|350±62|1,486±244
Gigantopyramidal|8|94,701±27,983|5,513±1,003|128±7|42±6|1,005±157|0.16±0.02|2,844±366|1,546±29
|African lion||||||||
Superficial|10|9,762±1,747|4,998±259|77±3|65±3|1,415±159|0.23±0.03|358±40|799±45
Deep|10|17,673±4,006|5,800±555|83±4|69±5|1,908±306|0.24±0.02|525±87|1,376±73
Gigantopyramidal|10|88,381±8,281|8,600±814|120±8|72±6|1,099±154|0.10±0.01|2,824±284|1,558±40
Lagomorph|||||||||
|Flemish giant rabbit||||||||
Superficial|19|4,261±299|2,861±207|67±2|43±3|1,365±113|0.40±0.02|248±12|762±27
Deep|18|6,353±797|3,522±313|66±3|52±4|1,115±125|0.20±0.02|350±19|1,322±34
Perissodactyls|||||||||
|Mountain zebra||||||||
Superficial|5|12,487±1,144|5,352±529|92±4|58±3|2,221±701|0.30±0.08|423±31|796±57
Deep|6|17,925±3,584|5,433±524|93±5|60±7|2,109±375|0.30±0.03|464±46|1,427±131
Gigantopyramidal|21|60,377±3,604|4,871±340|89±2|55±4|2,280±202|0.40±0.03|1,260±70|1,434±60
|Plains zebra||||||||
Superficial|10|13,088±1,963|5,105±469|79±1|65±6|2,896±497|0.45±0.04|377±42|818±50
Deep|13|14,339±1,613|5,015±407|87±4|58±5|2,637±307|0.41±0.02|455±28|1,168±59
Gigantopyramidal|15|51,879±5,012|3,970±395|104±4|39±4|1,976±271|0.37±0.03|870±79|1,188±21
Primates|||||||||
|Ring-tailed lemur||||||||
Superficial|9|5,729±672|4,571±365|65±3|70±5|2,652±329|0.50±0.03|225±14|526±33
Deep|1|2,611|3,118|82|38|1,235|0.28|172|877
Gigantopyramidal|2|22,159±5,598|4,787±691|69±0.04|69±10|2,308±200|0.46±0.03|1,007±37|1,188±39
|Golden lion tamarin||||||||
Superficial|10|2,650±512|4,476±330|64±2|71±6|1,986±160|0.42±0.03|185±21|715±52
Deep|10|5,111±856|5,029±447|70±4|72±6|2,211±257|0.38±0.03|268±34|1,255±76
Gigantopyramidal|19|26,474±2,508|6,286±399|89±3|73±6|2,008±123|0.28±0.02|954±60|1,230±38
|Chacma baboon||||||||
Superficial|10|8,294±1,142|6,511±494|68±3|95±5|4,468±546|0.70±0.03|282±21|615±54
Deep|10|10,491±2,355|5,968±615|77±4|77±6|3,347±387|0.50±0.03|389±59|1,505±114
Gigantopyramidal|9|45,638±10,333|9,524±621|90±4|107±7|4,002±837|0.40±0.05|1,018±167|1,763±157
|Human||||||||
Superficial|10|12,717±1,458|6,121±487|66±3|92±4|2,213±227|0.32±0.02|452±46|1,255±97
Deep|10|11,300±1,949|5,329±516|80±3|68±7|2,108±313|0.33±0.02|454±60|2,146±96
Gigantopyramidal|17|29,412±2,804|7,706±503|91±4|87±7|1,736±275|0.20±0.03|969±52|1,876±68
Rodent|||||||||
|Rat||||||||
Superficial|10|4,126±346|3,785±257|61±2|62±4|2,252±184|0.50±0.02|173±11|468±22
Deep|10|10,015±1,153|4,605±262|71±3|65±4|2,174±198|0.41±0.03|362±22|1,208±47
|||||||||
a Number of cells traced.|||||||||
b Volume in µm3.|||||||||
c Length in µm.|||||||||
d Average length of dendritic segments in µm.|||||||||
e Number of segments per neuron.|||||||||
f Number of spines per neuron.|||||||||
g Number of spines per µm of dendritic length.|||||||||
h Soma size in µm2.|||||||||
i Soma depth in µm from the pial surface.|||||||||"
write_sheet(txt_Table5, "Table5", "Jacobs_etal_2018_Table5_snapshot.xlsx", c(92L, 10L),
            bold_rows = c(2), wrap_rows = integer(0), widths = c(20.0, 22.0, 18.0, 18.0, 18.0, 18.0, 18.0, 18.0, 18.0, 18.0))
