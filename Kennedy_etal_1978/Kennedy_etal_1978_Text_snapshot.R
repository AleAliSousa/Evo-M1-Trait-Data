# Kennedy_etal_1978_Text_snapshot.R ----------------------------------------
#
# Builds the frozen snapshot of Kennedy, Sakurada, Shinohara, Jehle &
# Sokoloff (1978) "Local cerebral glucose utilization in the normal conscious
# macaque monkey", Annals of Neurology 4: 293-301.
#
#   Kennedy_etal_1978_Text_snapshot.csv values printed only in the
#                                                 DISCUSSION (p. 298) and in the
#                                                 legends of Fig 2 (p. 299) and
#                                                 Fig 3 (p. 300)
#
# The source is a 1978 scanned journal page whose OCR text layer is garbled
# (figure labels interleaved, "pmoles" for µmoles, digits split), so nothing
# was taken from it. The values below are a HAND TRANSCRIPTION read from
# 300- and 500-dpi renders of PDF pages 6-8 (__HOWTO_make_a_snapshot.md
# method 5, the Mink_etal_1981 printed-layout-block pattern). This script
# writes the frozen files and refuses to overwrite a frozen copy that differs;
# the build scripts READ them. No cleaning happens here.
#
# Fidelity decisions:
#  * The text snapshot is CONSTRUCTED: one row per printed value, with the
#    page, the location and the sentence it comes from. A printed range
#    ("from 47 to 67") gives two rows. Values the paper cites from other work
#    keep the printed reference number in cited_ref.
#
# Transcribed by an AI assistant (Claude) on 2026-11-02 from page renders.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_text <- "
text_row|page|location|passage_as_printed|value_printed|units_printed|subjects_as_printed|state_as_printed|region_as_printed|cited_ref
1|298|DISCUSSION, left column|Schmidt, Kety, and Pennes [20] reported a cerebral oxygen consumption of 3.7 cc per 100 gm of tissue per minute in the monkey under barbiturate anesthesia|3.7|cc per 100 gm of tissue per minute|the monkey|under barbiturate anesthesia, but the level of anesthesia was kept very low|cerebral|20
2|298|DISCUSSION, left-right column|then this rate is equivalent to approximately 28 µmoles of glucose per 100 gm of tissue per minute|28|µmoles of glucose per 100 gm of tissue per minute|the monkey|under barbiturate anesthesia (Schmidt et al. [20])|cerebral|20
3|298|DISCUSSION, right column|a rate very similar to that of 31 µmoles per 100 gm per minute observed in normal conscious young men [22]|31|µmoles per 100 gm per minute|normal conscious young men|conscious|cerebral|22
4|298|DISCUSSION, right column|if the monkey brain is estimated to consist of equal fractions of gray and white matter, and the arithmetic means of the rates in the gray structures and in the white structures are averaged on that basis, then that average is found to be 29 µmoles per 100 gm of tissue per minute|29|µmoles per 100 gm of tissue per minute|the monkey brain|conscious|the brain as a whole (estimate)|
5|298|DISCUSSION, right column|very close to the values of 28 and 31 µmoles per 100 gm per minute previously observed in the lightly anesthetized monkey [20] and in conscious man [22]|28|µmoles per 100 gm per minute|the lightly anesthetized monkey|lightly anesthetized|cerebral|20
6|298|DISCUSSION, right column|very close to the values of 28 and 31 µmoles per 100 gm per minute previously observed in the lightly anesthetized monkey [20] and in conscious man [22]|31|µmoles per 100 gm per minute|conscious man|conscious|cerebral|22
7|299|Fig 2 legend, (C) Auditory cortex|The rate of glucose utilization in the centrally placed dark lamina is 121 µmoles per 100 gm of tissue per minute.|121|µmoles per 100 gm of tissue per minute|[the animal of Fig 2]|conscious|Auditory cortex, centrally placed dark lamina|
8|299|Fig 2 legend, (C) Auditory cortex|In the streaks on the lateral surface it varies from 47 to 67 µmoles per 100 gm per minute.|47|µmoles per 100 gm per minute|[the animal of Fig 2]|conscious|Auditory cortex, streaks on the lateral surface (range low)|
9|299|Fig 2 legend, (C) Auditory cortex|In the streaks on the lateral surface it varies from 47 to 67 µmoles per 100 gm per minute.|67|µmoles per 100 gm per minute|[the animal of Fig 2]|conscious|Auditory cortex, streaks on the lateral surface (range high)|
10|300|Fig 3 legend, (B) Midbrain|In this animal the glucose utilization rate in the superficial layer was 107 µmoles per 100 gm of tissue per minute, 67% above that of the deep portion of the structure.|107|µmoles per 100 gm of tissue per minute|this animal|conscious|Superior colliculus, superficial layer|
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

grid_tx <- to_grid(printed_text, 10L)

stopifnot(nrow(grid_tx) == 11L)

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

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
