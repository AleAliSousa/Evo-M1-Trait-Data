## ============================================================================
## Ribeiro_etal_2014_Table1.R
##
## Build script for Ribeiro_etal_2014_Table1 -- reads ONLY this item's
## frozen snapshot (Ribeiro_etal_2014_Table1_snapshot.csv) and writes the
## analysis CSV (Ribeiro_etal_2014_Table1.csv) and the DOI-coded public
## TSV named by the registry row's "Item encoded".
##
## Table 1 of Ribeiro, Manger, Catania, Kaas & Herculano-Houzel (2014),
## Frontiers in Neuroanatomy 8:23: cellular composition of the
## olfactory bulb of 23 placental mammal species, in printed clade
## blocks (Glires 9, Primates 5, Scandentia 1, Eulipotyphla 5,
## Afrotheria 3). For each species the table prints olfactory-bulb
## mass (g), number of neurons (x 10^6, converted here to absolute
## counts), % neurons and neuronal density (neurons/mg), as species
## means +/- SD. All values refer to BOTH olfactory bulbs combined
## (table footnote). The table prints no total cell numbers, no
## non-neuronal (other) cell counts and no body or brain masses, so
## the analysis CSV has none. The cerebral-cortex data the paper's
## analyses compare against are not in this table; they were taken
## from the earlier studies (Methods) and are not built here.
##
## PROVENANCE (data-point level; also in the "Olfactory bulb Source"
## column and the definitions file). Table 1 is a compilation as well
## as a primary source -- its own footnote reads: "Data from Sarko
## et al. (2009), Herculano-Houzel et al. (2011), Neves et al. (2014)
## and this study." Per the Methods and verified cell-for-cell in
## this build's audit:
##  - measured for this study (first published here): the five
##    primates, Tupaia glis, and new, larger samples of Rattus
##    norvegicus (5 animals; Herculano-Houzel et al. (2011) had 4,
##    with different values) and Sciurus carolinensis (9 animals;
##    2011 had 3, with different values);
##  - re-reported from Herculano-Houzel et al. (2011): the other
##    seven glires (Mus musculus, Mesocricetus auratus, Proechimys
##    cayennensis, Cavia porcellus, Oryctolagus cuniculus,
##    Dasyprocta primnolopha, Hydrochoerus hydrochoeris) -- mass and
##    neuron values identical to the 2011 table at printed
##    precision; the % neurons and densities printed here are
##    derived quantities consistent with the 2011 counts;
##  - re-reported from Sarko et al. (2009): the five eulipotyphlans
##    (species averages, per the Methods);
##  - re-reported from Neves et al. (2014): the three afrotherians
##    -- means identical, but every printed SD is larger than Neves
##    et al.'s by a factor of sqrt(2) (see README), and the
##    Procavia capensis bulb mass differs (0.286 g here and in
##    Herculano-Houzel et al. (2015); 0.290 g in Neves et al.,
##    whose own printed density and count imply 0.286 g).
## Nothing in Table 1 is a fitted or predicted value.
##
## "Number" is the number of ANIMALS behind each row's values, from
## the Methods (this paper's collections) or the source paper
## (compiled rows); the number of bulbs is in the definitions file.
## Two sample-size conflicts are inherent in the printed record and
## are flagged in the definitions: the agouti row's values are
## Herculano-Houzel et al. (2011)'s three-animal averages although
## this paper's Methods count two agouti (two bulbs) collected
## here; and the spiny rat row is one animal (two bulbs) although
## the 2011 build's Number counts the two bulbs.
##
## Rows without SDs are exactly the four single-animal species
## (Proechimys cayennensis, Oryctolagus cuniculus, Macaca mulatta,
## Procavia capensis), whose two bulbs (or single bulb) were pooled.
##
## PRINTED ANOMALIES handled here (kept verbatim in the snapshot):
##  - the Neurons SD term is typeset with a plus-minus glyph where a
##    multiplication sign belongs ("3.89 x 10^6 +/- 1.25 +/- 10^6")
##    in both the PDF and PMC; the parser below is guarded on that
##    exact printed pattern and reads the SD as x 10^6.
##  - name forms: the table prints "Petrodomus tetradactylus"
##    (missing r), "Dasyprocta primnolopha" and "Hydrochoerus
##    hydrochoeris"; the build uses the binomials of the source
##    builds and of Herculano-Houzel et al. (2015) -- Petrodromus
##    tetradactylus, Dasyprocta prymnolopha, Hydrochoerus
##    hydrochaeris -- and "Otolemur garnettii" for the table's
##    "Otolemur garnetti", so the species keys join. The Methods
##    further call the spiny rat Proechimys guyannensis and the
##    short-tailed shrew Blarina carolinensis; the table's names
##    (cayennensis, brevicauda, as in the source papers) govern.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Ribeiro_etal_2014_Table1.R"
script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a) && basename(sub("^--file=", "", a[1])) == me)
    return(normalizePath(sub("^--file=", "", a[1])))
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) != 1L) stop("Cannot locate script: ", me)
  normalizePath(hits)
})
folder <- dirname(script_path)
base <- tools::file_path_sans_ext(basename(script_path))
item_name <- base
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
  root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository root not found")

snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character",
                        na.strings = "")
stopifnot(nrow(snap) == 28L,
          identical(names(snap), c("Species", "Mass, g", "Neurons",
                                   "% Neurons", "Neurons/mg")))
groups <- c("GLIRES", "PRIMATES", "SCANDENTIA", "EULIPOTYPHLA", "AFROTHERIA")
is_group <- snap[[1]] %in% groups
stopifnot(identical(snap[[1]][is_group], groups))
dat <- snap[!is_group, ]
printed_species <- c(
  "Mus musculus", "Mesocricetus auratus", "Rattus norvegicus",
  "Proechimys cayennensis", "Cavia porcellus", "Sciurus carolinensis",
  "Oryctolagus cuniculus", "Dasyprocta primnolopha",
  "Hydrochoerus hydrochoeris",
  "Microcebus murinus", "Callithrix jacchus", "Otolemur garnetti",
  "Aotus trivirgatus", "Macaca mulatta",
  "Tupaia glis",
  "Sorex fumeus", "Blarina brevicauda", "Parascalops breweri",
  "Condylura cristata", "Scalopus aquaticus",
  "Petrodomus tetradactylus", "Elephantulus myurus", "Procavia capensis")
stopifnot(identical(dat[[1]], printed_species))

## ---- species metadata (printed order) ---------------------------------------
species <- c(
  "Mus musculus", "Mesocricetus auratus", "Rattus norvegicus",
  "Proechimys cayennensis", "Cavia porcellus", "Sciurus carolinensis",
  "Oryctolagus cuniculus", "Dasyprocta prymnolopha",
  "Hydrochoerus hydrochaeris",
  "Microcebus murinus", "Callithrix jacchus", "Otolemur garnettii",
  "Aotus trivirgatus", "Macaca mulatta",
  "Tupaia glis",
  "Sorex fumeus", "Blarina brevicauda", "Parascalops breweri",
  "Condylura cristata", "Scalopus aquaticus",
  "Petrodromus tetradactylus", "Elephantulus myurus", "Procavia capensis")
order <- c(rep("Rodentia", 6), "Lagomorpha", "Rodentia", "Rodentia",
           rep("Primates", 5), "Scandentia", rep("Eulipotyphla", 5),
           rep("Afrotheria", 3))
common <- c("Mouse", "Hamster", "Rat", "Spiny rat", "Guinea pig",
            "Grey squirrel", "Rabbit", "Agouti", "Capybara",
            "Mouse lemur", "Common marmoset", "Greater galago",
            "Owl monkey", "Rhesus monkey", "Common treeshrew",
            "Smoky shrew", "Northern short-tailed shrew",
            "Hairy-tailed mole", "Star-nosed mole", "Eastern mole",
            "Four-toed elephant shrew", "Eastern rock elephant shrew",
            "Rock hyrax")
number <- c(2L, 2L, 5L, 1L, 2L, 9L, 1L, 3L, 2L,      # glires (see header:
                                                    # spiny rat 1 animal,
                                                    # agouti values n = 3)
            1L, 3L, 6L, 3L, 1L,                       # primates
            10L,                                      # Tupaia glis
            3L, 5L, 3L, 4L, 3L,                       # eulipotyphlans (Sarko)
            2L, 2L, 1L)                               # afrotherians (Neves)
source <- c("Herculano-Houzel et al., 2011", "Herculano-Houzel et al., 2011",
            "This study", "Herculano-Houzel et al., 2011",
            "Herculano-Houzel et al., 2011", "This study",
            "Herculano-Houzel et al., 2011", "Herculano-Houzel et al., 2011",
            "Herculano-Houzel et al., 2011",
            rep("This study", 6),
            rep("Sarko et al., 2009", 5),
            rep("Neves et al., 2014", 3))
stopifnot(length(species) == 23L, length(order) == 23L,
          length(common) == 23L, length(number) == 23L,
          length(source) == 23L)

## ---- parsers -----------------------------------------------------------------
## Plain cells are "mean +/- SD" or a bare mean.
ms <- function(x) {
  vapply(x, function(s) {
    if (is.na(s)) return(c(NA_real_, NA_real_))
    p <- strsplit(s, " \u00b1 ", fixed = TRUE)[[1]]
    c(as.numeric(gsub(",", "", p[1])),
      if (length(p) == 2L) as.numeric(gsub(",", "", p[2])) else NA_real_)
  }, numeric(2))
}
## Neurons cells are "M x 10^6" or "M x 10^6 +/- S +/- 10^6" -- the SD
## term's multiplication sign is misprinted as +/- (see header); the
## pattern is asserted exactly before parsing.
neu <- function(x) {
  vapply(x, function(s) {
    stopifnot(grepl("^[0-9.]+ \u00d7 10\\^6( \u00b1 [0-9.]+ \u00b1 10\\^6)?$", s))
    ## The misprinted +/- inside the SD term is itself surrounded by
    ## spaces, so splitting on " +/- " yields three parts for an
    ## SD-bearing cell ("M x 10^6", "S", "10^6") and one for a bare
    ## cell. Assert that shape, then read S as x 10^6.
    p <- strsplit(s, " \u00b1 ", fixed = TRUE)[[1]]
    mean <- as.numeric(sub(" \u00d7 10\\^6$", "", p[1])) * 1e6
    sd <- if (length(p) == 3L && p[3] == "10^6")
      as.numeric(p[2]) * 1e6 else NA_real_
    c(mean, sd)
  }, numeric(2))
}
M   <- ms(dat[[2]])                             # mass, g
N   <- neu(dat[[3]])                            # neurons, absolute
PCT <- ms(dat[[4]])                             # % neurons
DN  <- ms(dat[[5]])                             # neuronal density, /mg

## NA pattern, as printed: exactly the four single-animal species lack
## SDs, in every measure.
no_sd <- c("Proechimys cayennensis", "Oryctolagus cuniculus",
           "Macaca mulatta", "Procavia capensis")
for (blk in list(M, N, PCT, DN))
  stopifnot(identical(printed_species[is.na(blk[2, ])], no_sd))

## House check on the printed means: the printed density is the mean
## of the individual densities, so it tracks N / mass only loosely;
## the loosest cell (Callithrix jacchus, whose printed mass SD
## exceeds its mean) deviates 13.5% from the ratio of the means.
## Tolerance 15% guards against gross (e.g. unit) slips only.
rec <- N[1, ] / (M[1, ] * 1000)
stopifnot(all(abs(rec - DN[1, ]) / DN[1, ] <= 0.15))

final.dataframe <- data.frame(
  Species = species,
  Order = order,
  `Common name` = common,
  Number = number,
  `Olfactory bulb Mass, g` = M[1, ],
  `Olfactory bulb Mass, g SD` = M[2, ],
  `Olfactory bulb N, n` = N[1, ],
  `Olfactory bulb N, n SD` = N[2, ],
  `Olfactory bulb % Neurons` = PCT[1, ],
  `Olfactory bulb % Neurons SD` = PCT[2, ],
  `Olfactory bulb N/mg` = DN[1, ],
  `Olfactory bulb N/mg SD` = DN[2, ],
  `Olfactory bulb Source` = source,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 23L, ncol(final.dataframe) == 13L)

options(scipen = 999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_"))
  stop("Invalid Item encoded for ", item_name)
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")),
                   sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
    " columns\n", sep = "")
