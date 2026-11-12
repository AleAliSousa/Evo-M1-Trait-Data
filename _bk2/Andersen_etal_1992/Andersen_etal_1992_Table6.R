# Andersen_etal_1992_Table6.R ---------------------------------------------------
#
# Andersen, Korbo & Pakkenberg (1992), J Comp Neurol 326: 549-560.
# TABLE 6 "Total Number of Six Cell Types in Four Different Regions (10^6)"
# (p. 559, PDF page 11).
#
# Reads the frozen snapshot Andersen_etal_1992_Table6_snapshot.csv (hand transcription
# of the scanned page, printed layout) and:
#   - reshapes to one row per region x cell type, splitting "value (CV)";
#   - adds the absolute count (printed unit 10^6 cells x 1e6);
#   - re-adds the four regions per cell type and compares the sum with the Mean row
#     of the sibling item Andersen_etal_1992_Table4 (read from ITS frozen snapshot):
#     the four regions together make up the cerebellar cortex (Table 5);
#   - writes the analysis CSV and, once registered, the public TSV.
#
# No table value is typed in this script.

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

suppressPackageStartupMessages(library(readxl))

## ---- read the frozen snapshot (positional; every cell as printed text) -------
snap <- as.matrix(read.csv(paste0(base, "_snapshot.csv"), header = FALSE,
                           colClasses = "character", na.strings = character(0),
                           check.names = FALSE, fileEncoding = "UTF-8"))
dimnames(snap) <- NULL

## ---- helpers -----------------------------------------------------------------
## "80,900 (0.12)" -> value 80900, paren 0.12. Thousands commas stripped; a dash
## or blank cell is missing (never zero).
na_tokens <- c("", "-", "\u2013", "\u2014", "NA", "n.a.", "__", "e")
cell_value <- function(x) {
  v <- trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x))
  out <- suppressWarnings(as.numeric(gsub(",", "", v)))
  out[v %in% na_tokens] <- NA_real_
  out
}
cell_value_string <- function(x) gsub(",", "", trimws(sub("\\s*\\([^)]*\\)\\s*$", "", x)))
cell_paren <- function(x) {
  p <- ifelse(grepl("\\(", x), sub("^.*\\(([^)]*)\\).*$", "\\1", x), NA_character_)
  suppressWarnings(as.numeric(p))
}
## half a unit in the last significant printed digit ("34,000" -> 500; "0.042" -> 0.0005)
half_unit <- function(s) {
  s <- cell_value_string(s)
  ifelse(grepl("\\.", s), 0.5 * 10^-nchar(sub("^.*\\.", "", s)),
         0.5 * 10^(nchar(s) - nchar(sub("0+$", "", s))))
}
tc_row <- function(check_id, basis, observed, printed, tolerance, note = "") {
  d <- observed - printed
  data.frame(check_id = check_id, basis = basis, observed = observed, printed = printed,
             difference = d, tolerance = tolerance,
             status = ifelse(is.na(d), "not_evaluable",
                             ifelse(abs(d) <= tolerance + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}

stopifnot(ncol(snap) == 5L, nrow(snap) == 9L)
stopifnot(identical(snap[2, ], c("Cell types", "Pars anterior", "Vermis",
                                 "Flocculonodular lobe", "Pars posterior")))
cells   <- snap[3:8, 1]
regions <- snap[2, 2:5]
stopifnot(identical(cells, c("Granule", "Purkinje", "Golgi", "Glial in granular layer",
                             "Glial in molecular layer", "Neurons in molecular layer")))
body <- snap[3:8, 2:5, drop = FALSE]

layer_of <- c(Granule = "granular layer", Purkinje = "granular layer", Golgi = "granular layer",
              `Glial in granular layer` = "granular layer",
              `Glial in molecular layer` = "molecular layer",
              `Neurons in molecular layer` = "molecular layer")
class_of <- c(Granule = "neuron", Purkinje = "neuron", Golgi = "neuron",
              `Glial in granular layer` = "glia", `Glial in molecular layer` = "glia",
              `Neurons in molecular layer` = "neuron")

g <- expand.grid(i = seq_along(cells), j = seq_along(regions))
g <- g[order(g$i, g$j), ]
printed <- body[cbind(g$i, g$j)]
final.dataframe <- data.frame(
  printed_row           = g$i,
  cell_type_as_printed  = cells[g$i],
  region_as_printed     = regions[g$j],
  species_as_published  = "human",
  observation_level     = "group mean",
  n_brains              = 5L,
  cell_class            = unname(class_of[cells[g$i]]),
  layer                 = unname(layer_of[cells[g$i]]),
  value_as_printed      = printed,
  N_cells.1e6           = cell_value(printed),
  N_cells               = cell_value(printed) * 1e6,   # printed unit 10^6 cells -> cells
  CV                    = cell_paren(printed),
  stringsAsFactors = FALSE, check.names = FALSE
)
rownames(final.dataframe) <- NULL

## ---- table checks (build HOWTO 7a) --------------------------------------------
## Sum of the four regions per cell type vs the Table 4 Mean row (whole cerebellar
## cortex, same five brains). Tolerance: half a unit of the last significant printed
## digit of each regional value plus half a unit of the printed Table 4 mean.
t4 <- as.matrix(read.csv("Andersen_etal_1992_Table4_snapshot.csv", header = FALSE,
                         colClasses = "character", na.strings = character(0),
                         fileEncoding = "UTF-8"))
stopifnot(t4[8, 1] == "Mean")
t4_col <- c(Granule = "Granule", Purkinje = "Purkinje", Golgi = "Golgi/g",
            `Glial in granular layer` = "Glial/g", `Glial in molecular layer` = "Glial/m",
            `Neurons in molecular layer` = "Neurons/m")
table_checks <- do.call(rbind, lapply(seq_along(cells), function(i) {
  m_str <- t4[8, match(t4_col[[cells[i]]], t4[2, ])]
  tc_row(paste0("region_sum_", gsub(" ", "_", cells[i])),
         paste0("sum of 4 regions, row '", cells[i], "' vs Table 4 Mean, column '",
                t4_col[[cells[i]]], "' (10^6)"),
         sum(cell_value(body[i, ])), cell_value(m_str),
         sum(half_unit(body[i, ])) + half_unit(m_str),
         "cross-table: reads Andersen_etal_1992_Table4_snapshot.csv")
}))
tally <- table(factor(table_checks$status, levels = c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: observed %.6g vs printed %.6g (diff %.3g, tol %.3g)", bad$check_id[i],
                    bad$observed[i], bad$printed[i], bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
options(scipen = 999)
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- public TSV (only once the item is registered) --------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                         .name_repair = "minimal")
  reg_names <- registry[["Item name"]]
  item_encoded <- registry[["Item encoded"]][match(item_name, reg_names)]
}
if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$", item_encoded)) {
  tsv_dir <- file.path(root, "__Public", "comparative-data")
  dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "",
              fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else {
  message(item_name, ": not yet registered - TSV skipped")
}
