## =============================================================================
## Hayssen et al. (1993), Asdell's Patterns of Mammalian Reproduction
## -- step 3 of the transcription plan: one dataset item per ORDER (and one for the
##    Literature Cited), each registered in __ReadMe.xlsx and published as a TSV.
## =============================================================================
## Inputs (this folder; read only)
##   Hayssen_etal_1993_contents.csv                        orders and their families (TOC)
##   Hayssen_etal_1993_pdf_slices.csv                      slice map (the frozen source per order)
##   reference_tables/Hayssen_etal_1993_accounts_<Family>.csv   built by Hayssen_etal_1993_accounts.R
##   reference_tables/Hayssen_etal_1993_references.csv          built by Hayssen_etal_1993_references.R
## Outputs
##   Hayssen_etal_1993_<Order>.csv          analysis CSV = the order's family tables bound, in the book's order
##   Hayssen_etal_1993_LiteratureCited.csv  the references table as an item (the join target of ref_numbers)
##   __Public/comparative-data/<Item encoded>.tsv   one per item, Item encoded looked up by Item name
##
## Item names are Hayssen_etal_1993_<Order> (Item number = the order as the slice files name it, e.g.
## 'Primates', 'Macroscelidea') and Hayssen_etal_1993_LiteratureCited. All items of this folder are built
## by this one script because they are 21 identical bind-and-publish steps over the accounts tables; the
## item name is therefore derived from the contents table, not from the script's file name.
## Conventions (evom1-refs-conventions): an input problem stops; every count is printed.
## =============================================================================

options(scipen = 999, stringsAsFactors = FALSE, width = 200)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)
root <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", folder, call. = FALSE)
  d
})
source(file.path(root, "_tools", "dataset_builder", "load_dataset_builder.R"))
for (p in c("readr", "dplyr", "stringr", "readxl")) if (!requireNamespace(p, quietly = TRUE)) stop("Install package: ", p, call. = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr) })

paper   <- basename(folder)                      # "Hayssen_etal_1993"
out_dir <- file.path(folder, "reference_tables")

## ---- the orders and their families (same derivation as the accounts script) --------------------
contents <- read_csv(file.path(folder, paste0(paper, "_contents.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
CONTENTS_OCR_FIX <- c(Omithorhynchidae = "Ornithorhynchidae", Qctodontidae = "Octodontidae")   # as in the accounts script
CONTENTS_ORDER_TO_SECTION <- c(Macroscelidae = "Macroscelidea")                              # as in the accounts script
ord_rows <- contents %>% filter(level == "Order") %>% mutate(pp = as.integer(printed_page)) %>% arrange(pp) %>%
  mutate(name = ifelse(name %in% names(CONTENTS_ORDER_TO_SECTION), CONTENTS_ORDER_TO_SECTION[name], name))
fam_rows <- contents %>% filter(level == "Family") %>% mutate(pp = as.integer(printed_page)) %>% arrange(pp) %>%
  mutate(name = ifelse(name %in% names(CONTENTS_OCR_FIX), CONTENTS_OCR_FIX[name], name),
         order = vapply(pp, function(p) ord_rows$name[max(which(ord_rows$pp <= p))], character(1)))
slice_map <- read_csv(file.path(folder, paste0(paper, "_pdf_slices.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
if (!all(ord_rows$name %in% slice_map$section)) stop("Orders without a slice: ", paste(setdiff(ord_rows$name, slice_map$section), collapse = ","), call. = FALSE)
cat("orders:", nrow(ord_rows), " families:", nrow(fam_rows), "\n")

## ---- registry ----------------------------------------------------------------------------------------
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded_of <- function(item_name) {
  e <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
  if (length(e) != 1L || is.na(e) || !nzchar(e) || grepl("_$", e)) stop("No usable 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- register the item first (see ", paper, "_registry_rows.xlsx)", call. = FALSE)
  e
}
tsv_dir <- file.path(root, "__Public", "comparative-data")
if (!dir.exists(tsv_dir)) stop("Public TSV folder missing: ", tsv_dir, call. = FALSE)
readme_file      <- file.path(folder, paste0(paper, ".README.md"))
definitions_file <- file.path(out_dir, paste0(paper, "_accounts_definitions.csv"))
for (f in c(readme_file, definitions_file)) if (!file.exists(f)) stop("Missing: ", f, call. = FALSE)

## items that are registered now; the others are reported and skipped (the owner pastes their rows, then re-runs)
items <- c(paste0(paper, "_", ord_rows$name), paste0(paper, "_LiteratureCited"))
registered <- items[nfc(items) %in% nfc(filecodes$`Item name`)]
cat("items:", length(items), " registered in __ReadMe.xlsx:", length(registered), "\n")
if (length(setdiff(items, registered))) cat("  NOT registered (skipped):", paste(sub(paste0("^", paper, "_"), "", setdiff(items, registered)), collapse = ", "), "\n")   ## CONVENTION-OK: the missing registry row is reported, not invented

## ---- one item per order ---------------------------------------------------------------------------------
read_bom <- function(f) read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
write_bom_csv <- function(x, path) {
  write_excel_csv(x, path, na = "")
  rb <- read_bom(path); if (nrow(rb) != nrow(x)) stop("Row count changed on write: ", path, call. = FALSE)
}
built <- list(); table_checks <- list()
for (ord in ord_rows$name) {
  item_name <- paste0(paper, "_", ord)
  fams <- fam_rows$name[fam_rows$order == ord]
  files <- file.path(out_dir, sprintf("%s_accounts_%s.csv", paper, fams))
  if (!all(file.exists(files))) stop("Accounts table(s) missing for ", ord, ": ", paste(fams[!file.exists(files)], collapse = ","), " -- run ", paper, "_accounts.R first", call. = FALSE)
  final.dataframe <- bind_rows(lapply(files, read_bom))
  if (!all(final.dataframe$order == ord)) stop("Rows of another order in the ", ord, " tables", call. = FALSE)
  if (!setequal(unique(final.dataframe$family), fams)) stop("Family set differs from the contents table for ", ord, call. = FALSE)
  n_dl <- sum(final.dataframe$topic != "family_overview")
  cat(sprintf("%-15s %2d families  %6d rows (%6d data lines, %d species printed)\n", ord, length(fams), nrow(final.dataframe), n_dl, n_distinct(final.dataframe$species_printed, na.rm = TRUE)))
  ## table check (HOWTO 7a): the item's row count equals the sum of its family tables (nothing dropped or duplicated)
  n_expected <- sum(vapply(files, function(f) nrow(read_bom(f)), integer(1)))
  table_checks[[ord]] <- data.frame(check_id = paste0(ord, ":rows_equal_sum_of_family_tables"), basis = "sum of nrow over the order's _accounts_<Family>.csv",
                                    observed = nrow(final.dataframe), printed = n_expected, difference = nrow(final.dataframe) - n_expected, tolerance = 0,
                                    status = ifelse(nrow(final.dataframe) == n_expected, "pass", "mismatch"), note = "")
  csv_path <- file.path(folder, paste0(item_name, ".csv"))
  write_bom_csv(final.dataframe, csv_path)
  if (!item_name %in% registered) next
  item_encoded <- item_encoded_of(item_name)
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", quote = TRUE, fileEncoding = "UTF-8")
  frozen <- file.path(folder, "pdf_by_order", slice_map$file[slice_map$section == ord])
  checks <- validate_dataset_item(csv_file = csv_path, tsv_file = tsv_path, readme_file = readme_file, definitions_file = definitions_file,
                                  frozen_source_file = frozen, registry = filecodes, item_name = item_name, item_encoded = item_encoded)
  if (any(checks$status == "FAIL")) { print(checks, row.names = FALSE); stop("validation failed for ", item_name, call. = FALSE) }
  built[[item_name]] <- tibble(item_name, item_encoded, tsv = basename(tsv_path), rows = nrow(final.dataframe), data_lines = n_dl)
}

## ---- the Literature Cited as an item ------------------------------------------------------------------------
item_name <- paste0(paper, "_LiteratureCited")
refs <- read_bom(file.path(out_dir, paste0(paper, "_references.csv")))
if (anyDuplicated(refs$ref_number)) stop("references.csv ref_number not unique", call. = FALSE)
cat(sprintf("%-15s %6d reference rows\n", "LiteratureCited", nrow(refs)))
csv_path <- file.path(folder, paste0(item_name, ".csv")); write_bom_csv(refs, csv_path)
if (item_name %in% registered) {
  item_encoded <- item_encoded_of(item_name)
  tsv_path <- file.path(tsv_dir, paste0(item_encoded, ".tsv"))
  write.table(refs, tsv_path, sep = "\t", row.names = FALSE, na = "", quote = TRUE, fileEncoding = "UTF-8")
  checks <- validate_dataset_item(csv_file = csv_path, tsv_file = tsv_path, readme_file = readme_file,
                                  definitions_file = file.path(out_dir, paste0(paper, "_references_definitions.csv")),
                                  frozen_source_file = file.path(folder, "pdf_by_order", slice_map$file[slice_map$section == "LiteratureCited"]),
                                  registry = filecodes, item_name = item_name, item_encoded = item_encoded)
  if (any(checks$status == "FAIL")) { print(checks, row.names = FALSE); stop("validation failed for ", item_name, call. = FALSE) }
  built[[item_name]] <- tibble(item_name, item_encoded, tsv = basename(tsv_path), rows = nrow(refs), data_lines = NA_integer_)
}
table_checks <- bind_rows(table_checks)
cat("\nTable checks (rows per item = sum of its family tables):\n"); print(table_checks[, c("check_id", "observed", "printed", "difference", "status")], row.names = FALSE)
if (any(table_checks$status != "pass")) stop("Row-count table check failed for: ", paste(table_checks$check_id[table_checks$status != "pass"], collapse = ", "), call. = FALSE)
built <- bind_rows(built)
cat("\nItems built and validated (public TSV written):", nrow(built), "of", length(items), "\n")
if (nrow(built)) print(as.data.frame(built), row.names = FALSE)
cat("DONE\n")
