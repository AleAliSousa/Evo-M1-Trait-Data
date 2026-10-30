# Karbowski__2007_TablesS1-S23.R
# -----------------------------------------------------------------------------
# Reformat: frozen snapshot -> per-table analysis CSVs + DOI-encoded public TSVs
# for Karbowski (2007) supplementary Tables S1-S23 (brain O2 consumption + regional
# glucose utilization rates in mammals). DATA ROLE = secondary (compilation of other
# labs' primary CMR values) -> resolved to those primary works by the canonical
# source-aware merge; the compilation itself is not treated as primary evidence.
#
# Input : Karbowski__2007_TablesS1-S23_snapshot.xlsx  (one sheet per table:
#         row 1 = caption, row 2 = header, then printed rows in order; "average
#         <species>" summary rows and subdivision labels preserved; multi-references
#         already joined with "; ").
# Output: Karbowski__2007_Table S<N>.csv  (local, "use this")
#         __Public/comparative-data/<Item encoded>.tsv  (code from __ReadMe.xlsx)
#
# Long schema: table, source_snapshot_row, structure, subregion, species_printed,
#              species, is_average, measure, value, value_printed, sd,
#              sd_printed, units, n_areas, reference
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
here     <- dirname(dirname(.script_path))
snap     <- file.path(here, "Karbowski__2007", "Karbowski__2007_TablesS1-S23_snapshot.xlsx")
readme   <- file.path(here, "__ReadMe.xlsx")
tsv_dir  <- file.path(here, "__Public", "comparative-data")
csv_dir  <- file.path(here, "Karbowski__2007")
key_file <- file.path(here, "_keys", "Stephan", "species_key.csv")

structure_of <- c(S1="Brain",S2="Brain",S3="Visual cortex",S4="Prefrontal cortex",
  S5="Frontal cortex",S6="Cingulate cortex",S7="Temporal cortex",S8="Sensorimotor cortex",
  S9="Occipital cortex",S10="Parietal cortex",S11="Cerebral cortex",S12="Cerebral cortex",
  S13="Thalamus",S14="Cerebellum",S15="Hypothalamus",S16="Hippocampus",S17="Amygdala",
  S18="Septum",S19="Caudate",S20="Substantia nigra",S21="Globus pallidus",
  S22="Brain stem",S23="White matter")

# species harmonisation from the shared key (token Karbowski2007), printed name preserved
key <- read_csv(key_file, show_col_types = FALSE)
kk  <- key %>% filter(source_publication == "Karbowski__2007")
if (nrow(kk) == 0L)
  stop("No species_key.csv rows for source_publication == \"Karbowski__2007\" -- key rows are scoped to the paper folder name (_keys/SPECIES_NAMING.md sec 3b)", call. = FALSE)
lk  <- setNames(kk$accepted_name, tolower(kk$variant_name))
binom <- function(printed) {
  common <- tolower(str_squish(str_remove(printed, "^average\\s+")))
  unname(ifelse(common %in% names(lk), lk[common], NA_character_))
}
number_pattern <- "[−-]?(?:\\d+(?:[.,]\\d+)?|[.,]\\d+)"
num_lexeme <- function(x, index = 1L) {
  matches <- str_extract_all(as.character(x), number_pattern)[[1]]
  if (length(matches) < index) NA_character_ else matches[[index]]
}
lexeme_number <- function(x) {
  if (is.na(x)) return(NA_real_)
  as.numeric(gsub(",", ".", gsub("−", "-", x, fixed = TRUE), fixed = TRUE))
}
num1 <- function(x) lexeme_number(num_lexeme(x, 1L))
num2 <- function(x) lexeme_number(num_lexeme(x, 2L))
pdf_lexeme <- function(x, digits) {
  ifelse(is.na(x), "", formatC(x, format = "f", digits = digits,
                                decimal.mark = "."))
}

filecodes <- read_excel(readme, sheet = "Sheet1")
enc_of <- function(item_name)
  filecodes[["Item encoded"]][match(item_name, filecodes[["Item name"]])]

cols <- c("table","source_snapshot_row","structure","subregion","species_printed",
          "species","is_average","measure","value","value_printed","sd",
          "sd_printed","units","n_areas","reference")

for (i in 1:23) {
  tid <- paste0("S", i); sheet <- paste0("Table ", tid)
  raw <- read_excel(snap, sheet = sheet, col_names = FALSE, skip = 2, col_types = "text",
                    .name_repair = "minimal")
  raw <- as.data.frame(raw, stringsAsFactors = FALSE)
  hdr <- suppressMessages(read_excel(snap, sheet = sheet, col_names = FALSE, n_max = 2,
                    col_types = "text", .name_repair = "minimal"))
  h2  <- as.character(unlist(hdr[2, ]))
  tot_tbl   <- tid %in% c("S1","S2")
  narea_tbl <- tid %in% c("S11","S12")
  # The publisher workbook stores numeric cells and therefore drops display-only
  # zeros.  The published supplement is the record of the printed precision:
  # S1 uses three decimals; S2-S23 use two.
  rate_digits <- if (tid == "S1") 3L else 2L
  ncl <- ncol(raw)
  # S11's last cells are N=<number of cortical areas>, not citations. The
  # component-source lineage is reconstructed from Tables S3-S10 by the merge.
  c_ref <- if (tid == "S11") NA_integer_ else ncl
  c_val <- 2
  c_tot <- if (tot_tbl) 3 else NA
  c_nar <- if (narea_tbl) which(str_detect(h2, "areas")) else NA
  strc  <- unname(structure_of[tid]); sub <- strc
  out <- list()
  for (r in seq_len(nrow(raw))) {
    sp  <- str_squish(as.character(raw[r, 1])); sp <- ifelse(is.na(sp)|sp=="NA","",sp)
    val <- as.character(raw[r, c_val]);         val <- ifelse(is.na(val),"",val)
    ref <- if (is.na(c_ref)) "" else as.character(raw[r, c_ref])
    ref <- ifelse(is.na(ref)|ref=="NA","",ref)
    if (nzchar(sp) && !nzchar(val)) { sub <- str_squish(str_remove(sp, ":$")); next }  # subdivision
    if (!nzchar(sp) && !nzchar(val)) next
    m <- num1(val); sd <- num2(val)
    value_printed <- pdf_lexeme(m, rate_digits)
    sd_printed <- pdf_lexeme(sd, rate_digits)
    isavg <- str_starts(tolower(sp), "average ")
    n_ar  <- if (!is.na(c_nar) && length(c_nar)==1) { z <- as.character(raw[r,c_nar]); as.integer(str_extract(z,"\\d+")) } else NA
    base <- data.frame(table=tid, source_snapshot_row=r, structure=strc, subregion=sub,
      species_printed=sp, species=binom(sp), is_average=isavg,
      stringsAsFactors = FALSE)
    if (tot_tbl) {
      mr <- if (tid=="S1") "CMRO2" else "CMRgl"; ur <- if (tid=="S1") "ml/g/min" else "umol/g/min"
      mt <- if (tid=="S1") "Total_O2_consumption" else "Total_glucose_utilization"
      ut <- if (tid=="S1") "ml/min" else "umol/min"
      total_text <- as.character(raw[r, c_tot])
      tv <- num1(total_text)
      out[[length(out)+1]] <- cbind(base, measure=mr, value=m,
        value_printed=value_printed, sd=sd, sd_printed=sd_printed,
        units=ur, n_areas=NA, reference=ref)
      if (!is.na(tv)) out[[length(out)+1]] <- cbind(base, measure=mt, value=tv,
        value_printed=pdf_lexeme(tv, rate_digits), sd=NA, sd_printed="",
        units=ut, n_areas=NA, reference=ref)
    } else {
      out[[length(out)+1]] <- cbind(base, measure="CMRgl", value=m,
        value_printed=value_printed, sd=sd, sd_printed=sd_printed,
        units="umol/g/min", n_areas=n_ar, reference=ref)
    }
  }
  df <- bind_rows(out)[, cols]
  item <- paste0("Karbowski__2007_Table", tid)
  write_csv(df, file.path(csv_dir, paste0(item, ".csv")))
  enc <- enc_of(item)
  if (!is.na(enc) && dir.exists(tsv_dir)) {
    public_df <- df
    # An explicit terminal NA avoids ambiguous blank references and trailing
    # tab characters in the public text files (averages and S11 summaries).
    public_df$reference[public_df$reference == ""] <- NA_character_
    write_tsv(public_df, file.path(tsv_dir, paste0(enc, ".tsv")), na = "NA")
  } else {
    warning("No Item encoded / __Public for ", item, " -- TSV skipped")
  }
  message(sprintf("%-4s %-18s %d rows", tid, strc, nrow(df)))
}
message("Done. Rebuild AUTO_Public_TSV_FileList with _tools/file_list.R.")
