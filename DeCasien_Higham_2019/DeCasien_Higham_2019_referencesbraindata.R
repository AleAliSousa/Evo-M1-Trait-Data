## =============================================================================
## DeCasien & Higham 2019 references used by Brain Region Data
## Supplementary Data 1, sheet "Brain Region Data (mm3)" -> reference CSV
## =============================================================================
##
## Purpose
## -----------------------------------------------------------------------------
## Build DeCasien_Higham_2019_referencesbraindata.csv from the reference codes
## used in the supplementary spreadsheet.
##
## Output
## -----------------------------------------------------------------------------
## Two columns:
##   ref_number, citation
##
## Reference ranges such as "51-52" remain ranges. Citations belonging to a
## range are joined with " | ".
## =============================================================================

options(stringsAsFactors = FALSE)


## ---- packages ---------------------------------------------------------------

required_packages <- c("readxl", "pdftools")

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages)) {
  stop(
    "Install the required package(s): ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}


## ---- paths ------------------------------------------------------------------

script_path <- local({
  argv <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", argv, value = TRUE)
  
  if (length(file_arg) == 1L) {
    path <- sub("^--file=", "", file_arg)
    if (nzchar(path)) return(normalizePath(path, mustWork = FALSE))
  }
  
  source_path <- tryCatch(
    sys.frames()[[1]]$ofile,
    error = function(e) NULL
  )
  
  if (!is.null(source_path) && nzchar(source_path)) {
    return(normalizePath(source_path, mustWork = FALSE))
  }
  
  if (
    requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()
  ) {
    path <- tryCatch(
      rstudioapi::getSourceEditorContext()$path,
      error = function(e) ""
    )
    
    if (!nzchar(path)) {
      path <- tryCatch(
        rstudioapi::getActiveDocumentContext()$path,
        error = function(e) ""
      )
    }
    
    if (nzchar(path)) {
      return(normalizePath(path, mustWork = FALSE))
    }
  }
  
  file.path(getwd(), "DeCasien_Higham_2019_referencesbraindata.R")
})

paper_dir <- dirname(script_path)

supp_xlsx <- file.path(
  paper_dir,
  "41559_2019_969_MOESM3_ESM.xlsx"
)

pdf_file <- file.path(
  paper_dir,
  "DeCasien-2019-Primate mosaic brain evolution r.pdf"
)

output_csv <- file.path(
  paper_dir,
  paste0(
    tools::file_path_sans_ext(basename(script_path)),
    ".csv"
  )
)

if (!file.exists(supp_xlsx)) {
  stop("Cannot find supplementary spreadsheet: ", supp_xlsx, call. = FALSE)
}

if (!file.exists(pdf_file)) {
  stop("Cannot find article PDF: ", pdf_file, call. = FALSE)
}


## ---- helpers ----------------------------------------------------------------

normalize_space <- function(x) {
  trimws(gsub("\\s+", " ", x))
}


normalize_ref_code <- function(x) {
  x <- trimws(as.character(x))
  x <- gsub("\u2010|\u2011|\u2012|\u2013|\u2014|\u2212", "-", x)
  x <- gsub("\\s*-\\s*", "-", x)
  x
}


first_number <- function(x) {
  suppressWarnings(as.integer(sub("^([0-9]+).*", "\\1", x)))
}


expand_ref_code <- function(code) {
  code <- normalize_ref_code(code)
  
  if (grepl("^[0-9]+-[0-9]+$", code)) {
    bounds <- as.integer(strsplit(code, "-", fixed = TRUE)[[1]])
    
    if (bounds[2] < bounds[1]) {
      stop("Invalid descending reference range: ", code, call. = FALSE)
    }
    
    return(seq.int(bounds[1], bounds[2]))
  }
  
  if (!grepl("^[0-9]+$", code)) {
    stop("Unrecognized reference code: ", code, call. = FALSE)
  }
  
  as.integer(code)
}


## ---- read reference codes from spreadsheet ----------------------------------

get_reference_codes_from_sheet <- function(path) {
  brain <- readxl::read_excel(
    path,
    sheet = "Brain Region Data (mm3)",
    col_types = "text"
  )
  
  if (!"References" %in% names(brain)) {
    stop(
      "Sheet 'Brain Region Data (mm3)' does not contain a 'References' column.",
      call. = FALSE
    )
  }
  
  values <- brain$References
  values <- values[!is.na(values) & nzchar(trimws(values))]
  
  refs <- unlist(
    strsplit(values, "\\s*[,;]\\s*", perl = TRUE),
    use.names = FALSE
  )
  
  refs <- normalize_ref_code(refs)
  refs <- unique(refs[nzchar(refs)])
  
  invalid <- refs[
    !grepl("^[0-9]+(?:-[0-9]+)?$", refs, perl = TRUE)
  ]
  
  if (length(invalid)) {
    stop(
      "Unrecognized reference code(s) in spreadsheet: ",
      paste(invalid, collapse = ", "),
      call. = FALSE
    )
  }
  
  refs[order(first_number(refs), grepl("-", refs), refs)]
}


## ---- extract numbered references from PDF -----------------------------------

extract_references_from_pdf <- function(path) {
  txt <- pdftools::pdf_text(path)
  
  if (length(txt) < 11L) {
    stop(
      "The PDF has fewer than 11 extracted pages. ",
      "The expected reference pages cannot be processed.",
      call. = FALSE
    )
  }
  
  page_lines <- function(page_text) {
    strsplit(page_text, "\n", fixed = TRUE)[[1]]
  }
  
  detect_right_column_start <- function(lines) {
    positions <- unlist(
      lapply(lines, function(line) {
        matches <- gregexpr(
          "(^|\\s{2,})([0-9]{1,3})\\.\\s+[A-Z]",
          line,
          perl = TRUE
        )[[1]]
        
        if (identical(matches, -1L)) {
          return(integer(0))
        }
        
        capture_starts <- attr(matches, "capture.start")
        
        if (is.null(capture_starts)) {
          return(integer(0))
        }
        
        starts <- capture_starts[, 2]
        starts[starts > 75L]
      }),
      use.names = FALSE
    )
    
    if (!length(positions)) {
      return(NA_integer_)
    }
    
    counts <- sort(table(positions), decreasing = TRUE)
    as.integer(names(counts)[1])
  }
  
  split_two_columns <- function(page_text) {
    lines <- page_lines(page_text)
    right_start <- detect_right_column_start(lines)
    
    if (is.na(right_start)) {
      return(list(left = lines, right = character(0)))
    }
    
    left <- vapply(
      lines,
      function(line) {
        substr(line, 1L, min(nchar(line), right_start - 1L))
      },
      character(1)
    )
    
    right <- vapply(
      lines,
      function(line) {
        if (nchar(line) >= right_start) {
          substr(line, right_start, nchar(line))
        } else {
          ""
        }
      },
      character(1)
    )
    
    list(left = left, right = right)
  }
  
  page9 <- split_two_columns(txt[9])
  heading_line <- grep("^References\\s*$", trimws(page9$left))[1]
  
  if (is.na(heading_line)) {
    stop(
      "Could not find the References heading on extracted PDF page 9.",
      call. = FALSE
    )
  }
  
  page9_left_references <- page9$left[
    seq.int(heading_line + 1L, length(page9$left))
  ]
  
  page10 <- split_two_columns(txt[10])
  page11 <- split_two_columns(txt[11])
  
  reference_lines <- c(
    page9_left_references,
    page9$right,
    page10$left,
    page10$right,
    page11$left,
    page11$right
  )
  
  section <- paste(reference_lines, collapse = "\n")
  
  section <- sub("(?s)Acknowledgements.*$", "", section, perl = TRUE)
  section <- sub("(?s)Author contributions.*$", "", section, perl = TRUE)
  section <- sub("(?s)Competing interests.*$", "", section, perl = TRUE)
  section <- sub("(?s)Additional information.*$", "", section, perl = TRUE)
  
  section <- gsub(
    "\u2010|\u2011|\u2012|\u2013|\u2014|\u2212",
    "-",
    section
  )
  section <- gsub("\u00a0", " ", section, fixed = TRUE)
  section <- gsub("\r", "\n", section, fixed = TRUE)
  
  section <- gsub(
    "(^|\\n)\\s*([0-9]{1,3})\\.\\s+",
    "\\1@@REF@@\\2. ",
    section,
    perl = TRUE
  )
  
  pieces <- strsplit(section, "@@REF@@", fixed = TRUE)[[1]]
  pieces <- pieces[grepl("^[0-9]{1,3}\\.\\s+", pieces)]
  
  numbers <- sub(
    "^([0-9]{1,3})\\.\\s+.*$",
    "\\1",
    pieces
  )
  
  citations <- sub(
    "^[0-9]{1,3}\\.\\s+",
    "",
    pieces
  )
  
  citations <- normalize_space(citations)
  
  keep <- nzchar(numbers) & nzchar(citations)
  numbers <- numbers[keep]
  citations <- citations[keep]
  
  if (!length(numbers)) {
    stop("No numbered references were extracted from the PDF.", call. = FALSE)
  }
  
  citation_lookup <- split(citations, numbers)
  
  citation_lookup <- vapply(
    citation_lookup,
    function(x) x[which.max(nchar(x))],
    character(1)
  )
  
  citation_lookup[
    order(as.integer(names(citation_lookup)))
  ]
}


## ---- build ------------------------------------------------------------------

refs <- get_reference_codes_from_sheet(supp_xlsx)
citation_lookup <- extract_references_from_pdf(pdf_file)

needed_numbers <- sort(
  unique(
    unlist(
      lapply(refs, expand_ref_code),
      use.names = FALSE
    )
  )
)

missing_numbers <- setdiff(
  as.character(needed_numbers),
  names(citation_lookup)
)

if (length(missing_numbers)) {
  stop(
    "Reference number(s) used in the spreadsheet were not extracted ",
    "from the PDF: ",
    paste(missing_numbers, collapse = ", "),
    call. = FALSE
  )
}

citation_for_code <- function(code) {
  numbers <- expand_ref_code(code)
  citations <- unname(citation_lookup[as.character(numbers)])
  
  if (anyNA(citations)) {
    missing <- numbers[is.na(citations)]
    
    stop(
      "Missing citation text for reference number(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  
  paste(citations, collapse = " | ")
}

out <- data.frame(
  ref_number = refs,
  citation = vapply(refs, citation_for_code, character(1)),
  check.names = FALSE
)


## ---- write ------------------------------------------------------------------

write.csv(
  out,
  output_csv,
  row.names = FALSE,
  fileEncoding = "UTF-8",
  na = ""
)

message(
  "Wrote ",
  nrow(out),
  " reference code rows to: ",
  output_csv
)