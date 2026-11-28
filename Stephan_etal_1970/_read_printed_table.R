## Read the printed orientation retained by Table 1–6 source snapshots.
read_printed_table <- function(path) {
  grid <- read.csv(path, header = FALSE, fill = TRUE, check.names = FALSE,
                   colClasses = "character", na.strings = character(0),
                   encoding = "UTF-8")
  table_number <- NA_integer_
  data_rows <- list()
  for (i in seq_len(nrow(grid))) {
    label <- grid[[1]][i]
    if (grepl("^TABLE [1-6]\\.", label))
      table_number <- as.integer(sub("^TABLE ([1-6])\\..*$", "\\1", label))
    if (!grepl("^[0-9]+\\. ", label)) next
    if (is.na(table_number)) stop("Data row before table caption in ", path)
    names <- if (table_number <= 3L)
      c("body_weight_g", "brain_weight_mg", "total_brain_net_mm3",
        "medulla_oblongata_mm3", "cerebellum_mm3", "mesencephalon_mm3",
        "diencephalon_mm3", "telencephalon_mm3")
    else
      c("bulbus_olfactorius_mm3", "palaeocortex_plus_amygdala_mm3",
        "septum_mm3", "striatum_mm3", "schizocortex_mm3",
        "hippocampus_mm3", "neocortex_mm3")
    values <- vapply(grid[i, 1L + seq_along(names)],
                     function(x) as.numeric(gsub(",", "", x)), numeric(1))
    data_rows[[length(data_rows) + 1L]] <- data.frame(
      id = as.integer(sub("\\..*$", "", label)),
      group = c("Insectivore", "Prosimian", "Simian")[(table_number - 1L) %% 3L + 1L],
      species = sub("^[0-9]+\\. ", "", label),
      stats::setNames(as.list(values), names), check.names = FALSE)
  }
  if (!length(data_rows)) stop("No printed data rows in ", path)
  do.call(rbind, data_rows)
}
