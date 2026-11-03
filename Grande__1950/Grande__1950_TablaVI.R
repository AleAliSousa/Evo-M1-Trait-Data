# Grande__1950_TablaVI.R -----------------------------------------------------------
#
# Grande (1950), Rev Clin Esp 39(1): 1-17. Tabla VI p. 6: "Metabolismo cerebral en tanto
# por ciento del metabolismo total en reposo del organismo adulto, en varias especies de
# mamiferos" (15 rows, printed order). SECONDARY compilation of older literature, and the
# brain O2 column is NOT a measurement: the caption says the cerebral O2 figures were
# calculated with 3.7 c.c./100 g/min (Schmidt, Kety & Pennes) for every species.
#
# Reads the frozen snapshot (Grande__1950_TablaVI_snapshot.csv) and:
#   - parses Spanish number format ("." thousands, "," decimal);
#   - converts to project units: kg -> g (x 1000), g brain -> mg (x 1000),
#     mL O2 -> umol O2 (x 44.64 = 1000/22.4);
#   - keeps every printed cell as text beside its parsed value;
#   - table checks (HOWTO 7a): brain O2 = brain weight x 3.7/100 and printed % = 100 x brain O2 /
#     total O2, recomputed from the printed cells within the propagated rounding of those cells.
# No table value is typed in this script.
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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base  <- item_name
paper <- basename(folder)
locus <- sub(paste0("^", paper, "_"), "", item_name)

read_snapshot <- function(file, header = FALSE) {
  x <- utils::read.csv(file, header = header, colClasses = "character", na.strings = character(0),
                check.names = FALSE, encoding = "UTF-8")
  if (header) return(x)
  x <- as.matrix(x); dimnames(x) <- NULL; x
}

## Spanish print: "." = thousands separator (6.650 = 6650), "," = decimal mark (3,80 = 3.80).
num_es <- function(x) {
  x <- trimws(x); th <- grepl("^[0-9]{1,3}(\\.[0-9]{3})+$", x)
  x[th] <- gsub(".", "", x[th], fixed = TRUE)
  suppressWarnings(as.numeric(sub(",", ".", x, fixed = TRUE)))
}
dec_es <- function(x) ifelse(grepl(",", x, fixed = TRUE), nchar(sub("^.*,", "", x)), 0L)   # printed decimals

ML_TO_UMOL <- 44.64            # umol O2 per mL O2 (project factor; = 1000/22.4 rounded to 2 dp)

RATE_ML <- 3.7        # c.c. O2 /100 g brain /min, printed in the table caption

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(19L, 6L)), snap[1, 1] == "TABLA VI", snap[4, 1] == "Especie\nanimal")
rows <- 5:19
final.dataframe <- data.frame(
  printed_row = rows, row_order = seq_along(rows),
  species_as_published = snap[rows, 1],
  body_mass_kg_printed = snap[rows, 2], brain_mass_g_printed = snap[rows, 3],
  body_O2_ml_min_printed = snap[rows, 4], brain_O2_ml_min_printed = snap[rows, 5],
  brain_pct_BMR_printed = snap[rows, 6], stringsAsFactors = FALSE)
final.dataframe$Body_mass.g             <- round(num_es(snap[rows, 2]) * 1000, 3)
final.dataframe$Brain_mass.mg           <- round(num_es(snap[rows, 3]) * 1000, 3)
final.dataframe$Body_O2.mL_min          <- num_es(snap[rows, 4])
final.dataframe$Body_O2.umol_min        <- round(num_es(snap[rows, 4]) * ML_TO_UMOL, 2)
final.dataframe$Brain_O2.mL_min         <- num_es(snap[rows, 5])
final.dataframe$Brain_O2.umol_min       <- round(num_es(snap[rows, 5]) * ML_TO_UMOL, 2)
final.dataframe$Brain_pct_of_body_O2    <- num_es(snap[rows, 6])
final.dataframe$Brain_O2_rate_assumed.umol_100g_min <- round(RATE_ML * ML_TO_UMOL, 3)
final.dataframe$brain_O2_basis <- "calculated by the author: brain weight x 3.7 c.c./100 g/min, assumed equal in all species (not measured per species)"
final.dataframe$ref_keys_brain_O2_rate <- "SCHMIDT, KETY y PENNES"
final.dataframe$ref_keys_row_text <- NA_character_
final.dataframe$ref_keys_row_text[final.dataframe$species_as_published == "Monos (ateles)"] <- "SCHMIDT, KETY y PENNES"
final.dataframe$ref_keys_row_text[final.dataframe$species_as_published == "Perro"] <- "HIMWICH y NAHUM"
final.dataframe$note <- NA_character_
final.dataframe$note[!is.na(final.dataframe$ref_keys_row_text)] <-
  "ref_keys_row_text comes from the running text (p. 6), not from the table: monkeys (mean 3.8 kg, 11 animals) of Schmidt, Kety & Pennes; dogs (mean 16.4 kg, 13 animals) of Himwich & Nahum."
stopifnot(nrow(final.dataframe) == 15L, !anyNA(final.dataframe[, c("Body_mass.g", "Brain_mass.mg", "Body_O2.mL_min", "Brain_O2.mL_min", "Brain_pct_of_body_O2")]))

## ---- table checks (HOWTO section 7a) ------------------------------------------

chk <- function(id, basis, observed, printed, tol, note = NA_character_) {
  ok <- !is.na(observed) & !is.na(printed)
  data.frame(check_id = id, basis = basis, observed = observed, printed = printed,
             difference = observed - printed, tolerance = tol,
             status = ifelse(!ok, "not_evaluable", ifelse(abs(observed - printed) <= tol + 1e-9, "pass", "mismatch")),
             note = note, stringsAsFactors = FALSE)
}
report_checks <- function(table_checks) {
  tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
  message(item_name, ": table checks  pass=", tally[["pass"]], "  mismatch=", tally[["mismatch"]],
          "  not_evaluable=", tally[["not_evaluable"]])
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

u <- function(d) 10^(-d)
brain_g <- num_es(snap[rows, 3]); brain_o2 <- num_es(snap[rows, 5]); tot_o2 <- num_es(snap[rows, 4]); pct <- num_es(snap[rows, 6])
lab <- paste0(final.dataframe$row_order, "_", gsub("[^A-Za-z]", "", snap[rows, 1]))
table_checks <- rbind(
  do.call(rbind, lapply(seq_along(rows), function(i)
    chk(paste0("brainO2_", lab[i]), paste0("brain weight x 3.7/100 vs printed brain O2 c.c./min, row '", snap[rows[i], 1], "'"),
        brain_g[i] * RATE_ML / 100, brain_o2[i],
        0.5 * u(dec_es(snap[rows[i], 5])) + RATE_ML / 100 * 0.5 * u(dec_es(snap[rows[i], 3])),
        "tolerance = half unit of printed brain O2 + rate x half unit of printed brain weight"))),
  do.call(rbind, lapply(seq_along(rows), function(i)
    chk(paste0("pct_", lab[i]), paste0("100 x printed brain O2 / printed total O2 vs printed % of total, row '", snap[rows[i], 1], "'"),
        100 * brain_o2[i] / tot_o2[i], pct[i],
        0.5 * u(dec_es(snap[rows[i], 6])) + 100 * 0.5 * u(dec_es(snap[rows[i], 5])) / tot_o2[i] +
          100 * brain_o2[i] * 0.5 * u(dec_es(snap[rows[i], 4])) / tot_o2[i]^2,
        "tolerance = half unit of the printed % + propagated half units of the printed brain O2 and total O2 (the author computed the % from unrounded values)")))
)
report_checks(table_checks)
bad_ids <- table_checks$check_id[table_checks$status == "mismatch"]
for (k in seq_along(rows)) {
  hit <- bad_ids[endsWith(bad_ids, paste0("_", lab[k]))]
  if (length(hit)) final.dataframe$note[k] <- paste(stats::na.omit(c(final.dataframe$note[k],
    paste0("table_check mismatch: ", paste(sub(paste0("_", lab[k], "$"), "", hit), collapse = ", "), " (see README)"))), collapse = " | ")
}

## ---- outputs ----------------------------------------------------------------
utils::write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe),
        " cols written to ", base, ".csv")

## ---- public TSV ---------------------------------------------------------------
## Item encoded is looked up in __ReadMe.xlsx by Item name. While the item is not
## yet registered, the code is derived the way the registry formula builds it from
## column C (no DOI exists for this publication: Rev Clin Esp 39 (1950) 1-17): alt code with ":" and
## "/" percent-encoded, "_", item locus. The registry stays the authority.
alt_code <- "RevClinEsp:39:1-17"
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
item_encoded <- NA_character_
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
}
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(utils::URLencode(alt_code, reserved = TRUE), "_", locus)
  message(item_name, ": not (yet) in __ReadMe.xlsx; public TSV named by the derived code ",
          item_encoded, " (awaiting registration)")
}
stopifnot(!grepl("_$", item_encoded))
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (dir.exists(tsv_dir)) {
  utils::write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "", fileEncoding = "UTF-8")
  message(item_name, ": public TSV ", item_encoded, ".tsv")
} else warning(item_name, ": __Public/comparative-data not found; public TSV not written.")
