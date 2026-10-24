## =============================================================================
## Hayssen et al. (1993) -- registry rows for __ReadMe.xlsx: one row per order item
## (20 orders) + the Literature Cited item, built against the live Sheet1 header row.
## Writes Hayssen_etal_1993_registry_rows.xlsx (sheets 'Registry rows', 'HOW_TO_PASTE').
## The owner pastes the rows as VALUES into the first empty Sheet1 rows and runs
## _tools/file_list.R; the workbook itself is never edited by this script.
## Only columns A (citation), C (ISBN override), D (Item number) and the descriptive
## columns N onwards are filled; B and E-M are formula/generated and stay blank.
## Counts in the descriptive columns come from the built item CSVs (Hayssen_etal_1993_orders.R).
## =============================================================================
options(stringsAsFactors = FALSE)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) { p <- rstudioapi::getActiveDocumentContext()$path; if (nzchar(p)) return(normalizePath(p)) }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
folder <- dirname(.sp); setwd(folder)
root <- local({ d <- folder; while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d); if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx above ", folder, call. = FALSE); d })
for (p in c("readr", "dplyr", "stringr", "readxl", "writexl")) if (!requireNamespace(p, quietly = TRUE)) stop("Install package: ", p, call. = FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr); library(stringr) })
paper <- basename(folder)

## ---- live header and the existing Primates row (its descriptive text is the template) ---------------------
hdr <- names(readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1", n_max = 0))
## readxl returns the column-C header, whose cell preserves a trailing blank, as 'xml:space="preserve">DOI if ...'; the
## live header text is 'DOI if different from article or doi Alt ' (trailing blank kept in the output so a paste matches)
hdr <- ifelse(str_detect(hdr, '^xml:space="preserve">'), paste0(str_remove(hdr, '^xml:space="preserve">'), " "), hdr)
reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1"); names(reg) <- hdr
prim <- reg[which(reg$`Item name` == paste0(paper, "_Primates")), , drop = FALSE]
if (nrow(prim) != 1L) stop("Expected exactly one registry row with Item name ", paper, "_Primates; found ", nrow(prim), call. = FALSE)
cat("live header:", length(hdr), "columns; last =", hdr[length(hdr)], "\n")
col <- function(name) { i <- which(trimws(hdr) == trimws(name)); if (length(i) != 1L) stop("Header column not found exactly once: ", name, call. = FALSE); i }   # readxl trims trailing blanks in header names

## ---- the items and their counts from the built CSVs ------------------------------------------------------
contents <- read_csv(file.path(folder, paste0(paper, "_contents.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
CONTENTS_ORDER_TO_SECTION <- c(Macroscelidae = "Macroscelidea")                              # as in the accounts script
orders <- contents %>% filter(level == "Order") %>% mutate(pp = as.integer(printed_page)) %>% arrange(pp) %>% pull(name)
orders <- ifelse(orders %in% names(CONTENTS_ORDER_TO_SECTION), CONTENTS_ORDER_TO_SECTION[orders], orders)
slice_map <- read_csv(file.path(folder, paste0(paper, "_pdf_slices.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
read_bom <- function(f) read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
item_info <- bind_rows(lapply(orders, function(ord) {
  f <- file.path(folder, sprintf("%s_%s.csv", paper, ord)); if (!file.exists(f)) stop("Item CSV missing (run ", paper, "_orders.R first): ", f, call. = FALSE)
  d <- read_bom(f); dl <- d %>% filter(topic != "family_overview"); sm <- slice_map[slice_map$section == ord, ]
  tibble(item = ord, n_rows = nrow(d), n_data = nrow(dl), n_fam = n_distinct(d$family), n_sp = n_distinct(dl$species_printed), n_resolved = n_distinct(dl$species_msw05, na.rm = TRUE),
         topics = paste(unique(dl$topic), collapse = "; "), printed_pages = sm$printed_pages_detected, slice = sm$file,
         unusable = if (ord == "Rodentia") " Printed p. 634 (Muridae, LACTATION) has an unusable OCR layer and is NOT transcribed (kept verbatim in _accounts_unparsed.csv, kind page_ocr_unusable) -- transcribe by hand from the page image." else "")
}))
refs <- read_bom(file.path(folder, paste0(paper, "_LiteratureCited.csv")))
print(as.data.frame(item_info %>% select(item, n_fam, n_rows, n_data, n_sp, n_resolved)), row.names = FALSE)

## ---- rows ---------------------------------------------------------------------------------------------------
blank <- function() setNames(as.list(rep(NA_character_, length(hdr))), hdr)
trait_text <- function(topics) { t <- str_split(topics, "; ")[[1]]; paste(tolower(t[t != "family_overview"]), collapse = "; ") }
mk_order_row <- function(x) {
  r <- blank()
  r[[col("Citation (APA 7th-Annotated)")]]            <- prim$`Citation (APA 7th-Annotated)`
  r[[col("DOI if different from article or doi Alt ")]] <- prim[[col("DOI if different from article or doi Alt")]]
  r[[col("Item number")]]                              <- x$item
  r[[col("Item full original title")]]                 <- sprintf("Asdell's Patterns of Mammalian Reproduction -- Order %s species accounts (printed pp. %s), one row per printed data line", x$item, x$printed_pages)
  r[[col("Source format")]]                            <- sprintf("book PDF (2019 Cornell electronic reissue), OCR text layer; order slice %s (SHA-256 in %s_pdf_slices.csv); word boxes rebuilt into species / value / reference columns", x$slice, paper)
  r[[col("N.B.")]]                                     <- sprintf("%d families, %d rows = %d data lines + %d family_overview rows; %d distinct printed species, %d resolved through _keys/resolve_species.R. Every value carries its own Literature Cited number(s) (ref_numbers) joining %s_LiteratureCited on ref_number. Column definitions: reference_tables/%s_accounts_definitions.csv. Declared OCR repairs and page-image checks: %s.README.md.%s", x$n_fam, x$n_rows, x$n_data, x$n_rows - x$n_data, x$n_sp, x$n_resolved, paper, paper, paper, x$unusable)
  r[[col("Progress stage")]]                           <- sprintf("BUILT (R run %s; public TSV written by %s_orders.R)", format(Sys.Date()), paper)
  r[[col("Snapshot name if unchanged")]]               <- sprintf("pdf_by_order/%s (frozen order slice; the per-family tables reference_tables/%s_accounts_<Family>.csv are the transcription)", x$slice, paper)
  r[[col("Source URL link")]]                          <- prim$`Source URL link`
  r[[col("Flags possible")]]                           <- "OCR transcription of a scanned book: reference numbers mis-read by one confusable digit can pass the bibliography guard (see _accounts_ref_suspects.csv); population_status is a keyword heuristic; species_msw05 blank where the species key has no entry"
  r[[col("Topic")]]                                    <- prim$Topic
  r[[col("Taxon")]]                                    <- sprintf("Mammalia: %s (%d families, %d printed species)", x$item, x$n_fam, x$n_sp)
  r[[col("Main Trait(s)")]]                            <- trait_text(x$topics)
  r[[col("Material type (e.g. histological, MRI)")]]  <- prim$`Material type (e.g. histological, MRI)`
  r[[col("Method")]]                                   <- prim$Method
  r[[col("Measure type")]]                             <- "mass (g, kg, mg); length (mm, cm); time (d, wk, mo, yr, h); count; text (seasonality)"
  r[[col("Data role (primary/secondary/both)")]]       <- "secondary"
  r[[col("Source (if secondary)")]]                    <- sprintf("per-value numbered citations into the book's Literature Cited (%s_LiteratureCited item, %d entries)", paper, nrow(refs))
  r[[col("recommendation")]]                           <- "Root source under PanTHERIA / AnAge / Ernest 2003: use for value-level provenance; resolve the cited primary works before merging as primary"
  r[[col("Human visual check of snapshot")]]           <- "Page images rendered and compared for every declared repair site and for spot-checked pages (see README 'Species accounts'); not every page was compared line by line"
  r
}
rows <- lapply(seq_len(nrow(item_info)), function(k) mk_order_row(item_info[k, ]))
lit <- blank()
lit[[col("Citation (APA 7th-Annotated)")]]            <- prim$`Citation (APA 7th-Annotated)`
lit[[col("DOI if different from article or doi Alt ")]] <- prim[[col("DOI if different from article or doi Alt")]]
lit[[col("Item number")]]                              <- "LiteratureCited"
lit[[col("Item full original title")]]                 <- "Asdell's Patterns of Mammalian Reproduction -- Literature Cited (printed pp. 705-990), one row per reference number"
lit[[col("Source format")]]                            <- sprintf("book PDF, OCR text layer; slice %s; two-column pages read per column, sequence-constrained entry grammar", slice_map$file[slice_map$section == "LiteratureCited"])
lit[[col("N.B.")]]                                     <- sprintf("%d rows (bare numbers 1-12139 with 3 printed gaps, letter- and subscript-suffixed inserts). Join target of ref_numbers in every %s_<Order> item (split ref_numbers on ';'). Definitions: reference_tables/%s_references_definitions.csv.", nrow(refs), paper, paper)
lit[[col("Progress stage")]]                           <- sprintf("BUILT (R run %s; public TSV written by %s_orders.R)", format(Sys.Date()), paper)
lit[[col("Snapshot name if unchanged")]]               <- sprintf("pdf_by_order/%s (frozen slice)", slice_map$file[slice_map$section == "LiteratureCited"])
lit[[col("Source URL link")]]                          <- prim$`Source URL link`
lit[[col("Topic")]]                                    <- "bibliography"
lit[[col("Taxon")]]                                    <- "Mammalia (all orders)"
lit[[col("Main Trait(s)")]]                            <- "none (reference list: number, authors, year, title, journal/publisher, volume, pages)"
lit[[col("Method")]]                                   <- "OCR transcription with sequence-constrained parsing; 18 damaged number tokens resolved by position"
lit[[col("Data role (primary/secondary/both)")]]       <- "secondary"
lit[[col("Source (if secondary)")]]                    <- "the book's own bibliography"
lit[[col("recommendation")]]                           <- "Lookup table for the per-order items; roadmap for primary ingestion"
lit[[col("Human visual check of snapshot")]]           <- "Page images checked for the 3 declared headers and the 18 damaged number tokens (see README 'Reference table')"
rows[[length(rows) + 1]] <- lit
out <- bind_rows(lapply(rows, as_tibble))
out <- out[, hdr]

## the existing Primates row: the same descriptive text is proposed as an UPDATE (marked in a side column of the HOW_TO sheet)
how <- data.frame(Step = c("Paste", "Primates", "Generate", "Verify", "Build", "Blank columns"),
  Instruction = c(sprintf("Copy the rows of 'Registry rows' (row 2 onwards, all %d columns) as VALUES ONLY into the first empty rows of Sheet1 in __ReadMe.xlsx. Column B and E-M are intentionally blank (formulas / generated).", length(hdr)),
                  sprintf("The row with Item number 'Primates' duplicates the EXISTING Primates row: do not paste it as a new row; copy its descriptive cells (N onwards) over the existing row instead (its Progress stage changes from IN PROGRESS to BUILT)."),
                  "Run _tools/file_list.R so that columns K/L (Item encoded, public TSV match) refresh.",
                  "Check that Item name = Hayssen_etal_1993_<Order> and Item encoded = ISBN%3A9780801417535_<Order> with no trailing underscore for every new row (the C column carries the ISBN override, as on the Primates row).",
                  sprintf("Re-run %s_orders.R: it writes the public TSV of every item whose Item name it finds in the registry (items not yet registered are reported and skipped).", paper),
                  "Never type into E-M; never edit the workbook with a script."))
## writexl rather than openxlsx: the installed openxlsx (4.2.9) writes a dangling drawing relationship that Excel
## tolerates but other readers (openpyxl) refuse; the blank generated columns are documented in HOW_TO_PASTE instead of greyed
f_out <- file.path(folder, paste0(paper, "_registry_rows.xlsx"))
writexl::write_xlsx(list(`Registry rows` = out, HOW_TO_PASTE = how), f_out)
cat("written:", f_out, "(", nrow(out), "rows x", ncol(out), "columns )\n")
