# Seymour_Boyer_flow_combined.R
#
# Purpose
#   Merge the two cranial-canal encephalic blood-flow datasets in the repo into one
#   analysis-ready table, one row per accepted species, with a consistent total-flow
#   column (QTOT_best_mLs) and an internal-carotid (QICA) overlap cross-check.
#   First concrete step toward flow-based brain glucose scaling for fossil hominins.
#
#   Seymour et al. (2015) J Exp Biol 218:2631-2640  -> ICA-only flow (Total_QICA_cm3_s)
#   Boyer & Harrington (2019) J Hum Evol            -> QICA + QVA + QTOT (ICA + vertebral)
#
# Inputs (repo-relative)
#   Seymour_etal_2015/Seymour_etal_2015_TableS1.csv
#   Boyer_Harrington_2019/comparison/Boyer data added to compilation/
#       Boyer glucose blood flow/Boyer_predicting_pBGU.csv
#   _keys/Stephan/species_key.csv   (token Seymour2015 -> accepted names)
#
# Outputs (this folder)
#   Seymour_Boyer_flow_combined.csv       union, 96 species
#   Seymour_Boyer_QICA_crosscheck.csv     the 17 overlap species
#
# Units: all flow in mL/s; BM in g; ECV/brain volume in mL.

suppressPackageStartupMessages({library(readr); library(dplyr); library(tidyr); library(stringr); library(tibble)})  # tibble: deframe()

## ---- self-contained repo root (Rscript or RStudio; full repo or lone folder) ----
.here <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(dirname(normalizePath(sub("^--file=", "", a[1]))))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(dirname(normalizePath(rstudioapi::getSourceEditorContext()$path)))
  normalizePath(getwd())
})
repo <- normalizePath(file.path(.here, ".."))      # __flow_comparison/ -> repo root
rp   <- function(...) file.path(repo, ...)

## ---- accepted-name crosswalks ----
key <- read_csv(rp("_keys/Stephan/species_key.csv"), show_col_types = FALSE)
sey_map <- key %>% filter(source_publication == "Seymour2015") %>%
  select(variant_name, accepted_name) %>% deframe()
# Boyer has no key token yet; mirror the project's genus-lumping convention explicitly.
boyer_accept <- function(n) recode(str_trim(n),
  "Gorilla gorilla" = "Gorilla sp.", "Pongo pygmaeus" = "Pongo sp.",
  "Lagothrix lagotricha" = "Lagothrix lagothricha", .default = str_trim(n))

## ---- suborder harmonization (VA story is suborder-driven) ----
strep <- c("Archaeolemur","Avahi","Babakotia","Cheirogaleus","Daubentonia","Eulemur",
  "Galago","Hapalemur","Indri","Lemur","Lepilemur","Loris","Microcebus","Mirza",
  "Nycticebus","Otolemur","Perodicticus","Prolemur","Propithecus","Varecia","Galagoides")
hap <- c("Alouatta","Aotus","Ateles","Cacajao","Callicebus","Callithrix","Cebus",
  "Chiropotes","Cercopithecus","Chlorocebus","Colobus","Gorilla","Homo","Hylobates",
  "Lagothrix","Leontopithecus","Lophocebus","Macaca","Mandrillus","Miopithecus","Nasalis",
  "Pan","Papio","Piliocolobus","Pithecia","Pongo","Presbytis","Saimiri","Semnopithecus",
  "Trachypithecus","Tarsius")
other <- c(Cynocephalus="Dermoptera",Galeopterus="Dermoptera",Ptilocercus="Scandentia",
  Tupaia="Scandentia",Mus="Rodentia",Rattus="Rodentia",Sciurus="Rodentia",
  Oryctolagus="Lagomorpha")
sub_from_genus <- function(acc){ g <- word(acc,1)
  ifelse(g %in% strep,"Strepsirrhini", ifelse(g %in% hap,"Haplorrhini",
    ifelse(g %in% names(other), other[g], NA_character_))) }
norm_sub <- function(s,acc){ s <- str_trim(coalesce(s,""))
  s <- recode(s, "Haplorhini"="Haplorrhini","Strepsirhini"="Strepsirrhini")
  ifelse(nzchar(s), s, sub_from_genus(acc)) }

## ---- load Seymour 2015 (ICA only) ----
sey <- read_csv(rp("Seymour_etal_2015/Seymour_etal_2015_TableS1.csv"), show_col_types = FALSE) %>%
  filter(!is.na(Species), Species != "") %>%
  transmute(accepted_species = coalesce(sey_map[Species], Species),
            Suborder_raw = Suborder, BM_g_Seymour = Body_mass_g,
            ECV_ml_Seymour = Brain_volume_ml, Sey_QICA_mLs = Total_QICA_cm3_s)

## ---- load Boyer & Harrington 2019 (ICA + VA + TOT) ----
boy_path <- rp("Boyer_Harrington_2019/comparison/Boyer data added to compilation",
               "Boyer glucose blood flow/Boyer_predicting_pBGU.csv")
boy <- read_csv(boy_path, show_col_types = FALSE) %>%
  filter(!is.na(`Boyer Species`), `Boyer Species` != "") %>%
  transmute(accepted_species = boyer_accept(`Boyer Species`),
            BM_g_Boyer = BM, ECV_ml_Boyer = ECV,
            Boy_QICA_mLs = QICA, Boy_QVA_mLs = QVA, Boy_QTOT_mLs = QTOT)

## ---- merge (union) ----
combined <- full_join(sey, boy, by = "accepted_species") %>%
  mutate(
    suborder = norm_sub(Suborder_raw, accepted_species),
    in_Seymour2015 = if_else(!is.na(Sey_QICA_mLs) | !is.na(ECV_ml_Seymour), "Y", "N"),
    in_Boyer2019   = if_else(!is.na(Boy_QTOT_mLs) | !is.na(ECV_ml_Boyer), "Y", "N"),
    overlap = if_else(in_Seymour2015 == "Y" & in_Boyer2019 == "Y", "Y", "N"),
    QICA_ratio_Sey_over_Boy = if_else(!is.na(Sey_QICA_mLs) & !is.na(Boy_QICA_mLs) & Boy_QICA_mLs > 0,
                                      round(Sey_QICA_mLs / Boy_QICA_mLs, 3), NA_real_),
    # consistent total flow: only Boyer measures the vertebral contribution
    QTOT_best_mLs = Boy_QTOT_mLs,
    QTOT_source = case_when(
      !is.na(Boy_QTOT_mLs) ~ "Boyer2019_QTOT(ICA+VA)",
      !is.na(Sey_QICA_mLs) ~ "Seymour2015_ICA_only(no_VA;QTOT_unavailable)",
      TRUE ~ "NA"),
    notes = paste(
      if_else(in_Boyer2019 == "Y" & is.na(Boy_QICA_mLs),
              "Boyer RICA/QICA=NA (unknown-species cranial foramen)", ""),
      if_else(overlap == "Y", "overlap: cross-check row", ""), sep = "; ") %>%
      str_replace_all("^; |; $", "") %>% str_replace_all("^; $", "")) %>%
  select(accepted_species, suborder, in_Seymour2015, in_Boyer2019, overlap,
         BM_g_Seymour, BM_g_Boyer, ECV_ml_Seymour, ECV_ml_Boyer,
         Sey_QICA_mLs, Boy_QICA_mLs, Boy_QVA_mLs, Boy_QTOT_mLs,
         QICA_ratio_Sey_over_Boy, QTOT_best_mLs, QTOT_source, notes) %>%
  arrange(accepted_species)

write_csv(combined, file.path(.here, "Seymour_Boyer_flow_combined.csv"))

## ---- overlap cross-check ----
crosscheck <- combined %>% filter(overlap == "Y") %>%
  transmute(accepted_species, suborder,
            Sey_QICA = Sey_QICA_mLs, Boy_QICA = Boy_QICA_mLs,
            ratio_Sey_over_Boy = QICA_ratio_Sey_over_Boy,
            Boy_QVA = Boy_QVA_mLs, Boy_QTOT = Boy_QTOT_mLs,
            VA_share_of_QTOT = round(Boy_QVA_mLs / Boy_QTOT_mLs, 3),
            Sey_QICA_vs_Boy_QTOT_ratio = round(Sey_QICA_mLs / Boy_QTOT_mLs, 3))
write_csv(crosscheck, file.path(.here, "Seymour_Boyer_QICA_crosscheck.csv"))

## ---- console summary ----
message(sprintf("union=%d  overlap=%d  Seymour-only=%d  Boyer-only=%d",
  nrow(combined), sum(combined$overlap=="Y"),
  sum(combined$in_Seymour2015=="Y" & combined$in_Boyer2019=="N"),
  sum(combined$in_Boyer2019=="Y" & combined$in_Seymour2015=="N")))
message(sprintf("log(QICA) Pearson r (overlap) = %.3f",
  with(crosscheck, cor(log(Sey_QICA), log(Boy_QICA)))))
message(sprintf("median Sey/Boy QICA ratio = %.2f | median VA share: strep %.2f, haplo %.2f",
  median(crosscheck$ratio_Sey_over_Boy, na.rm=TRUE),
  median(crosscheck$VA_share_of_QTOT[crosscheck$suborder=="Strepsirrhini"], na.rm=TRUE),
  median(crosscheck$VA_share_of_QTOT[crosscheck$suborder=="Haplorrhini"], na.rm=TRUE)))
