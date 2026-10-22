## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database -- reference key table
## =============================================================================
##
## Input:
##   reference_tables/Myhrvold_etal_2015_cell_references_partNNN.csv   (built by Myhrvold_etal_2015_cell_references.R)
##   Supplemental_Materials/Supplemental_Table_1_Database_Literature_Cited.pdf   full citations (Chicago style)
##   Supplemental_Materials/Supplemental_Table_2_Reference_Counts.csv            declared record counts
##   Data_Files/Amniote_Sparse_Table_Aug_2015.csv                                 raw records, `dataset` = source
## Output:
##   reference_tables/Myhrvold_etal_2015_references.csv                 one row per distinct reference key
##   reference_tables/Myhrvold_etal_2015_references_table2_mismatches.csv
##   reference_tables/Myhrvold_etal_2015_references_citation_candidates.csv  (ambiguous PDF matches)
##   + *_definitions.csv for each
##
## Reference key = ref_key_norm of cell_references (printed key with the "BC <class> - " prefix
## removed), the form Supplemental Table 2 uses. Printed variants are listed per row.
##
## Table 2 reconciliation: the counting rule is chosen EMPIRICALLY -- several rules are
## computed and the one reproducing most Table 2 rows exactly is reported as the rule;
## agreement is never forced and every mismatch is written to the sidecar.
## =============================================================================

options(stringsAsFactors = FALSE, scipen = 999)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- sub("\\.R$","",basename(.sp)); setwd(folder)
base <- local({ d<-folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d<-dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })

ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "en_US.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "C.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) stop("No UTF-8 LC_CTYPE locale available.", call.=FALSE)

req <- c("readr", "dplyr", "pdftools")
miss <- req[!vapply(req, requireNamespace, logical(1), quietly=TRUE)]
if (length(miss)) stop("Install the required package(s): ", paste(miss, collapse=", "), call.=FALSE)
suppressPackageStartupMessages({ library(readr); library(dplyr) })

out_dir <- file.path(folder, "reference_tables")
f_cr <- sort(list.files(out_dir,
  pattern = "^Myhrvold_etal_2015_cell_references_part[0-9]+[.]csv$", full.names = TRUE))
if (!length(f_cr)) stop("Missing cell-reference parts; run Myhrvold_etal_2015_cell_references.R first.")
expected_parts <- sprintf("Myhrvold_etal_2015_cell_references_part%03d.csv", seq_along(f_cr))
if (!identical(basename(f_cr), expected_parts)) stop("Cell-reference part numbering has gaps.")
f_pdf <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_1_Database_Literature_Cited.pdf")
f_t2  <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_2_Reference_Counts.csv")
f_sp  <- file.path(folder, "Data_Files", "Amniote_Sparse_Table_Aug_2015.csv")
for (f in c(f_cr, f_pdf, f_t2, f_sp)) if (!file.exists(f)) stop("Missing input: ", f, call.=FALSE)

BC_RE <- "^BC (Birds|mammals|Reptiles) - "
PANTHERIA_KEYS <- c("Jones, K., Bielby, J., Cardillo, M. et al., 2009")
JONES2003_KEYS <- c("Jones et al., 2003", "Jones, et al. 2003")

## Declared spelling aliases between cell keys and Table 2 "Reference Name" (Table 2's file is
## latin1 and two names are mojibaked in the source itself). cell key -> Table 2 name.
T2_ALIASES <- c(
  "de Magalhaes and Costa, 2009"  = "de Magalh\u00dces and Costa, 2009",
  "Fradlova P., Frynta, D., 2010" = "Fr_dlov\u00e0, P., Frynta, D., 2010",
  "Greer_Greer, A.E., 1997"       = "Greer, A.E., 1997")
## cell key -> spelling used in the Sparse Table's `dataset` column where it differs
SPARSE_ALIASES <- c("Greer_Greer, A.E., 1997" = "Greer, A.E, 1997")

## ---- inputs -------------------------------------------------------------------------------
cr <- bind_rows(lapply(f_cr, function(f) read_csv(f, col_types=cols(.default="c"), progress=FALSE)))
if (!all(c("ref_key","ref_key_norm","derivation_role","row_id","trait") %in% names(cr))) stop("cell_references.csv lacks expected columns.")
cat("cell_references rows:", nrow(cr), "\n")

t2_raw <- iconv(readLines(f_t2, warn=FALSE, encoding="latin1"), "latin1", "UTF-8")
t2 <- read_csv(I(paste(t2_raw, collapse="\n")), col_types=cols(.default="c"), progress=FALSE)
t2 <- t2 %>% transmute(table2_name = `Reference Name`, n_records_declared = as.integer(`Number of records from each reference`)) %>%
  filter(!is.na(table2_name), nzchar(table2_name))
if (any(is.na(t2$n_records_declared))) stop("Non-integer record count in Table 2.")
cat("Table 2 names:", nrow(t2), "(incl. '(blank)')\n")

sp <- read_csv(f_sp, col_types=cols(.default="c"), progress=FALSE)
if (!"dataset" %in% names(sp)) stop("Sparse table lacks `dataset` column.")
sp_counts <- sp %>% mutate(norm = sub(BC_RE, "", sub("^BC (Birds|mammals|Reptiles) -$", "", dataset)),   # "BC Reptiles -" = blank key with trailing space trimmed
                           norm = ifelse(is.na(norm) | !nzchar(norm), "(blank)", norm)) %>%
  count(norm, name = "n_sparse_rows")
cat("Sparse table rows:", nrow(sp), "| distinct datasets (BC-stripped):", nrow(sp_counts), "\n")

## ---- one row per reference key ------------------------------------------------------------
refs <- cr %>% group_by(ref_key_norm) %>%
  summarise(printed_variants = paste(sort(unique(ref_key)), collapse = " | "),
            bc_prefixes = paste(sort(unique(bc_prefix[nzchar(bc_prefix)])), collapse = " | "),
            n_rows_all = n(),
            n_records_observed = sum(derivation_role != "selected_from_median_pool"),
            n_cells_observed = n_distinct(paste(row_id, trait)),
            n_species_rows_observed = n_distinct(row_id),
            n_mammalia_cells = n_distinct(paste(row_id, trait)[class == "Mammalia"]),
            .groups = "drop") %>%
  mutate(first_author = sub("^(.*?)(,| and | et al| & |$).*$", "\\1", ref_key_norm, perl=TRUE),
         year = { m <- regexpr("(1[6-9]|20)[0-9]{2}[a-z]?$", ref_key_norm, perl=TRUE); y <- rep(NA_character_, n()); y[m > 0] <- regmatches(ref_key_norm, m); y },
         first_author = ifelse(ref_key_norm == "(blank)", NA_character_, first_author),
         pantheria = ref_key_norm %in% PANTHERIA_KEYS, jones2003 = ref_key_norm %in% JONES2003_KEYS)
cat("distinct reference keys (BC-stripped):", nrow(refs), "| with a year:", sum(!is.na(refs$year)), "\n")

## ---- Table 2 join -------------------------------------------------------------------------
refs$table2_name <- ifelse(refs$ref_key_norm %in% t2$table2_name, refs$ref_key_norm,
                           unname(T2_ALIASES[refs$ref_key_norm]))
refs$sparse_name <- ifelse(refs$ref_key_norm %in% names(SPARSE_ALIASES), unname(SPARSE_ALIASES[refs$ref_key_norm]), refs$ref_key_norm)
refs <- refs %>% left_join(t2, by = "table2_name") %>% left_join(sp_counts, by = c("sparse_name" = "norm"))
sparse_not_in_cells <- setdiff(sp_counts$norm, refs$sparse_name)
cat("Sparse-table datasets with no parsed cell key:", length(sparse_not_in_cells), "| cell keys with no Sparse-table dataset:", sum(is.na(refs$n_sparse_rows)), "\n")
if (length(sparse_not_in_cells)) print(sparse_not_in_cells)
if (sum(is.na(refs$n_sparse_rows))) print(refs$ref_key_norm[is.na(refs$n_sparse_rows)])
n_in_t2 <- sum(!is.na(refs$table2_name))
t2_not_in_cells <- setdiff(t2$table2_name, refs$table2_name)
cat(sprintf("keys found in Table 2: %d of %d (via alias: %d) | Table 2 names with no parsed key: %d\n",
            n_in_t2, nrow(refs), sum(refs$ref_key_norm %in% names(T2_ALIASES)), length(t2_not_in_cells)))
if (length(t2_not_in_cells)) print(t2_not_in_cells)
if (any(is.na(refs$table2_name))) stop("Reference keys absent from Table 2 (add a declared alias or investigate): ",
                                        paste(refs$ref_key_norm[is.na(refs$table2_name)], collapse=" | "))

## Which counting rule reproduces Table 2? --------------------------------------------------
rules <- c(n_rows_all = "every cell_references row (selected keys counted again)",
           n_records_observed = "cell-level records: direct + mean members + median-pool members (selected keys not re-counted)",
           n_cells_observed = "distinct cells (row x trait) the key contributes to",
           n_species_rows_observed = "distinct Database rows (taxa) the key contributes to",
           n_sparse_rows = "rows of Amniote_Sparse_Table_Aug_2015.csv whose `dataset` is the key (BC prefix stripped)")
exact <- vapply(names(rules), function(v) sum(refs[[v]] == refs$n_records_declared, na.rm=TRUE), integer(1))
cat("\nTable 2 reproduction by counting rule (exact matches of", nrow(refs), "keys):\n")
for (v in names(rules)) cat(sprintf("  %-26s %4d  -- %s\n", v, exact[v], rules[v]))
best_rule <- names(which.max(exact))
cat(sprintf("best rule: %s (%d/%d = %.1f%% exact)\n", best_rule, exact[best_rule], nrow(refs), 100*exact[best_rule]/nrow(refs)))
refs$table2_match <- refs[[best_rule]] == refs$n_records_declared
refs$table2_match[is.na(refs$table2_match)] <- FALSE
refs$table2_match_rule <- best_rule
refs$table2_match_cell_records <- refs$n_records_observed == refs$n_records_declared
cat(sprintf("Table 2 rows reproduced exactly under best rule: %d | under cell-level records rule: %d | sum declared: %d | sum sparse rows: %d | sum cell-level records: %d\n",
            sum(refs$table2_match), sum(refs$table2_match_cell_records, na.rm=TRUE), sum(t2$n_records_declared), sum(sp_counts$n_sparse_rows), sum(refs$n_records_observed)))
mism <- refs %>% filter(!table2_match) %>%
  select(ref_key_norm, table2_name, n_records_declared, n_sparse_rows, n_records_observed, n_cells_observed, n_species_rows_observed) %>%
  mutate(ratio_sparse_to_declared = round(n_sparse_rows / n_records_declared, 3)) %>% arrange(desc(n_records_declared))
write_csv(mism, file.path(out_dir, "Myhrvold_etal_2015_references_table2_mismatches.csv"), na="")
cat("mismatch sidecar rows:", nrow(mism), "| top mismatches:\n"); print(head(as.data.frame(mism), 8), row.names=FALSE)

## ---- full citations from the Supplemental Table 1 PDF -------------------------------------
decode_placeholders <- function(x) {
  locs <- gregexpr("<U\\+[0-9A-Fa-f]+>", x)
  regmatches(x, locs) <- lapply(regmatches(x, locs), function(cc) vapply(cc, function(c1) intToUtf8(strtoi(sub("^<U\\+([0-9A-Fa-f]+)>$","\\1",c1),16L)), ""))
  x
}
pages <- pdftools::pdf_text(f_pdf)
lines <- decode_placeholders(unlist(strsplit(paste(pages, collapse="\n"), "\n")))
lines <- gsub("\u00a0", " ", lines)
starts <- which(!grepl("^\\s", lines) & nzchar(trimws(lines)))     # entries begin unindented; continuation lines are indented
if (trimws(lines[starts[1]]) != "References") stop("Unexpected first unindented line in PDF: ", lines[starts[1]])
ent_start <- starts[-1]; ent_end <- c(ent_start[-1] - 1L, length(lines))
entries <- mapply(function(a, b) trimws(gsub("\\s+", " ", paste(trimws(lines[a:b]), collapse=" "))), ent_start, ent_end, USE.NAMES=FALSE)
entries <- entries[nzchar(entries)]
## the PDF ends with the paper's parenthesised in-text citation list "(Acharya 1992; Ackermann et al. 2010; ...)"
## which is not a bibliography entry; drop entries that open with "(" and report how many
n_paren <- sum(startsWith(entries, "(")); cat("non-entry blocks opening with '(' dropped:", n_paren, "\n")
if (n_paren > 2L) stop("Unexpectedly many parenthesised blocks in the PDF text: ", n_paren)
entries <- entries[!startsWith(entries, "(")]
cat("\nPDF bibliography entries extracted:", length(entries), "\n")
if (length(entries) < 900L) stop("Too few bibliography entries extracted from the PDF: ", length(entries))

fold <- function(x) { y <- iconv(x, "UTF-8", "ASCII//TRANSLIT"); y[is.na(y)] <- x[is.na(y)]; gsub("[^a-z]", "", tolower(y)) }
extract <- function(x, re) { m <- regexpr(re, x, perl=TRUE); out <- rep(NA_character_, length(x)); out[m > 0] <- regmatches(x, m); out }
YR_RE <- "\\b((1[6-9]|20)[0-9]{2}[a-z]?)\\b"
pdf_year <- extract(entries, YR_RE)
ypos <- regexpr(YR_RE, entries, perl=TRUE)
pdf_auth <- ifelse(ypos > 0, substr(entries, 1, ypos - 1L), entries)
is_dash <- grepl("^\u2014{2,}", entries)                     # Chicago 3-em dash = same author(s) as preceding entry
for (i in which(is_dash)) { k <- i; while (k > 1 && is_dash[k]) k <- k - 1L; pdf_auth[i] <- pdf_auth[k] }
pdf_first <- fold(sub(",.*$", "", pdf_auth))
cat("entries with a 3-em-dash author (carried forward):", sum(is_dash), "| entries without a year:", sum(is.na(pdf_year)), "\n")

key_first <- fold(refs$first_author); key_rest <- fold(sub("^(.*?)(,| and | et al| & |$)", "", refs$ref_key_norm, perl=TRUE))
surname_match <- function(a, b) a == b | (nchar(a) >= 4 & nchar(b) >= 4 & (startsWith(a, b) | endsWith(a, b) | startsWith(b, a) | endsWith(b, a)))
cands <- lapply(seq_len(nrow(refs)), function(i) {
  if (is.na(refs$year[i]) || is.na(key_first[i]) || !nzchar(key_first[i])) return(integer(0))
  c1 <- which(!is.na(pdf_year) & pdf_year == refs$year[i] & surname_match(pdf_first, key_first[i]))
  if (length(c1) <= 1L) return(c1)
  ## disambiguate on further surnames named in the key
  toks <- regmatches(pdf_auth[c1], gregexpr("[A-Z][A-Za-z'\u00C0-\u024F-]{2,}", pdf_auth[c1]))
  sc <- vapply(toks, function(tk) sum(vapply(unique(fold(tk)), function(t) nchar(t) >= 4 && grepl(t, key_rest[i], fixed=TRUE), logical(1))), numeric(1))
  if (max(sc) > 0 && sum(sc == max(sc)) == 1L) c1[which.max(sc)] else c1
})
nc <- lengths(cands)
refs$full_citation <- ifelse(nc == 1L, entries[vapply(cands, function(x) if (length(x) == 1L) x else NA_integer_, integer(1))], NA_character_)
refs$citation_match_status <- case_when(nc == 1L ~ "matched_unique", nc > 1L ~ paste0("ambiguous_", nc, "_candidates"),
                                        is.na(refs$year) ~ "no_year_in_key", TRUE ~ "no_entry_found")
cat("citation match status:\n"); print(table(refs$citation_match_status))
cat(sprintf("citation match rate: %d of %d keys (%.1f%%) matched to a unique PDF entry; unmatched keys with >= 100 declared records:\n",
            sum(nc == 1L), nrow(refs), 100 * sum(nc == 1L) / nrow(refs)))
print(refs %>% filter(nc != 1L, n_records_declared >= 100) %>% select(ref_key_norm, n_records_declared, citation_match_status) %>% as.data.frame(), row.names=FALSE)
cand_tbl <- bind_rows(lapply(which(nc > 1L), function(i) tibble(ref_key_norm = refs$ref_key_norm[i], candidate_rank = seq_along(cands[[i]]), candidate_citation = entries[cands[[i]]])))
write_csv(cand_tbl, file.path(out_dir, "Myhrvold_etal_2015_references_citation_candidates.csv"), na="")

## ---- write --------------------------------------------------------------------------------
out <- refs %>% select(ref_key_norm, printed_variants, bc_prefixes, first_author, year, full_citation, citation_match_status,
                       n_records_observed, n_cells_observed, n_species_rows_observed, n_mammalia_cells, n_rows_all, n_sparse_rows,
                       table2_name, n_records_declared, table2_match, table2_match_rule, table2_match_cell_records,
                       pantheria_derived = pantheria, jones2003_derived = jones2003) %>%
  arrange(desc(n_records_declared), ref_key_norm)
f_out <- file.path(out_dir, "Myhrvold_etal_2015_references.csv")
write_csv(out, f_out, na="")
back <- read_csv(f_out, col_types=cols(.default="c"), progress=FALSE)
if (nrow(back) != nrow(out) || n_distinct(back$ref_key_norm) != nrow(back)) stop("Read-back failed or ref_key_norm not unique.")
if (!all(validUTF8(back$full_citation[!is.na(back$full_citation)]))) stop("Non-UTF-8 citation text written.")
if (any(grepl("<U\\+", back$full_citation))) stop("Undecoded unicode placeholder in written citations.")

def <- function(code, definition, role="info", note="", ref="Myhrvold_etal_2015_references")
  data.frame(Code=code, Definition=definition, Structure="", Measure="", Stat="", role=role, taxon="Aves; Reptilia; Mammalia", Reference=ref, Note=note, `Source Note`="", check.names=FALSE)
defs <- rbind(
  def("ref_key_norm", "distinct reference key as printed in the cell strings with the 'BC <class> - ' prefix removed (the form Supplemental Table 2 uses); '(blank)' = the compilers' empty citation; join key to cell_references.ref_key_norm"),
  def("printed_variants", "every printed form of the key seen in cells, '|'-separated (BC-prefixed and bare)"),
  def("bc_prefixes", "the 'BC Birds' / 'BC mammals' / 'BC Reptiles' prefixes observed for this key"),
  def("first_author", "text of the key before the first comma / ' and ' / ' et al' / ' & ' (used for PDF matching); not a curated surname"),
  def("year", "trailing 4-digit year (+ optional letter) of the key; empty when the key has none"),
  def("full_citation", "bibliography entry transcribed from Supplemental_Table_1_Database_Literature_Cited.pdf (pdftools text), matched on first-author surname + year, further surnames used to disambiguate; empty when no unique entry"),
  def("citation_match_status", "matched_unique | ambiguous_<n>_candidates (candidates in *_citation_candidates.csv) | no_entry_found | no_year_in_key"),
  def("n_records_observed", "cell-level record contributions: rows of cell_references with derivation_role direct, mean_of_member or median_of_member (selected_from_median_pool rows excluded because they duplicate a pool member)"),
  def("n_cells_observed", "distinct (row_id, trait) cells the key contributes to in any role"),
  def("n_species_rows_observed", "distinct Database rows (taxa) the key contributes to"),
  def("n_mammalia_cells", "n_cells_observed restricted to class Mammalia"),
  def("n_rows_all", "all cell_references rows for the key (selected keys counted again)"),
  def("n_sparse_rows", "rows of Data_Files/Amniote_Sparse_Table_Aug_2015.csv whose `dataset` equals the key (BC prefix stripped; one declared spelling alias, SPARSE_ALIASES) -- the raw-record level"),
  def("table2_name", "the Supplemental Table 2 'Reference Name' this key was matched to (identical to ref_key_norm except for the 3 declared spelling aliases)"),
  def("n_records_declared", "'Number of records from each reference' from Supplemental Table 2"),
  def("table2_match", "TRUE when the count under table2_match_rule equals n_records_declared; never forced"),
  def("table2_match_rule", "the counting rule that reproduced most Table 2 rows exactly (chosen empirically by the script and printed with all alternatives)"),
  def("table2_match_cell_records", "TRUE when n_records_observed (cell-level records) equals n_records_declared"),
  def("pantheria_derived", "key is the PanTHERIA entry (Jones, K., Bielby, J., Cardillo, M. et al., 2009)"),
  def("jones2003_derived", "key is Jones et al., 2003 or its variant 'Jones, et al. 2003'"),
  def("Method:table2", "Table 2 is latin1 with two mojibaked names; aliases declared in the script (T2_ALIASES). No counting rule reproduces Table 2 for the large references; the mismatch sidecar lists every row that does not reproduce", role="method"))
write_csv(defs, file.path(out_dir, "Myhrvold_etal_2015_references_definitions.csv"), na="")
defs_m <- rbind(
  def("ref_key_norm / table2_name / n_records_declared / n_sparse_rows / n_records_observed / n_cells_observed / n_species_rows_observed", "as in Myhrvold_etal_2015_references.csv; one row per key whose best-rule count != declared", ref="Myhrvold_etal_2015_references_table2_mismatches"),
  def("ratio_sparse_to_declared", "n_sparse_rows / n_records_declared (3 dp)", ref="Myhrvold_etal_2015_references_table2_mismatches"))
write_csv(defs_m, file.path(out_dir, "Myhrvold_etal_2015_references_table2_mismatches_definitions.csv"), na="")
defs_c <- rbind(
  def("ref_key_norm", "key with > 1 candidate PDF entry", ref="Myhrvold_etal_2015_references_citation_candidates"),
  def("candidate_rank", "1-based order of the candidate within the PDF", ref="Myhrvold_etal_2015_references_citation_candidates"),
  def("candidate_citation", "the candidate entry text", ref="Myhrvold_etal_2015_references_citation_candidates"))
write_csv(defs_c, file.path(out_dir, "Myhrvold_etal_2015_references_citation_candidates_definitions.csv"), na="")
cat(sprintf("\nWrote %s (%d rows)\n", f_out, nrow(out)))
