## Audit the upstream measurements behind Halley & Krubitzer (2019) Figure 1.
## This is intentionally NOT a dataset builder and writes no public TSV: the
## figure is a secondary visualization of already-held primary values.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source.", call. = FALSE)
})

folder <- dirname(.sp)
root <- normalizePath(file.path(folder, ".."))
setwd(folder)

map <- read_csv("Halley_Krubitzer_2019_Figure1_source_map.csv",
                show_col_types = FALSE, na = c("", "NA"))
stephan <- read_csv(file.path(root, "Stephan_etal_1981",
                             "Stephan_etal_1981_TablesI-VI.csv"),
                    show_col_types = FALSE, na = c("", "NA"))
campos <- read_csv(file.path(root, "Campos_Welker_1976",
                            "Campos_Welker_1976_Table1_snapshot.csv"),
                   show_col_types = FALSE, na = c("", "NA"))

stopifnot(nrow(map) == 39L)
stopifnot(sum(map$upstream_source == "Stephan_etal_1981") == 37L)
stopifnot(sum(map$upstream_source == "Campos_Welker_1976") == 2L)

get_values <- function(source, species) {
  if (source == "Stephan_etal_1981") {
    i <- match(species, stephan$Species)
    if (is.na(i)) stop("Stephan species not found: ", species, call. = FALSE)
    return(c(thalamus_mm3 = stephan$Thalamus[i], neocortex_mm3 = stephan$Neocortex[i]))
  }
  source_col <- switch(species,
    "Hydrochoerus hydrochoerus" = "capybara_59_490",
    "Cavia porcellus" = "guinea_pig_60_1",
    stop("Campos species not mapped: ", species, call. = FALSE)
  )
  c(
    thalamus_mm3 = campos[[source_col]][match("thalamus_volume_mm3", campos$code)],
    neocortex_mm3 = campos[[source_col]][match("neocortex_volume_mm3", campos$code)]
  )
}

values <- t(mapply(get_values, map$upstream_source, map$upstream_species))
audit <- bind_cols(map, as.data.frame(values)) %>%
  mutate(
    neocortex_to_thalamus_ratio = neocortex_mm3 / thalamus_mm3,
    caption_ratio_difference = if_else(
      is.na(caption_ratio), NA_real_, abs(neocortex_to_thalamus_ratio - caption_ratio)
    ),
    disposition = "upstream primary value already held; do not digitize Figure 1"
  )

stopifnot(!anyNA(audit[c("thalamus_mm3", "neocortex_mm3")]))
stopifnot(all(audit$thalamus_mm3 > 0), all(audit$neocortex_mm3 > 0))
stopifnot(all(audit$caption_ratio_difference[!is.na(audit$caption_ratio)] < 0.1))

write_csv(audit, "Halley_Krubitzer_2019_Figure1_source_audit.csv", na = "NA")
message("Halley & Krubitzer Figure 1 audit: 39/39 plotted values reconstructed from upstream primary tables.")
message("Sources: Stephan et al. 1981 = 37 species; Campos & Welker 1976 = 2 rodents.")
message("Disposition: DOCUMENTED SKIP; no plot digitization and no public TSV.")
