read_small_printed_table <- function(path, columns, pdf_page) {
  grid <- read.csv(path, header = FALSE, fill = TRUE,
                   colClasses = "character", check.names = FALSE,
                   na.strings = character(0), encoding = "UTF-8")
  stopifnot(nrow(grid) == 8L, ncol(grid) == length(columns) + 1L)
  stopifnot(identical(unname(as.character(grid[2L, -1L])), columns))
  snapshot <- grid[3L:8L, , drop = FALSE]
  names(snapshot) <- c("species_printed", columns)
  snapshot$species_row <- seq_len(nrow(snapshot))
  snapshot$source_pdf_page <- pdf_page
  snapshot
}
