# Grande__1980_extract_snapshot.R -------------------------------------------------
#
# Builds the frozen snapshots of Grande, F. (1980) "Energy expenditure of organs and
# tissues", pp. 88-92 in: Assessment of energy metabolism in health and disease,
# Report of the First Ross Conference on Medical Research (Columbus, Ohio: Ross
# Laboratories, c1980). The PDF is a British Library On Demand copy (cover sheet =
# PDF page 1; PDF page 2 = printed p. 88 ... PDF page 6 = printed p. 92).
#
#   Grande__1980_Table1_snapshot.csv   Table 1, p. 88 (PDF page 2): five estimates of
#                                      BMR partition in man, % of total BMR
#   Grande__1980_Table3_snapshot.csv   Table 3, p. 90 (PDF page 4): brain O2 uptake as %
#                                      of total O2 consumption (BMR), 14 rows
#
# The scan carries a text layer of uncertain quality; the blocks below are a HAND
# TRANSCRIPTION (method 5) by an AI assistant (Claude) on 2026-11-03 from 300-400 dpi
# renders, re-verified cell by cell. Yellow highlighter on the scan (Brain row of Table 1,
# Man row of Table 3) is the reader's annotation, not print.
#
# Fidelity decisions: English number format kept ("," thousands, "." decimal);
# printed row order kept (two Elephant rows, two Horse rows); "Subtotal 1/2" are indented
# in print; the indent is not recorded. Table 1: Ref 18 prints nothing in the Muscle and
# Subtotal 2 rows (blank kept); Ref 16 carries an asterisk in the header (footnote
# "Recalculated from original data of Ref 16"). A scan speck between "20" and "25.6" in
# the Muscle row is not a value. Table 3 Rabbit brain weight "19" has a scan speck next
# to it; the value is 19. O2 subscripts written "O2".
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
printed_Table1 <- "
Table 1. Various estimates of BMR partition in man, as percent of total BMR.|||||
Organ|Ref 15|Ref 19|Ref 16*|Ref 17|Ref 18
Liver|27|26.4|33|25|32
Brain|19|18.3|16|20|21
Heart|11|9.2|11|11|10
Kidney|4|7.2|8|7|7
Subtotal 1|61|61.1|68|63|70
Muscle|20|25.6|16|30|
Subtotal 2|81|86.7|84|93|
*Recalculated from original data of Ref 16.|||||
"
printed_Table3 <- "
Table 3. Brain O2 uptake as percentage of total O2 consumption* (BMR) in mammalian species.|||||
|||Total O2|Brain O2 Uptake|
|Body Weight|Brain Weight|Consumption BMR|Total|
Species|(kg)|(g)|(ml/min)|(ml/min)|% of BMR
Elephant|6,650|5,700|7,880|200|2.5
Elephant|3,752|4,896|5,960|171|2.9
Horse|600|670|1,296|23|1.8
Horse|392|517|1,000|18|1.8
Pig|125|120|400|4.2|1.0
Man|70|1,400|250|49|19.6
Sheep|52|106|215|3.7|1.7
Chimpanzee|38|387|158|13.5|8.6
Dog|16.4|70|83.4|2.4|2.9
Monkey (Ateles)|3.8|91|36.0|3.2|8.8
Rabbit|2.6|19|21.7|0.7|3.1
Guinea Pig|0.800|4.7|10.3|0.16|1.6
Rat|0.250|2.0|3.4|0.07|2.1
Mouse|0.027|0.37|0.75|0.013|1.7
*Brain O2 consumption = 3.5 ml/100 g/min for all the species.|||||
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

grid <- to_grid(printed_Table1, 6L)
stopifnot(nrow(grid) == 10L, identical(grid[2, 2:6], c("Ref 15", "Ref 19", "Ref 16*", "Ref 17", "Ref 18")),
          sum(!nzchar(grid[3:9, 2:6])) == 2L)
freeze(grid, file.path(folder, paste0(paper, "_Table1_snapshot.csv")))

grid <- to_grid(printed_Table3, 6L)
stopifnot(nrow(grid) == 19L, all(nzchar(grid[5:18, 1:6])), sum(nzchar(grid[5:18, 1])) == 14L)
freeze(grid, file.path(folder, paste0(paper, "_Table3_snapshot.csv")))
