## Olkowicz et al. 2016 — bird brain cell counts (Table S1)  [SCAFFOLD / STUB — BLOCKED]
## doi:10.1073/pnas.1517131113
##
## SCAFFOLD + BLOCKED: non-mammal. The taxonomy resolver is MDD/mammal-only and will drop
## birds silently. Do the resolver + Class work in SCOPING_backbone_traits_and_taxonomy.md
## (do-first steps 1 & 4) BEFORE building this. This script only sets up paths and stops.
## See Olkowicz_etal_2016_TableS1.README.md.

## 0. PATHS — self-contained ----------------------------------------------------------------
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
paper_dir    <- dirname(.sp)
table_name   <- "Olkowicz_etal_2016_TableS1"
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
pdf_file <- file.path(paper_dir, "TODO_Olkowicz_etal_2016.pdf")

stop("SCAFFOLD/BLOCKED: non-mammal. De-MDD the taxonomy resolver and add a Class column ",
     "(SCOPING do-first steps 1 & 4) before building Olkowicz 2016. ",
     "See Olkowicz_etal_2016_TableS1.README.md.", call. = FALSE)

## TODO after unblocking: extract Table S1 (28 spp.; telencephalon/pallium, cerebellum, RoB,
## optic tectum; neuron & non-neuronal numbers/densities); frozen snapshot before cleaning;
## CSV + public TSV; register; add to the appropriate merge's item_name with a Class tag.
