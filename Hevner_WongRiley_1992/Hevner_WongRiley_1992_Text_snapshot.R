# Hevner_WongRiley_1992_Text_snapshot.R ---------------------------------------
#
# Builds the frozen, CONSTRUCTED snapshot of Hevner & Wong-Riley (1992)
# "Entorhinal cortex of the human, monkey, and rat: Metabolic map as revealed
# by cytochrome oxidase", J Comp Neurol 326: 451-469, doi 10.1002/cne.903260310.
#
#   Hevner_WongRiley_1992_Text_snapshot.csv   every NUMERIC value printed in the
#       ABSTRACT (p. 451), MATERIALS AND METHODS (p. 452) and RESULTS (pp. 453,
#       455, 459): specimen numbers, species, body weights, ages, postmortem
#       interval, fixation, anesthesia, section thickness, antibody dilution,
#       field counts, CO-island diameter and the island / dark-spot counts.
#
# The paper prints NO table and NO densitometry (all 19 PDF pages inspected:
# Figs. 1-9 are photomicrographs). Figure scale bars (0.5, 1, 2 mm) are not
# data and are not rowed. The DISCUSSION prints no new numeric value.
#
# Source: scanned two-column journal PDF with OCR text layer (columns
# interleaved; "µm" rendered as "km"/"pm"; "ml/kg" as "mlikg"). Every number
# below was read from 170-220 dpi page renders of pp. 451, 452, 453, 455, 459
# (__HOWTO_make_a_snapshot.md method 5, the WongRiley_etal_1993_Text pattern).
# This script writes the frozen file and refuses to overwrite a frozen copy
# that differs; the build script READS it. No cleaning happens here.
#
# Fidelity decisions:
#  * One row per printed value LEXEME; a printed range ("300-400 g") is ONE row
#    (value_printed keeps the range; the build parses low/high). Number words
#    ("Seven", "six", "two", "four", "three", "Five") are kept as printed.
#  * "~200-250" keeps the tilde in stat_as_printed. "ages 3 days to 80 years"
#    gives two rows (range low, range high) because the units differ.
#  * Antibody dilutions "1:1,000 to 1:4,000" give two rows with the dilution
#    factor as the value (1000, 4000).
#  * The Results "3-day-old" is a restatement of the Methods age range.
#
# Transcribed by an AI assistant (Claude) on 2026-11-18 from page renders.
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
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))

printed_text <- r"-[
text_row|page|section|location|passage_as_printed|quantity|species_as_printed|region_as_printed|layer_as_printed|group_as_printed|value_printed|units_printed|stat_as_printed|cited_ref
1|451|ABSTRACT|paragraph 2|In the EC from one human hemisphere, ~200-250 CO-reactive layer II islands were present.|number of CO-reactive layer II islands|human|EC (one hemisphere)|II|adult|200-250|islands|~ (approximately), range|
2|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|number of animals|Sprague-Dawley rats|||adult male|Seven|rats|count|
3|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|body weight|Sprague-Dawley rats|||adult male|300-400|g|range|
4|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|anesthetic concentration (chloral hydrate)|Sprague-Dawley rats|||adult male|4|%||
5|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|anesthetic dose (chloral hydrate, i.p.)|Sprague-Dawley rats|||adult male|10|ml/kg||
6|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|perfusion volume (warm phosphate-buffered saline)|Sprague-Dawley rats|||adult male|30|ml||
7|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|perfusion volume (cold buffered fixative)|Sprague-Dawley rats|||adult male|100|ml||
8|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|Seven adult male Sprague-Dawley rats (300-400 g) were anesthetized with 4% chloral hydrate (10 ml/kg i.p.) and perfused transcardially with 30 ml warm phosphate-buffered saline, followed by 100 ml cold buffered fixative containing 4% paraformaldehyde.|fixative concentration (paraformaldehyde)|Sprague-Dawley rats|||adult male|4|%||
9|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|The brains were removed, postfixed by immersion in cold buffered fixative for 1 hour, and cryoprotected with increasing concentrations of sucrose (4-30%) in buffer.|postfixation duration (immersion)|Sprague-Dawley rats|brain||adult male|1|hour||
10|452|MATERIALS AND METHODS|Animal tissues, paragraph 1|The brains were removed, postfixed by immersion in cold buffered fixative for 1 hour, and cryoprotected with increasing concentrations of sucrose (4-30%) in buffer.|cryoprotectant concentration (sucrose)|Sprague-Dawley rats|brain||adult male|4-30|%|range (increasing)|
11|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Monkey EC specimens were obtained from six adult male and female macaques (two Macaca fascicularis, two M. radiata, and two M. mulatta; 2.7-6.7 kg) used primarily for another study; details of their treatment were given previously (Hevner and Wong-Riley, '91).|number of animals|macaques|EC||adult male and female|six|macaques|count|
12|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Monkey EC specimens were obtained from six adult male and female macaques (two Macaca fascicularis, two M. radiata, and two M. mulatta; 2.7-6.7 kg) used primarily for another study; details of their treatment were given previously (Hevner and Wong-Riley, '91).|number of animals|Macaca fascicularis|EC||adult|two|animals|count|
13|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Monkey EC specimens were obtained from six adult male and female macaques (two Macaca fascicularis, two M. radiata, and two M. mulatta; 2.7-6.7 kg) used primarily for another study; details of their treatment were given previously (Hevner and Wong-Riley, '91).|number of animals|M. radiata|EC||adult|two|animals|count|
14|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Monkey EC specimens were obtained from six adult male and female macaques (two Macaca fascicularis, two M. radiata, and two M. mulatta; 2.7-6.7 kg) used primarily for another study; details of their treatment were given previously (Hevner and Wong-Riley, '91).|number of animals|M. mulatta|EC||adult|two|animals|count|
15|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Monkey EC specimens were obtained from six adult male and female macaques (two Macaca fascicularis, two M. radiata, and two M. mulatta; 2.7-6.7 kg) used primarily for another study; details of their treatment were given previously (Hevner and Wong-Riley, '91).|body weight|macaques|||adult male and female|2.7-6.7|kg|range|
16|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|For anesthesia, the monkeys received ketamine (20 mg/kg i.m.) and sodium pentobarbital (30 mg/kg i.v. plus 30 mg/kg i.p., or 65 mg/kg i.v.).|anesthetic dose (ketamine, i.m.)|macaques|||adult|20|mg/kg||
17|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|For anesthesia, the monkeys received ketamine (20 mg/kg i.m.) and sodium pentobarbital (30 mg/kg i.v. plus 30 mg/kg i.p., or 65 mg/kg i.v.).|anesthetic dose (sodium pentobarbital, i.v.)|macaques|||adult|30|mg/kg|plus 30 mg/kg i.p.|
18|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|For anesthesia, the monkeys received ketamine (20 mg/kg i.m.) and sodium pentobarbital (30 mg/kg i.v. plus 30 mg/kg i.p., or 65 mg/kg i.v.).|anesthetic dose (sodium pentobarbital, i.p., in addition to i.v.)|macaques|||adult|30|mg/kg||
19|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|For anesthesia, the monkeys received ketamine (20 mg/kg i.m.) and sodium pentobarbital (30 mg/kg i.v. plus 30 mg/kg i.p., or 65 mg/kg i.v.).|anesthetic dose (sodium pentobarbital, i.v., alternative regimen)|macaques|||adult|65|mg/kg|or|
20|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Blocks containing the EC were dissected from the fresh monkey brains, fixed by immersion for 4-6 hours in cold buffered fixative containing 4% paraformaldehyde, and cryoprotected in sucrose.|fixation duration (immersion)|macaques|EC blocks||adult|4-6|hours|range|
21|452|MATERIALS AND METHODS|Animal tissues, paragraph 2|Blocks containing the EC were dissected from the fresh monkey brains, fixed by immersion for 4-6 hours in cold buffered fixative containing 4% paraformaldehyde, and cryoprotected in sucrose.|fixative concentration (paraformaldehyde)|macaques|EC blocks||adult|4|%||
22|452|MATERIALS AND METHODS|Human tissue|Human EC specimens were obtained at autopsy (12-24 hours postmortem) from normal individuals without evidence of neurological disease.|postmortem interval before fixation|human|EC||all specimens|12-24|hours|range|
23|452|MATERIALS AND METHODS|Human tissue|Specimens from six hemispheres from four individuals (ages 3 days to 80 years) were found acceptable.|number of hemispheres|human|EC||all specimens|six|hemispheres|count|
24|452|MATERIALS AND METHODS|Human tissue|Specimens from six hemispheres from four individuals (ages 3 days to 80 years) were found acceptable.|number of individuals|human|EC||all specimens|four|individuals|count|
25|452|MATERIALS AND METHODS|Human tissue|Specimens from six hemispheres from four individuals (ages 3 days to 80 years) were found acceptable.|age (youngest)|human|||all specimens|3|days|range low|
26|452|MATERIALS AND METHODS|Human tissue|Specimens from six hemispheres from four individuals (ages 3 days to 80 years) were found acceptable.|age (oldest)|human|||all specimens|80|years|range high|
27|452|MATERIALS AND METHODS|Histology|Cryoprotected specimens were sectioned at 30 µm (rat), 30-40 µm (monkey), or 40-60 µm (human) in the coronal, sagittal, and horizontal planes.|section thickness|rat|EC|||30|µm||
28|452|MATERIALS AND METHODS|Histology|Cryoprotected specimens were sectioned at 30 µm (rat), 30-40 µm (monkey), or 40-60 µm (human) in the coronal, sagittal, and horizontal planes.|section thickness|monkey|EC|||30-40|µm|range|
29|452|MATERIALS AND METHODS|Histology|Cryoprotected specimens were sectioned at 30 µm (rat), 30-40 µm (monkey), or 40-60 µm (human) in the coronal, sagittal, and horizontal planes.|section thickness|human|EC|||40-60|µm|range|
30|452|MATERIALS AND METHODS|Histology|For immunohistochemistry, antibodies were used at dilutions of 1:1,000 to 1:4,000 and were detected by the indirect immunoperoxidase method.|antibody dilution (anti-CO), most concentrated|all species||||1000|dilution factor (1:x)|range low|
31|452|MATERIALS AND METHODS|Histology|For immunohistochemistry, antibodies were used at dilutions of 1:1,000 to 1:4,000 and were detected by the indirect immunoperoxidase method.|antibody dilution (anti-CO), most dilute|all species||||4000|dilution factor (1:x)|range high|
32|453|RESULTS: Cytochrome oxidase in the human entorhinal cortex|paragraph 1|The essential features of the EC seen by Nissl and CO staining were the same in the 3-day-old as in the adult specimens we examined; however, only adult tissue is shown in the figures.|age of youngest specimen|human|EC||3-day-old|3|days|restatement of METHODS|
33|453|RESULTS: human EC, Laminar and field CO reactivity|paragraph 1|This heterogeneity was the basis for subdividing the EC into seven distinct fields (Amaral et al., '87).|number of EC fields (nomenclature)|human|EC|||seven|fields|count|Amaral et al., '87
34|453|RESULTS: human EC, Laminar and field CO reactivity|paragraph 1|Five of the fields are visible in the low magnification sections shown in Figure 1: Eo, ER, EI, Ec, and ECL.|number of EC fields visible in Figure 1|human|EC|||Five|fields|count|
35|455|RESULTS: human EC, Tangential sections|paragraph 2|The diameter of the CO islands was variable, but ranged mostly from 200-800 µm in layers I-II; a few CO islands were smaller or larger than these limits.|CO island diameter|human|EC|I-II|adult|200-800|µm|range (mostly)|
36|455|RESULTS: human EC, Tangential sections|paragraph 3|Two main groups of CO islands were recognized consistently: an anteromedial group and a posterolateral group.|number of CO island groups|human|EC|I-II|adult|Two|groups|count|
37|459|RESULTS: human EC, Tangential sections|paragraph 1|We counted 247 dark spots and 224 CO islands in the photographs shown in Figure 3A,B.|number of dark spots on the intact EC surface (one hemisphere, Fig. 3A)|human|EC surface||adult|247|dark spots|count (probable underestimate)|
38|459|RESULTS: human EC, Tangential sections|paragraph 1|We counted 247 dark spots and 224 CO islands in the photographs shown in Figure 3A,B.|number of CO islands (one hemisphere, Fig. 3B)|human|EC|I-II|adult|224|CO islands|count (probable underestimate)|
39|459|RESULTS: Cytochrome oxidase in the monkey entorhinal cortex|paragraph 1|Our results are based on studies of three different species of macaques.|number of macaque species|macaques|EC||adult|three|species|count|
]-"

to_grid <- function(txt, ncol) {
  g <- do.call(rbind, lapply(strsplit(trimws(txt), "\n", fixed = TRUE)[[1]], function(line) {
    x <- trimws(strsplit(line, "|", fixed = TRUE)[[1]])
    length(x) <- ncol
    x
  }))
  g[is.na(g)] <- ""
  g
}

freeze <- function(grid, file) {
  if (file.exists(file)) {
    old <- as.matrix(read.csv(file, header = FALSE, colClasses = "character",
                              na.strings = character(0), check.names = FALSE,
                              encoding = "UTF-8"))
    dimnames(old) <- NULL
    new <- grid; dimnames(new) <- NULL
    if (!identical(dim(old), dim(new)) || !identical(old, new))
      stop(basename(file), ": the frozen snapshot on disk differs from the block in this ",
           "script. Refusing to overwrite. Reconcile the difference against the PDF and ",
           "move the superseded file to archive/ before re-running.", call. = FALSE)
    message(basename(file), ": frozen snapshot already on disk and identical; nothing written.")
  } else {
    write.table(grid, file, sep = ",", row.names = FALSE, col.names = FALSE,
                qmethod = "double", fileEncoding = "UTF-8")
    message(basename(file), ": wrote ", nrow(grid), " rows x ", ncol(grid), " cols")
  }
}

grid_tx <- to_grid(printed_text, 14L)

stopifnot(nrow(grid_tx) == 40L)                      # header + 39 rows
stopifnot(identical(grid_tx[-1, 1], as.character(1:39)))
stopifnot(identical(grid_tx[1, 1], "text_row"))

freeze(grid_tx, file.path(folder, paste0(item_name, "_snapshot.csv")))
