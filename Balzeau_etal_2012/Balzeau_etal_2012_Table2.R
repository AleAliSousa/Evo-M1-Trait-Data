## Balzeau_etal_2012 — Table 2
## Regression results for the relationship between endocranial volume and the
## surface of the frontal, parieto-temporal and occipital lobes (Homo).
##
## Snapshot -> clean. Golden rule: the snapshot is frozen/faithful; ALL cleaning
## happens here. The printed lobe label spans three sub-rows (Complete sample /
## Fossil hominins / AMH); it is forward-filled here.
##
## These are published REGRESSION STATISTICS (allometric scaling of lobe surface
## on endocranial volume), not per-specimen measurements -> role = secondary.
## NOTE: this item is not (yet) in __ReadMe.xlsx; the TSV lookup will warn/skip
## until a registry row + Item encoded is added (see the proposed-registry xlsx).

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
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base      <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## row 1 = caption, row 2 = header, rows 3-11 = data, last row = footnote
raw <- read.csv("Balzeau_etal_2012_Table2_snapshot.csv", header = FALSE, skip = 2,
                colClasses = "character", check.names = FALSE,
                stringsAsFactors = FALSE, na.strings = c("", "NA"))
names(raw)[1:7] <- c("Lobe", "Sample", "n", "Slope", "Intercept", "Rsquared", "p")
raw <- raw[!is.na(raw$Sample), , drop = FALSE]     # drop the footnote row

## forward-fill the spanned lobe label
lobe <- raw$Lobe
for (i in seq_along(lobe)) if (is.na(lobe[i]) && i > 1) lobe[i] <- lobe[i - 1]

lobe_map <- c(
  "Frontal lobes"          = "FrontalLobe",
  "Parieto-temporal lobes" = "Parieto-TemporalLobe",
  "Occipital lobes"        = "OccipitalLobe"
)
as_num <- function(x) suppressWarnings(as.numeric(x))

clean <- data.frame(
  Lobe_Balzeau2012 = lobe,
  Structure        = unname(lobe_map[lobe]),
  Sample           = raw$Sample,
  n                = as.integer(as_num(raw$n)),
  Slope            = as_num(raw$Slope),
  Intercept        = as_num(raw$Intercept),
  Rsquared         = as_num(raw$Rsquared),
  p_code           = raw$p,
  source           = "Balzeau_etal_2012",
  stringsAsFactors = FALSE
)
stopifnot(nrow(clean) == 9L, !any(is.na(clean$Structure)))

csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " rows written to ", basename(csv_file))

tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped ",
          "(add a registry row: proposed code 10.1016%2Fj.jhevol.2012.03.007_Table2).")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
