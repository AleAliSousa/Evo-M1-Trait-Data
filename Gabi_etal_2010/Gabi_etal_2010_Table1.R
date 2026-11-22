## ============================================================================
## Gabi_etal_2010_Table1.R
##
## Build script for Gabi_etal_2010_Table1 -- reads ONLY this item's
## frozen snapshot (Gabi_etal_2010_Table1_snapshot.csv) and writes the
## analysis CSV (Gabi_etal_2010_Table1.csv) and the DOI-coded public
## TSV named by the registry row's "Item encoded".
##
## Table 1 of Gabi, Collins, Wong, Torres, Kaas & Herculano-Houzel
## (2010), Brain, Behavior and Evolution 76(1): cellular composition of
## the brain of five primate species (Microcebus murinus, Callimico
## goeldii, Macaca fascicularis, Macaca radiata, Papio cynocephalus).
## The printed table is transposed (species as columns, measures as
## rows, structures in blocks: Whole brain, Cerebral cortex,
## Cerebellum, Remaining areas); the snapshot keeps that layout and
## this script transposes it into one row per species. "Remaining
## areas" is the paper's rest of brain (RoB): all structures other
## than cerebral cortex and cerebellum, pooled; the olfactory bulb
## was not included in any brain (Methods). All values are for whole
## structures: only one hemisphere was available per animal, so the
## printed numbers are twice the single-hemisphere counts (Methods).
## The printed fold-variation column stays in the snapshot and is
## dropped here. Table 1 prints no SDs, so the analysis CSV has no SD
## columns (the values are single-animal values for four species and
## the average of two animals for Papio, with no dispersion printed).
##
## "n.a." cells: the Callimico cerebellum was only partially included
## in the dissection and was eliminated from the analysis (Methods),
## so Callimico has no cerebellum rows and no whole-brain rows; its
## cerebral cortex and remaining-areas rows are present.
##
## Body mass: the mouse lemur and baboon values were measured; the
## Callimico value (480 g, footnote 1) is from Stephan et al. (1981)
## and the two macaque values (footnotes 2) are from Burish et al.
## (2010), because body weights were not available for those animals
## (Methods). All five are printed in Table 1 and are built as
## printed; the literature provenance is recorded in the definitions
## file.
##
## ERRATUM applied here (publication error, kept verbatim in the
## snapshot): the remaining-areas total number of cells for Callimico
## is printed as "248.44 x 10^9". The exponent is a misprint: the
## row's own components (53.91 x 10^6 neurons + 194.53 x 10^6
## non-neuronal cells = 248.44 x 10^6) and the printed densities
## ((25,844 + 93,254) cells/mg x 2,086 mg = 248.44 x 10^6) both give
## 10^6, and Herculano-Houzel et al. (2015), Table 3, re-report the
## same animal's components summing to 248,440,000. The build uses
## 248.44 x 10^6, guarded below on the exact printed string.
## Two further printed anomalies are NOT corrected (values kept as
## printed; see README): the whole-brain total neurons of Macaca
## radiata (3.78 x 10^9) is inconsistent with the paper's own
## structure values (which sum to 3.76 x 10^9) and with its printed
## % neuronal cells and NN/N; and the remaining-areas non-neuronal
## density of Microcebus (93,254/mg) duplicates the Callimico value
## and disagrees with the printed count and mass (101,731/mg, the
## value Herculano-Houzel et al. (2015) print).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Gabi_etal_2010_Table1.R"
script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a) && basename(sub("^--file=", "", a[1])) == me)
    return(normalizePath(sub("^--file=", "", a[1])))
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) != 1L) stop("Cannot locate script: ", me)
  normalizePath(hits)
})
folder <- dirname(script_path)
base <- tools::file_path_sans_ext(basename(script_path))
item_name <- base
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
  root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository root not found")

snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character",
                        na.strings = "")
stopifnot(nrow(snap) == 36L)
species <- names(snap)[2:6]
stopifnot(identical(species, c("Microcebus murinus", "Callimico goeldii",
                               "Macaca fascicularis", "Macaca radiata",
                               "Papio cynocephalus")))
expected_labels <- c(
  "n", "Body mass, g",
  "Whole brain", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N",
  "Cerebral cortex", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg",
  "Cerebellum", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg",
  "Remaining areas", "Mass, g", "Total number of cells",
  "Total number of neurons", "Total number of non-neuronal cells",
  "% neuronal cells", "NN/N", "Neuronal density, N/mg",
  "Non-neuronal density, NN/mg")
if (!identical(snap[[1]], expected_labels))
  stop("Snapshot row labels do not match the printed Table 1 layout.")

## ---- parsers -----------------------------------------------------------------
num <- function(x) {                       # plain printed number or "n.a."
  if (is.na(x) || x == "n.a.") return(NA_real_)
  as.numeric(gsub(",", "", x, fixed = TRUE))
}
cnt <- function(x) {                       # printed count "393.66 x 10^6"
  if (is.na(x) || x == "n.a.") return(NA_real_)
  round(as.numeric(gsub(",", "", sub(" \u00d7 10\\^", "e", x), fixed = TRUE)))
}
row_vals <- function(i, parser) vapply(snap[i, 2:6], parser, numeric(1))

## Erratum: Callimico remaining-areas total cells (row 30, species
## column 3 of the snapshot) -- exponent misprinted as 10^9, see header.
rob_cells_raw <- snap[[3]][30]
if (!identical(rob_cells_raw, "248.44 \u00d7 10^9"))
  stop("Expected the misprinted RoB cells string for Callimico, got: ",
       rob_cells_raw)
rob_cells <- row_vals(30, cnt)
rob_cells[2] <- 248.44e6                   # printed 10^9 corrected to 10^6

block <- function(rows) list(              # rows: the block's 8 (or 6) rows
  mass  = row_vals(rows[1], num),
  cells = row_vals(rows[2], cnt),
  n     = row_vals(rows[3], cnt),
  o     = row_vals(rows[4], cnt),
  perc  = row_vals(rows[5], num),
  on    = row_vals(rows[6], num),
  nmg   = if (length(rows) >= 8L) row_vals(rows[7], num) else NULL,
  omg   = if (length(rows) >= 8L) row_vals(rows[8], num) else NULL)
wb <- block(c(4, 5, 6, 7, 8, 9))           # whole brain: no densities printed
cx <- block(11:18)
cb <- block(20:27)
rb <- block(29:36)
rb$cells <- rob_cells                      # erratum-corrected, guarded above

body_mass <- vapply(snap[2, 2:6],
                    function(x) num(sub("\\^[0-9]+$", "", x)), numeric(1))
number <- as.integer(row_vals(1, num))
stopifnot(identical(number, c(1L, 1L, 1L, 1L, 2L)))

final.dataframe <- data.frame(
  Species = species,
  Order = "Primata",
  `Common name` = c("Mouse lemur", "Goeldi's marmoset", "Long-tailed monkey",
                    "Bonnet monkey", "Baboon"),
  Number = number,
  `Body mass, g` = body_mass,
  `Brain mass, g` = wb$mass,
  `Whole brain Cells` = wb$cells,
  `Whole brain Neurons` = wb$n,
  `Whole brain Other cells` = wb$o,
  `Whole brain % Neurons` = wb$perc,
  `Whole brain O/N` = wb$on,
  `Cerebral cortex Mass, g` = cx$mass,
  `Cerebral cortex Cells, n` = cx$cells,
  `Cerebral cortex N, n` = cx$n,
  `Cerebral cortex O, n` = cx$o,
  `Cerebral cortex % Neurons` = cx$perc,
  `Cerebral cortex O/N` = cx$on,
  `Cerebral cortex N/mg` = cx$nmg,
  `Cerebral cortex O/mg` = cx$omg,
  `Cerebellum Mass, g` = cb$mass,
  `Cerebellum Cells, n` = cb$cells,
  `Cerebellum N, n` = cb$n,
  `Cerebellum O, n` = cb$o,
  `Cerebellum % Neurons` = cb$perc,
  `Cerebellum O/N` = cb$on,
  `Cerebellum N/mg` = cb$nmg,
  `Cerebellum O/mg` = cb$omg,
  `RoB Mass, g` = rb$mass,
  `RoB Cells, n` = rb$cells,
  `RoB N, n` = rb$n,
  `RoB O, n` = rb$o,
  `RoB % Neurons` = rb$perc,
  `RoB O/N` = rb$on,
  `RoB N/mg` = rb$nmg,
  `RoB O/mg` = rb$omg,
  check.names = FALSE, stringsAsFactors = FALSE)

## House checks: within every printed block, neurons and other cells
## cannot exceed total cells and must sum to it at printed precision
## (loosest cell: Macaca radiata whole brain, 0.35%); the Callimico
## whole-brain and cerebellum blocks are entirely absent (n.a.).
chk <- function(b) {
  ok <- !is.na(b$cells)
  stopifnot(all(b$n[ok] <= b$cells[ok]), all(b$o[ok] <= b$cells[ok]),
            all(abs(b$n[ok] + b$o[ok] - b$cells[ok]) / b$cells[ok] <= 0.005))
}
chk(wb); chk(cx); chk(cb); chk(rb)
stopifnot(all(is.na(cb$cells[2])), all(is.na(wb$cells[2])),
          !is.na(cx$cells[2]), !is.na(rb$cells[2]),
          all(final.dataframe[["Body mass, g"]] > 0),
          all(final.dataframe[["Brain mass, g"]][!is.na(
            final.dataframe[["Brain mass, g"]])] > 0))

options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_"))
  stop("Invalid Item encoded for ", item_name)
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                   sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
    " columns\n", sep = "")
