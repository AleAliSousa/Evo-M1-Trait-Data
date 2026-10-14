## Pirlot__1981_TABLEII
## Input : faithful manual TABLEII_snapshot.xlsx (three printed panels)
## Output: Pirlot__1981_TABLEII.csv and DOI-coded public TSV from __ReadMe.xlsx
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
 range="A1:AJ25", col_names=FALSE, col_types="text", .name_repair="minimal", trim_ws=FALSE)
stopifnot(nrow(snap)==25L, ncol(snap)==36L, snap[[1]][1]=="TABLE II",
 grepl("volumes in cubic mm for 12 brain components", snap[[1]][2], fixed=TRUE))
component <- c("BO","N","RH","PY","S","Di","STR","Hi","M","C","O","Sz")
panels <- list(3:17, 21:31, 35:36)
labels <- c(1L,19L,33L)
num <- function(x) {
 if(anyNA(x) || any(!grepl("^[0-9]+(\\.[0-9])?$", x)))
  stop("TABLE II: missing or invalid number (expected source precision of one decimal).", call.=FALSE)
 x <- as.numeric(x)
 stopifnot(all(is.finite(x)), all(x>0))
 x
}
clean <- do.call(rbind, lapply(seq_along(panels), function(k) {
 cols <- panels[[k]]; lab <- labels[k]
 code <- snap[[lab]][10:21]
 ## Only the printed BO/Bo and Hi/HI/H variants are normalised, within this item.
 code[code=="Bo" & !is.na(code)] <- "BO"
 code[code %in% c("HI","H")] <- "Hi"
 stopifnot(identical(code, component), snap[[lab]][9]=="Volumes",
  is.na(snap[[lab]][24]), gsub("[[:space:]]", "", snap[[lab]][25])=="RHPY",
  snap[[lab+1L]][25]=="}", all(is.na(snap[[lab+1L]][9:24])),
  all(is.na(as.matrix(snap[22:23,c(lab,cols)]))))
 values <- t(vapply(cols, function(j) num(snap[[j]][10:21]), numeric(12)))
 colnames(values) <- paste0(component,"_mm3")
 data.frame(species=unlist(snap[9,cols], use.names=FALSE), values,
  check.names=FALSE, stringsAsFactors=FALSE)
}))
stopifnot(nrow(clean)==28L, !anyNA(clean$species), all(nzchar(trimws(clean$species))),
 !anyDuplicated(clean$species))
clean$source <- item_name
clean$O_mm3_raw <- clean$O_mm3
cols <- unlist(panels, use.names=FALSE)
clean$total_brain_printed_mm3 <- num(unlist(snap[24,cols], use.names=FALSE))
clean$RH_PY_printed_mm3 <- num(unlist(snap[25,cols], use.names=FALSE))
## Integer tenths compare the printed precision exactly, without NA suppression or adaptive tolerance.
raw_sum <- rowSums(round(as.matrix(clean[paste0(component,"_mm3")])*10))
printed_total <- round(clean$total_brain_printed_mm3*10)
clean$total_components_raw_mm3 <- raw_sum/10
clean$total_brain_matches_raw <- raw_sum==printed_total
clean$RH_PY_calculated_mm3 <- (round(clean$RH_mm3*10)+round(clean$PY_mm3*10))/10
clean$RH_PY_matches <- round(clean$RH_PY_calculated_mm3*10)==round(clean$RH_PY_printed_mm3*10)
## Owner-authorised exception to keep-print errata policy; not a general total-balancing rule.
i <- which(clean$species=="Didelphis marsupialis")
stopifnot(length(i)==1L, snap[[9]][9]=="Didelphis marsupialis",
 round(clean$O_mm3_raw[i]*10)==660, raw_sum[i]==59850, printed_total[i]==64850)
other <- raw_sum[i]-round(clean$O_mm3_raw[i]*10)
candidate <- printed_total[i]-other
stopifnot(other==59190, candidate==5660, !clean$total_brain_matches_raw[i],
 round(clean$RH_PY_printed_mm3[i]*10)==11836, clean$RH_PY_matches[i])
clean$O_mm3[i] <- candidate/10
clean$O_mm3_corrected <- seq_len(nrow(clean))==i
clean$total_components_mm3 <- rowSums(round(as.matrix(clean[paste0(component,"_mm3")])*10))/10
clean$total_brain_matches <- round(clean$total_components_mm3*10)==printed_total
stopifnot(round(clean$total_components_mm3[i]*10)==64850, clean$total_brain_matches[i])
message(item_name, ": owner-confirmed/sum-inferred O_mm3 correction 66.0 -> 566.0; ",
 "raw total 5985.0; other 11 components 5919.0; corrected total 6485.0. Raw value retained.")
bad <- !clean$total_brain_matches
if(any(bad)) warning("Printed total mismatch (components minus print, mm3): ",
 paste0(clean$species[bad], " (", sprintf("%.1f", clean$total_components_mm3[bad]-clean$total_brain_printed_mm3[bad]), ")", collapse="; "),
 ". Values retained; no balancing correction.", call.=FALSE)
if(any(!clean$RH_PY_matches)) warning("Printed RH+PY mismatch: ",
 paste(clean$species[!clean$RH_PY_matches], collapse="; "), ". Values retained.", call.=FALSE)
utils::write.csv(clean, paste0(item_name,".csv"), row.names=FALSE, na="NA")
if(!is.na(base)) {
 fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1")
 item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
 out_dir <- file.path(base,"__Public","comparative-data")
 if(!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(out_dir)) utils::write.table(clean,file.path(out_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped: registry entry or output directory unavailable.")
} else warning("Repository root not found; public TSV skipped.")
message(item_name,": ",nrow(clean)," rows written")
