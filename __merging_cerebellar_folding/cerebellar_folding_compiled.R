#!/usr/bin/env Rscript
# Heuer 2023 cerebellar-folding/surface measurements as a dedicated merge.

suppressWarnings(suppressMessages(library(tidyverse)))
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript cerebellar_folding_compiled.R", call. = FALSE)
})
merge_dir <- dirname(.sp)
root <- normalizePath(file.path(merge_dir, ".."))
d <- read.csv(file.path(root, "Heuer_etal_2023", "Heuer_etal_2023_Data.csv"),
              stringsAsFactors = FALSE, check.names = FALSE)

meta <- tribble(
  ~Measure, ~Units,
  "Cerebellar_section_area", "mm2",
  "Cerebellar_section_length", "mm",
  "Cerebral_section_area", "mm2",
  "Cerebral_section_length", "mm",
  "Folial_width_median", "mm",
  "Folial_perimeter_median", "mm",
  "Molecular_layer_thickness_median", "mm"
)
source_cols <- paste0(meta$Measure, ifelse(meta$Units == "mm2", "_mm2", "_mm"))

long <- bind_rows(lapply(seq_len(nrow(meta)), function(i) {
  v <- suppressWarnings(as.numeric(d[[source_cols[i]]]))
  keep <- !is.na(v)
  tibble(
    Species = d$species_sci[keep],
    measure_class = "cerebellar_folding",
    Measure = meta$Measure[i],
    Units = meta$Units[i],
    Value = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    Value_median = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    n_sources = 1L,
    n_teams = 1L,
    n_teams_primary = 1L,
    primary_used = TRUE,
    Teams = "Heuer2023",
    roles = "primary",
    value_min = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12),
    value_max = format(v[keep], scientific = FALSE, trim = TRUE, digits = 12)
  )
})) |> arrange(Species, Measure)

write_csv(long, file.path(merge_dir, "cerebellar_folding_long.csv"))
wide <- long |> select(Species, Measure, Value) |>
  pivot_wider(names_from = Measure, values_from = Value) |> arrange(Species)
write_csv(wide, file.path(merge_dir, "cerebellar_folding_wide.csv"))
message("cerebellar folding: ", nrow(long), " observations across ",
        n_distinct(long$Species), " species")
