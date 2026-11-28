read_single_printed_page <- function(path, codes, source_pdf_page, expected_species) {
  raw <- utils::read.csv(path, header=FALSE, check.names=FALSE, stringsAsFactors=FALSE,
                         colClasses="character", na.strings=c("", "---"), blank.lines.skip=FALSE,
                         fileEncoding="UTF-8")
  stopifnot(ncol(raw)==length(codes)+1L, grepl("^Table ", raw[[1]][1]))
  value <- trimws(raw[[2]])
  is_species <- !is.na(value) & grepl("^[0-9]+(?:\\.[0-9]+)?$", value)
  grid <- raw[is_species, , drop=FALSE]
  stopifnot(nrow(grid)==expected_species)
  names(grid) <- c("species_printed", codes)
  grid$species_row <- seq_len(nrow(grid))
  grid$source_pdf_page <- source_pdf_page
  grid
}
