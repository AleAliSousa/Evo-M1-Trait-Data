## Plavcan_etal_1995_Table1_snapshot.R -- verbatim printed-layout transcription -> frozen snapshot
##
## Plavcan, J. M., van Schaik, C. P., & Kappeler, P. M. (1995). Competition, coalitions and canine size
##   in primates. Journal of Human Evolution, 28(3), 245-276. https://doi.org/10.1006/jhev.1995.1019
##
## Item: Table 1 "Behavioral classifications and residual maxillary canine crown height", printed
##   sideways on journal pp. 252-255 = PDF pages 8-11 of Plavcan_1995_article.pdf (p. 252 plus three
##   "Table 1 Continued" pages).
## Why a typed block: the PDF is a scan (one 200-dpi bilevel CCITT image per page, no text layer), so
##   there is nothing to extract at run time. Build HOWTO sec. 3 fallback: a verbatim printed-layout
##   block inside the extract script (the Jacobs_etal_2018_extract_snapshot.R pattern). This script
##   only freezes the block as the snapshot; Plavcan_etal_1995_Table1.R reads the snapshot and does all
##   cleaning.
## Reader: AI assistant (Copilot) transcribed the block by eye from 300-dpi renders of PDF pages 8-11
##   on 2026-11-10. The owner's OCR export (Plavcan_1995_user_ocr_export.xlsx, sheets 'Table 2' to
##   'Table 5'; not a journal file) was used only as a second reading: every disagreement was re-read
##   on the page image (Plavcan_etal_1995_Table1_ocr_crosscheck.csv). Human visual check pending.
##
## Block conventions (one block line = one printed line, in printed order, page by page):
##   * 10 fields separated by "|"; the padding spaces are only for alignment and are trimmed on read:
##       Species | Males: C, I, F | Females: C, I, F | Residuals: Males, Females | References
##   * every page keeps its caption line ("Table 1 Continued" on pp. 253-255), its two header lines and
##     its group heading(s) Catarrhines / Platyrrhines / Prosimians (printed as centred spanning
##     headings; kept in column 1, other cells blank). The four footnotes (a-d) are the last lines.
##   * a spanning header ("Males", "Females", "Residuals") sits over the first of its sub-columns, with
##     blank padding under the rest; "Species" and "References" sit in the sub-header line.
##   * superscript footnote marks are written as Unicode modifier letters: a b c d -> U+1D43 U+1D47
##     U+1D9C U+1D48.
##   * numbers as printed: middle-dot decimal (U+00B7) and minus sign (U+2212); the typographic gap
##     between the minus sign and the digits is not kept. A printed dash is U+2014 (no
##     classification / no value).
##   * a reference cell that wraps over 2-3 printed lines is joined with single spaces; italics (et
##     al., year suffixes a/b, and the whole Macaca nigra row, which is printed in italics) are not
##     kept. Printed spellings are kept (e.g. Cercopithecus nicitans, Alouatta paliatta, Crocket,
##     Peges-Feuillade): corrections belong in the species key / references table, never here.
## Output: <item_name>_snapshot.csv beside this script: 116 rows x 10 columns, UTF-8 with BOM (so Excel
##   shows the middle dots), every field double-quoted, LF line ends, no header line (the printed
##   header lines are rows 2-3 of each page).
## Guard: if the snapshot already exists and any cell differs from the block, the script stops and
##   does not overwrite it (re-freezing is a deliberate act: delete the old file first and say why in
##   the README). An identical snapshot is left untouched.

## ---- 0. Paths: self-locating, so it runs from any working directory ----
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
folder        <- dirname(.sp)
item_name     <- sub("_snapshot\\.R$", "", basename(.sp))      # Plavcan_etal_1995_Table1
snapshot_file <- file.path(folder, paste0(item_name, "_snapshot.csv"))

## ---- 1. The printed table, line by line (pp. 252-255) ----
block <- r"---(
Table 1 Behavioral classifications and residual maxillary canine crown height |       |      |      |         |      |      |            |         |
                         | Males |      |      | Females |      |      | Residualsᵃ |         |
Species                  | Cᵇ    | I    | F    | C       | I    | F    | Males      | Females | References
Catarrhines              |       |      |      |         |      |      |            |         |
Cercocebus albigena      | No    | High | High | Yes     | High | High | 0·153      | −0·367  | Chalmers (1968a,b); Chalmers & Rowell (1971); Waser (1984)
Cercocebus torquatus     | No    | High | High | Yes     | High | High | 0·487      | −0·208  | Bernstein (1976)
Cercopithecus aethiops   | No    | High | High | Yes     | High | High | 0·421      | −0·013  | Henzi (1985); Whitten (1983)
Cercopithecus ascanius   | No    | High | Low  | No      | High | High | 0·408      | 0·085   | Cords (1987, 1988); Jones & Bush (1988); Rowell (1988)
Cercopithecus cephus     | No    | High | Low  | —       | —    | —    | 0·428      | −0·027  | Gautier-Hion & Gautier (1985)
Cercopithecus lhoesti    | No    | High | Low  | —       | —    | —    | 0·383      | −0·029  | Cords (1988)
Cercopithecus mitis      | No    | High | Low  | No      | High | High | 0·396      | −0·096  | Rowell (1972)
Cercopithecus mona       | No    | High | Low  | No      | High | High | 0·489      | 0·035   | Kirkevold & Crocket (1987)
Cercopithecus neglectus  | No    | High | Low  | —       | —    | —    | 0·405      | 0·062   | Cords (1988); Gautier-Hion (1978); Brennan (1985)
Cercopithecus nicitans   | No    | High | Low  | —       | —    | —    | 0·371      | 0·044   | Gautier-Hion & Gautier (1985)
Cercopithecus pogonias   | No    | High | Low  | —       | —    | —    | 0·360      | 0·051   | Cords (1988)
Colobus angolensis       | No    | High | Low  | —       | —    | —    | 0·218      | −0·305  | Groves (1973)
Colobus badiusᶜ          | Yes   | High | High | No      | Low  | High | 0·226      | −0·301  | Struhsaker (1975); Isbell (1984)
Colobus guereza          | No    | High | Low  | No      | Low  | High | 0·370      | 0·046   | Marler (1969, 1972); Oates (1977)
Colobus polykomos        | No    | High | High | No      | Low  | High | 0·345      | −0·170  | Marler (1972)
Colobus satanus          | No    | High | High | —       | —    | —    | 0·052      | −0·432  | Struhsaker (1969); McKey & Waterman (1982)
Colobus verus            | No    | High | High | —       | —    | —    | 0·299      | −0·358  | Oates (1988)
Erythrocebus patas       | No    | High | Low  | No      | High | High | 0·613      | 0·030   | Chism & Rowell (1988)
Gorilla gorilla          | No    | High | Low  | No      | Low  | High | −0·188     | −0·565  | Stewart & Harcourt (1987)
Hylobates concolor       | No    | High | Low  | No      | High | Low  | 0·481      | 0·322   | Schilling (1984); Goustard (1984); Mitani (1985)
Hylobates hoolock        | No    | High | Low  | No      | High | Low  | 0·337      | 0·319   | Roonwal & Mohnot (1977); Mitani (1985)
Hylobates klossi         | No    | High | Low  | No      | High | Low  | 0·280      | 0·324   | Tilson & Tenaza (1982); Tenaza & Tilson (1985); Mitani (1985)
Hylobates lar            | No    | High | Low  | No      | High | Low  | 0·433      | 0·309   | Mitani (1985); Palombit (1993)
Hylobates syndactylus    | No    | High | Low  | No      | High | Low  | 0·348      | 0·184   | Chivers (1978); Curtin & Chivers (1978); Mitani (1985)
Macaca fascicularis      | No    | High | High | Yes     | High | High | 0·678      | −0·031  | Roonwal & Mohnot (1977); Wheatly (1982); Samuels et al. (1987); Walters & Seyfarth (1987)
Macaca fuscata           | No    | High | High | Yes     | High | High | 0·257      | −0·372  | Walters & Seyfarth (1987)
Table 1 Continued        |       |      |      |         |      |      |            |         |
                         | Males |      |      | Females |      |      | Residualsᵃ |         |
Species                  | Cᵇ    | I    | F    | C       | I    | F    | Males      | Females | References
Catarrhines              |       |      |      |         |      |      |            |         |
Macaca mulatta           | No    | High | High | Yes     | High | High | 0·297      | −0·348  | Vessey & Meikle (1987); Ehardt & Bernstein (1986); Walters & Seyfarth (1987)
Macaca nemestrina        | No    | High | High | Yes     | High | High | 0·686      | −0·076  | Roonwal & Mohnot (1977); Caldecott (1986); Ehardt & Bernstein (1986); Walters & Seyfarth (1987)
Macaca nigra             | No    | High | High | —       | —    | —    | 0·715      | −0·093  | Shively et al. (1982); Caldecott (1986)
Macaca sinica            | No    | High | High | Yes     | High | High | 0·461      | −0·002  | Dittus (1986, 1988)
Mandrillus leucophaeus   | No    | High | High | —       | —    | —    | 1·028      | −0·205  | Stammbach (1987)
Miopithecus talapoin     | No    | High | High | —       | —    | —    | 0·431      | −0·026  | Wolfheim (1977); Gautier-Hion (1978); Keverne et al. (1978); Rowell (1988)
Nasalis larvatus         | No    | High | High | —       | —    | —    | 0·231      | −0·320  | Yeager (1990)
Pan paniscus             | No    | Low  | High | No      | Low  | High | −0·384     | −0·645  | Nishida & Hiraiwa-Hasegawa (1987)
Pan troglodytesᵈ         | Yes   | High | High | No      | Low  | High | −0·049     | −0·306  | Morin (1993)
Papio cynocephalus       | No    | High | High | Yes     | High | High | 0·394      | −0·444  | Smith & Whitten (1988); Shopland (1982); Melnick & Pearl (1987); Samuels et al. (1987); Walters & Seyfarth (1987)
Papio hamadryas          | No    | High | High | No      | High | High | 0·560      | −0·283  | Stammbach (1987)
Pongo pygmaeus           | No    | High | Low  | No      | Low  | Low  | −0·094     | −0·350  | Rodman & Mitani (1987)
Presbytis comata         | No    | High | Low  | —       | —    | —    | 0·125      | −0·281  | Ruhiyat (1983)
Presbytis cristata       | No    | High | Low  | No      | Low  | High | 0·308      | −0·201  | Bernstein (1968); Wolfe & Fleagle (1977); Roonwal & Mohnot (1977)
Presbytis entellus       | No    | High | High | No      | Low  | High | 0·264      | −0·168  | Blaffer Hrdy (1977, 1981); Newton (1986, 1987, 1988)
Presbytis melalophos     | No    | High | Low  | No      | Low  | High | 0·091      | −0·427  | Curtin (1976); Curtin & Chivers (1978); Johns (1985); Bennet (1986)
Presbytis obscura        | No    | High | Low  | No      | Low  | High | 0·152      | −0·377  | Curtin (1976); Curtin & Chivers (1978)
Presbytis pileata        | No    | High | Low  | —       | —    | —    | 0·241      | −0·314  | Roonwal & Mohnot (1977); Green (1981); Islam & Husain (1982)
Presbytis potenziani     | No    | High | Low  | No      | Low  | Low  | 0·088      | −0·257  | Tilson & Tenaza (1982); Tenaza & Tilson (1985)
Presbytis rubicunda      | No    | High | Low  | —       | —    | —    | 0·035      | −0·371  | Jatna et al. (1986); Davies (1987)
Table 1 Continued        |       |      |      |         |      |      |            |         |
                         | Males |      |      | Females |      |      | Residualsᵃ |         |
Species                  | Cᵇ    | I    | F    | C       | I    | F    | Males      | Females | References
Catarrhines              |       |      |      |         |      |      |            |         |
Presbytis vetulus        | No    | High | Low  | —       | —    | —    | 0·221      | −0·346  | Rudran (1973); Roonwal & Mohnot (1977); Hladik (1978); Manley (1978)
Simias concolor          | —     | —    | —    | No      | Low  | High | —          | −0·462  | Watanabe (1981)
Theropithecus gelada     | No    | High | High | Yes     | High | High | 0·773      | −0·261  | Stammbach (1987)
Platyrrhines             |       |      |      |         |      |      |            |         |
Alouatta caraya          | No    | High | High | —       | —    | —    | 0·083      | −0·167  | Thorington et al. (1984)
Alouatta paliatta        | No    | High | High | No      | High | High | 0·061      | −0·278  | Milton (1978); Glander (1992)
Alouatta seniculus       | No    | High | High | No      | Low  | High | 0·005      | −0·323  | Neville (1972); Klein & Klein (1975); Glander (1992)
Aotus trivirgatus        | No    | High | Low  | No      | High | Low  | −0·135     | −0·285  | Wright (1985)
Ateles geoffroyiᵈ        | Yes   | High | High | No      | Low  | High | −0·126     | −0·570  | Fedigan & Baxter (1984); Chapman (1990)
Ateles paniscusᵈ         | Yes   | High | High | No      | Low  | High | −0·030     | −0·436  | McFarland Symington (1990); White (1986)
Brachyteles arachnoidesᵈ | Yes   | High | High | No      | Low  | Low  | −0·403     | −0·646  | Milton (1985); Strier (1986, 1992); Lemos de Sa & Glander (1993)
Callicebus moloch        | No    | Low  | Low  | No      | Low  | Low  | −0·287     | −0·266  | Kinzey et al. (1977); Robinson et al. (1987)
Callicebus torquatus     | No    | Low  | Low  | No      | Low  | Low  | −0·467     | −0·510  | Defler (1983); Robinson et al. (1987)
Cebuella pygmaea         | No    | Low  | Low  | No      | Low  | Low  | −0·057     | −0·107  | Hernandez-Camacho & Cooper (1986); Goldizen (1987)
Cebus apella             | No    | High | High | Yes     | High | High | 0·398      | 0·119   | Janson (1984)
Lagothrix lagotricha     | No    | Low  | High | —       | —    | —    | 0·119      | −0·399  | Leo Luna (1980)
Saguinus fuscicollis     | No    | Low  | High | No      | High | Low  | 0·136      | 0·145   | Goldizen & Terborgh (1986)
Saguinus midas           | No    | Low  | High | No      | High | Low  | −0·035     | 0·015   | Goldizen (1987)
Saguinus oedipus         | No    | Low  | High | No      | High | High | 0·038      | 0·050   | Dawson (1977); Neyman (1977)
Saimiri oerstedi         | No    | High | Low  | No      | Low  | High | 0·176      | −0·284  | Boinski (1987); Mitchell et al. (1991)
Saimiri sciureus         | No    | High | Low  | Yes     | High | High | 0·155      | −0·115  | Klein & Klein (1975); Mitchell et al. (1991)
Prosimians               |       |      |      |         |      |      |            |         |
Arctocebus calabarensis  | No    | Low  | Low  | No      | Low  | Low  | −0·217     | −0·105  | Charles-Dominique (1977)
Avahi laniger            | No    | Low  | Low  | No      | Low  | Low  | −0·625     | −0·649  | Harcourt (1991)
Cheirogaleus medius      | No    | Low  | Low  | No      | Low  | Low  | −0·143     | −0·082  | Petter (1988)
Table 1 Continued        |       |      |      |         |      |      |            |         |
                         | Males |      |      | Females |      |      | Residualsᵃ |         |
Species                  | Cᵇ    | I    | F    | C       | I    | F    | Males      | Females | References
Prosimians               |       |      |      |         |      |      |            |         |
Eulemur coronatus        | No    | High | High | No      | High | High | 0·174      | 0·072   | Kappeler (1992)
Eulemur fulvus           | No    | High | High | No      | High | High | 0·291      | 0·128   | Pereira et al. (1990)
Eulemur macaco           | No    | High | High | No      | High | High | 0·175      | 0·140   | Colquhoun (1993)
Eulemur mongoz           | No    | High | Low  | No      | Low  | Low  | 0·201      | 0·028   | Harrington (1978)
Eulemur rubriventer      | No    | High | Low  | No      | Low  | Low  | 0·186      | 0·155   | Overdorff (1991)
Galago elegantulus       | No    | Low  | Low  | No      | Low  | Low  | 0·117      | 0·063   | Charles-Dominique (1977)
Galago moholi            | No    | Low  | Low  | No      | Low  | Low  | −0·014     | −0·023  | Harcourt & Bearder (1989)
Galago senegalensis      | No    | Low  | Low  | No      | Low  | Low  | 0·031      | −0·074  | Bearder & Doyle (1974)
Galagoides alleni        | No    | Low  | Low  | No      | Low  | Low  | −0·049     | −0·218  | Charles-Dominique (1977)
Galagoides demidovii     | No    | Low  | Low  | No      | Low  | Low  | 0·055      | −0·135  | Charles-Dominique (1977)
Galagoides zanzibaricus  | No    | Low  | Low  | No      | Low  | Low  | 0·022      | −0·027  | Harcourt & Nash (1986)
Hapalemur griseus        | No    | Low  | Low  | No      | Low  | Low  | −0·268     | −0·249  | Petter & Peyrieras (1975)
Indri indri              | No    | Low  | Low  | No      | Low  | Low  | −0·354     | −0·453  | Pollock (1979)
Lemur catta              | No    | High | High | No      | High | High | 0·161      | −0·006  | Kappeler (1990b)
Lepilemur mustelinus     | No    | Low  | Low  | No      | Low  | Low  | 0·199      | −0·075  | Russell (1977)
Lepilemur ruficaudatus   | No    | Low  | Low  | No      | Low  | Low  | 0·163      | −0·036  | Russell (1977)
Loris tardigradus        | No    | Low  | Low  | No      | Low  | Low  | 0·170      | 0·184   | Petter & Hladik (1970)
Microcebus murinus       | No    | High | Low  | No      | Low  | Low  | −0·013     | 0·059   | Peges-Feuillade (1988)
Microcebus rufus         | No    | High | Low  | No      | Low  | Low  | −0·188     | −0·118  | Harcourt & Thornback (1990)
Otolemur crassicaudatus  | No    | Low  | Low  | No      | Low  | Low  | 0·167      | 0·023   | Bearder & Doyle (1974)
Otolemur garnettii       | No    | Low  | Low  | No      | Low  | Low  | −0·078     | −0·100  | Nash & Harcourt (1986)
Perodicticus potto       | No    | Low  | Low  | No      | Low  | Low  | 0·089      | 0·065   | Charles-Dominique (1977)
Propithecus diadema      | No    | Low  | High | No      | Low  | High | −0·390     | −0·278  | Wright (1988)
Propithecus verreauxi    | No    | High | High | No      | Low  | High | −0·194     | −0·259  | Richard (1992)
Varecia variegata        | No    | High | Low  | No      | High | Low  | 0·263      | 0·222   | Kaufman (1991)
ᵃResiduals are from an isometric line passed through a data set treating male and female values as separate points. |       |      |      |         |      |      |            |         |
ᵇAbbreviations are as follows: C is coalitions, I is intensity, and F is frequency. |       |      |      |         |      |      |            |         |
ᶜClassification of coalitions in males is tentative, see text. |       |      |      |         |      |      |            |         |
ᵈClassification of coalitions in males is for between-group behavior. Within-group behavior is low-intensity, high-frequency. |       |      |      |         |      |      |            |         |
)---"

## ---- 2. Parse the block: exactly 10 fields per line, padding trimmed, blanks kept as "" ----
if (!grepl("0\u{00B7}153", block, fixed = TRUE) || !grepl("\u{2212}0\u{00B7}367", block, fixed = TRUE))
  stop("The block was not read as UTF-8 (middle dot / minus sign lost). Run with R >= 4.2 or a UTF-8 locale.",
       call. = FALSE)
lines <- strsplit(block, "\n", fixed = TRUE)[[1]]
lines <- sub("\r$", "", lines)
lines <- lines[nzchar(trimws(lines))]
nf <- lengths(strsplit(paste0(lines, "|END"), "|", fixed = TRUE)) - 1L   # "|END" keeps a trailing empty field
if (any(nf != 10L))
  stop("Block lines without exactly 10 fields: ", paste(which(nf != 10L), collapse = ", "), call. = FALSE)
snap <- do.call(rbind, lapply(strsplit(paste0(lines, "|END"), "|", fixed = TRUE),
                              function(f) trimws(f[1:10])))
dimnames(snap) <- NULL
if (nrow(snap) != 116L) stop("expected 116 printed lines, got ", nrow(snap), call. = FALSE)
if (sum(grepl("^Table 1", snap[, 1])) != 4L) stop("expected 4 caption lines (pp. 252-255)", call. = FALSE)

## ---- 3. Freeze: write once; afterwards refuse to overwrite a differing copy ----
csv_line <- function(r) paste0('"', gsub('"', '""', r, fixed = TRUE), '"', collapse = ",")
csv_txt  <- enc2utf8(paste0(paste(apply(snap, 1, csv_line), collapse = "\n"), "\n"))
if (file.exists(snapshot_file)) {
  old <- as.matrix(utils::read.csv(snapshot_file, header = FALSE, colClasses = "character",
                                   na.strings = character(0), fileEncoding = "UTF-8-BOM",
                                   check.names = FALSE, strip.white = FALSE))
  dimnames(old) <- NULL
  if (!identical(dim(old), dim(snap)) || !all(old == snap))
    stop("Frozen snapshot ", basename(snapshot_file), " differs from the transcription block: refusing ",
         "to overwrite it. Re-freezing is deliberate: compare the two against the PDF, delete the old ",
         "file, rerun, and record the change in the README.", call. = FALSE)
  message("Frozen snapshot unchanged (identical to the block): ", basename(snapshot_file))
} else {
  con <- file(snapshot_file, open = "wb")
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)               # UTF-8 BOM: Excel shows the middle dots
  writeBin(charToRaw(csv_txt), con)
  close(con)
  message("Wrote frozen snapshot: ", snapshot_file, " (", nrow(snap), " rows x ", ncol(snap), " columns)")
}
