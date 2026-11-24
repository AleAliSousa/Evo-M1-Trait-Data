a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=","",a[1])))
item_name <- "ClippertonAllen_etal_2019_TableS2";root <- dirname(folder)
s <- suppressMessages(readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")),col_names=FALSE))
stopifnot(nrow(s)>=157L,ncol(s)>=4L)
v <- lapply(s[1:4],as.character)
section <- rep(NA_character_,nrow(s)); current <- NA_character_
for (i in seq_len(nrow(s))) {
 if (i>2L && !is.na(v[[1]][i]) && is.na(v[[2]][i]) && is.na(v[[3]][i]) && is.na(v[[4]][i])) current <- v[[1]][i]
 section[i] <- current
}
keep <- which(!is.na(v[[3]]) & seq_len(nrow(s))>2L)
out <- data.frame(source_xlsx_row=keep,section_as_published=section[keep],analysis_as_published=ifelse(is.na(v[[1]][keep]),"",v[[1]][keep]),effect_as_published=ifelse(is.na(v[[2]][keep]),"",v[[2]][keep]),statistics_as_published=v[[3]][keep],effect_size_as_published=ifelse(is.na(v[[4]][keep]),"",v[[4]][keep]),data_role="published inferential statistics; not raw brain volume observations",stringsAsFactors=FALSE)
stopifnot(nrow(out)>100L,all(nzchar(out$statistics_as_published)))
utils::write.csv(out,file.path(folder,paste0(item_name,".csv")),row.names=FALSE,na="",fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root,"__ReadMeAddON.xlsx"),sheet="Sheet1")
hit <- which(reg[["Item name"]]==item_name);if(length(hit)!=1L) stop("Expected one AddON registry row")
encoded <- as.character(reg[["Item encoded"]][hit])
utils::write.table(out,file.path(root,"__Public","comparative-data",paste0(encoded,".tsv")),sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
cat(item_name,": ",nrow(out)," statistical result rows\n",sep="")
