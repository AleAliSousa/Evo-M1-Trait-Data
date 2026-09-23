## Pirlot_Nelson_1978_TABLE3
## Input : Pirlot_Nelson_1978_TABLE3_snapshot.csv
## Output: Pirlot_Nelson_1978_TABLE3.csv and DOI-coded public TSV from __ReadMe.xlsx
options(scipen=999)
.sp <- local({
 a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
 if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
 if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
  p <- rstudioapi::getSourceEditorContext()$path
  if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
  if(nzchar(p)) return(normalizePath(p))
 }
 stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); setwd(folder)
base <- local({ d <- folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d <- dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
snap <- read.csv("Pirlot_Nelson_1978_TABLE3_snapshot.csv", check.names=FALSE, stringsAsFactors=FALSE, na.strings=c("","NA"))
stopifnot(nrow(snap)==36L)
clean <- snap; clean$source <- "Pirlot_Nelson_1978_TABLE3"
write.csv(clean, paste0(item_name,".csv"), row.names=FALSE, na="NA")
if(!is.na(base)) {
 fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1")
 item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
 out_dir <- file.path(base,"__Public","comparative-data")
 if(!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(out_dir)) write.table(clean,file.path(out_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped: registry entry or output directory unavailable.")
} else warning("Repository root not found; public TSV skipped.")
message(item_name,": ",nrow(clean)," rows written")
