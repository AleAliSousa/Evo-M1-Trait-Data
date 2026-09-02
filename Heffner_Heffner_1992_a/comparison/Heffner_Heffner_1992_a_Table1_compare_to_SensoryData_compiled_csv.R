## Compare Heffner_Heffner_1992_a_Table1.csv against the two independent extractions:
##  (a) ____Sensory_audiovisual/SensoryData_compiled_check/SensoryData_compiled.csv
##      (the Bath compilation check fixture; rows citing "Heffner and Heffner 1992a")
##  (b) the Bath student extraction sheet "Heffner Heffner 1992a" in hearing data.xlsx
##
## Committed reports were generated offline (no R in the build sandbox) by the
## Python mirror on 2026-08-31 with results: (a) 81 agree, 0 MISMATCH, 6 rows the
## compilation assigned to species not in Table 1 (Delphinus delphis x2,
## Hemiechinus auritus x3, Inia geoffrensis x1 -- compilation defects, see README);
## (b) 77 agree, 0 MISMATCH, 19 both-missing. Re-running this script must reproduce them.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript, or open in RStudio and Source.", call. = FALSE)
})
cmp_dir  <- dirname(.sp)
folder   <- dirname(cmp_dir)
base     <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  d
})
item     <- "Heffner_Heffner_1992_a_Table1"
paper_csv <- file.path(folder, paste0(item, ".csv"))
check_csv <- file.path(base, "____Sensory_audiovisual", "SensoryData_compiled_check", "SensoryData_compiled.csv")
student_x <- file.path(base, "____Sensory_audiovisual", "_incoming_Bath_archive_20260814",
                       "Part 2 Hearing data", "hearing data.xlsx")

library(tidyverse)
library(readxl)

num15 <- function(x) ifelse(is.na(x), "", sprintf("%.15g", x))

paper <- read.csv(paper_csv, stringsAsFactors = FALSE)

## (a) vs compiled check fixture -----------------------------------
check <- read.csv(check_csv, stringsAsFactors = FALSE) %>%
  filter(reference == "Heffner and Heffner 1992a")
trait2col <- c(sound_localization_threshold = "sound_localization_threshold_deg",
               field_of_best_vision_width   = "field_of_best_vision_deg",
               binocular_field              = "binocular_field_deg",
               trophic_level                = "trophic_level",
               visual_acuity_max            = "visual_acuity_cdeg",
               interaural_distance_functional = "delta_t_us")
alias <- c("canis lupus familiaris" = "canis familiaris",
           "macaca fuscata"         = "macaca sp.",
           "felis silvestris catus" = "felis catus",
           "felis domesticus"       = "felis catus")
norm <- function(x) { x <- tolower(trimws(x)); ifelse(x %in% names(alias), alias[x], x) }

rep <- map_dfr(seq_len(nrow(check)), function(i) {
  c1  <- check[i, ]
  col <- trait2col[c1$trait]
  cand <- paper[norm(paper$binomial) == norm(c1$Species_SensoryData), ]
  if (is.na(col)) { status <- "trait_not_in_paper"; pv <- ""; ps <- "" }
  else if (nrow(cand) == 0) { status <- "species_not_in_paper"; pv <- ""; ps <- "" }
  else {
    vals <- num15(cand[[col]])
    hit  <- which(vals == num15(as.numeric(c1$value_num)))
    if (length(hit)) { status <- "agree"; pv <- vals[hit[1]]; ps <- cand$Species_HH1992a[hit[1]] }
    else { status <- "MISMATCH"; pv <- paste(vals, collapse = "|"); ps <- paste(cand$Species_HH1992a, collapse = "|") }
  }
  tibble(check_value_id = c1$value_id, check_species = c1$Species_SensoryData,
         check_trait = c1$trait, check_value = c1$value,
         status = status, paper_value = pv, paper_species_row = ps)
})
write.csv(rep,  file.path(cmp_dir, paste0(item, "_comparison_report_from_R.csv")), row.names = FALSE)
write.csv(filter(rep, status == "MISMATCH"),
          file.path(cmp_dir, paste0(item, "_mismatches_from_R.csv")), row.names = FALSE)
print(count(rep, status))
stopifnot(sum(rep$status == "MISMATCH") == 0)

## (b) vs Bath student extraction sheet ----------------------------
stud <- read_excel(student_x, sheet = "Heffner Heffner 1992a", col_names = FALSE, skip = 1, n_max = 24)
scols <- c(`4` = "sound_localization_threshold_deg", `7` = "delta_t_us",
           `8` = "field_of_best_vision_deg", `9` = "visual_acuity_cdeg")  # 1-based sheet cols
smap  <- c("japanese macaque" = "macaque")
srep <- map_dfr(seq_len(nrow(stud)), function(i) {
  name <- tolower(trimws(as.character(stud[i, 2])))
  name <- ifelse(name %in% names(smap), smap[name], name)
  p <- paper[paper$Species_HH1992a == name, ]
  map_dfr(names(scols), function(ci) {
    sv <- as.character(stud[i, as.integer(ci)])
    sv <- ifelse(is.na(sv) | trimws(sv) %in% c("-", "—", ""), "",
                 sprintf("%.15g", suppressWarnings(as.numeric(sv))))
    pv <- num15(p[[scols[ci]]][1])
    tibble(student_species = as.character(stud[i, 2]), column = scols[ci],
           status = ifelse(sv == "" & pv == "", "both_missing",
                           ifelse(sv == pv, "agree", "MISMATCH")),
           student_value = sv, paper_value = pv)
  })
})
write.csv(srep, file.path(cmp_dir, paste0(item, "_vs_student_sheet_from_R.csv")), row.names = FALSE)
print(count(srep, status))
stopifnot(sum(srep$status == "MISMATCH") == 0)
