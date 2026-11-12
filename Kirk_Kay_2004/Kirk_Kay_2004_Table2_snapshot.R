## Kirk_Kay_2004_Table2_snapshot.R -- builds ONLY Kirk_Kay_2004_Table2_snapshot.csv
##
## Kirk, E. C., & Kay, R. F. (2004). The evolution of high visual acuity in the Anthropoidea. Chapter 20 of
## Ross & Kay (eds), Anthropoid Origins: New Visions, Kluwer/Plenum, pp. 539-602;
## doi:10.1007/978-1-4419-8873-7_20.  Table 2 (Anatomical estimates of visual acuity; 42 species).
##
## Faithful capture per __HOWTO_make_a_snapshot.md: printed strings verbatim -- ranges kept as printed
## (en dash), substrate qualifiers kept inside the value string ("2.5 (air); 3.3 (water)"), printed
## misspellings kept, genus-level rows kept as "... sp.". Wrapped cells (multi-reference sources) are joined
## with a single space. Nothing is corrected here; the species crosswalk carries the resolutions and
## Kirk_Kay_2004_Table2.R does the typing/splitting.
##
## The table is a typed transcription of the printed chapter table (born-digital PDF; the text layer is
## audited, not parsed): no image processing or PDF layout parsing is needed, so this is R.
## R port (2026-11-12) of Kirk_Kay_2004_Table2_snapshot.py, now retired as Kirk_Kay_2004_Table2_snapshot.py.retired.
## Verified in a temp dir (never in place): regenerated CSV is byte-identical to the committed
## snapshot (LF line ends, UTF-8, no BOM). An existing frozen snapshot that differs is never overwritten.
##
## Run:  Rscript Kirk_Kay_2004_Table2_snapshot.R [--verify]
## --verify re-extracts the PDF text (pdftools::pdf_text, per page) and asserts that every transcribed
## token of every row appears on the pages of the table -- the transcription audit. Wrapped-cell joins
## mean tokens are checked individually, not as whole cells.

suppressPackageStartupMessages(library(pdftools))

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
folder    <- dirname(.sp)
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # "Kirk_Kay_2004_Table2"
PDF       <- file.path(folder, "kirk_kay_2004.pdf")
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))
EN <- "\u2013"   # en dash as printed in ranges

# (scientific name, common name, activity pattern, visual acuity (c/deg), source)
rows <- list(
 c("Homo sapiens", "Human", "Diurnal", paste0("47.0", EN, "86.0"), "Hirsch and Curcio, 1989; Curcio et al., 1990"),
 c("Cebus apella", "Tufted capuchin", "Diurnal", paste0("38.8", EN, "54.8"), "Andrade da Costa and Hokoç, 2000"),
 c("Callithrix jacchus", "Common marmoset", "Diurnal", "30.0", "Troilo et al., 1993"),
 c("Equus caballus", "Domestic horse", "Cathemeral", paste0("16.4", EN, "20.4"), "Timney and Keil, 1992"),
 c("Camelus dromedarius", "Dromedary camel", "Cathemeral", "10.4", "Harman et al., 2001"),
 c("Aotus azarae", "Azara’s owl monkey", "Nocturnal or Cathemeral", "8.3", "Yamada et al., 2001"),
 c("Felis catus", "Domestic cat", "Cathemeral", "8.1", "Hughes, 1975"),
 c("Otolemur crassicaudatus", "Fat-tailed bush baby", "Nocturnal", paste0("6.2", EN, "7.5"), "DeBruyn et al., 1980; Dkhissi-Benyahya et al., 2001"),
 c("Callorhinus ursinus", "Northern fur seal", "Cathemeral", paste0("5.6", EN, "7.1"), "Mass and Supin, 1992"),
 c("Myrmecobius fasciatus", "Numbat", "Diurnal", "6.3", "Arrese et al., 2000"),
 c("Pteropus poliocephalus", "Gray-headed flying fox", "Nocturnal", "5.5", "Pettigrew et al., 1988"),
 c("Microcebus murinus", "Gray mouse lemur", "Nocturnal", "4.9", "Dkhissi-Benyahya et al., 2001"),
 c("Trichosurus vulpecula", "Brush-tailed possum", "Nocturnal", "4.8", "Freeman and Tancred, 1978"),
 c("Enhydra lutris", "Sea otter", "Diurnal", "4.2 (air and water)", "Mass and Supin, 2000"),
 c("Balaenoptera acutorostrata", "Minke whale", "Cathemeral", paste0("3.9", EN, "4.2 (water)"), "Murayama et al., 1992"),
 c("Loxodonta africana", "African elephant", "Cathemeral", "4.1", "Stone and Halasz, 1989"),
 c("Pteropus scapulatus", "Little red flying fox", "Nocturnal", "4.0", "Pettigrew et al., 1988"),
 c("Odobenus rosmarus", "Pacific walrus", "Cathemeral", "3.8", "Mass, 1992"),
 c("Delphinus delphis", "Common dolphin", "Cathemeral", "3.8 (water)", "Dral, 1983"),
 c("Pseudorca crassidens", "False killer whale", "Cathemeral", "3.3 (water)", "Murayama and Somiya, 1998"),
 c("Tursiops truncatus", "Bottlenose dolphin", "Cathemeral", "2.5 (air); 3.3 (water)", "Mass and Supin, 1995"),
 c("Rousettus sp.", "Rousette fruit bat", "Nocturnal", "3.0", "Marks, 1980; cited in Pettigrew et al., 1988"),
 c("Phocoena phocoena", "Harbor porpoise", "Cathemeral", "2.1 (air); 2.7 (water)", "Mass and Supin, 1986"),
 c("Eschrichtius robustus", "Gray whale", "Cathemeral", "2.7 (water)", "Mass and Supin, 1997"),
 c("Lagenorhynchus obliquidens", "Pacific white-sided dolphin", "Cathemeral", "2.7 (water)", "Murayama and Somiya, 1998"),
 c("Delphinapterus leucas", "Beluga whale", "Cathemeral", "2.6 (water)", "Murayama and Somiya, 1998"),
 c("Dasyurus hallucatus", "Quoll", "Nocturnal", "2.6", "Harman et al., 1986"),
 c("Phocoenoides dalli", "Dall’s porpoise", "Cathemeral", paste0("2.5", EN, "2.6 (water)"), "Murayama et al., 1992, 1995"),
 c("Phascolarctos cinereus", "Koala", "Cathemeral", "2.4", "Schmid et al., 1992"),
 c("Sminthopsis crassicaudata", "Fat-tailed dunnart", "Nocturnal", "2.3", "Arrese et al., 1999"),
 c("Macroderma gigas", "Australian false vampire bat", "Nocturnal", "1.9", "Pettigrew et al., 1988"),
 c("Mesocricetus auratus", "Golden hamster", "Nocturnal", "1.8", "Tiao and Blakemore, 1976"),
 c("Megaderma lyra", "Greater false vampire bat", "Nocturnal", "1.5", "Pettigrew et al., 1988"),
 c("Artibeus cinereus", "Gervaif fruit eating bat", "Nocturnal", "1.4", "Pettigrew et al., 1988"),
 c("Taphozous georgianus", "Brown sheath-tailed bat", "Nocturnal", "1.3", "Pettigrew et al., 1988"),
 c("Sotalia fluviatilis", "River dolphin (tucuxi)", "Cathemeral", "0.9 (air); 1.2 (water)", "Mass and Supin, 1999"),
 c("Saccopteryx sp.", "White-lined bat", "Nocturnal", "1.0", "Marks, 1980; cited in Pettigrew et al., 1988"),
 c("Tarsipes rostratus", "Honey possum", "Cathemeral", "0.8", "Dunlop et al., 1994"),
 c("Inia geoffrensis", "Amazon dolphin (boutos)", "Cathemeral", "0.6 (air); 0.8 (water)", "Mass and Supin, 1989, 1999"),
 c("Eptesicus sp.", "Big brown bat", "Nocturnal", "0.7", "Marks, 1980; cited in Pettigrew et al., 1988"),
 c("Nyctophilus gouldi", "Gould’s long-eared bat", "Nocturnal", "0.6", "Pettigrew et al., 1988"),
 c("Rhinolophus rouxi", "Horseshoe bat", "Nocturnal", "0.4", "Pettigrew et al., 1988")
)
HDR <- c("scientific_name", "common_name", "activity_pattern", "visual_acuity_cdeg_as_printed", "source_as_printed")
snap <- as.data.frame(do.call(rbind, rows), stringsAsFactors = FALSE)
names(snap) <- HDR

## pandas/csv-style minimal quoting, "\n" line ends, UTF-8 without BOM
csv_cell <- function(x) ifelse(grepl("[\",\r\n]", x), paste0("\"", gsub("\"", "\"\"", x), "\""), x)
out <- paste0(paste(c(paste(csv_cell(HDR), collapse = ","),
                      apply(as.matrix(snap), 1, function(r) paste(csv_cell(r), collapse = ","))), collapse = "\n"), "\n")
path <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(path)) {
  old <- readChar(path, file.info(path)$size, useBytes = TRUE); Encoding(old) <- "UTF-8"
  if (!identical(old, out)) stop("REFUSING to overwrite differing ", path, call. = FALSE)
  cat("unchanged", basename(path), ":", nrow(snap), "rows\n")
} else {
  con <- file(path, "wb"); writeBin(charToRaw(enc2utf8(out)), con); close(con)
  cat("wrote", basename(path), ":", nrow(snap), "rows\n")
}

if ("--verify" %in% commandArgs(TRUE)) {
  norm <- function(s) {
    s <- gsub("[\u2018\u2019]", "'", s)
    s <- stringi::stri_trans_nfkd(s)
    gsub("\\p{M}", "", s, perl = TRUE)
  }
  pages <- vapply(norm(pdf_text(PDF)), identity, "")
  span <- integer(0)
  anchor <- c(Table1 = "Behavioral measurements of visual acuity", Table2 = "Anatomical estimates of visual acuity")
  key <- sub("^.*_", "", item_name)
  num <- sub("^Table", "", key)
  for (p in seq_along(pages)) {
    if (grepl(anchor[[key]], pages[p], fixed = TRUE)) span <- c(span, p)
    if (grepl(paste0("Table ", num, "."), pages[p], fixed = TRUE) && grepl("Continued", pages[p], fixed = TRUE) && length(span)) span <- c(span, p)
  }
  span <- sort(unique(span)); text <- paste(pages[span], collapse = "\n"); bad <- 0L
  for (i in seq_len(nrow(snap))) for (cell in unlist(snap[i, ])) {
    toks <- strsplit(trimws(norm(gsub("[;()]", " ", cell))), "\\s+")[[1]]
    for (tok in toks[nzchar(toks)]) if (!grepl(tok, text, fixed = TRUE)) {
      cat("  !! token not found: ", tok, " (row ", snap$scientific_name[i], ")\n", sep = ""); bad <- bad + 1L }
  }
  cat(key, ": pages ", paste(span, collapse = ","), " verified", if (bad) paste(" with", bad, "misses") else "", "\n", sep = "")
  if (bad) quit(status = 1)
}
