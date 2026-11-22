## ============================================================================
## HerculanoHouzel_etal_2006_Table1.R
##
## Build script for HerculanoHouzel_etal_2006_Table1 -- reads ONLY this
## item's frozen snapshot (HerculanoHouzel_etal_2006_Table1_snapshot.csv)
## and writes the analysis CSV (HerculanoHouzel_etal_2006_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 of Herculano-Houzel, Mota & Lent (2006), PNAS 103(32):
## whole-brain totals for six rodent species -- body mass, brain mass,
## total cells and total neurons, printed as mean +/- SD (the table's own
## footnote: "Values are mean +/- SD"), counts in millions. The printed
## "Variation" summary row stays in the snapshot and is dropped here.
## The agouti total-neurons value is printed without an SD in both the
## publisher PDF and the PMC rendering; its SD cell is left empty (NA),
## never invented.
##
## Species: the printed vernacular names are mapped to the binomials the
## paper itself prints in its Methods (Animals), with three spellings
## corrected to the accepted names used by Herculano-Houzel et al. (2015)
## and the HerculanoHouzel species key: the paper prints "Mesocrycetus
## auratus" [sic], "Dasyprocta primnolopha" [sic] and "Hydrochoerus
## hydrochoeris" [sic]; the accepted names are Mesocricetus auratus,
## Dasyprocta prymnolopha and Hydrochoerus hydrochaeris. "Number" is the
## number of individuals per species, from the same Methods paragraph
## (guinea pigs: "Two young adult ... guinea pigs").
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "HerculanoHouzel_etal_2006_Table1.R"
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
stopifnot(nrow(snap) == 7L, snap[[1]][7] == "Variation")
dat <- snap[seq_len(6L), , drop = FALSE]

## ---- species map: printed vernacular -> binomial used in the paper text -----
species_map <- data.frame(
  vernacular = c("Mouse", "Hamster", "Rat", "Guinea pig", "Agouti", "Capybara"),
  binomial   = c("Mus musculus", "Mesocricetus auratus", "Rattus norvegicus",
                 "Cavia porcellus", "Dasyprocta prymnolopha",
                 "Hydrochoerus hydrochaeris"),
  number     = c(4L, 2L, 4L, 2L, 3L, 2L),
  stringsAsFactors = FALSE)
if (!identical(dat[[1]], species_map$vernacular))
  stop("Snapshot species rows do not match the expected printed order.")

num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
pm <- function(x) {
  p <- strsplit(x, "±", fixed = TRUE)[[1]]
  if (length(p) == 1L) return(c(num(trimws(p)), NA_real_))   # printed without SD
  if (length(p) != 2L) stop("Expected printed plus/minus: ", x)
  num(trimws(p))
}
m <- lapply(dat[-1], function(col) t(vapply(col, pm, numeric(2))))

final.dataframe <- data.frame(
  Species = species_map$binomial,
  Order = "Rodentia",
  `Common name` = species_map$vernacular,
  Number = species_map$number,
  `Body mass, g` = m[[1]][, 1], `Body mass, g SD` = m[[1]][, 2],
  `Brain mass, g` = m[[2]][, 1], `Brain mass, g SD` = m[[2]][, 2],
  `Whole brain Cells` = m[[3]][, 1] * 1e6, `Whole brain Cells SD` = m[[3]][, 2] * 1e6,
  `Whole brain Neurons` = m[[4]][, 1] * 1e6, `Whole brain Neurons SD` = m[[4]][, 2] * 1e6,
  check.names = FALSE, stringsAsFactors = FALSE)

## House checks: neurons can never exceed total cells; masses positive.
stopifnot(all(final.dataframe[["Whole brain Neurons"]] <=
              final.dataframe[["Whole brain Cells"]]),
          all(final.dataframe[["Body mass, g"]] > 0),
          all(final.dataframe[["Brain mass, g"]] > 0))

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
