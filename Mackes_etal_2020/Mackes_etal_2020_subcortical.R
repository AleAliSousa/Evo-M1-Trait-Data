## Mackes et al. 2020 - ERA subcortical group summaries
## Author-provided descriptive-statistics CSV snapshot -> analysis-ready public table.
## Uses raw bilateral mean_<structure> rows, not TBV/sex-adjusted *_reg rows.

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and Source.", call. = FALSE)
})
folder <- dirname(.sp)
setwd(folder)
options(scipen = 999, stringsAsFactors = FALSE)

snapshot <- "Mackes_etal_2020_subcortical_snapshot.csv"
lines <- readLines(snapshot, warn = FALSE, encoding = "UTF-8")
structure_map <- c(
  thalamus = "Thalamus",
  caudate = "Caudate",
  putamen = "Putamen",
  pallidum = "Pallidum",
  hippocampus = "Hippocampus",
  amygdala = "Amygdala",
  accumbens = "Nucleus Accumbens"
)
region_order <- unname(structure_map)
group <- NA_character_
rows <- list()
for (line in lines) {
  if (grepl("^UK adoptees", line)) group <- "UK"
  if (grepl("^Romanian adoptees", line)) group <- "Romanian"
  fields <- strsplit(line, ",", fixed = TRUE)[[1]]
  key <- trimws(fields[1])
  if (grepl("^mean_[a-z]+$", key) && !is.na(group)) {
    short <- sub("^mean_", "", key)
    if (short %in% names(structure_map)) {
      rows[[paste(group, short)]] <- data.frame(
        Region = structure_map[[short]],
        Group = group,
        n = as.integer(fields[2]),
        taxon = "Homo sapiens",
        Volume_per_hemisphere.cm3 = round(as.numeric(fields[3]), 4),
        SD.cm3 = round(as.numeric(fields[4]), 4),
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
    }
  }
}
final <- do.call(rbind, rows)
final$Group <- factor(final$Group, levels = c("UK", "Romanian"))
final$Region <- factor(final$Region, levels = region_order)
final <- final[order(final$Group, final$Region), ]
final$Group <- as.character(final$Group)
final$Region <- as.character(final$Region)
rownames(final) <- NULL
stopifnot(nrow(final) == 14L,
          identical(sort(unique(final$n)), c(21L, 67L)))
write.csv(final, "Mackes_etal_2020_subcortical.csv", row.names = FALSE, na = "NA")

root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (!is.na(root)) {
  tsv <- file.path(root, "__Public", "comparative-data",
                   "10.1073%2Fpnas.1911264116_subcortical.tsv")
  write.table(final, tsv, sep = "\t", row.names = FALSE, quote = FALSE, na = "NA", eol = "\n")
}
cat("Wrote", nrow(final), "subcortical summary rows.\n")
