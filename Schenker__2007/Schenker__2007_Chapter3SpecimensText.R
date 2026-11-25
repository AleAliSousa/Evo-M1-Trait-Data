# Chapter III Methods constructed roster: case-specific facts and qualified defaults.
arg <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(length(arg)!=1L)stop('Run with Rscript')
script <- normalizePath(sub('^--file=','',arg))
folder <- dirname(script);root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(script))
x <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),check.names=FALSE,
              colClasses='character',na.strings=NULL)
stopifnot(nrow(x)==14L,length(unique(x[['Specimen ID']]))==14L)
out <- data.frame(
 source_row=seq_len(nrow(x)),taxon_as_published=x$Species,
 specimen_as_published=x[['Specimen ID']],
 section_plane_as_published=x[['Section plane']],
 section_thickness_as_published=x[['Section thickness (um)']],
 section_thickness_um=as.numeric(sub(' .*','',x[['Section thickness (um)']])),
 stain_as_published=x$Stain,
 mounted_section_interval_as_published=x[['Mounted-section interval']],
 origin_as_published=x$Origin,
 language_training_as_published=x[['Language training']],
 neuropathology_cause_of_death_as_published=x[['Neuropathology cause of death']],
 processing_evidence=x[['Processing evidence']],
 observation_level='individual specimen; explicit details or qualified cohort defaults',
 data_role='primary',source=item,check.names=FALSE)
stopifnot(all(out$section_thickness_um>0))
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
hits <- lapply(file.path(root,c('__ReadMe.xlsx','__ReadMeAddON.xlsx')),function(p){
 z<-readxl::read_excel(p,sheet='Sheet1');z[z[['Item name']]==item,,drop=FALSE]})
hits <- hits[vapply(hits,nrow,integer(1))==1L]
if(length(hits)!=1L)stop('Expected exactly one registry row')
code <- as.character(hits[[1]][['Item encoded']][1])
if(is.na(code)||!nzchar(code)||endsWith(code,'_'))stop('Invalid Item encoded')
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,': ',nrow(out),' rows\n',sep='')
