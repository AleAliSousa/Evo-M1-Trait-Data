## ============================================================================
## Phillips_Sherwood_2007_Table1.R
##
## Build script for Phillips_Sherwood_2007_Table1 -- reads ONLY this
## item's frozen snapshot (Phillips_Sherwood_2007_Table1_snapshot.csv)
## and writes the analysis CSV (Phillips_Sherwood_2007_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 of Phillips & Sherwood (2007), Neuropsychologia
## 45(10):2398-2401, gives per-individual data for 13 named Hiram
## College capuchins (7 M, 6 F): sex, age, tube-task mean handedness
## index (MHI) and z-score, dextral group (R/L/A), and cerebral
## petalia asymmetry quotients for four regions (anterior frontal,
## posterior frontal, parietal, occipital; positive AQ = right-side
## bias, as printed in the table title). Petalia AQs are cerebral-
## width quotients, not volumes. The capture source is the NIH-PA
## author manuscript held in the repo, not the publisher version.
##
## Build decisions, all documented in the README:
## - Species: the paper prints "Cebus apella"; the build resolves to
##   Sapajus apella and keeps the printed form in a column.
## - Seven of the 13 animals also appear, coded, in
##   Phillips_Sherwood_2005_Table1; the identification rests on exact
##   tube-task MHI and z matches (Vincent = CA003, Alou = H03,
##   Miro = CA9207, Shoeless = H04, Carlos = CG29, Sosa = H02,
##   DiMaggio = H06) and is probable-grade, not printed. The names
##   are kept as printed here; the 2005 code is recorded per row in
##   the Note column. The assertions below pin this paper's MHI and
##   z vectors, which are the values the mapping rests on.
## - Coincidence as printed: Miro's anterior frontal and posterior
##   frontal petalia AQs are both -11.76. Recorded, not "fixed".
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Phillips_Sherwood_2007_Table1.R"
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
stopifnot(nrow(snap) == 13L)
num <- function(x) as.numeric(gsub("−", "-", x, fixed = TRUE))
age <- num(snap$Age); mhi <- num(snap$MHI); z <- num(snap$`z-score`)
ant <- num(snap$`Anterior Frontal Petalia AQ`)
pos <- num(snap$`Posterior Frontal Petalia AQ`)
par <- num(snap$`Parietal Petalia AQ`); occ <- num(snap$`Occipital Petalia AQ`)
stopifnot(!any(is.na(mhi)), !any(is.na(ant)),
          identical(mhi, c(0.81, -0.95, 0.96, 0.39, -0.75, 0.60, 1.00, 0.85,
                           1.00, -0.82, -0.14, -0.62, -1.00)),
          identical(z, c(7.40, -8.61, 5.39, 10.44, -9.41, 4.31, 12.85, 7.14,
                         7.02, -2.00, -0.68, -8.64, -14.59)),
          identical(ant[9], -11.76), identical(pos[9], -11.76))

code05 <- c(Alou = "H03", Carlos = "CG29", DiMaggio = "H06", Miro = "CA9207",
            Shoeless = "H04", Sosa = "H02", Vincent = "CA003")
note <- ifelse(snap$Subject %in% names(code05),
               sprintf("Named here; coded %s in Phillips_Sherwood_2005_Table1 (probable identification by exact tube-task MHI/z match)",
                       unname(code05[snap$Subject])), "")

final.dataframe <- data.frame(
  Species = "Sapajus apella",
  `Species (printed)` = "Cebus apella",
  Subject = snap$Subject,
  Sex = snap$Sex,
  `Age, years` = age,
  MHI = mhi,
  `z-score` = z,
  `Dextral Group` = snap$`Dextral Group`,
  `Anterior Frontal Petalia AQ` = ant,
  `Posterior Frontal Petalia AQ` = pos,
  `Parietal Petalia AQ` = par,
  `Occipital Petalia AQ` = occ,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 13L,
          sum(final.dataframe$Sex == "M") == 7L,
          sum(final.dataframe$Sex == "F") == 6L)

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
