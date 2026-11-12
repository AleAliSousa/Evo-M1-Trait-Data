# Grande__1950_extract_snapshot.R -------------------------------------------------
#
# Builds the frozen snapshots of Grande, F. (1950) "El consumo de oxigeno del
# cerebro", Revista Clinica Espanola 39(1): 1-17 (15 octubre 1950; Madrid).
#
#   Grande__1950_TablaVI_snapshot.csv    Tabla VI,   p. 6  (PDF page 6): brain O2 as % of
#                                        total resting O2, 15 mammal rows (printed order)
#   Grande__1950_TablaVIII_snapshot.csv  Tabla VIII, p. 12 (PDF page 12): human brain O2
#                                        and blood flow after Kety & Schmidt (1948)
#   Grande__1950_TablaIX_snapshot.csv    Tabla IX,   p. 12 (PDF page 12): O2 use of five
#                                        human organs, heading BMR estimate
#
# The PDF is a 1950 scan; its text layer is OCR and unusable for digits. The
# blocks below are a HAND TRANSCRIPTION (__HOWTO_make_a_snapshot.md method 5) by an
# AI assistant (Claude) on 2026-11-03 from 300-400 dpi renders of PDF pages 6 and 12,
# re-verified cell by cell against the page images (an earlier transcription in
# Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations
# was used only as a starting point; every printed value was re-read).
#
# Fidelity decisions (as printed; nothing repaired):
#  * Spanish number format kept: "." thousands separator (6.650 = 6650 kg, 1.296 =
#    1296 c.c.), "," decimal (3,80 = 3.80). Parsed only in the build script.
#  * Header line breaks kept as "\n"; hyphenated line-end breaks in body captions
#    (ORGA-NISMO, volu-menes, mi-nuto) are joined; the dot leaders after row labels
#    are decorative and omitted.  O2 subscripts written "O2".  "Monos (ateles)" is
#    printed with a leader dot that is not part of the name.
#  * Tabla IX heading prints the basal-metabolism estimate with a smudged middle
#    digit ("2?0 C. C."); recorded as "2?0". Tabla VI and the running text give
#    250 c.c./min, the build does NOT substitute it.
#  * Tabla IX musculatura label is printed on two lines ("Musculatura" / "(reposo)")
#    with the values on the second; one snapshot row. Corazon prints an em dash
#    (no arterio-venous difference).
#  * Row order, row duplicates (two Elefante rows, two Caballo rows) as printed.
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
printed_TablaVI <- "
TABLA VI|||||
METABOLISMO CEREBRAL EN TANTO POR CIENTO DEL METABOLISMO TOTAL EN REPOSO DEL ORGANISMO ADULTO, EN VARIAS ESPECIES DE MAMIFEROS|||||
Las cifras de consumo de oxigeno cerebral calculadas con el valor de 3,7 c. c. por 100 g. y minuto (SCHMIDT, KETY y PENNES).|||||
Especie\\nanimal|Peso corporal.\\nKilogramos|Peso cerebral.\\nGramos|Consumo total de\\nO2 c. c. minuto|Consumo de O2 del\\ncerebro c. c. min.|Metabolismo cere-\\nbral en % del total
Elefante|6.650|5.700|7.880|211|2,7
Elefante|3.752|4.896|5.960|182|3,0
Caballo|600|670|1.296|25|1,9
Caballo|392|517|1.000|19|1,9
Vaca|488|400|1.112|15|1,3
Cerdo|125|120|400|4,4|1,1
Hombre|70|1.400|250|52|20,8
Oveja|52|106|215|3,9|1,8
Chimpancé|38|387|158|14,3|9,0
Perro|16,4|70|83,4|2,6|3,1
Monos (ateles)|3,80|91|36,0|3,4|9,5
Conejo|2,60|19|21,7|0,70|3,2
Cobayo|0,800|4,7|10,3|0,17|1,6
Rata|0,250|2,0|3,4|0,074|2,2
Ratón|0,027|0,37|0,75|0,014|1,8
"
printed_TablaVIII <- "
TABLA VIII||
CONSUMO DE OXIGENO Y RIEGO SANGUINEO DEL CEREBRO HUMANO, SEGUN KETY Y SCHMIDT (1948).||
Valores medios de 34 observaciones en 14 sujetos jóvenes sanos.||
Consumo de oxigeno por 100 g. de cerebro y minuto|3,3|c. c.
Diferencia arterio-venosa de oxigeno (volúmenes por 100)|6,3|
Flujo de sangre cerebral (por 100 gramos y minuto)|54|c. c.
Consumo de oxigeno total del cerebro (por minuto)|46|c. c.
Flujo de sangre total del cerebro (por minuto)|756|c. c.
"
printed_TablaIX <- "
TABLA IX|||||||
METABOLISMO DE DISTINTOS ORGANOS HUMANOS (EXPRESADO EN CONSUMO DE OXIGENO). METABOLISMO BASAL ESTIMADO EN 2?0 C. C. DE OXIGENO POR MINUTO|||||||
Organo|Peso\\ngramos|% del peso\\ntotal|Riego sangui-\\nneo, c. c. por\\n100 g. y min.|Diferencia O2\\narterio - vena\\nvols. %|Consumo de oxigeno||En % del\\nmetabolismo\\nbasal
|||||Por 100 g. y\\nminuto|Total por\\nminuto|
Cerebro|1.400|2,00|54,0|6,3|3,30|46|19
Riñones|290|0,41|326,0|1,1|3,60|10|4
Higado|1.500|2,14|92,0|4,9|4,50|67|27
Musculatura (reposo)|30.000|43,00|2,8|6,0|0,17|51|20
Corazón|275|0,40|85,0|—|10,00|27|11
Las cifras correspondientes al cerebro han sido tomadas del trabajo de KETY y SCHMIDT (1948); la de los riñones, de BRADLEY y HELPERIN (1948); las del hígado, de MYERS (1947), correspondientes al método de la bromosulftaleína.|||||||
Las cifras correspondientes al corazón han sido calculadas sobre datos determinados en el corazón de perro \"in situ\", obtenidos por GOODALE y colaboradores (1948).|||||||
Las cifras para la musculatura esquelética han sido tomadas de ASMUSSEN, CHRISTENSEN y NIELSEN (1939).|||||||
"
to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- strsplit(line, "|", fixed = TRUE)[[1]]
    if (grepl("\\|$", line)) x <- c(x, "")
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

grid <- to_grid(printed_TablaVI, 6L)
stopifnot(nrow(grid) == 19L, all(nzchar(grid[5:19, 2:6])), sum(nzchar(grid[5:19, 1])) == 15L)
freeze(grid, file.path(folder, paste0(paper, "_TablaVI_snapshot.csv")))

grid <- to_grid(printed_TablaVIII, 3L)
stopifnot(nrow(grid) == 8L, all(nzchar(grid[4:8, 2])))
freeze(grid, file.path(folder, paste0(paper, "_TablaVIII_snapshot.csv")))

grid <- to_grid(printed_TablaIX, 8L)
stopifnot(nrow(grid) == 12L, grid[9, 5] == "\u2014",
          sum(nzchar(grid[5:9, 1])) == 5L)
freeze(grid, file.path(folder, paste0(paper, "_TablaIX_snapshot.csv")))
