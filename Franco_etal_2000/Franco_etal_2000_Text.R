.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
library(readxl)
registry <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text")
item_encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
snapshot <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
a <- as.data.frame(read_excel(snapshot, sheet = "Sheet1", col_types = "text"), check.names = FALSE)
b <- as.data.frame(read_excel(snapshot, sheet = "Other_text_data", col_types = "text"), check.names = FALSE)
stopifnot(nrow(a) == 14L, nrow(b) == 8L)
original_headers <- unique(c(names(a), names(b)))
sanitize <- function(x) { names(x) <- make.unique(make.names(names(x))); x }
a <- sanitize(a); b <- sanitize(b)
a$source_sheet <- "Sheet1"; b$source_sheet <- "Other_text_data"
a$source_row <- seq_len(nrow(a)) + 1L; b$source_row <- seq_len(nrow(b)) + 1L
cols <- union(names(a), names(b))
for (nm in setdiff(cols, names(a))) a[[nm]] <- NA_character_
for (nm in setdiff(cols, names(b))) b[[nm]] <- NA_character_
final.dataframe <- rbind(a[cols], b[cols])
final.dataframe$taxon_as_published <- ifelse(final.dataframe$source_sheet == "Sheet1",
                                             final.dataframe$Taxon, final.dataframe$Taxon...scope)
final.dataframe$data_role <- ifelse(grepl("^Franco et al", final.dataframe$Data.reference), "primary", "secondary")
stopifnot(nrow(final.dataframe) == 22L, !anyNA(final.dataframe$data_role))
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", quote = TRUE, qmethod = "double", fileEncoding = "UTF-8")
desc <- names(final.dataframe)
desc[match(make.unique(make.names(original_headers)), names(final.dataframe), nomatch = 0L)] <- original_headers
desc[names(final.dataframe) == "taxon_as_published"] <- "Taxon or scope exactly as entered in the source workbook"
desc[names(final.dataframe) == "data_role"] <- "Primary when the cited source is Franco et al. (2000); otherwise secondary"
defs <- data.frame(Code = names(final.dataframe), Definition = desc, Structure = "", Measure = "", Stat = "",
                   role = "info", taxon = "Primates", Reference = item_name, Note = "",
                   `Source Note` = "Franco et al. 2000 Results and Discussion text; constructed extraction workbook",
                   check.names = FALSE)
dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
write.csv(defs, file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")), row.names = FALSE, na = "")
writeLines(c(paste0("# ", item_name), "", "Frozen source: `Franco_etal_2000_Text_snapshot.xlsx`, copied from the existing constructed prose-extraction workbook.",
             "Source: Franco et al. (2000), Brain, Behavior and Evolution 56:276-286, doi:10.1159/000047211.",
             "The item combines 14 species-summary rows and 8 other prose-measurement rows; the workbook's individual Table 1 rows are handled by the separate Table1 item.",
             "Primary and quoted secondary rows are identified separately. Source wording and per-row citations are retained.",
             "Full human side-by-side visual check of the prose extraction remains pending."),
           file.path(folder, paste0(item_name, ".README.md")))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
