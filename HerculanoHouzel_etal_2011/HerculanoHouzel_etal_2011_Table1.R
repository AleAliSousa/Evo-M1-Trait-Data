## ============================================================================
## HerculanoHouzel_etal_2011_Table1.R
##
## Builds the analysis-ready table for Herculano-Houzel et al. (2011),
## Brain Behav Evol 78(4):302-314 (doi:10.1159/000330825), Table 1
## ("Average data for the 11 species of Glires") from the frozen snapshot
## HerculanoHouzel_etal_2011_Table1_snapshot.csv (captured from the PMC
## full text by HerculanoHouzel_etal_2011_Table1_snapshot.R; cross-checked
## against the publisher PDF in this folder).
##
## The printed table has species as COLUMNS (vernacular names) and
## measures as rows, all values "mean ± SD" (SD absent for
## single-specimen species and for the rabbit, whose source values are
## reported without SDs). This script transposes it to one row per
## species and:
##   * replaces the vernacular headers with the binomials used in the
##     paper's text (the printed "Dasyprocta primnolopha" [sic] is
##     normalised to Dasyprocta prymnolopha, the spelling used by
##     Herculano-Houzel et al. 2015 and the species hub);
##   * splits every "mean ± SD" cell into a mean column and an SD column;
##   * converts the cell counts, printed in millions ("× 106"), to
##     absolute counts;
##   * names the measure columns exactly as the sibling
##     HerculanoHouzel_etal_2015 tables do ("Cerebral cortex N, n",
##     "Whole brain Neurons", ...), so the item slots into the
##     isotropic-fractionator merge on the same terms;
##   * keeps "ca. 500" (grey squirrel body mass: body weights were not
##     recorded for the two wild-caught species; the paper assumes an
##     average of 500 g) as 500 -- the approximation is flagged in the
##     item README, the snapshot keeps the verbatim string;
##   * keeps the prairie dog olfactory bulb, printed "n.a.", as NA.
##
## The paper prints NO densities and NO O/N ratios: those are derived
## downstream by the merge from these counts, as for every source that
## reports counts only.
##
## Outputs (house pattern):
##   * HerculanoHouzel_etal_2011_Table1.csv  -- in this folder
##   * <Item encoded>.tsv                    -- in __Public/comparative-data/
##     (the "Item encoded" value is resolved from __ReadMe.xlsx Sheet1;
##      if the registry row is absent the script warns and skips the TSV)
##
## Table checks (HOWTO section 7a) are left in `table_checks`: the
## printed whole-brain values must equal the sum of the cortical +
## cerebellar + RoB values (the paper's whole brain excludes the
## olfactory bulb) within print-rounding tolerance, and the rabbit
## cerebellar O/N derived from these counts must be 0.314 (the value
## misprinted as 1.222 in Herculano-Houzel et al. 2015, Table 2).
## ============================================================================

## ---- self-locating header ---------------------------------------------------
script_path <- local({
  me   <- "HerculanoHouzel_etal_2011_Table1.R"   # this file's own name
  argv <- commandArgs(trailingOnly = FALSE)
  f    <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f) && basename(f) == me) return(normalizePath(f))
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    of <- tryCatch(fr[[k]]$ofile, error = function(e) NULL)
    if (is.character(of) && length(of) == 1L && basename(of) == me &&
        file.exists(of)) return(normalizePath(of))
  }
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me) return(normalizePath(p))
  }
  ## last resort: sys.source() (build_dataset_item) sets no ofile frame --
  ## find this file by name under the working directory (the repo root)
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"),
                     recursive = TRUE, full.names = TRUE)
  if (length(hits) == 1L) return(normalizePath(hits))
  stop("Cannot locate this script; run it with Rscript or from RStudio.")
})
folder      <- dirname(script_path)
source_name <- "HerculanoHouzel_etal_2011_Table1"
snap_file   <- file.path(folder, paste0(source_name, "_snapshot.csv"))
if (!file.exists(snap_file)) stop("Snapshot not found: ", snap_file)

## ---- read the snapshot -------------------------------------------------------
snap <- utils::read.csv(snap_file, check.names = FALSE, colClasses = "character",
                        na.strings = "", encoding = "UTF-8")
row_label <- snap[["Measure"]]
snap_mat  <- as.matrix(snap[, -1, drop = FALSE])   # rows = measures, cols = species
row.names(snap_mat) <- row_label

## ---- species map: printed vernacular -> binomial used in the paper text -----
species_map <- data.frame(
  vernacular = c("Naked mole-rat", "Mouse", "Hamster", "Rat", "Spiny rat",
                 "Guinea pig", "Prairie dog", "Grey squirrel", "Rabbit",
                 "Agouti", "Capybara"),
  binomial   = c("Heterocephalus glaber", "Mus musculus", "Mesocricetus auratus",
                 "Rattus norvegicus", "Proechimys cayennensis", "Cavia porcellus",
                 "Cynomys sp.", "Sciurus carolinensis", "Oryctolagus cuniculus",
                 "Dasyprocta prymnolopha", "Hydrochoerus hydrochaeris"),
  order      = c(rep("Rodentia", 8), "Lagomorpha", "Rodentia", "Rodentia"),
  stringsAsFactors = FALSE)
if (!identical(colnames(snap_mat), species_map$vernacular))
  stop("Snapshot species columns do not match the expected printed order.")

## ---- cell parser --------------------------------------------------------------
## "23.3 ± 5.9" -> c(23.3, 5.9); "26.88 ± 3.34 × 106" (count) -> c(26880000, 3340000)
parse_ms <- function(x, is_count) {
  if (is.na(x) || !nzchar(x) || x == "n.a.") return(c(NA_real_, NA_real_))
  x <- sub("^ca\\.\\s*", "", x)
  mult <- 1
  if (is_count) {
    if (!grepl(" × 106$", x)) stop("Count cell without ' × 106' suffix: ", x)
    x <- sub(" × 106$", "", x); mult <- 1e6
  }
  parts <- strsplit(x, "±", fixed = TRUE)[[1]]
  if (length(parts) > 2L) stop("Unparseable cell: ", x)
  num <- function(s) as.numeric(gsub(",", "", trimws(s)))
  c(num(parts[1]) * mult,
    if (length(parts) == 2L) num(parts[2]) * mult else NA_real_)
}

## printed row label -> built mean/SD column names (+ whether counts)
row_spec <- list(
  "Body mass, g"        = list(mean = "Body mass, g",        sd = "Body mass, g SD",        count = FALSE),
  "Brain mass, g"       = list(mean = "Brain mass, g",       sd = "Brain mass, g SD",       count = FALSE),
  "Brain neurons"       = list(mean = "Whole brain Neurons", sd = "Whole brain Neurons SD", count = TRUE),
  "Brain other cells"   = list(mean = "Whole brain Other cells", sd = "Whole brain Other cells SD", count = TRUE),
  "Cortical mass, g"    = list(mean = "Cerebral cortex Mass, g", sd = "Cerebral cortex Mass, g SD", count = FALSE),
  "Cortical neurons"    = list(mean = "Cerebral cortex N, n",    sd = "Cerebral cortex N, n SD",    count = TRUE),
  "Cortical other cells"= list(mean = "Cerebral cortex O, n",    sd = "Cerebral cortex O, n SD",    count = TRUE),
  "Cerebellar mass, g"  = list(mean = "Cerebellum Mass, g",  sd = "Cerebellum Mass, g SD",  count = FALSE),
  "Cerebellar neurons"  = list(mean = "Cerebellum N, n",     sd = "Cerebellum N, n SD",     count = TRUE),
  "Cerebellar other cells" = list(mean = "Cerebellum O, n",  sd = "Cerebellum O, n SD",     count = TRUE),
  "RoB mass, g"         = list(mean = "RoB Mass, g",         sd = "RoB Mass, g SD",         count = FALSE),
  "RoB neurons"         = list(mean = "RoB N, n",            sd = "RoB N, n SD",            count = TRUE),
  "RoB other cells"     = list(mean = "RoB O, n",            sd = "RoB O, n SD",            count = TRUE),
  "Olf bulb mass, g"    = list(mean = "Olfactory bulb Mass, g", sd = "Olfactory bulb Mass, g SD", count = FALSE),
  "Olf bulb neurons"    = list(mean = "Olfactory bulb N, n",    sd = "Olfactory bulb N, n SD",    count = TRUE),
  "Olf bulb other cells"= list(mean = "Olfactory bulb O, n",    sd = "Olfactory bulb O, n SD",    count = TRUE))
if (!all(names(row_spec) %in% row_label))
  stop("Snapshot is missing printed rows: ",
       paste(setdiff(names(row_spec), row_label), collapse = ", "))

n_sp <- ncol(snap_mat)
out <- data.frame(Species = species_map$binomial,
                  Order = species_map$order,
                  `Common name` = species_map$vernacular,
                  Number = as.integer(snap_mat["Number", ]),
                  check.names = FALSE, stringsAsFactors = FALSE)
for (lab in names(row_spec)) {
  spec <- row_spec[[lab]]
  vals <- vapply(seq_len(n_sp),
                 function(j) parse_ms(snap_mat[lab, j], spec$count),
                 numeric(2))
  out[[spec$mean]] <- if (spec$count) round(vals[1, ]) else vals[1, ]
  out[[spec$sd]]   <- if (spec$count) round(vals[2, ]) else vals[2, ]
}

## ---- table checks (HOWTO 7a) ---------------------------------------------------
chk <- list()
add_check <- function(check, species, printed, computed, tol) {
  chk[[length(chk) + 1L]] <<- data.frame(
    check = check, species = species, printed = printed, computed = computed,
    difference = abs(printed - computed), tolerance = tol,
    pass = abs(printed - computed) <= tol, stringsAsFactors = FALSE)
}
for (i in seq_len(nrow(out))) {
  sp <- out$Species[i]
  {
    add_check("brain neurons = cortex + cerebellum + RoB neurons", sp,
              out[["Whole brain Neurons"]][i],
              out[["Cerebral cortex N, n"]][i] + out[["Cerebellum N, n"]][i] +
                out[["RoB N, n"]][i], 20000)
    add_check("brain other cells = cortex + cerebellum + RoB other cells", sp,
              out[["Whole brain Other cells"]][i],
              out[["Cerebral cortex O, n"]][i] + out[["Cerebellum O, n"]][i] +
                out[["RoB O, n"]][i], 20000)
    add_check("brain mass = cortex + cerebellum + RoB mass", sp,
              out[["Brain mass, g"]][i],
              out[["Cerebral cortex Mass, g"]][i] + out[["Cerebellum Mass, g"]][i] +
                out[["RoB Mass, g"]][i], 0.002)
  }
}
rb <- out[out$Species == "Oryctolagus cuniculus", ]
add_check("rabbit cerebellum O/N derived from counts rounds to 0.314",
          "Oryctolagus cuniculus", 0.314,
          round(rb[["Cerebellum O, n"]] / rb[["Cerebellum N, n"]], 3), 0)
table_checks <- do.call(rbind, chk)
print(table_checks)
## The whole-brain sum checks are evidence, not a gate (HOWTO 7a): two
## printed deviations are known and documented in the item README --
##   * Cynomys sp. brain neurons: the 2011 table prints 473.94 x 10^6,
##     a digit transposition of 437.94 x 10^6 (its own parts sum, and
##     the value Herculano-Houzel et al. 2015 print with the same SD).
##     The built table stays verbatim; the isotropic-fractionator merge
##     corrects the cell in its section 3.4d guarded block.
##   * Dasyprocta prymnolopha: the printed whole-brain counts differ
##     from the sum of the printed parts in BOTH the 2011 table and
##     the 2015 compilation (same differences), so the whole-brain
##     values stand as the authors reported them.
## The rabbit check, by contrast, verifies this build's reason to
## exist; if it fails, the transcription is wrong and the build stops.
rabbit_ok <- table_checks$pass[grepl("rabbit cerebellum",
                                     table_checks$check)]
if (!isTRUE(rabbit_ok))
  stop("Rabbit cerebellum check FAILED for ", source_name,
       " -- transcription error; see table_checks above.")
failed <- table_checks[!table_checks$pass, ]
if (nrow(failed) > 0L)
  message("Known printed deviations (documented in the item README): ",
          paste(failed$check, "for", failed$species, collapse = "; "))

## ---- write the analysis CSV -----------------------------------------------------
csv_file <- file.path(folder, paste0(source_name, ".csv"))
utils::write.csv(out, csv_file, row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
message("Wrote ", csv_file, " (", nrow(out), " species rows, ",
        ncol(out), " columns)")

## ---- resolve "Item encoded" from the registry and write the public TSV --------
find_registry <- function(start_dir) {
  d <- normalizePath(start_dir)
  repeat {
    f <- file.path(d, "__ReadMe.xlsx")
    if (file.exists(f)) return(f)
    parent <- dirname(d)
    if (parent == d) return(NULL)
    d <- parent
  }
}
item_encoded <- NULL
reg <- find_registry(folder)
if (!is.null(reg) && requireNamespace("readxl", quietly = TRUE)) {
  sheet1 <- tryCatch(readxl::read_excel(reg, sheet = "Sheet1"),
                     error = function(e) NULL)
  if (!is.null(sheet1) && "Item name" %in% names(sheet1)) {
    hit <- which(sheet1[["Item name"]] == source_name)
    if (length(hit) == 1L) item_encoded <- as.character(sheet1[["Item encoded"]][hit])
  }
}
if (is.null(item_encoded) || is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("Item encoded not resolved from __ReadMe.xlsx for ", source_name,
          " -- public TSV not written.")
} else {
  tsv_file <- file.path(dirname(reg), "__Public", "comparative-data",
                        paste0(item_encoded, ".tsv"))
  if (!dir.exists(dirname(tsv_file)))
    stop("Public TSV directory does not exist: ", dirname(tsv_file))
  utils::write.table(out, tsv_file, sep = "\t", row.names = FALSE, na = "NA",
                     fileEncoding = "UTF-8")
  message("Wrote ", tsv_file)
}
