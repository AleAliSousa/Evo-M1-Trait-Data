# Poulsen_etal_1997_data_from_text_snapshot.R ---------------------------------------
#
# Builds the frozen snapshot of Poulsen, Smith, Ostergaard, Danielsen, Gee,
# Hansen, Astrup & Gjedde (1997) "In vivo estimation of cerebral blood flow,
# oxygen consumption and glucose metabolism in the pig by [15O]water
# injection, [15O]oxygen inhalation and dual injections of
# [18F]fluorodeoxyglucose", J Neurosci Methods 77: 199-209.
# doi:10.1016/S0165-0270(97)00127-1
#
#   reference_tables/Poulsen_etal_1997_data_from_text_snapshot.csv
#        CONSTRUCTED: values printed only in the Abstract (p. 199), Methods
#        (p. 200) and Results 3.1-3.3 (pp. 203, 205, 206); one row per printed
#        value, with the passage it comes from. Read by the Table 2 build for
#        its restatement checks; not an item of its own.
#
# The PDF has a text layer, but it scrambles both tables (Table 1's eight
# columns come out in the order Pglc, Tp, Hgb, O2 headers, then values in a
# different order; Table 2's cells are interleaved with its headers) and it
# renders every "±" as "9" ("171918" for 171 ± 18). Nothing was taken from it.
# The values below are a HAND TRANSCRIPTION read from 300/400-dpi renders of
# PDF pages 1, 2, 5, 7 and 8 (__HOWTO_make_a_snapshot.md method 5; the
# Mink_etal_1981 / Kennedy_etal_1978 printed-layout-block pattern). This
# script writes the frozen file and REFUSES TO OVERWRITE a frozen copy that
# differs; the Table 2 build script Poulsen_etal_1997_Table2.R READS it. No cleaning happens here.
#
# Fidelity decisions:
#  * One snapshot row per printed line. Table 2's Hemisphere row prints two
#    lines in the CMRglc columns ("Multilinear: 27 (3)" over "Graphical:
#    23 (4)", and "27 (3)" over "24 (3)"), so it is two snapshot rows, the
#    second with a blank row label, exactly as on the page.
#  * Caption and the Table 1 abbreviation footnote are kept as rows.
#  * Subscripts/superscripts are flattened to plain text: CMRO2, CMRglc,
#    PaO2, PaCO2, Tp, Pglc, cm^3, min^-1, 1^st, 2^nd. Units are kept exactly
#    as printed in the headers (ml/100 cm^3/min, µmol/100 cm^3/min, mM, kPa).
#  * The table's own "x (y)" notation (mean, SD in brackets) is kept verbatim.
#
# Transcribed by an AI assistant (Claude) on 2026-11-11 from page renders.
# ---------------------------------------------------------------------------

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
folder <- dirname(.sp)
paper  <- basename(folder)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Poulsen_etal_1997_data_from_text

## ---- values printed in running text (constructed) ---------------------------
## columns: text_row|page|location|passage_as_printed|quantity|value_printed|dispersion_printed|units_printed
printed_text <- "
text_row|page|location|passage_as_printed|quantity|value_printed|dispersion_printed|units_printed
1|199|Abstract|we have applied novel PET tracer methodology to seven anaesthetized pigs|n_pigs|seven||
2|199|Abstract|We found an average hemispheric CMRO2 of 171 ± 18 µmol/100 cm^3/min.|CMRO2 hemisphere|171|18|µmol/100 cm^3/min
3|199|Abstract|Individual hemispheric CBF measurements varied between 33 and 41 ml/100 cm^3/min|CBF hemisphere individual minimum|33||ml/100 cm^3/min
4|199|Abstract|Individual hemispheric CBF measurements varied between 33 and 41 ml/100 cm^3/min|CBF hemisphere individual maximum|41||ml/100 cm^3/min
5|199|Abstract|with an average of 37 ± 3 ml/100 cm^3/min at an average PaCO2 of 4.3 ± 0.9 kPa|CBF hemisphere|37|3|ml/100 cm^3/min
6|199|Abstract|with an average of 37 ± 3 ml/100 cm^3/min at an average PaCO2 of 4.3 ± 0.9 kPa|PaCO2|4.3|0.9|kPa
7|199|Abstract|the CBF measurements obeyed the equation CBF (ml/100 cm^3/min) = 8.9 PaCO2 (kPa)|CBF-PaCO2 slope (two pigs)|8.9||ml/100 cm^3/min/kPa
8|199|Abstract|In the first session, the values of CMRglc averaged 27 ± 3 and 23 ± 4 µmol/100 cm^3/min, estimated by multilinear and linear regression analysis, respectively.|CMRglc session 1 multilinear|27|3|µmol/100 cm^3/min
9|199|Abstract|In the first session, the values of CMRglc averaged 27 ± 3 and 23 ± 4 µmol/100 cm^3/min, estimated by multilinear and linear regression analysis, respectively.|CMRglc session 1 linear (graphical)|23|4|µmol/100 cm^3/min
10|199|Abstract|In the second session, the corresponding averages were 27 ± 3 and 24 ± 3 µmol/100 cm^3/min, respectively.|CMRglc session 2 multilinear|27|3|µmol/100 cm^3/min
11|199|Abstract|In the second session, the corresponding averages were 27 ± 3 and 24 ± 3 µmol/100 cm^3/min, respectively.|CMRglc session 2 linear (graphical)|24|3|µmol/100 cm^3/min
12|199|Abstract|The average oxygen extraction fraction was 0.46 ± 0.09|OEF|0.46|0.09|
13|199|Abstract|and the oxygen-glucose ratio was 6.1 ± 0.8.|oxygen-glucose ratio|6.1|0.8|
14|200|2. Materials and methods|Seven young pigs of the Danish Yorkshire land race, with a mean weight of 40 ± 2 kg, were deprived of food for 12 h before the study|body weight|40|2|kg
15|203|3.1. CMRO2|CMRO2 values ranged from 157 to 205 µmol/100 cm^3/min estimated by multilinear regression.|CMRO2 individual minimum|157||µmol/100 cm^3/min
16|203|3.1. CMRO2|CMRO2 values ranged from 157 to 205 µmol/100 cm^3/min estimated by multilinear regression.|CMRO2 individual maximum|205||µmol/100 cm^3/min
17|203|3.1. CMRO2|In normoventilated animals, the average hemispheric CMRO2 was 171 ± 18 µmol/100 cm^3/min.|CMRO2 hemisphere|171|18|µmol/100 cm^3/min
18|205|3.2. CBF|The CBF estimates ranged from 33 to 54 ml/100 cm^3/min|CBF individual minimum|33||ml/100 cm^3/min
19|205|3.2. CBF|The CBF estimates ranged from 33 to 54 ml/100 cm^3/min|CBF individual maximum|54||ml/100 cm^3/min
20|205|3.2. CBF|with an average blood flow of 37 ml/100 cm^3/min in moderately hyperventilated animals, i.e. at PaCO2 4.3 ± 0.9 kPa.|CBF|37||ml/100 cm^3/min
21|205|3.2. CBF|with an average blood flow of 37 ml/100 cm^3/min in moderately hyperventilated animals, i.e. at PaCO2 4.3 ± 0.9 kPa.|PaCO2|4.3|0.9|kPa
22|205|3.2. CBF|The oxygen extraction fraction calculated from the blood flow averaged 0.46 ± 0.09 (range 0.32-0.62).|OEF|0.46|0.09|
23|206|3.3. CMRglc|The estimated lumped constants were 0.45 and 0.42 in the first and second sessions, respectively.|lumped constant session 1|0.45||
24|206|3.3. CMRglc|The estimated lumped constants were 0.45 and 0.42 in the first and second sessions, respectively.|lumped constant session 2|0.42||
25|206|3.3. CMRglc|CMRglc values estimated by multilinear regression averaged 27 ± 3 µmol/100 cm^3/min in both sessions.|CMRglc multilinear (both sessions)|27|3|µmol/100 cm^3/min
26|206|3.3. CMRglc|The corresponding values estimated by simple unilinear regression averaged 23 ± 4 µmol/100 cm^3/min and 24 ± 3 µmol/100 cm^3/min in the first and second sessions, respectively.|CMRglc session 1 unilinear (graphical)|23|4|µmol/100 cm^3/min
27|206|3.3. CMRglc|The corresponding values estimated by simple unilinear regression averaged 23 ± 4 µmol/100 cm^3/min and 24 ± 3 µmol/100 cm^3/min in the first and second sessions, respectively.|CMRglc session 2 unilinear (graphical)|24|3|µmol/100 cm^3/min
28|206|3.3. CMRglc|The average oxygen-glucose ratio was 6.1 ± 0.8.|oxygen-glucose ratio|6.1|0.8|
"

block_to_matrix <- function(txt) {
  lines <- strsplit(sub("^\n", "", sub("\n$", "", txt)), "\n", fixed = TRUE)[[1]]
  cells <- strsplit(lines, "|", fixed = TRUE)
  k <- max(lengths(cells), lengths(regmatches(lines, gregexpr("|", lines, fixed = TRUE))) + 1L)
  do.call(rbind, lapply(seq_along(cells), function(i) {
    x <- cells[[i]]
    n_sep <- lengths(regmatches(lines[i], gregexpr("|", lines[i], fixed = TRUE)))
    x <- c(x, rep("", n_sep + 1L - length(x)))      # trailing empty cells
    c(x, rep("", k - length(x)))
  }))
}

freeze <- function(m, file, header = FALSE) {
  tmp <- tempfile(fileext = ".csv")
  if (header) {
    df <- as.data.frame(m[-1, , drop = FALSE], stringsAsFactors = FALSE)
    names(df) <- m[1, ]
    write.csv(df, tmp, row.names = FALSE, fileEncoding = "UTF-8")
  } else {
    write.table(m, tmp, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
  }
  if (file.exists(file)) {
    if (identical(readLines(file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
      message(basename(file), ": frozen copy identical - unchanged")
      return(invisible(FALSE))
    }
    stop(basename(file), " already exists and DIFFERS from this script's transcription. ",
         "The frozen snapshot is not overwritten. Fix a transcription error deliberately ",
         "(delete the old file by hand, record an errata row) and re-run.", call. = FALSE)
  }
  file.copy(tmp, file)
  message(basename(file), ": frozen (", nrow(m), " rows x ", ncol(m), " cols)")
  invisible(TRUE)
}
tx <- block_to_matrix(printed_text);   stopifnot(identical(dim(tx), c(29L, 8L)))

dir.create(file.path(folder, "reference_tables"), showWarnings = FALSE)
freeze(tx, file.path(folder, "reference_tables", paste0(item_name, "_snapshot.csv")),
       header = TRUE)
