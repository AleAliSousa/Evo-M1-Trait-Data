## Kaskan_etal_2005_Figure3.R -- frozen digitisation capture -> analysis CSV + public TSV
##
## Kaskan, P. M., Franco, E. C. S., Yamada, E. S., Silveira, L. C. L.,
## Darlington, R. B., & Finlay, B. L. (2005). Peripheral variability and
## central constancy in mammalian visual system evolution.
## Proc R Soc Lond B, 272, 91-100. doi:10.1098/rspb.2004.2925
##
## Figure 3 (printed p. 94) is the only place the paper publishes
## species-level V1 and total-visual-cortex areas: as plotted points. The
## values of this item are therefore DIGITISED COORDINATES, carrying an
## estimated +-0.05-0.1 log10-unit uncertainty, and the capture resolved
## fewer points than the paper's stated 20 nocturnal + 8 diurnal + 2
## monotremata per panel (see the README). They are not printed values.
##
## This script develops the frozen capture
## (Kaskan_etal_2005_Figure3_snapshot.csv -- marker shape, legend group,
## printed arrow label and the captured x/y as captured) into the analysis
## CSV. It does not re-digitise anything and it writes the coordinates
## through as captured strings, so no re-formatting can perturb them.

## 0. PATHS --------------------------------------------------------
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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kaskan_etal_2005_Figure3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv    <- file.path(folder, paste0(item_name, ".csv"))
tsv_dir      <- if (!is.na(base)) file.path(base, "__Public", "comparative-data") else NA

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(readxl) })

## 2. LOAD THE FROZEN CAPTURE ---------------------------------------
snap <- read.csv(snapshot_csv, stringsAsFactors = FALSE, check.names = FALSE,
                 colClasses = "character", na.strings = NULL, encoding = "UTF-8")
stopifnot(nrow(snap) == 46L,
          identical(names(snap),
                    c("panel","panel_y_axis_label_printed","marker_shape","legend_group_printed",
                      "arrow_label_printed","identification_basis","label_annotation",
                      "x_log_total_neocortex","y_log_value")))

## 3. SPECIES (collection key is the single source of truth) --------
## Figure 3b arrow-labels four points with abbreviated names; the key holds
## the expansion, evidenced against the Electronic Appendix A roster.
key_file <- if (!is.na(base)) file.path(base, "_keys", "General", "species_key.csv") else NA
if (is.na(key_file) || !file.exists(key_file))
  stop("General collection species key not found.", call. = FALSE)
key <- read.csv(key_file, colClasses = "character", check.names = FALSE, encoding = "UTF-8")
key <- key[key$source_publication == "Kaskan_etal_2005", , drop = FALSE]
if (nrow(key) == 0L)
  stop("No _keys/General/species_key.csv rows for source_publication == \"Kaskan_etal_2005\"; ",
       "key rows are scoped to the paper folder name.", call. = FALSE)
lk <- stats::setNames(key$accepted_name, key$variant_name)
labelled <- nzchar(snap$arrow_label_printed)
if (!all(snap$arrow_label_printed[labelled] %in% names(lk)))
  stop("Printed arrow labels absent from the Kaskan species key: ",
       paste(setdiff(snap$arrow_label_printed[labelled], names(lk)), collapse = "; "), call. = FALSE)

## 4. DEVELOP --------------------------------------------------------
## y_variable follows the panel; group is the legend entry reduced to its
## one-word token; unlabelled markers are numbered sequentially within each
## panel in capture order, and any capture annotation is appended in
## parentheses exactly as it was recorded.
y_variable <- ifelse(snap$panel == "a", "log_V1", "log_total_visual_cortex")
group      <- tolower(sub(" species$", "", snap$legend_group_printed))

species_or_label <- character(nrow(snap))
for (p in unique(snap$panel)) {
  idx <- which(snap$panel == p)
  n <- 0L
  for (i in idx) {
    if (nzchar(snap$arrow_label_printed[i])) {
      species_or_label[i] <- unname(lk[snap$arrow_label_printed[i]])
    } else {
      n <- n + 1L
      species_or_label[i] <- sprintf("unidentified_%02d", n)
    }
  }
}
ann <- nzchar(snap$label_annotation)
species_or_label[ann] <- paste0(species_or_label[ann], " (", snap$label_annotation[ann], ")")

final.dataframe <- data.frame(
  panel               = snap$panel,
  y_variable          = y_variable,
  group               = group,
  species_or_label    = species_or_label,
  log_total_neocortex = snap$x_log_total_neocortex,   # kept as captured strings
  log_y_value         = snap$y_log_value,
  stringsAsFactors = FALSE, check.names = FALSE)

## 5. CHECKS (sec 7a) -------------------------------------------------
## Nothing inside a digitised scatter can be checked arithmetically. Two
## structural facts can be, and both bear on how much the capture can be
## trusted: the group counts against the totals the paper states in the
## Figure 3 legend (20 nocturnal, 8 diurnal, and the 2 monotremes the text
## says are plotted), and -- because Figure 3's two panels share their
## x-axis -- whether each panel-a named species' x matches its panel-b twin.
stated <- c(nocturnal = 20, diurnal = 8, monotremata = 2)
counts <- as.data.frame(table(final.dataframe$panel, final.dataframe$group),
                        stringsAsFactors = FALSE)
names(counts) <- c("panel", "group", "n")
table_checks <- data.frame(
  check_id  = paste0("points_resolved_panel_", counts$panel, "_", counts$group),
  basis     = paste0("markers resolved in panel ", counts$panel, " for ", counts$group,
                     " vs the ", stated[counts$group], " the paper states are plotted"),
  observed  = as.numeric(counts$n),
  printed   = as.numeric(stated[counts$group]),
  tolerance = 0,
  note      = "a shortfall is expected: overlapping markers could not be separated at this image resolution",
  stringsAsFactors = FALSE)
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$status <- ifelse(table_checks$difference == 0, "pass",
                       ifelse(table_checks$difference < 0, "mismatch_undercount", "mismatch_overcount"))

xmatch <- do.call(rbind, lapply(unique(snap$arrow_label_printed[labelled]), function(lab) {
  xa <- as.numeric(snap$x_log_total_neocortex[snap$panel == "a" & snap$arrow_label_printed == lab])
  xb <- as.numeric(snap$x_log_total_neocortex[snap$panel == "b" & snap$arrow_label_printed == lab])
  if (length(xa) != 1L || length(xb) != 1L) return(NULL)
  data.frame(check_id = paste0("cross_panel_x_", gsub("[^A-Za-z]", "", lab)),
             basis = paste0("panel a and panel b share the x-axis, so ", lab,
                            " must sit at the same log total neocortex in both"),
             observed = xa, printed = xb, tolerance = 0.1,
             note = "tolerance is the digitisation uncertainty stated in the README (+-0.05-0.1 log10 units)",
             stringsAsFactors = FALSE)
}))
xmatch$difference <- xmatch$observed - xmatch$printed
## compare in whole units of the captured precision (0.01 log units) so that a
## difference sitting exactly on the tolerance cannot be decided by floating point
xmatch$status <- ifelse(abs(round(xmatch$difference * 100)) <= round(xmatch$tolerance * 100),
                        "pass", "mismatch")
cols <- c("check_id","basis","observed","printed","difference","tolerance","status","note")
table_checks <- rbind(table_checks[, cols], xmatch[, cols])
message(sprintf("table_checks: %d pass, %d undercount, %d other mismatch",
                sum(table_checks$status == "pass"),
                sum(table_checks$status == "mismatch_undercount"),
                sum(!table_checks$status %in% c("pass", "mismatch_undercount"))))

## 6. WRITE CSV + PUBLIC TSV ------------------------------------------
## CRLF and unquoted fields reproduce the file as it already stands on disk.
if (file.exists(final_csv)) {
  before <- readBin(final_csv, "raw", file.info(final_csv)$size)
} else before <- NULL
con <- file(final_csv, open = "wb")
write.table(final.dataframe, con, sep = ",", row.names = FALSE, quote = FALSE, eol = "\r\n")
close(con)
if (!is.null(before)) {
  after <- readBin(final_csv, "raw", file.info(final_csv)$size)
  if (!identical(before, after))
    warning("This build changed ", basename(final_csv),
            " relative to the copy that was on disk -- inspect the difference before accepting it.")
  else message("Analysis CSV reproduced byte-for-byte from the frozen capture.")
}
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = FALSE)
} else warning("__Public not mounted; TSV not written -- copy later")
message(sprintf("%s: %d rows written", item_name, nrow(final.dataframe)))
