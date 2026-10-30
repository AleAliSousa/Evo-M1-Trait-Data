## Kochiyama_etal_2018 — Figure 3A
## Relative volumes (region volume / mean MH volume; MH = 1.0) of the 13 parcellated
## regions among NT, EH and MH, read from the Figure 3(a) bar graphs.
##
## This script intentionally handles Figure 3A only. Figure 3B is a separate item.

options(scipen = 999)
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
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)

structure_map <- c("Fr SM"="FrontalLobe","Fr I"="FrontalLobe","Fr O"="FrontalLobe",
  "Sm"="SensorimotorCortex","Pa SI"="ParietalLobe","Pa TP"="ParietalLobe",
  "Te SM"="TemporalLobe","Te I"="TemporalLobe","Oc SM"="OccipitalLobe",
  "Oc I"="OccipitalLobe","Ce V"="Cerebellum","Ce A"="Cerebellum","Ce P"="Cerebellum")
subregion_map <- c("Fr SM"="superior and middle","Fr I"="inferior","Fr O"="orbitofrontal",
  "Sm"="whole (sensorimotor)","Pa SI"="superior and inferior","Pa TP"="temporo-parietal junction",
  "Te SM"="superior and middle","Te I"="inferior/medial","Oc SM"="superior and middle",
  "Oc I"="inferior","Ce V"="vermis","Ce A"="anterior","Ce P"="posterior")

raw <- read.csv("Kochiyama_etal_2018_Figure3A_snapshot.csv", skip = 1,
                colClasses = "character", check.names = FALSE, na.strings = c("", "NA"))
as_num <- function(x) suppressWarnings(as.numeric(x))
clean <- data.frame(
  Region_code = raw$Region,
  Structure = unname(structure_map[raw$Region]),
  Subregion = unname(subregion_map[raw$Region]),
  NT_rel = as_num(raw$NT_rel),
  EH_rel = as_num(raw$EH_rel),
  MH_rel = as_num(raw$MH_rel),
  source = "Kochiyama_etal_2018",
  note = "Figure 3A; figure-digitized (+/-0.02); ICV-size-adjusted",
  stringsAsFactors = FALSE)
stopifnot(nrow(clean) == 13L, !anyNA(clean$Structure), !anyNA(clean$Subregion))
write.csv(clean, paste0(item_name, ".csv"), row.names = FALSE)
write.table(clean, "10.1038%2Fs41598-018-24331-0_Figure3A.tsv", sep = "\t", row.names = FALSE, quote = FALSE)
message(item_name, ": ", nrow(clean), " rows")
