## ============================================================================
## Phillips_Sherwood_2005_Table1.R
##
## Build script for Phillips_Sherwood_2005_Table1 -- reads ONLY this
## item's frozen snapshot (Phillips_Sherwood_2005_Table1_snapshot.csv)
## and writes the analysis CSV (Phillips_Sherwood_2005_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 of Phillips & Sherwood (2005), Behavioral Neuroscience
## 119(6):1701-1704, gives per-individual data for the 7 male Hiram
## College capuchins: simple reaching handedness index (HI) and z,
## tube-task mean HI (MHI) and z, and the asymmetry quotient (AQ) for
## central sulcus depth measured from MRI. No per-hemisphere depths
## are printed -- the AQ is the only anatomical value. Sign
## conventions (table note): negative HI = left-hand preference;
## positive central-sulcus AQ = right-hemisphere dominance.
##
## Build decisions, all documented in the README:
## - Species: the paper prints "Cebus apella"; the build resolves to
##   Sapajus apella (current taxonomy, the name the dataset's species
##   key uses) and keeps the printed form in a column.
## - Sex: the table does not print sex; the Subjects text states the
##   seven subjects are all male, so Sex is M throughout.
## - The 7 coded animals are the same individuals as 7 of the named
##   animals in Phillips_Sherwood_2007_Table1, identifiable by exact
##   tube-task MHI and z matches (CA003 = Vincent, H03 = Alou,
##   CA9207 = Miro, H04 = Shoeless, CG29 = Carlos, H02 = Sosa,
##   H06 = DiMaggio). This is a probable-grade inference from exact
##   value matches, not a printed identification: the codes are kept
##   as printed and the mapping is recorded per row in the Note column.
## - The printed simple-reaching z-scores do not always carry the
##   sign of the simple-reaching HI (e.g. CA003: HI -0.84, z 6.52).
##   Captured verbatim; nothing is "corrected".
## - The snapshot's minus glyph is the APA font's U+2AFA; the build
##   converts it to ASCII "-" for numeric analysis.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Phillips_Sherwood_2005_Table1.R"
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
stopifnot(nrow(snap) == 7L,
          identical(snap$`Monkey ID`,
                    c("CA003", "H03", "CA9207", "H04", "CG29", "H02", "H06")))
num <- function(x) as.numeric(gsub("⫺", "-", x, fixed = TRUE))
age <- num(snap$`Age (in years)`)
sr_hi <- num(snap$`Simple reaching HI`); sr_z <- num(snap$`Simple reaching z`)
mhi <- num(snap$`Tube task MHI`);       tz  <- num(snap$`Tube task z`)
aq  <- num(snap$`Central sulcus AQ`)
stopifnot(!any(is.na(age)), !any(is.na(mhi)), !any(is.na(aq)),
          identical(mhi, c(-1.00, 0.81, 1.00, -0.14, -0.95, -0.62, 0.39)),
          identical(tz,  c(-14.59, 7.40, 7.02, -0.68, -8.61, -8.64, 10.44)))

name07 <- c(CA003 = "Vincent", H03 = "Alou", CA9207 = "Miro", H04 = "Shoeless",
            CG29 = "Carlos", H02 = "Sosa", H06 = "DiMaggio")
note <- unname(sprintf(
  "Coded here; named %s in Phillips_Sherwood_2007_Table1 (probable identification by exact tube-task MHI/z match)",
  name07[snap$`Monkey ID`]))

final.dataframe <- data.frame(
  Species = "Sapajus apella",
  `Species (printed)` = "Cebus apella",
  `Monkey ID` = snap$`Monkey ID`,
  Sex = "M",
  `Age, years` = age,
  `Simple reaching HI` = sr_hi,
  `Simple reaching z` = sr_z,
  `Tube task MHI` = mhi,
  `Tube task z` = tz,
  `Central sulcus AQ` = aq,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 7L,
          identical(final.dataframe$`Central sulcus AQ`[1], 10.80))

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
