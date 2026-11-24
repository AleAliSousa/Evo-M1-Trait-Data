## SI Table 2: cortical, cerebellar and remaining-area cellular composition.
## The snapshot is frozen separately from the local publisher HTML supplement.
me <- "HerculanoHouzel_etal_2007_SITable2.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run this script with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        header = FALSE, check.names = FALSE,
                        colClasses = "character", na.strings = NULL)
stopifnot(identical(dim(snap), c(27L, 11L)))
sections <- c("Cortex", "Cerebellum", "Remaining areas")
stopifnot(identical(snap[c(1, 10, 19), 1], sections))
rows <- do.call(rbind, lapply(seq_along(sections), function(i) {
  first <- c(3L, 12L, 21L)[i]
  d <- snap[first:(first + 6L), , drop = FALSE]
  d$structure_as_published <- sections[i]
  d
}))
stopifnot(nrow(rows) == 21L)

parse_published <- function(x) {
  x <- trimws(x)
  parts <- strsplit(x, " x 10^", fixed = TRUE)[[1]]
  scale <- if (length(parts) == 2L) 10^as.numeric(parts[2]) else 1
  if (length(parts) > 2L || is.na(scale)) stop("Unparsed scale: ", x)
  value <- strsplit(parts[1], "\uFFFD", fixed = TRUE)[[1]]
  if (length(value) == 1L) value <- strsplit(parts[1], "±", fixed = TRUE)[[1]]
  if (length(value) > 2L) stop("Unparsed value: ", x)
  mean <- suppressWarnings(as.numeric(trimws(value[1])))
  sd <- if (length(value) == 2L) suppressWarnings(as.numeric(trimws(value[2]))) else NA_real_
  if (is.na(mean) || (length(value) == 2L && is.na(sd))) stop("Unparsed value: ", x)
  c(mean * scale, sd * scale)
}
metric <- function(j) t(vapply(rows[[j]], parse_published, numeric(2)))
measures <- lapply(3:11, metric)
names(measures) <- c("mass_g", "brain_mass_pct", "neuronal_fraction_pct",
                     "neurons", "neuron_density_per_mg", "brain_neurons_pct",
                     "other_cells", "other_cell_density_per_mg", "brain_other_cells_pct")
species_as_published <- rows[[1]]
species <- species_as_published
species[species == "Otolemur garnetti"] <- "Otolemur garnettii"
species[species == "Cebus apella"] <- "Sapajus apella"
stopifnot(length(unique(species)) == 7L)

## The HTML source prints x10^9 for two Macaca non-neuron cells.
## Table 1 whole-brain non-neurons (7,162.90 x10^6) and the other SI
## structures place both in the x10^6 range; retain the raw cells in the
## frozen snapshot and make this explicit exponent correction downstream.
erratum <- species_as_published == "Macaca mulatta" &
  rows$structure_as_published %in% c("Cerebellum", "Remaining areas")
stopifnot(sum(erratum) == 2L,
          all(grepl("x 10^9", rows[[9]][erratum], fixed = TRUE)))
measures$other_cells[erratum, ] <- measures$other_cells[erratum, ] / 1000

final.dataframe <- data.frame(
  source_row = rep(1:7, 3),
  Species_as_published = species_as_published,
  Species = species,
  Order = ifelse(species_as_published == "Tupaia glis", "Scandentia", "Primata"),
  structure_as_published = rows$structure_as_published,
  Number = as.integer(rows[[2]]),
  stringsAsFactors = FALSE)
for (name in names(measures)) {
  final.dataframe[[name]] <- measures[[name]][, 1]
  final.dataframe[[paste0(name, "_SD")]] <- measures[[name]][, 2]
}
final.dataframe$source_exponent_note <- ifelse(erratum,
  "HTML prints x10^9 for this non-neuron cell; analysis corrects to x10^6", "")
final.dataframe$data_role <- "primary species-group summary"
stopifnot(all(final.dataframe$Number > 0),
          all(final.dataframe$neurons > 0),
          all(final.dataframe$other_cells > 0))
options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMeAddON.xlsx"), sheet = "Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected exactly one AddON row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (!nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
public <- file.path(root, "__Public", "comparative-data")
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                   sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " structure-species rows\n", sep = "")
