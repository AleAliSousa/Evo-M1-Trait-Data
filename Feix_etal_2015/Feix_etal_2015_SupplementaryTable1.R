## Frozen printed model-output table -> analysis CSV -> registry-coded public TSV.
.sp <- local({
  a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
  if(length(a))return(normalizePath(sub('^--file=','',a[1])))
  for(i in rev(seq_len(sys.nframe()))){p <- sys.frame(i)$ofile;if(!is.null(p))return(normalizePath(p))}
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp);item_name <- tools::file_path_sans_ext(basename(.sp));base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,
  stringsAsFactors=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
stopifnot(nrow(snap)==45L,ncol(snap)==6L)
# The printed group cell spans each block; carry its first-row label in R.
for (j in seq_len(nrow(snap))[-1]) if (is.na(snap$Group[j])) snap$Group[j] <- snap$Group[j-1]
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication==basename(folder),]
i <- match(snap$Species,key$variant_name);stopifnot(!anyNA(i))
measure <- c('N','peak workspace','relative object size (R)','real object size R (mm)')
for(x in measure) snap[[x]] <- as.numeric(snap[[x]])
stopifnot(!anyNA(snap[,measure]),all(snap$N>=1L),all(snap[[measure[2]]]>0),all(snap[[measure[3]]]>0),all(snap[[measure[4]]]>0))
variant <- ifelse(grepl('\\(Pan\\)$',snap$Species),'Pan',ifelse(grepl('\\(Human\\)$',snap$Species),'Human',''))
final.dataframe <- data.frame(source_row=seq_len(nrow(snap)),group_as_published=snap$Group,
 species_as_published=snap$Species,N_as_published=snap$N,
 peak_workspace=snap[['peak workspace']],relative_object_size_R=snap[['relative object size (R)']],
 real_object_size_R_mm=snap[['real object size R (mm)']],model_variant=variant,
 Species=key$accepted_name[i],observation_level=ifelse(snap$Group=='Fossils','fossil individual/composite model','taxon model summary'),
 data_role='primary modeled output',check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(sum(final.dataframe$group_as_published=='Fossils',na.rm=TRUE)==7L,sum(nzchar(variant))==4L)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')
