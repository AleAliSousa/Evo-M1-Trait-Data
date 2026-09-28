#!/usr/bin/env Rscript
#
# Primary-source volume compiler inspired by DeCasien & Higham (2019).
# Run from anywhere: Rscript volumes_compiled_select_DeCasien.R
#
# DATA BOUNDARY: ONLY the independently published source-paper CSVs in this
# repository are inputs. NEVER read the later compilation, a transcription
# recovered from it, or any "unpublishedvia" file. The reconstruction work
# informed the RULES below; it is not data, an executable dependency or a
# validation target. Some measurements in that publication are not independently
# available. Report those as coverage gaps; never backfill them from its table.
#
# Published methods: exclude a whole study if its brain/region definitions
# cannot be reconciled; prefer a later measurement only when it remeasured
# the SAME specimen and region; retain independent, anatomically compatible
# studies and weight species-level means by their actual regional specimen N.
# The paper does not publish a universal source-precedence algorithm. Here
# uncertain identity, anatomy, N and paired brain volume are explicit review
# fields, not assumptions hidden in recency or a source-row count.
#
# KEYS AT DIFFERENT GRAINS:
# source_row_id = paper item + row number (specimen or published source mean);
# candidate_id = source_row_id + ORIGINAL measurement column;
# cell_key = resolved taxon + STANDARDIZED region (only after curation).
# Neither the paper year nor identical numeric values establish specimen
# identity. A source mean with N > 1 is ONE cohort, not N separate rows.
#
# First run writes non-destructive review templates and stops. An existing
# review is NEVER overwritten. Only fully resolved cells enter final outputs;
# candidate/source audits and input hashes are retained even on a review stop.
# This script does not modify source CSVs, the canonical volume merge or any
# restricted file. It has no network requests and uses base R plus optional
# readxl for the original Stephan snapshots that retain printed sample Ns.

script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1]), mustWork = TRUE))
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p, mustWork = TRUE))
  }
  stop("Save the script and run it using Rscript or RStudio Source.", call. = FALSE)
})
folder <- dirname(script_path)
root <- dirname(folder)
source_review_file <- file.path(folder, "volumes_primary_DeCasien_sources.csv")
cell_review_file <- file.path(folder, "volumes_primary_DeCasien_curation.csv")
out <- function(stem) file.path(folder, paste0(stem, "_primary_DeCasien.csv"))
read_csv <- function(p) read.csv(p, stringsAsFactors = FALSE, check.names = FALSE,
                                 fileEncoding = "UTF-8-BOM",
                                 na.strings = c("", "NA"))
write_csv <- function(x, p) write.csv(x, p, row.names = FALSE, na = "")
text <- function(x) {
  y <- as.character(x)
  y[is.na(y)] <- ""
  trimws(y)
}
filled <- function(x) nzchar(text(x))
number <- function(x) suppressWarnings(as.numeric(gsub(",", "", text(x),
                                                       fixed = TRUE)))
tokens <- function(x) {
  if (!filled(x)) return(character())
  z <- tolower(trimws(strsplit(text(x), "|", fixed = TRUE)[[1]]))
  z[nzchar(z)]
}
joined <- function(x) paste(unique(x[nzchar(x)]), collapse = "; ")
identical_value <- function(x, y)
  all(abs(x - y) <= 1e-8 * pmax(1, abs(x), abs(y)))
same_numeric <- function(x, y) {
  if (length(x) != length(y) || any(is.na(x) != is.na(y))) return(FALSE)
  ok <- !is.na(x)
  identical_value(x[ok], y[ok])
}

# Local targets are distinct by laterality, tissue compartment and inclusion
# of nucleus accumbens. Add a new key only after checking the primary paper.
regions <- paste0(c(
  "Medulla_oblongata", "Cerebellum", "Mesencephalon", "Diencephalon",
  "Telencephalon", "Bulbus_olfactorius", "Bulbus_olfactorius_accessorius",
  "Lobus_piriformis", "Septum", "Striatum", "Striatum_incl_NAcc",
  "Schizo_cortex", "Hippocampus", "Neocortex", "Neocortex_grey_matter",
  "Epithalamus", "Thalamus", "Hypothalamus", "Subthalamus", "Pallidum",
  "Nucleus_subthalamicus", "Tractus_opticus", "Area_striata_grey_matter",
  "Corpus_geniculatum_laterale", "Palaeocortex", "Amygdala",
  "Nucleus_motorius_nervi_trigemini_left", "Nucleus_facialis_left",
  "Nucleus_hypoglossus_left", "Granular_insular_cortex",
  "Dysgranular_insular_cortex", "Agranular_insular_cortex", "Insula"
), "_Vol.mm3")
stopifnot(length(regions) == 33L, !anyDuplicated(regions))

# Admissions are SUGGESTIONS until the independent source registry below is
# reviewed. These are the source-paper tables relevant to the methods, not a
# download of, or a link to, the later compilation. Printed per-individual
# rows remain rows; unlike volumes_compiled_select.R nothing is pre-averaged.
stephan <- paste0("Stephan_etal_1981_Table",
                  c("I", "II", "III", "IV", "V", "VI", "VII", "VIII",
                    "IX", "X", "XI"))
items <- c(
  stephan, "Stephan_etal_1970_Tables1-6", "Frahm_etal_1984_Table1",
  "Bauernfeind_etal_2013_Table1", "Bauernfeind_etal_2013_Table2",
  "Sherwood_etal_2005_Table1", "Bush_Allman_2004_a_Table2",
  "Bush_Allman_2004_b_TABLE1", "Barger_etal_2007_TABLE1",
  "Barger_etal_2014_Table1", "Stimpson_etal_2015_TableS2",
  "Zilles_Rehk\u00e4mper_1988_Table12-2",
  "deSousa_etal_2010_Table1", "deSousa_etal_2010_SupTable2",
  "MacLeod_etal_2003_Table1", "MacLeod_etal_2003_Table2",
  "Rilling_Insel_1998_Table1", "Rilling_Insel_1999_Table1",
  "Sherwood_etal_2004_TABLEI", "Barks_etal_2014_TABLE1",
  "Barks_etal_2014_Fig4A"
)
papers <- c(
  rep("Stephan_etal_1981", length(stephan)), "Stephan_etal_1970",
  "Frahm_etal_1984", rep("Bauernfeind_etal_2013", 2),
  "Sherwood_etal_2005", "Bush_Allman_2004_a", "Bush_Allman_2004_b",
  "Barger_etal_2007", "Barger_etal_2014", "Stimpson_etal_2015",
  "Zilles_Rehk\u00e4mper_1988", rep("deSousa_etal_2010", 2),
  rep("MacLeod_etal_2003", 2), "Rilling_Insel_1998",
  "Rilling_Insel_1999", "Sherwood_etal_2004",
  rep("Barks_etal_2014", 2)
)
years <- c(rep(1981L, length(stephan)), 1970L, 1984L,
           2013L, 2013L, 2005L, 2004L, 2004L, 2007L, 2014L,
           2015L, 1988L, 2010L, 2010L, 2003L, 2003L,
           1998L, 1999L, 2004L, 2014L, 2014L)
n_rules <- c(
  rep("snapshot", length(stephan)), "not_printed", "column:n",
  "per_individual", "per_individual", "column:N",
  "not_printed", "not_printed", "per_individual",
  "per_individual", "per_individual", "not_printed",
  "per_individual", "by_measure", "per_individual", "per_individual",
  "sum:n_males,n_females", "column:n_total", "per_individual",
  "per_individual", "not_printed"
)
specimen_columns <- c(
  rep("", length(stephan)), "", "", "Individual", "Individual",
  "", "", "", "individual", "individual", "subject",
  "", "code", "", "specimen", "specimen",
  "", "", "Specimen", "Specimen", ""
)
stopifnot(length(items) == length(papers), length(items) == length(years),
          length(items) == length(n_rules),
          length(items) == length(specimen_columns), !anyDuplicated(items))
catalog <- data.frame(
  Source = items, paper = papers, year = years, n_rule = n_rules,
  specimen_column = specimen_columns, stringsAsFactors = FALSE
)
catalog$source_file <- file.path(root, catalog$paper,
                                 paste0(catalog$Source, ".csv"))
catalog$term_file <- file.path(folder, "standardized_term_by_reference",
                              paste0(catalog$Source, "_standardized_terms.csv"))
# Hard safety rule: no generated/circular values, whatever a future registry
# or manifest says. No name, DOI or pathname of the later dataset is used.
forbidden_path <- function(x) grepl("unpublishedvia|_BrainRegionData|MOESM",
                                   x, ignore.case = TRUE)
if (any(forbidden_path(catalog$source_file)) ||
    any(forbidden_path(catalog$term_file)))
  stop("The source list contains a downstream or circular data product.",
       call. = FALSE)

# Source-aware species keys are curated in this repository. An unmatched
# printed name is kept as printed and flagged, never silently genus-lumped.
species_file <- file.path(root, "_keys", "volumes_species_overrides.csv")
species_keys <- if (file.exists(species_file)) read_csv(species_file) else
  data.frame(Reference = character(), variant_name = character(),
             accepted_name = character())
if (!all(c("Reference", "variant_name", "accepted_name") %in%
         names(species_keys)))
  stop("Source-aware species overrides have an unrecognized schema.",
       call. = FALSE)
species_key <- paste(text(species_keys$Reference),
                     tolower(text(species_keys$variant_name)), sep = "\034")
if (anyDuplicated(species_key))
  stop("Species overrides contain two accepted names for one source label.",
       call. = FALSE)
resolve_species <- function(item, raw_name) {
  i <- match(paste(item, tolower(text(raw_name)), sep = "\034"),
             species_key)
  z <- text(species_keys$accepted_name[i])
  ifelse(nzchar(z), z, text(raw_name))
}

# The study concerns primates. Classify the ORDER from the project's own
# taxonomy, using the genus only when an exact species label is absent. This
# is an order check, NOT a licence to equate two species or to pool genera.
taxonomy_file <- file.path(root, "_keys", "species_taxonomy.csv")
if (!file.exists(taxonomy_file))
  stop("The project taxonomy is needed to exclude non-primate sources.",
       call. = FALSE)
taxonomy <- read_csv(taxonomy_file)
if (!all(c("Species", "Order") %in% names(taxonomy)) ||
    anyDuplicated(tolower(text(taxonomy$Species))))
  stop("Taxonomy has missing or ambiguous species/order fields.",
       call. = FALSE)
taxon_order <- function(x) {
  label <- tolower(gsub("_", " ", text(x), fixed = TRUE))
  exact <- match(label, tolower(text(taxonomy$Species)))
  order <- text(taxonomy$Order[exact])
  for (j in which(!nzchar(order))) {
    genus <- strsplit(label[j], " ", fixed = TRUE)[[1]][1]
    matches <- startsWith(tolower(text(taxonomy$Species)),
                          paste0(genus, " "))
    group <- unique(text(taxonomy$Order[matches]))
    group <- group[nzchar(group)]
    if (length(group) == 1L) order[j] <- group
  }
  order
}

# Whole-brain definitions are a compatibility HINT, never automatic authority.
# The paper-specific definition and any accepted protocol caveat go in the
# source review. Absent entries stay unknown.
basis_file <- file.path(root, "_keys", "brain_size_basis.csv")
basis <- if (file.exists(basis_file)) read_csv(basis_file) else
  data.frame(paper = character(), column = character(),
             poolable_group = character())
if (!all(c("paper", "column", "poolable_group") %in% names(basis)))
  stop("Brain-definition registry has an unrecognized schema.",
       call. = FALSE)

# Source units: inferred only when the printed heading/source conventions
# establish them. A missing scale is a HOLD, not a guessed conversion.
scale_for <- function(item, col) {
  if (grepl("cm3|(^|_)cc($|_)|_cc_", col, ignore.case = TRUE))
    return(1000)
  if (item %in% c("Barger_etal_2007_TABLE1",
                  "Sherwood_etal_2004_TABLEI",
                  "Rilling_Insel_1999_Table1",
                  "Stimpson_etal_2015_TableS2")) return(1000)
  if (grepl("mm3", col, ignore.case = TRUE) ||
      grepl("^(Stephan_etal_19|Frahm_etal_1984|Zilles_Rehk)",
            item)) return(1)
  NA_real_
}

# Stephan's cleaned CSVs dropped the n for each code-range sub-table. Read
# that n from the SAME SOURCE'S frozen snapshot, never from another compiler.
# Verify a mapped printed numeric column before trusting a species-name join.
snapshot_N <- function(df, item) {
  p <- file.path(root, "Stephan_etal_1981",
                 paste0(item, "_snapshot.xlsx"))
  if (!file.exists(p) || !requireNamespace("readxl", quietly = TRUE))
    return(rep(NA_real_, nrow(df)))
  tab <- sub("^Stephan_etal_1981_", "", item)
  s <- as.data.frame(readxl::read_excel(p, sheet = tab, skip = 1,
                                        .name_repair = "minimal"),
                     stringsAsFactors = FALSE)
  ncol_name <- grep("^n \\(", names(s), value = TRUE)
  if (length(ncol_name) != 1L || !"species" %in% names(s))
    stop("Source snapshot has no unique code-range N.", call. = FALSE)
  sk <- tolower(text(s$species))
  dk <- tolower(text(df$species))
  if (anyDuplicated(sk) || any(is.na(match(dk, sk))))
    stop("Ambiguous species join to the original source snapshot.",
         call. = FALSE)
  ix <- match(dk, sk)
  anchor <- sub(" \\([0-9]+\\)$", "", names(s))
  shared <- intersect(names(df), anchor)
  shared <- setdiff(shared, c("species", "group"))
  checked <- FALSE
  for (nm in shared) {
    a <- number(df[[nm]])
    b <- number(s[[match(nm, anchor)]][ix])
    comparable <- is.finite(a) & is.finite(b)
    if (!any(comparable)) next
    if (!identical_value(a[comparable], b[comparable]))
      stop("Original snapshot and source CSV disagree on ", nm, ".",
           call. = FALSE)
    checked <- TRUE
    break
  }
  if (!checked)
    stop("Could not verify the snapshot species join using a printed value.",
         call. = FALSE)
  source_inputs <<- c(source_inputs, p)
  number(s[[ncol_name]][ix])
}

N_for <- function(df, item, rule, source_col, snapshot_n) {
  if (identical(rule, "per_individual")) return(rep(1, nrow(df)))
  if (identical(rule, "snapshot")) return(snapshot_n)
  if (startsWith(rule, "column:")) {
    nm <- sub("^column:", "", rule)
    return(if (nm %in% names(df)) number(df[[nm]]) else
             rep(NA_real_, nrow(df)))
  }
  if (startsWith(rule, "sum:")) {
    cols <- strsplit(sub("^sum:", "", rule), ",", fixed = TRUE)[[1]]
    return(if (all(cols %in% names(df)))
      rowSums(do.call(cbind, lapply(df[cols], number)),
              na.rm = FALSE) else
        rep(NA_real_, nrow(df)))
  }
  if (identical(rule, "by_measure")) {
    n_by_col <- c(brain_volume_cm3 = "brain_N",
                  neocortex_volume_cm3 = "neocortex_N",
                  V1_area_striata_volume_cm3 = "V1_N",
                  LGN_volume_cm3 = "LGN_N")
    nm <- unname(n_by_col[source_col])
    return(if (length(nm) && !is.na(nm) && nm %in% names(df))
      number(df[[nm]]) else rep(NA_real_, nrow(df)))
  }
  rep(NA_real_, nrow(df))  # explicitly not printed
}

# The Stephan 1970 compilation has no current per-item term map; these names
# come from that independently transcribed primary table. It has no printed
# per-species N and therefore remains on hold until a supported N is supplied.
legacy_1970_map <- c(
  total_brain_net_mm3 = "Total_brain_net_volume_Vol.mm3",
  medulla_oblongata_mm3 = "Medulla_oblongata_Vol.mm3",
  cerebellum_mm3 = "Cerebellum_Vol.mm3",
  mesencephalon_mm3 = "Mesencephalon_Vol.mm3",
  diencephalon_mm3 = "Diencephalon_Vol.mm3",
  telencephalon_mm3 = "Telencephalon_Vol.mm3",
  bulbus_olfactorius_mm3 = "Bulbus_olfactorius_Vol.mm3",
  septum_mm3 = "Septum_Vol.mm3",
  striatum_mm3 = "Striatum_Vol.mm3",
  schizocortex_mm3 = "Schizo_cortex_Vol.mm3",
  hippocampus_mm3 = "Hippocampus_Vol.mm3",
  neocortex_mm3 = "Neocortex_Vol.mm3"
)
empty_candidate <- data.frame(
  candidate_id = character(), source_row_id = character(),
  Source = character(), source_paper = character(), Year = integer(),
  source_file = character(), term_file = character(),
  species_as_printed = character(), Species = character(),
  species_basis = character(), specimen_hint = character(),
  original_column = character(), Variable = character(),
  Value_original = numeric(), unit_scale = numeric(), Value_mm3 = numeric(),
  N_hint = numeric(), N_rule = character(), BV_hint = numeric(),
  BV_N_hint = numeric(), brain_basis_hint = character(),
  source_grain = character(), policy_reason = character(),
  policy_evidence = character(), stringsAsFactors = FALSE
)

source_issues <- character(nrow(catalog))
source_counts <- integer(nrow(catalog))
source_inputs <- character()
read_one <- function(i) {
  item <- catalog$Source[i]
  p <- catalog$source_file[i]
  mpath <- catalog$term_file[i]
  if (!file.exists(p)) {
    source_issues[i] <<- "primary source table not present"
    return(empty_candidate)
  }
  if (forbidden_path(p)) stop("Circular or downstream data path rejected.",
                               call. = FALSE)
  if (!file.exists(mpath) && item != "Stephan_etal_1970_Tables1-6") {
    source_issues[i] <<- "anatomical term map not present"
    return(empty_candidate)
  }
  df <- read_csv(p)
  if (!nrow(df)) {
    source_issues[i] <<- "empty primary source table"
    return(empty_candidate)
  }
  if (item == "Stephan_etal_1970_Tables1-6") {
    term <- data.frame(Original_Term = c("species", names(legacy_1970_map)),
      Standardized_Term = c("Species", unname(legacy_1970_map)))
  } else {
    term <- read_csv(mpath)
    if (!all(c("Original_Term", "Standardized_Term") %in% names(term)))
      stop("Invalid per-paper term map for ", item, ".", call. = FALSE)
    source_inputs <<- c(source_inputs, mpath)
  }
  term$Original_Term <- text(term$Original_Term)
  term$Standardized_Term <- text(term$Standardized_Term)
  if (anyDuplicated(term$Original_Term))
    stop("One source column maps to multiple anatomical terms in ", item,
         ".", call. = FALSE)
  # Source converters and term maps occasionally differ only in header
  # capitalization/punctuation (e.g. MacLeod "species" versus "Species").
  # Canonicalize headings, never values; refuse ambiguous collisions.
  folded <- function(x) tolower(gsub("[ ._]+", "", x))
  if (anyDuplicated(folded(term$Original_Term)))
    stop("Anatomical term map has ambiguous folded column names in ", item,
         ".", call. = FALSE)
  rename_i <- match(folded(names(df)), folded(term$Original_Term))
  renamed <- term$Original_Term[rename_i]
  names(df)[!is.na(rename_i)] <- renamed[!is.na(rename_i)]
  if (anyDuplicated(names(df)))
    stop("Two source columns collapse onto one mapped heading in ", item,
         ".", call. = FALSE)
  sp <- term$Original_Term[term$Standardized_Term == "Species"]
  sp <- sp[sp %in% names(df)]
  if (length(sp) != 1L) {
    source_issues[i] <<- "unique printed-species field missing"
    return(empty_candidate)
  }
  source_inputs <<- c(source_inputs, p)
  raw_species <- text(df[[sp]])
  if (any(!filled(raw_species))) {
    source_issues[i] <<- "source rows without species; inspect before use"
    return(empty_candidate)
  }
  identity_key <- paste(item, tolower(raw_species), sep = "\034")
  curated <- match(identity_key, species_key)
  accepted <- resolve_species(item, raw_species)
  taxon_basis <- ifelse(!is.na(curated), "source-aware curated override",
                        "printed label, not independently harmonized")
  idcol <- catalog$specimen_column[i]
  specimen_hint <- if (nzchar(idcol) && idcol %in% names(df))
    text(df[[idcol]]) else rep("", nrow(df))
  row_id <- sprintf("%s#%05d", item, seq_len(nrow(df)))
  rule <- catalog$n_rule[i]
  sn <- if (rule == "snapshot") {
    tryCatch(snapshot_N(df, item), error = function(e) {
      warning("Original source snapshot N could not be independently checked ",
              "for ", item, "; leave those cells on hold until reviewed.",
              call. = FALSE)
      rep(NA_real_, nrow(df))
    })
  } else rep(NA_real_, nrow(df))

  bv_term <- term$Original_Term[
    term$Standardized_Term %in%
      c("Total_brain_net_volume_Vol.mm3", "Total_brain_volume_Vol.mm3")]
  bv_term <- bv_term[bv_term %in% names(df)]
  bv_col <- if (length(bv_term) == 1L) bv_term else ""
  bv_scale <- if (nzchar(bv_col)) scale_for(item, bv_col) else NA_real_
  bv <- if (nzchar(bv_col) && is.finite(bv_scale))
    number(df[[bv_col]]) * bv_scale else rep(NA_real_, nrow(df))
  bv_n <- if (nzchar(bv_col))
    N_for(df, item, rule, bv_col, sn) else rep(NA_real_, nrow(df))
  bkey <- if (nzchar(bv_col))
    match(paste(catalog$paper[i], bv_col, sep = "\034"),
          paste(text(basis$paper), text(basis$column), sep = "\034"))
  else NA_integer_
  brain_basis_hint <- text(basis$poolable_group[bkey])
  if (!length(brain_basis_hint)) brain_basis_hint <- ""

  selected <- term[grepl("_Vol\\.mm3$", term$Standardized_Term) &
                     term$Original_Term %in% names(df) &
                     !(term$Original_Term %in% bv_term), , drop = FALSE]
  parts <- list()
  if (item == "Zilles_Rehk\u00e4mper_1988_Table12-2") {
    if (!all(c("structure", "volume_mm3") %in% names(df)))
      stop("Zilles structure-row source changed shape.", call. = FALSE)
    z <- match(text(df$structure), term$Original_Term)
    for (j in which(!is.na(z))) {
      target <- term$Standardized_Term[z[j]]
      if (!grepl("_Vol\\.mm3$", target)) next
      val <- number(df$volume_mm3[j])
      if (!is.finite(val) || val < 0)
        stop("Unusable structure-row volume in ", item, ".", call. = FALSE)
      # The source's "Paleocortex" contains amygdala; the prepiriform
      # component, not that total, is the separate palaeocortex key.
      if (df$structure[j] == "Paleocortex")
        target <- "Lobus_piriformis_Vol.mm3"
      if (df$structure[j] == "Regio praepiriformis")
        target <- "Palaeocortex_Vol.mm3"
      if (df$structure[j] == "Gray (without area striata)")
        target <- "Neocortex_grey_without_V1_Vol.mm3"
      parts[[length(parts) + 1L]] <- data.frame(
        candidate_id = paste(row_id[j], df$structure[j], sep = "::"),
        source_row_id = row_id[j], Source = item,
        source_paper = catalog$paper[i], Year = catalog$year[i],
        source_file = basename(p), term_file = basename(mpath),
        species_as_printed = raw_species[j], Species = accepted[j],
        species_basis = taxon_basis[j], specimen_hint = specimen_hint[j],
        original_column = text(df$structure[j]), Variable = target,
        Value_original = val, unit_scale = 1, Value_mm3 = val,
        # This paper describes two specimens, but the structure-row
        # transcription does not say which measures use one or both.
        N_hint = NA_real_, N_rule = "N per structure not in source table",
        BV_hint = NA_real_, BV_N_hint = NA_real_,
        brain_basis_hint = brain_basis_hint,
        source_grain = "published_mean", policy_reason = "",
        policy_evidence = "", stringsAsFactors = FALSE)
    }
  } else {
    for (j in seq_len(nrow(selected))) {
      col <- selected$Original_Term[j]
      variable <- selected$Standardized_Term[j]
      scale <- scale_for(item, col)
      raw <- number(df[[col]])
      present <- filled(df[[col]])
      if (any(present & !is.finite(raw)))
        stop("Non-numeric source volume in ", item, ": ", col,
             ".", call. = FALSE)
      keep <- which(present)
      if (!length(keep)) next
      n_hint <- N_for(df, item, rule, col, sn)
      if (item == "Barger_etal_2014_Table1" ||
          item == "Stimpson_etal_2015_TableS2") {
        # These source columns describe one side; a bilateral value needs
        # matched L+R or a justified 2x derivation, never a silent rename.
        variable <- sub("_Vol\\.mm3$", "_unilateral_Vol.mm3", variable)
      }
      parts[[length(parts) + 1L]] <- data.frame(
        candidate_id = paste(row_id[keep], col, sep = "::"),
        source_row_id = row_id[keep], Source = item,
        source_paper = catalog$paper[i], Year = catalog$year[i],
        source_file = basename(p), term_file = basename(mpath),
        species_as_printed = raw_species[keep], Species = accepted[keep],
        species_basis = taxon_basis[keep],
        specimen_hint = specimen_hint[keep],
        original_column = col, Variable = variable,
        Value_original = raw[keep], unit_scale = scale,
        Value_mm3 = raw[keep] * scale,
        N_hint = n_hint[keep], N_rule = rule,
        BV_hint = bv[keep], BV_N_hint = bv_n[keep],
        brain_basis_hint = brain_basis_hint,
        source_grain = if (rule == "per_individual") "specimen" else
          "published_mean",
        policy_reason = "", policy_evidence = "",
        stringsAsFactors = FALSE)
    }
  }
  result <- if (length(parts)) do.call(rbind, parts) else empty_candidate
  source_counts[i] <<- nrow(result)
  result
}
candidate <- do.call(rbind, lapply(seq_len(nrow(catalog)), read_one))
if (is.null(candidate) || !nrow(candidate))
  stop("No original source-paper measurements could be read.",
       call. = FALSE)
rownames(candidate) <- NULL
if (anyDuplicated(candidate$candidate_id))
  stop("Primary row/column identifiers are not unique.", call. = FALSE)

# Stephan's striatum includes the nucleus accumbens. Retain its ordinary
# striatum measurement AND offer the same printed value to the inclusive
# analysis arm. This is a *second anatomical key*, not a second animal:
# each target region is aggregated independently and both candidates point
# back to the same primary source row. It remains on hold for source review.
inclusive <- candidate[
  candidate$source_paper %in% c("Stephan_etal_1970", "Stephan_etal_1981") &
    candidate$Variable == "Striatum_Vol.mm3", , drop = FALSE
]
if (nrow(inclusive)) {
  inclusive$candidate_id <- paste0(inclusive$candidate_id, "::incl_NAcc")
  inclusive$target_hint <- "Striatum_incl_NAcc_Vol.mm3"
  inclusive$anatomy_hint <- "Source-defined striatum includes nucleus accumbens"
  candidate$target_hint <- ""
  candidate$anatomy_hint <- ""
  candidate <- rbind(candidate, inclusive[, names(candidate), drop = FALSE])
} else {
  candidate$target_hint <- ""
  candidate$anatomy_hint <- ""
}
if (anyDuplicated(candidate$candidate_id))
  stop("A derived anatomical-arm key collides with a source measurement.",
       call. = FALSE)
source_counts <- vapply(catalog$Source, function(s)
  sum(candidate$Source == s), integer(1))

# Hard exclusions from the methods, source anatomy and the project's source
# notes. These are cell-level decisions, not a blanket newest-paper rule.
veto <- function(x) {
  if (grepl("Semendeferi.*Damasio|Navarrete", x$Source,
            ignore.case = TRUE))
    return("Whole-dataset methods/brain definition incompatible")
  if (grepl("unpublishedvia|_BrainRegionData|MOESM", x$Source,
            ignore.case = TRUE))
    return("Circular/secondary source is prohibited")
  if (x$Source == "Barks_etal_2014_Fig4A" &&
      x$Variable == "Thalamus_Vol.mm3")
    return("Posterior thalamus omitted by this source")
  if (x$Source == "Sherwood_etal_2004_TABLEI" &&
      grepl("^Gorilla([ _]|$)", x$Species) &&
      x$Variable != "Thalamus_Vol.mm3")
    return("Gorilla non-thalamus regions were later remeasured")
  if (grepl("^Stephan_etal_1981_", x$Source) &&
      grepl("^Callicebus[ _]moloch", x$species_as_printed,
            ignore.case = TRUE))
    return("The 1981 components for this taxon do not sum to the whole; review the independent 1970 source instead")
  if (grepl("^Stephan_etal_1981_TableIX$", x$Source) &&
      x$Variable == "Area_striata_Vol.mm3")
    return("Original V1 includes arbitrarily bounded white matter")
  ""
}
candidate$policy_reason <- vapply(seq_len(nrow(candidate)), function(i)
  veto(candidate[i, , drop = FALSE]), character(1))
candidate$policy_evidence[filled(candidate$policy_reason)] <-
  "2019 Methods and Supplementary Appendix; primary source definitions; project source review"
candidate$taxon_order_hint <- taxon_order(candidate$Species)
outside_order <- filled(candidate$taxon_order_hint) &
  candidate$taxon_order_hint != "Primates"
candidate$policy_reason[outside_order] <- "Outside the primate order"
candidate$policy_evidence[outside_order] <- "_keys/species_taxonomy.csv"
# A printed "Neocortex" does not by itself say GM or GM+WM; nor do known
# transcription errors in part of a study justify excluding every species.
# Retain the primary numeric cells but leave their anatomy on hold until
# the corresponding source's own definition or figure is checked.
idx <- candidate$Source == "Sherwood_etal_2004_TABLEI" &
  candidate$original_column == "Neocortex"
candidate$Variable[idx] <- "Neocortex_unresolved_definition_Vol.mm3"
candidate$target_hint[idx] <- "Neocortex_grey_matter_Vol.mm3"
candidate$anatomy_hint[idx] <-
  "Check source grey-matter boundaries; the old term map implies GM+WM"
idx <- candidate$Source == "deSousa_etal_2010_SupTable2" &
  candidate$Variable == "Neocortex_Vol.mm3"
candidate$anatomy_hint[idx] <-
  "Check this taxon's source neocortex value; some have transcription errors"
idx <- candidate$Source == "deSousa_etal_2010_Table1" &
  candidate$Variable == "Neocortex_Vol.mm3"
candidate$anatomy_hint[idx] <-
  "Confirm whether the printed total includes corpus callosum; derive a documented total if required"
candidate$in_scope <- candidate$Variable %in% regions |
  sub("_(left|right|unilateral)_Vol\\.mm3$", "_Vol.mm3",
      candidate$Variable) %in% regions |
  candidate$target_hint %in% regions

source_template <- data.frame(
  Source = catalog$Source, paper = catalog$paper, year = catalog$year,
  source_file = basename(catalog$source_file),
  n_rule = catalog$n_rule, candidate_count = source_counts,
  intake_issue = source_issues,
  decision = "hold", compatibility = "unknown",
  whole_brain_definition = "", method_note = "",
  reason = "", evidence = "", stringsAsFactors = FALSE
)
cell_template <- data.frame(
  candidate_id = candidate$candidate_id, Source = candidate$Source,
  source_row_id = candidate$source_row_id,
  original_column = candidate$original_column,
  species_as_printed = candidate$species_as_printed,
  Taxon = candidate$Species,
  Variable_original = candidate$Variable,
  Value_original = candidate$Value_original,
  Value_mm3_hint = candidate$Value_mm3,
  unit_scale_hint = candidate$unit_scale,
  N_hint = candidate$N_hint, BV_hint_not_verified = candidate$BV_hint,
  specimen_hint_not_verified = candidate$specimen_hint,
  policy_reason = candidate$policy_reason,
  taxon_order_hint = candidate$taxon_order_hint,
  anatomy_hint = candidate$anatomy_hint,
  decision = ifelse(filled(candidate$policy_reason) |
                      !candidate$in_scope, "exclude", "hold"),
  target_variable = candidate$target_hint, transform = ifelse(
    filled(candidate$target_hint), "equivalent_label", ""),
  derivation = ifelse(filled(candidate$target_hint),
    "Primary Stephan striatum includes nucleus accumbens", ""),
  value_for_pooling = NA_real_, N_region = candidate$N_hint,
  N_basis = ifelse(is.finite(candidate$N_hint),
                   candidate$N_rule, ""),
  sample_id = "", specimen_ids = "", ids_complete = "",
  definition_code = "", anatomy_note = "",
  independence_basis = "", duplicate_basis = "",
  compatibility_basis = "", BV_for_pooling = NA_real_,
  BV_basis = "", reason = ifelse(filled(candidate$policy_reason),
    candidate$policy_reason, ifelse(!candidate$in_scope,
    "Outside the selected region definitions", "")),
  evidence = ifelse(filled(candidate$policy_reason),
    candidate$policy_evidence, ""),
  stringsAsFactors = FALSE
)
# These are omissions in independently available SOURCE data, not values to
# recover from a downstream compilation. They remain visible even if a
# corresponding study has only whole-brain or unweighted figure data.
known_gaps <- data.frame(
  source = c("Barks_etal_2014_TABLE1",
             "Barks_etal_2014_Fig4A",
             "Sherwood_etal_2004_TABLEI",
             "Stephan_etal_1970_Tables1-6"),
  missing_for_replication = c(
    "Individual regional volumes are not printed in the primary table",
    "Digitised group means have no per-bar regional specimen N",
    "Some individual measurements are absent from the published table",
    "No per-species specimen N is printed in this source"),
  handling = c(
    "Retain original BV rows; do not import downstream regional copies",
    "Hold regional cells until independent specimen counts are established",
    "Do not reconstruct missing individuals from a later compilation",
    "Hold any otherwise admissible region until N is independently supported"),
  evidence = c(
    "Barks et al. original Table 1 and regional figures",
    "Barks et al. original Fig. 4A",
    "Sherwood et al. original Table I",
    "Stephan et al. original 1970 tables"),
  stringsAsFactors = FALSE
)
write_csv(known_gaps, out("volumes_known_gaps"))
created <- character()
if (!file.exists(source_review_file)) {
  write_csv(source_template, source_review_file)
  created <- c(created, basename(source_review_file))
}
if (!file.exists(cell_review_file)) {
  write_csv(cell_template, cell_review_file)
  created <- c(created, basename(cell_review_file))
}
if (length(created))
  stop("Created primary-source review template(s): ",
       paste(created, collapse = ", "), ". Verify source admission, ",
       "specimen identity, region N, anatomy and paired BV before rerunning. ",
       "No compiled values were produced.", call. = FALSE)

source_review <- read_csv(source_review_file)
needed <- c("Source", "decision", "compatibility",
            "whole_brain_definition", "method_note", "reason", "evidence")
if (length(setdiff(needed, names(source_review))) ||
    anyDuplicated(text(source_review$Source)) ||
    length(setdiff(catalog$Source, text(source_review$Source))))
  stop("Source review needs one documented row per listed primary source.",
       call. = FALSE)
si <- match(catalog$Source, text(source_review$Source))
source_review <- source_review[si, , drop = FALSE]
source_review$decision <- tolower(text(source_review$decision))
source_review$compatibility <- tolower(text(source_review$compatibility))
if (any(!source_review$decision %in% c("include", "exclude", "hold")) ||
    any(!source_review$compatibility %in%
        c("compatible", "caveated", "incompatible", "unknown")))
  stop("Invalid source admission or compatibility code.", call. = FALSE)
inc <- source_review$decision == "include"
exc <- source_review$decision == "exclude"
if (any(inc & (filled(source_issues) |
    !source_review$compatibility %in% c("compatible", "caveated") |
    !filled(source_review$whole_brain_definition) |
    !filled(source_review$method_note) |
    !filled(source_review$reason) | !filled(source_review$evidence))) ||
    any(exc & (!filled(source_review$reason) |
               !filled(source_review$evidence))))
  stop("An admitted source needs its verified brain/protocol definition and ",
       "evidence. Excluded sources need a reason and evidence.", call. = FALSE)

review <- read_csv(cell_review_file)
required_review <- c("candidate_id", "Source", "source_row_id",
  "original_column", "species_as_printed", "Taxon",
  "Variable_original", "Value_original", "Value_mm3_hint",
  "unit_scale_hint", "N_hint", "BV_hint_not_verified",
  "specimen_hint_not_verified", "decision", "target_variable", "transform",
  "derivation", "value_for_pooling", "N_region", "N_basis",
  "sample_id", "specimen_ids", "ids_complete", "definition_code",
  "anatomy_note", "independence_basis", "duplicate_basis",
  "compatibility_basis", "BV_for_pooling", "BV_basis",
  "reason", "evidence")
if (length(setdiff(required_review, names(review))))
  stop("Cell review lacks required identity, anatomy or provenance fields.",
       call. = FALSE)
rid <- text(review$candidate_id)
if (anyDuplicated(rid) || length(rid) != nrow(candidate) ||
    !setequal(rid, candidate$candidate_id))
  stop("Raw source rows changed after review; reconcile candidate IDs.",
       call. = FALSE)
review <- review[match(candidate$candidate_id, rid), , drop = FALSE]
if (any(text(review$Source) != candidate$Source |
        text(review$source_row_id) != candidate$source_row_id |
        text(review$original_column) != candidate$original_column |
        text(review$species_as_printed) != candidate$species_as_printed |
        text(review$Variable_original) != candidate$Variable) ||
    !same_numeric(number(review$Value_original),
                  candidate$Value_original) ||
    !same_numeric(number(review$Value_mm3_hint),
                  candidate$Value_mm3) ||
    !same_numeric(number(review$unit_scale_hint),
                  candidate$unit_scale) ||
    !same_numeric(number(review$N_hint), candidate$N_hint) ||
    !same_numeric(number(review$BV_hint_not_verified),
                  candidate$BV_hint) ||
    any(text(review$specimen_hint_not_verified) !=
        candidate$specimen_hint))
  stop("Reviewed source fingerprint differs from the current source rows.",
       call. = FALSE)

candidate$Taxon <- text(review$Taxon)
candidate$taxon_order <- taxon_order(candidate$Taxon)
candidate$target_variable <- text(review$target_variable)
candidate$target_variable[!filled(candidate$target_variable)] <-
  candidate$Variable[!filled(candidate$target_variable)]
candidate$decision <- tolower(text(review$decision))
candidate$decision[!filled(candidate$decision)] <- "hold"
candidate$transform <- tolower(text(review$transform))
candidate$transform[!filled(candidate$transform)] <- "as_reported"
candidate$derivation <- text(review$derivation)
candidate$curation_reason <- text(review$reason)
candidate$curation_evidence <- text(review$evidence)
candidate$N_region <- number(review$N_region)
candidate$N_basis <- text(review$N_basis)
candidate$sample_id <- text(review$sample_id)
candidate$specimen_ids <- text(review$specimen_ids)
candidate$ids_complete <- tolower(text(review$ids_complete))
candidate$ids_complete[!filled(candidate$ids_complete)] <- "unknown"
candidate$definition_code <- text(review$definition_code)
candidate$anatomy_note <- text(review$anatomy_note)
candidate$independence_basis <- text(review$independence_basis)
candidate$duplicate_basis <- text(review$duplicate_basis)
candidate$compatibility_basis <- text(review$compatibility_basis)
candidate$BV_for_pooling <- number(review$BV_for_pooling)
candidate$BV_basis <- text(review$BV_basis)
candidate$source_decision <- source_review$decision[
  match(candidate$Source, catalog$Source)]
candidate$source_compatibility <- source_review$compatibility[
  match(candidate$Source, catalog$Source)]
candidate$brain_definition <- text(
  source_review$whole_brain_definition[
    match(candidate$Source, catalog$Source)])
if (any(!candidate$decision %in% c("include", "exclude", "hold")) ||
    any(!candidate$transform %in%
        c("as_reported", "bilateral_2x", "equivalent_label", "derived")) ||
    any(!filled(candidate$Taxon)))
  stop("Curation has an invalid decision, transform or taxon.", call. = FALSE)
if (any(candidate$decision == "include" &
        candidate$taxon_order != "Primates"))
  stop("The final selection requires a verified primate taxon. Update the ",
       "source-aware taxon key or project taxonomy first.", call. = FALSE)
taxon_changed <- candidate$Taxon != candidate$Species
if (any(candidate$decision == "include" & taxon_changed &
        (!filled(candidate$curation_reason) |
         !filled(candidate$curation_evidence))))
  stop("A changed taxon needs documented identity evidence.",
       call. = FALSE)
in_scope <- candidate$target_variable %in% regions
pending_route <- !in_scope & candidate$in_scope &
  candidate$decision != "exclude"
if (any(candidate$decision == "include" &
        (filled(candidate$policy_reason) |
         candidate$source_decision == "exclude" | !in_scope)))
  stop("An inclusion attempts to override a documented veto or non-target ",
       "structure. Reconcile the source policy first.", call. = FALSE)
candidate$gate <- ifelse(!in_scope & !pending_route, "out_of_scope",
  ifelse(candidate$source_decision == "exclude", "source_excluded",
  ifelse(filled(candidate$policy_reason), "source_structure_veto",
  ifelse(candidate$source_decision == "hold", "source_unreviewed",
  ifelse(pending_route, "anatomical_routing_unresolved", "curation")))))
candidate$effective_decision <- ifelse(candidate$gate %in%
  c("out_of_scope", "source_excluded", "source_structure_veto"),
  "exclude", ifelse(candidate$gate %in%
  c("source_unreviewed", "anatomical_routing_unresolved"),
  "hold", candidate$decision))

override <- number(review$value_for_pooling)
candidate$value_for_pooling <- candidate$Value_mm3
two <- candidate$transform == "bilateral_2x"
candidate$value_for_pooling[two] <- 2 * candidate$Value_mm3[two]
derived <- candidate$transform == "derived" & is.finite(override)
candidate$value_for_pooling[derived] <- override[derived]
candidate$derivation[two & !filled(candidate$derivation)] <-
  "2 * measured unilateral value in mm3"
bad <- candidate$decision == "include" & (
  !is.finite(candidate$value_for_pooling) |
  candidate$value_for_pooling < 0 |
  !is.finite(candidate$N_region) | candidate$N_region < 1 |
  candidate$N_region != floor(candidate$N_region) |
  !filled(candidate$N_basis) |
  !filled(candidate$sample_id) |
  !filled(candidate$definition_code) |
  !filled(candidate$anatomy_note) |
  !filled(candidate$curation_evidence) |
  (filled(candidate$anatomy_hint) &
   !filled(candidate$curation_reason)) |
  (candidate$transform != "as_reported" &
    (!filled(candidate$derivation) |
     !filled(candidate$curation_reason)))
)
candidate$curation_issue <- ifelse(bad, "inclusion lacks N, identity, anatomy, value or evidence", "")
candidate$curation_issue[
  candidate$decision == "exclude" & candidate$gate == "curation" &
  (!filled(candidate$curation_reason) |
   !filled(candidate$curation_evidence))] <-
  "exclusion lacks a reason and evidence"
if (any(candidate$decision == "include" &
        candidate$transform == "as_reported" &
        (candidate$target_variable != candidate$Variable |
         is.finite(override))) ||
    any(candidate$decision == "include" &
        candidate$transform == "equivalent_label" &
        (candidate$target_variable == candidate$Variable |
         is.finite(override))) ||
    any(candidate$decision == "include" &
        candidate$transform == "derived" &
        (!is.finite(override) | !filled(candidate$derivation))) ||
    any(candidate$decision == "include" & two &
        (!grepl("_(left|right|unilateral)_Vol\\.mm3$",
                candidate$Variable) |
         candidate$target_variable != sub(
           "_(left|right|unilateral)_Vol\\.mm3$",
           "_Vol.mm3", candidate$Variable) | is.finite(override))))
  stop("A changed value/definition must have a valid recorded derivation.",
       call. = FALSE)

cell_key <- paste(candidate$Taxon, candidate$target_variable, sep = "\034")
groups <- split(which(in_scope | pending_route),
                cell_key[in_scope | pending_route])
if (!length(groups))
  stop("No primary-source cells map to the selected anatomy.", call. = FALSE)
resolve_cell <- function(ix) {
  x <- candidate[ix, , drop = FALSE]
  chosen <- x[x$effective_decision == "include", , drop = FALSE]
  issues <- character()
  superseded <- data.frame(loser = character(), winner = character(),
                           stringsAsFactors = FALSE)
  if (any(x$effective_decision == "hold"))
    issues <- c(issues, "candidate or source admission unresolved")
  if (any(filled(x$curation_issue)))
    issues <- c(issues, x$curation_issue[filled(x$curation_issue)])

  if (nrow(chosen)) {
    valid_n <- is.finite(chosen$N_region) &
      chosen$N_region >= 1 & chosen$N_region == floor(chosen$N_region)
    if (any(!valid_n))
      issues <- c(issues, "missing/invalid independent region N")
    if (any(!(chosen$ids_complete %in% c("yes", "no", "unknown"))))
      issues <- c(issues, "ids_complete must be yes/no/unknown")
    ids <- lapply(chosen$specimen_ids, tokens)
    if (any(vapply(ids, anyDuplicated, integer(1)) > 0L))
      issues <- c(issues, "same specimen named twice in a candidate")
    if (any(chosen$ids_complete == "yes" &
            lengths(ids) != chosen$N_region, na.rm = TRUE))
      issues <- c(issues, "complete specimen ID count differs from regional N")
    if (any(chosen$source_grain == "specimen" &
            chosen$N_region != 1, na.rm = TRUE))
      issues <- c(issues, "a specimen row must contribute N = 1")
    changed_n <- is.finite(chosen$N_hint) &
      is.finite(chosen$N_region) & chosen$N_hint != chosen$N_region
    if (any(changed_n &
            (chosen$transform != "derived" |
             !filled(chosen$derivation) |
             !filled(chosen$curation_reason))))
      issues <- c(issues, "changed N requires a reconstructed independent-subset mean")
    if (any(is.finite(chosen$BV_for_pooling) &
            (chosen$BV_for_pooling <= 0 | !filled(chosen$BV_basis)),
            na.rm = TRUE))
      issues <- c(issues, "paired BV lacks positive value and specimen-subset basis")
    if (any(chosen$Source == "Zilles_Rehk\u00e4mper_1988_Table12-2" &
            chosen$original_column == "Cerebellum (without pons)" &
            !filled(chosen$compatibility_basis)))
      issues <- c(issues, "pons-free cerebellum needs an explicit comparability caveat")
  }

  # A repeated cohort must have matching N and specimen evidence. A later
  # year only breaks a tie for that SAME complete cohort; an unequal-N or
  # partially overlapping published mean must be reconstructed or excluded.
  keep <- seq_len(nrow(chosen))
  if (nrow(chosen) && all(filled(chosen$sample_id))) {
    for (cohort in split(seq_len(nrow(chosen)), chosen$sample_id)) {
      if (length(cohort) < 2L) next
      ns <- chosen$N_region[cohort]
      if (any(!is.finite(ns)) ||
          any(!is.finite(chosen$value_for_pooling[cohort])) ||
          length(unique(ns)) != 1L ||
          any(!filled(chosen$duplicate_basis[cohort]))) {
        issues <- c(issues, "overlapping cohort: N or identity unresolved")
        next
      }
      sets <- lapply(chosen$specimen_ids[cohort], tokens)
      present <- lengths(sets) > 0L
      identities <- vapply(sets,
        function(z) paste(sort(z), collapse = "|"), character(1))
      if (any(present) &&
          (!all(present) || length(unique(identities)) != 1L)) {
        issues <- c(issues, "shared sample ID has incompatible specimen lists")
        next
      }
      latest <- cohort[chosen$Year[cohort] == max(chosen$Year[cohort])]
      if (length(latest) > 1L &&
          !identical_value(chosen$value_for_pooling[latest],
            rep(chosen$value_for_pooling[latest[1]], length(latest)))) {
        issues <- c(issues, "same-year repeat conflicts; choose explicitly")
        next
      }
      winner <- latest[order(chosen$Source[latest],
                             chosen$candidate_id[latest])][1]
      loser <- setdiff(cohort, winner)
      keep <- setdiff(keep, loser)
      superseded <- rbind(superseded,
        data.frame(loser = chosen$candidate_id[loser],
                   winner = chosen$candidate_id[winner],
                   stringsAsFactors = FALSE))
    }
  }
  retained <- chosen[keep, , drop = FALSE]
  if (nrow(retained) > 1L) {
    if (any(!filled(retained$independence_basis)))
      issues <- c(issues, "independent specimens not demonstrated")
    known <- unlist(lapply(retained$specimen_ids, tokens),
                    use.names = FALSE)
    if (anyDuplicated(known))
      issues <- c(issues, "known specimen appears in two retained cohorts")
    if (length(unique(retained$definition_code)) > 1L)
      issues <- c(issues, "incompatible anatomy must not be averaged")
    if (length(unique(retained$brain_definition)) > 1L &&
        any(!filled(retained$compatibility_basis)))
      issues <- c(issues, "different brain protocols lack a pooling rationale")
  }
  if (!nrow(chosen) && !length(issues)) {
    state <- "excluded"
    detail <- "All primary measurements excluded with documented reasons"
  } else {
    if (!nrow(retained)) issues <- c(issues, "no retained source row")
    state <- if (length(issues)) "needs_review" else "ready"
    detail <- joined(issues)
  }
  ready <- identical(state, "ready")
  n_total <- if (ready) sum(retained$N_region) else NA_real_
  value <- if (ready) {
    sum(retained$N_region * retained$value_for_pooling) / n_total
  } else {
    NA_real_
  }
  paired <- ready && all(is.finite(retained$BV_for_pooling))
  bv <- if (paired) {
    sum(retained$N_region * retained$BV_for_pooling) / n_total
  } else {
    NA_real_
  }
  rob <- if (is.finite(bv)) bv - value else NA_real_
  analysis_status <- if (!ready) "not_compiled" else
    if (grepl("^Homo[ _]sapiens$", x$Taxon[1], ignore.case = TRUE))
      "excluded_human" else if (!paired) "missing_paired_BV" else
      if (value <= 0 || !is.finite(rob) || rob <= 0)
        "non_positive_region_or_ROB" else "eligible_pending_predictors"
  cautions <- if (ready) c(
    if (any(retained$source_compatibility == "caveated"))
      "whole_brain_protocol_caveat",
    if (any(retained$ids_complete != "yes"))
      "specimen_overlap_not_fully_checkable",
    if (any(retained$transform == "bilateral_2x"))
      "bilateral_estimate_from_one_side",
    if (any(!filled(retained$BV_for_pooling)))
      "paired_brain_volume_unavailable"
  ) else character()
  cell <- data.frame(
    Taxon = x$Taxon[1], Variable = x$target_variable[1],
    status = state, issue = detail, n_candidates = nrow(x),
    n_retained = if (ready) nrow(retained) else 0L,
    N_independent = n_total, Value = value, BV = bv, ROB = rob,
    analysis_status = analysis_status,
    Sources = if (ready) joined(retained$Source) else "",
    source_row_ids = if (ready) joined(retained$source_row_id) else "",
    candidate_ids = if (ready) joined(retained$candidate_id) else "",
    sample_ids = if (ready) joined(retained$sample_id) else "",
    definition_code = if (ready) retained$definition_code[1] else "",
    dispersion_pct = if (ready && nrow(retained) > 1L && value > 0)
      100 * (max(retained$value_for_pooling) -
             min(retained$value_for_pooling)) / value else NA_real_,
    assumption_flags = joined(cautions),
    method = if (!ready) "" else if (nrow(retained) == 1L)
      "one independent primary-source contribution" else
      "region-N-weighted independent primary-source contributions",
    stringsAsFactors = FALSE
  )
  list(cell = cell,
       used = if (ready) retained$candidate_id else character(),
       superseded = superseded)
}
resolved <- lapply(groups, resolve_cell)
cells <- do.call(rbind, lapply(resolved, `[[`, "cell"))
rownames(cells) <- NULL
used <- unlist(lapply(resolved, `[[`, "used"), use.names = FALSE)
superseded <- do.call(rbind, lapply(resolved, `[[`, "superseded"))
candidate$cell_status <- "out_of_scope"
ck <- paste(candidate$Taxon, candidate$target_variable, sep = "\034")
in_groups <- in_scope | pending_route
candidate$cell_status[in_groups] <- cells$status[
  match(ck[in_groups], paste(cells$Taxon, cells$Variable,
                             sep = "\034"))]
candidate$used_in_final <- candidate$candidate_id %in% used
candidate$superseded_by <- ""
candidate$resolution <- ifelse(!in_groups, "outside_scope",
  ifelse(candidate$effective_decision == "exclude", "excluded",
  ifelse(candidate$effective_decision == "hold", "held",
  ifelse(candidate$used_in_final, "weighted_contribution",
         "provisional_inclusion"))))
if (nrow(superseded)) {
  li <- match(superseded$loser, candidate$candidate_id)
  candidate$superseded_by[li] <- superseded$winner
  candidate$resolution[li] <- ifelse(
    candidate$cell_status[li] == "ready", "superseded_same_cohort",
    "proposed_supersession_pending")
}

source_audit <- source_review
source_audit$candidate_count <- source_counts
source_audit$intake_issue <- source_issues
hard_exclusions <- data.frame(
  Source = c("Semendeferi_Damasio", "Navarrete_etal"),
  paper = c("Semendeferi_Damasio", "Navarrete_etal"),
  year = NA_integer_, source_file = "",
  n_rule = "", candidate_count = 0L, intake_issue = "",
  decision = "exclude", compatibility = "incompatible",
  whole_brain_definition = c(
    "omits medulla, pons and most midbrain",
    "region boundaries insufficiently documented"),
  method_note = "whole-dataset exclusion",
  reason = c("whole-brain denominator differs",
             "reported region values and boundaries are incompatible"),
  evidence = "DeCasien & Higham 2019, Methods: Data collection and compilation",
  stringsAsFactors = FALSE
)
missing_audit <- setdiff(names(source_audit), names(hard_exclusions))
for (nm in missing_audit) hard_exclusions[[nm]] <- NA
source_audit <- rbind(source_audit,
  hard_exclusions[, names(source_audit), drop = FALSE])
candidate <- candidate[order(candidate$Taxon, candidate$target_variable,
                              candidate$Source, candidate$source_row_id),
                       , drop = FALSE]
cells <- cells[order(cells$Taxon, cells$Variable), , drop = FALSE]
write_csv(source_audit, out("volumes_source_decisions"))
write_csv(candidate, out("volumes_candidate_audit"))
write_csv(cells, out("volumes_cell_status"))

all_inputs <- unique(c(script_path, species_file[file.exists(species_file)],
  basis_file[file.exists(basis_file)],
  catalog$source_file[file.exists(catalog$source_file)],
  source_inputs, source_review_file, cell_review_file))
inputs <- data.frame(
  role = ifelse(all_inputs %in% c(script_path, source_review_file,
                                 cell_review_file), "script_or_review",
                "independent_primary_source_or_map"),
  file = basename(all_inputs),
  md5 = unname(as.character(tools::md5sum(all_inputs))),
  stringsAsFactors = FALSE
)
write_csv(inputs, out("volumes_run_inputs"))
unresolved_sources <- sum(source_review$decision == "hold")
unresolved_cells <- sum(cells$status == "needs_review")
if (unresolved_sources || unresolved_cells)
  stop(unresolved_sources, " source(s) and ", unresolved_cells,
       " species-region cell(s) still need review. Audits were written; ",
       "NO final long/wide/analysis table was produced. Missing regional Ns ",
       "and independently unavailable measurements were not fabricated.",
       call. = FALSE)

long <- cells[cells$status == "ready", , drop = FALSE]
if (!nrow(long))
  stop("All available primary-source cells were excluded.",
       call. = FALSE)
composition <- candidate[candidate$used_in_final,
  c("Taxon", "target_variable", "candidate_id", "source_row_id",
    "Source", "Year", "Value_original", "unit_scale", "Value_mm3",
    "value_for_pooling", "N_region", "N_basis", "BV_for_pooling",
    "sample_id", "specimen_ids", "definition_code", "anatomy_note",
    "derivation", "independence_basis", "compatibility_basis",
    "curation_reason", "curation_evidence"), drop = FALSE]
names(composition)[names(composition) == "target_variable"] <- "Variable"
composition$weight <- composition$N_region / long$N_independent[
  match(paste(composition$Taxon, composition$Variable, sep = "\034"),
        paste(long$Taxon, long$Variable, sep = "\034"))]
wide <- reshape(long[c("Taxon", "Variable", "Value")],
                idvar = "Taxon", timevar = "Variable", direction = "wide")
names(wide) <- sub("^Value\\.", "", names(wide))
wide <- wide[order(wide$Taxon), , drop = FALSE]
analysis <- long[long$analysis_status == "eligible_pending_predictors",
                 , drop = FALSE]
# Family-specific ecological predictor completeness belongs to a later
# analysis, never to source selection. It changes the species set by model.
write_csv(composition, out("volumes_species_composition"))
write_csv(long, out("volumes_long"))
write_csv(wide, out("volumes_wide"))
write_csv(analysis, out("volumes_analysis"))
message("Compiled ", nrow(long), " audited species-region values from ",
        nrow(composition), " independent primary-source contributions.")
