## =============================================================================
## Jones et al. (2009), PanTHERIA 1.0 -- variable definitions transcribed from
## the Ecological Archives metadata (metadata.htm) in the house definitions
## format (Code,Definition,Structure,Measure,Stat,role,taxon,Reference,Note,Source Note)
## =============================================================================
##
## One row per column of PanTHERIA_1-0_WR05_Aug2008.txt (55 columns; the three
## WR93 header variants are noted on the same rows), plus `method` rows that
## transcribe the metadata's own text on how multiple data lines were reduced
## to one value, the References column, the -999 sentinel, the unpublished raw
## data lines and the derived-variable procedures.
##
## Definition text is the metadata's own wording, verbatim (HTML tags removed,
## entities decoded, whitespace collapsed). Nothing is paraphrased from memory;
## where metadata.htm has no definition paragraph for a column, Note says so.
##
## Sources inside metadata.htm
##   Class IV.A "Header information"      abbreviations used in column names
##   Class IV.B Table 1                    definitions, units, data lines, NSpp
##   Class IV.B "Calculating measures of central tendency" + Table 2
##   Class V.C  "Related material"         derived variables (31)-(53)
##
## Output: reference_tables/Jones_etal_2009_definitions.csv
## Every input problem is a stop() (evom1-refs-conventions C5).
## =============================================================================

options(scipen = 999, stringsAsFactors = FALSE)
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
folder <- dirname(.sp); setwd(folder)
out_dir <- file.path(folder, "reference_tables")
if(!dir.exists(out_dir)) dir.create(out_dir)
ctype_ok <- any(vapply(c("en_US.UTF-8", "C.UTF-8"), function(l)
  tryCatch({ Sys.setlocale("LC_CTYPE", l); grepl("UTF-8", Sys.getlocale("LC_CTYPE"), fixed=TRUE) },
           error=function(e) FALSE), logical(1)))
if(!ctype_ok) stop("No UTF-8 LC_CTYPE locale available.", call.=FALSE)
for(p in c("xml2", "readr", "dplyr")) if(!requireNamespace(p, quietly=TRUE)) stop("Install package: ", p, call.=FALSE)
suppressPackageStartupMessages({ library(xml2); library(dplyr); library(readr) })

meta_file <- file.path(folder, "metadata.htm")
f05 <- file.path(folder, "PanTHERIA_1-0_WR05_Aug2008.txt")
f93 <- file.path(folder, "PanTHERIA_1-0_WR93_Aug2008.txt")
for(f in c(meta_file, f05, f93)) if(!file.exists(f)) stop("Missing input: ", f, call.=FALSE)
ITEM <- "Jones_etal_2009_PanTHERIA1-0WR05Aug2008.txt"
TAXON <- "mammals"

## ---- helpers ---------------------------------------------------------------
cp1252_fix <- function(x) {   # &#150; etc. decode to C1 controls; map to Windows-1252 glyphs
  for(n in 128:159) { ch <- intToUtf8(n)
    if(any(grepl(ch, x, fixed=TRUE))) { rep <- iconv(rawToChar(as.raw(n)), from="CP1252", to="UTF-8")
      x <- gsub(ch, if(is.na(rep)) "" else rep, x, fixed=TRUE) } }
  x
}
squish <- function(x) cp1252_fix(trimws(gsub("\\s+", " ", gsub("\u00a0", " ", x))))
norm_code <- function(x) gsub("\\s+", "", x)   # "26-1 _GR_Area_km2" -> "26-1_GR_Area_km2"
prefix_of <- function(x) sub("^([0-9]+-[0-9]+).*$", "\\1", norm_code(x))

## ---- data-file headers -------------------------------------------------------
hdr05 <- strsplit(readLines(f05, n=1, encoding="UTF-8"), "\t", fixed=TRUE)[[1]]
hdr93 <- strsplit(readLines(f93, n=1, encoding="UTF-8"), "\t", fixed=TRUE)[[1]]
if(length(hdr05) != 55L || length(hdr93) != 55L) stop("Expected 55 columns in both data files.", call.=FALSE)

## ---- parse metadata.htm ----------------------------------------------------------
doc <- read_html(meta_file, encoding="ISO-8859-1")
ps <- xml_find_all(doc, "//p")
ptxt <- squish(xml_text(ps))
find_p <- function(pattern, n_expected=1L) {
  i <- grep(pattern, ptxt)
  if(length(i) != n_expected) stop("Expected ", n_expected, " paragraph(s) matching '", pattern, "', found ", length(i), call.=FALSE)
  i
}
tabs <- xml_find_all(doc, "//table")
if(length(tabs) != 2L) stop("Expected exactly 2 HTML tables (Table 1, Table 2) in metadata.htm; found ", length(tabs), call.=FALSE)
table_rows <- function(tab) {
  rows <- xml_find_all(tab, ".//tr")
  lapply(rows, function(r) squish(xml_text(xml_find_all(r, ".//td|.//th"))))
}
t1 <- table_rows(tabs[[1]]); t2 <- table_rows(tabs[[2]])
if(!identical(t1[[1]], c("Variable: Variable Definition", "Units", "Data lines", "NSpp MSW93", "NSpp MSW05")))
  stop("Table 1 header is not as expected: ", paste(t1[[1]], collapse=" | "), call.=FALSE)
if(!identical(t2[[1]], c("Variable", "GLM model specification[method]", "Base factor", "Central tendency measure")))
  stop("Table 2 header is not as expected: ", paste(t2[[1]], collapse=" | "), call.=FALSE)

## Table 1 body: rows "(n) code: definition" x units x data lines x NSpp93 x NSpp05, then the References row
t1_body <- t1[-1]
is_var <- vapply(t1_body, function(r) grepl("^\\([0-9]+\\)", r[1]), logical(1))
if(sum(is_var) != 30L) stop("Table 1 should define 30 variables; found ", sum(is_var), call.=FALSE)
tab1 <- bind_rows(lapply(t1_body[is_var], function(r) {
  m <- regmatches(r[1], regexec("^\\(([0-9]+)\\)\\s*([^:]+):\\s*(.*)$", r[1]))[[1]]
  if(length(m) != 4L) stop("Cannot parse Table 1 row: ", r[1], call.=FALSE)
  tibble(table1_n = as.integer(m[2]), code_as_printed = squish(m[3]), definition = squish(m[4]),
         units = r[2], data_lines = r[3], nspp_msw93 = r[4], nspp_msw05 = r[5])
}))
if(!identical(tab1$table1_n, 1:30)) stop("Table 1 numbering is not (1)..(30).", call.=FALSE)
if(any(!grepl("^[0-9]+$", c(tab1$data_lines, tab1$nspp_msw93, tab1$nspp_msw05)))) stop("Non-numeric counts in Table 1.", call.=FALSE)
refs_row <- t1_body[!is_var]
if(length(refs_row) != 1L || !grepl("^References:", refs_row[[1]][1])) stop("Table 1 References row not found.", call.=FALSE)
references_statement <- refs_row[[1]][1]

## Table 2 body: "(n) code" x GLM spec x base factor x central tendency measure
tab2 <- bind_rows(lapply(t2[-1], function(r) {
  m <- regmatches(r[1], regexec("^\\(([0-9]+)\\)\\s*(.*)$", r[1]))[[1]]
  if(length(m) != 3L) stop("Cannot parse Table 2 row: ", r[1], call.=FALSE)
  tibble(table2_n = as.integer(m[2]), code_as_printed_t2 = squish(m[3]), glm_spec = r[2], base_factor = r[3], central_tendency = r[4])
}))
if(!identical(tab2$table2_n, 1:30)) stop("Table 2 numbering is not (1)..(30).", call.=FALSE)
if(!identical(prefix_of(tab1$code_as_printed), prefix_of(tab2$code_as_printed_t2)))
  stop("Table 1 and Table 2 variable prefixes do not line up.", call.=FALSE)
tab12 <- bind_cols(tab1, tab2 %>% select(-table2_n))

## Narrative paragraphs (verbatim)
p_header   <- ptxt[find_p("^Header information:")]
p_special  <- ptxt[find_p("^Special characters/fields:")]
p_storage  <- ptxt[find_p("^Storage location and medium:")]
p_variables<- ptxt[find_p("^Variables: Data were gathered from the literature")]
p_vardefs  <- ptxt[find_p("^30 specific variables were extracted for PanTHERIA")]
p_reflist  <- ptxt[find_p("^Reference list for the data set")]
i_ct <- find_p("^Calculating measures of central tendency$")
i_t2 <- find_p("^TABLE 2\\. Methods to generate measures of central tendency")
ct_paras <- ptxt[(i_ct + 1L):(i_t2 - 1L)]
ct_paras <- ct_paras[nzchar(ct_paras)]
if(length(ct_paras) < 3L || !grepl("94729", ct_paras[1])) stop("Central-tendency section not located as expected.", call.=FALSE)
i_rel <- find_p("^C\\. Related material$")
p_rel_intro <- ptxt[i_rel + 1L]
p_derived_existing <- ptxt[find_p("^Derived variables from existing data\\.")]
p_table3 <- ptxt[find_p("^Table 3\\. Models for Extrapolated Variables")]
p_derived_other <- ptxt[find_p("^Derived variables from other data\\.")]
if(!grepl("23 additional variables", p_rel_intro)) stop("Related-material intro paragraph not as expected.", call.=FALSE)
table3_img <- xml_attr(xml_find_all(doc, "//img"), "src")

## Derived variables (31)-(53): items "(n) code (counts), text" inside the two paragraphs
split_items <- function(p) {
  pos <- gregexpr("\\(([0-9]{2})\\)\\s*[0-9]+-\\s*[0-9]+\\s*_", p, perl=TRUE)[[1]]
  if(pos[1] < 0) stop("No derived-variable items found in paragraph.", call.=FALSE)
  starts <- as.integer(pos); ends <- c(starts[-1] - 1L, nchar(p))
  items <- substring(p, starts, ends)
  bind_rows(lapply(items, function(it) {
    m <- regmatches(it, regexec("^\\(([0-9]{2})\\)\\s*([0-9]+-\\s*[0-9]+\\s*_\\s*[A-Za-z0-9_/]+)\\s*\\(([^)]*)\\)\\s*,?\\s*(.*)$", it, perl=TRUE))[[1]]
    if(length(m) != 5L) stop("Cannot parse derived-variable item: ", substr(it, 1, 80), call.=FALSE)
    tibble(item_n = as.integer(m[2]), code_as_printed = norm_code(m[3]), species_counts = squish(m[4]),
           item_text = squish(sub("[;.]\\s*$", "", sub("\\s*(and|Secondly,).*$", "", m[5]))), item_verbatim = squish(it))
  }))
}
der_ext <- split_items(p_derived_existing)
der_oth <- split_items(p_derived_other)
## the "(see Table 3 ...)" tail of the last EXT item belongs to the paragraph, keep it verbatim in item_verbatim
derived <- bind_rows(der_ext, der_oth)
## The metadata text says "23 additional variables" / "19 variables using data
## from other sources", but it enumerates only 4 + 15 = 19 items (numbering
## jumps from (41) to (46)), and the data files have exactly 19 derived columns
## (37-55). The count asserted here is what is actually printed and published.
if(nrow(derived) != 19L) stop("Expected 19 enumerated derived variables (4 EXT + 15 spatial); parsed ", nrow(derived), call.=FALSE)
if(!identical(derived$item_n, c(31:41, 46:53))) stop("Derived-variable item numbering is not (31)-(41),(46)-(53) as printed.", call.=FALSE)

## ---- assemble one row per data-file column -----------------------------------
unit_from_suffix <- c(km2 = "km2", dd = "decimal degrees (dd)", mm = "mm", g = "grams (g)", d = "days (d)",
                      `n/km2` = "number per km2 (n/km2)", `01degC` = "0.1 degrees C (01degC)")
## Table 1 spells two codes differently from the data header; declared so any
## other mismatch still stops. The variant is recorded in the row's Note.
KNOWN_CODE_VARIANTS <- c("5-3_NeonatalBodyMass_g" = "5-3_NeonateBodyMass_g",
                         "21-1_PopulationDensity" = "21-1_PopulationDensity_n/km2")
note_join <- function(x) paste(Filter(nzchar, x), collapse=" | ")
rows <- list()
for(j in seq_along(hdr05)) {
  code <- hdr05[j]; code93 <- hdr93[j]
  wr93_note <- if(code != code93) paste0("WR93 header: ", code93) else ""
  colpos <- paste0("column ", j, " of 55")
  if(j <= 5L) {
    rows[[j]] <- tibble(Code = code,
      Definition = paste0("Taxonomic key column (", sub("MSW05_", "", code), ") in the Wilson and Reeder (2005) taxonomy (WR05 file) / Wilson and Reeder (1993) taxonomy (WR93 file). Metadata 'Header information': \"", p_header, "\""),
      Structure = "", Measure = "", Stat = "", role = "info", taxon = TAXON, Reference = ITEM,
      Note = note_join(c(colpos, wr93_note, "No per-variable definition paragraph in metadata.htm for the taxonomy columns; Definition quotes the Header information passage.")),
      `Source Note` = "Class IV.A Header information")
  } else if(code == "References") {
    rows[[j]] <- tibble(Code = code,
      Definition = paste0(references_statement, " Section F: \"", p_reflist, "\""),
      Structure = "", Measure = "", Stat = "", role = "info", taxon = TAXON, Reference = ITEM,
      Note = note_join(c(colpos, "Semicolon-separated reference index numbers listed once PER SPECIES (one list per row), not per variable or per value; -999 = none. Resolved in reference_tables/Jones_etal_2009_references.csv and _species_references.csv.")),
      `Source Note` = "Class IV.B Table 1 (last row) and Class V.F Reference list for the data set")
  } else if(j <= 35L) {
    k <- which(prefix_of(tab12$code_as_printed) == prefix_of(code))
    if(length(k) != 1L) stop("No unique Table 1 row for column ", code, call.=FALSE)
    r <- tab12[k, ]
    printed <- norm_code(r$code_as_printed)
    if(printed != norm_code(code) && printed != norm_code(code93) &&
       !(printed %in% names(KNOWN_CODE_VARIANTS) && KNOWN_CODE_VARIANTS[[printed]] == code))
      stop("Table 1 code '", r$code_as_printed, "' does not match data header '", code, "'", call.=FALSE)
    rows[[j]] <- tibble(Code = code, Definition = r$definition, Structure = "",
      Measure = r$units, Stat = r$central_tendency, role = "data", taxon = TAXON, Reference = ITEM,
      Note = note_join(c(colpos, wr93_note,
                     paste0("Table 1 (", r$table1_n, "): Data lines = ", r$data_lines, "; NSpp MSW93 = ", r$nspp_msw93, "; NSpp MSW05 = ", r$nspp_msw05),
                     if(norm_code(r$code_as_printed) != norm_code(code)) paste0("Table 1 prints the code as '", r$code_as_printed, "'"),
                     if(norm_code(r$code_as_printed_t2) != norm_code(code)) paste0("Table 2 prints the code as '", r$code_as_printed_t2, "'"))),
      `Source Note` = paste0("Table 2 (", r$table1_n, "): GLM model specification [method] = ", r$glm_spec, "; Base factor = ", r$base_factor, "; Central tendency measure = ", r$central_tendency))
  } else {
    k <- which(prefix_of(derived$code_as_printed) == prefix_of(code))
    if(length(k) != 1L) stop("No unique Class V.C item for column ", code, call.=FALSE)
    r <- derived[k, ]
    if(norm_code(r$code_as_printed) != norm_code(code) && norm_code(r$code_as_printed) != norm_code(code93))
      stop("Class V.C code '", r$code_as_printed, "' does not match data header '", code, "'", call.=FALSE)
    is_ext <- grepl("_EXT$", code)
    suffix <- sub("^.*_", "", sub("_EXT$", "", code))
    measure <- if(code == "27-4_HuPopDen_Change") "ratio (1995-1990)/1990" else if(suffix %in% names(unit_from_suffix)) unit_from_suffix[[suffix]] else ""
    defn <- if(is_ext) paste0(sub("\\s*\\(31\\).*$", "", p_derived_existing), " ", r$item_verbatim)
            else paste0(r$item_verbatim)
    rows[[j]] <- tibble(Code = code, Definition = defn, Structure = "", Measure = measure,
      Stat = if(is_ext) "fitted value (GLM)" else "", role = "data", taxon = TAXON, Reference = ITEM,
      Note = note_join(c(colpos, wr93_note, paste0("Class V.C item (", r$item_n, "): species counts as printed = ", r$species_counts, " (MSW93, MSW05)"),
                     if(is_ext) paste0("Model details are in Table 3, which metadata.htm includes only as an image (", paste(table3_img, collapse=", "), "), not as text; the image is not in this folder."),
                     if(norm_code(r$code_as_printed) != norm_code(code)) paste0("Class V.C prints the code as '", r$code_as_printed, "'"))),
      `Source Note` = if(is_ext) "Class V.C Derived variables from existing data" else "Class V.C Derived variables from other data")
  }
}
defs <- bind_rows(rows)
if(nrow(defs) != 55L) stop("Expected 55 column rows; got ", nrow(defs), call.=FALSE)
if(any(!nzchar(defs$Definition))) stop("Empty Definition for: ", paste(defs$Code[!nzchar(defs$Definition)], collapse=", "), call.=FALSE)

## ---- method rows (verbatim transcriptions) --------------------------------------
mrow <- function(code, text, note="", src="") tibble(Code = code, Definition = text, Structure = "", Measure = "", Stat = "",
  role = "method", taxon = TAXON, Reference = ITEM, Note = note, `Source Note` = src)
header_list_txt <- ptxt[find_p("^Headers included are as follows:")]
methods <- bind_rows(
  mrow("Method:frozen_source", "PanTHERIA_1-0_WR05_Aug2008.txt and PanTHERIA_1-0_WR93_Aug2008.txt are the original Ecological Archives E090-184 tab-delimited files and are the frozen sources; metadata.htm is the archive's own metadata document from which every Definition in this file is transcribed.",
       "", "this repo"),
  mrow("Method:raw_data_lines", paste(p_variables, p_storage, sep=" | "),
       "The 94729 (or 100740 before variable selection) raw data lines are not part of the published files; only one value per species x variable is published. The raw lines are stated to be held at ZSL.",
       "Class II Variables; Class III.B Storage location and medium"),
  mrow("Method:variable_definitions_scope", p_vardefs, "", "Class IV.B Variable definitions"),
  bind_rows(lapply(seq_along(ct_paras), function(i) mrow(paste0("Method:central_tendency_", i), ct_paras[i],
       if(i == 1L) "How multiple data lines were reduced to one value per species x variable; per-variable rule in each variable row's Stat and Source Note (Table 2)." else "",
       "Class IV.B Calculating measures of central tendency"))),
  mrow("Method:table2_header", paste0("TABLE 2 columns: ", paste(t2[[1]], collapse=" | ")), "Per-variable Table 2 content is in each variable row (Stat = Central tendency measure; Source Note = GLM model specification and Base factor).", "Class IV.B Table 2"),
  mrow("Method:references_column", paste(references_statement, p_reflist, sep=" | "),
       "References are cited per species (one list per row), not per variable or per value; the data lines that would tie a citation to a value are unpublished.",
       "Class IV.B Table 1; Class V.F"),
  mrow("Method:missing_value", p_special, "", "Class IV.A Special characters/fields"),
  mrow("Method:header_abbreviations", p_header, "", "Class IV.A Header information"),
  mrow("Method:header_list_as_printed", header_list_txt,
       "The metadata header list prints '29-1 _AET_Mean_mm' and '29-2 _PET_Mean_mm'; the data files and Class V.C use '30-1_AET_Mean_mm' and '30-2_PET_Mean_mm'. WR93 file headers differ from WR05 for columns 1-5 (MSW93_), 20 (14-1_InterBirthInterval_d), 44 (26-4_GR_MRLat_dd) and 47 (26-7_GR_MRLong_dd).",
       "Class IV.A Header information"),
  mrow("Method:derived_variables_intro", p_rel_intro, "", "Class V.C Related material"),
  mrow("Method:derived_from_existing", p_derived_existing, paste0("Table 3 is an image (", paste(table3_img, collapse=", "), ") in the archive, not text."), "Class V.C Derived variables from existing data"),
  mrow("Method:table3_caption", p_table3, "", "Class V.C Table 3"),
  mrow("Method:derived_from_other", p_derived_other,
       "Item numbering in this paragraph runs (35)-(41) then (46)-(53); numbers (42)-(45) are not used in the metadata text. The paragraph says '19 variables' but enumerates 15; with the 4 EXT variables that gives the 19 derived columns (37-55) actually present in the data files, not the '23 additional variables' stated in the intro.",
       "Class V.C Derived variables from other data")
)
out <- bind_rows(defs, methods)
out[] <- lapply(out, function(x) { x <- as.character(x); x[is.na(x)] <- ""; x })
if(anyDuplicated(out$Code)) stop("Duplicate Code in definitions.", call.=FALSE)
if(!identical(names(out), c("Code","Definition","Structure","Measure","Stat","role","taxon","Reference","Note","Source Note")))
  stop("Definitions columns are not in house order.", call.=FALSE)
if(any(grepl("<[a-zA-Z/][^>]*>|&[a-z#0-9]+;", out$Definition))) stop("HTML remains in Definition text.", call.=FALSE)

f_out <- file.path(out_dir, "Jones_etal_2009_definitions.csv")
write_csv(out, f_out, na = "")
back <- read_csv(f_out, show_col_types=FALSE, na=character(), progress=FALSE, locale=locale(encoding="UTF-8"),
                 col_types = cols(.default = col_character()))
if(nrow(problems(back))) stop("Read-back of definitions CSV reported parsing problems.", call.=FALSE)
if(nrow(back) != nrow(out) || !identical(names(back), names(out)) || !identical(as.character(back$Definition), out$Definition))
  stop("Read-back of definitions CSV does not match.", call.=FALSE)

cat("== Jones_etal_2009_definitions ==\n")
cat("column rows: ", nrow(defs), " (taxonomy ", sum(defs$`Source Note` == "Class IV.A Header information"),
    ", Table 1 variables ", sum(grepl("^Table 2", defs$`Source Note`)), ", References ", sum(defs$Code == "References"),
    ", derived ", sum(grepl("^Class V.C", defs$`Source Note`)), ")\n", sep="")
cat("method rows:", nrow(methods), "\n")
cat("Table 1 data lines total (sum of 30 variables):", sum(as.integer(tab1$data_lines)), "\n")
cat("central-tendency paragraphs transcribed:", length(ct_paras), "\n")
cat("Wrote", f_out, "\n")
