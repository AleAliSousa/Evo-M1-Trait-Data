## Kirk_Kay_2004_Table1_snapshot.R -- builds ONLY Kirk_Kay_2004_Table1_snapshot.csv
##
## Kirk, E. C., & Kay, R. F. (2004). The evolution of high visual acuity in the Anthropoidea. Chapter 20 of
## Ross & Kay (eds), Anthropoid Origins: New Visions, Kluwer/Plenum, pp. 539-602;
## doi:10.1007/978-1-4419-8873-7_20.  Table 1 (Behavioral measurements of visual acuity in various mammalian taxa; 37 species).
##
## Faithful capture per __HOWTO_make_a_snapshot.md: printed strings verbatim -- ranges kept as printed
## (en dash), substrate qualifiers kept inside the value string ("2.5 (air); 3.3 (water)"), printed
## misspellings kept, genus-level rows kept as "... sp.". Wrapped cells (multi-reference sources) are joined
## with a single space. Nothing is corrected here; the species crosswalk carries the resolutions and
## Kirk_Kay_2004_Table1.R does the typing/splitting.
##
## The table is a typed transcription of the printed chapter table (born-digital PDF; the text layer is
## audited, not parsed): no image processing or PDF layout parsing is needed, so this is R.
## R port (2026-11-12) of Kirk_Kay_2004_Table1_snapshot.py, now retired as Kirk_Kay_2004_Table1_snapshot.py.retired.
## Verified in a temp dir (never in place): regenerated CSV is byte-identical to the committed
## snapshot (LF line ends, UTF-8, no BOM). An existing frozen snapshot that differs is never overwritten.
##
## Run:  Rscript Kirk_Kay_2004_Table1_snapshot.R [--verify]
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
item_name <- sub("_snapshot\\.R$", "", basename(.sp))   # "Kirk_Kay_2004_Table1"
PDF       <- file.path(folder, "kirk_kay_2004.pdf")
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))
EN <- "\u2013"   # en dash as printed in ranges

# (scientific name, common name, activity pattern, visual acuity (c/deg), source)
rows <- list(
 c("Homo sapiens", "Human", "Diurnal", paste0("50.0", EN, "77.0"), "Cavonius and Robbins, 1973; DeValois et al., 1974"),
 c("Macaca mulatta", "Rhesus macaque", "Diurnal", paste0("46.2", EN, "53.6"), "Cowey and Ellis, 1967; Cavonius and Robbins, 1973"),
 c("Macaca nemestrina", "Pig-tailed macaque", "Diurnal", "46.0", "DeValois et al., 1974"),
 c("Macaca fascicularis", "Crab-eating macaque", "Diurnal", "46.0", "DeValois et al., 1974"),
 c("Saimiri sciureus", "Squirrel monkey", "Diurnal", "40.5", "Cowey and Ellis, 1967"),
 c("Equus caballus", "Domestic horse", "Cathemeral", paste0("10.9", EN, "23.3"), "Timney and Keil, 1992"),
 c("Aotus trivirgatus", "Northern owl monkey", "Nocturnal", "10.0", "Jacobs, 1977"),
 c("Camelus bactrius", "Bactrian camel", "Cathemeral", "10.0", "Harman et al., 2001"),
 c("Felis catus", "Domestic cat", "Cathemeral", paste0("5.0", EN, "8.9"), "Bisti and Maffei, 1974; Blake et al., 1974; Jacobson et al., 1976"),
 c("Lemur catta", "Ring-tailed lemur", "Diurnal", paste0("6.0", EN, "6.7"), "Neuringer et al., 1981"),
 c("Suricata suricatta", "Meerkat", "Diurnal", "6.3", "Moran et al., 1983"),
 c("Otolemur crassicaudatus", "Fat-tailed bush baby", "Nocturnal", paste0("4.8", EN, "6.0"), "Langston et al., 1986"),
 c("Zalophus californicus", "California sea lion", "Cathemeral", paste0("5.4", EN, "5.7"), "Schusterman and Balliet, 1970b"),
 c("Myrmecobius fasciatus", "Numbat", "Diurnal", "5.2", "Arrese et al., 2000"),
 c("Lagenorhynchus obliquidens", "Pacific white-sided dolphin", "Cathemeral", "5.0", "Spong and White, 1971"),
 c("Eumetopias jubata", "Stellar sea lion", "Cathemeral", "4.2 (water)", "Schusterman and Balliet, 1970a"),
 c("Spermophilus beecheyi", "California ground squirrel", "Diurnal", "4.0", "Jacobs et al., 1980"),
 c("Sciurus griseus", "Western gray squirrel", "Diurnal", "3.9", "Jacobs et al., 1982"),
 c("Sciurus niger", "Fox squirrel", "Diurnal", "3.9", "Jacobs et al., 1982"),
 c("Sciurus caroliniensis", "Eastern gray squirrel", "Diurnal", "3.9", "Jacobs et al., 1982"),
 c("Tursiops truncatus", "Bottlenose dolphin", "Cathemeral", paste0("1.6", EN, "2.5 (air); 2.5", EN, "3.8 (water)"), "Herman et al., 1975"),
 c("Phoca vitulina", "Harbour seal", "Cathemeral", "3.6", "Schusterman and Balliet, 1970a"),
 c("Pteropus giganteus", "Indian flying fox", "Nocturnal", "3.5", "Neuweiler, 1962; cited in Pettigrew et al., 1988"),
 c("Oryctolagus cuniculus", "Old World rabbit", "Cathemeral", paste0("1.5", EN, "3.0"), "Van Hof, 1967; Vaney, 1980"),
 c("Dasyurus hallucatus", "Quoll", "Nocturnal", paste0("2.3", EN, "2.8"), "Harman et al., 1986"),
 c("Amblonyx cinerea", "Asian clawless otter", "Cathemeral", paste0("1.9", EN, "2.2 (air); 2.0 (water)"), "Balliet and Schusterman, 1971"),
 c("Sminthopsis crassicaudata", "Fat-tailed dunnart", "Nocturnal", "2.4", "Arrese et al., 1999"),
 c("Tupaia belangeri", "Tree shrew", "Diurnal", paste0("1.2", EN, "2.4"), "Petry et al., 1984"),
 c("Mustela putorius", "European polecat", "Cathemeral", paste0("1.2", EN, "1.9"), "Neumann and Schmidt, 1959, cited in Mass and Supin, 2000"),
 c("Mustela erminea", "Ermine", "Cathemeral", paste0("1.2", EN, "1.9"), "Neumann and Schmidt, 1959, cited in Mass and Supin, 2000"),
 c("Rattus norvegicus", "Pigmented laboratory rat", "Nocturnal", paste0("1.2", EN, "1.6"), "Birch and Jacobs, 1979; Seymoure and Juraska, 1997"),
 c("Tarsipes rostratus", "Honey possum", "Cathemeral", "0.6", "Arrese et al., 2002"),
 c("Mus musculus", "House mouse", "Cathemeral", "0.5", "Sinex et al., 1979; Prusky et al., 2000"),
 c("Mesocricetus auratus", "Golden hamster", "Nocturnal", "0.5", "Emerson, 1980"),
 c("Phyllostomus hastatus", "Greater spear-nosed bat", "Nocturnal", paste0("0.1", EN, "0.4"), "Suthers, 1966"),
 c("Artibeus jamaicensis", "Jamaican fruit-eating bat", "Nocturnal", paste0("0.1", EN, "0.4"), "Suthers, 1966"),
 c("Myotis lucifugus", "Little brown bat", "Nocturnal", paste0("0.05", EN, "0.1"), "Suthers, 1966")
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
