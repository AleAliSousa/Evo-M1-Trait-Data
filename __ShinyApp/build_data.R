#!/usr/bin/env Rscript
# =============================================================================
# build_data.R  --  regenerate the Shiny app's derived data from the canonical
# repo files. data/ holds only:
#   * evom1_traits_long.csv  (DERIVED: melted from ____EvoM1_TraitTable/*.xlsx)
#   * source_manifest.csv    (DERIVED: source-table catalogue + citations)
#   * volumes_long.csv, cellcounts_long.csv  (small fallback copies)
#
# The app reads everything from GitHub at runtime; these files are the fallback
# plus the two things that don't exist anywhere else. Re-run whenever the merge
# or trait tables change, then commit + push:
#
#     Rscript __ShinyApp/build_data.R
#
# Requires: readxl  (install.packages("readxl"))
# =============================================================================

suppressWarnings(suppressMessages(library(readxl)))

# ---- locate repo root (parent of this script's folder) ----------------------
args     <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
app_dir  <- if (length(file_arg)) dirname(normalizePath(file_arg)) else getwd()
repo     <- normalizePath(file.path(app_dir, ".."))
out      <- file.path(app_dir, "data")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
message("repo: ", repo)
message("out:  ", out)

trim <- function(x) trimws(as.character(x))

# ---- 1. fallback copies of the two compiled long tables ---------------------
invisible(file.copy(file.path(repo, "__merging_volumes", "volumes_long.csv"),
          file.path(out, "volumes_long.csv"), overwrite = TRUE))
invisible(file.copy(file.path(repo, "__merging_cellcounts", "cellcounts_long.csv"),
          file.path(out, "cellcounts_long.csv"), overwrite = TRUE))
# canonical variable map + species aliases (fallback copies for offline mode)
invisible(file.copy(file.path(repo, "_keys", "variable_canonical.csv"),
          file.path(out, "variable_canonical.csv"), overwrite = TRUE))
invisible(file.copy(file.path(repo, "_keys", "species_display_aliases.csv"),
          file.path(out, "species_display_aliases.csv"), overwrite = TRUE))
# authoritative body-mass & brain-mass merges (single source of truth for those
# measures; the app supersedes the raw body/brain-mass columns with these)
invisible(file.copy(file.path(repo, "__merging_body_ecology", "body_ecology_long.csv"),
          file.path(out, "body_ecology_long.csv"), overwrite = TRUE))
invisible(file.copy(file.path(repo, "__merging_brain_mass", "brain_mass_long.csv"),
          file.path(out, "brain_mass_long.csv"), overwrite = TRUE))
# behavioural traits: one keyed merge (vocal repertoire, dexterity, gait,
# locomotion, handedness, manipulation), resolved per species with source keys.
invisible(file.copy(file.path(repo, "__merging_behaviour", "behaviour_long.csv"),
          file.path(out, "behaviour_long.csv"), overwrite = TRUE))
# cerebellar folding/surface measurements are method-specific and therefore live
# in their own merge rather than being pooled with Ashwell foliation or cortical GI.
invisible(file.copy(file.path(repo, "__merging_cerebellar_folding", "cerebellar_folding_long.csv"),
          file.path(out, "cerebellar_folding_long.csv"), overwrite = TRUE))
# species taxonomy lookup (Order/Family) for the plot clade filter
invisible(file.copy(file.path(repo, "_keys", "species_taxonomy.csv"),
          file.path(out, "species_taxonomy.csv"), overwrite = TRUE))
# mammal phylogeny for PGLS (optional — copy whichever tree file is present)
for (e in c("nwk", "tre", "newick", "nex", "tree")) {
  src <- file.path(repo, "_keys", paste0("mammal_tree.", e))
  if (file.exists(src))
    invisible(file.copy(src, file.path(out, paste0("mammal_tree.", e)), overwrite = TRUE))
}

# ---- 2. melt the EvoM1 trait tables -> evom1_traits_long.csv -----------------
TT <- file.path(repo, "____EvoM1_TraitTable")
# Label = the publication each file's values come from (shown as the app's
# Source column). Per-cell "<col>_Ref"/"_Source" columns override this where the
# source table records a value-specific primary reference (e.g. CST fibre data).
trait_files <- c(
  "dexterity_corticospinaltract.xlsx" = "Heffner & Masterton 1975 (corticospinal tract)",
  "corticospinaltract_etc.xlsx"       = "Iwaniuk et al. 1999 (corticospinal tract & ecology)",
  "glia_gyrification.xlsx"            = "Lewitus et al. 2014 (glia, gyrification & life history)",
  "interlaminar_astrocytes.xlsx"      = "Falcone et al. 2019 (interlaminar astrocytes)",
  "diet_foraging.xlsx"               = "Wilman et al. 2014 (EltonTraits diet & foraging)",
  "v1_synapses_karl.xlsx"            = "Karl et al. 2024 (V1 synapses & mitochondria)",
  "sleep.xlsx"                       = "Eagleman & Vaughn 2021 / Herculano-Houzel 2015 (sleep)"
  # NB: behavioural traits (vocal repertoire, dexterity, gait, locomotion,
  # handedness, manipulation) are NOT melted here. They live in their own keyed
  # merge, __merging_behaviour/behaviour_long.csv, loaded by the app via
  # std_merge() like body_ecology / brain_mass. The dexterity_* and
  # locomotion/gait/manipulation/handedness trait tables feed that merge, not the
  # app melt.
)
# Columns skipped when melting: species identifiers + taxonomy. Taxonomy
# (Order/Suborder/Family/…) is NOT a measurement — it lives in the separate
# species_taxonomy.csv lookup used for the plot clade filter, not as a variable.
id_cols  <- c("species_sci", "Species", "Animal", "Species Generic Name",
              "Order", "Suborder", "Family", "Infraclass", "Parvorder",
              "Phylo_rank", "phylo1_sci", "phylo2_sci")
suffixes <- c("_Source", " Source", "_Ref", " Ref", "_ref", " ref")
is_src   <- function(c) any(endsWith(c, suffixes))
base_of  <- function(c) { for (s in suffixes) if (endsWith(c, s))
                            return(trimws(substr(c, 1, nchar(c) - nchar(s)))); c }
# Species key: prefer the harmonised binomial (species_sci) over the paper's
# printed name, then normalise (drop *, underscores->space) so trait species
# match the cell-count / volume species and can be correlated.
clean_sp <- function(x) {
  x <- gsub("\\*", "", trim(x)); x <- gsub("_", " ", x)
  trimws(gsub("\\s+", " ", x))
}

trait_rows <- vector("list", 0L)
for (i in seq_along(trait_files)) {
  fn <- names(trait_files)[i]; label <- unname(trait_files[i])
  d  <- as.data.frame(read_excel(file.path(TT, fn), sheet = "Sheet1",
                                 col_types = "text", .name_repair = "minimal"),
                      stringsAsFactors = FALSE, check.names = FALSE)
  cols <- names(d)
  src_map <- list()
  for (cn in cols) if (nzchar(cn) && is_src(cn)) src_map[[base_of(cn)]] <- cn
  has_sci <- "species_sci" %in% cols
  sp_col  <- if ("Species" %in% cols) "Species" else cols[1]
  for (r in seq_len(nrow(d))) {
    sci <- if (has_sci) d[["species_sci"]][r] else NA
    sp  <- if (!is.na(sci) && nzchar(trim(sci)) && tolower(trim(sci)) != "none")
             sci else d[[sp_col]][r]
    if (is.na(sp) || !nzchar(trim(sp)) || tolower(trim(sp)) == "none") next
    sp <- clean_sp(sp)
    for (cn in cols) {
      if (!nzchar(cn) || cn %in% id_cols || is_src(cn)) next
      v <- d[[cn]][r]
      if (is.na(v)) next
      vs <- trim(v)
      if (!nzchar(vs) || tolower(vs) %in% c("na", "nan", "none", "-")) next
      src <- label
      sc  <- src_map[[cn]]
      if (!is.null(sc)) {
        sv <- d[[sc]][r]
        if (!is.na(sv) && nzchar(trim(sv))) src <- trim(sv)
      }
      trait_rows[[length(trait_rows) + 1L]] <-
        data.frame(Species = sp, Variable = cn, Value = vs, Source = src,
                   stringsAsFactors = FALSE)
    }
  }
}
traits <- unique(do.call(rbind, trait_rows))
write.csv(traits, file.path(out, "evom1_traits_long.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
message("evom1 traits rows: ", nrow(traits))

# ---- 3. index the public source tables (served from GitHub, not copied) -----
pub  <- file.path(repo, "__Public", "comparative-data")
tsvs <- sort(list.files(pub, pattern = "\\.tsv$"))
mds  <- list.files(pub, pattern = "\\.ReadMe\\.md$")
message("source tables indexed (served from GitHub): ", length(tsvs))

# ---- 4. build source_manifest.csv (filenames + citations from __ReadMe.xlsx) -
readme <- as.data.frame(read_excel(file.path(repo, "__ReadMe.xlsx"),
                                   sheet = "Sheet1", col_types = "text",
                                   .name_repair = "minimal"),
                        stringsAsFactors = FALSE, check.names = FALSE)
enc_col  <- "Item encoded"
cit_col  <- "Citation (APA 7th-Annotated)"
auth_col <- "1st Author"; year_col <- "year"
readme[[enc_col]] <- as.character(readme[[enc_col]])
by_enc   <- readme[!is.na(readme[[enc_col]]) & nzchar(readme[[enc_col]]), ]
enc_pref <- sub("_.*$", "", by_enc[[enc_col]])

rows <- lapply(tsvs, function(fn) {
  base <- sub("\\.tsv$", "", fn)
  if (grepl("_", base)) {
    label     <- sub("^.*_([^_]*)$", "\\1", base)
    ident_enc <- sub("^(.*)_[^_]*$", "\\1", base)
  } else { label <- ""; ident_enc <- base }
  ident <- utils::URLdecode(ident_enc)

  url <- ""; kind <- "Other"
  if (startsWith(ident, "10.")) {
    url <- paste0("https://doi.org/", ident); kind <- "DOI"
  } else if (grepl("^PMID", ident, ignore.case = TRUE)) {
    url  <- paste0("https://pubmed.ncbi.nlm.nih.gov/", gsub("[^0-9]", "", ident), "/")
    kind <- "PubMed"
  } else if (grepl("^UMI", ident, ignore.case = TRUE)) {
    kind <- "Dissertation (ProQuest)"
  }

  hit <- which(by_enc[[enc_col]] == base)
  if (!length(hit)) hit <- which(enc_pref == ident_enc)
  cit <- auth <- yr <- ""
  if (length(hit)) {
    h <- hit[1]
    cit  <- trim(by_enc[[cit_col]][h]);  if (is.na(cit)  || cit  == "NA") cit  <- ""
    auth <- trim(by_enc[[auth_col]][h]); if (is.na(auth) || auth == "NA") auth <- ""
    yr   <- trim(by_enc[[year_col]][h]); if (is.na(yr)   || yr   == "NA") yr   <- ""
  }
  short <- if (nzchar(auth) && nzchar(yr)) sprintf("%s et al. (%s)", auth, yr)
           else if (nzchar(auth)) auth
           else if (nzchar(cit)) substr(strsplit(cit, ".", fixed = TRUE)[[1]][1], 1, 60)
           else ident

  rm <- ""
  for (cand in c(paste0(base, ".ReadMe.md"), paste0(ident_enc, ".ReadMe.md")))
    if (cand %in% mds) { rm <- cand; break }

  # Count rows/cols and read the header via readLines — robust to ragged rows
  # and stray quotes/tabs that make read.delim throw "more columns than names".
  ln <- readLines(file.path(pub, fn), warn = FALSE, encoding = "UTF-8")
  ln <- ln[nzchar(ln)]
  hdr <- if (length(ln)) strsplit(ln[1], "\t", fixed = TRUE)[[1]] else character(0)
  hdr <- gsub('^"|"$', "", hdr)                 # strip surrounding quotes
  data.frame(file = fn, identifier = ident, id_type = kind, table_label = label,
             url = url, readme = rm,
             n_rows = max(0L, length(ln) - 1L), n_cols = length(hdr),
             columns = paste(hdr, collapse = "; "),
             citation = cit, citation_short = short,
             first_author = auth, year = yr,
             stringsAsFactors = FALSE)
})
manifest <- do.call(rbind, rows)
write.csv(manifest, file.path(out, "source_manifest.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
message("manifest rows: ", nrow(manifest),
        " | with citation: ", sum(nzchar(manifest$citation)))
message("DONE -> ", out)
