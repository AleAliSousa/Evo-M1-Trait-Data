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

## ---- Table 4: body and brain weight (g) and cortical thickness (mm), areas 4 and 7, 13 species ----
x <- readr::read_csv(paste0(item_name, "_snapshot.csv"), show_col_types = FALSE, col_types = readr::cols(.default = "c"))
x$Order <- sub(" \\(\\*[0-9]+\\)$", "", x$Order)  # drop the translator's endnote mark (*74); see README
x$Order <- stats::ave(x$Order, cumsum(!is.na(x$Order)), FUN = function(v) v[1])  # order is printed once per group; fill down
bb  <- strsplit(x[["Body:Brain weight in grams"]], ":", fixed = TRUE)
t4  <- x[["Cortical thickness in mm: Area 4"]]
t7  <- x[["Cortical thickness in mm: Area 7"]]
## "2.8 (3.1)": printed value with a bracketed alternative (Table 3 prints the same cell as 2.8-3.1)
has_alt <- grepl("(", t4, fixed = TRUE)
out <- data.frame(
  Species = sp_of(x$Species), species_as_published = x$Species, Order_printed = x$Order,
  `BodyWeight.g`  = num(vapply(bb, `[`, "", 1)),
  `BrainWeight.g` = num(vapply(bb, `[`, "", 2)),
  `CorticalThickness_area4.mm` = num(sub(" \\(.*$", "", t4)),
  `CorticalThickness_area4_alt.mm` = ifelse(has_alt, num(sub("^.*\\(([0-9.]+)\\)$", "\\1", t4)), NA_real_),
  `CorticalThickness_area7.mm` = num(ifelse(t7 == "-", NA, t7)),
  thickness_area4_as_published = t4, thickness_area7_as_published = t7,
  source_location = "Table 4, printed p. 62 (translation); Brodmann 1909 Chapter III",
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
