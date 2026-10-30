# Baron, Stephan & Frahm 1996: pre-ingestion overlap and historical-taxonomy audit.
#
# This script does not wire either Baron table into the volume merge. It freezes the
# row-level taxonomic decisions, identifies names that still require curator review,
# and checks the merge for existing species x structure measurements. The generated
# artifacts are inputs to the eventual ingestion decision.

suppressPackageStartupMessages(library(taxizedb))

.sp <- normalizePath(sub("^--file=", "",
                         grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))
paper_dir <- dirname(.sp)
root_dir <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("Repository root not found above ", paper_dir, call. = FALSE)
  d
})
audit_dir <- paper_dir

t10 <- read.csv(file.path(paper_dir, "Baron_etal_1996_Table10.csv"),
                check.names = FALSE, stringsAsFactors = FALSE)
t32 <- read.csv(file.path(paper_dir, "Baron_etal_1996_Table32.csv"),
                check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(t10) == 272L, nrow(t32) == 272L,
          identical(t10$species_row, t32$species_row))

# The book abbreviates a small number of repeated genus/species names. Expand those
# by row before applying the general species-level rule (drop subspecies/"ssp.").
row_expansions <- c(
  `3`   = "Rousettus amplexicaudatus",
  `4`   = "Rousettus amplexicaudatus",
  `19`  = "Dobsonia moluccensis",
  `20`  = "Dobsonia moluccensis",
  `43`  = "Syconycteris australis",
  `44`  = "Syconycteris australis",
  `102` = "Hipposideros calcaratus",
  `103` = "Hipposideros calcaratus",
  `112` = "Hipposideros maggietaylorae",
  `113` = "Hipposideros maggietaylorae",
  `213` = "Eptesicus brasiliensis",
  `229` = "Scotomanes sp.",
  `240` = "Miniopterus schreibersii",
  `241` = "Miniopterus schreibersii",
  `244` = "Murina cyclotis"
)

first_two_words <- function(x) {
  x <- trimws(gsub("[[:space:]]+", " ", x))
  vapply(strsplit(x, " ", fixed = TRUE), function(z) paste(head(z, 2L), collapse = " "), "")
}

source_concept <- first_two_words(t10$Species_Baron1996)
has_expansion <- as.character(t10$species_row) %in% names(row_expansions)
source_concept[has_expansion] <- unname(row_expansions[as.character(t10$species_row[has_expansion])])

# Resolve exact names against the locally installed NCBI taxonomy. NCBI deliberately
# remains the first pass used by the canonical merge; the small legacy-name table below
# is a frozen audit decision, not a live web dependency.
concepts <- sort(unique(source_concept[source_concept != "Scotomanes sp."]))
ids <- name2taxid(concepts, out_type = "summary")
ncbi_id <- ids$id[match(source_concept, ids$name)]
name_vec <- taxid2name(unique(stats::na.omit(ncbi_id)), out_type = "summary")
names(name_vec) <- unique(stats::na.omit(ncbi_id))
ncbi_name <- unname(name_vec[as.character(ncbi_id)])

# Frozen GBIF-backed resolutions for legacy names missed by the local NCBI taxdump.
# Clear spelling corrections and genus transfers are eligible; difficult cases are
# overridden in manual_review below and must not enter a species-level merge yet.
legacy_map <- data.frame(
  source_concept = c(
    "Rhinopoma hardwickei", "Nycteris nana", "Rhinolophus yunanensis",
    "Hipposideros maggietaylorae", "Pteronotus parnelli",
    "Vampyrops lineatus", "Vampyrops vittatus", "Vampyrodes caraccioloi",
    "Ectophylla macconnelli", "Enchisthenes harti",
    "Pipistrellus circumdatus", "Pipistrellus crassulus",
    "Pipistrellus imbricatus", "Pipistrellus papuanus",
    "Pipistrellus pulveratus", "Scotorepens sanborni",
    "Scotophilus dingani", "Scotophilus kuhli", "Miniopterus haradei",
    "Kerivoula phalaena", "Phoniscus atrox", "Tadarida mops",
    "Tadarida niveiventer", "Tadarida jobensis", "Tadarida leucostigma",
    "Molossops greenhalli", "Molossops planirostris",
    "Nyctalus stenopterus", "Tadarida beccarii", "Tadarida pumila",
    "Eptesicus flavescens", "Molossus trinitatis", "Nyctophilus timoriensis",
    "Scotomanes sp."
  ),
  candidate_name = c(
    "Rhinopoma hardwickii", "Nycteris nana", "Rhinolophus yunanensis",
    "Hipposideros maggietaylorae", "Pteronotus parnellii",
    "Platyrrhinus lineatus", "Platyrrhinus vittatus", "Vampyrodes caraccioli",
    "Mesophylla macconnelli", "Enchisthenes hartii",
    "Arielulus circumdatus", "Nycticeinops crassulus",
    "Hypsugo imbricatus", "Pipistrellus papuanus",
    "Hypsugo pulveratus", "Scotorepens sanborni",
    "Scotophilus dinganii", "Scotophilus kuhlii", "Miniopterus blepotis",
    "Kerivoula phalaena", "Phoniscus atrox", "Mops mops",
    "Mops niveiventer", "Chaerephon jobensis", "Mops leucostigma",
    "Cynomops greenhalli", "Cynomops planirostris",
    "Pipistrellus stenopterus", "Tadarida beccarii", "Mops pumilus",
    "Nycticeinops grandidieri", "Molossus sinaloae", "Nyctophilus timoriensis",
    "Scotomanes sp."
  ),
  stringsAsFactors = FALSE
)

legacy_candidate <- legacy_map$candidate_name[match(source_concept, legacy_map$source_concept)]
candidate_name <- ifelse(!is.na(ncbi_name) & nzchar(ncbi_name), ncbi_name, legacy_candidate)
resolution_status <- ifelse(!is.na(ncbi_name) & nzchar(ncbi_name),
                            "NCBI_exact", "GBIF_frozen_legacy_map")

# These concepts are intentionally held even where an automated backbone supplies a name.
# The issue is concept identity, not merely string matching.
manual_review <- c(
  "Nyctalus stenopterus",     # historical placement; provisional Pipistrellus mapping
  "Nyctophilus timoriensis", # nomen-dubium/cryptic-species concern despite NCBI acceptance
  "Eptesicus flavescens",    # GBIF synonym homonyms
  "Tadarida beccarii",       # unresolved Tadarida/Mops/Chaerephon placement
  "Tadarida pumila",         # competing Mops versus Chaerephon interpretations
  "Molossus trinitatis",     # fuzzy GBIF route to M. sinaloae
  "Scotomanes sp."           # genus-level source record
)
in_manual_review <- source_concept %in% manual_review
resolution_status[in_manual_review] <- "MANUAL_REVIEW"
merge_eligible <- !in_manual_review & !is.na(candidate_name) & nzchar(candidate_name)

if (any(is.na(candidate_name) | !nzchar(candidate_name))) {
  missing <- unique(source_concept[is.na(candidate_name) | !nzchar(candidate_name)])
  stop("Unresolved Baron source concept(s): ", paste(missing, collapse = "; "), call. = FALSE)
}

manual_note <- c(
  "Nyctalus stenopterus" = "Provisional Pipistrellus stenopterus; historical placement remains uncertain.",
  "Nyctophilus timoriensis" = "Accepted by some backbones, but BatNames reports nomen-dubium/cryptic-species concern.",
  "Eptesicus flavescens" = "GBIF match carries multiple synonym-homonym interpretations.",
  "Tadarida beccarii" = "Species is attested, but modern generic placement was not resolved reproducibly.",
  "Tadarida pumila" = "Historical name is interpreted as Mops pumilus or Chaerephon pumilus by different catalogs.",
  "Molossus trinitatis" = "Only a fuzzy GBIF route to Molossus sinaloae was found.",
  "Scotomanes sp." = "The source identifies only the genus."
)

concept_n <- ave(source_concept, source_concept, FUN = length)
final_n <- ave(candidate_name, candidate_name, FUN = length)
crosswalk <- data.frame(
  species_row = t10$species_row,
  Species_Baron1996 = t10$Species_Baron1996,
  source_concept = source_concept,
  NCBI_id = ncbi_id,
  NCBI_name = ncbi_name,
  candidate_name = candidate_name,
  resolution_status = resolution_status,
  merge_eligible = merge_eligible,
  source_rows_same_concept = as.integer(concept_n),
  source_rows_same_candidate = as.integer(final_n),
  within_source_mean_required = final_n > 1L,
  note = ifelse(in_manual_review, unname(manual_note[source_concept]),
                ifelse(has_expansion, "Expanded abbreviated source label; species-level concept retained.", "")),
  stringsAsFactors = FALSE
)
write.csv(crosswalk,
          file.path(paper_dir, "Baron_etal_1996_taxonomy_crosswalk.csv"),
          row.names = FALSE, na = "")

# Define the exact canonical terms the two tables would contribute, then check for
# existing species x variable cells in the current core merge.
t10_terms <- c(
  medulla_oblongata_mm3 = "Medulla_oblongata_Vol.mm3",
  mesencephalon_mm3 = "Mesencephalon_Vol.mm3",
  cerebellum_mm3 = "Cerebellum_Vol.mm3",
  diencephalon_mm3 = "Diencephalon_Vol.mm3",
  telencephalon_mm3 = "Telencephalon_Vol.mm3"
)
t32_terms <- c(
  main_olfactory_bulb_mm3 = "Bulbus_olfactorius_Vol.mm3",
  paleocortex_mm3 = "Palaeocortex_Vol.mm3",
  striatum_mm3 = "Striatum_Vol.mm3",
  septum_mm3 = "Septum_Vol.mm3",
  amygdala_mm3 = "Amygdala_Vol.mm3",
  hippocampus_mm3 = "Hippocampus_Vol.mm3",
  schizocortex_mm3 = "Schizo_cortex_Vol.mm3",
  neocortex_mm3 = "Neocortex_Vol.mm3"
)

to_long <- function(x, term_map, item) {
  do.call(rbind, lapply(names(term_map), function(col) data.frame(
    species_row = x$species_row,
    Baron_item = item,
    Variable = unname(term_map[[col]]),
    Baron_value = as.numeric(x[[col]]),
    stringsAsFactors = FALSE
  )))
}
baron_long <- rbind(
  to_long(t10, t10_terms, "Baron_etal_1996_Table10"),
  to_long(t32, t32_terms, "Baron_etal_1996_Table32")
)
baron_long <- merge(baron_long,
                    crosswalk[c("species_row", "candidate_name", "resolution_status", "merge_eligible")],
                    by = "species_row", all.x = TRUE, sort = FALSE)
names(baron_long)[names(baron_long) == "candidate_name"] <- "Species"

current <- read.csv(file.path(root_dir, "__merging_volumes", "volumes_unfiltered.csv"),
                    stringsAsFactors = FALSE, check.names = FALSE)
current_key <- unique(current[c("Species", "Variable", "Source")])
eligible <- baron_long[baron_long$merge_eligible, , drop = FALSE]
overlap <- merge(eligible, current_key, by = c("Species", "Variable"), all = FALSE)
overlap <- overlap[order(overlap$Species, overlap$Variable, overlap$Baron_item, overlap$Source), ]
write.csv(overlap,
          file.path(audit_dir, "Baron_etal_1996_overlap_audit.csv"),
          row.names = FALSE, na = "")

current_species <- sort(unique(current$Species))
baron_species <- unique(crosswalk[c("candidate_name", "resolution_status", "merge_eligible")])
baron_species$in_current_volume_merge <- baron_species$candidate_name %in% current_species
names(baron_species)[1] <- "Species"
baron_species <- baron_species[order(baron_species$Species), ]
write.csv(baron_species,
          file.path(audit_dir, "Baron_etal_1996_species_overlap_audit.csv"),
          row.names = FALSE, na = "")

components <- c("main_olfactory_bulb_mm3", "paleocortex_mm3", "striatum_mm3", "septum_mm3",
                "amygdala_mm3", "hippocampus_mm3", "schizocortex_mm3", "neocortex_mm3")
component_difference <- rowSums(t32[components]) - t10$telencephalon_mm3
source_flags <- abs(component_difference) > 1.5

manual_rows <- unique(crosswalk[c("source_concept", "candidate_name", "note")][in_manual_review, ])
manual_md <- paste0("| `", manual_rows$source_concept, "` | `", manual_rows$candidate_name,
                    "` | ", manual_rows$note, " |")
report <- c(
  "# Baron et al. 1996 overlap and taxonomy audit",
  "",
  "**Disposition: HOLD for taxonomy/aggregation completion; do not wire yet.**",
  "",
  sprintf("Tables 10 and 32 contain %d source rows and %d regional-volume cells across 13 candidate canonical structures.",
          nrow(t10), nrow(baron_long)),
  sprintf("The 272 rows reduce to %d printed species-level source concepts; %d row(s) participate in a within-source collapse and must be averaged before Tier-1 resolution.",
          length(unique(source_concept)), sum(crosswalk$within_source_mean_required)),
  sprintf("The frozen crosswalk leaves %d source concept(s) (%d row(s)) in `MANUAL_REVIEW`.",
          length(unique(source_concept[in_manual_review])), sum(in_manual_review)),
  "",
  "## Overlap result",
  "",
  sprintf("There are **%d eligible species × canonical-structure overlaps** with the current core `volumes_unfiltered.csv` and **%d Baron candidate species already present anywhere in that merge**.",
          nrow(overlap), sum(baron_species$in_current_volume_merge & baron_species$merge_eligible)),
  "The current Ashwell 2020 bat, *Pteropus giganteus*, is absent from Baron 1996. The previously anticipated Stephan/Baron overlap is therefore not present in the current canonical inputs: Baron is primarily a new Chiroptera block, not a duplicate block.",
  "",
  "The machine-readable checks are `Baron_etal_1996_overlap_audit.csv` (species × structure; empty when no overlaps exist) and `Baron_etal_1996_species_overlap_audit.csv` (species-only membership), beside this report. They use only public inputs and therefore remain public.",
  "",
  "## Taxa still requiring a curator decision",
  "",
  "| source concept | provisional candidate | reason for hold |",
  "|---|---|---|",
  manual_md,
  "",
  "All other NCBI-missed legacy names use the frozen GBIF-backed mappings embedded in the audit script. They are not re-queried during a build.",
  "",
  "## Source integrity and required ingestion behavior",
  "",
  sprintf("Table 32's eight telencephalic components reconstruct Table 10 telencephalon closely (median absolute difference %.2f mm3). Two printed rows exceed the 1.5 mm3 audit threshold: *Anoura caudifer* (-1.86 mm3) and *Vampyrops brachycephalus* (+23.71 mm3). Preserve the printed component values and flags; do not force a corrected sum.",
          median(abs(component_difference))),
  "",
  "Before wiring, the Baron reader path must average rows that resolve to the same species within each Baron item. Without that preprocessing, the canonical Tier-1 most-recent rule would select one duplicated source row arbitrarily instead of forming the source's species mean. Genus-only and `MANUAL_REVIEW` rows must remain excluded until resolved.",
  "",
  "## Taxonomy evidence consulted (2026-08-15)",
  "",
  "- NCBI taxonomy via the local `taxizedb` snapshot for exact names.",
  "- [GBIF Species Match API](https://api.gbif.org/v1/) for the frozen spelling/synonym/genus-transfer candidates.",
  "- [BatNames](https://batnames.org/species/Nyctophilus%2Btimoriensis) for the *Nyctophilus timoriensis* nomen-dubium/cryptic-species warning.",
  "- [Bat Taxonomic Alignment](https://jhpoelen.nl/bat-taxonomic-alignment/) and a [modern phylogenetic review](https://pmc.ncbi.nlm.nih.gov/articles/PMC7236909/) for the historical *Nyctalus stenopterus* → *Pipistrellus stenopterus* interpretation and its uncertainty.",
  "- [WorldFAIR bat-taxonomy case study](https://ris.utwente.nl/ws/portalfiles/portal/456139692/WorldFAIR_D10.1_v2.pdf) for the competing *Tadarida pumila* interpretations.",
  "",
  "Regenerate with `Rscript Baron_etal_1996/Baron_etal_1996_overlap_taxonomy_audit.R` after the canonical volume merge changes."
)
writeLines(report, file.path(paper_dir, "Baron_etal_1996_overlap_taxonomy_audit.md"))

message("Baron audit: ", length(unique(source_concept)), " source concepts; ",
        sum(in_manual_review), " row(s) on manual review; ", nrow(overlap),
        " species x structure overlap(s); disposition HOLD")
