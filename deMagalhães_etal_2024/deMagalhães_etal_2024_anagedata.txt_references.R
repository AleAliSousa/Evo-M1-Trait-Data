# deMagalhães_etal_2024_anagedata.txt_references.R
#
# Build the AnAge Build-15 bibliography lookup and its row-level join to anage_data.txt.
# The browser-print PDF is a complete 1,467-row bibliography table with BIBLIOID,
# author/year, title, citation count, and external-link type. Its BIBLIOID is the
# numeric key used by the dataset's Source / References columns.
#
# Frozen inputs
#   Search the AnAge Database.pdf   browser print of the full AnAge bibliography
#   anage_data.txt                  Build-15 dataset (4,645 rows)
#
# Outputs (reference_tables/)
#   <Item>_references.csv                 one row per BIBLIOID
#   <Item>_reference_alignment.csv        one row per dataset row x reference occurrence
#   <Item>_reference_alignment_issues.csv unresolved key/text-source summary

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})

item_dir <- dirname(.sp)
item_name <- sub("_references$", "", tools::file_path_sans_ext(basename(.sp)))
pdf_file <- file.path(item_dir, "Search the AnAge Database.pdf")
data_file <- file.path(item_dir, "anage_data.txt")
out_dir <- file.path(item_dir, "reference_tables")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!requireNamespace("pdftools", quietly = TRUE))
  stop("Package 'pdftools' is required to extract the frozen bibliography PDF.", call. = FALSE)
stopifnot(file.exists(pdf_file), file.exists(data_file))

join_words <- function(z) {
  if (!nrow(z)) return("")
  z <- z[order(z$y, z$x), ]
  x <- paste(z$text, collapse = " ")
  # Rejoin words split only because a hyphenated expression wrapped at the PDF line edge.
  x <- gsub("([[:alnum:]])- ([[:alnum:]])", "\\1-\\2", x, perl = TRUE)
  trimws(gsub("[[:space:]]+", " ", x))
}

# The PDF table uses fixed x-columns. Each five-digit BIBLIOID anchors one row;
# vertical midpoints between adjacent IDs retain wrapped author/title lines.
pages <- pdftools::pdf_data(pdf_file)
parsed <- list()
k <- 0L
for (pdf_page in seq_along(pages)) {
  d <- pages[[pdf_page]]
  ids <- d[abs(d$x - 189) <= 3 & grepl("^[0-9]{5}$", d$text), ]
  ids <- ids[order(ids$y), ]
  if (!nrow(ids)) next
  yy <- ids$y
  for (i in seq_len(nrow(ids))) {
    lower <- if (i > 1) (yy[i - 1] + yy[i]) / 2 else
      yy[i] - if (nrow(ids) > 1) (yy[2] - yy[1]) / 2 else 20
    upper <- if (i < nrow(ids)) (yy[i] + yy[i + 1]) / 2 else
      yy[i] + if (nrow(ids) > 1) (yy[i] - yy[i - 1]) / 2 else 20
    z <- d[d$y >= lower & d$y < upper & d$x >= 220 & d$x < 555, ]

    author_year <- join_words(z[z$x < 295, ])
    title <- join_words(z[z$x >= 295 & z$x < 475, ])
    citation_count <- join_words(z[z$x >= 475 & z$x < 510, ])
    external_link_type <- join_words(z[z$x >= 510, ])
    year <- if (grepl("\\([^()]+\\)$", author_year))
      sub("^.*\\(([^()]*)\\)$", "\\1", author_year) else ""
    authors <- if (nzchar(year))
      trimws(sub("\\s*\\([^()]+\\)$", "", author_year)) else author_year

    k <- k + 1L
    parsed[[k]] <- data.frame(
      biblio_id = ids$text[i], authors_as_published = authors,
      year_as_published = year, title_as_published = title,
      pdf_citation_count = as.integer(citation_count),
      external_link_type = external_link_type,
      source_pdf_page = pdf_page, pdf_display_rank = k,
      stringsAsFactors = FALSE
    )
  }
}
refs <- do.call(rbind, parsed)

stopifnot(
  nrow(refs) == 1467L,
  !anyDuplicated(refs$biblio_id),
  identical(sort(as.integer(refs$biblio_id)), seq_len(1467L)),
  !anyNA(refs$pdf_citation_count),
  all(nzchar(refs$title_as_published)),
  all(refs$external_link_type %in% c("PubMed", "Search", "URL"))
)

refs$ref_key <- as.character(as.integer(refs$biblio_id))
refs$citation <- ifelse(
  nzchar(refs$authors_as_published),
  paste0(
    refs$authors_as_published,
    ifelse(nzchar(refs$year_as_published), paste0(" (", refs$year_as_published, ")"), ""),
    ". ", refs$title_as_published
  ),
  refs$title_as_published
)
refs$anage_bibliography_url <- paste0(
  "https://genomics.senescence.info/species/biblio.php?id=", refs$biblio_id
)

raw <- read.delim(
  data_file, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE,
  colClasses = "character", encoding = "UTF-8", quote = ""
)
stopifnot(nrow(raw) == 4645L, all(c("HAGRID", "Genus", "Species", "Source", "References") %in% names(raw)))

numeric_keys <- function(x) {
  x <- trimws(x)
  if (!nzchar(x) || !grepl("^[0-9]+(?:,[0-9]+)*$", x, perl = TRUE)) return(character())
  as.character(as.integer(strsplit(x, ",", fixed = TRUE)[[1]]))
}
source_keys <- lapply(raw$Source, numeric_keys)
reference_keys <- lapply(raw$References, numeric_keys)

source_count <- tabulate(as.integer(unlist(source_keys)), nbins = 1467L)
references_count <- tabulate(as.integer(unlist(reference_keys)), nbins = 1467L)
any_count <- integer(1467L)
for (i in seq_len(nrow(raw))) {
  keys <- unique(c(source_keys[[i]], reference_keys[[i]]))
  keys <- as.integer(keys[keys != "0"])
  if (length(keys)) any_count[keys] <- any_count[keys] + 1L
}

idx <- as.integer(refs$ref_key)
refs$dataset_rows_source_ref <- source_count[idx]
refs$dataset_rows_references <- references_count[idx]
refs$dataset_rows_any_context <- any_count[idx]
refs$cited_in_column <- ifelse(
  refs$dataset_rows_source_ref > 0 & refs$dataset_rows_references > 0,
  "Source_ref; References",
  ifelse(refs$dataset_rows_source_ref > 0, "Source_ref",
         ifelse(refs$dataset_rows_references > 0, "References", ""))
)
refs$citation_count_difference <- refs$dataset_rows_any_context - refs$pdf_citation_count
refs$alignment_status <- ifelse(
  refs$dataset_rows_any_context == 0, "not_used_in_downloaded_dataset",
  ifelse(refs$citation_count_difference == 0, "matched_key_and_count", "matched_key_count_diff")
)
refs$note <- ifelse(
  refs$alignment_status == "matched_key_count_diff",
  paste0(
    "PDF citation count differs from the 4,645-row downloaded dataset by ",
    refs$citation_count_difference,
    "; the live Build-15 page reports 4,671 entries, so small release/export drift is expected."
  ),
  ifelse(
    refs$alignment_status == "not_used_in_downloaded_dataset",
    "Listed in the PDF bibliography but not cited by this 4,645-row downloaded dataset copy.",
    ""
  )
)

refs <- refs[order(as.integer(refs$ref_key)), c(
  "ref_key", "biblio_id", "cited_in_column", "authors_as_published",
  "year_as_published", "title_as_published", "citation", "pdf_citation_count",
  "dataset_rows_source_ref", "dataset_rows_references", "dataset_rows_any_context",
  "citation_count_difference", "alignment_status", "external_link_type",
  "anage_bibliography_url", "source_pdf_page", "pdf_display_rank", "note"
)]

ref_lookup <- setNames(refs$citation, refs$ref_key)
biblio_lookup <- setNames(refs$biblio_id, refs$ref_key)
alignment <- list()
a <- 0L
add_alignment <- function(dataset_row, key_column, applies_to, cell, keys,
                          status_override = NULL, citation_override = NULL, note = "") {
  n <- max(length(keys), 1L)
  if (!length(keys)) keys <- ""
  for (key in keys) {
    known <- nzchar(key) && key %in% refs$ref_key
    status <- if (!is.null(status_override)) status_override else
      if (known) "matched" else "key_not_in_pdf_bibliography"
    citation <- if (!is.null(citation_override)) citation_override else
      if (known) unname(ref_lookup[key]) else ""
    row_note <- note
    if (identical(status, "key_not_in_pdf_bibliography")) {
      row_note <- paste0(
        "Numeric key ", key, " is used by the dataset but absent from the PDF bibliography (BIBLIOID 1-1467). ",
        note
      )
    }
    a <<- a + 1L
    alignment[[a]] <<- data.frame(
      item = item_name,
      dataset_row = dataset_row,
      HAGRID = raw$HAGRID[dataset_row],
      Species = trimws(paste(raw$Genus[dataset_row], raw$Species[dataset_row])),
      key_column = key_column,
      applies_to = applies_to,
      key_cell_as_published = cell,
      n_keys_in_cell = n,
      ref_key = key,
      biblio_id = if (known) unname(biblio_lookup[key]) else "",
      citation = citation,
      match_status = status,
      note = row_note,
      stringsAsFactors = FALSE
    )
  }
}

for (i in seq_len(nrow(raw))) {
  source_cell <- trimws(raw$Source[i])
  if (nzchar(source_cell)) {
    keys <- source_keys[[i]]
    if (length(keys)) {
      add_alignment(
        i, "Source_ref",
        "Maximum_longevity_yrs; Specimen_origin; Sample_size; Data_quality",
        source_cell, keys
      )
    } else {
      add_alignment(
        i, "Source_ref",
        "Maximum_longevity_yrs; Specimen_origin; Sample_size; Data_quality",
        source_cell, character(), status_override = "non_bibliographic_source_text",
        citation_override = source_cell,
        note = "Source_ref is a personal communication or website-feedback label, not a numeric BIBLIOID."
      )
    }
  }

  reference_cell <- trimws(raw$References[i])
  if (nzchar(reference_cell)) {
    add_alignment(
      i, "References", "row_overall", reference_cell, reference_keys[[i]],
      note = "AnAge supplies row-level references but does not identify which individual variables each one supports."
    )
  }
}
alignment <- do.call(rbind, alignment)

unknown_numeric <- sort(unique(alignment$ref_key[alignment$match_status == "key_not_in_pdf_bibliography"]))
stopifnot(
  identical(unknown_numeric, "0"),
  sum(alignment$ref_key == "0") == 20L,
  sum(alignment$match_status == "non_bibliographic_source_text") == 32L,
  length(unique(alignment$citation[alignment$match_status == "non_bibliographic_source_text"])) == 18L,
  sum(refs$alignment_status == "matched_key_and_count") == 1381L,
  sum(refs$alignment_status == "matched_key_count_diff") +
    sum(refs$alignment_status == "not_used_in_downloaded_dataset") == 86L,
  refs$pdf_citation_count[refs$ref_key == "671"] == 1060L,
  refs$dataset_rows_any_context[refs$ref_key == "671"] == 1060L
)

issue_rows <- alignment[alignment$match_status != "matched", ]
issue_key <- paste(issue_rows$match_status, issue_rows$key_column, issue_rows$ref_key,
                   issue_rows$citation, sep = "\r")
issue_groups <- split(seq_len(nrow(issue_rows)), issue_key)
issues <- do.call(rbind, lapply(issue_groups, function(ii) {
  z <- issue_rows[ii, ]
  data.frame(
    issue = z$match_status[1], key_column = z$key_column[1],
    ref_key_or_text = if (nzchar(z$ref_key[1])) z$ref_key[1] else z$citation[1],
    n_rows = length(unique(z$dataset_row)),
    species = paste(sort(unique(z$Species)), collapse = "; "),
    note = z$note[1], stringsAsFactors = FALSE
  )
}))
issues <- issues[order(issues$issue, issues$ref_key_or_text), ]
rownames(issues) <- NULL

write.csv(
  refs, file.path(out_dir, paste0(item_name, "_references.csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8"
)
write.csv(
  alignment, file.path(out_dir, paste0(item_name, "_reference_alignment.csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8"
)
write.csv(
  issues, file.path(out_dir, paste0(item_name, "_reference_alignment_issues.csv")),
  row.names = FALSE, na = "", fileEncoding = "UTF-8"
)

message(
  "Built AnAge references: ", nrow(refs), " bibliography rows; ",
  nrow(alignment), " row-reference links; ", nrow(issues), " summarized issues."
)
message(
  "Matched numeric IDs: 1,421 of 1,422 used; unresolved key: 0 (20 crocodilian rows); ",
  "prose Source_ref rows: 32 (18 unique labels)."
)
