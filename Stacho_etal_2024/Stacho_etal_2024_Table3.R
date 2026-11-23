## ============================================================================
## Stacho_etal_2024_Table3.R
##
## Build script for Stacho_etal_2024_Table3 -- reads ONLY this item's
## frozen snapshot (Stacho_etal_2024_Table3_snapshot.csv) and writes
## the analysis CSV (Stacho_etal_2024_Table3.csv) and the DOI-coded
## public TSV named by the registry row's "Item encoded".
##
## Table 3 of Stacho et al. (2024), Frontiers in Neuroanatomy
## 18:1331305, prints species means over the specimens of Tables 1
## and 2: fresh brain volume (BV, cm3) and the volumes of the
## parvocellular (RNp) and magnocellular (RNm) red nucleus in each
## hemisphere (mm3), all shrinkage-corrected (table footnote), with
## the n behind each mean. Despite the caption's "five different
## groups", the rows are species (20).
##
## PRINTING ERROR -- DEMONSTRATED TRANSPOSITION, corrected in the
## guarded block below (section 3.4 pattern). As printed, the
## Gorilla gorilla row carries BV 98.8 cm3 / RNp 33.7/34.3 /
## RNm 2.6/2.0 and the Hylobates lar row BV 396.8 cm3 / RNp
## 131.1/129.3 / RNm 6.8/7.4. Both brain volumes are impossible (a
## gorilla brain is ~400 cm3; the two Hylobates specimens of
## Table 2 are the YN81 and Disco brains, 92 and 120 g). The
## within-paper checks (internal_checks/) could not prove the swap
## from the paper alone -- every text statement and figure descends
## from the same Table 3 pipeline, and each row's RNp/BV ratio
## (0.34/0.33 as printed) sits in the hominid band either way --
## but they did prove that the species names and sample sizes are
## correct as printed (Table 3's n matches Table 2's specimen
## counts for all 20 species), so any transposition exchanged ONLY
## the five measurement columns. The cross-paper check then
## demonstrated it: Table 2's specimens are YN82-140 (the gorilla;
## BV 362.9 cm3 in MacLeod et al. 2003 Table 2, de Sousa et al.
## 2010 Table 1 and Bauernfeind et al. 2013 Table 1) and YN81-146 +
## Disco (the gibbons; BV 88.8 and 115.8 cm3, mean 102.3). As
## printed, both rows are off by a factor of ~3.7-3.9 from the
## documented volumes of their own specimens; with the five
## measurement columns exchanged, both land within ordinary
## cross-method distance (gorilla 396.8 vs 362.9, +9.3%; gibbon
## 98.8 vs 102.3, -3.4%). The demonstration is committed in the
## restricted repo as __stacho2024_cross_paper_check. Michael
## approved applying the correction on 2026-11-23. The guarded
## block asserts the snapshot's two rows carry exactly the printed
## (transposed) values and fails loudly if they do not, then
## exchanges the five measurement values between the rows. The
## snapshot itself stays verbatim; Taxon, Species and Number never
## move. Both publisher renderings (Frontiers XML, PMC) print the
## same alignment and no erratum is known.
##
## Two species names are misprinted in the table ("Saimiri
## scuireus", "Daubentonia madagescariensis"); the build uses the
## correct binomials in Species and keeps the printed forms in
## "Species (printed)". "Cercopithecus Spec." is the paper's own
## indeterminate label and is kept in both columns.
##
## Checks asserted below: the per-species n of the non-human rows
## sums to the 25 specimens of Table 2; the human n is 10 (Table 1
## lists 11 human brains -- see the Table 1 build); every volume is
## positive.
## ============================================================================

## ---- self-locating header ---------------------------------------------------
me <- "Stacho_etal_2024_Table3.R"
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
stopifnot(nrow(snap) == 20L)
num <- function(x) as.numeric(x)
bv <- num(snap$`BV fresh (cm3)`); rnp_r <- num(snap$`RNp right (mm3)`)
rnp_l <- num(snap$`RNp left (mm3)`); rnm_r <- num(snap$`RNm right (mm3)`)
rnm_l <- num(snap$`RNm left (mm3)`); n <- as.integer(snap$n)
stopifnot(!any(is.na(c(bv, rnp_r, rnp_l, rnm_r, rnm_l, n))),
          all(c(bv, rnp_r, rnp_l, rnm_r, rnm_l) > 0),
          sum(n[snap$Taxon != "Homo"]) == 25L,
          n[snap$Species == "Homo sapiens"] == 10L)
## ---- guarded correction: Gorilla / Hylobates measurement transposition ----
## (see header). Assert the snapshot carries exactly the printed
## (transposed) values and the printed sample sizes; fail loudly
## otherwise. Only the five measurement columns are exchanged;
## Taxon, Species and Number stay as printed.
g_row <- which(snap$Species == "Gorilla gorilla")
h_row <- which(snap$Species == "Hylobates lar")
stopifnot(length(g_row) == 1L, length(h_row) == 1L)
printed_g <- c(bv[g_row], rnp_r[g_row], rnp_l[g_row], rnm_r[g_row], rnm_l[g_row])
printed_h <- c(bv[h_row], rnp_r[h_row], rnp_l[h_row], rnm_r[h_row], rnm_l[h_row])
if (!identical(printed_g, c(98.8, 33.7, 34.3, 2.6, 2.0)) ||
    !identical(printed_h, c(396.8, 131.1, 129.3, 6.8, 7.4)) ||
    n[g_row] != 1L || n[h_row] != 2L)
  stop("Guarded correction FAILED: the snapshot's Gorilla/Hylobates rows ",
       "do not carry the expected printed (transposed) values; refusing ",
       "to exchange. Gorilla: ", paste(printed_g, collapse = "/"),
       " (n=", n[g_row], "); Hylobates: ",
       paste(printed_h, collapse = "/"), " (n=", n[h_row], ")")
bv[c(g_row, h_row)]    <- c(bv[h_row], bv[g_row])
rnp_r[c(g_row, h_row)] <- c(rnp_r[h_row], rnp_r[g_row])
rnp_l[c(g_row, h_row)] <- c(rnp_l[h_row], rnp_l[g_row])
rnm_r[c(g_row, h_row)] <- c(rnm_r[h_row], rnm_r[g_row])
rnm_l[c(g_row, h_row)] <- c(rnm_l[h_row], rnm_l[g_row])
stopifnot(identical(bv[g_row], 396.8), identical(bv[h_row], 98.8),
          identical(n[g_row], 1L), identical(n[h_row], 2L))
ratio <- (rnp_r + rnp_l) / 2 / bv
stopifnot(all(ratio[snap$Taxon %in% c("Homo", "Hominidae")] > 0.2 &
              ratio[snap$Taxon %in% c("Homo", "Hominidae")] < 0.45))

corrected <- c("Saimiri scuireus" = "Saimiri sciureus",
               "Daubentonia madagescariensis" = "Daubentonia madagascariensis")
species <- snap$Species
hit <- species %in% names(corrected)
species[hit] <- unname(corrected[species[hit]])

note <- character(20)
note[snap$Species == "Gorilla gorilla"] <-
  "Guarded correction -- the printed table transposed this row's measurement values with Hylobates lar (printed: BV 98.8 cm3, RNp 33.7/34.3 mm3, RNm 2.6/2.0 mm3); the five measurement values are exchanged in the build, species and n (1) as printed. Demonstrated cross-paper: the row's only specimen, YN82-140 (Table 2), has BV 362.9 cm3 in MacLeod et al. 2003 Table 2, de Sousa et al. 2010 Table 1 and Bauernfeind et al. 2013 Table 1; the gibbon specimens YN81-146 and Disco measure 88.8 and 115.8 cm3. Demonstration committed in the restricted repo as __stacho2024_cross_paper_check -- see README"
note[snap$Species == "Hylobates lar"] <-
  "Guarded correction -- the printed table transposed this row's measurement values with Gorilla gorilla (printed: BV 396.8 cm3, RNp 131.1/129.3 mm3, RNm 6.8/7.4 mm3); the five measurement values are exchanged in the build, species and n (2) as printed. Demonstrated cross-paper: the row's specimens, YN81-146 and Disco (3_97) (Table 2), have documented BVs of 88.8 and 115.8 cm3 (mean 102.3; MacLeod et al. 2003 Table 2; de Sousa et al. 2010 Table 1), and the gorilla specimen YN82-140 measures 362.9 cm3. Demonstration committed in the restricted repo as __stacho2024_cross_paper_check -- see README"
note[snap$Species == "Saimiri scuireus"] <- "Species name misprinted 'Saimiri scuireus'"
note[snap$Species == "Daubentonia madagescariensis"] <-
  "Species name misprinted 'Daubentonia madagescariensis'"

final.dataframe <- data.frame(
  Taxon = snap$Taxon,
  Species = species,
  `Species (printed)` = snap$Species,
  `Brain Volume, cm3` = bv,
  `RNp Volume Right, mm3` = rnp_r,
  `RNp Volume Left, mm3` = rnp_l,
  `RNm Volume Right, mm3` = rnm_r,
  `RNm Volume Left, mm3` = rnm_l,
  Number = n,
  Note = note,
  check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(final.dataframe) == 20L)

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
