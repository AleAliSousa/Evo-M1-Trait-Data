## Lewitus et al. (2013), Appendix Table A1
## Conical expansion of the outer subventricular zone and the role of
## neocortical folding in evolution and development. Front Hum Neurosci 7:424.
## DOI: 10.3389/fnhum.2013.00424
##
## Input : Lewitus_etal_2013_TableA1_snapshot.csv
## Output: Lewitus_etal_2013_TableA1.csv
##         <Item encoded>.tsv in __Public/comparative-data/

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snap <- read.csv("Lewitus_etal_2013_TableA1_snapshot.csv", check.names=FALSE, stringsAsFactors=FALSE, na.strings=c("", "NA"))
stopifnot(nrow(snap) == 66L, !anyDuplicated(snap$species), all(nzchar(snap$species)))
num_cols <- setdiff(names(snap), "species")
for (nm in num_cols) snap[[nm]] <- suppressWarnings(as.numeric(snap[[nm]]))
clean <- snap
clean$source <- "Lewitus_etal_2013"
write.csv(clean, paste0(item_name, ".csv"), row.names=FALSE, na="NA")
message(item_name, ": ", nrow(clean), " rows written")
if (is.na(base)) {
  warning("Repository root containing __ReadMe.xlsx not found; TSV skipped.")
} else {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  out_dir <- file.path(base, "__Public", "comparative-data")
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "'; TSV skipped.")
  } else if (!dir.exists(out_dir)) {
    warning("Shared folder not found: ", out_dir, "; TSV skipped.")
  } else {
    write.table(clean, file.path(out_dir, paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, quote=TRUE, na="NA")
  }
}
