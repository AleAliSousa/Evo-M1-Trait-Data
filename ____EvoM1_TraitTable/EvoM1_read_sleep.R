# EvoM1: sleep & torpor -> sleep.xlsx for the trait table.
# Reads the compiled merge (__merging_sleep/sleep_wide.csv), not single source TSVs, because the
# traits come from four papers (Eagleman & Vaughn 2021 REM%, Herculano-Houzel 2015 daily sleep,
# Lyamin et al. 2008 cetacean SWS, Ruf & Geiser 2015 torpor). Emits a per-cell *_Source column for
# each trait (trait->source is 1:1 in this build). Correlatable side-by-side with the other trait
# tables on species_sci.
library(readxl); library(writexl)
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/")
folder_path <- "./____EvoM1_TraitTable/"

d <- read.csv("./__merging_sleep/sleep_wide.csv", stringsAsFactors = FALSE, check.names = FALSE)

# trait -> primary-source label (shown as the app's per-cell Source)
src <- c(
  REM_sleep_pct     = "Eagleman & Vaughn 2021 (REM sleep)",
  Sleep_h_day       = "Herculano-Houzel 2015 (daily sleep)",
  SWS_total_pct     = "Lyamin et al. 2008 (cetacean slow-wave sleep)",
  USWS_pctTST       = "Lyamin et al. 2008 (cetacean slow-wave sleep)",
  Torpor_type       = "Ruf & Geiser 2015 (torpor/hibernation)",
  Torpor_Tb_min_C   = "Ruf & Geiser 2015 (torpor/hibernation)",
  Torpor_bout_max_h = "Ruf & Geiser 2015 (torpor/hibernation)"
)
traits <- intersect(names(src), names(d))   # traits actually present in the merge

out <- data.frame(species_sci = d$Species, Species = d$Species,
                  stringsAsFactors = FALSE, check.names = FALSE)
for (t in traits) {
  v <- as.character(d[[t]]); v[v == ""] <- NA
  out[[t]] <- v
  out[[paste0(t, "_Source")]] <- ifelse(is.na(v), NA, unname(src[t]))
}

write_xlsx(out, paste0(folder_path, "sleep.xlsx"))
cat("sleep.xlsx:", nrow(out), "rows;",
    paste(sprintf("%s=%d", traits, sapply(traits, function(t) sum(!is.na(out[[t]])))), collapse = ", "), "\n")
