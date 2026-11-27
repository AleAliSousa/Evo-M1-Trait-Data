## Kamiya & Pirlot (1988), Malayan bear, printed Table 1 (p. 231).
## Frozen source table -> analysis CSV + registry-named public TSV.
args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(args)) stop("Run with Rscript <script>.R", call. = FALSE)
script <- normalizePath(sub("^--file=", "", args[1]))
folder <- dirname(script)
base <- dirname(folder)
item <- sub("\\.R$", "", basename(script))
snapshot <- file.path(folder, paste0(item, "_snapshot.csv"))
raw <- read.csv(snapshot, colClasses = "character", check.names = FALSE,
                na.strings = character(), stringsAsFactors = FALSE)
stopifnot(identical(names(raw), c("component", "Helarctos", "Ailuropoda", "Ursus")),
          identical(raw$component, c("BO", "N", "RH", "S", "D", "ST", "H", "M", "C", "O")))
for (name in c("Helarctos", "Ailuropoda", "Ursus")) {
  stopifnot(all(grepl("^[0-9]+$", raw[[name]])))
  raw[[name]] <- as.integer(raw[[name]])
}
out <- data.frame(raw, source = item, check.names = FALSE)
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
hits <- which(!is.na(reg$`Item name`) & reg$`Item name` == item)
stopifnot(length(hits) == 1L)
code <- reg$`Item encoded`[hits]
stopifnot(!is.na(code), nzchar(code), !grepl("_$", code))
write.csv(out, file.path(folder, paste0(item, ".csv")), row.names = FALSE, na = "")
write.table(out, file.path(base, "__Public", "comparative-data", paste0(code, ".tsv")),
            sep = "\t", row.names = FALSE, na = "")
