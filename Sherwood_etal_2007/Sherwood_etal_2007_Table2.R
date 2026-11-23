## ============================================================================
## Sherwood_etal_2007_Table2.R
##
## Build script for Sherwood_etal_2007_Table2 -- reads this item's
## frozen snapshot (Sherwood_etal_2007_Table2_snapshot.csv) and, as a
## documented exception to the one-snapshot rule, the sibling
## Sherwood_etal_2007_Table1_snapshot.csv from the same folder,
## because this table is the group-statistics summary OF Table 1:
## the build recomputes every mean and SD from Table 1's values and
## checks them against the printed statistics before writing the
## analysis CSV (Sherwood_etal_2007_Table2.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Table 2 of Sherwood et al. (2007), Journal of Comparative
## Neurology 503(4):525-537: mean AQ, SD, one-sample t and P for HI
## and the 11 neuroanatomical asymmetry quotients, n = 18. It adds
## no new observations; it is registered and built following the
## workbook's precedent for group-statistics tables (cf.
## Semendeferi_etal_2011 Tables 2-3) and because the recomputation
## check validates Table 1's capture.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Sherwood_etal_2007_Table2.R"
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
stopifnot(nrow(snap) == 12L)
num <- function(x) as.numeric(gsub("−", "-", x, fixed = TRUE))
mean_aq <- num(snap$`Mean AQ`); sd_aq <- num(snap$SD)
t_val <- num(snap$t); p_val <- num(snap$P)

## Recomputation check against the sibling Table 1 snapshot.
t1 <- utils::read.csv(file.path(folder, "Sherwood_etal_2007_Table1_snapshot.csv"),
                      check.names = FALSE, colClasses = "character")
map <- c("Coordinated bimanual HI" = "HI",
         "Hand knob" = "Hand Knob",
         "Neuron density in layer II/III" = "Neuron Density in Layer II/III",
         "Glia density in layer II/III" = "Glia Density in Layer II/III",
         "AF in layer II/III" = "AF in Layer II/III",
         "AF in layer V/VI" = "AF in Layer V/VI",
         "Relative thickness of layer I" = "Relative Thickness of Layer I",
         "Relative thickness of layer II/III" = "Relative Thickness of Layer II/III",
         "Relative thickness of layer V/VI" = "Relative Thickness of Layer V/VI",
         "PV-ir interneuron density in layer II/III" = "PV-ir Interneuron Density in Layer II/III",
         "PV-ir interneuron mean cell volume in layer II/III" = "PV-ir Interneuron Mean Cell Volume in Layer II/III",
         "NPNFP-ir mean cell volume in layer II/III" = "NPNFP-ir Mean Cell Volume in Layer II/III")
stopifnot(identical(snap$Variable, names(map)))
dev <- 0
for (i in seq_len(12)) {
  v <- num(t1[[map[i]]])
  dev <- max(dev, abs(mean(v) - mean_aq[i]), abs(sd(v) - sd_aq[i]))
}
cat("Recomputation vs Table 1: max |mean/SD deviation| = ", dev, "\n", sep = "")
stopifnot(dev <= 0.015)

final.dataframe <- data.frame(
  Species = "Pan troglodytes",
  Variable = snap$Variable,
  `Mean AQ` = mean_aq,
  SD = sd_aq,
  t = t_val,
  P = p_val,
  Note = "",
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 12L)

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
