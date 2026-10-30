.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
library(readxl)
registry <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text")
item_encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
final.dataframe <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                            colClasses = "character", check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(nrow(final.dataframe) == 147L, !anyNA(final.dataframe$citation_verbatim))
final.dataframe$source_item <- item_name
final.dataframe$data_role <- "bibliography"
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", quote = TRUE, qmethod = "double", fileEncoding = "UTF-8")
defs <- data.frame(Code = names(final.dataframe),
                   Definition = c("Paragraph ordinal in the author DOCX", "Full reference as printed in the author DOCX",
                                  "Registered source item", "Bibliography only, no measured values"),
                   Structure = "", Measure = "", Stat = "", role = "info", taxon = "Mammalia",
                   Reference = item_name, Note = "", `Source Note` = "Martin et al. 2017 Supporting Information S1",
                   check.names = FALSE)
dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
write.csv(defs, file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")), row.names = FALSE, na = "")
writeLines(c(paste0("# ", item_name), "", "Frozen source: `evo13128-sup-0001-suppmat.docx`, supplied author bibliography.",
             "The separate extract script reads the DOCX paragraphs into a frozen CSV without changing the DOCX.",
             "This item contains 147 bibliography entries and no species measurements. It should not enter a trait merge.",
             "Source: Martin, Tucker & Rogers 2017, Evolution, doi:10.1111/evo.13128, Supporting Information S1."),
           file.path(folder, paste0(item_name, ".README.md")))
message(item_name, ": ", nrow(final.dataframe), " bibliography rows")
