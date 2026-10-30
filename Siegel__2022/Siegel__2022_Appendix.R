## Siegel__2022_Appendix.R -- frozen snapshot -> analysis CSV + public TSV
##
## Siegel, J. M. (2022). Sleep function: an evolutionary perspective. Lancet Neurol 21(10):937-946.
## doi:10.1016/S1474-4422(22)00210-1. Supplementary appendix pp. 1-2: "Appendix: REM, non-REM, and
## total sleep amounts in homeotherms" -- 52 printed mammal rows in three blocks (Placentals 47,
## Marsupials 3, Monotremes 2). Birds are named (23 species, ref 1) but no values are printed.
## SECONDARY: values are compiled; the only source keys printed are the section superscripts
## (Mammals "52 species2-5") -> reference_tables/Siegel__2022_Appendix_references.csv.
## Frozen source = the pre-existing hand transcription, byte-identical copy-renamed 2026-10-28 from
## Siegel__2022_Sleep_Supplementary_Snapshot.xlsx to <Item>_snapshot.xlsx (verified cell-by-cell
## against the PDF text layer and page images; 52/52 rows equal). See README.
## Supersedes the script-less legacy Siegel__2022_Homeotherms.csv / .tsv (left untouched).

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  for (fr in rev(sys.frames())) if (!is.null(fr$ofile)) return(normalizePath(fr$ofile))
  cl <- sys.calls(); fs <- sys.frames()   # sys.source() (build_dataset_item) keeps the path in `file`
  for (i in rev(seq_along(cl))) if (identical(cl[[i]][[1]], quote(sys.source)) && is.character(fs[[i]]$file))
    return(normalizePath(fs[[i]]$file))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or source() the saved file.", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))      # "Siegel__2022_Appendix"
base      <- dirname(folder)
source_publication <- basename(folder)                     # species-key token = folder name
snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))

## 1. LOAD FROZEN SNAPSHOT (positional) -----------------------------
raw <- as.data.frame(readxl::read_excel(snapshot_file, sheet = "Sheet1", col_names = FALSE,
                                col_types = "text", .name_repair = "unique_quiet"),
                     stringsAsFactors = FALSE)
names(raw) <- c("label", "total", "rem", "nonrem")
raw$label <- trimws(raw$label)

## section blocks as printed: heading row, then "<n> species", then a header row, then data rows
sec_rows <- which(raw$label %in% c("Placentals", "Marsupials", "Monotremes"))
stopifnot(length(sec_rows) == 3L)
raw$section <- NA_character_
for (k in seq_along(sec_rows)) raw$section[sec_rows[k]:nrow(raw)] <- raw$label[sec_rows[k]]
printed_n <- stats::setNames(as.integer(sub(" species.*$", "", raw$label[sec_rows + 1L])), raw$label[sec_rows])
mammal_n  <- as.integer(sub(" species.*$", "", raw$label[grep("^Mammals$", raw$label) + 1L]))

num <- function(x) suppressWarnings(as.numeric(gsub(",", "", trimws(x), fixed = TRUE)))
dat <- raw[!is.na(raw$section) & !is.na(num(raw$total)), ]
dat$print_order <- stats::ave(seq_len(nrow(dat)), dat$section, FUN = seq_along)
stopifnot(nrow(dat) == 52L)

## 2. TABLE CHECKS (HOWTO 7a): total = REM + non-REM; block counts vs printed headings --
tc_sum <- data.frame(
  check_id = paste0("sum_", dat$section, "_", dat$print_order),
  basis = paste0(dat$label, ": Total sleep (h) vs REM time (h) + Non-REM time (h)"),
  observed = num(dat$rem) + num(dat$nonrem), printed = num(dat$total),
  stringsAsFactors = FALSE)
tc_sum$difference <- round(tc_sum$observed - tc_sum$printed, 6)
tc_sum$tolerance  <- 0.1     # two cells at 0.1 h precision, half a unit each
tc_sum$note <- "printed to 0.1 h; tolerance = 2 x 0.05 h"
counts <- c(table(factor(dat$section, levels = names(printed_n))))
tc_n <- data.frame(check_id = c(paste0("count_", names(printed_n)), "count_Mammals"),
                   basis = c(paste0(names(printed_n), " rows vs printed '<n> species'"),
                             "all mammal rows vs printed 'Mammals 52 species'"),
                   observed = c(counts, sum(counts)), printed = c(printed_n, mammal_n),
                   stringsAsFactors = FALSE)
tc_n$difference <- tc_n$observed - tc_n$printed; tc_n$tolerance <- 0
tc_n$note <- c("", "", "", paste0("printed 52 counts the Phalanger row twice (Placentals and Marsupials); ",
                                   length(unique(dat$label)), " distinct printed names - see errata E001"))
table_checks <- rbind(tc_sum, tc_n)
table_checks$status <- ifelse(is.na(table_checks$difference), "not_evaluable",
                       ifelse(abs(table_checks$difference) <= table_checks$tolerance + 1e-9, "pass", "mismatch"))
if (any(table_checks$status == "mismatch")) warning("Printed arithmetic mismatches retained; see table_checks.")

## 3. SPECIES HARMONISATION via the collection key (_keys/General) ---
key <- utils::read.csv(file.path(base, "_keys", "General", "species_key.csv"),
                stringsAsFactors = FALSE, check.names = FALSE, encoding = "UTF-8")
key <- key[trimws(key$source_publication) == source_publication, , drop = FALSE]
if (nrow(key) == 0L) stop("No rows for '", source_publication, "' in _keys/General/species_key.csv")
lk <- stats::setNames(key$accepted_name, tolower(trimws(key$variant_name)))
dat$species_harmonised <- unname(lk[tolower(dat$label)])
if (anyNA(dat$species_harmonised))
  stop("Unkeyed printed name: ", paste(unique(dat$label[is.na(dat$species_harmonised)]), collapse = ", "))

## 4. ANALYSIS TABLE (hours as printed; no unit conversion) ---------
final.dataframe <- data.frame(
  species_as_published = dat$label,
  species_harmonised   = dat$species_harmonised,
  taxon_group_as_published = dat$section,
  print_order          = dat$print_order,
  total_sleep_h        = num(dat$total),
  rem_sleep_h          = num(dat$rem),
  nonrem_sleep_h       = num(dat$nonrem),
  section_ref_keys     = "2; 3; 4; 5",          # printed "52 species2-5" (Mammals heading)
  duplicate_printed_row = dat$label == "Phalanger" & dat$section == "Placentals",
  source               = item_name,
  stringsAsFactors = FALSE)

## 5. WRITE CSV + PUBLIC TSV (registry is the naming authority) ------
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE,
          na = "", fileEncoding = "UTF-8")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
            sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows -> ", item_encoded, ".tsv; table checks: ",
        paste(names(table(table_checks$status)), table(table_checks$status), sep = "=", collapse = ", "))
