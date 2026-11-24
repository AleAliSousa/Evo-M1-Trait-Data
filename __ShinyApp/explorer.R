# Helpers shared by the species browser, regression sample audit and checks.
# Availability is based on measurement values, including categorical values and
# zero. It never substitutes values from another species in the same genus.
has_trait_value <- function(x) {
  !is.na(x) & nzchar(trimws(x)) & !trimws(x) %in% c("NA", "NaN", "Inf", "-Inf")
}

join_sources <- function(x) {
  paste(unique(x[!is.na(x) & nzchar(trimws(x))]), collapse = " | ")
}

source_tokens <- function(x) {
  # Some DOI-encoded filenames contain a literal semicolon. The item lists
  # emitted here separate filenames with "; "; retain those complete tokens
  # alongside legacy bare-semicolon-separated item names.
  x <- as.character(x[!is.na(x)])
  tokens <- trimws(unique(c(x, unlist(strsplit(x, ";\\s+|\\|")),
                           unlist(strsplit(x, "[;|]")))))
  tokens[nzchar(tokens)]
}

measurement_references <- function(items, sources, catalogue) {
  tokens <- source_tokens(c(items, sources))
  exact <- catalogue$item_name %in% tokens | catalogue$file %in% tokens
  # A publication token can identify a paper without identifying a table.
  m <- catalogue[exact | catalogue$publication %in% tokens, , drop = FALSE]
  c(References = join_sources(m$citation), Reference_URLs = join_sources(m$url))
}

measurement_reference_columns <- function(data, catalogue) {
  # Repeated item/source combinations share bibliography lookups, even when a
  # table contains thousands of species. Keep the original row order intact.
  key <- paste(data$Items, data$Source, sep = "\r")
  first <- which(!duplicated(key))
  refs <- lapply(first, function(i) measurement_references(data$Items[i], data$Source[i], catalogue))
  for (field in c("References", "Reference_URLs"))
    data[[field]] <- vapply(refs, `[[`, character(1), field)[match(key, key[first])]
  data
}

# Match the brain-mass merge's team means and primary-team preference. The
# combined measurement inherits the selected basis, never another basis's items.
brain_mass_items <- function(merged, reports) {
  reports <- reports[tolower(as.character(reports$pool_eligible)) == "true" &
                       is.finite(reports$Value_g), , drop = FALSE]
  key <- function(sp, measure) paste(sp, measure, sep = "\r")
  groups <- split(reports, key(reports$Species, reports$measure_emitted))
  items <- vapply(groups, function(d) {
    primary_teams <- unique(d$Team[d$role == "primary"])
    if (length(primary_teams)) d <- d[d$Team %in% primary_teams, , drop = FALSE]
    paste(sort(unique(d$Source)), collapse = "; ")
  }, character(1))
  measure <- merged$Measure
  selected <- !is.na(merged$selected_measure) & nzchar(merged$selected_measure)
  measure[selected] <- merged$selected_measure[selected]
  out <- unname(items[key(merged$Species, measure)])
  out[is.na(out)] <- ""
  out
}

# Add provenance only after model fitting. Use exactly the finite records that
# supply each species median; retain X, Y and control references independently.
# Contributor/team matches are discovery hints, not evidence for a citation.
regression_sources <- function(species, vars, data, catalogue) {
  out <- species
  for (v in unique(vars)) {
    d <- data[data$Species %in% species$Species & data$Variable == v &
                is.finite(data$Value_num), , drop = FALSE]
    groups <- split(d, d$Species)
    fields <- c("Sources", "Source_items", "Source_details", "Hemispheres", "References", "Reference_URLs")
    summaries <- lapply(groups, function(g) {
      c(Sources = join_sources(c(g$Source, g$Teams)),
        Source_items = join_sources(g$Items), Source_details = join_sources(g$Source_details),
        # hemisphere notes of the records pooled into this species value
        Hemispheres = sr_hemi_join(sr_hemi_col(g)),
        measurement_references(g$Items, g$Source, catalogue))
    })
    for (field in fields) {
      values <- vapply(summaries, `[[`, character(1), field)
      value <- unname(values[species$Species]); value[is.na(value)] <- ""
      out[[paste0(v, "_", field)]] <- value
    }
  }
  out
}

build_species_index <- function(species, taxonomy, canonical = identity) {
  out <- data.frame(Species = sort(unique(species)), stringsAsFactors = FALSE)
  out$Genus <- sub(" .*", "", out$Species)
  out$Order <- "Unknown"
  out$Order_basis <- "Not recorded"
  if (is.null(taxonomy) || !nrow(taxonomy)) return(out)
  tx <- taxonomy
  tx$Species <- canonical(tx$Species)
  tx$Genus <- if ("Genus" %in% names(tx)) tx$Genus else sub(" .*", "", tx$Species)
  # A common-name word is not a genus (Tree shrew / Tree swallow).
  recorded_genus <- tx$Genus[match(out$Species, tx$Species)]
  out$Genus <- ifelse(!is.na(recorded_genus) & nzchar(recorded_genus), recorded_genus, out$Genus)
  tx <- tx[!is.na(tx$Order) & nzchar(tx$Order) & tx$Order != "Unknown", ]
  unique_order <- function(x) if (length(unique(x)) == 1L) unique(x) else NA_character_
  exact <- vapply(split(tx$Order, tx$Species), unique_order, character(1))
  genus <- vapply(split(tx$Order, tx$Genus), unique_order, character(1))
  hit <- unname(exact[out$Species]); fallback <- unname(genus[out$Genus])
  known <- !is.na(hit)
  inferred <- !known & !is.na(fallback)
  out$Order[known] <- hit[known]
  out$Order_basis[known] <- "Species taxonomy key"
  if ("Order_basis" %in% names(tx)) {
    basis <- tx$Order_basis[match(out$Species[known], tx$Species)]
    out$Order_basis[known] <- ifelse(is.na(basis) | !nzchar(basis), "Species taxonomy key", basis)
  }
  out$Order[inferred] <- fallback[inferred]
  out$Order_basis[inferred] <- "Inferred from genus (one recorded order)"
  out
}

trait_coverage <- function(data, species, domains = character(), shared = FALSE) {
  d <- data[data$Species %in% species & data$Variable %in% meas_labels &
              has_trait_value(data$Value), , drop = FALSE]
  if (length(domains)) d <- d[unname(var_dom[d$Variable]) %in% domains, , drop = FALSE]
  pairs <- unique(d[c("Species", "Variable")])
  n <- table(pairs$Variable)
  out <- data.frame(Variable = as.character(names(n)), Species_with_data = as.integer(n),
                    stringsAsFactors = FALSE)
  out$Selected_species <- rep(length(species), nrow(out))
  out$Coverage_percent <- if (length(species)) round(100 * out$Species_with_data / length(species), 1) else numeric(nrow(out))
  out$Domain <- unname(var_dom[out$Variable])
  out$Unit <- look(lab_unit, out$Variable)
  out$Definition <- look(lab_def, out$Variable)
  if (shared) out <- out[out$Species_with_data == length(species), , drop = FALSE]
  out <- out[order(-out$Species_with_data, match(out$Domain, domain_levels), out$Variable),
             c("Variable", "Domain", "Unit", "Species_with_data", "Selected_species", "Coverage_percent", "Definition")]
  rownames(out) <- NULL
  out
}

trait_value_matrix <- function(data, species, variables) {
  out <- data.frame(Variable = variables, stringsAsFactors = FALSE, check.names = FALSE)
  out$Domain <- unname(var_dom[variables])
  d <- data[data$Species %in% species & data$Variable %in% variables & has_trait_value(data$Value), ]
  # a doubled or one-hemisphere value says so in its cell: "544 [2 x one hemisphere]"
  values <- split(paste0(d$Value, sr_hemi_suffix(sr_hemi_col(d))), paste(d$Species, d$Variable, sep = "\r"))
  values <- vapply(values, function(x) paste(unique(x), collapse = " | "), character(1))
  for (sp in species) out[[sp]] <- unname(values[paste(sp, variables, sep = "\r")])
  out
}

# Keep every candidate species in the audit, including species with no selected
# measurements. Exclusion reasons use the same finite/log/tree rules as reg_fit.
regression_audit <- function(w, vars, logscale, method, phy = NULL) {
  missing <- vapply(seq_len(nrow(w)), function(i) {
    paste(vars[!is.finite(as.numeric(w[i, vars, drop = TRUE]))], collapse = "; ")
  }, character(1))
  nonpositive <- vapply(seq_len(nrow(w)), function(i) {
    x <- as.numeric(w[i, vars, drop = TRUE])
    paste(vars[is.finite(x) & x <= 0], collapse = "; ")
  }, character(1))
  status <- ifelse(nzchar(missing), "Missing / non-finite measurement", "Included")
  if (isTRUE(logscale)) status[status == "Included" & nzchar(nonpositive)] <- "Non-positive under log10"
  if (method != "OLS") {
    tips <- if (is.null(phy)) character() else phy$tip.label
    m <- match(tolower(w$Species), tolower(tip_binom(tips)))
    eligible <- which(status == "Included")
    status[eligible[is.na(m[eligible])]] <- "No matching tree tip"
    matched <- eligible[!is.na(m[eligible])]
    status[matched[duplicated(m[matched])]] <- "Duplicate tree tip"
  }
  data.frame(Species = w$Species, Order = w$Order, Status = status,
             Missing_variables = missing, Nonpositive_variables = nonpositive,
             stringsAsFactors = FALSE)
}
