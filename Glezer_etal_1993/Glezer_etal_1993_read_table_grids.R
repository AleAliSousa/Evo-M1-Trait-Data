# Reassemble the two printed page grids for Tables 1 and 2 as analysis rows.
read_table_grids <- function(folder, item_name) {
  first <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                           header = FALSE, check.names = FALSE,
                           colClasses = "character", fileEncoding = "UTF-8")
  continued <- utils::read.csv(file.path(folder, paste0(item_name, "_continued_snapshot.csv")),
                               header = FALSE, check.names = FALSE,
                               colClasses = "character", fileEncoding = "UTF-8")
  stopifnot(nrow(first) == 13L, ncol(first) == 7L,
            nrow(continued) == 13L, ncol(continued) == 4L)
  layers <- first[[1L]][3:13]
  blocks <- list(list(grid = first, columns = c(2L, 4L, 6L), page = 8L),
                 list(grid = continued, columns = c(1L, 3L), page = 9L))
  rows <- list()
  order <- 0L
  for (block in blocks) for (col in block$columns) {
    order <- order + 1L
    group <- block$grid[[col]][1L]
    rows[[order]] <- data.frame(
      source_group_order = as.character(order),
      taxon_group_as_published = group,
      source_layer_order = as.character(seq_along(layers)),
      cortical_layer_as_published = layers,
      numerical_density_M_plus_SEM_as_published = block$grid[[col]][3:13],
      percent_of_total_neurons_as_published = block$grid[[col + 1L]][3:13],
      source_pdf_page = as.character(block$page),
      stringsAsFactors = FALSE)
  }
  do.call(rbind, rows)
}
