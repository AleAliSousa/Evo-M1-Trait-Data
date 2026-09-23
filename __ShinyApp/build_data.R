#!/usr/bin/env Rscript
# =============================================================================
# build_data.R  --  regenerate the Shiny app's derived data from the canonical
# repo files. data/ holds ONLY the two files that exist nowhere else:
#   * evom1_traits_long.csv  (DERIVED: melted from ____EvoM1_TraitTable/*.xlsx)
#   * source_manifest.csv    (DERIVED: source-table catalogue + citations)
#
# Everything else the app needs is read from its canonical home (_keys/,
# __merging_*/) over GitHub at runtime -- there are no fallback copies, by
# design; see section 1 below. Re-run whenever the merge or trait tables
# change, then commit + push:
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

# ---- 1. no copies live here ------------------------------------------------
# 2026-09-22: data/ used to hold 22 byte-identical copies of files whose real
# home is _keys/ or __merging_*/ -- an offline fallback for the deployed app.
# They were removed deliberately. The reason is not disk space (13 MB) but
# silence: when a copy drifted from its source, the app served the stale copy
# and said so only in the server log, so the UI showed old numbers with nothing
# on screen to say they were old. Reading one canonical copy per file means a
# GitHub outage now fails loudly instead of quietly serving data of unknown
# vintage. See DEPLOY.md "Why data/ holds only two files".
#
# Anything added back here must be a file that exists NOWHERE else in the repo.
# The guard below enforces that, so the copies cannot creep back unnoticed.
canonical_elsewhere <- function(fn) {
  hits <- c(file.path(repo, "_keys", fn),
            Sys.glob(file.path(repo, "__merging_*", fn)))
  hits[file.exists(hits)]
}
dupes <- Filter(function(fn) length(canonical_elsewhere(fn)) > 0,
                setdiff(list.files(out), c("source-tables", ".DS_Store")))
if (length(dupes))
  stop("data/ must not duplicate canonical repo files, but these do:\n  ",
       paste(sprintf("%s  (canonical: %s)", dupes,
                     vapply(dupes, function(f)
                       paste(sub(paste0("^", repo, "/"), "", canonical_elsewhere(f)),
                             collapse = ", "), character(1))),
             collapse = "\n  "),
       "\nDelete them from data/ and let the app read the canonical copy.")

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

# ---- 2b. vetoes: traits_select_value_flags.csv ------------------------------
# The same mechanism __merging_volumes/volumes_select_value_flags.csv gives the
# volumes merge, with the same schema and the same `skip` action, applied to the
# trait melt. It exists because superseding is not always enough: a column can
# be a republication of an earlier source AND carry defects of its own (a
# mis-cited source, an anatomy label the values contradict, a unit error), and
# where its species labels do not collide with the merge's it slips past
# variable_canonical.csv entirely and reaches the app as apparently new data.
#
# Source = trait file name, `*` = all species. A flagged row that matches
# nothing is fatal: a veto silently doing nothing is how a defect comes back.
flags_path <- file.path(TT, "traits_select_value_flags.csv")
if (file.exists(flags_path)) {
  fl <- read.csv(flags_path, stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", encoding = "UTF-8")
  bad_action <- setdiff(unique(trim(fl$action)), c("skip", ""))
  if (length(bad_action))
    stop("traits_select_value_flags.csv: unknown action(s) ",
         paste(bad_action, collapse = ", "), ". Only `skip` is implemented.")
  fl <- fl[trim(fl$action) == "skip", , drop = FALSE]
  # Map the flag's trait-file name to the Source label the melt stamped on rows.
  for (i in seq_len(nrow(fl))) {
    fsrc <- trim(fl$Source[i]); fsp <- trim(fl$Species[i]); fvar <- trim(fl$Variable[i])
    label <- unname(trait_files[fsrc])
    if (is.na(label))
      stop("traits_select_value_flags.csv row ", i, ": Source '", fsrc,
           "' is not one of the melted trait files.")
    sel <- traits$Variable == fvar & traits$Source == label
    if (fsp != "*") sel <- sel & traits$Species == fsp
    if (!any(sel))
      stop("traits_select_value_flags.csv row ", i, " (", fsrc, " / ", fvar,
           ") matched no melted rows. A veto that matches nothing is a broken ",
           "veto -- fix the Source/Variable spelling or remove the row.")
    message("  veto: dropped ", sum(sel), " row(s) -- ", fvar, " [", fsrc, "]")
    traits <- traits[!sel, , drop = FALSE]
  }
}

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
