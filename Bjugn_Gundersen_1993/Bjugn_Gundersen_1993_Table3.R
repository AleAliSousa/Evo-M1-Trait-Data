## Reader for frozen printed Table 3; source values are not hardcoded here.
me <- "Bjugn_Gundersen_1993_Table3.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character", na.strings = NULL)
number <- function(x) suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
stopifnot(nrow(snap) == 13L, ncol(snap) == 8L)
parse_column <- function(x) {
 y <- sub("^.*= *", "", x)
 y[y == "—"] <- NA_character_
 number(y)
}
final.dataframe <- data.frame(
 source_row=seq_len(nrow(snap)), bit=snap[[1]],
 Species="Rattus norvegicus", Order="Rodentia", animal_id="2",
 Q_neurons_counted=parse_column(snap[[2]]),
 F_fields=parse_column(snap[[3]]), P_points=parse_column(snap[[4]]),
 X_estimate=parse_column(snap[[5]]), A_product=parse_column(snap[[6]]),
 B_product=parse_column(snap[[7]]), C_product=parse_column(snap[[8]]),
 data_role=ifelse(snap[[1]]=="Σ","source summary","stereological method"),
 stringsAsFactors=FALSE)
for (col in c("Q_neurons_counted","F_fields","P_points","A_product","B_product","C_product"))
 stopifnot(sum(final.dataframe[[col]][1:12],na.rm=TRUE)==final.dataframe[[col]][13])
stopifnot(round(sum(final.dataframe$X_estimate[1:12]),0)==final.dataframe$X_estimate[13])
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
