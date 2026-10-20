## Nudo_Masterton_1990_IV_Figure2A.R -- frozen printed Fig. 2A (p.587, PDF page 4) -> analysis CSV.
## Staged build: writes only the analysis CSV by default; no public TSV write attempted here.
self <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(self)
item_name <- tools::file_path_sans_ext(basename(self))
setwd(folder)

snap <- utils::read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                         colClasses = "character", check.names = FALSE, fill = TRUE,
                         blank.lines.skip = FALSE, na.strings = NULL, skip = 2,
                         fileEncoding = "UTF-8")
names(snap) <- as.character(snap[1, ])
body <- snap[-1, , drop = FALSE]

interpreted_taxon <- c(
  "RACCOON- P.l." = "Procyon lotor", "ALBINO RAT- R.r." = NA,
  "MOLE- S.a." = "Scalopus aquaticus", "MONKEY- C.a." = "Cercopithecus aethiops",
  "VOLE- P.p." = "Pitymys pinetorum", "SLOW LORIS- N.c." = "Nycticebus coucang",
  "HEDGEHOG- E.e." = "Erinaceus europaeus", "GROUND SQUIRREL- ..." = NA,
  "BUSHBABY- G.s." = "Galago senegalensis", "MONKEY- S.s." = "Saimiri sciureus",
  "MONKEY- M.m." = "Macaca mulatta", "GRAY SQUIRREL- S.c." = "Sciurus carolinensis",
  "HEDGEHOG- E.a." = "Erinaceus albiventris", "OPOSSUM- D.v." = "Didelphis virginiana",
  "MARMOSET- C.j." = "Callithrix jacchus", "CAT- F.d." = "Felis catus",
  "RABBIT- O.c." = "Oryctolagus cuniculus", "MONKEY- M.f." = "Macaca fascicularis",
  "HEDGEHOG- H.a." = "Hemiechinus auritus", "LST. SHREW- C.p." = "Cryptotis parva",
  "TREE SHREW- T.g." = "Tupaia glis", "OPOSSUM- M.d." = "Monodelphis domestica"
)

num <- function(x) suppressWarnings(as.numeric(x))
out <- data.frame(
  rank = num(body[["rank"]]),
  animal_name_as_published = body[["animal_name_as_published"]],
  REG_A_sqmm = num(body[["REG_A_sqmm"]]), REG_B_sqmm = num(body[["REG_B_sqmm"]]),
  REG_C_sqmm = num(body[["REG_C_sqmm"]]), REG_Cprime_sqmm = num(body[["REG_Cprime_sqmm"]]),
  CST_cortex_sqmm = num(body[["CST_cortex_sqmm"]]), total_cortex_sqmm = num(body[["total_cortex_sqmm"]]),
  pct_CST_over_total_cortex = num(body[["pct_CST_over_total_cortex"]]),
  stringsAsFactors = FALSE
)
out$interpreted_taxon <- interpreted_taxon[out$animal_name_as_published]
out$data_role <- "primary"
out$source_table <- "Figure 2A"
out$source_printed_page <- 587
out$source_pdf_page <- 4
out$DOI <- "10.1002/cne.902960406"
out$Reference <- item_name

## sanity check: REG_A+B+C+C' == CST_cortex (within rounding), and CST/total == printed pct
stopifnot(all(abs((out$REG_A_sqmm+out$REG_B_sqmm+out$REG_C_sqmm+out$REG_Cprime_sqmm) - out$CST_cortex_sqmm) < 0.05))
stopifnot(all(abs(round(100*out$CST_cortex_sqmm/out$total_cortex_sqmm, 1) - out$pct_CST_over_total_cortex) < 0.15))

utils::write.csv(out, paste0(item_name, ".csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(out), " rows written (analysis CSV only; no public TSV)")
