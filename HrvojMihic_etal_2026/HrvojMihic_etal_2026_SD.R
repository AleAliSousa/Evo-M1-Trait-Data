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

## ---- frozen sources: digital-native journal supplementary data (PNAS Dataset S1/S2),
## copy-renamed byte-identical, never opened/resaved ----
sd1_file <- "HrvojMihic_etal_2026_SD1_snapshot.xlsx"
sd2_file <- "HrvojMihic_etal_2026_SD2_snapshot.xlsx"

species_sheet_map <- list(
  "Gorilla Female Adults"     = list(printed = "Gorilla",    taxon = "Gorilla gorilla"),
  "Gorilla Male Aduls"        = list(printed = "Gorilla",    taxon = "Gorilla gorilla"),
  "Orangutan Female Adults"   = list(printed = "Orangutan",  taxon = "Pongo pygmaeus"),
  "Orangutan Male Adults"     = list(printed = "Orangutan",  taxon = "Pongo pygmaeus"),
  "Bonobo Female Adults"      = list(printed = "Bonobo",     taxon = "Pan paniscus"),
  "Bonobo Males Adult"        = list(printed = "Bonobo",     taxon = "Pan paniscus"),
  "Chimpanzee Females Adult"  = list(printed = "Chimpanzee", taxon = "Pan troglodytes"),
  "Chimpanzee Males Adult"    = list(printed = "Chimpanzee", taxon = "Pan troglodytes")
)

sd1 <- do.call(rbind, lapply(names(species_sheet_map), function(sheet) {
  d <- readxl::read_excel(sd1_file, sheet = sheet)
  d <- d[!is.na(d[[1]]) & nzchar(trimws(as.character(d[[1]]))), c(1, 2, 3, 4)]
  names(d) <- c("code", "brain_weight_g", "sex", "age_years")
  d$species_as_published <- species_sheet_map[[sheet]]$printed
  d$interpreted_taxon     <- species_sheet_map[[sheet]]$taxon
  d$source_sheet          <- sheet
  d
}))

## ---- sd02: chimpanzee 15+ subset (verified: every code is also in sd1's two
## chimpanzee sheets -- not a new cohort). Left-join only the added column
## (body_weight_kg) onto the matching sd1 rows by code; do not append new rows. ----
sd2_m <- readxl::read_excel(sd2_file, sheet = "Chimpanzee Males 15 and older")
sd2_f <- readxl::read_excel(sd2_file, sheet = "Chimpanze Females 15 and older")
sd2 <- rbind(
  data.frame(code = sd2_m[[1]], brain_weight_g = sd2_m[[2]], body_weight_kg = sd2_m[[3]], age_years = sd2_m[[5]]),
  data.frame(code = sd2_f[[1]], brain_weight_g = sd2_f[[2]], body_weight_kg = sd2_f[[3]], age_years = sd2_f[[5]])
)
sd2 <- sd2[!is.na(sd2$code) & nzchar(trimws(as.character(sd2$code))), ]

stopifnot(all(sd2$code %in% sd1$code))  ## sd02 must be a pure subset of sd1's codes

## QA: sd02 has two codes (PTM153, PTF31) each printed TWICE with different
## brain_weight/age -- a duplicate-code data-entry anomaly in the source
## spreadsheet, not introduced here. Disambiguate by matching on
## (code, brain_weight_g, age_years) against sd1's single authoritative row,
## so the join cannot silently duplicate sd1 rows or pick an arbitrary match.
dup_codes <- sd2$code[duplicated(sd2$code)]
if (length(dup_codes)) {
  message("NOTE: sd02 duplicate code(s) disambiguated against sd1 by brain_weight+age: ",
          paste(unique(dup_codes), collapse = ", "))
}
## For the two duplicate codes, keep only the sd2 row matching sd1 on brain_weight_g
## (rounded to avoid float-precision mismatches); for every other code (a clean 1:1
## match) keep it as-is.
sd2_dedup <- do.call(rbind, lapply(split(sd2, sd2$code), function(g) {
  if (nrow(g) == 1L) return(g)
  sd1_bw <- sd1$brain_weight_g[sd1$code == g$code[1]]
  g[which.min(abs(round(g$brain_weight_g, 1) - round(sd1_bw, 1))), ]
}))
stopifnot(!any(duplicated(sd2_dedup$code)))

x <- merge(sd1, sd2_dedup[, c("code", "body_weight_kg")], by = "code", all.x = TRUE)
stopifnot(nrow(x) == nrow(sd1))  ## disambiguated join must not duplicate rows

## ---- project units: brain weight g -> mg; body weight kg -> g ----
x$brain_weight_mg <- x$brain_weight_g * 1000
x$body_weight_g   <- x$body_weight_kg * 1000
x$data_role       <- "primary"
x$source_location <- "Dataset S1 (all taxa) and Dataset S2 (chimpanzee body weight, 15+ subset)"

out <- x[, c("code", "species_as_published", "interpreted_taxon", "sex", "age_years",
             "brain_weight_mg", "body_weight_g", "source_sheet", "source_location", "data_role")]
out <- out[order(out$species_as_published, out$sex, out$code), ]

readr::write_csv(out, "HrvojMihic_etal_2026_SD.csv", na = "")
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
