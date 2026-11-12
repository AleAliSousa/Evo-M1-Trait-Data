# Karlsen_etal_2014_Table2.R ---------------------------------------------------
#
# Karlsen AS, Korbo S, Uylings HBM, Pakkenberg B (2014). A stereological study of the
# mediodorsal thalamic nucleus in Down syndrome. Neuroscience 279:253-259.
# doi:10.1016/j.neuroscience.2014.08.046
# Table 2 "Estimated quantities of the MDT nucleus (unilateral)" (journal p. 256, PDF p. 4)
#
# Reads the frozen snapshot (Karlsen_etal_2014_Table2_snapshot.xlsx, written by
# Karlsen_etal_2014_Table2_snapshot.R). One analysis row per printed group (2 rows):
# mean, CE and CV of each of the 7 printed quantities side by side. Volume is printed in
# the project unit (mm3; no conversion); cell numbers stay in the printed unit (10^6
# cells), carried in the column name. Checks the two sums the table implies
# (Neurons total = large + small; Glial cells total = oligodendrocytes + astrocytes --
# microglia were not counted, Methods p. 255).
# No table value is typed in this script.
#
# Disease paper: "Controls" = neurologically healthy female controls (N = 6);
# "DS" = Down syndrome (N = 4). Both kept, exactly as printed.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base <- item_name
paper <- sub("_Table4$", "", item_name)

suppressPackageStartupMessages(library(readxl))

read_snap <- function(file, sheet) {
  m <- as.matrix(read_excel(file, sheet = sheet, col_names = FALSE, col_types = "text",
                            .name_repair = "minimal"))
  m[is.na(m)] <- ""; dimnames(m) <- NULL; m
}
snap <- read_snap(paste0(base, "_snapshot.xlsx"), "Table2")
stopifnot(nrow(snap) == 10L, ncol(snap) == 9L)
lab <- function(x) sub("\n.*$", "", x)
stopifnot(identical(lab(snap[2, 3:9]), c("Volume", "Neurons, total", "Neurons, large", "Neurons, small",
                                         "Glial cells, total", "Oligodendr.", "Astrocytes")))
stopifnot(identical(sub("^.*\n", "", snap[2, 3:9]), c("(mm\u00b3)", rep("(10\u2076)", 6))))
code <- c("volume.mm3", "neurons_total.x10e6", "neurons_large.x10e6", "neurons_small.x10e6",
          "glia_total.x10e6", "oligodendrocytes.x10e6", "astrocytes.x10e6")

grp_rows <- which(nzchar(snap[, 1]) & snap[, 2] == "Mean")
stopifnot(length(grp_rows) == 2L, all(snap[grp_rows + 1, 2] == "CE"), all(snap[grp_rows + 2, 2] == "CV"))
one <- function(r) {
  g <- snap[r, 1]
  out <- data.frame(group_as_printed = g, Group = sub(" N = .*$", "", g),
                    n_subjects = as.integer(sub("^.*N = ", "", g)), stringsAsFactors = FALSE)
  for (k in seq_along(code)) {
    stem <- sub("\\..*$", "", code[k])
    out[[code[k]]] <- as.numeric(snap[r, k + 2])
    out[[paste0(stem, "_CE")]] <- as.numeric(snap[r + 1, k + 2])
    out[[paste0(stem, "_CV")]] <- as.numeric(snap[r + 2, k + 2])
  }
  out
}
final.dataframe <- do.call(rbind, lapply(grp_rows, one))
final.dataframe <- data.frame(
  final.dataframe[, 1:2], is_healthy_control = as.integer(final.dataframe$Group == "Controls"),
  final.dataframe[, -(1:2)],
  structure_as_printed = "MDT nucleus",
  hemisphere_basis = "unilateral (one hemisphere)",
  tissue_basis = "paraffin-embedded; Cavalieri volume NOT corrected for shrinkage (Methods p. 256)",
  glia_definition = "Glial cells, total = oligodendrocytes + astrocytes; microglia not included (too sparse; Methods p. 255)",
  species_as_published = "human",
  Species = "Homo sapiens",
  stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(nrow(final.dataframe) == 2L, !anyNA(final.dataframe[, grep("x10e6|mm3|_CE$|_CV$", names(final.dataframe))]))

## ---- table checks (HOWTO 7a): the two sums the table implies -----------------
## tolerance = half a unit in the last printed decimal of each of the three cells.
hu <- function(txt) { dec <- ifelse(grepl("\\.", txt), nchar(sub("^[^.]*\\.", "", txt)), 0); 0.5 * 10^(-dec) }
mk <- function(id, tot, a, b) {
  r <- grp_rows
  obs <- as.numeric(snap[r, a]) + as.numeric(snap[r, b]); prt <- as.numeric(snap[r, tot])
  tol <- hu(snap[r, a]) + hu(snap[r, b]) + hu(snap[r, tot])
  data.frame(check_id = paste0(id, "_", sub(" N = .*$", "", snap[r, 1])),
             basis = paste0("Table 2 ", snap[r, 1], ": ", lab(snap[2, a]), " + ", lab(snap[2, b]),
                            " vs ", lab(snap[2, tot])),
             observed = obs, printed = prt, difference = round(obs - prt, 4), tolerance = tol,
             status = ifelse(abs(obs - prt) <= tol + 1e-9, "pass", "mismatch"), note = NA_character_,
             stringsAsFactors = FALSE)
}
table_checks <- rbind(mk("neurons_total_sum", 4, 5, 6), mk("glia_total_sum", 7, 8, 9))
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
for (i in which(table_checks$status == "mismatch")) warning(table_checks$check_id[i], ": ", table_checks$basis[i], call. = FALSE)

## ---- outputs ----------------------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) ---------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) && !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), sep = "\t",
              row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
