## ============================================================================
## HerculanoHouzel_etal_2007_Table1.R
##
## Build script for HerculanoHouzel_etal_2007_Table1 -- reads ONLY this
## item's frozen snapshot (HerculanoHouzel_etal_2007_Table1_snapshot.csv)
## and writes the analysis CSV (HerculanoHouzel_etal_2007_Table1.csv)
## and the DOI-coded public TSV named by the registry row's
## "Item encoded".
##
## Table 1 of Herculano-Houzel, Collins, Wong & Kaas (2007),
## Proceedings of the National Academy of Sciences 104(9):3562-3567:
## "Comparative cellular composition of the brain of the tree shrew
## and six primate species". For the tree shrew and six primates it
## prints body mass and brain mass in g and the total numbers of
## neurons and of non-neuronal ("other") cells in the whole brain
## (printed x10^6), as mean +/- SD (the table's footnote: "Values are
## mean ± SD. n.a., not available."). The printed "Variation,
## macaque/marmoset" row is a summary, not a species: it stays in the
## snapshot, is used here as a capture check (the four ratios must
## recompute from the parsed species means), and does not enter the
## analysis CSV or the TSV.
##
## Species names: Table 1 prints vernacular names only. The binomials
## used here are the ones the paper's Methods (Animals paragraph)
## attach to the same animals, in the same breath as their sample
## sizes: Tupaia glis (n = 2), Callithrix jacchus (n = 3), Otolemur
## garnettii (n = 3), Aotus trivirgatus (n = 2), Saimiri sciureus
## (n = 2), Cebus apella (n = 1) and the rhesus monkey Macaca mulatta
## (n = 2). The Fig. 1 caption instead labels the macaque "Macaca
## fascicularis"; the Methods govern -- the animals were rhesus from
## the Vanderbilt colony -- and Herculano-Houzel et al. (2015) Table 5
## carries this row, identically valued, as Macaca mulatta. The
## capuchin is carried as Sapajus apella, the accepted name
## Herculano-Houzel et al. (2015) and the species key use for the
## same row (the HH 2006 build precedent: accepted names as in
## Herculano-Houzel et al. (2015) and the key); the name as printed,
## Cebus apella, is recorded in the README and definitions. Without
## this, the merge's resolver treats Cebus apella as a separate
## species and the 2007 totals would sit beside, not over, the 2015
## re-reports.
##
## The Saimiri non-neuron cell: Table 1 prints 2,075.03 x10^6, in the
## PMC full text and in the publisher PDF alike. Herculano-Houzel et
## al. (2015) Table 5 prints 2,073.03 x10^6 for the same quantity --
## a one-digit difference in the 2015 re-report, not in this paper.
## The build takes this paper's printed value; no guard is needed
## here (the merge's precedence pin lets the primary's value stand).
##
## What Table 1 does and does not print:
## - No total-cell count: neurons and non-neurons only. The merge
##   derives whole-brain total cells downstream, as it does for the
##   2015 tables.
## - SDs are printed only where the table prints them: body and
##   brain mass SDs for the first three species (brain mass also
##   without SD from the owl monkey on), neuron and non-neuron SDs
##   for the marmoset and galago only. Every other SD cell is left
##   empty; no value is invented or imported from the text.
## - Squirrel monkey body mass is "n.a." (not available) and stays
##   empty; Herculano-Houzel et al. (2015) Table 5's 859 g for this
##   species is not this table's value and is not imported.
## - The structure-level values (cerebral cortex, cerebellum,
##   remaining structures) behind the paper's scaling analyses are
##   NOT in Table 1; they are in the online supporting information
##   (SI Table 2), which is not part of this item.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "HerculanoHouzel_etal_2007_Table1.R"
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
                        check.names = FALSE, colClasses = "character")
stopifnot(nrow(snap) == 8L)   # 7 species rows + the Variation summary row
stopifnot(identical(names(snap),
                    c("Species", "Body mass, g", "Brain mass, g",
                      "Total neurons, \u00d710^6", "Total nonneurons, \u00d710^6")))

var_row <- snap[snap$Species == "Variation, macaque/marmoset", ]
dat <- snap[snap$Species != "Variation, macaque/marmoset", ]
row.names(dat) <- NULL
stopifnot(nrow(var_row) == 1L, nrow(dat) == 7L)

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x),
                                                    fixed = TRUE)))
## "mean ± SD" cells -> mean / SD (SD NA where only a mean is printed;
## "n.a." -> both NA)
mean_of <- function(x) num(sub("\\s*\u00b1.*$", "", x))
sd_of   <- function(x) ifelse(grepl("\u00b1", x),
                              num(sub("^.*\u00b1\\s*", "", x)), NA_real_)

body_mean  <- mean_of(dat[[2]]); body_sd  <- sd_of(dat[[2]])
brain_mean <- mean_of(dat[[3]]); brain_sd <- sd_of(dat[[3]])
nn_mean    <- mean_of(dat[[4]]); nn_sd    <- sd_of(dat[[4]])
oo_mean    <- mean_of(dat[[5]]); oo_sd    <- sd_of(dat[[5]])

## Capture check: the printed Variation row (macaque / marmoset) must
## recompute from the parsed means, to the printed one decimal.
i_mar <- which(dat$Species == "Marmoset"); i_mac <- which(dat$Species == "Macaque monkey")
stopifnot(length(i_mar) == 1L, length(i_mac) == 1L)
printed_var <- num(sub("\u00d7", "", unname(unlist(var_row[1, -1]))))
recomputed  <- c(body_mean[i_mac]  / body_mean[i_mar],
                 brain_mean[i_mac] / brain_mean[i_mar],
                 nn_mean[i_mac]    / nn_mean[i_mar],
                 oo_mean[i_mac]    / oo_mean[i_mar])
stopifnot(all(round(recomputed, 1) == printed_var))

## Binomials and sample sizes from the Methods (Animals paragraph);
## orders: the tree shrew is Scandentia, the other six Primata.
binom <- c("Tree shrew"       = "Tupaia glis",
           "Marmoset"         = "Callithrix jacchus",
           "Galago"           = "Otolemur garnettii",
           "Owl monkey"       = "Aotus trivirgatus",
           "Squirrel monkey"  = "Saimiri sciureus",
           "Capuchin monkey"  = "Sapajus apella",
           "Macaque monkey"   = "Macaca mulatta")
number <- c("Tree shrew" = 2L, "Marmoset" = 3L, "Galago" = 3L,
            "Owl monkey" = 2L, "Squirrel monkey" = 2L,
            "Capuchin monkey" = 1L, "Macaque monkey" = 2L)
ord <- ifelse(dat$Species == "Tree shrew", "Scandentia", "Primata")

final.dataframe <- data.frame(
  Species = unname(binom[dat$Species]),
  Order = ord,
  `Common name` = dat$Species,
  Number = unname(number[dat$Species]),
  `Body mass, g` = body_mean, `Body mass, g SD` = body_sd,
  `Brain mass, g` = brain_mean, `Brain mass, g SD` = brain_sd,
  `Whole brain Neurons` = round(nn_mean * 1e6),
  `Whole brain Neurons SD` = round(nn_sd * 1e6),
  `Whole brain Other cells` = round(oo_mean * 1e6),
  `Whole brain Other cells SD` = round(oo_sd * 1e6),
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 7L,
          all(final.dataframe$`Whole brain Neurons` > 0),
          ## the adjudicated printed value (see header)
          final.dataframe$`Whole brain Other cells`[final.dataframe$Species ==
            "Saimiri sciureus"] == 2075030000)

## Counts reach 7.2e9, past the point where write.csv switches to
## scientific notation; the house files print counts in full.
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
