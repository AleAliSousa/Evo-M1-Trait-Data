## =============================================================================
## Myhrvold et al. (2015), Amniote Life-History Database (Aug 2015 release)
## Per-cell citation strings -> one row per (cell x contributing reference)
## =============================================================================
##
## Input (frozen, never edited):
##   Data_Files/Amniote_Database_Aug_2015.csv              values, -999 = missing
##   Data_Files/Amniote_Database_References_Aug_2015.csv   same shape, per-cell citation string
##   Supplemental_Materials/Supplemental_Table_2_Reference_Counts.csv   key lexicon seed
## Output:
##   reference_tables/Myhrvold_etal_2015_cell_references_partNNN.csv
##   reference_tables/Myhrvold_etal_2015_cell_references_unparsed.csv   (parse failures, may be empty)
##   reference_tables/Myhrvold_etal_2015_mammal_independence_by_trait.csv
##   reference_tables/*_definitions.csv for each of the above
##
## Grammar (EBNF; documented in the README):
##   cell             ::= "-999" | "" | expr
##   expr             ::= single | mean2 | median_sel | mean_median_sel
##   single           ::= key
##   mean2            ::= "mean of " key " and " key
##   median_sel       ::= key " from median of " N "(" pool ")"
##   mean_median_sel  ::= "mean of " key " & " key " from median of " N "(" pool ")"
##   pool             ::= key { ", " key }                      -- exactly N keys
##   N                ::= [0-9]+
##   key              ::= [ bc_prefix ] ( lexkey | empty )
##   empty            ::= ""      -- the compilers' blank record; emitted as ref_key_norm "(blank)"
##   bc_prefix        ::= "BC " ( "Birds" | "mammals" | "Reptiles" ) " - "
##   lexkey           ::= a string of the key lexicon (Supplemental Table 2 "Reference Name"
##                        values, plus every string that occurs as an ENTIRE cell with no
##                        "mean of"/"from median of" construct), matched longest-first with
##                        backtracking; a key is accepted only when the character(s) that
##                        follow it are what the enclosing rule expects.
## Keys contain commas, " and " and parentheses ("Burghardt and Rand (Eds.), 1982"), so the
## pool cannot be split on ", " -- the lexicon + exact pool count N drive the tokenizer.
## One cell ("mean of  and") ends in " and" with the separator's trailing space lost; a separator
## is therefore also accepted in its right-trimmed form at end-of-string, followed by `empty`.
## A cell is a parse failure when no derivation consumes the whole string.
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

## ---- locale (see DeCasien_Higham_2019_referencesbraindata.R for the rationale) -------------
ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "en_US.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) ctype_ok <- tryCatch({ Sys.setlocale("LC_CTYPE", "C.UTF-8"); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) }, error=function(e) FALSE)
if (!ctype_ok) stop("No UTF-8 LC_CTYPE locale available; non-ASCII text would be corrupted on write.", call.=FALSE)

## ---- packages -----------------------------------------------------------------------------
req <- c("readr", "dplyr")
miss <- req[!vapply(req, requireNamespace, logical(1), quietly=TRUE)]
if (length(miss)) stop("Install the required package(s): ", paste(miss, collapse=", "), call.=FALSE)
suppressPackageStartupMessages({ library(readr); library(dplyr) })

## ---- paths & constants --------------------------------------------------------------------
f_vals <- file.path(folder, "Data_Files", "Amniote_Database_Aug_2015.csv")
f_refs <- file.path(folder, "Data_Files", "Amniote_Database_References_Aug_2015.csv")
f_t2   <- file.path(folder, "Supplemental_Materials", "Supplemental_Table_2_Reference_Counts.csv")
out_dir <- file.path(folder, "reference_tables")
for (f in c(f_vals, f_refs, f_t2)) if (!file.exists(f)) stop("Missing input: ", f, call.=FALSE)
if (!dir.exists(out_dir)) dir.create(out_dir)

TAX_COLS <- c("class","order","family","genus","species","subspecies","common_name")
N_ROWS_EXPECTED <- 21322L; N_COLS_EXPECTED <- 36L; N_TRAITS_EXPECTED <- 29L
SENTINEL <- "-999"
## CONVENTION-OK: the unparsed-fraction threshold below is a declared tolerance, not a silent
## drop -- every unparsed string is written to the sidecar and the count is printed; the run
## aborts when more than 0.5% of non-sentinel reference cells fail the grammar, because at
## that level the lexicon (not the data) is the likely problem.
UNPARSED_MAX_FRACTION <- 0.005

## PanTHERIA / Jones 2003 key spellings (BC-prefix-stripped form). Every lexicon key that
## contains "Jones" is printed below so an unlisted variant cannot hide; the script stops if a
## key matching the loose patterns is not in these declared sets.
## IDENTITY NOTE (verified by Myhrvold_etal_2015_references.R against Supplemental Table 1):
## "Jones et al., 2003" resolves to Jones, M., C.R. Dickman & M. Archer (2003) "Predators with
## Pouches: The Biology of Carnivorous Marsupials" -- the cells citing it are marsupials (623 of 628; 5 Carnivora; no bats) -- and
## NOT to K.E. Jones et al. (2003, bat life history). It is therefore flagged (jones2003_derived)
## but NOT counted as PanTHERIA-circular; the independence table carries the inclusive variant
## in separate *_incl_jones2003 columns.
PANTHERIA_KEYS <- c("Jones, K., Bielby, J., Cardillo, M. et al., 2009")
JONES2003_KEYS <- c("Jones et al., 2003", "Jones, et al. 2003")

## ---- read ---------------------------------------------------------------------------------
vals <- read_csv(f_vals, col_types=cols(.default="c"), na=character(), progress=FALSE)
refs <- read_csv(f_refs, col_types=cols(.default="c"), na=character(), progress=FALSE)
if (nrow(vals) != N_ROWS_EXPECTED || ncol(vals) != N_COLS_EXPECTED) stop("Unexpected Database shape: ", nrow(vals), " x ", ncol(vals))
if (!identical(dim(vals), dim(refs))) stop("Database and References files differ in shape.")
if (!identical(names(vals), names(refs))) stop("Database and References files differ in column names.")
if (!identical(as.matrix(vals[TAX_COLS]), as.matrix(refs[TAX_COLS]))) stop("Database and References files are not row-for-row taxon-aligned.")
traits <- setdiff(names(vals), TAX_COLS)
if (length(traits) != N_TRAITS_EXPECTED) stop("Expected ", N_TRAITS_EXPECTED, " trait columns, found ", length(traits))

## Table 2 is latin1-encoded (two names carry mojibake in the source itself); read as such.
t2_raw <- readLines(f_t2, warn=FALSE, encoding="latin1")
t2_raw <- iconv(t2_raw, "latin1", "UTF-8")
t2 <- read_csv(I(paste(t2_raw, collapse="\n")), col_types=cols(.default="c"), progress=FALSE)
if (!identical(names(t2)[1], "Reference Name")) stop("Supplemental Table 2: unexpected header: ", names(t2)[1])
t2_names <- t2[["Reference Name"]]
t2_names <- t2_names[!is.na(t2_names) & nzchar(t2_names) & t2_names != "(blank)"]

## ---- long table of cells ------------------------------------------------------------------
cells <- bind_rows(lapply(seq_along(traits), function(j) {
  tr <- traits[j]
  tibble(row_id = seq_len(nrow(vals)), trait = tr, value = vals[[tr]], ref_string = refs[[tr]])
}))
cells <- bind_cols(vals[cells$row_id, TAX_COLS[1:6]], cells)
n_cells <- nrow(cells)
if (n_cells != N_ROWS_EXPECTED * N_TRAITS_EXPECTED) stop("Cell enumeration mismatch.")

has_value <- cells$value != SENTINEL
has_ref   <- cells$ref_string != SENTINEL & nzchar(cells$ref_string)
is_blank_ref <- cells$ref_string == ""           # empty reference cell
cat(sprintf("cells: %d | with value: %d | with non-sentinel reference: %d\n", n_cells, sum(has_value), sum(has_ref)))

## Alignment assertions -------------------------------------------------------------------
n_ref_no_value <- sum(has_ref & !has_value)
n_value_no_ref <- sum(has_value & !has_ref)
n_value_blank_ref <- sum(has_value & is_blank_ref)
cat(sprintf("reference without value: %d | value without reference: %d (of which empty-string reference cells: %d)\n",
            n_ref_no_value, n_value_no_ref, n_value_blank_ref))
if (n_ref_no_value != 0) stop("Reference cells present where the value is -999: ", n_ref_no_value)
## CONVENTION-OK: the only value-without-reference cells are EMPTY reference cells (not -999),
## i.e. the compilers left the citation blank; Supplemental Table 2 itself declares a
## "(blank)" reference, so these are the source's own blanks and are carried as ref_key
## "(blank)" rather than treated as a build error. Anything else is fatal.
if (n_value_no_ref != n_value_blank_ref) stop("Value cells whose reference is neither a citation nor blank: ", n_value_no_ref - n_value_blank_ref)

## ---- key lexicon --------------------------------------------------------------------------
BC_RE <- "^BC (Birds|mammals|Reptiles) - "
u_strings <- unique(cells$ref_string[has_ref])
plain <- u_strings[!grepl("^mean of ", u_strings) & !grepl(" from median of [0-9]+\\(", u_strings)]
plain_norm <- sub(BC_RE, "", plain)
lexicon <- sort(unique(c(t2_names, plain_norm)))
lexicon <- lexicon[order(-nchar(lexicon))]              # longest first
cat(sprintf("unique reference strings: %d | plain (single-key) strings: %d | lexicon keys: %d (Table 2: %d)\n",
            length(u_strings), length(plain), length(lexicon), length(t2_names)))

## ---- parser -------------------------------------------------------------------------------
## match_key(s, pos): keys (with optional BC prefix) that match s at pos; returns a data.frame
## of (text, bc_prefix, norm, end) ordered longest-first.
match_key <- function(s, pos) {
  rest <- substr(s, pos, nchar(s))
  bc <- regmatches(rest, regexpr(BC_RE, rest))
  pre <- if (length(bc)) bc else ""
  body <- substr(rest, nchar(pre) + 1L, nchar(rest))
  hit <- lexicon[startsWith(body, lexicon)]
  ## the empty key (compilers' blank record) is always a last-resort candidate
  data.frame(text = paste0(pre, c(hit, "")), bc_prefix = pre, norm = c(hit, "(blank)"),
             end = pos + nchar(pre) + c(nchar(hit), 0L) - 1L)
}

## parse_seq(s, pos, seps, closer): parse a sequence of keys separated by the literal strings
## in `seps` (tried in order), terminated by `closer` (a literal, or "" for end-of-string);
## n_expect (NA = any count >= 1). Returns list(keys=data.frame, end=int) or NULL.
parse_seq <- function(s, pos, sep, closer, n_expect) {
  cand <- match_key(s, pos)
  if (is.null(cand)) return(NULL)
  for (i in seq_len(nrow(cand))) {
    e <- cand$end[i]
    after <- substr(s, e + 1L, nchar(s))
    this <- cand[i, c("text","bc_prefix","norm"), drop=FALSE]
    if (is.na(n_expect) || n_expect == 1L) {
      if (nzchar(closer) && startsWith(after, closer)) return(list(keys=this, end=e + nchar(closer)))
      if (!nzchar(closer) && !nzchar(after)) return(list(keys=this, end=e))
    }
    if (is.na(n_expect) || n_expect > 1L) {
      sep_len <- if (startsWith(after, sep)) nchar(sep)
                 else if (!nzchar(closer) && identical(after, sub(" $", "", sep))) nchar(after)   # truncated trailing separator
                 else NA_integer_
      if (!is.na(sep_len)) {
        sub_res <- parse_seq(s, e + sep_len + 1L, sep, closer, if (is.na(n_expect)) NA else n_expect - 1L)
        if (!is.null(sub_res)) return(list(keys=rbind(this, sub_res$keys), end=sub_res$end))
      }
    }
  }
  NULL
}

parse_cell <- function(s) {
  ## returns data.frame(ref_key, bc_prefix, ref_key_norm, derivation_role, member_position, n_pool, cell_form) or NULL
  if (grepl(" from median of [0-9]+\\(", s)) {
    m <- regexpr(" from median of [0-9]+\\(", s)
    head <- substr(s, 1L, m - 1L)
    N <- as.integer(sub("^ from median of ([0-9]+)\\($", "\\1", regmatches(s, m)))
    pool_start <- m + attr(m, "match.length")
    pool <- parse_seq(s, pool_start, ", ", ")", N)
    if (is.null(pool) || pool$end != nchar(s)) return(NULL)
    if (startsWith(head, "mean of ")) {
      sel <- parse_seq(head, 9L, " & ", "", 2L)
      if (is.null(sel)) return(NULL)
      form <- "mean_median_select"
    } else {
      sel <- parse_seq(head, 1L, " & ", "", 1L)
      if (is.null(sel)) return(NULL)
      form <- "median_select"
    }
    out <- rbind(
      data.frame(sel$keys, derivation_role="selected_from_median_pool", member_position=seq_len(nrow(sel$keys)), n_pool=N),
      data.frame(pool$keys, derivation_role="median_of_member", member_position=seq_len(N), n_pool=N))
    out$cell_form <- form
    return(out)
  }
  if (startsWith(s, "mean of ")) {
    r <- parse_seq(s, 9L, " and ", "", 2L)
    if (is.null(r)) return(NULL)
    out <- data.frame(r$keys, derivation_role="mean_of_member", member_position=1:2, n_pool=2L, cell_form="mean")
    return(out)
  }
  r <- parse_seq(s, 1L, "", "", 1L)
  if (is.null(r)) return(NULL)
  data.frame(r$keys, derivation_role="direct", member_position=1L, n_pool=NA_integer_, cell_form="single")
}

cat("parsing", length(u_strings), "unique strings ...\n")
parsed <- lapply(u_strings, parse_cell)
names(parsed) <- u_strings
ok <- !vapply(parsed, is.null, logical(1))
unparsed_strings <- u_strings[!ok]
n_unparsed_cells <- sum(cells$ref_string[has_ref] %in% unparsed_strings)
frac_unparsed <- n_unparsed_cells / sum(has_ref)
cat(sprintf("unparsed unique strings: %d | unparsed cells: %d of %d (%.4f%%)\n",
            length(unparsed_strings), n_unparsed_cells, sum(has_ref), 100 * frac_unparsed))
unparsed_tbl <- cells[has_ref & cells$ref_string %in% unparsed_strings, ] %>%
  select(row_id, class, order, family, genus, species, subspecies, trait, value, verbatim_reference_string = ref_string)
write_csv(unparsed_tbl, file.path(out_dir, "Myhrvold_etal_2015_cell_references_unparsed.csv"), na="")
if (frac_unparsed > UNPARSED_MAX_FRACTION)
  stop(sprintf("Unparsed fraction %.4f exceeds %.4f; see reference_tables/Myhrvold_etal_2015_cell_references_unparsed.csv", frac_unparsed, UNPARSED_MAX_FRACTION), call.=FALSE)

## ---- expand to cells ----------------------------------------------------------------------
parsed_ok <- bind_rows(lapply(u_strings[ok], function(s) { p <- parsed[[s]]; p$ref_string <- s; p }))
names(parsed_ok)[names(parsed_ok) == "text"] <- "ref_key"
names(parsed_ok)[names(parsed_ok) == "norm"] <- "ref_key_norm"

cell_refs <- cells[has_ref & !(cells$ref_string %in% unparsed_strings), ] %>%
  inner_join(parsed_ok, by = "ref_string", relationship = "many-to-many")
## blank-reference cells (value present, citation left empty by the compilers)
blank_rows <- cells[has_value & is_blank_ref, ] %>%
  mutate(ref_key = "(blank)", bc_prefix = "", ref_key_norm = "(blank)", derivation_role = "direct",
         member_position = 1L, n_pool = NA_integer_, cell_form = "blank")
cell_refs <- bind_rows(cell_refs, blank_rows) %>%
  mutate(pantheria_derived = ref_key_norm %in% PANTHERIA_KEYS,
         jones2003_derived = ref_key_norm %in% JONES2003_KEYS) %>%
  rename(verbatim_reference_string = ref_string) %>%
  select(row_id, class, order, family, genus, species, subspecies, trait, value,
         ref_key, bc_prefix, ref_key_norm, cell_form, derivation_role, member_position, n_pool,
         pantheria_derived, jones2003_derived, verbatim_reference_string) %>%
  arrange(row_id, match(trait, traits), derivation_role != "selected_from_median_pool", member_position)
cell_refs$bc_prefix <- sub(" - $", "", cell_refs$bc_prefix)

n_blank_tokens <- sum(cell_refs$ref_key_norm == "(blank)" & cell_refs$cell_form != "blank")
cat(sprintf("empty-key tokens inside constructs (ref_key_norm '(blank)'): %d rows in %d cells\n",
            n_blank_tokens, n_distinct(paste(cell_refs$row_id, cell_refs$trait)[cell_refs$ref_key_norm == "(blank)" & cell_refs$cell_form != "blank"])))

## Jones-variant guard: every key that looks like PanTHERIA / Jones 2003 must be declared.
jones_keys <- sort(unique(cell_refs$ref_key_norm[grepl("Jones", cell_refs$ref_key_norm)]))
cat("lexicon keys containing 'Jones':\n"); print(jones_keys)
loose_pan <- jones_keys[grepl("Bielby", jones_keys)]
loose_j03 <- jones_keys[grepl("^Jones,? et al\\.?,? 2003", jones_keys)]
if (!all(loose_pan %in% PANTHERIA_KEYS)) stop("Undeclared PanTHERIA key variant: ", paste(setdiff(loose_pan, PANTHERIA_KEYS), collapse=" | "))
if (!all(loose_j03 %in% JONES2003_KEYS)) stop("Undeclared Jones 2003 key variant: ", paste(setdiff(loose_j03, JONES2003_KEYS), collapse=" | "))

## ---- coverage assertions ------------------------------------------------------------------
covered <- cell_refs %>% distinct(row_id, trait)
value_cells <- cells[has_value, c("row_id","trait")]
missing_cov <- anti_join(value_cells, covered, by=c("row_id","trait"))
n_missing_cov <- nrow(missing_cov)
cat(sprintf("value cells: %d | value cells with >=1 reference row: %d | uncovered: %d (unparsed: %d)\n",
            nrow(value_cells), nrow(covered), n_missing_cov, n_unparsed_cells))
if (n_missing_cov != n_unparsed_cells) stop("Value cells lacking a reference row beyond the declared unparsed set: ", n_missing_cov - n_unparsed_cells)
extra <- anti_join(covered, value_cells, by=c("row_id","trait"))
if (nrow(extra)) stop("Reference rows for cells without a value: ", nrow(extra))
## pool-count check: every median pool has exactly N member rows
pool_chk <- cell_refs %>% filter(derivation_role == "median_of_member") %>% count(row_id, trait, n_pool) %>% filter(n != n_pool)
if (nrow(pool_chk)) stop("Median pools whose member count != N: ", nrow(pool_chk))

## ---- summaries ----------------------------------------------------------------------------
cat("\nrows per class:\n"); print(cell_refs %>% count(class) %>% as.data.frame())
cat("\nrows per cell_form x derivation_role:\n"); print(cell_refs %>% count(cell_form, derivation_role) %>% as.data.frame())
cat("\nMammalia: cells with value:", sum(has_value & cells$class == "Mammalia"),
    "| reference rows:", sum(cell_refs$class == "Mammalia"),
    "| distinct keys (norm):", n_distinct(cell_refs$ref_key_norm[cell_refs$class == "Mammalia"]), "\n")
cat("All classes: distinct ref_key (printed):", n_distinct(cell_refs$ref_key),
    "| distinct ref_key_norm:", n_distinct(cell_refs$ref_key_norm), "\n")

## Mammalia independence by trait
indep <- cell_refs %>% filter(class == "Mammalia") %>%
  group_by(trait, row_id) %>%
  summarise(n_refs = n(), n_circ2 = sum(pantheria_derived | jones2003_derived),
            n_pan = sum(pantheria_derived), n_j03 = sum(jones2003_derived), .groups="drop") %>%
  mutate(status = case_when(n_pan == n_refs ~ "fully_circular", n_pan > 0 ~ "partly_circular", TRUE ~ "fully_independent"),
         status2 = case_when(n_circ2 == n_refs ~ "fully_circular", n_circ2 > 0 ~ "partly_circular", TRUE ~ "fully_independent")) %>%
  group_by(trait) %>%
  summarise(n_cells_with_value = n(),
            n_fully_circular = sum(status == "fully_circular"),
            n_partly_circular = sum(status == "partly_circular"),
            n_fully_independent = sum(status == "fully_independent"),
            n_cells_any_pantheria = sum(n_pan > 0),
            n_cells_any_jones2003 = sum(n_j03 > 0),
            n_fully_circular_incl_jones2003 = sum(status2 == "fully_circular"),
            n_partly_circular_incl_jones2003 = sum(status2 == "partly_circular"),
            n_fully_independent_incl_jones2003 = sum(status2 == "fully_independent"), .groups="drop") %>%
  mutate(pct_fully_independent = round(100 * n_fully_independent / n_cells_with_value, 1)) %>%
  arrange(match(trait, traits))
mam_value_cells <- cells %>% filter(has_value, class == "Mammalia") %>% count(trait, name="n_value_cells_db")
chk <- full_join(indep, mam_value_cells, by="trait")
if (any(is.na(chk$n_cells_with_value) | is.na(chk$n_value_cells_db) | chk$n_cells_with_value != chk$n_value_cells_db))
  stop("Mammalia per-trait cell counts disagree between the database and the reference rows.")
cat("\nMammalia independence by trait (circular = PanTHERIA only):\n"); print(as.data.frame(indep %>% select(trait, n_cells_with_value, n_fully_circular, n_partly_circular, n_fully_independent, pct_fully_independent, n_cells_any_jones2003)), row.names=FALSE)
cat(sprintf("Mammalia totals (PanTHERIA only): cells %d | fully circular %d | partly circular %d | fully independent %d\n",
            sum(indep$n_cells_with_value), sum(indep$n_fully_circular), sum(indep$n_partly_circular), sum(indep$n_fully_independent)))
cat(sprintf("Mammalia totals (PanTHERIA or Jones 2003): fully circular %d | partly circular %d | fully independent %d\n",
            sum(indep$n_fully_circular_incl_jones2003), sum(indep$n_partly_circular_incl_jones2003), sum(indep$n_fully_independent_incl_jones2003)))

## ---- write --------------------------------------------------------------------------------
# Bound both row count and actual serialized bytes; each part repeats the header.
# Stage and validate every part before replacing the previous generated set.
part_prefix <- "Myhrvold_etal_2015_cell_references_part"
part_pattern <- "^Myhrvold_etal_2015_cell_references_part[0-9]+[.]csv$"
max_part_bytes <- 25 * 1024^2
stage <- tempfile("cell_refs_parts_", tmpdir = out_dir)
dir.create(stage)
f_parts <- character()
write_part <- function(rows) {
  path <- file.path(stage, sprintf("%s%03d.csv", part_prefix, length(f_parts) + 1L))
  write_csv(cell_refs[rows, ], path, na = "")
  if (file.info(path)$size > max_part_bytes) {
    unlink(path)
    if (length(rows) == 1L) stop("A single citation row exceeds the part size limit.")
    mid <- length(rows) %/% 2L
    write_part(rows[seq_len(mid)])
    write_part(rows[seq.int(mid + 1L, length(rows))])
    return(invisible(NULL))
  }
  back <- read_csv(path, col_types = cols(.default = "c"), progress = FALSE)
  if (nrow(back) != length(rows) || !identical(names(back), names(cell_refs)))
    stop("Read-back failed: ", path)
  if (!all(validUTF8(back$verbatim_reference_string))) stop("Non-UTF-8 text: ", path)
  f_parts <<- c(f_parts, path)
}
for (first in seq.int(1L, nrow(cell_refs), by = 50000L))
  write_part(seq.int(first, min(first + 49999L, nrow(cell_refs))))
for (path in f_parts) {
  if (!file.copy(path, file.path(out_dir, basename(path)), overwrite = TRUE))
    stop("Could not install part: ", path)
}
# Remove obsolete generated files only after all replacement parts are validated.
old_parts <- list.files(out_dir, pattern = part_pattern, full.names = TRUE)
unlink(setdiff(old_parts, file.path(out_dir, basename(f_parts))))
unlink(file.path(out_dir, "Myhrvold_etal_2015_cell_references.csv"))
unlink(stage, recursive = TRUE)
write_csv(indep, file.path(out_dir, "Myhrvold_etal_2015_mammal_independence_by_trait.csv"), na="")

## definitions files (house template columns)
def <- function(code, definition, role="info", note="", ref="Myhrvold_etal_2015_cell_references")
  data.frame(Code=code, Definition=definition, Structure="", Measure="", Stat="", role=role,
             taxon="Aves; Reptilia; Mammalia", Reference=ref, Note=note, `Source Note`="", check.names=FALSE)
defs_cr <- rbind(
  def("row_id", "1-based row number in Data_Files/Amniote_Database_Aug_2015.csv (identical row order in the References file)"),
  def("class / order / family / genus / species / subspecies", "taxon as printed in the Database row; subspecies -999 = none recorded"),
  def("trait", "one of the 29 numeric trait columns (Supplemental Table 9 fields 8-36)"),
  def("value", "the trait value in that cell as printed (never -999: only cells with a value have rows)", role="secondary"),
  def("ref_key", "contributing reference key exactly as printed inside the cell string (may carry a 'BC Birds - ' / 'BC mammals - ' / 'BC Reptiles - ' prefix); '(blank)' when the reference cell is empty"),
  def("bc_prefix", "'BC Birds', 'BC mammals', 'BC Reptiles' when the printed key carried that prefix, else empty; Supplemental Table 2 counts references without the prefix"),
  def("ref_key_norm", "ref_key with the BC prefix removed -- the form used by Supplemental Table 2 'Reference Name'; join key to Myhrvold_etal_2015_references.csv"),
  def("cell_form", "shape of the whole cell string: single | mean | median_select | mean_median_select | blank (see grammar in README)"),
  def("derivation_role", "direct (single key is the value's source) | mean_of_member (one of the two keys averaged in 'mean of A and B') | selected_from_median_pool (the key(s) named before 'from median of N(...)': the record(s) whose value was taken/averaged) | median_of_member (one entry of the N-record pool the median was taken over)"),
  def("member_position", "1-based position of this key within its construct (mean members 1-2; selected keys 1-2; pool members 1..N); the pool is printed in the compilers' order, duplicates kept"),
  def("n_pool", "size of the construct the row belongs to: 2 for a mean, N for a median pool / the pool a key was selected from, empty for direct"),
  def("pantheria_derived", "TRUE when ref_key_norm is the PanTHERIA entry 'Jones, K., Bielby, J., Cardillo, M. et al., 2009' (the only spelling found; all 'Jones' keys are printed by the script)"),
  def("jones2003_derived", "TRUE when ref_key_norm is 'Jones et al., 2003' or its variant spelling 'Jones, et al. 2003'. Identity per Supplemental Table 1 (see references.csv full_citation): Jones, M., C.R. Dickman & M. Archer 2003, Predators with Pouches: The Biology of Carnivorous Marsupials -- all citing cells are marsupials; this is NOT K.E. Jones et al. 2003 (bats) and is not treated as PanTHERIA-circular"),
  def("verbatim_reference_string", "the entire cell string from Amniote_Database_References_Aug_2015.csv, unmodified"),
  def("Method:grammar", "lexicon-driven longest-first backtracking parser over the EBNF in the script header; lexicon = Supplemental Table 2 names + strings occurring as whole single-key cells; parse failures -> *_cell_references_unparsed.csv; run stops if > 0.5% of cells fail", role="method"),
  def("Method:blank", "4 cells carry a value but an empty reference string; carried as ref_key '(blank)' (Supplemental Table 2 declares a '(blank)' reference), cell_form 'blank'. Inside constructs an empty key token (', ,', '(,', 'mean of  and', 'BC Reptiles - ,') is likewise emitted as ref_key_norm '(blank)' with the construct's own cell_form", role="method"))
write_csv(defs_cr, file.path(out_dir, "Myhrvold_etal_2015_cell_references_definitions.csv"), na="")
defs_un <- rbind(
  def("row_id / class..subspecies / trait / value", "as in cell_references", ref="Myhrvold_etal_2015_cell_references_unparsed"),
  def("verbatim_reference_string", "cell string the grammar could not fully consume (file may have zero data rows)", ref="Myhrvold_etal_2015_cell_references_unparsed"))
write_csv(defs_un, file.path(out_dir, "Myhrvold_etal_2015_cell_references_unparsed_definitions.csv"), na="")
defs_ind <- rbind(
  def("trait", "Mammalia trait (Supplemental Table 9 field)", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_cells_with_value", "Mammalia cells with a non -999 value for the trait", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_fully_circular", "cells whose EVERY contributing reference (all roles) is PanTHERIA (Jones, K., Bielby, J., Cardillo, M. et al., 2009)", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_partly_circular", "cells with at least one PanTHERIA reference and at least one other reference", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_fully_independent", "cells with no PanTHERIA reference in any role", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_fully_circular_incl_jones2003 / n_partly_circular_incl_jones2003 / n_fully_independent_incl_jones2003", "the same three counts when 'Jones et al., 2003' (Jones, Dickman & Archer 2003, carnivorous marsupials -- not K.E. Jones 2003) is ALSO treated as circular, as the original task specification asked; provided for comparison only", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_cells_any_pantheria", "cells with >= 1 PanTHERIA reference row", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("n_cells_any_jones2003", "cells with >= 1 Jones et al. 2003 reference row", ref="Myhrvold_etal_2015_mammal_independence_by_trait"),
  def("pct_fully_independent", "100 * n_fully_independent / n_cells_with_value, 1 dp", ref="Myhrvold_etal_2015_mammal_independence_by_trait"))
for (i in seq_len(nrow(defs_ind))) defs_ind$taxon[i] <- "Mammalia"
write_csv(defs_ind, file.path(out_dir, "Myhrvold_etal_2015_mammal_independence_by_trait_definitions.csv"), na="")

cat(sprintf("\nWrote %d numbered cell-reference parts (%d rows total; each <= 25 MiB)\n", length(f_parts), nrow(cell_refs)))
