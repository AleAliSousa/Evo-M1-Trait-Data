# Karbowski__2007_Table1.R
# -----------------------------------------------------------------------------
# Reformat: frozen snapshot -> analysis CSV + DOI-encoded public TSV for
# Karbowski (2007) main-paper Table 1 (specific scaling exponents of the
# regional cerebral glucose utilization rate CMRglc against brain volume).
#
# DATA ROLE = secondary. Table 1 holds no new measurements: each row is an
# OLS fit over the per-species CMRglc values that Karbowski compiled from
# other laboratories (supplementary Tables S3-S23, built separately in this
# folder) regressed on brain volume taken from Hofman [41] and
# Stephan et al [100] "or from the source" (Methods, printed p.9).
#
# Input : Karbowski__2007_Table1_snapshot.csv  (row 1 = caption, row 2 =
#         header, 27 printed body rows in printed order with the printed
#         indentation preserved, last row = the printed footnote)
#         plus the sibling Karbowski__2007_Table S<N>.csv files, used ONLY to
#         derive the per-row source references and to check Species (n).
# Output: Karbowski__2007_Table1.csv
#         __Public/comparative-data/<Item encoded>.tsv
# -----------------------------------------------------------------------------
suppressPackageStartupMessages({ library(readxl); library(readr); library(dplyr); library(stringr) })

.script_path <- local({
  args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(args)) return(normalizePath(sub("^--file=", "", args[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(path)) path <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(path)) return(normalizePath(path))
  }
  stop("Run with Rscript, or save and Source this file in RStudio.", call. = FALSE)
})
folder    <- dirname(.script_path)
item_name <- tools::file_path_sans_ext(basename(.script_path))   # "Karbowski__2007_Table1"
base      <- dirname(folder)
snap      <- file.path(folder, paste0(item_name, "_snapshot.csv"))
final_csv <- file.path(folder, paste0(item_name, ".csv"))
readme    <- file.path(base, "__ReadMe.xlsx")
tsv_dir   <- file.path(base, "__Public", "comparative-data")

## 1. LOAD THE FROZEN SNAPSHOT ------------------------------------------------
raw <- read.csv(snap, header = FALSE, colClasses = "character", check.names = FALSE,
                na.strings = NULL, encoding = "UTF-8")
hdr <- as.character(unlist(raw[2, ]))
stopifnot(identical(hdr[1], "Brain structure"), identical(hdr[6], "Species (n)"))
body <- raw[-c(1, 2), , drop = FALSE]
body <- body[!str_starts(body[[1]], "The t-test showed"), , drop = FALSE]   # printed footnote
stopifnot(nrow(body) == 27L)

label_printed <- body[[1]]
indent        <- ifelse(str_detect(label_printed, "^  "), 1L, 0L)
structure_printed <- str_squish(label_printed)
has_value     <- str_squish(body[[2]]) != ""

# Printed grouping: an indented row belongs to the nearest preceding flush-left
# label. Four of those labels ("Basal ganglia", "Limbic system", "Brain stem",
# "White matter") carry no values and are pure group headers; "Cerebral cortex"
# and "Hypothalamus" are both a fitted row and the heading of their indented rows.
group_as_published <- character(nrow(body)); current <- ""
for (i in seq_len(nrow(body))) {
  if (indent[i] == 0L) current <- structure_printed[i]
  group_as_published[i] <- if (indent[i] == 0L) "" else current
}

## 2. CLEAN -------------------------------------------------------------------
num <- function(x) suppressWarnings(as.numeric(str_replace_all(str_squish(x), "\u2212", "-")))
pm  <- str_split_fixed(str_squish(body[[2]]), "\\s*\u00b1\\s*", 2)
ci  <- str_split_fixed(str_squish(body[[3]]), "\\s+to\\s+", 2)

final.dataframe <- tibble(
  printed_row           = seq_len(nrow(body)),
  structure_printed     = structure_printed,
  group_as_published    = group_as_published,
  indent_level          = indent,
  scaling_exponent      = num(pm[, 1]),
  scaling_exponent_sd   = num(pm[, 2]),
  ci95_low              = num(ci[, 1]),
  ci95_high             = num(ci[, 2]),
  correlation_r2        = num(body[[4]]),
  p_value               = num(body[[5]]),
  n_species             = as.integer(num(body[[6]])),
  scaling_exponent_printed = str_squish(body[[2]]),
  ci95_printed             = str_squish(body[[3]])
)[has_value, ]
stopifnot(nrow(final.dataframe) == 23L)

## 3. PER-ROW SOURCE PROVENANCE ------------------------------------------------
# Each Table 1 row is a fit over one supplementary table's compiled values.
# The map below is the structure-name correspondence printed in the
# supplementary table captions (Table S3 "Visual cortex ...", S13
# "Thalamus ...", and so on); it holds no data values. Table S11 is the
# cortex average "Data for Fig. 2E in the main text" and prints N (number of
# cortical areas) instead of a Reference column, so the cortex row's sources
# are the union of the eight cortical-area tables it averages (Methods p.9).
supp_map <- tibble::tribble(
  ~structure_printed,     ~supp_table, ~supp_subregion,
  "Cerebral cortex",      "S11",       NA_character_,
  "Visual",               "S3",        NA_character_,
  "Prefrontal",           "S4",        NA_character_,
  "Frontal",              "S5",        NA_character_,
  "Cingulate",            "S6",        NA_character_,
  "Temporal",             "S7",        NA_character_,
  "Sensorimotor",         "S8",        NA_character_,
  "Occipital",            "S9",        NA_character_,
  "Parietal",             "S10",       NA_character_,
  "Thalamus",             "S13",       NA_character_,
  "Cerebellum",           "S14",       NA_character_,
  "Hypothalamus",         "S15",       "Hypothalamus",
  "Mammillary body",      "S15",       "Mammilary body",
  "Hippocampus",          "S16",       NA_character_,
  "Amygdala",             "S17",       NA_character_,
  "Septum",               "S18",       NA_character_,
  "Caudate",              "S19",       NA_character_,
  "Substantia nigra",     "S20",       NA_character_,
  "Globus pallidus",      "S21",       NA_character_,
  "Superior colliculus",  "S22",       "Superior colliculus",
  "Inferior colliculus",  "S22",       "Inferior colliculus",
  "Corpus callosum",      "S23",       "Corpus callosum",
  "Internal capsule",     "S23",       "Internal capsule"
)
cortex_component_tables <- c("S3","S4","S5","S6","S7","S8","S9","S10")

read_supp <- function(tid) {
  p <- file.path(folder, paste0("Karbowski__2007_Table", tid, ".csv"))
  if (!file.exists(p))
    stop("Sibling supplementary build missing: ", basename(p),
         " -- run Karbowski__2007_TablesS1-S23.R first.", call. = FALSE)
  read_csv(p, show_col_types = FALSE, progress = FALSE)
}
supp_rows <- function(tid, sub) {
  d <- read_supp(tid)
  if (!is.na(sub)) d <- d[d$subregion == sub, , drop = FALSE]
  d
}
refs_of <- function(d) {
  r <- d$reference
  r <- str_squish(r[!is.na(r) & str_squish(r) != ""])
  sort(unique(r))
}
species_of <- function(d) {
  s <- str_squish(str_remove(d$species_printed, "^average\\s+"))
  sort(unique(s[s != ""]))
}

prov <- supp_map
prov$supp_species_n <- NA_integer_
prov$source_refs    <- NA_character_
for (i in seq_len(nrow(prov))) {
  d  <- supp_rows(prov$supp_table[i], prov$supp_subregion[i])
  rr <- if (prov$structure_printed[i] == "Cerebral cortex")
          sort(unique(unlist(lapply(cortex_component_tables,
                                    function(t) refs_of(read_supp(t))))))
        else refs_of(d)
  prov$supp_species_n[i] <- length(species_of(d))
  prov$source_refs[i]    <- paste(rr, collapse = "; ")
}

final.dataframe <- final.dataframe %>%
  left_join(prov, by = "structure_printed") %>%
  mutate(
    source_supplementary_table = ifelse(structure_printed == "Cerebral cortex",
                                        "S11 (sources: S3-S10)", supp_table),
    brain_volume_refs = "Hofman [41]; Stephan et al [100]") %>%
  select(-supp_table, -supp_subregion, -supp_species_n)
stopifnot(!any(is.na(final.dataframe$source_refs)),
          all(nzchar(final.dataframe$source_refs)))

## 4. TABLE CHECKS (sec 7a) ----------------------------------------------------
# Table 1 has no internal arithmetic relation, but its "Species (n)" column is
# checkable against the compiled supplementary table each row was fitted to:
# n must equal the number of distinct species in that table. This is what
# certifies the structure -> supplementary-table map above.
chk <- final.dataframe %>%
  select(structure_printed, n_species) %>%
  left_join(prov %>% select(structure_printed, supp_table, supp_species_n),
            by = "structure_printed")
table_checks <- tibble(
  check_id  = paste0("n_species_", str_replace_all(chk$structure_printed, " ", "_")),
  basis     = sprintf("printed 'Species (n)' vs distinct species in supplementary Table %s",
                      chk$supp_table),
  observed  = as.numeric(chk$supp_species_n),
  printed   = as.numeric(chk$n_species),
  tolerance = 0,
  note      = "exact count; 'average <species>' summary rows collapsed onto the species"
) %>% mutate(difference = observed - printed,
             status = ifelse(abs(difference) <= tolerance, "pass", "mismatch")) %>%
  select(check_id, basis, observed, printed, difference, tolerance, status, note)
if (any(table_checks$status == "mismatch"))
  warning("Species (n) does not match the mapped supplementary table for: ",
          paste(table_checks$check_id[table_checks$status == "mismatch"], collapse = ", "))
message(sprintf("table_checks: %d pass, %d mismatch",
                sum(table_checks$status == "pass"), sum(table_checks$status == "mismatch")))

## 5. WRITE CSV + PUBLIC TSV ---------------------------------------------------
write_csv(final.dataframe, final_csv, na = "")
filecodes    <- read_excel(readme, sheet = "Sheet1")
item_encoded <- filecodes[["Item encoded"]][match(item_name, filecodes[["Item name"]])]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) ||
    grepl("_$", item_encoded))
  stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, call. = FALSE)
if (dir.exists(tsv_dir)) {
  write_tsv(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")), na = "")
} else warning("__Public not mounted; TSV not written -- copy later")
message(sprintf("%s: %d rows written", item_name, nrow(final.dataframe)))
