## Kaskan_etal_2005_Figure2.R -- constructed snapshot -> analysis CSV + public TSV
##
## Kaskan, P. M., Franco, E. C. S., Yamada, E. S., Silveira, L. C. L.,
## Darlington, R. B., & Finlay, B. L. (2005). Peripheral variability and
## central constancy in mammalian visual system evolution.
## Proc R Soc Lond B, 272, 91-100. doi:10.1098/rspb.2004.2925
##
## Figure 2 (printed p. 94) plots ONLY fitted regression lines -- it has no
## data points to digitize. What it does publish, in its legend, is the full
## set of eight fitted equations and their r-squared values, plus three
## slope-difference tests. Those printed statistics are this item.
##
## DATA ROLE = secondary. These are regressions of phylogenetically
## independent contrasts; they are fitted statistics, not measurements, and
## they must not enter any measurement merge (PROJECT_SCOPE_AND_DATASET_
## ROADMAP.md excludes ingesting secondary slopes as a measurement team).

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
item_name <- tools::file_path_sans_ext(basename(.sp))   # "Kaskan_etal_2005_Figure2"
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
suppressPackageStartupMessages({ library(readr); library(dplyr); library(stringr); library(readxl) })

## 2. LOAD THE FROZEN CONSTRUCTED SNAPSHOT ---------------------------
raw <- read.csv(snapshot_csv, header = FALSE, colClasses = "character",
                check.names = FALSE, na.strings = NULL, encoding = "UTF-8")
hdr_row <- which(raw[[1]] == "row")
stopifnot(length(hdr_row) == 1L)
hdr  <- as.character(unlist(raw[hdr_row, ]))
body <- raw[seq(hdr_row + 1L, nrow(raw)), , drop = FALSE]
body <- body[grepl("^[0-9]+$", body[[1]]), , drop = FALSE]   # drops the trailing locus line
names(body) <- hdr
stopifnot(nrow(body) == 8L)

## 3. CLEAN ----------------------------------------------------------
## Split the printed equation "KEY = <slope>x - <intercept>" into its terms.
eq <- str_match(body$equation_printed,
                "^\\s*\\S+\\s*=\\s*(-?[0-9.]+)x\\s*([-+])\\s*([0-9.]+)\\s*$")
if (anyNA(eq[, 2])) stop("Printed equation did not parse: ",
                         paste(body$equation_printed[is.na(eq[, 2])], collapse = " | "), call. = FALSE)
measure_of <- c(V1 = "primary visual cortex (V1)",
                Vtot = "total visual cortex",
                S1 = "primary somatosensory cortex (S1)",
                SStot = "total somatosensory cortex",
                A1 = "primary auditory cortex (A1)",
                Atot = "total auditory cortex",
                M = "primary motor cortex (M1)",
                Mtot = "total motor cortex")
level_of <- c(V1 = "primary", Vtot = "total", S1 = "primary", SStot = "total",
              A1 = "primary", Atot = "total", M = "primary", Mtot = "total")
modality_of <- c(V1 = "visual", Vtot = "visual", S1 = "somatosensory", SStot = "somatosensory",
                 A1 = "auditory", Atot = "auditory", M = "motor", Mtot = "motor")
stopifnot(all(body$equation_key_printed %in% names(measure_of)))

final.dataframe <- tibble(
  printed_row              = as.integer(body$row),
  equation_key_printed     = body$equation_key_printed,
  panel                    = body$panel,
  panel_line_label_printed = body$panel_line_label_printed,
  structure                = unname(measure_of[body$equation_key_printed]),
  area_level               = unname(level_of[body$equation_key_printed]),
  modality                 = unname(modality_of[body$equation_key_printed]),
  slope                    = as.numeric(eq[, 2]),
  intercept                = as.numeric(paste0(ifelse(eq[, 3] == "-", "-", ""), eq[, 4])),
  r2                       = as.numeric(body$r2_printed),
  equation_printed         = body$equation_printed,
  r2_printed               = body$r2_printed,
  x_variable               = "log(total neocortex size)",
  y_variable               = "log(cortical area), as phylogenetically independent contrasts",
  intercept_plotted_is_adjusted = TRUE,
  data_role                = "secondary",
  source                   = "this study (fitted regression printed in the Figure 2 legend)"
)
stopifnot(nrow(final.dataframe) == 8L)

## 4. TABLE CHECKS (sec 7a) -------------------------------------------
## The legend has no internal arithmetic (slopes and r2 are not additive), but
## it does make one claim that the printed numbers themselves can confirm:
## "The slopes for primary and total visual cortices are greatest." Checked
## here per panel; a mismatch would mean the transcription or the panel
## assignment is wrong.
greatest <- final.dataframe %>% group_by(panel) %>%
  summarise(steepest = equation_key_printed[which.max(slope)],
            steepest_slope = max(slope), .groups = "drop")
expected <- c(a = "V1", b = "Vtot")
table_checks <- tibble(
  check_id  = paste0("visual_slope_greatest_panel_", greatest$panel),
  basis     = paste0("legend claim 'The slopes for primary and total visual cortices are greatest': ",
                     "steepest of the four lines in panel ", greatest$panel,
                     " should be ", expected[greatest$panel],
                     "; observed ", greatest$steepest),
  observed  = as.numeric(greatest$steepest == expected[greatest$panel]),
  printed   = 1,
  tolerance = 0,
  note      = "consistency of the printed equations with the printed claim, not an arithmetic sum"
) %>% mutate(difference = observed - printed,
             status = ifelse(difference == 0, "pass", "mismatch")) %>%
  select(check_id, basis, observed, printed, difference, tolerance, status, note)
if (any(table_checks$status == "mismatch"))
  warning("Printed slopes contradict the legend's 'visual slopes are greatest' claim.")
message(sprintf("table_checks: %d pass, %d mismatch",
                sum(table_checks$status == "pass"), sum(table_checks$status == "mismatch")))

## 5. WRITE CSV + PUBLIC TSV ------------------------------------------
write.csv(final.dataframe, final_csv, row.names = FALSE, na = "")
if (!is.na(tsv_dir) && dir.exists(tsv_dir)) {
  filecodes    <- read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
      grepl("_$", item_encoded))
    stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name,
         " -- refusing to write NA.tsv.", call. = FALSE)
  write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(sprintf("%s: %d rows written", item_name, nrow(final.dataframe)))
