# Chapter III Table 3.1a: uncorrected hemisphere and BA44/45 volumes.
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
  a <- number(x[[paste('Area',area,side,'(mm3)')]])
  parts[[length(parts)+1L]] <- data.frame(
    source_row=seq_len(nrow(x)),taxon_as_published=x$Species,
    specimen_as_published=x[['Specimen ID']],age_as_published=x$Age,
    age_years=number(x$Age),sex_as_published=x$Sex,
    brain_weight_g=number(x[['Brain Weight (g)']]),
    hemisphere=if(side=='L')'left' else 'right',cortical_area=paste0('BA',area),
    hemisphere_volume_uncorrected_mm3=number(x[[paste('Hemisphere',side,'(cm3)')]])*1000,
    cortical_area_volume_uncorrected_mm3=a,
    observation_level='individual specimen x hemisphere x cortical area',
    data_role='primary',source=item,check.names=FALSE)
}
out <- do.call(rbind,parts)
out <- out[order(out$source_row,factor(out$hemisphere,c('left','right')),
                 factor(out$cortical_area,c('BA44','BA45'))),,drop=FALSE]
# One human (CS025) has no right-hemisphere BA measurements.
out <- out[!is.na(out$cortical_area_volume_uncorrected_mm3),,drop=FALSE]
stopifnot(nrow(out)==54L,length(unique(out$specimen_as_published))==14L)
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
