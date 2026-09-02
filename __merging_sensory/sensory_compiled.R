## Sensory compiled merge -- comparative SENSORY PERFORMANCE (percepts only).
## Counterpart of __merging_volumes/volumes_compiled.R and
## __merging_cellcounts/cellcounts_compiled.R, built on the COMPILATION-AWARE
## pattern of __merging_cerebral_metabolic_rate (see README__merging.md, and
## __HOWTO_build_a_dataset_file.md sections 9-10).
##
## Sources (all mammal-only at present):
##   Heffner_Heffner_1992_a_Table1        - BOTH. Own field-of-best-vision, binocular
##                                          field and unfootnoted acuities (primary);
##                                          localization thresholds + footnoted acuities
##                                          compiled, each with a printed footnote source.
##   Veilleux_Kirk_2014_SupplementalTable1 - BOTH. "this study" acuities (primary);
##                                          bracket-sourced acuities compiled from its
##                                          122-entry data-source list.
##   Koay_etal_1998_Figure6               - BOTH. Rousettus audiogram (primary); the other
##                                          66 points compiled, each with a caption source.
##   Heffner_etal_2020_Figure3            - PRIMARY, text values only (Cottontail rabbit).
##
## Because three of the four are compilations of OTHER labs' measurements that print a
## reference per value, we do NOT average their published values as if independent. Every
## value is pulled down to PRIMARY-STUDY level, keyed by first author + year (+ a/b/c),
## and two values are treated as the same measurement when their study sets INTERSECT.
##
## EXCLUDED BY DESIGN
##   * Heffner_etal_2020 Figure 3 comparative points -- that figure prints no per-point
##     reference, so those values have no traceable primary (only its text values enter).
##   * derived measures -- Hearing_range.octaves is RECOMPUTED from the merged limits.
##   * non-percept covariates (functional interaural distance, eye axial diameter) and
##     ecology (trophic level, activity pattern, diet, running speed, body mass).
##   * non-mammals -- class gate (no non-mammal sources yet; keep the gate when adding).
##
## NOTE: this .R is the house-style reproducible equivalent of build_sensory_merge.py,
## which is the script that actually generated the shipped CSVs (no R in the build
## environment; same arrangement as __merging_cerebral_metabolic_rate). Run either.

suppressPackageStartupMessages({ library(tidyverse) })
setwd("~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/__merging_sensory")
base <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"

item <- c(HH1992a  = "Heffner_Heffner_1992_a_Table1",
          VK2014   = "Veilleux_Kirk_2014_SupplementalTable1",
          Koay1998 = "Koay_etal_1998_Figure6",
          H2020    = "Heffner_etal_2020_Figure3")
item_year <- c(1992, 2014, 1998, 2020); names(item_year) <- item
heffner_lab_items <- item[c("HH1992a", "Koay1998", "H2020")]

units_of <- c("Audible_freq_high_60dB.kHz" = "kHz", "Audible_freq_low_60dB.kHz" = "kHz",
              "Sound_localization_threshold.deg" = "deg", "Visual_acuity.cdeg" = "c/deg",
              "Field_of_best_vision.deg" = "deg", "Binocular_field.deg" = "deg")

## printed / older names -> merge name (each taken from that source's own crosswalk)
species_canon <- c(
  "felis domesticus"="Felis catus","canis familiaris"="Canis lupus familiaris",
  "sylvilagus floridana"="Sylvilagus floridanus","orcina orca"="Orcinus orca",
  "mesocricetus auritus"="Mesocricetus auratus","chinchilla laniger"="Chinchilla lanigera",
  "sciureus niger"="Sciurus niger","macaca irus"="Macaca fascicularis",
  "lemur fulvus"="Eulemur fulvus","marmosa elegans"="Thylamys elegans",
  "spalax ehrenbergi"="Nannospalax ehrenbergi","cercopithecus aithiops"="Chlorocebus aethiops",
  "agouti paca"="Cuniculus paca","myotis dabentonii"="Myotis daubentonii",
  "sarcrophilus harrisii"="Sarcophilus harrisii","macropus fulginosus"="Macropus fuliginosus",
  "setonyx brachyurus"="Setonix brachyurus","dasyprocta leoporina"="Dasyprocta leporina",
  "sciurus caroliniensis"="Sciurus carolinensis","rhinolophus rouxi"="Rhinolophus rouxii",
  "mustela putorius furo"="Mustela putorius")
canon_sp <- function(x){ y <- str_squish(x); k <- tolower(y)
  ifelse(k %in% names(species_canon), species_canon[k], y) }

## study key: surname + year (+ a/b/c); the initial is carried after "|" because the
## sources print it inconsistently -- it only disambiguates same-surname, same-year
## authors (H. E. Heffner vs R. S. Heffner, 1980).
key_of     <- function(k) str_split_fixed(k, "\\|", 2)[,1]
initial_of <- function(k) str_split_fixed(k, "\\|", 2)[,2]
compatible <- function(a, b) key_of(a) == key_of(b) &
  (initial_of(a) == "" | initial_of(b) == "" | initial_of(a) == initial_of(b))

ref_key <- function(text){
  t <- str_squish(text)
  if (!nzchar(t)) return(character(0))
  if (str_detect(tolower(t), "present report|present study")) return("SELF")
  m <- str_match(t, "\\((\\d{2})([a-c])?\\)")                    # ('82) / ('88c)
  if (!is.na(m[1,1])) { year <- paste0("19", m[1,2]); suf <- ifelse(is.na(m[1,3]), "", m[1,3])
                        head <- str_split_fixed(t, fixed(m[1,1]), 2)[,1]
  } else {
    m <- str_match(t, "(1[89]\\d{2}|20\\d{2})([a-c])?")
    if (is.na(m[1,1])) return(paste0("unkeyed:", tolower(str_sub(t, 1, 40))))
    year <- m[1,2]; suf <- ifelse(is.na(m[1,3]), "", m[1,3])
    head <- str_split_fixed(t, fixed(m[1,1]), 2)[,1]
  }
  toks <- str_extract_all(head, "[A-Za-zÀ-ÿ'\\.]+")[[1]]
  toks <- toks[!tolower(str_remove_all(toks, "\\.")) %in% c("and","et","al","the","in","press","of","")]
  bare <- str_remove_all(toks, "\\.")
  surname <- bare[nchar(bare) >= 3][1]
  init <- bare[nchar(bare) <= 2 & bare == toupper(bare)][1]
  if (is.na(surname)) return(paste0("unkeyed:", tolower(str_sub(t, 1, 40))))
  paste0(tolower(surname), year, suf, ifelse(is.na(init), "", paste0("|", tolower(str_sub(init,1,1)))))
}

## ---- 1. load sources, emit STUDY-LEVEL rows ---------------------------------------------
rows <- tibble(Species=character(), Measure=character(), Value=double(), Medium=character(),
               population=character(), Source_item=character(), Study_keys=list(),
               value_origin=character(), Data_role=character(), note=character())
addrow <- function(sp, meas, val, it, keys, origin, role, note="", medium="air", pop=""){
  v <- suppressWarnings(as.numeric(val))
  if (is.na(v) || !nzchar(sp)) return(invisible(NULL))
  rows <<- add_row(rows, Species=canon_sp(sp), Measure=meas, Value=v, Medium=medium,
                   population=pop, Source_item=it, Study_keys=list(keys),
                   value_origin=origin, Data_role=role, note=note)
}

## Heffner & Heffner 1992a -- study keys are CURATED in the footnotes reference table,
## because the printed footnotes mix prose with citations.
hh   <- read.csv(file.path(base, "Heffner_Heffner_1992_a", "Heffner_Heffner_1992_a_Table1.csv"),
                 stringsAsFactors = FALSE)
hhfn <- read.csv(file.path(base, "Heffner_Heffner_1992_a", "reference_tables",
                           "Heffner_Heffner_1992_a_Table1_footnotes.csv"), stringsAsFactors = FALSE)
fnkey <- setNames(lapply(hhfn$primary_study_keys, function(x) x[nzchar(x)] <-
                           str_split(x, ";")[[1]][nzchar(str_split(x, ";")[[1]])]),
                  as.character(hhfn$footnote))
for (i in seq_len(nrow(hh))) {
  r <- hh[i, ]; sp <- r$binomial
  if (grepl(" sp\\.$", sp)) next                     # Macaca sp. -- not resolvable
  addrow(sp, "Field_of_best_vision.deg", r$field_of_best_vision_deg, item["HH1992a"],
         character(0), "published", "primary", pop = r$Species_HH1992a)
  addrow(sp, "Binocular_field.deg", r$binocular_field_deg, item["HH1992a"],
         character(0), "published", "primary", pop = r$Species_HH1992a)
  addrow(sp, "Sound_localization_threshold.deg", r$sound_localization_threshold_deg,
         item["HH1992a"], fnkey[[as.character(r$threshold_footnote)]] %||% character(0),
         "published", "secondary", pop = r$Species_HH1992a)
  if (nzchar(as.character(r$acuity_footnote))) {
    addrow(sp, "Visual_acuity.cdeg", r$visual_acuity_cdeg, item["HH1992a"],
           fnkey[[as.character(r$acuity_footnote)]] %||% character(0),
           "published", "secondary", pop = r$Species_HH1992a)
  } else {
    addrow(sp, "Visual_acuity.cdeg", r$visual_acuity_cdeg, item["HH1992a"],
           character(0), "published", "primary", pop = r$Species_HH1992a)
  }
}

## Veilleux & Kirk 2014 -- bracket numbers resolve through its data-source table
vk    <- read.csv(file.path(base, "Veilleux_Kirk_2014", "Veilleux_Kirk_2014_SupplementalTable1.csv"),
                  stringsAsFactors = FALSE)
vksrc <- read.csv(file.path(base, "Veilleux_Kirk_2014", "reference_tables",
                            "Veilleux_Kirk_2014_SupplementalTable1_data_sources.csv"), stringsAsFactors = FALSE)
vkxw  <- read.csv(file.path(base, "Veilleux_Kirk_2014", "reference_tables",
                            "Veilleux_Kirk_2014_SupplementalTable1_species_crosswalk.csv"), stringsAsFactors = FALSE)
srcmap <- setNames(vksrc$citation, as.character(vksrc$source_number))
xwmap  <- setNames(vkxw$corrected_binomial, tolower(vkxw$species_as_published))
for (i in seq_len(nrow(vk))) {
  r <- vk[i, ]
  sp <- if (tolower(r$Species_VK2014) %in% names(xwmap)) xwmap[[tolower(r$Species_VK2014)]] else r$Species_VK2014
  if (identical(r$va_this_study, "TRUE")) {
    addrow(sp, "Visual_acuity.cdeg", r$visual_acuity_cdeg, item["VK2014"],
           character(0), "published", "primary")
  } else {
    ns   <- str_extract_all(r$src_VA, "\\d+")[[1]]
    keys <- unique(unlist(lapply(ns, function(n) if (!is.null(srcmap[[n]])) ref_key(srcmap[[n]]) else NULL)))
    addrow(sp, "Visual_acuity.cdeg", r$visual_acuity_cdeg, item["VK2014"],
           keys, "published", "secondary")
  }
}

## Koay et al 1998 Figure 6 -- caption gives an audiogram source per point; medium matters
koay <- read.csv(file.path(base, "Koay_etal_1998", "Koay_etal_1998_Figure6.csv"), stringsAsFactors = FALSE)
for (i in seq_len(nrow(koay))) {
  r <- koay[i, ]
  keys <- ref_key(r$audiogram_source)
  self <- identical(keys, "SELF")
  addrow(r$corrected_binomial, "Audible_freq_high_60dB.kHz", r$high_freq_hearing_limit_60dB_kHz,
         item["Koay1998"], if (self) character(0) else keys[keys != "SELF"],
         "digitised_from_figure", if (self) "primary" else "secondary",
         medium = ifelse(nzchar(r$medium), r$medium, "air"), pop = r$common_name_Koay1998)
}

## Heffner et al 2020 -- Cottontail values FROM TEXT (not the unattributed Figure 3)
h20 <- read.csv(file.path(base, "Heffner_etal_2020", "reference_tables",
                          "Heffner_etal_2020_cottontail_values_from_text.csv"), stringsAsFactors = FALSE)
tmap <- c(audible_freq_high_60dBSPL="Audible_freq_high_60dB.kHz",
          audible_freq_low_60dBSPL ="Audible_freq_low_60dB.kHz",
          sound_localization_threshold="Sound_localization_threshold.deg")
for (i in seq_len(nrow(h20))) {
  m <- tmap[[h20$trait[i]]]
  if (is.null(m) || is.na(m)) next                   # hearing_range is derived; recomputed below
  addrow("Sylvilagus floridanus", m, h20$value[i], item["H2020"], character(0),
         "published", "primary", note = "value stated in the paper's text, not read off Figure 3")
}

## ---- 2. dedupe: same primary study reported by two DIFFERENT sources --------------------
rows <- rows %>% mutate(
  Study_key = map_chr(Study_keys, ~ if (length(.x)) paste(.x, collapse="+") else NA_character_),
  Study_key = ifelse(is.na(Study_key),
                     paste0("SELF:", Source_item, ifelse(nzchar(population), paste0(":", population), "")),
                     Study_key))
kept <- rows[0, ]; dropped <- rows[0, ] %>% mutate(kept_from=character(), kept_value=double(),
                                                   shared_study=character(), agrees=character())
for (g in split(seq_len(nrow(rows)), paste(rows$Species, rows$Measure, rows$Medium, sep=""))) {
  keep_here <- integer(0)
  for (i in g) {
    mine <- rows$Study_keys[[i]]; clash <- NA_integer_
    if (length(mine)) for (j in keep_here) {
      if (rows$Source_item[j] == rows$Source_item[i]) next
      if (any(outer(mine, rows$Study_keys[[j]], Vectorize(compatible)))) { clash <- j; break }
    }
    if (!is.na(clash)) {
      shared <- key_of(mine[which(sapply(mine, function(a)
        any(sapply(rows$Study_keys[[clash]], function(b) compatible(a, b)))))[1]])
      dropped <- add_row(dropped, rows[i, ], kept_from = rows$Source_item[clash],
                         kept_value = rows$Value[clash], shared_study = shared,
                         agrees = ifelse(abs(rows$Value[clash] - rows$Value[i]) <=
                                         0.05 * abs(rows$Value[clash]), "TRUE", "FALSE"))
    } else keep_here <- c(keep_here, i)
  }
  kept <- bind_rows(kept, rows[keep_here, ])
}

## ---- 3. within ONE lab, the most recent measurement supersedes --------------------------
study_year <- function(keys, src){
  y <- as.integer(unlist(str_extract_all(paste(keys, collapse=" "), "(1[89]\\d{2}|20\\d{2})")))
  if (length(y)) max(y) else unname(item_year[src])
}
is_heffner <- function(keys, src) if (!length(keys)) src %in% heffner_lab_items else
  all(str_detect(key_of(keys), "^(heffner|koay)"))
kept <- kept %>% mutate(.year = map2_dbl(Study_keys, Source_item, study_year),
                        .hef  = map2_lgl(Study_keys, Source_item, is_heffner))
superseded <- kept %>% group_by(Species, Measure, Medium) %>%
  filter(n() > 1, all(.hef), .year < max(.year)) %>% ungroup()
kept <- anti_join(kept, superseded, by = c("Species","Measure","Medium","Source_item","Study_key"))

## ---- 4. average across DISTINCT primary studies ------------------------------------------
long <- kept %>% group_by(Species, Measure, Medium) %>%
  summarise(Units = unname(units_of[first(Measure)]), Value = round(mean(Value), 6),
            n_studies = n(), Sources = paste(sort(unique(Source_item)), collapse="; "),
            Study_keys = paste(sort(unique(Study_key)), collapse="; "),
            Data_role = if (all(Data_role=="primary")) "primary"
                        else if (all(Data_role=="secondary")) "secondary" else "mixed",
            value_origin = paste(sort(unique(value_origin)), collapse="; "),
            value_range = if (n_distinct(Value)==1) "" else
                          sprintf("%g-%g", min(Value), max(Value)), .groups="drop")

## derived: hearing range recomputed from the merged in-air limits (never merged as a value)
air <- long %>% filter(Medium == "air") %>% select(Species, Measure, Value) %>%
  pivot_wider(names_from = Measure, values_from = Value)
if (all(c("Audible_freq_high_60dB.kHz","Audible_freq_low_60dB.kHz") %in% names(air))) {
  long <- bind_rows(long, air %>%
    filter(!is.na(.data[["Audible_freq_high_60dB.kHz"]]), !is.na(.data[["Audible_freq_low_60dB.kHz"]])) %>%
    transmute(Species, Measure="Hearing_range.octaves", Medium="air", Units="octaves",
              Value = round(log2(.data[["Audible_freq_high_60dB.kHz"]] /
                                 .data[["Audible_freq_low_60dB.kHz"]]), 6),
              n_studies = 0L, Sources = "DERIVED from the merged limits", Study_keys = "",
              Data_role = "derived", value_origin = "recomputed", value_range = ""))
}
long <- long %>% arrange(Species, Measure, Medium) %>%
  select(Species, Measure, Units, Value, Medium, n_studies, Sources, Study_keys,
         Data_role, value_origin, value_range)

## ---- 5. write ---------------------------------------------------------------------------
write.csv(long, "sensory_long.csv", row.names = FALSE, na = "")
write.csv(rows %>% select(Species, Measure, Value, Medium, population, Source_item,
                          Study_key, value_origin, Data_role, note),
          "sensory_unfiltered.csv", row.names = FALSE, na = "")
write.csv(dropped %>% select(Species, Measure, Value, Medium, Source_item, Study_key,
                             shared_study, kept_from, kept_value, agrees),
          "sensory_dedupe_report.csv", row.names = FALSE, na = "")
write.csv(superseded %>% select(Species, Measure, Value, Medium, Source_item, Study_key),
          "sensory_superseded_report.csv", row.names = FALSE, na = "")
## wide table is IN-AIR only; underwater measurements stay in sensory_long.csv
write.csv(long %>% filter(Medium == "air") %>%
            select(Species, Measure, Value) %>%
            pivot_wider(names_from = Measure, values_from = Value) %>% arrange(Species),
          "sensory_wide.csv", row.names = FALSE, na = "")
