# Original file:
# de Sousa, A. A., Sherwood, C. C., Mohlberg, H., Amunts, K., Schleicher, A., MacLeod, C. E.,
# Hof, P. R., Frahm, H., & Zilles, K. (2010). Hominoid visual brain structure volumes and the
# position of the lunate sulcus. J Hum Evol, 58(4), 281-292. https://doi.org/10.1016/j.jhevol.2009.11.011
#
# Item: Supplementary Table 2 (online supplementary material) = "1-s2.0-S0047248410000023-mmc2.doc"
#   "Supplementary Table 2. Primate species mean volumes (g)"  [units labelled g; values are cm3]
# Source footnote (verbatim):
#   "Non-hominoid mean values (except M. fascicularis) are from Stephan et al (1981, 1988).
#    Hominoid and M. fascicularis mean values were obtained for this study
#    (see Table 1 and text for further details)."

## 1. SNAPSHOT  (freeze BEFORE cleaning -- keeps the published error, see step 3)
# The PDF/doc was digitised into a faithful, frozen copy in original layout:
#   deSousa_etal_2010_SupTable2_snapshot.xlsx
# It reproduces the published table exactly: original column headers, taxonomic grouping,
# original species spellings, the "(g)" label, the footnote, and -- importantly -- the
# ERRONEOUS neocortex values (see step 3). Do NOT fix anything in the snapshot.

## 2. READ SNAPSHOT

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)
library(readxl)
snap <- read_excel("deSousa_etal_2010_SupTable2_snapshot.xlsx", skip = 2)  # row 1 title, row 2 blank
# keep species + the 8 measure columns; drop the 7 taxonomic-hierarchy columns
names(snap)[8:16] <- c("species","brain_volume_cm3","brain_N","neocortex_volume_cm3","neocortex_N",
                       "V1_area_striata_volume_cm3","V1_N","LGN_volume_cm3","LGN_N")
df <- snap[!is.na(snap$species), c("species","brain_volume_cm3","brain_N","neocortex_volume_cm3",
       "neocortex_N","V1_area_striata_volume_cm3","V1_N","LGN_volume_cm3","LGN_N")]
df$species_as_published <- df$species
df$correction <- ""

## 3. CORRECT VALUE ERROR -- neocortex mis-copied from Stephan  (kept in snapshot, fixed here)
# In the published Supp. Table 2 the Neocortex ("Neo. vol.") values for the 17 strepsirrhine +
# tarsier (prosimian) species were mis-copied from Stephan et al (1981, 1988): 13 of the 17
# exceed the whole-brain volume of the same species, which is impossible. The brain, V1 and LGN
# columns are unaffected. Corrected values are the Stephan neocortex volumes (cm3).
neo_correct <- c(
  "Tarsius syrichta"             = 1.768,
  "Microcebus murinus"           = 0.740,
  "Cheirogaleus major"           = 2.938,
  "Cheirogaleus medius"          = 1.221,
  "Eulemur fulvus"               = 12.207,
  "Varecia variegata"            = 15.293,
  "Lepilemur ruficaudatus"       = 3.282,
  "Avahi laniger"                = 4.813,
  "Propithecus verreauxi"        = 13.170,
  "Indri indri"                  = 20.114,
  "Daubentonia madagascariensis" = 22.127,
  "Loris tardigradus"            = 3.524,   # name also corrected in step 4
  "Nycticebus coucang"           = 6.192,
  "Perodicticus potto"           = 6.683,
  "Galago senegalensis"          = 2.139,
  "Otolemur crassicaudatus"      = 4.723,
  "Galagoides demidoff"          = 1.568
)
# species in this block are still under their PUBLISHED names at this point (Loris "tardigradius")
pub_for_neo <- df$species_as_published
pub_for_neo[pub_for_neo == "Loris tardigradius"] <- "Loris tardigradus"
for (i in seq_along(neo_correct)) {
  sp <- names(neo_correct)[i]
  hit <- which(pub_for_neo == sp)
  if (length(hit) == 1) {
    old <- df$neocortex_volume_cm3[hit]
    df$neocortex_volume_cm3[hit] <- neo_correct[[sp]]
    df$correction[hit] <- paste0(df$correction[hit],
      sprintf("neocortex value corrected %s->%s (mis-copied from Stephan in published Supp. Table 2; corrected per Stephan 1981/1988); ",
              old, neo_correct[[sp]]))
  }
}

## 4. CORRECT SPECIES NAMES -- spelling/typo errors  (FLAGGED SEPARATELY from value errors)
# These are transcription errors in the species binomials, not data-value errors.
name_correct <- c(
  "Syndactylus symphalangus" = "Symphalangus syndactylus",
  "Cercopithecus mitus"      = "Cercopithecus mitis",
  "Sanguinus midas"          = "Saguinus midas",
  "Sanguinus oedipus"        = "Saguinus oedipus",
  "Pithecus monachus"        = "Pithecia monachus",
  ## The published binomial misspells BOTH parts: the genus is Lagothrix (the r
  ## was missing) and the epithet lagothricha. An earlier pass corrected only the
  ## epithet and left "Lagothix", so the row could not be matched to the repo
  ## canonical name (_keys/species_reference.csv line 95, _keys/Stephan/species_key.csv).
  "Lagothix lagathricha"     = "Lagothrix lagothricha",
  "Loris tardigradius"       = "Loris tardigradus"
)
for (i in seq_along(name_correct)) {
  oldn <- names(name_correct)[i]; newn <- name_correct[[i]]
  hit <- which(df$species == oldn)
  if (length(hit) == 1) {
    df$species[hit] <- newn
    df$correction[hit] <- paste0(df$correction[hit],
      sprintf("species name corrected from published '%s'; ", oldn))
  }
}
df$correction <- trimws(gsub(";\\s*$", "", df$correction))
df$source <- "deSousa_etal_2010 (J Hum Evol) Supp. Table 2"

## 5. SAVE  ("use this" cleaned, analysis-ready file)
df <- df[, c("species","species_as_published","brain_volume_cm3","brain_N","neocortex_volume_cm3",
             "neocortex_N","V1_area_striata_volume_cm3","V1_N","LGN_volume_cm3","LGN_N",
             "source","correction")]
write.csv(df, "deSousa_etal_2010_SupTable2.csv", row.names = FALSE)

## 6. Also write the DOI/PMID-coded TSV to __Public/comparative-data/ -----------
## Mirrors the tail of deSousa_etal_2010_Table1.R: the encoded filename is looked up
## from __ReadMe.xlsx ("Item name" -> "Item encoded"), so the shared snapshot of this
## table lives under __Public/comparative-data/<encoded>.tsv and downstream scripts
## (e.g. the DeCasien BrainRegion comparison) read it via that stable coded name
## instead of re-transcribing the species-mean values. These SupTable 2 means are the
## species-level, already-BILATERAL V1/LGN volumes DeCasien draws on for its LGN cells
## (Table 1 carries only per-specimen LEFT V1/LGN); keeping both items as Public TSVs
## lets the comparison attribute every deSousa-2010 cell to its correct source item.
if (is.na(base) || !file.exists(file.path(base, "__ReadMe.xlsx"))) {
  warning("No repository root with __ReadMe.xlsx found; TSV skipped.")
} else {
  tsv_dir   <- file.path(base, "__Public/comparative-data")
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  enc <- filecodes$"Item encoded"[match(item_name, filecodes$"Item name")]

  if (is.na(enc) || !nzchar(enc)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else if (!dir.exists(path.expand(tsv_dir))) {
    warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
  } else {
    readr::write_tsv(df, file.path(tsv_dir, paste0(enc, ".tsv")), na = "")
    message("Wrote ", file.path(tsv_dir, paste0(enc, ".tsv")))
  }
}
