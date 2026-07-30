## Brodmann K (1913) Verhandlungen der Anatomischen Gesellschaft 41:157-216
## Table 1 — total cortical surface, sulcal cortex, brain weight across mammals (Gesamtrindenfläche)
## Build: frozen snapshot -> analysis CSV (+ public TSV).  See __HOWTO_build_a_dataset_file.md
##
## Scanned 1913 Fraktur: OCR is unreliable, so the snapshot was TRANSCRIBED from a rendered image of
## p.206 (§0a invariant 1 — the frozen source is the hand-verified snapshot). qmm = mm2; surface is
## per ONE hemisphere. Broadens Smaers 2017's Brodmann use (10 primates x 4 regions) to ~38 taxa across
## all mammal orders with total surface + sulcal cortex + brain weight.

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
folder       <- dirname(.sp)
item_name    <- "Brodmann__1913_Table1"                 # registry Item name (double underscore)
dataset_root <- local({ d<-folder
  while (dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d)
  if (file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)
snapshot_xlsx  <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv      <- file.path(folder, paste0(item_name, ".csv"))
readme_xlsx    <- file.path(dataset_root, "__ReadMe.xlsx")
public_tsv_dir <- file.path(dataset_root, "__Public", "comparative-data")

library(readxl)
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet="Tabelle1", .name_repair="minimal"), check.names=FALSE)

acc <- c(  # printed name -> best-effort accepted binomial (genus-level where undetermined)
 "Europäer: Maximalwert"="Homo sapiens","Europäer: Minimalwert"="Homo sapiens",
 "Europäer: Durchschnitt"="Homo sapiens","Naturmenschen: Durchschnitt"="Homo sapiens",
 "Idioten: Durchschnitt"="Homo sapiens","Schimpanse (Anthropopithecus)"="Pan troglodytes",
 "Gibbon (Hylobates)"="Hylobates sp.","Mandrill (Cynocephalus)"="Mandrillus sphinx",
 "Meerkatze (Cercopithecus)"="Cercopithecus sp.","Krallenaffe (Hapale)"="Callithrix sp.",
 "Mohrenmaki (Lemur)"="Eulemur macaco","Zwergmaki (Chirogaleus)"="Cheirogaleus sp.",
 "Bär (Ursus)"="Ursus sp.","Löwe (Felis leo)"="Panthera leo","Hund (Terrier) (Canis)"="Canis familiaris",
 "Katze (Felis)"="Felis catus","Steinmarder (Mustela)"="Martes foina","Iltis (Putorius)"="Mustela putorius",
 "Elefant (Elephas)"="Elephas sp.","Pferd (Equus)"="Equus caballus","Hausrind (Bos)"="Bos taurus",
 "Schaf (Ovis)"="Ovis aries","Schwein (Sus)"="Sus scrofa","Ziege (Capra)"="Capra hircus",
 "Tümmler (Phocaena)"="Phocoena phocoena","Seehund (Phoca)"="Phoca sp.","Kaninchen (Lepus)"="Oryctolagus cuniculus",
 "Hausmaus (Mus)"="Mus musculus","Igel (Erinaceus)"="Erinaceus europaeus","Borstenigel (Centetes)"="Tenrec ecaudatus",
 "Maulwurf (Talpa)"="Talpa europaea","Spitzmaus (Sorex)"="Sorex sp.","Gürteltier (Dasypus)"="Dasypus sp.",
 "Beutelteufel (Sarcophilus)"="Sarcophilus harrisii","Fuchskusu (Phalangista)"="Trichosurus vulpecula",
 "Beutelratte (Didelphys)"="Didelphis sp.","Langschnabeligel (Proechidna)"="Zaglossus sp.",
 "Schnabeltier (Ornithorhynchus)"="Ornithorhynchus anatinus")

out <- data.frame(
  Species = unname(acc[snap$Name]),
  Species_Brodmann1913 = snap$Name,
  Genus_printed = snap$Genus_printed,
  Order_printed = snap$Ordnung,
  `CorticalSurface_1hemisphere.mm2` = suppressWarnings(as.numeric(snap$Rindenflaeche_1hemisphere_qmm)),
  `SulcalCortex.mm2`  = suppressWarnings(as.numeric(snap$Furchenrinde_qmm)),
  SulcalCortex_pct    = suppressWarnings(as.numeric(snap$Furchenrinde_pct_Gesamtrinde)),
  `BrainWeight.g`     = suppressWarnings(as.numeric(snap$Hirngewicht_g)),
  `HemisphereWeight.g`= suppressWarnings(as.numeric(snap$Hemisphaerengewicht_g)),
  stringsAsFactors=FALSE, check.names=FALSE)

options(scipen=999); write.csv(out, final_csv, row.names=FALSE, na="")
fc <- read_excel(readme_xlsx, sheet="Sheet1")
ie <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(ie)) stop("No Item encoded for ", item_name, " (add a Brodmann 1913 row, Item number 'Table 1', DOI-alt OCLC:8777719)")
dir.create(public_tsv_dir, recursive=TRUE, showWarnings=FALSE)
write.table(out, file.path(public_tsv_dir, paste0(ie, ".tsv")), sep="\t", row.names=FALSE, na="")
message("Wrote ", nrow(out), " taxa -> ", ie, ".tsv")
