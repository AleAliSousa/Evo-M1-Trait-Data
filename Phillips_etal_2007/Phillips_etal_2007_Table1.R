## ============================================================================
## Phillips_etal_2007_Table1.R
##
## Build script for Phillips_etal_2007_Table1 -- reads ONLY this
## item's frozen snapshot (Phillips_etal_2007_Table1_snapshot.csv)
## and writes the analysis CSV (Phillips_etal_2007_Table1.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 1 of Phillips, Sherwood & Lilak (2007), PLoS ONE 2(8):e792,
## gives per-individual UNADJUSTED midsagittal areas (mm2) of the
## corpus callosum (CC) and its 7 subdivisions, total CC area, brain
## volume (cc) and body weight (kg) for 18 Hiram College capuchins:
## the 13 named animals of Phillips_Sherwood_2007_Table1 plus Sabro
## (M), Shiro (M) and the coded M21-02 (M), M57-04 (F), M58-04 (F).
## The brain volumes are per-individual (specimen-level) values for
## the same animals as the other Phillips items, not an independent
## species sample.
##
## Build decisions, documented in the README:
## - Species: the paper prints "Cebus apella"; the build resolves to
##   Sapajus apella and keeps the printed form in a column.
## - The printed Total CC Area does NOT equal the sum of the 7
##   printed subdivision areas (e.g. Alou: subdivisions sum to
##   59.50 mm2, printed total 62.50 mm2) -- the total was evidently
##   traced as its own outline. Both are carried exactly as printed;
##   nothing is recomputed or "corrected". (Table 2's adjusted
##   Overall CC is consistent with the printed totals, which the
##   round verification confirms.)
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Phillips_etal_2007_Table1.R"
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
subs <- c("Rostrum", "Genu", "Rostral body", "Anterior midbody",
          "Posterior midbody", "Isthmus", "Splenium")
areas <- lapply(snap[, subs], num)
total <- num(snap$`Total CC Area(mm2)`)
bv <- num(snap$`Brain Volume(cc)`); bw <- num(snap$`Body Weight (kg)`)
stopifnot(!any(is.na(total)), !any(is.na(bv)),
          identical(total[1], 62.50), identical(bv[2], 98.81))
## The printed totals are NOT subdivision sums (documented above):
sub_sum <- Reduce(`+`, areas)
stopifnot(abs(sub_sum[1] - 59.50) < 1e-9, abs(total[1] - sub_sum[1]) > 1)

new5 <- c("Sabro", "Shiro", "M21-02", "M57-04", "M58-04")
note <- ifelse(snap$Subject %in% new5,
               "First appears in this paper; not in Phillips_Sherwood_2007_Table1",
               "")

final.dataframe <- data.frame(
  Species = "Sapajus apella",
  `Species (printed)` = "Cebus apella",
  Subject = snap$Subject,
  Sex = snap$Sex,
  `Rostrum, mm2` = areas$Rostrum,
  `Genu, mm2` = areas$Genu,
  `Rostral body, mm2` = areas[["Rostral body"]],
  `Anterior midbody, mm2` = areas[["Anterior midbody"]],
  `Posterior midbody, mm2` = areas[["Posterior midbody"]],
  `Isthmus, mm2` = areas$Isthmus,
  `Splenium, mm2` = areas$Splenium,
  `Total CC area, mm2` = total,
  `Brain volume, cc` = bv,
  `Body weight, kg` = bw,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 18L,
          sum(final.dataframe$Sex == "M") == 10L,
          sum(final.dataframe$Sex == "F") == 8L)

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
