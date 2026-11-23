## ============================================================================
## Sherwood_etal_2007_Table1.R
##
## Build script for Sherwood_etal_2007_Table1 -- reads ONLY this
## item's frozen snapshot (Sherwood_etal_2007_Table1_snapshot.csv)
## and writes the analysis CSV (Sherwood_etal_2007_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 ("Individual Subject Data") of Sherwood et al. (2007),
## Journal of Comparative Neurology 503(4):525-537, gives
## per-individual data for 18 Yerkes chimpanzees (8 F, 10 M;
## identified by Yerkes code only, never named): sex, age at death,
## handedness index (HI, coordinated bimanual tube task) and
## handedness classification (HC: R/L/A), then ASYMMETRY QUOTIENTS
## ONLY for 11 neuroanatomical variables of the primary motor cortex
## hand representation. No per-hemisphere raw values are printed
## anywhere in the paper. AQ = (R - L)/((R + L) x 0.5); positive =
## right-hemisphere dominance.
##
## Flags carried, nothing harmonised:
## - All 18 animals reappear in Sherwood_etal_2010_Table1 with
##   identical HIs (asserted below), but three demographic conflicts
##   stand between the papers: C0576 is F, 20 y here but M, 19 y in
##   2010; C0573 is 15 y here but 28 y in 2010; C0406 is 41 y here
##   but 42 y in 2010. Each conflict is recorded on the affected row
##   of BOTH builds; both papers are carried as printed.
## - Methods prose slip (table unaffected): the Methods describe HI
##   as subtracting right-handed from left-handed responses, but the
##   printed formula HI = (R - L)/(R + L), the sign statement and
##   this table's classifications all agree with each other. The
##   formula governs; the slip is recorded in the README.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Sherwood_etal_2007_Table1.R"
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
stopifnot(nrow(snap) == 18L)
num <- function(x) as.numeric(gsub("−", "-", x, fixed = TRUE))
age <- num(snap$`Age at Death`); hi <- num(snap$HI)
aq_cols <- names(snap)[6:16]
aqs <- lapply(snap[, aq_cols], num)
stopifnot(identical(hi, c(0.51, 0.34, 0.36, -0.69, 0.91, -0.16, 1.00, 0.68,
                          0.45, 0.83, 0.35, 0.34, 0.50, 0.36, 0.77, -0.71,
                          0.65, -1.00)),
          sum(snap$Sex == "F") == 8L, sum(snap$Sex == "M") == 10L,
          sum(snap$HC == "R") == 14L, sum(snap$HC == "L") == 3L,
          sum(snap$HC == "A") == 1L,
          !any(vapply(aqs, function(v) any(is.na(v)), logical(1))))

note <- character(18)
note[snap$`Yerkes Code` == "C0576"] <-
  "Sex and age as printed here (F, 20 y); Sherwood et al. (2010) print M, 19 y for this animal (HI identical)"
note[snap$`Yerkes Code` == "C0573"] <-
  "Age as printed here (15 y); Sherwood et al. (2010) print 28 y for this animal (HI identical)"
note[snap$`Yerkes Code` == "C0406"] <-
  "Age as printed here (41 y); Sherwood et al. (2010) print 42 y for this animal (HI identical)"

final.dataframe <- data.frame(
  Species = "Pan troglodytes",
  `Yerkes Code` = snap$`Yerkes Code`,
  Sex = snap$Sex,
  `Age at death, years` = age,
  HI = hi,
  HC = snap$HC,
  `Hand knob AQ` = aqs[["Hand Knob"]],
  `Neuron density in layer II/III AQ` = aqs[["Neuron Density in Layer II/III"]],
  `Glia density in layer II/III AQ` = aqs[["Glia Density in Layer II/III"]],
  `AF in layer II/III AQ` = aqs[["AF in Layer II/III"]],
  `AF in layer V/VI AQ` = aqs[["AF in Layer V/VI"]],
  `Relative thickness of layer I AQ` = aqs[["Relative Thickness of Layer I"]],
  `Relative thickness of layer II/III AQ` = aqs[["Relative Thickness of Layer II/III"]],
  `Relative thickness of layer V/VI AQ` = aqs[["Relative Thickness of Layer V/VI"]],
  `PV-ir interneuron density in layer II/III AQ` = aqs[["PV-ir Interneuron Density in Layer II/III"]],
  `PV-ir interneuron mean cell volume in layer II/III AQ` = aqs[["PV-ir Interneuron Mean Cell Volume in Layer II/III"]],
  `NPNFP-ir mean cell volume in layer II/III AQ` = aqs[["NPNFP-ir Mean Cell Volume in Layer II/III"]],
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 18L)

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
