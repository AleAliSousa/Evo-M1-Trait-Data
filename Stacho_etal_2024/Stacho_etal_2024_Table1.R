## ============================================================================
## Stacho_etal_2024_Table1.R
##
## Build script for Stacho_etal_2024_Table1 -- reads ONLY this item's
## frozen snapshot (Stacho_etal_2024_Table1_snapshot.csv) and writes
## the analysis CSV (Stacho_etal_2024_Table1.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Table 1 ("Overview of postmortem human brains") of Stacho et al.
## (2024), Frontiers in Neuroanatomy 18:1331305, lists the 11
## postmortem human brains of the study: specimen ID, section type,
## sex (printed heading "Gender"), age (years) and fresh brain
## weight (g). The build strips the printed thousands separators
## from the weights and renames the ID column "Specimen".
##
## pm20 carries the table's footnote marker (kept in the snapshot as
## "pm20*"): "*High-resolution brain model BigBrain (Amunts et al.,
## 2013)". The build strips the marker and records the footnote in
## the row's Note. Table 3's human means use n = 10, so one of these
## 11 brains is excluded there -- most plausibly pm20, the model
## brain; the paper does not say, and the build does not decide it.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Stacho_etal_2024_Table1.R"
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
stopifnot(nrow(snap) == 11L)
bw <- as.numeric(gsub(",", "", snap$`Fresh brain weight (g)`, fixed = TRUE))
age <- as.numeric(snap$Age)
stopifnot(!any(is.na(bw)), !any(is.na(age)), all(bw > 800 & bw < 1800))

note <- character(11)
note[snap$ID == "pm20*"] <-
  "Footnote in the paper: 'High-resolution brain model BigBrain (Amunts et al., 2013)'"

final.dataframe <- data.frame(
  Specimen = sub("\\*$", "", snap$ID),
  `Section type` = snap$`Section type`,
  Sex = snap$Gender,
  `Age, years` = age,
  `Fresh brain weight, g` = bw,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 11L,
          identical(final.dataframe$Specimen[11], "pm20"))

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
