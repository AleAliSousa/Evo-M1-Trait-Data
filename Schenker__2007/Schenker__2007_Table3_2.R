# Chapter III Table 3.2: neuron counts and both density bases.
arg <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(length(arg)!=1L)stop('Run with Rscript')
script <- normalizePath(sub('^--file=','',arg))
folder <- dirname(script); root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(script))
x <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),check.names=FALSE,
              colClasses='character',na.strings=NULL)
stopifnot(nrow(x)==14L,length(unique(x[['Specimen ID']]))==14L)
number <- function(z) suppressWarnings(as.numeric(z))
parts <- list()
for(side in c('L','R')) for(area in c('44','45')) {
  prefix <- paste('Area',area)
  parts[[length(parts)+1L]] <- data.frame(
    source_row=seq_len(nrow(x)),taxon_as_published=x$Species,
    specimen_as_published=x[['Specimen ID']],
    hemisphere=if(side=='L')'left' else 'right',cortical_area=paste0('BA',area),
    n_neurons=number(x[[paste(prefix,'Count',side,'(x10^6)')]])*1000000,
    neuron_density_uncorrected_per_mm3=number(x[[paste(prefix,'Uncorrected Density',side,'(1000s/mm3)')]])*1000,
    neuron_density_corrected_per_mm3=number(x[[paste(prefix,'Corrected Density',side,'(1000s/mm3)')]])*1000,
    observation_level='individual specimen x hemisphere x cortical area',
    data_role='primary',source=item,check.names=FALSE)
}
out <- do.call(rbind,parts)
out <- out[order(out$source_row,factor(out$hemisphere,c('left','right')),
                 factor(out$cortical_area,c('BA44','BA45'))),,drop=FALSE]
# CS025, 1548, and A375 have printed dashes in every neuron-data cell.
out <- out[!is.na(out$n_neurons),,drop=FALSE]
stopifnot(nrow(out)==44L,length(unique(out$specimen_as_published))==11L,
          all(out$n_neurons>0))
options(scipen=999)
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
