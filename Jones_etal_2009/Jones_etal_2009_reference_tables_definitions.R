## =============================================================================
## Jones et al. (2009), PanTHERIA 1.0 -- column definitions for every CSV in
## reference_tables/ produced by the three sibling scripts
##   Jones_etal_2009_references.R, Jones_etal_2009_definitions.R,
##   Jones_etal_2009_WR05_vs_WR93_consistency.R
## Output: reference_tables/Jones_etal_2009_reference_tables_definitions.csv
## (house format Code,Definition,Structure,Measure,Stat,role,taxon,Reference,Note,Source Note;
##  Reference = the CSV the row describes). Asserts that every column of every
##  non-definitions CSV in reference_tables/ has exactly one row.
## =============================================================================
options(stringsAsFactors = FALSE)
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
if(!dir.exists(out_dir)) stop("reference_tables/ does not exist; run Jones_etal_2009_references.R first.", call.=FALSE)
suppressPackageStartupMessages({ library(dplyr); library(readr) })
TAXON <- "mammals"
D <- function(ref, code, def, measure="", stat="", role="info", note="", src="")
  tibble(Code=code, Definition=def, Structure="", Measure=measure, Stat=stat, role=role, taxon=TAXON, Reference=ref, Note=note, `Source Note`=src)

R1 <- "Jones_etal_2009_references"
R2 <- "Jones_etal_2009_references_unparsed"
R3 <- "Jones_etal_2009_species_references"
R4 <- "Jones_etal_2009_species_reference_counts"
R5 <- "Jones_etal_2009_species_data_without_references"
R6 <- "Jones_etal_2009_References_malformed_tokens"
R7 <- "Jones_etal_2009_WR05_vs_WR93_consistency"
R8 <- "Jones_etal_2009_WR05_vs_WR93_consistency_references"
R9 <- "Jones_etal_2009_WR05_vs_WR93_consistency_summary"
heur <- "heuristic split of the verbatim citation (regex on 'Authors. YEAR. Title. Journal <strong>VOL</strong>:PAGES.'); citation is the authoritative column"
defs <- bind_rows(
  D(R1, "ref_number", "Reference index number as printed in metadata.htm section F 'Reference list for the data set' (1..3143); the key used by the data files' References column", "integer", note="one row per individual number, contiguous 1..max, asserted", src="metadata.htm Class V.F"),
  D(R1, "citation", "Full bibliographic entry verbatim: HTML tags removed, entities decoded, whitespace collapsed; spelling and errors as printed", note="entry 3018 is printed as 'Wiles, G. 1996.' only (incomplete in the source); kept verbatim", src="metadata.htm Class V.F"),
  D(R1, "first_author", paste("Surname of the first author (text before the first comma of the author block);", heur)),
  D(R1, "year", paste("Four-digit publication year (first 'YYYY.' in the entry);", heur), "year"),
  D(R1, "title", paste("Title (text between the year and the last sentence break before the bold volume; for entries without a bold volume, the first sentence after the year);", heur), note="empty where the entry has no title text or the split failed"),
  D(R1, "journal_or_publisher", paste("Journal name (sentence immediately before the bold volume) or, for books/theses/chapters, the remainder of the entry after the title;", heur)),
  D(R1, "volume", "Volume as marked in bold (<strong>) in the source entry; empty when the entry has no bold volume", note="as printed"),
  D(R1, "pages", "Page range following 'VOLUME:' or a 'Pages a-b' phrase; empty when absent", note="as printed"),
  D(R1, "species_in_citation", "Italicised (<em>) text in the entry, as printed, semicolon-joined; empty if none", note="italics mark Latin names in this list; occasionally other italic text"),
  D(R1, "n_species_citing_WR05", "Number of WR05 species rows whose References list contains this number (after decoding fused tokens, see Jones_etal_2009_References_malformed_tokens)", "count"),
  D(R1, "n_species_citing_WR93", "Number of WR93 species rows whose References list contains this number (after decoding fused tokens)", "count"),
  D(R2, "ref_number", "Reference index number of an entry whose year, author or body could not be parsed; the row is still present in Jones_etal_2009_references", "integer"),
  D(R2, "citation", "The entry verbatim, as in Jones_etal_2009_references"),
  D(R2, "reason", "Why the entry is listed: incomplete as printed / no year / no author text"),
  D(R3, "taxonomy", "Which published file the row comes from: WR05 (Wilson & Reeder 2005) or WR93 (Wilson & Reeder 1993)"),
  D(R3, "MSW_Binomial", "MSW05_Binomial or MSW93_Binomial as printed in that file"),
  D(R3, "MSW_Order", "MSW05_Order or MSW93_Order as printed"),
  D(R3, "MSW_Family", "MSW05_Family or MSW93_Family as printed"),
  D(R3, "ref_number", "One reference index number cited by the species (the References column is a per-SPECIES list; it does not say which variable or value the reference supports)", "integer", note="structural: references are per species, not per cell; the 94729 raw data lines that would link them are unpublished"),
  D(R3, "citation", "Citation text for ref_number, joined from Jones_etal_2009_references"),
  D(R3, "ref_token_as_printed", "The token in the References column that produced this row; equals ref_number except for fused tokens"),
  D(R3, "token_status", "as_printed = token is a valid reference number; decoded_from_fused_token = token exceeded the reference-list range and was split into exactly one pair of valid numbers (missing ';' in the source)", note="see Jones_etal_2009_References_malformed_tokens"),
  D(R3, "n_reference_numbers", "Number of individual reference numbers for this species (rows for this species in this file)", "count", note="asserted == n_citations_resolved"),
  D(R3, "n_citations_resolved", "Number of those reference numbers that resolved to a citation", "count", note="asserted == n_reference_numbers"),
  D(R4, "taxonomy", "WR05 or WR93"),
  D(R4, "MSW_Binomial", "Binomial as printed in that file (all 5416 + 4629 rows present)"),
  D(R4, "MSW_Order", "Order as printed"),
  D(R4, "MSW_Family", "Family as printed"),
  D(R4, "n_refs", "Number of individual reference numbers in the species' References list (0 when -999)", "count"),
  D(R4, "n_variables_with_data", "Number of the 30 source variables (columns 6-35) with a value other than -999", "count"),
  D(R4, "n_variables_with_data_incl_derived", "Number of the 49 non-key, non-References columns (6-35, 37-55) with a value other than -999", "count", note="derived spatial columns have values for species with no References"),
  D(R5, "taxonomy", "WR05 or WR93"),
  D(R5, "MSW_Binomial", "Species with at least one source-variable value (cols 6-35) but References = -999"),
  D(R5, "MSW_Order", "Order as printed"), D(R5, "MSW_Family", "Family as printed"),
  D(R5, "n_refs", "Always 0 in this sidecar", "count"),
  D(R5, "n_variables_with_data", "Number of source variables with data", "count"),
  D(R5, "n_variables_with_data_incl_derived", "Number of non-key columns with data incl. derived", "count"),
  D(R6, "taxonomy", "WR05 or WR93"),
  D(R6, "MSW_Binomial", "Binomial whose References list contains the malformed token"),
  D(R6, "token_as_printed", "Token in the References column that is not a valid reference number (exceeds the reference list's maximum)", note="all cases are two 4-digit numbers fused by a missing ';' -- a publication defect, reported not repaired"),
  D(R6, "decoded_as", "The unique pair of valid reference numbers the token splits into (a;b); used, flagged, in Jones_etal_2009_species_references"),
  D(R6, "n_candidate_decodings", "Number of ways the token splits into two valid numbers; the script stops unless exactly 1", "count"),
  D(R6, "References_as_printed", "The whole References cell verbatim"),
  D(R7, "MSW_Binomial", "Binomial spelled identically in both files (4080 shared)"),
  D(R7, "variable", "Column name (WR05 spelling) of the differing cell; columns matched by position"),
  D(R7, "column_group", "source = columns 6-35 (30 extracted variables); EXT = columns 37-40; spatial = columns 41-55 (included for completeness, filter out for the requested comparison)"),
  D(R7, "value_WR05", "Cell value as printed in the WR05 file"),
  D(R7, "value_WR93", "Cell value as printed in the WR93 file"),
  D(R7, "presence", "both_present = neither side is -999; only_WR05_present / only_WR93_present = the other side is -999"),
  D(R7, "numeric_difference_type", "For both_present cells: within_1pct (ratio within 1%), power_of_ten (ratio is 10^k), other; empty otherwise", note="cells equal as numbers but formatted differently (e.g. 1 vs 1.00, -999 vs -999.00) are counted in the summary, not listed"),
  D(R8, "MSW_Binomial", "Shared binomial whose References lists differ between files"),
  D(R8, "References_WR05", "References cell verbatim, WR05"), D(R8, "References_WR93", "References cell verbatim, WR93"),
  D(R8, "n_refs_WR05", "Number of tokens in the WR05 list", "count"), D(R8, "n_refs_WR93", "Number of tokens in the WR93 list", "count"),
  D(R8, "only_WR05", "Tokens present only in the WR05 list (;-joined)"), D(R8, "only_WR93", "Tokens present only in the WR93 list (;-joined)"),
  D(R8, "n_only_WR05", "Count of tokens only in WR05", "count"), D(R8, "n_only_WR93", "Count of tokens only in WR93", "count"),
  D(R9, "count", "Name of a summary count printed by Jones_etal_2009_WR05_vs_WR93_consistency.R"),
  D(R9, "value", "Its value for the current run", "count")
)
## every column of every non-definitions CSV in reference_tables/ must have exactly one row
csvs <- list.files(out_dir, pattern="\\.csv$", full.names=TRUE)
csvs <- csvs[!grepl("_definitions\\.csv$", csvs)]
if(!length(csvs)) stop("No CSVs found in reference_tables/.", call.=FALSE)
for(f in csvs) {
  item <- sub("\\.csv$", "", basename(f))
  hdr <- names(read_csv(f, n_max=0, show_col_types=FALSE, col_types=cols(.default=col_character())))
  have <- defs$Code[defs$Reference == item]
  if(!identical(sort(hdr), sort(have)))
    stop("Definitions rows for ", item, " do not match its columns. Missing: ", paste(setdiff(hdr, have), collapse=", "),
         "; extra: ", paste(setdiff(have, hdr), collapse=", "), call.=FALSE)
}
undescribed <- setdiff(unique(defs$Reference), sub("\\.csv$", "", basename(csvs)))
if(length(undescribed)) stop("Definitions describe CSV(s) that do not exist: ", paste(undescribed, collapse=", "), call.=FALSE)
f_out <- file.path(out_dir, "Jones_etal_2009_reference_tables_definitions.csv")
write_csv(defs, f_out, na="")
back <- read_csv(f_out, show_col_types=FALSE, col_types=cols(.default=col_character()), na=character())
if(nrow(back) != nrow(defs)) stop("Read-back mismatch.", call.=FALSE)
cat("reference_tables definitions rows:", nrow(defs), "for", length(csvs), "CSVs\n")
