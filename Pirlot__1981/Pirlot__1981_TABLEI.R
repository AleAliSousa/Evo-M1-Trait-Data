## Pirlot__1981_TABLEI
## Input : faithful TABLEI_snapshot.xlsx (two printed parts)
## Output: Pirlot__1981_TABLEI.csv and DOI-coded public TSV from __ReadMe.xlsx
options(scipen=999)
.sp <- local({
 for(fr in rev(sys.frames())) for(nm in c("ofile", "file")) {
  p <- fr[[nm]]
  if(is.character(p) && length(p)==1L && !is.na(p) && nzchar(p) &&
     grepl("\\.[Rr]$", p) && file.exists(p)) return(normalizePath(p))
 }
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
snap <- readxl::read_excel(paste0(item_name,"_snapshot.xlsx"), sheet="Sheet1",
 range="A1:G87", col_names=FALSE, col_types="text", .name_repair="minimal", trim_ws=FALSE)
header <- c("Species","Collection","Sex","Use","Body-weight","Brain-weight")
stopifnot(nrow(snap)==87L, ncol(snap)==7L, snap[[1]][1]=="TABLE I",
 identical(unlist(snap[4,2:7], use.names=FALSE), header),
 identical(unlist(snap[59,2:7], use.names=FALSE), header),
 snap[[6]][5]=="gr", snap[[7]][5]=="mgr", snap[[6]][60]=="gr", snap[[7]][60]=="mgr")
rows <- which(!is.na(snap[[1]]) & grepl("^\\([0-9]+\\)$", snap[[1]]))
stopifnot(length(rows)==50L, sum(rows>=9L & rows<=54L)==36L,
 sum(rows>=63L & rows<=80L)==14L)
clean <- as.data.frame(snap[rows,2:7], stringsAsFactors=FALSE)
names(clean) <- c("species","collection","sex","use","body_weight_g","brain_weight_mg")
clean$source <- item_name
clean$specimen_number <- as.integer(gsub("[()]", "", snap[[1]][rows]))
stopifnot(identical(clean$specimen_number, seq_len(50L)), !anyNA(as.matrix(clean)),
 !anyDuplicated(clean$collection), all(grepl("^[PJ][0-9]+$", clean$collection)),
 sum(startsWith(clean$collection,"P"))==5L, sum(startsWith(clean$collection,"J"))==45L,
 all(clean$sex %in% c("M","F","?")), all(clean$use %in% c("S","W")))
clean$species_as_printed <- clean$species
stopifnot(all(nzchar(trimws(clean$species))))
## Expand only idem with its optional printed (x) qualifier; retain the literal label separately.
idem <- grepl("^idem( ?\\(x\\))?$", clean$species_as_printed)
for(j in which(idem)) {
 stopifnot(j>1L)
 clean$species[j] <- clean$species[j-1L]
 if(grepl("\\(x\\)$", clean$species_as_printed[j]) && !grepl("\\(x\\)$", clean$species[j]))
  clean$species[j] <- paste(clean$species[j],"(x)")
}
stopifnot(!any(grepl("^idem", clean$species)))
num <- function(x) {
 if(anyNA(x) || any(!grepl("^[0-9]+(\\.[0-9]+)?$", x)))
  stop("TABLE I: missing or invalid weight.", call.=FALSE)
 x <- as.numeric(x)
 stopifnot(all(is.finite(x)), all(x>0))
 x
}
clean$body_weight_g <- num(clean$body_weight_g)
clean$brain_weight_parenthetical <- grepl("^\\([0-9]+(\\.[0-9]+)?\\)$", clean$brain_weight_mg)
brain <- num(ifelse(clean$brain_weight_parenthetical,
 substring(clean$brain_weight_mg,2L,nchar(clean$brain_weight_mg)-1L), clean$brain_weight_mg))
stopifnot(sum(clean$brain_weight_parenthetical)==1L, clean$brain_weight_parenthetical[11L],
 clean$brain_weight_mg[11L]=="(2200)", brain[11L]==2200)
message(item_name, ": validated 50 numbered specimens, unique collection codes, use codes and weights; ",
 sum(idem), " idem labels expanded. (2200) retained as printed; TABLE I has no printed total.")
utils::write.csv(clean, paste0(item_name,".csv"), row.names=FALSE, na="NA")
if(!is.na(base)) {
 fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1")
 item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
 out_dir <- file.path(base,"__Public","comparative-data")
 if(!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(out_dir)) utils::write.table(clean,file.path(out_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped: registry entry or output directory unavailable.")
} else warning("Repository root not found; public TSV skipped.")
message(item_name,": ",nrow(clean)," rows written")
