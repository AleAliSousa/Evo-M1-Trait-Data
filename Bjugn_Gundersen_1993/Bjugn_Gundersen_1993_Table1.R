## Reader for frozen printed Table 1; source values are not hardcoded here.
me <- "Bjugn_Gundersen_1993_Table1.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character", na.strings = NULL)
number <- function(x) suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
stopifnot(nrow(snap) == 8L, ncol(snap) == 5L)
measured <- snap[1:5,,drop=FALSE]
mean_row <- snap[6,,drop=FALSE]
for (j in 2:5)
 stopifnot(abs(mean(number(measured[[j]])) - number(mean_row[[j]])) <= 0.05)
final.dataframe <- data.frame(
 source_row=seq_len(nrow(snap)), animal_as_published=snap[[1]],
 Species="Rattus norvegicus", Order="Rodentia",
 animal_weight_g=number(snap[[2]]), spinal_cord_length_mm=number(snap[[3]]),
 white_matter_volume_mm3=number(snap[[4]]), gray_matter_volume_mm3=number(snap[[5]]),
 statistic=ifelse(snap[[1]] %in% c("Mean","SD","CV"),snap[[1]],"individual"),
 data_role=ifelse(snap[[1]] %in% c("Mean","SD","CV"),"source summary","primary individual"),
 stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe) == 8L)
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
