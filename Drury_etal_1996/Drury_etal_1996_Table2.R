## Drury et al. 1996, J Cogn Neurosci 8(1):1-28 -- Table 2: surface area of cortical subdivisions
## in the macaque (case 79-0, right hemisphere; 3-D reconstruction).  doi:10.1162/jocn.1996.8.1.1
##
## Frozen source: Drury_etal_1996_Table2_snapshot.csv, written by Drury_etal_1996_Table2_snapshot.R
##   (hand transcription of the scanned page, read by eye from a 300-dpi render; see the README).
##   This script only reads it.
## What the table is: absolute surface area (mm2) and percent of total cortical surface area for 80
##   cortical subdivisions of one macaque hemisphere (case 79-0: layer-4 contours of Nissl-stained
##   sections; areal borders painted on a physical model following Felleman & Van Essen 1991 and
##   transferred to the computerized reconstruction). Group subtotals, neocortex and total rows kept.
## Species: the paper identifies the animal only as a macaque (commercially acquired brain, species
##   unknown) -> Macaca sp.; the printed caption word is kept in species_as_published.
## Table checks (in `table_checks`, never applied to values): every printed subtotal and total is
##   recomputed from its cells (tolerance = half a unit per summed cell), and every percentage is
##   recomputed as 100 x area / printed total cerebral cortex (tolerance = half the last printed
##   decimal + the effect of rounding the area to whole mm2).

options(scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, source() it, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))            # Drury_etal_1996_Table2
base <- local({ d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
setwd(folder)

## ---- 1. Read the frozen snapshot (positional; all character) ----
grid <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 header = FALSE, colClasses = "character", check.names = FALSE,
                 na.strings = character(0), encoding = "UTF-8")
stopifnot(ncol(grid) == 6L, nrow(grid) == 61L)
make_block <- function(block, cols, n) {
  z <- grid[3:(n + 2L), cols, drop = FALSE]
  data.frame(block = block, line = as.character(seq_len(n)),
             label = z[[1L]], area = z[[2L]], pct = z[[3L]],
             stringsAsFactors = FALSE)
}
tab <- rbind(make_block("left", 1:3, 59L), make_block("right", 4:6, 43L))
is_value <- nzchar(tab$area)

## ---- 2. Carry group headings down; classify rows ----
systems   <- c("Visual areas", "Somatosensory areas", "Motor areas", "Auditory areas", "Gustatory area",
               "Prefrontal areas", "Cingulate areas", "Perirhinal areas", "Hippocampal formation",
               "Transitional areas", "Paleocortex")
visual_sub <- c("Occipital", "Temporal", "Parietal", "Frontal")
cur_sys <- NA_character_; cur_sub <- NA_character_; past_neo <- FALSE
system <- subgroup <- cortex_class <- row_type <- character(nrow(tab))
for (i in seq_len(nrow(tab))) {
  lab <- tab$label[i]
  if (lab %in% systems) { cur_sys <- lab; cur_sub <- NA_character_ }
  if (lab %in% visual_sub) cur_sub <- lab
  if (lab == "Unspecified cortex") { cur_sys <- lab; cur_sub <- NA_character_ }
  row_type[i]  <- if (grepl("^Subtotal", lab)) "subtotal" else if (grepl("^Total", lab)) "total" else if (is_value[i]) "area" else "heading"
  system[i]    <- if (row_type[i] == "total") NA_character_ else cur_sys
  subgroup[i]  <- if (identical(cur_sys, "Visual areas") && row_type[i] == "area") cur_sub else NA_character_
  cortex_class[i] <- if (row_type[i] == "total") "all" else if (past_neo) "non-neocortex" else "neocortex"
  if (lab == "Subtotal (neocortex)") { past_neo <- TRUE; system[i] <- NA_character_ }
}
label_std <- c("MST1" = "MSTl", "S11" = "SII")                    # typeface l/1 and II/11 as printed

final.dataframe <- data.frame(
  Species               = "Macaca sp.",
  species_as_published  = "Macaque",
  specimen              = "case 79-0, right cerebral hemisphere (commercially acquired macaque brain, species unknown)",
  area_label_as_printed = tab$label,
  area_label            = ifelse(tab$label %in% names(label_std), label_std[tab$label], tab$label),
  system                = system,
  visual_subgroup       = subgroup,
  cortex_class          = cortex_class,
  row_type              = row_type,
  area_mm2              = suppressWarnings(as.numeric(tab$area)),
  pct_total_cortex      = suppressWarnings(as.numeric(tab$pct)),
  method                = paste0("surface area on the 3-D reconstruction (layer-4 contours of Nissl-stained sections); ",
                                 "areal borders from the physical model (Felleman & Van Essen 1991) transferred to it"),
  printed_block         = tab$block,
  printed_line          = as.integer(tab$line),
  source                = item_name,
  stringsAsFactors = FALSE, check.names = FALSE
)[is_value, ]
rownames(final.dataframe) <- NULL
fd <- final.dataframe

## ---- 3. Table checks (sums and percentages; values never changed) ----
chk <- list()
add_sum <- function(id, cells, printed_label, basis) {
  obs <- sum(cells); pr <- fd$area_mm2[fd$area_label_as_printed == printed_label]
  tol <- 0.5 * length(cells)
  chk[[length(chk) + 1]] <<- data.frame(check_id = id, basis = basis, observed = obs, printed = pr,
    difference = obs - pr, tolerance = tol, status = if (abs(obs - pr) <= tol) "pass" else "mismatch",
    note = paste0(length(cells), " cells summed; tolerance = half a mm2 per cell"), stringsAsFactors = FALSE)
}
area_of <- function(sys) fd$area_mm2[fd$row_type == "area" & fd$system %in% sys]
sub_of  <- function(lab) fd$area_mm2[fd$area_label_as_printed == lab]
add_sum("sum_visual", area_of("Visual areas"), "Subtotal (visual)", "32 visual areas vs 'Subtotal (visual)'")
add_sum("sum_somatosensory", area_of("Somatosensory areas"), "Subtotal (somatosensory)", "10 somatosensory areas vs subtotal")
add_sum("sum_motor", area_of("Motor areas"), "Subtotal (motor)", "3 motor areas vs subtotal")
add_sum("sum_auditory", area_of("Auditory areas"), "Subtotal (auditory)", "6 auditory areas vs subtotal")
add_sum("sum_prefrontal", area_of("Prefrontal areas"), "Subtotal (prefrontal)", "9 prefrontal areas vs subtotal")
add_sum("sum_neocortex",
        c(sub_of("Subtotal (visual)"), sub_of("Subtotal (somatosensory)"), sub_of("Subtotal (motor)"),
          sub_of("Subtotal (auditory)"), area_of("Gustatory area"), sub_of("Subtotal (prefrontal)"),
          area_of("Cingulate areas"), area_of("Perirhinal areas"), area_of("Unspecified cortex")),
        "Subtotal (neocortex)", "printed subtotals + gustatory, cingulate, perirhinal and unspecified cells vs 'Subtotal (neocortex)'")
add_sum("sum_non_neocortex", area_of(c("Hippocampal formation", "Transitional areas", "Paleocortex")),
        "Total non-neocortex", "10 hippocampal, transitional and paleocortical areas vs 'Total non-neocortex'")
add_sum("sum_total", c(sub_of("Subtotal (neocortex)"), sub_of("Total non-neocortex")),
        "Total cerebral cortex", "'Subtotal (neocortex)' + 'Total non-neocortex' vs 'Total cerebral cortex'")
total <- sub_of("Total cerebral cortex")
for (i in seq_len(nrow(fd))) {
  obs <- 100 * fd$area_mm2[i] / total
  tol <- 0.05 + 100 * 0.5 / total
  chk[[length(chk) + 1]] <- data.frame(check_id = paste0("pct_", fd$printed_block[i], "_", fd$printed_line[i]),
    basis = paste0("100 x area / ", total, " (", fd$area_label_as_printed[i], ")"), observed = round(obs, 3),
    printed = fd$pct_total_cortex[i], difference = round(obs - fd$pct_total_cortex[i], 3), tolerance = round(tol, 3),
    status = if (abs(obs - fd$pct_total_cortex[i]) <= tol) "pass" else "mismatch",
    note = "percent printed to 1 decimal", stringsAsFactors = FALSE)
}
table_checks <- do.call(rbind, chk)
bad <- table_checks[table_checks$status != "pass", ]
if (nrow(bad)) warning(item_name, ": ", nrow(bad), " table check(s) did not pass: ", paste(bad$check_id, collapse = ", "))
message(item_name, ": table checks ", sum(table_checks$status == "pass"), " pass / ", nrow(table_checks))

## ---- 4. Write the analysis CSV and the public TSV ----
write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE)
message(item_name, ": ", nrow(final.dataframe), " rows written")
if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc  <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  tsv_dir <- file.path(base, "__Public", "comparative-data")
  if (!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(path.expand(tsv_dir))) {
    write.table(final.dataframe, file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE)
  } else warning("Item encoded not found for ", item_name, "; public TSV not written.")
}
