## Per-specimen stereological sampling, age and sex in printed Table 2.
me <- "Charvet_etal_2017_Table2.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character",
                        na.strings = NULL)
stopifnot(nrow(snap) == 23L, ncol(snap) == 9L)
pair <- strsplit(gsub(",", "", snap[[3]], fixed = TRUE), "/", fixed = TRUE)
stopifnot(all(lengths(pair) == 2L))
num <- function(x) as.numeric(gsub(",", "", x, fixed = TRUE))
upper_sample <- vapply(pair, function(x) num(x[1]), numeric(1))
lower_sample <- vapply(pair, function(x) num(x[2]), numeric(1))
genus <- sub(" .*", "", snap$Species)
order <- ifelse(genus %in% c("Dasyprocta", "Mus", "Rattus"), "Rodentia",
  ifelse(genus %in% c("Ailurus", "Felis"), "Carnivora",
  ifelse(genus == "Hippopotamus", "Artiodactyla", "Primata")))
final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  common_name_as_published = snap[[1]],
  Species_as_published = snap[[2]],
  Species = snap[[2]],
  Order = order,
  upper_layer_neurons_counted_in_sample = upper_sample,
  lower_layer_neurons_counted_in_sample = lower_sample,
  brain_weight_g = num(snap[[4]]),
  age_as_published = snap[[5]],
  sex_as_published = snap[[6]],
  sections_sampled = num(snap[[7]]),
  section_thickness_um = num(snap[[8]]),
  optical_disector_um = num(snap[[9]]),
  data_role = "primary specimen and sampling metadata",
  stringsAsFactors = FALSE)
stopifnot(all(final.dataframe$upper_layer_neurons_counted_in_sample > 0),
          all(final.dataframe$lower_layer_neurons_counted_in_sample > 0))
## Sampled-neuron counts are not estimates of total cortical neurons.
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
cat(item_name, ": ", nrow(final.dataframe), " specimen rows\n", sep = "")
