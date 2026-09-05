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

## ---- read frozen snapshot: the ONE printed table (Table I, Panel A, p. 43) covering brain
## divisions, spinal cord, and body weight/length for 162 male + 159 female adult dogs ----
x <- readr::read_csv("Latimer__1942_TABLEI_snapshot.csv", show_col_types = FALSE)

## ---- species harmonisation via the Stephan-collection key (Latimer1942 token) ----
key <- readr::read_csv(file.path(base, "_keys", "Stephan", "species_key.csv"), show_col_types = FALSE)
key_lat <- key[key$source_publication == "Latimer1942", ]
lk <- setNames(key_lat$accepted_name, tolower(key_lat$variant_name))
x$Species <- lk[["dog"]]
x$species_as_published <- "dog"

## ---- project units: mass -> mg (g x1000, kg x1,000,000); length stays cm (no project-unit
## conversion defined for length in __HOWTO_build_a_dataset_file.md sec.6) ----
x$value_mean_mg <- ifelse(x$measure == "mass" & x$unit_as_published == "g",  x$value_mean * 1000,
                    ifelse(x$measure == "mass" & x$unit_as_published == "kg", x$value_mean * 1e6, NA))
x$value_se_mg   <- ifelse(x$measure == "mass" & x$unit_as_published == "g",  x$value_se * 1000,
                    ifelse(x$measure == "mass" & x$unit_as_published == "kg", x$value_se * 1e6, NA))
x$value_mean_cm <- ifelse(x$measure == "length", x$value_mean, NA)
x$value_se_cm   <- ifelse(x$measure == "length", x$value_se, NA)

x$source_location <- "Table I panel A, p. 43"
x$data_role       <- "primary"

out <- x[, c("Species", "species_as_published", "sex", "n", "structure_as_published", "measure",
             "value_mean_mg", "value_se_mg", "value_mean_cm", "value_se_cm",
             "cv_pct", "cv_se_pct", "source_location", "data_role")]

readr::write_csv(out, "Latimer__1942_TABLEI.csv", na = "")
message(item_name, ": ", nrow(out), " rows written")

## ---- public TSV ----
tsv_dir      <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  fc$`Item encoded`[match(item_name, fc$`Item name`)][1]
} else NA_character_
if (length(item_encoded) == 0 || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "'; TSV skipped.")
} else if (dir.exists(path.expand(tsv_dir))) {
  write.table(out, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  message("Wrote TSV: ", item_encoded)
}
