## Analysis reader: only the frozen item snapshot supplies values.
me <- "Naumann_etal_2016_Table6.R"
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
stopifnot(nrow(snap) == 5L, ncol(snap) == 4L)
metrics <- c("grid score", "elliptical grid score", "Cartesian score")
res <- list(); n <- 0L
for (i in seq_len(nrow(snap))) for (j in 2:4) {
 raw <- gsub("−", "-", snap[[j]][i], fixed = TRUE)
 vals <- as.numeric(strsplit(raw, " ± ", fixed = TRUE)[[1]])
 stopifnot(length(vals) == 2L, !anyNA(vals))
 n <- n + 1L
 res[[n]] <- data.frame(source_row=i, species_as_published=snap[[1]][i],
   Species=match_species(snap[[1]][i]), Order=order_for(snap[[1]][i]),
   score_type=metrics[j-1L], mean_score=vals[1], SD=vals[2],
   observation_level="species x score type", data_role="primary")
}
final.dataframe <- do.call(rbind, res)
stopifnot(nrow(final.dataframe) == 15L)
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
