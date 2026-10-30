# Wilman et al. 2014 (EltonTraits 1.0) — mammal functional data -> analysis CSV + public TSV
# Reformat: frozen snapshot -> harmonised species + derived diet/foraging/activity summaries.
# House pipeline: snapshot (frozen, faithful) -> clean here -> CSV + DOI-coded TSV.
# Scope: full EltonTraits mammal table (5403 species). Body mass kept for reference (secondary).

library(readxl)
library(writexl)

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(repo)
folder    <- "Wilman_etal_2014"
item_name <- "Wilman_etal_2014_MamFuncDat"

# ---- species resolver (single source of truth = _keys) ----------------------
key <- read.csv("_keys/Stephan/species_key.csv", stringsAsFactors = FALSE)
ref <- read.csv("_keys/species_reference.csv",   stringsAsFactors = FALSE)$accepted_name
km  <- setNames(key$accepted_name, tolower(trimws(key$variant_name)))
clean_sp <- function(x) trimws(gsub("\\s+", " ", gsub("_", " ", gsub("\\*", "", x))))
resolve <- function(x) {
  c <- clean_sp(x)
  hit <- match(tolower(c), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  a <- km[tolower(c)]; if (!is.na(a)) return(unname(a))
  c
}

# ---- read frozen snapshot ---------------------------------------------------
snap <- read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")),
                   sheet = "MamFuncDat_snapshot", .name_repair = "minimal")
snap <- as.data.frame(snap, check.names = FALSE)

diet_cols <- c("Diet-Inv","Diet-Vend","Diet-Vect","Diet-Vfish","Diet-Vunk",
               "Diet-Scav","Diet-Fruit","Diet-Nect","Diet-Seed","Diet-PlantO")
diet_lab  <- c("Invertebrates","Endotherm vertebrates","Ectotherm vertebrates","Fish",
               "Vertebrates (unknown)","Carrion/scavenge","Fruit","Nectar","Seed","Other plant")
D <- sapply(snap[diet_cols], function(x) suppressWarnings(as.numeric(x)))
dsum   <- rowSums(D)
animal <- rowSums(D[, 1:6, drop = FALSE])   # Inv..Scav
plant  <- rowSums(D[, 7:10, drop = FALSE])  # Fruit..PlantO

dominant <- ifelse(dsum == 0, NA, diet_lab[max.col(D, ties.method = "first")])
breadth  <- ifelse(dsum == 0, NA, rowSums(D > 0))
guild    <- ifelse(dsum == 0, NA,
             ifelse(animal >= 70, "Faunivore",
             ifelse(plant  >= 70, "Herbivore", "Omnivore")))

for_map <- c(M = "Marine", G = "Ground", Ar = "Arboreal", S = "Scansorial", A = "Aerial")
stratum <- unname(for_map[trimws(snap[["ForStrat-Value"]])])

n <- snap[["Activity-Nocturnal"]] == "1"
c <- snap[["Activity-Crepuscular"]] == "1"
d <- snap[["Activity-Diurnal"]] == "1"
activity <- ifelse(!(n | c | d), NA,
             ifelse(n & d, "Cathemeral",
             ifelse(n, "Nocturnal",
             ifelse(d, "Diurnal",
             ifelse(c, "Crepuscular", NA)))))

df <- data.frame(
  species_sci        = vapply(snap$Scientific, resolve, character(1)),
  Species            = trimws(snap$Scientific),
  MSW3_ID            = snap$MSW3_ID,
  Family             = snap$MSWFamilyLatin,
  stringsAsFactors = FALSE, check.names = FALSE)
for (i in seq_along(diet_cols))
  df[[gsub("-", "_", diet_cols[i])]] <- D[, i]
df$Diet_dominant     <- dominant
df$Diet_breadth      <- breadth
df$Trophic_guild     <- guild
df$Diet_Certainty    <- snap[["Diet-Certainty"]]
df$ForStrat_Value    <- snap[["ForStrat-Value"]]
df$ForStrat_stratum  <- stratum
df$ForStrat_Certainty<- snap[["ForStrat-Certainty"]]
df$Activity_Nocturnal   <- snap[["Activity-Nocturnal"]]
df$Activity_Crepuscular <- snap[["Activity-Crepuscular"]]
df$Activity_Diurnal     <- snap[["Activity-Diurnal"]]
df$Activity_pattern     <- activity
df$Activity_Certainty   <- snap[["Activity-Certainty"]]
df$BodyMass.g           <- suppressWarnings(as.numeric(snap[["BodyMass-Value"]]))
df$BodyMass_SpecLevel   <- snap[["BodyMass-SpecLevel"]]

# ---- write analysis CSV + DOI-coded public TSV ------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- tryCatch(read_excel("__ReadMe.xlsx", sheet = "Sheet1"), error = function(e) NULL)
item_encoded <- if (!is.null(filecodes))
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")] else NA
if (is.na(item_encoded)) {
  item_encoded <- "10.1890%2F13-1917.1_MamFuncDat"   # fallback until registry row added
  warning("Item not yet in __ReadMe.xlsx; using known encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

cat("Wilman MamFuncDat:", nrow(df), "species written\n")
