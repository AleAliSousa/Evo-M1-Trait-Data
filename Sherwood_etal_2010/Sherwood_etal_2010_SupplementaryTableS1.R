## ============================================================================
## Sherwood_etal_2010_SupplementaryTableS1.R
##
## Build script for Sherwood_etal_2010_SupplementaryTableS1 --
## reads this item's frozen snapshot
## (Sherwood_etal_2010_SupplementaryTableS1_snapshot.csv) and, as a
## documented exception to the one-snapshot rule, the sibling
## Sherwood_etal_2010_Table1_snapshot.csv from the same folder,
## because this table's AQ column must agree with Table 1's density
## AQ for the same animals. It writes the analysis CSV
## (Sherwood_etal_2010_SupplementaryTableS1.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Supplementary Table S1 of Sherwood et al. (2010) gives the
## per-hemisphere SY-immunoreactive puncta densities (number of
## puncta per 10^8/mm3) for the left and right primary motor cortex
## hand representation of the same 33 chimpanzees as Table 1, with
## the AQ calculated from them. It is the only per-hemisphere raw
## data in either Sherwood chimpanzee paper. The build recomputes
## every AQ from the printed left/right densities and checks it
## against both this table's printed AQ column and Table 1's
## density AQ: the two printed AQ columns agree EXACTLY for all 33
## animals, and recomputation agrees within 0.016 for 32 of 33.
## The exception is C0594 (printed AQ 0.02 in both tables;
## recomputation from the printed densities 2.24/2.32 gives 0.035,
## more than density rounding explains) -- the paper's AQ was
## evidently computed from unrounded or intermediate values.
## Carried as printed everywhere and flagged on the row; not a
## guarded correction (the two AQ printings agree with each other,
## and there is no basis for preferring a recomputed value).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Sherwood_etal_2010_SupplementaryTableS1.R"
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
stopifnot(nrow(snap) == 33L)
num <- function(x) as.numeric(gsub("−", "-", x, fixed = TRUE))
age <- num(snap$Age)
left <- num(snap$`SY-ir puncta density - left`)
right <- num(snap$`SY-ir puncta density - right`)
aq <- num(snap$`SY-ir puncta density AQ`)
stopifnot(!any(is.na(left)), !any(is.na(right)), !any(is.na(aq)))

## Recompute every AQ from the per-hemisphere densities.
aq_calc <- (right - left) / ((right + left) * 0.5)
dev1 <- max(abs(aq_calc - aq))
## Cross-check against Table 1's density AQ for the same animals.
t1 <- utils::read.csv(file.path(folder, "Sherwood_etal_2010_Table1_snapshot.csv"),
                      check.names = FALSE, colClasses = "character")
stopifnot(identical(t1$Subject, snap$Subject),
          identical(t1$Sex, snap$Sex),
          identical(num(t1$`Age at death (years)`), age))
dev2 <- max(abs(num(t1$`SY-immunoreactive puncta density AQ`) - aq))
cat("AQ recomputation: max |calc - printed| = ", dev1,
    "; max |Table 1 AQ - S1 AQ| = ", dev2, "\n", sep = "")
## Tolerance 0.02: the printed densities are rounded to 2 dp, which
## alone bounds the recomputation error near ~0.01, and C0594's
## documented case (see header) reaches 0.0151. The two printed AQ
## columns must agree exactly.
stopifnot(dev1 <= 0.02, dev2 == 0)

note <- character(33)
note[snap$Subject == "C0594"] <- paste(
  "Printed AQ 0.02 (also 0.02 in Sherwood_etal_2010_Table1); recomputation",
  "from the printed densities gives 0.035 -- the paper's AQ was evidently",
  "computed from unrounded values; carried as printed")

final.dataframe <- data.frame(
  Species = "Pan troglodytes",
  Subject = snap$Subject,
  Sex = snap$Sex,
  `Age at death, years` = age,
  `SY-ir puncta density, left (per 10^8/mm3)` = left,
  `SY-ir puncta density, right (per 10^8/mm3)` = right,
  `SY-ir puncta density AQ` = aq,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 33L)

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
