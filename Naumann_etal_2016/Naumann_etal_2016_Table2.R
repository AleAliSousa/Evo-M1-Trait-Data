## Analysis reader: only the frozen item snapshot supplies values.
me <- "Naumann_etal_2016_Table2.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character", na.strings = NULL)
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE)
key <- key[key$source_publication == "Naumann_etal_2016", ]
match_species <- function(x) {
 idx <- match(x, key$variant_name)
 if (anyNA(idx)) stop("Unresolved species label in snapshot")
 key$accepted_name[idx]
}
order_for <- function(x) {
 out <- c("Shrew"="Eulipotyphla", "Mouse"="Rodentia", "Rat"="Rodentia",
          "Egyptian fruit bat"="Chiroptera", "Human"="Primata")[x]
 if (anyNA(out)) stop("Unresolved order")
 unname(out)
}
stopifnot(nrow(snap) == 5L, ncol(snap) == 3L)
parts <- regmatches(snap[[2]], regexec("^([0-9]+) from ([0-9]+) brains$", snap[[2]]))
stopifnot(all(lengths(parts) == 3L))
pm <- strsplit(snap[[3]], " ± ", fixed = TRUE)
stopifnot(all(lengths(pm) == 2L))
final.dataframe <- data.frame(
 source_row = seq_len(nrow(snap)), species_as_published = snap[[1]],
 Species = match_species(snap[[1]]), Order = order_for(snap[[1]]),
 patches_counted = as.integer(vapply(parts, `[`, character(1), 2)),
 brains_counted = as.integer(vapply(parts, `[`, character(1), 3)),
 calbindin_positive_neurons_per_patch = as.numeric(vapply(pm, `[`, character(1), 1)),
 neurons_per_patch_plusminus_as_published = as.numeric(vapply(pm, `[`, character(1), 2)),
 plusminus_type = "not specified in Table 2",
 observation_level = "species summary", data_role = "primary",
 stringsAsFactors = FALSE)
stopifnot(!anyNA(final.dataframe$calbindin_positive_neurons_per_patch))
options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMeAddON.xlsx"), sheet = "Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one AddON registry row")
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (!nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
utils::write.table(final.dataframe,
  file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
  sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows\n", sep = "")
