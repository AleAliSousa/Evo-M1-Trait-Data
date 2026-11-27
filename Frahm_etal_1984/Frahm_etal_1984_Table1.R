## Frahm, Stephan & Baron (1984), Table 1: source-layout snapshot -> analysis CSV.
## The printed ASW column precedes ASG; sorting and renaming happen here.
options(scipen = 999)
if (!requireNamespace("readxl", quietly = TRUE)) stop("Package 'readxl' required")
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(.sp)
item <- tools::file_path_sans_ext(basename(.sp))
raw <- as.data.frame(readxl::read_excel(file.path(folder, paste0(item, "_snapshot.xlsx")),
                                       sheet = "Table1", col_names = FALSE, col_types = "text"),
                     stringsAsFactors = FALSE)
raw[is.na(raw)] <- ""
stopifnot(ncol(raw) == 7L, nrow(raw) == 54L,
          grepl("^Table 1\\. Volumes of area striata", raw[1, 1]),
          identical(as.character(raw[3, ]), c("", "n", "ASV", "ASW", "ASG", "ASG 1", "ASG 2–6")),
          sum(raw[[1]] %in% c("Scandentia", "Primates", "Prosimians", "Simians")) == 4L)
is_data <- grepl("^[0-9]+$", raw[[2]]) & grepl("^[0-9,]+$", raw[[3]])
body <- raw[is_data, , drop = FALSE]
stopifnot(nrow(body) == 44L)
lookup <- read.csv(file.path(folder, "reference_tables", paste0(item, "_species_lookup.csv")),
                   stringsAsFactors = FALSE)
stopifnot(identical(body[[1]], lookup$printed_species),
          setequal(lookup$previous_analysis_order, seq_len(44L)))
num <- function(x) {
  x[x %in% c("", "—", "-")] <- NA_character_
  as.numeric(gsub(",", "", x, fixed = TRUE))
}
clean <- data.frame(
  Species = lookup$analysis_species,
  n = as.integer(num(body[[2]])),
  Area_striata_mm3 = num(body[[3]]),
  Area_striata_grey_matter_mm3 = num(body[[5]]),
  Area_striata_lamina_1_mm3 = num(body[[6]]),
  Area_striata_laminae_2_6_mm3 = num(body[[7]]),
  Area_striata_white_matter_mm3 = num(body[[4]]),
  source = sub("_Table[^_]*$", "", item),
  stringsAsFactors = FALSE
)
foot <- read.csv(file.path(folder, "reference_tables", paste0(item, "_footnotes.csv")),
                 stringsAsFactors = FALSE)
clean$former_name_stephan1981 <- foot$former_name_stephan1981[
  match(clean$Species, foot$species_in_table)]
clean <- clean[order(lookup$previous_analysis_order), , drop = FALSE]
rownames(clean) <- NULL
write.csv(clean, file.path(folder, paste0(item, ".csv")), row.names = FALSE)

base <- dirname(folder)
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  encoded <- codes$`Item encoded`[match(item, codes$`Item name`)]
  if (!is.na(encoded) && nzchar(encoded))
    write.table(clean, file.path(base, "__Public", "comparative-data", paste0(encoded, ".tsv")),
                sep = "\t", row.names = FALSE)
}
