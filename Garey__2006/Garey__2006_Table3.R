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

## ---- frozen snapshot: Table 3, thickness of homologous cortical areas (mm), 6 areas x 10 species ----
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

area  <- x[[1]]
long  <- do.call(rbind, lapply(names(x)[-1], function(cn)
  data.frame(species_as_published = sub("^(.*?)[0-9]\\)$", "\\1", cn),
             Brodmann_area = area, thickness_as_published = x[[cn]], stringsAsFactors = FALSE)))
long$species_as_published[long$species_as_published == "Man2)"] <- "Man"
long$species_as_published <- sub("2\\)$", "", long$species_as_published)
long$Species <- sp_of(long$species_as_published)
out <- data.frame(
  Species = long$Species, species_as_published = long$species_as_published,
  Brodmann_area = long$Brodmann_area,
  thickness_as_published = long$thickness_as_published,
  `CorticalThickness_low.mm`  = lo(long$thickness_as_published),
  `CorticalThickness_high.mm` = hi(long$thickness_as_published),
  source_location = "Table 3, printed p. 62 (translation); Brodmann 1909 Chapter III",
  data_role = "secondary", check.names = FALSE, stringsAsFactors = FALSE)

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
