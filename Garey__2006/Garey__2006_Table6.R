.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

## ---- frozen snapshot: Table 6, thickness of layer I (mm) and ratio to total cortical thickness ----
x <- readr::read_csv(paste0(item_name, "_snapshot.csv"), show_col_types = FALSE, col_types = readr::cols(.default = "c"))

## ---- species harmonisation via the General-collection key (scoped to this paper folder) ----
key <- readr::read_csv(file.path(base, "_keys", "General", "species_key.csv"), show_col_types = FALSE)
key_g <- key[key$source_publication == "Garey__2006", ]
if (nrow(key_g) == 0L)
  stop("No species_key.csv rows for source_publication == \"Garey__2006\" -- key rows are scoped to the paper folder name (_keys/SPECIES_NAMING.md sec 3b)", call. = FALSE)
lk <- setNames(key_g$accepted_name, tolower(key_g$variant_name))
sp_of <- function(v) {
  s <- unname(lk[tolower(v)])
  if (anyNA(s)) stop("No species_key row for: ", paste(unique(v[is.na(s)]), collapse = "; "), call. = FALSE)
  s
}
num <- function(v) suppressWarnings(as.numeric(v))
## "a-b" range or single value -> low / high (single value: low == high); "-" or blank -> NA
lo <- function(v) num(sub("^([0-9.]+)-([0-9.]+)$", "\\1", ifelse(v %in% c("-", ""), NA, v)))
hi <- function(v) num(sub("^([0-9.]+)-([0-9.]+)$", "\\2", ifelse(v %in% c("-", ""), NA, v)))

is_val <- !is.na(x[[1]]) & nzchar(x[[1]])
vals   <- x[is_val, ]
ratios <- x[which(is_val) + 1L, ]
if (!all(is.na(ratios[[1]]) | !nzchar(ratios[[1]]))) stop("Table 6 snapshot: ratio rows out of step with value rows", call. = FALSE)
out <- do.call(rbind, lapply(names(x)[-1], function(cn) {
  r <- ratios[[cn]]; r[is.na(r) | r == "-"] <- NA
  data.frame(species_as_published = cn, Brodmann_area = vals[[1]],
             thickness_as_published = vals[[cn]], ratio_as_published = r, stringsAsFactors = FALSE)
}))
out$Species <- sp_of(out$species_as_published)
out$`LayerI_thickness.mm` <- num(out$thickness_as_published)
out$LayerI_to_total_ratio_denominator <- num(sub("^\\(1:([0-9.]+)\\)$", "\\1", out$ratio_as_published))
out$source_location <- "Table 6, printed p. 79 (translation); Brodmann 1909 Chapter III"
out$data_role <- "secondary"
out <- out[, c("Species", "species_as_published", "Brodmann_area", "thickness_as_published", "ratio_as_published",
               "LayerI_thickness.mm", "LayerI_to_total_ratio_denominator", "source_location", "data_role")]

readr::write_csv(out, paste0(item_name, ".csv"), na = "")
message(item_name, ": ", nrow(out), " rows written")

## ---- public TSV ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)][1]
} else NA_character_
if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' (registry row not pasted yet); TSV skipped.")
} else if (dir.exists(path.expand(tsv_dir))) {
  write.table(out, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE, na = "")
  message("Wrote TSV: ", item_encoded)
}
