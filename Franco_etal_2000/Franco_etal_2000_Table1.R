.sp <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
folder <- dirname(.sp); base <- dirname(folder); item_name <- tools::file_path_sans_ext(basename(.sp))
library(readxl)
registry <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1", col_types = "text")
item_encoded <- registry$`Item encoded`[match(item_name, registry$`Item name`)]
stopifnot(length(item_encoded) == 1L, !is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
raw <- read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")), skip = 3,
                  col_names = FALSE, col_types = "text", .name_repair = "minimal")
stopifnot(ncol(raw) >= 7L)
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x), fixed = TRUE)))
species <- ""; animal <- ""; sex <- ""; mass <- NA_real_; rows <- list()
for (i in seq_len(nrow(raw))) {
  v <- as.character(unlist(raw[i, 1:7], use.names = FALSE))
  v[is.na(v)] <- ""
  if (nzchar(v[1]) && !nzchar(v[4])) { species <- trimws(v[1]); animal <- ""; sex <- ""; mass <- NA_real_; next }
  if (!nzchar(v[4])) next
  if (nzchar(trimws(v[1]))) animal <- trimws(v[1])
  if (nzchar(trimws(v[2]))) sex <- trimws(v[2])
  if (!is.na(num(v[3]))) mass <- num(v[3])
  rows[[length(rows) + 1L]] <- data.frame(species_as_published = species, animal_id = animal,
    sex = sex, body_mass_g = mass, eye_side = trimws(v[4]), retinal_area_mm2 = num(v[5]),
    nasotemporal_extent_mm = num(v[6]), peak_cone_density_cells_mm2 = num(v[7]) * 1000,
    source_row = i + 3L, data_role = "primary", stringsAsFactors = FALSE)
}
final.dataframe <- do.call(rbind, rows)
stopifnot(nrow(final.dataframe) == 19L, length(unique(final.dataframe$species_as_published)) == 5L,
          all(final.dataframe$eye_side %in% c("L", "R")))
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", quote = TRUE, qmethod = "double", fileEncoding = "UTF-8")
desc <- c("Species name as printed", "Individual identifier; carried down for second eye",
          "Sex as printed; carried down for second eye", "Body mass in g; carried down for second eye",
          "Left or right eye", "Retinal area in mm2", "Nasotemporal extent in mm",
          "Peak cone density in cells/mm2; printed units x 1000", "One-based worksheet row", "Study's primary measurements")
defs <- data.frame(Code = names(final.dataframe), Definition = desc, Structure = "", Measure = "",
                   Stat = "", role = c("info", "info", "info", "both", "info", "primary", "primary", "primary", "info", "info"),
                   taxon = "Primates", Reference = item_name, Note = "", `Source Note` = "Franco et al. 2000 Table 1 p.278",
                   check.names = FALSE)
dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
write.csv(defs, file.path(folder, "reference_tables", paste0(item_name, "_definitions.csv")), row.names = FALSE, na = "")
writeLines(c(paste0("# ", item_name), "", "Frozen source: `Franco_etal_2000_Table1_snapshot.xlsx`, a copy of the existing Table 1 transcription.",
             "Source: Franco et al. (2000), Brain, Behavior and Evolution 56:276-286, doi:10.1159/000047211, Table 1 p.278.",
             "The snapshot's 19 eye rows match the PDF text layer. Five species headings are carried down; paired-eye identifiers are carried down.",
             "Printed cone density is in thousands of cells/mm2; the analysis value multiplies by 1000.",
             "Full human side-by-side visual check remains pending."), file.path(folder, paste0(item_name, ".README.md")))
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns")
