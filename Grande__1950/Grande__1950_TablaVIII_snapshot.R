# Grande__1950_TablaVIII_snapshot.R -------------------------------------------------
# (Split from the retired Grande__1950_extract_snapshot.R: this script writes only Grande__1950_TablaVIII_snapshot.csv.)
#
# Builds the frozen snapshot of Grande, F. (1950) "El consumo de oxigeno del
# cerebro", Revista Clinica Espanola 39(1): 1-17 (15 octubre 1950; Madrid).
#
#   Grande__1950_TablaVIII_snapshot.csv  Tabla VIII, p. 12 (PDF page 12): human brain O2
#                                        and blood flow after Kety & Schmidt (1948)
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # = Grande__1950_TablaVIII
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

grid <- to_grid(printed_TablaVIII, 3L)
stopifnot(nrow(grid) == 8L, all(nzchar(grid[4:8, 2])))
freeze(grid, file.path(folder, paste0(item_name, "_snapshot.csv")))

