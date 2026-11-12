# Grande__1950_TablaVI_snapshot.R -------------------------------------------------
# (Split from the retired Grande__1950_extract_snapshot.R: this script writes only Grande__1950_TablaVI_snapshot.csv.)
#
# Builds the frozen snapshot of Grande, F. (1950) "El consumo de oxigeno del
# cerebro", Revista Clinica Espanola 39(1): 1-17 (15 octubre 1950; Madrid).
#
#   Grande__1950_TablaVI_snapshot.csv    Tabla VI,   p. 6  (PDF page 6): brain O2 as % of
#                                        total resting O2, 15 mammal rows (printed order)
#
# The PDF is a 1950 scan; its text layer is OCR and unusable for digits. The
# block below is a HAND TRANSCRIPTION (__HOWTO_make_a_snapshot.md method 5) by an
# AI assistant (Claude) on 2026-11-03 from 300-400 dpi renders of PDF page 6,
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Grande__1950_TablaVI
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
freeze(grid, file.path(folder, paste0(item_name, "_snapshot.csv")))

