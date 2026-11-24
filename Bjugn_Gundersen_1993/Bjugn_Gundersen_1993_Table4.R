## Reader for frozen printed Table 4; source values are not hardcoded here.
me <- "Bjugn_Gundersen_1993_Table4.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character", na.strings = NULL)
number <- function(x) suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
stopifnot(nrow(snap) == 2L, ncol(snap) == 5L)
final.dataframe <- data.frame(
 source_row=seq_len(nrow(snap)), stain_as_published=snap[[1]],
 Species="Rattus norvegicus", Order="Rodentia", animal_id="2",
 all_cells_million=number(snap[[2]]), glial_million=number(snap[[3]]),
 endothelial_million=number(snap[[4]]), neurons_million=number(snap[[5]]),
 observation_level="same animal, alternate stains",
 data_role="primary method comparison; not independent specimens",
 stringsAsFactors=FALSE)
stopifnot(all(abs(final.dataframe$all_cells_million -
  (final.dataframe$glial_million+final.dataframe$endothelial_million+
   final.dataframe$neurons_million))<0.001))
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
