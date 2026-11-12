# Grande__1950_TablaIX_snapshot.R -------------------------------------------------
# (Split from the retired Grande__1950_extract_snapshot.R: this script writes only Grande__1950_TablaIX_snapshot.csv.)
#
# Builds the frozen snapshot of Grande, F. (1950) "El consumo de oxigeno del
# cerebro", Revista Clinica Espanola 39(1): 1-17 (15 octubre 1950; Madrid).
#
#   Grande__1950_TablaIX_snapshot.csv    Tabla IX,   p. 12 (PDF page 12): O2 use of five
#                                        human organs, heading BMR estimate
#
# The PDF is a 1950 scan; its text layer is OCR and unusable for digits. The
# block below is a HAND TRANSCRIPTION (__HOWTO_make_a_snapshot.md method 5) by an
# AI assistant (Claude) on 2026-11-03 from 300-400 dpi renders of PDF page 12,
# re-verified cell by cell against the page images (an earlier transcription in
# Evo-M1-Trait-Data-restricted/__energetics_comparison/classic_energetics_compilations
# was used only as a starting point; every printed value was re-read).
#
# Fidelity decisions (as printed; nothing repaired):
#  * Spanish number format kept: "." thousands separator (6.650 = 6650 kg, 1.296 =
#    1296 c.c.), "," decimal (3,80 = 3.80). Parsed only in the build script.
#  * Header line breaks kept as "\n"; hyphenated line-end breaks in body captions
#    (ORGA-NISMO, volu-menes, mi-nuto) are joined; the dot leaders after row labels
#    are decorative and omitted.  O2 subscripts written "O2".
#  * Tabla IX heading prints the basal-metabolism estimate with a smudged middle
#    digit ("2?0 C. C."); recorded as "2?0". Tabla VI and the running text give
#    250 c.c./min, the build does NOT substitute it.
#  * Tabla IX musculatura label is printed on two lines ("Musculatura" / "(reposo)")
#    with the values on the second; one snapshot row. Corazon prints an em dash
#    (no arterio-venous difference).
#  * Row order as printed.
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Grande__1950_TablaIX
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

grid <- to_grid(printed_TablaIX, 8L)
stopifnot(nrow(grid) == 12L, grid[9, 5] == "\u2014",
          sum(nzchar(grid[5:9, 1])) == 5L)
freeze(grid, file.path(folder, paste0(item_name, "_snapshot.csv")))
