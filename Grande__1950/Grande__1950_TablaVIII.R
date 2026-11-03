# Grande__1950_TablaVIII.R ---------------------------------------------------------
#
# Grande (1950), Rev Clin Esp 39(1): 1-17. Tabla VIII p. 12: "Consumo de oxigeno y riego
# sanguineo del cerebro humano, segun Kety y Schmidt (1948). Valores medios de 34
# observaciones en 14 sujetos jovenes sanos." SECONDARY: five values of Kety & Schmidt
# (1948) as reported by Grande.
#
# Reads the frozen snapshot (Grande__1950_TablaVIII_snapshot.csv) and:
#   - writes one analysis row per printed quantity (5 rows, printed order);
#   - parses Spanish number format; converts mL O2 -> umol O2 (x 44.64 = 1000/22.4) for the
#     O2 quantities; blood-flow quantities stay in mL (no unit conversion needed);
#   - table checks: total brain O2 = rate x brain weight and total flow = flow/100 g x brain
#     weight, with the 1400 g brain weight that the running text (p. 12) gives for this
#     table's subject, and the Fick relation flow x A-V difference / 100 = O2 rate.
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
stopifnot(identical(dim(snap), c(8L, 3L)), snap[1, 1] == "TABLA VIII")
rows <- 4:8
codes <- c("CMRO2", "AVdiff_O2", "CBF", "CMRO2_total", "CBF_total")
stopifnot(grepl("^Consumo de oxigeno por 100 g", snap[rows[1], 1]), grepl("^Flujo de sangre total", snap[rows[5], 1]))
val <- num_es(snap[rows, 2])
is_o2 <- codes %in% c("CMRO2", "CMRO2_total", "AVdiff_O2")
final.dataframe <- data.frame(
  printed_row = rows, row_order = seq_along(rows),
  species_as_published = "cerebro humano",
  quantity_as_published = gsub("\n", " ", snap[rows, 1], fixed = TRUE),
  value_printed = snap[rows, 2], unit_as_printed = ifelse(nzchar(snap[rows, 3]), snap[rows, 3], "volumenes por 100"),
  variable_code = codes, value_numeric = val, stringsAsFactors = FALSE)
final.dataframe$value_converted <- c(round(val[1] * ML_TO_UMOL, 3), round(val[2] * ML_TO_UMOL / 100, 4), val[3], round(val[4] * ML_TO_UMOL, 2), val[5])
final.dataframe$unit_converted  <- c("umol O2/100 g/min", "umol O2/mL blood", "mL blood/100 g/min", "umol O2/min", "mL blood/min")
final.dataframe$n_observations <- 34L
final.dataframe$n_subjects <- 14L
final.dataframe$ref_keys_source <- "KETY y SCHMIDT (1948)"
final.dataframe$note <- NA_character_
final.dataframe$note[3] <- "Unit printed as 'c. c.' per 100 g and min (mL blood)."
final.dataframe$note[2] <- "Printed as volumes per 100 (vol %: mL O2 per 100 mL blood); converted to umol O2 per mL blood = x 44.64/100."
stopifnot(nrow(final.dataframe) == 5L)

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

BRAIN_G <- 1400       # running text p. 12: "Para un cerebro humano de 1.400 g."; not printed in the table
table_checks <- rbind(
  chk("total_O2_from_rate", "rate (3,3) x 1400 g / 100 vs printed total brain O2 c.c./min (46)", val[1] * BRAIN_G / 100, val[4],
      0.5 + 0.05 * BRAIN_G / 100, "brain weight 1400 g taken from the running text; tolerance = half unit of total + half unit of rate x weight"),
  chk("total_flow_from_flow", "flow per 100 g (54) x 1400 g / 100 vs printed total flow c.c./min (756)", val[3] * BRAIN_G / 100, val[5],
      0.5 + 0.5 * BRAIN_G / 100, "tolerance = half unit of total + half unit of flow/100 g x weight"),
  chk("fick_rate", "flow (54) x A-V difference (6,3) / 100 vs printed rate (3,3) c.c./100 g/min", val[3] * val[2] / 100, val[1],
      0.5 * 0.1 + 0.5 * val[2] / 100 + 0.05 * val[3] / 100, "tolerance = half unit of rate + propagated half units of flow (integer) and A-V difference (1 decimal)")
)
report_checks(table_checks)

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
