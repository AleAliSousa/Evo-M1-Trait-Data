## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "Sarko_etal_2009_Table2.R"
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

sections <- c("TOTAL CORTEX", "TOTAL HIPPOCAMPUS", "TOTAL OLFACTORY BULBS",
              "CEREBELLUM", "REMAINING AREAS")
group <- NA_character_
dat <- list()
for (i in seq_len(nrow(snap))) {
  label <- snap[[1]][i]
  if (label %in% sections) group <- label
  else { dat[[length(dat) + 1L]] <- c(group, unlist(snap[i, ], use.names = FALSE)) }
}
dat <- as.data.frame(do.call(rbind, dat), stringsAsFactors = FALSE)
stopifnot(nrow(dat) == 25L, ncol(dat) == 15L)
names(dat) <- c("Section", names(snap))
pm <- function(x) {
  p <- strsplit(x, "±", fixed = TRUE)[[1]]
  if (length(p) != 2L) stop("Expected printed plus/minus: ", x)
  num(trimws(p))
}
final.dataframe <- data.frame(
 Species = resolve_species(dat$Species), species_as_published = dat$Species,
 Structure_as_published = dat$Section, n = as.integer(dat$n),
 check.names = FALSE, stringsAsFactors = FALSE)
code <- c("Mass.g", "PctBrainMass", "Cells.n", "Cells.p.mg",
          "PctBrainCells", "PctNeuronalCells", "N.n", "N.p.mg",
          "PctBrainNeurons", "O.n", "O.p.mg", "PctBrainOtherCells")
for (j in seq_along(code)) {
  z <- t(vapply(dat[[j + 3L]], pm, numeric(2)))
  factor <- if (code[j] %in% c("Cells.n", "N.n", "O.n")) 1e6 else
            if (code[j] %in% c("Cells.p.mg", "N.p.mg", "O.p.mg")) 1e3 else 1
  final.dataframe[[code[j]]] <- z[,1] * factor
  final.dataframe[[paste0(code[j], "_plusminus_reported")]] <- z[,2] * factor
}

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
