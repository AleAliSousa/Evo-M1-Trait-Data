## ============================================================================
## Sherwood_etal_2010_Table1.R
##
## Build script for Sherwood_etal_2010_Table1 -- reads ONLY this
## item's frozen snapshot (Sherwood_etal_2010_Table1_snapshot.csv)
## and writes the analysis CSV (Sherwood_etal_2010_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 ("Data used in this study") of Sherwood et al. (2010),
## European Journal of Neuroscience 31(8):1456-1464, gives
## per-individual data for 33 chimpanzees (15 F, 18 M; Yerkes and
## UT MD Anderson Bastrop; code-only, never named): sex, age at
## death, postmortem interval (PMI, h), rearing history (C =
## captive-born, W = wild-born), synaptophysin (SY)-immunoreactive
## puncta density AQ, SY protein expression level AQ, handedness
## index (tube task) and handedness category (R/L/NP; NP = no
## preference, this paper's term for the ambidextrous construct).
## AQ = (R - L)/((R + L) x 0.5); positive = right-hemisphere
## dominance.
##
## Missingness is real data, carried as missing, never zero:
## - the protein-expression AQ is blank (printed en dash) for 12 of
##   the 33 animals in the PMC author manuscript (Western blot
##   subset n = 21);
## - PMI is printed "N/A" for 4 animals.
##
## Flags carried, nothing harmonised: all 18 animals of
## Sherwood_etal_2007_Table1 are contained here with identical HIs
## (asserted below), but C0576 is M, 19 y here against F, 20 y in
## 2007; C0573 is 28 y here against 15 y in 2007; C0406 is 42 y
## here against 41 y in 2007. Each conflict is recorded on the
## affected row of BOTH builds; both papers are carried as printed.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Sherwood_etal_2010_Table1.R"
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
age <- num(snap$`Age at death (years)`)
pmi <- num(ifelse(snap$`PMI (h)` == "N/A", NA_character_, snap$`PMI (h)`))
dens_aq <- num(snap$`SY-immunoreactive puncta density AQ`)
prot_aq <- num(ifelse(snap$`SY protein expression level AQ` == "–",
                      NA_character_, snap$`SY protein expression level AQ`))
hi <- num(snap$`Handedness index`)
stopifnot(sum(is.na(pmi)) == 4L, sum(is.na(prot_aq)) == 12L,
          sum(!is.na(prot_aq)) == 21L,
          sum(snap$Sex == "F") == 15L, sum(snap$Sex == "M") == 18L,
          sum(snap$`Handedness category` == "R") == 25L,
          sum(snap$`Handedness category` == "L") == 5L,
          sum(snap$`Handedness category` == "NP") == 3L)
## The 18 shared animals carry identical HIs in both papers:
hi07 <- c(C0630 = 0.51, C0576 = 0.34, C0342 = 0.36, C0320 = -0.69,
          C0406 = 0.91, C0336 = -0.16, C0408 = 1.00, C0242 = 0.68,
          C0645 = 0.45, C0573 = 0.83, C0507 = 0.35, C0491 = 0.34,
          C0429 = 0.50, C0423 = 0.36, C0369 = 0.77, C0301 = -0.71,
          C0273 = 0.65, C0367 = -1.00)
shared <- snap$Subject %in% names(hi07)
stopifnot(sum(shared) == 18L,
          identical(unname(hi[shared]), unname(hi07[snap$Subject[shared]])))

note <- character(33)
note[snap$`PMI (h)` == "N/A"] <- "PMI printed as N/A"
note[snap$Subject == "C0576"] <- paste(
  "Sex and age as printed here (M, 19 y); Sherwood et al. (2007) print F, 20 y",
  "for this animal (HI identical)")
note[snap$Subject == "C0573"] <- paste(
  "Age as printed here (28 y); Sherwood et al. (2007) print 15 y",
  "for this animal (HI identical)")
note[snap$Subject == "C0406"] <- paste(
  "Age as printed here (42 y); Sherwood et al. (2007) print 41 y",
  "for this animal (HI identical)")

final.dataframe <- data.frame(
  Species = "Pan troglodytes",
  Subject = snap$Subject,
  Sex = snap$Sex,
  `Age at death, years` = age,
  `PMI, h` = pmi,
  `Rearing history` = snap$`Rearing history`,
  `SY puncta density AQ` = dens_aq,
  `SY protein expression AQ` = prot_aq,
  HI = hi,
  `Handedness category` = snap$`Handedness category`,
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
