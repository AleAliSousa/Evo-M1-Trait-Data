## ============================================================================
## Semendeferi_etal_2011_Table1.R
##
## Build script for Semendeferi_etal_2011_Table1 -- reads ONLY this
## item's frozen snapshot (Semendeferi_etal_2011_Table1_snapshot.csv)
## and writes the analysis CSV (Semendeferi_etal_2011_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 ("Specimens") of Semendeferi et al. (2011), Cerebral Cortex
## 21(7):1485-1497, lists the 19 hominoid brains (8 humans, 11 apes)
## whose layer III neuronal spacing is summarised in the paper's
## Tables 2 and 3: group, specimen name/code, sex, age (years) and
## brain weight (g). The table prints group names only (Human, Bonobo,
## Chimpanzee, Gorilla, Orangutan, Gibbon); the build resolves each
## group to its binomial and keeps the printed form in a column:
## - Gibbon -> Hylobates lar: both gibbon specimens are lar gibbons in
##   the collection records -- Disco is ZILLES-HYLOBATES-GPZ-5542
##   (de Sousa et al., 2010, Table 1; MacLeod, 2000, Appendix I) and
##   YN81 is the Hylobates lar of Stacho et al. (2024, Table 2,
##   "YN81-146") and of the de Sousa/MacLeod specimen records.
## - Orangutan -> Pongo pygmaeus: YN85, Briggs and Harry are the
##   Pongo pygmaeus of the same collection records (Stacho et al.,
##   2024, Table 2: "YN 85-38", "5_97" = Briggs, "2_97" = Harry).
## - Gorilla -> Gorilla gorilla (YN82; Stacho et al., 2024, "YN82-140").
## The species label is printed only on the first row of each group;
## the build fills it down (asserted against the printed anchors in
## the snapshot script).
##
## Printed forms kept verbatim in the snapshot and recorded here:
## - the young bonobo is printed "Zahlie" (the Zahlia of the /97
##   cohort elsewhere);
## - YN81's age is printed "Ad" (adult): the analysis CSV leaves Age
##   empty for that row and says why in its Note column.
## Text cross-checks asserted below: the human ages span 21-75 years
## and the two bonobos are 2 and 11, as the paper's Subjects text
## states. (The same text gives the ape age range as "16.5-37 years",
## which matches no reading of this table -- the ape ages printed are
## 2-37 -- a text slip that does not touch the table; see README.)
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Semendeferi_etal_2011_Table1.R"
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
stopifnot(nrow(snap) == 19L)

## Fill the group label down (printed only on each group's first row).
grp <- snap$Species
for (i in seq_along(grp)) if (!nzchar(grp[i])) grp[i] <- grp[i - 1L]
stopifnot(identical(grp, c(rep("Human", 8), rep("Bonobo", 2),
                           rep("Chimpanzee", 3), "Gorilla",
                           rep("Orangutan", 3), rep("Gibbon", 2))))

binomial <- c("Human" = "Homo sapiens", "Bonobo" = "Pan paniscus",
              "Chimpanzee" = "Pan troglodytes", "Gorilla" = "Gorilla gorilla",
              "Orangutan" = "Pongo pygmaeus", "Gibbon" = "Hylobates lar")
age <- suppressWarnings(as.numeric(snap$`Age (years)`))
stopifnot(all(is.na(age) == (snap$`Age (years)` == "Ad")))
bw <- as.numeric(snap$`Brain weight (g)`)
stopifnot(!any(is.na(bw)), all(bw > 0))
## Text cross-checks (Subjects): human ages 21-75; bonobos aged 2 and 11.
stopifnot(min(age[grp == "Human"]) == 21, max(age[grp == "Human"]) == 75,
          identical(age[grp == "Bonobo"], c(2, 11)))

note <- character(19)
note[snap$Specimen == "YN81"] <- "Age printed as 'Ad' (adult)"
note[snap$Specimen == "Zahlie"] <-
  "Printed 'Zahlie'; the bonobo Zahlia of the /97 cohort in de Sousa et al. (2010)"

final.dataframe <- data.frame(
  Species = unname(binomial[grp]),
  `Group (printed)` = grp,
  Specimen = snap$Specimen,
  Sex = snap$Sex,
  `Age, years` = age,
  `Brain weight, g` = bw,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 19L,
          identical(final.dataframe$`Brain weight, g`[final.dataframe$Specimen == "Disco"], 120))

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
