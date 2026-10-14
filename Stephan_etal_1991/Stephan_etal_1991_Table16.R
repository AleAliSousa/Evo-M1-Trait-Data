# Reads the immutable published-layout snapshot and item-scoped context; never recreates evidence.
.find_self <- function() {
  for (frame in rev(sys.frames())) {
    for (field in c("ofile", "file")) {
      candidate <- frame[[field]]
      if (is.character(candidate) && length(candidate) == 1L &&
          grepl("^Stephan_etal_1991_Table(13|16)\\.R$", basename(candidate)) && file.exists(candidate))
        return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
    }
  }
  candidate <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(candidate) == 1L && grepl("^Stephan_etal_1991_Table(13|16)\\.R$", basename(candidate)) && file.exists(candidate))
    return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
  if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
    candidate <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(candidate) && grepl("^Stephan_etal_1991_Table(13|16)\\.R$", basename(candidate)) && file.exists(candidate))
      return(normalizePath(candidate, winslash = "/", mustWork = TRUE))
  }
  stop("Save and source this exact item reader, or use Rscript --vanilla on it.")
}
folder <- dirname(.find_self())
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(.find_self()))
source <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), header = FALSE,
                          colClasses = "character", na.strings = NULL, check.names = FALSE, fill = TRUE)
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                           colClasses = "character", na.strings = NULL, check.names = FALSE)
measures <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_measure_context.csv")),
                            colClasses = "character", na.strings = NULL, check.names = FALSE)
header_row <- which(source[[1L]] == "" & apply(source, 1L, function(x) any(x == "n")))
if (length(header_row) != 1L) stop("Frozen header not uniquely resolved.")
headers <- unlist(source[header_row, ], use.names = FALSE)
volume_positions <- match(measures$Printed_abbreviation, headers)
n_position <- match("n", headers)
if (anyNA(volume_positions) || is.na(n_position)) stop("Measure context does not match frozen headers.")
.keep <- grepl("^[0-9]+([.][0-9]+)?$", source[[volume_positions[1L]]])
.data <- source[.keep, , drop = FALSE]
.family <- character(nrow(source))
.current_family <- ""
for (i in seq_len(nrow(source))) {
  if (source[[1L]][i] %in% unique(context$Family_as_published)) .current_family <- source[[1L]][i]
  .family[i] <- .current_family
}
.family <- .family[.keep]
.source_row <- seq_len(nrow(.data))
.join <- match(paste(item_name, .source_row, .data[[1L]], sep = "|"),
               paste(context$Reference, context$Source_row, context$Species_as_published, sep = "|"))
if (anyNA(.join) || anyDuplicated(.join) || nrow(context) != nrow(.data)) stop("Context key mismatch.")
context <- context[.join, , drop = FALSE]
if (!identical(.family, context$Family_as_published)) stop("Frozen family groups disagree with context.")
.num <- function(x) {
  x[x %in% c("", "-.-")] <- NA_character_
  if (any(!is.na(x) & !grepl("^[0-9]+([.][0-9]+)?$", x))) stop("Unrecognized published numeric token.")
  as.numeric(x)
}
# Blank/missing values remain NA. Printed mm³ already matches the project unit; no scaling or ×2.
final.dataframe <- data.frame(Reference = context$Reference, Source_row = .source_row,
                              Species_Stephan1991 = .data[[1L]], Family_as_published = .family,
                              n = .num(.data[[n_position]]), stringsAsFactors = FALSE, check.names = FALSE)
for (i in seq_len(nrow(measures))) final.dataframe[[measures$Code[i]]] <- .num(.data[[volume_positions[i]]])
.metadata <- setdiff(names(context), c("Reference", "Source_row", "Species_as_published", "Family_as_published"))
for (column in .metadata) final.dataframe[[column]] <- context[[column]]
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
# Only a fresh exact-name registry lookup may supply the public filename; no guessed fallback.
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl before canonical publication validation.")
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
.matches <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
if (length(.matches) != 1L) stop("Item name must match exactly one fresh registry row.")
item_encoded <- filecodes$`Item encoded`[.matches]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
    grepl("_$", item_encoded) || grepl("[/\\\\]", item_encoded)) stop("Invalid registered Item encoded.")
dir.create(file.path(base, "__Public", "comparative-data"), recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                    sep = "\t", row.names = FALSE, quote = FALSE, na = "", fileEncoding = "UTF-8")
