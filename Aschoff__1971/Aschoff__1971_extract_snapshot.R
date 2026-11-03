# Aschoff__1971_extract_snapshot.R -------------------------------------------
#
# Builds the frozen snapshots of Aschoff, J. (1971), "Temperaturregulation" section of
# Aschoff, Guenther & Kramer, "Energiehaushalt und Temperaturregulation", in Gauer,
# Kramer & Jung (eds), Physiologie des Menschen, Band 2, Urban & Schwarzenberg,
# Muenchen-Berlin-Wien (scanned excerpt, 12 PDF pages; book pp. 43-69).
#
#   Aschoff__1971_Tabelle1_snapshot.csv   Tabelle 1, p. 44 (PDF page 2)
#   Aschoff__1971_Text_snapshot.csv       CONSTRUCTED: values printed in Abb. 1 (p. 45)
#                                         and in the running text of pp. 44-45
#
# The scan has a poor OCR layer (decimal commas and thousands points survive in
# Tabelle 1, but Abb. 1 is a figure). The blocks below are a HAND TRANSCRIPTION read
# from 170/300-dpi renders of PDF page 2 by an AI assistant (Claude) on 2026-11-03
# (__HOWTO_make_a_snapshot.md method 5). The text layer of Tabelle 1 was read
# afterwards as an independent second reading and agrees on all 42 value cells.
# This script writes the frozen file and refuses to overwrite a differing frozen copy;
# the build scripts READ it.
#
# Fidelity: German decimal commas ("3,20") and thousands points ("27.000") kept as
# printed; row label "Splanchnikus-\ngebiet" kept as a two-line cell; header tiers
# kept with blank padding under spanners. Printed arithmetic is NOT corrected here.
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
folder <- dirname(.sp)
paper  <- basename(folder)

printed_Tabelle1 <- "
Tabelle 1. Sauerstoffaufnahme bzw. Wärmebildung der Organe im ruhenden Körper. (65 kg Gewicht, 270 cm³/min Sauerstoffaufnahme).|||||
|Gewicht\\nin g|Sauerstoffaufnahme||Wärmebildung|
||ml|ml|cal|cal
||100 g · min|Organ · min|100 g · min|Organ · min
Haut|5.000|0,10|5,0|0,48|24
Muskel|27.000|0,16|43,0|0,75|203
Gehirn|1.350|3,20|43,0|15,40|208
Lunge|600|2,00|12,0|9,50|57
Herz|290|10,00|29,0|48,00|139
Nieren|290|7,00|20,3|34,50|100
Splanchnikus-\\ngebiet|2.500|3,60|90,0|17,40|435
"

## Constructed text snapshot: one row per printed value. Quantities are quoted as
## printed (German decimal comma kept); the sentence / label they come from is in
## passage_as_printed. Abb. 1 is a figure with printed numbers (a values-in-figure table).
printed_text <- "
text_row|page|location|passage_as_printed|value_printed|units_printed|quantity_as_printed|state_as_printed|region_as_printed|ref_key_printed
1|45|Abb. 1, column 'Wärmebildung %' / 'in Ruhe'|Gehirn  16  3  2|16|%|Wärmebildung (heat production)|in Ruhe|Gehirn|
2|45|Abb. 1, column 'Wärmebildung %' / 'bei Arbeit'|Gehirn  16  3  2|3|%|Wärmebildung (heat production)|bei Arbeit|Gehirn|
3|45|Abb. 1, column 'Gewicht %'|Gehirn  16  3  2|2|%|Gewicht (weight)||Gehirn|
4|45|Abb. 1, column 'Wärmebildung %' / 'in Ruhe'|Brust und Bauch-eingeweide  56  22  6|56|%|Wärmebildung (heat production)|in Ruhe|Brust und Bauch-\\neingeweide|
5|45|Abb. 1, column 'Wärmebildung %' / 'bei Arbeit'|Brust und Bauch-eingeweide  56  22  6|22|%|Wärmebildung (heat production)|bei Arbeit|Brust und Bauch-\\neingeweide|
6|45|Abb. 1, column 'Gewicht %'|Brust und Bauch-eingeweide  56  22  6|6|%|Gewicht (weight)||Brust und Bauch-\\neingeweide|
7|45|Abb. 1, column 'Wärmebildung %' / 'in Ruhe'|Haut und Muskel  18  73  52|18|%|Wärmebildung (heat production)|in Ruhe|Haut und Muskel|
8|45|Abb. 1, column 'Wärmebildung %' / 'bei Arbeit'|Haut und Muskel  18  73  52|73|%|Wärmebildung (heat production)|bei Arbeit|Haut und Muskel|
9|45|Abb. 1, column 'Gewicht %'|Haut und Muskel  18  73  52|52|%|Gewicht (weight)||Haut und Muskel|
10|45|Abb. 1, column 'Wärmebildung %' / 'in Ruhe'|restliche Anteile (Knochen usw.)  10  2  40|10|%|Wärmebildung (heat production)|in Ruhe|restliche Anteile\\n(Knochen usw.)|
11|45|Abb. 1, column 'Wärmebildung %' / 'bei Arbeit'|restliche Anteile (Knochen usw.)  10  2  40|2|%|Wärmebildung (heat production)|bei Arbeit|restliche Anteile\\n(Knochen usw.)|
12|45|Abb. 1, column 'Gewicht %'|restliche Anteile (Knochen usw.)  10  2  40|40|%|Gewicht (weight)||restliche Anteile\\n(Knochen usw.)|
13|45|Abb. 1, legend (shading classes)|45,0 [darkest shading], in Ruhe cal/100g·min|45,0|cal/100g·min|Wärmebildung per 100 g (shading class)|in Ruhe|(shading class; no organ named)|
14|45|Abb. 1, legend (shading classes)|35,0, in Ruhe cal/100g·min|35,0|cal/100g·min|Wärmebildung per 100 g (shading class)|in Ruhe|(shading class; no organ named)|
15|45|Abb. 1, legend (shading classes)|15,0, in Ruhe cal/100g·min|15,0|cal/100g·min|Wärmebildung per 100 g (shading class)|in Ruhe|(shading class; no organ named)|
16|45|Abb. 1, legend (shading classes)|1,0, in Ruhe cal/100g·min|1,0|cal/100g·min|Wärmebildung per 100 g (shading class)|in Ruhe|(shading class; no organ named)|
17|45|Abb. 1, legend (shading classes)|0,5 [open], in Ruhe cal/100g·min|0,5|cal/100g·min|Wärmebildung per 100 g (shading class)|in Ruhe|(shading class; no organ named)|
18|45|Abb. 1, left axis 'Oberfläche/Volumen cm-1'|0,1 (leader line to the trunk region)|0,1|cm-1|Oberfläche/Volumen||(leader line; body part not named in print)|
19|45|Abb. 1, left axis 'Oberfläche/Volumen cm-1'|0,6 (leader line to the upper arm region)|0,6|cm-1|Oberfläche/Volumen||(leader line; body part not named in print)|
20|45|Abb. 1, left axis 'Oberfläche/Volumen cm-1'|1,0 (leader line to the hand region)|1,0|cm-1|Oberfläche/Volumen||(leader line; body part not named in print)|
21|45|Abb. 1, left axis 'Oberfläche/Volumen cm-1'|2,2 (leader line to the fingers)|2,2|cm-1|Oberfläche/Volumen||(leader line; body part not named in print)|
22|45|Abb. 1, left axis 'Oberfläche/Volumen cm-1'|0,9 (leader line to the foot region)|0,9|cm-1|Oberfläche/Volumen||(leader line; body part not named in print)|
23|44|Tabelle 1 caption|(65 kg Gewicht, 270 cm³/min Sauerstoffaufnahme)|65|kg|Körpergewicht (body weight of the reference body)|im ruhenden Körper|Körper|
24|44|Tabelle 1 caption|(65 kg Gewicht, 270 cm³/min Sauerstoffaufnahme)|270|cm³/min|Sauerstoffaufnahme (whole-body O2 uptake)|im ruhenden Körper|Körper|
25|44|left column, 'Orte der Wärmebildung'|Sie bilden zusammen nur etwa 8% der Körpermasse, sind jedoch mit über 70% am Umsatz des ruhenden Organismus beteiligt.|8|% (etwa)|Körpermasse (body mass share)||Organe mit hohem Stoffwechsel in der Schädel-, Brust- und Bauchhöhle|
26|44|left column, 'Orte der Wärmebildung'|Sie bilden zusammen nur etwa 8% der Körpermasse, sind jedoch mit über 70% am Umsatz des ruhenden Organismus beteiligt.|70|% (über)|Umsatz (share of resting turnover)|ruhender Organismus|Organe mit hohem Stoffwechsel in der Schädel-, Brust- und Bauchhöhle|
27|44|left column, 'Orte der Wärmebildung'|Schale aus Muskulatur und Haut ab, die zusammen etwa 52% des Körpergewichtes ausmachen, jedoch nur rund 18% der gesamten Wärme liefern [1].|52|% (etwa)|Körpergewicht (body weight share)||Schale aus Muskulatur und Haut|[1]
28|44|left column, 'Orte der Wärmebildung'|Schale aus Muskulatur und Haut ab, die zusammen etwa 52% des Körpergewichtes ausmachen, jedoch nur rund 18% der gesamten Wärme liefern [1].|18|% (rund)|gesamte Wärme (share of total heat)||Schale aus Muskulatur und Haut|[1]
29|45|left column, 'Bei Muskelarbeit ...'|Große Teile der Schale bilden nunmehr ebensoviel Wärme wie die Kernorgane, deren Anteil am Gesamtumsatz bei mittelschwerer Arbeit auf etwa 25% zurückgeht.|25|% (etwa)|Anteil der Kernorgane am Gesamtumsatz|bei mittelschwerer Arbeit|Kernorgane|
"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g[] <- gsub("\\n", "\n", g, fixed = TRUE)
  g
}
freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

grid_T1 <- to_grid(printed_Tabelle1, 6L)
grid_tx <- to_grid(printed_text, 10L)

## Structural guards: 4 header rows + 7 data rows; 1 header + 29 text rows.
stopifnot(nrow(grid_T1) == 4L + 7L, sum(nzchar(grid_T1[5:11, 2])) == 7L)
stopifnot(nrow(grid_tx) == 30L, all(grid_tx[2:30, 1] == as.character(1:29)))

freeze(grid_T1, file.path(folder, paste0(paper, "_Tabelle1_snapshot.csv")))
freeze(grid_tx, file.path(folder, paste0(paper, "_Text_snapshot.csv")))
