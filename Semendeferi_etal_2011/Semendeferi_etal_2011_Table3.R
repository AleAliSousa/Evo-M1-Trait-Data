## ============================================================================
## Semendeferi_etal_2011_Table3.R
##
## Build script for Semendeferi_etal_2011_Table3 -- reads ONLY this
## item's frozen snapshot (Semendeferi_etal_2011_Table3_snapshot.csv)
## and writes the analysis CSV (Semendeferi_etal_2011_Table3.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 3 of Semendeferi et al. (2011), Cerebral Cortex 21(7):
## species means of the gray level ratio (GLR, dimensionless) in
## layer III of BA 10, BA 4, BA 3 and BA 17, each printed as
## "mean (SD)" over the images of the individual specimens of the
## paper's Table 1. The build splits each printed cell into a mean
## column and an SD column and resolves the printed group names to
## binomials (see the Table 1 build for the resolution evidence;
## "Gibbon" is Hylobates lar). Per-specimen GLR values are not
## printed anywhere in the paper (figures only).
##
## Capture checks asserted below, from the paper's Results text: the
## human BA 10 mean (0.18) is the lowest value in the table; the
## human BA 17 mean is 0.29; the ape BA 3 range runs 0.28 (gorilla)
## to 0.33 (bonobo). One text slip the checks document rather than
## absorb: the text describes the ape BA 17 range as running "from
## 0.31 in the chimpanzee specimens to 0.39 for the gibbons", but in
## this table 0.31 is the BONOBO mean (chimpanzee is 0.35); the
## asserted range below uses the table's own values (0.31-0.39).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Semendeferi_etal_2011_Table3.R"
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
stopifnot(nrow(snap) == 6L,
          identical(snap$Species, c("Human", "Bonobo", "Chimpanzee", "Gorilla",
                                    "Orangutan", "Gibbon")))
parse_ms <- function(x) {
  m <- regmatches(x, regexec("^([0-9.]+) \\(([0-9.]+)\\)$", x))
  vapply(m, function(p) {
    if (length(p) != 3L) stop("Unparseable printed mean (SD): ", x)
    as.numeric(p[2])
  }, numeric(1))
}
parse_sd <- function(x) {
  m <- regmatches(x, regexec("^([0-9.]+) \\(([0-9.]+)\\)$", x))
  vapply(m, function(p) {
    if (length(p) != 3L) stop("Unparseable printed mean (SD): ", x)
    as.numeric(p[3])
  }, numeric(1))
}
areas <- c("BA 10", "BA 4", "BA 3", "BA 17")
means <- lapply(areas, function(a) parse_ms(snap[[paste0(a, " (SD)")]]))
sds   <- lapply(areas, function(a) parse_sd(snap[[paste0(a, " (SD)")]]))
names(means) <- names(sds) <- areas
## Results-text cross-checks (see header for the BA 17 attribution slip):
stopifnot(identical(means[["BA 10"]][1], 0.18),
          identical(min(unlist(means)), 0.18),
          identical(means[["BA 17"]][1], 0.29),
          identical(range(means[["BA 3"]][-1]), c(0.28, 0.33)),
          identical(range(means[["BA 17"]][-1]), c(0.31, 0.39)),
          identical(means[["BA 17"]][2], 0.31),   # bonobo, not chimpanzee
          identical(means[["BA 17"]][3], 0.35))   # chimpanzee

binomial <- c("Human" = "Homo sapiens", "Bonobo" = "Pan paniscus",
              "Chimpanzee" = "Pan troglodytes", "Gorilla" = "Gorilla gorilla",
              "Orangutan" = "Pongo pygmaeus", "Gibbon" = "Hylobates lar")
final.dataframe <- data.frame(
  Species = unname(binomial[snap$Species]),
  `Group (printed)` = snap$Species,
  `BA 10 GLR` = means[["BA 10"]], `BA 10 GLR SD` = sds[["BA 10"]],
  `BA 4 GLR`  = means[["BA 4"]],  `BA 4 GLR SD`  = sds[["BA 4"]],
  `BA 3 GLR`  = means[["BA 3"]],  `BA 3 GLR SD`  = sds[["BA 3"]],
  `BA 17 GLR` = means[["BA 17"]], `BA 17 GLR SD` = sds[["BA 17"]],
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 6L)

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
