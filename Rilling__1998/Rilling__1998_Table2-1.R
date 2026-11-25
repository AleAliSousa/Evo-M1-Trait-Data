# Rilling 1998 dissertation, Table 2-1: one row per scanned subject.
# Read only this item's frozen transcription; source labels and dates are retained.
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(script_arg) != 1L) stop("Run with Rscript")
script_path <- normalizePath(sub("^--file=", "", script_arg))
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character",
                        na.strings = NULL, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 44L,
          identical(names(snap), c("Subject", "Species", "Sex", "Scan Date",
                                   "DOB", "Age (yrs)", "Body Weight (kg)")),
          !anyDuplicated(snap$Subject),
          sum(snap$Sex == "M") == 27L, sum(snap$Sex == "F") == 17L)

# Scientific labels are listed in the dissertation's Subjects paragraph (printed p. 32).
species_names <- c(human = "Homo sapiens", bonobo = "Pan paniscus",
                   chimp = "Pan troglodytes", orangutan = "Pongo pygmaeus",
                   gorilla = "Gorilla gorilla", gibbon = "Hylobates lar",
                   baboon = "Papio cynocephalus", capuchin = "Cebus apella",
                   rhesus = "Macaca mulatta", mangabey = "Cercocebus atys",
                   squirrel = "Saimiri sciureus")
if (!all(snap$Species %in% names(species_names))) stop("Unmapped source species")
body_kg <- as.numeric(sub("^([0-9]+(?:\\.[0-9]+)?).*", "\\1",
                          snap[["Body Weight (kg)"]], perl = TRUE))
if (anyNA(body_kg)) stop("Unparsed source body weight")

final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  subject_as_published = snap$Subject,
  species_as_published = snap$Species,
  Species = unname(species_names[snap$Species]),
  sex = snap$Sex,
  scan_date_as_published = snap[["Scan Date"]],
  dob_as_published = snap$DOB,
  age_years = as.numeric(snap[["Age (yrs)"]]),
  body_weight_text_as_published = snap[["Body Weight (kg)"]],
  body_mass_g = body_kg * 1000,  # published kg -> project g
  observation_level = "individual in vivo MRI subject",
  data_role = "primary",
  stringsAsFactors = FALSE)
stopifnot(!anyNA(final.dataframe$age_years))
options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# The owner's master registry may be open; the AddON row is used until pasted.
registry_paths <- file.path(root, c("__ReadMe.xlsx", "__ReadMeAddON.xlsx"))
matches <- lapply(registry_paths, function(path) {
  tab <- readxl::read_excel(path, sheet = "Sheet1")
  tab[tab[["Item name"]] == item_name, , drop = FALSE]
})
matches <- matches[vapply(matches, nrow, integer(1)) == 1L]
if (length(matches) != 1L) stop("Expected one master/AddON registry row")
item_encoded <- as.character(matches[[1]][["Item encoded"]][1])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_"))
  stop("Invalid Item encoded")
utils::write.table(final.dataframe,
  file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
  sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " subjects\n", sep = "")
