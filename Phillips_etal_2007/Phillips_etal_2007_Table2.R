## ============================================================================
## Phillips_etal_2007_Table2.R
##
## Build script for Phillips_etal_2007_Table2 -- reads ONLY this
## item's frozen snapshot (Phillips_etal_2007_Table2_snapshot.csv)
## and writes the analysis CSV (Phillips_etal_2007_Table2.csv) and
## the DOI-coded public TSV named by the registry row's "Item encoded".
##
## Table 2 of Phillips, Sherwood & Lilak (2007), PLoS ONE 2(8):e792,
## gives the ADJUSTED corpus callosum measures for the same 18
## capuchins as Table 1: each area adjusted as sqrt(area) /
## cbrt(brain volume) (unitless derived ratios), plus age, tube-task
## MHI and dextral group. The adjusted values are carried exactly as
## printed and are NOT back-converted to areas. MHI and dextral
## group are blank, as printed, for the 5 animals that were not in
## the 2007 behavioural sample (Sabro, Shiro, M21-02, M57-04,
## M58-04); the blanks are carried as missing with a Note.
##
## Assertions pin the ages and MHIs of the 13 shared animals to the
## values printed in Phillips_Sherwood_2007_Table1 (they agree), and
## the round verification recomputes every adjusted value from
## Table 1's areas and brain volumes.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Phillips_etal_2007_Table2.R"
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
age <- num(snap$Age)
adj <- lapply(snap[, c("Overall CC", "Rostrum", "Genu", "Rostral body",
                       "Anterior midbody", "Posterior midbody", "Isthmus",
                       "Splenium")], num)
mhi <- num(snap$MHI)
stopifnot(identical(age, c(2.5, 5, 1, 12, 5, 5, 1.5, 3.5, 18, 7, 21, 6, 16,
                           15, 15, 14, 13, 20)),
          identical(mhi[!is.na(mhi)],
                    c(0.81, -0.95, 0.39, 1.00, -0.14, -0.62, -1.00, 0.96,
                      -0.75, 0.60, 1.00, 0.85, -0.82)),
          sum(is.na(mhi)) == 5L,
          identical(adj[["Overall CC"]][1], 1.86))

note <- ifelse(is.na(mhi),
               "MHI and Dextral Group blank as printed (animal not in the 2007 behavioural sample)",
               "")

final.dataframe <- data.frame(
  Species = "Sapajus apella",
  `Species (printed)` = "Cebus apella",
  Subject = snap$Subject,
  Sex = snap$Sex,
  `Age, years` = age,
  `Overall CC (adjusted)` = adj[["Overall CC"]],
  `Rostrum (adjusted)` = adj$Rostrum,
  `Genu (adjusted)` = adj$Genu,
  `Rostral body (adjusted)` = adj[["Rostral body"]],
  `Anterior midbody (adjusted)` = adj[["Anterior midbody"]],
  `Posterior midbody (adjusted)` = adj[["Posterior midbody"]],
  `Isthmus (adjusted)` = adj$Isthmus,
  `Splenium (adjusted)` = adj$Splenium,
  MHI = mhi,
  `Dextral Group` = snap$`Dextral Group`,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 18L)

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
