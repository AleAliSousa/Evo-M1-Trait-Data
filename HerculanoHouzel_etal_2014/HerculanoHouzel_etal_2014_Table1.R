## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "HerculanoHouzel_etal_2014_Table1.R"
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
optional_num <- function(x) ifelse(x == "–", NA_real_, num(replace(x, x == "–", NA_character_)))
species_key <- utils::read.csv(file.path(root, "_keys", "HerculanoHouzel", "species_key.csv"),
                               stringsAsFactors = FALSE)
species_key <- species_key[species_key$source_publication == "HerculanoHouzel_etal_2014", ]
resolve_species <- function(x) {
  val <- species_key$accepted_name[match(x, species_key$variant_name)]
  if (anyNA(val)) stop("Unresolved species: ", paste(x[is.na(val)], collapse = "; "))
  val
}

dat <- snap[seq_len(14L), , drop = FALSE]
stopifnot(dat[[1]][1] == "Whole brain", dat[[1]][14] == "Olfactory bulb")
count <- function(x) {
  if (is.na(x) || x == "–") return(NA_real_)
  suffix <- sub(".* ([BM])$", "\\1", x)
  if (!(suffix %in% c("B", "M"))) stop("Unexpected count: ", x)
  num(sub(" [BM]$", "", x)) * if (suffix == "B") 1e9 else 1e6
}
source_species <- "Loxodonta africana" # stated in paper Methods, not in table
final.dataframe <- data.frame(
  Species = resolve_species(source_species), species_as_published = source_species,
  n = 1L, Structure_as_published = dat[[1]],
  Mass.g = num(dat[[2]]), N.n = vapply(dat[[3]], count, numeric(1)),
  O.n = vapply(dat[[4]], count, numeric(1)),
  N.p.mg = optional_num(dat[[5]]),
  O.p.mg = optional_num(dat[[6]]),
  O.p.N = optional_num(dat[[7]]),
  hemisphere_basis = "2 times one half-brain",
  source_value_flag = ifelse(dat[[1]] == "Rest of brain",
    "O/N printed 36,948; retained literally pending source erratum review", ""),
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
