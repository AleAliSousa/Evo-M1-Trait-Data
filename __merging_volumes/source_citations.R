# Source item name -> publishable citation.
#
# WHY: the merged long tables report provenance as ITEM NAMES (e.g.
# "Bauernfeind_etal_2013_Table1") because that is the key the merge engine, the
# term maps and __ReadMe.xlsx all share. An item name is not a citation, so
# nothing downstream could cite a value without a manual lookup. This file turns
# the registry into that lookup, so every value in volumes_long*.csv is traceable
# to a specific paper AND a specific table within it -- the granularity a methods
# section or a supplementary source table needs.
#
# USAGE (sourced by volumes_compiled.R / _select.R / _DeCasien.R):
#   source(file.path(folder, "source_citations.R"))
#   cit <- source_citations(base, unique(long$Source))   # tibble, one row per Source
#   write_csv(cit, "volumes_source_citations.csv")
#
# The single source of truth is __ReadMe.xlsx (sheet 1), matched CASE- and
# SPACE-INSENSITIVELY on "Item name" exactly as read_item() does, so a registry
# case drift (Table2 vs TABLE2) can never orphan a citation. Sources that are not
# registry items (currently only the DeCasien gap-fill pseudo-source) are mapped
# through `pseudo_source_items` below.

## Sources that are not themselves __ReadMe.xlsx items -> the registry item that
## should be cited for them. Add a row here if a future merge invents another
## synthetic source label.
pseudo_source_items <- c(
  # step 4b gap-fill: the value is DeCasien & Higham's own compiled mean, so the
  # citable item is their MOESM3 brain-region supplement.
  "DeCasien2019_MOESM3_meanvalue" = "DeCasien_Higham_2019_SupplementaryData1-BrainRegion"
)

source_citations <- function(base, sources, registry = NULL) {
  stopifnot(is.character(sources))
  sources <- sort(unique(sources[!is.na(sources) & nzchar(sources)]))
  if (is.null(registry))
    registry <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")

  # same normalizer as read_item(): case- and space-insensitive item-name match
  norm <- function(x) tolower(gsub(" ", "", as.character(x)))
  # registry column names carry trailing spaces in places; fetch defensively and
  # return NA rather than erroring, so a renamed column degrades to a blank cell
  # instead of breaking the merge.
  col <- function(nm) {
    hit <- names(registry)[norm(names(registry)) == norm(nm)]
    if (length(hit)) registry[[hit[1]]] else rep(NA_character_, nrow(registry))
  }
  # %2F/%3A-encoded DOIs are stored that way to be filename-safe; decode for display
  dec <- function(x) vapply(as.character(x), function(v)
    if (is.na(v) || !nzchar(v)) NA_character_
    else tryCatch(utils::URLdecode(v), error = function(e) v), character(1), USE.NAMES = FALSE)

  # the item to look up: the source itself, or its pseudo-source mapping
  lookup <- ifelse(sources %in% names(pseudo_source_items),
                   pseudo_source_items[sources], sources)
  i <- match(norm(lookup), norm(col("Item name")))

  blank <- function(x) ifelse(is.na(x) | !nzchar(trimws(as.character(x))), NA_character_, trimws(as.character(x)))
  doi   <- blank(dec(col("DOI (or Alt)")[i]))

  # Short in-text label. "et al." is only correct for 3+ authors, and the registry already encodes
  # which case a paper is: "other author(s)" holds the literal token "etal" for 3+, a single surname
  # for a two-author paper, and is blank for a sole author. Follow that convention rather than
  # counting names, so "Bush & Allman (2003)" never comes out as "Bush et al. (2003)". Getting this
  # wrong is a copy-editor catch, so it is derived once here rather than in each consumer.
  a1  <- blank(col("1st Author")[i]); yr <- blank(col("year")[i]); tb <- blank(col("Item number")[i])
  oth <- blank(col("other author(s)")[i])
  is_etal <- !is.na(oth) & grepl("^et[ .]?al[.]?$", trimws(oth), ignore.case = TRUE)
  authors <- dplyr::case_when(
    is.na(a1)  ~ NA_character_,
    is.na(oth) ~ a1,                                   # sole author
    is_etal    ~ paste0(a1, " et al."),                # 3+ authors
    TRUE       ~ paste0(a1, " & ", trimws(oth)))       # exactly two
  cited_as <- ifelse(is.na(authors) | is.na(yr), NA_character_,
                     paste0(authors, " (", yr, ")", ifelse(is.na(tb), "", paste0(" ", tb))))

  out <- tibble::tibble(
    Source            = sources,
    Cited_as          = cited_as,                              # short in-text form, incl. the table
    Registry_item     = ifelse(is.na(i), NA_character_, as.character(col("Item name")[i])),
    Citation          = blank(col("Citation (APA 7th-Annotated)")[i]),
    First_author      = blank(col("1st Author")[i]),
    Other_authors     = blank(col("other author(s)")[i]),
    Year              = suppressWarnings(as.integer(blank(col("year")[i]))),
    Publication       = blank(col("Publication name")[i]),
    Table             = blank(col("Item number")[i]),          # which table/figure within the paper
    DOI_or_ISBN       = doi,
    URL               = ifelse(is.na(doi), NA_character_,
                        ifelse(grepl("^ISBN", doi, ignore.case = TRUE), NA_character_,
                               paste0("https://doi.org/", doi))),
    Registry_team     = blank(col("Team")[i]),
    Registry_collection = blank(col("Collection")[i]),
    Cited_via         = ifelse(sources %in% names(pseudo_source_items),
                               "compiled value -- cite the compilation, not a primary measurement",
                               NA_character_)
  )
  # A missing citation is a registry gap, not something to paper over: name the
  # offenders loudly so they get a row rather than silently shipping a blank.
  gaps <- out$Source[is.na(out$Citation)]
  if (length(gaps))
    warning("source_citations(): no __ReadMe.xlsx citation for ", length(gaps), " source(s): ",
            paste(head(gaps, 8), collapse = "; "),
            if (length(gaps) > 8) " ..." else "",
            ". Add the registry row (or a pseudo_source_items mapping) -- these values cannot be ",
            "cited in a publication until you do.", call. = FALSE)
  out
}
