# Helpers shared by the species browser, regression sample audit and checks.
# Availability is based on measurement values, including categorical values and
# zero. It never substitutes values from another species in the same genus.
has_trait_value <- function(x) {
  !is.na(x) & nzchar(trimws(x)) & !trimws(x) %in% c("NA", "NaN", "Inf", "-Inf")
}

build_species_index <- function(species, taxonomy, canonical = identity) {
  out <- data.frame(Species = sort(unique(species)), stringsAsFactors = FALSE)
  out$Genus <- sub(" .*", "", out$Species)
  out$Order <- "Unknown"
  out$Order_basis <- "Not recorded"
  if (is.null(taxonomy) || !nrow(taxonomy)) return(out)
  tx <- taxonomy
  tx$Species <- canonical(tx$Species)
  tx <- tx[!is.na(tx$Order) & nzchar(tx$Order) & tx$Order != "Unknown", ]
  unique_order <- function(x) if (length(unique(x)) == 1L) unique(x) else NA_character_
  exact <- vapply(split(tx$Order, tx$Species), unique_order, character(1))
  genus <- vapply(split(tx$Order, sub(" .*", "", tx$Species)), unique_order, character(1))
  hit <- unname(exact[out$Species]); fallback <- unname(genus[out$Genus])
  known <- !is.na(hit)
  inferred <- !known & !is.na(fallback)
  out$Order[known] <- hit[known]
  out$Order_basis[known] <- "Species taxonomy key"
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
  values <- split(d$Value, paste(d$Species, d$Variable, sep = "\r"))
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
