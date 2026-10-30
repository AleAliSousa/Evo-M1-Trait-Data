## Smaers JB, Gomez-Robles A, Parks AN, Sherwood CC (2017), Current Biology 27:714-720
## "Exceptional Evolutionary Expansion of Prefrontal Cortex in Great Apes and Humans."
## Table S1 ("Smaers data") = species-level gray & white volumes for primary-visual / prefrontal /
## other-association / frontal-motor.  NB: COMPILED from Smaers 2010 [S1] + 2011 [S2] (+ Brodmann [S3]);
## not newly collected. Units stated mm3 in source but values scale as cm3 (match 2011) -- FLAG.

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(folder)
options(scipen = 999)
clean <- read.csv("Smaers_etal_2017_TableS1_snapshot.csv", check.names = FALSE, stringsAsFactors = FALSE)
names(clean) <- c("species","primary_visual_gray","prefrontal_gray","other_association_gray","frontal_motor_gray",
                  "primary_visual_white","prefrontal_white","other_association_white","frontal_motor_white")
clean$species <- gsub(" ", "_", trimws(clean$species))
clean$source  <- "Smaers_etal_2017"
write.csv(clean, "Smaers_etal_2017_TableS1.csv", row.names = FALSE)
