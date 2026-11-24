## Upper- and lower-layer isocortical neuron estimates in 25 mammalian species.
me <- "Charvet_etal_2017_Table1.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 25L,
          identical(names(snap), c("Common name", "Species",
            "Upper-layer neuron numbers x 10^6", "Lower-layer neuron numbers x 10^6")))
num <- function(x) suppressWarnings(as.numeric(gsub(",", "", x, fixed = TRUE)))
upper <- num(snap[[3]]) * 1e6
lower <- num(snap[[4]]) * 1e6
stopifnot(!anyNA(upper), !anyNA(lower), all(upper > 0), all(lower > 0))
genus <- sub(" .*", "", snap$Species)
order <- ifelse(genus %in% c("Agouti", "Dasyprocta", "Mesocricetus", "Mus", "Rattus"), "Rodentia",
  ifelse(genus %in% c("Ailurus", "Felis"), "Carnivora",
  ifelse(genus == "Hippopotamus", "Artiodactyla",
  ifelse(genus == "Trichechus", "Sirenia", "Primata"))))
stopifnot(identical(sort(unique(order)), sort(c("Rodentia","Carnivora","Artiodactyla","Sirenia","Primata"))))
final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  common_name_as_published = snap[[1]],
  Species_as_published = snap[[2]],
  Species = snap[[2]],
  Order = order,
  upper_layer_II_IV_neurons_unilateral = upper,
  lower_layer_V_VI_neurons_unilateral = lower,
  source_measure_unit = "neurons; original values in millions",
  data_role = "mixed primary and previously published species means",
  stringsAsFactors = FALSE)
## Table 1 combines 23 newly measured individuals with previously
## published species values, but does not tag provenance per row. It is
## not eligible for an unqualified primary merge until Fig. 1 and source
## papers are reconciled. The paper states unilateral isocortical counts.
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
cat(item_name, ": ", nrow(final.dataframe), " species rows\n", sep = "")
