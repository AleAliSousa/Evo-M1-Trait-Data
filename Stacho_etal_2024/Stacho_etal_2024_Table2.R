## ============================================================================
## Stacho_etal_2024_Table2.R
##
## Build script for Stacho_etal_2024_Table2 -- reads ONLY this item's
## frozen snapshot (Stacho_etal_2024_Table2_snapshot.csv) and writes
## the analysis CSV (Stacho_etal_2024_Table2.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Table 2 ("Overview of postmortem non-human primate brains") of
## Stacho et al. (2024), Frontiers in Neuroanatomy 18:1331305, lists
## the 25 non-human primate brains of the study (the paper's text:
## "25 non-human brains" from the C. & O. Vogt Institute collection):
## taxon (family/group, as printed), species, archive name, sex,
## section plane and staining. The table carries no measurements;
## the item is registered because the specimen crosswalk cites it --
## it is the only published list that places the archive label "3_97"
## (Hylobates lar) in the Vogt collection's /97 cohort alongside the
## named 1_97, 2_97, 4_97 and 5_97 specimens, which is the evidence
## that "3_97" is the gibbon Disco (ZILLES-HYLOBATES-GPZ-5542).
##
## The build renames the printed "Name" column "Specimen" and keeps
## every value verbatim, including the numeric archive names with
## their printed thousands separators ("1,548") and the sex code
## "NA" printed for four specimens (kept as the string "NA" -- it is
## the paper's code for not available, not a missing cell).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Stacho_etal_2024_Table2.R"
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
stopifnot(nrow(snap) == 25L)
## "NA" is a printed sex code in this table, not a missing value:
snap$Sex[is.na(snap$Sex)] <- "NA"
stopifnot(all(nzchar(as.matrix(snap))),
          identical(as.integer(table(snap$Taxon)), c(4L, 11L, 3L, 7L)),
          identical(snap$Name[snap$Species == "Hylobates lar"],
                    c("YN81-146", "3_97")))

final.dataframe <- data.frame(
  Taxon = snap$Taxon,
  Species = snap$Species,
  Specimen = snap$Name,
  Sex = snap$Sex,
  `Section plane` = snap$`Section plane`,
  Staining = snap$Staining,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 25L)

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
