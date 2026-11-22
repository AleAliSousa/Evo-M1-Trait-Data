## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "Sarko_etal_2009_Table1.R"
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
num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
species_key <- utils::read.csv(file.path(root, "_keys", "HerculanoHouzel", "species_key.csv"),
                               stringsAsFactors = FALSE)
species_key <- species_key[species_key$source_publication == "Sarko_etal_2009", ]
resolve_species <- function(x) {
  val <- species_key$accepted_name[match(x, species_key$variant_name)]
  if (anyNA(val)) stop("Unresolved species: ", paste(x[is.na(val)], collapse = "; "))
  val
}

dat <- snap[seq_len(5L), , drop = FALSE]
stopifnot(dat[[1]][1] == "Smoky shrew", dat[[1]][5] == "Eastern mole")
pm <- function(x) {
  p <- strsplit(x, "±", fixed = TRUE)[[1]]
  if (length(p) != 2L) stop("Expected printed plus/minus: ", x)
  num(trimws(p))
}
m <- lapply(dat[-1], function(col) t(vapply(col, pm, numeric(2))))
final.dataframe <- data.frame(
 Species = resolve_species(dat[[1]]), species_as_published = dat[[1]],
 Body_Mass.g = m[[1]][,1], Body_Mass.g_plusminus_reported = m[[1]][,2],
 WholeBrain_Mass.g = m[[2]][,1], WholeBrain_Mass.g_plusminus_reported = m[[2]][,2],
 WholeBrain_Cells.n = m[[3]][,1] * 1e6,
 WholeBrain_Cells.n_plusminus_reported = m[[3]][,2] * 1e6,
 WholeBrain_N.n = m[[4]][,1] * 1e6,
 WholeBrain_N.n_plusminus_reported = m[[4]][,2] * 1e6,
 check.names = FALSE, stringsAsFactors = FALSE)

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
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns\n", sep = "")
