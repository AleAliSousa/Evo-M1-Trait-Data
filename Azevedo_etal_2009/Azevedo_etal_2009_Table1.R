## ============================================================================
## Azevedo_etal_2009_Table1.R
##
## Build script for Azevedo_etal_2009_Table1 -- reads ONLY this item's
## frozen snapshot (Azevedo_etal_2009_Table1_snapshot.csv) and writes
## the analysis CSV (Azevedo_etal_2009_Table1.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Table 1 of Azevedo et al. (2009), J Comp Neurol 513(5): the cellular
## composition of the human brain, printed as five blocks. Each block
## conditions on one observed quantity (a primate of 75 kg; a primate
## brain of 1,508 g; a cortex of 1,233 g; a cerebellum of 154 g; an RoB
## of 118 g) and prints, per quantity, the value EXPECTED under the
## primate cellular scaling rules of Herculano-Houzel et al. (2007),
## the OBSERVED value, and the percentage difference. ONLY the Observed
## column is this paper's data: the Expected and Difference columns
## stay in the snapshot and never enter the analysis CSV or the TSV
## (the Difference column is used below only as a check on the capture:
## it must recompute from the printed Expected and Observed values).
## Counts are printed in billions (the table's footnote) and are
## converted here to absolute numbers; masses are in grams.
##
## What Table 1 does and does not print:
## - No SDs anywhere. The paper reports mean +/- SD in its text and
##   figures, and Herculano-Houzel et al. (2015) re-report the SDs, but
##   they are not part of this table, so every SD column of the
##   analysis CSV is left empty rather than filled from elsewhere.
## - No body mass. The "75 kg" heading the first block is the reference
##   body mass its Expected values are computed for, not a measurement
##   of the donors, so Body mass is left empty.
## - Structure masses appear only inside the block headings (1,233 g
##   cortex, 154 g cerebellum, 118 g RoB), rounded to the gram; they
##   are the observed masses the blocks condition on and are taken as
##   the structures' masses, as printed. Their sum (1,505 g) falls 3 g
##   short of the printed whole-brain mass (1,508 g) -- a rounding /
##   dissection property of the printed table, kept as printed.
## - Whole-brain neurons and nonneurons are printed twice (first and
##   second blocks, against two different Expected values); the script
##   asserts the two Observed printings agree and uses the value once.
##
## Species: Homo sapiens, one pooled row for the four donors. "Number"
## is the number of individuals, from the paper's Methods and Results
## (four male brains, from men aged 50, 51, 54 and 71 years); it is not
## printed in Table 1. The cerebral cortex includes subcortical white
## matter; the RoB ("rest of brain") comprises the basal ganglia,
## diencephalon and brainstem (the paper's Results wording).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Azevedo_etal_2009_Table1.R"
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
                        check.names = FALSE, colClasses = "character", na.strings = "")
stopifnot(nrow(snap) == 17L)
lab <- snap[[1]]; expct <- snap[[2]]; obs <- snap[[3]]; dif <- snap[[4]]

num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
group_rows <- which(startsWith(lab, "For a primate"))
stopifnot(identical(group_rows, c(1L, 6L, 9L, 12L, 15L)))

## Observed value of the data row `offset` lines below group row `g`.
ob <- function(g, offset) num(obs[g + offset])
## Structure mass printed in a block heading, e.g. "... of 1,233 g".
heading_mass <- function(g) num(sub(".* of ([0-9,]+) g$", "\\1", lab[g]))

## Capture check: the printed Difference column must recompute from the
## printed Expected and Observed values. Two cells (whole-brain
## nonneurons, -10.2%; cerebellar nonneurons, +42.4%) sit 0.06 points
## off the value recomputed from the rounded printings, consistent with
## the authors having computed from unrounded values; tolerance 0.1.
data_rows <- setdiff(seq_len(17L), group_rows)
recomputed <- (num(obs[data_rows]) - num(expct[data_rows])) /
              num(expct[data_rows]) * 100
printed_dif <- num(gsub("%", "", gsub("\u2212", "-", dif[data_rows]),
                        fixed = TRUE))
stopifnot(all(abs(recomputed - printed_dif) <= 0.1))

## Whole-brain block (group 1) and its re-printing (group 2).
brain_mass   <- ob(1L, 1L)          # "Total brain mass (g)"
wb_cells     <- ob(1L, 2L)          # billions
wb_neurons   <- ob(1L, 3L)
wb_nonneu    <- ob(1L, 4L)
stopifnot(ob(6L, 1L) == wb_neurons, ob(6L, 2L) == wb_nonneu)

## Structure blocks (groups 3-5): neurons then nonneurons, billions.
ctx_mass <- heading_mass(9L);  ctx_n <- ob(9L, 1L);  ctx_o <- ob(9L, 2L)
cb_mass  <- heading_mass(12L); cb_n  <- ob(12L, 1L); cb_o  <- ob(12L, 2L)
rob_mass <- heading_mass(15L); rob_n <- ob(15L, 1L); rob_o <- ob(15L, 2L)

## House checks on the Observed values: the structures must sum to the
## whole brain. Neuron and nonneuron sums are exact at the printed
## precision; total cells are 0.01 billion below the sum of their parts
## (170.68 printed vs 170.67 summed) -- a rounding property of the
## printed table, asserted with that tolerance, not corrected.
stopifnot(round(ctx_n + cb_n + rob_n, 2) == wb_neurons,
          round(ctx_o + cb_o + rob_o, 2) == wb_nonneu,
          abs(wb_cells - (wb_neurons + wb_nonneu)) <= 0.011,
          brain_mass > 0, wb_neurons < wb_cells)

B <- 1e9   # printed counts are in billions (table footnote)
cnt <- function(x) round(x * B)   # counts are whole numbers (house pattern)
final.dataframe <- data.frame(
  Species = "Homo sapiens",
  Order = "Primata",
  `Common name` = "Human",
  Number = 4L,
  `Body mass, g` = NA_real_, `Body mass, g SD` = NA_real_,
  `Brain mass, g` = brain_mass, `Brain mass, g SD` = NA_real_,
  `Whole brain Cells` = cnt(wb_cells), `Whole brain Cells SD` = NA_real_,
  `Whole brain Neurons` = cnt(wb_neurons), `Whole brain Neurons SD` = NA_real_,
  `Whole brain Other cells` = cnt(wb_nonneu), `Whole brain Other cells SD` = NA_real_,
  `Cerebral cortex Mass, g` = ctx_mass, `Cerebral cortex Mass, g SD` = NA_real_,
  `Cerebral cortex N, n` = cnt(ctx_n), `Cerebral cortex N, n SD` = NA_real_,
  `Cerebral cortex O, n` = cnt(ctx_o), `Cerebral cortex O, n SD` = NA_real_,
  `Cerebellum Mass, g` = cb_mass, `Cerebellum Mass, g SD` = NA_real_,
  `Cerebellum N, n` = cnt(cb_n), `Cerebellum N, n SD` = NA_real_,
  `Cerebellum O, n` = cnt(cb_o), `Cerebellum O, n SD` = NA_real_,
  `RoB Mass, g` = rob_mass, `RoB Mass, g SD` = NA_real_,
  `RoB N, n` = cnt(rob_n), `RoB N, n SD` = NA_real_,
  `RoB O, n` = cnt(rob_o), `RoB O, n SD` = NA_real_,
  check.names = FALSE, stringsAsFactors = FALSE)

## Counts reach 1.7e11, past the point where write.csv switches to
## scientific notation; the house files print counts in full.
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
