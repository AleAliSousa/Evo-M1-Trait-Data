## ============================================================================
## HerculanoHouzel_Kaas_2011_Table2.R
##
## Build script for HerculanoHouzel_Kaas_2011_Table2 -- reads ONLY this
## item's frozen snapshot (HerculanoHouzel_Kaas_2011_Table2_snapshot.csv)
## and writes the analysis CSV (HerculanoHouzel_Kaas_2011_Table2.csv)
## and the DOI-coded public TSV named by the registry row's
## "Item encoded".
##
## Table 2 of Herculano-Houzel & Kaas (2011), Brain Behav Evol 77(1):
## "Deviation from expected cellular composition of the cerebellum".
## For nine primate species it prints the cerebellar mass (in the row
## label), the total number of cells EXPECTED in the cerebellum under
## the primate cellular scaling rules and under the rodent rules (the
## two fitted equations in the group headings), the OBSERVED total
## number of cells (printed twice, identically, once under each rule),
## and the percentage deviation of observed from expected. Per the
## registry row, ONLY the observed values are this paper's data: the
## expected and deviation columns stay in the snapshot and never enter
## the analysis CSV or the TSV. Below, the expected and deviation
## columns serve only as checks on the capture: the expected values
## must recompute from the printed equations and masses, and the
## deviations must recompute from the printed expected and observed
## values (the table's footnote a: Deviation = 100 x (observed -
## expected)/expected).
##
## One printed error the checks must absorb: in the PRIMATE block, the
## deviation percentages of the Pongo pygmaeus and Gorilla gorilla
## rows are transposed. Pongo prints 31.9% where its own printed
## expected and observed give +37.7%; Gorilla prints 37.7% where its
## own give +31.9%; each row's printed value matches the OTHER row's
## recomputed value (31.92 and 37.75 from the printed numbers). The
## rodent block of both rows recomputes correctly, the expected
## values recompute from the equations row by row, and the observed
## values are confirmed by the paper's text and by Herculano-Houzel
## et al. (2015) -- so the slip is confined to those two printed
## percentages, which are not built. The script asserts the
## transposition explicitly rather than widening the tolerance.
##
## Provenance of the observed rows (the paper's text; carried per row
## in the Cerebellum Source column):
## - Gorilla gorilla (n = 1) and Pongo pygmaeus (n = 3) are THIS
##   paper's own measurements: whole cerebella donated by the Yerkes
##   Regional Research Center, stored in 4% paraformaldehyde for over
##   10 years and processed in 2008; one cerebellar hemisphere was
##   counted with the isotropic fractionator and doubled (Methods).
## - Homo sapiens is compiled from Azevedo et al. (2009): the mass
##   (154.02 g) is that paper's unrounded cerebellar mass and the
##   observed 85.08 billion is its Results-text total (the Azevedo
##   Table 1 parts sum to 85.07 billion; see the Azevedo build).
## - The other six species are compiled from Herculano-Houzel et al.
##   (2007): "the other primate cerebella analyzed previously
##   [Herculano-Houzel et al., 2007]". Herculano-Houzel et al. (2015)
##   cite the same sources for the same rows.
## Number is the number of individuals behind the values, from this
## paper's Methods (gorilla 1, orangutans 3) and from Azevedo et al.
## (2009) for the human row (4 donors). It is left empty for the six
## rows compiled from Herculano-Houzel et al. (2007): Table 2 does not
## print it, and it is not imported from the 2007 paper.
##
## What Table 2 does and does not print:
## - No SDs anywhere, so every SD column of the analysis CSV is left
##   empty. (The paper's text reports SDs for the orangutan -- mass
##   35.06 +/- 4.34 g, cells 28.5 +/- 3.78 billion -- but they are not
##   part of this table and are not imported; the Azevedo precedent.)
## - No neuron / non-neuron split: the table's only cell measure is
##   the TOTAL number of cells in the cerebellum. The neuron numbers
##   for the two apes exist only in the paper's text, as granule-cell
##   counts estimated from nuclear morphology (the tissue had been
##   fixed too long for NeuN immunocytochemistry); they are not part
##   of this item and are not built here.
## - No body mass and no other structure: the cerebellar mass in the
##   row labels is the only mass.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "HerculanoHouzel_Kaas_2011_Table2.R"
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
                        check.names = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 10L)   # sub-heading row + 9 species rows
subhdr <- unname(unlist(snap[1, ]))
stopifnot(identical(subhdr, c("", "expected", "observed", "deviation^a",
                              "expected", "observed", "deviation^a")))
dat <- snap[-1, ]
row.names(dat) <- NULL
stopifnot(all(nzchar(as.matrix(dat))))   # the printed table has no empty cells

labels       <- dat[[1]]
prim_exp     <- dat[[2]]; prim_obs <- dat[[3]]; prim_dev <- dat[[4]]
rod_exp      <- dat[[5]]; rod_obs  <- dat[[6]]; rod_dev  <- dat[[7]]

## The observed column is printed twice, identically.
stopifnot(identical(prim_obs, rod_obs))

species <- sub(" \\([0-9.]+ g\\)$", "", labels)
mass    <- as.numeric(sub(".*\\(([0-9.]+) g\\)$", "\\1", labels))
stopifnot(!any(is.na(mass)), length(species) == 9L)

## "453.80 x 10^6" -> 453,800,000 (x is the printed U+00D7; the
## snapshot renders the superscript with a caret).
parse_count <- function(x) {
  m <- regmatches(x, regexec("^([0-9.]+) \u00d7 10\\^([0-9]+)$", x))
  vapply(m, function(p) {
    if (length(p) != 3L) stop("Unparseable printed count: ", x)
    round(as.numeric(p[2]) * 10^as.numeric(p[3]))
  }, numeric(1))
}
cells      <- parse_count(prim_obs)
prim_exp_n <- parse_count(prim_exp)
rod_exp_n  <- parse_count(rod_exp)
parse_dev  <- function(x) as.numeric(gsub("%", "", gsub("\u2212", "-", x,
                                                       fixed = TRUE),
                                          fixed = TRUE))
prim_dev_n <- parse_dev(prim_dev)
rod_dev_n  <- parse_dev(rod_dev)

## Capture check 1: the printed expected values must recompute from
## the printed equations (group headings) at the printed masses.
## Loosest cell (Otolemur, primate block) is 0.34% off, because its
## mass is printed rounded to 1.20 g (unrounded 1.196 g in
## Herculano-Houzel et al., 2015); tolerance 0.5%.
prim_calc <- 619105857.039 * mass^0.987
rod_calc  <- 386335032.000 * mass^0.766
stopifnot(all(abs(prim_calc / prim_exp_n - 1) <= 0.005),
          all(abs(rod_calc  / rod_exp_n  - 1) <= 0.005))

## Capture check 2: the printed deviations must recompute from the
## printed expected and observed values (footnote a). All cells agree
## within 1.0 percentage point (loosest: Aotus primate block, 0.52,
## from the three-significant-figure printings) EXCEPT the primate
## block of Pongo and Gorilla, whose printed percentages are
## transposed (see header): each must instead match the other row's
## recomputed deviation.
recomputed_prim <- 100 * (cells - prim_exp_n) / prim_exp_n
recomputed_rod  <- 100 * (cells - rod_exp_n) / rod_exp_n
ip <- which(species == "Pongo pygmaeus"); ig <- which(species == "Gorilla gorilla")
stopifnot(length(ip) == 1L, length(ig) == 1L)
plain <- setdiff(seq_len(9L), c(ip, ig))
stopifnot(all(abs(recomputed_prim[plain] - prim_dev_n[plain]) <= 1.0),
          all(abs(recomputed_rod - rod_dev_n) <= 1.0),
          abs(prim_dev_n[ip] - recomputed_prim[ig]) <= 1.0,
          abs(prim_dev_n[ig] - recomputed_prim[ip]) <= 1.0)

common <- c("Callithrix jacchus" = "Common marmoset",
            "Otolemur garnettii" = "Greater galago",
            "Aotus trivirgatus"  = "Owl monkey",
            "Saimiri sciureus"   = "Squirrel monkey",
            "Cebus apella"       = "Tufted capuchin",
            "Macaca mulatta"     = "Rhesus monkey",
            "Pongo pygmaeus"     = "Bornean orangutan",
            "Gorilla gorilla"    = "Western gorilla",
            "Homo sapiens"       = "Human")
source <- c("Callithrix jacchus" = "Herculano-Houzel et al., 2007",
            "Otolemur garnettii" = "Herculano-Houzel et al., 2007",
            "Aotus trivirgatus"  = "Herculano-Houzel et al., 2007",
            "Saimiri sciureus"   = "Herculano-Houzel et al., 2007",
            "Cebus apella"       = "Herculano-Houzel et al., 2007",
            "Macaca mulatta"     = "Herculano-Houzel et al., 2007",
            "Pongo pygmaeus"     = "This study",
            "Gorilla gorilla"    = "This study",
            "Homo sapiens"       = "Azevedo et al., 2009")
number <- c("Pongo pygmaeus" = 3L, "Gorilla gorilla" = 1L,
            "Homo sapiens" = 4L)

final.dataframe <- data.frame(
  Species = species,
  Order = "Primata",
  `Common name` = unname(common[species]),
  Number = unname(number[species]),
  `Cerebellum Mass, g` = mass, `Cerebellum Mass, g SD` = NA_real_,
  `Cerebellum Cells, n` = cells, `Cerebellum Cells, n SD` = NA_real_,
  `Cerebellum Source` = unname(source[species]),
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 9L,
          all(final.dataframe$`Cerebellum Cells, n` > 0))

## Counts reach 8.5e10, past the point where write.csv switches to
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
