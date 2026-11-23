## ============================================================================
## Neves_etal_2014_Table1.R
##
## Build script for Neves_etal_2014_Table1 -- reads ONLY this item's
## frozen snapshot (Neves_etal_2014_Table1_snapshot.csv) and writes the
## analysis CSV (Neves_etal_2014_Table1.csv) and the DOI-coded public
## TSV named by the registry row's "Item encoded".
##
## Table 1 of Neves, Ferreira, Tovar-Moll, Gravett, Bennett, Kaswera,
## Gilissen, Manger & Herculano-Houzel (2014), Frontiers in
## Neuroanatomy 8:5: cellular composition of the brains of five
## afrotherian species (Elephantulus myurus, Petrodromus
## tetradactylus, Amblysomus hottentotus, Procavia capensis,
## Dendrohyrax dorsalis). The printed table is transposed (species as
## columns, measures as rows under abbreviated codes); the snapshot
## keeps that layout and this script transposes it into one row per
## species. Structures: whole brain (BR), cerebral cortex excluding
## the hippocampus (CX), hippocampus (HP), cerebral cortex including
## the hippocampus (CxT = CX + HP), cerebellum (CB), rest of brain
## (RoB: all other structures pooled) and olfactory bulb (OB). Whole
## brain excludes the olfactory bulb (Methods). For each structure
## the table prints mass (g), number of neurons and number of other
## (non-neuronal) cells (both in millions, converted here to absolute
## counts), neuronal and other-cell densities (cells/mg) and the
## other/neuron ratio (O/N), as species means +/- SD. The table does
## NOT print total cell numbers or % neurons for any structure, so
## the analysis CSV has no such columns (Herculano-Houzel et al.
## (2015), which re-report these animals, likewise have no
## total-cells column, and their Table 5 % Neurons is NA for all
## five species). Body mass is printed as a single value per species (the
## species average; no SD printed), so its SD column is empty.
##
## All values are whole-structure estimates: only one hemisphere of
## each brain was available, so the printed numbers are twice the
## single-hemisphere counts (Methods). Numbers of other cells were
## derived by the authors by subtraction (total nuclei minus
## neurons).
##
## "n.a." cells: the olfactory bulb was not available for all
## specimens (Methods). Dendrohyrax dorsalis has no olfactory-bulb
## rows at all; Amblysomus hottentotus has an olfactory-bulb mass
## (0.050 g, no SD) but no cell counts; Procavia capensis has
## olfactory-bulb values without SDs (a single bulb, evidently).
##
## PRINTED ANOMALY handled here (kept verbatim in the snapshot): the
## Procavia capensis olfactory-bulb neuron count is printed inside
## typographic double quotes, "20.909" (millions), in both the PDF
## and PMC. The digits are unambiguous and are consistent with the
## printed density and mass (73,110 neurons/mg x 290 mg = 21.2 x 10^6
## at printed precision, and with Herculano-Houzel et al. (2015),
## Table 4), so the build parses the number, guarded below on the
## exact printed string. The quotes themselves are not explained in
## the paper.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Neves_etal_2014_Table1.R"
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
stopifnot(nrow(snap) == 43L)
headings <- names(snap)[2:6]
stopifnot(identical(headings, c("E. myurus (n = 2)", "P. tetradactylus (n = 2)",
                                "A. hottentotus (n = 2)", "P. capensis (n = 2)",
                                "D. dorsalis (n = 1)")))
expected_labels <- c(
  "MBD",
  "MBR", "MCX", "MHP", "MCxT", "MCB", "MRoB", "MOB",
  "NBR", "NCX", "NHP", "NCxT", "NCB", "NRoB", "NOB",
  "OBR", "OCX", "OHP", "OCxT", "OCB", "ORoB", "OOB",
  "DNBR", "DNCX", "DNHP", "DNCxT", "DNCB", "DNRoB", "DNOB",
  "DOBR", "DOCX", "DOHP", "DOCxT", "DOCB", "DORoB", "DOOB",
  "O/NBR", "O/NCX", "O/NHP", "O/NCxT", "O/NCB", "O/NRoB", "O/NOB")
if (!identical(snap[[1]], expected_labels))
  stop("Snapshot row labels do not match the printed Table 1 layout.")

species <- c("Elephantulus myurus", "Petrodromus tetradactylus",
             "Amblysomus hottentotus", "Procavia capensis",
             "Dendrohyrax dorsalis")
number <- as.integer(sub(".*\\(n = ([0-9]+)\\).*", "\\1", headings))
stopifnot(identical(number, c(2L, 2L, 2L, 2L, 1L)))

## ---- parsers -----------------------------------------------------------------
## Each printed cell is "mean +/- SD", a bare mean, or "n.a.".
## Returns a 2 x 5 matrix (mean, SD) for snapshot row i.
ms <- function(i) {
  vapply(snap[i, 2:6], function(x) {
    if (is.na(x) || x == "n.a.") return(c(NA_real_, NA_real_))
    x <- gsub("[\u201c\u201d]", "", x)          # the quoted NOB cell, below
    p <- strsplit(x, " \u00b1 ", fixed = TRUE)[[1]]
    c(as.numeric(gsub(",", "", p[1])),
      if (length(p) == 2L) as.numeric(gsub(",", "", p[2])) else NA_real_)
  }, numeric(2))
}
cnt <- function(m) { m * 1e6 }                  # printed counts are millions

## Guarded anomaly: NOB (row 15), P. capensis (4th species column) is
## printed inside typographic quotes; assert the exact printed string
## before the parser above strips the quotes.
stopifnot(identical(snap[[5]][15], "\u201c20.909\u201d"))

## Row blocks: structures in printed order BR, CX, HP, CxT, CB, RoB, OB.
st <- c("BR", "CX", "HP", "CxT", "CB", "RoB", "OB")
M   <- lapply(2:8,   ms)                        # mass, g
N   <- lapply(9:15,  function(i) cnt(ms(i)))    # neurons, absolute
O   <- lapply(16:22, function(i) cnt(ms(i)))    # other cells, absolute
DN  <- lapply(23:29, ms)                        # neuronal density, /mg
DO  <- lapply(30:36, ms)                        # other-cell density, /mg
ON  <- lapply(37:43, ms)                        # O/N ratio
names(M) <- names(N) <- names(O) <- names(DN) <- names(DO) <- names(ON) <- st
body <- ms(1)                                   # MBD: mean only, no SD printed

## House checks on the printed means: the additive identities
## CxT = CX + HP and BR = CxT + CB + RoB hold at printed precision
## (loosest cell 0.12%: Petrodromus brain mass, rounding of the
## printed means); the olfactory bulb is excluded from BR.
additive <- function(a, parts, tol = 0.005) {
  s <- Reduce(`+`, lapply(parts, function(p) p[1, ]))
  stopifnot(all(abs(s - a[1, ]) / a[1, ] <= tol))
}
for (blk in list(M, N, O)) {
  additive(blk$CxT, list(blk$CX, blk$HP))
  additive(blk$BR,  list(blk$CxT, blk$CB, blk$RoB))
}
## NA pattern of the olfactory bulb, as printed.
stopifnot(is.na(M$OB[1, 5]), !is.na(M$OB[1, 3]), is.na(M$OB[2, 3]),
          all(is.na(N$OB[, 3])), all(is.na(N$OB[, 5])),
          !is.na(N$OB[1, 4]), is.na(N$OB[2, 4]),
          all(!is.na(N$OB[, 1])), all(!is.na(N$OB[, 2])))

block_cols <- function(S, nm) {
  out <- list()
  out[[paste0(nm, " Mass, g")]]     <- S$M[1, ]
  out[[paste0(nm, " Mass, g SD")]]  <- S$M[2, ]
  out[[paste0(nm, " N, n")]]        <- S$N[1, ]
  out[[paste0(nm, " N, n SD")]]     <- S$N[2, ]
  out[[paste0(nm, " O, n")]]        <- S$O[1, ]
  out[[paste0(nm, " O, n SD")]]     <- S$O[2, ]
  out[[paste0(nm, " N/mg")]]        <- S$DN[1, ]
  out[[paste0(nm, " N/mg SD")]]     <- S$DN[2, ]
  out[[paste0(nm, " O/mg")]]        <- S$DO[1, ]
  out[[paste0(nm, " O/mg SD")]]     <- S$DO[2, ]
  out[[paste0(nm, " O/N")]]         <- S$ON[1, ]
  out[[paste0(nm, " O/N SD")]]      <- S$ON[2, ]
  out
}
get <- function(blk, s) blk[[s]]
struct <- function(s) list(M = get(M, s), N = get(N, s), O = get(O, s),
                           DN = get(DN, s), DO = get(DO, s), ON = get(ON, s))

final.dataframe <- data.frame(
  Species = species,
  Order = "Afrotheria",
  `Common name` = c("Eastern rock elephant shrew", "Four-toed elephant shrew",
                    "Hottentot golden mole", "Rock hyrax",
                    "Western tree hyrax"),
  Number = number,
  `Body mass, g` = body[1, ],
  `Body mass, g SD` = body[2, ],
  `Brain mass, g` = M$BR[1, ],
  `Brain mass, g SD` = M$BR[2, ],
  `Whole brain Neurons` = N$BR[1, ],
  `Whole brain Neurons SD` = N$BR[2, ],
  `Whole brain Other cells` = O$BR[1, ],
  `Whole brain Other cells SD` = O$BR[2, ],
  `Whole brain N/mg` = DN$BR[1, ],
  `Whole brain N/mg SD` = DN$BR[2, ],
  `Whole brain O/mg` = DO$BR[1, ],
  `Whole brain O/mg SD` = DO$BR[2, ],
  `Whole brain O/N` = ON$BR[1, ],
  `Whole brain O/N SD` = ON$BR[2, ],
  check.names = FALSE, stringsAsFactors = FALSE)
for (s in st[-1]) {
  nm <- c(CX = "Cerebral cortex", HP = "Hippocampus",
          CxT = "Cerebral cortex total", CB = "Cerebellum",
          RoB = "RoB", OB = "Olfactory bulb")[[s]]
  bc <- block_cols(struct(s), nm)
  for (cn in names(bc)) final.dataframe[[cn]] <- bc[[cn]]
}
stopifnot(nrow(final.dataframe) == 5L, ncol(final.dataframe) == 90L)

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
