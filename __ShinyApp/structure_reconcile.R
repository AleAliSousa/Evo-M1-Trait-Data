# =============================================================================
# structure_reconcile.R -- shared by the Evo-M1 app (__ShinyApp/app.R) and
# TraitExplorer (TraitExplorer/app.R). Keep the two copies identical.
#
# Two features, both pure data functions over one long table with columns
#   Species, Variable, Dataset, Source, Value_num
# plus the variable key _keys/variable_definitions.csv (label, domain,
# measure_class, Structure, Measure, Unit, poolable_group, poolable_family):
#
#   1. Brain-structure comparison WITHIN a species: every structure-level value
#      a species has for one kind of measurement (volume, mass, neuron number,
#      CMRgl, ...), on one unit, optionally as a percentage of a reference
#      structure the user picks.
#   2. Source reconciliation: candidate pairs of variables that look like the
#      same trait from different sources (same structure + measure + unit +
#      life-stage/sex scope, or the same name stem once the source tag is
#      removed), compared species by species.
#
# Neither feature pools, averages across variables, or edits a value. A
# disagreement is reported, never balanced. Decisions stay in
# _keys/variable_canonical.csv (action = supersede / keep_separate), which is
# read here only to SHOW the decision already on record for a pair.
# =============================================================================

# ---- Units ------------------------------------------------------------------
# Unit -> dimension + factor to that dimension's base unit. Volume base mm3,
# mass base g, area base mm2, length base mm. Anything not listed keeps its own
# unit as its "dimension" (so umol/100g/min only ever meets umol/100g/min).
# Cellular units (um, um2, um3, nm) are deliberately NOT listed: they keep their
# own unit, so a soma volume stays in um3 rather than becoming 1e-9 mm3.
SR_UNITS <- data.frame(
  unit = c("mm3", "mm^3", "cm3", "cc", "ml",
           "g", "mg", "kg",
           "mm2", "cm2",
           "mm", "cm",
           "count", "n", "%", "percent"),
  dim = c(rep("volume", 5), rep("mass", 3), rep("area", 2), rep("length", 2),
          "count", "count", "percent", "percent"),
  factor = c(1, 1, 1e3, 1e3, 1e3,
             1, 1e-3, 1e3,
             1, 100,
             1, 10,
             1, 1, 1, 1),
  stringsAsFactors = FALSE)
SR_BASE_UNIT <- c(volume = "mm3", mass = "g", area = "mm2", length = "mm",
                  count = "count", percent = "%")

# Unit for each label: the key's Unit, else "(unit)" at the end of the label,
# else a measure-code suffix (_Vol.mm3, _Mass.g, _N.n ...).
sr_unit_of <- function(labels, key_unit) {
  u <- ifelse(is.na(key_unit), "", trimws(key_unit))
  miss <- !nzchar(u)
  paren <- sub("^.*\\(([^()]*)\\)\\s*$", "\\1", labels)
  has_paren <- grepl("\\([^()]*\\)\\s*$", labels)
  u[miss & has_paren] <- paren[miss & has_paren]
  miss <- !nzchar(u)
  code <- regmatches(labels, regexpr("(Vol\\.mm3|Mass\\.g|Mass\\.mg|Mass\\.kg|Area\\.mm2|\\.n)$", labels))
  code_full <- rep("", length(labels))
  code_full[grepl("(Vol\\.mm3|Mass\\.g|Mass\\.mg|Mass\\.kg|Area\\.mm2|\\.n)$", labels)] <- code
  map <- c("Vol.mm3" = "mm3", "Mass.g" = "g", "Mass.mg" = "mg", "Mass.kg" = "kg",
           "Area.mm2" = "mm2", ".n" = "count")
  fill <- miss & nzchar(code_full)
  u[fill] <- unname(map[code_full[fill]])
  u
}

sr_unit_dim <- function(unit) {
  k <- tolower(trimws(unit))
  k <- gsub("\u00b3", "3", k, fixed = TRUE); k <- gsub("\u00b2", "2", k, fixed = TRUE)
  i <- match(k, SR_UNITS$unit)
  data.frame(dim = ifelse(is.na(i), ifelse(nzchar(k), k, "unitless"), SR_UNITS$dim[i]),
             factor = ifelse(is.na(i), 1, SR_UNITS$factor[i]),
             stringsAsFactors = FALSE)
}

# ---- Label metadata ---------------------------------------------------------
# Domains whose "structure" is not a brain structure (Body, hand, head ...):
# their labels go to the name-stem route of reconciliation, never to the
# brain-structure comparison.
SR_NONBRAIN_DOMAINS <- c("body size", "hand & limb morphology", "life history",
                         "diet & ecology", "behaviour & cognition", "behaviour",
                         "sleep & torpor", "dataset metadata", "sensory performance",
                         "sociality", "ecology", "communication", "sensory")
SR_NONBRAIN_STRUCT  <- c("body", "hand", "head", "eyevisualsystem")

# Life stage / sex qualifiers: two variables with different scope are never
# candidates for the same trait (adult vs neonate brain mass; female-only vs
# all-animal endocranial volume).
sr_scope <- function(labels) {
  vapply(labels, function(l) {
    s <- tolower(regmatches(l, gregexpr("(?i)(neonat[a-z]*|newborn|at_birth|adult|juvenile|infant|fetal|foetal|female|male)", l, perl = TRUE))[[1]])
    s <- sub("^neonat.*$", "neonate", s); s[s == "newborn"] <- "neonate"; s[s == "foetal"] <- "fetal"
    s <- unique(s)
    if ("female" %in% s) s <- setdiff(s, "male")
    paste(sort(s), collapse = "+")
  }, character(1), USE.NAMES = FALSE)
}

# Author-year tag that the supplementary merge appends to a source-specific
# view ("Home_range_Kamilar2013 (km2)" -> "Kamilar2013").
SR_TAG_RE <- "_?([A-Z][A-Za-z]+?)(_?et_?al)?_?((1[89]|20)[0-9]{2})[a-z]?(?=$|[_ (])"
sr_source_tag <- function(labels) {
  s <- sub("\\s*\\([^()]*\\)\\s*$", "", labels)
  m <- regexpr(SR_TAG_RE, s, perl = TRUE)
  out <- rep("", length(s))
  hit <- m > 0
  if (any(hit)) {
    tok <- regmatches(s, m)
    out[hit] <- gsub("[_ ]|et_?al", "", tok)
  }
  out
}

# Name stem used to match non-structure traits across sources: unit, method
# bracket and author-year tag removed, case and punctuation folded.
sr_stem <- function(labels) {
  s <- sub("\\s*\\([^()]*\\)\\s*$", "", labels)
  s <- gsub("\\s*\\[[^]]*\\]", "", s)
  s <- gsub(SR_TAG_RE, "", s, perl = TRUE)
  s <- sub("(?i)[._](g|kg|mg|mm3|mm2|mm|cm3|ml|days|d|yr|yrs|y|mo|mnths|months|h|pct|percent|n)$", "", s, perl = TRUE)
  s <- tolower(s)
  s <- gsub("[^a-z0-9]+", "_", s)
  s <- gsub("(^|_)maximum(_|$)", "\\1max\\2", s)
  s <- gsub("longevity", "lifespan", s, fixed = TRUE)
  s <- gsub("weight", "mass", s, fixed = TRUE)
  gsub("^_+|_+$", "", s)
}

# CMR labels carry their measure in the label, not the key (the key's Measure is
# "CMR.umol/100g/min" for both glucose and oxygen), so it is parsed here.
sr_measure_tag <- function(labels, dataset, key_measure) {
  tag <- rep("", length(labels))
  m <- regexpr("_(CMRgl|CMRglc|CMRO2|CBF)\\b", labels, perl = TRUE)
  tag[m > 0] <- sub("^_", "", regmatches(labels, m))
  cm <- dataset %in% "Cell type, size & morphology" & !nzchar(tag)
  if (any(cm)) {
    meth <- ifelse(grepl("\\[[^]]+\\]", labels[cm]),
                   sub("^.*\\[([^]]+)\\].*$", "[\\1]", labels[cm]), "")
    km <- ifelse(is.na(key_measure[cm]), "", key_measure[cm])
    tag[cm] <- paste0(km, meth)
  }
  tag
}

# What a measurement is, for grouping: volume and mass of a structure are one
# class each whatever the key calls them (structure_volume / volume / brain_size).
sr_key_class <- function(measure_class, dim) {
  mc <- ifelse(is.na(measure_class), "", measure_class)
  out <- mc
  out[mc %in% c("mass", "structure_mass") | (!nzchar(mc) & dim == "mass")] <- "mass"
  out[mc %in% c("structure_volume", "volume", "brain_size") | (!nzchar(mc) & dim == "volume")] <- "volume"
  out[mc %in% c("cortical_surface", "surface_area") | (!nzchar(mc) & dim == "area")] <- "surface_area"
  out[!nzchar(out)] <- dim[!nzchar(out)]
  out
}

SR_CLASS_LABEL <- c(
  volume = "Volume", mass = "Mass", neuron_number = "Neuron number",
  other_cell_number = "Non-neuronal cell number", total_cell_number = "Total cell number",
  neuron_density = "Neuron density", other_cell_density = "Non-neuronal cell density",
  other_cell_per_neuron = "Non-neuronal cells per neuron", neuron_fraction = "Neuron fraction",
  cerebral_metabolic_rate = "Cerebral metabolic rate", cerebral_perfusion = "Cerebral blood flow",
  cortical_surface = "Surface area", surface_area = "Surface area",
  microglia_number = "Microglia number", microglia_density = "Microglia density",
  microglia_per_cell = "Microglia per cell", endocranial_volume = "Endocranial volume",
  protein_concentration = "Protein concentration", cerebellar_folding = "Cerebellar folding")

# Text before the measure in a label: "Cerebellum_grey_matter" from
# "Cerebellum_grey_matter_Vol.mm3", "Neocortex" from
# "Neocortex_volume_Dunn2018 (mm3)", region + cell type from a cell-morphology
# label. NA when the label has no recognisable measure at its end (then the
# key's Structure is used).
SR_CODE_RE <- "_(Vol\\.mm3|Vol|volume|Mass\\.g|Mass\\.mg|Mass\\.kg|Mass|Surface_Area\\.mm2|N\\.n|O\\.n|C\\.n|I\\.n|N\\.p\\.mg|O\\.p\\.mg|O\\.p\\.N|I\\.p\\.mg|I\\.p\\.C|p\\.C\\.N|CMRgl|CMRglc|CMRO2|CBF)$"
sr_stated_structure <- function(labels, key_measure = rep(NA_character_, length(labels)),
                                dim = rep("", length(labels))) {
  s <- sub("\\s*\\([^()]*\\)\\s*$", "", labels)
  s <- trimws(gsub("\\s*\\[[^]]*\\]", "", s))
  s <- gsub(SR_TAG_RE, "", s, perl = TRUE)
  out <- rep(NA_character_, length(s))
  km <- ifelse(is.na(key_measure), "", key_measure)
  by_measure <- nzchar(km) & !grepl("[.]", km) & endsWith(s, paste0("_", km))
  out[by_measure] <- substr(s[by_measure], 1, nchar(s[by_measure]) - nchar(km[by_measure]) - 1)
  rest <- is.na(out) & grepl(SR_CODE_RE, s, perl = TRUE)
  # a volume code only ends a volume label and a mass code a mass label, so
  # "Brain_Mass_estimated_from_volume (g)" is not cut at "_volume"
  code <- sub("^.*_", "", regmatches(s, regexpr(SR_CODE_RE, s, perl = TRUE)))
  code_full <- rep("", length(s)); code_full[grepl(SR_CODE_RE, s, perl = TRUE)] <- code
  wrong <- (code_full %in% c("Vol.mm3", "Vol", "volume") & dim != "volume") |
    (startsWith(code_full, "Mass") & dim != "mass")
  rest <- rest & !wrong
  out[rest] <- sub(SR_CODE_RE, "", s[rest], perl = TRUE)
  out[!is.na(out) & !nzchar(out)] <- NA_character_
  out
}

# One row per label: structure, display name, unit, dimension, factor to base,
# comparison key and its human-readable name. `labels` and `datasets` are
# parallel (one dataset per label: the first it occurs in).
sr_label_meta <- function(labels, datasets, vardef) {
  labels <- as.character(labels)
  g <- function(col) {
    if (is.null(vardef) || !col %in% names(vardef)) return(rep(NA_character_, length(labels)))
    v <- trimws(as.character(vardef[[col]][match(labels, vardef$label)]))
    v[!is.na(v) & !nzchar(v)] <- NA_character_
    v
  }
  dom <- g("domain"); mc <- g("measure_class"); st <- g("Structure")
  km <- g("Measure"); ku <- g("Unit"); pg <- g("poolable_group"); pf <- g("poolable_family")
  unit <- sr_unit_of(labels, ku)
  ud <- sr_unit_dim(unit)
  # Structure as the LABEL states it. The key's Structure column is the
  # canonical (parent) structure -- Cerebellum for Cerebellum_white_matter_Vol.mm3
  # and for LateralCerebellum_Vol (mm3) alike -- which is right for grouping a
  # trait but wrong for telling sub-parts apart. So the stated structure is the
  # label cut at its measure (the key's Measure, else a known measure code at the
  # END of the label), and the key's Structure is kept as `structure_group`.
  stated <- sr_stated_structure(labels, km, ud$dim)
  group <- st
  basis <- ifelse(!is.na(stated), ifelse(is.na(st), "parsed from label", "label"),
                  ifelse(is.na(st), "", "key"))
  st <- ifelse(!is.na(stated), stated, st)
  st_norm <- gsub("[^a-z0-9]", "", tolower(ifelse(is.na(st), "", st)))
  st_norm[st_norm %in% c("brain", "wholebrain")] <- "wholebrain"
  is_brain <- !is.na(st) & !(dom %in% SR_NONBRAIN_DOMAINS) & !(st_norm %in% SR_NONBRAIN_STRUCT)
  mtag <- sr_measure_tag(labels, datasets, km)
  # a CMR label with no key row still is a cerebral metabolic rate / blood flow
  mc[is.na(mc) & mtag %in% c("CMRgl", "CMRglc", "CMRO2")] <- "cerebral_metabolic_rate"
  mc[is.na(mc) & mtag == "CBF"] <- "cerebral_perfusion"
  kc <- sr_key_class(mc, ud$dim)
  scope <- sr_scope(labels)
  base_unit <- unname(ifelse(ud$dim %in% names(SR_BASE_UNIT), SR_BASE_UNIT[ud$dim], unit))
  # Comparison key for the within-species view: same kind of measurement, same
  # unit dimension, same measure tag and scope. Structure is NOT part of it.
  cmp_key <- paste(kc, ud$dim, mtag, scope, sep = "|")
  cls <- unname(ifelse(kc %in% names(SR_CLASS_LABEL), SR_CLASS_LABEL[kc], gsub("_", " ", kc)))
  cmp_name <- paste0(cls, ifelse(nzchar(mtag), paste0(" - ", mtag), ""),
                     " (", base_unit, ")", ifelse(nzchar(scope), paste0(" [", scope, "]"), ""))
  # Display name of the structure as this label states it, e.g.
  # Cerebellum_grey_matter for Cerebellum_grey_matter_Vol.mm3.
  disp <- ifelse(is.na(st), "", st)
  data.frame(label = labels, dataset = datasets, domain = ifelse(is.na(dom), "", dom),
             measure_class = ifelse(is.na(mc), "", mc), structure = ifelse(is.na(st), NA_character_, st),
             structure_group = ifelse(is.na(group), "", group),
             structure_norm = st_norm, structure_basis = basis, is_brain = is_brain,
             unit = unit, dim = ud$dim, factor = ud$factor, base_unit = base_unit,
             key_class = kc, measure_tag = mtag, scope = scope,
             cmp_key = cmp_key, cmp_name = cmp_name, display = disp,
             pool_group = ifelse(is.na(pg), "", pg), pool_family = ifelse(is.na(pf), "", pf),
             source_tag = sr_source_tag(labels), stem = sr_stem(labels),
             stringsAsFactors = FALSE)
}

# ---- 1. Brain-structure comparison within a species -------------------------

# Numeric structure-level rows, each with its value in the base unit.
sr_structure_rows <- function(data, meta) {
  m <- meta[meta$is_brain, , drop = FALSE]
  d <- data[data$Variable %in% m$label & is.finite(data$Value_num),
            c("Species", "Variable", "Dataset", "Source", "Value_num"), drop = FALSE]
  if (!nrow(d)) return(data.frame())
  i <- match(d$Variable, m$label)
  d$structure <- m$structure[i]; d$display <- m$display[i]
  d$structure_group <- m$structure_group[i]
  d$cmp_key <- m$cmp_key[i]; d$cmp_name <- m$cmp_name[i]
  d$base_unit <- m$base_unit[i]; d$value_base <- d$Value_num * m$factor[i]
  d$structure_basis <- m$structure_basis[i]; d$pool_group <- m$pool_group[i]
  d
}

# Species that can be compared: at least two distinct structures on one key.
sr_species_choices <- function(srows) {
  if (!nrow(srows)) return(character(0))
  u <- unique(srows[, c("Species", "cmp_key", "structure")])
  n <- tapply(u$structure, paste(u$Species, u$cmp_key, sep = "\r"), length)
  ok <- names(n)[n >= 2]
  sp <- sort(unique(sub("\r.*$", "", ok)))
  nst <- tapply(srows$structure, srows$Species, function(x) length(unique(x)))
  setNames(sp, sprintf("%s  (%d structures)", sp, as.integer(nst[sp])))
}

# Keys available for one species, most structures first.
sr_keys_for <- function(srows, species) {
  d <- srows[srows$Species %in% species, , drop = FALSE]
  if (!nrow(d)) return(character(0))
  n <- tapply(d$structure, d$cmp_key, function(x) length(unique(x)))
  nm <- d$cmp_name[match(names(n), d$cmp_key)]
  o <- order(-n, nm)
  keep <- n[o] >= 1
  setNames(names(n)[o][keep], sprintf("%s  -  %d structure%s", nm[o][keep], n[o][keep],
                                      ifelse(n[o][keep] == 1, "", "s")))
}

# One row per (variable, dataset) for a species on one key: the value (mean of
# that variable's rows if a dataset carries several), its range and sources.
# Different variables are never averaged together: two labels for the same
# structure stay two rows, and the table says so.
sr_profile <- function(srows, species, key) {
  d <- srows[srows$Species %in% species & srows$cmp_key == key, , drop = FALSE]
  if (!nrow(d)) return(data.frame())
  grp <- paste(d$Species, d$Variable, d$Dataset, sep = "\r")
  idx <- split(seq_len(nrow(d)), grp)
  out <- do.call(rbind, lapply(idx, function(ix) {
    x <- d[ix, , drop = FALSE]
    data.frame(Species = x$Species[1], Structure = x$display[1],
               Structure_group = x$structure_group[1], Variable = x$Variable[1],
               Dataset = x$Dataset[1], Value = mean(x$value_base), Min = min(x$value_base),
               Max = max(x$value_base), N_values = nrow(x), Unit = x$base_unit[1],
               Sources = paste(unique(x$Source[!is.na(x$Source) & nzchar(x$Source)]), collapse = " | "),
               Structure_from = x$structure_basis[1], Basis = x$pool_group[1],
               stringsAsFactors = FALSE)
  }))
  rownames(out) <- NULL
  # Flag a structure stated by more than one variable/dataset: the rows are
  # shown side by side, not merged.
  k <- paste(out$Species, out$Structure, sep = "\r")
  out$Same_structure_rows <- as.integer(table(k)[k])
  out[order(out$Species, -out$Value), , drop = FALSE]
}

# Reference candidates for "% of reference": any series this species has in
# the same unit dimension (so a structure mass can be expressed against a
# weighed whole-brain mass, and the basis of that mass is named in the label).
sr_reference_choices <- function(data, meta, species, key) {
  dim <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", key)
  labs <- meta$label[meta$dim == dim & meta$label %in% data$Variable[data$Species %in% species]]
  if (!length(labs)) return(character(0))
  d <- data[data$Species %in% species & data$Variable %in% labs & is.finite(data$Value_num), , drop = FALSE]
  if (!nrow(d)) return(character(0))
  ids <- unique(paste(d$Variable, d$Dataset, sep = " @ "))
  # wholes first, so the default reference is a whole brain where one exists
  whole <- grepl("(?i)whole.?brain|brain_mass|brain mass|total_brain|endocranial", ids, perl = TRUE)
  ids[order(!whole, ids)]
}

sr_reference_value <- function(data, meta, species, ref_id) {
  if (is.null(ref_id) || !nzchar(ref_id)) return(NA_real_)
  parts <- strsplit(ref_id, " @ ", fixed = TRUE)[[1]]
  d <- data[data$Species %in% species & data$Variable == parts[1] & data$Dataset == parts[2] &
              is.finite(data$Value_num), , drop = FALSE]
  if (!nrow(d)) return(NA_real_)
  f <- meta$factor[match(parts[1], meta$label)]
  mean(d$Value_num) * ifelse(is.na(f), 1, f)
}

# Which structures a species has, for which measurement keys (coverage matrix).
sr_species_matrix <- function(srows, species) {
  d <- unique(srows[srows$Species %in% species, c("display", "cmp_name")])
  if (!nrow(d)) return(data.frame())
  tb <- table(d$display, d$cmp_name)
  m <- as.data.frame.matrix(tb)
  m[] <- lapply(m, function(x) ifelse(x > 0, "\u2713", ""))
  out <- cbind(Structure = rownames(m), m, stringsAsFactors = FALSE)
  out$Measurements <- rowSums(tb > 0)
  rownames(out) <- NULL
  out[order(-out$Measurements, out$Structure), , drop = FALSE]
}

# ---- 2. Source reconciliation -------------------------------------------------
# A "series" is one variable as delivered by one dataset. A label that occurs in
# more than one compiled dataset (Cerebellum_Mass (g) from both the brain-part
# weights merge and the cell-count tables) is two series, because the app's
# species means would otherwise average them without saying so.
sr_series_table <- function(data, meta) {
  d <- data[is.finite(data$Value_num) & data$Variable %in% meta$label,
            c("Species", "Variable", "Dataset", "Source", "Value_num"), drop = FALSE]
  if (!nrow(d)) return(d)
  n_ds <- tapply(d$Dataset, d$Variable, function(x) length(unique(x)))
  d$series <- ifelse(n_ds[d$Variable] > 1, paste0(d$Variable, " @ ", d$Dataset), d$Variable)
  d$value_base <- d$Value_num * meta$factor[match(d$Variable, meta$label)]
  d
}

# Candidate group key: brain structures by structure + class + unit + tag +
# scope; everything else by name stem + unit + scope.
sr_group_key <- function(meta) {
  ifelse(meta$is_brain,
         paste("S", meta$structure_norm, meta$key_class, meta$dim, meta$measure_tag, meta$scope, sep = "|"),
         paste("N", meta$stem, meta$dim, meta$scope, sep = "|"))
}

SR_VERDICTS <- c("same values", "agree within 10%", "median agrees, wide scatter",
                 "consistent offset", "disagree",
                 "different measurement basis", "too few shared species",
                 "no shared species (complementary coverage)")

sr_verdict <- function(r, pa, pb) {
  n <- length(r)
  if (!n) return("no shared species (complementary coverage)")
  if (nzchar(pa) && nzchar(pb) && pa != pb) return("different measurement basis")
  if (mean(abs(r - 1) <= 0.01) >= 0.9) return("same values")
  if (n < 3) return("too few shared species")
  lr <- log10(r)
  med <- stats::median(lr)
  iqr <- diff(stats::quantile(lr, c(0.25, 0.75), names = FALSE))
  if (abs(med) <= log10(1.1) && mean(abs(r - 1) <= 0.10) >= 0.75) return("agree within 10%")
  if (abs(med) <= log10(1.1)) return("median agrees, wide scatter")
  if (iqr <= 0.05) return("consistent offset")
  "disagree"
}

# Decision already recorded for a pair in variable_canonical.csv. Matched on the
# label stripped of its "(unit)", against raw_variable / canonical_variable.
sr_decision_for <- function(a, b, canon) {
  if (is.null(canon) || !nrow(canon)) return("")
  strip <- function(x) sub("\\s*\\([^()]*\\)\\s*$", "", sub(" @ .*$", "", x))
  A <- c(strip(a), sub(" @ .*$", "", a)); B <- c(strip(b), sub(" @ .*$", "", b))
  raw <- trimws(as.character(canon$raw_variable)); can <- trimws(as.character(canon$canonical_variable))
  hit <- (raw %in% A & can %in% B) | (raw %in% B & can %in% A)
  if (!any(hit)) return("")
  r <- canon[which(hit)[1], ]
  paste0(r$action, if (!is.null(r$notes) && !is.na(r$notes) && nzchar(r$notes))
    paste0(": ", substr(as.character(r$notes), 1, 160)) else "")
}

# Candidate pairs with per-pair agreement statistics on species means.
sr_candidates <- function(data, meta, canon = NULL) {
  st <- sr_series_table(data, meta)
  if (!nrow(st)) return(data.frame())
  ser <- unique(st[, c("series", "Variable", "Dataset")])
  mi <- match(ser$Variable, meta$label)
  ser$group <- sr_group_key(meta)[mi]
  ser$tag <- meta$source_tag[mi]; ser$pool <- meta$pool_group[mi]
  ser$domain <- meta$domain[mi]; ser$unit <- meta$base_unit[mi]
  groups <- split(ser, ser$group)
  groups <- groups[vapply(groups, nrow, integer(1)) >= 2]
  if (!length(groups)) return(data.frame())
  # species means only for series that are in a candidate group (keeps the
  # series x species matrix small enough for a free shinyapps.io instance)
  in_grp <- unlist(lapply(groups, function(g) g$series), use.names = FALSE)
  st <- st[st$series %in% in_grp, , drop = FALSE]
  means <- tapply(st$value_base, list(st$series, st$Species), mean)
  rows <- list()
  for (g in groups) {
    g <- g[order(g$series), , drop = FALSE]
    pr <- utils::combn(nrow(g), 2)
    for (j in seq_len(ncol(pr))) {
      a <- g[pr[1, j], ]; b <- g[pr[2, j], ]
      # Parallel variables of ONE merge (Brain_Mass_measured vs the selection
      # built from it) are not two sources; the same label from two datasets is.
      if (a$Dataset == b$Dataset && a$tag == b$tag && a$Variable != b$Variable) next
      va <- means[a$series, ]; vb <- means[b$series, ]
      na_ <- sum(is.finite(va)); nb_ <- sum(is.finite(vb))
      ok <- is.finite(va) & is.finite(vb) & va > 0 & vb > 0
      r <- unname(vb[ok] / va[ok])
      rows[[length(rows) + 1L]] <- data.frame(
        Group = a$group, Domain = a$domain, Series_A = a$series, Series_B = b$series,
        Dataset_A = a$Dataset, Dataset_B = b$Dataset, Unit = a$unit,
        Species_A = na_, Species_B = nb_, Shared_species = length(r),
        Median_ratio_B_over_A = if (length(r)) round(stats::median(r), 4) else NA_real_,
        Pct_within_1pct = if (length(r)) round(100 * mean(abs(r - 1) <= 0.01), 1) else NA_real_,
        Pct_within_10pct = if (length(r)) round(100 * mean(abs(r - 1) <= 0.10), 1) else NA_real_,
        Verdict = sr_verdict(r, a$pool, b$pool),
        Decision_on_record = sr_decision_for(a$series, b$series, canon),
        stringsAsFactors = FALSE)
    }
  }
  if (!length(rows)) return(data.frame())
  out <- do.call(rbind, rows)
  out$Verdict <- factor(out$Verdict, levels = SR_VERDICTS)
  out[order(out$Verdict, -out$Shared_species), , drop = FALSE]
}

# Species-by-species view of one pair: both values in base units, the ratio,
# and a flag where they differ by more than `tol`.
sr_pair_detail <- function(data, meta, series_a, series_b, tol = 0.10) {
  st <- sr_series_table(data, meta)
  one <- function(s) {
    x <- st[st$series == s, , drop = FALSE]
    if (!nrow(x)) return(data.frame(Species = character(0), v = numeric(0), src = character(0)))
    v <- tapply(x$value_base, x$Species, mean)
    src <- tapply(x$Source, x$Species, function(z) paste(unique(z[!is.na(z) & nzchar(z)]), collapse = " | "))
    data.frame(Species = names(v), v = as.numeric(v), src = as.character(src[names(v)]),
               stringsAsFactors = FALSE)
  }
  A <- one(series_a); B <- one(series_b)
  sp <- sort(union(A$Species, B$Species))
  out <- data.frame(Species = sp, stringsAsFactors = FALSE)
  out$Value_A <- A$v[match(sp, A$Species)]; out$Value_B <- B$v[match(sp, B$Species)]
  out$Ratio_B_over_A <- ifelse(is.finite(out$Value_A) & is.finite(out$Value_B) & out$Value_A > 0,
                               round(out$Value_B / out$Value_A, 4), NA_real_)
  out$Status <- ifelse(is.na(out$Value_A), "B only",
                ifelse(is.na(out$Value_B), "A only",
                ifelse(is.na(out$Ratio_B_over_A), "not comparable",
                ifelse(abs(out$Ratio_B_over_A - 1) <= 0.01, "same",
                ifelse(abs(out$Ratio_B_over_A - 1) <= tol, "within tolerance",
                       "DIFFERS")))))
  out$Sources_A <- A$src[match(sp, A$Species)]; out$Sources_B <- B$src[match(sp, B$Species)]
  out[order(out$Status != "DIFFERS", -abs(log10(ifelse(is.na(out$Ratio_B_over_A) | out$Ratio_B_over_A <= 0, 1, out$Ratio_B_over_A))), out$Species), , drop = FALSE]
}

# Reconciled view of a whole candidate group: one column per series, the spread
# across series, and the value taken by the user's precedence order (first
# available wins), with the series it came from. Nothing is averaged across
# series; a species whose series disagree beyond `tol` is flagged.
sr_reconciled_view <- function(data, meta, series, precedence = series, tol = 0.10) {
  st <- sr_series_table(data, meta)
  st <- st[st$series %in% series, , drop = FALSE]
  if (!nrow(st)) return(data.frame())
  m <- tapply(st$value_base, list(st$Species, st$series), mean)
  sp <- rownames(m)
  out <- data.frame(Species = sp, stringsAsFactors = FALSE, check.names = FALSE)
  for (s in series) out[[s]] <- if (s %in% colnames(m)) unname(m[sp, s]) else NA_real_
  vals <- as.matrix(out[, series, drop = FALSE])
  out$N_series <- rowSums(is.finite(vals))
  lo <- suppressWarnings(apply(vals, 1, function(v) if (any(is.finite(v))) min(v[is.finite(v)]) else NA_real_))
  hi <- suppressWarnings(apply(vals, 1, function(v) if (any(is.finite(v))) max(v[is.finite(v)]) else NA_real_))
  out$Spread_pct <- ifelse(out$N_series >= 2 & lo > 0, round(100 * (hi / lo - 1), 1), NA_real_)
  prec <- c(intersect(precedence, series), setdiff(series, precedence))
  pick <- rep(NA_real_, length(sp)); from <- rep("", length(sp))
  for (s in rev(prec)) {
    v <- out[[s]]; ok <- is.finite(v)
    pick[ok] <- v[ok]; from[ok] <- s
  }
  out$Preferred_value <- pick; out$Taken_from <- from
  out$Flag <- ifelse(!is.na(out$Spread_pct) & out$Spread_pct > 100 * tol,
                     sprintf("series differ by %.0f%%", out$Spread_pct), "")
  out[order(out$Flag == "", -out$N_series, out$Species), , drop = FALSE]
}
