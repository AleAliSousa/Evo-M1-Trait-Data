# Grande__1950_TablaIX.R -----------------------------------------------------------
#
# Grande (1950), Rev Clin Esp 39(1): 1-17. Tabla IX p. 12: "Metabolismo de distintos organos
# humanos (expresado en consumo de oxigeno). Metabolismo basal estimado en 2?0 c. c. de
# oxigeno por minuto" - brain, kidneys, liver, resting skeletal muscle, heart; footnotes
# name a source for each organ. SECONDARY compilation: values come from Kety & Schmidt
# (1948), Bradley & Helperin (1948), Myers (1947), Asmussen, Christensen & Nielsen (1939)
# and dog heart data (Goodale et al.). The BMR figure in the heading is smudged and is
# recorded as printed.
#
# Reads the frozen snapshot (Grande__1950_TablaIX_snapshot.csv) and:
#   - writes one analysis row per organ (5 rows, printed order);
#   - parses Spanish number format ("." thousands, "," decimal), keeps printed strings;
#   - converts mL O2 -> umol O2 (x 44.64 = 1000/22.4);
#   - table checks: % of body weight, total O2 = weight x rate, % of BMR, and the Fick relation
#     flow x A-V difference = O2 rate, all recomputed from the printed cells.
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

snap <- read_snapshot(paste0(base, "_snapshot.csv"))
stopifnot(identical(dim(snap), c(12L, 8L)), snap[1, 1] == "TABLA IX", grepl("EN 2\\?0 C\\. C\\.", snap[2, 1]),
          snap[3, 1] == "Organo")
rows <- 5:9
stopifnot(identical(snap[rows, 1], c("Cerebro", "Riñones", "Higado", "Musculatura (reposo)", "Corazón")))
bmr_heading <- sub("^.*ESTIMADO EN (.*) C\\. C\\. DE OXIGENO.*$", "\\1", snap[2, 1])
final.dataframe <- data.frame(
  printed_row = rows, row_order = seq_along(rows),
  species_as_published = "humanos",
  organ_as_published = snap[rows, 1],
  organ_mass_g_printed = snap[rows, 2], pct_body_weight_printed = snap[rows, 3],
  blood_flow_printed = snap[rows, 4], AV_diff_O2_printed = snap[rows, 5],
  O2_rate_per_100g_printed = snap[rows, 6], O2_total_per_min_printed = snap[rows, 7],
  pct_of_BMR_printed = snap[rows, 8], stringsAsFactors = FALSE)
final.dataframe$Organ_mass.g              <- num_es(snap[rows, 2])
final.dataframe$pct_of_body_weight        <- num_es(snap[rows, 3])
final.dataframe$Blood_flow.mL_100g_min    <- num_es(snap[rows, 4])
final.dataframe$AV_diff_O2.vol_pct        <- num_es(snap[rows, 5])      # "-" (heart) -> NA
final.dataframe$O2_rate.mL_100g_min       <- num_es(snap[rows, 6])
final.dataframe$O2_rate.umol_100g_min     <- round(num_es(snap[rows, 6]) * ML_TO_UMOL, 3)
final.dataframe$O2_total.mL_min           <- num_es(snap[rows, 7])
final.dataframe$O2_total.umol_min         <- round(num_es(snap[rows, 7]) * ML_TO_UMOL, 2)
final.dataframe$pct_of_BMR                <- num_es(snap[rows, 8])
final.dataframe$BMR_in_heading_as_printed <- bmr_heading           # "2?0" (smudged digit), NOT substituted
final.dataframe$ref_keys_source <- c("KETY y SCHMIDT (1948)", "BRADLEY y HELPERIN (1948)", "MYERS (1947)",
                                     "ASMUSSEN, CHRISTENSEN y NIELSEN (1939)", "GOODALE y colaboradores (1948)")
final.dataframe$note <- c(NA, NA, "Printed footnote: figures correspond to the bromosulftaleina method.",
                          NA, "Printed footnote: calculated by the author from dog heart data determined in situ; not a human measurement.")
stopifnot(nrow(final.dataframe) == 5L, identical(bmr_heading, "2?0"), is.na(final.dataframe$AV_diff_O2.vol_pct[5]),
          !anyNA(final.dataframe[, c("Organ_mass.g", "O2_rate.mL_100g_min", "O2_total.mL_min", "pct_of_BMR")]))

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
BODY_G <- 70000   # Tabla VI prints Hombre = 70 kg; Tabla IX prints no body weight (brain 1400 g = 2.00 %)
BMR_ML <- 250     # Tabla VI / running text; the heading digit is smudged ("2?0")
w <- final.dataframe$Organ_mass.g
org <- final.dataframe$organ_as_published
table_checks <- rbind(
  do.call(rbind, lapply(1:5, function(i)
    chk(paste0("pct_weight_", org[i]), paste0("100 x weight / 70000 g vs printed % del peso total, ", org[i]),
        100 * w[i] / BODY_G, final.dataframe$pct_of_body_weight[i],
        0.5 * u(dec_es(snap[rows[i], 3])) + 100 * 0.5 * u(0) / BODY_G,
        "body weight 70 kg assumed from Tabla VI; tolerance = half unit of printed % + half gram of organ weight"))),
  do.call(rbind, lapply(1:5, function(i)
    chk(paste0("total_O2_", org[i]), paste0("weight x rate / 100 vs printed total O2 c.c./min, ", org[i]),
        w[i] * final.dataframe$O2_rate.mL_100g_min[i] / 100, final.dataframe$O2_total.mL_min[i],
        0.5 + w[i] * 0.5 * u(dec_es(snap[rows[i], 6])) / 100,
        "tolerance = half unit of printed total + weight x half unit of printed rate"))),
  do.call(rbind, lapply(1:5, function(i)
    chk(paste0("pct_BMR_", org[i]), paste0("100 x printed total O2 / 250 vs printed % del metabolismo basal, ", org[i]),
        100 * final.dataframe$O2_total.mL_min[i] / BMR_ML, final.dataframe$pct_of_BMR[i],
        0.5 + 100 * 0.5 / BMR_ML,
        "BMR 250 c.c./min assumed (heading smudged); tolerance = half unit of printed % + half unit of printed total as % of BMR"))),
  do.call(rbind, lapply(1:5, function(i)
    chk(paste0("fick_", org[i]), paste0("flow x A-V difference / 100 vs printed O2 per 100 g, ", org[i]),
        final.dataframe$Blood_flow.mL_100g_min[i] * final.dataframe$AV_diff_O2.vol_pct[i] / 100,
        final.dataframe$O2_rate.mL_100g_min[i],
        0.5 * u(dec_es(snap[rows[i], 6])) + (0.5 * u(dec_es(snap[rows[i], 4])) * final.dataframe$AV_diff_O2.vol_pct[i] +
          0.5 * u(dec_es(snap[rows[i], 5])) * final.dataframe$Blood_flow.mL_100g_min[i]) / 100,
        if (is.na(final.dataframe$AV_diff_O2.vol_pct[i])) "no A-V difference printed (dash): not evaluable" else NA_character_)))
)
report_checks(table_checks)
bad_ids <- table_checks$check_id[table_checks$status == "mismatch"]
for (k in 1:5) {
  hit <- bad_ids[grepl(paste0("_", org[k], "$"), bad_ids, fixed = FALSE)]
  hit <- bad_ids[endsWith(bad_ids, paste0("_", org[k]))]
  if (length(hit)) final.dataframe$note[k] <- paste(stats::na.omit(c(final.dataframe$note[k],
    paste0("table_check mismatch: ", paste(sub(paste0("_", org[k], "$"), "", hit), collapse = ", "), " (see README)"))), collapse = " | ")
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
