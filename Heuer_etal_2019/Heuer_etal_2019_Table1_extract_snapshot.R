# Heuer_etal_2019_Table1_extract_snapshot.R -----------------------------------------------------
# Build Heuer_etal_2019_Table1_snapshot.xlsx - a hand-verified capture of the printed Table 1.
# R port of Heuer_etal_2019_Table1_make_snapshot.py (openpyxl -> openxlsx); the transcribed
# values, printed row order and printed grade rows are carried over unchanged.
#
# Heuer, K., et al. (2019). Evolution of neocortical folding: A phylogenetic
# comparative analysis of MRI from 34 primate species. Cortex 118:275-291.
#
# Table 1 ("List of species included") is printed on p. 3. It is a PRINTED source,
# so a snapshot is required (__HOWTO_build_a_dataset_file.md sec 0a invariant 1).
# The PDF's text layer has lost all intra-cell spaces ("Daubentoniamadagascariensis"),
# so an automatic parse would have to re-insert word breaks by guesswork. The values
# below are therefore TRANSCRIBED BY HAND from the rendered page, keeping the printed
# grade rows, printed row order, and the multi-valued cells exactly as printed
# (e.g. "No,Yes,Yes" / "BC,PL,PDE" for the pooled macaque rows).
#
# Checks that the transcription satisfies (asserted below, so a typo cannot pass
# silently):
#   * 34 species rows - the paper's "34 primate species"
#   * N sums to 65     - the paper's "65 individuals"

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
OUT <- file.path(paper_dir, "Heuer_etal_2019_Table1_snapshot.xlsx")

suppressPackageStartupMessages(library(openxlsx))

# Caption transcribed verbatim, including the paper's own "Nationale" (the p. 1
# affiliation says "National") and its U+2019 apostrophe. Do not correct either -
# fidelity beats tidiness.
CAPTION <- "Table 1 - List of species included. ABIDE1: Autism Brain Imaging Data Exchange 1. BC: Brain Catalogue. MNHN: Muséum Nationale d’Histoire Naturelle de Paris. NCBR: National Chimpanzee Brain Resource. PL: Pruszynski Lab. PDE: PRIMate Data Exchange (PRIME-DE)."
HEADER  <- c("Name", "Binomial Name (GenBank)", "N", "In vivo", "Extracted", "Provenance")

# Printed row order. A row with only a Name is a printed GRADE row; empty fields
# are printed blanks.
txt <- "Lemuriformes|||||
Aye-aye|Daubentonia madagascariensis|1|No|No|MNHN
Black-and-white ruffed lemur|Varecia variegata variegata|1|No|No|MNHN
Coquerel's mouse lemur|Mirza coquereli|1|No|No|MNHN
Grey mouse lemur|Microcebus murinus|1|No|No|MNHN
Mongoose lemur|Eulemur mongoz|1|No|No|MNHN
Red-tailed sportive lemur|Lepilemur ruficaudatus|1|No|No|MNHN
Ring-tailed lemur|Lemur catta|1|No|Yes|MNHN
Loridae|||||
Red slender loris|Loris tardigradus|1|No|Yes|MNHN
Galagonidae|||||
Demidoff's galago|Galago demidoff|1|No|No|MNHN
Cebidae|||||
Black-pencilled marmoset|Callithrix penicillata|1|No|Yes|MNHN
Cotton-top tamarin|Saguinus oedipus|1|No|Yes|MNHN
Douroucouli|Aotus trivirgatus|1|No|No|MNHN
Squirrel monkey|Saimiri sciureus|2|No|Yes|MNHN
Tufted capuchin|Cebus apella|1|No|No|MNHN
White-faced sapajou|Cebus capucinus|1|No|Yes|MNHN
Atelidae|||||
Black spider monkey|Ateles paniscus|2|No|No|MNHN
Woolly monkey|Lagothrix lagotricha|1|No|Yes|MNHN
Cercopithecini|||||
Green monkey|Chlorocebus sabaeus|1|No|Yes|MNHN
Moustached guenon|Cercopithecus cephus cephus|1|No|Yes|MNHN
Papionini|||||
Crab-eating macaque|Macaca fascicularis|8|No,Yes,Yes|Yes,No,No|BC,PL,PDE
Grey-cheeked mangabey|Lophocebus albigena|1|No|Yes|MNHN
Hamadryas baboon|Papio hamadryas|1|No|Yes|MNHN
Rhesus monkey|Macaca mulatta|6|No,Yes,Yes|Yes,No,No|MNHN,PL,PDE
Sooty mangabey|Cercocebus atys|1|No|Yes|MNHN
Colobinae|||||
Hanuman langur|Semnopithecus entellus|1|No|Yes|MNHN
Indochinese lutung|Trachypithecus germaini|1|No|No|MNHN
King colobus|Colobus polykomos|1|No|Yes|MNHN
Hominoidea|||||
Bonobo|Pan paniscus|1|Yes|No|NCBR
Chimpanzee|Pan troglodytes troglodytes|9|Yes|No|NCBR
Gibbon|Hylobates lar|1|Yes|No|NCBR
Gorilla|Gorilla beringei|1|No|Yes|BC
Gorilla|Gorilla gorilla|1|Yes|No|NCBR
Human|Homo sapiens|10|Yes|No|ABIDE1
Orangutan|Pongo pygmaeus|1|No|No|MNHN"

rows <- read.delim(text = txt, sep = "|", header = FALSE, quote = "",
                   colClasses = "character", na.strings = "",
                   check.names = FALSE, stringsAsFactors = FALSE)
names(rows) <- HEADER
rows$N <- suppressWarnings(as.integer(rows$N))

is_grade <- is.na(rows[["Binomial Name (GenBank)"]])
stopifnot(sum(!is_grade) == 34L)                       # the paper's 34 primate species
stopifnot(sum(rows$N, na.rm = TRUE) == 65L)            # the paper's 65 individuals
stopifnot(ncol(rows) == 6L)

sheet <- rbind(
  setNames(data.frame(CAPTION, NA, NA, NA, NA, NA, stringsAsFactors = FALSE), HEADER),
  setNames(as.data.frame(as.list(HEADER), stringsAsFactors = FALSE), HEADER),
  transform(rows, N = as.character(N))
)

wb <- createWorkbook()
addWorksheet(wb, "Table1")
writeData(wb, "Table1", sheet, colNames = FALSE, keepNA = FALSE)
for (i in which(!is.na(rows$N))) {                     # N is written as a number, as in the .py
  writeData(wb, "Table1", rows$N[i], startRow = i + 2L, startCol = 3L, colNames = FALSE)
}
saveWorkbook(wb, OUT, overwrite = TRUE)

message(sprintf("%s: %d species rows, N = %d individuals",
                basename(OUT), sum(!is_grade), sum(rows$N, na.rm = TRUE)))
