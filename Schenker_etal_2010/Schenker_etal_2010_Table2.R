# Schenker et al. 2010 Table 2: BA44/45 volumes in 12 individual chimpanzees.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=', '', arg)))
root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(sub('^--file=', '', arg)))
x <- read.csv(file.path(folder, paste0(item, '_snapshot.csv')), check.names=FALSE,
              colClasses='character', na.strings=NULL)
x <- x[grepl('^C[0-9]{4}$', x$Subject),,drop=FALSE]
stopifnot(nrow(x)==12L, length(unique(x$Subject))==12L)
parts <- list()
for (side in c('Left','Right')) for (area in c('44','45')) {
  v <- as.numeric(x[[paste(side, area, 'volume (mm3)')]])
  ce <- as.numeric(x[[paste('CE', side, area)]])
  parts[[length(parts)+1L]] <- data.frame(
    source_row=seq_len(nrow(x)), species_as_published='Pan troglodytes',
    specimen_as_published=x$Subject, sex_as_published=x$Sex,
    age_years=as.numeric(x[['Age (years)']]), hemisphere=tolower(side),
    cortical_area=paste0('BA',area),
    whole_brain_volume_mm3=as.numeric(x[['Whole brain (cm3)']])*1000,
    neocortical_gray_volume_mm3=as.numeric(x[[paste(side,'neocortical gray (cm3)')]])*1000,
    cortical_area_volume_mm3=v, volume_coefficient_of_error=ce,
    volume_shrinkage_corrected=TRUE,
    observation_level='individual specimen x hemisphere x cortical area',
    data_role='primary', source=item, check.names=FALSE)
}
out <- do.call(rbind,parts)
out <- out[order(out$source_row, factor(out$hemisphere,c('left','right')),
                 factor(out$cortical_area,c('BA44','BA45'))),,drop=FALSE]
stopifnot(nrow(out)==48L, all(out$cortical_area_volume_mm3>0))
options(scipen=999)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
paths <- file.path(root,c('__ReadMe.xlsx','__ReadMeAddON.xlsx'))
hits <- lapply(paths,function(p){z<-readxl::read_excel(p,sheet='Sheet1');z[z[['Item name']]==item,,drop=FALSE]})
hits <- hits[vapply(hits,nrow,integer(1))==1L]
if(length(hits)!=1L)stop('Expected exactly one registry row')
code <- as.character(hits[[1]][['Item encoded']][1])
if(is.na(code)||!nzchar(code)||endsWith(code,'_'))stop('Invalid Item encoded')
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,': ',nrow(out),' rows\n',sep='')
