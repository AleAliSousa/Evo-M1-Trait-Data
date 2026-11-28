# Pontzer et al. 2014, supporting Table S1 (PDF page 7).
# Read the frozen table capture, preserve printed labels and population rows,
# convert body mass kg to the project g unit, and parse the printed ranges.
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(a) != 1L) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a)))
item_name <- sub("\\.R$", "", basename(sub("^--file=", "", a)))
root <- dirname(folder)
snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     skip = 2, colClasses = "character", check.names = FALSE,
                     na.strings = character(0), fileEncoding = "UTF-8")
names(snapshot) <- c("Species", "Population", "N", "Mean age, y", "Body mass Mean, kg",
                     "Body mass SD", "Body mass Range", "TEE Mean, kcal/d", "TEE SD",
                     "TEE Range", "Notes")
stopifnot(nrow(snapshot) == 19L)

# Resolve abbreviated names through this paper's rows in the General key.
# The source spelling remains in species_as_published, including its typos.
key <- read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                colClasses = "character", check.names = FALSE,
                na.strings = character(0), fileEncoding = "UTF-8")
key <- key[key$source_publication == basename(folder), ]
hit <- match(snapshot$Species, key$variant_name)
if (anyNA(hit) || anyDuplicated(key$variant_name))
  stop("Pontzer taxon key is missing or duplicates a source label")

number <- function(x) {
  x[x %in% c("", "—")] <- NA_character_
  suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
}
range_end <- function(x, which) {
  x[x %in% c("", "—")] <- NA_character_
  pieces <- strsplit(x, "–", fixed = TRUE)
  vapply(pieces, function(p) {
    if (length(p) == 1L && is.na(p)) return(NA_real_)
    if (length(p) != 2L) stop("Unexpected printed range: ", paste(p, collapse = ""))
    number(p[which])
  }, numeric(1))
}
age <- snapshot[["Mean age, y"]]
age[age %in% c("Adult", "—", "")] <- NA_character_
final.dataframe <- data.frame(
  source_order = seq_len(nrow(snapshot)),
  species_as_published = snapshot$Species,
  Species = key$accepted_name[hit],
  population_as_published = snapshot$Population,
  n_individuals = as.integer(number(snapshot$N)),
  mean_age_as_published = snapshot[["Mean age, y"]],
  mean_age_y = number(age),
  body_mass_mean_g = number(snapshot[["Body mass Mean, kg"]]) * 1000,
  body_mass_sd_g = number(snapshot[["Body mass SD"]]) * 1000,
  body_mass_range_as_published = snapshot[["Body mass Range"]],
  body_mass_min_g = range_end(snapshot[["Body mass Range"]], 1L) * 1000,
  body_mass_max_g = range_end(snapshot[["Body mass Range"]], 2L) * 1000,
  tee_mean_kcal_d = number(snapshot[["TEE Mean, kcal/d"]]),
  tee_sd_kcal_d = number(snapshot[["TEE SD"]]),
  tee_range_as_published = snapshot[["TEE Range"]],
  tee_min_kcal_d = range_end(snapshot[["TEE Range"]], 1L),
  tee_max_kcal_d = range_end(snapshot[["TEE Range"]], 2L),
  notes_as_published = snapshot$Notes,
  stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(!anyNA(final.dataframe$n_individuals),
          !anyNA(final.dataframe$body_mass_mean_g),
          !anyNA(final.dataframe$tee_mean_kcal_d),
          all(final.dataframe$body_mass_min_g <= final.dataframe$body_mass_mean_g |
                is.na(final.dataframe$body_mass_min_g)),
          all(final.dataframe$body_mass_mean_g <= final.dataframe$body_mass_max_g |
                is.na(final.dataframe$body_mass_max_g)),
          all(final.dataframe$tee_min_kcal_d <= final.dataframe$tee_mean_kcal_d |
                is.na(final.dataframe$tee_min_kcal_d)),
          all(final.dataframe$tee_mean_kcal_d <= final.dataframe$tee_max_kcal_d |
                is.na(final.dataframe$tee_max_kcal_d)))

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"),
                               sheet = "Sheet1", col_types = "text")
row <- which(registry[["Item name"]] == item_name)
if (length(row) != 1L) stop("Expected one registered item row for ", item_name)
item_encoded <- registry[["Item encoded"]][row]
if (is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded))
  stop("Invalid registered Item encoded for ", item_name)
write.table(final.dataframe,
            file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", quote = TRUE,
            fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows; public TSV ",
    item_encoded, ".tsv\n", sep = "")
