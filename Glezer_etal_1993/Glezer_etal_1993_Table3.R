## Layer-level averages across five toothed-whale species; no species rows.
me <- "Glezer_etal_1993_Table3.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),
  check.names=FALSE,colClasses="character")
stopifnot(nrow(snap)==6L,ncol(snap)==4L)
pm <- function(x) {
 p <- strsplit(x," ± ",fixed=TRUE)
 stopifnot(all(lengths(p)==2L))
 matrix(as.numeric(unlist(p)),ncol=2L,byrow=TRUE)
}
gaba <- pm(snap[[2]]); pv_cb <- pm(snap[[3]])
diff <- as.numeric(gsub("−","-",snap[[4]],fixed=TRUE))
stopifnot(!anyNA(gaba),!anyNA(pv_cb),!anyNA(diff))
final.dataframe <- data.frame(
 source_row=seq_len(nrow(snap)),cortical_layer_as_published=snap[[1]],
 taxon_group_as_published="five toothed-whale species",
 GABA_positive_percent=gaba[,1],GABA_positive_SD=gaba[,2],
 PV_plus_CB_positive_percent=pv_cb[,1],PV_plus_CB_positive_SD=pv_cb[,2],
 PV_plus_CB_minus_GABA_percent_as_published=diff,
 recomputed_difference_from_printed_means=pv_cb[,1]-gaba[,1],
 observation_level=ifelse(snap[[1]]=="AVG","cross-layer source average","layer average across five species"),
 data_role="source group mean; not species-level data",stringsAsFactors=FALSE)
## VI prints −2.3 despite 23.2−26=−2.8; AVG differs by 0.1,
## plausibly because printed means were rounded. Never replace either.
stopifnot(abs(final.dataframe$recomputed_difference_from_printed_means[5]-
              final.dataframe$PV_plus_CB_minus_GABA_percent_as_published[5])>0.4)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,".csv")),
  row.names=FALSE,na="",fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root,"__ReadMeAddON.xlsx"),sheet="Sheet1")
hit <- which(reg[["Item name"]]==item_name)
if (length(hit)!=1L) stop("Expected one AddON registry row")
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (!nzchar(item_encoded)||endsWith(item_encoded,"_")) stop("Invalid Item encoded")
utils::write.table(final.dataframe,
  file.path(root,"__Public","comparative-data",paste0(item_encoded,".tsv")),
  sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
cat(item_name,": ",nrow(final.dataframe)," source rows\n",sep="")
