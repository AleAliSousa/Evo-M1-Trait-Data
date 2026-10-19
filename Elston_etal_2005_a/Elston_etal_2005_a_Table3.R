## Owner decision 2026-10-16: the public TSV is written automatically with the analysis CSV.
## Release switches default ON here; every identity/registry/overwrite check below is unchanged.
if (is.null(getOption("evom1.R_validated"))) options(evom1.R_validated = TRUE)
if (is.null(getOption("evom1.owner_source_review"))) options(evom1.owner_source_review = TRUE)
if (is.null(getOption("evom1.publish"))) options(evom1.publish = TRUE)
# Frozen published table -> analysis CSV; public export remains owner/R-gated.
expected.basename <- "Elston_etal_2005_a_Table3.R"
locate.self <- function() {
  # source() sets ofile; sys.source() sets file; a wrapper --file is not this reader.
  for (fr in rev(sys.frames())) {
    for (key in c("ofile", "file")) {
      if (exists(key, envir = fr, inherits = FALSE)) {
        candidate <- get(key, envir = fr, inherits = FALSE)
        if (is.character(candidate) && length(candidate) == 1L &&
            !is.na(candidate) && basename(candidate) == expected.basename &&
            file.exists(candidate)) return(normalizePath(candidate, mustWork = TRUE))
      }
    }
  }
  arguments <- commandArgs(trailingOnly = FALSE)
  candidates <- sub("^--file=", "", arguments[grepl("^--file=", arguments)])
  candidates <- c(candidates, file.path(getwd(), expected.basename))
  for (candidate in candidates) {
    if (basename(candidate) == expected.basename && file.exists(candidate))
      return(normalizePath(candidate, mustWork = TRUE))
  }
  stop("Cannot locate exact saved item script: ", expected.basename)
}
base <- locate.self()
stopifnot(identical(basename(base), expected.basename))
folder <- dirname(base)
item_name <- sub("\\.R$", "", basename(base))
snapshot <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                            header = FALSE, colClasses = "character", na.strings = NULL,
                            check.names = FALSE, fileEncoding = "UTF-8", blank.lines.skip = FALSE)
context <- utils::read.csv(file.path(folder, "reference_tables",
                          paste0(item_name, "_context_snapshot.csv")),
                          colClasses = "character", na.strings = NULL,
                          check.names = FALSE, fileEncoding = "UTF-8")
stopifnot(ncol(snapshot) == 11L, nrow(context) == 10L,
          all(context$Reference == item_name), all(context$Data_role == "primary"))
source.doi <- unique(context$source_doi)
stopifnot(length(source.doi) == 1L, nzchar(source.doi))
context.key <- paste(context$Reference, context$Case, context$Cortical_area_as_published, sep = "|")
stopifnot(!anyDuplicated(context.key))
headers <- which(snapshot[[1L]] %in% c("VM1", "VM2"))
stopifnot(length(headers) == 6L,
          identical(snapshot[[1L]][headers], rep(c("VM1", "VM2"), each = 3L)))
areas <- c("7", "5", "1/2", "4", "6")
records <- vector("list", length(headers) * length(areas) * 10L)
k <- 0L
for (panel in seq_along(headers)) {
  h <- headers[panel]
  case <- snapshot[[1L]][h]
  within.case <- ((panel - 1L) %% 3L) + 1L
  stopifnot(identical(snapshot[[1L]][h + seq_along(areas)], areas))
  for (area.order in seq_along(areas)) {
    area <- areas[area.order]
    join <- match(paste(item_name, case, area, sep = "|"), context.key)
    if (is.na(join)) stop("Case-area context join unresolved")
    ctx <- context[join, , drop = FALSE]
    for (j in seq_len(10L)) {
      label <- gsub("[[:space:]]+", " ", snapshot[h, j + 1L])
      if (!grepl("^[0-9]+–[0-9]+ μm$", label)) stop("Invalid printed distance header")
      bounds <- as.integer(strsplit(sub(" μm$", "", label), "–", fixed = TRUE)[[1L]])
      bin.order <- (within.case - 1L) * 10L + j
      stopifnot(identical(bounds, c(if (bin.order == 1L) 0L else 10L * (bin.order - 1L) + 1L,
                                  10L * bin.order)))
      annotated <- snapshot[h + area.order, j + 1L]
      bold <- grepl("^\\*\\*[0-9]+[.][0-9]+\\*\\*±[0-9]+[.][0-9]+$", annotated)
      cell <- gsub("**", "", annotated, fixed = TRUE)
      if (!grepl("^0$|^[0-9]+[.][0-9]+±[0-9]+[.][0-9]+$", cell) ||
          (grepl("*", annotated, fixed = TRUE) && !bold)) stop("Invalid frozen numerical cell/annotation")
      parts <- strsplit(cell, "±", fixed = TRUE)[[1L]]
      mean.printed <- parts[1L]
      sem.printed <- if (length(parts) == 2L) parts[2L] else ""
      mean <- as.numeric(mean.printed)
      sem <- if (nzchar(sem.printed)) as.numeric(sem.printed) else NA_real_
      stopifnot(is.finite(mean), mean >= 0, is.na(sem) || (is.finite(sem) && sem >= 0),
                ctx$Body_mass_unit_as_published == "kg")
      # Spines/10 μm and distance μm stay in printed units; context kg ×1000 -> g.
      body.mass <- as.numeric(ctx$Body_mass_as_published) * 1000
      stopifnot(is.finite(body.mass), body.mass > 0)
      k <- k + 1L
      records[[k]] <- data.frame(
        Reference = item_name, Case = case, Cortical_area_as_published = area,
        Panel_order = panel, Panel_within_case = within.case, Area_order = area.order,
        Bin_order = bin.order, Distance_bin_as_published = label,
        Distance_lower_um = bounds[1L], Distance_upper_um = bounds[2L],
        Cell_as_printed = cell, Mean_as_printed = mean.printed, SEM_as_printed = sem.printed,
        Spines_per_10um_mean = mean, Spines_per_10um_SEM = sem,
        Bold_mean_as_published = bold, Literal_zero_as_published = cell == "0",
        SEM_status = if (nzchar(sem.printed)) "printed" else "not printed; unspecified",
        species_as_published = ctx$species_as_published, species_in_title = ctx$species_in_title,
        Body_mass_g = body.mass, Hemisphere = ctx$Hemisphere, Layer = ctx$Layer,
        Dendritic_compartment = ctx$Dendritic_compartment, Data_role = ctx$Data_role,
        Observation_level = ctx$Observation_level, source_doi = source.doi,
        stringsAsFactors = FALSE, check.names = FALSE)
    }
  }
}
final.dataframe <- do.call(rbind, records)
rownames(final.dataframe) <- NULL
stopifnot(nrow(final.dataframe) == 300L, ncol(final.dataframe) == 27L,
          !anyDuplicated(paste(final.dataframe$Case, final.dataframe$Cortical_area_as_published,
                               final.dataframe$Bin_order, sep = "|")),
          sum(final.dataframe$Bold_mean_as_published) == 10L,
          sum(final.dataframe$Literal_zero_as_published) == 101L,
          identical(is.na(final.dataframe$Spines_per_10um_SEM), final.dataframe$Literal_zero_as_published))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names = FALSE, na = "", fileEncoding = "UTF-8")

# Try a fresh exact-name registry lookup, even for the default analysis-only run.
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root)
  root <- dirname(root)
item_encoded <- NA_character_
registry.matches.source <- FALSE
if (file.exists(file.path(root, "__ReadMe.xlsx")) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", trim_ws = FALSE)
  required <- c("Item name", "Item encoded", "Item number", "DOI (or Alt)",
                "Citation (APA 7th-Annotated)", "DOI if different from article or doi Alt ")
  if (!all(required %in% names(filecodes))) stop("Current registry headers are incomplete")
  matches <- which(!is.na(filecodes[["Item name"]]) & filecodes[["Item name"]] == item_name)
  if (length(matches) != 1L) stop("Current exact Item name must match once")
  item_encoded <- as.character(filecodes[["Item encoded"]][matches])
  expected.encoded <- paste0(gsub("/", "%2F", source.doi, fixed = TRUE), "_",
                             sub("^.*_", "", item_name))
  registered.doi <- as.character(filecodes[["DOI (or Alt)"]][matches])
  registered.citation <- as.character(filecodes[["Citation (APA 7th-Annotated)"]][matches])
  registered.item <- as.character(filecodes[["Item number"]][matches])
  override <- as.character(filecodes[["DOI if different from article or doi Alt "]][matches])
  registry.matches.source <- isTRUE(!is.na(item_encoded) && nzchar(item_encoded) &&
    !grepl("_$|[/\\\\]", item_encoded) && identical(item_encoded, expected.encoded) &&
    !is.na(registered.doi) && identical(utils::URLdecode(registered.doi), source.doi) &&
    !is.na(registered.citation) && grepl(paste0("https://doi.org/", source.doi), registered.citation, fixed = TRUE) &&
    !is.na(registered.item) && identical(gsub(" ", "", registered.item, fixed = TRUE), sub("^.*_", "", item_name)) &&
    (is.na(override) || !nzchar(trimws(override))))
  if (!registry.matches.source) message("Public TSV WITHHELD: registry DOI/citation/Item encoded does not match source identity, or C is not blank/default.")
} else {
  message("Public TSV WITHHELD: fresh registry lookup unavailable (complete repository/readxl required).")
}
if (identical(getOption("evom1.publish", FALSE), TRUE)) {
  if (!identical(getOption("evom1.owner_source_review", FALSE), TRUE) ||
      !identical(getOption("evom1.R_validated", FALSE), TRUE))
    stop("Public TSV withheld: owner source-identity/placement review and actual R validation required")
  if (!registry.matches.source) stop("Public TSV withheld: fresh registry identity does not match printed source DOI and encoded item")
  public <- file.path(root, "__Public", "comparative-data")
  if (!dir.exists(public)) stop("Canonical public directory not mounted")
  destination <- file.path(public, paste0(item_encoded, ".tsv"))
  if (file.exists(destination)) stop("Existing public TSV requires owner reconciliation; this item reader never overwrites it")
  utils::write.table(final.dataframe, destination, sep = "\t", row.names = FALSE,
                     quote = FALSE, na = "", fileEncoding = "UTF-8")
} else {
  message("Analysis CSV only. Public TSV WITHHELD; no registry, keys or merge updates.")
}
